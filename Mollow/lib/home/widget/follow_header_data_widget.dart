

import 'package:coinw_flutter/bean/follow/follow_trader_entity.dart';
import 'package:coinw_flutter/modules/common/them/global_color_manager.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/extension/string_extension.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_international/generated/l10n.dart';

class FollowHeaderDataWidget extends StatelessWidget {

  final FollowTraderEntity? traderEntity;

  const FollowHeaderDataWidget({Key? key, this.traderEntity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, top: 18, right: 15, bottom: 25),
      child: Row(
        children: [
          Expanded(
            ///"跟随"
            child: getDataWidget(
                S.of(context).follow_copy, traderEntity?.followerCount ?? "0"),
          ),
          Container(
            height: 55,
            width: 1,
            color: globalColorManager.dividerColor,
          ),
          Expanded(
            ///"关注"
            child: getDataWidget(S.of(context).bbs_mine_header_follow,
                (traderEntity?.focusCount ?? "0").fixNumberTwoDecimal),
          )
        ],
      ),
    );
  }


  getDataWidget(String title, String data){
    return Column(
      children: [
        Text(data, style: StBold(30, text_main),),
        const SizedBox(height: 6,),
        Text(title, style: StRegular(14, text_main),),
      ],
    );

  }
}
