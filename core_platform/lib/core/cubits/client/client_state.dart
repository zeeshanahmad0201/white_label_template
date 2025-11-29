import 'package:core_platform/core/core.dart';
import 'package:core_platform/core_platform.dart';


/// State for client-specific configuration and theming
class ClientState extends BaseState {
  final BaseConfig config;

  ClientColorScheme get colorScheme => config.colorScheme;

  ClientAssetScheme get assetScheme => config.assetScheme;

  const ClientState({required this.config});

  const ClientState.initial(this.config);

  @override
  List<Object> get props => [config];
}
