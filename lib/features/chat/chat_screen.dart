import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../core/api_client.dart';
import '../../core/cola_envios.dart';
import '../../core/rutas.dart';
import '../../core/sesion.dart';
import '../../core/tema.dart';
import '../crisis/crisis_screen.dart';
import '../crisis/recursos_ayuda.dart';
import 'widgets/indicador_escribiendo.dart';
import 'widgets/lista_mensajes.dart';
import 'widgets/mensaje.dart';

/// Pantalla de conversación con el asistente (HU-05, RF-07, HU-16).
///
/// Carga el historial con `GET /chat/historial` y envía con `POST /chat`.
/// Cada mensaje lleva un identificador: si la conexión falla, queda en una cola
/// local y se reenvía con el mismo identificador, sin duplicarse en el servidor.
/// Si la respuesta es de crisis, abre la pantalla de crisis con sus datos.
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    this.api,
    this.cola,
    this.intervaloReintento = const Duration(seconds: 20),
  });

  /// Permite inyectar el cliente en pruebas; por defecto usa la sesión activa.
  final ApiClient? api;

  /// Cola de mensajes sin confirmar. En pruebas se inyecta una en memoria.
  final ColaEnvios? cola;

  /// Cada cuánto se intenta reenviar lo que quedó pendiente.
  final Duration intervaloReintento;

  @override
  State<ChatScreen> createState() => _ChatEstado();
}

enum _Resultado { enviado, descartado, reintentar }

class _ChatEstado extends State<ChatScreen> {
  final List<Mensaje> _historial = [];
  final List<EnvioPendiente> _pendientes = [];
  final TextEditingController _entrada = TextEditingController();
  late final ApiClient _api =
      widget.api ?? ApiClient(usuarioId: Sesion.usuarioId);
  late final ColaEnvios _cola = widget.cola ?? ColaEnvios();
  Timer? _reintento;

  bool _cargando = true;
  bool _procesando = false;
  bool _ofrecerRecursos = false;
  String? _aviso;

  @override
  void initState() {
    super.initState();
    _iniciar();
    _reintento =
        Timer.periodic(widget.intervaloReintento, (_) => _procesarCola());
  }

  @override
  void dispose() {
    _reintento?.cancel();
    _entrada.dispose();
    super.dispose();
  }

  Future<void> _iniciar() async {
    await _recargarHistorial(alTerminarCarga: true);
    final pendientes = await _cola.pendientes();
    if (!mounted) return;
    setState(() => _pendientes
      ..clear()
      ..addAll(pendientes));
    await _procesarCola();
  }

  Future<void> _recargarHistorial({bool alTerminarCarga = false}) async {
    try {
      final datos = await _api.get('/chat/historial') as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _historial
          ..clear()
          ..addAll(datos.map((m) {
            final mapa = m as Map<String, dynamic>;
            return Mensaje(
                autor: mapa['autor'] as String, texto: mapa['texto'] as String);
          }));
      });
    } catch (e) {
      if (mounted) setState(() => _aviso = mensajeDeError(e));
    } finally {
      if (mounted && alTerminarCarga) setState(() => _cargando = false);
    }
  }

  Future<void> _enviar() async {
    final texto = _entrada.text.trim();
    if (texto.isEmpty) return;
    final envio = EnvioPendiente(id: generarIdEvento(), texto: texto);
    setState(() {
      _pendientes.add(envio);
      _entrada.clear();
      _aviso = null;
    });
    await _cola.encolar(envio);
    await _procesarCola();
  }

  /// Envía los pendientes en orden. Se detiene al primer fallo de conexión para
  /// no reordenar la conversación. Un proceso a la vez.
  Future<void> _procesarCola() async {
    if (_procesando || _pendientes.isEmpty) return;
    setState(() => _procesando = true);
    try {
      for (final envio in List.of(_pendientes)) {
        if (!mounted) return;
        final resultado = await _enviarUno(envio);
        if (resultado == _Resultado.reintentar) break;
      }
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  Future<_Resultado> _enviarUno(EnvioPendiente envio) async {
    try {
      final respuesta = await _api.post('/chat', {
        'texto': envio.texto,
        'id_evento': envio.id,
      }) as Map<String, dynamic>;
      await _quitar(envio.id);
      if (!mounted) return _Resultado.enviado;
      await _recargarHistorial();
      if (!mounted) return _Resultado.enviado;
      if (respuesta['tipo'] == 'crisis') {
        Navigator.pushNamed(
          context,
          Rutas.crisis,
          arguments: DatosCrisis.desde(respuesta),
        );
      }
      return _Resultado.enviado;
    } on ApiException catch (e) {
      // Errores del contenido o de la cuenta: reenviar no los arregla.
      if (e.codigo == 401 || e.codigo == 403 || e.codigo == 422) {
        await _quitar(envio.id);
        if (mounted) setState(() => _aviso = e.mensaje);
        return _Resultado.descartado;
      }
      _avisarFallo('No se pudo enviar. Lo reintentamos.');
      return _Resultado.reintentar;
    } catch (_) {
      _avisarFallo('Sin conexión. Lo reintentamos.');
      return _Resultado.reintentar;
    }
  }

  Future<void> _quitar(String id) async {
    await _cola.quitar(id);
    if (!mounted) return;
    setState(() => _pendientes.removeWhere((e) => e.id == id));
  }

  void _avisarFallo(String aviso) {
    if (!mounted) return;
    setState(() {
      _aviso = aviso;
      _ofrecerRecursos = true;
    });
  }

  void _mostrarRecursos(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (contexto) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: SingleChildScrollView(child: RecursosAyuda()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final visibles = [
      ..._historial,
      ..._pendientes.map((e) => Mensaje(autor: 'usuario', texto: e.texto)),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversación'),
        actions: [
          IconButton(
            tooltip: 'Recursos de ayuda',
            icon: const Icon(Icons.support_agent_outlined),
            onPressed: () => _mostrarRecursos(context),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, Rutas.crisis),
            icon: const Icon(Icons.emergency_outlined),
            label: const Text('SOS'),
            style:
                TextButton.styleFrom(foregroundColor: tema.colorScheme.error),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: tema.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.spa_outlined, color: HoloTema.marca, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Espacio protegido y confidencial',
                    style: tema.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _cargando
                ? const Center(child: Text('Cargando la conversación…'))
                : ListaMensajes(mensajes: visibles),
          ),
          if (_procesando) const IndicadorEscribiendo(),
          if (_aviso != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _aviso!,
                      style: tema.textTheme.bodySmall
                          ?.copyWith(color: tema.colorScheme.error),
                    ),
                  ),
                  if (_ofrecerRecursos)
                    TextButton(
                      onPressed: () => _mostrarRecursos(context),
                      child: const Text('Ver recursos de ayuda'),
                    ),
                ],
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _entrada,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _enviar(),
                      decoration: InputDecoration(
                        hintText: 'Escribe cómo te sientes…',
                        filled: true,
                        fillColor: tema.colorScheme.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _enviar,
                    tooltip: 'Enviar mensaje',
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: HoloTema.mostaza,
                      foregroundColor: const Color(0xFF281900),
                      disabledBackgroundColor:
                          tema.colorScheme.surfaceContainerHigh,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
