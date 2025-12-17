import 'dart:math';

import 'package:flutter/material.dart';
import '../config/client_design_scheme.dart';

typedef ResponsiveBuild = Widget Function(
  BuildContext context,
  Orientation orientation,
);

class SizerUtils extends StatelessWidget {
  const SizerUtils({
    super.key,
    required this.builder,
    required this.designScheme,
  });

  /// Builds the widget whenever the orientation changes.
  final ResponsiveBuild builder;

  /// Design scheme to use for responsive calculations
  final ClientDesignScheme designScheme;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return OrientationBuilder(builder: (context, orientation) {
        SizeUtils.setScreenSize(
          constraints,
          orientation,
          designScheme,
        );
        return builder(context, orientation);
      });
    });
  }
}

class SizeUtils {
  /// Device's BoxConstraints
  static late BoxConstraints boxConstraints;

  /// Device's Orientation
  static late Orientation orientation;

  /// Device's Height
  static late double height;

  /// Device's Width
  static late double width;

  /// Current design scheme being used
  static late ClientDesignScheme _designScheme;

  static void setScreenSize(
    BoxConstraints constraints,
    Orientation currentOrientation,
    ClientDesignScheme designScheme,
  ) {
    // Store design scheme for use in extensions
    _designScheme = designScheme;

    // Sets boxConstraints and orientation
    boxConstraints = constraints;
    orientation = currentOrientation;

    // Sets screen width and height
    if (orientation == Orientation.portrait) {
      width = boxConstraints.maxWidth.isNonZero(defaultValue: designScheme.figmaWidth);
      height = boxConstraints.maxHeight.isNonZero(defaultValue: designScheme.figmaHeight);
    } else {
      width = boxConstraints.maxHeight.isNonZero(defaultValue: designScheme.figmaWidth);
      height = boxConstraints.maxWidth.isNonZero(defaultValue: designScheme.figmaHeight);
    }
  }

  /// Get current design scheme (for use in extensions)
  static ClientDesignScheme get designScheme => _designScheme;
}

/// This extension is used to set padding/margin (for the top and bottom side) &
/// height of the screen or widget according to the Viewport height.
extension ResponsiveExtension on num {
  /// This method is used to get device viewport width.
  double get _width => SizeUtils.width;

  /// This method is used to get device viewport height.
  double get _height => SizeUtils.height;

  /// This method is used to get current design scheme.
  ClientDesignScheme get _designScheme => SizeUtils.designScheme;

  /// This method is used to set padding/margin (for the left and Right side) &
  /// width of the screen or widget according to the Viewport width.
  double get w => ((this * _width) / _designScheme.figmaWidth);

  /// This method is used to set padding/margin (for the top and bottom side) &
  /// height of the screen or widget according to the Viewport height.
  double get h =>
      (this * _height) / (_designScheme.figmaHeight - _designScheme.statusBarHeight);

  /// This method is used to set smallest px in image height and width
  double get adaptSize {
    var height = w;
    var width = h;
    return height < width ? height.toDoubleValue() : width.toDoubleValue();
  }

  /// This method is used to get radius based on Viewport
  double get r => adaptSize / 2;

  /// This method is used to set text font size according to Viewport
  double get fSize {
    double size = adaptSize;
    return size.clamp(8.0, 100.0);
  }

  /// Returns a responsive height with minimum constraint
  /// Use this when you want to ensure a minimum height while still being responsive
  double get respH {
    double originalValue = toDouble();
    double responsiveValue = h;
    return max(originalValue, responsiveValue);
  }

  /// Returns a responsive width with minimum constraint
  /// Use this when you want to ensure a minimum width while still being responsive
  double get respW {
    double originalValue = toDouble();
    double responsiveValue = w;
    return max(originalValue, responsiveValue);
  }
}

extension FormatExtension on double {
  /// Return a [double] value with formatted according to provided fractionDigits
  double toDoubleValue({int fractionDigits = 2}) {
    return double.parse(toStringAsFixed(fractionDigits));
  }

  double isNonZero({num defaultValue = 0.0}) {
    return this > 0 ? this : defaultValue.toDouble();
  }
}