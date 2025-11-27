# Flutter White Label Template

A complete Flutter white-label application template for creating multiple branded apps from a single codebase.

## Architecture

This template separates **core business logic** from **client-specific branding**, allowing you to maintain one codebase while deploying multiple branded applications.

```
/white_label_template/
├── core_platform/              # Shared business logic & UI components
│   ├── lib/
│   │   ├── config/base_config.dart    # Abstract configuration class
│   │   ├── app.dart                   # Main WhiteLabelApp widget
│   │   ├── features/                  # Shared business logic
│   │   └── widgets/                   # Reusable UI components
│   └── pubspec.yaml
├── clients/                    # Individual client applications
│   ├── client_a/              # Client-specific app
│   └── client_b/              # Another client-specific app
└── tools/
    └── create_client.dart     # Automated client generation script
```

## Quick Start

### 1. Generate a New Client

```bash
# Basic usage
dart tools/create_client.dart -c nyc_biz -n "NYC Business Directory" -p business_directory

# With custom organization
dart tools/create_client.dart -c miami_hotels -n "Miami Hotels" -p hotel_booking -o com.yourcompany
```

### 2. Run the Generated Client

```bash
cd clients/nyc_biz
flutter pub get
flutter run
```

## Client Generation Script

The `tools/create_client.dart` script automatically:

- Creates a complete Flutter project structure
- Generates client-specific configuration class
- Sets up proper package dependencies
- Creates asset directories with guidelines
- Configures Android/iOS platform files

### Script Options

| Option | Description | Required | Default |
|--------|-------------|----------|---------|
| `-c, --client-id` | Client identifier (lowercase, underscores) | Yes | - |
| `-n, --app-name` | Human readable app name | Yes | - |
| `-p, --project-name` | Base project name (e.g., business_directory) | Yes | - |
| `-o, --org` | Organization domain | No | `com.example` |

## Client Customization

Each generated client has its own configuration in `lib/config.dart`:

```dart
class BusinessDirectoryNycBizConfig extends BaseConfig {
  @override
  String get clientId => 'nyc_biz';

  @override
  String get appName => 'NYC Business Directory';

  @override
  Color get primaryColor => const Color(0xFF2196F3);

  @override
  String get apiBaseUrl => 'https://api.example.com/business_directory/nyc_biz';

  // ... more customization options
}
```

## Core Platform Features

The `core_platform` package provides:

- **BaseConfig**: Abstract configuration class for client customization
- **WhiteLabelApp**: Main application widget with theme support
- **Shared Widgets**: Reusable UI components
- **Theme System**: Automatic Material 3 theme generation from brand colors

## Package Structure

### Core Platform (`core_platform/`)

The core platform is a Flutter package containing shared business logic and UI components that all clients import.

### Client Apps (`clients/{client_id}/`)

Each client is a complete Flutter application that:
- Imports `core_platform` as a dependency
- Implements client-specific configuration
- Customizes branding, colors, and content
- Can override any core functionality

## Development Workflow

1. **Develop Core Features**: Add shared business logic to `core_platform/`
2. **Generate Client**: Use the generation script to create a new branded app
3. **Customize Branding**: Modify the client's `config.dart` and assets
4. **Deploy**: Each client can be deployed independently

## Asset Management

Generated clients include organized asset directories:

```
clients/{client_id}/assets/
├── images/
│   ├── logo.png              # App icon source (512x512)
│   ├── splash.png            # Splash background (1080x1920)
│   └── logo_text.png         # Logo with text
└── icons/                    # Custom navigation icons
```

## Benefits

- **Single Codebase**: Maintain core business logic in one place
- **Multiple Brands**: Deploy unlimited branded variations
- **Easy Scaling**: Add new clients with a single command
- **Independent Deployment**: Each client can be deployed separately
- **Consistent Quality**: Shared components ensure consistent UX

## License

This template is open source and available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

**Happy coding!**
