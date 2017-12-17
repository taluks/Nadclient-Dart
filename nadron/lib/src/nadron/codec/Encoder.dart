import 'Transform.dart';
import 'dart:convert';

class Encoder extends Transform {
  @override
  transform(input) {
    return JSON.encode(input);
  }
}
