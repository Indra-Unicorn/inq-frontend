import 'package:flutter/material.dart';
import '../../../../shared/common_style.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../models/queue.dart';
import '../../models/shop.dart';
import '../../services/queue_service.dart';
import 'store_details_header.dart';
import 'store_details_info.dart';
import 'store_details_queues.dart';
import '../../models/queue_status.dart';

class StoreDetailsPage extends StatefulWidget {
  final Shop store;

  const StoreDetailsPage({
    super.key,
    required this.store,
  });

  @override
  State<StoreDetailsPage> createState() => _StoreDetailsPageState();
}

class _StoreDetailsPageState extends State<StoreDetailsPage> {
  final QueueService _queueService = QueueService();
  bool _isLoading = true;
  String? _error;
  List<Queue> _queues = [];

  @override
  void initState() {
    super.initState();
    _loadQueues();
  }

  Future<void> _loadQueues() async {
    try {
      final queues = await _queueService.getShopQueues(widget.store.shopId);
      setState(() {
        _queues = queues;
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
    await _loadQueues();
  }

  @override
  Widget build(BuildContext context) {
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
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: StoreDetailsHeader(
                          store: widget.store,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: StoreDetailsInfo(
                          store: widget.store,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Available Queues',
                            style: CommonStyle.heading3,
                          ),
                        ),
                      ),
                      if (_isLoading)
                        const SliverFillRemaining(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_error != null)
                        SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _error!,
                                  style: CommonStyle.errorTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _onRefresh,
                                  style: CommonStyle.primaryButton,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (_queues.isEmpty)
                        const SliverFillRemaining(
                          child: Center(
                            child: Text('No queues available'),
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
                                                  content: Text('Error: $e')),
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
