
import 'package:coinw_flutter/bean/follow/follow_trader_entity.dart';
import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/extension/string_extension.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/custom_cached_network_image.dart';
import 'package:module_follow/home/widget/sub_item/position_value_widget.dart';
import 'package:module_core/core/utils/common_utils.dart';
import 'package:sprintf/sprintf.dart';

class FollowListItem extends StatelessWidget {

  final FollowTraderEntity traderEntity;

  const FollowListItem({Key? key, required this.traderEntity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: RegularRadius(color: text_main2.withOpacity(0.05), radius: 12.0),
      child: Column(
        children: [
          _headerWidget(context),
          const SizedBox(height: 20,),
          _dataWidget(context)
        ],
      ),
    );
  }

  _dataWidget(context){
    return Row(
      children: [
        ///总收益率
        Expanded(child: PositionValueWidget("${(traderEntity.totalProfitRate ?? "").percent} %",S.of(context).follow_over_total_profit_rate, upStyle: StMedium(18, CommonUtils.downOrUpColor(traderEntity.totalProfitRate)), downStyle: StRegular(12, text_main2),crossAxisAlignment: CrossAxisAlignment.start,)),
        ///总收益
        Expanded(child: PositionValueWidget("\$${(traderEntity.profitAmount??"").fixNumberTwoDecimal}",S.of(context).bbs_mine_follow_total_revenue, upStyle: StMedium(18, CommonUtils.downOrUpColor(traderEntity.profitAmount)), downStyle: StRegular(12, text_main2),)),
        ///跟单资金
        Expanded(child: PositionValueWidget("\$${(traderEntity.totalFollowerBalance??"").fixNumberTwoDecimal}",S.of(context).follow_fund, upStyle: StMedium(18, text_main), downStyle: StRegular(12, text_main2),crossAxisAlignment: CrossAxisAlignment.end,)),

      ],
    );
  }

  _headerWidget(context){
    String label = sprintf(S.of(context).follow_settle_in_time, [traderEntity.settleInTime]);
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: CustomCachedNetworkImage(
            traderEntity.profileUrl,
            fit: BoxFit.cover,
            width: 48,
            height: 48
          ),
        ),
        const SizedBox(width: 10,),
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(traderEntity.nickName ?? "", style: StMedium(16, text_main),),
                const SizedBox(height: 6,),
                ///入住平台${traderEntity.settleInTime}天
                Text("${traderEntity.country} $label", style: StRegular(11, text_main2),),
              ],
            )
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            InkWell(
              onTap: (){

              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                decoration: RegularRadius(),
                child: Text(S.of(context).asset_tabbar_follow_title, style: StRegular(12, white),),
              ),
            ),
            const SizedBox(height: 6,),
            ///跟随者
            Text("${(traderEntity.followerCount ?? "").fixNumberDecimal(2)}" + S.of(context).follow_copies, style: StMedium(12, text_main),),
          ],
        )

      ],
    );
  }


}
