import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:webview_master_app/screens/webview_screen.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _shineController; 
  late AnimationController _exitController;    
  late AnimationController _pulseController;   
  
  late Animation<double> _exitZoomAnimation;
  late Animation<double> _exitOpacityAnimation;
  
  bool _isFinishing = false;

  @override
  void initState() {
    super.initState();
    
    // 1. Shine Effect (Flash)
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // 2. Background Aura Pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // 3. Exit Scale Up (Zoom)
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _exitZoomAnimation = Tween<double>(begin: 1.0, end: 15.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInExpo),
    );

    _exitOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() => _isFinishing = true);
        _exitController.forward().then((value) => _goToHome());
      }
    });
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim, anim2) => const WebViewScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (c, anim, anim2, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _shineController.dispose();
    _exitController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
backgroundColor: const Color(0xFF22314E),
      body: AnimatedBuilder(
        animation: Listenable.merge([_shineController, _exitController, _pulseController]),
        builder: (context, child) {
          return Stack(
            children: [
              // Pulse Aura
              Center(
                child: Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.2),
                  child: Container(
                    width: 350, height: 350,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.07), blurRadius: 100, spreadRadius: 50)],
                    ),
                  ),
                ),
              ),
              // Fixed Text with Flash & Zoom
              Center(
                child: Opacity(
                  opacity: _isFinishing ? _exitOpacityAnimation.value : 1.0,
                  child: Transform.scale(
                    scale: _isFinishing ? _exitZoomAnimation.value : 1.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) => LinearGradient(
                            colors: const [Colors.white, Colors.white, Colors.white38, Colors.white, Colors.white],
                            stops: [0.0, (_shineController.value * 1.5) - 0.4, (_shineController.value * 1.5) - 0.2, _shineController.value * 1.5, 1.0],
                          ).createShader(bounds),
                          child: const Text('CLOSH', style: TextStyle(fontSize: 85, fontWeight: FontWeight.w900, letterSpacing: -5, color: Colors.white, height: 1.0)),
                        ),
                        const SizedBox(height: 10),
                        //const Text('PREMIUM DELIVERY SERVICES', style: TextStyle(color: Colors.white, letterSpacing: 5, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}