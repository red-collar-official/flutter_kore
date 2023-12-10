dart test --coverage=coverage
dart pub global run coverage:format_coverage --check-ignore --packages=.dart_tool/package_config.json --report-on=lib --lcov -o "coverage/lcov.info" -i ./coverage
genhtml coverage/lcov.info -o coverage/html