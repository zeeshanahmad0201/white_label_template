# Flutter White Label Template

A production-ready Flutter white-label template for creating multiple branded apps from a single codebase with automatic Firebase integration.

## Architecture

This template separates **core platform** from **client-specific branding**, allowing you to maintain one codebase while deploying multiple branded applications.

```
/white_label_template/
├── core_platform/              # Shared platform & UI components
│   ├── lib/
│   │   ├── core/
│   │   │   ├── config/             # Configuration schemes
│   │   │   ├── cubits/             # State management
│   │   │   ├── extensions/         # Context extensions
│   │   │   └── utils/              # Responsive sizing utilities
│   │   ├── features/               # Shared features
│   │   ├── main_runner.dart        # Centralized app initialization
│   │   └── app.dart                # Main app widget
├── clients/                    # Individual client applications
└── tools/
    └── create_client.dart     # Automated client generation
```

## Prerequisites

Before using this template, ensure you have the following tools installed:

### Required
- **Flutter SDK** (3.0.0 or higher)
- **Firebase CLI**: `npm install -g firebase-tools`
- **Firebase Account**: Google account with Firebase access

### Auto-installed by Script
- **FlutterFire CLI**: Automatically activated if missing

### Setup
1. **Login to Firebase**: `firebase login`
2. **Verify access**: `firebase projects:list`

## Quick Start

### 1. Generate a New Client

```bash
# Restaurant app (mobile only) - creates new Firebase project
dart tools/create_client.dart -c nyc_biz -n "NYC Restaurant" -p restaurant -f admin@example.com

# Food delivery with web support - creates new Firebase project with hosting
dart tools/create_client.dart -c chicago_eats -n "Chicago Food Delivery" -p food_delivery -f admin@example.com --web

# Use shared/existing Firebase project (multi-tenant)
dart tools/create_client.dart -c acme_client -n "Acme App" -p business -f admin@example.com --firebase-project-id existing-firebase-project --web

# Skip Firebase (development only)
dart tools/create_client.dart -c test_app -n "Test App" -p restaurant --skip-firebase

# Custom organization
dart tools/create_client.dart -c acme_corp -n "Acme App" -p business -o com.acme -f dev@acme.com --web
```

### 2. Run the Generated Client

```bash
cd clients/nyc_biz
flutter run  # Dependencies auto-installed, Firebase configured
```

## Client Structure

Each generated client contains:

```
clients/my_client/
├── lib/
│   ├── main.dart                  # 3-line main (uses MainRunner)
│   ├── client_config.dart         # BaseConfig implementation
│   ├── client_color_scheme.dart   # Color scheme (7+ colors)
│   ├── client_asset_scheme.dart   # Asset paths
│   ├── client_theme_scheme.dart   # Complete theme customization (optional)
│   └── client_design_scheme.dart  # Responsive sizing config (optional)
├── assets/
│   └── images/                    # Client-specific assets
└── .firebaserc                    # Firebase project mapping (if web enabled)
```

## Client Customization

### Minimal Configuration (Required Files)

**1. Color Scheme** (`client_color_scheme.dart`)
```dart
class MyClientColorScheme extends ClientColorScheme {
  @override
  Color get primary => const Color(0xFF2196F3);
  @override
  Color get secondary => const Color(0xFF03A9F4);
  @override
  Color get background => Colors.white;
  @override
  Color get surface => const Color(0xFFF5F5F5);
  @override
  Color get onSurface => Colors.black87;
  @override
  Color get error => Colors.red;
  @override
  Color get success => Colors.green;

  // Optional: Custom onPrimary (defaults to auto-contrast)
  @override
  Color get onPrimary => Colors.white;

  // Optional: Dark mode colors (set ALL or NONE)
  @override
  Color? get backgroundDark => const Color(0xFF121212);
  @override
  Color? get surfaceDark => const Color(0xFF1E1E1E);
  @override
  Color? get onSurfaceDark => Colors.white;
}
```

**2. Assets** (`client_asset_scheme.dart`)
```dart
class MyClientAssetScheme extends ClientAssetScheme {
  @override
  String get appLogo => 'assets/images/logo.png';
  @override
  String get splashBackground => 'assets/images/splash_bg.png';
}
```

**3. Main Configuration** (`client_config.dart`)
```dart
class MyClientConfig extends BaseConfig {
  @override
  String get clientId => 'my_client';
  @override
  String get appName => 'My App';
  @override
  ClientColorScheme get colorScheme => MyClientColorScheme();
  @override
  ClientAssetScheme get assetScheme => MyClientAssetScheme();

  // Optional: Custom theme scheme
  @override
  ClientThemeScheme get themeScheme => MyClientThemeScheme();

  // Optional: Custom design scheme for responsive sizing
  @override
  ClientDesignScheme get designScheme => MyClientDesignScheme();
}
```

**4. Entry Point** (`main.dart`)
```dart
Future<void> main() => MainRunner.run(config: MyClientConfig());
```

**5. Assets** (Add your images to `assets/images/`)

