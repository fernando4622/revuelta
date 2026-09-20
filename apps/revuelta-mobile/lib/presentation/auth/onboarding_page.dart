import 'package:flutter/material.dart';
import '../shared/theme/app_colors.dart';
import 'login_page.dart';
import 'splash_welcome_page.dart';

/// Interactive Onboarding carousel covering Mockup Screens 1, 2, 3, 4:
/// - Slide 0: Splash / Bienvenida 100% fiel al diseño
/// - Slide 1: Onboarding 1 (Usa. Disfruta. Devuelve.)
/// - Slide 2: Onboarding 2 (Tu acción hace la diferencia.)
/// - Slide 3: Onboarding 3 (Un campus más limpio, juntos.)
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingItem> _slides = [
    const _OnboardingItem(
      stepTag: '',
      title: '',
      subtitle: '',
      isSplash: true,
      icon: Icons.lunch_dining,
    ),
    const _OnboardingItem(
      stepTag: '1 / 3',
      title: 'Usa. Disfruta.\nDevuelve.',
      subtitle: 'Los contenedores que utilizas en el campus vuelven a la vida.',
      icon: Icons.inventory_2_outlined,
    ),
    const _OnboardingItem(
      stepTag: '2 / 3',
      title: 'Tu acción\nhace la diferencia.',
      subtitle:
          'Cada contenedor devuelto reduce residuos y cuida nuestro campus.',
      icon: Icons.location_city,
    ),
    const _OnboardingItem(
      stepTag: '3 / 3',
      title: 'Un campus\nmás limpio, juntos.',
      subtitle: 'Sé parte del cambio. Devuelve, reutiliza, impacta.',
      icon: Icons.volunteer_activism_outlined,
    ),
  ];

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPage == 0) {
      // Direct 100% faithful presentation of the Splash / Welcome screen
      return SplashWelcomePage(
        onStart: () {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      );
    }

    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // PageView Carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  if (slide.isSplash) {
                    return SplashWelcomePage(
                        onStart: () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ));
                  }
                  return _buildOnboardingSlide(slide);
                },
              ),
            ),

            // Bottom Navigation Indicators & Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Saltar button
                  TextButton(
                    onPressed: _navigateToLogin,
                    child: const Text(
                      'Saltar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  // Dot Indicators
                  Row(
                    children: List.generate(
                      _slides.length - 1,
                      (i) {
                        final dotIndex = i + 1;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == dotIndex ? 18 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _currentPage == dotIndex
                                ? AppColors.forestGreen
                                : AppColors.cardBorder,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      },
                    ),
                  ),

                  // Siguiente / Comenzar button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.forestGreen,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 12),
                    ),
                    onPressed: () {
                      if (isLastPage) {
                        _navigateToLogin();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(isLastPage ? 'Comenzar' : 'Siguiente'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Slides 1, 2, 3: Onboarding step
  Widget _buildOnboardingSlide(_OnboardingItem slide) {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            slide.stepTag,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.forestGreen,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            slide.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            slide.subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const Spacer(),
          // Central illustration
          Center(
            child: Container(
              width: 180,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.mintGreen.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                slide.icon,
                size: 72,
                color: AppColors.forestGreen,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _OnboardingItem {
  final String stepTag;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSplash;

  const _OnboardingItem({
    required this.stepTag,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isSplash = false,
  });
}
