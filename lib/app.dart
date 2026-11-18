import 'package:material_ui/material_ui.dart';

import 'core/rutas.dart';
import 'core/tema.dart';
import 'features/chat/chat_screen.dart';
import 'features/consentimiento/consentimiento_screen.dart';
import 'features/crisis/crisis_screen.dart';
import 'features/inicio/inicio_screen.dart';
import 'features/tratante/tratante_screen.dart';

class HoloApp extends StatelessWidget {
  const HoloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Holo',
      debugShowCheckedModeBanner: false,
      theme: HoloTema.claro,
      // `home` en lugar de `initialRoute`: así la web abre la ruta de la URL
      // (por ejemplo /#/crisis) en vez de volver siempre al inicio.
      home: const InicioScreen(),
      routes: {
        Rutas.consentimiento: (context) => const ConsentimientoScreen(),
        Rutas.chat: (context) => const ChatScreen(),
        Rutas.crisis: (context) => const CrisisScreen(),
        Rutas.tratante: (context) => const TratanteScreen(),
      },
    );
  }
}