### Advanced Customization (Optional)

**6. Theme Scheme** (`client_theme_scheme.dart`)

Complete control over MaterialApp theme with responsive typography:

```dart
class MyClientThemeScheme extends ClientThemeScheme {
  @override
  String? get fontFamily => 'Roboto';

  @override
  bool get useMaterial3 => true;

  @override
  double get defaultBorderRadius => 12.0;

  @override
  double get defaultElevation => 4.0;

  // Responsive text theme using .fSize for scalable typography
  @override
  TextTheme? buildTextTheme(ClientColorScheme colors) => TextTheme(
    displayLarge: TextStyle(fontSize: 32.fSize, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(fontSize: 24.fSize, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16.fSize),
    bodyMedium: TextStyle(fontSize: 14.fSize),
    labelLarge: TextStyle(fontSize: 14.fSize, fontWeight: FontWeight.w500),
  );

  // Custom elevated button theme
  @override
  ElevatedButtonThemeData? buildElevatedButtonTheme(ClientColorScheme colors) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius.r),
        ),
      ),
    );
  }

  // Custom input decoration theme
  @override
  InputDecorationTheme? buildInputDecorationTheme(
    ClientColorScheme colors, {required bool isDark}
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? colors.surfaceDark : colors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius.r),
      ),
    );
  }

  // Custom card theme
  @override
  CardTheme? buildCardTheme(ClientColorScheme colors, {required bool isDark}) {
    return CardTheme(
      elevation: defaultElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius.r),
      ),
    );
  }

  // Custom app bar theme
  @override
  AppBarTheme? buildAppBarTheme(ClientColorScheme colors, {required bool isDark}) {
    return AppBarTheme(
      elevation: 0,
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
    );
  }
}
```

**7. Design Scheme** (`client_design_scheme.dart`)

Configure responsive sizing based on your Figma design dimensions:

```dart
class MyClientDesignScheme extends ClientDesignScheme {
  const MyClientDesignScheme();

  @override
  double get figmaWidth => 390;  // iPhone 14 Pro width

  @override
  double get figmaHeight => 844; // iPhone 14 Pro height

  @override
  double get statusBarHeight => 47; // Optional status bar offset
}
```

## Responsive Sizing

The template includes responsive sizing utilities that scale UI elements based on the device screen size relative to your Figma design.

### Usage

```dart
// Width-based scaling (for horizontal spacing, widths)
Container(width: 100.w)  // Scales proportionally to screen width

// Height-based scaling (for vertical spacing, heights)
Container(height: 50.h)  // Scales proportionally to screen height

// Font size scaling (optimized for readability)
Text('Hello', style: TextStyle(fontSize: 16.fSize))

// Radius scaling (for border radius, circular elements)
BorderRadius.circular(8.r)
```

### How It Works

1. Define your design dimensions in `ClientDesignScheme` (defaults: 430x932)
2. The system calculates scale factors based on actual device dimensions
3. Use `.w`, `.h`, `.fSize`, `.r` extensions for automatic scaling
4. Works across all device sizes while maintaining design proportions

## Dark Mode Support

Dark mode is explicitly opt-in. Clients must provide ALL dark mode colors or none:

```dart
class MyClientColorScheme extends ClientColorScheme {
  // ... light mode colors (required) ...

  // Dark mode colors - set ALL THREE or NONE
  @override
  Color? get backgroundDark => const Color(0xFF121212);
  @override
  Color? get surfaceDark => const Color(0xFF1E1E1E);
  @override
  Color? get onSurfaceDark => Colors.white;

  // Additional dark mode colors available:
  @override
  Color? get primaryDark => const Color(0xFF64B5F6);
  @override
  Color? get secondaryDark => const Color(0xFF4FC3F7);
  @override
  Color? get errorDark => const Color(0xFFEF5350);
  @override
  Color? get successDark => const Color(0xFF66BB6A);
  @override
  Color? get onPrimaryDark => Colors.black;
}
```

If `supportsDarkMode` returns true (when background, surface, and onSurface dark colors are provided), the app automatically responds to system theme changes.

## Core Platform Features

The `core_platform` provides:

- **MainRunner**: Centralized app initialization (no duplication)
- **BaseConfig**: Abstract configuration for client customization
- **ClientColorScheme**: 7-color foundation with optional dark mode and auto-contrast
- **ClientAssetScheme**: Asset management with fallbacks
- **ClientThemeScheme**: Complete theme customization with responsive typography
- **ClientDesignScheme**: Responsive sizing configuration
- **ClientTranslationScheme**: Text/label overrides for branding
- **ClientCubit**: State management for client data
- **Context Extensions**: Clean API access (`context.clientConfig`, `context.appColors`)
- **SizerUtils**: Responsive sizing utilities (`.w`, `.h`, `.fSize`, `.r`)

## Development Workflow

1. **Develop Core Features**: Add shared logic to `core_platform/`
2. **Generate Client**: Use script to create new branded app
3. **Customize Colors & Assets**: Edit required client files
4. **Optional Theme Customization**: Add theme/design schemes for advanced branding
5. **Deploy**: Each client deploys independently

