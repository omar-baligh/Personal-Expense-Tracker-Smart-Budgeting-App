# Personal Expense Tracker & Smart Budgeting App

A comprehensive Flutter application designed to help users manage their finances with ease. This app features real-time synchronization using Firebase Firestore, secure authentication, and a modern Material 3 user interface.

## 🚀 Features

- **Real-time Firestore Sync**: Your transactions and goals are synced instantly across all your devices.
- **Secure Authentication**: Email/Password and Google Sign-In support via Firebase Auth.
- **Smart Budgeting**: Set monthly budgets for different categories like Housing, Food, Transport, etc.
- **Goal Tracking**: Create and track financial goals with visual progress indicators.
- **Transaction Management**: Easily add, delete, and filter transactions by type and category.
- **Responsive Design**: Works beautifully on Android, iOS, and Web.
- **Clean Architecture**: Built using Flutter BLoC (Cubit) for state management.

## 🛠️ Tech Stack

- **Framework**: Flutter
- **State Management**: Flutter BLoC / Cubit
- **Backend**: Firebase (Auth, Firestore)
- **Design**: Material 3

## 📦 Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- A Firebase project

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/omar-baligh/Personal-Expense-Tracker-Smart-Budgeting-App.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:
   - Follow the instructions on [Firebase Console](https://console.firebase.google.com/) to add an Android/iOS/Web app.
   - Replace the `google-services.json`, `GoogleService-Info.plist`, and `firebase_options.dart` with your own configurations.
4. Run the app:
   ```bash
   flutter run
   ```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
