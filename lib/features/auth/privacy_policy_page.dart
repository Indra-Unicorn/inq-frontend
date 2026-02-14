import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/common_style.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 40,
                vertical: isMobile ? 40 : 60,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.privacy_tip_outlined,
                    size: isMobile ? 48 : 64,
                    color: AppColors.textWhite,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: isMobile ? 28 : 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your Privacy Matters to Us',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      color: AppColors.textWhite.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Last Updated: February 13, 2026',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Container
            Container(
              constraints: BoxConstraints(maxWidth: isDesktop ? 1200 : double.infinity),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 40,
                vertical: isMobile ? 30 : 50,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Introduction
                  _buildSection(
                    title: '1. Introduction',
                    content:
                        'Welcome to InQ ("we," "us," "our," or "Company"). We are committed to protecting your privacy and ensuring you have a positive experience on our mobile application. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use the InQ app.',
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 32),

                  // Information We Collect
                  Text(
                    '2. Information We Collect',
                    style: isMobile ? CommonStyle.heading3 : CommonStyle.heading2,
                  ),
                  const SizedBox(height: 16),

                  _buildSubSection(
                    title: '2.1 Information You Provide',
                    items: [
                      'Account Information: Name, email, phone number, and password',
                      'Profile Information: Profile picture, preferences, and settings',
                      'Location Data: GPS location to show nearby stores and queues (only when app is active)',
                      'Communications: Messages, feedback, and support inquiries',
                    ],
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 16),

                  _buildSubSection(
                    title: '2.2 Information Collected Automatically',
                    items: [
                      'Device Information: Device type, OS version, unique device identifiers',
                      'Usage Data: Features used, queue interactions, timestamps',
                      'Crash Reports: App performance and error logs',
                      'Analytics: User behavior patterns and app engagement metrics',
                    ],
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 16),

                  // Camera Permission Highlight
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.camera_alt,
                              color: AppColors.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '2.3 Camera Permission',
                                style: TextStyle(
                                  fontSize: isMobile ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'We request camera access to allow you to:',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...['Upload a profile picture', 'Take photos for verification purposes', 'Scan QR codes for queue check-in'].map((item) => Padding(
                          padding: const EdgeInsets.only(left: 16, top: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ', style: TextStyle(color: AppColors.primary, fontSize: 16)),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        )),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: AppColors.success, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'We do NOT record videos or access your photos without permission',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // How We Use Your Information
                  _buildSection(
                    title: '3. How We Use Your Information',
                    content: 'We use the information we collect to:',
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 8),
                  _buildBulletList([
                    'Provide, operate, and maintain the InQ application',
                    'Create and manage your account',
                    'Display real-time queue information and estimated wait times',
                    'Send notifications about your queue status',
                    'Improve app performance and user experience',
                    'Respond to your inquiries and provide customer support',
                    'Comply with legal obligations and enforce our Terms of Service',
                    'Prevent fraud and ensure security',
                  ]),
                  const SizedBox(height: 32),

                  // Data Protection
                  _buildSection(
                    title: '4. How We Protect Your Data',
                    content: '',
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.success.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        ...['All data transmission is encrypted using SSL/TLS protocol', 'Passwords are stored using industry-standard hashing algorithms', 'Access to personal data is restricted to authorized personnel only', 'Regular security audits and vulnerability assessments are conducted', 'We comply with data protection regulations and best practices'].map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.security, color: AppColors.success, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Data Sharing
                  Text(
                    '5. Data Sharing and Disclosure',
                    style: isMobile ? CommonStyle.heading3 : CommonStyle.heading2,
                  ),
                  const SizedBox(height: 16),
                  _buildSubSection(
                    title: '5.1 When We Share Your Data',
                    items: [
                      'With Store Partners: Your queue information with participating stores',
                      'Service Providers: Third-party services for hosting, analytics, and payment processing',
                      'Legal Requirements: When required by law or to protect rights and safety',
                      'Business Transfers: In case of merger, acquisition, or business sale',
                    ],
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 16),
                  _buildSubSection(
                    title: '5.2 We Do NOT Share',
                    items: [
                      'Your data is never sold to third parties for marketing purposes',
                      'We do not share sensitive information (passwords, financial details)',
                      'Camera footage or photos are never shared without explicit consent',
                    ],
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 32),

                  // Your Rights
                  _buildSection(
                    title: '6. Your Rights and Choices',
                    content: 'You have the right to:',
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 8),
                  _buildBulletList([
                    'Access your personal data at any time through your account settings',
                    'Update or correct your information',
                    'Request deletion of your account and associated data',
                    'Opt-out of marketing communications',
                    'Revoke app permissions (camera, location) anytime through device settings',
                    'Request a copy of your data in a machine-readable format',
                  ]),
                  const SizedBox(height: 32),

                  // Children's Privacy
                  _buildSection(
                    title: '7. Children\'s Privacy',
                    content:
                        'InQ is not intended for children under 13 years old. We do not knowingly collect personal information from children. If we become aware that a child under 13 has provided us with information, we will delete such data immediately and terminate the child\'s account.',
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 32),

                  // Data Retention
                  _buildSection(
                    title: '8. Data Retention',
                    content: '',
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 8),
                  _buildBulletList([
                    'Active Accounts: Data is retained as long as your account is active',
                    'Inactive Accounts: Data is retained for 12 months after account deletion',
                    'Analytics Data: Aggregated data may be retained indefinitely',
                    'Legal Requirements: Data may be retained longer if required by law',
                  ]),
                  const SizedBox(height: 32),

                  // Changes to Policy
                  _buildSection(
                    title: '9. Changes to This Privacy Policy',
                    content:
                        'We may update this Privacy Policy from time to time. We will notify you of any significant changes by updating the "Last Updated" date and posting a notice in the app. Your continued use of InQ after changes constitute acceptance of the updated Privacy Policy.',
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 32),

                  // Contact Section
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '10. Contact Us',
                          style: isMobile ? CommonStyle.heading3 : CommonStyle.heading2,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Have questions about your privacy? We\'re here to help!',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: isMobile ? 14 : 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        _buildContactItem(
                          icon: Icons.email,
                          label: 'Email',
                          value: 'team@inqueue.in',
                          isMobile: isMobile,
                          onTap: () => _launchEmail('team@inqueue.in'),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Response Time: We aim to respond within 7 business days',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: isMobile ? 12 : 13,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Compliance
                  _buildSection(
                    title: '11. Compliance',
                    content: 'InQ complies with applicable data protection laws and regulations including:',
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 8),
                  _buildBulletList([
                    'Information Technology Act, 2000 (India)',
                    'Digital Personal Data Protection Act, 2023 (India)',
                    'General Data Protection Regulation (GDPR) - for EU users',
                    'California Consumer Privacy Act (CCPA) - for California users',
                  ]),
                ],
              ),
            ),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              color: AppColors.backgroundLight,
              child: Column(
                children: [
                  Text(
                    '© 2026 inQueue. All rights reserved.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your privacy is our priority.',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: isMobile ? CommonStyle.heading3 : CommonStyle.heading2,
        ),
        if (content.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubSection({
    required String title,
    required List<String> items,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 15 : 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 16, top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(left: 16, top: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isMobile,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    try {
      // For web, open Gmail directly
      if (kIsWeb) {
        final gmailUrl = Uri.parse(
          'https://mail.google.com/mail/?view=cm&fs=1&to=$email&su=Privacy%20Inquiry%20-%20inQueue&body=Hello%20inQueue%20Team',
        );
        if (await canLaunchUrl(gmailUrl)) {
          await launchUrl(gmailUrl, mode: LaunchMode.externalApplication);
        } else {
          _showEmailFallback(email);
        }
      } else {
        // For mobile, use mailto: scheme
        final Uri emailUri = Uri(
          scheme: 'mailto',
          path: email,
          queryParameters: {
            'subject': 'Privacy Inquiry - inQueue',
            'body': 'Hello inQueue Team,\n\nI have a question about your privacy policy.\n\nThank you!',
          },
        );

        if (await canLaunchUrl(emailUri)) {
          await launchUrl(emailUri);
        } else {
          _showEmailFallback(email);
        }
      }
    } catch (e) {
      _showEmailFallback(email);
    }
  }

  void _showEmailFallback(String email) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: $email', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                'Please reach out to us at the email above.',
                style: TextStyle(color: AppColors.textWhite.withOpacity(0.8)),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
