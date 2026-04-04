import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/models/department_model.dart';
import 'package:unibook/services/firestore_service.dart';

class AdminDepartmentsScreen extends StatelessWidget {
  const AdminDepartmentsScreen({super.key});

  Future<void> _showForm(
    BuildContext context, {
    DepartmentModel? department,
  }) async {
    final nameCtrl = TextEditingController(text: department?.name ?? '');
    final codeCtrl = TextEditingController(text: department?.code ?? '');
    final service = context.read<FirestoreService>();

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(department == null ? 'Новая кафедра' : 'Редактировать кафедру'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Название')),
            const SizedBox(height: 10),
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Код')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          FilledButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty || codeCtrl.text.trim().isEmpty) return;
              if (department == null) {
                await service.addDepartment(nameCtrl.text, codeCtrl.text);
              } else {
                await service.updateDepartment(
                  id: department.id,
                  name: nameCtrl.text,
                  code: codeCtrl.text,
                );
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<FirestoreService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Кафедры')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<DepartmentModel>>(
        stream: service.streamDepartments(),
        builder: (context, snapshot) {
          final departments = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: departments.length,
            itemBuilder: (context, index) {
              final department = departments[index];
              return Card(
                child: ListTile(
                  title: Text(department.name),
                  subtitle: Text('Код: ${department.code} • Книг: ${department.bookCount}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _showForm(context, department: department),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Удалить кафедру?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Отмена'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Удалить'),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;
                          if (!confirm) return;
                          await service.deleteDepartment(department.id);
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
