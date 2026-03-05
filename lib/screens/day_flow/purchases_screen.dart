import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../providers/language_provider.dart';
import '../../theme.dart';
import '../../widgets/shared_widgets.dart';
import 'price_check_screen.dart';

class PurchasesScreen extends StatelessWidget {
  final DateTime date;
  const PurchasesScreen({super.key, required this.date});
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(builder: (context, lang, _) {
      final s = lang.s;
      return Scaffold(
        appBar: AppBar(
          title: Text(DateFormat('d MMMM yyyy').format(date), style: AppTheme.serifAmharic(fontSize: 18, color: AppTheme.cream)),
          actions: [Padding(padding: const EdgeInsets.only(right: 12), child: Center(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.brown, borderRadius: BorderRadius.circular(20)),
            child: Text(s.step(2,6), style: AppTheme.sansAmharic(fontSize: 11, color: AppTheme.cream)),
          )))],
        ),
        body: Consumer<AppProvider>(builder: (context, provider, _) {
          return Column(children: [
            const StepIndicator(currentStep: 2, totalSteps: 6),
            Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
              ScreenHeader(title: s.dailyPurchases, subtitle: s.dailyPurchasesSub),
              ...provider.activeProducts.map((p) => Card(child: Padding(padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name, style: AppTheme.sansAmharic(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(s.openingStockLabel(provider.getOpeningStock(p.id!)), style: AppTheme.sansAmharic(fontSize: 12, color: AppTheme.brown)),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: QtyField(label: s.qtyPurchased, value: provider.pendingPurchaseQty[p.id] ?? 0, onChanged: (v) => provider.setPurchaseQty(p.id!, v))),
                    const SizedBox(width: 12),
                    Expanded(child: CurrencyField(label: s.buyPrice, value: provider.pendingPurchasePrice[p.id] ?? p.buyPrice, onChanged: (v) => provider.setPurchasePrice(p.id!, v))),
                  ]),
                ]),
              ))),
            ])),
            BottomActionBar(label: s.saveAndContinue, onPressed: () async {
              await provider.savePurchases();
              if (context.mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const PriceCheckScreen()));
            }),
          ]);
        }),
      );
    });
  }
}
