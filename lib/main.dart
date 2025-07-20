import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import BlocProvider
import 'firebase_options.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/sign_in_page.dart';
import 'features/auth/presentation/pages/home_page.dart'; // We'll create this
import 'injection_container.dart' as di; // Alias for injection_container

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await di.init(); // Initialize GetIt
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AuthBloc>(), // Provide AuthBloc
      child: MaterialApp(
        title: 'Firebase Auth Clean Arch',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return HomePage(user: state.user);
        } else if (state is Unauthenticated) {
          return const SignInPage();
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}










/*
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:start/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:start/features/auth/presentation/pages/login_page.dart';
import 'package:start/features/auth/responsive_login_screen.dart';
import 'package:start/features/auth/responsive_reset_password_screen.dart';
import 'package:start/features/auth/responsive_signup_screen.dart';
import 'package:start/features/auth/responsive_welcome_screen.dart';
import 'generated/l10n.dart';
import 'package:start/dadadu/dadadu_screen.dart';
import 'package:start/screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 await dotenv.load(fileName: ".env"); 
  await Firebase.initializeApp();
  await di.init();
  // await StripeService.init();

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  runApp(
    ScreenUtilInit(
      designSize: const Size(360, 640),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MyApp(savedThemeMode: savedThemeMode);
      },
    )
  );
}


class MyApp extends StatefulWidget {
  final AdaptiveThemeMode? savedThemeMode;
  const MyApp({super.key, required this.savedThemeMode});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }
  
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale');
    if (code != null) {
      setState(() {
        _locale = Locale(code);
      });
    }
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.white,
          highlightColor: Colors.grey[200],
          focusColor: Colors.white,
          primaryColor: Colors.black,
          primaryColorLight: const Color.fromARGB(255, 63, 63, 63).withAlpha(51),
          canvasColor: Colors.black54,
          shadowColor: Colors.black87,
          cardColor: Colors.grey[50],
          splashColor: Colors.black38,
          hintColor: Colors.black12,
          primaryColorDark: const Color(0xFFF8F8F8),
          inputDecorationTheme: const InputDecorationTheme(
            hintStyle: TextStyle(color: Colors.black54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.amberAccent),
            ),
          )),
      dark: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.black,
          primaryColorLight: Colors.grey.withAlpha(51),
          primaryColorDark: const Color(0xFF0a0a0a),
          highlightColor: Colors.grey[800],
          primaryColor: Colors.white,
          focusColor: Colors.grey[800],
          shadowColor: Colors.white70,
          canvasColor: Colors.white54,
          cardColor: Colors.grey[900],
          splashColor: Colors.white38,
          hintColor: Colors.white10,
          inputDecorationTheme: const InputDecorationTheme(
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.amberAccent),
            ),
          )),
      initial: widget.savedThemeMode ?? AdaptiveThemeMode.dark,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'Dadadu',
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        locale: _locale,
        supportedLocales: S.delegate.supportedLocales,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        home: BlocProvider(create: (_) => di.sl<AuthBloc>(), child: LoginPage(),),
        // initialRoute: '/',
        // routes: {
        //   '/': (context) => const AuthWrapper(),
        //   '/welcome': (context) => const ResponsiveWelcomeScreen(),
        //   '/login': (context) => const ResponsiveLoginScreen(),
        //   '/signup': (context) => const ResponsiveSignupScreen(),
        //   '/reset': (context) => const ResponsiveResetPasswordScreen(),
        //   '/home': (context) => const HomeScreen(),
        //   '/settings': (context) => const SettingsScreen(),
        //   '/profile': (context) => const ProfileScreen(),
        //   '/discover': (context) => const DadaduScreen(),
        // },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.amberAccent),
            ),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return const ResponsiveWelcomeScreen();
        }
      },
    );
  }
}
*/
