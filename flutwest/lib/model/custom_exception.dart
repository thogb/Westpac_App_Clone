class InsufficientFundException implements Exception {
  String cause;
  InsufficientFundException(this.cause);

  @override
  String toString() {
    return cause;
  }
}

class DocumentNotFoundException implements Exception {
  String cause;
  DocumentNotFoundException(this.cause);

  @override
  String toString() {
    return cause;
  }
}
