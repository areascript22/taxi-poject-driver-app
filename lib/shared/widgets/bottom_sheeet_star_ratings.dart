import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class StarRatingsBottomSheet extends StatelessWidget {
  final String passengerId;
  StarRatingsBottomSheet({
    super.key,
    required this.passengerId,
  });
  final textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final sharedProvider = Provider.of<SharedProvider>(context);

    return Container(
      padding: const EdgeInsets.all(20.0),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.only(
          left: 15,
          right: 15,
          top: 10,
          bottom: keyboardHeight > 0
              ? keyboardHeight
              : 10, // Adjust bottom padding based on keyboard
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text(
                'Califique su viaje',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) async {
                  await sharedProvider.saveRatingAndComments(
                    rating,
                    passengerId,
                    textController.text,
                    context,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
              TextField(
                controller: textController,
                keyboardType: TextInputType.multiline,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Omitir',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showStarRatingsBottomSheet(BuildContext context, String passengerId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StarRatingsBottomSheet(
        passengerId: passengerId,
      );
    },
  );
}
