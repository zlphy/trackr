# TRACKR — AI Receipt & Expense Tracker

แอปพลิเคชัน Flutter สำหรับติดตามค่าใช้จ่ายด้วย AI โดยใช้กล้องสแกนใบเสร็จ, OCR อ่านข้อความ และ Gemini LLM จัดหมวดหมู่อัตโนมัติ — บันทึกข้อมูลในเครื่องแบบ Offline-First

---

## ภาพรวมแอปพลิเคชัน

| หน้าจอ | คำอธิบาย |
|---|---|
| **Dashboard** | แสดงยอดรวมรายเดือน, กราฟสัดส่วนหมวดหมู่, รายการล่าสุด |
| **Receipt Scanner** | สแกนใบเสร็จผ่านกล้อง → OCR ดึงชื่อร้านและจำนวนเงิน |
| **Expense Form** | เพิ่ม/แก้ไขรายการ พร้อม Validation และ AI จัดหมวดหมู่ |
| **Expense Details** | ดูรายละเอียดพร้อม Hero animation |
| **Settings** | ตั้งค่า Gemini API Key, เปลี่ยน Theme, โหลดข้อมูลตัวอย่าง |

---

## การตรวจสอบตามเกณฑ์การประเมิน

### ข้อ 1 — Architecture & State Management

**Clean Architecture** แบ่งชั้นชัดเจน 3 ระดับ:

```
lib/
├── domain/          # Entities, Repository interfaces, Use Cases
│   ├── entities/    # Expense, ExpenseCategory
│   ├── repositories/
│   └── usecases/    # AddExpenseUseCase, GetExpensesUseCase, ...
├── data/            # Repository implementations, DataSources, Models
│   ├── datasources/local/   # Drift DB, Hive cache
│   ├── datasources/remote/  # Gemini LLM datasource
│   ├── models/              # json_serializable models
│   └── repositories/        # ExpenseRepositoryImpl
└── presentation/    # BLoC, Pages, Routes, Theme
    ├── bloc/        # ExpenseBloc, SettingsBloc
    └── pages/
```

**Dependency Injection** ด้วย `get_it` — ไฟล์ `lib/config/injection.dart`:
- ลงทะเบียน `AppDatabase`, `ExpenseLocalDataSource`, `HiveCacheDataSource`, `LLMRemoteDataSource`, `ExpenseRepository`, Use Cases และ BLoC ทุกตัว
- ใช้ `sl<T>()` เรียกใช้ทั่วทั้งแอป

**State Management** ด้วย `flutter_bloc` (BLoC pattern):
- `ExpenseBloc` — จัดการ state: `ExpenseLoading`, `DashboardLoaded`, `ExpenseLoaded`, `ExpenseError`, `ExpenseCategorized`
- `SettingsBloc` — จัดการ theme mode และ API key

---

### ข้อ 2 — Offline-First & Local Storage

**ฐานข้อมูลหลัก: Drift (SQLite)**
- ไฟล์: `lib/data/datasources/local/app_database.dart`
- ตาราง: `Expenses`, `ExpenseCategories`
- รองรับ CRUD ทั้งหมด, query ตามช่วงวันที่และหมวดหมู่
- แอปทำงานได้สมบูรณ์โดยไม่ต้องเชื่อมต่ออินเทอร์เน็ต

**Key-Value Storage:**
- `SharedPreferences` — เก็บ Gemini API Key และ Theme mode (`lib/presentation/bloc/settings/settings_bloc.dart`)
- `Hive` — Cache ผลลัพธ์การจัดหมวดหมู่จาก LLM (TTL 24 ชั่วโมง) เพื่อลด API calls (`lib/data/datasources/local/hive_cache_datasource.dart`)

---

### ข้อ 3 — Networking & API

**Dio + Interceptors** — ไฟล์: `lib/core/network/gemini_client.dart`

```dart
// Request Interceptor: ตรวจสอบ API key ก่อนส่ง request
onRequest: (options, handler) {
  final apiKey = _prefs.getString(AppConstants.prefKeyApiKey) ?? '';
  if (apiKey.isEmpty) {
    handler.reject(...); // ปฏิเสธก่อนถึง network
    return;
  }
  options.queryParameters['key'] = apiKey;
  handler.next(options);
}
```

