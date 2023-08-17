

import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_core/core/utils/other/comma_text_input_formatter.dart';

class FollowTextfiwldWidget extends StatelessWidget {
  FollowTextfiwldWidget(this.controller, {Key? key, this.keyboardType, this.hint, this.suffix, this.focusNode, this.obscureText = false}) : super(key: key);

  TextEditingController controller;
  TextInputType? keyboardType;
  String? hint;
  Widget? suffix;
  FocusNode? focusNode;
  bool obscureText;
  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: RegularRadius(color: text_main2.withOpacity(0.1), radius: 6.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: StMedium(14, text_main),
              decoration:  customTextFieldDecoration(hint: hint),
              keyboardType: keyboardType,
              focusNode: focusNode,
              obscureText: obscureText,
              inputFormatters: [
                CommaTextInputFormatter()
              ],
            ),
          ),
          suffix != null ? suffix! : Container()
        ],
      ),
    );
  }
}
