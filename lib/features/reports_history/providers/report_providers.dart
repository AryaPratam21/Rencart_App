// lib/features/reports_history/providers/report_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ReportPeriod { daily, weekly, monthly }

class DailyRevenueData {
  final String day;
  final double revenue;
  DailyRevenueData({required this.day, required this.revenue});
}

class RevenueSummary {
  final double totalRevenue;
  final double percentageChange;
  final List<DailyRevenueData> weeklyBreakdown;
  RevenueSummary({
    required this.totalRevenue,
    required this.percentageChange,
    required this.weeklyBreakdown,
  });
}

final reportPeriodProvider =
    StateProvider<ReportPeriod>((ref) => ReportPeriod.weekly);

final revenueDataProvider =
    FutureProvider.autoDispose<RevenueSummary>((ref) async {
  final period = ref.watch(reportPeriodProvider);

  await Future.delayed(const Duration(seconds: 1));

  if (period == ReportPeriod.weekly) {
    return RevenueSummary(
      totalRevenue: 2500.00,
      percentageChange: 15.0,
      weeklyBreakdown: [
        DailyRevenueData(day: "Sen", revenue: 300),
        DailyRevenueData(day: "Sel", revenue: 450),
        DailyRevenueData(day: "Rab", revenue: 200),
        DailyRevenueData(day: "Kam", revenue: 500),
        DailyRevenueData(day: "Jum", revenue: 600),
        DailyRevenueData(day: "Sab", revenue: 350),
        DailyRevenueData(day: "Min", revenue: 100),
      ],
    );
  } else if (period == ReportPeriod.daily) {
    return RevenueSummary(
        totalRevenue: 350.00, percentageChange: 5.0, weeklyBreakdown: []);
  } else {
    return RevenueSummary(
        totalRevenue: 10500.00, percentageChange: 8.0, weeklyBreakdown: []);
  }
});
