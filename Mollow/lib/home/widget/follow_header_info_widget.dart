
import 'package:coinw_flutter/bean/follow/follow_trader_entity.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_core/core/utils/string_utils.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/custom_cached_network_image.dart';
import 'package:sprintf/sprintf.dart';

class FollowHeaderInfoWidget extends StatelessWidget {

  final FollowTraderEntity? traderEntity;
  const FollowHeaderInfoWidget({Key? key, this.traderEntity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String label = sprintf(S.of(context).follow_settle_in_time, [traderEntity?.settleInTime ?? ""]);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9,horizontal: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ///头像
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: CustomCachedNetworkImage(
              traderEntity?.profileUrl,
              fit: BoxFit.cover,
              width: 60,
              height: 60,
              errorWidget: (context, error, stackTrace) => Image.asset(
                ImageSourceConst.IC_IMAGE_DEFAUT,
                width: 20,
                height: 20,
              ),
            ),
          ),
          const SizedBox(height: 12,),
          Text(traderEntity?.nickName ?? "", style: StMedium(18, text_main),),
          const SizedBox(height: 5,),
          Text("@${getNickEnName(traderEntity)} $label", style: StMedium(12, text_main2),),
        ],
      ),
    );
  }

  static String getNickEnName(FollowTraderEntity? traderEntity){
    // if(StringUtils.isNotBlank(traderEntity?.nickNameEn)){
    //   return traderEntity?.nickNameEn ?? "";
    // }
    return traderEntity?.nickNameEn ?? "";
  }


}
