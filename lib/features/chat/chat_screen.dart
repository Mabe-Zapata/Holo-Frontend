import 'package:flutter/material.dart';

/// Pantalla de conversación con el asistente (HU-05, RF-07).
///
/// Pendiente: lista de mensajes, campo de texto, carga del historial con
/// `GET /chat/historial` y envío con `POST /chat`. Cuando la respuesta tiene
/// `tipo == 'crisis'`, se navega a la pantalla de crisis.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conversación')),
      body: const Center(
        child: Text('Pendiente de implementar: historia HU-05'),
      ),
    );
  }
}
