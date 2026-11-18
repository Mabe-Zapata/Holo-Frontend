import 'package:flutter_test/flutter_test.dart';
import 'package:holo_app/core/tema.dart';
import 'package:holo_app/features/crisis/crisis_screen.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('muestra el texto y los recursos que llegan como argumento',
      (tester) async {
    const datos = DatosCrisis(
      texto: 'Texto de prueba',
      recursos: [
        RecursoAyuda(nombre: 'Recurso A', telefono: '111', descripcion: 'Uno'),
        RecursoAyuda(nombre: 'Recurso B', telefono: '222', descripcion: 'Dos'),
      ],
    );
    await tester.pumpWidget(MaterialApp(
      theme: HoloTema.claro,
      home: Builder(
        builder: (contexto) => FilledButton(
          onPressed: () => Navigator.push(
            contexto,
            MaterialPageRoute(
              settings: const RouteSettings(arguments: datos),
              builder: (_) => const CrisisScreen(),
            ),
          ),
          child: const Text('abrir'),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Texto de prueba'), findsOneWidget);
    expect(find.text('Recurso A'), findsOneWidget);
    expect(find.text('222'), findsOneWidget);
  });

  testWidgets('sin argumentos muestra los números de respaldo', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: HoloTema.claro,
      home: const CrisisScreen(),
    ));

    expect(find.text('911'), findsOneWidget);
    expect(find.text('171'), findsOneWidget);
    expect(find.textContaining('Línea 171'), findsOneWidget);
  });
}
