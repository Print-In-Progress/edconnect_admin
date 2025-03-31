import 'package:edconnect_admin/core/utils/crypto_utils.dart';
import 'package:edconnect_admin/domain/entities/registration_fields.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pointycastle/export.dart' as pc;

class PdfService {
  static Future<Uint8List> generateRegistrationPdf(
      List<BaseRegistrationField> flattenedRegistrationList,
      bool signed,
      String uid,
      String orgName,
      String lastName,
      String firstName,
      String email,
      {pc.RSAPublicKey? publicKey}) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'edConnect Registration Form',
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('edConnect Registration Form', textScaleFactor: 2),
            pw.SizedBox(height: 10),
            pw.Text(
              orgName,
              textScaleFactor: 1.5,
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              defaultColumnWidth: const pw.FlexColumnWidth(1),
              children: [
                pw.TableRow(
                  children: [
                    pw.Text(
                      'Last Name',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'First Name',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Email',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text(
                      lastName.trim()[0].toUpperCase() +
                          lastName.trim().substring(1),
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      firstName.trim()[0].toUpperCase() +
                          firstName.trim().substring(1),
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      email.trim(),
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Text('edConnect User ID: $uid',
                style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 30),
            // free_response x, dropdown x, checkbox x, checkbox_assign_group x, signature, file_upload x, infobox, date x
            for (var field in flattenedRegistrationList)
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                },
                border: const pw.TableBorder(
                  bottom: pw.BorderSide(width: 0.5), // Define a thin border
                ),
                children: [
                  if (field.type == 'free_response')
                    pw.TableRow(
                      children: [
                        pw.Text(field.title,
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text(field.response!.text,
                            style: const pw.TextStyle(fontSize: 14),
                            textAlign: pw.TextAlign.right),
                      ],
                    ),
                  if (field.type == 'dropdown')
                    pw.TableRow(
                      children: [
                        pw.Text(field.title,
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text(field.selectedOption!,
                            style: const pw.TextStyle(fontSize: 14),
                            textAlign: pw.TextAlign.right),
                      ],
                    ),
                  if (field.type == 'checkbox')
                    pw.TableRow(
                      children: [
                        pw.Text(field.title,
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text(field.checked! ? 'Yes' : 'No',
                            style: const pw.TextStyle(fontSize: 14),
                            textAlign: pw.TextAlign.right),
                      ],
                    ),
                  if (field.type == 'checkbox_assign_group')
                    pw.TableRow(
                      children: [
                        pw.Text(field.title,
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text(field.checked! ? 'Yes' : 'No',
                            style: const pw.TextStyle(fontSize: 14),
                            textAlign: pw.TextAlign.right),
                      ],
                    ),
                  if (field.type == 'date')
                    pw.TableRow(
                      children: [
                        pw.Text(field.title,
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                            DateFormat.yMd()
                                .format(field.selectedDate!)
                                .toString(),
                            style: const pw.TextStyle(fontSize: 14),
                            textAlign: pw.TextAlign.right),
                      ],
                    ),
                  if (field.type == 'file_upload')
                    pw.TableRow(
                      children: [
                        pw.Text(field.title,
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                            '${field.file?.length.toString() ?? '0'} files uploaded',
                            style: const pw.TextStyle(fontSize: 14),
                            textAlign: pw.TextAlign.right),
                      ],
                    ),
                ],
              ),
            if (signed)
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 20),
                child: pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'This form was cryptographically signed by the user with the edConnect System.',
                      style: pw.TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    pw.Text(
                      'The public key fingerprint is: ${generatePublicKeyFingerprint(publicKey!)}',
                      style: pw.TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
    return await pdf.save();
  }
}
