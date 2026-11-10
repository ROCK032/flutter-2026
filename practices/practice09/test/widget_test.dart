import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:practice9/main.dart';
import 'package:practice9/models/book.dart';
import 'package:practice9/models/cart.dart';

Future<void> pumpShop(WidgetTester tester, Cart cart) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ChangeNotifierProvider<Cart>.value(value: cart, child: const Shell()),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Поиск учитывает название, автора и пустой результат', (
    tester,
  ) async {
    final cart = Cart();
    await pumpShop(tester, cart);

    await tester.enterText(find.byType(TextField), 'NAVIGATOR');
    await tester.pumpAndSettle();
    expect(find.text(books[3].title), findsOneWidget);
    expect(find.text(books[0].title), findsNothing);

    await tester.enterText(find.byType(TextField), 'omarova');
    await tester.pumpAndSettle();
    expect(find.text(books[4].title), findsOneWidget);
    expect(find.text(books[3].title), findsNothing);

    await tester.enterText(find.byType(TextField), 'no-such-book');
    await tester.pumpAndSettle();
    expect(find.text('Книги не найдены'), findsOneWidget);
    expect(cart.count, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Успешное добавление показывает один SnackBar, повтор отклоняется',
    (tester) async {
      final cart = Cart();
      await pumpShop(tester, cart);

      final button = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Добавить в корзину').first,
      );
      button.onPressed!();
      button.onPressed!();
      await tester.pumpAndSettle();

      expect(cart.count, 1);
      expect(cart.qtyOf(books[0]), 1);
      expect(find.text('Добавлен'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.text('Добавлен'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Очистка сохраняет корзину при отмене и очищает при подтверждении',
    (tester) async {
      final cart = Cart();
      cart.add(books[0]);
      cart.add(books[1]);
      cart.increment(books[0]);
      await pumpShop(tester, cart);

      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Очистить корзину'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();
      expect(cart.count, 2);
      expect(cart.total, 11500);

      await tester.tap(find.byTooltip('Очистить корзину'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Очистить'));
      await tester.pumpAndSettle();

      expect(cart.items, isEmpty);
      expect(cart.count, 0);
      expect(cart.total, 0);
      expect(find.text('0 ₸'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Закрытие диалога кнопкой назад не очищает корзину', (
    tester,
  ) async {
    final cart = Cart();
    cart.add(books[0]);
    await pumpShop(tester, cart);

    await tester.tap(find.byIcon(Icons.shopping_cart));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Очистить корзину'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(cart.count, 1);
    expect(cart.total, 4200);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Поиск сохраняется при навигации, количество и удаление обновляют UI',
    (tester) async {
      final cart = Cart();
      await pumpShop(tester, cart);

      await tester.enterText(find.byType(TextField), 'null safety');
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Добавить в корзину'),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(cart.count, 1);
      expect(cart.qtyOf(books[1]), 2);
      expect(find.text('×2'), findsOneWidget);
      expect(find.text('6200 ₸'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      final search = tester.widget<EditableText>(find.byType(EditableText));
      expect(search.controller.text, 'null safety');
      expect(find.text(books[1].title), findsOneWidget);
      expect(find.text(books[0].title), findsNothing);

      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(cart.count, 0);
      expect(
        find.widgetWithText(OutlinedButton, 'Добавить в корзину'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
