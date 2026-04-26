import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../models/shop.dart';

class StoreDetailsHeader extends StatefulWidget {
  final Shop store;

  const StoreDetailsHeader({
    super.key,
    required this.store,
  });

  @override
  State<StoreDetailsHeader> createState() => _StoreDetailsHeaderState();
}

class _StoreDetailsHeaderState extends State<StoreDetailsHeader> {
  int _currentImageIndex = 0;

  void _shareStore(BuildContext context) async {
    try {
      final domain = AppConstants.getShareableDomain();
      final shareableUrl = '$domain/store/${widget.store.shopId}';

      final shareText = '''
Check out ${widget.store.shopName} on InQ!

📍 ${widget.store.address.streetAddress}, ${widget.store.address.city}
${widget.store.categories.isNotEmpty ? '🏷️ ${widget.store.categories.take(3).join(', ')}' : ''}

Join queues and skip the wait! 🚀

$shareableUrl
'''
          .trim();

      await Share.share(
        shareText,
        subject: 'Check out ${widget.store.shopName} on InQ',
      );
    } catch (e) {
      final fallbackUrl = 'http://inqueue.in/store/${widget.store.shopId}';
      await Clipboard.setData(ClipboardData(text: fallbackUrl));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Store link copied to clipboard!'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280.0,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/customer-dashboard');
              }
            },
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.white, size: 18),
              onPressed: () => _shareStore(context),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.store.images.isNotEmpty)
              PageView.builder(
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemCount: widget.store.images.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    widget.store.images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.broken_image, color: AppColors.primary, size: 50),
                    ),
                  );
                },
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryLight,
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.store,
                  color: Colors.white54,
                  size: 80,
                ),
              ),
            
            // Gradient Overlay for Top Buttons readability
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Bottom fade into background
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.background,
                      AppColors.background.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            
            // Image Indicator
            if (widget.store.images.length > 1)
              Positioned(
                bottom: 24,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentImageIndex + 1}/${widget.store.images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
