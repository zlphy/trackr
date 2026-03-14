import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/expense.dart';
import '../../../config/injection.dart';
import '../../bloc/expense/expense_bloc.dart';
import '../../routes/app_router.dart';

@RoutePage()
class ExpenseDetailsPage extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailsPage({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ExpenseBloc>(),
      child: _ExpenseDetailsView(expense: expense),
    );
  }
}

class _ExpenseDetailsView extends StatefulWidget {
  final Expense expense;
  const _ExpenseDetailsView({required this.expense});

  @override
  State<_ExpenseDetailsView> createState() => _ExpenseDetailsViewState();
}

class _ExpenseDetailsViewState extends State<_ExpenseDetailsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  Expense get expense => widget.expense;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Animation<double> _fadeAt(double start, double end) =>
      Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _ctrl, curve: Interval(start, end)));

  Animation<Offset> _slideAt(double start, double end) =>
      Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(
              parent: _ctrl,
              curve: Interval(start, end, curve: Curves.easeOutCubic)));

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final catColor = _getCategoryColor(expense.category);

    return BlocListener<ExpenseBloc, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseLoaded) {
          context.router.popUntilRoot();
        } else if (state is ExpenseError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: cs.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // ── SliverAppBar with Hero image ──
            SliverAppBar(
              expandedHeight: expense.receiptImagePath != null ? 240 : 160,
              pinned: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'แก้ไข',
                  onPressed: () => context.router.push(ExpenseFormRoute(
                    receiptImagePath: expense.receiptImagePath,
                    merchantName: expense.merchantName,
                    amount: expense.amount,
                    extractedText: expense.receiptText,
                    existingExpense: expense,
                  )),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  expense.merchantName,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                background: Hero(
                  tag: 'expense-${expense.id}',
                  child: expense.receiptImagePath != null
                      ? Image.file(
                          File(expense.receiptImagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _categoryHeader(catColor),
                        )
                      : _categoryHeader(catColor),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Animated amount card ──
                    FadeTransition(
                      opacity: _fadeAt(0.0, 0.4),
                      child: SlideTransition(
                        position: _slideAt(0.0, 0.4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [catColor, catColor.withOpacity(0.7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: expense.amount),
                                duration: const Duration(milliseconds: 900),
                                curve: Curves.easeOutCubic,
                                builder: (_, val, __) => Text(
                                  '฿${NumberFormat('#,##0.00').format(val)}',
                                  style: const TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getCategoryNameThai(expense.category),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Info card ──
                    FadeTransition(
                      opacity: _fadeAt(0.2, 0.65),
                      child: SlideTransition(
                        position: _slideAt(0.2, 0.65),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                  color: cs.outline.withOpacity(0.2))),
                          child: Column(children: [
                            _infoRow(
                                context,
                                Icons.store_outlined,
                                'ร้านค้า',
                                expense.merchantName,
                                catColor),
                            _divider(cs),
                            _infoRow(
                                context,
                                Icons.calendar_today_outlined,
                                'วันที่',
                                DateFormat('d MMMM yyyy').format(expense.date),
                                catColor),
                            if (expense.notes != null &&
                                expense.notes!.isNotEmpty) ...[
                              _divider(cs),
                              _infoRow(context, Icons.note_outlined,
                                  'หมายเหตุ', expense.notes!, catColor),
                            ],
                          ]),
                        ),
                      ),
                    ),

                    // ── Receipt text ──
                    if (expense.receiptText != null &&
                        expense.receiptText!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      FadeTransition(
                        opacity: _fadeAt(0.4, 0.8),
                        child: SlideTransition(
                          position: _slideAt(0.4, 0.8),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                    color: cs.outline.withOpacity(0.2))),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              title: const Text('ข้อความจากใบเสร็จ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              leading: Icon(Icons.receipt_outlined,
                                  color: catColor),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 0, 16, 16),
                                  child: Text(expense.receiptText!,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ── Delete button ──
                    FadeTransition(
                      opacity: _fadeAt(0.5, 0.9),
                      child: SlideTransition(
                        position: _slideAt(0.5, 0.9),
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmDelete(context),
                          icon: Icon(Icons.delete_outline, color: cs.error),
                          label: Text('ลบรายการนี้',
                              style: TextStyle(color: cs.error)),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            side: BorderSide(color: cs.error),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryHeader(Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(_getCategoryIcon(expense.category),
            size: 72, color: Colors.white70),
      ),
    );
  }

  Widget _divider(ColorScheme cs) =>
      Divider(height: 1, indent: 56, color: cs.outline.withOpacity(0.15));

  Widget _infoRow(BuildContext context, IconData icon, String label,
      String value, Color accent) {
    return ListTile(
      dense: true,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: accent),
      ),
      title: Text(label,
          style: const TextStyle(fontSize: 11, color: Colors.grey)),
      subtitle: Text(value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ยืนยันการลบ'),
        content: Text(
            'ต้องการลบรายการ "${expense.merchantName}" ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ExpenseBloc>().add(DeleteExpense(expense.id));
            },
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  static Color _getCategoryColor(String id) {
    const m = {
      'food': Color(0xFFFF5722),
      'transport': Color(0xFF2196F3),
      'shopping': Color(0xFF9C27B0),
      'entertainment': Color(0xFFE91E63),
      'health': Color(0xFF4CAF50),
      'education': Color(0xFF009688),
      'utilities': Color(0xFFFF9800),
    };
    return m[id] ?? const Color(0xFF607D8B);
  }

  static IconData _getCategoryIcon(String id) {
    const m = {
      'food': Icons.restaurant,
      'transport': Icons.directions_car,
      'shopping': Icons.shopping_cart,
      'entertainment': Icons.movie,
      'health': Icons.local_hospital,
      'education': Icons.school,
      'utilities': Icons.power,
    };
    return m[id] ?? Icons.more_horiz;
  }

  static String _getCategoryNameThai(String id) {
    const m = {
      'food': 'อาหาร',
      'transport': 'การเดินทาง',
      'shopping': 'ช้อปปิ้ง',
      'entertainment': 'บันเทิง',
      'health': 'สุขภาพ',
      'education': 'การศึกษา',
      'utilities': 'สาธารณูปโภค',
    };
    return m[id] ?? 'อื่นๆ';
  }
}
