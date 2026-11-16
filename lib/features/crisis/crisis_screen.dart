import 'package:material_ui/material_ui.dart';

/// Pantalla fija de crisis (HU-15, RF-24).
///
/// Pendiente: mostrar el texto y los recursos de ayuda que devuelve
/// `POST /chat` cuando `tipo == 'crisis'`. El texto lo aprueba la
/// especialista; la aplicación no lo redacta ni lo modifica.
class CrisisScreen extends StatelessWidget {
  const CrisisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayuda inmediata')),
      body: const Center(
        child: Text('Pendiente de implementar: historia HU-15'),
      ),
    );
  }
}
