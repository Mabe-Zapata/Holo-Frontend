/// Mensaje de la conversacion (FE-05).
///
/// Los nombres coinciden con la respuesta de GET /chat/historial
/// (odds/chat-historial.md del backend).
class Mensaje {
  const Mensaje({required this.autor, required this.texto});

  /// 'usuario' o 'asistente'.
  final String autor;
  final String texto;

  bool get esUsuario => autor == 'usuario';
}
