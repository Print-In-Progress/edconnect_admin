import 'package:flutter/material.dart';

class SignatureButton extends StatefulWidget {
  final bool isChecked;
  final VoidCallback onPressed;

  const SignatureButton({
    Key? key,
    required this.isChecked,
    required this.onPressed,
  }) : super(key: key);

  @override
  SignatureButtonState createState() => SignatureButtonState();
}

class SignatureButtonState extends State<SignatureButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (widget.isChecked) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant SignatureButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isChecked != oldWidget.isChecked) {
      if (widget.isChecked) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Icon(
                  widget.isChecked ? Icons.check : Icons.lock,
                  key: ValueKey<bool>(widget.isChecked),
                  color: widget.isChecked ? Colors.green : null,
                  size: widget.isChecked
                      ? 24.0 * _animation.value
                      : 24.0 * (_animation.value - 1) * -1,
                );
              },
            ),
          ),
          SizedBox(width: 8),
          Text(widget.isChecked ? 'Document Signed' : 'Sign Document'),
        ],
      ),
    );
  }
}
// Hiermit bestätige ich, dass ich durch das Ankreuzen dieses Kästchens und das Absenden dieses Formulars meine Zustimmung zur digitalen Unterzeichnung dieses Dokuments gebe. Ich verstehe, dass meine Unterschrift sicher mit kryptografischen Techniken 
// erzeugt wird, um die Authentizität und Integrität des Dokuments zu gewährleisten. Diese Unterschrift ist rechtlich bindend, und ich versichere, dass die angegebenen Informationen nach bestem Wissen und Gewissen korrekt sind.