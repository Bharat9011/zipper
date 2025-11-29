import 'package:archive/archive_io.dart';
import 'dart:io';

void main() {
  final encoder = ZipEncoder();
  encoder.startEncode(OutputFileStream('test.zip'));
}
