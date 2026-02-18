import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:KETAHANANPANGAN/features/admin/personnel/providers/personel_provider.dart';
import 'package:KETAHANANPANGAN/auth/models/auth_model.dart';

import 'widgets/personel_card.dart';
import 'widgets/personel_toolbar.dart';
import 'widgets/edit_personel_dialog.dart';

class PersonelPage extends StatefulWidget {
  const PersonelPage({super.key});

  @override
  State<PersonelPage> createState() => _PersonelPageState();
}

class _PersonelPageState extends State<PersonelPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PersonelProvider>().fetchPersonel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF0F9),
      body: Column(
        children: [
          const PersonelToolbar(),
          Expanded(
            child: Consumer<PersonelProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  );
                }

                if (provider.errorMessage != null) {
                  return _buildErrorState(provider);
                }

                if (provider.personelList.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchPersonel(),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth > 900;

                      return Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isDesktop ? 900 : double.infinity,
                          ),
                          child: ListView.separated(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            physics:
                                const AlwaysScrollableScrollPhysics(),
                            itemCount: provider.personelList.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final UserModel user =
                                  provider.personelList[index];

                              return PersonelCard(
                                personel: user,
                                onTap: () =>
                                    _navigateToDetail(context, user),
                                onEdit: () =>
                                    _showEditDialog(context, user),
                                onDelete: () =>
                                    _onDelete(context, user),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // STATES
  // =========================

  Widget _buildErrorState(PersonelProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data:\n${provider.errorMessage}',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => provider.fetchPersonel(),
              icon: const Icon(Icons.refresh),
              label: const Text("Coba Lagi"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Data personel tidak ditemukan",
            style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // =========================
  // ACTIONS
  // =========================

  void _navigateToDetail(
      BuildContext context, UserModel user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text("Membuka profil: ${user.namaLengkap}"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, UserModel user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditPersonelDialog(user: user),
    );
  }

  void _onDelete(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Personel"),
        content: Text(
            "Yakin ingin menghapus ${user.namaLengkap}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context
                    .read<PersonelProvider>()
                    .deletePersonel(user.id);

                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content:
                          Text("Berhasil dihapus"),
                      behavior:
                          SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      content: Text("Gagal: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              "Hapus",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
