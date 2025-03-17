import 'dart:async';
import 'package:flutter/material.dart';

typedef CloseLoadingScreen = bool Function();
typedef UpdateLoadingScreen = bool Function(String text);

@immutable
class LoadingScreenController {
  final CloseLoadingScreen close; // to closs our dialog
  final UpdateLoadingScreen
      update; // to update anytext with in our dialog if needed

  const LoadingScreenController({
    required this.close,
    required this.update,
  });
}

LoadingScreenController? showOverlay({
  required BuildContext context,
  required String text,
}) {
  final textController = StreamController<
      String>(); // this is our streamController that return String value
  textController.add(text); // first we add the text to show with our loading
  final state = Overlay.of(
      context); // create our overlay instance to INSERT our overlay later
  final renderBox =
      context.findRenderObject() as RenderBox; // get our RenderBox size
  final size = renderBox.size;

  // Then create our overlay
  final overlay = OverlayEntry(
    builder: (context) {
      return Material(
        color: Colors.black.withAlpha(150),
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: size.width * .8,
              maxHeight: size.width * .8,
              minWidth: size.width * .5,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  StreamBuilder(
                    // this StreamBuilder widget is to immediately update our text whenever we add a new value (update : ) our textController
                    stream: textController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.requireData,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.black),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  state.insert(
      overlay); // !! This is the most important step in displaying our overlay: using the insert function.
  return LoadingScreenController(
    close: () {
      // this is what happen when we call close inside our LoadingScreenController
      textController.close(); // close our textController
      overlay.remove(); // remove our overlay
      return true;
    },
    update: (String text) {
      // this is what happen when we call update inside our LoadingScreenController
      textController.add(text); // update new value to our textController
      return true;
    },
  ); // then we return our LoadingScreenController
}

class LoadingScreen {
  LoadingScreen._shareInstance();
  static final LoadingScreen _shared = LoadingScreen._shareInstance();
  factory LoadingScreen.instance() => _shared;

  LoadingScreenController? _controller;

  void show({
    required BuildContext context,
    String text = "Loading",
  }) {
    if (_controller?.update(text) ?? false) {
      return;
    } else {
      _controller = showOverlay(context: context, text: text);
    }
  }

  void hide() {
    _controller?.close();
    _controller = null;
  }

  LoadingScreenController? showOverlay({
    required BuildContext context,
    required String text,
  }) {
    final textController = StreamController<String>();
    textController.add(text);
    final state = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final overlay = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.black.withAlpha(150),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: size.width * .8,
                maxHeight: size.width * .8,
                minWidth: size.width * .5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 10),
                    StreamBuilder(
                      stream: textController.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            snapshot.requireData,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.black),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    state.insert(overlay);

    return LoadingScreenController(
      close: () {
        textController.close();
        overlay.remove();
        return true;
      },
      update: (String text) {
        textController.add(text);
        return true;
      },
    );
  }
}
