import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:laboratorio/core/json.dart';
import 'package:laboratorio/features/reportes/domain/estado_reporte.dart';
import 'package:laboratorio/features/reportes/domain/reporte.dart';
import 'package:laboratorio/features/reportes/domain/ubicacion.dart';

Reporte ejemplo({EstadoReporte? estado, List<String>? fotos}) => Reporte(
  id: 'rep-001',
  titulo: 'Hueco en la carrera 19',
  descripcion: 'Medio metro frente al bloque C.',
  ubicacion: const Ubicacion(
    latitud: 10.4631,
    longitud: -73.2532,
    barrio: 'Centro',
  ),
  creadoEn: DateTime.utc(2026, 8, 10, 19, 5),
  estado: estado ?? const Desconocido(),
  fotos: fotos ?? const <String>[],
);

void main() {
  group('serialización', () {
    test('un reporte sobrevive la ida y vuelta a JSON sin perder nada', () {
      final original = ejemplo(
        estado: const Pendiente('5/10', 'cuadrilla-3'),
        fotos: const ['https://ejemplo.co/f/1.jpg'],
      );

      final texto = jsonEncode(original.toJson());
      final vuelta = Reporte.fromJson(
        jsonDecode(texto) as Map<String, dynamic>,
      );

      expect(vuelta, equals(original));
    });

    test('un reporte sin la clave fotos se lee con la lista vacía', () {
      final json = ejemplo().toJson()..remove('fotos');
      expect(Reporte.fromJson(json).fotos, isEmpty);
    });

    test('un reporte sin título dice QUÉ campo falló, no solo que falló', () {
      final json = ejemplo().toJson()..remove('titulo');

      expect(
        () => Reporte.fromJson(json),
        throwsA(isA<CampoInvalido>().having((e) => e.campo, 'campo', 'titulo')),
      );
    });

    test('una fecha que no es ISO 8601 se rechaza', () {
      final json = ejemplo().toJson()..['creadoEn'] = '10 de agosto';
      expect(() => Reporte.fromJson(json), throwsA(isA<CampoInvalido>()));
    });

    test('la hora se conserva en UTC y no se corre cinco horas', () {
      final json = ejemplo().toJson();
      expect(json['creadoEn'], '2026-08-10T19:05:00.000Z');
    });
  });

  group('igualdad', () {
    test('dos reportes con los mismos datos son iguales', () {
      expect(ejemplo(), equals(ejemplo()));
    });

    test('dos reportes con los mismos datos comparten hashCode', () {
      expect(ejemplo().hashCode, equals(ejemplo().hashCode));
      expect({ejemplo(), ejemplo()}.length, 1);
    });

    test('dos reportes con fotos distintas NO son iguales', () {
      expect(
        ejemplo(fotos: const ['a']),
        isNot(equals(ejemplo(fotos: const ['b']))),
      );
    });

    test('copyWith cambia solo lo que se le pasa', () {
      final original = ejemplo();
      final copia = original.copyWith(titulo: 'Otro título');

      expect(copia.titulo, 'Otro título');
      expect(copia.id, original.id);
      expect(copia.creadoEn, original.creadoEn);
    });
  });

  group('reglas de negocio', () {
    test('un reporte en proceso no se puede editar', () {
      expect(
        ejemplo(estado: const EnProceso('cuadrilla-3')).sePuedeEditar,
        isFalse,
      );
    });

    test('un reporte pendiente sí se puede editar', () {
      expect(
        ejemplo(estado: const Pendiente('5/10', 'cuadrilla-3')).sePuedeEditar,
        isTrue,
      );
    });

    test('un reporte de hace 40 días está vencido', () {
      final ahora = DateTime.utc(2026, 9, 20);
      expect(ejemplo().estaVencido(ahora), isTrue);
    });

    test('la etiqueta de un pendiente incluye la prioridad', () {
      expect(const Pendiente('5/10', 'cuadrilla-3').etiqueta, contains('5/10'));
    });
  });
}
