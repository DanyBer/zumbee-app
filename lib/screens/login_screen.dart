import 'package:flutter/material.dart';
import 'package:zumbee_app/core/mycolors.dart';
import 'package:zumbee_app/core/mytextstyles.dart';
import 'package:zumbee_app/screens/register_screen.dart';
import 'package:zumbee_app/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool hiddenPassword = true;
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

    Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final error = await _authService.login(
      _emailController.text,
      _passwordController.text,
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: MyColors.background),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Bienvenido de vuelta", style: MyTextStyles.screenTitle),
              Text(
                "Ingresa tu correo y contraseña para continuar",
                style: MyTextStyles.bodySmall,
              ),

              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: Text("CORREO ELECTRÓNICO", style: MyTextStyles.label),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  style: MyTextStyles.body,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Escribe tu correo';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: MyColors.surface,
                    hintText: "Introduce tu email",
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
                padding: const EdgeInsets.only(top: 32.0),
                child: Text("CONTRASEÑA", style: MyTextStyles.label),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextFormField(
                  controller: _passwordController,
                  style: MyTextStyles.body,
                  obscureText: hiddenPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Escribe tu contraseña';
                    }
                    return null;
                  },
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
                          hiddenPassword = !hiddenPassword;
                        });
                      },
                      icon: Icon(
                        hiddenPassword
                            ? Icons.remove_red_eye_outlined
                            : Icons.remove_red_eye,
                      ),
                    ),
                  ),
                ),
              ),

              if (errorMessage != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 16),
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
                    onPressed: isLoading ? null : _onLogin,
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        MyColors.primary,
                      ),
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
                        : Text("Entrar", style: MyTextStyles.button),
                  ),
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 65, left: 65),
                child: Row(
                  children: [
                    Text("¿No tienes cuenta?", style: MyTextStyles.bodySmall),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterScreen(),
                          ),
                        );
                      },
                      child: Text("Regístrate", style: MyTextStyles.link),
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