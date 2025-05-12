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

## Search Functionality

Auracle implements a powerful search feature that allows users to find songs and artists quickly:

### Search Implementation

The search functionality uses a three-tier approach:

1. **Direct Title Matching** - Highest priority is given to songs whose titles directly contain the search query.
2. **Artist Matching** - Second tier priority is given to songs by artists whose names match the search query.
3. **Fuzzy Matching** - For less precise searches, we use the fuzzywuzzy package to find close matches based on string similarity.

The search avoids duplicate results by tracking already added songs and ensures a responsive user experience by updating results as you type. When a user taps on a search result, the song begins playing immediately.

### User Experience

- The search screen provides genre category cards that can be tapped to quickly initiate a search
- Empty states are handled gracefully with helpful messaging
- Results display in a consistent format with the rest of the app
- The search box automatically receives focus when entering the screen
