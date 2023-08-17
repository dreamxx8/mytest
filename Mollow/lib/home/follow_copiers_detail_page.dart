
import 'package:coinw_flutter/bean/follow/follow_my_profit_entity.dart';
import 'package:coinw_flutter/bean/follow/follow_trader_entity.dart';
import 'package:coinw_flutter/bean/follow/follow_user_info_entity.dart';
import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:coinw_flutter/modules/common/them/global_color_manager.dart';
import 'package:coinw_flutter/modules/example/test_page.dart';
import 'package:flutter/material.dart';
import 'package:module_contract_service/data_center/contract_data_center.dart';
import 'package:module_core/core/config/app_config.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/url_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/net/http_client.dart';

import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_core/core/utils/system_utils.dart';
import 'package:module_core/core/ws/web_socket_manager.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/big_button.dart';
import 'package:module_core/widget/custom_app_bar.dart';
import 'package:module_core/widget/custom_dialog.dart';
import 'package:module_core/widget/custom_tab_bar.dart';
import 'package:module_follow/common/follow_action_manager.dart';
import 'package:module_follow/common/follow_manager.dart';
import 'package:module_follow/home/child/follow_copy_order_page.dart';
import 'package:module_follow/home/child/follow_over_view_page.dart';
import 'package:module_follow/home/child/follow_stats_data_page.dart';
import 'package:module_follow/home/child/user_follow_child/user_current_order_child_page.dart';
import 'package:module_follow/home/child/user_follow_child/user_follower_like_list_page.dart';
import 'package:module_follow/home/child/user_follow_child/user_follower_list_info_page.dart';
import 'package:module_follow/home/child/user_follow_child/user_history_order_child_page.dart';
import 'package:module_follow/home/widget/follow_bottom_widget.dart';
import 'package:module_follow/home/widget/follow_copiers_header_data_widget.dart';
import 'package:module_follow/home/widget/follow_header_data_widget.dart';
import 'package:module_follow/home/widget/follow_header_desc_widget.dart';
import 'package:module_follow/home/widget/follow_header_info_widget.dart';
import 'package:module_core/widget/custom_widget.dart';
import 'package:module_follow/home/widget/follow_my_cancel_alert_widget.dart';
import 'package:module_follow/home/widget/follow_my_header_info_widget.dart';

const url = 'http://www.pptbz.com/pptpic/UploadFiles_6909/201203/2012031220134655.jpg';

class FollowCopiersDetailPage extends StatefulWidget {

  static const String routeName = "FollowCopiersDetailPage";

  static void start(BuildContext context) {
    Navigator.pushNamed(context, routeName);
  }
  bool isNative;
  FollowCopiersDetailPage({Key? key, this.isNative = false}) : super(key: key);

  @override
  _FollowCopiersDetailPageState createState() => _FollowCopiersDetailPageState();
}

class _FollowCopiersDetailPageState extends State<FollowCopiersDetailPage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin, _FollowCopiersDetailPageBloc{

