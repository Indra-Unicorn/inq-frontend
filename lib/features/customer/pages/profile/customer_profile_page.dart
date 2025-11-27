import 'package:flutter/material.dart';
import '../../services/profile_service.dart';
import 'widgets/profile_header.dart';
import 'widgets/logout_button.dart';
import 'widgets/logout_dialog.dart';

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  Map<String, dynamic>? _userData;
  final ProfileService _profileService = ProfileService();

  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _profileService.getUserData();
      setState(() {
        _userData = userData;
        _nameController.text = userData['name'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
    });
    try {
      await _profileService.updateCustomerProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );
      setState(() {
        _isEditing = false;
        _userData?['name'] = _nameController.text.trim();
        _userData?['email'] = _emailController.text.trim();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LogoutDialog(
          onLogout: () async {
            try {
              await _profileService.logout();
              if (mounted) {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              }
            } catch (e) {
              if (mounted) {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FB),
      body: SafeArea(
        child: Column(
          children: [
            ProfileHeader(
              onBackPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 480),
                          margin: const EdgeInsets.symmetric(
                              vertical: 32, horizontal: 16),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.08),
                                              blurRadius: 16,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          radius: 48,
                                          backgroundColor: theme
                                              .colorScheme.primary
                                              .withValues(alpha: 0.08),
                                          backgroundImage: _userData?[
                                                          'profileImage'] !=
                                                      null &&
                                                  _userData!['profileImage']
                                                      .toString()
                                                      .isNotEmpty
                                              ? NetworkImage(
                                                  _userData!['profileImage'])
                                              : null,
                                          child: _userData?['profileImage'] ==
                                                      null ||
                                                  _userData!['profileImage']
                                                      .toString()
                                                      .isEmpty
                                              ? Icon(Icons.person,
                                                  size: 48,
                                                  color:
                                                      theme.colorScheme.primary)
                                              : null,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 4,
                                        right: 4,
                                        child: Material(
                                          color: theme.colorScheme.primary,
                                          shape: const CircleBorder(),
                                          child: InkWell(
                                            customBorder: const CircleBorder(),
                                            onTap: () {
                                              // TODO: Implement profile image update
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Icon(Icons.edit,
                                                  color: Colors.white,
                                                  size: 20),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    _userData?['name'] ?? '',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _userData?['email'] ?? '',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.primary),
                                  ),
                                  const SizedBox(height: 18),
                                  Divider(
                                      height: 32,
                                      thickness: 1.2,
                                      color: theme.dividerColor
                                          .withValues(alpha: 0.15)),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text('Personal Info',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600)),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildEditableField(
                                    label: 'Name',
                                    controller: _nameController,
                                    enabled: _isEditing,
                                    icon: Icons.person,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildEditableField(
                                    label: 'Email',
                                    controller: _emailController,
                                    enabled: _isEditing,
                                    keyboardType: TextInputType.emailAddress,
                                    icon: Icons.email,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildStaticField(
                                    label: 'Phone Number',
                                    value: _userData?['phoneNumber'] ?? '',
                                    icon: Icons.phone,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildStaticField(
                                    label: 'inQoin',
                                    value:
                                        (_userData?['inQoin'] ?? '').toString(),
                                    icon: Icons.monetization_on,
                                  ),
                                  const SizedBox(height: 28),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (!_isEditing)
                                        ElevatedButton.icon(
                                          icon:
                                              const Icon(Icons.edit, size: 18),
                                          label: const Text('Edit Profile'),
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16)),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 12),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isEditing = true;
                                            });
                                          },
                                        ),
                                      if (_isEditing)
                                        ElevatedButton.icon(
                                          icon: _isSaving
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white),
                                                )
                                              : const Icon(Icons.save,
                                                  size: 18),
                                          label: const Text('Save'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                theme.colorScheme.primary,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16)),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 12),
                                          ),
                                          onPressed:
                                              _isSaving ? null : _saveProfile,
                                        ),
                                      if (_isEditing) const SizedBox(width: 12),
                                      if (_isEditing)
                                        OutlinedButton.icon(
                                          icon:
                                              const Icon(Icons.close, size: 18),
                                          label: const Text('Cancel'),
                                          style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16)),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 12),
                                          ),
                                          onPressed: _isSaving
                                              ? null
                                              : () {
                                                  setState(() {
                                                    _isEditing = false;
                                                    _nameController.text =
                                                        _userData?['name'] ??
                                                            '';
                                                    _emailController.text =
                                                        _userData?['email'] ??
                                                            '';
                                                  });
                                                },
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: LogoutButton(onPressed: _showLogoutDialog),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    bool enabled = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[100],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  Widget _buildStaticField({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return TextField(
      controller: TextEditingController(text: value),
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}
