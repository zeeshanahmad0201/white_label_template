# Flutter White Label Template

A simplified Flutter white-label template for creating multiple branded apps from a single codebase.

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

## Quick Start

### 1. Generate a New Client

```bash
# Create a new client
dart tools/create_client.dart -c my_client -n "My App" -p com.company.myapp

# With custom API
dart tools/create_client.dart -c acme_corp -n "Acme App" -p com.acme.app -a https://api.acme.com
```

### 2. Run the Generated Client

```bash
cd clients/my_client
flutter pub get
flutter run
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
- **7-Color Theming**: Define 7 colors, get 25+ professionally related colors
- **Zero Code Duplication**: All shared logic in core_platform
- **Automatic Theming**: Colors automatically applied to all UI components
- **Asset Management**: Organized asset schemes with fallbacks
- **State Management**: Built-in BLoC pattern for client configuration
- **Easy Scaling**: Add unlimited clients with single command

## Client Generation Script

The script automatically creates:
- Complete Flutter project structure
- All 5 customization files with proper imports
- Asset directories and guidelines
- Dependencies configured correctly

### Script Options

| Option | Description | Required |
|--------|-------------|----------|
| `-c, --client-id` | Client identifier (lowercase, underscores) | Yes |
| `-n, --app-name` | Human readable app name | Yes |
| `-p, --package-name` | Package name (com.company.app) | Yes |
| `-a, --api-url` | API base URL | No |

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

**Ready to scale? Generate your first client and see the magic!** ✨