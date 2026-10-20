// Package imports:
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// Project imports:
// import '../components/webview_back_button.dart';
import '../imports.dart';

class WebviewPage extends StatefulWidget {
  final String? title;
  final String url;

  /// e.g. kTopUpReturnPath: where a payment gateway sends the player back.
  /// Once the page heads there, it closes with that address's `status`
  /// (paid / pending / failed) instead of loading it.
  final String? returnPath;

  const WebviewPage({
    super.key,
    required this.url,
    this.title,
    this.returnPath,
  });

  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;

  String url = "";
  double progress = 0;
  String? consoleMessageResult;

  /// Closed for [WebviewPage.returnPath] already (it can be seen more than
  /// once: the navigation, then its load).
  bool _isReturned = false;

  /// Whether [url] is [WebviewPage.returnPath]; if so, closes with its
  /// `status`.
  /// A payment gateway's page (it has a return path): Apple Pay on. That
  /// blocks any script the app puts in the page (no long-press script, no
  /// close0 / close1 console messages); the return path is caught natively,
  /// so it still works.
  bool get _isPayment => widget.returnPath != null;

  /// A payment page on Android: Google Pay is turned on natively (see
  /// MainActivity) before the page loads, so it's loaded once created.
  bool get _isAndroidPayment => _isPayment && !kIsWeb && Platform.isAndroid;

  static const MethodChannel _channel = MethodChannel(
    'com.asia.getithk/webview',
  );

  URLRequest get _request => URLRequest(url: WebUri(ensureHttps(widget.url)));

  Future<void> _loadAndroidPayment(InAppWebViewController controller) async {
    try {
      await _channel.invokeMethod('enablePaymentRequest', {
        'viewId': controller.getViewId(),
      });
    } catch (e) {
      // the page still loads, just without Google Pay
      printLog("enablePaymentRequest $e");
    }
    await controller.loadUrl(urlRequest: _request);
  }

  bool _checkReturn(Uri? url) {
    final String? path = widget.returnPath;
    if (path == null || url == null || !url.path.endsWith(path)) return false;

    if (!_isReturned && mounted) {
      _isReturned = true;
      AppNavigator.pop(context, url.queryParameters['status']);
    }
    return true;
  }

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      onRefresh: () async {
        if (webViewController != null) {
          await webViewController!.reload(); // Reload the page
          await Future.delayed(100.milliseconds); // Delay for stability
          await webViewController!.scrollTo(x: 0, y: 0); // Scroll to top
        }
        pullToRefreshController?.endRefreshing(); // Stop refresh animation
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: consoleMessageResult == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && consoleMessageResult != null) {
          AppNavigator.pop(context, consoleMessageResult);
        }
      },
      child: Scaffold(
        appBar: AppBarWidget(
          text: widget.title,
          leading: AppBarBackButton(
            onTap: () => AppNavigator.pop(context, consoleMessageResult),
          ),
        ),
        body: Stack(
          children: [
            // webview
            Consumer<AppController>(
              builder: (BuildContext context, _appController, _) {
                return InAppWebView(
                  pullToRefreshController: pullToRefreshController,
                  initialSettings: InAppWebViewSettings(
                    cacheEnabled: false, // Disables caching
                    // a payment page gets the browser's own user agent
                    // (""), not one naming no browser, and a normal (not
                    // private) store: the gateway's wallet check (Apple
                    // Pay) then sees Safari, as it would outside the app
                    userAgent: _isPayment ? "" : "is_mobile_webview",
                    allowsBackForwardNavigationGestures: false,
                    incognito: !_isPayment,
                    // else shouldOverrideUrlLoading is never called
                    useShouldOverrideUrlLoading: true,
                    // off by default in a web view; iOS only
                    applePayAPIEnabled: _isPayment,
                  ),
                  initialUrlRequest: _isAndroidPayment ? null : _request,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                    printLog("onWebViewCreated $url");
                    if (_isAndroidPayment) _loadAndroidPayment(controller);
                  },
                  onLoadStart: (controller, url) {
                    if (!mounted) return;
                    // a server redirect there can skip
                    // shouldOverrideUrlLoading
                    if (_checkReturn(url)) return;
                    setState(() {
                      this.url = url.toString();
                      printLog("onLoadStart $url");
                    });
                  },
                  // a script changing the address there (no page load)
                  onUpdateVisitedHistory: (controller, url, isReload) =>
                      _checkReturn(url),
                  onLoadStop: (controller, url) async {
                    if (!mounted) return;

                    // disable long press
                    // not with Apple Pay on, which blocks injected scripts
                    if (!_isPayment) _disableLongPressScript();
                  },
                  onProgressChanged: (controller, progress) {
                    if (!mounted) return;

                    setState(() {
                      this.progress = progress / 100;
                    });
                  },

                  // on download
                  onDownloadStartRequest: (controller, downloadStartRequest) async {
                    printLog(
                      "downloadStartRequest : ${downloadStartRequest.mimeType}",
                    );

                    // Optionally show your own progress or confirmation UI
                    setState(() {
                      progress = 1.0; // Manually set to full
                    });

                    // You can launch the download URL externally
                    if (await canLaunchUrl(
                      Uri.parse(downloadStartRequest.url.toString()),
                    )) {
                      await launchUrl(
                        Uri.parse(downloadStartRequest.url.toString()),
                      );
                    }
                  },

                  onConsoleMessage: (controller, consoleMessage) {
                    printLog(
                      "consoleMessage : $consoleMessage",
                      name: "consoleMessage",
                    );
                    final message = consoleMessage.message;
                    if (message == "close0" || message == "close1") {
                      consoleMessageResult = message;
                      AppNavigator.pop(context, message);
                    }
                  },

                  // check url is valid or invalid
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                        // the gateway sending the player back: close with
                        // its status, don't load it
                        if (_checkReturn(navigationAction.request.url)) {
                          return NavigationActionPolicy.CANCEL;
                        }

                        final url =
                            navigationAction.request.url?.toString() ?? "";

                        if (url.contains("slogout")) {
                          printLog(
                            "Detected slogout! Performing logout actions...",
                          );
                          _appController.logout();
                          await 0.01.delay();
                          setState(() {});
                          return NavigationActionPolicy.CANCEL;
                        }

                        return NavigationActionPolicy
                            .ALLOW; // Allow other URLs to load normally
                      },
                );
              },
            ),

            // linear progress
            Positioned(
              child: progress < 1.0
                  ? PreferredSize(
                      preferredSize: const Size(double.infinity, 3.0),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        color: context.color.primary,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // back button
            // WebviewBackButton(webViewController: webViewController),
          ],
        ),
      ),
    );
  }

  void _disableLongPressScript() async {
    const String disableLongPressScript = """
  document.body.style.webkitTouchCallout='none';
  document.body.style.webkitUserSelect='none';
  document.body.style.khtmlUserSelect='none';
  document.body.style.mozUserSelect='none';
  document.body.style.msUserSelect='none';
  document.body.style.userSelect='none';

  document.body.addEventListener('contextmenu', event => event.preventDefault());
""";

    await webViewController?.evaluateJavascript(source: disableLongPressScript);
  }
}
