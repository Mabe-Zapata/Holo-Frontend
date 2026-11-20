import 'package:material_ui/material_ui.dart';

import '../../core/api_client.dart';
import '../../core/rutas.dart';
import '../../core/sesion.dart';
import '../../core/tema.dart';
import '../crisis/crisis_screen.dart';
import '../crisis/recursos_ayuda.dart';
import 'widgets/indicador_escribiendo.dart';
import 'widgets/lista_mensajes.dart';
import 'widgets/mensaje.dart';

/// Pantalla de conversación con el asistente (HU-05, RF-07).
///
/// Carga el historial con `GET /chat/historial` y envía con `POST /chat`.
/// Si la respuesta es de crisis, abre la pantalla de crisis con sus datos.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.api});

  /// Permite inyectar el cliente en pruebas; por defecto usa la sesión activa.
  final ApiClient? api;

  @override
  State<ChatScreen> createState() => _ChatEstado();
}

class _ChatEstado extends State<ChatScreen> {
  final List<Mensaje> _mensajes = [];
  final TextEditingController _entrada = TextEditingController();
  late final ApiClient _api =
      widget.api ?? ApiClient(usuarioId: Sesion.usuarioId);

  bool _cargando = true;
  bool _enviando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  @override
  void dispose() {
    _entrada.dispose();
    super.dispose();
  }

  Future<void> _cargarHistorial() async {
    try {
      final datos = await _api.get('/chat/historial') as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _mensajes
          ..clear()
          ..addAll(datos.map((m) {
            final mapa = m as Map<String, dynamic>;
            return Mensaje(
                autor: mapa['autor'] as String, texto: mapa['texto'] as String);
          }));
      });
    } catch (e) {
      if (mounted) setState(() => _error = mensajeDeError(e));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _enviar() async {
    final texto = _entrada.text.trim();
    if (texto.isEmpty || _enviando) return;
    setState(() {
      _mensajes.add(Mensaje(autor: 'usuario', texto: texto));
      _entrada.clear();
      _enviando = true;
      _error = null;
    });
    try {
      final respuesta =
          await _api.post('/chat', {'texto': texto}) as Map<String, dynamic>;
      if (!mounted) return;
      if (respuesta['tipo'] == 'crisis') {
        Navigator.pushNamed(
          context,
          Rutas.crisis,
          arguments: DatosCrisis.desde(respuesta),
        );
      } else {
        setState(() => _mensajes.add(
              Mensaje(autor: 'asistente', texto: respuesta['texto'] as String),
            ));
      }
    } catch (e) {
      if (mounted) setState(() => _error = mensajeDeError(e));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
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
                : ListaMensajes(mensajes: _mensajes),
          ),
          if (_enviando) const IndicadorEscribiendo(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                _error!,
                style: tema.textTheme.bodySmall
                    ?.copyWith(color: tema.colorScheme.error),
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
                    onPressed: _enviando ? null : _enviar,
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
