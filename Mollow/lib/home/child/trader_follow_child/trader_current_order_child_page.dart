import 'package:coinw_flutter/bean/contract/bean/position_and_order_entity.dart';
import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:flutter/material.dart';
import 'package:module_contract_service/data_center/contract_data_center.dart';
import 'package:module_contract_service/wrap/position_wrap.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/url_const.dart';
import 'package:module_core/core/net/http_client.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_core/core/utils/scroll_view.dart';
import 'package:module_core/core/utils/system_utils.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/custom_refresher_widget.dart';
import 'package:module_core/widget/empty_widget.dart';
import 'package:module_core/widget/list_divider_widget.dart';
import 'package:module_follow/home/widget/item/trader_position_current_item.dart';
import 'package:module_follow/home/widget/sub_item/position_value_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

///当前订单持仓
class TraderCurrentOrderChildPage extends StatefulWidget {
  static const String routeName = "TraderCurrentOrderChildPage";
  final String leaderId;
  final int isBinding;

  static void start(BuildContext context) {
    Navigator.pushNamed(context, routeName);
  }

  const TraderCurrentOrderChildPage({Key? key, required this.leaderId, required this.isBinding,})
      : super(key: key);

  @override
  State<TraderCurrentOrderChildPage> createState() =>
      _TraderCurrentOrderChildPageState();
}

class _TraderCurrentOrderChildPageState
    extends State<TraderCurrentOrderChildPage>
    with _CurrentOrderChildPageBloc, AutomaticKeepAliveClientMixin {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_isInitialized) {
      _isInitialized = true;
      _init();
    }
    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: widget.isBinding == 1,
      enablePullUp: false,
      footer: customRefresherFooter(context),
      header: customRefresherHeader(context),
      onRefresh: () {
        _pageNum = 1;
        _fetchCurrentPosition();
      },
      onLoading: () {
        _pageNum++;
        _fetchCurrentPosition();
      },
      child: ListView.separated(
        itemBuilder: (context, index) => buildItem(index),
        physics: DefScrollPhysics.def,
        separatorBuilder: (context, index) {
          return ListDividerWidget();
        },
        itemCount: _positionWrapList.isEmpty ? 1 : _positionWrapList.length,
      ),
    );
  }

  buildItem(int index) {
    if (_positionWrapList.isEmpty) {
      return SizedBox(height: 250, child: EmptyWidget(
        ///"当前带单仅对跟随者展示，请跟随后查看"
        text: widget.isBinding == 0 ? S.of(context).follow_current_order_hint : null,
      ));
    }
    return PositionCurrentItem(positionWrap: _positionWrapList[index]);
  }

  @override
  bool get wantKeepAlive => true;
}

mixin _CurrentOrderChildPageBloc on State<TraderCurrentOrderChildPage> {
  bool _isInitialized = false;
  int _pageNum = 1;
  final int _pageSize = 20;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final List<PositionWrap> _positionWrapList = [];

  _init() {
    if(widget.isBinding == 1){
      _fetchCurrentPosition();
    }
  }

  _fetchCurrentPosition() async {
    Map<String, dynamic> params = {};
    params["queryParameter"] = widget.leaderId;
    params["page"] = _pageNum;
    params["pageSize"] = _pageSize;

    await httpClientContract.post<List<PositionAndOrderEntity>>(
        url: UrlConst.API_FOLLOW_LEADER_CURRENT_POSITION,
        parameters: params,
        showErrorMessage: true,
        showLoginDialog: false,
        onError: (error) {
          print('_HistoryOrderChildPageBloc getData error${error}');
          SystemUtils.endRefresh(_refreshController);
        },
        onSuccess: (resp) {

          if (_pageNum == 1) {
            _positionWrapList.clear();
          }

          resp?.forEach((position) {
            _positionWrapList.add(PositionWrap(position: position));
          });
          SystemUtils.endRefresh(_refreshController);
          // _positionWrapList = resp?.map((position) {
          //   PositionWrap(position: position);
          // }).toList() as List<PositionWrap>?;
          setState(() {});
        }
        );
  }
}
