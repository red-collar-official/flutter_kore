// ignore: depend_on_referenced_packages
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'generators.dart';

Builder generateMainApp(BuilderOptions options) => PartBuilder(
      [MainAppGenerator()],
       '.mvvm.dart',
      allowSyntaxErrors: true,
    );
Builder generateMainApi(BuilderOptions options) => PartBuilder(
      [MainApiGenerator()],
      '.api.dart',
      allowSyntaxErrors: true,
    );
Builder generateNavigation(BuilderOptions options) => PartBuilder(
      [MainNavigationGenerator()],
      '.navigation.dart',
      allowSyntaxErrors: true,
    );
Builder generateNavigationInteractor(BuilderOptions options) => PartBuilder(
      [MainNavigationInteractorGenerator()],
      '.app_navigation.dart',
      allowSyntaxErrors: true,
    );
