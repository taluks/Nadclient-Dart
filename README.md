# nadron_dart
Dart library which implements the protocol for the Nadron (https://github.com/menacher/java-game-server/tree/netty4)


```
 Config config = new Config(["user", "pass", "reconnectKey"]);
  Function _onStart = (Session session) => print("connected");
  Session session =
      new Session("ws://localhost:18090/nadsocket", config, _onStart);
  session.send(new NadEvent(NadEvent.SESSION_MESSAGE, {"text": "test"}));
  session.addHandler(NadEvent.ANY,
      (NadEvent e) => print("Event any " + (e != null ? e.toString() : "null")));
```
