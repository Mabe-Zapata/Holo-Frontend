import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'crisis_screen.dart';

/// Recursos de ayuda con botón para llamar (FE-07, HU-14).
///
/// Por defecto muestra ECU 911 y la línea 171, opción 6. [alLlamar] permite
/// cambiar la acción de llamada en pruebas.
class RecursosAyuda extends StatelessWidget {
  const RecursosAyuda({super.key, this.recursos, this.alLlamar});

  final List<RecursoAyuda>? recursos;
  final Future<void> Function(String telefono)? alLlamar;

  Future<void> _llamar(String telefono) {
    final accion = alLlamar;
    if (accion != null) return accion(telefono);
    return launchUrl(Uri(scheme: 'tel', path: telefono));
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final lista = recursos ?? DatosCrisis.respaldo.recursos;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Recursos de ayuda', style: tema.textTheme.titleLarge),
        const SizedBox(height: 12),
        for (final recurso in lista)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tema.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recurso.nombre, style: tema.textTheme.titleMedium),
                Text(recurso.descripcion, style: tema.textTheme.bodySmall),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _llamar(recurso.telefono),
                  icon: const Icon(Icons.call_outlined),
                  label: Text('Llamar al ${recurso.telefono}'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
