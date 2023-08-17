import 'package:coinw_flutter/bean/follow/follow_trader_entity.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/extension/string_extension.dart';
import 'package:module_core/core/utils/common_utils.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_international/generated/l10n.dart';

///图表统计
///
class OverViewStatsWidget extends StatelessWidget {
  const OverViewStatsWidget({Key? key, this.traderEntity}) : super(key: key);
  final FollowTraderEntity? traderEntity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15,right: 15, bottom: 24, top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 3,
              child: _getStatsWidget(
                ///总收益率
                  S.of(context).follow_over_total_profit_rate, "${(traderEntity?.totalProfitRate ?? "0").percent}%", CommonUtils.downOrUpColor(traderEntity?.profitRate), alignment: CrossAxisAlignment.start, textAlign: TextAlign.start)),
          Expanded(
            flex: 4,
              child: _getStatsWidget(
                ///总收益
                  S.of(context).bbs_mine_follow_total_revenue, "\$${(traderEntity?.profitAmount ?? "0").fixNumberTwoDecimal}", CommonUtils.downOrUpColor(traderEntity?.profitAmount))),
          Expanded(
              flex: 3,
              ///胜率
              child: _getStatsWidget(S.of(context).follow_over_total_profit_win, "${(traderEntity?.winRate ?? "0").percent}%", text_main)),
          Expanded(
            flex: 4,
              ///跟单规模
              child: _getStatsWidget(
                  S.of(context).follow_over_total_balance, "\$${(traderEntity?.totalFollowerBalance ?? "0").fixNumberTwoDecimal}", text_main, alignment: CrossAxisAlignment.end, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  _getStatsWidget(String title, String value, Color color, {CrossAxisAlignment alignment = CrossAxisAlignment.center, TextAlign textAlign = TextAlign.center}){
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(value, style: StBold(18, color) , textAlign: textAlign,),
        const SizedBox(height: 3,),
        Text(title, style: StRegular(14, text_main2), textAlign: textAlign, ),
      ],
    );
  }



}
