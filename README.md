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
│   │   │   └── extensions/         # Context extensions
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
# Restaurant app (mobile only)
dart tools/create_client.dart -c nyc_biz -n "NYC Restaurant" -p restaurant -f admin@example.com

# Food delivery with web support
dart tools/create_client.dart -c chicago_eats -n "Chicago Food Delivery" -p food_delivery -f admin@example.com --web

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
│   ├── main.dart              # 3-line main (uses MainRunner)
│   ├── client_config.dart     # BaseConfig implementation
│   ├── client_color_scheme.dart   # Color scheme (7 colors)
│   └── client_asset_scheme.dart   # Asset paths
└── assets/
    └── images/                # Client-specific assets
```

## Client Customization

### Minimal Configuration (5 files to customize)

**1. Color Scheme** (`client_color_scheme.dart`)
```dart
class MyClientColorScheme extends ClientColorScheme {
  @override
  Color get primary => const Color(0xFF2196F3);
  @override
  Color get background => Colors.white;
  @override
  Color get onSurface => Colors.black87;
  // ... 4 more colors
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
}
```

**4. Entry Point** (`main.dart`)
```dart
Future<void> main() => MainRunner.run(config: MyClientConfig());
```

**5. Assets** (Add your images to `assets/images/`)

## Core Platform Features

The `core_platform` provides:

- **MainRunner**: Centralized app initialization (no duplication)
- **BaseConfig**: Abstract configuration for client customization
- **ClientColorScheme**: 7-color foundation that generates 25+ derived colors
- **ClientAssetScheme**: Asset management with fallbacks
- **ClientCubit**: State management for client data
- **Context Extensions**: Clean API access (`context.clientConfig`, `context.appColors`)

## Development Workflow

1. **Develop Core Features**: Add shared logic to `core_platform/`
2. **Generate Client**: Use script to create new branded app
3. **Customize Colors & Assets**: Edit the 5 client files
4. **Deploy**: Each client deploys independently

## Benefits

- **3-Line Client Setup**: `main.dart` is just 3 lines
- **Automatic Firebase Integration**: Analytics & Crashlytics ready out-of-the-box
- **7-Color Theming**: Define 7 colors, get 25+ professionally related colors
- **Zero Code Duplication**: All shared logic in core_platform
- **Multi-Platform Support**: Android, iOS, and Web with single flag
- **Production-Ready**: Enterprise-grade error handling and recovery
- **Asset Management**: Organized asset schemes with fallbacks
- **State Management**: Built-in BLoC pattern for client configuration
- **Easy Scaling**: Add unlimited clients with single command

## Client Generation Script

The script automatically creates:
- **Complete Flutter project** with proper structure
- **Firebase project** with Analytics & Crashlytics
- **All 5 customization files** with proper imports
- **Dependencies configured** and installed
- **Asset directories** with guidelines
- **Platform support** (Android, iOS, optionally Web)
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
| `--skip-firebase` | Skip Firebase project creation | No | `false` |

*Required unless `--skip-firebase` is used

## Firebase Integration

### Automatic Setup
The script automatically:
- **Creates Firebase projects** with unique IDs
- **Configures Analytics & Crashlytics** for production tracking
- **Sets up FlutterFire** with proper platform configuration
- **Handles errors gracefully** with fallback options

### Web Platform Support
Add `--web` flag for Progressive Web App support:
```bash
dart tools/create_client.dart -c my_app -n "My App" -p business -f admin@example.com --web
```

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

## License

MIT License - feel free to use for commercial projects.

---

**Ready to scale? Generate your first client with automatic Firebase integration!**