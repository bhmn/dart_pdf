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

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:printing_demo/my_widgets.dart';
import 'package:signature/signature.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

import 'data_send_product.dart';
import 'examples.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  int _tab = 0;
  TabController? _tabController;
  var textDate = 'انتخاب تاریخ';
  List<Product> products = <Product>[];
  Uint8List? imageInUnit8ListSender;
  Uint8List? imageInUnit8ListReceiver;

  // Initialise a controller. It will contains signature points, stroke width and pen color.
// It will allow you to interact with the widget
  final SignatureController _controllerSignatureSender = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  final SignatureController _controllerSignatureReceiver = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  PrintingInfo? printingInfo;

  var _data = const SendProductData();
  var _hasData = false;
  var _pending = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  //DONT FORGET TO DISPOSE IT IN THE `dispose()` METHOD OF STATEFUL WIDGETS
  @override
  void dispose() {
    _controllerSignatureSender.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final info = await Printing.info();

    _tabController = TabController(
      vsync: this,
      length: examples.length,
      initialIndex: _tab,
    );
    _tabController!.addListener(() {
      if (_tab != _tabController!.index) {
        setState(() {
          _tab = _tabController!.index;
        });
      }
      // if (examples[_tab].needsData && !_hasData && !_pending) {
      //   if (kDebugMode) {
      //     print("Yep");
      //   }
      //   _pending = true;
      //   askName(context).then((value) {
      //     if (value != null) {
      //       setState(() {
      //         _data = CustomData(name: value);
      //         _hasData = true;
      //         _pending = false;
      //       });
      //     }
      //   });
      // } else {
      //   if (kDebugMode) {
      //     print("Nope");
      //   }
      // }
    });

    if (examples[_tab].needsData && !_hasData && !_pending) {
      if (kDebugMode) {
        print("Yep");
      }
      _pending = true;
      askName(context).then((value) {
        if (value != null) {
          setState(() {
            _data = SendProductData(
                formNumber: value[0],
                formDate: value[1],
                formReceiver: value[2],
                products: products,
                sum: int.parse(value[3]),
                imageInUnit8ListSender: imageInUnit8ListSender,
                imageInUnit8ListReceiver: imageInUnit8ListReceiver);
            _hasData = true;
            _pending = false;
          });
        }
      });
    } else {
      if (kDebugMode) {
        print("Nope");
      }
    }

    setState(() {
      printingInfo = info;
    });
  }

  void _showPrintedToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document printed successfully'),
      ),
    );
  }

  void _showSharedToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document shared successfully'),
      ),
    );
  }

  Future<void> _saveAsFile(
    BuildContext context,
    LayoutCallback build,
    PdfPageFormat pageFormat,
  ) async {
    final bytes = await build(pageFormat);

    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = appDocDir.path;
    final file = File(appDocPath + '/' + 'document.pdf');
    print('Save as file ${file.path} ...');
    await file.writeAsBytes(bytes);
    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    pw.RichText.debug = true;

    if (_tabController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final actions = <PdfPreviewAction>[
      if (!kIsWeb)
        PdfPreviewAction(
          icon: const Icon(Icons.save),
          onPressed: _saveAsFile,
        )
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter PDF Demo'),
        // bottom: TabBar(
        //   controller: _tabController,
        //   tabs: examples.map<Tab>((e) => Tab(text: e.name)).toList(),
        //   isScrollable: true,
        // ),
      ),
      body: PdfPreview(
        maxPageWidth: 700,
        initialPageFormat: PdfPageFormat.a4,
        allowSharing: false,
        canDebug: true,
        build: (format) => examples[_tab].builder(format, _data),
        actions: actions,
        onPrinted: _showPrintedToast,
        onShared: _showSharedToast,
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.deepOrange,
      //   onPressed: _showSources,
      //   child: const Icon(Icons.code),
      // ),
    );
  }

  // void _showSources() {
  //   ul.launchUrl(
  //     Uri.parse(
  //       'https://github.com/DavBfr/dart_pdf/blob/master/demo/lib/examples/${examples[_tab].file}',
  //     ),
  //   );
  // }

  Future<List<String>?> askName(BuildContext context) {
    //   return showDialog<String>(
    //       barrierDismissible: false,
    //       context: context,
    //       builder: (context) {
    //         final controller = TextEditingController();

    //         return AlertDialog(
    //           title: const Text('Please type your name:'),
    //           contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    //           content: TextField(
    //             decoration: const InputDecoration(hintText: '[your name]'),
    //             controller: controller,
    //           ),
    //           actions: [
    //             TextButton(
    //               onPressed: () {
    //                 if (controller.text != '') {
    //                   Navigator.pop(context, controller.text);
    //                 }
    //               },
    //               child: const Text('OK'),
    //             ),
    //           ],
    //         );
    //       });
    // }
    final controller = TextEditingController();
    final formNumberController = TextEditingController();
    final formReceiverController = TextEditingController();

    final productController = TextEditingController();
    final productNumbersController = TextEditingController();
    final productDescController = TextEditingController();

    final _formKey = GlobalKey<FormState>();
    final _formKeyProduct = GlobalKey<FormState>();

    var selectedDate = DateTime.now();

    // INITIALIZE. RESULT IS A WIDGET, SO IT CAN BE DIRECTLY USED IN BUILD METHOD
    final _signatureCanvasSender = Signature(
      controller: _controllerSignatureSender,
      width: 300,
      height: 300,
      backgroundColor: Colors.white,
    );

    final _signatureCanvasReceiver = Signature(
      controller: _controllerSignatureReceiver,
      width: 300,
      height: 300,
      backgroundColor: Colors.white,
    );

    Padding _myTextFieldWidget(TextEditingController controller, String label) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: TextFormField(
          controller: controller,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'لطفا $label را وارد کنید';
            }
            return null;
          },
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            labelText: '$label : ',
          ),
          style: const TextStyle(
            fontFamily: 'VazirRegular',
          ),
        ),
      );
    }

    Padding _myTextFieldNumberWidget(
        TextEditingController controller, String label) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: TextFormField(
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            // for below version 2 use this
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            // for version 2 and greater youcan also use this
            FilteringTextInputFormatter.digitsOnly
          ],
          controller: controller,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'لطفا $label را وارد کنید';
            }
            return null;
          },
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            labelText: '$label : ',
          ),
          style: const TextStyle(
            fontFamily: 'VazirRegular',
          ),
        ),
      );
    }

    _myElevatedButtonWidget(String text, VoidCallback onPress,
        {double width = 150, double height = 50, Color? color = Colors.blue}) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              elevation: 2,
              fixedSize: Size(width, height),
              backgroundColor: color),
          onPressed: () {
            onPress();
          },
          child: Text(text),
        ),
      );
    }

    Future<String?> _selectDate(BuildContext context) async {
      // final picked = await showDatePicker(
      //     context: context,
      //     initialDate: selectedDate,
      //     firstDate: DateTime(2015, 8),
      //     lastDate: DateTime(2101));
      // if (picked != null && picked != selectedDate) {
      //   setState(() {
      //     selectedDate = picked;
      //   });
      // }
      final picked = await showPersianDatePicker(
        context: context,
        initialDate: Jalali.now(),
        firstDate: Jalali(1385, 8),
        lastDate: Jalali(1450, 9),
        locale: const Locale('fa', 'IR'),
      );
      //final label = picked?.formatFullDate();

      return (picked?.year.toString())! +
          '/' +
          (picked?.month.toString())! +
          '/' +
          (picked?.day.toString())!;
/////////////////////////Example 2 select time////////////////////////////
      // final picked1 = await showTimePicker(
      //   context: context,
      //   initialTime: TimeOfDay.now(),
      // );
      // final label1 = picked1?.persianFormat(context);

      // return label1;
/////////////////////////Example 3 date and time////////////////////////////
      /* final pickedDate = await showModalBottomSheet<Jalali>(
        context: context,
        builder: (context) {
          Jalali? tempPickedDate;
          return Container(
            height: 250,
            child: Column(
              children: <Widget>[
                Container(
                  color: Colors.black54,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      CupertinoButton(
                        child: Text(
                          'لغو',
                          style: TextStyle(
                            fontFamily: 'VazirRegular',
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      CupertinoButton(
                        child: Text(
                          'تایید',
                          style: TextStyle(
                            fontFamily: 'VazirRegular',
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .pop(tempPickedDate ?? Jalali.now());
                        },
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 0,
                  thickness: 1,
                ),
                Expanded(
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      textTheme: const CupertinoTextThemeData(
                          dateTimePickerTextStyle: TextStyle(
                              fontFamily: "VazirRegular", color: Colors.black38),
                          primaryColor: Colors.black54),
                    ),
                    child: PCupertinoDatePicker(
                      mode: PCupertinoDatePickerMode.dateAndTime,
                      onDateTimeChanged: (Jalali dateTime) {
                        tempPickedDate = dateTime;
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
      */

      /////////////////////////Example 4 select from date to date////////////////////////////
      // var picked1 = await showPersianDateRangePicker(
      //   context: context,
      //   initialEntryMode: PDatePickerEntryMode.input,
      //   initialDateRange: JalaliRange(
      //     start: Jalali(1400, 1, 2),
      //     end: Jalali(1400, 1, 10),
      //   ),
      //   firstDate: Jalali(1385, 8),
      //   lastDate: Jalali(1450, 9),
      // );
    }

    // String _datetime = '';
    // String _format = 'yyyy-mm-dd';
    // String _valuePiker = '';

    // void _changeDatetime(int year, int month, int day) {
    //   setState(() {
    //     _datetime = '$year-$month-$day';
    //   });
    // }

    String uint8ListTob64(Uint8List uint8list) {
      var base64String = base64Encode(uint8list);
      var header = 'data:image/png;base64,';
      return header + base64String;
    }

    /// Display date picker.
    return showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation,
            Animation secondaryAnimation) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return Scaffold(
              body: Center(
                child: Container(
                  // width: MediaQuery.of(context).size.width - 10,
                  // height: MediaQuery.of(context).size.height - 80,
                  padding: const EdgeInsets.all(5.0),
                  color: Colors.black45,
                  child: Form(
                    key: _formKey,
                    child: Center(
                      child:
                          ListView(scrollDirection: Axis.vertical, children: <
                              Widget>[
                        Flex(
                          direction: Axis.vertical,
                          children: [
                            Column(
                              children: [
                                _myTextFieldWidget(
                                  formNumberController,
                                  'شماره فرم',
                                ),
                                Row(
                                  children: [
                                    // ignore: prefer_const_constructors
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 16),
                                      child: const Text(
                                        'تاریخ فرم:',
                                        style: TextStyle(
                                          fontFamily: 'VazirRegular',
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 16),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _selectDate(context).then((value) {
                                            setState(() {
                                              textDate = value!;
                                              print(textDate);
                                            });
                                          });
                                        },
                                        child: Text(
                                          textDate,
                                          style: const TextStyle(
                                            fontFamily: 'VazirRegular',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                _myTextFieldWidget(
                                  formReceiverController,
                                  'گیرنده',
                                ),
                                const Divider(
                                  height: 20,
                                  color: Colors.amberAccent,
                                ),
                                Form(
                                  key: _formKeyProduct,
                                  child: Center(
                                    child: Column(
                                      children: [
                                        const Text('مشخصات کالا'),
                                        _myTextFieldWidget(
                                          productController,
                                          'شرح کالا',
                                        ),
                                        _myTextFieldNumberWidget(
                                          productNumbersController,
                                          'تعداد',
                                        ),
                                        _myTextFieldWidget(
                                          productDescController,
                                          'توضیحات',
                                        ),
                                        _myElevatedButtonWidget(
                                          'افزودن به لیست',
                                          () {
                                            if (!_formKeyProduct.currentState!
                                                .validate()) {
                                              return;
                                            }

                                            setState(() {
                                              products.add(
                                                Product(
                                                    rowNumber:
                                                        (products.length + 1)
                                                            .toString(),
                                                    product:
                                                        productController.text,
                                                    productNumber: int.parse(
                                                        productNumbersController
                                                            .text),
                                                    productDescription:
                                                        productDescController
                                                            .text),
                                              );
                                              // productController.clear();
                                              // productNumbersController
                                              //     .clear();
                                              // productDescController.clear();

                                              if (kDebugMode) {
                                                print(products[0].product);
                                              }
                                            });
                                          },
                                          height: 40,
                                          width: 150,
                                        ),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const ClampingScrollPhysics(),
                                          scrollDirection: Axis.vertical,
                                          itemCount: products.length,
                                          itemBuilder:
                                              (BuildContext ctxt, int index) {
                                            /// return Text(entries[index]);
                                            // ignore: prefer_const_constructors
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                ),
                                                elevation: 2.0,
                                                // ignore: prefer_const_constructors
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.blue.withAlpha(30),
                                                  onTap: () {},
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Column(
                                                          // ignore: prefer_const_literals_to_create_immutables
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              // ignore: prefer_const_literals_to_create_immutables
                                                              children: <
                                                                  Widget>[
                                                                generalText(
                                                                    'شرح کالا: '),
                                                                generalText(
                                                                    products[
                                                                            index]
                                                                        .product,
                                                                    color: Colors
                                                                        .blue),
                                                              ],
                                                            ),
                                                            Row(
                                                              // ignore: prefer_const_literals_to_create_immutables
                                                              children: <
                                                                  Widget>[
                                                                generalText(
                                                                  'تعداد: ',
                                                                ),
                                                                generalText(
                                                                  products[
                                                                          index]
                                                                      .productNumber
                                                                      .toString(),
                                                                  color: Colors
                                                                      .blue,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              // ignore: prefer_const_literals_to_create_immutables
                                                              children: <
                                                                  Widget>[
                                                                generalText(
                                                                  'توضیحات: ',
                                                                ),
                                                                generalText(
                                                                  products[
                                                                          index]
                                                                      .productDescription,
                                                                  color: Colors
                                                                      .blue,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: generalText(
                                              'امضاء تحویل دهنده:',
                                              color: Colors.white),
                                        ),
                                        _signatureCanvasSender,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            _myElevatedButtonWidget(
                                              'پاک کردن',
                                              () {
                                                // CLEAR CANVAS
                                                _controllerSignatureSender
                                                    .clear();
                                              },
                                              height: 50,
                                              width: 200,
                                            ),
                                            // _myElevatedButtonWidget(
                                            //   'ذخیره امضاء',
                                            //   () {
                                            //     // EXPORT BYTES AS PNG
                                            //     // The exported image will be limited to the drawn area
                                            //    // async variant
                                            //   },
                                            //   height: 50,
                                            //   width: 200,
                                            // ),
                                          ],
                                        )
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: generalText(
                                              'امضاء تحویل گینده:',
                                              color: Colors.white),
                                        ),
                                        _signatureCanvasReceiver,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            _myElevatedButtonWidget(
                                              'پاک کردن',
                                              () {
                                                // CLEAR CANVAS
                                                _controllerSignatureReceiver
                                                    .clear();
                                              },
                                              height: 50,
                                              width: 200,
                                            ),
                                            // _myElevatedButtonWidget(
                                            //   'ذخیره امضاء',
                                            //   () {
                                            //     // EXPORT BYTES AS PNG
                                            //     // The exported image will be limited to the drawn area
                                            //     // async variant
                                            //   },
                                            //   height: 50,
                                            //   width: 200,
                                            // ),
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                _myElevatedButtonWidget(
                                  'ثبت و پیش نمایش فرم',
                                  () {
                                    if (_formKey.currentState!.validate()) {
                                      var sum = 0;
                                      for (var product in products) {
                                        sum += product.productNumber;
                                      }
                                      print(sum);
                                      //---------------------------------------------///
                                      //save signature
                                      _controllerSignatureSender
                                          .toPngBytes()
                                          .then((value) async {
                                        // callback variant

                                        imageInUnit8ListSender =
                                            value!; // store unit8List image here ;
                                        final appDocDir =
                                            await getApplicationDocumentsDirectory();
                                        final appDocPath = appDocDir.path;
                                        final file1 = File(
                                            appDocPath + '/' + 'image.png');
                                        print('Save as file ${file1.path} ...');
                                        await file1.writeAsBytes(
                                            imageInUnit8ListSender!);
                                        await OpenFile.open(file1.path);

                                        // print(uint8ListTob64(value));
                                      });
                                      //end save signature
                                      _controllerSignatureReceiver
                                          .toPngBytes()
                                          .then((value) async {
                                        // callback variant

                                        imageInUnit8ListReceiver =
                                            value!; // store unit8List image here ;
                                        final appDocDir =
                                            await getApplicationDocumentsDirectory();
                                        final appDocPath = appDocDir.path;
                                        final file1 = File(
                                            appDocPath + '/' + 'image1.png');
                                        print('Save as file ${file1.path} ...');
                                        await file1.writeAsBytes(
                                            imageInUnit8ListReceiver!);
                                        await OpenFile.open(file1.path);

                                        // print(uint8ListTob64(value));

                                        Navigator.of(context).pop([
                                          formNumberController.text,
                                          textDate,
                                          formReceiverController.text,
                                          sum.toString(),
                                        ]);
                                      });
                                      //end save signature
                                      //---------------------------------------------///

                                      if (kDebugMode) {}
                                    }
                                  },
                                  height: 50,
                                  width: 200,
                                ),
                              ],
                            )
                          ],
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }
}
