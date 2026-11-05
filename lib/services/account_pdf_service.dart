import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AccountPdfService {
  static Future<void> share({
    required String language,
    required Map<String, String> fields,
  }) async {
    final urduData = await rootBundle.load('assets/fonts/NotoNastaliqUrdu.ttf');
    final hindiData = await rootBundle.load('assets/fonts/NotoSansDevanagari.ttf');
    final englishData = await rootBundle.load('assets/fonts/NotoSansEnglish.ttf');
    final urduFont = pw.Font.ttf(urduData);
    final hindiFont = pw.Font.ttf(hindiData);
    final englishFont = pw.Font.ttf(englishData);

    final isUrdu = language == 'ur';
    final isHindi = language == 'hi';
    final isRtl = isUrdu;
    final primaryFont = isUrdu ? urduFont : isHindi ? hindiFont : englishFont;
    final labels = language == 'ur'
        ? <String>['واپاری — انفرادی کھاتے کی رپورٹ', 'نام', 'ولدیت', 'پتہ', 'موبائل نمبر', 'اجناس', 'کل بوریاں', 'فی بوری وزن', 'بوریوں کا کل وزن', 'اضافی وزن', 'کل وزن', 'من', 'باقی کلو', 'فی کلو ریٹ', 'فی من ریٹ', 'کل قیمت', 'تاریخ']
        : language == 'hi'
            ? <String>['व्यापारी — व्यक्तिगत खाता रिपोर्ट', 'नाम', 'पिता का नाम', 'पता', 'मोबाइल नंबर', 'वस्तु', 'कुल बोरियाँ', 'प्रति बोरी वजन', 'बोरियों का कुल वजन', 'अतिरिक्त वजन', 'कुल वजन', 'मन', 'शेष किलो', 'प्रति किलो दर', 'प्रति मन दर', 'कुल राशि', 'तारीख']
            : <String>['Wapari — Individual Account Report', 'Name', 'Father name', 'Address', 'Mobile number', 'Commodity', 'Total bags', 'Weight per bag', 'Total bag weight', 'Additional weight', 'Total weight', 'Maunds', 'Remaining kg', 'Rate per kg', 'Rate per maund', 'Total amount', 'Date'];
    final keys = <String>['name', 'father', 'address', 'phone', 'commodity', 'bags', 'bagWeight', 'bagTotal', 'extra', 'totalWeight', 'maunds', 'remaining', 'kgRate', 'maundRate', 'totalPrice', 'date'];
    final rows = <pw.Widget>[];
    for (var i = 0; i < keys.length; i++) {
      final value = fields[keys[i]] ?? '';
      if (value.isEmpty && (keys[i] == 'father' || keys[i] == 'address' || keys[i] == 'phone')) continue;
      rows.add(
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: pw.BoxDecoration(
            color: i.isEven ? PdfColors.grey100 : PdfColors.white,
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: .5)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 5,
                child: pw.Text(labels[i + 1], style: pw.TextStyle(font: primaryFont, fontSize: 10), textDirection: isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr, textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                flex: 6,
                child: pw.Text(value, style: pw.TextStyle(font: primaryFont, fontSize: 10), textDirection: isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr, textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left),
              ),
            ],
          ),
        ),
      );
    }

    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(34),
        build: (context) => [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: const pw.BoxDecoration(color: PdfColors.green900),
            child: pw.Text(
              labels.first,
              style: pw.TextStyle(font: primaryFont, fontSize: 17, color: PdfColors.white),
              textDirection: isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(height: 18),
          pw.Column(children: rows),
          pw.SizedBox(height: 18),
          pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Wapari',
              style: pw.TextStyle(font: englishFont, fontSize: 9, color: PdfColors.grey600),
            ),
          ),
        ],
      ),
    );
    final safeName = (fields['name'] ?? 'account').replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');
    await Printing.sharePdf(bytes: await document.save(), filename: 'wapari_$safeName.pdf');
  }
}
