class ApiEndpoints {
  static const String baseUrl = 'https://lnq-production.up.railway.app/api';
  //static const String baseUrl = 'http://localhost:8080/api';

  // Auth endpoints
  static const String adminLogin = '/auth/login/admin';
  static const String customerEmailSignup = '/auth/signup/customer/email';
  static const String customerPhoneSignupInitiate =
      '/auth/signup/customer/phone/initiate';
  static const String customerPhoneSignup = '/auth/signup/customer/phone';
  static const String customerLogin = '/auth/login/customer';
  static const String customerLoginInitiate = '/auth/login/customer/initiate';
  static const String customerPhoneLogin = '/auth/login/customer/phone';
  static const String merchantSignup = '/auth/signup/merchant';
  static const String merchantLogin = '/auth/login/merchant';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';

  // User endpoints
  static const String getUserById = '/users/get';
  static const String getCustomerInfo = '/users/customer/info';
  static const String getCustomer = '/users/customer/get';
  static const String getMerchant = '/users/merchant/get';
  static const String getAllMerchants = '/users/merchant/get/all';
  static const String updateMerchantStatus = '/users/merchants';
  static const String updateMerchantDetails = '/users/merchant/update';
  static const String updateCustomerDetails = '/users/customer/update';
  static const String updateShopImage = '/users/shop/image/update';

  // Queue endpoints
  static const String createQueue = '/queues/create';
  static const String getQueue = '/queues';
  static const String getMerchantQueues = '/queues/merchant';
  static const String updateQueueStatus = '/queues';
  static const String updateQueueDetails = '/queues';

  // Queue Manager endpoints
  static const String joinQueue = '/queue-manager';
  static const String leaveQueue = '/queue-manager';
  static const String getCurrentPosition = '/queue-manager';
  static const String getCustomerQueueHistory =
      '/queue-manager/customer/history';
  static const String streamLivePosition = '/queue-manager';
  static const String processNextCustomer = '/queue-manager';
  static const String getQueueMembers = '/queue-manager';
  static const String getQueueHistory = '/queue-manager';
  static const String updateMemberPosition = '/queue-manager';

  // Notification endpoints
  static const String registerFCMToken = '/v1/tokens/register';
  static const String unregisterFCMToken = '/v1/tokens/unregister';
  static const String refreshFCMToken = '/v1/tokens/refresh';
  static const String getMyDevices = '/v1/tokens/my-devices';
  static const String getMyTokens = '/v1/tokens/my-tokens';

  // SMS endpoints
  static const String sendOTPPublic = '/v1/sms/public/otp';
  static const String sendOTPProtected = '/v1/sms/protected/otp';
  static const String verifyOTP = '/v1/sms/verify-otp';
  static const String sendCustomSMS = '/v1/sms/send-custom';
  static const String getSMSStatus = '/v1/sms/status';
}
