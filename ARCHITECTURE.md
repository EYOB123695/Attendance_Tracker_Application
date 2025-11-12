# Attendance Tracker App - Architecture & Code Structure

## 📁 Folder Structure

```
attendance_tracker_app/
├── lib/
│   ├── main.dart                          # App entry point
│   │
│   ├── app/                               # Application layer
│   │   ├── feature/                       # Feature modules (MVC pattern)
│   │   │   ├── auth/                     # Authentication feature
│   │   │   │   ├── controller/
│   │   │   │   │   └── auth_controller.dart
│   │   │   │   ├── model/
│   │   │   │   │   └── user_model.dart
│   │   │   │   └── view/
│   │   │   │       ├── login_view.dart
│   │   │   │       └── register_view.dart
│   │   │   │
│   │   │   ├── home/                     # Home/Check-in feature
│   │   │   │   ├── controller/
│   │   │   │   │   └── home_controller.dart
│   │   │   │   └── view/
│   │   │   │       └── home_view.dart
│   │   │   │
│   │   │   ├── dashboard/                # Dashboard feature
│   │   │   │   ├── controller/
│   │   │   │   │   └── dashboard_controller.dart
│   │   │   │   └── view/
│   │   │   │       └── dashboard_view.dart
│   │   │   │
│   │   │   ├── history/                  # History feature
│   │   │   │   ├── controller/
│   │   │   │   │   └── history_controller.dart
│   │   │   │   └── view/
│   │   │   │       └── history_view.dart
│   │   │   │
│   │   │   └── profile/                  # Profile feature
│   │   │       ├── controller/
│   │   │       │   └── profile_controller.dart
│   │   │       └── view/
│   │   │           └── profile_view.dart
│   │   │
│   │   ├── routes/                       # Navigation routes
│   │   │   ├── app_pages.dart            # Route definitions
│   │   │   └── app_routes.dart           # Route constants
│   │   │
│   │   ├── services/                     # App-level services
│   │   │   └── local_storage_service.dart
│   │   │
│   │   └── utils/                        # App-level utilities
│   │       └── constants.dart
│   │
│   └── core/                             # Core/shared layer
│       ├── model/                         # Core data models
│       │   └── attendance_model.dart
│       ├── service/                       # Core services
│       │   └── attendance_service.dart
│       └── utils/                         # Core utilities
│           └── month_year_picker.dart
```

---

## 🏗️ Architecture Pattern

The app follows **MVC (Model-View-Controller)** architecture with **GetX** for state management:

### **Model** (Data Layer)
- **`AttendanceModel`**: Represents daily attendance with multiple sessions
- **`AttendanceSession`**: Represents a single check-in/check-out session
- **`UserModel`**: Represents user data

### **View** (UI Layer)
- All `*_view.dart` files - Flutter widgets that display UI
- Use `Obx()` or `GetBuilder()` for reactive updates

### **Controller** (Business Logic Layer)
- All `*_controller.dart` files - Manage state and business logic
- Extend `GetxController` for reactive state management
- Handle user interactions and data operations

### **Service** (Data Access Layer)
- **`AttendanceService`**: Handles attendance data persistence
- Uses `SharedPreferences` for local storage
- Provides CRUD operations for attendance records

---

## 🔄 State Management with GetX

### **GetX Core Concepts Used:**

1. **Reactive Variables (`.obs`)**
   ```dart
   var status = 'Not checked in'.obs;
   var records = <Map<String, String>>[].obs;
   ```
   - Variables marked with `.obs` are reactive
   - UI automatically updates when these values change

2. **Obx() Widget**
   ```dart
   Obx(() => Text(controller.status.value))
   ```
   - Rebuilds UI when observed reactive variables change
   - Automatically tracks dependencies

3. **GetxController**
   ```dart
   class HomeController extends GetxController {
     // Business logic here
   }
   ```
   - Manages state and business logic
   - Lifecycle: `onInit()`, `onReady()`, `onClose()`

4. **Dependency Injection**
   ```dart
   Get.put(HomeController(), permanent: true);  // Register
   Get.find<HomeController>();                   // Retrieve
   ```
   - Controllers registered globally
   - Can be accessed from anywhere

---

## 🧭 Navigation System

### **Route Structure:**

```dart
// app/routes/app_routes.dart
Routes.login      → '/login'
Routes.register   → '/register'
Routes.home       → '/home'
Routes.dashboard  → '/dashboard'
Routes.history    → '/history'
Routes.profile    → '/profile'
```

### **Navigation Flow:**

```
App Start
    ↓
main.dart
    ↓
GetMaterialApp (initialRoute: Routes.login)
    ↓
┌─────────────────────────────────────┐
│  Authentication Flow                │
├─────────────────────────────────────┤
│  LoginView → RegisterView          │
│  (AuthController manages auth)     │
└─────────────────────────────────────┘
    ↓ (After successful login)
HomeView (Bottom Navigation)
    ↓
┌─────────────────────────────────────┐
│  Main App (IndexedStack)            │
├─────────────────────────────────────┤
│  Tab 0: HomeView                     │
│  Tab 1: DashboardView               │
│  Tab 2: HistoryView                  │
│  Tab 3: ProfileView                  │
└─────────────────────────────────────┘
```

