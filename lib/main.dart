import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
        scaffoldBackgroundColor: const Color(0xFF0F0F0F), // Crunchyroll Dark Theme
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List animes = [];
  bool isLoading = true;

  // Tumhari Firebase ID aur API Key
  final String projectId = "anime-website-42907";
  final String apiKey = "AIzaSyDfNgqR9UtKUvd2Prf2YPBFu33DJ_ubytk";

  @override
  void initState() {
    super.initState();
    fetchAnimes(); // App khulte hi data fetch karna start
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
      }
    } catch (e) {
      setState(() {
        isLoading = false;
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
          : animes.isEmpty
              ? const Center(child: Text("No Anime Found! Server empty."))
              : ListView.builder(
                  itemCount: animes.length,
                  itemBuilder: (context, index) {
                    // Firebase ka JSON data parse karna
                    var fields = animes[index]['fields'];
                    String name = fields['name']?['stringValue'] ?? 'Unknown Anime';
                    // Agar script ne poster upload kiya hai toh wo, warna default
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
                          // Phase 3 me yahan click karne par Episodes list open hogi!
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fetching episodes for $name...")));
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
