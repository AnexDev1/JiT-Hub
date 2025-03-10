import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:nex_planner/pages/HomePage/Category/Academics/calendar/pdfViewer_page.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
class AcademicCalendar extends StatefulWidget {
  const AcademicCalendar({super.key});

  @override
  _AcademicCalendarState createState() => _AcademicCalendarState();
}

class _AcademicCalendarState extends State<AcademicCalendar> {
  String? localPath;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    final byteData = await rootBundle.load('lib/assets/academic_calendar.pdf');
    final file = File('${(await getTemporaryDirectory()).path}/academic_calendar.pdf');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    setState(() {
      localPath = file.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: localPath == null
          ? const Center(child: CircularProgressIndicator())
          : PDFViewerPage(pdfPath: localPath!),
    );
  }
}