  @override
  void initState() {
    super.initState();
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
            title: S.of(context).follow_my_follow,
            backAction: (){
              if (widget.isNative) {
                SystemUtils.backToSystomApp();
              } else {
                Navigator.pop(context);
              }
            },
            rightWidget: InkWell(
              onTap: (){
                FollowActionManager.pushUserEditInfo(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                child: Image.asset(
                  ImageSourceConst.FOLLOW_USER_EDIT,
                  width: 15,
                  height: 15,
                  color: globalColorManager.imageThemColor(),
                ),
              ),
            ),
          ),
          body:Column(
            children: [
              Expanded(
                child: NestedScrollView(
                  headerSliverBuilder: (context, bool) {
                    return [
                      SliverList(delegate: SliverChildListDelegate(
                          [
                        FollowMyHeaderInfoWidget(
                          followUserInfo: _followUserInfo,
                        ),
                        customLine(
                            height: 9, color: globalColorManager.dividerColor),
                        FollowHeaderDescWidget(
                          labelNote: _followUserInfo?.labelNote,
                          country: "",
                        ),
                        customLine(
                            height: 9, color: globalColorManager.dividerColor),
                        FollowCopiersHeaderDataWidget(
                          profitEntity: _profitEntity,
                          followUserInfo: _followUserInfo,
                        )
                      ])),
                      SliverPersistentHeader(
                        delegate: SliverTabBarDelegate(
                            CustomTabBar(
                              indicatorColor: Colors.transparent,
                              fontSize: 16,
                              tabs: _tabs.map((e) => Tab(text: e)).toList(),
                              isScrollable: true,
                              textStyle: StBold(14, text_main),
                            ),
                            color: globalColorManager.scaffoldBackgroundColor),
                        pinned: true,
                      ),
                    ];
                  },
                  body: TabBarView(
                    children: tabBarWidgets(),
                  ),
                ),
              ),
              _getBottomButton(),
            ],
          ),
          floatingActionButton: _buildTestWidget(),
        ));
  }

  List<Widget> tabBarWidgets(){
    List<Widget> list = [];
    list.add(const UserCurrentOrderChildPage());
    list.add(const UserHistoryOrderChildPage());
    list.add(const UserFollowerListInfoPage());
    list.add(const UserFollowerLikeListPage());
    return list;
  }

  ///底部按钮
  _getBottomButton() {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 15),
      child: Row(
        children: [
          Expanded(
              child: Container(
                decoration: RegularBorder(borderWidth: 2,backgroundColor: transparent, radius: 6.0, colorBorder: text_main),
                child: BigButton(
                  onPressed: () {
                    if (widget.isNative) {
                      SystemUtils.backToSystomApp();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  ///去跟单
                  text: S.of(context).follow_go_follow,
                  option: BigBtnOption(height: 38, radius: 6.0, bg: transparent, textStyle: StMedium(14, text_main)),
                ),
              )),
          const SizedBox(width: 15,),
          Expanded(
              child: BigButton(
            onPressed: () {
              FollowActionManager.pushFollowApply(context);
            },
                ///申请成为交易员
            text: S.of(context).follow_apply_to_trader,
            option: BigBtnOption(height: 42, radius: 6.0, textStyle: StMedium(14, white)),
          )),
        ],
      ),
    );
  }

  Widget _buildTestWidget() {
    if (!AppConfig.DEBUG) {
      return Container();
    }
    return InkWell(
      onTap: () {
        TestPage.start(context);
      },
      child: Container(
        alignment: Alignment.center,
        width: 44,
        height: 44,
        decoration: RegularRadius(radius: 22.0),
        child: Text(
          "Test",
          style: StMedium(16, background_main),
        ),
      ),
    );
  }







  @override
  bool get wantKeepAlive => true;

}

mixin _FollowCopiersDetailPageBloc on State<FollowCopiersDetailPage> {
  bool _isInitialized = false;
  late TabController _tabController;
  late List _tabs;
  FollowUserInfoEntity? _followUserInfo;
  FollowMyProfitEntity? _profitEntity;
  _init() {
    ///"当前跟单", "历史跟随", "我的跟随", "我的关注"
    _tabs = [S.of(context).follow_current_order, S.of(context).follow_current_order_history, S.of(context).follow_my_order_list, S.of(context).follow_my_foucs_list];
    contractDataCenter.start();
    _loadData();
  }

  _loadData() async {

    _followUserInfo = await AppConfig.getFollowUserInfo();
    Map<String, dynamic> params = {};
    httpClientContract.post<FollowMyProfitEntity>(
        url: UrlConst.API_FOLLOW_MY_FOLLOW_PROFIY,
        parameters: params,
        showErrorMessage: true,
        onSuccess: (resp) {
          if(resp != null){
            setState(() {
              _profitEntity = resp;
            });
          }
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

