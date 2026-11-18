import 'package:material_ui/material_ui.dart';

/// Aviso mientras Holo prepara su respuesta.
class IndicadorEscribiendo extends StatelessWidget {
  const IndicadorEscribiendo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('Holo esta escribiendo...'),
        ],
      ),
    );
  }
}
