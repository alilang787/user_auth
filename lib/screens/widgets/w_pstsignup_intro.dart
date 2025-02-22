import 'package:user_auth/screens/widgets/w_ring_shape.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class IntroPostSignUp extends StatefulWidget {
  const IntroPostSignUp({
    super.key,
  });

  @override
  State<IntroPostSignUp> createState() => _IntroPostSignUpState();
}

class _IntroPostSignUpState extends State<IntroPostSignUp>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _animationController1;

  @override
  void initState() {
    super.initState();
    _animationController1 =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animationController = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 1700,
        ));
    _animationController.forward().then((value) {
      _animationController1.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationController1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return SlideTransition(
              child: AnimatedBuilder(
                animation: _animationController1,
                child: child,
                builder: (context, child) {
                  // double height = MediaQuery.of(context).size.height * 2;
                  return SlideTransition(
                    child: child,
                    position: Tween(begin: Offset(0, 0), end: Offset(0, -10))
                        .animate(_animationController1),
                  );
                },
              ),
              position: Tween(begin: Offset(0, -1), end: Offset(0, 0)).animate(
                CurvedAnimation(
                    parent: _animationController, curve: Curves.easeOut),
              ),
            );
          },
          child: RingShape(),
        ),
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return SlideTransition(
              child: AnimatedBuilder(
                animation: _animationController1,
                child: child,
                builder: (context, child) {
                  // double height = MediaQuery.of(context).size.height * 2;
                  return SlideTransition(
                    child: child,
                    position: Tween(begin: Offset(0, 0), end: Offset(0, 100))
                        .animate(_animationController1),
                  );
                },
              ),
              position: Tween(begin: Offset(0, -1), end: Offset(0, 0)).animate(
                CurvedAnimation(
                    parent: _animationController, curve: Curves.easeOut),
              ),
            );
          },
          child: Text(
            'you are just one step away to create an account!',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        Gap(8),
      ],
    );
  }
}
