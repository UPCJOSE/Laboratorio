import 'package:laboratorio/features/reportes/domain/reporte.dart';

/// Lo que la aplicación necesita saber de los reportes.
abstract interface class ReportesRepository {
  Future<List<Reporte>> obtenerTodos();

  Future<Reporte?> obtenerPorId(String id);
  
  Future<List<Reporte>> obtenerPendientes();
}