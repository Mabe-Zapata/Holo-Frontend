import 'package:flutter_test/flutter_test.dart';
import 'package:holo_app/core/api_simulado.dart';
import 'package:holo_app/core/tema.dart';
import 'package:holo_app/features/chat/chat_screen.dart';
import 'package:holo_app/features/crisis/recursos_ayuda.dart';
import 'package:material_ui/material_ui.dart';

Widget envolver(Widget hijo) => MaterialApp(theme: HoloTema.claro, home: hijo);

void main() {
  testWidgets('muestra ECU 911 y la línea 171, opción 6', (tester) async {
    await tester.pumpWidget(envolver(const Scaffold(body: RecursosAyuda())));

    expect(find.text('ECU 911'), findsOneWidget);
    expect(find.text('Línea 171, opción 6'), findsOneWidget);
    expect(find.text('Llamar al 911'), findsOneWidget);
    expect(find.text('Llamar al 171'), findsOneWidget);
  });

  testWidgets('cada botón llama al número de su recurso', (tester) async {
    final llamadas = <String>[];
    await tester.pumpWidget(envolver(Scaffold(
      body: RecursosAyuda(alLlamar: (telefono) async => llamadas.add(telefono)),
    )));

    await tester.tap(find.text('Llamar al 911'));
    await tester.tap(find.text('Llamar al 171'));
    await tester.pump();

    expect(llamadas, ['911', '171']);
  });

  testWidgets('la conversación abre los recursos desde un botón',
      (tester) async {
    await tester.pumpWidget(envolver(
      ChatScreen(api: ApiSimulado(usuarioId: 'ana')),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Recursos de ayuda'));
    await tester.pumpAndSettle();

    expect(find.text('ECU 911'), findsOneWidget);
    expect(find.text('Línea 171, opción 6'), findsOneWidget);
  });
}
