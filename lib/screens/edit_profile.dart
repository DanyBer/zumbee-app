import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zumbee_app/components/zumbee_app_bar.dart';
import 'package:zumbee_app/core/app_state.dart';
import 'package:zumbee_app/core/mycolors.dart';
import 'package:zumbee_app/core/mytextstyles.dart';
import 'package:zumbee_app/services/auth_service.dart';
import 'package:zumbee_app/services/database_service.dart';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic> profile;

  const EditProfile({super.key, required this.profile});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _apiaryController = TextEditingController();

  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.profile['name']?.toString() ?? '';
    _phoneController.text = widget.profile['phone']?.toString() ?? '';
    _apiaryController.text = widget.profile['apiaryName']?.toString() ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _apiaryController.dispose();
    super.dispose();
  }

  Future<void> onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    try {
      await DatabaseService().updateUserProfile(
        name: _nameController.text,
        phone: _phoneController.text,
        apiaryName: _apiaryController.text,
      );

      await AuthService().currentUser?.updateDisplayName(
        _nameController.text.trim(),
      );

      AppState.apiaryName.value = _apiaryController.text.trim();

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
    final String email = widget.profile['email']?.toString() ?? '';

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
              Text("Editar mis datos", style: MyTextStyles.screenTitle),
              SizedBox(height: 8),
              Text(
                "Los cambios se guardan en la base de datos",
                style: MyTextStyles.bodySmall,
              ),

              SizedBox(height: 24),
              Text("NOMBRE COMPLETO", style: MyTextStyles.label),
              SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                style: MyTextStyles.body,
                textCapitalization: TextCapitalization.words,
                autocorrect: false,
                maxLength: 40,
                validator: (value) {
                  final name = value?.trim() ?? '';
                  if (name.isEmpty) return 'Escribe tu nombre';
                  if (name.length < 3) return 'Muy corto';
                  return null;
                },
                decoration: fieldStyle("Introduce tu nombre"),
              ),

              SizedBox(height: 20),
              Text("NÚMERO DE TELEFONO", style: MyTextStyles.label),
              SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: MyTextStyles.body,
                maxLength: 10,
                autocorrect: false,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  final phone = value?.trim() ?? '';
                  if (phone.isEmpty) return 'Escribe tu número';
                  if (phone.length != 10) return 'Debe tener 10 dígitos';
                  return null;
                },
                decoration: InputDecoration(
                  prefixText: "+57  ",
                  counterText: '',
                  filled: true,
                  fillColor: MyColors.surface,
                  hintText: "Introduce tu número de telefono",
                  prefixStyle: MyTextStyles.body,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: MyColors.border, width: 1.5),
                  ),
                ),
              ),

              SizedBox(height: 20),
              Text("NOMBRE DEL APIARIO", style: MyTextStyles.label),
              SizedBox(height: 8),
              TextFormField(
                controller: _apiaryController,
                keyboardType: TextInputType.text,
                style: MyTextStyles.body,
                textCapitalization: TextCapitalization.words,
                maxLength: 40,
                validator: (value) {
                  final apiary = value?.trim() ?? '';
                  if (apiary.isEmpty) return 'Ponle un nombre a tu apiario';
                  if (apiary.length < 3) return 'Muy corto';
                  return null;
                },
                decoration: fieldStyle("Apiario La Esperanza"),
              ),

              SizedBox(height: 20),
              Text("CORREO ELECTRÓNICO", style: MyTextStyles.label),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MyColors.border,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  email,
                  style: MyTextStyles.body.copyWith(
                    color: MyColors.secondaryText,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                "El correo es tu identificador de acceso y no se puede cambiar desde aquí.",
                style: MyTextStyles.bodySmall,
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
                      : Text("Guardar cambios", style: MyTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
