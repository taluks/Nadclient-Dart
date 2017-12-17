import 'codec/Codecs.dart';

class Config {
  List<String> credentials;
  Codecs _codecs;
  
  Config(this.credentials) {}

  Codecs get codecs => _codecs;
  void set codecs(Codecs codecs) {
    _codecs = codecs;
  }
}
