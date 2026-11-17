import 'package:material_ui/material_ui.dart';

import '../../core/rutas.dart';

/// Pantalla de consentimiento informado (HU-02, RF-02).
///
/// Pendiente: texto del consentimiento, declaración de mayoría de edad y
/// llamada a `POST /consentimiento` antes de continuar.
class ConsentimientoScreen extends StatelessWidget {
  const ConsentimientoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consentimiento informado')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(
              child: Center(
                child: Text('Pendiente de implementar: historia HU-02'),
              ),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, Rutas.chat),
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
