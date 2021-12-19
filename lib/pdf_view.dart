import 'package:czytelnia/user_state.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart' as pdf;

class PDFView extends StatefulWidget {
  int bookId;
  PDFView(this.bookId, {Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<PDFView> {
  //late File urlFile;
  int pages = 0;
  bool isReady = false;

  Future<String> getPDF() async {
    // try {
    //   final token = Provider.of<UserState>(context, listen: false).token;
    //   var data = await http.get(
    //     Uri.parse('127.0.0.1:8000/api/books/get_pdf/1'),
    //     headers: <String, String>{
    //       'Authorization': token,
    //     },
    //   ).timeout(const Duration(seconds: 1));
    //   print("PLIK WCZYTANY\n");
    //   var bytes = data.bodyBytes;
    //   final dir = await Pspdfkit.getTemporaryDirectory();
    //   final File file = await File(dir.path).create();
    //   urlFile = await file.writeAsBytes(bytes);
    // } catch (e) {
    //   print("Ja nie paniemaju\n");
    //   //throw Exception("Error opening url file");
    // }
    // final dir = await getApplicationDocumentsDirectory();
    // File urlFile = await File('$dir.path/assets/notka.pdf');
    // await Pspdfkit.present(urlFile.path);
    final token = Provider.of<UserState>(context, listen: false).token;
    print("PO TOkENIE");
    var file = await DefaultCacheManager().getSingleFile(
      'http://10.0.2.2:8000/api/books/${widget.bookId}/pdf',
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );
    return file.path;
    //await Pspdfkit.present(file.path);
  }

  Widget PDFRender() {
    return FutureBuilder(
        future: getPDF(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return pdf.PDFView(
              filePath: snapshot.data,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: false,
              pageFling: false,
              onRender: (_pages) {
                setState(() {
                  isReady = true;
                });
              },
              onError: (error) {
                print(error.toString());
              },
              onPageError: (page, error) {
                print('$page: ${error.toString()}');
              },
            );
          } else {
            return Column(
              children: [CircularProgressIndicator()],
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Temp Title'),
        ),
        body: PDFRender());
  }

//   @override
//   Widget build(BuildContext context) {
//     final themeData = Theme.of(context);
//     return MaterialApp(
//       home: Scaffold(
//       body: FutureBuilder(
//         future : getPDF(),
//         builder: (BuildContext context, AsyncSnapshot<String>snap) {
//           return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               ElevatedButton(
//               child: Text('Tap to Open Document',
//                 style: themeData.textTheme.headline4?.copyWith(fontSize: 21.0)),
//                 onPressed: () {
//                   if(snap.hasData){
//                     Pspdfkit.present(snap.data.toString());
//                   }
//                 }
//               )
//             ]));
//         },
//       )),
//     );
//   }
}