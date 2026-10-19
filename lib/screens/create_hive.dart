import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zumbee_app/components/zumbee_app_bar.dart';
import 'package:zumbee_app/core/app_state.dart';
import 'package:zumbee_app/core/mycolors.dart';
import 'package:zumbee_app/core/mytextstyles.dart';
import 'package:zumbee_app/services/database_service.dart';

class CreateHive extends StatefulWidget {
  final Map<String, dynamic>? hive;

  const CreateHive({super.key, this.hive});

  @override
  State<CreateHive> createState() => _CreateHiveState();
}

class _CreateHiveState extends State<CreateHive> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _typeController = TextEditingController();
  final _nodeController = TextEditingController();
  final _channelController = TextEditingController();

  bool isSaving = false;
  String? errorMessage;

  bool get isEditing => widget.hive != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.hive!['name']?.toString() ?? '';
      _locationController.text = widget.hive!['location']?.toString() ?? '';
      _typeController.text = widget.hive!['hiveType']?.toString() ?? '';
      _nodeController.text = widget.hive!['nodeIdentifier']?.toString() ?? '';
      _channelController.text = widget.hive!['channelId']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _typeController.dispose();
    _nodeController.dispose();
    _channelController.dispose();
    super.dispose();
  }

  Future<void> onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    try {
      if (isEditing) {
        await DatabaseService().updateHive(
          hiveId: widget.hive!['id'],
          name: _nameController.text,
          location: _locationController.text,
          hiveType: _typeController.text,
          nodeIdentifier: _nodeController.text,
          channelId: _channelController.text,
        );

        if (AppState.selectedId == widget.hive!['id']) {
          AppState.select({
            'id': widget.hive!['id'],
            'name': _nameController.text.trim(),
            'location': _locationController.text.trim(),
            'hiveType': _typeController.text.trim(),
            'nodeIdentifier': _nodeController.text.trim(),
            'channelId': _channelController.text.trim(),
          });
        }
      } else {
        final newId = await DatabaseService().addHive(
          name: _nameController.text,
          location: _locationController.text,
          hiveType: _typeController.text,
          nodeIdentifier: _nodeController.text,
          channelId: _channelController.text,
        );

        if (AppState.selectedId == null) {
          AppState.select({
            'id': newId,
            'name': _nameController.text.trim(),
            'location': _locationController.text.trim(),
            'hiveType': _typeController.text.trim(),
            'nodeIdentifier': _nodeController.text.trim(),
            'channelId': _channelController.text.trim(),
          });
        }
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        isSaving = false;
        errorMessage = "No se pudo guardar. Revisa tu conexión.";
      });
    }
  }

  Future<void> onDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: MyColors.surface,
        title: Text("Eliminar colmena", style: MyTextStyles.subtitle),
        content: Text(
          "Esta acción no se puede deshacer.",
          style: MyTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text("Cancelar", style: MyTextStyles.bodySmall),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              "Eliminar",
              style: MyTextStyles.bodySmall.copyWith(
                color: MyColors.criticalStrong,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => isSaving = true);

    try {
      await DatabaseService().deleteHive(widget.hive!['id']);

      if (AppState.selectedId == widget.hive!['id']) {
        AppState.select(null);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        isSaving = false;
        errorMessage = "No se pudo eliminar. Revisa tu conexión.";
      });
    }
  }

  InputDecoration fieldStyle(String hint) {
    return InputDecoration(
      counterText: '',
      filled: true,
      fillColor: MyColors.surface,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: MyColors.border, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      appBar: ZumbeeAppBar(showPerfil: false),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? "Editar colmena" : "Nueva colmena",
                style: MyTextStyles.screenTitle,
              ),
              SizedBox(height: 8),
              Text(
                isEditing
                    ? "Los cambios se guardan en la base de datos"
                    : "La colmena quedará registrada en tu apiario",
                style: MyTextStyles.bodySmall,
              ),

              SizedBox(height: 16),
              Text("NOMBRE", style: MyTextStyles.label),
              SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: MyTextStyles.body,
                maxLines: 1,
                maxLength: 30,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  final name = value?.trim() ?? '';
                  if (name.isEmpty) return 'Ponle un nombre a la colmena';
                  if (name.length < 3) return 'Muy corto';
                  return null;
                },
                decoration: fieldStyle("Colmena 01"),
              ),

              SizedBox(height: 16),
              Text("UBICACIÓN", style: MyTextStyles.label),
              SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                style: MyTextStyles.body,
                maxLines: 1,
                maxLength: 30,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if ((value?.trim() ?? '').isEmpty) {
                    return 'Escribe dónde está ubicada';
                  }
                  return null;
                },
                decoration: fieldStyle("Vereda Hipaquirá"),
              ),

              SizedBox(height: 16),
              Text("TIPO DE COLMENA", style: MyTextStyles.label),
              SizedBox(height: 8),
              TextFormField(
                controller: _typeController,
                style: MyTextStyles.body,
                maxLines: 1,
                maxLength: 30,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if ((value?.trim() ?? '').isEmpty) {
                    return 'Escribe el tipo de colmena';
                  }
                  return null;
                },
                decoration: fieldStyle("Langstroth"),
              ),

              SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MyColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: MyColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("NODO IoT", style: MyTextStyles.label),
                    SizedBox(height: 4),
                    Text(
                      "Si esta colmena ya tiene nodo instalado, escribe su canal de ThingSpeak. Si lo dejas vacío, la colmena se registra pero no mostrará mediciones.",
                      style: MyTextStyles.bodySmall,
                    ),

                    SizedBox(height: 16),
                    Text("CANAL DE THINGSPEAK", style: MyTextStyles.label),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _channelController,
                      style: MyTextStyles.body,
                      maxLines: 1,
                      maxLength: 15,
                      autocorrect: false,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: fieldStyle("3533092"),
                    ),

                    SizedBox(height: 16),
                    Text("IDENTIFICADOR DEL NODO", style: MyTextStyles.label),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _nodeController,
                      style: MyTextStyles.body,
                      maxLines: 1,
                      maxLength: 30,
                      autocorrect: false,
                      decoration: fieldStyle("identity1"),
                    ),
                  ],
                ),
              ),

              if (errorMessage != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MyColors.criticalSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: MyColors.critical),
                  ),
                  child: Text(
                    errorMessage!,
                    style: MyTextStyles.bodySmall.copyWith(
                      color: MyColors.criticalStrong,
                    ),
                  ),
                ),

              SizedBox(height: 40),
              SizedBox(
                height: 60,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : onSave,
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(MyColors.primary),
                    foregroundColor: WidgetStatePropertyAll(
                      MyColors.primaryText,
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  child: isSaving
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: MyColors.primaryText,
                          ),
                        )
                      : Text(
                          isEditing ? "Guardar cambios" : "Crear colmena",
                          style: MyTextStyles.button,
                        ),
                ),
              ),

              if (isEditing) SizedBox(height: 16),
              if (isEditing)
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : onDelete,
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        MyColors.background,
                      ),
                      foregroundColor: WidgetStatePropertyAll(
                        MyColors.critical,
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: MyColors.criticalStrong,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    child: Text("Eliminar colmena", style: MyTextStyles.button),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}