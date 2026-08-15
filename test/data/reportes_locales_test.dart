import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:laboratorio/core/json.dart';
import 'package:laboratorio/features/reportes/data/reportes_locales.dart';
import 'package:laboratorio/features/reportes/domain/estado_reporte.dart';

const _json = '''
[
  {
    "id": "rep-001",
    "titulo": "Hueco en la carrera 19",
    "descripcion": "Medio metro frente al bloque C.",
    "ubicacion": { "latitud": 10.4631, "longitud": -73.2532, "barrio": "Centro" },
    "creadoEn": "2026-08-10T19:05:00Z",
    "estado": { "tipo": "desconocido" }
  }
]
''';

void main() {
  test('lee la lista completa del archivo', () async {
    final repo = ReportesLocales(lector: (_) async => _json);
    expect((await repo.obtenerTodos()).length, 1);
  });

  test('busca por id y devuelve null cuando no está', () async {
    final repo = ReportesLocales(lector: (_) async => _json);

    expect(
      (await repo.obtenerPorId('rep-001'))?.titulo,
      'Hueco en la carrera 19',
    );
    expect(await repo.obtenerPorId('no-existe'), isNull);
  });

  test('un archivo que no es una lista se rechaza', () async {
    final repo = ReportesLocales(lector: (_) async => '{"a": 1}');
    expect(repo.obtenerTodos(), throwsA(isA<CampoInvalido>()));
  });

  test(
    'el asset declarado en pubspec existe y el modelo lo entiende',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();

      final repo = ReportesLocales(lector: rootBundle.loadString);
      expect((await repo.obtenerTodos()).length, greaterThanOrEqualTo(3));
    },
  );

  test(
    'obtenerPendientes devuelve solo los reportes en estado pendiente',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final repo = ReportesLocales(lector: rootBundle.loadString);

      final pendientes = await repo.obtenerPendientes();

      expect(pendientes, isNotEmpty);
      expect(pendientes.every((r) => r.estado is Pendiente), isTrue);
    },
  );
}
