import 'package:material_ui/material_ui.dart';

import '../../core/api_client.dart';
import '../../core/rutas.dart';
import '../../core/sesion.dart';
import '../../core/tema.dart';

/// Consentimiento informado (HU-02, RF-02).
///
/// Las dos casillas empiezan desmarcadas: el consentimiento existe solo si la
/// persona las marca. Continuar envía `POST /consentimiento`.
class ConsentimientoScreen extends StatefulWidget {
  const ConsentimientoScreen({super.key, this.api});

  /// Permite inyectar el cliente en pruebas; por defecto usa la sesión activa.
  final ApiClient? api;

  @override
  State<ConsentimientoScreen> createState() => _ConsentimientoEstado();
}

class _ConsentimientoEstado extends State<ConsentimientoScreen> {
  bool _mayorDeEdad = false;
  bool _acepta = false;
  bool _enviando = false;
  String? _error;

  late final ApiClient _api =
      widget.api ?? ApiClient(usuarioId: Sesion.usuarioId);

  bool get _puedeContinuar => _mayorDeEdad && _acepta && !_enviando;

  Future<void> _continuar() async {
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      await _api.post('/consentimiento', {
        'mayor_de_edad': _mayorDeEdad,
        'acepta': _acepta,
      });
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Rutas.chat);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Consentimiento')),
      // SingleChildScrollView construye todo el contenido, incluido el botón.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tu bienestar y tu seguridad son lo primero',
              style: tema.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const _Clausula(
              icono: Icons.psychology_outlined,
              texto:
                  'Holo es un asistente de apoyo emocional. El material que usa es provisional y está pendiente de revisión por una especialista.',
            ),
            const _Clausula(
              icono: Icons.medical_services_outlined,
              texto:
                  'Holo no sustituye la terapia. No emite diagnósticos ni recomienda medicación.',
            ),
            const _Clausula(
              icono: Icons.lock_outline,
              texto:
                  'Los datos de esta demostración son ficticios. No se usan datos reales.',
            ),
            const _Clausula(
              icono: Icons.emergency_outlined,
              texto:
                  'En una emergencia o un riesgo para tu vida, Holo te muestra de inmediato los números de ayuda.',
              destacado: true,
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _mayorDeEdad,
              onChanged: _enviando
                  ? null
                  : (v) => setState(() => _mayorDeEdad = v ?? false),
              title: const Text('Confirmo que soy mayor de 18 años.'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              value: _acepta,
              onChanged: _enviando
                  ? null
                  : (v) => setState(() => _acepta = v ?? false),
              title: const Text(
                'He leído y acepto el uso de mis mensajes para esta demostración.',
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error!,
                  style: tema.textTheme.bodySmall
                      ?.copyWith(color: tema.colorScheme.error),
                ),
              ),
            FilledButton(
              onPressed: _puedeContinuar ? _continuar : null,
              child:
                  Text(_enviando ? 'Enviando…' : 'Continuar a la conversación'),
            ),
            const SizedBox(height: 8),
            if (!_puedeContinuar && !_enviando)
              Text(
                'Marca ambas casillas para continuar.',
                style: tema.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}

class _Clausula extends StatelessWidget {
  const _Clausula(
      {required this.icono, required this.texto, this.destacado = false});

  final IconData icono;
  final String texto;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: destacado
            ? HoloTema.pastelCrisis
            : tema.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: HoloTema.marca),
          const SizedBox(width: 12),
          Expanded(child: Text(texto, style: tema.textTheme.bodySmall)),
        ],
      ),
    );
  }
}
