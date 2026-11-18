import 'package:flutter_test/flutter_test.dart';
import 'package:holo_app/features/chat/widgets/indicador_escribiendo.dart';
import 'package:material_ui/material_ui.dart';

Widget envolver(Widget hijo) => MaterialApp(home: Scaffold(body: hijo));

void main() {
  testWidgets('Muestra el texto y el indicador de progreso', (tester) async {
    // Solo pumpWidget: la animacion es infinita y pumpAndSettle se colgaria.
    await tester.pumpWidget(envolver(const IndicadorEscribiendo()));

    expect(find.text('Holo está escribiendo...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
