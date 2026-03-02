import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';
import 'product_setup_screen.dart';
import 'day_flow/purchases_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      provider.loadProducts().then((_) {
        provider.loadMonthEntries(_focusedDay);
        // Show setup if no products
        if (provider.products.isEmpty) {
          _showSetupModal();
        }
      });
    });
  }

  void _showSetupModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ወደ ስቶክቡክ እንኳን በደህና መጡ 🛒', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 8),
            Text(
              "ይህ የመጀመሪያ ጊዜዎ ነው! መጀመሪያ የእቃዎች ዝርዝርዎን እናዘጋጅ።",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductSetupScreen()));
              },
              child: const Text('እቃዎችን አዘጋጅ'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('በኋላ አድርግ'),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return CustomScrollView(
            slivers: [
              // ─── App bar ───────────────────────────
              SliverAppBar(
                pinned: true,
                title: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'የግሮሰሪ ',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.cream,
                        ),
                      ),
                      TextSpan(
                        text: ' መዝገብ',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.amberLight,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.inventory_2_outlined),
                    tooltip: 'የእቃ ዝርዝር',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProductSetupScreen()),
                    ).then((_) => provider.loadMonthEntries(_focusedDay)),
                  ),
                ],
              ),

              // ─── Calendar ──────────────────────────
              SliverToBoxAdapter(
                child: TableCalendar(
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  focusedDay: _focusedDay,
                  calendarFormat: CalendarFormat.month,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: GoogleFonts.playfairDisplay(
                      fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.ink,
                    ),
                    leftChevronIcon: const Icon(Icons.chevron_left, color: AppTheme.brown),
                    rightChevronIcon: const Icon(Icons.chevron_right, color: AppTheme.brown),
                    headerPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: GoogleFonts.dmMono(fontSize: 12, color: AppTheme.brown),
                    weekendStyle: GoogleFonts.dmMono(fontSize: 12, color: AppTheme.brown),
                  ),
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.ink),
                    weekendTextStyle: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.ink),
                    todayDecoration: BoxDecoration(
                      border: Border.all(color: AppTheme.amber, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    todayTextStyle: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.ink, fontWeight: FontWeight.w600),
                    selectedDecoration: BoxDecoration(
                      color: AppTheme.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    cellMargin: const EdgeInsets.all(4),
                    outsideDaysVisible: false,
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (ctx, day, focusedDay) {
                      final entry = provider.getEntryForDay(day.day);
                      if (entry == null) return null;
                      final color = entry.complete ? AppTheme.greenLight : AppTheme.redLight;
                      final bg = entry.complete ? const Color(0xFFEDF7F2) : const Color(0xFFFFF2EE);
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${day.day}', style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.ink)),
                              Text(entry.complete ? '✓' : '●',
                                style: TextStyle(fontSize: 10, color: color, height: 1.2)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  onPageChanged: (day) {
                    setState(() => _focusedDay = day);
                    provider.loadMonthEntries(day);
                  },
                  onDaySelected: (selected, focused) {
                    setState(() => _focusedDay = focused);
                    _openDay(context, provider, selected);
                  },
                ),
              ),

              // ─── Monthly summary ────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.ink,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  DateFormat('MMMM yyyy').format(_focusedDay),
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 16, color: AppTheme.amberLight,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${provider.completedDaysCount} ቀናት ተመዝግበዋል',
                                  style: GoogleFonts.dmMono(
                                    fontSize: 11, color: AppTheme.cream.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _SummaryItem(
                                    label: 'ገቢ',
                                    value: formatCurrency(provider.monthlyRevenue),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _SummaryItem(
                                    label: 'ትርፍ',
                                    value: formatCurrency(provider.monthlyProfit),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _SummaryItem(
                                    label: 'ምርጥ ቀን',
                                    value: provider.bestDay ?? '—',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openDay(BuildContext context, AppProvider provider, DateTime day) async {
    if (provider.activeProducts.isEmpty) {
      _showSetupModal();
      return;
    }
    await provider.openDay(day);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PurchasesScreen(date: day)),
    ).then((_) => provider.loadMonthEntries(_focusedDay));
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.dmMono(
            fontSize: 10, letterSpacing: 1,
            color: AppTheme.amberLight.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.playfairDisplay(
            fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.cream,
          ),
        ),
      ],
    );
  }
}
