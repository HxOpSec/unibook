import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/models/user_model.dart';
import 'package:unibook/services/firestore_service.dart';
import 'package:unibook/widgets/animated_list_item.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Пользователи')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              hintText: 'Поиск пользователей',
              leading: const Icon(Icons.search),
              onChanged: (v) => setState(() => _query = v.toLowerCase().trim()),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: context.read<FirestoreService>().streamUsers(),
              builder: (context, snapshot) {
                final users = (snapshot.data ?? [])
                    .where(
                      (u) => u.name.toLowerCase().contains(_query) ||
                          u.email.toLowerCase().contains(_query),
                    )
                    .toList();

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return AnimatedListItem(
                      index: index,
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              user.name.isEmpty
                                  ? '?'
                                  : user.name.trim()[0].toUpperCase(),
                            ),
                          ),
                          title: Text(user.name),
                          subtitle: Text(user.email),
                          trailing: DropdownButton<String>(
                            value: user.role,
                            items: const [
                              DropdownMenuItem(value: 'student', child: Text('Студент')),
                              DropdownMenuItem(value: 'teacher', child: Text('Учитель')),
                              DropdownMenuItem(value: 'admin', child: Text('Админ')),
                            ],
                            onChanged: (value) async {
                              if (value == null || value == user.role) return;
                              await context
                                  .read<FirestoreService>()
                                  .updateUserRole(user.uid, value);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
