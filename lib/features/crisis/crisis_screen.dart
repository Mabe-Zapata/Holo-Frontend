import 'package:material_ui/material_ui.dart';

import '../../core/tema.dart';
import 'recursos_ayuda.dart';

/// Un recurso de ayuda tal como lo devuelve `POST /chat` (campo `recursos`).
class RecursoAyuda {
  const RecursoAyuda({
    required this.nombre,
    required this.telefono,
    required this.descripcion,
  });

  factory RecursoAyuda.desde(Map<String, dynamic> datos) => RecursoAyuda(
        nombre: datos['nombre'] as String,
        telefono: datos['telefono'] as String,
        descripcion: datos['descripcion'] as String,
      );

  final String nombre;
  final String telefono;
  final String descripcion;
}

/// Texto y recursos de una respuesta de crisis.
class DatosCrisis {
  const DatosCrisis({required this.texto, required this.recursos});

  factory DatosCrisis.desde(Map<String, dynamic> respuesta) => DatosCrisis(
        texto: respuesta['texto'] as String,
        recursos: (respuesta['recursos'] as List<dynamic>)
            .map((r) => RecursoAyuda.desde(r as Map<String, dynamic>))
            .toList(),
      );

  /// Se usa cuando el botón SOS se pulsa sin respuesta del backend.
  /// Los números salen de `data/texto_crisis.md`; el texto es provisional.
  static const DatosCrisis respaldo = DatosCrisis(
    texto:
        'Si estás en peligro o sientes que no puedes continuar, busca ayuda ahora mismo. Texto provisional, pendiente de aprobación de la especialista.',
    recursos: [
      RecursoAyuda(
        nombre: 'ECU 911',
        telefono: '911',
        descripcion: 'Emergencias',
      ),
      RecursoAyuda(
        nombre: 'Línea 171, opción 6',
        telefono: '171',
        descripcion: 'Salud mental, Ministerio de Salud Pública',
      ),
    ],
  );

  final String texto;
  final List<RecursoAyuda> recursos;
}

/// Pantalla de crisis (HU-15, RF-24).
///
/// Recibe los datos como argumento de la ruta. Sin argumento (botón SOS) usa
/// los de respaldo. Los recursos usan RecursosAyuda (FE-07) para poder llamar.
/// No ofrece técnicas, sugerencias ni campo de escritura.
class CrisisScreen extends StatelessWidget {
  const CrisisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final argumento = ModalRoute.of(context)?.settings.arguments;
    final datos = argumento is DatosCrisis ? argumento : DatosCrisis.respaldo;
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ayuda inmediata')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: HoloTema.pastelCrisis,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              datos.texto,
              style: tema.textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 20),
          RecursosAyuda(recursos: datos.recursos),
          const SizedBox(height: 8),
          Text(
            'Si estás en un lugar seguro, pide a alguien de confianza que te acompañe.',
            style: tema.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
