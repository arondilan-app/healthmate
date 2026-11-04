# HealthMate – Personal Health & Wellness Tracker

Mobile Application Development – Coursework 1 (Kingston University top-up, ESoft).

HealthMate lets a user record daily **steps**, **calories burned** and **water intake**,
review past records, search by date, update/delete entries and see a dashboard for today.

## Features

| Requirement | Implementation |
|---|---|
| Add daily entries | `AddEditRecordScreen` (form + validation) |
| List of past records | `RecordListScreen` (newest first, with dates) |
| Update / delete | Tap a card to edit; delete button or swipe (with Undo) |
| Search / filter by date | Date picker filter on the Records screen |
| Summary dashboard | `DashboardScreen` – today's totals, goal progress, 7-day chart |
| Database | `sqflite` – table `health_records` (id, date, steps, calories, water) |
| Dummy data | 14 days of sample records inserted on first launch |
| Extras | Dark mode, editable daily goals, 7-day chart, undo delete |

## Architecture (feature based MVVM + Repository)

```
lib/
├── main.dart                     # app entry, dependency wiring (MultiProvider)
├── app.dart                      # MaterialApp, light/dark theme
├── core/                         # constants, theme, validators, date helpers
├── data/database/                # DatabaseHelper (only place that writes SQL)
├── shared/widgets/               # widgets shared by many features
└── features/
    ├── health/
    │   ├── models/               # HealthRecord, DaySummary
    │   ├── repository/           # HealthRepository
    │   ├── viewmodel/            # HealthProvider (ChangeNotifier)
    │   └── views/                # screens + widgets
    ├── settings/                 # SettingsProvider + SettingsScreen
    └── home/                     # bottom navigation shell
```

State management: **Provider** (`ChangeNotifier`).
Data flow: `View → Provider (ViewModel) → Repository → DatabaseHelper → SQLite`.

## Packages

`provider`, `sqflite`, `path`, `intl`, `shared_preferences`

## How to run

> The repository contains the Dart source (`lib/`, `test/`, `pubspec.yaml`).
> Generate the platform folders once:

```bash
flutter create . --project-name healthmate --platforms=android,ios
flutter pub get
flutter run
```

`flutter create .` only adds missing files (android/, ios/ ...), it does not overwrite `lib/`.

## Run tests

```bash
flutter test
```

## Build the release APK

```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

## Branching

* `main` – stable code
* `feature/database` – SQLite, repository
* `feature/state-management` – Provider view models
* `feature/ui` – screens and widgets
* `feature/testing` – unit and widget tests, documentation
