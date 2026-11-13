## Descripción

<!-- Qué cambia y por qué, en dos o tres líneas. -->

## Historia relacionada

<!-- Ejemplo: HU-05. Ver docs/product-backlog.md -->
HU-

## Tipo de cambio

- [ ] Nueva funcionalidad (`feat`)
- [ ] Corrección (`fix`)
- [ ] Documentación (`docs`)
- [ ] Refactorización o tarea técnica (`refactor`, `chore`, `test`)

## Capturas de pantalla

<!-- Obligatorias cuando el cambio es visual. -->

## Cómo se probó

<!-- Dispositivo o emulador utilizado y pasos para reproducir la prueba. -->

## Lista de verificación

- [ ] La rama parte de `develop` y el pull request apunta a `develop`
- [ ] El título sigue el convenio de commits (ver CONTRIBUTING.md)
- [ ] `flutter analyze` no reporta problemas
- [ ] `flutter test` se ejecuta sin fallos y se agregaron pruebas para el cambio
- [ ] La comunicación con el backend pasa por `lib/core/api_client.dart`
- [ ] Si se requirió un cambio de endpoint, está documentado en `odds/` del backend
- [ ] No se incluyen claves, archivos `.env` ni datos de personas reales
- [ ] Se cumplen los criterios de aceptación de la historia
