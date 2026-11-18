import 'package:flutter_test/flutter_test.dart';
import 'package:holo_app/features/chat/widgets/lista_mensajes.dart';
import 'package:holo_app/features/chat/widgets/mensaje.dart';
import 'package:material_ui/material_ui.dart';

Widget envolver(Widget hijo) => MaterialApp(home: Scaffold(body: hijo));

void main() {
  testWidgets('El mensaje mas reciente queda debajo del anterior', (
    tester,
  ) async {
    await tester.pumpWidget(
      envolver(
        const ListaMensajes(
          mensajes: [
            Mensaje(autor: 'usuario', texto: 'primero'),
            Mensaje(autor: 'asistente', texto: 'segundo'),
          ],
        ),
      ),
    );

    final yPrimero = tester.getTopLeft(find.text('primero')).dy;
    final ySegundo = tester.getTopLeft(find.text('segundo')).dy;
    expect(yPrimero, lessThan(ySegundo));
  });

  testWidgets('La lista vacia muestra un mensaje de bienvenida', (
    tester,
  ) async {
    await tester.pumpWidget(envolver(const ListaMensajes(mensajes: [])));

    expect(find.textContaining('Aun no hay mensajes'), findsOneWidget);
  });
}
