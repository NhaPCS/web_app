import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_app/can_back_provider.dart';
import 'package:web_app/can_forward_provider.dart';
import 'package:web_app/link_provider.dart';
import 'package:web_app/loading_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web App',
      theme: ThemeData(primarySwatch: Colors.blue, primaryColor: Colors.blue),
      home: MyHomePage(title: 'Web App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _textEditingController = TextEditingController();
  LinkProvider _linkProvider = LinkProvider();
  LoadingProvider _loadingProvider = LoadingProvider();
  CanBackProvider _canBackProvider = CanBackProvider();
  CanForwardProvider _canForwardProvider = CanForwardProvider();
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _linkProvider.getLink();
//    Provider.of<LinkProvider>(context).getLink();

    Future.delayed(Duration(seconds: 1)).then((a) {
      if (_linkProvider.currentLink == null ||
          _linkProvider.currentLink.isEmpty) _showInputLinkDialog();
    });
  }

  @override
  Widget build(BuildContext context) {
    print("ww");
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LinkProvider>(
          create: (BuildContext context) {
            return _linkProvider;
          },
        ),
        ChangeNotifierProvider<LoadingProvider>(
          create: (BuildContext context) {
            return _loadingProvider;
          },
        ),
        ChangeNotifierProvider<CanBackProvider>(
          create: (BuildContext context) {
            return _canBackProvider;
          },
        ),
        ChangeNotifierProvider<CanForwardProvider>(
          create: (BuildContext context) {
            return _canForwardProvider;
          },
        )
      ],
      child: WillPopScope(
          child: Scaffold(
            body: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Container(
                  padding: MediaQuery.of(context).padding,
                  child: Consumer<LinkProvider>(
                    builder: (BuildContext context, LinkProvider linkProvider,
                        Widget child) {
                      print("AAA  ${linkProvider.currentLink}");
                      if (linkProvider.currentLink != null &&
                          linkProvider.currentLink.isNotEmpty) {
                        _textEditingController.text = linkProvider.currentLink;
                        return WebView(
                          initialUrl: linkProvider.currentLink,
                          javascriptMode: JavascriptMode.unrestricted,
                          onWebViewCreated:
                              (WebViewController webViewController) {
                            _controller.complete(webViewController);
                          },
                          onPageFinished: (string) async {
                            WebViewController webController =
                                await _controller.future;
                            _loadingProvider.updateLoading(false);
                            _canForwardProvider
                                .updateCan(await webController.canGoForward());
                            _canBackProvider
                                .updateCan(await webController.canGoBack());
                          },
                          onPageStarted: (string) async {
                            WebViewController webController =
                                await _controller.future;
                            _loadingProvider.updateLoading(true);
                            _canForwardProvider
                                .updateCan(await webController.canGoForward());
                            _canBackProvider
                                .updateCan(await webController.canGoBack());
                          },
                        );
                      } else {
                        return Center(
                          child: Text("Please set web's url on settings."),
                        );
                      }
                    },
                  ),
                ),
                Consumer<LoadingProvider>(
                  builder: (BuildContext context, LoadingProvider value,
                      Widget child) {
                    return value.loading
                        ? Container(
                            alignment: FractionalOffset.center,
                            child: CircularProgressIndicator(),
                          )
                        : Container(
                            width: 0,
                            height: 0,
                          );
                  },
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              mini: true,
              child: Icon(CupertinoIcons.settings_solid),
              onPressed: () {
                _showInputLinkDialog();
              },
            ),
          ),
          onWillPop: () async {
            WebViewController controller = await _controller.future;
            bool canGoBack = await controller.canGoBack();
            print("AAAAA $canGoBack");
            if (canGoBack) {
              controller.goBack();
              return false;
            } else
              return true;
          }),
    );
  }

  _showInputLinkDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return FutureBuilder<WebViewController>(
            builder: (BuildContext context,
                AsyncSnapshot<WebViewController> snapshot) {
              return AlertDialog(
                title: Text(
                  "Setup Web's url",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
                content: TextField(
                  controller: _textEditingController,
                  maxLines: 1,
                  decoration: InputDecoration(
                      hintText: "Enter web url...",
                      labelText: "Please enter your web url:"),
                ),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        if (_textEditingController.text.isEmpty) return;
                        bool _validURL =
                            Uri.parse(_textEditingController.text).isAbsolute;
                        if (!_validURL) return;
                        Navigator.pop(context);
                        _linkProvider.updateLink(_textEditingController.text);
                        snapshot.data.loadUrl(_textEditingController.text);
                      },
                      child: Text(
                        "OK",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold),
                      ))
                ],
              );
            },
          );
        });
  }
}
