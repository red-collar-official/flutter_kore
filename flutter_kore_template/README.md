# flutter_kore_template

Template project for flutter_kore.

## Folder Structure

### domain

The domain folder contains all business logic and model definitions.

#### apis

This folder contains API declarations. In `apis/base/request.dart`, you can override HTTP authorization logic and error processing. `request_keys.dart` contains constant parameter names for all used requests, for example, query parameters like "limit" or "order".

`test_api.dart` contains an example of API declaration. Create a new API declaration for every backend API, for example, admin or posts API.

After you create a new API declaration, call build runner to rebuild.

#### data

The data folder contains all model classes. For generation of JSON parsing and copy-with methods, we use `dart_mappable`.

#### global

The global folder contains several files:

1) `events.dart` - place definitions of events used in the app here—for example, like events or network change events;
2) `exceptions.dart` - place definitions of exceptions used in the app here—for example, exceptions for AWS Cognito authorization;
3) `flavors.dart` - place flavor definitions here. By default, there are four flavors: dev, stage, prod_test, and prod (prod_test is the prod flavor with logging enabled);
4) `global_app.dart` - main flutter_kore app logic—you can place initialization of app components that need to run on the native splash screen here—for example, initializing Firebase or global error handlers;
5) `scopes.dart` - place your custom flutter_kore scopes here.

#### interactors

The interactors folder contains every interactor used in the app in subfolders. Here we also have the navigation interactor declaration and a predefined authorization interactor where you can place token refresh logic for request authorization.

#### mixins_and_extensions

In this folder, you can place extensions and mixins for business logic components. For example, you can place extensions for the navigation interactor to open common menus or screens that require additional processing.

#### wrappers

Here we can define all wrappers used in the app. For example, a wrapper for haptic feedback mechanisms.

### plugins

This folder contains all custom plugins. For example, here we define a device locale plugin to get the current user locale for localizations.

### resources

Here we can place all resource types used in the app:

1) `app_settings.dart` - place app settings here—for example, default pagination limit or default animation duration;
2) `app_urls.dart` - place app URLs here—for example, the app website link;
3) `colors.dart` - place the color palette used in the app here. Name colors with names from Figma;
4) `contacts.dart` - place app contacts here—for example, service support email;
5) `dimens.dart` - place app dimensions here—default spacings, paddings, etc.;
6) `images.dart` - place paths of PNG, JPG (non-vector) images here;
7) `styles.dart` - place all text styles used in the app here;
8) `svg.dart` - place paths of vector icons here.

### ui

Here we can define all screens and UI components used in the app:

#### components

Here we can place UI components:

For example: cards—cards used in the app.
Here we can also place fields, content scrolls, and utility widgets.

#### widgets

Here we can place all widgets used in the app—for example, custom buttons, dividers, input texts, etc.

#### bottom_sheets

Place bottom sheet definitions here.

#### dialogs

Place dialog definitions here.

#### Predefined Screens

1) `app` - here we define the main app container—here we define Material or Cupertino app and initialize global navigation;
2) `splash` - Flutter splash screen. In `splash_view_model.dart`, you can place initialization logic for the Flutter splash screen—for example, user authorization;
3) `home` - here we define the main screen with a tab bar and initialize inner navigation.

### utilities

Place all utility classes here. For example, validations for email. A log utility is predefined. Also included is secure storage logic for flutter_kore app component cache.

There are also `main.dart` files for every flavor used in the app.

### scripts

Here we place bash scripts used in the app.

In `execute_flutter_command_for_app.sh`, we can define global app constants that we can later use in flavor initialization. Do not place secure API keys in code.
Also included are scripts for build runner rebuilds and a script to create a release artifact for a particular platform.

### assets

Here we place app assets. The `svg` folder is for vector images, and the `images` folder is for JPG and PNG images. The `fonts` folder contains all fonts used in the app. Do not forget to add new folders to `pubspec.yaml`.

### .vscode

Here we place VS Code configuration for flavors defined in the app. You need to add constants from `execute_flutter_command_for_app.sh` here.