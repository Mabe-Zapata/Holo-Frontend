import 'package:flutter_test/flutter_test.dart';
import 'package:holo_app/app.dart';

void main() {
  testWidgets('La pantalla de inicio muestra las cuentas de demostración',
      (tester) async {
    await tester.pumpWidget(const HoloApp());

    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Luis'), findsOneWidget);
    expect(find.text('Tratante'), findsOneWidget);
  });
}
