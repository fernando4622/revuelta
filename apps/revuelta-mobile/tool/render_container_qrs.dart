import 'dart:convert';
import 'dart:io';

import 'package:qr/qr.dart';

void main(List<String> arguments) {
  if (arguments.length != 2) {
    stderr.writeln(
      'Usage: dart run tool/render_container_qrs.dart <manifest.json> <output-directory>',
    );
    exitCode = 64;
    return;
  }

  final manifest = jsonDecode(File(arguments[0]).readAsStringSync()) as List;
  final outputDirectory = Directory(arguments[1])..createSync(recursive: true);

  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final code = entry['code'] as String;
    final payload = entry['payload'] as String;
    final qrCode = QrCode.fromData(
      data: payload,
      errorCorrectLevel: QrErrorCorrectLevel.M,
    );
    final image = QrImage(qrCode);
    final svg = _renderSvg(image, code);
    File('${outputDirectory.path}${Platform.pathSeparator}$code.svg')
        .writeAsStringSync(svg);
  }
}

String _renderSvg(QrImage image, String code) {
  const quietZone = 4;
  const moduleSize = 12;
  const labelHeight = 100;
  final qrSize = (image.moduleCount + quietZone * 2) * moduleSize;
  final totalHeight = qrSize + labelHeight;
  final modules = StringBuffer();

  for (var row = 0; row < image.moduleCount; row++) {
    for (var column = 0; column < image.moduleCount; column++) {
      if (!image.isDark(row, column)) continue;
      final x = (column + quietZone) * moduleSize;
      final y = (row + quietZone) * moduleSize;
      modules.write(
        '<rect x="$x" y="$y" width="$moduleSize" height="$moduleSize"/>',
      );
    }
  }

  return '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="$qrSize" height="$totalHeight" viewBox="0 0 $qrSize $totalHeight" role="img" aria-label="QR estático del envase ${_xml(code)}">
  <rect width="$qrSize" height="$totalHeight" fill="#ffffff"/>
  <g fill="#000000">$modules</g>
  <text x="${qrSize ~/ 2}" y="${qrSize + 54}" text-anchor="middle" font-family="Arial, sans-serif" font-size="32" font-weight="700" fill="#163A2E">${_xml(code)}</text>
  <text x="${qrSize ~/ 2}" y="${qrSize + 84}" text-anchor="middle" font-family="Arial, sans-serif" font-size="20" fill="#3F5E52">ReVuelta · QR estático</text>
</svg>
''';
}

String _xml(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&apos;');
