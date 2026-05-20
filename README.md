# QuickBite

A food discovery iOS application built with Swift, UIKit, and MVVM architecture.

## Features

- **Authentication** - Mock login with email/password validation
- **Home Screen** - Browse meal categories and search for meals
- **Meal Detail** - View meal images, ingredients, and cooking instructions
- **Favorites** - Save and manage favorite meals
- **Profile** - User info display with logout functionality

## Requirements

- iOS 15.0+
- Xcode 14.0+
- CocoaPods

## Setup Instructions

1. **Clone the repository**

```bash
git clone https://github.com/darkzidedemigod/quickbite-ios.git
cd quickbite-ios
```

2. **Install dependencies via CocoaPods**

```bash
pod install
```

3. **Open the workspace**

```bash
open QuickBite.xcworkspace
```

4. **Build and run**

Select a simulator (iOS 15.0+) and press `Cmd + R` to build and run.

## Login Credentials

For testing the mock authentication:

- **Email:** `test@quickbite.com`
- **Password:** `password123`

## Architecture

### MVVM (Model-View-ViewModel)

```
View (ViewController)
  → ViewModel (Business Logic + State Management)
    → Repository (Data Abstraction Layer)
      → Service/API (Network Calls / Local Storage)
```

### Data Flow

1. **View** sends user actions to the **ViewModel**
2. **ViewModel** processes logic and calls **Repository** methods
3. **Repository** handles data fetching from **APIService** (network) or **UserDefaults** (local)
4. **ViewModel** updates its **Observable** properties
5. **View** observes changes and updates UI accordingly

### State Management

Each ViewModel uses an enum-based state system:

- `loading` - Data is being fetched
- `success(T)` - Data loaded successfully
- `error(String)` - Error occurred with message
- `empty` - No data available

## Project Structure

```
QuickBite/
├── App/
│   ├── AppDelegate.swift          # Application entry point
│   └── SceneDelegate.swift        # Scene lifecycle & window setup
├── Models/
│   ├── Meal.swift                 # Meal model with Codable + Ingredient
│   └── User.swift                 # User authentication model
├── Networking/
│   ├── APIService.swift           # Alamofire-based network service
│   ├── APIEndpoint.swift          # API endpoint definitions
│   └── NetworkError.swift         # Network error handling
├── Repositories/
│   └── MealRepository.swift       # Data layer abstraction
├── Services/
│   └── AuthService.swift          # Mock authentication service
├── ViewModels/
│   ├── LoginViewModel.swift       # Login screen logic & validation
│   ├── HomeViewModel.swift        # Home screen data & search
│   ├── MealDetailViewModel.swift  # Meal detail & favorites
│   ├── FavoritesViewModel.swift   # Favorites management
│   └── ProfileViewModel.swift     # User profile & logout
├── Views/
│   ├── Authentication/
│   │   └── LoginViewController.swift
│   ├── Home/
│   │   └── HomeViewController.swift
│   ├── MealDetail/
│   │   └── MealDetailViewController.swift
│   ├── Favorites/
│   │   └── FavoritesViewController.swift
│   └── Profile/
│       └── ProfileViewController.swift
├── Components/
│   ├── PrimaryButton.swift        # Reusable button with loading state
│   ├── CustomTextField.swift      # Input field with validation UI
│   ├── SearchBarView.swift        # Search input with debounce
│   ├── MealCardView.swift         # Meal card with gradient overlay
│   ├── LoadingView.swift          # Activity indicator overlay
│   └── EmptyStateView.swift       # Empty state placeholder
├── Utilities/
│   └── Observable.swift           # Simple observable binding class
└── Extensions/
    └── UIViewController+Extensions.swift  # Alert helpers

QuickBiteTests/
└── Tests/
    ├── LoginViewModelTests.swift   # Login validation & auth flow
    ├── HomeViewModelTests.swift    # Categories, search, empty states
    ├── APIServiceTests.swift       # Network request mocking
    └── FavoritesViewModelTests.swift   # Favorites CRUD operations
```

## Dependencies

| Pod | Purpose |
|-----|---------|
| [Alamofire](https://github.com/Alamofire/Alamofire) | HTTP networking |
| [SnapKit](https://github.com/SnapKit/SnapKit) | Auto Layout DSL |
| FirebaseAnalytics (optional) | App analytics |
| FirebaseCrashlytics (optional) | Crash reporting |

## Design Decisions

- **Programmatic UI only** - No storyboards, XIBs, or SwiftUI
- **SnapKit for layout** - No NSLayoutConstraint.activate() calls
- **Protocol-based services** - Enables dependency injection and mocking for tests
- **Observable pattern** - Lightweight binding without Combine or RxSwift
- **Repository pattern** - Centralizes data access and abstracts data sources
- **Weak references** - Prevents retain cycles in closures

## Running Tests

Run tests from Xcode:

1. Select `QuickBiteTests` scheme
2. Press `Cmd + U`

Or via command line:

```bash
xcodebuild test -workspace QuickBite.xcworkspace -scheme QuickBite -destination 'platform=iOS Simulator,name=iPhone 14' -only-testing QuickBiteTests
```

## License

MIT