### **Navigation Implementation:**

1. **Route Definition** (`app_pages.dart`):
   ```dart
   static final routes = [
     GetPage(name: Routes.login, page: () => const LoginView()),
     GetPage(name: Routes.home, page: () => const HomeView()),
     // ...
   ];
   ```

2. **Navigation Methods:**
   ```dart
   Get.toNamed(Routes.home);           // Navigate to route
   Get.offNamed(Routes.home);          // Navigate & remove previous
   Get.back();                         // Go back
   ```

3. **Bottom Navigation** (`HomeView`):
   - Uses `IndexedStack` to maintain state across tabs
   - All tabs are pre-loaded but only visible tab is rendered
   - Controllers initialized once and persist across tab switches

---

## 📊 Data Flow

### **1. Check-In/Check-Out Flow:**

```
User clicks "Check In"
    ↓
HomeController.checkIn()
    ↓
AttendanceService.addCheckIn()
    ↓
SharedPreferences.setString()  [Save to storage]
    ↓
HomeController._notifyAttendanceChanged()
    ↓
┌─────────────────────────────────────┐
│  Notify Other Controllers           │
├─────────────────────────────────────┤
│  DashboardController.updateSummary()│
│  HistoryController.loadRecords()    │
└─────────────────────────────────────┘
    ↓
UI Updates (Obx() rebuilds)
```

### **2. Data Persistence:**

```
AttendanceService
    ↓
SharedPreferences (Local Storage)
    ↓
Key Format: "attendance_YYYY-MM-DD"
    ↓
Value Format: JSON
{
  "sessions": [
    {
      "checkIn": "09:00",
      "checkOut": "17:00",
      "duration": "8h 0m"
    }
  ]
}
```

### **3. Data Retrieval:**

```
Controller needs data
    ↓
AttendanceService.getAllAttendance()
    ↓
SharedPreferences.getKeys()
    ↓
Filter by prefix "attendance_"
    ↓
Parse JSON → AttendanceModel
    ↓
Return Map<String, AttendanceModel>
    ↓
Controller processes data
    ↓
Update reactive variables (.obs)
    ↓
UI rebuilds (Obx())
```

---

## 🎯 Feature Breakdown

### **1. Authentication (auth/)**

**Purpose:** User login and registration

**Components:**
- **`AuthController`**: 
  - Validates email/password
  - Manages login/register state
  - Stores user in SharedPreferences
  - Handles logout

- **`LoginView`**: Login UI with validation
- **`RegisterView`**: Registration UI with password strength

**Flow:**
```
Login → Validate → Save user → Navigate to Home
```

---

### **2. Home (home/)**

**Purpose:** Main check-in/check-out interface

**Components:**
- **`HomeController`**:
  - Manages check-in/check-out logic
  - Tracks current status
  - Notifies other controllers on changes
  - Loads today's attendance

- **`HomeView`**:
  - Contains bottom navigation
  - Uses `IndexedStack` for tab management
  - Initializes all controllers permanently

**Key Features:**
- Multiple sessions per day support
- Real-time status updates
- Automatic notification to Dashboard/History

---

### **3. Dashboard (dashboard/)**

**Purpose:** Display attendance statistics

**Components:**
- **`DashboardController`**:
  - Calculates weekly days (unique days)
  - Calculates monthly days (unique days)
  - Calculates total time worked (sum of all sessions)
  - Supports month/year filtering

- **`DashboardView`**:
  - Displays summary cards
  - Month/year picker
  - Reactive updates via Obx()

**Metrics:**
- **Weekly Days**: Unique days with completed sessions in current week
- **Monthly Days**: Unique days with completed sessions in selected month
- **Total Time**: Sum of all session durations in selected month

---

### **4. History (history/)**

**Purpose:** Display detailed attendance records

**Components:**
- **`HistoryController`**:
  - Loads all attendance records
  - Filters by month/year
  - Flattens sessions (each session = separate record)
  - Manages expandable list state

- **`HistoryView`**:
  - List of attendance records
  - Expandable cards for details
  - Session numbers for multiple sessions per day
  - Month/year filter

**Data Structure:**
- Each session appears as separate record
- Sorted by date (newest first), then by session index

---

### **5. Profile (profile/)**

**Purpose:** User settings and preferences

**Components:**
- **`ProfileController`**:
  - Manages theme switching (light/dark)
  - Loads user information
  - Saves preferences to SharedPreferences

- **`ProfileView`**:
  - User info display
  - Theme toggle switch
  - Logout option

---

## 🔧 Core Services

### **AttendanceService**

**Purpose:** Centralized data access layer

