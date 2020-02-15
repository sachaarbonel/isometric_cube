import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Isometric Cube'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: CustomPaint(
        // size: Size(150, 150),
        painter: IsometricCube(hexColor: '#ff8d4b'),
      )),
    );
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

String _textSubString(String text) {
  if (text == null) return null;

  if (text.length < 6) return null;

  if (text.length == 6) return text;

  return text.substring(1, text.length);
}

// Colour adjustment function
// Nicked from http://stackoverflow.com/questions/5560248
String shadeColor(String hexColor, percent) {
  var num = int.parse(_textSubString(hexColor), radix: 16),
      amt = (2.55 * percent).round(),
      R = (num >> 16) + amt,
      G = (num >> 8 & 0x00FF) + amt,
      B = (num & 0x0000FF) + amt;
  return '#' +
      (0x1000000 +
              (R < 255 ? R < 1 ? 0 : R : 255) * 0x10000 +
              (G < 255 ? G < 1 ? 0 : G : 255) * 0x100 +
              (B < 255 ? B < 1 ? 0 : B : 255))
          .toRadixString(16)
          .substring(1);
}

// Draw a cube to the specified specs
void drawCube(
    {Canvas canvas,
    String hexColor,
    double x,
    double y,
    double wx,
    double wy,
    double h}) {
  final leftFace = Path()
    ..moveTo(x, y)
    ..lineTo(x - wx, y - wx * 0.5)
    ..lineTo(x - wx, y - h - wx * 0.5)
    ..lineTo(x, y - h * 1)
    ..close();
  final leftFaceFillPaint = Paint()
    ..color = HexColor.fromHex(shadeColor(hexColor, -10))
    ..style = PaintingStyle.fill;
  final leftFaceStrokePaint = Paint()
    ..color = HexColor.fromHex(hexColor)
    ..style = PaintingStyle.stroke;
  canvas.save();
  canvas.drawPath(leftFace, leftFaceFillPaint);
  canvas.restore();
  canvas.save();
  canvas.drawPath(leftFace, leftFaceStrokePaint);

  canvas.restore();

  final rightFace = Path()
    ..moveTo(x, y)
    ..lineTo(x + wy, y - wy * 0.5)
    ..lineTo(x + wy, y - h - wy * 0.5)
    ..lineTo(x, y - h * 1)
    ..close();

  final rightFaceFillPaint = Paint()
    ..color = HexColor.fromHex(shadeColor(hexColor, 10))
    ..style = PaintingStyle.fill;
  final rightFaceStrokePaint = Paint()
    ..color = HexColor.fromHex(shadeColor(hexColor, 50))
    ..style = PaintingStyle.stroke;
  canvas.save();
  canvas.drawPath(rightFace, rightFaceFillPaint);
  canvas.restore();
  canvas.save();
  canvas.drawPath(rightFace, rightFaceStrokePaint);
  canvas.restore();

  final centerFace = Path()
    ..moveTo(x, y - h)
    ..lineTo(x - wx, y - h - wx * 0.5)
    ..lineTo(x - wx + wy, y - h - (wx * 0.5 + wy * 0.5))
    ..lineTo(x + wy, y - h - wy * 0.5)
    ..close();

  final centerFaceFillPaint = Paint()
    ..color = HexColor.fromHex(shadeColor(hexColor, 20))
    ..style = PaintingStyle.fill;
  final centerFaceStrokePaint = Paint()
    ..color = HexColor.fromHex(shadeColor(hexColor, 60))
    ..style = PaintingStyle.stroke;
  canvas.save();
  canvas.drawPath(centerFace, centerFaceFillPaint);
  canvas.restore();
  canvas.save();
  canvas.drawPath(centerFace, centerFaceStrokePaint);
  canvas.restore();
}

class IsometricCube extends CustomPainter {
  final double x1;
  final double x2;
  final double y;
  final String hexColor;

  IsometricCube({this.x1 = 100, this.x2 = 100, this.y = 100, this.hexColor});

  @override
  void paint(Canvas canvas, Size size) {
    drawCube(
        canvas: canvas,
        hexColor: hexColor,
        x: size.width / 2,
        y: size.height / 2 + y,
        wx: x1,
        wy: x2,
        h: y);
    canvas.translate(size.width / 2, size.height / 2);
  }

  @override
  bool shouldRepaint(IsometricCube oldDelegate) => false;
}
