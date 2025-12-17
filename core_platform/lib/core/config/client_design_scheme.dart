/// Client-specific design scheme for responsive sizing
///
/// This allows each client to define their design specifications
/// from their Figma/design files for accurate responsive scaling.
///
/// Example:
/// ```dart
/// class MyClientDesignScheme extends ClientDesignScheme {
///   @override
///   double get figmaWidth => 375; // iPhone design width
///
///   @override
///   double get figmaHeight => 812; // iPhone design height
/// }
/// ```
abstract class ClientDesignScheme {
  /// Figma/Design file width (viewport width used in design)
  /// This is used as the reference for responsive width calculations
  double get figmaWidth;

  /// Figma/Design file height (viewport height used in design)
  /// This is used as the reference for responsive height calculations
  double get figmaHeight;

  /// Status bar height in the design (usually 0 for modern designs)
  /// This is subtracted from height calculations for accurate sizing
  double get statusBarHeight => 0;
}

/// Default design scheme implementation
/// Based on common mobile design standards (430x932 - modern Android)
class DefaultClientDesignScheme extends ClientDesignScheme {
  DefaultClientDesignScheme();

  @override
  double get figmaWidth => 430;

  @override
  double get figmaHeight => 932;

  @override
  double get statusBarHeight => 0;
}