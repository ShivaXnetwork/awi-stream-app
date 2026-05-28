import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async'; // Timer ke liye

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
        primaryColor: Colors.deepOrange,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
      ),
      // App ab seedha Splash Screen se shuru hoga
      home: const SplashScreen(),
    );
  }
}

// 🎬 SPLASH SCREEN (Crunchyroll Style)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3 second wait karega aur fir Home Screen pe jayega
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Yahan tum apna Custom Logo image bhi laga sakte ho aage chalkar
            const Text(
              'AwiStream',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 20),
            // Crunchyroll jaisa orange spinner
            const CircularProgressIndicator(
              color: Colors.deepOrange,
            ),
          ],
        ),
      ),
    );
  }
}

// 🏠 HOME SCREEN (Tumhara Data)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List animes = [];
  bool isLoading = true;
  String errorMessage = ""; // Error dikhane ke liye

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
        setState(() {
          isLoading = false;
          errorMessage = "Server Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Internet nahi chal raha ya API block hai.\nError: $e";
      });
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AwiStream', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                    ),
                  ),
                )
              : animes.isEmpty
                  ? const Center(child: Text("No Anime Found! Server empty."))
                  : ListView.builder(
                      itemCount: animes.length,
                      itemBuilder: (context, index) {
                        var fields = animes[index]['fields'];
                        String name = fields['name']?['stringValue'] ?? 'Unknown Anime';
                        String posterUrl = fields['poster']?['stringValue'] ?? 'https://via.placeholder.com/150';

                        return Card(
                          color: const Color(0xFF1A1A1A),
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.network(
                                posterUrl,
                                width: 55,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.movie, color: Colors.grey, size: 50),
                              ),
                            ),
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: const Text("Tap to view episodes", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            trailing: const Icon(Icons.play_circle_fill, color: Colors.deepOrange, size: 28),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fetching episodes for $name...")));
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
