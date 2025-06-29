import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../shared/common_style.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../models/shop.dart';

class StoreDetailsHeader extends StatelessWidget {
  final Shop store;

  const StoreDetailsHeader({
    super.key,
    required this.store,
  });

  void _shareStore(BuildContext context) async {
    try {
      // Dynamically extract the domain from the API base URL
      final domain = AppConstants.getShareableDomain();

      // Create a shareable URL with the store ID using the dynamic domain
      final shareableUrl = '$domain/store/${store.shopId}';

      // Create a fallback deep link for the app
      final deepLink = 'inqueue.in/store/${store.shopId}';

      // Create share text with store information
      final shareText = '''
Check out ${store.shopName} on InQ!

📍 ${store.address.streetAddress}, ${store.address.city}
${store.categories.isNotEmpty ? '🏷️ ${store.categories.take(3).join(', ')}' : ''}

Join queues and skip the wait! 🚀

$shareableUrl
$deepLink
'''
          .trim();

      // Use share_plus to share the content
      await Share.share(
        shareText,
        subject: 'Check out ${store.shopName} on InQ',
      );
    } catch (e) {
      // Fallback to clipboard if sharing fails
      final fallbackUrl = 'http://inqueue.in/store/${store.shopId}';
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.textWhite,
                      size: 20,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => _shareStore(context),
                    icon: const Icon(
                      Icons.share_outlined,
                      color: AppColors.textWhite,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              store.shopName,
              style: CommonStyle.heading1.copyWith(
                color: AppColors.textWhite,
                fontSize: 28,
              ),
            ),
            if (store.categories.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: store.categories.take(3).map((category) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: CommonStyle.caption.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: AppColors.backgroundLight.withValues(alpha: 0.8),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${store.address.streetAddress}, ${store.address.city}',
                    style: CommonStyle.bodyMedium.copyWith(
                      color: AppColors.backgroundLight.withValues(alpha: 0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
