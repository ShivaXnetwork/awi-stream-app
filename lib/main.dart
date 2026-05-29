import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart'; 

void main() {
  runApp(const AwiStreamApp());
}

class AwiStreamApp extends StatelessWidget {
  const AwiStreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AwiStream',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFF47521),
        scaffoldBackgroundColor: const Color(0xFF000000),
      ),
      home: const SplashScreen(),
    );
  }
}

// 🎬 SPLASH SCREEN
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('AWI.TO', style: TextStyle(fontSize: 45, fontWeight: FontWeight.w900, color: Color(0xFFF47521), letterSpacing: 3.0)),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Color(0xFFF47521)),
          ],
        ),
      ),
    );
  }
}

// 🏠 HOME SCREEN
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List animes = [];
  bool isLoading = true;
  String errorMessage = "";
  final String projectId = "anime-website-42907";
  final String apiKey = "AIzaSyDfNgqR9UtKUvd2Prf2YPBFu33DJ_ubytk";

  @override
  void initState() {
    super.initState();
    fetchAnimes();
  }

  Future<void> fetchAnimes() async {
    final url = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/anime?key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          animes = json.decode(response.body)['documents'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() { isLoading = false; errorMessage = "Server Error"; });
      }
    } catch (e) {
      setState(() { isLoading = false; errorMessage = "Network Error"; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AwiStream', style: TextStyle(color: Color(0xFFF47521), fontWeight: FontWeight.w900, fontSize: 24)),
        backgroundColor: Colors.black,
        elevation: 0, centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF47521)))
          : animes.isEmpty ? Center(child: Text(errorMessage.isNotEmpty ? errorMessage : "No Anime Found!"))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AnimeDetailsScreen(animeData: animes[0]))),
                    child: Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Image.network(animes[0]['fields']['poster']?['stringValue'] ?? '', height: 250, width: double.infinity, fit: BoxFit.cover, alignment: Alignment.topCenter),
                        Container(height: 250, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.9)]))),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), color: const Color(0xFFF47521), child: const Text("FEATURED", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white))),
                              const SizedBox(height: 5),
                              Text(animes[0]['fields']['name']?['stringValue'] ?? 'Unknown', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 15.0), child: Text("All Anime", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: animes.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AnimeDetailsScreen(animeData: animes[index]))),
                          child: Container(
                            width: 130, margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(animes[index]['fields']['poster']?['stringValue'] ?? '', height: 160, width: 130, fit: BoxFit.cover)),
                                const SizedBox(height: 5),
                                Text(animes[index]['fields']['name']?['stringValue'] ?? 'Unknown', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// 📄 ANIME DETAILS & EPISODES
class AnimeDetailsScreen extends StatefulWidget {
  final Map animeData;
  const AnimeDetailsScreen({super.key, required this.animeData});
  @override
  State<AnimeDetailsScreen> createState() => _AnimeDetailsScreenState();
}

class _AnimeDetailsScreenState extends State<AnimeDetailsScreen> {
  List episodes = [];
  bool isLoadingEps = true;
  final String projectId = "anime-website-42907";
  final String apiKey = "AIzaSyDfNgqR9UtKUvd2Prf2YPBFu33DJ_ubytk";

  @override
  void initState() {
    super.initState();
    fetchRealEpisodes();
  }

  Future<void> fetchRealEpisodes() async {
    String animeDocId = widget.animeData['name'].split('/').last;
    final url = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/episodes?key=$apiKey';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List allEps = data['documents'] ?? [];
        List filteredEps = allEps.where((ep) => ep['fields']['animeId']?['stringValue'] == animeDocId).toList();
        filteredEps.sort((a, b) => int.parse(a['fields']['num']?['integerValue'] ?? '0').compareTo(int.parse(b['fields']['num']?['integerValue'] ?? '0')));
        setState(() { episodes = filteredEps; isLoadingEps = false; });
      }
    } catch (e) {
      setState(() { isLoadingEps = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    var fields = widget.animeData['fields'];
    String name = fields['name']?['stringValue'] ?? 'Unknown';
    String posterUrl = fields['poster']?['stringValue'] ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0, pinned: true, backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, shadows: [Shadow(color: Colors.black, blurRadius: 10)])),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(posterUrl, fit: BoxFit.cover, alignment: Alignment.topCenter),
                  Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.9)]))),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fields['description']?['stringValue'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 20),
                    const Text("Episodes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 10),
                    
                    isLoadingEps 
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFFF47521)))
                        : episodes.isEmpty 
                            ? const Text("Episodes aane baaki hain...", style: TextStyle(color: Colors.grey))
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: episodes.length,
                                itemBuilder: (context, index) {
                                  var epFields = episodes[index]['fields'];
                                  String epNum = epFields['num']?['integerValue'] ?? '0';
                                  String epTitle = epFields['title']?['stringValue'] ?? 'Episode $epNum';
                                  var linksData = epFields['links']?['mapValue']?['fields'];
                                  String playerUrl = "";
                                  
                                  if (linksData != null) {
                                    var qualityData = linksData['1080p'] ?? linksData['720p'] ?? linksData['480p'] ?? linksData['HD'];
                                    if (qualityData != null) {
                                      playerUrl = qualityData['mapValue']?['fields']?['player']?['stringValue'] ?? "";
                                    }
                                  }

                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 5),
                                    leading: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.network(posterUrl, width: 100, height: 60, fit: BoxFit.cover),
                                        Container(width: 100, height: 60, color: Colors.black.withOpacity(0.4)),
                                        const Icon(Icons.play_circle_fill, color: Colors.white),
                                      ],
                                    ),
                                    title: Text("E$epNum - $epTitle", maxLines: 1, overflow: TextOverflow.ellipsis),
                                    subtitle: const Text("HD | Sub", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    onTap: () {
                                      if (playerUrl.isNotEmpty) {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(videoUrl: playerUrl, title: "E$epNum - $name")));
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Is episode ka video link nahi mila!")));
                                      }
                                    },
                                  );
                                },
                              )
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// 🛡️ IN-APP VIDEO PLAYER (WITH AD-BLOCKER SHIELD)
class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  const VideoPlayerScreen({super.key, required this.videoUrl, required this.title});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    
    // Original website ka host nikalo (jaise bysekoze.com)
    String videoHost = Uri.parse(widget.videoUrl).host;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // 💉 JAVASCRIPT INJECTOR (Kill Pop-ups)
            _controller.runJavaScript('''
              // 1. Naye tab kholne wale function ko dead kar do
              window.open = function() { return null; };
              
              // 2. Click karne par jo redirect wale hidden links hote hain, unko hata do
              var links = document.getElementsByTagName('a');
              for(var i=0; i<links.length; i++) {
                if(links[i].target === '_blank') {
                  links[i].removeAttribute('target');
                  links[i].href = 'javascript:void(0);';
                }
              }
            ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            // 🛑 NAVIGATION SHIELD (Block redirects to Ads)
            if (!request.url.contains(videoHost) && !request.url.contains('google')) {
              // Agar koi naya URL khul raha hai jo original host nahi hai, toh use block kar do
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
        title: Text(widget.title, style: const TextStyle(fontSize: 16)),
      ),
      body: SafeArea(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
