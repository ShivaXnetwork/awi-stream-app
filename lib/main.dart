import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:screen_brightness/screen_brightness.dart';

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

class AnimeDetailsScreen extends StatefulWidget {
  final String animeId;
  final String title;
  final String posterUrl;

  const AnimeDetailsScreen({super.key, required this.animeId, required this.title, required this.posterUrl});

  @override
  State<AnimeDetailsScreen> createState() => _AnimeDetailsScreenState();
}

class _AnimeDetailsScreenState extends State<AnimeDetailsScreen> {

  Future<void> _playEpisode(BuildContext context, String msgId, String epTitle) async {
    if (msgId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link not found in database!")));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFF47521))),
    );

    try {
      DocumentSnapshot serverDoc = await FirebaseFirestore.instance.collection('settings').doc('server').get();
      Navigator.pop(context); 

      if (serverDoc.exists) {
        String activeUrl = serverDoc.get('active_url') ?? "";
        String finalStreamLink = "$activeUrl/stream/$msgId";
        
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(videoUrl: finalStreamLink, title: epTitle)
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Stream Server is Offline!")));
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Connection Error: $e")));
    }
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
              title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(widget.posterUrl, fit: BoxFit.cover, alignment: Alignment.topCenter),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Color(0xFF07070F)],
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
                children: const [
                  SizedBox(height: 10),
                  Text("Episodes", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('episodes').where('animeId', isEqualTo: widget.animeId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: Color(0xFFF47521))));
              
              var rawEpisodes = snapshot.data?.docs ?? [];
              if (rawEpisodes.isEmpty) return const SliverToBoxAdapter(child: Center(child: Text("No episodes uploaded yet!", style: TextStyle(color: Colors.white54))));

              rawEpisodes.sort((a, b) => ((a.data() as Map<String, dynamic>)['num'] ?? 0).compareTo((b.data() as Map<String, dynamic>)['num'] ?? 0));

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    var epData = rawEpisodes[index].data() as Map<String, dynamic>;
                    int epNum = epData['num'] ?? (index + 1);
                    String actualTitle = epData['title'] ?? 'Episode $epNum';
                    
                    String msgId = "";
                    if (epData['links'] != null && epData['links']['1080p'] != null) {
                      msgId = epData['links']['1080p']['player']?.toString() ?? "";
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
                        title: Text("Season 1 • Ep $epNum", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFF47521))),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(actualTitle, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                        onTap: () {
                          _playEpisode(context, msgId, "Ep $epNum - $actualTitle");
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

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  const VideoPlayerScreen({super.key, required this.videoUrl, required this.title});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  double _currentVolume = 0.5;
  double _currentBrightness = 0.5;

  @override
  void initState() {
    super.initState();
    
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    PerfectVolumeControl.getVolume().then((vol) => _currentVolume = vol);
    ScreenBrightness().current.then((b) => _currentBrightness = b);
    PerfectVolumeControl.hideUI = true; 

    _initNativePlayer();
  }

  void _initNativePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _videoPlayerController!.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true, 
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      allowedScreenSleep: false, 
      showControlsOnInitialize: false,
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFFF47521), 
        handleColor: const Color(0xFFF47521),
        bufferedColor: Colors.white24,
        backgroundColor: Colors.black54,
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized)
              ? GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragUpdate: (details) async {
                    double screenWidth = MediaQuery.of(context).size.width;
                    double delta = -details.delta.dy / 200; 

                    if (details.globalPosition.dx < screenWidth / 2) {
                      _currentBrightness = (_currentBrightness + delta).clamp(0.0, 1.0);
                      await ScreenBrightness().setScreenBrightness(_currentBrightness);
                    } else {
                      _currentVolume = (_currentVolume + delta).clamp(0.0, 1.0);
                      PerfectVolumeControl.setVolume(_currentVolume);
                    }
                  },
                  child: Chewie(controller: _chewieController!),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(color: Color(0xFFF47521)),
                    SizedBox(height: 20),
                    Text("CONNECTING TO AWI SERVER...", style: TextStyle(color: Color(0xFFF47521), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ],
                ),
        ),
      ),
    );
  }
}
