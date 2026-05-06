import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;
import 'package:garudahub/core/constants/constants.dart';

import 'package:garudahub/core/services/biometric_service.dart';
import 'package:garudahub/core/services/notification_service.dart';
import 'package:garudahub/core/models/user_model.dart';

import 'package:garudahub/shared/widgets/garuda_widgets.dart';

import 'package:garudahub/features/auth/providers/auth_provider.dart';
import 'package:garudahub/features/auth/services/auth_service.dart';

import 'package:garudahub/features/profile/providers/profile_provider.dart';
import 'package:garudahub/features/profile/screens/about_screen.dart';
import 'package:garudahub/features/profile/screens/change_password_screen.dart';
import 'package:garudahub/features/profile/screens/feedback_screen.dart';
import 'package:garudahub/features/profile/screens/saran_kesan_screen.dart';
import 'package:garudahub/features/profile/screens/edit_profile_screen.dart';

import 'package:garudahub/features/chant/providers/chant_provider.dart';

import 'package:garudahub/core/providers/timezone_provider.dart';
import 'package:garudahub/core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isNotificationEnabled = false;
  bool _isMatchNotificationEnabled = false;
  bool _isResultNotificationEnabled = false;
  bool _isQuizNotificationEnabled = false;
  bool _isNotificationLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      context.read<ProfileProvider>().fetchProfile(auth);
      _loadNotificationSettings();
    });
  }

  Future<void> _refreshProfile() async {
    final auth = context.read<AuthProvider>();

    await Future.wait([
      context.read<ProfileProvider>().fetchProfile(auth),
      _loadNotificationSettings(),
    ]);
  }

  Future<void> _loadNotificationSettings() async {
    await NotificationService.instance.init();

    if (!mounted) return;

    setState(() {
      _isNotificationEnabled =
          NotificationService.instance.notificationsEnabled;
      _isMatchNotificationEnabled =
          NotificationService.instance.matchNotificationsEnabled;
      _isResultNotificationEnabled =
          NotificationService.instance.resultNotificationsEnabled;
      _isQuizNotificationEnabled =
          NotificationService.instance.quizNotificationsEnabled;
      _isNotificationLoading = false;
    });
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final profileProvider = context.read<ProfileProvider>();
    final auth = context.read<AuthProvider>();
    final name = auth.user?.name ?? '';

    final picked = await picker.pickImage(source: source);
    if (picked == null || !mounted) return;

    try {
      final rawFile = File(picked.path);

      final file = await processImage(rawFile);

      await profileProvider.updateProfile(auth, name: name, imageFile: file);

      if (!mounted) return;
      showGarudaSnackbar(context, 'Foto berhasil diperbarui');
    } catch (e) {
      if (!mounted) return;
      showGarudaSnackbar(context, 'Gagal memproses gambar', isError: true);
    }
  }

  Future<void> _removePhoto(BuildContext context) async {
    final profileProvider = context.read<ProfileProvider>();
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    final name = user?.name ?? '';

    if (user?.profilePhoto == null || user!.profilePhoto!.isEmpty) {
      showGarudaSnackbar(
        context,
        'Belum ada foto untuk dihapus',
        isError: true,
      );
      return;
    }

    await profileProvider.updateProfile(auth, name: name, removePhoto: true);

    if (!mounted) return;
    showGarudaSnackbar(context, 'Foto berhasil dihapus');
  }

  Future<File> processImage(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) return file;

    final resized = img.copyResize(image, width: 600);
    final jpg = img.encodeJpg(resized, quality: 65);

    final newPath =
        '${file.parent.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newFile = File(newPath);

    await newFile.writeAsBytes(jpg);

    return newFile;
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Hapus Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _removePhoto(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final auth = context.watch<AuthProvider>();
    final profile = context.watch<ProfileProvider>();
    final user = auth.user;

    if (profile.error != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showGarudaSnackbar(context, profile.error!, isError: true);

        context.read<ProfileProvider>().clearError();
      });
    }

    if (profile.isLoading && user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.softBackground(
        cs,
        isDark: Theme.of(context).brightness == Brightness.dark,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.softBackground(
          cs,
          isDark: Theme.of(context).brightness == Brightness.dark,
        ),
        surfaceTintColor: cs.surfaceTint,
        titleSpacing: AppSpacing.base,
        centerTitle: false,
        title: const Text('Profil'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.base,
                  AppSpacing.sm,
                  AppSpacing.base,
                  AppSpacing.base +
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileCard(context, cs, user),
                    const SizedBox(height: AppSpacing.lg),

                    _SectionLabel('Akun'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildAccountSection(context, cs, auth),
                    const SizedBox(height: AppSpacing.base),

                    _SectionLabel('Notifikasi'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildNotificationSection(context, cs),
                    const SizedBox(height: AppSpacing.base),

                    _SectionLabel('Lainnya'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildOtherSection(context, cs),
                    const SizedBox(height: AppSpacing.base),

                    _buildLogoutButton(context, cs, auth),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section Builders
  Widget _buildProfileCard(
    BuildContext context,
    ColorScheme cs,
    UserModel? user,
  ) {
    final base = AppConstants.baseUrl.replaceAll('/api', '');
    final imageUrl =
        user?.profilePhoto != null && user!.profilePhoto!.isNotEmpty
        ? '$base${user.profilePhoto}'
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _showPhotoOptions(context),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: cs.primaryContainer,
                    backgroundImage: imageUrl != null
                        ? NetworkImage(imageUrl)
                        : null,
                    child: imageUrl == null
                        ? Text(
                            user?.name.isNotEmpty == true
                                ? user!.name[0].toUpperCase()
                                : '🦅',
                            style: TextStyle(
                              color: cs.onPrimaryContainer,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.surface, width: 2),
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 12,
                      color: cs.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'Pengguna GarudaHub',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(
    BuildContext context,
    ColorScheme cs,
    AuthProvider auth,
  ) {
    final tz = context.watch<TimezoneProvider>();
    return Card(
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.person_outline,
            label: 'Edit Profil',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
          const Divider(height: 1, indent: 56),
          _MenuTile(
            icon: Icons.lock_outline,
            label: 'Ganti Kata Sandi',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            ),
          ),
          const Divider(height: 1, indent: 56),
          _MenuTile(
            icon: Icons.schedule,
            label: 'Zona Waktu',
            trailing: Text(
              tz.label,
              style: TextStyle(color: cs.primary, fontSize: 12),
            ),
            onTap: () => _showTimezonePicker(context),
          ),
          const Divider(height: 1, indent: 56),
          _MenuTile(
            icon: Icons.fingerprint,
            label: 'Login Biometrik',
            trailing: _buildBiometricSwitch(context, auth),
            onTap: null,
          ),
          const Divider(height: 1, indent: 56),
          _MenuTile(
            icon: Icons.campaign,
            label: 'Chant Supporter',
            trailing: _buildChantSwitch(context),
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context, ColorScheme cs) {
    return Card(
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.notifications_outlined,
            label: 'Notifikasi',
            trailing: _isNotificationLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Switch(
                    value: _isNotificationEnabled,
                    onChanged: (val) => _onNotificationToggle(context, val),
                  ),
            onTap: null,
          ),
          const Divider(height: 1, indent: 56),
          _MenuTile(
            icon: Icons.schedule,
            label: 'Pengingat Pertandingan',
            trailing: _buildSubNotificationSwitch(
              value: _isMatchNotificationEnabled,
              enabled: _isNotificationEnabled && !_isNotificationLoading,
              onChanged: (val) => _onMatchNotificationToggle(context, val),
            ),
            onTap: null,
          ),
          const Divider(height: 1, indent: 56),
          _MenuTile(
            icon: Icons.emoji_events_outlined,
            label: 'Hasil Pertandingan',
            trailing: _buildSubNotificationSwitch(
              value: _isResultNotificationEnabled,
              enabled: _isNotificationEnabled && !_isNotificationLoading,
              onChanged: (val) => _onResultNotificationToggle(context, val),
            ),
            onTap: null,
          ),
          const Divider(height: 1, indent: 56),
          _MenuTile(
            icon: Icons.psychology_alt_outlined,
            label: 'Tebak Score',
            trailing: _buildSubNotificationSwitch(
              value: _isQuizNotificationEnabled,
              enabled: _isNotificationEnabled && !_isNotificationLoading,
              onChanged: (val) => _onQuizNotificationToggle(context, val),
            ),
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildSubNotificationSwitch({
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Switch(value: value, onChanged: enabled ? onChanged : null);
  }

  Future<void> _onNotificationToggle(BuildContext context, bool val) async {
    await NotificationService.instance.setNotificationsEnabled(val);

    if (!mounted) return;

    setState(() {
      _isNotificationEnabled = val;
      if (!val) {
        _isMatchNotificationEnabled = false;
        _isResultNotificationEnabled = false;
        _isQuizNotificationEnabled = false;
      }
    });

    showGarudaSnackbar(
      context,
      val ? 'Notifikasi diaktifkan' : 'Notifikasi dinonaktifkan',
    );
  }

  Future<void> _onMatchNotificationToggle(
    BuildContext context,
    bool val,
  ) async {
    await NotificationService.instance.setMatchNotificationsEnabled(val);

    if (!mounted) return;

    setState(() => _isMatchNotificationEnabled = val);

    showGarudaSnackbar(
      context,
      val ? 'Pengingat pertandingan aktif' : 'Pengingat pertandingan nonaktif',
    );
  }

  Future<void> _onResultNotificationToggle(
    BuildContext context,
    bool val,
  ) async {
    await NotificationService.instance.setResultNotificationsEnabled(val);

    if (!mounted) return;

    setState(() => _isResultNotificationEnabled = val);

    showGarudaSnackbar(
      context,
      val ? 'Notifikasi hasil aktif' : 'Notifikasi hasil nonaktif',
    );
  }

  Future<void> _onQuizNotificationToggle(BuildContext context, bool val) async {
    await NotificationService.instance.setQuizNotificationsEnabled(val);

    if (!mounted) return;

    setState(() => _isQuizNotificationEnabled = val);

    showGarudaSnackbar(
      context,
      val ? 'Tebak score aktif' : 'Tebak score nonaktif',
    );
  }

  Widget _buildOtherSection(BuildContext context, ColorScheme cs) {
    return Card(
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.info_outline,
            label: 'Tentang GarudaHub',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),
          const Divider(height: 1, indent: 56),
          _MenuTile(
            icon: Icons.star_outline,
            label: 'Beri Penilaian',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FeedbackScreen()),
            ),
          ),
          const Divider(height: 1, indent: 56),
          _MenuTile(
            icon: Icons.chat_bubble_outline,
            label: 'Saran & Kesan',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SaranKesanScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    ColorScheme cs,
    AuthProvider auth,
  ) {
    return FilledButton.tonal(
      onPressed: () => _confirmLogout(context, auth),
      style: FilledButton.styleFrom(
        backgroundColor: cs.errorContainer,
        foregroundColor: cs.onErrorContainer,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout, size: 18),
          SizedBox(width: AppSpacing.sm),
          Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Biometric Switch
  Widget _buildBiometricSwitch(BuildContext context, AuthProvider auth) {
    return FutureBuilder<bool>(
      future: BiometricService.canCheck(),
      builder: (context, snapshot) {
        final isAvailable = snapshot.data ?? false;
        return Switch(
          value: auth.isBiometricEnabled,
          onChanged: isAvailable
              ? (val) => _onBiometricToggle(context, auth, val)
              : null,
        );
      },
    );
  }

  Future<void> _onBiometricToggle(
    BuildContext context,
    AuthProvider auth,
    bool val,
  ) async {
    if (val) {
      final ok = await BiometricService.authenticate();
      if (!ok) {
        if (context.mounted) {
          showGarudaSnackbar(context, 'Autentikasi gagal', isError: true);
        }
        return;
      }

      final token = await AuthService.getToken();
      if (token != null) await BiometricService.saveToken(token);
    }

    await auth.setBiometricEnabled(val);

    if (context.mounted) {
      showGarudaSnackbar(
        context,
        val ? 'Biometrik berhasil diaktifkan' : 'Biometrik dinonaktifkan',
      );
    }
  }

  Widget _buildChantSwitch(BuildContext context) {
    final chant = context.watch<ChantProvider>();

    return Switch(
      value: chant.isInitialized ? chant.isEnabled : false,
      onChanged: chant.isInitialized
          ? (val) {
              context.read<ChantProvider>().setEnabled(val);

              showGarudaSnackbar(
                context,
                val
                    ? 'Chant supporter diaktifkan'
                    : 'Chant supporter dinonaktifkan',
              );
            }
          : null,
    );
  }

  void _showTimezonePicker(BuildContext context) {
    final tzProvider = context.read<TimezoneProvider>();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md - 2),
          children: TimezoneProvider.options.entries.map((e) {
            final isSelected = e.key == tzProvider.selected;

            return ListTile(
              title: Text(e.value),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                tzProvider.setTimezone(e.key);
                Navigator.pop(context);

                showGarudaSnackbar(context, 'Zona waktu diubah ke ${e.value}');
              },
            );
          }).toList(),
        );
      },
    );
  }

  // Dialogs & Sheets
  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Keluar?'),
          content: const Text('Kamu akan keluar dari akun GarudaHub.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);

                final chant = context.read<ChantProvider>();

                await auth.logout();

                chant.stop();

                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (_) => false);
                }
              },
              style: FilledButton.styleFrom(backgroundColor: cs.error),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }
}

// Sub-widgets

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: cs.primary,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: cs.onSurfaceVariant),
      title: Text(label, style: TextStyle(color: cs.onSurface)),
      trailing:
          trailing ?? Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
