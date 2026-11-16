import 'package:material_ui/material_ui.dart';

import '../../core/rutas.dart';
import '../../core/sesion.dart';

/// Selección de la cuenta de demostración.
class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  void _entrar(BuildContext context, String usuarioId, String ruta) {
    Sesion.usuarioId = usuarioId;
    Navigator.pushNamed(context, ruta);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Holo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Seleccione una cuenta de demostración'),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: const Text('Ana'),
              subtitle: const Text('Usuaria estándar'),
              onTap: () => _entrar(context, 'ana', Rutas.consentimiento),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Luis'),
              subtitle: const Text('Paciente con tratante'),
              onTap: () => _entrar(context, 'luis', Rutas.consentimiento),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Tratante'),
              subtitle: const Text('Consulta alertas y resumen'),
              onTap: () => _entrar(context, 'tratante', Rutas.tratante),
            ),
          ),
        ],
      ),
    );
  }
}
