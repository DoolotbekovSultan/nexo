import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_example/main.dart';

void main() {
  testWidgets('shows failure demo', (tester) async {
    await tester.pumpWidget(const NexoExampleApp());
    expect(find.text('nexo example'), findsWidgets);
    expect(find.textContaining('интернет'), findsWidgets);
  });
}
