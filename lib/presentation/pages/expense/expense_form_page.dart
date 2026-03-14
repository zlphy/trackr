import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:uuid/uuid.dart';
import '../../../config/injection.dart';
import '../../../domain/entities/expense.dart';
import '../../../domain/entities/expense_category.dart';
import '../../bloc/expense/expense_bloc.dart';

@RoutePage()
class ExpenseFormPage extends StatefulWidget {
  final String? receiptImagePath;
  final String? merchantName;
  final double? amount;
  final String? extractedText;
  final Expense? existingExpense;

  const ExpenseFormPage({
    super.key,
    this.receiptImagePath,
    this.merchantName,
    this.amount,
    this.extractedText,
    this.existingExpense,
  });

  @override
  State<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

// Outer shell provides BLoC so initState can access it safely
class _ExpenseFormShell extends StatelessWidget {
  final ExpenseFormPage widget;
  const _ExpenseFormShell(this.widget);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ExpenseBloc>(),
      child: _ExpenseFormBody(widget: widget),
    );
  }
}

class _ExpenseFormPageState extends State<ExpenseFormPage> {
  @override
  Widget build(BuildContext context) => _ExpenseFormShell(widget);
}

class _ExpenseFormBody extends StatefulWidget {
  final ExpenseFormPage widget;
  const _ExpenseFormBody({required this.widget});

  @override
  State<_ExpenseFormBody> createState() => _ExpenseFormBodyState();
}

