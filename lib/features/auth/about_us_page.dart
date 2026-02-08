import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/common_style.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('About Us'),
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
                  Text(
                    'Welcome to inQueue',
                    style: TextStyle(
                      fontSize: isMobile ? 28 : 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Revolutionary Queue Management Solution',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      color: AppColors.textWhite.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
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
                  // About Section
                  _buildSection(
                    title: 'About inQueue',
                    content:
                        'inQueue is a cutting-edge queue management solution designed to eliminate waiting times and enhance customer experience. '
                        'We believe that time is precious, and our mission is to help businesses manage customer flow efficiently while improving satisfaction.\n\n'
                        'Our platform combines advanced technology with user-friendly design to provide a seamless experience for both customers and merchants. '
                        'With inQueue, customers can skip long lines by joining virtual queues, and merchants can optimize their operations and reduce congestion.',
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 40),

                  // Mission Section
                  _buildSection(
                    title: 'Our Mission',
                    content:
                        'To transform the way businesses manage queues and customers experience service by providing innovative, reliable, and accessible queue management solutions that save time, reduce frustration, and enhance overall satisfaction.',
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 40),

                  // Vision Section
                  _buildSection(
                    title: 'Our Vision',
                    content:
                        'To become the leading queue management platform globally, empowering businesses of all sizes to deliver exceptional customer experiences through intelligent queue optimization and seamless digital solutions.',
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 40),

                  // Key Features Section
                  Text(
                    'Why Choose inQueue?',
                    style: isMobile ? CommonStyle.heading3 : CommonStyle.heading2,
                  ),
                  const SizedBox(height: 24),
                  _buildFeatureGrid(isMobile: isMobile),
                  const SizedBox(height: 40),

                  // Normal Way Section
                  Text(
                    'The Normal Way (Problem)',
                    style: isMobile ? CommonStyle.heading3 : CommonStyle.heading2,
                  ),
                  const SizedBox(height: 24),
                  _buildNormalWaySection(isMobile: isMobile),
                  const SizedBox(height: 40),

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
                          'Get in Touch',
                          style: isMobile ? CommonStyle.heading3 : CommonStyle.heading2,
                        ),
                        const SizedBox(height: 24),
                        _buildContactItem(
                          icon: Icons.email,
                          label: 'Email',
                          value: 'team@inqueue.in',
                          isMobile: isMobile,
                          onTap: () => _launchEmail('team@inqueue.in'),
                        ),
                        const SizedBox(height: 20),
                        _buildContactItem(
                          icon: Icons.business,
                          label: 'LinkedIn',
                          value: 'inQ Solutions Private Limited',
                          isMobile: isMobile,
                          onTap: () => _launchLinkedIn(),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Follow us for the latest updates and announcements',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: isMobile ? 14 : 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // InQ Way Section
                  const SizedBox(height: 20),
                  _buildInQWaySection(isMobile: isMobile),
                  const SizedBox(height: 40),

                  // Call to Action
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/customer-dashboard');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Start Using inQueue',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                  ),
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
                    '© 2025 inQueue. All rights reserved.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No More Waiting. Just Scan and Go.',
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
    );
  }

  Widget _buildFeatureGrid({required bool isMobile}) {
    final features = [
      {
        'icon': Icons.schedule,
        'title': 'Virtual Queues',
        'description': 'Join queues remotely and get notified when it\'s your turn',
      },
      {
        'icon': Icons.qr_code_scanner,
        'title': 'Easy Check-in',
        'description': 'Simple QR code scanning to confirm your arrival',
      },
      {
        'icon': Icons.notifications,
        'title': 'Smart Notifications',
        'description': 'Real-time updates on queue status and arrival times',
      },
      {
        'icon': Icons.analytics,
        'title': 'Analytics',
        'description': 'Comprehensive insights for merchants to optimize operations',
      },
      {
        'icon': Icons.security,
        'title': 'Secure',
        'description': 'Bank-level security for all your personal information',
      },
      {
        'icon': Icons.smartphone,
        'title': '24/7 Available',
        'description': 'Access inQueue anytime, anywhere on any device',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 3,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: isMobile ? 1.0 : 0.95,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildFeatureCard(
          icon: feature['icon'] as IconData,
          title: feature['title'] as String,
          description: feature['description'] as String,
          isMobile: isMobile,
        );
      },
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isMobile,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNormalWaySection({required bool isMobile}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied,
                    color: Colors.red,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sees Crowded Store',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Customer arrives and sees a long queue of people waiting.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.directions_walk,
                    color: Colors.orange,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Goes to Another Shop',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Instead of waiting, customer leaves and visits a competitor\'s shop.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'This is where inQueue comes in to solve the problem!',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
          'https://mail.google.com/mail/?view=cm&fs=1&to=$email&su=Inquiry%20from%20inQueue&body=Hello%20inQueue%20Team',
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
            'subject': 'Inquiry from inQueue',
            'body': 'Hello inQueue Team,\n\nI would like to know more about inQueue.\n\nThank you!',
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
              const Text('Email: team@inqueue.in', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Future<void> _launchLinkedIn() async {
    final Uri linkedInUri = Uri.parse(
      'https://www.linkedin.com/company/inq-solutions-private-limited/about/?viewAsMember=true',
    );

    try {
      if (await canLaunchUrl(linkedInUri)) {
        await launchUrl(
          linkedInUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Visit us on LinkedIn for more updates'),
              backgroundColor: AppColors.primary,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('LinkedIn: inq-solutions-private-limited'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  Widget _buildInQWaySection({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The InQ Way',
          style: isMobile ? CommonStyle.heading3 : CommonStyle.heading2,
        ),
        const SizedBox(height: 24),
        
        // Customer Journey
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.phone, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Join Queue Via Phone',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Customers can easily join a queue remotely by scanning a QR code or using the app.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.notifications, color: AppColors.secondary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Get Real-Time Notifications',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Receive instant notifications when it\'s your turn or when the queue is about to call you.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.store, color: AppColors.success, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Walk In Without Waiting',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Come to the store at your designated time and enjoy service without standing in long queues.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),
        
        // Merchant Benefits
        Text(
          'Benefits for Merchants',
          style: isMobile ? CommonStyle.heading3 : CommonStyle.heading2,
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.people, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No Customers Leave',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Reduce customer abandonment by notifying them when it\'s their turn, keeping them engaged.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.trending_up, color: AppColors.secondary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Evenly Spread Traffic',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Distribute customer flow efficiently with smart queue management to optimize operations.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.search, color: AppColors.success, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Higher Online Visibility',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Appear higher in search results and maps, making your business more discoverable.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.card_giftcard, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Customer Rewards Program',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Reward loyal customers with inQoins and special offers to increase repeat business.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

