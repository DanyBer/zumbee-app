import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_ui/material_ui.dart';
import 'package:zumbee_app/core/mycolors.dart';
import 'package:zumbee_app/core/mytextstyles.dart';
import 'package:zumbee_app/services/node_service.dart';

/// Tarjeta "Estado de la colmena": muestra lo que calcula la Raspberry
/// (semáforo, estado estimado por el sonido, motivos, afuera, sonido, actuador).
/// Lee en vivo el documento nodes/{nodeId} de Firestore.
class AnalyticsCard extends StatelessWidget {
  final String nodeId;

  const AnalyticsCard({super.key, required this.nodeId});

  static const List<String> classIds = ['sana', 'sin_reina', 'varroa', 'enjambre'];
  static const List<String> classNames = [
    'Sana',
    'Sin reina',
    'Riesgo varroa (preliminar)',
    'Pre-enjambre',
  ];

  double? number(dynamic value) => value is num ? value.toDouble() : null;

  Map<String, dynamic> map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  String ageOf(dynamic stamp) {
    if (stamp is! Timestamp) return "";
    final seconds = DateTime.now().difference(stamp.toDate()).inSeconds;
    if (seconds < 60) return "hace un momento";
    if (seconds < 3600) return "hace ${seconds ~/ 60} min";
    return "hace ${seconds ~/ 3600} h";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: NodeService(nodeId).stream(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final analytics = map(data?['analitica']);
        final last = map(data?['ultimo']);
        final status = map(data?['estado']);
        final connection = map(data?['conexion']);
        final model = map(analytics['modelo']);
        final online = connection['en_linea'] != false;

        int light = (number(analytics['semaforo']) ?? 0).toInt();
        if (!online || light < 0 || light > 3) light = 0;

        final Color color = [
          MyColors.secondaryText,
          MyColors.healthy,
          MyColors.primary,
          MyColors.critical,
        ][light];
        final Color soft = [
          MyColors.background,
          MyColors.healthySoft,
          MyColors.primarySoft,
          MyColors.criticalSoft,
        ][light];
        final String lightText = !online
            ? "Nodo desconectado"
            : ["Sin datos", "Todo bien", "Atención", "Revisar la colmena"][light];

        final reasons = (analytics['motivos'] is List)
            ? List<String>.from(analytics['motivos'].map((m) => m.toString()))
            : <String>[];
        final probs = map(model['prob']);

        final freq = [number(last['f_izq']), number(last['f_der'])].whereType<double>().toList();
        final db = [number(last['a_izq']), number(last['a_der'])].whereType<double>().toList();
        final double? avgFreq = freq.isEmpty ? null : freq.reduce((a, b) => a + b) / freq.length;
        final double? avgDb = db.isEmpty ? null : db.reduce((a, b) => a + b) / db.length;

        final action = status['accion']?.toString() ?? 'ninguna';
        final remaining = (number(status['restante_s']) ?? 0) ~/ 60;
        final label = analytics['etiqueta_actuador']?.toString() ?? '';
        final String actuatorText = action == 'ninguna'
            ? "Apagado"
            : "${action == 'calentar' ? 'Calentando' : 'Enfriando'}"
                "${label.contains('auto') ? ' (automático)' : label.contains('app') ? ' (desde la app)' : ''}"
                " · quedan ~$remaining min";

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MyColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: MyColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text("ESTADO DE LA COLMENA", style: MyTextStyles.label)),
                  Text(ageOf(analytics['actualizado']), style: MyTextStyles.bodySmall),
                ],
              ),
              const SizedBox(height: 12),

              // ---------- Semáforo ----------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: soft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(lightText, style: MyTextStyles.subtitle.copyWith(color: color)),
                    ),
                  ],
                ),
              ),
              for (final reason in reasons)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text("• $reason", style: MyTextStyles.bodySmall),
                ),

              // ---------- Estado estimado por el sonido ----------
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Text("SONIDO (ESTIMADO)", style: MyTextStyles.label)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: MyColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Modelo preliminar",
                      style: MyTextStyles.chip.copyWith(color: MyColors.primaryStrong),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (model.isEmpty)
                Text(
                  analytics['audio'] == 'sin_zumbido'
                      ? "No se detecta zumbido de abejas"
                      : "Sin audio todavía",
                  style: MyTextStyles.bodySmall,
                )
              else ...[
                Text(
                  "${model['clase_texto']} · ${((number(model['confianza']) ?? 0) * 100).round()} %",
                  style: MyTextStyles.subtitle,
                ),
                const SizedBox(height: 8),
                for (int i = 0; i < 4; i++)
                  buildBar(classNames[i], number(probs[classIds[i]]) ?? 0,
                      i == 0 ? MyColors.healthy : i == 2 ? MyColors.critical : MyColors.primary),
              ],

              // ---------- Datos extra ----------
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  buildChip(Icons.thermostat, "Afuera",
                      "${number(last['t_ext'])?.toStringAsFixed(1) ?? '—'} °C · ${number(last['h_ext'])?.toStringAsFixed(0) ?? '—'} %"),
                  buildChip(Icons.graphic_eq, "Zumbido",
                      "${avgFreq?.toStringAsFixed(0) ?? '—'} Hz · ${avgDb?.toStringAsFixed(0) ?? '—'} dB"),
                  buildChip(Icons.compare_arrows, "Adentro − afuera",
                      "${number(analytics['delta_t'])?.toStringAsFixed(1) ?? '—'} °C"),
                  buildChip(Icons.local_fire_department_outlined, "Actuador", actuatorText),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "El estado por sonido es una estimación con un modelo entrenado en datos sintéticos basados en estudios publicados. No reemplaza la revisión de la colmena.",
                style: MyTextStyles.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildBar(String name, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(name, style: MyTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: value < 0 ? 0.0 : (value > 1 ? 1.0 : value),
                minHeight: 8,
                color: color,
                backgroundColor: MyColors.border,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text("${(value * 100).round()} %", style: MyTextStyles.bodySmall, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget buildChip(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: MyColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: MyColors.secondaryText),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: MyTextStyles.bodySmall),
                Text(value, style: MyTextStyles.bodySmall.copyWith(color: MyColors.primaryText, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
