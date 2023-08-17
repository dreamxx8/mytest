import 'package:flutter/cupertino.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/utils/lc_styles.dart';

class PositionValueWidget extends StatelessWidget {
  String upValue;
  String downValue;
  CrossAxisAlignment crossAxisAlignment;
  TextStyle? upStyle;
  TextStyle? downStyle;
  /// 是否上下颠倒
  bool upsideDown;

  PositionValueWidget(this.upValue, this.downValue,
      {Key? key,
      this.upStyle,
      this.downStyle,
      this.crossAxisAlignment = CrossAxisAlignment.center,
      this.upsideDown = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(upsideDown){
      return Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(downValue, style: downStyle ?? StRegular(10, text_main2)),
          const SizedBox(
            height: 4,
          ),
          Text(upValue, style: upStyle ?? StMedium(13, text_main)),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(upValue, style: upStyle ?? StMedium(13, text_main)),
          const SizedBox(
            height: 4,
          ),
          Text(downValue, style: downStyle ?? StRegular(10, text_main2)),
        ],
      );
    }

  }
}
