import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_app/link_provider.dart';
import 'package:web_app/loading_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LIWITECH',
      theme: ThemeData(primarySwatch: Colors.blue, primaryColor: Colors.blue),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SplashState();
  }
}

class _SplashState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3)).then((a) {
      Navigator.of(context).pop();
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => SettingLinkScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/splash.jpg',
          width: MediaQuery.of(context).size.width * 0.5,
        ),
      ),
    );
  }
}

class SettingLinkScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsState();
  }
}

class _SettingsState extends State<SettingLinkScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final LinkProvider _linkProvider = LinkProvider();

  @override
  void initState() {
    super.initState();
    check();
  }

  Future<void> check() async {
    String link = await _linkProvider.getLink();
    if (link != null) {
      _textEditingController.text = link;
      goWeb();
    }
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white70,
        body: Center(
          child: Card(
            elevation: 20,
            color: Colors.white,
            margin: EdgeInsets.all(20),
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Wrap(
                spacing: 20,
                children: <Widget>[
                  Text(
                    "Setup Web's url",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: _textEditingController,
                    maxLines: 1,
                    decoration: InputDecoration(
                        hintText: "Enter web url...",
                        suffixIcon: IconButton(
                            icon: Icon(Icons.cancel),
                            onPressed: () {
                              _textEditingController.clear();
                            })),
                  ),
                  ButtonTheme(
                    minWidth: double.infinity,
                    child: RaisedButton(
                        color: Theme.of(context).primaryColor,
                        onPressed: () async {
                          goWeb();
                        },
                        child: Text(
                          "OK",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }

  Future<void> goWeb() async {
    bool _validURL = _textEditingController != null &&
        _textEditingController.text.isNotEmpty &&
        Uri.parse(_textEditingController.text).isAbsolute;
    if (!_validURL) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('link', _textEditingController.text);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => MyHomePage(
                  link: _textEditingController.text,
                ),
            fullscreenDialog: true));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.link}) : super(key: key);

  final String title;
  final String link;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  WebViewController _webViewController;
  final LoadingProvider _loadingProvider = LoadingProvider();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
//    Provider.of<LinkProvider>(context).getLink();
  }

  @override
  Widget build(BuildContext context) {
    print("ww");
    return ChangeNotifierProvider(
      create: (_) => _loadingProvider,
      child: Scaffold(
        appBar: PreferredSize(
          child: Container(),
          preferredSize: Size.fromHeight(0.0),
        ),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            WebView(
              initialUrl: widget.link,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onPageStarted: (a) {
                _loadingProvider.updateLoading(true);
              },
              onPageFinished: (a) {
                _loadingProvider.updateLoading(false);
              },
            ),
            Consumer<LoadingProvider>(
              builder:
                  (BuildContext context, LoadingProvider value, Widget child) {
                return value.loading
                    ? LinearProgressIndicator()
                    : SizedBox(
                        height: 0,
                      );
              },
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          mini: true,
          child: Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
          onPressed: () async {
            print("popop");
            bool canGoBack = _webViewController == null
                ? false
                : await _webViewController.canGoBack();
            print("AAAAA $canGoBack");
            if (canGoBack) {
              _webViewController.goBack();
              return false;
            } else
              return true;
          },
        ),
      ),
    );
  }
}
