import 'package:buttons_tabbar_plus/buttons_tabbar_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _tabs = <Widget>[
  Tab(text: 'First', icon: Icon(Icons.home)),
  Tab(text: 'Second', icon: Icon(Icons.settings)),
];

Widget _app({TabController? controller, ValueChanged<int>? onTap}) {
  return MaterialApp(
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
    home: Scaffold(
      body: DefaultTabController(
        length: _tabs.length,
        child: Column(
          children: [
            ButtonsTabBar(controller: controller, onTap: onTap, tabs: _tabs),
            Expanded(
              child: TabBarView(
                controller: controller,
                children: const [
                  Center(child: Text('First page')),
                  Center(child: Text('Second page')),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('tapping a material_ui tab selects its page and calls onTap', (
    tester,
  ) async {
    final taps = <int>[];
    await tester.pumpWidget(_app(onTap: taps.add));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Second'));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(ButtonsTabBar));
    expect(DefaultTabController.of(context).index, 1);
    expect(find.text('Second page').hitTestable(), findsOneWidget);
    expect(taps, [1]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('swiping material_ui pages updates the selected button', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.fling(find.byType(TabBarView), const Offset(-600, 0), 1000);
    await tester.pumpAndSettle();

    final selectedLabel = tester.widget<Text>(find.text('Second'));
    final unselectedLabel = tester.widget<Text>(find.text('First'));
    expect(selectedLabel.style?.color, Colors.white);
    expect(unselectedLabel.style?.color, Colors.black);
    expect(tester.takeException(), isNull);
  });

  testWidgets('accepts an explicit material_ui controller and initial index', (
    tester,
  ) async {
    final controller = TabController(
      length: _tabs.length,
      initialIndex: 1,
      vsync: tester,
    );
    await tester.pumpWidget(_app(controller: controller));
    await tester.pumpAndSettle();
    expect(find.text('Second page').hitTestable(), findsOneWidget);
    expect(tester.widget<Text>(find.text('Second')).style?.color, Colors.white);

    controller.animateTo(0);
    await tester.pumpAndSettle();
    expect(find.text('First page').hitTestable(), findsOneWidget);
    expect(tester.widget<Text>(find.text('First')).style?.color, Colors.white);

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'uses the standalone Material theme for the selected background',
    (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(ButtonsTabBar));
      final inks = tester.widgetList<Ink>(
        find.descendant(
          of: find.byType(ButtonsTabBar),
          matching: find.byType(Ink),
        ),
      );
      expect(
        (inks.first.decoration as BoxDecoration).color,
        Theme.of(context).colorScheme.secondary,
      );
      expect((inks.last.decoration as BoxDecoration).color, Colors.grey[300]);
      expect(tester.takeException(), isNull);
    },
  );
}
