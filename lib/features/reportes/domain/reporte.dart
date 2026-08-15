import 'package:laboratorio/core/comparaciones.dart';
import 'package:laboratorio/core/json.dart';
import 'package:laboratorio/features/reportes/domain/estado_reporte.dart';
import 'package:laboratorio/features/reportes/domain/ubicacion.dart';

/// Un aviso ciudadano.
///
/// Es una **entidad**: tiene identidad propia. Dos reportes con el mismo texto
/// son dos reportes distintos si tienen `id` distinto.
class Reporte {
  const Reporte({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.ubicacion,
    required this.creadoEn,
    required this.estado,
    this.fotos = const <String>[],
  });

  factory Reporte.fromJson(Map<String, dynamic> json) => Reporte(
    id: leerTexto(json, 'id'),
    titulo: leerTexto(json, 'titulo'),
    descripcion: leerTexto(json, 'descripcion'),
    ubicacion: Ubicacion.fromJson(leerMapa(json, 'ubicacion')),
    creadoEn: leerFecha(json, 'creadoEn'),
    estado: EstadoReporte.fromJson(leerMapa(json, 'estado')),
    fotos: leerTextos(json, 'fotos'),
  );

  final String id;
  final String titulo;
  final String descripcion;
  final Ubicacion ubicacion;
  final DateTime creadoEn;
  final EstadoReporte estado;
  final List<String> fotos;

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'descripcion': descripcion,
    'ubicacion': ubicacion.toJson(),
    'creadoEn': creadoEn.toUtc().toIso8601String(),
    'estado': estado.toJson(),
    'fotos': fotos,
  };

  // ── Reglas de negocio ───────────────────────────────────────────────────

  bool get tieneEvidencia => fotos.isNotEmpty;

  bool get sePuedeEditar => estado.sePuedeEditar;

  Duration antiguedad(DateTime ahora) => ahora.difference(creadoEn);

  bool estaVencido(DateTime ahora) =>
      antiguedad(ahora) > const Duration(days: 30);

  // ── Copia ───────────────────────────────────────────────────────────────

  Reporte copyWith({
    String? titulo,
    String? descripcion,
    Ubicacion? ubicacion,
    EstadoReporte? estado,
    List<String>? fotos,
  }) => Reporte(
    id: id,
    titulo: titulo ?? this.titulo,
    descripcion: descripcion ?? this.descripcion,
    ubicacion: ubicacion ?? this.ubicacion,
    creadoEn: creadoEn,
    estado: estado ?? this.estado,
    fotos: fotos ?? this.fotos,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reporte &&
          other.id == id &&
          other.titulo == titulo &&
          other.descripcion == descripcion &&
          other.ubicacion == ubicacion &&
          other.creadoEn == creadoEn &&
          other.estado == estado &&
          listasIguales(other.fotos, fotos);

  @override
  int get hashCode => Object.hash(
    id,
    titulo,
    descripcion,
    ubicacion,
    creadoEn,
    estado,
    Object.hashAll(fotos),
  );

  @override
  String toString() => 'Reporte($id, $titulo, ${estado.etiqueta})';
}
