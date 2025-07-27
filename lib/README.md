# DhanQ App - MVVM Architecture

This Flutter app implements the MVVM (Model-View-ViewModel) architecture pattern for clean separation of concerns and maintainable code.

## Project Structure

```
lib/
├── models/           # Data models
│   ├── user_model.dart
│   ├── portfolio_model.dart
│   ├── activity_model.dart
│   └── financial_service_model.dart
├── viewmodels/       # Business logic and state management
│   ├── sign_viewmodel.dart
│   ├── login_viewmodel.dart
│   └── home_viewmodel.dart
├── views/           # UI components
│   ├── splash_screen.dart
│   ├── sign_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   └── success_screen.dart
├── services/        # External services and API calls
│   ├── auth_service.dart
│   └── home_service.dart
├── utils/           # Utility functions and constants
└── main.dart        # App entry point
```

## Architecture Components

### 1. Models (`lib/models/`)
- **UserModel**: Represents user data with JSON serialization/deserialization
- Contains data validation and business logic for data entities

### 2. ViewModels (`lib/viewmodels/`)
- **SignViewModel**: Manages the state and business logic for the sign screen
- **LoginViewModel**: Manages the state and business logic for the comprehensive login screen
- **HomeViewModel**: Manages the state and business logic for the home screen
- Handles user input validation, API calls, and UI state management
- Uses `ChangeNotifier` for reactive UI updates
- Implements MVVM pattern with clear separation from UI

### 3. Views (`lib/views/`)
- **SplashScreen**: Animated logo screen with DhanQ branding
- **SignScreen**: Simple authentication screen with phone number input
- **LoginScreen**: Comprehensive login screen with multiple authentication options
- **HomeScreen**: Main dashboard with portfolio, services, and activities
- **SuccessScreen**: Success screen shown after successful authentication
- Pure UI components that observe ViewModels for state changes
- No business logic, only presentation logic

### 4. Services (`lib/services/`)
- **AuthService**: Handles authentication operations
- Manages local storage, API calls, and data persistence
- Provides clean interface for ViewModels to interact with external data

## Key Features

### Home Screen Features:
- **Portfolio Overview**:
  - Total portfolio value with monthly change percentage
  - Breakdown of investments, savings, and expenses
  - Interactive "View Details" button
- **Voice Search**:
  - AI-powered voice search with microphone icon
  - Example queries for user guidance
  - Real-time query processing
- **Financial Services Grid**:
  - 6 service cards with icons and descriptions
  - Smart Investor Agent, Market Analysis, Goal Planner
  - Debt Doctor, Tax Whisperer, Asset Management
- **Recent Activity Feed**:
  - Transaction history with icons and amounts
  - Color-coded activity types (income, expense, investment)
  - "See All" navigation option
- **Location-based Segments**:
  - Urban/Rural location toggle
  - Context-aware financial recommendations
- **Bottom Navigation**:
  - Home, Finance, History, Settings tabs
  - Active state indicators

### MVVM Benefits:
- **Separation of Concerns**: UI, business logic, and data are clearly separated
- **Testability**: Each component can be tested independently
- **Maintainability**: Changes in one layer don't affect others
- **Reusability**: ViewModels can be reused across different views
- **State Management**: Centralized state management with Provider

## Dependencies

- `provider`: For state management and dependency injection
- `shared_preferences`: For local data persistence
- `flutter_lints`: For code quality and best practices

## Usage

1. Run `flutter pub get` to install dependencies
2. Run `flutter run` to start the app
3. **Splash Screen**:
   - Animated DhanQ logo with fade-in and scale effects
   - Brand tagline "Where Every Rupee Has a Goal"
   - Automatic navigation to home screen after 3 seconds
4. **Home Screen Features**:
   - View your total portfolio value and monthly changes
   - Use voice search to ask financial questions
   - Explore financial services in the grid layout
   - Check recent activities and transactions
   - Toggle between Urban/Rural segments
   - Navigate using bottom navigation bar
5. **Interactive Elements**:
   - Tap service cards to explore features
   - Pull to refresh for updated data
   - Use voice search with microphone icon
   - View detailed portfolio information

## State Management

The app uses Provider pattern for state management:
- ViewModels extend `ChangeNotifier`
- Views use `Consumer<ViewModel>` to listen to state changes
- UI automatically updates when ViewModel state changes

## Error Handling

- Input validation with user-friendly error messages
- Network error handling with retry mechanisms
- Graceful error display in UI
- Error state management in ViewModels

## Future Enhancements

- Add OTP verification screen
- Implement real API integration
- Add biometric authentication
- Implement proper navigation with routes
- Add unit tests for ViewModels and Services
- Add integration tests for complete user flows 