part of 'analytics_page_bloc.dart';

enum AnalyticsPageStatus { initial, loading, success, failure }

final class AnalyticsPageState extends Equatable {
  AnalyticsPageState({
    this.status = AnalyticsPageStatus.initial,
    this.analyticsData = const {},
    this.contracts = const [],
    DateTime? endDate,
    DateTime? startDate,
    this.customDate = false,
    this.totalCurrentQuantity = 0,
    this.totalCurrentOversizeQuantity = 0,
    this.totalCurrentPieceCount = 0,
  })  : endDate = endDate ??
            DateTime.now().copyWith(hour: 23, minute: 59, second: 59),
        startDate = startDate ??
            DateTime.now()
                .copyWith(hour: 23, minute: 59, second: 59)
                .subtract(const Duration(days: 32));

  final AnalyticsPageStatus status;
  final Map<String, AnalyticsDataElement> analyticsData;
  final List<Contract> contracts;
  final DateTime endDate;
  final DateTime startDate;
  final bool customDate;
  final double totalCurrentQuantity;
  final double totalCurrentOversizeQuantity;
  final int totalCurrentPieceCount;

  AnalyticsPageState copyWith({
    AnalyticsPageStatus? status,
    Map<String, AnalyticsDataElement>? analyticsData,
    List<Contract>? contracts,
    DateTime? endDate,
    DateTime? startDate,
    bool? customDate,
    double? totalCurrentQuantity,
    double? totalCurrentOversizeQuantity,
    int? totalCurrentPieceCount,
  }) {
    return AnalyticsPageState(
      status: status ?? this.status,
      analyticsData: analyticsData ?? this.analyticsData,
      contracts: contracts ?? this.contracts,
      endDate: endDate ?? this.endDate,
      startDate: startDate ?? this.startDate,
      customDate: customDate ?? this.customDate,
      totalCurrentQuantity: totalCurrentQuantity ?? this.totalCurrentQuantity,
      totalCurrentOversizeQuantity:
          totalCurrentOversizeQuantity ?? this.totalCurrentOversizeQuantity,
      totalCurrentPieceCount:
          totalCurrentPieceCount ?? this.totalCurrentPieceCount,
    );
  }

  @override
  List<Object?> get props => [
        status,
        analyticsData,
        contracts,
        endDate,
        startDate,
        customDate,
        totalCurrentQuantity,
        totalCurrentOversizeQuantity,
        totalCurrentPieceCount,
      ];
}
