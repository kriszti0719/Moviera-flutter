import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Szolgáltatások és Repositories
import 'data/services/firebase_auth_service.dart';
import 'data/services/tmdb_api_service.dart';
import 'data/services/local_storage_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/movie_repository.dart';

// Domain modellek
import 'domain/models/user_model.dart';

// UI és ViewModels
import 'ui/auth/view_model/auth_view_model.dart';
import 'ui/auth/widgets/login_screen.dart';
import 'ui/search/view_model/search_view_model.dart';
import 'ui/search/widgets/search_screen.dart';
import 'ui/watchlist/view_model/watchlist_view_model.dart';
import 'ui/watchlist/widgets/watchlist_screen.dart';
import 'ui/about/widgets/about_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authService = FirebaseAuthService();
  final authRepository = AuthRepository(authService: authService);
  
  final apiService = TmdbApiService();
  final localStorageService = LocalStorageService();
  final movieRepository = MovieRepository(
    apiService: apiService,
    localStorageService: localStorageService,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchViewModel(movieRepository: movieRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => WatchlistViewModel(movieRepository: movieRepository)..loadWatchlist(),
        ),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<MovieRepository>.value(value: movieRepository),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moviera',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = context.read<AuthRepository>();

    return StreamBuilder<UserModel?>(
      stream: authRepository.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const MainNavigationShell();
        }

        return const LoginScreen();
      },
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  // Most már csak 2 fülünk van alul
  final List<Widget> _screens = [
    const WatchlistScreen(),
    const SearchScreen(),
  ];

  final List<String> _titles = [
    'My Watchlist',
    'Search Movies',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
        // BAL FELSŐ SAROK: Az About gomb beágyazása, ami felugró ablakot nyit meg
        leading: IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.grey[900],
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => const AboutScreen(),
            );
          },
          tooltip: 'About Project',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<SearchViewModel>().clearSearch();
              context.read<AuthViewModel>().logout();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blueGrey[200],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_outlined),
            activeIcon: Icon(Icons.movie),
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }
}