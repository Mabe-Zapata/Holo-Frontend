import 'package:material_ui/material_ui.dart';

import '../../core/rutas.dart';
import '../../core/sesion.dart';
import '../../core/tema.dart';

/// Selección de la cuenta de demostración.
class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  void _entrar(BuildContext context, String usuarioId, String ruta) {
    Sesion.usuarioId = usuarioId;
    Navigator.pushNamed(context, ruta);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Holo')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Bienvenida a Holo', style: tema.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Espacio de apoyo conversacional. Elige una cuenta de demostración.',
            style:
                tema.textTheme.bodyMedium?.copyWith(color: HoloTema.textoSuave),
          ),
          const SizedBox(height: 24),
          _TarjetaCuenta(
            titulo: 'Ana',
            descripcion: 'Usuaria estándar, sin tratante',
            icono: Icons.spa_outlined,
            onTap: () => _entrar(context, 'ana', Rutas.consentimiento),
          ),
          _TarjetaCuenta(
            titulo: 'Luis',
            descripcion: 'Paciente con tratante',
            icono: Icons.self_improvement_outlined,
            onTap: () => _entrar(context, 'luis', Rutas.consentimiento),
          ),
          _TarjetaCuenta(
            titulo: 'Tratante',
            descripcion: 'Consulta alertas y resúmenes',
            icono: Icons.health_and_safety_outlined,
            onTap: () => _entrar(context, 'tratante', Rutas.tratante),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HoloTema.superficieAlta,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Entorno de demostración. No sustituye la atención de un profesional. En caso de emergencia, usa el botón SOS.',
              style: tema.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaCuenta extends StatelessWidget {
  const _TarjetaCuenta({
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.onTap,
  });

  final String titulo;
  final String descripcion;
  final IconData icono;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: tema.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: HoloTema.superficieAlta,
                  foregroundColor: HoloTema.marca,
                  child: Icon(icono),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: tema.textTheme.titleMedium),
                      Text(descripcion, style: tema.textTheme.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: HoloTema.marca),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
