# 📋 EthicFin TaskManager

A modern, production-grade, **offline-first Task Management Application** built with Flutter, Clean Architecture, BLoC State Management, Firebase Authentication, Cloud Firestore synchronization, and Firebase Cloud Messaging (FCM).

---

## ✨ Features

### 🔐 1. Firebase Authentication & User Isolation
- **Email & Password Authentication**: Secure sign-up and sign-in powered by Firebase Auth.
- **Guest / Anonymous Mode**: Instant 1-tap offline-ready guest access without requiring an account.
- **Strict User Scoping**: Tasks created by an authenticated user are isolated in both local SQLite and Cloud Firestore (`user_id`). Switching accounts seamlessly isolates each user's tasks.
- **Persistent Sessions**: Users remain logged in across app restarts.
- **Account Management**: App Bar avatar menu displaying user email, full name, and a 1-tap Sign Out option.

### 🔄 2. Advanced Offline-First Synchronization
- **SQLite Local Database**: High-speed local reads and writes using SQLite (v2 schema) with indexed queries.
- **Bi-directional Delta Sync**: Seamlessly syncs local changes with Cloud Firestore when internet connectivity is detected.
- **Conflict Resolution (Last-Write-Wins)**: Deterministically resolves multi-device conflicts using UTC `updatedAt` timestamps.
- **Batch Operations**: Atomic batch sync (`WriteBatch`) for optimal network usage and low latency.
- **Live Sync Status Indicator**: Real-time badge in the App Bar showing *Synced*, *Syncing*, *Offline*, or *Queued* count.

### 🔔 3. FCM & Local Push Notifications
- **Push Notifications (FCM v1)**: Handles foreground, background, and terminated push notifications.
- **Local Notifications**: Automatic task due-date notifications and instant confirmations when creating or editing tasks.
- **Token Management**: Auto-registers FCM device tokens under `users/{userId}` in Cloud Firestore.
- **In-App Test Notification**: 1-tap test notification button in the user profile menu.

### 🎨 4. WhatsApp-Inspired Dark & Light Theme
- **High-Contrast Dark Mode**: Deep `#121B22` background with `#00A884` emerald green accents.
- **Crystal-Clear Light Mode**: Clean `#FFFFFF` and `#F0F2F5` backgrounds with `#D9FDD3` mint pill filters and bold high-contrast text (`#111B21`).
- **Global Theme Switcher**: 1-tap Dark/Light toggle accessible from the App Bar on every screen.

### 🔍 5. Search, Filter & Real-Time Form Validation
- **Search**: Instant, debounced search across task titles and descriptions.
- **Filters & Sorting**: Filter by Status (*All, Pending, Completed*) or Priority (*Low, Medium, High, Urgent*) and sort by Due Date, Priority, or Creation Date.
- **Dynamic Form Validations**: Real-time feedback (`AutovalidateMode.onUserInteraction`) with live character counters for Title (3-80 chars), Description (5-500 chars), and future-date picker.
- **Full 36-char Task UUID**: Selectable and copyable Task IDs in the details view.

---

## 🏗️ Architecture & Project Structure

The project strictly follows **Clean Architecture** with separation of concerns:

```
lib/
├── core/
│   ├── constants/            # App and Database constants
│   ├── database/             # SQLite DatabaseHelper (v2 schema & migrations)
│   ├── di/                   # GetIt Service Locator dependency injection
│   ├── error/                # Exceptions and Failures
│   ├── network/              # Connectivity checker
│   ├── router/               # GoRouter configuration with Auth guards
│   ├── services/             # NotificationService (FCM & Local Notifications)
│   ├── theme/                # AppColors, AppTheme, ThemeCubit
│   └── utils/                # Date formatting utilities
├── features/
│   ├── auth/
│   │   ├── domain/           # UserEntity, AuthRepository, AuthUseCases
│   │   ├── data/             # AuthRemoteDataSource, AuthRepositoryImpl
│   │   └── presentation/     # AuthBloc, LoginScreen, RegisterScreen
│   └── tasks/
│       ├── domain/           # TaskEntity, Enums, TaskRepository, UseCases, ConflictResolver
│       ├── data/             # TaskModel, TaskLocalDataSource, TaskRemoteDataSource, TaskRepositoryImpl
│       └── presentation/     # TaskBloc, TaskListScreen, TaskFormScreen, TaskDetailScreen, Widgets
├── firebase_options.dart     # Auto-generated Firebase configuration
└── main.dart                 # Application entry point
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.9.0 or higher)
- [Android Studio](https://developer.android.com/studio) / Xcode
- A [Firebase](https://console.firebase.google.com/) Project

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/rohith18n/ethicfin_taskmanager.git
   cd ethicfin_taskmanager
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   - Place your `google-services.json` inside `android/app/`.
   - Ensure `firebase_options.dart` contains your project configuration.

4. **Run the application:**
   ```bash
   flutter run
   ```

---

## 🛡️ Cloud Firestore Security Rules

Set the following security rules in your **Firebase Console > Firestore Database > Rules**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Tasks collection: Users can only read/write their own tasks
    match /tasks/{taskId} {
      allow read, write: if request.auth != null && (
        request.auth.uid == resource.data.userId || 
        request.auth.uid == request.resource.data.userId ||
        resource.data.userId == null
      );
      allow create: if request.auth != null;
    }
    
    // Users collection: For FCM tokens and profile metadata
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 🧪 Testing & Verification

Run the comprehensive unit, BLoC, and widget test suite:

```bash
# Run static analysis
flutter analyze

# Run all tests
flutter test
```

### Test Coverage Highlights:
- **`ConflictResolver`**: Validates deterministic Last-Write-Wins resolution under varying timestamp scenarios.
- **`AuthBloc`**: Tests authentication lifecycle, anonymous sign-in, and error handling.
- **`TaskRepositoryImpl`**: Tests offline caching, batch syncing, and remote merges.
- **`TaskModel`**: Tests serialization across JSON, SQLite, and Cloud Firestore.
- **`Widget Tests`**: Tests UI rendering, theme switches, priority chips, and dynamic form validations.

---

## 📦 Building for Release

### Android APK
```bash
flutter build apk --release
```
The output APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 📄 License
This project is licensed under the MIT License.
