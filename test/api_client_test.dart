import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:holo_app/core/api_client.dart';
import 'package:holo_app/core/api_simulado.dart';
import 'package:holo_app/core/config.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('ApiClient elige el modo indicado por USAR_SIMULACION', () async {
    final transporte = MockClient((peticion) async {
      expect(peticion.url, Uri.parse('${Config.apiBaseUrl}/salud'));
      expect(peticion.headers['x-usuario-id'], 'ana');
      return http.Response('{"estado":"ok","version":"http"}', 200);
    });
    addTearDown(transporte.close);
    final api = ApiClient(usuarioId: 'ana', cliente: transporte);

    final salud = await api.get('/salud');

    expect(salud['estado'], 'ok');
    expect(salud['version'], Config.usarSimulacion ? '0.1.0' : 'http');
  });

  test('el modo HTTP conserva el cuerpo y el detalle de error', () async {
    final transporte = MockClient((peticion) async {
      expect(peticion.method, 'POST');
      expect(jsonDecode(peticion.body), {'texto': 'Hola'});
      return http.Response('{"detail":"Falta el consentimiento"}', 403);
    });
    addTearDown(transporte.close);
    final api = ApiClient(usuarioId: 'ana', cliente: transporte);

    await expectLater(
      api.post('/chat', {'texto': 'Hola'}),
      throwsA(
        isA<ApiException>()
            .having((error) => error.codigo, 'código', 403)
            .having(
              (error) => error.mensaje,
              'detalle',
              'Falta el consentimiento',
            ),
      ),
    );
  }, skip: Config.usarSimulacion);

  group('ApiSimulado', () {
    final api = ApiSimulado(usuarioId: 'ana');

    test('devuelve el consentimiento y el historial de demostración', () async {
      final consentimiento = await api.post('/consentimiento', {
        'mayor_de_edad': true,
        'acepta': true,
      });
      final historial = await api.get('/chat/historial') as List<dynamic>;

      expect(consentimiento['usuario_id'], 'ana');
      expect(
        DateTime.parse(consentimiento['aceptado_en'] as String).isUtc,
        true,
      );
      expect(historial.map((dynamic mensaje) => mensaje['tipo']), [
        'mensaje',
        'respuesta',
      ]);
    });

    test('devuelve un eco para una conversación normal', () async {
      expect(await api.post('/chat', {'texto': 'Hola'}), {
        'tipo': 'respuesta',
        'texto': '[eco] Hola',
        'riesgo': 'sin_riesgo',
        'fragmentos': [],
        'recursos': [],
      });
    });

    test('devuelve el ejemplo de crisis con los campos del contrato', () async {
      final respuesta = await api.post('/chat', {
        'texto': ApiSimulado.mensajeCrisis,
      });

      expect(respuesta['tipo'], 'crisis');
      expect(respuesta['riesgo'], 'alto');
      expect(respuesta['texto'], contains('Texto provisional'));
      expect(respuesta['recursos'], hasLength(2));
      for (final recurso in respuesta['recursos'] as List<dynamic>) {
        expect(
          recurso.keys,
          unorderedEquals(['nombre', 'telefono', 'descripcion']),
        );
      }
    });

    test('permite consultar al paciente y el resumen propuesto', () async {
      final tratante = ApiSimulado(usuarioId: 'tratante');
      final paciente = await tratante.get('/tratante/paciente');
      final resumen = await tratante.post('/resumen');

      expect(paciente['paciente_id'], 'luis');
      expect(paciente['alertas'], hasLength(1));
      expect(resumen['paciente_id'], 'luis');
      expect(resumen['generado_por_ia'], true);
    });

    test('informa datos inválidos y rutas no disponibles', () async {
      await expectLater(
        api.post('/chat', {'texto': '  '}),
        throwsA(
          isA<ApiException>().having((error) => error.codigo, 'código', 422),
        ),
      );
      await expectLater(
        api.get('/ruta-desconocida'),
        throwsA(
          isA<ApiException>().having((error) => error.codigo, 'código', 404),
        ),
      );
    });
  });
}
