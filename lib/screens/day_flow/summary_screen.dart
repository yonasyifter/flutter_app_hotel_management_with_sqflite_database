import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme.dart';
import '../../widgets/shared_widgets.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('የቀን ማጠቃለያ'), actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF6B4226), borderRadius: BorderRadius.circular(20)),
              child: const Text('ደረጃ 5 ከ 5', style: TextStyle(fontFamily: 'NotoEthiopic', fontSize: 11, color: Color(0xFFF5F0E8))),
            ),
          ),
        ),
      ]),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final products = provider.activeProducts;
          final warnings = <String>[];

          return Column(
            children: [
              const StepIndicator(currentStep: 5, totalSteps: 5),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const ScreenHeader(
                      title: 'የቀኑ መጨረሻ',
                      subtitle: 'የዛሬውን ውሎ ከታች ይመልከቱ።',
                    ),

                    // ─── Product table ──────────────────
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowHeight: 36,
                            dataRowMinHeight: 48,
                            dataRowMaxHeight: 56,
                            columnSpacing: 16,
                            headingTextStyle: const TextStyle(
                              fontSize: 10, color: AppTheme.brown,
                              letterSpacing: 0.8, fontWeight: FontWeight.w500,
                              fontFamily: 'NotoEthiopic',
                            ),
                            dataTextStyle: const TextStyle(fontSize: 12, color: AppTheme.ink, fontFamily: 'NotoEthiopic'),
                            columns: const [
                              DataColumn(label: Text('እቃ')),
                              DataColumn(label: Text('ጅምር/መነሻ'), numeric: true),
                              DataColumn(label: Text('+ተገዛ'), numeric: true),
                              DataColumn(label: Text('ተሸጠ'), numeric: true),
                              DataColumn(label: Text('ቀሪ'), numeric: true),
                              DataColumn(label: Text('ገቢ'), numeric: true),
                            ],
                            rows: products.map((p) {
                              final opening = provider.getOpeningStock(p.id!);
                              final bought = provider.pendingPurchaseQty[p.id] ?? 0;
                              final sold = provider.pendingSalesQty[p.id] ?? 0;
                              final closing = (opening + bought - sold).clamp(0, 9999);
                              final sellPrice = provider.pendingSellPrice[p.id] ?? p.sellPrice;
                              final revenue = sold * sellPrice;

                              if (closing <= 3) {
                                warnings.add('${p.name}: $closing ፍሬ ብቻ ነው የቀረው');
                              }

                              return DataRow(cells: [
                                DataCell(Text(p.name,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.ink, fontFamily: 'NotoEthiopic'))),
                                DataCell(Text('$opening')),
                                DataCell(Text('+$bought')),
                                DataCell(Text('$sold')),
                                DataCell(Text(
                                  '$closing',
                                  style: TextStyle(color: closing <= 3 ? AppTheme.red : AppTheme.ink),
                                )),
                                DataCell(Text(formatCurrency(revenue))),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),

                    // ─── Warnings ───────────────────────
                    if (warnings.isNotEmpty) ...[
                      const SectionLabel('የእቃው ማለቅ ማስጠንቀቂያ'),
                      ...warnings.map((w) => WarningChip(w)),
                    ],

                    // ─── Totals ─────────────────────────
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: 'ጠቅላላ ገቢ',
                            value: formatCurrency(provider.dailyRevenue),
                            dark: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            label: 'ጠቅላላ ትርፍ',
                            value: formatCurrency(provider.dailyProfit),
                            dark: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              BottomActionBar(
                label: '✓ ቀኑን ጨርስ',
                color: AppTheme.green,
                onPressed: () async {
                  await provider.completeDay();
                  if (context.mounted) {
                    // Pop back to home (pop all day flow screens)
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
