import 'package:firstlook/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:firstlook/features/onboarding/presentation/pages/review_onboarding_page.dart';
import 'package:firstlook/features/onboarding/presentation/pages/reward_onboarding_page.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/widgets/firstlook_logo.dart';
import 'package:firstlook/widgets/firstlook_startup_experience.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('drop rank assets decode without errors',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: <Widget>[
              for (final String path in <String>[
                'assets/icons/drop-rank-1.png',
                'assets/icons/drop-rank-2.png',
                'assets/icons/drop-rank-3.png',
              ])
                Image.asset(
                  path,
                  width: 56,
                  height: 56,
                  filterQuality: FilterQuality.high,
                ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark logo keeps its blend inside the image paint',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: const Scaffold(body: FirstLookLogo()),
      ),
    );

    expect(find.byType(ColorFiltered), findsNothing);

    final Image logo = tester.widget<Image>(find.byType(Image));
    expect(logo.color, const Color(0x52FFFFFF));
    expect(logo.colorBlendMode, BlendMode.srcATop);
  });

  testWidgets('startup waits for app readiness before revealing content',
      (WidgetTester tester) async {
    bool isAppReady = false;
    late StateSetter updateHost;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          updateHost = setState;

          return MaterialApp(
            builder: (BuildContext context, Widget? child) {
              return FirstLookStartupExperience(
                isAppReady: isAppReady,
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const Scaffold(body: Text('HOME')),
          );
        },
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pump();

    expect(find.text('FIRSTLOOK'), findsOneWidget);
    expect(find.text('HOME'), findsOneWidget);

    updateHost(() => isAppReady = true);
    await tester.pump();
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.text('FIRSTLOOK'), findsNothing);
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('onboarding fits standard and compact phone viewports',
      (WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    Future<void> pumpOnboarding(Size size, Widget home) async {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: const Locale('tr'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: home,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pumpOnboarding(const Size(411, 914), const OnboardingPage());

    expect(find.text('Uygulamaları Keşfet'), findsOneWidget);
    expect(find.text('Hemen Başla'), findsOneWidget);
    expect(find.text('Geç'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await pumpOnboarding(const Size(360, 720), const OnboardingPage());

    expect(find.text('Uygulamaları Keşfet'), findsOneWidget);
    expect(find.text('Hemen Başla'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await pumpOnboarding(
      const Size(411, 914),
      const ReviewOnboardingPage(),
    );

    expect(find.text('Deneyimini Paylaş'), findsNWidgets(2));
    expect(find.text('Güvenilir puanlama'), findsOneWidget);
    expect(find.bySemanticsLabel('2 / 3'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await pumpOnboarding(
      const Size(360, 720),
      const ReviewOnboardingPage(),
    );

    expect(find.text('Deneyimini Paylaş'), findsNWidgets(2));
    expect(find.text('Topluluk deneyimi'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await pumpOnboarding(
      const Size(411, 914),
      const RewardOnboardingPage(),
    );

    expect(find.text('Uygulamanı Yayınla, Zirveye Çık'), findsOneWidget);
    expect(find.text('Uygulamanı Gönder'), findsOneWidget);
    expect(find.bySemanticsLabel('3 / 3'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await pumpOnboarding(
      const Size(360, 720),
      const RewardOnboardingPage(),
    );

    expect(find.text('Uygulamanı Yayınla, Zirveye Çık'), findsOneWidget);
    expect(find.text('Liderlikte Yüksel'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
