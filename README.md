# Digital Edir - No One Greieves Alone Anymore

![Digital Edir Banner](assets/images/banner.png)

## Overview
Digital Edir is a cross-platform mobile application that digitizes traditional Ethiopian community social support systems (Edirs). The app enables users to discover, join, and manage Edir groups, track contributions, request support, and facilitates transparent social management for community groups.

## Features
- **User Authentication**: OTP-based registration and login via phone/email
- **Edir Discovery**: Find nearby Edir groups with location-based search
- **Smart Contribution Calculator**: Automated calculation based on family size and age
- **Contribution Management**: Track payments, history, and dues
- **Support Request System**: Submit and track financial support requests
- **Admin Dashboard**: Complete admin panel for group management
- **Real-time Notifications**: Reminders for contributions and meetings
- **Multi-role Support**: Member, Admin, and Super Admin roles

## Tech Stack
- **Frontend**: Flutter (Dart) - Cross-platform mobile development
- **State Management**: Provider + GetIt for dependency injection
- **HTTP Client**: Dio with interceptors and error handling
- **Local Storage**: Shared Preferences + Flutter Secure Storage
- **Notifications**: Flutter Local Notifications
- **Backend**: Node.js/Express (Mock) - Ready for production API integration
- **Database**: Ready for SQL/NoSQL integration

## Quick Start
```bash
# Clone the repository
git clone https://github.com/quaja-abu/digitalEdir.git
cd digitalEdir

# Install Flutter dependencies
flutter pub get

# Start mock backend server
cd mock_server
npm install
npm start

# Run the app
flutter run
