import 'package:material_ui/material_ui.dart';

import '../../core/api_client.dart';
import '../../core/sesion.dart';
import '../../core/tema.dart';

/// Vista del tratante (HU-18, RF-30).
///
/// Muestra las alertas y el último resumen de `GET /tratante/paciente`, y
/// genera uno nuevo con `POST /resumen`. Nunca muestra la conversación: las
/// alertas se muestran solo con nivel y fecha.
class TratanteScreen extends StatefulWidget {
  const TratanteScreen({super.key, this.api});

  /// Permite inyectar el cliente en pruebas; por defecto usa la sesión activa.
  final ApiClient? api;

  @override
  State<TratanteScreen> createState() => _TratanteEstado();
}

class _TratanteEstado extends State<TratanteScreen> {
  late final ApiClient _api =
      widget.api ?? ApiClient(usuarioId: Sesion.usuarioId);

  Map<String, dynamic>? _vista;
  bool _cargando = true;
  bool _generando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final datos =
          await _api.get('/tratante/paciente') as Map<String, dynamic>;
      if (mounted) setState(() => _vista = datos);
    } catch (e) {
      if (mounted) setState(() => _error = mensajeDeError(e));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _generarResumen() async {
    setState(() {
      _generando = true;
      _error = null;
    });
    try {
      final resumen = await _api.post('/resumen') as Map<String, dynamic>;
      if (mounted) setState(() => _vista = {..._vista!, 'resumen': resumen});
    } catch (e) {
      if (mounted) setState(() => _error = mensajeDeError(e));
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Vista del tratante')),
      body: _cargando
          ? const Center(child: Text('Cargando…'))
          : _vista == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error ?? 'No hay datos disponibles.',
                        textAlign: TextAlign.center),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _Bloque(
                      titulo: 'Paciente',
                      hijo: Text(
                        (_vista!['nombre'] ?? _vista!['paciente_id'])
                            .toString(),
                        style: tema.textTheme.titleLarge,
                      ),
                    ),
                    _Bloque(
                      titulo: 'Alertas',
                      hijo: _Alertas(
                          alertas: (_vista!['alertas'] as List<dynamic>?) ??
                              const []),
                    ),
                    _Bloque(
                      titulo: 'Resumen semanal',
                      etiqueta: 'Generado por IA',
                      hijo: _Resumen(
                          resumen: _vista!['resumen'] as Map<String, dynamic>?),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _error!,
                          style: tema.textTheme.bodySmall
                              ?.copyWith(color: tema.colorScheme.error),
                        ),
                      ),
                    FilledButton(
                      onPressed: _generando ? null : _generarResumen,
                      child: Text(
                          _generando ? 'Generando…' : 'Generar resumen nuevo'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Herramienta de apoyo. Los resúmenes se interpretan con criterio profesional y no son un diagnóstico.',
                      style: tema.textTheme.bodySmall,
                    ),
                  ],
                ),
    );
  }
}

class _Bloque extends StatelessWidget {
  const _Bloque({required this.titulo, required this.hijo, this.etiqueta});

  final String titulo;
  final Widget hijo;
  final String? etiqueta;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tema.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(titulo, style: tema.textTheme.titleMedium)),
              if (etiqueta != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: HoloTema.superficieAlta,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(etiqueta!, style: tema.textTheme.bodySmall),
                ),
            ],
          ),
          const SizedBox(height: 10),
          hijo,
        ],
      ),
    );
  }
}

class _Alertas extends StatelessWidget {
  const _Alertas({required this.alertas});

  final List<dynamic> alertas;

  @override
  Widget build(BuildContext context) {
    if (alertas.isEmpty) {
      return Text('Sin alertas recientes.',
          style: Theme.of(context).textTheme.bodySmall);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final a in alertas)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'Nivel ${(a as Map<String, dynamic>)['nivel']} · ${a['fecha']}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }
}

class _Resumen extends StatelessWidget {
  const _Resumen({required this.resumen});

  final Map<String, dynamic>? resumen;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    if (resumen == null) {
      return Text(
        'Aún no hay resumen. Genera uno nuevo para ver los hechos de la última semana.',
        style: tema.textTheme.bodySmall,
      );
    }
    final temas = (resumen!['temas'] as List<dynamic>?) ?? const [];
    final hechos = (resumen!['hechos'] as List<dynamic>?) ?? const [];
    final patrones = (resumen!['patrones'] as List<dynamic>?) ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (temas.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final t in temas) Chip(label: Text(t.toString()))],
          ),
        const SizedBox(height: 10),
        for (final h in hechos)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '${(h as Map<String, dynamic>)['fecha']} · ${h['descripcion']}',
              style: tema.textTheme.bodyMedium,
            ),
          ),
        if (patrones.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Patrones observados', style: tema.textTheme.titleMedium),
          for (final p in patrones)
            Text('• $p', style: tema.textTheme.bodyMedium),
        ],
      ],
    );
  }
}
