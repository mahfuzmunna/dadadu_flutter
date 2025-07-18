
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'package:start/generated/l10n.dart'; // Import your localization
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveWelcomeScreen extends StatelessWidget {
  const ResponsiveWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = S.of(context); // Localization shortcut
    final colorScheme = Theme.of(context).colorScheme;

    // DARK MODE & LIGHT MODE NEEDS SEPARATE BACKGROUND IMAGE
    // BASED ON WALLPAPER
    // IMPLEMENTED LOGIC - IMAGES TO BE ADDED/UPDATED LATER

    var brightness = Theme.of(context).brightness;
    String backgroundImage = brightness == Brightness.light ?
    'assets/images/space_background_2.jpg' : 'assets/images/space_background.jpg';

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isPortrait = orientation == Orientation.portrait;
            return Stack(
              children: [
                // 🌌 Background image
                Positioned.fill(
                  child: Image.asset(
                    backgroundImage,
                    fit: BoxFit.cover,
                  ),
                ),

                // 🌍 Foreground content
                Container(
                  margin: EdgeInsets.only(top: 24.h),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: isPortrait ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // PORTRAIT CONTENTS
                          ..._buildSectionA(context, size, s, colorScheme, true),
                          ..._buildSectionB(context, size, s, colorScheme, true),
                        ],
                      ) : Row(
                        children: [
                          Expanded(child: Column(
                            children: [
                              ..._buildSectionA(context, size, s, colorScheme, false)
                            ],
                          )
                          ),
                          SizedBox(width: 16.w,),
                          Container(
                            margin: EdgeInsets.only(top: 24.h),
                            child: Expanded(child: Column(
                              children: [
                                ..._buildSectionB(context, size, s, colorScheme, false)
                              ],
                            )),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),

      ),
    );
  }



  List<Widget> _buildSectionA(BuildContext context, Size size, S s, ColorScheme colorScheme, bool isPortrait) {
    return [
      SizedBox(
      // width: size.width * 0.45,
      width: 72.w,
      child: Image.asset(
        'assets/icons/logo_v2.png',
        fit: BoxFit.contain,
      ),
    ),
      SizedBox(height: 18.h),
      Text(s.welcomeToDadaduSubHeader),

      Expanded(
        child: Text(
          s.welcomeToDadadu, // Localized text
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isPortrait ? 26.sp : 14.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),

     ];
  }

  List<Widget> _buildSectionB(BuildContext context, Size size, S s, ColorScheme colorScheme, bool isPortrait) {
    return [
      // SWITCHED TO MATERIAL FILLED BUTTONS

      // 🔐 Signup button (blue neon)
      // NeonButton(
      //   text: s.welcomeSignUp,
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (_) => const SignupScreen()),
      //     );
      //   },
      // ),

      SizedBox(
        width: isPortrait? 0.9.sw : 92.w,
        height: isPortrait ? 36.h : 42.h,
        child: FilledButton.tonal(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const LoginScreen()),
              );
            },
            style: FilledButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        24.r)
                )
            ),
            child: Text(s.welcomeLogin,
              style: TextStyle(
                  fontSize: isPortrait ? 18.sp : 10.sp,
                  fontWeight: FontWeight.w600
              ),
            )
        ),
      ),

      SizedBox(height: 12.h,),

      Text(s.welcomeSignUpSubHeader, style: TextStyle(
        fontSize: isPortrait? 12.sp : 6.sp
      ),),
      SizedBox(height: 10.h,),
      SizedBox(
        width: isPortrait? 0.9.sw : 92.w,
        height: isPortrait? 36.h  : 42.h,
        child: FilledButton(
            onPressed: () {
              Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const SignupScreen()),
              );
            },
            style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        24.r)
                )
            ),
            child: Text(s.welcomeSignUp,
              style: TextStyle(
                  fontSize: isPortrait?18.sp : 10.sp,
                  fontWeight: FontWeight.w600
              ),
            )
        ),
      ),
      if(isPortrait)SizedBox(height: 12.h,),

      // 🔑 Login button (yellow neon)
      // NeonButton(
      //   text: s.welcomeLogin,
      //   glowColor: Colors.amberAccent,
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (_) => const LoginScreen()),
      //     );
      //   },
      // ),
    ];
  }

}

