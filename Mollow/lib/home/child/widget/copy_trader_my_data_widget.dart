

import 'package:coinw_flutter/bean/follow/follow_leader_profit_entity.dart';
import 'package:coinw_flutter/bean/follow/follow_my_profit_entity.dart';
import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:coinw_flutter/modules/common/them/global_color_manager.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/extension/string_extension.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_follow/common/follow_action_manager.dart';

class CopyTraderMyDataWidget extends StatelessWidget {
  const CopyTraderMyDataWidget({Key? key, this.profitEntity}) : super(key: key);
  final FollowLeaderProfitEntity? profitEntity;

  @override
  Widget build(BuildContext context) {
    return _dataWidget(context);
  }

  _dataWidget(context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 9),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: InkWell(
                    onTap: (){
                      FollowActionManager.pushLeaderTodayProfit(context);
                    },
                    child: Container(
                        padding: const EdgeInsets.all(12),
                    decoration:
                        CustomShadow(color: globalColorManager.cardColor),

                    ///今日预估分润(USDT) 利润分成比例：
                    child: _dataItem(
                        S.of(context).follow_trader_profit_today,
                        profitEntity?.todayProfit ?? "0",
                        "${S.of(context).follow_trader_profit_rate}${(profitEntity?.shareRate ?? "0").percent} %")),
                  )),
             const SizedBox(
                width: 12,
              ),
              Expanded(
                  child: InkWell(
                    onTap: (){
                      FollowActionManager.pushLeaderTotalProfit(context);
                    },
                    child: Container(
                        padding: const EdgeInsets.all(12),
                      decoration:
                          CustomShadow(color: globalColorManager.cardColor),

                      ///累计分润(USDT)
                      child: _dataItem(S.of(context).follow_trader_profit_total,
                          profitEntity?.accumulatedProfit ?? "0", "")),
                  ),)
            ],
          ),
        ],
      ),
    );
  }

  Widget _dataItem(String title, String value, String subValue){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: StRegular(12, text_main),)),
            const SizedBox(width: 5,),
            Image.asset(ImageSourceConst.ICON_ARROW_GRAY_RIGHT,width: 16,height: 16,)
          ],
        ),
        const SizedBox(height: 6,),
        Text(value, style: StBold(18, text_main),),
        const SizedBox(height: 6,),
        Text(subValue, style: StRegular(11, text_main2),),
      ],
    );
  }
}
