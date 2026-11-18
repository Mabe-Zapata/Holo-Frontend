import 'package:flutter_test/flutter_test.dart';
import 'package:holo_app/features/chat/widgets/burbuja_mensaje.dart';
import 'package:holo_app/features/chat/widgets/mensaje.dart';
import 'package:material_ui/material_ui.dart';

Widget envolver(Widget hijo) => MaterialApp(home: Scaffold(body: hijo));

/// Alineacion de la burbuja que contiene el texto indicado.
AlignmentGeometry alineacionDe(WidgetTester tester, String texto) => tester
    .widget<Align>(
      find.ancestor(of: find.text(texto), matching: find.byType(Align)).first,
    )
    .alignment;

void main() {
  testWidgets('El mensaje del usuario va a la derecha', (tester) async {
    await tester.pumpWidget(
      envolver(const BurbujaMensaje(texto: 'Hola', esUsuario: true)),
    );

    expect(find.text('Hola'), findsOneWidget);
    expect(alineacionDe(tester, 'Hola'), Alignment.centerRight);
  });

  testWidgets('El mensaje del asistente va a la izquierda', (tester) async {
    await tester.pumpWidget(
      envolver(const BurbujaMensaje(texto: 'Te escucho', esUsuario: false)),
    );

    expect(alineacionDe(tester, 'Te escucho'), Alignment.centerLeft);
  });

  test('Mensaje reconoce al autor usuario', () {
    expect(const Mensaje(autor: 'usuario', texto: 'a').esUsuario, isTrue);
    expect(const Mensaje(autor: 'asistente', texto: 'b').esUsuario, isFalse);
  });
}
