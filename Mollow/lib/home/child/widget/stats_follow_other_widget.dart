
import 'package:coinw_flutter/bean/follow/follow_trader_entity.dart';
import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/extension/string_extension.dart';
import 'package:module_core/core/utils/common_utils.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_international/generated/l10n.dart';

///其他统计数据
class StatsFollowOtherWidget extends StatelessWidget {
  final FollowTraderEntity? traderEntity;
  const StatsFollowOtherWidget({Key? key, this.traderEntity}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(12),
      decoration: RegularBorder(colorBorder: text_main2.withOpacity(0.1), backgroundColor: Colors.transparent, radius: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            ///其他数据
            child: Text(S.of(context).follow_stats_other_data, style: StMedium(14, text_main),),
          ),
          ///交易频次
          _item(S.of(context).follow_stats_trade_number,  (traderEntity?.tradeFrequency ?? "--")+S.of(context).follow_stats_time_week),
          ///平均持仓时间
          _item(S.of(context).bbs_mine_follow_hold_time,  CommonUtils.secondToString(traderEntity?.holdTime)),
          ///累计跟随人数
          _item(S.of(context).bbs_mine_follow_number_people,  "${traderEntity?.totalFollowerCount ?? 0}"),
          ///交易胜率
          _item(S.of(context).follow_trade_win_rate,  (traderEntity?.winRate ?? "0").percent+"%"),
          ///保证金中位数
          _item(S.of(context).follow_stats_margin_median,  (traderEntity?.marginMedian ?? "--")),
          ///杠杆中位数
          _item(S.of(context).follow_stats_leverage_median,  (traderEntity?.leverageMedian ?? "--")),
          ///总交易次数
          _item(S.of(context).follow_stats_trade_count,  "${traderEntity?.totalTradeCount ?? 0}"),
          ///盈利次数
          _item(S.of(context).follow_stats_profit_count,  "${traderEntity?.profitCount ?? 0}"),
          ///亏损次数
          _item(S.of(context).follow_stats_loss_count,  "${traderEntity?.loseCount ?? 0}"),
          ///平均盈利额
          _item(S.of(context).follow_stats_avg_profit_num,  (traderEntity?.avgProfitNum ?? "--")),
          ///平均亏损额
          _item(S.of(context).follow_stats_avg_loss_num,  (traderEntity?.avgLossNum ?? "--")),
          ///盈亏比
          _item(S.of(context).follow_stats_profit_loss,  traderEntity?.profitAndLossRatio ?? "--"),
          ///跟单分润比
          _item(S.of(context).follow_stats_share_rate,  (traderEntity?.shareRate ?? "0").percent+"%")
        ],
      ),


    );
  }

  _item(String title, String value){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 120,
            child: Text(title, style: StRegular(12, text_main2),),
          ),
          Expanded(
              child: Text(value, style: StMedium(12, text_main,),textAlign: TextAlign.right,),
          )
        ],
      ),
    );
  }


}
