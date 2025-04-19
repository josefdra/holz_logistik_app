class AnalyticsDataElement {
  const AnalyticsDataElement({
    this.quantity = 0,
    this.oversizeQuantity = 0,
    this.pieceCount = 0,
    this.sawmillName = '',
  });

  final double quantity;
  final double oversizeQuantity;
  final int pieceCount;
  final String sawmillName;

  AnalyticsDataElement copyWith({
    double? quantity,
    double? oversizeQuantity,
    int? pieceCount,
    String? sawmillName,
  }) {
    return AnalyticsDataElement(
      quantity: quantity ?? this.quantity,
      oversizeQuantity: oversizeQuantity ?? this.oversizeQuantity,
      pieceCount: pieceCount ?? this.pieceCount,
      sawmillName: sawmillName ?? this.sawmillName,
    );
  }
}
