import 'package:flutter/material.dart';
import '../../../../shared/common_style.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../models/queue.dart';
import '../../models/shop.dart';
import '../../services/queue_service.dart';
import '../../services/shop_service.dart';
import 'store_details_header.dart';
import 'store_details_info.dart';
import 'store_details_queues.dart';
import 'store_images_section.dart';
import '../../models/queue_status.dart';

class StoreDetailsPage extends StatefulWidget {
  final String shopId;

  const StoreDetailsPage({
    super.key,
    required this.shopId,
  });

  @override
  State<StoreDetailsPage> createState() => _StoreDetailsPageState();
}

class _StoreDetailsPageState extends State<StoreDetailsPage> {
  final QueueService _queueService = QueueService();
  final ShopService _shopService = ShopService();
  bool _isLoading = true;
  String? _error;
  List<Queue> _queues = [];
  Shop? _shop;

  @override
  void initState() {
    super.initState();
    _loadShopById();
  }

  Future<void> _loadShopById() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final shop = await _shopService.getShopById(widget.shopId);
      setState(() {
        _shop = shop;
        _isLoading = false;
      });

      _loadShopAndQueues();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadShopAndQueues() async {
    if (_shop == null) return;

    try {
      final response = await _queueService.getShopQueues(_shop!.shopId);
      setState(() {
        _queues = response.queues;
        // Update shop with latest data from API
        _shop = response.shop;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    await _loadShopById();
  }

  // Get the current shop data
  Shop? get currentShop => _shop;

  @override
  Widget build(BuildContext context) {
    if (_isLoading && currentShop == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_error != null && currentShop == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Store not found',
                    style: CommonStyle.heading4,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: CommonStyle.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: CommonStyle.primaryButton,
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (currentShop == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: Text('Store not found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;
            return Center(
              child: Container(
                constraints:
                    BoxConstraints(maxWidth: isDesktop ? 900 : double.infinity),
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 0),
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppColors.primary,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: StoreDetailsHeader(
                          store: currentShop!,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: StoreImagesSection(
                          store: currentShop!,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: StoreDetailsInfo(
                          store: currentShop!,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Available Queues',
                                style: CommonStyle.heading3.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_isLoading)
                        const SliverFillRemaining(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else if (_error != null)
                        SliverFillRemaining(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: AppColors.error,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Something went wrong',
                                    style: CommonStyle.heading4,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _error!,
                                    style: CommonStyle.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: _onRefresh,
                                    style: CommonStyle.primaryButton,
                                    child: const Text('Try Again'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else if (_queues.isEmpty)
                        SliverFillRemaining(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.queue_outlined,
                                    size: 64,
                                    color: AppColors.textTertiary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No queues available',
                                    style: CommonStyle.heading4.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'This store doesn\'t have any active queues at the moment.',
                                    style: CommonStyle.bodyMedium.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else if (isDesktop)
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.6,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final queue = _queues[index];
                                if (queue == null) {
                                  return const SizedBox.shrink();
                                }
                                return StoreQueueCard(
                                  queue: queue,
                                  onJoin: queue.status == QueueStatus.active
                                      ? () async {
                                          setState(() => _isLoading = true);
                                          try {
                                            final result = await _queueService
                                                .joinQueue(queue.qid);
                                            if (!mounted) return;
                                            Navigator.pushNamed(
                                              context,
                                              '/queue-status',
                                              arguments: {
                                                'queueId': queue.qid,
                                                'queueData': result,
                                              },
                                            );
                                          } catch (e) {
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text('Error: $e'),
                                                backgroundColor:
                                                    AppColors.error,
                                              ),
                                            );
                                          } finally {
                                            if (mounted)
                                              setState(
                                                  () => _isLoading = false);
                                          }
                                        }
                                      : null,
                                  isJoining: _isLoading,
                                );
                              },
                              childCount: _queues.length,
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverToBoxAdapter(
                            child: StoreDetailsQueues(
                              queues: _queues,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
