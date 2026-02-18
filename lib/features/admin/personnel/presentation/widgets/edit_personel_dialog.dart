import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:KETAHANANPANGAN/auth/models/auth_model.dart';
import 'package:KETAHANANPANGAN/auth/models/role_enum.dart';
import 'package:KETAHANANPANGAN/features/admin/personnel/providers/personel_provider.dart';

class EditPersonelDialog extends StatefulWidget {
  final UserModel user;

  const EditPersonelDialog({super.key, required this.user});

  @override
  State<EditPersonelDialog> createState() =>
      _EditPersonelDialogState();
}

class _EditPersonelDialogState
    extends State<EditPersonelDialog> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late UserRole _selectedRole;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  static const _primaryDark = Color(0xFF1E293B);

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.user.namaLengkap);
    _phoneController =
        TextEditingController(text: widget.user.noTelp);
    _selectedRole = widget.user.role;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  double _responsiveWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return width * 0.95;
    if (width < 1024) return width * 0.7;
    return 600;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: _responsiveWidth(context)),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ================= HEADER =================
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              _primaryDark.withOpacity(.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.manage_accounts_rounded,
                          color: _primaryDark,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Edit Akses Personel",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold),
                            ),
                            Text(
                              "NRP: ${widget.user.nrp}",
                              style: TextStyle(
                                color:
                                    Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _isLoading
                            ? null
                            : () =>
                                Navigator.pop(context),
                        icon: const Icon(
                            Icons.close_rounded),
                      )
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ================= NAMA =================
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: "Nama Lengkap",
                      prefixIcon: const Icon(
                          Icons.person_outline),
                      filled: true,
                      fillColor:
                          const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty
                            ? "Nama wajib diisi"
                            : null,
                  ),

                  const SizedBox(height: 20),

                  // ================= ROLE =================
                  DropdownButtonFormField<UserRole>(
                    value: _selectedRole,
                    decoration: InputDecoration(
                      labelText: "Hak Akses",
                      prefixIcon: const Icon(
                          Icons.shield_outlined),
                      filled: true,
                      fillColor:
                          const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    items: UserRole.values
                        .where((r) =>
                            r != UserRole.unknown)
                        .map(
                          (role) => DropdownMenuItem(
                            value: role,
                            child: Text(role.label),
                          ),
                        )
                        .toList(),
                    onChanged: _isLoading
                        ? null
                        : (val) => setState(
                              () => _selectedRole =
                                  val!,
                            ),
                  ),

                  const SizedBox(height: 20),

                  // ================= PHONE =================
                  TextFormField(
                    controller: _phoneController,
                    keyboardType:
                        TextInputType.phone,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText:
                          "Nomor WhatsApp",
                      prefixIcon: const Icon(
                          Icons.phone_android),
                      filled: true,
                      fillColor:
                          const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty
                            ? "Nomor wajib diisi"
                            : null,
                  ),

                  const SizedBox(height: 32),

                  // ================= ACTION =================
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.pop(
                                  context),
                          child: const Text("Batal"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                _primaryDark,
                            foregroundColor:
                                Colors.white,
                          ),
                          onPressed:
                              _isLoading ? null : _submit,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                        Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Simpan Perubahan",
                                  style: TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= SUBMIT =================

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updated = UserModel(
      id: widget.user.id,
      namaLengkap: _nameController.text,
      nrp: widget.user.nrp,
      noTelp: _phoneController.text,
      idTugas: widget.user.idTugas,
      role: _selectedRole,
      jabatanDetail: widget.user.jabatanDetail,
      tingkatDetail: widget.user.tingkatDetail,
    );

    try {
      await context
          .read<PersonelProvider>()
          .updatePersonel(updated);

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Data berhasil diperbarui"),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text("Gagal: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
