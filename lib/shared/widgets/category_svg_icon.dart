import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Maps a category name to a crisp single-color SVG vector icon.
/// Falls back to a generic storefront icon for unknown categories.
class CategorySvgIcon extends StatelessWidget {
  final String categoryName;
  final double size;
  final Color color;

  const CategorySvgIcon({
    super.key,
    required this.categoryName,
    this.size = 18,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final svgString = _svgFor(categoryName.toLowerCase());
    return SvgPicture.string(
      svgString,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  static String _svgFor(String name) {
    switch (name) {
      case 'restaurant':
        // Fork and knife
        return '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
          <path d="M11 9H9V2H7v7H5V2H3v7c0 2.12 1.66 3.84 3.75 3.97V22h2.5v-9.03C11.34 12.84 13 11.12 13 9V2h-2v7zm5-3v8h2.5v8H21V2c-2.76 0-5 2.24-5 4z"/>
        </svg>''';

      case 'cafe':
        // Coffee cup with steam
        return '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
          <path d="M20 3H4v10c0 3.31 2.69 6 6 6h4c3.31 0 6-2.69 6-6v-3h2V8h-2V3zM16 13c0 2.21-1.79 4-4 4h-4c-2.21 0-4-1.79-4-4V5h12v8zm4-3h-2V5h2v5zM7 16h2v2H7zm4 0h2v2h-2z"/>
        </svg>''';

      case 'salon':
        // Scissors
        return '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
          <path d="M9.64 7.64c.23-.5.36-1.05.36-1.64 0-2.21-1.79-4-4-4S2 3.79 2 6s1.79 4 4 4c.59 0 1.14-.13 1.64-.36L10 12l-2.36 2.36C7.14 14.13 6.59 14 6 14c-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4c0-.59-.13-1.14-.36-1.64L12 14l7 7h3v-1L9.64 7.64zM6 8c-1.1 0-2-.89-2-2s.9-2 2-2 2 .89 2 2-.9 2-2 2zm0 12c-1.1 0-2-.89-2-2s.9-2 2-2 2 .89 2 2-.9 2-2 2zm6-7.5c-.28 0-.5-.22-.5-.5s.22-.5.5-.5.5.22.5.5-.22.5-.5.5zM19 3l-6 6 2 2 7-7V3z"/>
        </svg>''';

      case 'medical':
        // Hospital cross
        return '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
          <path d="M19 3H5c-1.1 0-1.99.9-1.99 2L3 19c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-1 11h-4v4h-4v-4H6v-4h4V6h4v4h4v4z"/>
        </svg>''';

      case 'clothing':
        // Clothes hanger / shirt
        return '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
          <path d="M12 3c-1.2 0-2.4.5-3.2 1.3L2 10l2 2 2.5-2.5V20h15V9.5L24 12l2-2-6.8-5.7C18.4 3.5 17.2 3 16 3h-4zm0 2h4c.7 0 1.4.3 1.9.7L21.5 9 19 11.5V18H5v-6.5L2.5 9l3.6-3.3C6.6 5.3 7.3 5 8 5h4z"/>
        </svg>''';

      case 'bank':
        // Bank columns
        return '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
          <path d="M4 10v7h3v-7H4zm6 0v7h3v-7h-3zM2 22h19v-3H2v3zm14-12v7h3v-7h-3zM11.5 1L2 6v2h19V6l-9.5-5z"/>
        </svg>''';

      default:
        // Generic storefront
        return '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
          <path d="M20 4H4v2h16V4zm1 10v-2l-1-5H4l-1 5v2h1v6h10v-6h4v6h2v-6h1zm-9 4H6v-4h6v4z"/>
        </svg>''';
    }
  }
}
