import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../../../config/injection.dart';
import '../../../data/datasources/local/app_database.dart';
import '../../bloc/settings/settings_bloc.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _apiKeyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureApiKey = true;
  bool _isSeeding = false;
  bool _isResetting = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<SettingsBloc>().state;
    _apiKeyController.text = state.apiKey;
    context.read<SettingsBloc>().add(const LoadSettings());
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งค่า'),
        centerTitle: true,
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          _apiKeyController.text = state.apiKey;
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Theme Section
                  _buildSectionHeader(context, 'ธีม'),
                  const SizedBox(height: 8),
                  Card(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: state.themeMode == ThemeMode.dark
                            ? Colors.grey.shade800
                            : Colors.white,
                      ),
                      child: SwitchListTile(
                        title: const Text('โหมดมืด'),
                        subtitle: Text(
                          state.themeMode == ThemeMode.dark
                              ? 'เปิดใช้งานโหมดมืด'
                              : 'เปิดใช้งานโหมดสว่าง',
                        ),
                        secondary: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            state.themeMode == ThemeMode.dark
                                ? Icons.dark_mode
                                : Icons.light_mode,
                            key: ValueKey(state.themeMode),
                          ),
                        ),
                        value: state.themeMode == ThemeMode.dark,
                        onChanged: (_) {
                          context
                              .read<SettingsBloc>()
                              .add(const ToggleTheme());
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // API Key Section
                  _buildSectionHeader(context, 'Gemini API Key'),
                  const SizedBox(height: 8),
                  Text(
                    'ใส่ API Key จาก Google AI Studio เพื่อเปิดใช้งานการจัดหมวดหมู่ด้วย AI',
                    style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _apiKeyController,
                    obscureText: _obscureApiKey,
                    decoration: InputDecoration(
                      labelText: 'Gemini API Key',
                      hintText: 'AIzaSy...',
                      prefixIcon: const Icon(Icons.key),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureApiKey
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () =>
                            setState(() => _obscureApiKey = !_obscureApiKey),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'กรุณากรอก API Key';
                      }
                      if (v.length < 10) {
                        return 'API Key ไม่ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saveApiKey,
                          icon: const Icon(Icons.save, size: 18),
                          label: const Text('บันทึก'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: _clearApiKey,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('ล้างค่า'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Sample Data Section
                  _buildSectionHeader(context, 'SAMPLE DATA'),
                  const SizedBox(height: 8),
                  Text(
                    'โหลดข้อมูลตัวอย่าง 40 รายการจากร้านค้าทั่วไป (food, transport, shopping ฯลฯ)',
                    style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: (_isSeeding || _isResetting) ? null : _loadSampleData,
                          icon: _isSeeding
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.dataset_outlined, size: 18),
                          label: Text(_isSeeding ? 'กำลังโหลด...' : 'Load 40 รายการ'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: (_isSeeding || _isResetting) ? null : _resetSampleData,
                        icon: _isResetting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.delete_sweep_outlined, size: 18),
                        label: Text(_isResetting ? 'กำลังลบ...' : 'Reset'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // About Section
                  _buildSectionHeader(context, 'เกี่ยวกับ'),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Receipt & Expense Tracker',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'เวอร์ชัน 1.0.0',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'แอปจัดการรายรับรายจ่ายด้วย AI วิเคราะห์ใบเสร็จอัตโนมัติ',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 0.5,
      ),
    );
  }

  void _saveApiKey() {
    if (_formKey.currentState!.validate()) {
      context
          .read<SettingsBloc>()
          .add(SaveApiKey(_apiKeyController.text.trim()));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('บันทึก API Key สำเร็จ'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _loadSampleData() async {
    setState(() => _isSeeding = true);
    try {
      await sl<AppDatabase>().seedSampleExpenses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('โหลดข้อมูลตัวอย่าง 40 รายการสำเร็จ'),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  Future<void> _resetSampleData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text(
            'ต้องการลบข้อมูลตัวอย่าง 40 รายการ (seed-001 ถึง seed-040) ใช่หรือไม่?\nรายการที่คุณบันทึกเองจะไม่ถูกลบ'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('ยกเลิก')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('ลบ')),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _isResetting = true);
    try {
      await sl<AppDatabase>().deleteSampleExpenses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('ลบข้อมูลตัวอย่างสำเร็จ'),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResetting = false);
    }
  }

  void _clearApiKey() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ล้าง API Key'),
        content: const Text('ต้องการลบ Gemini API Key ออกจากแอปใช่หรือไม่?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('ยกเลิก')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('ล้างค่า')),
        ],
      ),
    ).then((confirm) {
      if (confirm != true || !mounted) return;
      context.read<SettingsBloc>().add(const SaveApiKey(''));
      _apiKeyController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ล้าง API Key สำเร็จ')),
      );
    });
  }
}
