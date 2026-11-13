# Consumo de la API

El presente documento explica cómo se comunica la aplicación con el backend. El contrato detallado de cada endpoint se encuentra en la carpeta `odds/` del repositorio `Holo-project`, que constituye la referencia oficial.

## Reglas

- Toda petición pasa por la clase `ApiClient` (`lib/core/api_client.dart`). Las pantallas no utilizan el paquete `http` directamente.
- La cuenta activa se envía en la cabecera `X-Usuario-Id`, tomada de `Sesion.usuarioId`.
- La URL del backend se define con `--dart-define=API_BASE_URL=...` (ver `lib/core/config.dart`).
- Los errores del backend llegan como `ApiException`, con el código HTTP y el mensaje del campo `detail`.

## Ejemplo de uso

```dart
final api = ApiClient(usuarioId: Sesion.usuarioId);

try {
  final respuesta = await api.post('/chat', {'texto': 'Estoy estresada'});
  if (respuesta['tipo'] == 'crisis') {
    // Navegar a la pantalla de crisis con respuesta['texto'] y respuesta['recursos'].
  } else {
    // Mostrar respuesta['texto'] en la conversación.
  }
} on ApiException catch (error) {
  // error.codigo == 403: falta aceptar el consentimiento.
}
```

## Endpoints utilizados

| Endpoint | Pantalla | Documento en el backend |
| --- | --- | --- |
| `GET /salud` | Comprobación de conexión | `odds/salud.md` |
| `POST /consentimiento` | Consentimiento | `odds/consentimiento.md` |
| `POST /chat` | Conversación | `odds/chat.md` |
| `GET /chat/historial` | Conversación | `odds/chat-historial.md` |
| `POST /resumen` | Vista del tratante | `odds/resumen.md` |
| `GET /tratante/paciente` | Vista del tratante | `odds/tratante-paciente.md` |

## Manejo de errores

| Código | Acción en la aplicación |
| --- | --- |
| 401 | Volver a la pantalla de inicio |
| 403 en `POST /chat` | Navegar a la pantalla de consentimiento |
| 422 | Revisar los datos enviados; corresponde a un defecto de la aplicación |
| 501 | Indicar que la función aún no está disponible |
| Sin conexión | Mostrar un mensaje claro, permitir reintentar y mantener visibles los recursos de ayuda |

## Cambios en un endpoint

Cuando una pantalla requiere un dato que el backend no entrega, primero se acuerda el cambio con el equipo del backend y se actualiza el documento correspondiente en `odds/`. Después se implementa en ambos repositorios.
