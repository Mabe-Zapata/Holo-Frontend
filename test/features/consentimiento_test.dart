import 'package:flutter_test/flutter_test.dart';
import 'package:holo_app/core/api_simulado.dart';
import 'package:holo_app/core/tema.dart';
import 'package:holo_app/features/consentimiento/consentimiento_screen.dart';
import 'package:material_ui/material_ui.dart';

Widget envolver(Widget hijo) => MaterialApp(theme: HoloTema.claro, home: hijo);

void main() {
  testWidgets('las casillas empiezan desmarcadas y el botón está deshabilitado',
      (tester) async {
    await tester.pumpWidget(envolver(
      ConsentimientoScreen(api: ApiSimulado(usuarioId: 'ana')),
    ));

    final casillas =
        tester.widgetList<CheckboxListTile>(find.byType(CheckboxListTile));
    expect(casillas.every((c) => c.value == false), isTrue);
    final boton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(boton.onPressed, isNull);
  });

  testWidgets('el botón se habilita solo cuando se marcan ambas casillas',
      (tester) async {
    await tester.pumpWidget(envolver(
      ConsentimientoScreen(api: ApiSimulado(usuarioId: 'ana')),
    ));

    await tester.tap(find.byType(CheckboxListTile).at(0));
    await tester.pump();
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);

    await tester.tap(find.byType(CheckboxListTile).at(1));
    await tester.pump();
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull);
  });
}
