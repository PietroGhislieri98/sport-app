import 'dart:ui';
import 'package:flutter/material.dart';
import '../api_client.dart';
import 'home_screen.dart';

/// --- Se li hai già nel login, rimuovi queste classi duplicate e importa da lì. ---
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final FormFieldValidator<String>? validator;

  const CustomTextField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      cursorColor: theme.colorScheme.onSurface,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintText: hintText,
        hintStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.primary),
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(.25)),
          borderRadius: BorderRadius.circular(12.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.error),
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface.withOpacity(0.6),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final Widget child;
  const _GlassPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.45),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
/// --- fine utility ---

class RegisterPage extends StatefulWidget {
  final ApiClient api;
  const RegisterPage({super.key, required this.api});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _hidePwd = true;
  bool _hideConfirm = true;
  bool _loading = false;
  bool _acceptedTerms = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final formOk = _formKey.currentState?.validate() ?? false;
    if (!formOk) return;
    if (!_acceptedTerms) {
      setState(() => _error = 'Devi accettare i Termini per continuare.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.api.register(_name.text.trim(), _email.text.trim(), _password.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen(api: widget.api)),
      );
    } catch (e) {
      setState(() {
        _error = 'Registrazione non riuscita. Verifica i dati o riprova più tardi.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.2),
              theme.colorScheme.secondary.withOpacity(0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: _GlassPanel(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Crea il tuo account',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Unisciti a MatchUp in pochi secondi',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(.8),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            children: [
                              CustomTextField(
                                controller: _name,
                                hintText: 'Nome e cognome',
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Inserisci il tuo nome';
                                  }
                                  if (v.trim().length < 2) {
                                    return 'Inserisci un nome valido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              CustomTextField(
                                controller: _email,
                                hintText: 'Email',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Inserisci la tua email';
                                  }
                                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Email non valida';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  CustomTextField(
                                    controller: _password,
                                    hintText: 'Password',
                                    obscureText: _hidePwd,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Inserisci una password';
                                      if (v.length < 8) return 'Minimo 8 caratteri';
                                      return null;
                                    },
                                  ),
                                  IconButton(
                                    onPressed: () => setState(() => _hidePwd = !_hidePwd),
                                    icon: Icon(
                                      _hidePwd ? Icons.visibility_off : Icons.visibility,
                                      color: theme.colorScheme.onSurface.withOpacity(.7),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  CustomTextField(
                                    controller: _confirm,
                                    hintText: 'Conferma password',
                                    obscureText: _hideConfirm,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Conferma la password';
                                      if (v != _password.text) return 'Le password non coincidono';
                                      return null;
                                    },
                                  ),
                                  IconButton(
                                    onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
                                    icon: Icon(
                                      _hideConfirm ? Icons.visibility_off : Icons.visibility,
                                      color: theme.colorScheme.onSurface.withOpacity(.7),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _acceptedTerms,
                                    onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Accetto i Termini e l’Informativa Privacy',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(.8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_error != null) ...[
                                const SizedBox(height: 4),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 52,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: theme.colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 10,
                                    shadowColor: theme.shadowColor.withOpacity(0.25),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          height: 22, width: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2.2),
                                        )
                                      : Text(
                                          'Crea account',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
