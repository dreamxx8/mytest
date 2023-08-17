import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:flutter/material.dart';
import 'package:module_contract_service/wrap/position_wrap.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/utils/common_utils.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_core/widget/list_divider_widget.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_follow/home/widget/sub_item/position_value_widget.dart';
import 'package:sprintf/sprintf.dart';

class PositionHistoryItem extends StatefulWidget {
  final PositionWrap positionWrap;

  PositionHistoryItem({Key? key, required this.positionWrap}) : super(key: key);

  @override
  State<PositionHistoryItem> createState() => _PositionCurrentItemState();
}

class _PositionCurrentItemState extends State<PositionHistoryItem> {
  @override
  Widget build(BuildContext context) {
    // widget.positionWrap;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                sprintf(S.of(context).follow_order_user_count, [widget.positionWrap.position.followNum]),
                style: StRegular(12, text_main2),
                textAlign: TextAlign.center,
              ),
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${widget.positionWrap.getFollowerProfit()} USDT",
                        style: StRegular(18, text_main),
                        textAlign: TextAlign.center,
                      ),
                      ///跟随着收益
                      Text(
                        S.of(context).follow_my_profit,
                        style: StRegular(12, text_main2),
                        textAlign: TextAlign.center,
                      ),
                    ]),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
              "${widget.positionWrap.getContractName()} ${S.of(context).contract_perpetual}",
              style: StRegular(15, text_main)),
          const SizedBox(height: 14),
          ListDividerWidget(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                ///开仓价格
                child: PositionValueWidget(widget.positionWrap.getOpen(),
                    "${S.of(context).follow_open_price}(USDT)",
                    crossAxisAlignment: CrossAxisAlignment.start),
              ),
              Expanded(
                ///平仓价格
                child: PositionValueWidget(
                    widget.positionWrap.getClosePrice(), "${S.of(context).follow_close_true_price}(USDT)"),
              ),
              Expanded(
              ///"收益率"
                child: PositionValueWidget(
                    widget.positionWrap.getFollowPositionProfitRate(), S.of(context).bbs_mine_follow_yield,
                    upStyle: StMedium(
                        13,
                        CommonUtils.downOrUpColorByBool(
                            widget.positionWrap.isFollowPositionHaveProfit())),
                    crossAxisAlignment: CrossAxisAlignment.end),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 0,
                child: Text(
                  ///开仓时间
                  "${S.of(context).follow_open_order_time} ${widget.positionWrap.getOpenTime()}",
                  style: StRegular(10, text_main2),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 1,
                child: Text(
                  ///平仓时间
                  "${S.of(context).follow_close_order_time} ${widget.positionWrap.getCloseTime()}",
                  style: StRegular(10, text_main2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  ///交易员订单本金
                 "${S.of(context).follow_trader_order_principal} ${widget.positionWrap.getMarginStr()}",
                  style: StRegular(10, text_main2),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
