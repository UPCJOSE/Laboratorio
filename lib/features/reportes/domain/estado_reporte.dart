import 'package:laboratorio/core/json.dart';

/// En qué punto de su vida está un reporte.
///
/// `sealed` significa dos cosas: nadie fuera de este archivo puede añadir un
/// estado, y el compilador conoce la lista completa. Eso es lo que hace que
/// los `switch` de abajo puedan ser exhaustivos sin `default`.

sealed class EstadoReporte {
  const EstadoReporte();

/// El ÚNICO sitio donde un texto del JSON se convierte en un tipo.
    factory EstadoReporte.fromJson(Map<String, dynamic> json) {
    final tipo = leerTexto(json, 'tipo');
    return switch (tipo) {
      'desconocido' => const Desconocido(),
      'pendiente' => Pendiente(
          leerTexto(json, 'prioridad'),
          leerTexto(json, 'asignadoA'),
        ),
      'en_proceso' => EnProceso(leerTexto(json, 'asignadoA')),
      'resuelto' => Resuelto(
          leerFecha(json, 'fechaCierre'),
          leerTexto(json, 'verificadoPor'),
        ),
      _ => throw CampoInvalido('estado.tipo', 'no es un estado conocido', tipo),
    };
  }

  /// Y el único sitio donde vuelve a ser texto. Simétrico a fromJson: si
  /// añades un estado arriba y olvidas añadirlo aquí, esto no compila.
  /// 
  Map<String, dynamic> toJson() => switch (this) {
      Desconocido() => {'tipo': 'desconocido'},
      Pendiente(:final prioridad, :final asignadoA) => {
          'tipo': 'pendiente',
          'prioridad': prioridad,
          'asignadoA': asignadoA,
        },
      EnProceso(:final asignadoA) => {
          'tipo': 'en_proceso',
          'asignadoA': asignadoA,
        },
      Resuelto(:final fechaCierre, :final verificadoPor) => {
          'tipo': 'resuelto',
          'fechaCierre': fechaCierre.toIso8601String(),
          'verificadoPor': verificadoPor,
        },
        
    };

  /// Regla de negocio, no de interfaz: quién puede tocar el reporte.
  bool get sePuedeEditar => switch (this) {        // ← empieza un getter NUEVO, separado
      Desconocido() || Pendiente() => true,
      EnProceso() || Resuelto() => false,
    };

  /// Texto para la pantalla. En un proyecto con varios idiomas esto se va a
  /// la capa de presentación; con uno solo, aquí está bien y se prueba fácil.
  
  String get etiqueta => switch (this) {
      Desconocido() => 'Sin revisar',
      Pendiente(:final prioridad) => 'Pendiente · prioridad $prioridad',
      EnProceso(:final asignadoA) => 'En proceso · $asignadoA',
      Resuelto(:final verificadoPor) => 'Resuelto por $verificadoPor',
    };
}

final class Desconocido extends EstadoReporte {
  const Desconocido();

  @override
  bool operator ==(Object other) => other is Desconocido;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Desconocido()';
}

final class Pendiente extends EstadoReporte {
  const Pendiente(this.prioridad, this.asignadoA);

  final String prioridad;
  final String asignadoA;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pendiente &&
          other.prioridad == prioridad &&
          other.asignadoA == asignadoA;

  @override
  int get hashCode => Object.hash(runtimeType, prioridad, asignadoA);

  @override
  String toString() => 'Pendiente($prioridad, $asignadoA)';
}

final class EnProceso extends EstadoReporte {
  const EnProceso(this.asignadoA);

  final String asignadoA;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is EnProceso && other.asignadoA == asignadoA;

  @override
  int get hashCode => Object.hash(runtimeType, asignadoA);

  @override
  String toString() => 'EnProceso($asignadoA)';
}

final class Resuelto extends EstadoReporte {
  const Resuelto(this.fechaCierre, this.verificadoPor);

  final DateTime fechaCierre;
  final String verificadoPor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Resuelto &&
          other.fechaCierre == fechaCierre &&
          other.verificadoPor == verificadoPor;

  @override
  int get hashCode => Object.hash(runtimeType, fechaCierre, verificadoPor);

  @override
  String toString() => 'Resuelto($fechaCierre, $verificadoPor)';
}