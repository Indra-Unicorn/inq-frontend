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

    // A5 size: 420x595 points (standard for printing)
    return Container(
      width: 420,
      height: 595,
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _selectedShop!.shopName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: QrImageView(
              data: _getShopLink(_selectedShop!),
              version: QrVersions.auto,
              size: 250.0,
              backgroundColor: AppColors.backgroundLight,
              dataModuleStyle: QrDataModuleStyle(color: AppColors.textPrimary),
              eyeStyle: QrEyeStyle(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Scan to join the queue',
            style: TextStyle(
              fontSize: 20,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            'Merchant: ${_selectedMerchant!.name}',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Powered by InQueue',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPoster() async {
    final imageBytes = await _screenshotController.capture();
    if (imageBytes != null) {
      final pngImage = img.decodePng(imageBytes);
      if (pngImage != null) {
        final jpgBytes = img.encodeJpg(pngImage);
        await FileSaver.instance.saveFile(
          name: 'qr_poster.jpg',
          bytes: jpgBytes,
          mimeType: MimeType.jpeg,
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
                          'QR Poster Preview:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Center(
                            child: Screenshot(
                              controller: _screenshotController,
                              child: _buildPoster(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _downloadPoster,
                          child: const Text('Download Poster'),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}