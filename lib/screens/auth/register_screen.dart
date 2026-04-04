import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/core/constants/app_routes.dart';
import 'package:unibook/core/constants/app_strings.dart';
import 'package:unibook/core/utils/validators.dart';
import 'package:unibook/models/department_model.dart';
import 'package:unibook/providers/auth_provider.dart';
import 'package:unibook/services/firestore_service.dart';
import 'package:unibook/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _teacherCodeCtrl = TextEditingController();

  String _role = 'student';
  String? _departmentId;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _teacherCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _departmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Выберите кафедру'),
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
      role: _role,
      departmentId: _departmentId!,
      teacherCode: _teacherCodeCtrl.text,
    );

    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(auth.error ?? 'Ошибка регистрации. Попробуйте позже'),
        ),
      );
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.register)),
      body: FutureBuilder<List<DepartmentModel>>(
        future: context.read<FirestoreService>().getDepartments(),
        builder: (context, snapshot) {
          final departments = snapshot.data ?? [];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _nameCtrl,
                    label: AppStrings.name,
                    icon: Icons.person_outline,
                    validator: Validators.requiredField,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _emailCtrl,
                    label: AppStrings.email,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _passwordCtrl,
                    label: AppStrings.password,
                    icon: Icons.lock_outline,
                    obscureText: true,
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _role,
                    items: const [
                      DropdownMenuItem(value: 'student', child: Text('Студент')),
                      DropdownMenuItem(value: 'teacher', child: Text('Учитель')),
                    ],
                    onChanged: (v) => setState(() => _role = v ?? 'student'),
                    decoration: const InputDecoration(labelText: AppStrings.role),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _departmentId,
                    items: departments
                        .map(
                          (d) => DropdownMenuItem(
                            value: d.id,
                            child: Text(d.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _departmentId = v),
                    decoration: const InputDecoration(labelText: AppStrings.department),
                  ),
                  if (_role == 'teacher') ...[
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _teacherCodeCtrl,
                      label: AppStrings.teacherCode,
                      icon: Icons.verified,
                      validator: Validators.requiredField,
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: loading ? null : _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(AppStrings.register),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
