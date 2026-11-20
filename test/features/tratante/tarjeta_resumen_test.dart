import 'package:flutter_test/flutter_test.dart';
import 'package:holo_app/core/api_client.dart';
import 'package:holo_app/core/tema.dart';
import 'package:holo_app/features/tratante/tarjeta_resumen.dart';
import 'package:material_ui/material_ui.dart';

/// Cliente falso: devuelve el resumen con el contrato de odds/resumen.md.
class ApiResumenFalsa implements ApiClient {
  ApiResumenFalsa(this._respuesta);

  final Map<String, dynamic> _respuesta;

  @override
  String get usuarioId => 'tratante';

  @override
  Future<dynamic> get(String ruta) async => throw UnimplementedError();

  @override
  Future<dynamic> post(String ruta, [Map<String, dynamic>? cuerpo]) async => _respuesta;
}

Widget envolver(Widget hijo) => MaterialApp(
      theme: HoloTema.claro,
      home: Scaffold(body: SingleChildScrollView(child: hijo)),
    );

Map<String, dynamic> resumenDeEjemplo() => {
      'generado_por_ia': true,
      'temas': <String>[],
      'patrones': <String>[],
      'hechos': [
        {'fecha': '2026-11-16', 'descripcion': 'Relató que durmió mal.'},
        {'fecha': '2026-11-17', 'descripcion': 'Dijo que el martes fue mejor.'},
      ],
    };

void main() {
  testWidgets('sin resumen indica cómo generarlo', (tester) async {
    await tester.pumpWidget(envolver(const TarjetaResumen(resumen: null)));

    expect(find.textContaining('Aún no hay resumen'), findsOneWidget);
    expect(find.text('Generado por IA'), findsNothing);
  });

  testWidgets('muestra cada hecho con su día y la etiqueta de IA', (tester) async {
    final api = ApiResumenFalsa(resumenDeEjemplo());
    final resumen = await api.post('/resumen') as Map<String, dynamic>;

    await tester.pumpWidget(envolver(TarjetaResumen(resumen: resumen)));

    expect(find.text('Generado por IA'), findsOneWidget);
    expect(find.text('2026-11-16'), findsOneWidget);
    expect(find.text('Relató que durmió mal.'), findsOneWidget);
    expect(find.text('2026-11-17'), findsOneWidget);
    expect(find.text('Dijo que el martes fue mejor.'), findsOneWidget);
  });

  testWidgets('un resumen sin hechos lo dice sin inventar contenido', (tester) async {
    final vacio = {...resumenDeEjemplo(), 'hechos': <Map<String, dynamic>>[]};

    await tester.pumpWidget(envolver(TarjetaResumen(resumen: vacio)));

    expect(find.text('No hay hechos destacados en la última semana.'), findsOneWidget);
    expect(find.text('Generado por IA'), findsOneWidget);
  });

  testWidgets('sin la marca de IA no se etiqueta como generado por IA', (tester) async {
    final sinMarca = {...resumenDeEjemplo(), 'generado_por_ia': false};

    await tester.pumpWidget(envolver(TarjetaResumen(resumen: sinMarca)));

    expect(find.text('Generado por IA'), findsNothing);
    expect(find.text('Relató que durmió mal.'), findsOneWidget);
  });
}
