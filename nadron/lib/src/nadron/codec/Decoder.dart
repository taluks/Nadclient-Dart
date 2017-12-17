
import '../NadEvent.dart';
import 'Transform.dart';

class Decoder extends Transform {
  @override
  transform(input) {
    NadEvent event = new NadEvent.fromJsonString(input);    
    if (event.type != 0 && event.type == NadEvent.NETWORK_MESSAGE)
      event.type = NadEvent.SESSION_MESSAGE;
    return event;
  }
}
