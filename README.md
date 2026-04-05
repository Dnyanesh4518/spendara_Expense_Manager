# 💰 Spendara — Personal Finance Companion

> A lightweight, intuitive mobile finance companion built with Flutter that helps users track transactions, monitor spending patterns, set savings goals, and gain meaningful insights into their daily money habits.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Screens](#screens)
- [State Management](#state-management)
- [Local Data Layer](#local-data-layer)
- [Localization](#localization)
- [Monetization](#monetization)
- [Design System](#design-system)
- [Getting Started](#getting-started)
- [APK / Build](#apk--build)
- [Assumptions & Decisions](#assumptions--decisions)

---

## Overview

Spendara is a personal finance companion app — not a banking app. It is designed for regular everyday use: logging what you spend, setting savings targets, and understanding your money habits through clear visual summaries. All data is stored locally on the device. No login, no server, no data sharing.

**Platform:** Android (primary), iOS compatible  
**Framework:** Flutter 3.x  
**Language:** Dart  
**Min SDK:** Android 5.0 (API 21)

---

## Features

### 1. Home Dashboard
- Greeting with user's name pulled from local profile
- **Current balance card** — total income minus total expenses with a savings progress bar showing overall goal completion percentage
- **Summary cards** — total income and total expenses for all time, color coded green (income) and coral (expense)
- **Weekly spending bar chart** — last 7 days of expense data visualised as a bar chart using fl_chart, with the highest spend day highlighted in full brand purple and tooltips showing exact amounts
- **Recent transactions list** — last 5 transactions with category icon, notes preview, signed amount, and relative date (Today / Yesterday / date)
- Dashboard auto-refreshes every time the user navigates back to the Home tab

### 2. Transaction Tracking
- **Add transaction** — full form with:
    - Large centered amount field, color coded by type
    - Expense / Income type toggle (TabBar with animated indicator)
    - Category grid picker with icon and animated selection highlight
    - Date picker (themed to brand color, relative labels for Today and Yesterday)
    - Optional notes field (120 character limit)
    - Inline validation with contextual error messages
- **Edit transaction** — same form pre-filled, opened by tapping any transaction tile
- **Delete transaction** — from edit screen with confirmation dialog, or swipe-to-delete (Dismissible) on list tiles
- **Transaction list** — grouped by date with sticky date headers, most recent first
- **Search** — live search across category name and notes
- **Filter chips** — All / Income / Expense, updates list instantly
- **Empty states** — contextual message changes based on active filter

### 3. Goals & Savings
- **Create goal** — form with:
    - Goal title (40 character limit)
    - Target amount and already-saved amount (side by side)
    - Deadline date picker with days/months/years remaining badge
    - Icon picker (10 options: shield, flight, laptop, heart, home, car, savings, school, medical, gift)
    - Color picker (6 brand colors with animated selected indicator)
    - Live preview card that updates as you type
- **Edit goal** — same form pre-filled
- **Delete goal** — from edit screen with confirmation dialog
- **Deposit bottom sheet** — launched from "Add funds" button on each goal card:
    - Large amount input field color-matched to goal color
    - Quick suggestion chips: 10%, 25%, 50%, and 100% of remaining amount — tap to fill
    - Validates deposit does not exceed remaining amount
    - Button label updates live to show exact amount being deposited
- **Goal cards** — show icon, title, days left (amber warning when under 7 days), progress bar, saved vs remaining amounts, and percentage badge
- **Completion state** — "Goal achieved! 🎉" label, "Complete ✓" badge, deposit button hidden
- **Overview card** — total saved across all goals, target total, overall progress bar, goal count
- **Empty state** — illustrated prompt with CTA button when no goals exist

### 4. Insights Screen
- **4 stat cards:**
    - Top spending category with total amount
    - This week's total with week-over-week percentage change (green if decreased, red if increased)
    - Most frequent category by transaction count
    - Total number of all recorded transactions
- **Spending by category — donut chart:**
    - Interactive: tap any slice to show category name and exact amount in the centre
    - Legend with animated highlight matching the tapped slice
    - Percentage labels per category
- **This week vs last week — grouped bar chart:**
    - Side-by-side bars per day (solid purple = this week, muted purple = last week)
    - Today's column highlighted with full gradient
    - Tooltips on touch showing week label and formatted amount
    - Real day labels (Mon–Sun) aligned to actual calendar days
- **Month overview card:**
    - This month vs last month side-by-side progress bars
    - Percentage change badge (↑ red if up, ↓ green if down)
    - Graceful message when prior month has no data
- **Category breakdown list:**
    - Ranked 1–N with rank badge (rank 1 highlighted in category color)
    - Proportional inline progress bar per category
    - Exact amount and percentage of total spending
- **Empty state** — shown when zero transactions exist

### 5. Add/Edit Goal Form — UX details
- Preview card at the top of the form updates live as the user types title, changes amount, selects icon or color — the user sees exactly what the card will look like before saving
- Deadline field shows a "X days/months/yr left" badge alongside the date
- All pickers (icon, color, date) are inline — no nested modals except the system date picker

### 6. Profile / Onboarding
- First-launch onboarding screen collects name and email — stored locally with Hive
- Profile screen accessible from dashboard avatar — allows editing name and email
- Avatar in dashboard app bar shows first letter of user's name
- "Stored locally. We never share your data." disclaimer shown on onboarding

### 7. Mobile UX Polish
- **Navigation:** IndexedStack with BottomNavigationBar — tabs preserve scroll position
- **Transitions:** Slide-up animation (300ms, easeOutCubic) for Add/Edit forms, fade transition (200ms) between tabs
- **Empty states:** Every list screen has a contextual empty state with icon, message, and CTA
- **Loading states:** CircularProgressIndicator shown while BLoC status is initial or loading
- **Swipe to delete:** Dismissible tiles on transaction list with red delete background
- **Keyboard handling:** Forms scroll above keyboard using viewInsets padding on bottom sheets
- **Dark mode:** Full dark theme support, switches automatically with system setting
- **Touch targets:** All interactive elements minimum 44×44px

---

## Tech Stack

| Dependency | Version | Purpose |
|---|---------|---|
| `flutter_bloc` | ^9.1.1  | State management (Cubit pattern) |
| `hive_flutter` | ^1.1.0  | Local NoSQL database |
| `hive_generator` | ^2.0.1  | Code generation for Hive adapters |
| `build_runner` | ^2.4.9  | Dart code generation |
| `fl_chart` | ^1.2.0  | Bar charts, pie/donut charts, line charts |
| `get_it` | ^9.2.1  | Service locator / dependency injection |
| `equatable` | ^2.0.8  | Value equality for BLoC states |
| `uuid` | ^4.3.3  | Unique IDs for transactions and goals |
| `intl` | ^0.20.2 | Number formatting, date formatting, l10n |
| `flutter_dotenv` | ^6.0.0 | Environment variables |
| `google_mobile_ads` | ^7.0.0  | Banner ads (AdMob integration) |
| `flutter_localizations` | SDK     | Localization framework |

---

## Architecture

The app follows a **feature-first clean architecture** with clear separation between UI, business logic, and data:

```
UI (View)  ──▶  Cubit (Business Logic)  ──▶  Repository (Data)  ──▶  Hive (Storage)
     ▲                    │
     └────── State ◀──────┘
```

- **Views** contain only UI code — they read state via `BlocBuilder` and dispatch calls via `context.read<Cubit>()`
- **Cubits** hold all business logic, compute derived values (totals, percentages, filters), and expose a single immutable state object
- **Repositories** are the only classes that touch Hive boxes — they expose typed methods (getAll, add, update, delete) and aggregate queries (totalIncome, expensesByCategory, last7DaysExpenses)
- **GetIt** is used as a service locator — repositories are registered as lazy singletons, cubits as factories
- **Models** are plain Dart classes annotated with `@HiveType` — adapters are generated by `build_runner`

### Data flow example — adding a transaction

```
User taps Save
  → AddEditTransactionScreen calls cubit.addTransaction(model)
    → TransactionCubit calls _repo.add(model)
      → TransactionRepository writes to Hive box
    → TransactionCubit calls load() — re-reads full list
      → emits new TransactionState with updated list
        → BlocBuilder rebuilds TransactionsScreen
  → Navigator.pop() closes form
  → AppShell detects tab 0 — DashboardCubit.load() called
    → Dashboard rebuilds with new balance and recent transactions
```

---

## Screens

| Screen | Description |
|---|---|
| Onboarding | First-launch only — collects name and email |
| Dashboard | Balance, summary cards, weekly chart, recent transactions |
| Transactions | Searchable, filterable grouped list with swipe-to-delete |
| Add Transaction | Slide-up form — amount, type, category, date, notes |
| Edit Transaction | Same form pre-filled, with delete option |
| Goals | Overview card, goal cards with progress and deposit CTA |
| Add Goal | Title, amounts, deadline, icon picker, color picker, live preview |
| Edit Goal | Same form pre-filled, with delete option |
| Deposit Sheet | Bottom sheet — amount input, quick suggestions |
| Insights | Stat cards, donut chart, week bars, month comparison, category list |
| Profile | Edit name and email |

---

## State Management

Each feature has its own **Cubit + State** pair:

### TransactionCubit
- `load()` — reads all transactions from Hive, sorted by date descending
- `addTransaction(model)` — writes to Hive then calls load()
- `updateTransaction(model)` — overwrites by ID then calls load()
- `deleteTransaction(id)` — deletes by ID then calls load()
- `setFilter(filter)` — updates filter string in state (no Hive call)
- `setQuery(query)` — updates search query in state (no Hive call)
- **Computed:** `state.filtered` — applies both filter and query on the full list inline

### GoalCubit
- `load()` — reads all goals from Hive
- `addGoal / updateGoal / deleteGoal` — CRUD + reload
- `deposit(id, amount)` — fetches goal by ID, clamps new savedAmount to target, updates
- **Computed:** `state.totalSaved`, `state.totalTarget`, `state.overallProgress`

### DashboardCubit
- `load()` — reads from both TransactionRepository and GoalRepository in one call
- Computes: balance, totalIncome, totalExpenses, last7DaysExpenses, recent 5 transactions, savingsProgress
- Called on every tab switch to Home to ensure freshness

### InsightsCubit
- `load()` — reads all transactions, computes all analytics in one pass
- Computes: expensesByCategory (sorted desc), last7DaysExpenses, prev7DaysExpenses, thisMonthTotal, lastMonthTotal, mostFrequentCategory (by count), totalTransactions
- **Derived state getters:** topCategory, weekOverWeekPct, monthOverMonthPct, isWeekSpendingUp, peakDaySpend, peakDayIndex

---

## Local Data Layer

All data is persisted locally using **Hive** — a fast key-value NoSQL database for Flutter.

### Hive Boxes

| Box name | Type | typeId |
|---|---|---|
| `transactions` | `TransactionModel` | 0 |
| `goals` | `GoalModel` | 1 |
| `profile` | `Map` | — (manual) |

### TransactionModel fields

| Field | Type | Notes |
|---|---|---|
| `id` | String | UUID v4 |
| `amount` | double | Always positive |
| `type` | String | `'income'` or `'expense'` |
| `category` | String | From AppConstants category lists |
| `date` | DateTime | Stored as DateTime via Hive adapter |
| `notes` | String | Optional, defaults to `''` |

### GoalModel fields

| Field | Type | Notes |
|---|---|---|
| `id` | String | UUID v4 |
| `title` | String | Max 40 chars |
| `targetAmount` | double | Must be > 0 |
| `savedAmount` | double | Clamped to 0–target on deposit |
| `deadline` | DateTime | Must be future date |
| `iconName` | String | Key into AppConstants.goalIcons map |
| `colorValue` | int | Index into AppConstants.goalColors list |

### Repository aggregate queries

`TransactionRepository` exposes:
- `totalIncome` — sum of all income transactions
- `totalExpenses` — sum of all expense transactions
- `balance` — totalIncome − totalExpenses
- `expensesByCategory` — `Map<String, double>` sorted by amount descending
- `last7DaysExpenses` — list of 7 daily totals ending today
- `prev7DaysExpenses` — list of 7 daily totals ending 7 days ago
- `last7DayLabels` — list of 7 abbreviated day names aligned to real calendar

---

## Localization

The app supports **12 languages** using Flutter's built-in `flutter_localizations` package with ARB files.

### Supported languages

| Code | Language | Currency used |
|---|---|---|
| `en` | English | ₹ |
| `hi` | Hindi | ₹ |
| `bn` | Bengali | ₹ |
| `te` | Telugu | ₹ |
| `mr` | Marathi | ₹ |
| `ta` | Tamil | ₹ |
| `gu` | Gujarati | ₹ |
| `kn` | Kannada | ₹ |
| `ml` | Malayalam | ₹ |
| `pa` | Punjabi | ₹ |
| `or` | Odia | ₹ |
| `es` | Spanish | $ |


### How it works

- All user-visible strings live in `.arb` files under `lib/l10n/`
- The base file is `app_en.arb` — all other files mirror its keys
- All Indian language translations keep ₹ as the currency symbol
- International translations replace the currency symbol with the relevant local currency
- Translations are contextually accurate — category names, financial terms, and UI labels are translated by meaning, not word-for-word
- The app detects device locale automatically via `MaterialApp.localizationsDelegates`
- Arabic uses RTL layout automatically via Flutter's directionality support

### Adding a new language

1. Create `lib/l10n/app_XX.arb` (where XX is the locale code)
2. Copy all keys from `app_en.arb` and translate the values
3. Add the locale to `supportedLocales` in `main.dart`
4. Run `flutter gen-l10n`

---

## Monetization

The app integrates **Google AdMob** banner ads via the `google_mobile_ads` package.

- A banner ad is displayed at the bottom of the screen (above the bottom navigation bar)
- Ads are loaded lazily and fail silently — the layout does not shift or break if an ad fails to load
- A **"Remove Ads (1 hr)"** option is available — watching a rewarded interstitial ad removes the banner for 60 minutes using a local timestamp check
- Ad unit IDs are stored in a constants file — test IDs are used in debug builds, real AdMob IDs in release builds
- No ads are shown on Add/Edit form screens to avoid disrupting user input

---

## Design System

### Colors

| Token | Hex | Usage |
|---|---|---|
| Primary | `#6C63FF` | Brand purple — buttons, active states, charts |
| Income | `#1D9E75` | Green — income amounts, goals overview |
| Expense | `#D85A30` | Coral — expense amounts, delete actions |
| Warning | `#BA7517` | Amber — deadline warnings, week-over-week increase |
| Background | `#F8F7FF` | Light mode page background |
| Surface | `#FFFFFF` | Light mode card background |
| Background Dark | `#0F0F1A` | Dark mode page background |
| Surface Dark | `#1A1A2E` | Dark mode card background |

### Typography

All text uses the **Inter** font family.

| Style | Size | Weight | Usage |
|---|---|---|---|
| Display Large | 32px | 700 | Balance amount |
| Heading Large | 22px | 700 | Screen titles |
| Heading Medium | 18px | 600 | Section titles |
| Body Large | 16px | 400 | Primary body text |
| Body Medium | 14px | 400 | Secondary / muted text |
| Body Small | 12px | 400 | Hints, timestamps, labels |
| Label Large | 14px | 600 | Transaction amounts, category names |
| Amount | 28px | 700 | Large financial figures |

### Component conventions

- **Cards:** `border-radius: 16px`, 1px border using `outline.withOpacity(0.4)`, no elevation shadow
- **Buttons:** `border-radius: 14px`, full width (52px height), color matches context (expense = coral, income = green, default = primary purple)
- **Input fields:** `border-radius: 12px`, 2px focus border in context color
- **Chips:** `border-radius: 20px` (pill shape), no border in default state
- **Bottom sheets:** `border-radius: 24px` top corners, drag handle centered at top

---

## Getting Started

### Prerequisites

- Flutter SDK 3.x
- Dart SDK 3.x
- Android Studio or VS Code with Flutter plugin
- Android emulator or physical device (API 21+)

## APK / Build

```bash
# Debug APK
flutter build apk --debug

# Release APK (single file)
flutter build apk --release

# Release APK (split by ABI — smaller file sizes, recommended)
flutter build apk --split-per-abi --release

# App Bundle for Play Store
flutter build appbundle --release
```

Release APKs are output to:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## Assumptions & Decisions

| Decision | Reasoning |
|---|---|
| Hive over SQLite | Hive has zero native dependency, simpler setup for this scale, and faster read performance for key-value patterns. SQLite would be preferable for complex relational queries. |
| Cubit over full BLoC | Events add boilerplate without benefit at this feature complexity. Cubit gives the same state isolation with simpler syntax. |
| IndexedStack over GoRouter ShellRoute | IndexedStack preserves scroll state natively across tab switches without additional route configuration. GoRouter is still used for full-screen routes (Add/Edit forms). |
| Feature-first folder structure | Scales better than layer-first (screens/, cubits/, models/) as each feature is self-contained and can be worked on independently. |
| Currency symbol per locale | Indian languages all use ₹ — the symbol is culturally familiar and contextually correct. International locales use their own currency symbol as the app is designed to be adapted per market. |
| No backend / no auth | The assignment specifies a lightweight finance companion. Adding auth would introduce complexity that distracts from the UX and data design goals. |
| All data local | Privacy-first approach. Users do not need to trust a server. Data survives offline use indefinitely. |
| GetIt over Provider for DI | GetIt is framework-agnostic, easier to test, and does not require wrapping widget trees with Providers purely for DI purposes. |
| Inter font | Highly legible at small sizes, excellent support for Latin and Devanagari scripts, free and open source. |

---