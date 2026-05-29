import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDfNgqR9UtKUvd2Prf2YPBFu33DJ_ubytk", 
        appId: "1:747833174910:web:eefcbf01901ecb58b8a12f", 
        messagingSenderId: "747833174910", 
        projectId: "anime-website-42907", 
      ),
    );
    runApp(const AwiToApp());
  } catch (e) {
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(backgroundColor: Colors.black, body: Center(child: Text("🔥 ERROR:\n\n$e", style: const TextStyle(color: Colors.red)))),
    ));
  }
}

class AwiToApp extends StatelessWidget {
  const AwiToApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AWI.TO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D14), 
        primaryColor: const Color(0xFFF47521), 
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0D0D14), elevation: 0),
      ),
      home: const HomeScreen(),
    );
  }
}

// ==========================================
// 🏠 HOME SCREEN
// ==========================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AWI.TO', style: TextStyle(color: Color(0xFFF47521), fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 24)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search Anime...",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFF47521)),
                filled: true,
                fillColor: const Color(0xFF1E1E2A),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('anime').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFFF47521)));
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Koi Anime nahi mila 😅"));

                final animes = snapshot.data!.docs.where((doc) {
                  return ((doc.data() as Map<String, dynamic>)['name'] ?? '').toString().toLowerCase().contains(searchQuery);
                }).toList();

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 16, mainAxisSpacing: 16),
                  itemCount: animes.length,
                  itemBuilder: (context, index) {
                    var animeData = animes[index].data() as Map<String, dynamic>;
                    String title = animeData['name'] ?? 'Unknown Anime';
                    String animeId = animes[index].id;
                    String posterUrl = animeData['poster'] ?? 'https://via.placeholder.com/300x400.png?text=No+Image';

                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AnimeDetailsScreen(animeId: animeId, title: title, posterUrl: posterUrl))),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(posterUrl, fit: BoxFit.cover),
                            Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withOpacity(0.9)], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
                            Positioned(
                              bottom: 10, left: 10, right: 10,
                              child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 🎬 ANIME DETAILS SCREEN (With Server Selection)
// ==========================================
class AnimeDetailsScreen extends StatelessWidget {
  final String animeId;
  final String title;
  final String posterUrl;

  const AnimeDetailsScreen({super.key, required this.animeId, required this.title, required this.posterUrl});

  // 🔥 Server Choose Karne ka Hacker Pop-up
  void _showServerSelection(BuildContext context, String title, String server1, String server2) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Choose Server", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              if (server1.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.flash_on, color: Color(0xFFF47521)),
                  title: const Text("Server 1 (Native Fast MP4)", style: TextStyle(fontWeight: FontWeight.bold)),
                  tileColor: Colors.black26,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(videoUrl: server1, title: title)));
                  },
                ),
              const SizedBox(height: 10),
              if (server2.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.web, color: Colors.blueAccent),
                  title: const Text("Server 2 (Backup Web Player)", style: TextStyle(fontWeight: FontWeight.bold)),
                  tileColor: Colors.black26,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(videoUrl: server2, title: title)));
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          SizedBox(height: 220, width: double.infinity, child: Image.network(posterUrl, fit: BoxFit.cover, alignment: Alignment.topCenter)),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(alignment: Alignment.centerLeft, child: Text("Episodes", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFF47521)))),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('episodes').where('animeId', isEqualTo: animeId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFFF47521)));
                var rawEpisodes = snapshot.data?.docs ?? [];
                if (rawEpisodes.isEmpty) return const Center(child: Text("Abhi episodes upload nahi hue hain.", style: TextStyle(color: Colors.white54)));

                rawEpisodes.sort((a, b) => ((a.data() as Map<String, dynamic>)['num'] ?? 0).compareTo((b.data() as Map<String, dynamic>)['num'] ?? 0));

                return ListView.builder(
                  itemCount: rawEpisodes.length,
                  itemBuilder: (context, index) {
                    var epData = rawEpisodes[index].data() as Map<String, dynamic>;
                    int epNum = epData['num'] ?? (index + 1);
                    String epTitle = epData['title'] ?? 'S1 E$epNum - Episode $epNum';
                    
                    // 🔥 Dual Link Logic (12 episodes ke liye bhi aur future ke liye bhi)
                    String server1Mp4 = "";
                    String server2Web = "";

                    if (epData['links'] != null && epData['links']['1080p'] != null) {
                      var links = epData['links']['1080p'];
                      // Purana format ('player' naam se save hai) usko Server 2 maan rahe hain
                      if (links['player'] != null) server2Web = links['player'];
                      
                      // Naya format jo tum aage upload karoge ('server1' aur 'server2' naam se)
                      if (links['server1'] != null) server1Mp4 = links['server1'];
                      if (links['server2'] != null) server2Web = links['server2'];
                    }

                    return Card(
                      color: const Color(0xFF1E1E2A),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(width: 60, height: 40, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6))),
                            const Icon(Icons.play_circle_fill, color: Color(0xFFF47521), size: 30),
                          ],
                        ),
                        title: Text(epTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text("Sub | Dub", style: TextStyle(color: Colors.white54, fontSize: 12)),
                        trailing: const Icon(Icons.more_vert, size: 20, color: Colors.white54),
                        onTap: () {
                          if (server1Mp4.isEmpty && server2Web.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link nahi mila bhai!")));
                          } else if (server1Mp4.isNotEmpty && server2Web.isNotEmpty) {
                            // Dono link hain toh Pop-up dikhao
                            _showServerSelection(context, epTitle, server1Mp4, server2Web);
                          } else {
                            // Sirf ek link hai (jaise purane 12 episodes), toh direct chalao!
                            String finalLink = server1Mp4.isNotEmpty ? server1Mp4 : server2Web;
                            Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(videoUrl: finalLink, title: epTitle)));
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 🛡️ DUAL VIDEO PLAYER (Native + WebView)
// ==========================================
class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  const VideoPlayerScreen({super.key, required this.videoUrl, required this.title});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final WebViewController _webController;
  bool _isWebLoading = true;

  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isNativePlayer = false;

  @override
  void initState() {
    super.initState();
    // Auto-detect: Bysekoze link hai toh Web, warna Native Player
    if (!widget.videoUrl.contains("bysesukior.com") && !widget.videoUrl.contains("byse.sx") && !widget.videoUrl.contains("rareanimes")) {
      _isNativePlayer = true;
      _initNativePlayer();
    } else {
      _initWebViewPlayer();
    }
  }

  void _initNativePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _videoPlayerController!.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFFF47521), 
        handleColor: const Color(0xFFF47521),
        backgroundColor: Colors.grey,
        bufferedColor: Colors.white54,
      ),
      placeholder: const Center(child: CircularProgressIndicator(color: Color(0xFFF47521))),
      errorBuilder: (context, errorMessage) {
        return Center(child: Text("Player Error: $errorMessage", style: const TextStyle(color: Colors.white)));
      },
    );
    setState(() {});
  }

  void _initWebViewPlayer() {
    String videoHost = Uri.parse(widget.videoUrl).host;
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) { if (mounted) setState(() { _isWebLoading = true; }); },
          onPageFinished: (String url) {
            if (mounted) setState(() { _isWebLoading = false; });
            _webController.runJavaScript('''
              window.open = function() { return null; };
              var links = document.getElementsByTagName('a');
              for(var i=0; i<links.length; i++) { links[i].removeAttribute('target'); links[i].href = 'javascript:void(0);'; }
              var iframes = document.getElementsByTagName('iframe');
              for(var i=0; i<iframes.length; i++) { iframes[i].style.display = 'none'; }
            ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (!request.url.contains(videoHost)) return NavigationDecision.prevent;
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.videoUrl));
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black, elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SafeArea(
        child: Center(
          child: _isNativePlayer
              ? (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                  ? Chewie(controller: _chewieController!)
                  : const CircularProgressIndicator(color: Color(0xFFF47521)))
              : Stack(
                  children: [
                    WebViewWidget(controller: _webController),
                    if (_isWebLoading) const Center(child: CircularProgressIndicator(color: Color(0xFFF47521))),
                  ],
                ),
        ),
      ),
    );
  }
}
