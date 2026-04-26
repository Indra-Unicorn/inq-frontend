import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/common_style.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../models/shop.dart';

class StoreDetailsInfo extends StatefulWidget {
  final Shop store;

  const StoreDetailsInfo({
    super.key,
    required this.store,
  });

  @override
  State<StoreDetailsInfo> createState() => _StoreDetailsInfoState();
}

class _StoreDetailsInfoState extends State<StoreDetailsInfo> {
  bool _isExpanded = false;

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $urlString');
    }
  }

  void _openMap() {
    final query = Uri.encodeComponent(
      '${widget.store.shopName}, ${_formatAddress(widget.store.address)}',
    );
    final url = 'https://www.google.com/maps/search/?api=1&query=$query';
    _launchUrl(url);
  }

  void _callShop() {
    if (widget.store.shopPhoneNumber != null) {
      _launchUrl('tel:${widget.store.shopPhoneNumber}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store Name & Rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.store.shopName,
                  style: CommonStyle.heading2.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (widget.store.rating > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        widget.store.rating.toStringAsFixed(1),
                        style: CommonStyle.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        ' (${widget.store.ratingCount})',
                        style: CommonStyle.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Categories
          if (widget.store.categories.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.store.categories.map((category) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Text(
                    category,
                    style: CommonStyle.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          
          const SizedBox(height: 24),

          // Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (widget.store.shopPhoneNumber != null && widget.store.shopPhoneNumber!.isNotEmpty)
                _buildActionButton(
                  icon: Icons.phone_outlined,
                  label: 'Call',
                  onTap: _callShop,
                ),
              _buildActionButton(
                icon: Icons.directions_outlined,
                label: 'Directions',
                onTap: _openMap,
              ),
              _buildActionButton(
                icon: _isExpanded ? Icons.info : Icons.info_outline,
                label: 'Details',
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
            ],
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Column(
                    children: [
                      const SizedBox(height: 24),
                      const Divider(height: 1, thickness: 1),
                      const SizedBox(height: 24),

                      // Quick Stats Row
                      _buildQuickStats(),
                      
                      const SizedBox(height: 24),
                      
                      // Address & Hours
                      _buildModernInfoItem(
                        icon: Icons.location_on_outlined,
                        label: 'Address',
                        value: _formatAddress(widget.store.address),
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      _buildModernInfoItem(
                        icon: Icons.schedule_outlined,
                        label: 'Business Hours',
                        value: widget.store.openTime != null && widget.store.closeTime != null
                            ? '${widget.store.openTime} - ${widget.store.closeTime}'
                            : 'Not specified',
                        color: AppColors.success,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: CommonStyle.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Status',
            widget.store.shopStatus,
            Icons.storefront_outlined,
            widget.store.statusColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Avg Wait',
            widget.store.avgEntryTimeMinutes > 0 ? '${widget.store.avgEntryTimeMinutes}m' : '--',
            Icons.timer_outlined,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Queues',
            '${widget.store.queueResponses?.length ?? 0}',
            Icons.people_outline,
            AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: CommonStyle.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: CommonStyle.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: CommonStyle.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: CommonStyle.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatAddress(ShopAddress address) {
    final parts = <String>[];
    if (address.streetAddress.isNotEmpty) parts.add(address.streetAddress);
    if (address.city.isNotEmpty) parts.add(address.city);
    if (address.state.isNotEmpty) parts.add(address.state);
    if (address.postalCode.isNotEmpty) parts.add(address.postalCode);

    return parts.join(', ');
  }
}
