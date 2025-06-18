import 'package:flutter/material.dart';
import '../../models/shop.dart';

class CustomerDashboardStoreList extends StatelessWidget {
  final List<Shop> shops;
  final bool isLoading;
  final String? error;
  final IconData Function(List<String>) getStoreIcon;
  final Color Function(List<String>) getStoreIconColor;
  final void Function(Shop) onStoreTap;

  const CustomerDashboardStoreList({
    super.key,
    required this.shops,
    required this.isLoading,
    required this.error,
    required this.getStoreIcon,
    required this.getStoreIconColor,
    required this.onStoreTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (error != null) {
      return Center(
          child: Text(error!, style: const TextStyle(color: Colors.red)));
    } else {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: shops.length,
        itemBuilder: (context, index) {
          final shop = shops[index];
          return StoreListItem(
            shop: shop,
            getStoreIcon: getStoreIcon,
            getStoreIconColor: getStoreIconColor,
            onTap: () => onStoreTap(shop),
          );
        },
      );
    }
  }
}

class StoreListItem extends StatelessWidget {
  final Shop shop;
  final IconData Function(List<String>) getStoreIcon;
  final Color Function(List<String>) getStoreIconColor;
  final VoidCallback onTap;

  const StoreListItem({
    super.key,
    required this.shop,
    required this.getStoreIcon,
    required this.getStoreIconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFFF4F0F0),
            image:
                shop.images.isNotEmpty && shop.images.first.startsWith('http')
                    ? DecorationImage(
                        image: NetworkImage(shop.images.first),
                        fit: BoxFit.cover,
                      )
                    : null,
          ),
          child: shop.images.isEmpty || !shop.images.first.startsWith('http')
              ? Icon(
                  getStoreIcon(shop.categories),
                  color: getStoreIconColor(shop.categories),
                  size: 28,
                )
              : null,
        ),
        title: Text(
          shop.shopName,
          style: const TextStyle(
            color: Color(0xFF181111),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${shop.address.city}, ${shop.address.state}',
              style: const TextStyle(
                color: Color(0xFF886364),
                fontSize: 14,
              ),
            ),
            if (shop.isOpen)
              const Text(
                'Open',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                ),
              )
            else
              const Text(
                'Closed',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
