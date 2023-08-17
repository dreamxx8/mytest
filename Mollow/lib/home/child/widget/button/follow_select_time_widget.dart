
import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:coinw_flutter/modules/common/them/global_color_manager.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/utils/lc_styles.dart';

class FollowSelectTimeWidget extends StatelessWidget {
  final String title;
  const FollowSelectTimeWidget(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
      decoration: RegularBorder(colorBorder: line_main, radius: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: StRegular(14, text_main),),
          const SizedBox(width: 6,),
          Image.asset(ImageSourceConst.FOLLOW_DOWN_ARROW, width: 8, height: 8, color: globalColorManager.imageThemColor(),)
        ],
      ),
    );
  }
}
