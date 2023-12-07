import 'package:animated_introduction/animated_introduction.dart';
import 'package:flutter/material.dart';

class IntroductionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<SingleIntroScreen> pages = [
      const SingleIntroScreen(
        title: 'Welcome to DishDash!',
        description:
            'Plan your meals, discover new recipes, and enjoy cooking like never before!',
        imageAsset: 'assets/onboard_one.png',
      ),
      const SingleIntroScreen(
        title: 'Discover Delicious Recipes',
        description:
            'Explore a variety of recipes, from quick and easy to gourmet meals!',
        imageAsset: 'assets/onboard_two.png',
      ),
      const SingleIntroScreen(
        title: 'Plan Your Meals with Ease',
        description:
            'Take the stress out of meal planning with our easy-to-use meal planner!',
        imageAsset: 'assets/onboard_three.png',
      ),
    ];
    return Scaffold(
      body: AnimatedIntroduction(
        slides: pages,
        indicatorType: IndicatorType.circle,
        onDone: () {
          Navigator.of(context).pushReplacementNamed('/login');
        },
      ),
    );
  }
}
