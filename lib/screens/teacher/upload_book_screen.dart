import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/core/constants/app_strings.dart';
import 'package:unibook/core/utils/file_utils.dart';
import 'package:unibook/core/utils/validators.dart';
import 'package:unibook/models/department_model.dart';
import 'package:unibook/providers/auth_provider.dart';
import 'package:unibook/providers/upload_provider.dart';
import 'package:unibook/services/firestore_service.dart';
import 'package:unibook/widgets/custom_text_field.dart';

class UploadBookScreen extends StatefulWidget {
  const UploadBookScreen({super.key});

  @override
  State<UploadBookScreen> createState() => _UploadBookScreenState();
}

class _UploadBookScreenState extends State<UploadBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();

  File? _pdf;
  File? _cover;
  String? _departmentId;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _yearCtrl.dispose();
    _subjectCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    final file = await FileUtils.pickPdf();
    if (!mounted || file == null) return;
    final valid = await FileUtils.isPdfSizeValid(file);
    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.red, content: Text(AppStrings.fileTooLarge)),
      );
      return;
    }
    setState(() => _pdf = file);
  }

  Future<void> _pickCover() async {
    final file = await FileUtils.pickImage();
    if (!mounted) return;
    setState(() => _cover = file);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _pdf == null || _departmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Заполните форму и выберите PDF'),
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final uploader = auth.user;
    if (uploader == null) return;

    final ok = await context.read<UploadProvider>().uploadBook(
          uploader: uploader,
          pdf: _pdf!,
          title: _titleCtrl.text,
          author: _authorCtrl.text,
          year: int.parse(_yearCtrl.text),
          subject: _subjectCtrl.text,
          departmentId: _departmentId!,
          cover: _cover,
          uploadPreset: 'unibook_upload',
        );

    if (!mounted) return;
    if (!ok) {
      final error = context.read<UploadProvider>().error ?? AppStrings.uploadFailed;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(backgroundColor: Colors.green, content: Text(AppStrings.uploadSuccess)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final upload = context.watch<UploadProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.addBook)),
      body: FutureBuilder<List<DepartmentModel>>(
        future: context.read<FirestoreService>().getDepartments(),
        builder: (context, snapshot) {
          final departments = snapshot.data ?? [];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _titleCtrl,
                    label: AppStrings.title,
                    validator: Validators.requiredField,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _authorCtrl,
                    label: AppStrings.author,
                    validator: Validators.requiredField,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _yearCtrl,
                    label: AppStrings.year,
                    keyboardType: TextInputType.number,
                    validator: Validators.year,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _subjectCtrl,
                    label: AppStrings.subject,
                    validator: Validators.requiredField,
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickPdf,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: Text(_pdf == null ? AppStrings.pickPdf : 'PDF выбран'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickCover,
                          icon: const Icon(Icons.image_outlined),
                          label: Text(_cover == null ? AppStrings.pickCover : 'Обложка выбрана'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (upload.isUploading)
                    Column(
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: upload.progress),
                          duration: const Duration(milliseconds: 250),
                          builder: (_, value, __) => LinearProgressIndicator(value: value),
                        ),
                        const SizedBox(height: 8),
                        Text('${(upload.progress * 100).toStringAsFixed(0)}%'),
                        const SizedBox(height: 8),
                      ],
                    ),
                  FilledButton(
                    onPressed: upload.isUploading ? null : _submit,
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                    child: const Text(AppStrings.save),
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