**Error Handling** ครอบคลุม:
- `connectionTimeout` / `receiveTimeout` → ข้อความ timeout
- `400` → API key ไม่ถูกต้อง → แนะนำให้ไปตั้งค่า
- `401/403` → Unauthorized
- `429` → Rate limit
- ไม่มีอินเทอร์เน็ต → Network error

**json_serializable** — ไฟล์: `lib/data/models/llm_response_model.dart`
- `GeminiRequestModel`, `GeminiResponseModel` ใช้ `@JsonSerializable()` แปลง JSON อัตโนมัติ

---

### ข้อ 4 — AI & Machine Learning Integration

**On-device ML: Google ML Kit Text Recognition**
- ไฟล์: `lib/core/services/ml_kit_service.dart`
- สแกนรูปใบเสร็จ → ดึงข้อความทั้งหมด → parse ชื่อร้านและยอดเงิน
- ทำงาน **บนเครื่องโดยไม่ต้องส่งรูปออก** — Privacy-first

**Cloud LLM: Google Gemini 1.5 Flash**
- ไฟล์: `lib/data/datasources/remote/llm_remote_datasource.dart`
- ส่ง prompt พร้อมชื่อร้าน, จำนวนเงิน, ข้อความจากใบเสร็จ → รับ JSON กลับ `{"category": "...", "reasoning": "..."}`
- จัดหมวดหมู่ใน 8 หมวด: food, transport, shopping, entertainment, health, education, utilities, other
- มี **fallback keyword matching** เมื่อ API ไม่พร้อมใช้งาน
- ผลลัพธ์ถูก **cache ด้วย Hive** 24 ชั่วโมงเพื่อประหยัด API quota

---

### ข้อ 5 — UI, UX & Routing

**auto_route** — ไฟล์: `lib/presentation/routes/app_router.dart`
- `DashboardRoute`, `CameraRoute`, `ExpenseFormRoute(receiptImagePath, merchantName, amount, extractedText, existingExpense)`, `ExpenseDetailsRoute(expense)`, `SettingsRoute`
- ส่งพารามิเตอร์ผ่าน Route constructor ทุกหน้า
- Transition animations: `slideBottom` สำหรับ camera, `slideRight` สำหรับ form

**Form Validation** ด้วย `GlobalKey<FormState>` — `lib/presentation/pages/expense/expense_form_page.dart`:
- ตรวจสอบ: ชื่อร้านค้า (min 2 ตัวอักษร), จำนวนเงิน (ตัวเลข > 0), หมวดหมู่ (required)

**Animations (มากกว่า 2 จุด):**

| ประเภท | ตำแหน่ง | รายละเอียด |
|---|---|---|
| **Implicit** | Dashboard stats | `TweenAnimationBuilder` นับยอดเงินจาก 0 ขึ้นไปยอดจริง |
| **Implicit** | Category bars | `TweenAnimationBuilder` ขยาย progress bar |
| **Explicit** | Dashboard list | `AnimationController` + staggered fade+slide ทุก item |
| **Explicit** | Form fields | `AnimationController` stagger entrance ทุก field |
| **Explicit** | Header | `SlideTransition` + `FadeTransition` slide-in จากบน |
| **Hero** | Expense details | `Hero` widget บน amount/merchant ระหว่างหน้า |
| **Explicit** | FAB | Pulse animation บนปุ่มสแกน |
| **Explicit** | Camera | Rotating scan-line + pulse ring ขณะประมวลผล |

---

### ข้อ 6 — Testing

**รัน tests ทั้งหมด:**

```bash
flutter test test/
```

| ไฟล์ | ประเภท | จำนวน | รายละเอียด |
|---|---|---|---|
| `test/unit/add_expense_usecase_test.dart` | Unit (Mocked) | 6 | ทดสอบ AddExpenseUseCase, DeleteExpenseUseCase, UpdateExpenseUseCase ด้วย Mockito |
| `test/unit/expense_bloc_test.dart` | Unit (BLoC) | 7 | ทดสอบ state transitions ทุก event ของ ExpenseBloc |
| `test/widget/expense_form_widget_test.dart` | Widget | 6 | ทดสอบ Form validation ทุกกรณี (empty, short, invalid amount, zero) |
| `test/widget_test.dart` | Widget (Smoke) | 1 | ทดสอบแอปเริ่มต้นได้ |
| `integration_test/app_test.dart` | Integration | 5 | E2E ทดสอบ navigation, form submit, delete (ต้องใช้อุปกรณ์จริง/emulator) |
| **รวม** | | **25** | |

