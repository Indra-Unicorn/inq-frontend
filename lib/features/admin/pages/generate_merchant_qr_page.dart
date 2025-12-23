import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:file_saver/file_saver.dart';
import 'package:image/image.dart' as img;
import '../../../shared/constants/app_colors.dart';
import '../services/admin_merchant_service.dart';
import '../../merchant/models/merchant_data.dart';

class GenerateMerchantQRPage extends StatefulWidget {
  const GenerateMerchantQRPage({super.key});

  @override
  State<GenerateMerchantQRPage> createState() => _GenerateMerchantQRPageState();
}

class _GenerateMerchantQRPageState extends State<GenerateMerchantQRPage> {
  List<MerchantData> _activeMerchants = [];
  bool _isLoading = true;
  String? _errorMessage;
  MerchantData? _selectedMerchant;
  ShopData? _selectedShop;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _loadActiveMerchants();
  }

  Future<void> _loadActiveMerchants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final merchants = await AdminMerchantService.getAllMerchants('APPROVED');
      setState(() {
        _activeMerchants = merchants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load merchants: $e';
        _isLoading = false;
      });
    }
  }

  String _getShopLink(ShopData shop) {
    return 'https://inqueue.in/#/store/${shop.shopId}';
  }

  Widget _buildPoster() {
    if (_selectedShop == null) return const SizedBox.shrink();

    // A4 size: 595x842 points (standard for printing)
    return Container(
      width: 595,
      height: 842,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundLight,
            AppColors.primary.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          // Header Section with Shop Branding (~148px)
          _buildHeaderSection(),
          
          // QR Code Section (~285px)
          _buildQRSection(),
          
          // How It Works Section (~314px)
          _buildHowItWorksSection(),
          
          // Footer with InQ Branding (~95px)
          _buildFooterSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
      child: Column(
        children: [
          // Shop Name
          Text(
            _selectedShop!.shopName,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          // Shop Address
          if (_selectedShop!.address.city.isNotEmpty)
            Text(
              '${_selectedShop!.address.streetAddress}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textWhite.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 10),
          // Tagline
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.textWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Skip the Wait, Join the Queue!',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      child: Column(
        children: [
          // Instruction
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Scan to Join Queue',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // QR Code with enhanced styling
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: QrImageView(
              data: _getShopLink(_selectedShop!),
              version: QrVersions.auto,
              size: 180.0,
              backgroundColor: AppColors.backgroundLight,
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.textPrimary,
              ),
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Open your camera and point at the QR code',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.border,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.secondary,
                  size: 18,
                ),
                const SizedBox(width: 6),
                const Text(
                  'How InQ Works',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Steps
            _buildStep(
              number: '1',
              icon: Icons.qr_code_scanner,
              title: 'Scan QR Code',
              description: 'Use your phone camera to scan',
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            _buildStep(
              number: '2',
              icon: Icons.app_registration,
              title: 'Join Queue Virtually',
              description: 'Reserve your spot instantly',
              color: AppColors.secondary,
            ),
            const SizedBox(height: 8),
            _buildStep(
              number: '3',
              icon: Icons.notifications_active,
              title: 'Get Notified',
              description: 'We\'ll alert you when it\'s your turn',
              color: AppColors.success,
            ),
            const SizedBox(height: 8),
            _buildStep(
              number: '4',
              icon: Icons.store,
              title: 'Visit the Store',
              description: 'Come back at your turn, no waiting!',
              color: AppColors.info,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        // Step Number Circle
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Icon
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        // Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.secondaryGradient,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: AppColors.backgroundLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.schedule,
                  color: AppColors.secondary,
                  size: 14,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'Save Time',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textWhite,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: AppColors.backgroundLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mobile_friendly,
                  color: AppColors.secondary,
                  size: 14,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'Stay Informed',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '⚡ Powered by InQueue',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPoster() async {
    try {
      final imageBytes = await _screenshotController.capture();
      if (imageBytes != null) {
        final pngImage = img.decodePng(imageBytes);
        if (pngImage != null) {
          final jpgBytes = img.encodeJpg(pngImage, quality: 95);
          
          // Create filename with shop name
          final shopName = _selectedShop!.shopName
              .replaceAll(RegExp(r'[^\w\s]'), '')
              .replaceAll(RegExp(r'\s+'), '_');
          final fileName = 'InQ_${shopName}_QR_Poster';
          
          await FileSaver.instance.saveFile(
            name: fileName,
            bytes: jpgBytes,
            mimeType: MimeType.jpeg,
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Poster downloaded successfully!'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading poster: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Merchant QR'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Merchant:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<MerchantData>(
                        value: _selectedMerchant,
                        items: _activeMerchants.map((merchant) {
                          return DropdownMenuItem(
                            value: merchant,
                            child: Text(merchant.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMerchant = value;
                            _selectedShop = value?.shops.isNotEmpty == true ? value!.shops.first : null;
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Choose a merchant',
                        ),
                      ),
                      if (_selectedMerchant != null && _selectedMerchant!.shops.length > 1) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Select Shop:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<ShopData>(
                          value: _selectedShop,
                          items: _selectedMerchant!.shops.map((shop) {
                            return DropdownMenuItem(
                              value: shop,
                              child: Text(shop.shopName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedShop = value;
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Choose a shop',
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      if (_selectedShop != null) ...[
                        const Text(
                          'QR Poster Preview (A4 Size):',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ready to print and display at your store',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Center(
                            child: SingleChildScrollView(
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadow,
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Screenshot(
                                  controller: _screenshotController,
                                  child: Transform.scale(
                                    scale: 0.6, // Scale down for preview
                                    child: _buildPoster(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _downloadPoster,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            icon: const Icon(Icons.download, size: 24),
                            label: const Text(
                              'Download High-Quality Poster',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Poster will be saved as JPG (A4 595×842 px)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}