import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

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
        // Crunchyroll ka asli Orange color
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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
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

// 🏠 HOME SCREEN (Crunchyroll UI)
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
        final data = json.decode(response.body);
        setState(() {
          animes = data['documents'] ?? [];
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
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF47521)))
          : animes.isEmpty
              ? Center(child: Text(errorMessage.isNotEmpty ? errorMessage : "No Anime Found!"))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HERO BANNER (Top Featured Anime)
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AnimeDetailsScreen(animeData: animes[0]))),
                        child: Stack(
                          alignment: Alignment.bottomLeft,
                          children: [
                            Container(
                              height: 250,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(animes[0]['fields']['poster']?['stringValue'] ?? ''),
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                ),
                              ),
                            ),
                            // Black Gradient Fade at bottom
                            Container(
                              height: 250,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    color: const Color(0xFFF47521),
                                    child: const Text("NEW UPDATE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    animes[0]['fields']['name']?['stringValue'] ?? 'Unknown',
                                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text("Latest Episodes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      const SizedBox(height: 10),

                      // HORIZONTAL SCROLLING POSTERS
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          itemCount: animes.length,
                          itemBuilder: (context, index) {
                            var fields = animes[index]['fields'];
                            String name = fields['name']?['stringValue'] ?? 'Unknown';
                            String posterUrl = fields['poster']?['stringValue'] ?? '';

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => AnimeDetailsScreen(animeData: animes[index])));
                              },
                              child: Container(
                                width: 130,
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(posterUrl, height: 160, width: 130, fit: BoxFit.cover),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }
}

// 📄 ANIME DETAILS & EPISODES SCREEN (New!)
class AnimeDetailsScreen extends StatelessWidget {
  final Map animeData;
  const AnimeDetailsScreen({super.key, required this.animeData});

  @override
  Widget build(BuildContext context) {
    var fields = animeData['fields'];
    String name = fields['name']?['stringValue'] ?? 'Unknown Anime';
    String posterUrl = fields['poster']?['stringValue'] ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, shadows: [Shadow(color: Colors.black, blurRadius: 10)])),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(posterUrl, fit: BoxFit.cover, alignment: Alignment.topCenter),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                      ),
                    ),
                  ),
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
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: const Text("START WATCHING E1", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF47521),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Episodes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 10),
                    // Dummy Episodes List for now (Phase 4 me isko database se jodenge)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 5, // abhi ke liye 5 dummy episodes
                      itemBuilder: (context, index) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.network(posterUrl, width: 100, height: 60, fit: BoxFit.cover),
                              const Icon(Icons.play_circle_outline, color: Colors.white),
                            ],
                          ),
                          title: Text("Episode ${index + 1}"),
                          subtitle: const Text("Sub | Dub", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Video Player loading...")));
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
