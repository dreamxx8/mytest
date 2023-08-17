import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:flutter/material.dart';
import 'package:module_contract_service/data_center/contract_data_center.dart';
import 'package:module_contract_service/wrap/position_wrap.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/utils/common_utils.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_core/core/ws/subscribe_type.dart';
import 'package:module_core/core/ws/web_socket_manager.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_follow/home/widget/sub_item/position_value_widget.dart';

class PositionCurrentItem extends StatefulWidget {
  final PositionWrap positionWrap;
  bool _isInitialized = false;

  PositionCurrentItem({Key? key, required this.positionWrap})
      : super(key: key) {
    _isInitialized = false;
  }

  @override
  State<PositionCurrentItem> createState() => _PositionCurrentItemState();
}

class _PositionCurrentItemState extends State<PositionCurrentItem>
    with _PositionCurrentItemBloc {



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
              Text(
                  "${widget.positionWrap.getContractName()} ${S.of(context).contract_perpetual}",
                  style: StMedium(15, text_main)),
              const SizedBox(width: 10),
              Text("${widget.positionWrap.position.leverage}X", style: StRegular(15, text_main)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                ///开仓价格
                  child: PositionValueWidget(
                      widget.positionWrap.getOpen(), "${S.of(context).follow_open_price}(USDT)",
                      crossAxisAlignment: CrossAxisAlignment.start)),
              Expanded(
                ///持仓均价
                  child: PositionValueWidget(
                      widget.positionWrap.getOpen(), "${S.of(context).follow_position_avg_prive}(USDT)")),
              Expanded(
                ///收益率
                  child: PositionValueWidget( widget.positionWrap.getProfitRate(), S.of(context).bbs_mine_follow_yield,
                      upStyle: StMedium(13, CommonUtils.downOrUpColor(widget.positionWrap.getProfitRate().replaceAll("%", ""))),
                      crossAxisAlignment: CrossAxisAlignment.end)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            child: Text(
              ///开仓时间
              "${S.of(context).follow_open_order_time} ${widget.positionWrap.getCreateDate()}",
              style: StRegular(10, text_main2),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (subscribeTypeBean != null) {
      wsManager.unsubscribe(subscribeTypeBean!);
    }
  }
}

mixin _PositionCurrentItemBloc on State<PositionCurrentItem> {
  SubscribeTypeBean? subscribeTypeBean;

  _init() {
    if (subscribeTypeBean != null) {
      wsManager.unsubscribe(subscribeTypeBean!);
    }
    subscribeTypeBean =
        contractDataCenter.subscribePosition(widget.positionWrap, (value) {
      setState(() {});
    });
  }
}
