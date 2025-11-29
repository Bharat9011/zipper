import 'package:archive/archive_io.dart';
import 'dart:io';

void main() {
  final encoder = ZipEncoder();
  // encoder.password = '123'; // Does this exist?
  
  // Or in create?
  // final archive = Archive();
  // encoder.encode(archive, level: Deflate.BEST_COMPRESSION, password: '123');
}
