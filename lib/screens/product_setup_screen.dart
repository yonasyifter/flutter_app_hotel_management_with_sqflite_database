import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';

class ProductSetupScreen extends StatelessWidget {
  const ProductSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ግሮሰሪ አቃዎች'),
        actions: [
          TextButton.icon(
            onPressed: () => _showAddProduct(context),
            icon: const Icon(Icons.add, color: AppTheme.amberLight),
            label: Text('ተጨማሪ', style: GoogleFonts.dmSans(color: AppTheme.amberLight, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final active = provider.products.where((p) => p.active).toList();
          if (active.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('ግሮሰሪ ውስጥ አቃ የለም🛒', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      '',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ከላይ ያለውን የምልክት በመጫን የመጀመሪያዎን አቃ ያስገቡ።.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _showAddProduct(context),
                      child: const Text('የመጀመርያ አቃ ኣስገባ/ቢ'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const ScreenHeader(
                title: 'የግሮሰሪ ዝርዝር አቃዎች',
                subtitle: 'የግሮሰሪ እቃ ብዛት፣ የመግዛት እና የመሸጥ ዋጋዎችን ያስተዳድሩ።',
              ),
              ...active.map((p) => _ProductTile(product: p)),
            ],
          );
        },
      ),
    );
  }

  void _showAddProduct(BuildContext context, {Product? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddProductSheet(existing: existing),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;

  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'መግዛት: ${formatCurrency(product.buyPrice)}  ·  መሸጥ: ${formatCurrency(product.sellPrice)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'መነሻ ብዛት: ${product.openingStock} ፍሬ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppTheme.brown),
              onSelected: (val) {
                if (val == 'edit') {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: AppTheme.paper,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => _AddProductSheet(existing: product),
                  );
                } else if (val == 'deactivate') {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppTheme.paper,
                      title: Text('አቁም?', style: Theme.of(context).textTheme.displaySmall),
                      content: const Text('ይህ ምርት ከዕለታዊ ዝርዝር ይደበቃል። ታሪኩ ግን ይቀመጣል/ ኣይተፋም።'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ይቅር')),
                        TextButton(
                          onPressed: () {
                            context.read<AppProvider>().deactivateProduct(product.id!);
                            Navigator.pop(ctx);
                          },
                          child: Text('ይቅር', style: TextStyle(color: AppTheme.red)),
                        ),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('አርትዕ')),
                const PopupMenuItem(value: 'deactivate', child: Text('ይቅር')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddProductSheet extends StatefulWidget {
  final Product? existing;
  const _AddProductSheet({this.existing});

  @override
  State<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<_AddProductSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl, _buyCtrl, _sellCtrl, _stockCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _buyCtrl = TextEditingController(text: widget.existing?.buyPrice.toStringAsFixed(2) ?? '');
    _sellCtrl = TextEditingController(text: widget.existing?.sellPrice.toStringAsFixed(2) ?? '');
    _stockCtrl = TextEditingController(text: (widget.existing?.openingStock ?? 0).toString());
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 28, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Edit (የገባ አቃ ኣስተካክል)' : 'ኣዲስ አቃ ኣስገባ',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'የእቃው መረጃ እና ዋጋ ያስገቡ።',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'የእቃ ስም'),
              validator: (v) => (v == null || v.isEmpty) ? 'ያስፈልጋል' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _buyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'የመግዛት ዋጋ (ብር)', prefixText: 'ብር '),
                    validator: (v) => double.tryParse(v ?? '') == null ? 'ስህተት' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _sellCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'የመሸጥ ዋጋ (ብር)', prefixText: 'ብር'),
                    validator: (v) => double.tryParse(v ?? '') == null ? 'ስህተት' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _stockCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'መነሻ ብዛት (እቃ)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: Text(isEditing ? 'Save (ለውጦችን አስቀምጥ)' : 'እቃ ጨምር'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel (ይቅር)'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AppProvider>();
    final product = Product(
      id: widget.existing?.id,
      name: _nameCtrl.text.trim(),
      buyPrice: double.parse(_buyCtrl.text),
      sellPrice: double.parse(_sellCtrl.text),
      openingStock: int.tryParse(_stockCtrl.text) ?? 0,
    );
    if (widget.existing != null) {
      provider.updateProduct(product);
    } else {
      provider.addProduct(product);
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _buyCtrl.dispose();
    _sellCtrl.dispose(); _stockCtrl.dispose();
    super.dispose();
  }
}
