cd ./packages/umvvm
flutter test --coverage
lcov --remove coverage/lcov.info "lib/ui/widgets/*" "lib/domain/data/*" "lib/resources/*" "lib/plugins/*" "lib/ui/**/components/*" "lib/ui/**/pages/*" "lib/ui/dialogs/*" "lib/domain/global/*" "lib/domain/interactors/navigation/*" "lib/ui/bottom_sheets/*" "lib/ui/**/utility/*" "lib/**/*.g.dart" "lib/**/*_state.dart" "lib/**/*_view.dart" -o coverage/fixed_lcov.info
genhtml coverage/fixed_lcov.info -o coverage/html