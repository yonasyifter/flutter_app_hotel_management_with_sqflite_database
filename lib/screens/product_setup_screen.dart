import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product.dart';
import '../providers/app_provider.dart';
import '../providers/language_provider.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';


class ProductSetupScreen extends StatefulWidget {
  const ProductSetupScreen({super.key});
  @override
  State<ProductSetupScreen> createState() => _ProductSetupScreenState();
}

class _ProductSetupScreenState extends State<ProductSetupScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadClosingStockCache();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LanguageProvider>().s;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(s.products),
        actions: [
          TextButton.icon(
            onPressed: () => _showAddProduct(context),
            icon: const Icon(Icons.add, color: AppTheme.amberLight),
            label: Text(s.add,
                style: GoogleFonts.dmSans(
                    color: AppTheme.amberLight, fontWeight: FontWeight.w600)),
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
                    const Text('🛒', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      s.noProducts,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.noProductsSub,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _showAddProduct(context),
                      child: Text(s.addFirstProduct),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ScreenHeader(
                title: s.productList,
                subtitle: s.productListSub,
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
    final s = context.watch<LanguageProvider>().s;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    '${s.buy}: ${s.formatCurrency(product.buyPrice)}  ·  ${s.sell}: ${s.formatCurrency(product.sellPrice)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    s.openingStockLabel(context.read<AppProvider>().getProductCurrentStock(product.id!)),
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
                    builder: (bottomSheetContext) => _AddProductSheet(existing: product),
                  );
                } else if (val == 'deactivate') {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppTheme.paper,
                      title: Text(s.deactivateTitle,
                          style: Theme.of(context).textTheme.displaySmall),
                      content: Text(s.deactivateBody),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(s.cancel)),
                        TextButton(
                          onPressed: () {
                            context
                                .read<AppProvider>()
                                .deactivateProduct(product.id!);
                            Navigator.pop(ctx);
                          },
                          child: Text(s.deactivate,
                              style: const TextStyle(color: AppTheme.red)),
                        ),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Text(s.edit)),
                PopupMenuItem(value: 'deactivate', child: Text(s.deactivate)),
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
  late TextEditingController _nameCtrl, _buyCtrl, _sellCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _buyCtrl = TextEditingController(
        text: widget.existing?.buyPrice.toStringAsFixed(2) ?? '');
    _sellCtrl = TextEditingController(
        text: widget.existing?.sellPrice.toStringAsFixed(2) ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LanguageProvider>().s;
    final isEditing = widget.existing != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 28, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? s.editProduct : s.addProduct,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 4),
            Text(
              s.productDetails,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: s.productName),
              validator: (v) => (v == null || v.isEmpty) ? s.required : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _buyCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        labelText: s.buyPrice, prefixText: s.isAmharic ? 'ብር ' : 'ETB '),
                    validator: (v) =>
                        double.tryParse(v ?? '') == null ? s.invalid : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _sellCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        labelText: s.sellPrice, prefixText: s.isAmharic ? 'ብር ' : 'ETB '),
                    validator: (v) =>
                        double.tryParse(v ?? '') == null ? s.invalid : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          
            ElevatedButton(
              onPressed: _save,
              child: Text(isEditing ? s.saveChanges : s.addProduct),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.cancel),
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
    _nameCtrl.dispose();
    _buyCtrl.dispose();
    _sellCtrl.dispose();
    super.dispose();
  }
}