---

## 🚀 Additional Features (Beyond Requirements)

### Multi-language Support
- **Thai UI** - Complete Thai language interface
- English fallback for technical terms
- Localized date formatting (Thai months)

### Advanced Currency Features
- **Multi-currency Detection** - Automatically detects USD, EUR, GBP, JPY, CNY, SGD, MYR, KRW, HKD, AUD
- **Real-time Conversion** - Converts detected currencies to Thai Baht (THB)
- **Smart Default** - Defaults to USD when no currency symbol is found
- **Display Format** - Shows "USD 25.97 → ฿934.92" conversion info

### Enhanced OCR Parsing
- **Two-pass Total Detection** - Prioritizes lines with "total" keywords first
- **Smart Filtering** - Excludes item quantities, dates, and times from amount detection
- **Range Validation** - Validates extracted amounts (0.01 - 9999.99)
- **Null Safety** - Robust error handling for malformed text

### Month Selection & Sorting
- **Historical Data View** - Select any month to view expenses
- **Multiple Sort Options** - Sort by date, amount, or merchant name
- **Bidirectional Sorting** - Ascending/descending toggle
- **Month Comparison** - Shows previous month total with trend indicator

### Enhanced UI/UX
- **Light/Dark Theme** - Complete theme system with proper contrast
- **Steam-inspired Design** - Gaming aesthetic with gradients and animations
- **Responsive Layout** - Adapts to different screen sizes
- **Micro-interactions** - Button animations, loading states, transitions

### Data Management
- **Sample Data Seeding** - 40 pre-loaded sample expenses for testing
- **Data Reset** - Clear sample data while preserving user entries
- **API Key Management** - Secure storage and easy key updates
- **Offline-first** - Full functionality without internet

### Error Handling & UX
- **User-friendly Errors** - Clear error messages in Thai
- **Auto-retry Logic** - Handles network failures gracefully
- **Loading States** - Proper loading indicators throughout
- **Form Validation** - Real-time validation with helpful messages

### Performance Optimizations
- **Hive Caching** - Caches AI responses to reduce API calls
- **Efficient Database Queries** - Optimized Drift queries
- **Lazy Loading** - Loads data progressively
- **Memory Management** - Proper disposal of controllers and resources

---

## Tech Stack

| ด้าน | แพ็กเกจ | เวอร์ชัน |
|---|---|---|
| State Management | flutter_bloc | ^8.1.6 |
| Local DB | drift + drift_flutter | ^2.18.0 |
| Key-Value | shared_preferences + hive_flutter | ^2.3.2 / ^1.4.0 |
| HTTP Client | dio | ^5.7.0 |
| JSON | json_serializable + json_annotation | ^6.8.0 |
| DI | get_it | ^7.7.0 |
| Navigation | auto_route | ^9.2.2 |
| On-device ML | google_mlkit_text_recognition | ^0.13.1 |
| LLM API | (Gemini REST via Dio) | gemini-2.5-flash |
| Camera | camera | ^0.10.6 |
| Responsive | flutter_screenutil | ^5.9.3 |

---

## วิธีติดตั้งและรัน

```bash
# 1. ติดตั้ง dependencies
flutter pub get

# 2. รันแอป
flutter run

# 3. ตั้งค่า Gemini API Key
# เปิดแอป → Settings (⚙) → กรอก API Key → บันทึก
# รับ Key ฟรีได้ที่: https://aistudio.google.com/app/apikey
```

> **หมายเหตุ:** แอปทำงานได้โดยไม่ต้อง API Key — OCR และการบันทึกข้อมูลทำงานได้สมบูรณ์ AI categorization จะใช้ fallback keyword matching แทน

---

## 🤖 AI Assistant Credit

**Developed with assistance from Cascade AI** - Advanced Flutter development partner

- **Architecture Guidance** - Clean Architecture with BLoC pattern
- **Code Generation** - Auto-route, JSON serialization, database models
- **UI/UX Implementation** - Steam-inspired design with animations
- **Feature Development** - OCR integration, AI categorization, multi-currency
- **Testing Strategy** - Unit tests, widget tests, integration tests
- **Platform Configuration** - Cross-platform deployment setup

*Special thanks to Cascade AI for helping transform this expense tracking concept into a production-ready Flutter application with modern architecture and advanced features.*

---

## License

MIT
