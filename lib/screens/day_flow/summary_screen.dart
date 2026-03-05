import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/language_provider.dart';
import '../../theme.dart';
import '../../widgets/shared_widgets.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(builder: (context, lang, _) {
      final s = lang.s;
      return Scaffold(
        appBar: AppBar(
          title: Text(s.dailySummary, style: AppTheme.serifAmharic(fontSize: 20, color: AppTheme.cream)),
          actions: [Padding(padding: const EdgeInsets.only(right: 12), child: Center(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.brown, borderRadius: BorderRadius.circular(20)),
            child: Text(s.step(6,6), style: AppTheme.sansAmharic(fontSize: 11, color: AppTheme.cream)),
          )))],
        ),
        body: Consumer<AppProvider>(builder: (context, provider, _) {
          final products = provider.activeProducts;
          final warnings = <String>[];
          return Column(children: [
            const StepIndicator(currentStep: 6, totalSteps: 6),
            Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
              ScreenHeader(title: s.endOfDay, subtitle: s.endOfDaySub),
              Card(child: Padding(padding: const EdgeInsets.all(4),
                child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowHeight: 36, dataRowMinHeight: 48, dataRowMaxHeight: 56, columnSpacing: 14,
                    headingTextStyle: AppTheme.sansAmharic(fontSize: 10, color: AppTheme.brown, letterSpacing: 0.5),
                    dataTextStyle: AppTheme.sansAmharic(fontSize: 12),
                    columns: [
                      DataColumn(label: Text(s.colProduct)),
                      DataColumn(label: Text(s.colOpen), numeric: true),
                      DataColumn(label: Text(s.colBought), numeric: true),
                      DataColumn(label: Text(s.colSold), numeric: true),
                      DataColumn(label: Text(s.colClose), numeric: true),
                      DataColumn(label: Text(s.colRevenue), numeric: true),
                    ],
                    rows: products.map((p) {
                      final opening = provider.getOpeningStock(p.id!);
                      final bought = provider.pendingPurchaseQty[p.id] ?? 0;
                      final sold = provider.pendingSalesQty[p.id] ?? 0;
                      final closing = (opening + bought - sold).clamp(0, 9999);
                      final sellPrice = provider.pendingSellPrice[p.id] ?? p.sellPrice;
                      if (closing <= 3) warnings.add(s.lowStockMsg(p.name, closing));
                      return DataRow(cells: [
                        DataCell(Text(p.name, style: AppTheme.sansAmharic(fontSize: 13, fontWeight: FontWeight.w600))),
                        DataCell(Text('$opening')),
                        DataCell(Text('+$bought')),
                        DataCell(Text('$sold')),
                        DataCell(Text('$closing', style: TextStyle(color: closing <= 3 ? AppTheme.red : AppTheme.ink))),
                        DataCell(Text(s.formatCurrency(sold * sellPrice))),
                      ]);
                    }).toList(),
                  ),
                ),
              )),
              if (warnings.isNotEmpty) ...[
                SectionLabel(s.lowStockWarning),
                ...warnings.map((w) => WarningChip(w)),
                const SizedBox(height: 8),
              ],
              Row(children: [
                Expanded(child: StatCard(label: s.totalRevenue, value: s.formatCurrency(provider.dailyRevenue))),
                const SizedBox(width: 12),
                Expanded(child: StatCard(label: s.grossProfit, value: s.formatCurrency(provider.dailyProfit))),
              ]),
              const SizedBox(height: 12),
              if (provider.pendingExpenses.isNotEmpty) ...[
                SectionLabel(s.householdExpenses),
                Card(child: Column(children: [
                  ...provider.pendingExpenses.map((exp) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(children: [
                      const Text('🏠', style: TextStyle(fontSize: 15)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(exp.description, style: AppTheme.sansAmharic(fontSize: 15))),
                      Text('- ${s.formatCurrency(exp.amount)}', style: AppTheme.serifAmharic(fontSize: 13, color: AppTheme.red, fontWeight: FontWeight.w600)),
                    ]))),
                  Padding(padding: const EdgeInsets.fromLTRB(16,4,16,12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(s.totalExpenses, style: AppTheme.sansAmharic(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.brown)),
                    Text('- ${s.formatCurrency(provider.totalDailyExpenses)}', style: AppTheme.serifAmharic(fontSize: 14, color: AppTheme.red, fontWeight: FontWeight.w700)),
                  ])),
                ])),
              ],
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppTheme.ink, borderRadius: BorderRadius.circular(14)),
                child: Column(children: [
                  if (provider.pendingExpenses.isNotEmpty) ...[
                    _NetRow(s.grossProfit, s.formatCurrency(provider.dailyProfit), AppTheme.amberLight),
                    const SizedBox(height: 6),
                    _NetRow(s.minusExpenses, '- ${s.formatCurrency(provider.totalDailyExpenses)}', AppTheme.redLight),
                    Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Divider(color: Colors.white.withOpacity(0.15), thickness: 1)),
                  ],
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(s.netProfit, style: AppTheme.serifAmharic(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.cream)),
                    Text(s.formatCurrency(provider.dailyNetProfit),
                      style: AppTheme.serifAmharic(fontSize: 28, fontWeight: FontWeight.w900,
                        color: provider.dailyNetProfit >= 0 ? AppTheme.greenLight : AppTheme.redLight)),
                  ]),
                ]),
              ),
              const SizedBox(height: 80),
            ])),
            BottomActionBar(label: s.markComplete, color: AppTheme.green, onPressed: () async {
              await provider.completeDay();
              if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
            }),
          ]);
        }),
      );
    });
  }
}
class _NetRow extends StatelessWidget {
  final String label, value; final Color color;
  const _NetRow(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: AppTheme.sansAmharic(fontSize: 13, color: AppTheme.cream.withOpacity(0.65))),
    Text(value, style: AppTheme.serifAmharic(fontSize: 14, color: color, fontWeight: FontWeight.w600)),
  ]);
}
