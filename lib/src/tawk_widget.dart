import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'tawk_visitor.dart';

/// [Tawk] Widget.
class Tawk extends StatefulWidget {
  /// Tawk direct chat link.
  final String directChatLink;

  /// Object used to set the visitor name and email.
  final TawkVisitor? visitor;

  /// Called right after the widget is rendered.
  final Function? onLoad;

  /// Called when a link pressed.
  final Function(String)? onLinkTap;

  /// Render your own loading widget.
  final Widget? placeholder;

  const Tawk({
    Key? key,
    required this.directChatLink,
    this.visitor,
    this.onLoad,
    this.onLinkTap,
    this.placeholder,
  }) : super(key: key);

  @override
  _TawkState createState() => _TawkState();
}
class _TawkState extends State<Tawk> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url == 'about:blank' ||
                request.url.contains('tawk.to')) {
              return NavigationDecision.navigate;
            }

            if (widget.onLinkTap != null) {
              widget.onLinkTap!(request.url);
            }

            return NavigationDecision.prevent;
          },
          onPageFinished: (String url) {
            if (widget.visitor != null) {
              _setUser(widget.visitor!);
            }

            if (widget.onLoad != null) {
              widget.onLoad!();
            }

            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.directChatLink));
  }

  void _setUser(TawkVisitor visitor) {
    final json = jsonEncode(visitor);
    String javascriptString;

    if (Platform.isIOS) {
      javascriptString = '''
        Tawk_API = Tawk_API || {};
        Tawk_API.setAttributes($json);
      ''';
    } else {
      javascriptString = '''
        Tawk_API = Tawk_API || {};
        Tawk_API.onLoad = function() {
          Tawk_API.setAttributes($json);
        };
      ''';
    }

    _controller.runJavaScript(javascriptString);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          widget.placeholder ??
              const Center(
                child: CircularProgressIndicator(),
              ),
      ],
    );
  }
}


// class _TawkState extends State<Tawk> {
//   late WebViewController _controller;
//   bool _isLoading = true;
//
//   void _setUser(TawkVisitor visitor) {
//     final json = jsonEncode(visitor);
//     String javascriptString;
//
//     if (Platform.isIOS) {
//       javascriptString = '''
//         Tawk_API = Tawk_API || {};
//         Tawk_API.setAttributes($json);
//       ''';
//     } else {
//       javascriptString = '''
//         Tawk_API = Tawk_API || {};
//         Tawk_API.onLoad = function() {
//           Tawk_API.setAttributes($json);
//         };
//       ''';
//     }
//
//     _controller.runJavascript(javascriptString);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         WebView(
//           initialUrl: widget.directChatLink,
//           javascriptMode: JavascriptMode.unrestricted,
//           onWebViewCreated: (WebViewController webViewController) {
//             setState(() {
//               _controller = webViewController;
//             });
//           },
//           navigationDelegate: (NavigationRequest request) {
//             if (request.url == 'about:blank' ||
//                 request.url.contains('tawk.to')) {
//               return NavigationDecision.navigate;
//             }
//
//             if (widget.onLinkTap != null) {
//               widget.onLinkTap!(request.url);
//             }
//
//             return NavigationDecision.prevent;
//           },
//           onPageFinished: (_) {
//             if (widget.visitor != null) {
//               _setUser(widget.visitor!);
//             }
//
//             if (widget.onLoad != null) {
//               widget.onLoad!();
//             }
//
//             setState(() {
//               _isLoading = false;
//             });
//           },
//         ),
//         _isLoading
//             ? widget.placeholder ??
//                 const Center(
//                   child: CircularProgressIndicator(),
//                 )
//             : Container(),
//       ],
//     );
//   }
// }