## Benefits

- **3-Line Client Setup**: `main.dart` is just 3 lines
- **Automatic Firebase Integration**: Analytics & Crashlytics ready out-of-the-box
- **Shared Firebase Support**: Multiple clients can share one Firebase project
- **7-Color Theming**: Define 7 colors, get 25+ professionally related colors
- **Complete Theme Control**: Customize every Material component via ClientThemeScheme
- **Responsive Sizing**: Figma-based responsive utilities for all devices
- **Optional Dark Mode**: Explicit opt-in with full control over dark colors
- **Zero Code Duplication**: All shared logic in core_platform
- **Multi-Platform Support**: Android, iOS, and Web with single flag
- **Production-Ready**: Enterprise-grade error handling and recovery
- **Asset Management**: Organized asset schemes with fallbacks
- **State Management**: Built-in BLoC pattern for client configuration
- **Easy Scaling**: Add unlimited clients with single command

## Client Generation Script

The script automatically creates:
- **Complete Flutter project** with proper structure
- **Firebase project** (new or uses existing shared project)
- **Web app & hosting site** (when using shared Firebase with --web)
- **All customization files** with proper imports
- **Dependencies configured** and installed
- **Asset directories** with guidelines
- **Platform support** (Android, iOS, optionally Web)
- **Firebase RC file** for web deployment
- **Interactive confirmation** and progress indicators

### Script Options

| Option | Description | Required | Default |
|--------|-------------|----------|---------|
| `-c, --client-id` | Client identifier (lowercase, underscores) | Yes | - |
| `-n, --app-name` | Human readable app name | Yes | - |
| `-p, --project-name` | Base project name (e.g., restaurant, food_delivery) | Yes | - |
| `-f, --firebase-account` | Firebase account email (required for Firebase) | Yes* | - |
| `-o, --org` | Organization domain | No | `com.example` |
| `-w, --web` | Include web platform support | No | `false` |
| `--firebase-project-id` | Existing Firebase project ID (shared/multi-tenant) | No | - |
| `--skip-firebase` | Skip Firebase project creation | No | `false` |

*Required unless `--skip-firebase` is used

### Firebase Options Explained

**New Firebase Project (Default)**
```bash
dart tools/create_client.dart -c my_app -n "My App" -p business -f admin@example.com
```
Creates a new Firebase project named `my-app-XXXXX` with unique suffix.

**Shared/Existing Firebase Project**
```bash
dart tools/create_client.dart -c my_app -n "My App" -p business -f admin@example.com \
  --firebase-project-id my-shared-firebase-project --web
```
Uses existing Firebase project. Creates:
- New web app within the project (named `my_app`)
- New hosting site (named `my-app`)
- Proper `.firebaserc` configuration

## Firebase Integration

### Automatic Setup
The script automatically:
- **Creates Firebase projects** with unique IDs (or uses existing)
- **Configures Analytics & Crashlytics** for production tracking
- **Sets up FlutterFire** with proper platform configuration
- **Creates web apps and hosting sites** for shared projects
- **Generates .firebaserc** for web deployment
- **Updates web/index.html title** with app name
- **Handles errors gracefully** with fallback options

### Web Platform Support
Add `--web` flag for Progressive Web App support:
```bash
# New Firebase project with web
dart tools/create_client.dart -c my_app -n "My App" -p business -f admin@example.com --web

# Shared Firebase project with web
dart tools/create_client.dart -c my_app -n "My App" -p business -f admin@example.com \
  --firebase-project-id shared-project --web
```

### Web Deployment
For clients with web support:
```bash
cd clients/my_app

# Build web app
flutter build web

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

The `.firebaserc` file is automatically configured with the correct hosting site.

### Development Mode
Skip Firebase for development/testing:
```bash
dart tools/create_client.dart -c test_app -n "Test App" -p business --skip-firebase
```

## Error Handling & Recovery

### Smart Retry Logic
- **Firebase project creation**: Automatic retries with progress indicators
- **FlutterFire configuration**: Handles propagation delays
- **Graceful fallbacks**: Continues without Firebase if setup fails

### Recovery Options
If Firebase setup fails:
1. **Continue without Firebase**: Creates placeholder configurations
2. **Manual setup instructions**: Provides exact commands for manual configuration
3. **Validation checks**: Ensures all prerequisites before project creation

## Advanced Features

### Custom Splash Gradients
```dart
@override
LinearGradient? get splashGradient => LinearGradient(
  colors: [primary.withOpacity(0.8), primary],
  stops: [0.0, 1.0],
);
```

### Translation Overrides
```dart
@override
ClientTranslationScheme get translationScheme => MyClientTranslationScheme();
```

### Custom onPrimary Color
```dart
// Override auto-contrast with explicit color
@override
Color get onPrimary => Colors.white;
```

## License

MIT License - feel free to use for commercial projects.

---

**Ready to scale? Generate your first client with automatic Firebase integration!**