**Key Methods:**
```dart
// Add new check-in session
addCheckIn(String date, String checkInTime)

// Add check-out to last session
addCheckOut(String date, String checkOutTime, String duration)

// Get attendance for specific date
getAttendance(String date) → AttendanceModel?

// Get all attendance records
getAllAttendance() → Map<String, AttendanceModel>

// Get today's date string
today → String (format: "YYYY-MM-DD")
```

**Storage Strategy:**
- One key per date: `"attendance_YYYY-MM-DD"`
- Each date can have multiple sessions
- JSON serialization for complex data
- Backward compatible with old format

---

## 🔄 Controller Communication

### **Notification Pattern:**

When check-in/check-out happens:

```dart
HomeController.checkIn()
    ↓
Save to storage
    ↓
_notifyAttendanceChanged()
    ↓
┌─────────────────────────────────────┐
│  Find & Update Controllers          │
├─────────────────────────────────────┤
│  Get.find<DashboardController>()    │
│  .updateSummary()                   │
│                                      │
│  Get.find<HistoryController>()      │
│  .loadRecords()                      │
└─────────────────────────────────────┘
    ↓
Reactive variables update
    ↓
Obx() widgets rebuild
    ↓
UI updates automatically
```

### **Why This Works:**
1. **Permanent Controllers**: All controllers initialized in `HomeView` with `permanent: true`
2. **Synchronous Updates**: Controllers update immediately after data save
3. **Reactive UI**: `Obx()` automatically rebuilds when `.obs` variables change

---

## 💾 Data Model

### **AttendanceSession**
```dart
class AttendanceSession {
  final String checkIn;        // "09:00"
  final String? checkOut;      // "17:00" or null
  final String? duration;      // "8h 0m" or null
}
```

### **AttendanceModel**
```dart
class AttendanceModel {
  final List<AttendanceSession> sessions;  // Multiple sessions per day
}
```

### **Storage Format:**
```json
{
  "sessions": [
    {
      "checkIn": "09:00",
      "checkOut": "12:00",
      "duration": "3h 0m"
    },
    {
      "checkIn": "13:00",
      "checkOut": "17:00",
      "duration": "4h 0m"
    }
  ]
}
```

---

## 🎨 UI/UX Features

### **1. Reactive Updates**
- All UI updates automatically via `Obx()`
- No manual `setState()` calls needed
- Real-time updates across tabs

### **2. State Persistence**
- `IndexedStack` maintains tab state
- Controllers persist across tab switches
- Data persists in SharedPreferences

### **3. Theme Support**
- Light/Dark mode toggle
- Preference saved in SharedPreferences
- App-wide theme application

### **4. Validation**
- Real-time form validation
- Password strength indicator
- Error messages displayed inline

---

## 🚀 App Initialization Flow

```
1. main() function
   ↓
2. WidgetsFlutterBinding.ensureInitialized()
   ↓
3. Initialize SharedPreferences
   ↓
4. Register SharedPreferences in GetX
   ↓
5. Initialize AttendanceService (async)
   ↓
6. Run AttendanceApp widget
   ↓
7. GetMaterialApp configured:
   - Theme (light/dark)
   - Routes
   - Initial route: Login
   ↓
8. LoginView displayed
   ↓
9. After login → HomeView
   ↓
10. All controllers initialized permanently
   ↓
11. Bottom navigation active
```

---

## 🔐 Key Design Decisions

### **1. Why IndexedStack?**
- Maintains state across tab switches
- Better performance (no rebuild on tab change)
- Controllers stay alive

### **2. Why Permanent Controllers?**
- Ensures controllers always available
- Allows cross-controller communication
- Prevents "controller not found" errors

### **3. Why Multiple Sessions Per Day?**
- Supports real-world scenarios
- User can check in/out multiple times
- Each session tracked separately

### **4. Why SharedPreferences?**
- Simple key-value storage
- No database setup needed
- Sufficient for attendance data
- Fast and reliable

---

## 📝 Best Practices Used

1. **Separation of Concerns**: MVC pattern with clear boundaries
2. **Dependency Injection**: GetX DI for loose coupling
3. **Reactive Programming**: GetX reactive variables for automatic updates
4. **Service Layer**: Centralized data access
5. **Error Handling**: Try-catch blocks with debug prints
6. **Code Organization**: Feature-based folder structure
7. **Backward Compatibility**: Legacy data format support

---

## 🐛 Debugging Features

- Extensive `print()` statements for tracing
- Controller initialization logs
- Data save/load verification
- UI rebuild tracking
- Error logging with emojis for easy identification

---

## 📚 Summary

This Attendance Tracker app is built with:
- **Flutter** for UI
- **GetX** for state management, routing, and DI
- **SharedPreferences** for local storage
- **MVC architecture** for code organization
- **Reactive programming** for automatic UI updates
- **Feature-based structure** for scalability

The app supports multiple check-in/check-out sessions per day, real-time updates across all screens, and persistent data storage.

