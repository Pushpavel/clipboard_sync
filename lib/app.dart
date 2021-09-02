import 'dart:io';

import 'package:clipboard_sync/logic/network/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class App extends HookWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketStream = useMemoized(() => initializeNetwork(), []);
    useEffect(() => () => socketStream.close(), []);

    return Scaffold(
      body: Center(
        child: StreamBuilder<List<Socket>>(
          initialData: [],
          stream: socketStream,
          builder: (BuildContext context, AsyncSnapshot<List<Socket>> snapshot) {
            if (!snapshot.hasData || snapshot.requireData.isEmpty) return Loader();

            return Wrap(
              children: [
                Icon(Icons.check),
                SizedBox(width: 8),
                Text("Connected"),
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
