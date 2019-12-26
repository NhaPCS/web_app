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
      title: 'DC Monitoring',
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
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => MyHomePage(
                link:
                    "http://dc-mon.tcmotor.vn:3000/d/iE4OsafWk/dc-monitoring-copy?orgId=1&refresh=5s&from=1577305401420&to=1577327001420",
              )));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/splash.jpg',
        ),
      ),
    );
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
