import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

// ─── Step progress indicator ─────────────────────────
class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({super.key, required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.paper,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: List.generate(totalSteps, (i) {
          Color color;
          if (i < currentStep - 1) color = AppTheme.greenLight;
          else if (i == currentStep - 1) color = AppTheme.amber;
          else color = AppTheme.rule;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < totalSteps - 1 ? 6 : 0),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Section Label ───────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11, color: AppTheme.brown,
          letterSpacing: 1, fontWeight: FontWeight.w500,
          fontFamily: 'NotoEthiopic',
        ),
      ),
    );
  }
}

// ─── Screen Header ───────────────────────────────────
class ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const ScreenHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ─── Numeric input tile ──────────────────────────────
class NumericTile extends StatelessWidget {
  final String label;
  final String subLabel;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int? max;

  const NumericTile({
    super.key,
    required this.label,
    required this.subLabel,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value.toString());
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 2),
                  Text(subLabel, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            SizedBox(
              width: 70,
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 18, color: AppTheme.ink, fontFamily: 'NotoEthiopic'),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  isDense: true,
                ),
                onChanged: (v) {
                  int parsed = int.tryParse(v) ?? min;
                  if (max != null && parsed > max!) parsed = max!;
                  if (parsed < min) parsed = min;
                  onChanged(parsed);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Currency input field ────────────────────────────
class CurrencyField extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const CurrencyField({super.key, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value.toStringAsFixed(2));
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 15, color: AppTheme.ink, fontFamily: 'NotoEthiopic'),
      decoration: InputDecoration(
        labelText: label,
        prefixText: 'ብር ',
        prefixStyle: const TextStyle(color: AppTheme.brown, fontFamily: 'NotoEthiopic'),
      ),
      onChanged: (v) => onChanged(double.tryParse(v) ?? value),
    );
  }
}

// ─── Bottom primary button ───────────────────────────
class BottomActionBar extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const BottomActionBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: const BoxDecoration(
        color: AppTheme.paper,
        border: Border(top: BorderSide(color: AppTheme.rule)),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppTheme.ink,
          foregroundColor: AppTheme.cream,
        ),
        child: Text(label),
      ),
    );
  }
}

// ─── Warning chip ────────────────────────────────────
class WarningChip extends StatelessWidget {
  final String text;
  const WarningChip(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2EE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.redLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 13, color: AppTheme.red, fontFamily: 'NotoEthiopic')),
        ],
      ),
    );
  }
}

// ─── Stat card (for summary/monthly) ─────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool dark;

  const StatCard({super.key, required this.label, required this.value, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? AppTheme.ink : AppTheme.paper,
        borderRadius: BorderRadius.circular(12),
        border: dark ? null : Border.all(color: AppTheme.rule, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10, letterSpacing: 1,
              color: dark ? AppTheme.amberLight : AppTheme.brown,
              fontWeight: FontWeight.w500,
              fontFamily: 'NotoEthiopic',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w700,
              color: dark ? AppTheme.cream : AppTheme.ink,
              fontFamily: 'NotoEthiopic',
            ),
          ),
        ],
      ),
    );
  }
}
