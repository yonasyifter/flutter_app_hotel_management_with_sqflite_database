# StockBook 🛒

A Flutter grocery stock and sales management app. Track daily purchases, sales, revenue and profit — all stored locally on the device.

---

## Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0.0 ([install guide](https://flutter.dev/docs/get-started/install))
- Android Studio or VS Code with Flutter plugin

### Setup

```bash
# 1. Open the project folder
cd stockbook

# 2. Install dependencies
flutter pub get

# 3. Run on your connected device or emulator
flutter run
```

---

## Project Structure

```
lib/
├── main.dart                         # App entry point
├── theme.dart                        # Colors, typography, ThemeData
├── models/
│   ├── product.dart                  # Product model
│   └── day_entry.dart                # DayEntry, PurchaseItem, SaleItem models
├── services/
│   └── db_service.dart               # SQLite (sqflite) database operations
├── providers/
│   └── app_provider.dart             # State management (Provider)
├── widgets/
│   └── shared_widgets.dart           # Reusable UI components
└── screens/
    ├── home_screen.dart              # Month calendar + monthly summary
    ├── product_setup_screen.dart     # Product list management
    └── day_flow/
        ├── purchases_screen.dart     # Step 2: Log purchases
        ├── price_check_screen.dart   # Step 3: Confirm sell prices
        ├── sales_screen.dart         # Step 4: Log units sold
        └── summary_screen.dart      # Step 5: End-of-day summary
```

---

## App Flow

1. **Home** — Pick a month, see calendar. Tap any day to begin logging.
2. **Products** — First-time setup: add product name, buy price, sell price, opening stock.
3. **Step 2 – Purchases** — Log what you restocked (qty + price per product).
4. **Step 3 – Price Check** — Confirm or update today's selling prices.
5. **Step 4 – Sales** — Enter units sold with a +/− stepper; running revenue shows live.
6. **Step 5 – Summary** — Full breakdown per product (opening → bought → sold → closing), plus total revenue, profit, and ⚠️ low stock warnings.

---

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `sqflite` | ^2.3.0 | Local SQLite database |
| `path` | ^1.8.3 | DB file path |
| `provider` | ^6.1.1 | State management |
| `table_calendar` | ^3.1.2 | Calendar grid on home screen |
| `intl` | ^0.19.0 | Date formatting |
| `google_fonts` | ^6.1.0 | Playfair Display + DM Sans/Mono |

---

## Design System

| Token | Colour | Use |
|-------|--------|-----|
| `ink` | `#1A1208` | Primary text, buttons, app bar |
| `cream` | `#F5F0E8` | Scaffold background |
| `amber` | `#D4870A` | Active state, accents |
| `green` | `#2D6A4F` | Complete states, profit |
| `brown` | `#6B4226` | Secondary text, labels |
| `red` | `#B5323A` | Warnings, errors |

---

## Next Steps / Extensions
- [ ] Cloud sync (Firebase / Supabase) for multi-device access
- [ ] Export monthly report as CSV or PDF
- [ ] Push notifications for low stock
- [ ] Multiple shops / locations support
- [ ] Barcode scanning for quick product lookup
