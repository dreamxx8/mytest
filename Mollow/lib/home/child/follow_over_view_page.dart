
import 'package:coinw_flutter/bean/bbs/bean/bbs_list_entity.dart';
import 'package:coinw_flutter/bean/follow/follow_trader_entity.dart';
import 'package:coinw_flutter/modules/common/them/global_color_manager.dart';
import 'package:flutter/material.dart';
import 'package:module_bbs/bbs_enum.dart';
import 'package:module_bbs/widget/bbs_item_widget.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/url_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/net/http_client.dart';
import 'package:module_core/core/utils/event_bus_utils.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/custom_refresher_widget.dart';
import 'package:module_core/widget/custom_widget.dart';
import 'package:module_core/widget/empty_widget.dart';
import 'package:module_follow/home/child/widget/over_view_chart_widget.dart';
import 'package:module_follow/home/child/widget/over_view_perference_widget.dart';
import 'package:module_follow/home/child/widget/over_view_stats_widget.dart';
import 'package:module_follow/home/child/widget/stats_chart_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

///概述
class FollowOverViewPage extends StatefulWidget {
  static const String routeName = "FollowOverViewPage";
  final String leaderId;
  final String? userId;
  final FollowTraderEntity? traderEntity;
  static void start(BuildContext context) {
    Navigator.pushNamed(context, routeName);
  }

  const FollowOverViewPage({Key? key, required this.leaderId, this.traderEntity, this.userId}) : super(key: key);

  @override
  State<FollowOverViewPage> createState() => _FollowOverViewPageState();
}

class _FollowOverViewPageState extends State<FollowOverViewPage>
    with _FollowOverViewPageBloc,AutomaticKeepAliveClientMixin {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      _isInitialized = true;
      _init();
    }
    return Container(
      child: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: _isLoadMore,
        footer: customRefresherFooter(context),
        header: customRefresherHeader(context),
        onRefresh: () {
          _refresh();
        },
        onLoading: () {
          _pageNum++;
          _getListData();
        },
        child: ListView.builder(
          itemBuilder: _itemBuilder,
          itemCount: _dataList.isEmpty ? 7 : _dataList.length + 6,
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index){
    if(index == 0){
      //统计月份柱状图
      return OverViewChartWidget(leaderId: widget.leaderId,);
    }else if(index == 1){
      //统计数据
      return OverViewStatsWidget(traderEntity: widget.traderEntity,);
    }else if(index == 2){
      return customLine(height: 9, color: globalColorManager.dividerColor);
    }else if(index == 3){
      //偏好数据
     return OverViewPerferenceWidget(traderEntity: widget.traderEntity,);
    }else if(index == 4){
      //偏好数据
      return customLine(height: 9, color: globalColorManager.dividerColor);
    }else if(index == 5){
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 22),
        ///他的贴子
        child: Text(S.of(context).follow_him_community, style: StBold(16, text_main),),);
    }
    if(_dataList.isEmpty){
      return EmptyWidget();
    }
    var itemData = _dataList[index-6];
    return BbsItemWidget(itemData, BbsItemEnum.MINE_HOME);
  }

  @override
  bool get wantKeepAlive => true;



}

mixin _FollowOverViewPageBloc on State<FollowOverViewPage> {
  bool _isInitialized = false;
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  int _pageNum = 1;
  bool _isLoadMore = true;
  List<BbsItemEntity> _dataList = [];
  String? uid;
  _init() {
    uid = widget.userId;
    _getListData();
    eventBus.on<EventFollowUserId>().listen((event) {
      if(event.uid.isNotEmpty && uid == null){
        uid = event.uid;
        _refresh();
      }
    });
  }

  _refresh() {
    _pageNum = 1;
    _getListData();
  }

  _getListData({showLoading = false}) async {
    //uid = "1117594";
    if(uid == null){
      return;
    }
    Map<String, dynamic> params = Map();
    params[RequestConst.PAGE_SIZE] = CommonConst.PAGE_SIZE_NUM;
    params[RequestConst.PAGE_NUM] = _pageNum;
    params['uid'] = uid;

    await httpClient.post<BbsListEntity>(
      url: UrlConst.API_BBS_USER_DYNAMIC,
      parameters: params,
      showLoading: showLoading,
      showLoginDialog: false,
      onSuccess: (resp) {
        if (resp != null && resp.rows != null) {
          if (_pageNum == 1) {
            _dataList.clear();
          }
          _dataList.addAll(resp.rows!);
          if (resp.totalPages != null &&
              resp.pageNo != null &&
              resp.totalPages! > resp.pageNo!) {
            _isLoadMore = true;
          } else {
            _isLoadMore = false;
          }
        }
        setState(() {});
      },
      onError: (e) {},
    );
    _endRefresh();
  }


  _endRefresh() {
    _refreshController.loadComplete();
    _refreshController.refreshCompleted();
  }
}
