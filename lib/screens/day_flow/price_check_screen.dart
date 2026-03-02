import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/shared_widgets.dart';
import 'sales_screen.dart';

class PriceCheckScreen extends StatelessWidget {
  const PriceCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('መሸጫ ዋጋ'), actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF6B4226), borderRadius: BorderRadius.circular(20)),
              child: const Text('ደረጃ 3 ከ 5', style: TextStyle(fontFamily: 'NotoEthiopic', fontSize: 11, color: Color(0xFFF5F0E8))),
            ),
          ),
        ),
      ]),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              const StepIndicator(currentStep: 3, totalSteps: 5),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const ScreenHeader(
                      title: 'የዋጋ ማረጋገጫ',
                      subtitle: 'የዛሬውን የመሸጫ ዋጋ ያረጋግጡ ወይም ያሻሽሉ።',
                    ),
                    ...provider.activeProducts.map((p) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 12),
                              CurrencyField(
                                label: 'የመሸጫ ዋጋ',
                                value: provider.pendingSellPrice[p.id] ?? p.sellPrice,
                                onChanged: (v) => provider.setSellPrice(p.id!, v),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              BottomActionBar(
                label: 'ዋጋዎችን አረጋግጥ →',
                onPressed: () async {
                  await provider.saveSellPrices();
                  if (context.mounted) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesScreen()));
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
