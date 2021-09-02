import 'dart:io';

import 'package:clipboard_sync/logic/network/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class App extends HookWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketStream = useMemoized(() => initializeNetwork(), []);
    useEffect(() => () => socketStream.value.forEach((element) => element.close()), []);
    useEffect(() => () => socketStream.close(), []);

    final control = useTextEditingController();

    return Scaffold(
      body: Center(
        child: StreamBuilder<List<Socket>>(
          initialData: [],
          stream: socketStream,
          builder: (BuildContext context, AsyncSnapshot<List<Socket>> snapshot) {
            if (!snapshot.hasData || snapshot.requireData.isEmpty) return Loader();

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(32),
                  child: TextField(
                    controller: control,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: "Playground",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color: Colors.amber,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Wrap(
                  children: [
                    Icon(Icons.check),
                    SizedBox(width: 8),
                    Text("Connected"),
                  ],
                ),
                SizedBox(height: 18),
                ...snapshot.requireData.map((e) => Text(e.address.address)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class Loader extends StatelessWidget {
  const Loader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.vertical,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 32),
        Text("Looking for connections"),
      ],
    );
  }
}
