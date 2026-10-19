import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zumbee_app/core/mycolors.dart';
import 'package:zumbee_app/core/mytextstyles.dart';
import 'package:zumbee_app/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _apiaryController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _apiaryController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Escribe tu nombre';
    if (name.length < 3) return 'Muy corto';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Escribe tu correo';
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(email)) {
      return 'Correo no válido. Ejemplo: nombre@gmail.com';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Escribe una contraseña';
    if (password.length < 8) return 'Mínimo 8 caracteres';
    if (!RegExp(r'[A-Za-zÁÉÍÓÚáéíóúÑñ]').hasMatch(password)) {
      return 'Debe tener al menos una letra';
    }
    if (!RegExp(r'[\d\W]').hasMatch(password)) {
      return 'Debe tener al menos un número o un símbolo';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Repite la contraseña';
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return 'Escribe tu número';
    if (phone.length != 10) return 'Debe tener 10 dígitos';
    return null;
  }

  String? _validateApiary(String? value) {
    final apiary = value?.trim() ?? '';
    if (apiary.isEmpty) return 'Ponle un nombre a tu apiario';
    if (apiary.length < 3) return 'Muy corto';
    return null;
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final error = await _authService.register(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      phone: _phoneController.text,
      apiaryName: _apiaryController.text,
    );

    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    setState(() {
      isLoading = false;
      errorMessage = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      appBar: AppBar(
        backgroundColor: MyColors.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Crear cuenta", style: MyTextStyles.screenTitle),
              Text(
                "Registrate en todos los campos para continuar.",
                style: MyTextStyles.bodySmall,
              ),

              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: Text("NOMBRE COMPLETO", style: MyTextStyles.label),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  style: MyTextStyles.body,
                  textCapitalization: TextCapitalization.words,
                  autocorrect: false,
                  validator: _validateName,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: MyColors.surface,
                    hintText: "Introduce tu nombre",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: MyColors.border,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text("CORREO ELECTRÓNICO", style: MyTextStyles.label),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: MyTextStyles.body,
                  autocorrect: false,
                  validator: _validateEmail,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: MyColors.surface,
                    hintText: "Introduce tu correo electrónico",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: MyColors.border,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text("CONTRASEÑA", style: MyTextStyles.label),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextFormField(
                  controller: _passwordController,
                  style: MyTextStyles.body,
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],

                  decoration: InputDecoration(
                    filled: true,
                    fillColor: MyColors.surface,
                    hintText: "Introduce tu contraseña",

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: MyColors.border,
                        width: 1.5,
                      ),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.remove_red_eye_outlined
                            : Icons.remove_red_eye,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text("REPETIR CONTRASEÑA", style: MyTextStyles.label),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextFormField(
                  style: MyTextStyles.body,
                  obscureText: _obscureConfirmPassword,
                  validator: _validateConfirmPassword,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],

                  decoration: InputDecoration(
                    filled: true,
                    fillColor: MyColors.surface,
                    hintText: "Introduce de nuevo tu contraseña",

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: MyColors.border,
                        width: 1.5,
                      ),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.remove_red_eye_outlined
                            : Icons.remove_red_eye,
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text("NÚMERO DE TELEFONO", style: MyTextStyles.label),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: MyTextStyles.body,
                  maxLength: 10,
                  autocorrect: false,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: _validatePhone,
                  decoration: InputDecoration(
                    prefixText: "+57  ",
                    counterText: '',
                    filled: true,
                    fillColor: MyColors.surface,
                    hintText: "Introduce tu número de telefono",
                    prefixStyle: MyTextStyles.body,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: MyColors.border,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text("NOMBRE DEL APIARIO", style: MyTextStyles.label),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextFormField(
                  controller: _apiaryController,
                  keyboardType: TextInputType.text,
                  style: MyTextStyles.body,
                  textCapitalization: TextCapitalization.words,
                  validator: _validateApiary,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: MyColors.surface,
                    hintText: "Ejemplo: Apiario La Esperanza",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: MyColors.border,
                        width: 1.5,
                      ),
                    ),
                  ),
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

              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _onSubmit,
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
                    child: isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: MyColors.primaryText,
                            ),
                          )
                        : Text("Registrame", style: MyTextStyles.button),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 65, left: 65),
                child: Row(
                  children: [
                    Text("¿Ya tienes cuenta?", style: MyTextStyles.bodySmall),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Inicia sesión", style: MyTextStyles.link),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}