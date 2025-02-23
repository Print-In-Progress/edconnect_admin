import 'package:flutter/material.dart';

errorMessage(BuildContext context, String? messageContent,
    {bool closeIcon = true, int durationMilliseconds = 5000}) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: Duration(milliseconds: durationMilliseconds),
    content: Container(
      decoration: BoxDecoration(
          color: const Color.fromRGBO(244, 67, 54, 1),
          borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(),
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
              ),
              const SizedBox(
                width: 4,
              ),
              Flexible(
                  child: Text(
                messageContent!,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              )),
              closeIcon
                  ? IconButton(
                      color: Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                      icon: const Icon(Icons.close))
                  : const SizedBox.shrink(),
            ],
          )),
    ),
    backgroundColor: Colors.transparent,
    elevation: 1000,
    behavior: SnackBarBehavior.floating,
  ));
}

successMessage(BuildContext context, String messageContent,
    {bool closeIcon = true, int durationMilliseconds = 5000}) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: Duration(milliseconds: durationMilliseconds),
    content: Container(
      decoration: BoxDecoration(
          color: const Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(),
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
              ),
              const SizedBox(
                width: 4,
              ),
              Flexible(
                  child: Text(
                messageContent,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              )),
              closeIcon
                  ? IconButton(
                      color: Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                      icon: const Icon(Icons.close))
                  : const SizedBox.shrink(),
            ],
          )),
    ),
    backgroundColor: Colors.transparent,
    elevation: 1000,
    behavior: SnackBarBehavior.floating,
  ));
}

warningMessage(BuildContext context, String messageContent,
    {bool closeIcon = true, int durationMilliseconds = 5000}) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: Duration(milliseconds: durationMilliseconds),
    content: Container(
      decoration: BoxDecoration(
          color: const Color.fromRGBO(251, 192, 45, 1),
          borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(),
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_outlined,
                color: Colors.white,
              ),
              const SizedBox(
                width: 4,
              ),
              Flexible(
                  child: Text(
                messageContent,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              )),
              closeIcon
                  ? IconButton(
                      color: Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                      icon: const Icon(Icons.close))
                  : const SizedBox.shrink(),
            ],
          )),
    ),
    backgroundColor: Colors.transparent,
    elevation: 1000,
    behavior: SnackBarBehavior.floating,
  ));
}
