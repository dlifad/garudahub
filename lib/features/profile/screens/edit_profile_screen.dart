import 'package:flutter/material.dart';
import 'package:garudahub/features/profile/screens/verify_email_update_screen.dart';
import 'package:provider/provider.dart';
import 'package:garudahub/shared/widgets/garuda_widgets.dart';
import 'package:garudahub/features/auth/providers/auth_provider.dart';
import 'package:garudahub/features/profile/providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController emailController;

  @override
  void initState() {
    super.initState();

    final user = context.read<AuthProvider>().user;

    nameController = TextEditingController(
      text: user?.name ?? '',
    );

    emailController = TextEditingController(
      text: user?.email ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final profileProvider = context.read<ProfileProvider>();
    final auth = context.read<AuthProvider>();

    final newEmail = emailController.text.trim();
    final currentEmail = auth.user?.email;

    // Kalau email berubah
    if (newEmail != currentEmail) {
      try {
        await profileProvider.requestEmailOtp(newEmail);

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyEmailScreen(email: newEmail, name: nameController.text.trim(),),
          ),
        );
      } catch (e) {
        if (!mounted) return;

        final message = e.toString().replaceAll('Exception: ', '');

        showGarudaSnackbar(context, message, isError: true);
      }

      return;
    }

    // Kalau email tidak berubah
    try {
      await profileProvider.updateProfile(
        auth,
        name: nameController.text.trim(),
      );

      if (!mounted) return;

      showGarudaSnackbar(context, 'Profil berhasil diperbarui');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      showGarudaSnackbar(context, 'Gagal update profil', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty
                          ? 'Nama wajib diisi'
                          : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    if (!val.contains('@')) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: provider.isLoading ? null : _submit,
                    child: provider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}