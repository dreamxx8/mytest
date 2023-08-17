import 'package:coinw_flutter/bean/follow/follow_setting_entity.dart';
import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:coinw_flutter/modules/common/them/global_color_manager.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/extension/string_extension.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_core/core/utils/other/comma_text_input_formatter.dart';
import 'package:module_core/core/utils/string_utils.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/big_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:module_core/widget/custom_text_field.dart';
import 'package:module_core/widget/custom_text_field_out_line.dart';
import 'package:module_follow/home/follow_settings/widget/follow_textfield_widget.dart';

///风险控制弹窗
class FollowSelectRiskWidget extends StatefulWidget {
  FollowSelectRiskWidget({Key? key, this.followSetting, this.callBack})
      : super(key: key);
  ValueChanged<FollowSettingEntity>? callBack;
  FollowSettingEntity? followSetting;

  @override
  State<FollowSelectRiskWidget> createState() => _FollowSelectRiskWidgetState();
}

class _FollowSelectRiskWidgetState extends State<FollowSelectRiskWidget> {
  final TextEditingController _profitController = TextEditingController();
  final TextEditingController _lossController = TextEditingController();
  final TextEditingController _marginController = TextEditingController();
  List<FocusNode> focus = [FocusNode(), FocusNode(), FocusNode()];

  @override
  void initState() {
    super.initState();
    if (StringUtils.isNotBlank(widget.followSetting?.stopProfitRate)) {
      _profitController.text = widget.followSetting!.stopProfitRate!.percent;
    }
    if (StringUtils.isNotBlank(widget.followSetting?.stopLossRate)) {
      _lossController.text = widget.followSetting!.stopLossRate!.percent;
    }
    _marginController.text = widget.followSetting?.maxPosition ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        for (var element in focus) {
          element.unfocus();
        }
      },
      child: Container(
        decoration: BoxDecoration(
            color: globalColorManager.scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(),
            const SizedBox(
              height: 15,
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 10, top: 24),
              child: Text(
                /// 止盈比例
                S.of(context).follow_setting_tp_rate,
                style: StRegular(14, text_main2),
              ),
            ),
            FollowTextfiwldWidget(
                _profitController,
                focusNode: focus[0],
                suffix: Container(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text(
                      "%",
                      style: StRegular(14, text_main),
                    )),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 10, top: 24),
              child: Text(
                /// 止损比例
                S.of(context).follow_setting_sl_rate,
                style: StRegular(14, text_main2),
              ),
            ),
            FollowTextfiwldWidget(
                _lossController,
                focusNode: focus[1],
                suffix: Container(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text(
                      "%",
                      style: StRegular(14, text_main),
                    )),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
            Container(
              padding: const EdgeInsets.only(bottom: 10, top: 24),
              child: Text(
                // 最大持仓金额
                S.of(context).follow_setting_max_hold_amount,
                style: StRegular(14, text_main2),
              ),
            ),
            FollowTextfiwldWidget(
                _marginController,
                focusNode: focus[2],
                suffix: Container(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text(
                      "USDT",
                      style: StRegular(14, text_main),
                    )),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
            const SizedBox(
              height: 10,
            ),
            Text(
              S.of(context).follow_setting_max_hold_amount_tips,
              style: StRegular(12, text_main2),
            ),
            const SizedBox(
              height: 20,
            ),
            BigButton(
              text: S.of(context).common_confirm,
              onPressed: () {
                Navigator.pop(context);
                if (widget.callBack != null) {
                  FollowSettingEntity setting = FollowSettingEntity();
                  setting.stopLossRate =  getDividPercent(_lossController.text);
                  setting.stopProfitRate = getDividPercent(_profitController.text);
                  setting.maxPosition = _marginController.text;
                  widget.callBack!(setting);
                }
              },
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  String getDividPercent(String value){
    if(value.isEmpty){
      return value;
    }
    double percent = StringUtils.doubleParse(value);
    return (percent/100.0).toString();
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          S.of(context).follow_risk_manager,
          style: StMedium(14, text_main),
        ),
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 30, top: 5,bottom: 5),
            child: Image.asset(
              ImageSourceConst.LIVE_ALERT_CLOSE,
              width: 14,
              height: 14,
              color: globalColorManager.imageThemColor(),
            ),
          ),
        )
      ],
    );
  }

  Widget _items(String value, bool isSelect) {
    double width = (ScreenUtil().screenWidth - 54) / 3.0;
    return InkWell(
      onTap: () {},
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: RegularBorder(
            colorBorder: isSelect ? colorTheme : text_main2.withOpacity(0.2),
            radius: 4,
            backgroundColor: isSelect ? colorTheme : transparent),
        child: Center(
            child: Text(
          value,
          style: StRegular(14, isSelect ? white : text_main),
        )),
      ),
    );
  }
}
