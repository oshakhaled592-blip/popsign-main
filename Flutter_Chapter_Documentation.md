# Chapter 7 — Flutter (I Hear You Application)

---

## 7.1 Introduction to Flutter and Dart

### What is Flutter?

Flutter is an open-source UI software development toolkit created by **Google**. It is used for building natively compiled applications for **mobile (Android and iOS)**, **web**, **desktop**, and even **embedded devices**, all from a **single codebase**. Launched officially in 2017, Flutter quickly gained popularity due to its performance, flexibility, and developer-friendly architecture.

### Key Features of Flutter:

- **Cross-Platform Development**: Write your code once and run it anywhere. No need to maintain separate codebases for Android and iOS.
- **Native Performance**: Flutter compiles down to native ARM code using Dart, which ensures smooth performance.
- **Beautiful UI**: Flutter provides a rich set of widgets that mimic the behavior of native components.
- **Hot Reload**: Allows developers to instantly see UI changes without restarting the app.
- **Custom Rendering Engine**: Flutter uses its own rendering engine (Skia/Impeller) ensuring consistent UI across all platforms.

### Understanding Dart

Dart is the programming language used to build Flutter applications. It is developed by **Google** and designed for fast, modern, reactive apps.

**Why Dart?**

- **Optimized for UI**: Handles layout expressions, smooth animations, and declarative programming.
- **Object-Oriented and Class-Based**: Strong support for classes, inheritance, interfaces, and mixins.
- **AOT & JIT Compilation**: AOT for production performance; JIT for hot reload during development.
- **Strongly Typed with Null Safety**: Prevents null reference errors at compile time, improving stability.

### Why Flutter was chosen for I Hear You

The I Hear You application targets **sign language learners** on both Android and iOS. Flutter was selected because:

- A single codebase covers both platforms simultaneously.
- The rich widget ecosystem supports complex UI interactions like flashcard animations and video playback.
- The `flutter_screenutil` package ensures fully responsive layouts across all screen sizes.
- Firebase integration is first-class with official Flutter packages.

---

## 7.2 Project Structure in Flutter

### Overview

The I Hear You project follows a **feature-based layered architecture** that separates concerns clearly and enables scalability. The root directory contains a `lib/` folder housing all Dart source code, divided into `core/` (shared utilities) and `features/` (screen-specific modules).

### Folder Structure

```
lib/
├── core/
│   ├── helpers/
│   │   └── spacing.dart
│   ├── l10n/
│   │   └── app_strings.dart
│   ├── models/
│   │   └── prediction_model.dart
│   ├── routing/
│   │   ├── app_router.dart
│   │   └── routes.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── chat_service.dart
│   │   └── translation_service.dart
│   ├── state/
│   │   └── translation_notifier.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── font_weights_helper.dart
│   │   ├── language_notifier.dart
│   │   ├── styles.dart
│   │   └── theme_notifier.dart
│   └── widgets/
│       ├── linear_button.dart
│       ├── logo_and_name.dart
│       └── text_form_widget.dart
├── features/
│   ├── auth/
│   │   ├── login/
│   │   │   └── ui/
│   │   │       ├── screen/
│   │   │       │   ├── login_screen.dart
│   │   │       │   ├── forgot_password_screen.dart
│   │   │       │   └── change_password_screen.dart
│   │   │       └── widgets/
│   │   │           └── dont_have_account.dart
│   │   └── signup/
│   │       └── ui/
│   │           └── screen/
│   │               ├── signup_screen.dart
│   │               └── check_email_screen.dart
│   └── initialization/
│       └── ui/
│           ├── screens/
│           │   ├── splash_screen.dart
│           │   ├── start_page_screen.dart
│           │   ├── get_started_screen.dart
│           │   ├── onboarding_screen.dart
│           │   ├── choose_language_screen.dart
│           │   ├── about_you_screen.dart
│           │   ├── purpose_screen.dart
│           │   ├── level_intro_screen.dart
│           │   ├── level_options_screen.dart
│           │   ├── study_time_screen.dart
│           │   ├── select_categories_screen.dart
│           │   ├── dashboard_screen.dart
│           │   ├── levels_screen.dart
│           │   ├── pre_start_screen.dart
│           │   ├── word_list_screen.dart
│           │   ├── sign_practice_screen.dart
│           │   ├── chat_screen.dart
│           │   ├── lost_page_screen.dart
│           │   ├── account_info_screen.dart
│           │   ├── profile._screen.dart
│           │   └── reset_screen.dart
│           └── widgets/
│               └── quiz_step_scaffold.dart
└── main.dart
```

