import 'package:coinw_flutter/bean/contract/bean/product.dart';
import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:coinw_flutter/modules/common/them/global_color_manager.dart';
import 'package:flutter/material.dart';
import 'package:module_contract_service/data_center/contract_data_center.dart';
import 'package:module_contract_service/widget/share/position_share_widget.dart';
import 'package:module_contract_service/wrap/position_wrap.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/value_const.dart';
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
import 'package:module_follow/home/widget/sub_item/position_value_widget.dart';
import 'package:module_contract_service/widget/modify_tp_sl/modify_tp_sl_widget.dart';
import 'package:sprintf/sprintf.dart';


class TraderMySelfPositionItem extends StatefulWidget {
  final PositionWrap positionWrap;

  final bool isHistory;
  bool _isInitialized = false;

  TraderMySelfPositionItem({
    Key? key,
    required this.positionWrap,
    required this.isHistory,
  }) : super(key: key) {
    _isInitialized = false;
  }

  @override
  State<TraderMySelfPositionItem> createState() => _PositionCurrentItemState();
}

class _PositionCurrentItemState extends State<TraderMySelfPositionItem>
    with _TraderMySelfPositionItemBloc{

  @override
  Widget build(BuildContext context) {
    // widget.positionWrap;
    if (!widget._isInitialized) {
      widget._isInitialized = true;
      _init();
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ///永续
              Text("${widget.positionWrap.getContractName()} ${S.of(context).contract_perpetual}",
                  style: StMedium(15, text_main)),
              Expanded(
                flex: 1,
                child: Container(),
              ),
              _getPopMenu(),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ///倍杠杆
              Text(sprintf(S.of(context).contract_leverage, [widget.positionWrap.position.leverage]),
                  style: StMedium(12, text_main)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.only(left: 6, right: 6 ,top: 3, bottom: 2),
                decoration: RegularRadius(
                  color: CommonUtils.downOrUpColorByDirection(
                      widget.positionWrap.position.direction ?? "long"),
                  radius: 3,
                ),
                child: Text(
                  widget.positionWrap.getDirection(context),
                  style: StRegular(10, text_on_button),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListDividerWidget(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: PositionValueWidget(

                      ///开仓价格
                      widget.positionWrap.getOpen(),
                      "${S.of(context).follow_open_price}(USDT)",
                      crossAxisAlignment: CrossAxisAlignment.start)),
              Expanded(

                  ///跟随者收益
                  child: PositionValueWidget(
                      widget.positionWrap.getFollowerProfit(), S.of(context).follow_copiers_profit)),
              Expanded(
                ///收益率
                  child: PositionValueWidget(_getProfitRate(), S.of(context).bbs_mine_follow_yield,
                      upStyle: StMedium(
                        13,
                        CommonUtils.downOrUpColorByBool(widget.isHistory
                            ? widget.positionWrap.isFollowPositionHaveProfit()
                            : widget.positionWrap.isHaveProfit),
                      ),
                      crossAxisAlignment: CrossAxisAlignment.end)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ///"利润分成(USDT)" : "预计利润分成(USDT)"
              Expanded(
                  child: PositionValueWidget(widget.positionWrap.getFollowerSharingProfit(),
                      widget.isHistory ? "${S.of(context).follow_item_profit_rate}(USDT)" : "${S.of(context).follow_profit_estimate_rate}(USDT)",
                      crossAxisAlignment: CrossAxisAlignment.start)),
              Expanded(child: PositionValueWidget(widget.positionWrap.position.followNum.toString(), S.of(context).follow_copiers)),
              Expanded(child: Container()),
            ],
          ),
        ],
      ),
    );
  }

  _getProfitRate() {
    if (widget.isHistory) {
      return widget.positionWrap.getFollowPositionProfitRate();
    } else {
      return widget.positionWrap.getProfitRate();
    }
  }

  _getPopMenu() {
    return PopupMenuButton<String>(
      offset:const Offset(20, 30),
      onSelected: (String value) {
        if(widget.isHistory){
          if(value == _menuItems[0]){
            FollowActionManager.pushFollowOrder(context, widget.positionWrap.position.id, widget.isHistory);
          }
        } else {
          if (value == _menuItems[0]) {
            // 止盈止损
            if(_product != null){
              ModifyTP_SL_Widget.show(context, widget.positionWrap.position, _product!, isFollowOrder: true, isShowMoveTP_SL: false);
            }

          } else if (value == _menuItems[1]) {
            // 一键平仓
            ///确认要平仓吗?
            CustomDialog(title: S.of(context).follow_colse_order_hint, showCancelButton: true, confirmCallback: () {
              contractDataCenter.closePosition(widget.positionWrap.position, (isSuccess) => {
                eventBus.fire(EventFollowPositionItemChange())
              });
            },).show(context);
          } else if (value == _menuItems[2]) {
            CommonShareWidget.showCommonShare(context, shareWidget: PositionShareWidget(widget.positionWrap, isHistoryOrder: widget.isHistory));
          } else {
            FollowActionManager.pushFollowOrder(context,  widget.positionWrap.position.id, widget.isHistory);
          }
        }
      },
      itemBuilder: (BuildContext context) {
        return _menuItems.map((String value) {
          return PopupMenuItem<String>(
            value: value,
            child: Text(value, style: StMedium(14, text_main),),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.only(left: 15, top: 5, right: 0, bottom: 5),
        child: Image.asset(
          ImageSourceConst.ICON_MENU,
          width: 15,
          height: 15,
          color: globalColorManager.imageThemColor(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if(subscribeTypeBean != null){
      wsManager.unsubscribe(subscribeTypeBean!);
    }
  }
}

mixin _TraderMySelfPositionItemBloc on State<TraderMySelfPositionItem> {
  SubscribeTypeBean? subscribeTypeBean;
  late List<String> _menuItems;
  Product? _product;
  _init() {
    if (widget.isHistory) {
      ///跟随订单
      _menuItems = [S.of(context).follow_my_follow_order];
    } else {
      ///"止盈止损", "一键平仓", "分享", "跟随订单"
      _menuItems = [S.of(context).follow_profit_and_loss1,
        S.of(context).follow_close_order_one, S.of(context).follow_share, S.of(context).follow_my_follow_order];
    }

    if(subscribeTypeBean != null){
      wsManager.unsubscribe(subscribeTypeBean!);
    }

    contractDataCenter.getInstrument().then((value) {
      for (var product in value) {
        if (product.base ==
            widget.positionWrap.position.instrument?.toLowerCase()) {
          widget.positionWrap.product = product;
          _product = product;
          break;
        }
      }
      subscribeTypeBean = contractDataCenter.subscribePosition(widget.positionWrap, (value) {
        setState(() {});
      });
    });


  }
}
