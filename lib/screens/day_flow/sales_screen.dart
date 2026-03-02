import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme.dart';
import '../../widgets/shared_widgets.dart';
import 'summary_screen.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('የቀን ሽያጭ'), actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF6B4226), borderRadius: BorderRadius.circular(20)),
              child: const Text('ደረጃ 4 ከ 5', style: TextStyle(fontFamily: 'NotoEthiopic', fontSize: 11, color: Color(0xFFF5F0E8))),
            ),
          ),
        ),
      ]),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              const StepIndicator(currentStep: 4, totalSteps: 5),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const ScreenHeader(
                      title: 'ሽያጮችን መዝግብ',
                      subtitle: 'ዛሬ ስንት ፍሬ ሸጡ?',
                    ),
                    ...provider.activeProducts.map((p) {
                      final available = provider.getAvailableStock(p.id!);
                      final currentSold = provider.pendingSalesQty[p.id] ?? 0;
                      final sellPrice = provider.pendingSellPrice[p.id] ?? p.sellPrice;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name, style: Theme.of(context).textTheme.titleLarge),
                                    const SizedBox(height: 2),
                                    Text(
                                      'ያለ ክምችት: $available  ·  @ ${formatCurrency(sellPrice)}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    if (currentSold > 0) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'ጠቅላላ ዋጋ: ${formatCurrency(currentSold * sellPrice)}',
                                        style: TextStyle(
                                          fontSize: 12, color: AppTheme.green,
                                          fontFamily: 'NotoEthiopic',
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              _StepperWidget(
                                value: currentSold,
                                max: available,
                                onChanged: (v) => provider.setSalesQty(p.id!, v),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    // Live running total
                    Consumer<AppProvider>(
                      builder: (ctx, p, _) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.ink.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('የዛሬ ገቢ', style: Theme.of(ctx).textTheme.titleLarge),
                            Text(
                              formatCurrency(p.dailyRevenue),
                              style: const TextStyle(
                                fontFamily: 'NotoEthiopic', fontSize: 18,
                                fontWeight: FontWeight.w600, color: AppTheme.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              BottomActionBar(
                label: 'ማጠቃለያውን ይመልከቱ →',
                onPressed: () async {
                  await provider.saveSales();
                  if (context.mounted) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SummaryScreen()));
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

class _StepperWidget extends StatefulWidget {
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  const _StepperWidget({required this.value, required this.max, required this.onChanged});

  @override
  State<_StepperWidget> createState() => _StepperWidgetState();
}

class _StepperWidgetState extends State<_StepperWidget> {
  late int _val;

  @override
  void initState() { super.initState(); _val = widget.value; }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Btn(Icons.remove, () { if (_val > 0) { setState(() => _val--); widget.onChanged(_val); } }),
        Container(
          width: 40, alignment: Alignment.center,
          child: Text('$_val', style: const TextStyle(fontFamily: 'NotoEthiopic', fontSize: 18, fontWeight: FontWeight.w600)),
        ),
        _Btn(Icons.add, () { if (_val < widget.max) { setState(() => _val++); widget.onChanged(_val); } }),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Btn(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: AppTheme.ink, borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.cream, size: 16),
      ),
    );
  }
}
