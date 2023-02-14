// import 'package:gsheets/gsheets.dart';

// import 'sheet_fields.dart';

// // ignore: avoid_classes_with_only_static_members
// class SliderSheetAPI {
//   static const _spreadSheetID = '1NqtCSfkYRPvXwB4g4cqYiIgZ-uyBLphanlQpeXNiGOI';
//   static const _credentials = r'''
// {
//   "type": "service_account",
//   "project_id": "dogwood-reserve-321202",
//   "private_key_id": "7d524ed0c562e4e54c28ce392bc6888ca6c1526e",
//   "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCK7ZxjRIs0MmRc\nE+C4sJ83CBQtEyh3P6T2h89bfI7PHuV6WhIpUIl8D3e4sy/bhAonJtHFrzWSMG1o\nGtnCMS86ZX5IQSo6anaky54Sgjo88+fp88x5QhqN1Loik7YZZTZ8N6XXhbz+Y3ZH\nTVnyEoNfHPpwWLsDiDTM6MqYXoNS1Pe6SVMukVUQJJjkY5miByySafJSGH1Qfz/c\nSgPYXfuDQ61K4eT5wT8pCNocZwofSjwwWnB55cNEpUUFlkdTOTu1FKU28HMTayZe\n7kVDj9U3HFDRYm4s+4JsLOlJ1d6y2M07KrATQG38qTpWFMfZVWl8JQC8Nv+nbnZs\ngcm+xawtAgMBAAECggEAHxlilSweVzBim+QNPXq4IVsLHS35NHyIQnGTXuDqnP3H\nE9T+1MXFCQLzY2KlN2f+19XORojanp99ljzQezKEZneaxbTkrY/wgCJef7ksLUHS\nK+JZ5tj/1bkFc8EKFfQ8tqDEXJMBBBcivoJXvKMdSljTzPtn3boLS8VeuK4Liqpy\nW1As8RoJz1hwPTMNokU+bu42Kh3mkChctawJvFcINhDrq/5VGGLz1jtMWJx6o0e0\nRU/ieBhW8V3LZgjLBwzBnIkfU/QmqSBHHKvQdB5rkYYY6D3GqkK5Zrbv2sXIDpl5\nKS31PA5hhpTKPRSj1tRUf3NczUmamzl4K9t0z3e5JwKBgQC/IX82+2kspTcEOavt\ny9ocJUu+Csf5f1JnEfbXIQAbbecIr4mw7rSw4cebxGBoN/HdH7nDxx9iq8LlOSvL\n2o/jTDuclTEnF+p4Q+7PLzKBAQWt0OdcJHJI6NFStJgb4Cy3/A5duNlc/t0Dn5c5\nH57V+y6n6PxyXAVc9e/Xf2KxWwKBgQC6FHT8FAs8b1I0YB0aKJO1y/TEfzkevK51\ne1wBh5n2pQIDKTr0oEfNpQ4Negw2SzkS6/HvLKYhDKtktrIzXui6x1yOf4CEu9Hs\nTovjSGBe5n8D1+gFY+N9mGWEG8c8J55CEGvO0J2R6Zx9vI5zVFocmnfHH7R1mbmJ\neArasz7HFwKBgQCh+oxql1TB/l6K2SlpBSsaUU1IiLCDNLEsIqBUH2aM2G5FAScq\n6JH/mcjlrN6bVFZItRtk3PsvTyuDwhjo0ZjB5BhdEl8up2kRdVkNAw3FII2kifeZ\nMlYcjhrgAacrcKfVYOr36LFly6SY7oZlZfPhmtcmfCB99pig+NjDg/SrIwKBgQCf\n5sZke+Dv7QVqBpHbkbTky0Apvt3Z4O/V+sykb99JSKCDEOIdpsItIEIEKLXnzhpc\nfS6ohei4i8eYwzo81LkPEBQkS8KnzTJma1TgWaiexFmvdtBmGWE640ORE8HQmobv\nZGcQEMrmwSX+EpMi3gCVhdOZ5E/RoukCDYreRpuSvwKBgBV58+ekFwNrzJx8XhJK\nVDc/Naa0XDLP5UcxYGSmyeDcYCD7Zg27fXtwCO34MESRLi7oiXLxlfQ2GiwO3pEp\nRrtvcHZLVhe8sGkOcCRAMGRiNhA2mkYl5jdpmPAC1dizWs8zCouGuGNDcM0iZ5Ry\nsnRZ09wgO1uZMPDz4ykv6e47\n-----END PRIVATE KEY-----\n",
//   "client_email": "gsheets@dogwood-reserve-321202.iam.gserviceaccount.com",
//   "client_id": "110059417066777471194",
//   "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//   "token_uri": "https://oauth2.googleapis.com/token",
//   "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
//   "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/gsheets%40dogwood-reserve-321202.iam.gserviceaccount.com"
// }
// ''';
//   static final _gSheet = GSheets(_credentials);
//   static Worksheet? _dataSheet;
//   static Worksheet? _slidersSheet;

//   static Future init() async {
//     try {
//       final spreadsheet = await _gSheet.spreadsheet(_spreadSheetID);
//       _dataSheet = await _getWorkSheet(spreadsheet, title: 'data');
//       _slidersSheet = await _getWorkSheet(spreadsheet, title: 'Sliders');
//       //final firstRow = DataSheetFields.getFields();
//       //_dataSheet!.values.insertRow(1, firstRow);
//     } catch (e) {}
//   }

//   static Future<Worksheet?> _getWorkSheet(
//     Spreadsheet spreadsheet, {
//     required String title,
//   }) async {
//     try {
//       return _dataSheet = await spreadsheet.addWorksheet(title);
//     } catch (e) {
//       return _dataSheet = spreadsheet.worksheetByTitle(title);
//     }
//   }

//   static Future<DataSheet?> getById(int key) async {
//     if (_dataSheet == null) {
//       return null;
//     }
//     final json = await _dataSheet!.values.map.rowByKey(key, fromColumn: 1);
//     return json == null ? null : DataSheet.fromJson(json);
//   }

//   static Future<double?>? getCacheVersion() async {
//     if (_dataSheet != null) {
//       try {
//         final value = await _dataSheet!.values.value(row: 2, column: 1);
//         return double.tryParse(value);
//       } on Exception {
//         return -1;
//       }
//     }
//     return null;
//   }

//   static Future insert(List<Map<String, dynamic>> rowList) async {
//     if (_dataSheet == null) return;
//     _dataSheet!.values.map.appendRows(rowList);
//   }

//   static Future<int> getRowCount() async {
//     if (_dataSheet == null) return 0;
//     final lastRow = await _dataSheet!.values.lastRow();
//     return lastRow == null ? 0 : int.tryParse(lastRow.first) ?? 0;
//   }

//   static Future<List<HomeSlider>> getAllSlides() async {
//     if (_slidersSheet == null) return <HomeSlider>[];

//     final slides = await _slidersSheet!.values.map.allRows();
//     if (slides != null) {
//       return slides.map((json) => HomeSlider.fromJson(json)).toList();
//     }
//     return <HomeSlider>[];
//   }
// }
