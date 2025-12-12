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
import '../../../../shared/widgets/error_dialog.dart';
import '../../../../services/auth_service.dart';
import '../../../auth/login_page.dart';

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
  Set<String> _userCurrentQueueIds = {}; // Store user's current queue IDs

  @override
  void initState() {
    super.initState();
    _loadShopById();
    _loadUserCurrentQueues();
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
        _isLoading = false;
      });
      
      if (mounted) {
        ErrorDialog.show(
          context,
          title: 'Unable to Load Shop',
          message: ErrorDialog.getErrorMessage(e),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop(); // Go back to previous screen
          },
        );
      }
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
        _isLoading = false;
      });
      
      if (mounted) {
        ErrorDialog.show(
          context,
          title: 'Unable to Load Queues',
          message: ErrorDialog.getErrorMessage(e),
          buttonText: 'Retry',
          onPressed: () {
            Navigator.of(context).pop();
            _loadShopAndQueues(); // Retry loading queues
          },
        );
      }
    }
  }

  Future<void> _loadUserCurrentQueues() async {
    try {
      // Only try to load user queues if logged in
      final isLoggedIn = await AuthService.isLoggedIn();
      if (!isLoggedIn) {
        setState(() {
          _userCurrentQueueIds = {};
        });
        return;
      }
      
      final customerQueueSummary = await _queueService.getCustomerQueueSummary();
      setState(() {
        _userCurrentQueueIds = customerQueueSummary.customerQueues
            .map((queue) => queue.qid)
            .toSet();
      });
    } catch (e) {
      // Silently handle error - user might not be logged in or have no queues
      setState(() {
        _userCurrentQueueIds = {};
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    await _loadShopById();
    await _loadUserCurrentQueues();
  }

  // Get the current shop data
  Shop? get currentShop => _shop;

  // Check if user is already in a specific queue
  bool _isUserInQueue(String queueId) {
    return _userCurrentQueueIds.contains(queueId);
  }

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

    // Error handling is now done via dialogs, so we just show loading or content

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
                    backgroundColor: AppColors.backgroundLight,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Enhanced Header
                        SliverToBoxAdapter(
                          child: StoreDetailsHeader(
                            store: currentShop!,
                          ),
                        ),
                        
                        // Spacing between header and images
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 24),
                        ),
                        
                        // Images Section with better spacing
                        SliverToBoxAdapter(
                          child: StoreImagesSection(
                            store: currentShop!,
                          ),
                        ),
                        
                        // Enhanced Info Section
                        SliverToBoxAdapter(
                          child: Transform.translate(
                            offset: const Offset(0, -20),
                            child: StoreDetailsInfo(
                              store: currentShop!,
                            ),
                          ),
                        ),
                        
                        // Enhanced Queue Section Header
                        SliverToBoxAdapter(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.queue_outlined,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Available Queues',
                                    style: CommonStyle.heading4.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (_queues.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${_queues.length}',
                                      style: CommonStyle.bodySmall.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
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
                              child: Container(
                                padding: const EdgeInsets.all(32),
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
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.error_outline,
                                        size: 48,
                                        color: AppColors.error,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Something Went Wrong',
                                      style: CommonStyle.heading4.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
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
                                    ElevatedButton.icon(
                                      onPressed: _onRefresh,
                                      icon: const Icon(Icons.refresh, size: 18),
                                      label: const Text('Try Again'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      else if (_queues.isEmpty)
                        SliverFillRemaining(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Container(
                                padding: const EdgeInsets.all(32),
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
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.queue_outlined,
                                        size: 48,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'No Queues Available',
                                      style: CommonStyle.heading4.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'This store doesn\'t have any active queues right now. Check back later or contact the store directly.',
                                      style: CommonStyle.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton.icon(
                                      onPressed: _onRefresh,
                                      icon: const Icon(Icons.refresh, size: 18),
                                      label: const Text('Refresh'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                                  onJoin: (queue.status == QueueStatus.active && !_isUserInQueue(queue.qid))
                                      ? () async {
                                          // Check if user is logged in before joining queue
                                          final isLoggedIn = await AuthService.isLoggedIn();
                                          if (!isLoggedIn) {
                                            // Show dialog to prompt login
                                            if (!mounted) return;
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Login Required'),
                                                content: const Text('Please login to join the queue.'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                      Navigator.pushNamed(context, '/login');
                                                    },
                                                    child: const Text('Login'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            return;
                                          }
                                          
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
                                  isUserInQueue: _isUserInQueue(queue.qid),
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
                              userCurrentQueueIds: _userCurrentQueueIds,
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
