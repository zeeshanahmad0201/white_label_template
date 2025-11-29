import 'package:core_platform/core_platform.dart';

/// Cubit responsible for managing client-specific configuration and theming
///
/// This cubit holds all the client customization data and provides
/// access to colors, assets, translations, and other white label settings.
class ClientCubit extends BaseCubit<ClientState> {
  ClientCubit({
    required BaseConfig config,
  }) : super(ClientState.initial(config));

  /// Access to client configuration
  BaseConfig get config => state.config;

  /// Access to client colors (derived from color scheme)
  DerivedAppColors get colors => DerivedAppColors(state.colorScheme);

  /// Access to client assets (from asset scheme)
  ClientAssetScheme get assets => state.assetScheme;
}