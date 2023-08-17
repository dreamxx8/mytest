
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
import 'package:module_follow/home/widget/sub_item/position_value_widget.dart';

class FollowerMyselfListItem extends StatelessWidget {
  final TaderFollowerEntity followerEntity;
  final ValueChanged<TaderFollowerEntity>? removeCallBack;
  const FollowerMyselfListItem(this.followerEntity, {Key? key, this.removeCallBack}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: CustomShadow(color: white),
      padding: const EdgeInsets.symmetric(vertical: 15),
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
                  Text(followerEntity.labelNote ?? "", style: StRegular(12, text_main2), maxLines: 1,) : Container(),
                ],
              )),
              InkWell(
                onTap: (){
                  _alertView(context);
                },
                child: Container(
                  decoration: RegularRadius(color: colorTheme.withOpacity(0.1), radius: 4.0),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                  ///移除
                  child: Text(S.of(context).follow_remove, style: StRegular(12, colorTheme),),
                ),
              )
            ],
          ),
          const SizedBox(height: 20,),
          Row(
            children: [
              ///累计收益
              Expanded(child: PositionValueWidget(followerEntity.accumulatedProfit ?? "","${S.of(context).assets_earn_cumulative_income}(USDT)", upStyle: StMedium(14, text_main), downStyle: StRegular(12, text_main2), crossAxisAlignment: CrossAxisAlignment.start,)),
              ///累计跟单
              Expanded(child: PositionValueWidget(followerEntity.accumulatedFollowCount ?? "","${S.of(context).follow_accumulative_total}(USDT)", upStyle: StMedium(14, text_main), downStyle: StRegular(12, text_main2))),
              ///累计分成
              Expanded(child: PositionValueWidget(followerEntity.accumulatedShare ?? "","${S.of(context).follow_accumulative_divide}(USDT)", upStyle: StMedium(14, text_main), downStyle: StRegular(12, text_main2), crossAxisAlignment: CrossAxisAlignment.end,)),
            ],
          )
        ],
      ),
    );
  }

  _alertView(BuildContext context){
    ///"移除后，跟随者的收益无法进行分润"
    showImageDialog(
        context, S.of(context).follow_order_remove_hint, ImageSourceConst.FOLLOW_WARNING_BIG,
        titleStyle: StMedium(14, text_main),
        sureButtonTitle: S.of(context).follow_sure_remove,
        imageSize: 80, confirmCallback: () {
      if (removeCallBack != null) {
        removeCallBack!(followerEntity);
      }
    });
  }


}
