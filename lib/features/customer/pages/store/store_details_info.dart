import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Quick Stats Row
          _buildQuickStats(),
          const SizedBox(height: 16),
          
          // Collapsible Main Info Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.store_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Store Details',
                              style: CommonStyle.heading4.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isExpanded ? 'Tap to collapse' : 'Tap to view details',
                              style: CommonStyle.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.expand_more,
                          color: AppColors.textSecondary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Collapsible content
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: _isExpanded ? null : 0,
                  child: _isExpanded ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      
                      // Info items in a more modern layout
                      _buildModernInfoItem(
                  icon: Icons.schedule_outlined,
                  label: 'Business Hours',
                  value: widget.store.openTime != null && widget.store.closeTime != null
                      ? '${widget.store.openTime} - ${widget.store.closeTime}'
                      : 'Not specified',
                  color: AppColors.primary,
                ),
                
                if (widget.store.shopPhoneNumber != null) ...[
                  const SizedBox(height: 16),
                  _buildModernInfoItem(
                    icon: Icons.phone_outlined,
                    label: 'Phone Number',
                    value: widget.store.shopPhoneNumber!,
                    color: AppColors.success,
                    isClickable: true,
                  ),
                ],
                
                const SizedBox(height: 16),
                _buildModernInfoItem(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: _formatAddress(widget.store.address),
                  color: AppColors.warning,
                ),
                
                if (widget.store.rating > 0) ...[
                  const SizedBox(height: 16),
                  _buildModernInfoItem(
                    icon: Icons.star_outlined,
                    label: 'Customer Rating',
                    value: '${widget.store.rating.toStringAsFixed(1)} ★ (${widget.store.ratingCount} reviews)',
                    color: Colors.amber,
                  ),
                ],
                    ],
                  ) : const SizedBox.shrink(),
                ),
              ],
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
            Icons.access_time_outlined,
            widget.store.statusColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Avg Wait',
            widget.store.avgEntryTimeMinutes > 0 ? '${widget.store.avgEntryTimeMinutes}m' : 'No data',
            Icons.timer_outlined,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Queues',
            '${widget.store.queueResponses?.length ?? 0}',
            Icons.queue_outlined,
            AppColors.success,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: CommonStyle.bodyLarge.copyWith(
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
    bool isClickable = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: CommonStyle.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: isClickable ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isClickable)
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 14,
            ),
        ],
      ),
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
