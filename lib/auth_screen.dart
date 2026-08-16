import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'core/auth_service.dart';
import 'core/errors/app_failure.dart';
import 'models/user_profile.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({required this.auth, super.key});

  final AuthService auth;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await widget.auth.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on AppFailure catch (failure) {
      if (mounted) _showMessage(failure.message);
    } catch (_) {
      if (mounted) {
        _showMessage('Unable to sign in. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showMessage('Enter your email first, then choose Forgot password.');
      return;
    }
    setState(() => _loading = true);
    try {
      await widget.auth.sendPasswordReset(email);
      if (mounted) {
        _showMessage('Password reset instructions have been sent.');
      }
    } on AppFailure catch (failure) {
      if (mounted) _showMessage(failure.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 900;
            final form = _LoginForm(
              formKey: _formKey,
              emailController: _emailController,
              passwordController: _passwordController,
              obscurePassword: _obscurePassword,
              loading: _loading,
              onTogglePassword: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              onSignIn: _signIn,
              onResetPassword: _resetPassword,
              onCreateAccount: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SignUpScreen(auth: widget.auth),
                ),
              ),
            );
            if (!desktop) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: form,
                  ),
                ),
              );
            }
            return Row(
              children: [
                const Expanded(flex: 11, child: _AuthBrandPanel()),
                Expanded(
                  flex: 9,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: form,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AuthBrandPanel extends StatelessWidget {
  const _AuthBrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: const BoxDecoration(gradient: AppGradients.hero),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'MY CAMPUS',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(color: Colors.white, letterSpacing: 1.2),
              ),
            ],
          ),
          const Spacer(),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              'Stay connected with your campus life.',
              style: Theme.of(context).textTheme.displaySmall
                  ?.copyWith(color: Colors.white, height: 1.2),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Classes, schedules, notices and friends—organized in one place.',
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: Colors.white.withValues(alpha: 0.78)),
          ),
          const Spacer(),
          Text(
            'Securely powered by Firebase Authentication',
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: Colors.white.withValues(alpha: 0.68)),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.loading,
    required this.onTogglePassword,
    required this.onSignIn,
    required this.onResetPassword,
    required this.onCreateAccount,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool loading;
  final VoidCallback onTogglePassword;
  final VoidCallback onSignIn;
  final VoidCallback onResetPassword;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (MediaQuery.sizeOf(context).width < 900) ...[
              const Icon(Icons.school_rounded, size: 44),
              const SizedBox(height: AppSpacing.md),
              Text(
                'My Campus',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
            Text(
              'Welcome back',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Sign in to see your campus day at a glance.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.xl),
            TextFormField(
              controller: emailController,
              enabled: !loading,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'student@example.com',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return 'Enter your email.';
                if (!email.contains('@') || !email.contains('.')) {
                  return 'Enter a valid email address.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: passwordController,
              enabled: !loading,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => onSignIn(),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: obscurePassword ? 'Show password' : 'Hide password',
                  onPressed: loading ? null : onTogglePassword,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) => value == null || value.isEmpty
                  ? 'Enter your password.'
                  : null,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: loading ? null : onResetPassword,
                child: const Text('Forgot password?'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: loading ? null : onSignIn,
                child: loading
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : const Text('Sign in'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('New to My Campus?'),
                TextButton(
                  onPressed: loading ? null : onCreateAccount,
                  child: const Text('Create account'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({required this.auth, super.key});

  final AuthService auth;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _studentId = TextEditingController();
  final _email = TextEditingController();
  final _className = TextEditingController();
  final _course = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    for (final controller in [
      _name,
      _username,
      _studentId,
      _email,
      _className,
      _course,
      _password,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await widget.auth.register(
        email: _email.text,
        password: _password.text,
        profile: UserProfileDraft(
          name: _name.text,
          username: _username.text,
          studentId: _studentId.text,
          className: _className.text,
          course: _course.text,
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } on AppFailure catch (failure) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to create your account.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return 'Enter $label.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Set up your campus profile',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Private account details stay separate from the fields friends can search.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final twoColumns = constraints.maxWidth >= 620;
                        final width = twoColumns
                            ? (constraints.maxWidth - AppSpacing.md) / 2
                            : constraints.maxWidth;
                        final fields = <Widget>[
                          _field(
                            width,
                            controller: _name,
                            label: 'Full name',
                            icon: Icons.badge_outlined,
                          ),
                          _field(
                            width,
                            controller: _username,
                            label: 'Username',
                            icon: Icons.alternate_email_rounded,
                            helper: 'Friends can find you using this username.',
                            validator: (value) {
                              final required = _required(value, 'a username');
                              if (required != null) return required;
                              if (!RegExp(r'^[A-Za-z0-9._-]{3,30}$')
                                  .hasMatch(value!.trim())) {
                                return 'Use 3–30 letters, numbers, dots, dashes or underscores.';
                              }
                              return null;
                            },
                          ),
                          _field(
                            width,
                            controller: _studentId,
                            label: 'Student ID',
                            icon: Icons.credit_card_rounded,
                            helper: 'Used to help friends find you.',
                            validator: (value) {
                              final required = _required(value, 'a Student ID');
                              if (required != null) return required;
                              if (!RegExp(r'^[A-Za-z0-9-]{3,30}$')
                                  .hasMatch(value!.trim())) {
                                return 'Use 3–30 letters, numbers or dashes.';
                              }
                              return null;
                            },
                          ),
                          _field(
                            width,
                            controller: _email,
                            label: 'Student email',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              final required = _required(value, 'your email');
                              if (required != null) return required;
                              if (!value!.contains('@') ||
                                  !value.contains('.')) {
                                return 'Enter a valid email address.';
                              }
                              return null;
                            },
                          ),
                          _field(
                            width,
                            controller: _className,
                            label: 'Class',
                            icon: Icons.groups_2_outlined,
                          ),
                          _field(
                            width,
                            controller: _course,
                            label: 'Course',
                            icon: Icons.school_outlined,
                          ),
                        ];
                        return Wrap(
                          spacing: AppSpacing.md,
                          runSpacing: AppSpacing.md,
                          children: fields,
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _password,
                      enabled: !_loading,
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: 'Password',
                        helperText: 'Use at least 8 characters.',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          tooltip: _obscure ? 'Show password' : 'Hide password',
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter a password.';
                        }
                        if (value.length < 8) {
                          return 'Use at least 8 characters.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
                        child: _loading
                            ? const SizedBox.square(
                                dimension: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                ),
                              )
                            : const Text('Create account'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    double width, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? helper,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        enabled: !_loading,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          prefixIcon: Icon(icon),
        ),
        validator:
            validator ?? (value) => _required(value, label.toLowerCase()),
      ),
    );
  }
}
