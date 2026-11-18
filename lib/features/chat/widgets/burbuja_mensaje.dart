import 'package:material_ui/material_ui.dart';

import '../../../core/tema.dart';

/// El mensaje del usuario va a la derecha con el color principal del tema
/// y el del asistente a la izquierda en gris.
class BurbujaMensaje extends StatelessWidget {
  const BurbujaMensaje({
    super.key,
    required this.texto,
    required this.esUsuario,
  });

  final String texto;
  final bool esUsuario;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // El asistente usa el verde menta claro para distinguirse del fondo.
          color: esUsuario ? colores.primary : HoloTema.superficieAlta,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Semantics(
          label: esUsuario ? 'Tu mensaje' : 'Respuesta de Holo',
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 16, // la guía de interfaz pide 14 como mínimo
              color: esUsuario ? colores.onPrimary : colores.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
