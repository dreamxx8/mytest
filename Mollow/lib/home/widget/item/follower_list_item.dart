
import 'package:coinw_flutter/bean/follow/tader_follower_entity.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/utils/common_utils.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/custom_cached_network_image.dart';

class FollowerListItem extends StatelessWidget {
  final TaderFollowerEntity followerEntity;
  const FollowerListItem(this.followerEntity, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: CustomCachedNetworkImage(
              followerEntity.profileUrl,
              width: 36,
              height: 36,
            ),
          ),
          const SizedBox(width: 12,),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(followerEntity.nickName ?? "", style: StMedium(14, text_main),),
              const SizedBox(height: 6,),
              Row(
                children: [
                  ///跟随总额
                  Text(S.of(context).follow_total_number, style: StRegular(12, text_main2)),
                  const SizedBox(width: 5,),
                  Expanded(child: Text("${followerEntity.margin ?? ""} USDT", style: StRegular(12, text_main2))),
                ],
              ),
              const SizedBox(height: 6,),
              Row(
                children: [
                  ///跟随收益
                  Text(S.of(context).follow_total_profit_number, style: StRegular(12, text_main2)),
                  const SizedBox(width: 5,),
                  Expanded(child: Text("${followerEntity.followProfit ?? ""} USDT", style: StRegular(12, CommonUtils.downOrUpColor(followerEntity.followProfit)))),
                ],
              ),
            ],
          ))
        ],
      ),
    );
  }
}
