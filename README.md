# CSMS Phase 1

## Overview
Church Servants Management System (Phase 1) is a Flutter application designed for managing student attendance and servants. It features an offline-first architecture using Hive for local storage and Firestore for remote synchronization.

## Features
- **Authentication**: Role-based access (Admin/Servant).
- **Offline-First**: Full functionality offline; syncs when online.
- **Attendance**: Mark present/absent/excused.
- **Conflict Resolution**: Detects and resolves data conflicts during sync.
- **Data Management**: Import students via Excel, Export attendance reports.

## Architecture
- **Clean Architecture**: Domain, Data, Presentation layers.
- **State Management**: BLoC / Cubit.
- **Local Database**: Hive.
- **Remote Database**: Firebase Firestore.

## Setup
1.  Ensure Flutter is installed.
2.  Run `flutter pub get`.
3.  Configure Firebase (ensure `google-services.json` is present for Android).
4.  Run `flutter run`.

## Sync Protocol
- Writes are saved to Hive and a Sync Queue.
- Background sync runs every 60s or on connectivity restore.
- Conflicts are flagged for Admin resolution.
