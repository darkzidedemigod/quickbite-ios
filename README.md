# 🍔 QuickBite

<p align="center">
  <b>QuickBite</b> is a food discovery iOS application built using <b>Swift</b>, <b>UIKit</b>, and <b>MVVM architecture</b>.
</p>

<p align="center">
  Discover meals, create an account, manage favorites, and explore recipes through a scalable and testable iOS architecture.
</p>

---

## 📱 Features

### 🔐 Authentication
- Firebase Authentication integration
- Login with email and password
- User registration screen
- Registration linked directly from login screen
- Input validation
- Persistent login sessions
- Secure logout functionality

### 📝 Registration
- Create a new account
- Store user information in Firestore
- First name and last name support
- Email/password validation
- Error handling and feedback

### 🏠 Home Screen
- Browse meal categories
- Search meals with debounce functionality
- Dynamic meal listings
- Loading and empty states

### 🍽️ Meal Details
- Display meal image
- Ingredients list
- Cooking instructions
- Add/remove favorites

### ❤️ Favorites
- Save favorite meals
- Manage favorite meal collection
- Persistent local storage

### 👤 Profile
- Display authenticated user information
- View user details from Firestore
- Logout support

---

## 🛠 Tech Stack

| Technology | Usage |
|------------|-------|
| Swift | Main programming language |
| UIKit | User Interface |
| MVVM | Architectural pattern |
| Alamofire | Networking |
| SnapKit | Programmatic Auto Layout |
| Firebase Authentication | User authentication |
| Firestore | Cloud database |
| CocoaPods | Dependency management |
| UserDefaults | Local persistence |
| XCTest | Unit testing |

---

## 📋 Requirements

- iOS 15.0+
- Xcode 14.0+
- CocoaPods

---

## 🚀 Installation

### 1. Clone repository

```bash
git clone https://github.com/darkzidedemigod/quickbite-ios.git
cd quickbite-ios
```

### 2. Install dependencies

```bash
pod install
```

### 3. Configure Firebase

1. Create a Firebase project
2. Add an iOS application in Firebase Console
3. Download:

```text
GoogleService-Info.plist
```

4. Add it into your Xcode project root
5. Enable:

- Authentication → Email/Password
- Firestore Database

---

### 4. Open workspace

```bash
open QuickBite.xcworkspace
```

---

### 5. Run application

Open in Xcode and press:

```bash
Cmd + R
```

---

## 🏗 Architecture

QuickBite follows **MVVM (Model–View–ViewModel)** combined with a Repository pattern.

### Architecture Flow

```text
View (ViewController)
        ↓
ViewModel
(Business Logic + State Management)
        ↓
Repository
(Data Abstraction Layer)
        ↓
Services
(API / Firebase / Local Storage)
```

---

## 🔄 Data Flow

1. User interaction happens in View
2. View sends actions to ViewModel
3. ViewModel processes business logic
4. Repository communicates with Services
5. Services retrieve local or remote data
6. Observable updates UI automatically

---

## 📦 State Management

ViewModels use an enum-based state system:

```swift
enum ViewState<T> {
    case loading
    case success(T)
    case error(String)
    case empty
}
```

Available states:

- `loading`
- `success(T)`
- `error(String)`
- `empty`

---

## 📂 Project Structure

```text
QuickBite/
├── App/
├── Models/
├── Networking/
├── Repositories/
├── Services/
├── ViewModels/
│   ├── LoginViewModel.swift
│   ├── RegisterViewModel.swift
│   ├── HomeViewModel.swift
│   ├── MealDetailViewModel.swift
│   ├── FavoritesViewModel.swift
│   └── ProfileViewModel.swift
│
├── Views/
│   ├── Authentication/
│   │   ├── LoginViewController.swift
│   │   └── RegisterViewController.swift
│   │
│   ├── Home/
│   ├── MealDetail/
│   ├── Favorites/
│   └── Profile/
│
├── Components/
├── Utilities/
└── Extensions/

QuickBiteTests/
└── Tests/
```

---

## 🧩 Reusable Components

Reusable UI components include:

- `PrimaryButton`
- `CustomTextField`
- `SearchBarView`
- `MealCardView`
- `LoadingView`
- `EmptyStateView`

---

## 📚 Dependencies

| Dependency | Purpose |
|------------|---------|
| Alamofire | Networking |
| SnapKit | Auto Layout |
| FirebaseAuth | Authentication |
| FirebaseFirestore | Cloud database |
| FirebaseAnalytics | Analytics |
| FirebaseCrashlytics | Crash reporting |

---

## 🎯 Design Decisions

### Programmatic UI
- No Storyboards
- No XIB
- No SwiftUI

### Architecture Principles
- MVVM architecture
- Repository pattern
- Protocol-based services
- Dependency injection
- Testable components

### Performance & Maintainability
- Lightweight Observable implementation
- Debounced searching
- Weak references for memory safety
- Reusable UI components

---

## 🧪 Running Tests

### Via Xcode

Select:

```text
QuickBiteTests
```

Then run:

```bash
Cmd + U
```

### Via terminal

```bash
xcodebuild test \
-workspace QuickBite.xcworkspace \
-scheme QuickBite \
-destination 'platform=iOS Simulator,name=iPhone 14'
```

---

## 🔮 Future Improvements

- Social login (Google / Apple Sign In)
- Offline caching
- Dark mode
- Recipe filtering
- User profile editing
- Push notifications
- Pagination support
- UI snapshot testing

---

## 📄 License

MIT License

---

## 👨‍💻 Author

Nestor Alorro

GitHub:  
https://github.com/darkzidedemigod
