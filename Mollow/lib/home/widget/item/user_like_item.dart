
import 'package:coinw_flutter/bean/follow/follow_my_profit_entity.dart';
import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/custom_cached_network_image.dart';
import 'package:module_follow/common/follow_action_manager.dart';

class UserLikeItem extends StatelessWidget {
  const UserLikeItem(this.followerEntity, {Key? key, this.cancelCallBack}) : super(key: key);
  final FollowMyProfitEntity followerEntity;
  final ValueChanged<FollowMyProfitEntity>? cancelCallBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(

        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CustomCachedNetworkImage(
              followerEntity.profileUrl,
              width: 32,
              height: 32,
            ),
          ),
          const SizedBox(width: 15,),
          Expanded(child: Text(followerEntity.nickName ??"", style: StMedium(15, text_main),)),
          const SizedBox(width: 12,),
          InkWell(
            onTap: (){
              _cancelCallBack();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
              decoration: RegularBorder(radius: 4.0),
              ///取消关注
              child: Text(S.of(context).follow_cancel_focus_button, style: StRegular(12, colorTheme),),
            ),
          ),
          const SizedBox(width: 12,),
          InkWell(
            onTap: (){
              FollowActionManager.pushFollowTrader(context, followerEntity.leaderId ?? "");
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
              decoration: RegularBorder(radius: 4.0, backgroundColor: colorTheme),
              ///跟单
              child: Text(S.of(context).asset_tabbar_follow_title, style: StRegular(12, white),),
            ),
          )
        ],
      ),
    );
  }

  _cancelCallBack(){
    if(cancelCallBack!=null){
      cancelCallBack!(followerEntity);
    }
  }
}
