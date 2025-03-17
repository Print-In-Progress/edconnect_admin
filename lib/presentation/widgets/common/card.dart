import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PIPResponsiveCard extends ConsumerStatefulWidget {
  final String title;
  final VoidCallback onTap;
  final List<String>? textContent;
  final List<Widget>? actionButtons;
  final List<Widget>? iconText;
  const PIPResponsiveCard(
      {super.key,
      required this.textContent,
      required this.title,
      this.iconText,
      this.actionButtons,
      required this.onTap});

  @override
  ConsumerState<PIPResponsiveCard> createState() => _PIPResponsiveCardState();
}

class _PIPResponsiveCardState extends ConsumerState<PIPResponsiveCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hoveredTransform = Matrix4.identity()..scale(1.01);
    final transfom = isHovered ? hoveredTransform : Matrix4.identity();
    final theme = ref.watch(appThemeProvider);
    return widget.actionButtons != null
        ? MouseRegion(
            onEnter: (event) => onEntered(true),
            onExit: (event) => onEntered(false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: transfom,
              child: GestureDetector(
                onTap: () {
                  widget.onTap();
                },
                child: Card(
                  margin: const EdgeInsets.only(
                      left: 20, right: 20, top: 10, bottom: 10),
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Flexible(
                                  fit: FlexFit.tight,
                                  child: Text(
                                    widget.title,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: theme.isDarkMode
                                            ? const Color.fromRGBO(
                                                202, 196, 208, 1)
                                            : Colors.grey[700]),
                                  ),
                                ),
                                for (var i in widget.textContent!)
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: Text(
                                      i.toString(),
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: theme.isDarkMode
                                              ? const Color.fromRGBO(
                                                  202, 196, 208, 1)
                                              : Colors.grey[700]),
                                    ),
                                  ),
                              ]),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (var i in widget.actionButtons!)
                                Expanded(child: i)
                            ],
                          )
                        ],
                      )),
                ),
              ),
            ),
          )
        : MouseRegion(
            onEnter: (event) => onEntered(true),
            onExit: (event) => onEntered(false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: transfom,
              child: GestureDetector(
                onTap: () {
                  widget.onTap();
                },
                child: Card(
                  margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              fit: FlexFit.tight,
                              child: Text(
                                widget.title,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: theme.isDarkMode
                                        ? const Color.fromRGBO(202, 196, 208, 1)
                                        : Colors.grey[700]),
                              ),
                            ),
                            for (var i in widget.textContent!)
                              Flexible(
                                fit: FlexFit.tight,
                                child: Text(
                                  i.toString(),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: theme.isDarkMode
                                          ? const Color.fromRGBO(
                                              202, 196, 208, 1)
                                          : Colors.grey[700]),
                                ),
                              ),
                          ])),
                ),
              ),
            ),
          );
  }

  void onEntered(bool isHovered) => setState(() {
        this.isHovered = isHovered;
      });
}

class PIPPopUpMenu extends StatefulWidget {
  final Widget? icon;
  final List<Widget> content;

  const PIPPopUpMenu({super.key, this.icon, required this.content});

  @override
  State<PIPPopUpMenu> createState() => _PIPPopUpMenuState();
}

class _PIPPopUpMenuState extends State<PIPPopUpMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            enabled: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.content,
            ),
          ),
        ];
      },
      icon: widget.icon,
    );
  }
}

class PIPAccountManagmentCard extends StatefulWidget {
  final List<Widget> inputFields;
  final Widget takeActionButton;
  const PIPAccountManagmentCard(
      {super.key, required this.inputFields, required this.takeActionButton});

  @override
  State<PIPAccountManagmentCard> createState() =>
      _PIPAccountManagmentCardState();
}

class _PIPAccountManagmentCardState extends State<PIPAccountManagmentCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: Card(
        elevation: 50,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.inputFields,
              ),
              widget.takeActionButton
            ],
          ),
        ),
      ),
    );
  }
}
