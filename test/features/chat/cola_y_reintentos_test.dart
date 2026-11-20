import 'package:flutter_test/flutter_test.dart';
import 'package:holo_app/core/api_client.dart';
import 'package:holo_app/core/cola_envios.dart';
import 'package:holo_app/core/rutas.dart';
import 'package:holo_app/core/tema.dart';
import 'package:holo_app/features/chat/chat_screen.dart';
import 'package:holo_app/features/crisis/crisis_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Almacén en memoria para la cola de envíos.
class AlmacenMemoria implements AlmacenEnvios {
  AlmacenMemoria([this.valor]);

  String? valor;

  @override
  Future<String?> leer() async => valor;

  @override
  Future<void> guardar(String contenido) async => valor = contenido;
}

/// API de prueba: el historial es fijo y cada envío sigue el guion indicado.
class ApiFalsa implements ApiClient {
  ApiFalsa({required this.alEnviar});

  /// Recibe el cuerpo de cada envío y responde o lanza un error.
  final Future<dynamic> Function(Map<String, dynamic> cuerpo) alEnviar;

  final List<Map<String, dynamic>> envios = [];
  final List<Map<String, dynamic>> _historial = [];

  @override
  String get usuarioId => 'ana';

  @override
  Future<dynamic> get(String ruta) async => _historial;

  @override
  Future<dynamic> post(String ruta, [Map<String, dynamic>? cuerpo]) async {
    final datos = cuerpo!;
    envios.add(Map<String, dynamic>.of(datos));
    final respuesta = await alEnviar(datos);
    _historial.add({'autor': 'usuario', 'texto': datos['texto'], 'fecha': '', 'tipo': 'mensaje'});
    _historial.add({
      'autor': 'asistente',
      'texto': respuesta['texto'],
      'fecha': '',
      'tipo': respuesta['tipo'],
    });
    return respuesta;
  }
}

Map<String, dynamic> respuestaEco(Map<String, dynamic> cuerpo) =>
    {'tipo': 'respuesta', 'texto': '[eco] ${cuerpo['texto']}', 'riesgo': 'sin_riesgo'};

Widget envolver(Widget hijo) => MaterialApp(
      theme: HoloTema.claro,
      routes: {Rutas.crisis: (_) => const CrisisScreen()},
      home: hijo,
    );

/// Desmonta la pantalla para que su temporizador se cancele al terminar la prueba.
Future<void> desmontar(WidgetTester tester) => tester.pumpWidget(const SizedBox());

