import 'package:material_ui/material_ui.dart';

import '../../core/tema.dart';

/// Resumen semanal del paciente, tal como lo devuelve la API (FE-11, HU-17).
///
/// Muestra cada hecho con su día de origen y la etiqueta "Generado por IA".
/// Sin resumen, indica cómo generarlo. Nunca muestra la conversación literal.
class TarjetaResumen extends StatelessWidget {
  const TarjetaResumen({super.key, required this.resumen});

  /// Respuesta de `POST /resumen` o el campo `resumen` de `GET /tratante/paciente`.
  final Map<String, dynamic>? resumen;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final datos = resumen;
    if (datos == null) {
      return Text(
        'Aún no hay resumen. Genera uno nuevo para ver los hechos de la última semana.',
        style: tema.textTheme.bodySmall,
      );
    }

    final hechos = (datos['hechos'] as List<dynamic>?) ?? const [];
    final generadoPorIa = datos['generado_por_ia'] == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (generadoPorIa)
          const Chip(
            avatar: Icon(Icons.auto_awesome_outlined, size: 18),
            label: Text('Generado por IA'),
            backgroundColor: HoloTema.superficieAlta,
          ),
        const SizedBox(height: 8),
        if (hechos.isEmpty)
          Text(
            'No hay hechos destacados en la última semana.',
            style: tema.textTheme.bodyMedium,
          ),
        for (final hecho in hechos)
          _FilaHecho(hecho: hecho as Map<String, dynamic>),
      ],
    );
  }
}

class _FilaHecho extends StatelessWidget {
  const _FilaHecho({required this.hecho});

  final Map<String, dynamic> hecho;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hecho['fecha'] as String,
            style: tema.textTheme.labelLarge?.copyWith(color: HoloTema.marca),
          ),
          Text(
            hecho['descripcion'] as String,
            style: tema.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
