import 'package:flutter/material.dart';
import 'package:ecard_app/modals/card_modal.dart';
import 'card_display_widget.dart';

class CardListWidget extends StatelessWidget {
  final List<CustomCard> cards;
  final Function(CustomCard) onCardTap;

  const CardListWidget({
    Key? key,
    required this.cards,
    required this.onCardTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No cards found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the + button to create a new card',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: cards.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => onCardTap(cards[index]),
          child: CardDisplayWidget(card: cards[index]),
        );
      },
    );
  }
}