void main() {
  group('ColaEnvios', () {
    test('conserva el orden de llegada y permite quitar un envío', () async {
      final cola = ColaEnvios(almacen: AlmacenMemoria());

      await cola.encolar(const EnvioPendiente(id: 'uno-aaaa', texto: 'primero'));
      await cola.encolar(const EnvioPendiente(id: 'dos-bbbb', texto: 'segundo'));
      await cola.quitar('uno-aaaa');

      final pendientes = await cola.pendientes();
      expect(pendientes.map((e) => e.texto), ['segundo']);
    });

    test('encolar en paralelo no pierde ningún envío', () async {
      final cola = ColaEnvios(almacen: AlmacenMemoria());

      await Future.wait([
        for (var n = 0; n < 20; n++)
          cola.encolar(EnvioPendiente(id: 'par-${n.toString().padLeft(3, '0')}', texto: 'x$n')),
      ]);

      expect((await cola.pendientes()).length, 20);
    });

    test('un contenido dañado se trata como cola vacía', () async {
      final cola = ColaEnvios(almacen: AlmacenMemoria('{no es json'));

      expect(await cola.pendientes(), isEmpty);
    });

    test('el identificador de evento cumple el formato del backend', () {
      final ids = {for (var n = 0; n < 500; n++) generarIdEvento()};

      expect(ids.length, 500);
      for (final id in ids) {
        expect(id, matches(RegExp(r'^[A-Za-z0-9_-]{8,64}$')));
      }
    });
  });

  group('ChatScreen con cola de envíos', () {
    testWidgets('un envío exitoso aparece con su respuesta y sale de la cola',
        (tester) async {
      final api = ApiFalsa(alEnviar: (cuerpo) async => respuestaEco(cuerpo));
      final cola = ColaEnvios(almacen: AlmacenMemoria());
      await tester.pumpWidget(envolver(ChatScreen(api: api, cola: cola)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'hola');
      await tester.tap(find.byTooltip('Enviar mensaje'));
      await tester.pumpAndSettle();

      expect(find.text('[eco] hola'), findsOneWidget);
      expect(await cola.pendientes(), isEmpty);
      expect(api.envios.single['id_evento'], matches(RegExp(r'^[A-Za-z0-9_-]{8,64}$')));
      await desmontar(tester);
    });

    testWidgets('sin conexión el mensaje queda pendiente y se ofrecen recursos',
        (tester) async {
      final api = ApiFalsa(alEnviar: (_) async => throw Exception('sin red'));
      final cola = ColaEnvios(almacen: AlmacenMemoria());
      await tester.pumpWidget(envolver(ChatScreen(api: api, cola: cola)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'hola');
      await tester.tap(find.byTooltip('Enviar mensaje'));
      await tester.pumpAndSettle();

      expect(find.text('hola'), findsOneWidget);
      expect(find.text('Sin conexión. Lo reintentamos.'), findsOneWidget);
      expect(find.text('Ver recursos de ayuda'), findsOneWidget);
      expect((await cola.pendientes()).map((e) => e.texto), ['hola']);
      await desmontar(tester);
    });

    testWidgets('el reintento reenvía con el mismo identificador y confirma',
        (tester) async {
      var intentos = 0;
      final api = ApiFalsa(alEnviar: (cuerpo) async {
        intentos++;
        if (intentos == 1) throw Exception('sin red');
        return respuestaEco(cuerpo);
      });
      final cola = ColaEnvios(almacen: AlmacenMemoria());
      await tester.pumpWidget(envolver(ChatScreen(
        api: api,
        cola: cola,
        intervaloReintento: const Duration(seconds: 20),
      )));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'hola');
      await tester.tap(find.byTooltip('Enviar mensaje'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 21));
      await tester.pumpAndSettle();

      expect(api.envios.length, 2);
      expect(api.envios[1]['id_evento'], api.envios[0]['id_evento']);
      expect(await cola.pendientes(), isEmpty);
      expect(find.text('[eco] hola'), findsOneWidget);
      await desmontar(tester);
    });

    testWidgets('un error de contenido descarta el envío y muestra el motivo',
        (tester) async {
      final api = ApiFalsa(
        alEnviar: (_) async => throw ApiException(422, 'El mensaje no puede estar vacío.'),
      );
      final cola = ColaEnvios(almacen: AlmacenMemoria());
      await tester.pumpWidget(envolver(ChatScreen(api: api, cola: cola)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'hola');
      await tester.tap(find.byTooltip('Enviar mensaje'));
      await tester.pumpAndSettle();

      expect(find.text('El mensaje no puede estar vacío.'), findsOneWidget);
      expect(await cola.pendientes(), isEmpty);
      await desmontar(tester);
    });

    testWidgets('un error del servidor conserva el envío para reintentarlo',
        (tester) async {
      final api = ApiFalsa(
        alEnviar: (_) async => throw ApiException(500, 'Error interno'),
      );
      final cola = ColaEnvios(almacen: AlmacenMemoria());
      await tester.pumpWidget(envolver(ChatScreen(api: api, cola: cola)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'hola');
      await tester.tap(find.byTooltip('Enviar mensaje'));
      await tester.pumpAndSettle();

      expect((await cola.pendientes()).map((e) => e.texto), ['hola']);
      expect(find.text('No se pudo enviar. Lo reintentamos.'), findsOneWidget);
      await desmontar(tester);
    });

    testWidgets('si el primero falla, el segundo espera para no reordenar',
        (tester) async {
      final api = ApiFalsa(alEnviar: (_) async => throw Exception('sin red'));
      final cola = ColaEnvios(almacen: AlmacenMemoria());
      await tester.pumpWidget(envolver(ChatScreen(api: api, cola: cola)));
      await tester.pumpAndSettle();

      for (final texto in ['primero', 'segundo']) {
        await tester.enterText(find.byType(TextField), texto);
        await tester.tap(find.byTooltip('Enviar mensaje'));
        await tester.pumpAndSettle();
      }

      // Cada intento reenvía desde el primero: el segundo nunca sale antes que él.
      expect(api.envios.map((e) => e['texto']).toSet(), {'primero'});
      expect((await cola.pendientes()).map((e) => e.texto), ['primero', 'segundo']);
      await desmontar(tester);
    });

    testWidgets('al abrir la conversación se reenvía lo que quedó pendiente',
        (tester) async {
      final almacen = AlmacenMemoria(
        '[{"id": "previo-00001", "texto": "quedó pendiente"}]',
      );
      final api = ApiFalsa(alEnviar: (cuerpo) async => respuestaEco(cuerpo));
      await tester.pumpWidget(
        envolver(ChatScreen(api: api, cola: ColaEnvios(almacen: almacen))),
      );
      await tester.pumpAndSettle();

      expect(api.envios.single['id_evento'], 'previo-00001');
      expect(find.text('quedó pendiente'), findsOneWidget);
      expect(find.text('[eco] quedó pendiente'), findsOneWidget);
      expect(almacen.valor, '[]');
      await desmontar(tester);
    });

    testWidgets('una crisis confirmada abre la pantalla de crisis', (tester) async {
      final api = ApiFalsa(
        alEnviar: (_) async => {
          'tipo': 'crisis',
          'texto': 'Texto de crisis de prueba',
          'riesgo': 'alto',
          'recursos': [
            {'nombre': 'ECU 911', 'telefono': '911', 'descripcion': 'Emergencias'},
          ],
        },
      );
      await tester.pumpWidget(
        envolver(ChatScreen(api: api, cola: ColaEnvios(almacen: AlmacenMemoria()))),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'quiero morir');
      await tester.tap(find.byTooltip('Enviar mensaje'));
      await tester.pumpAndSettle();

      expect(find.text('Ayuda inmediata'), findsOneWidget);
      expect(find.text('Texto de crisis de prueba'), findsOneWidget);
      await desmontar(tester);
    });
  });
}
