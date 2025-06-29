import 'shop.dart';
import 'queue.dart';

class ShopQueueResponse {
  final Shop shop;
  final List<Queue> queues;

  ShopQueueResponse({
    required this.shop,
    required this.queues,
  });

  factory ShopQueueResponse.fromJson(Map<String, dynamic> json) {
    final shopData = json['data'] as Map<String, dynamic>;

    // Extract shop information
    final shop = Shop.fromJson(shopData);

    // Extract queue information
    final List<dynamic> queueResponses = shopData['queueResponses'] ?? [];
    final queues = queueResponses
        .map((queueJson) => Queue.fromJson(queueJson as Map<String, dynamic>))
        .toList();

    return ShopQueueResponse(
      shop: shop,
      queues: queues,
    );
  }
}
