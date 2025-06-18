class QueueValidator {
  static bool isValidSize(int size) => size >= 0;
  static bool isValidMaxSize(int maxSize) => maxSize > 0;
  static bool isValidProcessed(int processed) => processed >= 0;
  static bool isValidInQoinRate(int rate) => rate >= 0;
  static bool isValidAlertNumber(int number) => number >= 0;
  static bool isValidBufferNumber(int number) => number >= 0;
  static bool isValidProcessingRate(int rate) => rate >= 0;

  static bool validateQueueData({
    required int size,
    required int maxSize,
    required int processed,
    required int inQoinRate,
    required int alertNumber,
    required int bufferNumber,
    required int processingRate,
  }) {
    return isValidSize(size) &&
        isValidMaxSize(maxSize) &&
        isValidProcessed(processed) &&
        isValidInQoinRate(inQoinRate) &&
        isValidAlertNumber(alertNumber) &&
        isValidBufferNumber(bufferNumber) &&
        isValidProcessingRate(processingRate);
  }
}
