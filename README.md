# Variable Width ScrollPhysics

A Flutter package that provides custom scroll physics and widgets for handling variable-width pages with dynamic height adjustment. Perfect for creating flexible page views where each page can have different widths and heights.

<img src="example.gif" width="300px" alt="Example GIF">

## Features

- **Variable Width Page ScrollPhysics**: Custom scroll physics that snaps to pages with different widths
- **Adaptive Height Page Slider**: Automatically adjusts container height based on scroll position
- **Sliver-based Slider**: Efficient implementation using Flutter's sliver system for large datasets

### Key Components

1. **FlexPageScrollPhysics**: Custom ScrollPhysics that handles variable-width pages
2. **FlexPageSlider**: Widget that adjusts height dynamically based on scroll position
3. **FlexSliverSlider**: Sliver-based implementation for better performance with many items

## Getting started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  variable_width_scrollphysics: ^0.0.1
```

## Usage

### Basic Variable Width Page View

```dart
import 'package:variable_width_scrollphysics/variable_width_scrollphysics.dart';

FlexPageSlider(
  pageWidths: [300, 400, 350],  // Widths of each page
  pageHeights: [200, 300, 300], // Heights of each page
  child: Row(
    children: [
      // Your page content here
      Container(width: 300, color: Colors.red),
      Container(width: 400, color: Colors.green),
      Container(width: 350, color: Colors.blue),
    ],
  ),
)
```

### Using Custom ScrollPhysics

```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  physics: FlexPageScrollPhysics([300, 400, 400]),
  child: Row(
    children: [
      Container(width: 300, child: Page1()),
      Container(width: 400, child: Page2()),
      Container(width: 400, child: Page3()),
    ],
  ),
)
```

## Example

Check out the `/example` folder for complete examples:

- **Demo1**: Basic variable width pages with different heights
- **Demo2**: Image gallery with variable widths
- **Demo3**: Dynamic content with sliver implementation
- **Demo4**: Complex layout with nested scrolling

To run the example:

```bash
cd example
flutter run
```

## Additional information

This package is useful for:
- Image galleries with different image sizes
- Card-based layouts with variable content
- Any UI requiring variable-width pages with smooth scrolling

For bugs or feature requests, please file an issue on the [GitHub repository](https://github.com/your-repo/variable_width_scrollphysics).

## Language

- [English](README.md)
- [中文](README_CN.md)
