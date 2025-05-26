# Auracle

A music app with beautiful UI built with Flutter.

## Features

- Beautiful dark theme UI
- Login and signup screens
- Google auth integration (UI only)
- Responsive design

## Getting Started

1. Make sure you have Flutter installed
2. Clone this repository
3. Create a `.env` file in the root directory with the following variables:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```
4. Run `flutter pub get` to install dependencies
5. Run `flutter run` to start the app

## Screenshots

- Login Screen
- Signup Screen

## Architecture

This project follows a feature-based architecture with clean separation of concerns:

- **Core**: Contains reusable components, theme, and router configuration
- **Features**: Contains domain-specific features (auth, music player, etc.)
  - Each feature has presentation, application, and domain layers

## Tech Stack

- Flutter for UI
- GoRouter for navigation
- Riverpod for state management
- Supabase for backend (configured but not implemented)
- Google Fonts for typography
