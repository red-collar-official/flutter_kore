# Utility

Package contains small utility classes.

The first two are just sealed classes for network requests and field validation:

```dart
var statefulData = LoadingData();

statefulData.unwrap(); // throws error

var statefulData = ErrorData(error: 'test error');

statefulData.unwrap(); // throws error

var statefulData = SuccessData(result: 1);

statefulData.unwrap(); // valid

```

Stateful data can be unwrapped to get result value if it is present.

And here is sealed class for field validation: it contains valid, error and ignored state.

```dart
sealed class FieldValidationState {}

class ValidFieldState extends FieldValidationState {}

class IgnoredFieldState extends FieldValidationState {}

class ErrorFieldState extends FieldValidationState {
  final String? error;

  ErrorFieldState({this.error});
}
```

This values used by <b>FormViewModelMixin</b>. More info about <b>FormViewModelMixin</b> below.

There is also <b>ResultState</b> class to hold function execution result:

```dart
ResultState.success(result: 'test');
ResultState.check(error: result.serverSideException);
ResultState.error(
  error: StandartEmptyException(),
  messageToDisplay: app.localization.authorization('login_error'),
);
```

You also can unwrap error with specific type with <b>unwrapError</b> method.

```dart
Future<ResultState> confirmEmail(String link) async {
  final uri = Uri.parse(link);

  // ...

  if (error) {
    return ResultState.error(
      error: result.serverSideException!,
      messageToDisplay: app.localization.global('something_went_wrong'),
    );
  }

  return ResultState.success();
}

final confirmationResult = await confirmEmail(link);

final error = confirmationResult.unwrapError<ServerSideException>();
```

There are also two helper mixins that you can apply to your view models or instances.

#### UseDisposableMixin

<b>UseDisposableMixin</b> can be applied to any <b>MvvmInstance</b>.

It provides methods to initialize disposable objects like <b>TextEditingController</b>.
They will be disposed authomatically when instance is disposed.

Here is full list of supported initializers:

```dart
TextEditingController useTextEditingController({String? text});
ScrollController useScrollController();
Debouncer useDebouncer({required Duration delay});
```

Here is usecase example:

```dart
class SupportViewModel extends NavigationViewModel<SupportView, SupportViewState>
    with UseDisposableViewModelMixin {
  late final descriptionController = useTextEditingController();
  late final emailController = useTextEditingController();
}
```

#### FormViewModelMixin

FormViewModelMixin can be applied only to view models.

It helps to manage form views where you need to validate user input.

It contains map of validators (keys of map are <b>GlobalKey</b> so form can automatically scroll to error field if user trying to submit form) and <b>executeSubmitAction</b> method to call form validation process. You need to pass theese keys as parameters to your field widgets. Field widget implementation is up do developer.

Validators can be manually updated:

```dart
updateFieldState(
  passwordKey,
  ErrorFieldState(error: result.messageToDisplay),
);
```

You also can manually call validator for field and reset field with corresponding methods:

```dart
validateField(passwordKey);

resetField(passwordKey);
```

You can also override <b>additionalCheck</b> method if you need to check some additional fields. It will be run after validators check.

Here you can see the example:

```dart
class SupportViewModel
    extends NavigationViewModel<SupportView, SupportViewState>
    with FormViewModelMixin, UseDisposableViewModelMixin {
  late final descriptionController = useTextEditingController();
  late final emailController = useTextEditingController();

  final descriptionKey = GlobalKey();
  final emailKey = GlobalKey();

  @override
  Future<bool> additionalCheck() async {
    updateState(state.copyWith(
      platformPolicyIgnored: !state.platformPolicyApproved,
    ));

    return state.platformPolicyApproved;
  }

  @override
  Future<void> submit() async {
    await sendSupportRequest();
  }

  @override
  ValidatorsMap get validators => {
        descriptionKey: () {
          return Future.value(validateSupportTicket(descriptionController));
        },
        emailKey: () {
          return Future.value(validateEmail(emailController, []));
        },
      };

  @override
  SupportViewState get initialState => SupportViewState();
}
```

After initialization you can use streams of validation states for fields that you specified:

```dart
WhatHappenedField(
  key: viewModel.descriptionKey,
  controller: viewModel.descriptionController,
  stateStream:
      viewModel.fieldStateStream(viewModel.descriptionKey),
  initialState: () =>
      viewModel.currentFieldState(viewModel.descriptionKey),
  validator: () =>
      viewModel.validatorForKey(viewModel.descriptionKey),
),

Button(
  onTap: () async {
    await viewModel.executeSubmitAction();
  },
);
```
