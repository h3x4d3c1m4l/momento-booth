import 'package:fluent_ui/fluent_ui.dart';

class CenteredProgressRing extends StatelessWidget {

  final double? progressPercentage;
  final String? text;

  const CenteredProgressRing({super.key, this.progressPercentage, this.text});

  @override
  Widget build(BuildContext context) {
    switch ((progressPercentage, text)) {
      case (null, null):
        return const Center(
          child: ProgressRing(),
        );
      case (!= null, null):
        return Center(
          child: ProgressRing(value: progressPercentage),
        );
      default:
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ProgressRing(
                value: progressPercentage,
              ),
            ),
            Text(text!, textAlign: TextAlign.center),
          ],
        );
    }
  }

}
