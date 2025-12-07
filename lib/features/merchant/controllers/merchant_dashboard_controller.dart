import 'package:flutter/material.dart';
import '../models/merchant_queue.dart';
import '../models/merchant_data.dart';
import '../services/merchant_queue_service.dart';
import '../services/merchant_data_service.dart';
import '../../customer/models/customer_queue_summary.dart';

class MerchantDashboardController extends ChangeNotifier {
  bool _isLoading = true;
  bool _isLoadingMerchantData = true;
  List<MerchantQueue> _queues = [];
  MerchantData? _merchantData;
  String? _errorMessage;
  String? _merchantDataErrorMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingMerchantData => _isLoadingMerchantData;
  List<MerchantQueue> get queues => _queues;
  MerchantData? get merchantData => _merchantData;
  String? get errorMessage => _errorMessage;
  String? get merchantDataErrorMessage => _merchantDataErrorMessage;

  // Computed properties
  int get totalQueues => _queues.length;
  int get activeQueues => _queues.where((q) => q.isActive).length;
  int get totalCustomers => _queues.fold(0, (sum, q) => sum + q.size);

  // Merchant data computed properties
  String get merchantName => _merchantData?.name ?? 'Merchant';
  String get merchantEmail => _merchantData?.email ?? '';
  double get merchantInQoin => _merchantData?.inQoin ?? 0.0;
  int get totalShops => _merchantData?.shops.length ?? 0;
  List<ShopData> get shops => _merchantData?.shops ?? [];

  /// Load both merchant data and queues
  Future<void> loadInitialData() async {
    await Future.wait([
      loadMerchantData(),
      loadQueues(),
    ]);
  }

  /// Refresh queue data for polling (silent refresh without loading states)
  Future<void> refreshQueueData() async {
    try {
      final queues = await MerchantQueueService.getMerchantQueues();
      _queues = queues;
      notifyListeners();
    } catch (e) {
      // Silent failure for polling - don't update error state
      // This prevents UI disruption during background polling
    }
  }

  /// Load merchant data from the API
  Future<void> loadMerchantData() async {
    _setLoadingMerchantData(true);
    _clearMerchantDataError();

    try {
      final merchantData = await MerchantDataService.getMerchantData();
      _merchantData = merchantData;
      _setLoadingMerchantData(false);
    } catch (e) {
      _setMerchantDataError(e.toString());
      _setLoadingMerchantData(false);
    }
  }

  /// Load merchant queues from the API
  Future<void> loadQueues() async {
    _setLoading(true);
    _clearError();

    try {
      final queues = await MerchantQueueService.getMerchantQueues();
      _queues = queues;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Create a new queue
  Future<void> createQueue({
    required String name,
    required int maxSize,
    required double inQoinRate,
    required int alertNumber,
    required int bufferNumber,
  }) async {
    try {
      await MerchantQueueService.createQueue(
        name: name,
        maxSize: maxSize,
        inQoinRate: inQoinRate,
        alertNumber: alertNumber,
        bufferNumber: bufferNumber,
      );

      // Refresh the queue list after creation
      await loadQueues();
    } catch (e) {
      rethrow;
    }
  }

  /// Process the next customer in a queue
  Future<void> processNextCustomer(MerchantQueue queue) async {
    try {
      // Get queue members to find the top customer
      final members = await MerchantQueueService.getQueueMembers(queue.qid);
      
      if (members.isEmpty) {
        throw Exception('No customers in queue to process');
      }
      
      // Sort members by currentRank to get the top customer (rank 1)
      final sortedMembers = List<CustomerQueue>.from(members)
        ..sort((a, b) => a.currentRank.compareTo(b.currentRank));
      
      final topCustomer = sortedMembers.first;
      
      // Process the top customer using their customer ID
      await MerchantQueueService.processNextCustomer(queue.qid, topCustomer.customerId);
      await loadQueues(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  /// Pause a queue
  Future<void> pauseQueue(MerchantQueue queue) async {
    try {
      await MerchantQueueService.pauseQueue(queue.qid);
      await loadQueues(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  /// Resume a queue
  Future<void> resumeQueue(MerchantQueue queue) async {
    try {
      await MerchantQueueService.resumeQueue(queue.qid);
      await loadQueues(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  /// Stop a queue
  Future<void> stopQueue(MerchantQueue queue) async {
    try {
      await MerchantQueueService.stopQueue(queue.qid);
      await loadQueues(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingMerchantData(bool loading) {
    _isLoadingMerchantData = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _setMerchantDataError(String error) {
    _merchantDataErrorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _clearMerchantDataError() {
    _merchantDataErrorMessage = null;
    notifyListeners();
  }
}
