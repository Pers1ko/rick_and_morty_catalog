/// A single layout calculation is shared by real cards and their skeletons.
final class CatalogGridLayout {
  CatalogGridLayout({required double width, required double textScale}) {
    padding = width > 700 ? 30 : 18;
    final availableWidth = width - padding * 2;
    columns = (availableWidth / (165 * textScale.clamp(1, 2))).floor().clamp(
      1,
      4,
    );
    final cardWidth = (availableWidth - (columns - 1) * gap) / columns;
    imageHeight = cardWidth * .92;
    cardExtent = imageHeight + 116 * textScale;
  }
  static const gap = 14.0;
  late final double padding;
  late final int columns;
  late final double imageHeight;
  late final double cardExtent;
}
