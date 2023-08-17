

import 'package:coinw_flutter/bean/follow/follow_config_entity.dart';
import 'package:coinw_flutter/bean/follow/follow_trader_entity.dart';
import 'package:coinw_flutter/bean/follow/follow_user_info_entity.dart';
import 'package:coinw_flutter/modules/common/enum/assets_enum.dart';
import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:coinw_flutter/modules/common/them/global_color_manager.dart';
import 'package:coinw_flutter/modules/example/test_page.dart';
import 'package:flutter/material.dart';
import 'package:module_contract_service/data_center/contract_data_center.dart';
import 'package:module_core/core/config/app_config.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/url_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/manager/assets_manager.dart';
import 'package:module_core/core/net/http_client.dart';
import 'package:module_core/core/utils/common_share.dart';
import 'package:module_core/core/utils/event_bus_utils.dart';

import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_core/core/utils/string_utils.dart';
import 'package:module_core/core/utils/system_utils.dart';
import 'package:module_core/core/ws/subscribe_type.dart';
import 'package:module_core/core/ws/web_socket_manager.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/custom_app_bar.dart';
import 'package:module_core/widget/custom_tab_bar.dart';
import 'package:module_core/widget/custom_toast.dart';
import 'package:module_follow/common/follow_action_manager.dart';
import 'package:module_follow/common/follow_manager.dart';
import 'package:module_follow/home/child/follow_copy_order_page.dart';
import 'package:module_follow/home/child/follow_over_view_page.dart';
import 'package:module_follow/home/child/follow_stats_data_page.dart';
import 'package:module_follow/home/widget/follow_bottom_widget.dart';
import 'package:module_follow/home/widget/follow_header_data_widget.dart';
import 'package:module_follow/home/widget/follow_header_desc_widget.dart';
import 'package:module_follow/home/widget/follow_header_info_widget.dart';
import 'package:module_core/widget/custom_widget.dart';
import 'package:module_follow/home/widget/follow_header_warning_widget.dart';
import 'package:module_follow/home/widget/follow_my_cancel_alert_widget.dart';
import 'package:module_follow/home/widget/follow_my_cancel_verify_widget.dart';
import 'package:module_follow/home/widget/share/trader_share_widget.dart';



const url = 'http://www.pptbz.com/pptpic/UploadFiles_6909/201203/2012031220134655.jpg';

class FollowTraderDetailPage extends StatefulWidget {

  static const String routeName = "FollowTraderDetailPage";
  final String leaderId;
  bool isNative;
  static void start(BuildContext context, {String? leaderId}) {
    Navigator.pushNamed(context, routeName, arguments: leaderId);
  }

  FollowTraderDetailPage({Key? key, required this.leaderId, this.isNative = false}) : super(key: key);

  @override
  _FollowTraderDetailPageState createState() => _FollowTraderDetailPageState();
}

