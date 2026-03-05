import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../providers/language_provider.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';
import 'product_setup_screen.dart';
import 'day_flow/purchases_screen.dart';
import 'login_screen.dart';

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
        if (provider.products.isEmpty) _showSetupModal();
      });
    });
  }

  void _showSetupModal() {
    final s = context.read<LanguageProvider>().s;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${s.welcomeTitle} 🛒',
                style: AppTheme.serifAmharic(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(s.welcomeBody,
                style: AppTheme.sansAmharic(
                    fontSize: 13, color: AppTheme.brown, fontStyle: FontStyle.italic)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProductSetupScreen()));
              },
              child: Text(s.setupProducts,
                  style: AppTheme.sansAmharic(
                      fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.cream)),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.doLater,
                  style: AppTheme.sansAmharic(fontSize: 15, color: AppTheme.ink)),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker() {
    final lang = context.read<LanguageProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ChangeNotifierProvider.value(
        value: lang,
        child: Consumer<LanguageProvider>(
          builder: (ctx, l, _) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.s.selectLanguage,
                    style: AppTheme.serifAmharic(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                _LangOption(
                  flagText: 'ET',
                  label: 'አማርኛ',
                  sublabel: 'Amharic',
                  selected: l.isAmharic,
                  onTap: () {
                    l.setAmharic(true);
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 12),
                _LangOption(
                  flagText: 'EN',
                  label: 'English',
                  sublabel: 'English',
                  selected: !l.isAmharic,
                  onTap: () {
                    l.setAmharic(false);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _logout(LanguageProvider lang) {
    final s = lang.s;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.paper,
        title: Text(s.logout, style: AppTheme.serifAmharic(fontSize: 20)),
        content: Text(lang.isAmharic ? 'እርግጠኛ ነዎት መውጣት ይፈልጋሉ?' : 'Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text(s.logout, style: const TextStyle(color: AppTheme.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<AppProvider, LanguageProvider>(
        builder: (context, provider, lang, _) {
          final s = lang.s;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                title: Row(children: [
                  Text(s.appNamePart1,
                      style: AppTheme.serifAmharic(
                          fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.cream)),
                  Text(s.appNamePart2,
                      style: AppTheme.serifAmharic(
                          fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.amberLight)),
                ]),
                actions: [
                  // ── Language toggle pill ──────────────
                  GestureDetector(
                    onTap: _showLanguagePicker,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.amberLight.withOpacity(0.6)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language, size: 13, color: AppTheme.amberLight),
                          const SizedBox(width: 4),
                          Text(
                            lang.isAmharic ? 'አማርኛ' : 'EN',
                            style: AppTheme.sansAmharic(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.amberLight),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.local_grocery_store_sharp),
                    tooltip: s.manageProducts,
                    onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ProductSetupScreen()))
                        .then((_) => provider.loadMonthEntries(_focusedDay)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded),
                    tooltip: s.logout,
                    onPressed: () => _logout(lang),
                  ),
                ],
              ),

              // Calendar
              SliverToBoxAdapter(
                child: TableCalendar(
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  focusedDay: _focusedDay,
                  calendarFormat: CalendarFormat.month,
                  locale: lang.isAmharic ? 'am' : 'en_US',
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle:
                        AppTheme.serifAmharic(fontSize: 17, fontWeight: FontWeight.w700),
                    leftChevronIcon:
                        const Icon(Icons.chevron_left, color: AppTheme.brown),
                    rightChevronIcon:
                        const Icon(Icons.chevron_right, color: AppTheme.brown),
                    headerPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle:
                        AppTheme.sansAmharic(fontSize: 12, color: AppTheme.brown),
                    weekendStyle:
                        AppTheme.sansAmharic(fontSize: 12, color: AppTheme.brown),
                  ),
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: AppTheme.sansAmharic(fontSize: 14),
                    weekendTextStyle: AppTheme.sansAmharic(fontSize: 14),
                    todayDecoration: BoxDecoration(
                      border: Border.all(color: AppTheme.amber, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    todayTextStyle: AppTheme.sansAmharic(
                        fontSize: 14, fontWeight: FontWeight.w600),
                    selectedDecoration: BoxDecoration(
                        color: AppTheme.amber,
                        borderRadius: BorderRadius.circular(8)),
                    cellMargin: const EdgeInsets.all(4),
                    outsideDaysVisible: false,
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (ctx, day, _) {
                      final entry = provider.getEntryForDay(day.day);
                      if (entry == null) return null;
                      final color =
                          entry.complete ? AppTheme.greenLight : AppTheme.redLight;
                      final bg = entry.complete
                          ? const Color(0xFFEDF7F2)
                          : const Color(0xFFFFF2EE);
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color)),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${day.day}',
                                  style: AppTheme.sansAmharic(fontSize: 13)),
                              Text(entry.complete ? 'X' : 'o',
                                  style: TextStyle(
                                      fontSize: 10, color: color, height: 1.2)),
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

              // Monthly summary card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: AppTheme.ink,
                        borderRadius: BorderRadius.circular(14)),
                    child: Column(children: [
                      Row(children: [
                        Text(
                          DateFormat('MMMM yyyy').format(_focusedDay),
                          style: AppTheme.serifAmharic(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.amberLight),
                        ),
                        const Spacer(),
                        Text(
                          '${provider.completedDaysCount} ${s.daysLogged}',
                          style: AppTheme.sansAmharic(
                              fontSize: 11,
                              color: AppTheme.cream.withOpacity(0.5)),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                            child: _SummaryItem(
                                label: s.totalRevenue,
                                value: s.formatCurrency(provider.monthlyRevenue))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _SummaryItem(
                                label: s.netProfit,
                                value:
                                    s.formatCurrency(provider.monthlyNetProfit))),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                            child: _SummaryItem(
                                label: s.bestDay,
                                value: provider.bestDay ?? '-')),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _SummaryItem(
                                label: s.expensesLabel,
                                value:
                                    s.formatCurrency(provider.monthlyExpenses))),
                      ]),
                    ]),
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
    Navigator.push(context,
            MaterialPageRoute(builder: (_) => PurchasesScreen(date: day)))
        .then((_) => provider.loadMonthEntries(_focusedDay));
  }
}

// ── Language option tile ─────────────────────────────
class _LangOption extends StatelessWidget {
  final String flagText;
  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  const _LangOption({
    required this.flagText,
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppTheme.ink : AppTheme.paper,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.amber : AppTheme.rule,
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: selected
                  ? AppTheme.amber.withOpacity(0.2)
                  : const Color(0xFFF0EBE3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                flagText,
                style: AppTheme.serifAmharic(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: selected ? AppTheme.amberLight : AppTheme.brown),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTheme.serifAmharic(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: selected ? AppTheme.cream : AppTheme.ink)),
                Text(sublabel,
                    style: AppTheme.sansAmharic(
                        fontSize: 12,
                        color: selected ? AppTheme.amberLight : AppTheme.brown)),
              ],
            ),
          ),
          if (selected)
            const Icon(Icons.check_circle_rounded,
                color: AppTheme.amber, size: 22),
        ]),
      ),
    );
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
        Text(label,
            style: AppTheme.sansAmharic(
                fontSize: 10,
                color: AppTheme.amberLight.withOpacity(0.7),
                letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value,
            style: AppTheme.serifAmharic(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.cream)),
      ],
    );
  }
}
