import 'Config.dart';
import 'NadEvent.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:html';

class Session {
  static const int CONNECTING = 0;
  static const int CONNECTED = 1;
  static const int NOT_CONNECTED = 2;
  static const int CLOSED = 3;

  Function onError;
  Function onMessage;
  Function onClose;

  WebSocket _ws;
  String _url;
  Config _config;
  Function _onStart;
  HashMap _handlers;
  String _reconnectKey;
  int _state = CONNECTING;

  StreamSubscription<MessageEvent> subscMessage;

  Session(this._url, this._config, this._onStart) {
    _handlers = new HashMap();
    clearHandlers();
    _ws = connectWebSocket(_url);
  }

// -------- WS -------
  WebSocket connectWebSocket(url) {
    WebSocket ws = new WebSocket(_url);
    ws.onOpen.listen(_onWsOpen);
    subscMessage = ws.onMessage.listen(_onWsMessage);
    ws.onClose.listen(_onWsClose);
    ws.onError.listen(_onWsError);
    return ws;
  }

  void _onWsOpen(Event event) {
    print("ws open");
    if (_state == CONNECTING) {
      _ws.send(loginEvent());
    } else if (_state == NOT_CONNECTED) {
      _ws.send(reconectEvent(_reconnectKey));
    } else {
      var evt = new NadEvent(NadEvent.EXCEPTION,
          "Cannot reconnect when session state is: " + _state.toString());
      onError(evt);
      dispatch(NadEvent.EXCEPTION, evt);
    }
  }

  void _onWsMessage(MessageEvent event) {
    NadEvent evt = _config.codecs.decoder.transform(event.data);
    if (evt.type == CONNECTING) {
      throw new ArgumentError("Event object missing 'type' property.");
    }
    if (evt.type == NadEvent.LOG_IN_FAILURE ||
        evt.type == NadEvent.GAME_ROOM_JOIN_FAILURE) {
      _ws.close();
    }
    if (evt.type == NadEvent.GAME_ROOM_JOIN_SUCCESS) {
      _reconnectKey = evt.source == null ? _reconnectKey : evt.source;
    }
    if (evt.type == NadEvent.START) {
      if (_onStart != null) {
        _state = CONNECTED;
        applyProtocol();
        _onStart(this);
      }
    }
  }

  void _onWsClose(CloseEvent event) {
    _state = NOT_CONNECTED;
    dispatch(
        NadEvent.DISCONNECT, new NadEvent(NadEvent.DISCONNECT, null, this));
  }

  void _onWsError(Event event) {
    _state = NOT_CONNECTED;
    dispatch(NadEvent.EXCEPTION, new NadEvent(NadEvent.EXCEPTION, null, this));
  }

  void applyProtocol() {
    subscMessage.cancel();
    _ws.onMessage.listen(protocol);
  }

  dynamic loginEvent() {
    return _config.codecs.encoder.transform(new NadEvent(
        NadEvent.LOG_IN, _config.credentials));
  }

  dynamic reconectEvent(String reconnectKey) {
    if (reconnectKey == null)
      throw new ArgumentError("Session does not have reconnect key");
    return _config.codecs.encoder
        .transform(new NadEvent(NadEvent.RECONNECT, reconnectKey));
  }

  void protocol(MessageEvent event) {
    NadEvent evt = _config.codecs.decoder.transform(event.data);

    dispatch(evt.type, evt);
  }

// -------- HANDLERS -------
  void addHandler(int eventName, Function callback) {
    if (_handlers[eventName] == null) _handlers[eventName] = new List();
    _handlers[eventName].add(callback);
  }

  void removeHandler(int eventName, Function callback) {
    _handlers[eventName].remove(callback);
  }

  void clearHandlers() {
    _handlers.clear();
    onError = (NadEvent event) => {};
    onMessage = (NadEvent event) => {};
    onClose = (NadEvent event) => {};
  }

  void close() {
    _state = CLOSED;
    _ws.close();
    dispatch(NadEvent.CLOSED, new NadEvent(NadEvent.CLOSED));
  }

  void disconnect() {
    _state = NOT_CONNECTED;
    _ws.close();
  }

  void reconnect(Function callback) {
    if (_state != NOT_CONNECTED) {
      throw new ArgumentError(
          "Session is not in not-connected state. Cannot reconnect now");
    }
    _onStart = callback;
    _ws = connectWebSocket(_url);
  }

  Session send(NadEvent event) {
    if (_state != 1 && !((event.type == NadEvent.RECONNECT) && (_state == 2))) {
      throw new ArgumentError("Session is not in connected state");
    }
    _ws.send(_config.codecs.encoder
        .transform(event)); // <= send JSON/Binary data to socket server
    return this; // chainable
  }

  void dispatch(int eventName, NadEvent evt) {
    if (evt.target == null) {
      evt.target = this;
    }
    if (eventName == NadEvent.SESSION_MESSAGE) {
      this.onMessage(evt);
    }
    if (eventName == NadEvent.CLOSED) {
      this.onClose(evt);
    }
    dispatchToEventHandlers(_handlers[NadEvent.ANY], evt);
    dispatchToEventHandlers(_handlers[eventName], evt);
  }

  void dispatchToEventHandlers(List chain, NadEvent evt) {
    if (chain == null) return;
    for (var i = 0; i < chain.length; i++) {
      chain[i](evt);
    }
  }
}
