import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meomum/core/routing/routes.dart';
import 'package:meomum/feature/on_boarding/feature/on_boarding/presentation/screen/on_boarding_action.dart';
import 'package:meomum/feature/on_boarding/feature/on_boarding/presentation/screen/on_boarding_screen.dart';

class OnBoardingScreenRoot extends StatelessWidget {
  const OnBoardingScreenRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return OnBoardingScreen(
      onAction: (OnBoardingAction action) {
        switch (action) {
          case TapCreateProfile():
            context.push(
              '${Routes.onBoarding}/${Routes.onBoardingCreateProfile}',
            );
        }
      },
    );
  }
}
