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
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
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
  var textDate = 'تاریخ';

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
            _data = SendProductData(formNumber: value[0], formDate: value[2]);
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

  void _showSources() {
    ul.launchUrl(
      Uri.parse(
        'https://github.com/DavBfr/dart_pdf/blob/master/demo/lib/examples/${examples[_tab].file}',
      ),
    );
  }

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
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    var selectedDate = DateTime.now();

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

    String _datetime = '';
    String _format = 'yyyy-mm-dd';
    String _valuePiker = '';

    void _changeDatetime(int year, int month, int day) {
      setState(() {
        _datetime = '$year-$month-$day';
      });
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
                      child: ListView(
                          scrollDirection: Axis.vertical,
                          children: <Widget>[
                            Flex(
                              direction: Axis.vertical,
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 16),
                                      child: TextFormField(
                                        controller: usernameController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'لطفا شماره فرم را وارد کنید';
                                          }
                                          return null;
                                        },
                                        decoration: const InputDecoration(
                                          border: UnderlineInputBorder(),
                                          labelText: 'شماره فرم: ',
                                        ),
                                        style: const TextStyle(
                                          fontFamily: 'VazirRegular',
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 16),
                                      child: TextFormField(
                                        controller: passwordController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'لطفا کلمه عبور خود را وارد کنید';
                                          }
                                          return null;
                                        },
                                        decoration: const InputDecoration(
                                          border: UnderlineInputBorder(),
                                          labelText: 'کلمه عبور',
                                        ),
                                        style: const TextStyle(
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
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 16),
                                      child: Text(textDate,
                                          style: const TextStyle(
                                              fontFamily: 'VazirRegular',
                                              color: Colors.white)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 16),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            elevation: 2,
                                            fixedSize: const Size(150, 50)),
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            if (kDebugMode) {}
                                            Navigator.of(context).pop([
                                              usernameController.text,
                                              passwordController.text,
                                              textDate
                                            ]);
                                          }
                                        },
                                        child: Text('ورود'),
                                      ),
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
