import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:ui';

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
      home: Scaffold(backgroundColor: const Color(0xFF07070F), body: Center(child: Text("🔥 ERROR:\n\n$e", style: const TextStyle(color: Colors.red)))),
    ));
  }
}

class AwiToApp extends StatelessWidget {
  const AwiToApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AWI.TO Premium',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07070F), 
        primaryColor: const Color(0xFFF47521),
        fontFamily: 'Roboto', 
      ),
      home: const MainScreen(),
    );
  }
}

// ==========================================
// 📱 AWI.TO EXCLUSIVE FLOATING NAV BAR
// ==========================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const Center(child: Text("My Watchlist (Coming Soon)", style: TextStyle(color: Colors.white54))),
    const AccountScreen(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, 
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF13131F).withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: const Color(0xFFF47521).withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: _selectedIndex,
              selectedItemColor: const Color(0xFFF47521),
              unselectedItemColor: Colors.white54,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              onTap: (index) => setState(() => _selectedIndex = index),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.bookmark_rounded), label: 'Watchlist'),
                BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFF47521), borderRadius: BorderRadius.circular(8)),
              child: const Text('AWI.TO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 18)),
            ),
            const Spacer(),
            const Icon(Icons.notifications_none_rounded, color: Colors.white),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search your favorite anime...",
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFF47521)),
                  filled: true,
                  fillColor: const Color(0xFF13131F),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text("Discover", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            ),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('anime').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Color(0xFFF47521))));
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox(height: 200, child: Center(child: Text("No Anime Uploaded Yet 😅")));

                final animes = snapshot.data!.docs.where((doc) {
                  return ((doc.data() as Map<String, dynamic>)['name'] ?? '').toString().toLowerCase().contains(searchQuery);
                }).toList();

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.68, crossAxisSpacing: 16, mainAxisSpacing: 16),
                  itemCount: animes.length,
                  itemBuilder: (context, index) {
                    var animeData = animes[index].data() as Map<String, dynamic>;
                    String title = animeData['name'] ?? 'Unknown Anime';
                    String animeId = animes[index].id;
                    String posterUrl = animeData['poster'] ?? 'https://via.placeholder.com/300x400.png?text=No+Image';

                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AnimeDetailsScreen(animeId: animeId, title: title, posterUrl: posterUrl))),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(posterUrl, fit: BoxFit.cover),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.transparent, const Color(0xFF07070F).withOpacity(0.95)],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: const [0.4, 1.0],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 12, left: 12, right: 12,
                                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 100), 
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 👤 ACCOUNT SCREEN
// ==========================================
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text("My Profile")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFF47521), width: 3), image: const DecorationImage(image: NetworkImage("https://i.pinimg.com/736x/8f/c2/f0/8fc2f07d2b86b03913076840742f5b84.jpg"), fit: BoxFit.cover)),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Owner Shiva", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("Premium Member", style: TextStyle(color: Color(0xFFF47521), fontSize: 14)),
                ],
              )
            ],
          ),
          const SizedBox(height: 30),
          ListTile(leading: const Icon(Icons.settings, color: Colors.white), title: const Text("App Settings"), trailing: const Icon(Icons.arrow_forward_ios, size: 14), tileColor: const Color(0xFF13131F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), onTap: () {}),
          const SizedBox(height: 10),
          ListTile(leading: const Icon(Icons.logout, color: Colors.redAccent), title: const Text("Log Out", style: TextStyle(color: Colors.redAccent)), tileColor: const Color(0xFF13131F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), onTap: () {}),
        ],
      ),
    );
  }
}

// ==========================================
// 🎬 ANIME DETAILS SCREEN
// ==========================================
class AnimeDetailsScreen extends StatelessWidget {
  final String animeId;
  final String title;
  final String posterUrl;

  const AnimeDetailsScreen({super.key, required this.animeId, required this.title, required this.posterUrl});