class _FollowTraderDetailPageState extends State<FollowTraderDetailPage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin, _FollowTraderDetailPageBloc{

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    print("FollowTraderDetailPage leaderId = ${widget.leaderId}");
    _tabController.addListener(() {
      _tabController.index == 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(!_isInitialized){
      _isInitialized = true;
      _init();
    }
    return DefaultTabController(
        length: _tabs.length,
        child: Scaffold(
          appBar: CustomAppBar(
            context,
            ///我的主页：交易员
            title: isMySheet?S.of(context).follow_my_home_page:S.of(context).bbs_mine_notice_traders,
            rightWidget: _popupMenu(),
            backAction: (){
              if (widget.isNative) {
                SystemUtils.backToSystomApp();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          body:Column(
            children: [
              Expanded(
                child: NestedScrollView(
                  controller: _scrollController,
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverList(
                          key:_keyGreen,
                          delegate: SliverChildListDelegate(
                              [
                            _getWarningWidget(),
                            FollowHeaderInfoWidget(
                              traderEntity: _traderEntity,
                            ),
                            FollowHeaderDataWidget(traderEntity: _traderEntity),
                            customLine(
                                height: 9,
                                color: globalColorManager.dividerColor),
                            FollowHeaderDescWidget(
                              labelNote: _traderEntity?.labelNote,
                              country: _traderEntity?.country,
                              buttonClickCallBack: () {
                                // _getPosition();
                              },
                            ),
                          ])),
                     SliverPersistentHeader(
                        delegate: SliverTabBarDelegate(
                            _tabBar(),
                            color: globalColorManager.scaffoldBackgroundColor),
                        pinned: true,
                      ),
                      i!= 0?   SliverList(delegate: SliverChildListDelegate(
                          [
                              const FollowHeaderDescWidget(),
                              customLine(
                                  height: 9,
                                  color: globalColorManager.dividerColor),
                            ])):
                      SliverList(delegate: SliverChildListDelegate(
                          [

                          ]
                      )),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: tabBarWidgets(),
                  ),
                ),
              ),
              FollowBottomWidget(_traderEntity, _followUserInfo, key: _bottomKey,)
            ],
          ),

        ));
  }

  CustomTabBar _tabBar(){
    CustomTabBar tabbar = CustomTabBar(
      controller: _tabController,
      indicatorColor: Colors.transparent,
      fontSize: 16,
      tabs: _tabs.map((e) => Tab(text: e)).toList(),
      isScrollable: true,
      textStyle: StBold(16, text_main),
      labelPadding: EdgeInsets.only(left: 15, right: 10),
    );
    tabBarHeight =  tabbar.preferredSize.height;
    return tabbar;
  }

  Widget _getWarningWidget(){
    if(!isMySheet&&StringUtils.isNotBlank(_traderEntity?.warningContent)){
      return FollowHeaderWarningWidget(content: _traderEntity!.warningContent!,);
    }
    return Container();
  }

  List<Widget> tabBarWidgets(){
    List<Widget> list = [];
    list.add(FollowOverViewPage(leaderId: widget.leaderId, traderEntity: _traderEntity,));
    list.add(FollowStatsDataPage(leaderId:  widget.leaderId, traderEntity: _traderEntity,));
    list.add(FollowCopyOrderPage(leaderId: widget.leaderId, followUserInfo: _followUserInfo, traderEntity: _traderEntity));
    return list;
  }

  bool get isMySheet {
    if(_followUserInfo != null){
      return _followUserInfo?.userId == widget.leaderId;
    }
    return false;
  }

  Widget _popupMenu(){
    if(!isMySheet){
      return InkWell(
        onTap: (){
          if(_traderEntity != null){
            CommonShareWidget.showCommonShare(context, shareWidget: TraderShareWidget(_traderEntity!));
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          child: Image.asset(
            ImageSourceConst.FOLLOW_USER_SHARE,
            width: 15,
            height: 15,
            color: globalColorManager.imageThemColor(),
          ),
        ),
      );
    }
    return PopupMenuButton<String>(
      offset:const Offset(20, 30),
      onSelected: (String value) {
        if(value == _menuItems[0]){
          FollowActionManager.pushUserEditInfo(context);
        }else if(value == _menuItems[1]){
          if(_traderEntity != null){
            CommonShareWidget.showCommonShare(context, shareWidget: TraderShareWidget(_traderEntity!));
          }
        }else if(value == _menuItems[2]){
          _alertView();
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
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        child: Image.asset(
          ImageSourceConst.ICON_MENU,
          width: 15,
          height: 15,
          color: globalColorManager.imageThemColor(),
        ),
      ),
    );
  }
  //取消交易员
  _alertView(){
    Map<String, dynamic> params = {};
    //params["leaderId"] = _followUserInfo?.userId;
    httpClientContract.post<FollowConfigEntity>(
        url: UrlConst.API_FOLLOW_LEADER_CONFIG,
        parameters: params,
        showErrorMessage: true,
        showLoading: true,
        onSuccess: (resp) {
          if(resp != null){
            FollowMyCancelAlertWidget(resp, onPress: (){
              _senMsg();
            },).show(context);
          }
        });

  }

  _senMsg(){
    Map<String, dynamic> params = {};
    params["leaderId"] = _followUserInfo?.userId;
    httpClientContract.post<Map>(
        url: UrlConst.API_FOLLOW_LEADER_CANCEL,
        parameters: params,
        showErrorMessage: true,
        showLoading: true,
        onSuccess: (resp) {
          if(resp != null){
            FollowMyCancelVerifyWidget(type: resp["msgType"], userInfo: resp["userInfo"], callBack: (code){
              _cancelLeader(code);
            },).show(context);
          }
        });

  }


  //取消
  _cancelLeader(String code) {
    Map<String, dynamic> params = {};
    params["leaderId"] = _followUserInfo?.userId;
    params["verificationCode"] = code;
    httpClientContract.post<Map>(
        url: UrlConst.API_FOLLOW_CANCEL_LEADER_IDENTITY,
        parameters: params,
        showErrorMessage: true,
        showLoading: true,
        onSuccess: (resp) {
          Navigator.pop(context);
          ///取消成功
          CustomToast.show(S.of(context).assets_bill_cancel_success);
          _goback();
        });
  }

  _goback(){
    Future.delayed(Duration(microseconds: 1), (){
      FollowActionManager.popRootView();
    });
  }


  @override
  bool get wantKeepAlive => true;

}

mixin _FollowTraderDetailPageBloc on State<FollowTraderDetailPage> {
  bool _isInitialized = false;
  late List _tabs;
  FollowTraderEntity? _traderEntity;
  late TabController _tabController;
  int i = 0;
  FollowUserInfoEntity? _followUserInfo;
  late List<String> _menuItems;
  UniqueKey _bottomKey = UniqueKey();
  ScrollController _scrollController = ScrollController();
  GlobalKey _keyGreen = GlobalKey();
  //tabbar 的offset
  double offsetY = 1000;
  double tabBarHeight = 48;
  _init() {
    ///"概述", "统计数据", "带单"
    _tabs = [S.of(context).follow_stats, S.of(context).follow_over, S.of(context).follow_with_single];
    ///"编辑", "分享", "取消交易员"
    _menuItems = [S.of(context).otc_edit, S.of(context).follow_share, S.of(context).follow_cancel_trader_status];
    contractDataCenter.start();
    _getFollowerInfo();
    eventBus.on<EventFollowRefreshTraderDetail>().listen((event) {
      _loadData();
    });
    ///登录成功后回调
    eventBus.on<EventLoginSuccessCallback>().listen((event) {
      _getFollowUserInfo();
    });
    ///跟单设置后回调
    eventBus.on<EventFollowSettingCallback>().listen((event) {
      _getFollowerInfo();
    });

    _scrollController.addListener(() {
      _notificationHeader();
    });
    _getPosition();
  }
  double _currentOffset = 0.0;
  _notificationHeader() {
    print("_scrollController.offset ${_scrollController.offset}   ${offsetY}" );
    if(_scrollController.offset>offsetY && (_scrollController.offset - offsetY) < tabBarHeight ){
      //print(_scrollController.offset - offsetY);
      double offset = _scrollController.offset - offsetY;
      if(offset < 0) offset = 0;
      if(offset > tabBarHeight) offset = tabBarHeight;
      _currentOffset = offset;
      eventBus.fire(EventFollowTabHeaderOffset(offset));
    }
    if(_scrollController.offset<=offsetY && _currentOffset>0){
      _currentOffset = 0;
      eventBus.fire(EventFollowTabHeaderOffset(_currentOffset));
    }
    // if(_scrollController.offset>=offsetY && _currentOffset<tabBarHeight){
    //   _currentOffset = tabBarHeight;
    //   eventBus.fire(EventFollowTabHeaderOffset(_currentOffset));
    // }
  }

  _getPosition() {
    Future.delayed(Duration(milliseconds: 200), (){
      final RenderObject? renderBox = _keyGreen.currentContext?.findRenderObject();
      final positionGreen = renderBox?.paintBounds;
      print("POSITION of green: $positionGreen");
      offsetY = (positionGreen?.height ?? 1000.0);
      _notificationHeader();
    });
  }

  ///获取跟单用户信息
  _getFollowerInfo() async {
    _followUserInfo = await AppConfig.getFollowUserInfo();
    setState(() {});
    _loadData();
  }

  _getFollowUserInfo(){
    assetsManager.checkContractStatus(statusBlock: (status){
      if(status == ContractAccountStatus.OPENED){
        httpClientContract.post<FollowUserInfoEntity>(
            url: UrlConst.API_FOLLOW_GET_USER_INFO,
            showLoading: true,
            showErrorMessage: true,
            showLoginDialog: false,
            onSuccess: (resp) {
              _followUserInfo = resp;
              _loadData();
            },
            onError: (error){
              print("getUserInfo error = ${error?.msg}");
            }
        );
      }
    });

  }


  _loadData(){
    Map<String, dynamic> params = {};
    params["leaderId"] = widget.leaderId;
    if(_followUserInfo != null){
      params["userId"] = _followUserInfo?.userId;
    }
    httpClientContract.post<FollowTraderEntity>(
        url: UrlConst.API_FOLLOW_LEADER_DETAIL,
        parameters: params,
        showErrorMessage: true,
        showLoginDialog: false,
        onSuccess: (resp) {
          _traderEntity = resp;
          setState(() {});
          eventBus.fire(EventFollowUserId(_traderEntity?.uid ?? ""));
          _getPosition();
        });

  }

}

class SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar widget;
  final Color color;

  const SliverTabBarDelegate(this.widget, {required this.color}) : assert(widget != null);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      child: widget,
      color: color,
    );
  }

  @override
  bool shouldRebuild(SliverTabBarDelegate oldDelegate) {
    return false;
  }

  @override
  double get maxExtent => widget.preferredSize.height;

  @override
  double get minExtent => widget.preferredSize.height;
}

