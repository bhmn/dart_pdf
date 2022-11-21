/*
 * Copyright (C) 2017, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:image/image.dart' as im;

import '../data_send_product.dart';

Future<Uint8List> generateInvoice(
    PdfPageFormat pageFormat, SendProductData data1) async {
  final lorem = pw.LoremText();

  final products = data1.products;

  final invoice = Invoice(
    invoiceNumber: '982347',
    products: products,
    customerName: 'Abraham Swearegin',
    customerAddress: '54 rue de Rivoli\n75001 Paris, France',
    paymentInfo:
        '4509 Wiseman Street\nKnoxville, Tennessee(TN), 37929\n865-372-0425',
    tax: .15,
    baseColor: PdfColors.teal,
    accentColor: PdfColors.blueGrey900,
  );

  return await invoice.buildPdf(pageFormat, data1);
}

class Invoice {
  Invoice({
    required this.products,
    required this.customerName,
    required this.customerAddress,
    required this.invoiceNumber,
    required this.tax,
    required this.paymentInfo,
    required this.baseColor,
    required this.accentColor,
  });

  final List<Product> products;
  final String customerName;
  final String customerAddress;
  final String invoiceNumber;
  final double tax;
  final String paymentInfo;
  final PdfColor baseColor;
  final PdfColor accentColor;

  static const _darkColor = PdfColors.blueGrey800;
  static const _lightColor = PdfColors.white;

  PdfColor get _baseTextColor => baseColor.isLight ? _lightColor : _darkColor;

  PdfColor get _accentTextColor => baseColor.isLight ? _lightColor : _darkColor;

  String? _logo;

  String? _bgShape;

  pw.Font? myFont;
  pw.ImageProvider? myLogo;
  SendProductData? data;

  Future<Uint8List> buildPdf(
      PdfPageFormat pageFormat, SendProductData data1) async {
    data = data1;
    // Create a PDF document.
    final doc = pw.Document();

    //_logo = await rootBundle.loadString('assets/logo.svg');
    _logo = await rootBundle.loadString('assets/eacd.svg');

    _bgShape = await rootBundle.loadString('assets/invoice.svg');

    //mycode
    final font = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Vazirmatn-FD-Regular.ttf'));
    myFont = font;
    final imageGGG = pw.MemoryImage(
        (await rootBundle.load('assets/application-icon.png'))
            .buffer
            .asUint8List());
    myLogo = imageGGG;

    // Add page to the PDF
    doc.addPage(
      pw.MultiPage(
        // pageTheme: _buildTheme(
        //   pageFormat,
        //   pw.Font.ttf(
        //       await rootBundle.load('assets/fonts/Vazirmatn-FD-Regular.ttf')),
        //   pw.Font.ttf(
        //       await rootBundle.load('assets/fonts/Vazirmatn-FD-Regular.ttf')),
        //   pw.Font.ttf(
        //       await rootBundle.load('assets/fonts/Vazirmatn-FD-Regular.ttf')),
        // ),
        header: _buildHeader,
        footer: _buildFooter,
        build: (context) => [
          // _contentHeader(context),
          _contentTable(context),
          pw.SizedBox(height: 10),
          //_contentFooter(context),
          // pw.SizedBox(height: 20),
          // _termsAndConditions(context),
        ],
        textDirection: pw.TextDirection.rtl,
      ),
    );

    // Return the PDF file content
    return doc.save();
  }

  pw.Widget _buildHeader(pw.Context context) {
    return pw.Column(
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.Container(
                      height: 60,
                      padding: const pw.EdgeInsets.all(5.0),
                      alignment: pw.Alignment.center,
                      child: pw.Text('فرم ارسال کالا',
                          style: pw.TextStyle(
                              color: baseColor,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 22,
                              font: myFont),
                          textAlign: pw.TextAlign.justify),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Container(
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.all(5.0),
                      height: 72,
                      child: _logo != null
                          ? pw.SvgImage(svg: _logo!)
                          : pw.PdfLogo(),
                      // pw.Image(myLogo!)
                    ),
                    // pw.Container(
                    //   color: baseColor,
                    //   padding: pw.EdgeInsets.only(top: 3),
                    // ),
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        borderRadius:
                            const pw.BorderRadius.all(pw.Radius.circular(25)),
                        color: accentColor,
                      ),
                      padding: const pw.EdgeInsets.only(
                          left: 40, top: 10, bottom: 10, right: 20),
                      alignment: pw.Alignment.center,
                      height: 40,
                      child: pw.DefaultTextStyle(
                        style: pw.TextStyle(
                          color: _accentTextColor,
                          fontSize: 12,
                        ),
                        child: pw.GridView(
                          crossAxisCount: 1,
                          children: [
                            pw.Text(
                              'مهندسین مشاور ارتباط گستران شرق',
                              style: pw.TextStyle(font: myFont),
                            ),
                            // pw.Text(invoiceNumber),
                            // pw.Text('Date:'),
                            // pw.Text(_formatDate(DateTime.now())),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Container(
                    margin: const pw.EdgeInsets.symmetric(horizontal: 20),
                    height: 20,
                    child: pw.FittedBox(
                      child: pw.Text(
                        'تاریخ: ${data?.formDate}',
                        style: pw.TextStyle(
                          color: baseColor,
                          fontStyle: pw.FontStyle.normal,
                          fontSize: 15,
                          font: myFont,
                        ),
                      ),
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Container(
                    margin: const pw.EdgeInsets.symmetric(horizontal: 20),
                    height: 20,
                    child: pw.FittedBox(
                      child: pw.Text(
                        'شماره: ${data?.formNumber}',
                        style: pw.TextStyle(
                          color: baseColor,
                          fontStyle: pw.FontStyle.normal,
                          fontSize: 15,
                          font: myFont,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Expanded(
                child: pw.Container(
                  margin: const pw.EdgeInsets.symmetric(horizontal: 20),
                  height: 20,
                  child: pw.FittedBox(
                    child: pw.Text(
                      'گیرنده:',
                      style: pw.TextStyle(
                        color: baseColor,
                        fontStyle: pw.FontStyle.normal,
                        fontSize: 15,
                        font: myFont,
                      ),
                    ),
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Container(
                  margin: const pw.EdgeInsets.symmetric(horizontal: 20),
                  height: 20,
                  child: pw.FittedBox(
                    child: pw.Text(
                      'فرستنده:',
                      style: pw.TextStyle(
                        color: baseColor,
                        fontStyle: pw.FontStyle.normal,
                        fontSize: 15,
                        font: myFont,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Expanded(
                child: pw.Container(
                  margin: const pw.EdgeInsets.symmetric(horizontal: 20),
                  height: 20,
                  child: pw.FittedBox(
                    child: pw.Text(
                      data!.formReceiver,
                      style: pw.TextStyle(
                        color: baseColor,
                        fontStyle: pw.FontStyle.normal,
                        fontSize: 15,
                        font: myFont,
                      ),
                    ),
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Container(
                  margin: const pw.EdgeInsets.symmetric(horizontal: 20),
                  height: 20,
                  child: pw.FittedBox(
                    child: pw.Text(
                      'مهندسین مشاور ارتباط گستران شرق',
                      style: pw.TextStyle(
                        color: baseColor,
                        fontStyle: pw.FontStyle.normal,
                        fontSize: 15,
                        font: myFont,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ],
        ),
        if (context.pageNumber > 1) pw.SizedBox(height: 20)
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    var uint8ListSender = data?.imageInUnit8ListSender;
    var uint8ListReceiver = data?.imageInUnit8ListReceiver;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 1,
          child: pw.DefaultTextStyle(
            style: const pw.TextStyle(
              fontSize: 10,
              color: _darkColor,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(children: [
                  pw.SizedBox(height: 5),
                  // pw.Divider(color: accentColor),
                  pw.Expanded(
                    child: pw.DefaultTextStyle(
                      style: pw.TextStyle(
                        color: baseColor,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        font: myFont,
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(data!.sum.toString()),
                          pw.Text('مجموع:', textAlign: pw.TextAlign.right),
                        ],
                      ),
                    ),
                  ),
                ]),
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(top: pw.BorderSide(color: _darkColor)),
                  ),
                  child: pw.Row(children: [
                    // pw.SizedBox(height: 5),
                    pw.Divider(color: accentColor),
                    pw.Expanded(
                      child: pw.DefaultTextStyle(
                        style: pw.TextStyle(
                          color: baseColor,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          font: myFont,
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('تحویل گیرنده:',
                                textAlign: pw.TextAlign.right),
                            pw.Text('تحویل دهنده:',
                                textAlign: pw.TextAlign.right),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(top: pw.BorderSide(color: _darkColor)),
                  ),
                  child: pw.Row(children: [
                    pw.SizedBox(height: 5),
                    pw.Divider(color: accentColor),
                    pw.Expanded(
                      child: pw.DefaultTextStyle(
                        style: pw.TextStyle(
                          color: baseColor,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          font: myFont,
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(10.0),
                              child: pw.Image(
                                width: 100,
                                height: 100,
                                pw.MemoryImage(uint8ListReceiver!),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(10.0),
                              child: pw.Image(
                                width: 100,
                                height: 100,
                                pw.MemoryImage(uint8ListSender!),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                )
              ],
            ),
          ),
        ),
      ],
    );
    // return pw.Row(
    //   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    //   crossAxisAlignment: pw.CrossAxisAlignment.end,
    //   children: [
    //     pw.Container(
    //       height: 20,
    //       width: 100,
    //       child: pw.BarcodeWidget(
    //         barcode: pw.Barcode.pdf417(),
    //         data: 'Invoice# $invoiceNumber',
    //         drawText: false,
    //       ),
    //     ),
    //     pw.Text(
    //       'Page ${context.pageNumber}/${context.pagesCount}',
    //       style: const pw.TextStyle(
    //         fontSize: 12,
    //         color: PdfColors.white,
    //       ),
    //     ),
    //   ],
    // );
  }

  pw.PageTheme _buildTheme(
      PdfPageFormat pageFormat, pw.Font base, pw.Font bold, pw.Font italic) {
    return pw.PageTheme(
      pageFormat: pageFormat,
      theme: pw.ThemeData.withFont(
        base: base,
        bold: bold,
        italic: italic,
      ),
      buildBackground: (context) => pw.FullPage(
        ignoreMargins: true,
        child: pw.SvgImage(svg: _bgShape!),
      ),
    );
  }

  pw.Widget _contentHeader(pw.Context context) {
    return pw.Column(children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Container(
              margin: const pw.EdgeInsets.symmetric(horizontal: 20),
              height: 30,
              child: pw.FittedBox(
                child: pw.Text(
                  'تاریخ: ',
                  style: pw.TextStyle(
                    color: baseColor,
                    fontStyle: pw.FontStyle.normal,
                    fontSize: 15,
                    font: myFont,
                  ),
                ),
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Container(
              margin: const pw.EdgeInsets.symmetric(horizontal: 20),
              height: 30,
              child: pw.FittedBox(
                child: pw.Text(
                  'شماره: ',
                  style: pw.TextStyle(
                    color: baseColor,
                    fontStyle: pw.FontStyle.normal,
                    fontSize: 15,
                    font: myFont,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Expanded(
          child: pw.Container(
            margin: const pw.EdgeInsets.symmetric(horizontal: 20),
            height: 30,
            child: pw.FittedBox(
              child: pw.Text(
                'گیرنده:',
                style: pw.TextStyle(
                  color: baseColor,
                  fontStyle: pw.FontStyle.normal,
                  fontSize: 15,
                  font: myFont,
                ),
              ),
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Container(
            margin: const pw.EdgeInsets.symmetric(horizontal: 20),
            height: 30,
            child: pw.FittedBox(
              child: pw.Text(
                'فرستنده:',
                style: pw.TextStyle(
                  color: baseColor,
                  fontStyle: pw.FontStyle.normal,
                  fontSize: 15,
                  font: myFont,
                ),
              ),
            ),
          ),
        ),
      ]),
      pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Expanded(
          child: pw.Container(
            margin: const pw.EdgeInsets.symmetric(horizontal: 20),
            height: 30,
            child: pw.FittedBox(
              child: pw.Text(
                'تاریخ: ',
                style: pw.TextStyle(
                  color: baseColor,
                  fontStyle: pw.FontStyle.normal,
                  fontSize: 15,
                  font: myFont,
                ),
              ),
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Container(
            margin: const pw.EdgeInsets.symmetric(horizontal: 20),
            height: 30,
            child: pw.FittedBox(
              child: pw.Text(
                'شماره: ',
                style: pw.TextStyle(
                  color: baseColor,
                  fontStyle: pw.FontStyle.normal,
                  fontSize: 15,
                  font: myFont,
                ),
              ),
            ),
          ),
        ),
      ]),
    ]);
  }

  pw.Widget _contentFooter(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 1,
          child: pw.DefaultTextStyle(
            style: const pw.TextStyle(
              fontSize: 10,
              color: _darkColor,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(children: [
                  pw.SizedBox(height: 5),
                  // pw.Divider(color: accentColor),
                  pw.Expanded(
                    child: pw.DefaultTextStyle(
                      style: pw.TextStyle(
                        color: baseColor,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        font: myFont,
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(data!.sum.toString()),
                          pw.Text('مجموع:', textAlign: pw.TextAlign.right),
                        ],
                      ),
                    ),
                  ),
                ]),
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(top: pw.BorderSide(color: _darkColor)),
                  ),
                  child: pw.Row(children: [
                    // pw.SizedBox(height: 5),
                    pw.Divider(color: accentColor),
                    pw.Expanded(
                      child: pw.DefaultTextStyle(
                        style: pw.TextStyle(
                          color: baseColor,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          font: myFont,
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('تحول گیرنده:',
                                textAlign: pw.TextAlign.right),
                            pw.Text('تحویل دهنده:',
                                textAlign: pw.TextAlign.right),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(top: pw.BorderSide(color: _darkColor)),
                  ),
                  child: pw.Row(children: [
                    // pw.SizedBox(height: 5),
                    pw.Divider(color: accentColor),
                    pw.Expanded(
                      child: pw.DefaultTextStyle(
                        style: pw.TextStyle(
                          color: baseColor,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          font: myFont,
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [],
                        ),
                      ),
                    ),
                  ]),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _termsAndConditions(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(color: _darkColor)),
                ),
                padding: const pw.EdgeInsets.only(top: 10, bottom: 4),
                child: pw.Text(
                  'Terms & Conditions',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: baseColor,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Text(
                pw.LoremText().paragraph(40),
                textAlign: pw.TextAlign.justify,
                style: const pw.TextStyle(
                  fontSize: 6,
                  lineSpacing: 2,
                  color: _darkColor,
                ),
              ),
            ],
          ),
        ),
        pw.Expanded(
          child: pw.SizedBox(),
        ),
      ],
    );
  }

  pw.Widget _contentTable(pw.Context context) {
    const tableHeaders = ['توضیحات', 'تعداد', 'شرح کالا', 'ردیف'];

    return pw.Table.fromTextArray(
      border: null,
      cellAlignment: pw.Alignment.centerRight,
      headerDecoration: pw.BoxDecoration(
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
        color: baseColor,
      ),
      headerHeight: 25,
      cellHeight: 40,
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
      },
      headerStyle: pw.TextStyle(
        color: _baseTextColor,
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        font: myFont,
      ),
      cellStyle: pw.TextStyle(
        color: _darkColor,
        fontSize: 10,
        font: myFont,
      ),
      rowDecoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: accentColor,
            width: .5,
          ),
        ),
      ),
      headers: List<String>.generate(
        tableHeaders.length,
        (col) => tableHeaders[col],
      ),
      data: List<List<String>>.generate(
        products.length,
        (row) => List<String>.generate(
          tableHeaders.length,
          (col) => products[row].getIndex(col),
        ),
      ),
    );
  }
}

String _formatCurrency(double amount) {
  return '\$${amount.toStringAsFixed(2)}';
}

String _formatDate(DateTime date) {
  final format = DateFormat.yMMMd('en_US');
  return format.format(date);
}

// class Product {
//   const Product(
//     this.sku,
//     this.productName,
//     this.price,
//     this.quantity,
//   );

//   final String sku;
//   final String productName;
//   final double price;
//   final int quantity;
//   double get total => price * quantity;

//   String getIndex(int index) {
//     switch (index) {
//       case 0:
//         return sku;
//       case 1:
//         return productName;
//       case 2:
//         return _formatCurrency(price);
//       case 3:
//         return quantity.toString();
//       case 4:
//         return _formatCurrency(total);
//     }
//     return '';
//   }
// }
