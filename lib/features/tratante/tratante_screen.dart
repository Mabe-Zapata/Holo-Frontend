import 'package:flutter/material.dart';

/// Vista del tratante (HU-18, RF-30).
///
/// Pendiente: mostrar las alertas y el resumen que devuelve
/// `GET /tratante/paciente`, y permitir generar un resumen nuevo con
/// `POST /resumen`. Esta vista nunca muestra la conversación del paciente.
class TratanteScreen extends StatelessWidget {
  const TratanteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vista del tratante')),
      body: const Center(
        child: Text('Pendiente de implementar: historia HU-18'),
      ),
    );
  }
}
