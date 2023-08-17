

import 'package:coinw_flutter/bean/contract/bean/contract_asset_info.dart';
import 'package:coinw_flutter/bean/contract/bean/position_and_order_entity.dart';
import 'package:coinw_flutter/bean/follow/my_trader_entity.dart';
import 'package:flutter/material.dart';
import 'package:module_contract_service/wrap/position_wrap.dart';
import 'package:module_core/core/constant/url_const.dart';
import 'package:module_core/core/extension/string_extension.dart';
import 'package:module_core/core/net/http_client.dart';
import 'package:module_core/core/utils/event_bus_utils.dart';
import 'package:module_core/core/utils/scroll_view.dart';
import 'package:module_core/core/utils/system_utils.dart';
import 'package:module_core/widget/custom_refresher_widget.dart';
import 'package:module_core/widget/empty_widget.dart';
import 'package:module_core/widget/list_divider_widget.dart';
import 'package:module_follow/home/widget/item/follower_current_position_item.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:module_core/core/utils/event_bus_utils.dart';

///当前订单持仓
class UserCurrentOrderChildPage extends StatefulWidget {
  static const String routeName = "CurrentOrderChildPage";

  static void start(BuildContext context) {
    Navigator.pushNamed(context, routeName);
  }

  const UserCurrentOrderChildPage({Key? key}) : super(key: key);

  @override
  State<UserCurrentOrderChildPage> createState() => _UserCurrentOrderChildPageState();
}

class _UserCurrentOrderChildPageState extends State<UserCurrentOrderChildPage>
    with _UserCurrentOrderChildPageBloc, AutomaticKeepAliveClientMixin{

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
    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
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
        itemCount: _positionWrapList.isNotEmpty ? _positionWrapList.length : 1,
      ),
    );
  }

  buildItem(int index){

    if(_positionWrapList.isEmpty){
      return SizedBox(
          height: 250,
          child: EmptyWidget());
    }

    var positionWrap = _positionWrapList[index];
    var usableBalances = ContractAssetInfo();
    double totalFee = 0;
    double totalMargin = 0;
    for (var element in _positionWrapList) {
      totalFee += element.position.fee??0;
      totalMargin += element.position.margin??0;

    }
    usableBalances.userPositions = _positionWrapList.map((e) => e.position).toList();
    usableBalances.totalFee = totalFee;
    usableBalances.totalMargin = totalMargin;
    usableBalances.totalFundingFee = 0;
    for (var element in _traderList) {
      if (element.leaderId == positionWrap.position.leaderId) {
        usableBalances.available = element.transferAmount.getDouble();
      }
    }
    positionWrap.usableBalances = usableBalances;
//key: GlobalKey(),
    return FollowerCurrentPositionItem(positionWrap: positionWrap);
  }

  @override
  bool get wantKeepAlive => true;

}

mixin _UserCurrentOrderChildPageBloc on State<UserCurrentOrderChildPage> {
  bool _isInitialized = false;
  final List<PositionWrap> _positionWrapList = [];
  final List<MyTraderEntity> _traderList = [];
  int _pageNum = 1;

  final RefreshController _refreshController =
    RefreshController(initialRefresh: false);

  _init() {
    _fetchTraderList().then((value) {
      if(value != null){
        _traderList.addAll(value);
        _fetchCurrentPosition();
      }
    });
    eventBus.on<EventFollowPositionItemChange>().listen((event) {
      _refreshController.requestRefresh();
    });
  }

  _fetchCurrentPosition() async {
    Map<String, dynamic> params = {};
    params["queryParameter"] = "";

    await httpClientContract.post<List<PositionAndOrderEntity>>(
        url: UrlConst.API_FOLLOW_FOLLOWER_CURRENT_POSITION,
        parameters: params,
        showErrorMessage: true,
        onError: (error) {
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
          eventBus.fire(EventRefreshFollowPositionList());
        });
  }

  Future<List<MyTraderEntity>?> _fetchTraderList() {
    return httpClientContract.request<List<MyTraderEntity>>(
      url: UrlConst.API_FOLLOW_FOLLOWER_TRADER_LIST,
      method: "POST",
      showErrorMessage: true,
    );
  }
}
