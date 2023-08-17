
import 'package:coinw_flutter/bean/follow/follow_my_profit_entity.dart';
import 'package:coinw_flutter/bean/follow/tader_follower_entity.dart';
import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/utils/common_utils.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_core/core/utils/string_utils.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/custom_cached_network_image.dart';
import 'package:module_core/widget/custom_dialog.dart';
import 'package:module_follow/common/follow_action_manager.dart';
import 'package:module_follow/home/widget/sub_item/position_value_widget.dart';

class UserFollowerItem extends StatelessWidget {
  final FollowMyProfitEntity followerEntity;
  final ValueChanged<FollowMyProfitEntity>? settingCallBack;
  const UserFollowerItem(this.followerEntity, {Key? key, this.settingCallBack}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: CustomShadow(color: white),
      padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: CustomCachedNetworkImage(
                  followerEntity.profileUrl,
                  width: 40,
                  height: 40,
                ),
              ),
              const SizedBox(width: 12,),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(followerEntity.nickName ?? "", style: StMedium(15, text_main),),
                  const SizedBox(height: 6,),
                  StringUtils.isNotBlank(followerEntity.labelNote)?
                  Text(followerEntity.labelNote ?? "", style: StRegular(12, text_main2)) : Container(),
                ],
              )),
              InkWell(
                onTap: (){
                  FollowActionManager.pushFollowTrader(context, followerEntity.leaderId ?? "");
                },
                child: Container(
                  decoration: RegularRadius(color: colorTheme.withOpacity(0.1), radius: 4.0),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                  ///跟随设置
                  child: Text(S.of(context).follow_setting, style: StRegular(12, colorTheme),),
                ),
              )
            ],
          ),
          const SizedBox(height: 20,),
          Row(
            children: [
              ///今日收益
              Expanded(child: PositionValueWidget(followerEntity.todayProfit ?? "0","${S.of(context).follow_today_profit_all}(USDT)", upStyle: StMedium(14, text_main), downStyle: StRegular(12, text_main2), crossAxisAlignment: CrossAxisAlignment.start,)),
              Expanded(child: PositionValueWidget(followerEntity.cumulativeProfit ?? "0","${S.of(context).assets_earn_cumulative_income}(USDT)", upStyle: StMedium(14, text_main), downStyle: StRegular(12, text_main2), crossAxisAlignment: CrossAxisAlignment.end,)),
            ],
          )
        ],
      ),
    );
  }



}
