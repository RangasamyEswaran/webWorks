
# WebWorks - Event Management & Live Updates

WebWorks is a production-quality Flutter application designed for real-time event management, discovery, and attendee engagement. The app provides a seamless experience for users to find events, register, participate in group chats, and receive live updates.

## Project Status

The application is currently in a fully functional state with the following core features implemented:

- User Authentication: Secure login and signup powered by Firebase Authentication.
- Event Discovery: Interactive dashboard with event categorization and search.
- Real-time Updates: Live event status and updates integrated via Socket.IO.
- Group Chat: Real-time messaging for each event group using Firestore Snapshots.
- Push Notifications: Integrated Firebase Cloud Messaging (FCM) for event reminders and group chat notifications.
- Maps Integration: Google Maps integration for visualizing event locations.
- Theming: Premium UI design with dynamic dark and light mode support.

## Architecture

The project follows Clean Architecture principles to ensure scalability, maintainability, and testability. The code is organized into three main layers:

### 1. Presentation Layer
- Contains Flutter widgets, pages, and UI logic.
- Uses the Bloc pattern for state management, ensuring a clear separation between UI and business logic.
- Custom design system for consistent styling and premium aesthetics.

### 2. Domain Layer
- The "heart" of the application, containing business rules.
- Entities: Plain Dart classes representing the core objects (e.g., User, Event, ChatMessage).
- Use Cases: Specific application logic (e.g., login, register for event, send message).
- Repositories (Abstract): Interfaces defining how data should be handled without knowing the source.

### 3. Data Layer
- Responsible for data fetching and storage.
- Repositories (Implementation): Coordinate data flow between data sources.
- Data Sources: Handle API calls (Retrofit/Dio), Firestore interactions, Socket.IO connections, and local storage (Hive).
- Models/DTOs: Data Transfer Objects used for JSON serialization and data source specific logic.

## Data Flow

The application follows a predictable unidirectional data flow:

1. UI triggers an Event in a Bloc.
2. Bloc calls a Use Case.
3. Use Case interacts with a Repository interface.
4. Repository implementation fetches data from a Remote or Local Data Source.
5. Data (in the form of Entities) flows back to the Bloc.
6. Bloc emits a new State.
7. UI rebuilds based on the new State.

## Setup & Installation

### Prerequisites
- Flutter SDK (latest stable version recommended)
- Firebase Account and Project
- Google Maps API Key

### Configuration

1. Firebase Setup:
   - Create a Firebase project and add Android/iOS apps.
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).
   - Place them in `android/app/` and `ios/Runner/` respectively.

2. Dependencies:
   - Run `flutter pub get` to install all necessary packages.

### Running the App
- For development: `flutter run`
- To generate code (for JSON serialization, etc.): `flutter pub run build_runner build --delete-conflicting-outputs`

## Design Philosophy

The application prioritizes a premium user experience through:
- Fluid animations and transitions.
- A consistent and accessible design system.
- Responsive layouts for various screen sizes.
- Intuitive navigation and micro-interactions.

