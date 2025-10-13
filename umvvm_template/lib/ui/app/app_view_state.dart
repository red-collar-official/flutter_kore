import 'package:dart_mappable/dart_mappable.dart';

part 'app_view_state.mapper.dart';

@MappableClass()
class AppViewState with AppViewStateMappable {
  const AppViewState({
    this.artWorkBarVisibile = false,
  });

  final bool artWorkBarVisibile;
}
