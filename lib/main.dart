import 'package:flutter/material.dart';
import 'package:laboratorio/features/reportes/data/reportes_locales.dart';
import 'package:laboratorio/features/reportes/domain/reporte.dart';

// Punto de entrada de toda la app. runApp() "monta" el widget raíz en pantalla.
void main() => runApp(const MiApp());

// Widget raíz de la aplicación. StatelessWidget porque no necesita cambiar
// nada por sí mismo, solo define el "esqueleto" general (tema, título, home).
class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Reportes',
        // colorSchemeSeed genera automáticamente toda la paleta de colores
        // de Material Design a partir de un solo color base.
        theme: ThemeData(colorSchemeSeed: Colors.indigo),
        // 'home' es la primera pantalla que se muestra al abrir la app.
        home: const PantallaReportes(),
      );
}

// Esta pantalla SÍ necesita ser Stateful, porque tiene que "recordar"
// el resultado de la carga del JSON (el Future) mientras el usuario
// interactúa con la app.
class PantallaReportes extends StatefulWidget {
  const PantallaReportes({super.key});

  @override
  State<PantallaReportes> createState() => _PantallaReportesState();
}

class _PantallaReportesState extends State<PantallaReportes> {
  // OJO con esto: 'late final' + inicializado en el campo (no en initState
  // ni en build) significa que ReportesLocales().obtenerTodos() se llama
  // UNA SOLA VEZ, cuando se crea el State.
  //
  // Si en cambio pusieras esta línea DENTRO de build(), cada vez que Flutter
  // redibuja la pantalla (lo cual pasa muy seguido) volvería a leer el
  // archivo JSON desde cero. Eso causa que la lista "parpadee" en un loop
  // sin fin porque nunca termina de cargar de verdad.
  late final Future<List<Reporte>> _reportes = ReportesLocales().obtenerTodos();

  @override
  Widget build(BuildContext context) => Scaffold(
        // Scaffold = la estructura básica de una pantalla Material
        // (barra superior, cuerpo, botones flotantes, etc.)
        appBar: AppBar(title: const Text('Reportes')),

        // FutureBuilder es el widget que "espera" a que un Future termine
        // y reconstruye la pantalla automáticamente según su estado:
        // cargando / error / listo.
        body: FutureBuilder<List<Reporte>>(
          future: _reportes,
          builder: (context, snapshot) {
            // Mientras el Future todavía no ha terminado (está leyendo
            // el archivo), muestra un círculo de carga.
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            // Si el Future terminó pero con un error (por ejemplo, un
            // CampoInvalido porque el JSON está mal formado), lo mostramos
            // en pantalla tal cual. Aquí es donde se ve el beneficio de
            // haber escrito CampoInvalido con mensajes claros en el Paso 4:
            // en vez de un error genérico, dice EXACTAMENTE qué campo falló.
            if (snapshot.hasError) {
              return Center(child: Text('No se pudo leer:\n${snapshot.error}'));
            }

            // Si todo salió bien, snapshot.data trae la lista de Reporte.
            // El '?? const <Reporte>[]' es una protección extra: si por
            // algún motivo data fuera null, usamos una lista vacía en vez
            // de que la app truene.
            final reportes = snapshot.data ?? const <Reporte>[];

            // ListView.separated dibuja la lista con una línea divisoria
            // (Divider) entre cada elemento.
            return ListView.separated(
              itemCount: reportes.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final reporte = reportes[i];
                // ListTile es el "renglón" típico de una lista: título,
                // subtítulo, e ícono opcional a la derecha (trailing).
                return ListTile(
                  title: Text(reporte.titulo),
                  // Aquí usamos directamente los datos de tu dominio:
                  // reporte.ubicacion.barrio viene de tu clase Ubicacion,
                  // reporte.estado.etiqueta viene del getter que escribiste
                  // en EstadoReporte (el switch que arma el texto según
                  // el tipo de estado).
                  subtitle: Text(
                    '${reporte.ubicacion.barrio} · ${reporte.estado.etiqueta}',
                  ),
                  // tieneEvidencia es la regla de negocio que escribiste
                  // en Reporte (fotos.isNotEmpty). Si es true, muestra un
                  // ícono de foto; si no, no muestra nada (null).
                  trailing: reporte.tieneEvidencia
                      ? const Icon(Icons.photo_outlined)
                      : null,
                );
              },
            );
          },
        ),
      );
}