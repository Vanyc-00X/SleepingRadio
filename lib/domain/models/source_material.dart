enum SourceMaterialStatus {
  pending,
  extracting,
  ready,
  failed;

  String get storageValue => name;

  static SourceMaterialStatus fromStorage(String value) {
    return SourceMaterialStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SourceMaterialStatus.pending,
    );
  }
}

class SourceMaterial {
  const SourceMaterial({
    required this.id,
    required this.title,
    this.url,
    this.rawText,
    this.extractedText,
    this.status = SourceMaterialStatus.pending,
    this.errorMessage,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? url;
  final String? rawText;
  final String? extractedText;
  final SourceMaterialStatus status;
  final String? errorMessage;
  final DateTime? createdAt;
}
