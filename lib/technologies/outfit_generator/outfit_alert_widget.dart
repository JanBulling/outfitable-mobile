import 'package:flutter/material.dart';

import '../../models/clothing/outfit.dart';

class OutfitAlertWidge extends StatelessWidget {
  final Outfit outfit;

  const OutfitAlertWidge(this.outfit, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return outfit.message == null
        ? Container()
        : Container(
            width: double.infinity,
            height: 55,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: outfit.backgroundColor,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    outfit.message!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
                outfit.icon == null ? Container() : Icon(outfit.icon!, color: Colors.white),
              ],
            ),
          );
  }
}
