import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:laboratorio/core/json.dart';
import 'package:laboratorio/features/reportes/domain/reporte.dart';
import 'package:laboratorio/features/reportes/domain/reportes_repository.dart';
import 'package:laboratorio/features/reportes/domain/estado_reporte.dart';

typedef LectorDeAssets = Future<String> Function(String ruta);

class ReportesLocales implements ReportesRepository {
  ReportesLocales({
    LectorDeAssets? lector,
    this.ruta = 'assets/data/reportes.json',
  }) : _lector = lector ?? rootBundle.loadString;

  final LectorDeAssets _lector;
  final String ruta;

  List<Reporte>? _cache;

  @override
  Future<List<Reporte>> obtenerTodos() async {
    final guardado = _cache;
    if (guardado != null) return guardado;

    final crudo = await _lector(ruta);
    final decodificado = jsonDecode(crudo);

    if (decodificado is! List) {
      throw const CampoInvalido('(raíz)', 'el archivo debe contener una lista', null);
    }

    return _cache = decodificado
        .map((e) => Reporte.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Reporte?> obtenerPorId(String id) async {
    for (final reporte in await obtenerTodos()) {
      if (reporte.id == id) return reporte;
    }
    return null;
  }

  @override
    Future<List<Reporte>> obtenerPendientes() async {
    final todos = await obtenerTodos();
    return todos.where((r) => r.estado is Pendiente).toList();
  }
}