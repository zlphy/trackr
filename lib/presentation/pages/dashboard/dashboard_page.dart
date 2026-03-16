import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/expense.dart';
import '../../../domain/entities/expense_category.dart';
import '../../../config/injection.dart';
import '../../bloc/expense/expense_bloc.dart';
import '../../routes/app_router.dart';

@RoutePage()
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ExpenseBloc>()..add(LoadDashboardStatsWithFilters(
      month: DateTime.now(),
      sortBy: 'date',
      sortDescending: true,
    )),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView>
    with TickerProviderStateMixin {
  late AnimationController _listController;
  late AnimationController _headerController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  int _prevExpenseCount = 0;
  DateTime _selectedMonth = DateTime.now();
  String _sortBy = 'date'; // 'date', 'amount', 'merchant'
  bool _sortDescending = true;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFade = CurvedAnimation(
        parent: _headerController, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
            begin: const Offset(0, -0.15), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _headerController, curve: Curves.easeOut));

    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _headerController.forward();
    _listController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _listController.dispose();
    super.dispose();
  }

  void _reload() {
    context.read<ExpenseBloc>().add(LoadDashboardStatsWithFilters(
      month: _selectedMonth,
      sortBy: _sortBy,
      sortDescending: _sortDescending,
    ));
    _listController.reset();
    _listController.forward();
  }

  Future<void> _navigateTo(PageRouteInfo route) async {
    await context.router.push(route);
    if (mounted) _reload();
  }

  void _showMonthPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).brightness == Brightness.dark
                ? const ColorScheme.dark(primary: Color(0xFF66C0F4))
                : const ColorScheme.light(primary: Color(0xFF1A3A5C)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month, 1);
      });
      _reload();
    }
  }

  void _sortExpenses() {
    // Reload with new sort settings
    context.read<ExpenseBloc>().add(LoadDashboardStatsWithFilters(
      month: _selectedMonth,
      sortBy: _sortBy,
      sortDescending: _sortDescending,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: BlocConsumer<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is DashboardLoaded &&
              state.expenses.length != _prevExpenseCount) {
            _prevExpenseCount = state.expenses.length;
            _listController.reset();
            _listController.forward();
          }
        },
        builder: (context, state) {
          final expenses = state is DashboardLoaded
              ? state.expenses
              : state is ExpenseLoaded
                  ? state.expenses
                  : <Expense>[];
          final monthlyTotal =
              state is DashboardLoaded ? state.monthlyTotal : 0.0;
          final lastMonthTotal =
              state is DashboardLoaded ? state.lastMonthTotal : 0.0;
          final categoryBreakdown = state is DashboardLoaded
              ? state.categoryBreakdown
              : <String, double>{};
          final categories =
              state is DashboardLoaded ? state.categories : <ExpenseCategory>[];

          return RefreshIndicator(
            color: cs.primary,
            backgroundColor: cs.surfaceContainerHighest,
            onRefresh: () async => _reload(),
            child: CustomScrollView(
              slivers: [
                // ── Pinned AppBar with Steam logo (NO FlexibleSpaceBar title overlap) ──
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  surfaceTintColor: Colors.transparent,
                  backgroundColor:
                      Theme.of(context).appBarTheme.backgroundColor,
                  title: const _SteamLogoTitle(),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.settings_outlined,
                          color: cs.onSurfaceVariant),
                      tooltip: 'Settings',
                      onPressed: () =>
                          context.router.push(const SettingsRoute()),
                    ),
                  ],
                ),

                // ── Steam stats header (scrollable — no overlap possible) ──
                SliverToBoxAdapter(
                  child: SlideTransition(
                    position: _headerSlide,
                    child: FadeTransition(
                      opacity: _headerFade,
                      child: _SteamStatsHeader(
                        monthlyTotal: monthlyTotal,
                        lastMonthTotal: lastMonthTotal,
                        expenseCount: expenses.length,
                      ),
                    ),
                  ),
                ),

                // ── Month selector and sorting controls ──
                SliverToBoxAdapter(
                  child: Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Container(
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF243447) : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                    child: Row(
                      children: [
                        // Month selector
                        Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: _showMonthPicker,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_today, 
                                      size: 16, 
                                      color: isDark ? cs.primary : const Color(0xFF1A3A5C)),
                                  const SizedBox(width: 6),
                                  Text(
                                    DateFormat('MMM yyyy').format(_selectedMonth),
                                    style: TextStyle(
                                      color: isDark ? cs.onSurface : const Color(0xFF1A3A5C),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Icon(Icons.arrow_drop_down, 
                                      size: 16, 
                                      color: isDark ? cs.onSurface : const Color(0xFF1A3A5C)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Sort dropdown
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _sortBy,
                              isDense: true,
                              style: TextStyle(
                                color: isDark ? cs.onSurface : const Color(0xFF1A3A5C),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              items: [
                                DropdownMenuItem(value: 'date', child: Text('วันที่')),
                                DropdownMenuItem(value: 'amount', child: Text('จำนวนเงิน')),
                                DropdownMenuItem(value: 'merchant', child: Text('ร้านค้า')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _sortBy = value;
                                    _sortExpenses();
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Sort direction toggle
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _sortDescending = !_sortDescending;
                              _sortExpenses();
                            });
                          },
                          icon: Icon(
                            _sortDescending ? Icons.arrow_downward : Icons.arrow_upward,
                            size: 18,
                            color: isDark ? cs.onSurface : const Color(0xFF1A3A5C),
                          ),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(32, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                      );
                    },
                  ),
                ),

                // ── Loading / Error states ──
                if (state is ExpenseLoading)
                  SliverFillRemaining(
                    child: Center(
                        child: CircularProgressIndicator(color: cs.primary)),
                  )
                else if (state is ExpenseError)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: cs.error),
                          const SizedBox(height: 12),
                          Text(state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: cs.onSurfaceVariant)),
                          const SizedBox(height: 12),
                          FilledButton(
                              onPressed: _reload,
                              child: const Text('ลองอีกครั้ง')),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // ── Category breakdown ──
                  if (categoryBreakdown.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _CategoryBreakdownCard(
                        breakdown: categoryBreakdown,
                        total: monthlyTotal,
                        categories: categories,
                      ),
                    ),

                  // ── Section header ──
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: _SteamSectionHeader(
                        label: 'RECENT EXPENSES',
                        count: expenses.length,
                      ),
                    ),
                  ),

                  // ── Expense list ──
                  expenses.isEmpty
                      ? SliverFillRemaining(
                          child: _EmptyState(
                            onAdd: () => _navigateTo(const CameraRoute()),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.only(bottom: 100),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) => _AnimatedExpenseItem(
                                expense: expenses[i],
                                index: i,
                                listAnimation: _listController,
                                onTap: () => context.router.push(
                                    ExpenseDetailsRoute(
                                        expense: expenses[i])),
                              ),
                              childCount: expenses.length,
                            ),
                          ),
                        ),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: _AnimatedFab(
        onPressed: () => _navigateTo(const CameraRoute()),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Steam Logo Title (AppBar widget)
// ─────────────────────────────────────────────
class _SteamLogoTitle extends StatelessWidget {
  const _SteamLogoTitle();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primary, cs.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.receipt_long_rounded,
              color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'TRACKR',
              style: TextStyle(
                // AppBar bg is always dark (steamDeepNavy / navy), so always use light text
                color: isDark ? cs.primary : Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                height: 1.1,
              ),
            ),
            Text(
              'AI EXPENSE TRACKER',
              style: TextStyle(
                color: isDark ? cs.onSurfaceVariant : Colors.white70,
                fontSize: 7.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                height: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Steam Stats Header
// ─────────────────────────────────────────────
class _SteamStatsHeader extends StatelessWidget {
  final double monthlyTotal;
  final double lastMonthTotal;
  final int expenseCount;

  const _SteamStatsHeader({
    required this.monthlyTotal,
    required this.lastMonthTotal,
    required this.expenseCount,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF171A21), const Color(0xFF1B2838)]
              : [cs.primary, cs.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(
              color: cs.primary.withOpacity(isDark ? 0.25 : 0.4), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month label
          Row(children: [
            Icon(Icons.calendar_month_outlined,
                size: 12,
                color: isDark ? cs.primary.withOpacity(0.75) : const Color(0xFF1A3A5C)),
            const SizedBox(width: 6),
            Text(
              DateFormat('MMMM yyyy', 'en').format(DateTime.now()).toUpperCase(),
              style: TextStyle(
                color: isDark ? cs.primary.withOpacity(0.7) : const Color(0xFF1A3A5C),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ]),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Monthly total
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MONTHLY TOTAL',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF8F98A0)
                            : const Color(0xFF1A3A5C).withOpacity(0.8),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: monthlyTotal),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                      builder: (_, val, __) => Text(
                        '฿${val.toStringAsFixed(0)}',
                        style: TextStyle(
                          // Force readable color in both themes
                          color: isDark ? cs.primary : const Color(0xFF1A3A5C),
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          height: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Last month comparison (always show)
                    if (true)
                      Row(
                        children: [
                          Text(
                            'เดือนที่แล้ว: ฿${lastMonthTotal.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Change indicator
                          Icon(
                            monthlyTotal >= lastMonthTotal
                                ? Icons.trending_up
                                : Icons.trending_down,
                            size: 14,
                            color: monthlyTotal >= lastMonthTotal
                                ? Colors.red
                                : Colors.green,
                          ),
                          Text(
                            '${((monthlyTotal - lastMonthTotal) / lastMonthTotal * 100).abs().toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: monthlyTotal >= lastMonthTotal
                                  ? Colors.red
                                  : Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // Items counter chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2A475E).withOpacity(0.5)
                      : Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2A475E)
                        : Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Column(children: [
                  Text(
                    '$expenseCount',
                    style: TextStyle(
                      color: isDark ? cs.primary : Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ITEMS',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF8F98A0)
                          : Colors.white.withOpacity(0.7),
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Steam-style accent divider
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                cs.primary,
                cs.primary.withOpacity(0.3),
                Colors.transparent,
              ]),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Steam Section Header
// ─────────────────────────────────────────────
class _SteamSectionHeader extends StatelessWidget {
  final String label;
  final int count;

  const _SteamSectionHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(children: [
      Container(
        width: 3,
        height: 15,
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: TextStyle(
          color: cs.primary,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.8,
        ),
      ),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: cs.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: cs.primary.withOpacity(0.3)),
        ),
        child: Text(
          '$count',
          style: TextStyle(
              color: cs.primary, fontSize: 10, fontWeight: FontWeight.w700),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              cs.outline.withOpacity(0.4),
              Colors.transparent,
            ]),
          ),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────
// Category Breakdown Card
// ─────────────────────────────────────────────
class _CategoryBreakdownCard extends StatelessWidget {
  final Map<String, double> breakdown;
  final double total;
  final List<ExpenseCategory> categories;

  const _CategoryBreakdownCard({
    required this.breakdown,
    required this.total,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Sort by amount descending so biggest spends show first
    final sorted = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF243447) : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent bar
            Container(width: 4, color: cs.primary),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.bar_chart_rounded, size: 15, color: cs.primary),
                      const SizedBox(width: 8),
                      Text(
                        'SPENDING BREAKDOWN',
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 14),
                    ...sorted.take(5).map((e) => _CategoryBar(
                          categoryId: e.key,
                          amount: e.value,
                          total: total,
                          categories: categories,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final String categoryId;
  final double amount;
  final double total;
  final List<ExpenseCategory> categories;

  const _CategoryBar({
    required this.categoryId,
    required this.amount,
    required this.total,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (amount / total).clamp(0.0, 1.0) : 0.0;
    final cat = categories.where((c) => c.id == categoryId).firstOrNull;
    final color =
        cat != null ? Color(cat.color) : _categoryColor(categoryId);
    final name = cat?.name ?? categoryId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(name,
                    style: const TextStyle(fontSize: 12)),
              ]),
              Text('฿${NumberFormat('#,##0').format(amount)}',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: pct),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (_, val, __) => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: val,
                backgroundColor: color.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Color _categoryColor(String id) {
    const map = {
      'food': Color(0xFFFF5722),
      'transport': Color(0xFF2196F3),
      'shopping': Color(0xFF9C27B0),
      'entertainment': Color(0xFFE91E63),
      'health': Color(0xFF4CAF50),
      'education': Color(0xFF009688),
      'utilities': Color(0xFFFF9800),
    };
    return map[id] ?? const Color(0xFF607D8B);
  }
}

// ─────────────────────────────────────────────
// Animated Expense List Item
// ─────────────────────────────────────────────
class _AnimatedExpenseItem extends StatelessWidget {
  final Expense expense;
  final int index;
  final AnimationController listAnimation;
  final VoidCallback onTap;

  const _AnimatedExpenseItem({
    required this.expense,
    required this.index,
    required this.listAnimation,
    required this.onTap,
  });

  static const _colors = {
    'food': Color(0xFFFF5722),
    'transport': Color(0xFF2196F3),
    'shopping': Color(0xFF9C27B0),
    'entertainment': Color(0xFFE91E63),
    'health': Color(0xFF4CAF50),
    'education': Color(0xFF009688),
    'utilities': Color(0xFFFF9800),
  };

  static const _icons = {
    'food': Icons.restaurant,
    'transport': Icons.directions_car,
    'shopping': Icons.shopping_cart,
    'entertainment': Icons.movie,
    'health': Icons.local_hospital,
    'education': Icons.school,
    'utilities': Icons.power,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final delay = (index * 0.07).clamp(0.0, 0.6);
    final end = (delay + 0.4).clamp(0.0, 1.0);

    final slideAnim = Tween<Offset>(begin: const Offset(0.15, 0), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: listAnimation,
            curve: Interval(delay, end, curve: Curves.easeOutCubic)));
    final fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: listAnimation,
            curve: Interval(delay, end, curve: Curves.easeOut)));

    final catColor = _colors[expense.category] ?? const Color(0xFF607D8B);
    final catIcon  = _icons[expense.category]  ?? Icons.more_horiz;

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Hero(
            tag: 'expense-${expense.id}',
            child: Material(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left category accent bar
                        Container(width: 4, color: catColor),
                        // Content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                // Category icon
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: catColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(catIcon, color: catColor, size: 20),
                                ),
                                const SizedBox(width: 12),
                                // Name + date
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        expense.merchantName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: cs.onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        DateFormat('d MMM yyyy').format(expense.date),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Amount + category chip
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '฿${NumberFormat('#,##0.00').format(expense.amount)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: cs.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: catColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: catColor.withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        expense.category,
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: catColor,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.outline.withOpacity(0.3)),
            ),
            child: Icon(Icons.receipt_long_rounded,
                size: 44, color: cs.primary.withOpacity(0.4)),
          ),
          const SizedBox(height: 20),
          Text(
            'NO EXPENSES YET',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 1.5,
              color: cs.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Scan a receipt to get started',
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.document_scanner_outlined, size: 18),
            label: const Text('SCAN RECEIPT'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Animated FAB
// ─────────────────────────────────────────────
class _AnimatedFab extends StatefulWidget {
  final VoidCallback onPressed;
  const _AnimatedFab({required this.onPressed});

  @override
  State<_AnimatedFab> createState() => _AnimatedFabState();
}

class _AnimatedFabState extends State<_AnimatedFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1, end: 0.92).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: FloatingActionButton.extended(
          onPressed: null,
          icon: const Icon(Icons.document_scanner),
          label: const Text('สแกนใบเสร็จ'),
        ),
      ),
    );
  }
}
