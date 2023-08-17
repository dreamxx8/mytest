import 'package:coinw_flutter/bean/contract/bean/position_and_order_entity.dart';
import 'package:flutter/material.dart';
import 'package:module_contract_service/wrap/position_wrap.dart';
import 'package:module_core/core/base/base_entity.dart';
import 'package:module_core/core/base/base_page_entiry.dart';
import 'package:module_core/core/constant/url_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/net/http_client.dart';
import 'package:module_core/core/utils/scroll_view.dart';
import 'package:module_core/core/utils/system_utils.dart';
import 'package:module_core/widget/custom_refresher_widget.dart';
import 'package:module_core/widget/empty_widget.dart';
import 'package:module_core/widget/list_divider_widget.dart';
import 'package:module_follow/home/widget/item/trader_position_current_item.dart';
import 'package:module_follow/home/widget/item/trader_position_history_item.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

///历史带单
class TraderHistoryOrderChildPage extends StatefulWidget {
  static const String routeName = "HistoryOrderChildPage";
  final String leaderId;
  static void start(BuildContext context) {
    Navigator.pushNamed(context, routeName);
  }

  const TraderHistoryOrderChildPage({Key? key, required this.leaderId}) : super(key: key);

  @override
  State<TraderHistoryOrderChildPage> createState() => _TraderHistoryOrderChildPageState();
}

class _TraderHistoryOrderChildPageState extends State<TraderHistoryOrderChildPage>
    with _HistoryOrderChildPageBloc, AutomaticKeepAliveClientMixin {

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
      enablePullDown: true,
      enablePullUp: _isLoadMore,
      footer: customRefresherFooter(context),
      header: customRefresherHeader(context),
      onRefresh: () {
        _pageNum = 1;
        _fetchHistoryPosition();
      },
      onLoading: () {
        _pageNum++;
        _fetchHistoryPosition();
      },
      child: ListView.separated(
        itemBuilder: (context, index) => buildItem(index),
        physics: DefScrollPhysics.def,
        separatorBuilder: (context, index){
          return ListDividerWidget();
        },
        itemCount: _positionWrapList.isEmpty ? 1 : _positionWrapList.length,
      ),
    );
  }

  buildItem(int index) {
    if (_positionWrapList.isEmpty) {
      return SizedBox(height: 250, child: EmptyWidget());
    }
    return PositionHistoryItem(positionWrap:_positionWrapList[index]);
  }

  @override
  bool get wantKeepAlive => true;
}

mixin _HistoryOrderChildPageBloc on State<TraderHistoryOrderChildPage> {
  bool _isInitialized = false;
  int _pageNum = 1;
  final int _pageSize = 20;
  bool _isLoadMore = true;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final List<PositionWrap> _positionWrapList = [];

  _init() {
    _fetchHistoryPosition();
  }

  _fetchHistoryPosition() async {
    Map<String, dynamic> params = {};
    params["queryParameter"] = widget.leaderId;
    params["page"] = _pageNum;
    params["pageSize"] = _pageSize;
    await httpClientContract.post<List<PositionAndOrderEntity>>(
        url: UrlConst.API_FOLLOW_LEADER_HISTORY_POSITION,
        parameters: params,
        showErrorMessage: true,
        parseKey: CommonConst.ROWS_PAGE,
        onError: (error) {
          SystemUtils.endRefresh(_refreshController);
        },
        onSuccess: (resp) {
          _isLoadMore = resp != null && resp.length >= _pageSize;

          if(_pageNum == 1){
            _positionWrapList.clear();
          }

          // _positionWrapList = resp?.map((e) => PositionWrap(position: e)).toList();

          resp?.forEach((position) {
            _positionWrapList.add(PositionWrap(position: position));
          });
          SystemUtils.endRefresh(_refreshController);
          // _positionWrapList = resp?.map((position) {
          //   PositionWrap(position: position);
          // }).toList() as List<PositionWrap>?;
          setState(() {});
        });
  }
}

