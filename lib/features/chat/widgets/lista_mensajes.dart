import 'package:holo_app/features/chat/widgets/burbuja_mensaje.dart';
import 'package:holo_app/features/chat/widgets/mensaje.dart';
import 'package:material_ui/material_ui.dart';

/// Lista de la conversacion: el mensaje mas reciente queda abajo.
class ListaMensajes extends StatelessWidget {
  const ListaMensajes({super.key, required this.mensajes});

  final List<Mensaje> mensajes;

  @override
  Widget build(BuildContext context) {
    if (mensajes.isEmpty) {
      return const Center(
        child: Text('Aun no hay mensajes. Cuentame como te sientes.'),
      );
    }
    return ListView.builder(
      // el ultimo mensaje queda abajo y visible
      reverse: true,
      itemCount: mensajes.length,
      itemBuilder: (context, i) {
        final mensaje = mensajes[mensajes.length - 1 - i];
        return BurbujaMensaje(
          texto: mensaje.texto,
          esUsuario: mensaje.esUsuario,
        );
      },
    );
  }
}
