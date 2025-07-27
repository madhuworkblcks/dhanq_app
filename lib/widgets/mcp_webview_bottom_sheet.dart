import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MCPWebViewBottomSheet extends StatefulWidget {
  final String url;
  final VoidCallback? onClose;

  const MCPWebViewBottomSheet({
    Key? key, 
    required this.url,
    this.onClose,
  }) : super(key: key);

  @override
  State<MCPWebViewBottomSheet> createState() => _MCPWebViewBottomSheetState();
}

class _MCPWebViewBottomSheetState extends State<MCPWebViewBottomSheet> {
  WebViewController? controller;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

    Future<void> _initializeWebView() async {
    try {
      final webViewController = WebViewController();
      
      // Set JavaScript mode
      await webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
      
      // Configure WebView settings for better scrolling
      await webViewController.setBackgroundColor(Colors.white);
      
      // Enable scrolling and other important settings
      await webViewController.enableZoom(false);
      
      // Set navigation delegate
      await webViewController.setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView loading progress: $progress%');
          },
          onPageStarted: (String url) {
            debugPrint('WebView page started: $url');
            if (mounted) {
              setState(() {
                isLoading = true;
                hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            debugPrint('WebView page finished: $url');
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
            if (mounted) {
              setState(() {
                isLoading = false;
                hasError = true;
                errorMessage = 'Failed to load page: ${error.description}';
              });
            }
          },
        ),
      );
      
      // Load the URL
      debugPrint('Loading WebView URL: ${widget.url}');
      await webViewController.loadRequest(Uri.parse(widget.url));
      
      if (mounted) {
        setState(() {
          controller = webViewController;
        });
        debugPrint('WebView controller set successfully');
      }
    } catch (e) {
      debugPrint('WebView initialization error: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'Failed to initialize WebView: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9, // Increased height
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header with close button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1E3A8A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // Drag handle (visual only since drag is disabled)
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'MCP WebView',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onClose?.call();
                  },
                ),
              ],
            ),
          ),
          // WebView content
          Expanded(
            child: Stack(
              children: [
                if (controller != null && !hasError)
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: WebViewWidget(controller: controller!),
                  ),
                if (isLoading) const Center(child: CircularProgressIndicator()),
                if (hasError)
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load WebView',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                              hasError = false;
                              errorMessage = '';
                            });
                            _initializeWebView();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
