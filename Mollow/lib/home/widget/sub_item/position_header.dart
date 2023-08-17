import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/utils/common_utils.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_core/widget/list_divider_widget.dart';
import 'package:module_follow/home/follow_trader_detail_page.dart';

class PositionHeaderWidget extends StatelessWidget {
  String contractName;
  String leverage;
  String directionStr;
  String direction;
  String? traderNickname;
  String? traderId;

  PositionHeaderWidget(this.contractName, this.leverage, this.directionStr,this.direction,
      {Key? key, this.traderNickname, this.traderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          contractName,
          style: StMedium(15, text_main),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              leverage,
              style: StRegular(10, text_main2),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: RegularRadius(
                color: CommonUtils.downOrUpColorByDirection(direction),
                radius: 3,
              ),
              child: Text(
                directionStr,
                style: StRegular(10, text_on_button),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(child: Container()),
            getTraderNicknameWidget(context),
          ],
        ),
        const SizedBox(height: 10),
        ListDividerWidget(),
        const SizedBox(height: 10),
      ],
    );
  }

  getTraderNicknameWidget(BuildContext context){
    if(traderNickname != null && traderNickname!.isNotEmpty){
      return GestureDetector(
        onTap: () {
          FollowTraderDetailPage.start(context, leaderId: traderId);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: RegularRadius(
            color: color_FFF7D6,
            radius: 3,
          ),
          child: Text(
            traderNickname ?? "",
            style: StRegular(10, text_trader),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      Container();
    }

  }

}
