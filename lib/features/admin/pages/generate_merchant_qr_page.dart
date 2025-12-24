import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:file_saver/file_saver.dart';
import 'package:image/image.dart' as img;
import '../../../shared/constants/app_colors.dart';
import '../services/admin_merchant_service.dart';
import '../../merchant/models/merchant_data.dart';

/// Poster size configuration
class PosterSize {
  final String name;
  final double width;
  final double height;
  final String description;

  const PosterSize({
    required this.name,
    required this.width,
    required this.height,
    required this.description,
  });

  double get aspectRatio => width / height;
  
  String get dimensions => '${width.toInt()}×${height.toInt()} px';
}

// Custom painter for decorative circle pattern
class _CirclePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textWhite.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw circles in a pattern
    for (int i = 0; i < 20; i++) {
      final x = (i % 5) * (size.width / 5) + (size.width / 10);
      final y = (i ~/ 5) * (size.height / 4) + (size.height / 8);
      final radius = (15 + (i % 3) * 5).toDouble();
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GenerateMerchantQRPage extends StatefulWidget {
  const GenerateMerchantQRPage({super.key});

  @override
  State<GenerateMerchantQRPage> createState() => _GenerateMerchantQRPageState();
}

class _GenerateMerchantQRPageState extends State<GenerateMerchantQRPage> {
  // Standard poster sizes (in points/pixels at 72 DPI)
  static const List<PosterSize> _posterSizes = [
    PosterSize(
      name: 'A4',
      width: 595,
      height: 842,
      description: 'Standard printing size (210×297 mm)',
    ),
    PosterSize(
      name: 'A5',
      width: 420,
      height: 595,
      description: 'Half A4 size (148×210 mm)',
    ),
    PosterSize(
      name: 'A3',
      width: 842,
      height: 1191,
      description: 'Large format (297×420 mm)',
    ),
    PosterSize(
      name: 'Letter',
      width: 612,
      height: 792,
      description: 'US Letter size (8.5×11 inches)',
    ),
    PosterSize(
      name: 'Legal',
      width: 612,
      height: 1008,
      description: 'US Legal size (8.5×14 inches)',
    ),
  ];

  List<MerchantData> _activeMerchants = [];
  bool _isLoading = true;
  String? _errorMessage;
  MerchantData? _selectedMerchant;
  ShopData? _selectedShop;
  PosterSize _selectedSize = _posterSizes[0]; // Default to A4
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

  Widget _buildPreview() {
    // Calculate preview scale to fit on screen
    // Use a maximum width/height for preview display
    const double maxPreviewWidth = 400;
    const double maxPreviewHeight = 600;
    
    final double widthScale = maxPreviewWidth / _selectedSize.width;
    final double heightScale = maxPreviewHeight / _selectedSize.height;
    final double previewScale = widthScale < heightScale ? widthScale : heightScale;
    
    // Clamp scale between 0.3 and 0.7 for better visibility
    final double clampedScale = previewScale.clamp(0.3, 0.7);
    
    return Transform.scale(
      scale: clampedScale,
      child: _buildPoster(),
    );
  }

  Widget _buildA4Template() {
    return Container(
      width: 595,
      height: 842,
      child: Column(
        children: [
          // Top Purple Section
          _buildA4TopSection(),
          // Middle White Section with QR Code and How It Works
          Expanded(
            child: _buildA4MiddleSection(),
          ),
          // Bottom Purple Section
          _buildA4BottomSection(),
        ],
      ),
    );
  }

  Widget _buildA4TopSection() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles pattern
          CustomPaint(
            size: const Size(595, 150),
            painter: _CirclePatternPainter(),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Shop Name
                Flexible(
                  child: Text(
                    _selectedShop!.shopName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),
                // Address
                if (_selectedShop!.address.city.isNotEmpty)
                  Flexible(
                    child: Text(
                      _selectedShop!.address.streetAddress,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textWhite.withOpacity(0.95),
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 10),
                // Scan instruction with better styling
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.textWhite.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.textWhite.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'SCAN CODE BELOW TO JOIN QUEUE!',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildA4MiddleSection() {
    return Container(
      color: AppColors.backgroundLight,
      child: Column(
        children: [
          // Top part - QR Code Area
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left side - Shop info
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.store,
                              size: 30,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'THANK YOU FOR CHOOSING',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Flexible(
                            child: Text(
                              _selectedShop!.shopName.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.8,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Join your queue from anywhere. Say goodbye to crowd and chaos.',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Center - QR Code
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: _getShopLink(_selectedShop!),
                            version: QrVersions.auto,
                            size: 160.0,
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
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 24),
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'SCAN NOW',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhite,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 14),
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'No More Waiting. Just Scan and Go.',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textWhite,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Because Time is Priceless.',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AppColors.textWhite.withOpacity(0.9),
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right side - Minimal branding
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'InQ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: List.generate(5, (index) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: Icon(
                                  Icons.star,
                                  color: AppColors.warning,
                                  size: 12,
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'inqueue.in',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom part - How InQ Works
          Expanded(
            flex: 2,
            child: _buildA4HowItWorksSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildA4HowItWorksSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.secondary,
                size: 16,
              ),
              const SizedBox(width: 6),
              const Text(
                'How InQ Works',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Steps in 2x2 grid
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildA4Step(
                        number: '1',
                        icon: Icons.qr_code_scanner,
                        title: 'Scan QR Code',
                        description: 'Use your phone camera',
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      _buildA4Step(
                        number: '2',
                        icon: Icons.app_registration,
                        title: 'Join Queue',
                        description: 'Reserve your spot',
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: [
                      _buildA4Step(
                        number: '3',
                        icon: Icons.notifications_active,
                        title: 'Get Notified',
                        description: 'We\'ll alert you',
                        color: AppColors.success,
                      ),
                      const SizedBox(height: 8),
                      _buildA4Step(
                        number: '4',
                        icon: Icons.store,
                        title: 'Visit Store',
                        description: 'Come at your turn',
                        color: AppColors.info,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildA4Step({
    required String number,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 9,
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

  Widget _buildA4BottomSection() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles pattern
          CustomPaint(
            size: const Size(595, 100),
            painter: _CirclePatternPainter(),
          ),
          // Minimal branding
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.flash_on,
                        size: 14,
                        color: AppColors.textWhite.withOpacity(0.9),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Powered by InQueue',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'www.inqueue.in',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textWhite.withOpacity(0.85),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoster() {
    if (_selectedShop == null) return const SizedBox.shrink();

    // Use different template for A4 size
    if (_selectedSize.name == 'A4') {
      return _buildA4Template();
    }

    // Calculate scale factor based on A4 (base size) for other sizes
    const double baseHeight = 842.0; // A4 height
    final double scaleFactor = _selectedSize.height / baseHeight;

    return Container(
      width: _selectedSize.width,
      height: _selectedSize.height,
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
          // Header Section with Shop Branding
          _buildHeaderSection(scaleFactor),
          
          // QR Code Section
          _buildQRSection(scaleFactor),
          
          // How It Works Section
          _buildHowItWorksSection(scaleFactor),
          
          // Footer with InQ Branding
          _buildFooterSection(scaleFactor),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(double scaleFactor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30 * scaleFactor),
          bottomRight: Radius.circular(30 * scaleFactor),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15 * scaleFactor,
            offset: Offset(0, 5 * scaleFactor),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        24 * scaleFactor,
        22 * scaleFactor,
        24 * scaleFactor,
        18 * scaleFactor,
      ),
      child: Column(
        children: [
          // Shop Name
          Text(
            _selectedShop!.shopName,
            style: TextStyle(
              fontSize: 32 * scaleFactor,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
              letterSpacing: 0.5 * scaleFactor,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 5 * scaleFactor),
          // Shop Address
          if (_selectedShop!.address.city.isNotEmpty)
            Text(
              '${_selectedShop!.address.streetAddress}',
              style: TextStyle(
                fontSize: 14 * scaleFactor,
                color: AppColors.textWhite.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          SizedBox(height: 10 * scaleFactor),
          // Tagline
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 18 * scaleFactor,
              vertical: 7 * scaleFactor,
            ),
            decoration: BoxDecoration(
              color: AppColors.textWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20 * scaleFactor),
            ),
            child: Text(
              'Skip the Wait, Join the Queue!',
              style: TextStyle(
                fontSize: 14 * scaleFactor,
                color: AppColors.textWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRSection(double scaleFactor) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 14 * scaleFactor,
        horizontal: 24 * scaleFactor,
      ),
      child: Column(
        children: [
          // Instruction
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(6 * scaleFactor),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.qr_code_scanner,
                  color: AppColors.primary,
                  size: 20 * scaleFactor,
                ),
              ),
              SizedBox(width: 10 * scaleFactor),
              Text(
                'Scan to Join Queue',
                style: TextStyle(
                  fontSize: 20 * scaleFactor,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 14 * scaleFactor),
          // QR Code with enhanced styling
          Container(
            padding: EdgeInsets.all(16 * scaleFactor),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(20 * scaleFactor),
              border: Border.all(
                color: AppColors.primary,
                width: 3 * scaleFactor,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 20 * scaleFactor,
                  offset: Offset(0, 10 * scaleFactor),
                ),
              ],
            ),
            child: QrImageView(
              data: _getShopLink(_selectedShop!),
              version: QrVersions.auto,
              size: 180.0 * scaleFactor,
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
          SizedBox(height: 8 * scaleFactor),
          Text(
            'Open your camera and point at the QR code',
            style: TextStyle(
              fontSize: 11 * scaleFactor,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(double scaleFactor) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24 * scaleFactor,
        vertical: 12 * scaleFactor,
      ),
      child: Container(
        padding: EdgeInsets.all(12 * scaleFactor),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(20 * scaleFactor),
          border: Border.all(
            color: AppColors.border,
            width: 2 * scaleFactor,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.secondary,
                  size: 18 * scaleFactor,
                ),
                SizedBox(width: 6 * scaleFactor),
                Text(
                  'How InQ Works',
                  style: TextStyle(
                    fontSize: 18 * scaleFactor,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12 * scaleFactor),
            // Steps
            _buildStep(
              number: '1',
              icon: Icons.qr_code_scanner,
              title: 'Scan QR Code',
              description: 'Use your phone camera to scan',
              color: AppColors.primary,
              scaleFactor: scaleFactor,
            ),
            SizedBox(height: 8 * scaleFactor),
            _buildStep(
              number: '2',
              icon: Icons.app_registration,
              title: 'Join Queue Virtually',
              description: 'Reserve your spot instantly',
              color: AppColors.secondary,
              scaleFactor: scaleFactor,
            ),
            SizedBox(height: 8 * scaleFactor),
            _buildStep(
              number: '3',
              icon: Icons.notifications_active,
              title: 'Get Notified',
              description: 'We\'ll alert you when it\'s your turn',
              color: AppColors.success,
              scaleFactor: scaleFactor,
            ),
            SizedBox(height: 8 * scaleFactor),
            _buildStep(
              number: '4',
              icon: Icons.store,
              title: 'Visit the Store',
              description: 'Come back at your turn, no waiting!',
              color: AppColors.info,
              scaleFactor: scaleFactor,
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
    required double scaleFactor,
  }) {
    return Row(
      children: [
        // Step Number Circle
        Container(
          width: 28 * scaleFactor,
          height: 28 * scaleFactor,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 5 * scaleFactor,
                offset: Offset(0, 2 * scaleFactor),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 15 * scaleFactor,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
          ),
        ),
        SizedBox(width: 8 * scaleFactor),
        // Icon
        Container(
          padding: EdgeInsets.all(5 * scaleFactor),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6 * scaleFactor),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18 * scaleFactor,
          ),
        ),
        SizedBox(width: 8 * scaleFactor),
        // Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13 * scaleFactor,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 10 * scaleFactor,
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

  Widget _buildFooterSection(double scaleFactor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 12 * scaleFactor,
        horizontal: 24 * scaleFactor,
      ),
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
                padding: EdgeInsets.all(5 * scaleFactor),
                decoration: const BoxDecoration(
                  color: AppColors.backgroundLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.schedule,
                  color: AppColors.secondary,
                  size: 14 * scaleFactor,
                ),
              ),
              SizedBox(width: 5 * scaleFactor),
              Text(
                'Save Time',
                style: TextStyle(
                  fontSize: 12 * scaleFactor,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textWhite,
                ),
              ),
              SizedBox(width: 12 * scaleFactor),
              Container(
                padding: EdgeInsets.all(5 * scaleFactor),
                decoration: const BoxDecoration(
                  color: AppColors.backgroundLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mobile_friendly,
                  color: AppColors.secondary,
                  size: 14 * scaleFactor,
                ),
              ),
              SizedBox(width: 5 * scaleFactor),
              Text(
                'Stay Informed',
                style: TextStyle(
                  fontSize: 12 * scaleFactor,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scaleFactor),
          Text(
            '⚡ Powered by InQueue',
            style: TextStyle(
              fontSize: 14 * scaleFactor,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
              letterSpacing: 0.5 * scaleFactor,
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
          
          // Create filename with shop name and size
          final shopName = _selectedShop!.shopName
              .replaceAll(RegExp(r'[^\w\s]'), '')
              .replaceAll(RegExp(r'\s+'), '_');
          final fileName = 'InQ_${shopName}_QR_Poster_${_selectedSize.name}';
          
          await FileSaver.instance.saveFile(
            name: fileName,
            bytes: jpgBytes,
            mimeType: MimeType.jpeg,
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${_selectedSize.name} poster downloaded successfully!'),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
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
                      if (_selectedShop != null) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Select Poster Size:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<PosterSize>(
                          value: _selectedSize,
                          items: _posterSizes.map((size) {
                            return DropdownMenuItem(
                              value: size,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    size.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${size.description} • ${size.dimensions}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedSize = value;
                              });
                            }
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Choose a size',
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'QR Poster Preview (${_selectedSize.name} Size):',
                          style: const TextStyle(
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
                                  child: _buildPreview(),
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
                            label: Text(
                              'Download ${_selectedSize.name} Poster',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Poster will be saved as JPG (${_selectedSize.name} ${_selectedSize.dimensions})',
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