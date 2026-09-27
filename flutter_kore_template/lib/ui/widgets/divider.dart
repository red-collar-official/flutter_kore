import 'package:flutter_kore_template/resources/resources.dart';
import 'package:material_ui/material_ui.dart';

class const UIDivider({super.key, final Color color = UIColors.surfaceDark})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: color);
  }
}
