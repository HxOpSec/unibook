import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/core/constants/app_routes.dart';
import 'package:unibook/core/constants/app_strings.dart';
import 'package:unibook/models/department_model.dart';
import 'package:unibook/providers/auth_provider.dart';
import 'package:unibook/services/firestore_service.dart';
import 'package:unibook/widgets/department_card.dart';
import 'package:unibook/widgets/search_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  List<DepartmentModel> _departments = [];
  bool _offline = false;
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySub;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final offline = results.contains(ConnectivityResult.none);
      if (mounted) {
        setState(() => _offline = offline);
      }
    });
  }

  Future<void> _loadDepartments() async {
    final items = await context.read<FirestoreService>().getDepartments();
    if (!mounted) return;
    setState(() => _departments = items);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _connectivitySub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final query = _searchCtrl.text.toLowerCase();
    final departments = _departments
        .where((d) => d.name.toLowerCase().contains(query))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appTitle),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profile),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      floatingActionButton: (user?.isTeacher ?? false) || (user?.isAdmin ?? false)
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.uploadBook),
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addBook),
            )
          : null,
      body: Column(
        children: [
          if (_offline)
            Container(
              width: double.infinity,
              color: Colors.amber.shade700,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
              child: const Text(
                AppStrings.offlineMode,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBarWidget(
              hintText: AppStrings.searchBooks,
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadDepartments,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: departments.isEmpty
                    ? const ListView(
                        children: [
                          SizedBox(height: 120),
                          Center(child: Text('Кафедры не найдены')),
                        ],
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: departments.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.05,
                        ),
                        itemBuilder: (context, index) {
                          final department = departments[index];
                          return DepartmentCard(
                            department: department,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.bookList,
                                arguments: department,
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
