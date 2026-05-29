import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 🔥 STEALTH FIREBASE INITIALIZATION (Bina JSON file ke)
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDfNgqR9UtKUvd2Prf2YPBFu33DJ_ubytk", 
        appId: "1:747833174910:web:eefcbf01901ecb58b8a12f", // Tumhari App ID aa gayi!
        messagingSenderId: "747833174910", // Tumhara Sender ID aa gaya!
        projectId: "anime-website-42907", 
      ),
    );
    runApp(const AwiToApp());
  } catch (e) {
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "🔥 HACKER ALERT - ERROR MIL GAYA: 🔥\n\n$e",
              style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
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
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D0D14),
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ==========================================
// 🏠 HOME SCREEN (List of Animes)
// ==========================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AWI.TO', 
          style: TextStyle(color: Color(0xFFF47521), fontWeight: FontWeight.w900, letterSpacing: 2)
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('anime').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFF47521)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Koi Anime nahi mila 😅"));
          }

          final animes = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: animes.length,
            itemBuilder: (context, index) {
              var animeData = animes[index].data() as Map<String, dynamic>;
              String title = animeData['name'] ?? 'Unknown Anime';
              String animeId = animes[index].id;
              String posterUrl = animeData['posterUrl'] ?? 'https://via.placeholder.com/300x400.png?text=Poster';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnimeDetailsScreen(animeId: animeId, title: title, posterUrl: posterUrl),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(posterUrl, fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        right: 10,
                        child: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==========================================
// 🎬 ANIME DETAILS SCREEN (Episodes List)
// ==========================================
class AnimeDetailsScreen extends StatelessWidget {
  final String animeId;
  final String title;
  final String posterUrl;

  const AnimeDetailsScreen({super.key, required this.animeId, required this.title, required this.posterUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Image.network(posterUrl, fit: BoxFit.cover),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Episodes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF47521))),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('episodes')
                  .where('animeId', isEqualTo: animeId)
                  .orderBy('num')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFF47521)));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Abhi episodes upload nahi hue hain."));
                }

                final episodes = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: episodes.length,
                  itemBuilder: (context, index) {
                    var epData = episodes[index].data() as Map<String, dynamic>;
                    String epTitle = epData['title'] ?? 'Episode ${epData['num']}';
                    
                    String videoLink = "";
                    if (epData['links'] != null && epData['links']['1080p'] != null) {
                      videoLink = epData['links']['1080p']['player'] ?? "";
                    }

                    return Card(
                      color: const Color(0xFF1E1E2A),
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: const Icon(Icons.play_circle_fill, color: Color(0xFFF47521), size: 30),
                        title: Text(epTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          if (videoLink.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoPlayerScreen(videoUrl: videoLink, title: epTitle),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link nahi mila bhai!")));
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
// 🛡️ THE STEALTH NATIVE-FEEL VIDEO PLAYER
// ==========================================
class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  const VideoPlayerScreen({super.key, required this.videoUrl, required this.title});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    String videoHost = Uri.parse(widget.videoUrl).host;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() { _isLoading = true; });
          },
          onPageFinished: (String url) {
            if (mounted) setState(() { _isLoading = false; });
            
            // 💉 STEALTH INJECTOR
            _controller.runJavaScript('''
              window.open = function() { return null; };
              var links = document.getElementsByTagName('a');
              for(var i=0; i<links.length; i++) {
                links[i].removeAttribute('target');
                links[i].href = 'javascript:void(0);';
              }
            ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            // 🛑 STRICT NAVIGATION SHIELD
            if (!request.url.contains(videoHost)) {
              debugPrint("Blocked Ad/Redirect: \${request.url}");
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.videoUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFFF47521)),
              ),
          ],
        ),
      ),
    );
  }
}
