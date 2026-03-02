import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../theme.dart';
import '../../widgets/shared_widgets.dart';
import 'price_check_screen.dart';

class PurchasesScreen extends StatelessWidget {
  final DateTime date;
  const PurchasesScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('d MMMM yyyy', 'am_ET').format(date)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.brown,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('ደረጃ 2 ከ 5',
                  style: TextStyle(
                    fontFamily: 'NotoEthiopic', fontSize: 11, color: AppTheme.cream,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              const StepIndicator(currentStep: 2, totalSteps: 5),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const ScreenHeader(
                      title: 'ግዢዎችን መዝግብ',
                      subtitle: 'ዛሬ ምን አዲስ እቃ ገዙ?',
                    ),
                    ...provider.activeProducts.map((p) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(p.name, style: Theme.of(context).textTheme.titleLarge),
                                        Text(
                                          'ግሮሰሪ ውስጥ የነበረ : ${provider.getOpeningStock(p.id!)} ፍሬ',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: _QtyField(
                                      label: 'የተገዛ ብዛት',
                                      value: provider.pendingPurchaseQty[p.id] ?? 0,
                                      onChanged: (v) => provider.setPurchaseQty(p.id!, v),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: CurrencyField(
                                      label: 'የገዢ ዋጋ',
                                      value: provider.pendingPurchasePrice[p.id] ?? p.buyPrice,
                                      onChanged: (v) => provider.setPurchasePrice(p.id!, v),
                                    ),
                                  ),
                                ],
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
                label: 'አስቀምጥ እና ቀጥል →',
                onPressed: () async {
                  await provider.savePurchases();
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PriceCheckScreen()),
                    );
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

class _QtyField extends StatefulWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _QtyField({required this.label, required this.value, required this.onChanged});

  @override
  State<_QtyField> createState() => _QtyFieldState();
}

class _QtyFieldState extends State<_QtyField> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value.toString());
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _ctrl,
      keyboardType: TextInputType.number,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(labelText: widget.label),
      onChanged: (v) => widget.onChanged(int.tryParse(v) ?? 0),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
}
