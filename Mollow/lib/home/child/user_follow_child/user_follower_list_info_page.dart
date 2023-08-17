
import 'package:coinw_flutter/bean/follow/follow_my_profit_entity.dart';
import 'package:coinw_flutter/bean/follow/tader_follower_entity.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/url_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/net/http_client.dart';
import 'package:module_core/core/utils/event_bus_utils.dart';
import 'package:module_core/core/utils/scroll_view.dart';
import 'package:module_core/core/utils/system_utils.dart';
import 'package:module_core/widget/custom_refresher_widget.dart';
import 'package:module_core/widget/empty_widget.dart';
import 'package:module_follow/home/widget/item/user_follower_item.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

///跟随者
class UserFollowerListInfoPage extends StatefulWidget {
  static const String routeName = "FollowerListInfoPage";

  static void start(BuildContext context) {
    Navigator.pushNamed(context, routeName);
  }

  const UserFollowerListInfoPage({Key? key}) : super(key: key);

  @override
  State<UserFollowerListInfoPage> createState() => _UserFollowerListInfoPageState();
}

class _UserFollowerListInfoPageState extends State<UserFollowerListInfoPage>
    with _UserFollowerListInfoPageBloc, AutomaticKeepAliveClientMixin {

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
      enablePullUp: _isLoadMore,
      footer: customRefresherFooter(context),
      header: customRefresherHeader(context),
      onRefresh: () {
        _refresh();
      },
      onLoading: () {
        _onLoad();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: ListView.builder(
          physics: DefScrollPhysics.def,
          itemBuilder: _item,
          itemCount: _dataList.isEmpty ? 1 : _dataList.length,
        ),
      ),
    );
  }

  Widget _item(context, index){
    if(_dataList.isEmpty){
      return Container(
          height: 250,
          child: EmptyWidget());
    }
    FollowMyProfitEntity followerEntity = _dataList[index];
    return UserFollowerItem(followerEntity, settingCallBack: (follower){
      //跟随设置
    },);
  }

  @override
  bool get wantKeepAlive => true;
}

mixin _UserFollowerListInfoPageBloc on State<UserFollowerListInfoPage> {
  bool _isInitialized = false;
  List<FollowMyProfitEntity> _dataList = [];
  int _page = 1;
  bool _isLoadMore = true;

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  _init() {
    _refresh();
    ///跟单设置后回调
    eventBus.on<EventFollowSettingCallback>().listen((event) {
      _refresh();
    });
  }

  _refresh() {
    _dataList.clear();
    _page = 1;
    _getFollowerData();
  }

  _onLoad() {
    _page++;
    _getFollowerData();
  }

  _getFollowerData(){
    Map<String, dynamic> params = {};
    params[RequestConst.PAGE_SIZE] = 10;
    params["page"] = _page;
    httpClientContract.post<List<FollowMyProfitEntity>>(
        url: UrlConst.API_FOLLOW_MY_LEADER_LIST,
        parameters: params,
        showErrorMessage: true,
        parseKey: CommonConst.ROWS_PAGE,
        onSuccess: (resp) {
          if (resp != null) {
            if(_page == 1){
              _dataList = resp;
            }else{
              _dataList.addAll(resp);
            }
            if(resp.length < 10){
              _isLoadMore = false;
            }else{
              _isLoadMore = true;
            }
            setState(() {});
          }
          SystemUtils.endRefresh(_refreshController);
        },
        onError:  (e){
          SystemUtils.endRefresh(_refreshController);
        }
    );
  }

}
