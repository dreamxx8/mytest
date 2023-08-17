import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:module_contract_service/data_center/contract_data_center.dart';
import 'package:module_contract_service/data_center/contract_enum.dart';
import 'package:module_contract_service/wrap/position_wrap.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/utils/common_utils.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_core/widget/list_divider_widget.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_follow/home/widget/sub_item/position_header.dart';
import 'package:module_follow/home/widget/sub_item/position_value_widget.dart';
import 'package:sprintf/sprintf.dart';
import 'package:coinw_flutter/modules/common/them/global_color_manager.dart';

class FollowerHistoryPositionItem extends StatefulWidget {
  final PositionWrap positionWrap;

  const FollowerHistoryPositionItem({Key? key, required this.positionWrap})
      : super(key: key);

  @override
  State<FollowerHistoryPositionItem> createState() =>
      _FollowerHistoryPositionItemState();
}

class _FollowerHistoryPositionItemState
    extends State<FollowerHistoryPositionItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PositionHeaderWidget(
            "${widget.positionWrap.getContractName()} ${S.of(context).contract_perpetual}",
            ///倍杠杆
            sprintf(S.of(context).contract_leverage, [widget.positionWrap.position.leverage]),
            widget.positionWrap.getDirection(context),
            widget.positionWrap.position.direction ?? "long",
            traderNickname: widget.positionWrap.position.nickName ?? "",
            traderId: widget.positionWrap.position.leaderId,
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ///收益
                    S.of(context).follow_common_profit+"(USDT)",
                    style: StMedium(15, text_main2),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.positionWrap.getFollowPositionProfit(),
                    style: StRegular(
                        15,
                        CommonUtils.downOrUpColorByBool(
                            widget.positionWrap.isFollowPositionHaveProfit())),
                  )
                ],
              ),
              Expanded(child: Container()),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    ///收益率
                    S.of(context).bbs_mine_follow_yield,
                    style: StRegular(15, text_main2),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.positionWrap.getFollowPositionProfitRate(),
                    style:
                        StMedium(15, CommonUtils.downOrUpColorByBool(widget.positionWrap.isFollowPositionHaveProfit())),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ListDividerWidget(),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: PositionValueWidget(
                  widget.positionWrap.getOpen(),

                  ///开仓价格
                  S.of(context).follow_open_price + "(USDT)",
                  crossAxisAlignment: CrossAxisAlignment.start,
                  upsideDown: true,
                  upStyle: StMedium(11, text_main),
                ),
              ),
              Expanded(
                child: PositionValueWidget(
                  widget.positionWrap.getClosePrice(),
                  ///平仓价格
                  S.of(context).follow_close_true_price+"(USDT)",
                  upsideDown: true,
                  upStyle: StMedium(11, text_main),
                ),
              ),
              Expanded(
                child: PositionValueWidget(
                  widget.positionWrap.getHoldPosition(quantityUnit: contractDataCenter.TRADE_UNIT),
                  ///"持仓数量(%s)"
                  // getTradeUnitStr(
                  sprintf(S.of(context).follow_position_count, [widget.positionWrap.getTradeUnitStr(contractDataCenter.TRADE_UNIT, context)]),
                  upsideDown: true,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  upStyle: StMedium(11, text_main),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: PositionValueWidget(
                  widget.positionWrap.getOpenTime(),
                  ///开仓时间
                  S.of(context).follow_open_order_time,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  upsideDown: true,
                  upStyle: StMedium(11, text_main),
                ),
              ),
              Expanded(
                child: PositionValueWidget(
                  widget.positionWrap.getCloseTime(),
                  ///平仓时间
                  S.of(context).follow_close_order_time,
                  upsideDown: true,
                  upStyle: StMedium(11, text_main),
                ),
              ),
              Expanded(
                child: PositionValueWidget(
                  widget.positionWrap.position.id.toString(),
                  ///仓位ID
                  S.of(context).follow_order_id,
                  upsideDown: true,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  upStyle: StMedium(11, text_main),
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}
