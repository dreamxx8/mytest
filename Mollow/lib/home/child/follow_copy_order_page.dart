
import 'dart:ffi';

import 'package:coinw_flutter/bean/follow/follow_leader_profit_entity.dart';
import 'package:coinw_flutter/bean/follow/follow_trader_entity.dart';
import 'package:coinw_flutter/bean/follow/follow_user_info_entity.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/config/app_config.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/url_const.dart';
import 'package:module_core/core/net/http_client.dart';
import 'package:module_core/core/utils/event_bus_utils.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/custom_tab_bar.dart';
import 'package:module_follow/home/child/trader_follow_child/trader_current_order_child_page.dart';
import 'package:module_follow/home/child/trader_follow_child/trader_follower_like_list_page.dart';
import 'package:module_follow/home/child/trader_follow_child/trader_follower_list_info_page.dart';
import 'package:module_follow/home/child/trader_follow_child/trader_history_order_child_page.dart';
import 'package:module_follow/home/child/trader_follow_my_self_child/trader_my_self_follower_list_info_page.dart';
import 'package:module_follow/home/child/trader_follow_my_self_child/trader_my_self_history_order_child_page.dart';
import 'package:module_follow/home/child/widget/copy_trader_my_data_widget.dart';
import 'package:module_follow/home/follow_copiers_detail_page.dart';

import 'trader_follow_my_self_child/trader_my_self_current_order_child_page.dart';


///我的跟随
class FollowCopyOrderPage extends StatefulWidget {
  static const String routeName = "FollowCopyOrderPage";
  final String leaderId;
  final FollowUserInfoEntity? followUserInfo;
  final FollowTraderEntity? traderEntity;

  static void start(BuildContext context) {
    Navigator.pushNamed(context, routeName);
  }

  const FollowCopyOrderPage({Key? key,required this.leaderId, this.followUserInfo, this.traderEntity}) : super(key: key);

  @override
  State<FollowCopyOrderPage> createState() => _FollowCopyOrderPageState();
}

class _FollowCopyOrderPageState extends State<FollowCopyOrderPage>
    with _FollowCopyOrderPageBloc,SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin {

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      _isInitialized = true;
      _init();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: _offset,
          ),
          isMySheet ? CopyTraderMyDataWidget(profitEntity: _profit, key: hkey,): Container(),
          CustomTabBar(
            controller: _tabController,
            indicatorColor: Colors.transparent,
            fontSize: 14,
            tabs: _tabs.map((e) => Tab(text: e)).toList(),
            isScrollable: true,
            labelPadding: const EdgeInsets.only(right: 10),
          ),
          Expanded(child: _tabBarView())
          ,
        ],
      ),
    );
    // return Container(
    //   padding: const EdgeInsets.symmetric(horizontal: 15),
    //   child: ListView.builder(
    //     itemBuilder: _itemBuilder,
    //     itemCount: 30,
    //   ),
    // );
    // return Container(
    //   padding: const EdgeInsets.symmetric(horizontal: 15),
    //   child: NestedScrollView(
    //     controller: _scrollController,
    //     headerSliverBuilder: (context, innerBoxIsScrolled) {
    //       return [
    //         SliverList(delegate: SliverChildListDelegate(
    //           [
    //             // Container(
    //             //   padding: const EdgeInsets.symmetric(vertical: 10),
    //             //   child: Text("更新时间"),
    //             // ),
    //             isMySheet ? CopyTraderMyDataWidget(profitEntity: _profit, key: hkey,): Container(),
    //           ]
    //         )),
    //         SliverPersistentHeader(
    //           delegate: SliverTabBarDelegate(
    //               CustomTabBar(
    //                 controller: _tabController,
    //                 indicatorColor: Colors.transparent,
    //                 fontSize: 14,
    //                 tabs: _tabs.map((e) => Tab(text: e)).toList(),
    //                 isScrollable: true,
    //                 labelPadding: const EdgeInsets.only(right: 10),
    //               ),
    //               color: white
    //           ),
    //           pinned: true,
    //         ),
    //       ];
    //     },
    //     body: _tabBarView(),
    //   ),
    // );

  }


  _tabBarView() {

    return TabBarView(
      controller: _tabController,
      //physics: NeverScrollableScrollPhysics(),
      children: tabBarWidgets(),
    );
  }

  List<Widget> tabBarWidgets(){
    List<Widget> list = [];
    if(isMySheet){
      list.add(TraderMySelfCurrentOrderChildPage(leaderId: widget.leaderId,));
      list.add(TraderMySelfHistoryOrderChildPage(leaderId: widget.leaderId,));
      list.add(TraderMySelfFollowerListInfoPage());
      list.add(TraderFollowerLikeListPage(leaderId: widget.leaderId));

    }else{
      list.add(TraderCurrentOrderChildPage(leaderId: widget.leaderId, isBinding: widget.traderEntity?.isBinding ?? 0));
      list.add(TraderHistoryOrderChildPage(leaderId: widget.leaderId,));
      list.add(TraderFollowerListInfoPage(leaderId: widget.leaderId,));
      list.add(TraderFollowerLikeListPage(leaderId: widget.leaderId,));
    }
    return list;
  }


  @override
  bool get wantKeepAlive => true;
}

mixin _FollowCopyOrderPageBloc on State<FollowCopyOrderPage> {
  bool _isInitialized = false;
  late TabController _tabController;
  late List _tabs;
  final _scrollController = ScrollController();
  FollowLeaderProfitEntity? _profit;
  UniqueKey hkey = UniqueKey();
  double _offset = 0.0;
  _init() {
    ///"持仓订单", "历史订单", "跟随者", "关注者"
    _tabs = [S.of(context).follow_position_order, S.of(context).follow_order_history, S.of(context).follow_copies, S.of(context).follow_focus_user];
    _loadLaderData();
    eventBus.on<EventLoginSuccessCallback>().listen((event) {
      _loadLaderData();
    });

    eventBus.on<EventFollowTabHeaderOffset>().listen((event) {
      if(mounted){
        setState(() {
          //print("EventFollowTabHeaderOffset = ${event.offset}");
          _offset = event.offset;
        });
      }
    });
  }
  ///是否是我的主页
  bool get isMySheet {
    if(widget.followUserInfo != null){
      return widget.followUserInfo?.userId == widget.leaderId;
    }
    return false;
  }

  _loadLaderData(){

    Map<String, dynamic> params = {};
    httpClientContract.post<FollowLeaderProfitEntity>(
        url: UrlConst.API_FOLLOW_LEADER_PROFIT,
        parameters: params,
        showErrorMessage: false,
        showLoading: false,
        showLoginDialog: false,
        onSuccess: (resp) {
          setState(() {
            _profit = resp;
          });
        });

  }

}
