import "package:flutter/material.dart";

import "core/accessibility/smart_assistant.dart";
import "features/home/home_screen.dart";
import "features/onboarding/onboarding_screen.dart";
import "features/community_feedback/data/community_feedback_repository.dart";
import "features/profile/data/user_profile_repository.dart";
import "features/shopping_list/data/shopping_list_repository.dart";

/// Onboarding tamamlanana kadar kurulum, ardından ana ekran.
class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  @override
  void initState() {
    super.initState();
    final repo = UserProfileRepository.instance;
    repo.ensureLoaded().then((_) {
      if (mounted) {
        setState(() {});
        // Onboarding tamamlanmışsa akıllı asistan rehberliğini başlat
        if (repo.onboardingComplete) {
          Future<void>.delayed(const Duration(milliseconds: 1500), () {
            SmartAssistant.instance.showInitialGuidance();
          });
        }
      }
    });
    ShoppingListRepository.instance.ensureLoaded().then((_) {
      if (mounted) setState(() {});
    });
    CommunityFeedbackRepository.instance.ensureLoaded().then((_) {
      if (mounted) setState(() {});
    });
    repo.addListener(_onRepo);
  }

  void _onRepo() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    UserProfileRepository.instance.removeListener(_onRepo);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = UserProfileRepository.instance;
    if (!repo.isLoaded) {
      return Scaffold(
        body: Center(
          child: Semantics(
            label: "Uygulama yükleniyor",
            child: const CircularProgressIndicator(),
          ),
        ),
      );
    }
    if (!repo.onboardingComplete) {
      return const OnboardingScreen();
    }
    return const HomeScreen();
  }
}
