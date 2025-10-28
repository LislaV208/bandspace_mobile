class PlayerMathUtils {
  static double normalizeValue(
    double value,
    double originalMin,
    double originalMax,
  ) {
    double originalRange = originalMax - originalMin;
    if (originalRange == 0) {
      return 0.0;
    }
    final clampedValue = value.clamp(originalMin, originalMax);
    return (clampedValue - originalMin) / originalRange;
  }

  static double calculatePercentageScrolled(
    double size,
    double minSize,
    double maxSize,
  ) {
    return normalizeValue(
      size,
      minSize,
      maxSize,
    );
  }

  static double calculateMinDraggableScrollSize(
    double maxHeight,
    double minBottomHeight,
  ) {
    return 1 -
        normalizeValue(
          maxHeight - minBottomHeight,
          0,
          maxHeight,
        );
  }

  static double calculateMaxDraggableScrollSize(
    double minBottomHeight,
    double maxHeight,
  ) {
    return 1 -
        normalizeValue(
          minBottomHeight,
          0,
          maxHeight,
        );
  }
}
