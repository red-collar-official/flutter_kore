import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_kore/flutter_kore.dart';

import '../helpers/test_builders.dart';
import '../mocks/test_interactors.dart';

class FormTestView extends StatefulWidget {
  const FormTestView({super.key, this.hasErrors = false, this.submitCompleter});

  final bool hasErrors;
  final Completer<void>? submitCompleter;

  @override
  State<FormTestView> createState() {
    return FormTestViewWidgetState();
  }
}

class FormTestViewWidgetState extends BaseIndependentView<FormTestView>
    with FormViewMixin {
  final emailKey = GlobalKey();

  var submitCount = 0;
  bool? dependenciesReadyOnLaunch;

  @override
  DependentKoreInstanceConfiguration get configuration =>
      const DependentKoreInstanceConfiguration(
        dependencies: [Connector(type: TestInteractor1, input: 2)],
      );

  late final testInteractor1 = useLocalInstance<TestInteractor1>();

  @override
  bool get pauseWhenViewBecomeInvisible => false;

  @override
  void onLaunch() {
    super.onLaunch();

    dependenciesReadyOnLaunch = testInteractor1.isInitialized;
  }

  @override
  ValidatorsMap get validators => {
    emailKey: () {
      return Future.value(
        widget.hasErrors ? const ErrorFieldState() : const ValidFieldState(),
      );
    },
  };

  @override
  Future<void> onSubmit() async {
    submitCount++;

    await widget.submitCompleter?.future;
  }

  @override
  Widget buildView(BuildContext context) {
    return SizedBox(key: emailKey);
  }
}

void main() {
  group('FormViewMixin tests', () {
    setUp(() async {
      KoreApp.isInTestMode = true;

      addTestBuilders(InstanceCollection.instance);
    });

    testWidgets('FormViewMixin prefills fields on launch test', (tester) async {
      final viewKey = GlobalKey<FormTestViewWidgetState>();

      await tester.pumpWidget(FormTestView(key: viewKey));

      final state = viewKey.currentState!;

      expect(state.dependenciesReadyOnLaunch, true);
      expect(
        state.currentFieldState(state.emailKey).runtimeType,
        IgnoredFieldState,
      );
    });

    testWidgets('FormViewMixin executeSubmitAction test', (tester) async {
      final viewKey = GlobalKey<FormTestViewWidgetState>();

      await tester.pumpWidget(FormTestView(key: viewKey));

      final state = viewKey.currentState!;

      await state.executeSubmitAction();

      expect(state.submitCount, 1);
      expect(state.isFormDisabled, false);
      expect(
        state.currentFieldState(state.emailKey).runtimeType,
        ValidFieldState,
      );
    });

    testWidgets('FormViewMixin executeSubmitAction with errors test', (
      tester,
    ) async {
      final viewKey = GlobalKey<FormTestViewWidgetState>();

      await tester.pumpWidget(FormTestView(key: viewKey, hasErrors: true));

      final state = viewKey.currentState!;

      await state.executeSubmitAction();

      expect(state.submitCount, 0);
      expect(
        state.currentFieldState(state.emailKey).runtimeType,
        ErrorFieldState,
      );
    });

    testWidgets('FormViewMixin dispose while submitting test', (tester) async {
      final viewKey = GlobalKey<FormTestViewWidgetState>();
      final submitCompleter = Completer<void>();

      await tester.pumpWidget(
        FormTestView(key: viewKey, submitCompleter: submitCompleter),
      );

      final state = viewKey.currentState!;
      final submitFuture = state.executeSubmitAction();

      await tester.pump();

      expect(state.isFormDisabled, true);

      await tester.pumpWidget(const SizedBox());

      expect(state.isDisposed, true);

      submitCompleter.complete();

      await submitFuture;

      expect(state.disable.isDisposed, true);

      state.fieldStates.forEach((key, value) {
        expect(value.isDisposed, true);
      });
    });
  });
}
