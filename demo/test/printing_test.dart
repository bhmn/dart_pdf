import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:printing_demo/data_send_product.dart';
import 'package:printing_demo/examples/document.dart';

void main() {
  testWidgets('Pdf Generate the document', (WidgetTester tester) async {
    const data = SendProductData();
    final doc = await generateDocument(PdfPageFormat.a4, data);

    final file = File('document.pdf');
    file.writeAsBytesSync(doc);
  });
}
