import 'NetEvent.dart';
import 'package:json_object/json_object.dart' show JsonObject;

class NadEvent extends JsonObject implements NetEvent{

    // Event code Constants
  static const int ANY = 0x00;
  static const int PROTOCOL_VERSION = 0x01;

  static const int CONNECT = 0x02;
  static const int RECONNECT = 0x03;
  static const int CONNECT_FAILED = 0x06;
  static const int LOG_IN = 0x08;
  static const int LOG_OUT = 0x0a;//10
  static const int LOG_IN_SUCCESS = 0x0b;//11
  static const int LOG_IN_FAILURE = 0x0c;//12
  static const int LOG_OUT_SUCCESS = 0x0e;//14
  static const int LOG_OUT_FAILURE = 0x0f;//15

  static const int GAME_LIST = 0x10;//16
  static const int ROOM_LIST = 0x12;//18
  static const int GAME_ROOM_JOIN = 0x14;//20
  static const int GAME_ROOM_LEAVE = 0x16;//22
  static const int GAME_ROOM_JOIN_SUCCESS = 0x18;//24
  static const int GAME_ROOM_JOIN_FAILURE = 0x19;//25

  //Event sent from server to client to start message sending from client to server.
  static const int START = 0x1a;//26
  // Event sent from server to client to stop messages from being sent to server.
  static const int STOP = 0x1b;//27
  // Incoming data from server or from another session.
  static const int SESSION_MESSAGE = 0x1c;//28
  // This event is used to send data from the current machine to remote server
  static const int NETWORK_MESSAGE = 0x1d;//29
  static const int CHANGE_ATTRIBUTE = 0x20;//32
  static const int DISCONNECT =
      0x22; // Use this one for handling close event of ws.
  static const int EXCEPTION = 0x24;//36

  static const int CLOSED = 0x25;//37


  var target;
  String cName;
  NadEvent([type, source, target, cName, timeStamp]) {
    this.type = type;
    this.source = source;
    this.cName = cName;
    this.timeStamp = timeStamp;
    if (null == this.timeStamp) {
      this.timeStamp = new DateTime.now().millisecondsSinceEpoch;
    }
  }
  factory NadEvent.fromJsonString(string) {
    return new JsonObject.fromJsonString(string, new NadEvent());
  }
}
