import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:vrikshanova/navigation/bottom_nav/Home/homescreen.dart';
import 'package:vrikshanova/navigation/bottom_nav/analysis/analysis.dart';
import 'package:vrikshanova/navigation/bottom_nav/disease_diagnosis/disease_diagnosis.dart';
import 'package:vrikshanova/navigation/side_nav_drawer/Settings/settings_screen.dart';
import 'package:vrikshanova/navigation/side_nav_drawer/controls/control_rover.dart';
import 'package:vrikshanova/navigation/side_nav_drawer/help.dart';
import 'package:vrikshanova/navigation/side_nav_drawer/profile_screen.dart';
import 'splash_screen.dart';


Future<void> main() async {
  await Supabase.initialize(
      url: 'https://wvtasqulnbqresqpvzfn.supabase.co',
      anonKey:'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind2dGFzcXVsbmJxcmVzcXB2emZuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxMTkzNzAsImV4cCI6MjA3OTY5NTM3MH0.dYMKxwDS3fU_K3tyeX2lVgz_n0y0xbGNDzJm0y2zso4'
  );
   runApp(const VirikshaNova());

}

class VirikshaNova extends StatelessWidget{
  const VirikshaNova({super.key});

@override
Widget build(BuildContext context){
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Vrikshanova',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF1e5128)),
      useMaterial3: true
    ),
    home: const SplashScreen(),

  //   Routes for Bottom Navigation and Side Navigation Drawer
    routes: { '/home': (context) => const HomeScreen(),
      '/disease': (context) => const DiseaseCheck(),
      '/control': (context) => const ControlScreen(),
      '/analysis' : (context) => const AnalyzePlant(),
      '/profile': (context) => const ProfileScreen(),
     // '/settings': (context) => const SettingsScreen(),


   //  '/video': (context) =>  VideoTFLiteScreen(),
      '/help': (context) => const HelpScreen()
     // '/logout': (context) => const LogoutScreen()
    },
  );
}
}
