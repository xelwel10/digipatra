import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:simple_app/core/config.dart';
import 'package:simple_app/core/loading_indicator.dart';
import 'package:simple_app/core/update_manager.dart';

String firstUrl = "   ";

class HomePageView extends StatefulWidget {
  final String? tempUrl;
  final String? token;
  final int? selectedIndex;
  const HomePageView({
    super.key,
    this.tempUrl,
    this.selectedIndex,
    this.token,
  });

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  bool _isConnected = true;
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  String tempUrl = "https://digitalbadapatra.com";

  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone",
    builtInZoomControls: false,
    displayZoomControls: false,
    useWideViewPort: false,
    iframeAllowFullscreen: true,
    supportZoom: false,
    javaScriptEnabled: true,
    cacheMode: CacheMode.LOAD_NO_CACHE,
  );
  PullToRefreshController? pullToRefreshController;

  String initUrl = "https://digitalbadapatra.com";
  String url = "https://digitalbadapatra.com";
  String? token;
  bool isLoading = false;
  double progress = 0;
  final urlController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int keyPressCount = 0;
  Timer? singlePressTimer;

  @override
  void initState() {
    super.initState();
    checkConnectivity();
    _focusNode.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final updateAvailable = await checkAppUpdates();
      if (updateAvailable && mounted) {
        showAppUpdateDialog(context);
      }
    });
  }

  Future<void> logError(dynamic e, StackTrace stack) async {
    FirebaseCrashlytics.instance.recordError(e, stack);
  }

  Future<void> checkConnectivity() async {
    try {
      Connectivity().onConnectivityChanged.listen((result) {
        setState(() {
          _isConnected = result.first != ConnectivityResult.none;
          Config.hasInternet(_isConnected);
        });
      });
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
    }
  }

  @override
  void dispose() {
    InAppWebViewController.clearAllCache();
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            _isConnected
                ? KeyboardListener(
                    focusNode: _focusNode,
                    autofocus: true,
                    onKeyEvent: (event) {
                      try {
                        if (event is KeyDownEvent) {
                          String key = event.logicalKey.keyLabel;
                          if (RegExp(r'^Numpad [0-9]$').hasMatch(key)) {
                            webViewController?.evaluateJavascript(source: '''
                            var inputField = document.getElementById("select-charter");
                            inputField.click();
                            inputField.value += "$key".replace("Numpad ", "");
                            inputField.focus();
                            var event = new Event('input', {
                                bubbles: true,
                                cancelable: true
                            });
                            inputField.dispatchEvent(event);
                        ''');
                          } else if (key == 'Numpad Multiply') {
                            keyPressCount++;
                            if (keyPressCount == 1) {
                              singlePressTimer =
                                  Timer(Duration(milliseconds: 200), () {
                                webViewController
                                    ?.evaluateJavascript(source: '''
                                      var closeButton = document.querySelector('.btn-close');
                                      var modalElement = document.getElementById('broadCastModal');

                                      if (closeButton) {
                                          closeButton.click();
                                      }
                                      if (modalElement && modalElement.classList.contains('show')) {
                                          var modal = bootstrap.Modal.getInstance(modalElement); 
                                          modal.hide();
                                      }
                                      var inputField = document.getElementById("select-charter");
                                      if (inputField) {
                                          inputField.value = '';
                                          inputField.focus();
                                      }
                                  ''');
                                keyPressCount = 0;
                              });
                            } else if (keyPressCount == 2) {
                              if (singlePressTimer != null) {
                                singlePressTimer!.cancel();
                              }
                              webViewController?.evaluateJavascript(source: '''
                                var xhr = new XMLHttpRequest();
                                xhr.open('GET', 'https://digitalbadapatra.com/badapatra/notices', true);
                                xhr.onload = function() {
                                    if (xhr.status === 200) {
                                        var response = JSON.parse(xhr.responseText);
                                        if (response.success) {
                                            document.getElementById('broadCastModalContent').innerHTML = response.template;
                                            var modal = new bootstrap.Modal(document.getElementById('broadCastModal'));
                                            modal.show();
                                        }
                                    } else {
                                        console.log('Failed to fetch notices');
                                    }
                                };
                                xhr.onerror = function() {
                                    console.log('Request error...');
                                };
                                xhr.send();
                            ''');
                              keyPressCount = 0;
                            }
                          }
                        }
                      } catch (e, stack) {
                        logError(e, stack);
                      }
                    },
                    child: Column(
                      children: [
                        // ElevatedButton(
                        //   onPressed: () {
                        //     debugPrint(
                        //         "Test error report -----------------------");
                        //     FirebaseCrashlytics.instance
                        //         .log("WebView failed to load: test");

                        //     FirebaseCrashlytics.instance.recordError(
                        //         Exception("Test error message"),
                        //         StackTrace.empty,
                        //         reason: "Test crash report");
                        //     // FirebaseCrashlytics.instance.crash();
                        //   },
                        //   child: Text('Send Test Crash'),
                        // ),
                        Expanded(
                          child: InAppWebView(
                            key: webViewKey,
                            initialUrlRequest: URLRequest(url: WebUri(url)),
                            initialSettings: settings,
                            pullToRefreshController: pullToRefreshController,
                            onWebViewCreated: (controller) {
                              webViewController = controller;
                              webViewController?.setSettings(
                                  settings: settings);
                            },
                            onReceivedError:
                                (controller, request, error) async {
                              try {
                                FirebaseCrashlytics.instance.log(
                                    "WebView failed to load: ${error.description}");
                                FirebaseCrashlytics.instance
                                    .recordError(error, StackTrace.current);
                              } catch (e, stack) {
                                logError(e, stack);
                              }
                            },
                            onLoadStart: (controller, url) async {
                              if (mounted) {
                                setState(() {
                                  this.url = url.toString();
                                });
                              }
                              if (mounted) {
                                setState(() {
                                  isLoading = true;
                                });
                              }
                            },
                            onCreateWindow:
                                (controller, createWindowRequest) async {
                              if (createWindowRequest.request.url != null) {
                                return false;
                              }
                              return true;
                            },
                            onPermissionRequest: (controller, request) async {
                              return PermissionResponse(
                                resources: request.resources,
                                action: PermissionResponseAction.GRANT,
                              );
                            },
                            onLoadStop: (controller, initUrl) async {
                              try {
                                if (mounted) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                                pullToRefreshController?.endRefreshing();
                                if (mounted) {
                                  setState(() {
                                    url = initUrl.toString();
                                    urlController.text = this.initUrl;
                                  });
                                }
                                if (webViewController != null) {
                                  await webViewController?.setSettings(
                                      settings: settings);
                                }

                                await webViewController
                                    ?.evaluateJavascript(source: '''
                                    window.onerror = function(message, source, lineno, colno, error) {
                                      console.log("WebView Error: " + message);
                                    };
                                  ''');

                                await webViewController
                                    ?.evaluateJavascript(source: '''
                                    var inputField = document.getElementById("select-charter");
                                    inputField.click();
                                    
                                    if (inputField) {
                                        inputField.addEventListener("focus", function() {
                                        inputField.setAttribute("readonly", "readonly");
                                        });
                                        inputField.click();
                                    }
                                    var meta = document.createElement('meta');
                                    meta.name = 'viewport';
                                    meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                                    document.getElementsByTagName('head')[0].appendChild(meta);
                                ''');
                              } catch (e, stack) {
                                FirebaseCrashlytics.instance
                                    .recordError(e, stack);
                              }
                            },
                            onUpdateVisitedHistory:
                                (controller, initUrl, androidIsReload) async {
                              if (mounted) {
                                setState(() {
                                  url = initUrl.toString();
                                  urlController.text = this.initUrl;
                                });
                              }
                            },
                            shouldOverrideUrlLoading:
                                (controller, navigationAction) async {
                              try {
                                var uri = navigationAction.request.url!;

                                if (uri.scheme == 'mailto' ||
                                    uri.toString() == 'about:home') {
                                  return NavigationActionPolicy.CANCEL;
                                }

                                if (![
                                  "http",
                                  "https",
                                  "file",
                                  "chrome",
                                  "data",
                                  "javascript",
                                  "about"
                                ].contains(uri.scheme)) {
                                  return NavigationActionPolicy.CANCEL;
                                }

                                if (uri.toString() !=
                                    'https://digitalbadapatra.com') {
                                  await webViewController?.loadUrl(
                                    urlRequest: URLRequest(
                                        url: WebUri(
                                            'https://digitalbadapatra.com')),
                                  );
                                  return NavigationActionPolicy.CANCEL;
                                }

                                return NavigationActionPolicy.ALLOW;
                              } catch (e, stack) {
                                FirebaseCrashlytics.instance
                                    .recordError(e, stack);
                                return NavigationActionPolicy.CANCEL;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off,
                            color: Colors.redAccent,
                            size: 100,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'No Internet Connection',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Please check your internet settings and try again.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
            if (isLoading)
              Container(
                color: Colors.white.withOpacity(1),
                child: const Center(
                  child: CustomLoadingIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
