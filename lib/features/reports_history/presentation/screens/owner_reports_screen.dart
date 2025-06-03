import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rental_mobil_app_flutter/features/reports_history/providers/report_providers.dart';

class OwnerReportsScreen extends ConsumerWidget {
  const OwnerReportsScreen({super.key});

  // Pastikan fitur aktif
  static const bool isReportFeatureImplemented = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Warna sesuai gambar
    const Color darkBackgroundColor = Color(0xFF1F2C2E);
    const Color cardBackgroundColor = Color(0xFF2A3A3D);
    const Color primaryTextColor = Colors.white;
    const Color secondaryTextColor = Colors.white70;
    const Color accentColor = Color(0xFFB2D3A8); // Hijau muda
    const Color positiveChangeColor =
        Color(0xFF4CAF50); // Hijau untuk persentase positif

    // Periksa kondisi ini DULUAN
    if (!isReportFeatureImplemented) {
      return Scaffold(
        backgroundColor: darkBackgroundColor,
        appBar: AppBar(
          title:
              const Text('Revenue', style: TextStyle(color: primaryTextColor)),
          backgroundColor: const Color(0xFF1A2426),
          iconTheme: const IconThemeData(color: primaryTextColor),
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction, size: 60, color: secondaryTextColor),
              SizedBox(height: 16),
              Text(
                'Fitur Laporan Segera Hadir!',
                style: TextStyle(fontSize: 18, color: primaryTextColor),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Kami sedang menyiapkannya untuk Anda.',
                style: TextStyle(fontSize: 14, color: secondaryTextColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Jika fitur sudah diimplementasikan, lanjutkan dengan kode yang ada
    final selectedPeriod = ref.watch(reportPeriodProvider);
    final revenueDataAsync = ref.watch(revenueDataProvider);
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      backgroundColor: darkBackgroundColor,
      appBar: AppBar(
        title: const Text('Revenue', style: TextStyle(color: primaryTextColor)),
        backgroundColor: const Color(0xFF1A2426),
        iconTheme: const IconThemeData(color: primaryTextColor),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Segmented Control untuk Periode
            _buildPeriodSelector(
                context, ref, selectedPeriod, accentColor, cardBackgroundColor),
            const SizedBox(height: 24.0),

            // Total Revenue Card
            revenueDataAsync.when(
              data: (data) {
                // Tambahkan pengecekan apakah data revenue valid sebelum menampilkan
                if (data.totalRevenue < 0 && data.weeklyBreakdown.isEmpty) {
                  return _buildEmptyDataCard(
                      cardBackgroundColor,
                      secondaryTextColor,
                      "Data laporan tidak tersedia saat ini.");
                }
                return _buildTotalRevenueCard(
                    context,
                    data.totalRevenue,
                    currencyFormatter,
                    cardBackgroundColor,
                    primaryTextColor,
                    secondaryTextColor);
              },
              loading: () => _buildLoadingCard(cardBackgroundColor),
              error: (err, stack) =>
                  _buildErrorCard(err.toString(), cardBackgroundColor),
            ),
            const SizedBox(height: 24.0),

            // Weekly Revenue Section
            if (selectedPeriod == ReportPeriod.weekly)
              revenueDataAsync.when(
                data: (data) {
                  if (data.weeklyBreakdown.isEmpty &&
                      data.totalRevenue == 2500.00) {
                    return _buildEmptyDataCard(
                        cardBackgroundColor,
                        secondaryTextColor,
                        "Tidak ada data pendapatan mingguan.");
                  }
                  return _buildWeeklyRevenueSection(
                      context,
                      data,
                      currencyFormatter,
                      primaryTextColor,
                      secondaryTextColor,
                      positiveChangeColor,
                      accentColor);
                },
                loading: () => _buildLoadingIndicator(accentColor),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text('Error loading weekly data: $err',
                      style: const TextStyle(color: Colors.redAccent)),
                ),
              ),

            // Daily Revenue Section
            if (selectedPeriod == ReportPeriod.daily)
              revenueDataAsync.when(
                data: (data) => _buildSimpleRevenueView(
                    context,
                    "Today's Revenue",
                    data,
                    currencyFormatter,
                    primaryTextColor,
                    secondaryTextColor,
                    positiveChangeColor,
                    ref),
                loading: () => _buildLoadingIndicator(accentColor),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text('Error loading daily data: $err',
                      style: const TextStyle(color: Colors.redAccent)),
                ),
              ),

            // Monthly Revenue Section
            if (selectedPeriod == ReportPeriod.monthly)
              revenueDataAsync.when(
                data: (data) => _buildSimpleRevenueView(
                    context,
                    "This Month's Revenue",
                    data,
                    currencyFormatter,
                    primaryTextColor,
                    secondaryTextColor,
                    positiveChangeColor,
                    ref),
                loading: () => _buildLoadingIndicator(accentColor),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text('Error loading monthly data: $err',
                      style: const TextStyle(color: Colors.redAccent)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget helper tambahan
  Widget _buildEmptyDataCard(Color cardBg, Color textColor, String message) {
    return Card(
      color: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: SizedBox(
        height: 120,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              message,
              style: TextStyle(
                  color: textColor, fontSize: 16, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // Loading indicator khusus
  Widget _buildLoadingIndicator(Color color) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: CircularProgressIndicator(color: Color(0xFFB2D3A8)),
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, WidgetRef ref,
      ReportPeriod currentPeriod, Color activeColor, Color inactiveColor) {
    return Container(
      decoration: BoxDecoration(
        color: inactiveColor, // Warna latar belakang container selector
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ReportPeriod.values.map((period) {
          bool isSelected = currentPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(reportPeriodProvider.notifier).state = period;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Text(
                  period.toString().split('.').last.capitalize(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.black87 : Colors.white70,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTotalRevenueCard(
      BuildContext context,
      double totalRevenue,
      NumberFormat formatter,
      Color cardBg,
      Color primaryText,
      Color secondaryText) {
    return Card(
      color: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Revenue',
              style: TextStyle(fontSize: 16, color: secondaryText),
            ),
            const SizedBox(height: 8.0),
            Text(
              formatter.format(totalRevenue),
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: primaryText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(Color cardBg) {
    return Card(
      color: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: const SizedBox(
        height: 120, // Sesuaikan tinggi
        child:
            Center(child: CircularProgressIndicator(color: Color(0xFFB2D3A8))),
      ),
    );
  }

  Widget _buildErrorCard(String error, Color cardBg) {
    return Card(
      color: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: SizedBox(
        height: 120, // Sesuaikan tinggi
        child: Center(
            child: Text('Error: $error',
                style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }

  Widget _buildWeeklyRevenueSection(
      BuildContext context,
      RevenueSummary summary,
      NumberFormat formatter,
      Color primaryText,
      Color secondaryText,
      Color positiveChange,
      Color barColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Revenue',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: primaryText),
        ),
        const SizedBox(height: 4.0),
        Row(
          children: [
            Text(
              formatter.format(summary
                  .totalRevenue), // Menampilkan total revenue mingguan juga
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryText),
            ),
            const SizedBox(width: 8.0),
            if (summary.percentageChange != 0)
              Text(
                '${summary.percentageChange > 0 ? '+' : ''}${summary.percentageChange.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  color: summary.percentageChange > 0
                      ? positiveChange
                      : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        Text('This Week', style: TextStyle(fontSize: 14, color: secondaryText)),
        const SizedBox(height: 20.0),
        _buildBarChart(summary.weeklyBreakdown, barColor, secondaryText),
      ],
    );
  }

  Widget _buildSimpleRevenueView(
      // Definisi fungsi sudah diperbaiki
      BuildContext context,
      String title,
      RevenueSummary summary,
      NumberFormat formatter,
      Color primaryText,
      Color secondaryText,
      Color positiveChange,
      WidgetRef ref // Menerima WidgetRef jika perlu akses provider lain di sini
      ) {
    final currentPeriod =
        ref.watch(reportPeriodProvider); // Akses provider periode di sini

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: primaryText),
        ),
        const SizedBox(height: 4.0),
        Row(
          children: [
            Text(
              formatter.format(summary.totalRevenue),
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryText),
            ),
            const SizedBox(width: 8.0),
            if (summary.percentageChange != 0)
              Text(
                '${summary.percentageChange > 0 ? '+' : ''}${summary.percentageChange.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  color: summary.percentageChange > 0
                      ? positiveChange
                      : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        Text(
          currentPeriod == ReportPeriod.daily ? 'Today' : 'This Month',
          style: TextStyle(fontSize: 14, color: secondaryText),
        ),
      ],
    );
  }

  Widget _buildBarChart(
      List<DailyRevenueData> data, Color barColor, Color axisLabelColor) {
    if (data.isEmpty) {
      return const SizedBox(
          height: 200,
          child: Center(
              child: Text("No data for chart.",
                  style: TextStyle(color: Colors.white70))));
    }

    double maxY =
        data.map((d) => d.revenue).reduce((a, b) => a > b ? a : b) * 1.2;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(data[index].day,
                          style:
                              TextStyle(color: axisLabelColor, fontSize: 10)),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          barGroups: data.asMap().entries.map((entry) {
            final index = entry.key;
            final dailyData = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: dailyData.revenue,
                  color: barColor.withOpacity(0.7),
                  width: 22,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Extension untuk capitalize string (letakkan di file utilitas jika sering dipakai)
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
