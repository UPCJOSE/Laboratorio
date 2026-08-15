# Laboratorio

Qué problema resuelve, en dos frases.

## El dominio

- `Reporte`   — entidad principal. Identidad: `id`.
- `Ubicacion` — objeto de valor.
- `EstadoReporte` — sellada: Borrador · Enviado · EnRevision · Resuelto · Rechazado.

Decisión: modelo escrito a mano, porque el generador de freezed 4.0.0-dev.3
no serializaba correctamente el objeto de valor anidado `Ubicacion`
(`type 'Ubicacion' is not a subtype of type 'Map<String, dynamic>'`),
y con el tiempo disponible fue más confiable mantener el fromJson/toJson manual.

## Cómo correrlo

    flutter pub get
    flutter test
    flutter run