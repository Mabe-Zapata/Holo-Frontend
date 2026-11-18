import 'package:flutter_test/flutter_test.dart';
import 'package:holo_app/core/api_simulado.dart';
import 'package:holo_app/core/tema.dart';
import 'package:holo_app/features/chat/chat_screen.dart';
import 'package:holo_app/features/tratante/tratante_screen.dart';
import 'package:material_ui/material_ui.dart';

Widget envolver(Widget hijo) => MaterialApp(theme: HoloTema.claro, home: hijo);

void main() {
  testWidgets('la conversación carga el historial de la cuenta',
      (tester) async {
    await tester.pumpWidget(envolver(
      ChatScreen(api: ApiSimulado(usuarioId: 'ana')),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Estoy muy estresada'), findsOneWidget);
    expect(find.text('[eco] Estoy muy estresada'), findsOneWidget);
  });

  testWidgets('la vista del tratante muestra al paciente y sin resumen todavía',
      (tester) async {
    await tester.pumpWidget(envolver(
      TratanteScreen(api: ApiSimulado(usuarioId: 'tratante')),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Luis'), findsOneWidget);
    expect(find.textContaining('Aún no hay resumen'), findsOneWidget);
    expect(find.text('Generado por IA'), findsOneWidget);
  });
}
