import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/core/constants/app_colors.dart';
import 'package:unibook/core/utils/file_utils.dart';
import 'package:unibook/core/utils/snackbar_utils.dart';
import 'package:unibook/core/utils/validators.dart';
import 'package:unibook/models/department_model.dart';
import 'package:unibook/providers/auth_provider.dart';
import 'package:unibook/providers/upload_provider.dart';
import 'package:unibook/services/firestore_service.dart';

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

  late final Future<List<DepartmentModel>> _departmentsFuture;

  File? _pdf;
  File? _cover;
  String? _departmentId;

  bool get _canSave =>
      _titleCtrl.text.trim().isNotEmpty &&
      _authorCtrl.text.trim().isNotEmpty &&
      _yearCtrl.text.trim().isNotEmpty &&
      _subjectCtrl.text.trim().isNotEmpty &&
      _departmentId != null &&
      _pdf != null;

  @override
  void initState() {
    super.initState();
    _departmentsFuture = context.read<FirestoreService>().getDepartments();
  }

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
      showError(context, 'Файл слишком большой. Максимум 50 МБ');
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
      showError(context, 'Заполните форму и выберите PDF');
      return;
    }

    final uploader = context.read<AuthProvider>().user;
    if (uploader == null) {
      showError(context, 'Требуется авторизация');
      return;
    }

    int year;
    try {
      year = int.parse(_yearCtrl.text);
    } catch (_) {
      showError(context, 'Некорректный год издания');
      return;
    }

    final ok = await context.read<UploadProvider>().uploadBook(
      uploader: uploader,
      pdf: _pdf!,
      title: _titleCtrl.text,
      author: _authorCtrl.text,
      year: year,
      subject: _subjectCtrl.text,
      departmentId: _departmentId!,
      cover: _cover,
      uploadPreset: 'unibook_upload',
    );

    if (!mounted) return;
    if (!ok) {
      showError(context, context.read<UploadProvider>().error ?? 'Ошибка загрузки');
      return;
    }

    showSuccess(context, 'Книга успешно загружена');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final upload = context.watch<UploadProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить книгу'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
          ),
        ),
      ),
      body: FutureBuilder<List<DepartmentModel>>(
        future: _departmentsFuture,
        builder: (context, snapshot) {
          final departments = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _SectionCard(
                    title: 'Информация о книге',
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleCtrl,
                          onChanged: (_) => setState(() {}),
                          validator: Validators.requiredField,
                          decoration: const InputDecoration(labelText: 'Название*'),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _authorCtrl,
                          onChanged: (_) => setState(() {}),
                          validator: Validators.requiredField,
                          decoration: const InputDecoration(labelText: 'Автор*'),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _yearCtrl,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          validator: Validators.year,
                          decoration: const InputDecoration(labelText: 'Год издания*'),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _subjectCtrl,
                          onChanged: (_) => setState(() {}),
                          validator: Validators.requiredField,
                          decoration: const InputDecoration(labelText: 'Предмет*'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Кафедра',
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _departmentId,
                      hint: const Text('Выберите кафедру'),
                      onChanged: (v) => setState(() => _departmentId = v),
                      validator: Validators.requiredField,
                      items: departments
                          .map(
                            (d) => DropdownMenuItem(
                              value: d.id,
                              child: Text(
                                '${d.name} — ${d.facultyName}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      decoration: const InputDecoration(labelText: 'Кафедра'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Файлы',
                    child: Column(
                      children: [
                        InkWell(
                          onTap: _pickPdf,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _pdf == null ? AppColors.primary : AppColors.success,
                                style: BorderStyle.solid,
                              ),
                              color: _pdf == null
                                  ? AppColors.primary.withValues(alpha: 0.04)
                                  : AppColors.success.withValues(alpha: 0.08),
                            ),
                            child: _pdf == null
                                ? const Column(
                                    children: [
                                      Icon(Icons.upload_file, size: 32, color: AppColors.primary),
                                      SizedBox(height: 6),
                                      Text('Выбрать PDF файл'),
                                      SizedBox(height: 2),
                                      Text(
                                        'Максимум 50 МБ',
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: AppColors.success,
                                        size: 28,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _pdf!.path.split('/').last,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${(_pdf!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} МБ',
                                      ),
                                      const Text(
                                        'Изменить',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed: _pickCover,
                            icon: const Icon(Icons.image_outlined),
                            label: Text(
                              _cover == null
                                  ? 'Добавить обложку (необязательно)'
                                  : 'Обложка выбрана',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (upload.isUploading)
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(value: upload.progress),
                        ),
                        const SizedBox(height: 6),
                        Text('Загрузка PDF... ${(upload.progress * 100).round()}%'),
                        const SizedBox(height: 8),
                      ],
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: upload.isUploading || !_canSave ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Сохранить книгу'),
                    ),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