### Layer Descriptions

- **core/helpers/**: Utility functions such as `verticalSpace()` and `horizontalSpace()` for consistent widget spacing.
- **core/l10n/**: The `app_strings.dart` file contains all user-facing strings across 10 languages (English, Arabic, Spanish, French, Russian, German, Italian, Turkish, Japanese, Chinese, Korean, Portuguese, Hindi, Dutch).
- **core/models/**: Data models for API responses (e.g., `PredictionResult`, `PredictionItem`).
- **core/routing/**: Named route definitions and `AppRouter` for centralised navigation.
- **core/services/**: Service classes that abstract all external communication — backend REST API calls, Firebase Auth, and the AI translation server.
- **core/state/**: `TranslationNotifier` — a `ChangeNotifier` that manages the sign-language translation feature state.
- **core/theme/**: Theme configuration, text styles (`AppTextStyles`), color definitions (`AppColors`), and notifiers for dark/light mode and language switching.
- **core/widgets/**: Reusable UI components: `LinearButton` (gradient CTA button), `TextFormWidget` (styled input field with show/hide password), and `LogoAndName`.
- **features/auth/**: All authentication screens (login, signup, email verification, password reset).
- **features/initialization/**: All post-authentication screens from the splash screen through the full onboarding quiz, learning dashboards, and profile management.
- **main.dart**: App entry point — loads saved theme from `SharedPreferences` before `runApp()` so the splash screen always renders with the user's correct theme.

---

## 7.3 UI Components and Navigation

### Design System

The app uses a consistent design system built around two themes — **Dark** and **Light** — toggled in real time via the `themeNotifier` (`ValueNotifier<ThemeMode>`).

**Color Palette:**

| Role | Dark Mode | Light Mode |
|---|---|---|
| Background | `#0B1020` / `#0D0F1A` | `#F5F7FB` |
| Card Surface | `#141829` / `#181830` | `#FFFFFF` |
| Primary Accent | `#22C55E` (green) | `#22C55E` (green) |
| Button Gradient | `linear1` → `linear2` | `linear1` → `linear2` |
| Text Primary | `#FFFFFF` | `#1A1A2E` |
| Text Secondary | `rgba(255,255,255,0.54)` | `#6B7280` |

**Typography (AppTextStyles):**

All font sizes use `.sp` from `flutter_screenutil` for proper scaling:

```dart
static TextStyle font36BoldWhite = GoogleFonts.openSans(
  fontWeight: FontWeightHelper.bold,
  fontSize: 36.sp,
  color: Colors.white,
);
```

All text styles support theme overrides via `.copyWith(color: textColor)`.

### Responsive Design with flutter_screenutil

Every dimension in the app uses `flutter_screenutil` with a **design size of 390×844 (iPhone 14 equivalent)**:

```dart
ScreenUtilInit(
  designSize: const Size(390, 844),
  minTextAdapt: true,
  builder: (context, child) { ... },
)
```

- Width values: `.w` (e.g., `24.w`)
- Height values: `.h` (e.g., `16.h`)
- Font sizes: `.sp` (e.g., `14.sp`)
- Border radii: `.r` (e.g., `12.r`)

This ensures the UI scales correctly across all Android and iOS screen sizes without hardcoded pixel values.

### Reusable Widgets

**LinearButton** — the primary CTA button with a gradient background:

```dart
LinearButton(
  text: S.get('get_started'),
  onPressed: () => Navigator.pushNamed(context, Routes.login),
  width: double.infinity.w,
  radius: 14.r,
)
```

**TextFormWidget** — a styled input field with built-in show/hide for password fields:

```dart
TextFormWidget(
  controller: _emailCtrl,
  hintText: S.get('email'),
  icon: Icons.email_outlined,
  keyboardType: TextInputType.emailAddress,
  validator: (v) => (v ?? '').isEmpty ? S.get('email_required') : null,
)
```

**LogoAndName** — the app logo and title, theme-aware:

```dart
class LogoAndName extends StatelessWidget {
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(children: [
      SvgPicture.asset('assets/svgs/app-logo.svg', height: 81.h, width: 67.w),
      Text("I Hear You",
        style: AppTextStyles.font36SemiboldWhite.copyWith(
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        )),
    ]);
  }
}
```

### Navigation

The app uses **Named Routes** with a central `AppRouter` class:

```dart
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:     return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Routes.login:      return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.dashboard:  return MaterialPageRoute(builder: (_) => const DashboardScreen());
      // ...
    }
  }
}
```

**Navigation Flow:**

```
SplashScreen
    │
    ├─► StartPageScreen ──► GetStartedScreen ──► OnboardingScreen
    │                                                    │
    │                                           ChooseLanguageScreen
    │                                                    │
    │                                           AboutYouScreen ──► PurposeScreen
    │                                                    │
    │                                           LevelIntroScreen ──► LevelOptionsScreen
    │                                                    │
    │                                           StudyTimeScreen ──► LoginScreen
    │
    └─► (already logged in)
            │
            └─► DashboardScreen
                    │
                    ├─► LevelsScreen ──► PreStartScreen ──► WordListScreen ──► SignPracticeScreen
                    ├─► LostPageScreen (Translation)
                    ├─► ChatScreen (AI Sign Assistant)
                    └─► ProfileScreen ──► AccountInfoScreen
```

`SharedPreferences` flags control which route is shown at startup:
- `isLoggedIn`: Skip auth screens if already authenticated
- `hasSelectedLevel`: Skip onboarding if level was previously chosen

---

## 7.4 State Management

### Overview

The I Hear You app uses a **lightweight, pragmatic state management approach** without heavy global state libraries like BLoC or Provider. State is handled through three complementary mechanisms:

1. **`ValueNotifier`** for global reactive app state (theme, language)
2. **`ChangeNotifier`** for feature-specific complex state (translation)
3. **`SharedPreferences`** for persisted user state across sessions
4. **`setState`** for local screen-level state

### 1. ValueNotifier — Theme and Language

**Theme Notifier** (`theme_notifier.dart`):

```dart
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);
```

Used in `main.dart` to rebuild `MaterialApp` when the user toggles dark/light mode:

```dart
ValueListenableBuilder<ThemeMode>(
  valueListenable: themeNotifier,
  builder: (context, mode, _) => MaterialApp(
    themeMode: mode,
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    ...
  ),
)
```

The theme choice is **persisted to `SharedPreferences`** (`isDark`) and loaded before `runApp()` so the splash screen always shows the correct theme immediately:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(...);
  final prefs = await SharedPreferences.getInstance();
  final savedDark = prefs.getBool('isDark');
  if (savedDark != null) {
    themeNotifier.value = savedDark ? ThemeMode.dark : ThemeMode.light;
  }
  runApp(const IHeartYouApp());
}
```

**Language Notifier** (`language_notifier.dart`):

```dart
final languageNotifier = ValueNotifier<LanguageInfo>(
  LanguageInfo(code: 'en', name: 'English', flag: '🇺🇸'),
);
```

All text in the app is served through the `S.get(key)` helper, which reads the current language code from `languageNotifier` and returns the correct string from `AppStrings._t`. Screens add listeners to rebuild on language change:

```dart
@override
void initState() {
  super.initState();
  languageNotifier.addListener(_rebuild);
}
void _rebuild() => setState(() {});
```

### 2. ChangeNotifier — Translation Feature

`TranslationNotifier` (`translation_notifier.dart`) manages the full lifecycle of a sign-language video translation request:

```dart
enum TranslationStatus { idle, loading, success, error }
enum ServerStatus { unknown, online, offline }

class TranslationNotifier extends ChangeNotifier {
  TranslationStatus _status = TranslationStatus.idle;
  PredictionResult? _result;
  ServerStatus _serverStatus = ServerStatus.unknown;
  List<String> _classes = [];
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> predict(File video) async {
    _status = TranslationStatus.loading;
    _notify();
    try {
      _result = await _service.predict(video);
      _status = TranslationStatus.success;
      _sentence.add(_result!.top);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = TranslationStatus.error;
    }
    _notify();
  }
}
```

The disposed flag prevents `notifyListeners()` from being called after the widget is removed from the tree — a common Flutter pitfall when async operations outlive their widget.

### 3. SharedPreferences — Persistent State

The following keys are persisted across sessions:

| Key | Type | Purpose |
|---|---|---|
| `isDark` | bool | Theme preference |
| `isLoggedIn` | bool | Authentication gate |
| `hasSelectedLevel` | bool | Skip onboarding on next launch |
| `userLevel` | String | Selected CEFR level (A1–C2) |
| `authToken` | String | Backend JWT token |
| `userEmail` | String | Logged-in user email |
| `localEmail` | String | Email entered during signup |
| `userName` | String | Display name |
| `langCode` | String | Selected learning language code |
| `langName` | String | Selected learning language name |
| `langFlag` | String | Flag emoji for selected language |
| `userPurpose` | String | Reason for learning (family, work…) |
| `userMinutesPerDay` | int | Daily study time goal |

### 4. setState — Local Screen State

Individual screens use `setState` for transient UI state such as form input, loading indicators, and selection state:

```dart
bool _isLoading = false;

Future<void> _submit() async {
  setState(() => _isLoading = true);
  final result = await AuthService().login(email: ..., password: ...);
  if (!mounted) return;
  setState(() => _isLoading = false);
  // handle result...
}
```

The `mounted` check before any `setState` call after an `await` prevents "setState called after dispose" errors.

---

## 7.5 API Integration

### Backend REST API

The app communicates with a backend server at `http://91.108.113.135` using the standard Dart `http` package. All API logic is encapsulated in the `AuthService` class, keeping UI code free of HTTP concerns.

**AuthService Pattern:**

```dart
class AuthResult {
  final bool success;
  final String message;
  AuthResult({required this.success, required this.message});
}

class AuthService {
  static const _base = 'http://91.108.113.135';
  static const _timeout = Duration(seconds: 20);
  final _fb = FirebaseAuth.instance;
  // ...
}
```

Every method returns an `AuthResult` with a `success` flag and a user-facing `message`, keeping error handling uniform across the app.

**Active Backend Endpoints:**

| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/api/auth/signup` | Register a new user |
| GET | `/api/auth/verify/:token` | Verify email with token |
| POST | `/api/auth/login` | Authenticate and receive JWT |

**Login Flow:**

```dart
Future<AuthResult> login({required String email, required String password}) async {
  final res = await http.post(
    Uri.parse('$_base/api/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  ).timeout(_timeout);

  final json = _decode(res);

  // Save token early — present even in verify-required responses
  final token = _extractToken(json);
  if (token != null) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    await prefs.setString('userEmail', email);
  }

  if (json['success'] != true) {
    return AuthResult(success: false, message: json['message'] ?? 'Login failed');
  }

  // Mirror into Firebase for password-management operations
  await _signIntoFirebase(email, password);

  return AuthResult(success: true, message: json['message'] ?? 'Logged in');
}
```

The token is extracted and saved **before** checking `json['success']` so it is available even when the backend returns a "verify your email" message — which some login flows send alongside the token.

### Firebase Auth Integration

Firebase Auth (`firebase_auth: ^6.5.2`) is integrated as a **secondary auth layer** for password-management operations that the backend does not support. During login, the app also signs into Firebase so that password-change operations can be performed later without re-authentication.

**Firebase Sign-in Helper:**

```dart
Future<void> _signIntoFirebase(String email, String password) async {
  try {
    await _fb.signInWithEmailAndPassword(email: email, password: password);
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      try {
        await _fb.createUserWithEmailAndPassword(email: email, password: password);
      } catch (_) {}
    }
  }
}
```

**Password Reset (Firebase Email Link):**

```dart
Future<void> sendPasswordReset(String email) async {
  try {
    await _fb.sendPasswordResetEmail(email: email);
  } on FirebaseAuthException catch (e) {
    throw Exception(_fbError(e));
  }
}
```

**Firebase Error Mapping:**

```dart
String _fbError(FirebaseAuthException e) {
  switch (e.code) {
    case 'wrong-password':
    case 'invalid-credential':  return 'Current password is incorrect.';
    case 'user-not-found':      return 'No account found for this email.';
    case 'weak-password':       return 'New password is too weak (min 6 characters).';
    case 'requires-recent-login': return 'Please log out and log in again, then retry.';
    case 'too-many-requests':   return 'Too many attempts. Please try again later.';
    default:                    return e.message ?? 'An error occurred.';
  }
}
```

### Translation Service

The sign-language translation feature connects to a separate AI server through `TranslationService`:

```dart
class TranslationService {
  final _base = 'http://91.108.113.135';

  Future<bool> checkHealth() async {
    final res = await http.get(Uri.parse('$_base/health')).timeout(...);
    return res.statusCode == 200;
  }

  Future<PredictionResult> predict(File videoFile) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_base/predict'));
    request.files.add(await http.MultipartFile.fromPath('video', videoFile.path));
    final streamed = await request.send().timeout(...);
    final res = await http.Response.fromStream(streamed);
    return PredictionResult.fromJson(jsonDecode(res.body));
  }
}
```

### Chat Service

The AI Sign Assistant screen uses `ChatService` for a conversational interface:

```dart
class ChatService {
  Future<String> newSession() async {
    final res = await http.post(Uri.parse('$_base/session/new'), ...);
    return jsonDecode(res.body)['session_id'];
  }

  Future<String> sendMessage({required String sessionId, required String message}) async {
    final res = await http.post(Uri.parse('$_base/chat'), body: jsonEncode({
      'session_id': sessionId, 'message': message
    }), ...);
    return jsonDecode(res.body)['response'];
  }
}
```

---

## 7.6 Screens Overview and Implementation

### Authentication Screens

#### Splash Screen

**Purpose:** Entry point. Determines which screen to navigate to based on saved session state.

**Key logic:**
- Reads `isLoggedIn` and `hasSelectedLevel` from `SharedPreferences`
- If logged in and level selected → navigate to Dashboard
- If logged in but no level → navigate to onboarding (language selection)
- Otherwise → navigate to StartPage

The splash screen is **fully theme-aware**: background, text, and sub-text colors are derived from `Theme.of(context).brightness`, and the correct theme is loaded from `SharedPreferences` before `runApp()` so there is no flash of the wrong theme.

#### Start Page Screen

**Purpose:** Welcome screen with animated logo and tagline, offering "Get Started" and "Login" actions.

**Key Features:**
- Animated logo entrance
- Theme-aware text colors (white on dark, `#1A1A2E` on light)
- Localised button labels via `S.get('get_started')` and `S.get('login')`

#### Get Started Screen

**Purpose:** A brief marketing screen explaining the app's value, with a CTA to begin onboarding.

#### Login Screen

**Purpose:** Authenticates existing users.

**Fields:** Email, Password (with show/hide toggle)  
**Actions:** Login, Forgot Password, Sign Up redirect

**Implementation highlights:**
- Uses `TextFormWidget` for styled inputs with built-in validation
- Calls `AuthService().login()` on submit
- Shows error snackbar on failure
- Navigates to Dashboard on success; handles "verify email" bypass gracefully
- Theme-aware layout adapting colors for dark and light modes

```dart
Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);
  final result = await AuthService().login(
    email: _emailCtrl.text.trim(),
    password: _passCtrl.text.trim(),
  );
  if (!mounted) return;
  setState(() => _isLoading = false);
  if (result.success || result.message.toLowerCase().contains('verify')) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    // navigate based on level selection state...
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
  }
}
```

#### Signup Screen

**Purpose:** Registers new users.

**Fields:** Email, Password, Confirm Password  
**Actions:** Sign Up, login redirect

**Implementation highlights:**
- Password match validation client-side before API call
- Saves `localEmail` to `SharedPreferences` so the Check Email screen knows where to display
- Calls `AuthService().signup()` which also mirrors the account to Firebase

#### Check Email Screen

**Purpose:** Informs the user to verify their email before continuing. Displayed after successful signup.

#### Forgot Password Screen

**Purpose:** Allows users to request a password reset email from Firebase.

**Field:** Email  
**Action:** "Send Reset Link" triggers `AuthService().sendPasswordReset(email)` which calls Firebase `sendPasswordResetEmail()`. A dialog confirms the email was sent and navigates back to Login.

---

### Onboarding / Quiz Screens

The onboarding flow collects user preferences through a series of conversational quiz steps, all wrapped in the reusable `QuizStepScaffold` widget.

#### QuizStepScaffold Widget

A shared layout for every quiz step providing consistent header, progress indicator, and content area:

```dart
class QuizStepScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? bottomBar;
  // ...
}
```

#### Choose Language Screen

**Purpose:** The user selects which language they want to learn (10 options available).

**Languages supported:** English, Spanish, French, Russian, Arabic, German, Italian, Turkish, Japanese, Chinese, Korean, Portuguese, Hindi, Dutch

Selection is saved to `SharedPreferences` as `langCode`, `langName`, and `langFlag`.

#### About You Screen

**Purpose:** The user indicates their existing knowledge level (beginner vs. already studied).

#### Purpose Screen

**Purpose:** The user selects their motivation for learning:
- Immigrant family
- Entertainment & Culture
- Work
- Travel

Saved as `userPurpose` in `SharedPreferences`.

#### Level Intro Screen

**Purpose:** Explains the CEFR level system and invites the user to choose their level.

#### Level Options Screen

**Purpose:** Displays the six CEFR levels (Beginner, Elementary, Intermediate, Upper Intermediate, Advanced, Proficient) and a "Not sure" guidance note.

Selected level saved as `userLevel`.

#### Study Time Screen

**Purpose:** Lets the user set a daily study goal in minutes (e.g., 5, 10, 15, 20 min/day).

Saved as `userMinutesPerDay`.

After this screen, `hasSelectedLevel = true` is saved and the user is routed to Dashboard.

---

### Learning Screens

#### Dashboard Screen

**Purpose:** The main hub displaying learning progress, current level, words learned, and navigation to levels.

**Displayed information:**
- Current CEFR level
- Number of words learned
- Number of levels completed
- Progress in the current level
- Navigation to the Levels screen

Data is computed from `SharedPreferences` (level selection, known words tracking per level stored as JSON).

#### Levels Screen

**Purpose:** Shows all available CEFR levels with progress bars indicating completion percentage.

Each level card shows:
- Level name and label (A1–C2)
- Number of words total
- Number of words already learned
- Circular or linear progress indicator
- Lock/unlock status

#### Pre-Start Screen

**Purpose:** A motivational interstitial before beginning a word list, showing what to expect in the upcoming session.

#### Word List Screen

**Purpose:** The core learning screen — a flashcard-style interface for learning sign-language vocabulary.

**Interactions:**
- "Learn" button: marks a word as unknown, keeps it in the queue
- "I Know" button: marks a word as known, saves to `SharedPreferences`
- Progress bar at the top shows session completion

**State management:**
- Local `setState` for current card index and known/unknown tracking
- On session completion, updates the level progress in `SharedPreferences`
- Navigates to the Sign Practice screen for known words

#### Sign Practice Screen

**Purpose:** After learning a word, the user can practice signing it by recording or uploading a video. The app uses the AI translation service to verify the signed word.

**Features:**
- Camera permission request via `permission_handler`
- Video picker from gallery via `image_picker`
- Video preview using `video_player`
- Submission to the backend AI model
- Result display: "Correct!" with green feedback or "Not quite!" with the expected vs. detected sign

```dart
Future<void> _analyzeVideo(File video) async {
  notifier.predict(video); // updates TranslationNotifier state
}

// In build():
BlocConsumer equivalent using ValueListenableBuilder + ChangeNotifier:
if (notifier.isLoading) return CircularProgressIndicator();
if (notifier.isSuccess) return CorrectResultWidget(result: notifier.result!);
if (notifier.isError) return ErrorWidget(message: notifier.error);
```

---

### Translation Screen (Lost Page Screen)

**Purpose:** Upload a sign-language video and receive an instant text translation — the "Translate Any Sign" feature.

**Features:**
- Server health indicator (Online / Offline / Checking…)
- Supported signs list (fetched from backend)
- Video upload from gallery or camera
- Loading indicator while the AI model processes the video
- Result display: translated word, confidence percentage, and alternative possibilities
- Accumulated sentence builder — the user can translate multiple signs to build a sentence
- Long-press a word in the sentence to remove it

**State managed by `TranslationNotifier`:**

| State | UI |
|---|---|
| `idle` | Upload prompt with icon |
| `loading` | `CircularProgressIndicator` with "Analyzing…" message |
| `success` | Translation result card with top prediction and alternatives |
| `error` | Error message with retry option |

---

### AI Chat Screen

**Purpose:** A conversational AI assistant specialising in sign language questions — "What are the app's features?", "How do I say hello in sign language?", etc.

**Features:**
- Session management (new session on first message, maintains context)
- Speech-to-text input via `speech_to_text` package with microphone permission
- Chat bubble UI (user bubbles right, assistant bubbles left)
- Typing indicator animation (three dots)
- Server health badge (Online / Offline)
- Clear chat button (deletes session history on server)
- Common question shortcuts pre-populated on empty state

**Robot avatar widget** — a custom-drawn widget (`RobotIcon`) that renders a stylised robot face using nested `Container` layers, built entirely in Flutter without image assets.

**Key implementation:**

```dart
Future<void> _sendMessage([String? override]) async {
  final text = override ?? _inputController.text.trim();
  if (text.isEmpty) return;
  setState(() {
    _messages.add(_ChatMessage(text: text, isUser: true));
    _isTyping = true;
  });
  _inputController.clear();
  _scrollToBottom();

  String reply;
  try {
    final sessionId = await _ensureSession();
    reply = await _service.sendMessage(sessionId: sessionId, message: text);
  } catch (_) {
    reply = "Sorry, I couldn't reach the server. Please check your connection.";
  }
  setState(() {
    _isTyping = false;
    _messages.add(_ChatMessage(text: reply, isUser: false));
  });
  _scrollToBottom();
}
```

---

### Profile & Settings Screens

#### Profile Screen

**Purpose:** User account management hub.

**Settings tiles:**
- **Dark Mode** — switch toggle that updates `themeNotifier` and saves to `SharedPreferences`
- **Account Information** — navigates to AccountInfoScreen
- **Password** — shows "Coming Soon" snackbar (no navigation)
- **Translate** — navigates to the Lost Page translation screen
- **My Progress** — navigates to the Levels screen

**User card** at the top shows:
- Profile avatar (asset image)
- Display name (editable via dialog, saved to `SharedPreferences`)
- Verified badge

**Logout** clears all `SharedPreferences` keys except `hasSelectedLevel` and `userLevel` (preserved so the next login skips onboarding).

#### Account Info Screen

**Purpose:** Displays the user's account details (email, name, account type) in a read-only card layout.

---

## 7.7 Multi-Language Support

### Implementation

The app supports **10 languages** for the UI interface. All user-facing strings are defined in `AppStrings._t` — a nested map of language codes to string maps:

```dart
class S {
  static String get(String key) {
    final code = languageNotifier.value.code;
    return _t[code]?[key] ?? _t['en']![key] ?? key;
  }

  static const _t = <String, Map<String, String>>{
    'en': { 'login': 'Login', 'signup': 'Sign Up', ... },
    'ar': { 'login': 'تسجيل الدخول', 'signup': 'إنشاء حساب', ... },
    'sp': { 'login': 'Iniciar sesión', ... },
    // ... 10 languages total
  };
}
```

The lookup falls back to English if a key is not defined in the current language, preventing any missing-string crashes.

**Supported UI Languages:**

| Code | Language |
|---|---|
| `en` | English |
| `ar` | Arabic |
| `sp` | Spanish |
| `fr` | French |
| `ru` | Russian |
| `ge` | German |
| `it` | Italian |
| `tu` | Turkish |
| `ja` | Japanese |
| `ch` | Chinese |
| `ko` | Korean |
| `po` | Portuguese |
| `hi` | Hindi |
| `du` | Dutch |

---

## 7.8 Key Packages and Dependencies

| Package | Version | Purpose |
|---|---|---|
| `firebase_auth` | ^6.5.2 | User authentication and password management |
| `firebase_core` | ^4.10.0 | Firebase initialisation |
| `cloud_firestore` | ^6.5.0 | Cloud database (available for future features) |
| `flutter_screenutil` | ^5.9.3 | Responsive UI scaling (designSize 390×844) |
| `http` | ^1.2.1 | REST API calls to backend and AI servers |
| `shared_preferences` | ^2.2.3 | Persistent local storage for user state |
| `flutter_svg` | ^2.2.4 | SVG asset rendering (logo) |
| `google_fonts` | ^8.0.2 | Poppins, Open Sans, Inter font families |
| `video_player` | ^2.9.1 | Video preview in sign practice screen |
| `image_picker` | ^1.1.2 | Gallery and camera video selection |
| `speech_to_text` | ^7.0.0 | Voice input for AI chat screen |
| `permission_handler` | ^11.3.1 | Runtime permission requests (microphone, storage) |
| `flutter_local_notifications` | ^17.2.2 | Local push notifications |
| `url_launcher` | ^6.3.1 | Opening external links |
| `flutter_native_splash` | ^2.4.7 | Native splash screen configuration |
| `flutter_launcher_icons` | ^0.14.4 | App icon generation |

---

## 7.9 Performance and Best Practices

### Responsive Design

All dimensions use `flutter_screenutil` — no hardcoded pixel values exist anywhere in the UI layer. The design size of 390×844 matches the iPhone 14 baseline, and all values scale proportionally on larger/smaller screens.

### Theme Consistency

The theme is loaded from `SharedPreferences` **before** `runApp()` in `main.dart`. This eliminates the flash-of-incorrect-theme problem where the splash screen would momentarily appear in the wrong mode.

### Async Safety

Every async method that calls `setState` includes a `mounted` guard:

```dart
if (!mounted) return;
setState(() { ... });
```

`TranslationNotifier` uses a `_disposed` flag to prevent `notifyListeners()` from being called after the notifier is disposed — protecting against the `ChangeNotifier.debugAssertNotDisposed` error.

### Memory Management

All screens that add listeners to `ValueNotifier` objects (`themeNotifier`, `languageNotifier`) remove those listeners in `dispose()`:

```dart
@override
void dispose() {
  languageNotifier.removeListener(_rebuild);
  super.dispose();
}
```

### Code Organisation

- Service classes (`AuthService`, `TranslationService`, `ChatService`) encapsulate all external communication.
- Reusable widgets (`LinearButton`, `TextFormWidget`) reduce duplication across screens.
- Named routes centralise navigation logic.
- The `S.get()` system centralises all user-facing strings with automatic language fallback.

---

## 7.10 Summary

The I Hear You Flutter application demonstrates a well-structured, feature-complete mobile app built with modern Flutter practices. Key architectural decisions include:

- **Feature-based folder structure** separating auth, onboarding, and learning modules
- **Lightweight state management** using `ValueNotifier`, `ChangeNotifier`, and `SharedPreferences` without unnecessary complexity
- **Dual-backend integration** — REST API for authentication, Firebase Auth for password management, and a dedicated AI server for sign-language recognition
- **Full responsive design** via `flutter_screenutil` ensuring pixel-perfect layouts on all devices
- **10-language support** with a centralised string lookup and automatic English fallback
- **Dark/Light theme** switching persisted across sessions with no splash-screen flash
- **Reusable component library** (`LinearButton`, `TextFormWidget`, `LogoAndName`) maintaining UI consistency
- **Async safety patterns** (`mounted` checks, `_disposed` flags) preventing common Flutter memory and lifecycle errors

The app provides a complete sign language learning experience: vocabulary flashcards, AI-powered sign recognition practice, a translation tool for live signs, and a conversational AI assistant — all within a polished, accessible, and multilingual interface.
