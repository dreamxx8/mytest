import 'package:coinw_flutter/bean/contract/bean/contract_asset_info.dart';
import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:coinw_flutter/modules/common/them/global_color_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:module_contract_service/data_center/contract_data_center.dart';
import 'package:module_contract_service/data_center/contract_enum.dart';
import 'package:module_contract_service/widget/modify_tp_sl/modify_tp_sl_widget.dart';
import 'package:module_contract_service/widget/share/position_share_widget.dart';
import 'package:module_contract_service/wrap/position_wrap.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/utils/clipboard_util.dart';
import 'package:module_core/core/utils/common_share.dart';
import 'package:module_core/core/utils/common_utils.dart';
import 'package:module_core/core/utils/event_bus_utils.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_core/core/ws/subscribe_type.dart';
import 'package:module_core/core/ws/web_socket_manager.dart';
import 'package:module_core/widget/list_divider_widget.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/custom_dialog.dart';
import 'package:module_follow/common/follow_action_manager.dart';
import 'package:module_follow/home/widget/sub_item/position_header.dart';
import 'package:module_follow/home/widget/sub_item/position_value_widget.dart';
import 'package:sprintf/sprintf.dart';

class FollowerCurrentPositionItem extends StatefulWidget {
  final PositionWrap positionWrap;
  bool _isInitialized = false;

  FollowerCurrentPositionItem({Key? key, required this.positionWrap})
      : super(key: key) {
    _isInitialized = false;
  }

  @override
  State<FollowerCurrentPositionItem> createState() =>
      _FollowerCurrentPositionItemState();
}

class _FollowerCurrentPositionItemState
    extends State<FollowerCurrentPositionItem>
    with _FollowerCurrentPositionItemBloc {
  @override
  Widget build(BuildContext context) {
    if (!widget._isInitialized) {
      widget._isInitialized = true;
      _init();
    }
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
                    widget.positionWrap.getProfit(),
                    style: StRegular(
                        15,
                        CommonUtils.downOrUpColorByBool(
                            widget.positionWrap.isHaveProfit)),
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
                    widget.positionWrap.getProfitRate(),
                    style: StMedium(
                        15,
                        CommonUtils.downOrUpColorByBool(
                            widget.positionWrap.isHaveProfit)),
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
                  widget.positionWrap.getHoldPosition(
                      quantityUnit: contractDataCenter.TRADE_UNIT),

                  ///"持仓数量(%s)"
                  sprintf(S.of(context).follow_position_count, [
                    widget.positionWrap
                        .getTradeUnitStr(contractDataCenter.TRADE_UNIT, context)
                  ]),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  upsideDown: true,
                  upStyle: StMedium(11, text_main),
                ),
              ),
              Expanded(
                child: PositionValueWidget(
                  widget.positionWrap.getMargin(),
                  ///保证金
                  S.of(context).follow_margin+"(USDT)",
                  upsideDown: true,
                  upStyle: StMedium(11, text_main),
                ),
              ),
              Expanded(
                child: PositionValueWidget(
                  widget.positionWrap.getLiquidationPrice(),
                  ///预估爆仓价
                  S.of(context).follow_close_price+"(USDT)",
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
                  widget.positionWrap.getRiskFormat(),
                  ///保证金率
                  S.of(context).follow_margin_rate,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  upsideDown: true,
                  upStyle: StMedium(11, text_main),
                ),
              ),
              Expanded(
                child: PositionValueWidget(
                  widget.positionWrap.getOpen(),
                  ///开仓价格
                  S.of(context).follow_open_price+"(USDT)",
                  upsideDown: true,
                  upStyle: StMedium(11, text_main),
                ),
              ),
              Expanded(
                child: PositionValueWidget(
                  widget.positionWrap.getTakeProfitStopLoss(),
                  ///止盈/止损
                  S.of(context).follow_profit_and_loss,
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
                child: InkWell(
                  onTap: () {
                    if(widget.positionWrap.product != null){
                      ModifyTP_SL_Widget.show(context, widget.positionWrap.position, widget.positionWrap.product!, isFollowOrder: true, isShowMoveTP_SL: false);
                    }

                  },
                  child: Container(
                    height: 31,
                    alignment: Alignment.center,
                    decoration: RegularRadius(
                      color: background_gray,
                      radius: 3,
                    ),
                    child: Text(
                      ///止盈止损
                      S.of(context).follow_profit_and_loss1,
                      style: StRegular(11, accent_main),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () {
                    CustomDialog(title: S.of(context).follow_colse_order_hint, showCancelButton: true, confirmCallback: () {
                      contractDataCenter.closePosition(widget.positionWrap.position, (isSuccess) => {
                        eventBus.fire(EventFollowPositionItemChange())
                      });
                    },).show(context);
                  },
                  child: Container(
                    height: 31,
                    alignment: Alignment.center,
                    decoration: RegularRadius(
                      color: background_gray,
                      radius: 3,
                    ),
                    child: Text(
                      ///一键平仓
                      S.of(context).follow_close_order_one,
                      style: StRegular(11, text_main2),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () {
                    CommonShareWidget.showCommonShare(context, shareWidget: PositionShareWidget(widget.positionWrap));
                  },
                  child: Container(
                    height: 31,
                    alignment: Alignment.center,
                    decoration: RegularRadius(
                      color: background_gray,
                      radius: 3,
                    ),
                    child: Text(
                      ///"分享"
                      S.of(context).follow_share,
                      style: StRegular(11, text_main2),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                ///创建时间
                child: Text(S.of(context).follow_common_create_time+":${widget.positionWrap.getCreateDate()}",
                    style: StRegular(10, text_main2)),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    ClipboardUtil.setDataToastMsg((widget.positionWrap.position.id ??0).toString(), toastMsg: S.of(context).common_copy_success);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        ImageSourceConst.ICON_COPY_ACCENT_COLOR,
                        height: 14,
                        width: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        ///仓位ID
                        S.of(context).follow_order_id+" ${widget.positionWrap.position.id}",
                        style: StRegular(10, text_main2),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_subscribeTypeBean != null) {
      wsManager.unsubscribe(_subscribeTypeBean!);
    }
  }
}

mixin _FollowerCurrentPositionItemBloc on State<FollowerCurrentPositionItem> {
  SubscribeTypeBean? _subscribeTypeBean = null;

  _init() {
    subscribe(widget.positionWrap);
  }

  subscribe(PositionWrap positionWrap) {
    if (_subscribeTypeBean != null) {
      wsManager.unsubscribe(_subscribeTypeBean!);
    }

    contractDataCenter.getInstrument().then((value) {
      for (var product in value) {
        if (product.base == positionWrap.position.instrument?.toLowerCase()) {
          positionWrap.product = product;
          break;
        }
      }

      _subscribeTypeBean =
          contractDataCenter.subscribePosition(positionWrap, (value) {
        print('${value.position.instrument} markPrice = ${value.markPrice}');
        setState(() {});
      });
    });
  }
}
