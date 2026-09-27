import 'package:material_ui/material_ui.dart';

class const UIProgressDialog({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Material(child: Center(child: CircularProgressIndicator()));
  }
}
