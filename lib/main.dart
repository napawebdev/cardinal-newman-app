import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// Conditional imports for web-specific functionality
import 'dart:html' as html show IFrameElement;
import 'dart:ui_web' as ui_web show platformViewRegistry;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cardinal John Henry Newman App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'NAPA.dev'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  WebViewController? _webViewController;
  bool _isLoading = true;
  String _errorMessage = '';
  static const String iframeViewType = 'cardinal-newman-iframe';

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _registerIframe();
      setState(() {
        _isLoading = false;
      });
    } else {
      _initializeWebView();
    }
  }

  void _registerIframe() {
    // Register the iframe view factory for web
    ui_web.platformViewRegistry.registerViewFactory(
      iframeViewType,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = 'https://cardinaljohnhenrynewman.com'
          ..style.border = 'none'
          ..style.height = '100%'
          ..style.width = '100%'
          ..allowFullscreen = true;
        
        // Add error handling
        iframe.onError.listen((event) {
          print('Iframe loading error: $event');
          setState(() {
            _errorMessage = 'Failed to load website in iframe. Website may not allow embedding.';
            _isLoading = false;
          });
        });
        
        iframe.onLoad.listen((event) {
          setState(() {
            _isLoading = false;
          });
        });
        
        return iframe;
      },
    );
  }

  void _initializeWebView() {
    try {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              if (progress == 100) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onPageStarted: (String url) {
              setState(() {
                _isLoading = true;
                _errorMessage = '';
              });
            },
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false;
              });
            },
            onWebResourceError: (WebResourceError error) {
              setState(() {
                _isLoading = false;
                _errorMessage = 'Error loading website: ${error.description}';
              });
            },
          ),
        )
        ..loadRequest(Uri.parse('https://cardinaljohnhenrynewman.com'));
    } catch (e) {
      setState(() {
        _errorMessage = 'WebView not supported on this platform';
        _isLoading = false;
      });
    }
  }

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://cardinaljohnhenrynewman.com');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      setState(() {
        _errorMessage = 'Could not launch $url';
      });
    }
  }

  Widget _buildHomeTab() {
    // For web platform, show the iframe or fallback
    if (kIsWeb) {
      if (_errorMessage.isNotEmpty) {
        // Show fallback UI if iframe fails
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.web_asset_off,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _launchURL,
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Open in New Tab'),
              ),
              const SizedBox(height: 24),
              const Text(
                'The website blocks embedding in iframes.\nClick above to visit the official website.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        );
      }
      
      return Stack(
        children: [
          const HtmlElementView(viewType: iframeViewType),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading Cardinal Newman website...'),
                ],
              ),
            ),
        ],
      );
    }

    // For mobile platforms, use WebView
    if (_errorMessage.isNotEmpty) {
      return Center(
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
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _errorMessage = '';
                    });
                    _initializeWebView();
                  },
                  child: const Text('Retry'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _launchURL,
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Open in Browser'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        if (_webViewController != null)
          WebViewWidget(controller: _webViewController!),
        if (_isLoading)
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading Cardinal John Henry Newman website...'),
              ],
            ),
          ),
      ],
    );
  }


  Widget _buildSearchTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Search functionality coming soon!'),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Favorites functionality coming soon!'),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Profile functionality coming soon!'),
        ],
      ),
    );
  }

  Widget _getCurrentTab() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildSearchTab();
      case 2:
        return _buildFavoritesTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildMenuButton(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected 
                  ? Theme.of(context).colorScheme.primary 
                  : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              onPressed: _launchURL,
              icon: const Icon(Icons.open_in_browser),
              tooltip: 'Open in Browser',
            ),
        ],
      ),
      body: _getCurrentTab(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMenuButton(Icons.home, 'Home', 0),
                _buildMenuButton(Icons.search, 'Search', 1),
                _buildMenuButton(Icons.favorite, 'Favorites', 2),
                _buildMenuButton(Icons.person, 'Profile', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}