class _ExpenseFormBodyState extends State<_ExpenseFormBody>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCategory = 'food';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isCategorizing = false;
  bool _showAiResult = false;
  String _aiReasoning = '';
  List<ExpenseCategory> _categories = [];

  late AnimationController _staggerCtrl;

  ExpenseFormPage get _page => widget.widget;
  bool get _isEditMode => _page.existingExpense != null;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    final existing = _page.existingExpense;
    if (existing != null) {
      _merchantController.text = existing.merchantName;
      _amountController.text = existing.amount.toStringAsFixed(2);
      _notesController.text = existing.notes ?? '';
      _selectedCategory = existing.category;
      _selectedDate = existing.date;
    } else {
      if (_page.merchantName != null) {
        _merchantController.text = _page.merchantName!;
      }
      if (_page.amount != null && _page.amount! > 0) {
        _amountController.text = _page.amount!.toStringAsFixed(2);
      }
    }
    context.read<ExpenseBloc>().add(LoadCategories());
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    _merchantController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Animation<Offset> _slideAt(int step) {
    final start = (step * 0.12).clamp(0.0, 0.8);
    final end = (start + 0.35).clamp(0.0, 1.0);
    return Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _staggerCtrl,
            curve: Interval(start, end, curve: Curves.easeOutCubic)));
  }

  Animation<double> _fadeAt(int step) {
    final start = (step * 0.12).clamp(0.0, 0.8);
    final end = (start + 0.35).clamp(0.0, 1.0);
    return Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _staggerCtrl,
        curve: Interval(start, end, curve: Curves.easeOut)));
  }

  Widget _animated(int step, Widget child) {
    return FadeTransition(
      opacity: _fadeAt(step),
      child: SlideTransition(position: _slideAt(step), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dateLabel =
        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'แก้ไขรายการ' : 'เพิ่มค่าใช้จ่าย'),
        centerTitle: true,
      ),
      body: BlocListener<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is CategoriesLoaded) {
            setState(() => _categories = state.categories);
          } else if (state is ExpenseCategorized) {
            setState(() {
              _selectedCategory = state.category;
              _isCategorizing = false;
              _showAiResult = true;
            });
          } else if (state is ExpenseLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isEditMode
                    ? 'อัปเดตรายการสำเร็จ'
                    : 'บันทึกรายการสำเร็จ'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Return to dashboard after save
            int popCount = 0;
            while (context.router.canPop() && popCount < 5) {
              context.router.pop();
              popCount++;
            }
          } else if (state is ExpenseError) {
            setState(() {
              _isLoading = false;
              _isCategorizing = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: cs.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Receipt image preview
                if (_page.receiptImagePath != null)
                  _animated(
                    0,
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 160,
                        child: Image.file(
                          File(_page.receiptImagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.broken_image, size: 48)),
                        ),
                      ),
                    ),
                  ),
                if (_page.receiptImagePath != null)
                  const SizedBox(height: 16),

                // ── Merchant + Amount card ──
                _animated(
                  1,
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                            color: cs.outline.withOpacity(0.2))),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _merchantController,
                            decoration: const InputDecoration(
                              labelText: 'ชื่อร้านค้า *',
                              prefixIcon: Icon(Icons.store_outlined),
                              border: InputBorder.none,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'กรุณากรอกชื่อร้านค้า';
                              }
                              if (v.trim().length < 2) {
                                return 'ชื่อร้านค้าต้องมีอย่างน้อย 2 ตัวอักษร';
                              }
                              return null;
                            },
                          ),
                          Divider(
                              height: 1,
                              color: cs.outline.withOpacity(0.15)),
                          TextFormField(
                            controller: _amountController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'จำนวนเงิน (บาท) *',
                              prefixIcon:
                                  Icon(Icons.payments_outlined),
                              prefixText: '฿ ',
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'กรุณากรอกจำนวนเงิน';
                              }
                              final p = double.tryParse(v.trim());
                              if (p == null) {
                                return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                              }
                              if (p <= 0) {
                                return 'จำนวนเงินต้องมากกว่า 0';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Date + Category card ──
                _animated(
                  2,
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                            color: cs.outline.withOpacity(0.2))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(12),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'วันที่',
                                prefixIcon:
                                    Icon(Icons.calendar_today_outlined),
                                border: InputBorder.none,
                              ),
                              child: Text(dateLabel),
                            ),
                          ),
                          Divider(
                              height: 1,
                              color: cs.outline.withOpacity(0.15)),
                          DropdownButtonFormField<String>(
                            value: _categories
                                    .any((c) => c.id == _selectedCategory)
                                ? _selectedCategory
                                : (_categories.isNotEmpty
                                    ? _categories.first.id
                                    : null),
                            decoration: const InputDecoration(
                              labelText: 'หมวดหมู่',
                              prefixIcon:
                                  Icon(Icons.category_outlined),
                              border: InputBorder.none,
                            ),
                            items: _categories.map((cat) {
                              return DropdownMenuItem(
                                value: cat.id,
                                child: Row(children: [
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: Color(cat.color),
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                    child: Icon(_mapIcon(cat.icon),
                                        color: Colors.white, size: 11),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(cat.name),
                                ]),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _selectedCategory = v);
                              }
                            },
                            validator: (v) =>
                                v == null ? 'กรุณาเลือกหมวดหมู่' : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── AI categorize ──
                if (_page.extractedText != null ||
                    _page.merchantName != null)
                  _animated(
                    3,
                    OutlinedButton.icon(
                      onPressed: _isCategorizing ? null : _categorizeWithAI,
                      icon: _isCategorizing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.auto_awesome, size: 18),
                      label: Text(_isCategorizing
                          ? 'กำลังวิเคราะห์...'
                          : 'จัดหมวดหมู่ด้วย AI'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                // AI result badge
                AnimatedSize(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  child: _showAiResult
                      ? AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 400),
                          child: Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'AI แนะนำ: $_selectedCategory'
                                  '${_aiReasoning.isNotEmpty ? '\n$_aiReasoning' : ''}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ]),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 12),

                // ── Notes + extracted text card ──
                _animated(
                  4,
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                            color: cs.outline.withOpacity(0.2))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'บันทึกเพิ่มเติม (ไม่จำเป็น)',
                              prefixIcon: Icon(Icons.note_outlined),
                              alignLabelWithHint: true,
                              border: InputBorder.none,
                            ),
                          ),
                          if (_page.extractedText != null &&
                              _page.extractedText!.isNotEmpty) ...[
                            Divider(
                                height: 1,
                                color: cs.outline.withOpacity(0.15)),
                            ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              title: const Text('ข้อความจากใบเสร็จ',
                                  style: TextStyle(fontSize: 13)),
                              leading: const Icon(
                                  Icons.receipt_outlined,
                                  size: 18),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0, 0, 0, 12),
                                  child: Text(_page.extractedText!,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey)),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Save button ──
                _animated(
                  5,
                  _SaveButton(
                    isLoading: _isLoading,
                    isEditMode: _isEditMode,
                    onPressed: _saveExpense,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _categorizeWithAI() {
    final merchant = _merchantController.text.trim();
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0.0;
    setState(() {
      _isCategorizing = true;
      _showAiResult = false;
    });
    context.read<ExpenseBloc>().add(CategorizeExpense(
          receiptText: _page.extractedText ?? merchant,
          amount: amount,
          merchantName: merchant.isEmpty ? 'Unknown' : merchant,
        ));
  }

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final now = DateTime.now();
    final expense = Expense(
      id: _isEditMode
          ? _page.existingExpense!.id
          : const Uuid().v4(),
      merchantName: _merchantController.text.trim(),
      category: _selectedCategory,
      amount: double.parse(_amountController.text.trim()),
      date: _selectedDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      receiptImagePath: _page.receiptImagePath ??
          _page.existingExpense?.receiptImagePath,
      receiptText: _page.extractedText ??
          _page.existingExpense?.receiptText,
      createdAt: _isEditMode
          ? _page.existingExpense!.createdAt
          : now,
      updatedAt: now,
    );

    if (_isEditMode) {
      context.read<ExpenseBloc>().add(UpdateExpense(expense));
    } else {
      context.read<ExpenseBloc>().add(AddExpense(expense));
    }
  }

  IconData _mapIcon(String? name) {
    switch (name) {
      case 'restaurant':     return Icons.restaurant;
      case 'directions_car': return Icons.directions_car;
      case 'shopping_cart':  return Icons.shopping_cart;
      case 'movie':          return Icons.movie;
      case 'local_hospital': return Icons.local_hospital;
      case 'school':         return Icons.school;
      case 'power':          return Icons.power;
      default:               return Icons.more_horiz;
    }
  }
}

// ─────────────────────────────────────────────
// Animated Save Button
// ─────────────────────────────────────────────
class _SaveButton extends StatefulWidget {
  final bool isLoading;
  final bool isEditMode;
  final VoidCallback onPressed;

  const _SaveButton({
    required this.isLoading,
    required this.isEditMode,
    required this.onPressed,
  });

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.94)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
        if (!widget.isLoading) widget.onPressed();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          height: 54,
          child: FilledButton.icon(
            onPressed: widget.isLoading ? null : widget.onPressed,
            icon: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Icon(widget.isEditMode ? Icons.check_rounded : Icons.save_rounded),
            label: Text(
              widget.isEditMode ? 'อัปเดต' : 'บันทึก',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ),
    );
  }
}