  void _showServerSelection(BuildContext context, String epTitle, String server1, String server2) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(color: Color(0xFF13131F), borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Select Server", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text(epTitle, style: const TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 20),
              
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF47521).withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.flash_on, color: Color(0xFFF47521))),
                title: const Text("AWI Premium (Auto)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: const Text("Fastest / MP4", style: TextStyle(color: Colors.white54, fontSize: 12)),
                tileColor: const Color(0xFF1A1A24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  Navigator.pop(context);
                  String finalLink = server1.isNotEmpty ? server1 : (server2.isNotEmpty ? server2 : "");
                  if(finalLink.isNotEmpty) Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(videoUrl: finalLink, title: epTitle)));
                },
              ),
              const SizedBox(height: 12),
              
              if (server2.isNotEmpty)
                ListTile(
                  leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.web, color: Colors.blueAccent)),
                  title: const Text("Web Player (Backup)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: const Text("Use if Premium fails", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  tileColor: const Color(0xFF1A1A24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(videoUrl: server2, title: epTitle)));
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF07070F),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(posterUrl, fit: BoxFit.cover, alignment: Alignment.topCenter),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, const Color(0xFF07070F)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF47521), borderRadius: BorderRadius.circular(5)), child: const Text("HD", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      const SizedBox(width: 10),
                      const Text("Sub | Dub", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("Episodes", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('episodes').where('animeId', isEqualTo: animeId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: Color(0xFFF47521))));
              var rawEpisodes = snapshot.data?.docs ?? [];
              if (rawEpisodes.isEmpty) return const SliverToBoxAdapter(child: Center(child: Text("Episodes coming soon...", style: TextStyle(color: Colors.white54))));

              rawEpisodes.sort((a, b) => ((a.data() as Map<String, dynamic>)['num'] ?? 0).compareTo((b.data() as Map<String, dynamic>)['num'] ?? 0));

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    var epData = rawEpisodes[index].data() as Map<String, dynamic>;
                    int epNum = epData['num'] ?? (index + 1);
                    String actualTitle = epData['title'] ?? 'Episode $epNum';
                    
                    String displayEpNumber = "Season 1 • Ep $epNum";
                    
                    String server1Mp4 = "";
                    String server2Web = "";

                    if (epData['links'] != null && epData['links']['1080p'] != null) {
                      var links = epData['links']['1080p'];
                      if (links['player'] != null) server2Web = links['player'];
                      if (links['server1'] != null) server1Mp4 = links['server1'];
                      if (links['server2'] != null) server2Web = links['server2'];
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFF13131F), borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(color: const Color(0xFFF47521).withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.play_arrow_rounded, color: Color(0xFFF47521), size: 30),
                        ),
                        title: Text(displayEpNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFF47521))),
                        // 🔥 YAHAN THI WOH GALTI. Ise theek kar diya hai:
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(actualTitle, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                        onTap: () {
                          _showServerSelection(context, "$displayEpNumber - $actualTitle", server1Mp4, server2Web);
                        },
                      ),
                    );
                  },
                  childCount: rawEpisodes.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)), 
        ],
      ),
    );
  }
}

// ==========================================
// 🛡️ CUSTOM DUAL VIDEO PLAYER
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
      autoPlay: true, aspectRatio: 16 / 9,
      materialProgressColors: ChewieProgressColors(playedColor: const Color(0xFFF47521), handleColor: const Color(0xFFF47521)),
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
          onPageStarted: (String url) { if (mounted) setState(() => _isWebLoading = true); },
          onPageFinished: (String url) { if (mounted) setState(() => _isWebLoading = false); },
          onNavigationRequest: (NavigationRequest request) {
            if (!request.url.contains(videoHost) && !request.url.contains("google")) {
              return NavigationDecision.prevent; 
            }
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
        title: Text(widget.title, style: const TextStyle(fontSize: 14, color: Colors.white54)),
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
