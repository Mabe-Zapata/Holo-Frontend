import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'crisis_screen.dart';

/// Acción que intenta marcar un número. Devuelve `true` si se abrió el marcador.
typedef AccionLlamar = Future<bool> Function(String telefono);

/// Recursos de ayuda con botón para llamar (FE-07, HU-14).
///
/// Por defecto muestra ECU 911 y la línea 171, opción 6. [alLlamar] permite
/// cambiar la acción de llamada en pruebas.
class RecursosAyuda extends StatefulWidget {
  const RecursosAyuda({super.key, this.recursos, this.alLlamar});

  final List<RecursoAyuda>? recursos;
  final AccionLlamar? alLlamar;

  @override
  State<RecursosAyuda> createState() => _RecursosAyudaEstado();
}

class _RecursosAyudaEstado extends State<RecursosAyuda> {
  String? _aviso;

  Future<bool> _marcar(String telefono) async {
    try {
      final accion = widget.alLlamar;
      if (accion != null) return await accion(telefono);
      return await launchUrl(Uri(scheme: 'tel', path: telefono));
    } catch (_) {
      // Sin marcador disponible (escritorio, navegador) no debe romper la pantalla.
      return false;
    }
  }

  Future<void> _llamar(RecursoAyuda recurso) async {
    final abierto = await _marcar(recurso.telefono);
    if (!mounted) return;
    setState(() {
      _aviso = abierto
          ? null
          : 'No se pudo abrir el marcador. Marca ${recurso.telefono} desde tu teléfono.';
    });
  }

  /// La línea 171 atiende con un menú y la opción 6 es salud mental
  /// (ver data/texto_crisis.md), así que el botón lo indica.
  String _etiqueta(RecursoAyuda recurso) => recurso.telefono == '171'
      ? 'Llamar 171 y marcar 6'
      : 'Llamar al ${recurso.telefono}';

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final lista = widget.recursos ?? DatosCrisis.respaldo.recursos;
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
                  onPressed: () => _llamar(recurso),
                  icon: const Icon(Icons.call_outlined),
                  label: Text(_etiqueta(recurso)),
                ),
              ],
            ),
          ),
        if (_aviso != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _aviso!,
              style: tema.textTheme.bodyMedium
                  ?.copyWith(color: tema.colorScheme.error),
            ),
          ),
      ],
    );
  }
}
