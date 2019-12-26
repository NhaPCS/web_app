import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_app/link_provider.dart';
import 'package:web_app/loading_provider.dart';

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
  final flutterWebViewPlugin = FlutterWebviewPlugin();
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
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  final LoadingProvider _loadingProvider = LoadingProvider();

  @override
  void initState() {
    super.initState();
    flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      if (state.type == WebViewState.startLoad)
        _loadingProvider.updateLoading(true);
      else if (state.type == WebViewState.finishLoad ||
          state.type == WebViewState.abortLoad)
        _loadingProvider.updateLoading(false);
    });
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
      child: WillPopScope(
          child: WebviewScaffold(
            appBar: PreferredSize(
              child: Container(),
              preferredSize: Size.fromHeight(0.0),
            ),
            url: widget.link,
            withLocalStorage: true,
            hidden: true,
            withZoom: true,
            withJavascript: true,
            bottomNavigationBar: Consumer<LoadingProvider>(
              builder:
                  (BuildContext context, LoadingProvider value, Widget child) {
                return value.loading
                    ? LinearProgressIndicator()
                    : SizedBox(
                        height: 0,
                      );
              },
            ),
          ),
          onWillPop: () async {
            print("popop");
            bool canGoBack = await flutterWebViewPlugin.canGoBack();
            print("AAAAA $canGoBack");
            if (canGoBack) {
              flutterWebViewPlugin.goBack();
              return false;
            } else
              return true;
          }),
    );
  }
}
