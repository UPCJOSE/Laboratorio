import 'package:laboratorio/core/json.dart';


/// Dónde ocurrió lo que se reporta.
///
/// Es un **objeto de valor**: dos ubicaciones con las mismas coordenadas son
/// la misma ubicación, así que no lleva `id` y se compara por contenido.
class Ubicacion {
  const Ubicacion({
    required this.latitud,
    required this.longitud,
    required this.barrio,
    }) : assert(latitud >= -90 && latitud <= 90, 'latitud fuera de rango'),
     assert(longitud >= -180 && longitud <= 180, 'longitud fuera de rango');
 
  factory Ubicacion.fromJson(Map<String, dynamic> json) => Ubicacion(
        latitud: leerDecimal(json, 'latitud'),
        longitud: leerDecimal(json, 'longitud'),
        barrio: leerTexto(json, 'barrio'),
      );
 
  final double latitud;
  final double longitud;
  final String barrio;
 
  Map<String, dynamic> toJson() => {
        'latitud': latitud,
        'longitud': longitud,
        'barrio': barrio,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ubicacion &&
          other.latitud == latitud &&
          other.longitud == longitud &&
          other.barrio == barrio;
 
  @override
  int get hashCode => Object.hash(latitud, longitud, barrio);
 
  @override
  String toString() => 'Ubicacion($barrio, $latitud, $longitud)';
}