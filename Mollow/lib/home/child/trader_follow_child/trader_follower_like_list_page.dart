

import 'package:coinw_flutter/bean/follow/tader_follower_entity.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/url_const.dart';
import 'package:module_core/core/net/http_client.dart';
import 'package:module_core/core/utils/collection_utils.dart';
import 'package:module_core/core/utils/system_utils.dart';
import 'package:module_core/widget/custom_refresher_widget.dart';
import 'package:module_core/widget/empty_widget.dart';
import 'package:module_follow/home/widget/item/like_trader_item.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

///关注者
class TraderFollowerLikeListPage extends StatefulWidget {
  static const String routeName = "FollowerLikeListPage";
  final String leaderId;

  static void start(BuildContext context) {
    Navigator.pushNamed(context, routeName);
  }

  const TraderFollowerLikeListPage({Key? key, required this.leaderId}) : super(key: key);

  @override
  State<TraderFollowerLikeListPage> createState() => _TraderFollowerLikeListPageState();
}

class _TraderFollowerLikeListPageState extends State<TraderFollowerLikeListPage>
    with _FollowerLikeListPageBloc, AutomaticKeepAliveClientMixin {

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
        _getLikeData();
      },
      child: ListView.builder(
        shrinkWrap: true,
        //physics: const ClampingScrollPhysics(),
        itemBuilder: _item,
        itemCount: dataList.isNotEmpty?dataList.length:1,
      ),
    );
  }

  Widget _item(BuildContext context, index){
    if(dataList.isEmpty){
      return Container(
        height: 250,
          child: EmptyWidget());
    }
    return LikeTaderItem(dataList[index]);
  }

  @override
  bool get wantKeepAlive => true;


}

mixin _FollowerLikeListPageBloc on State<TraderFollowerLikeListPage> {
  bool _isInitialized = false;
  List<TaderFollowerEntity> dataList = [];
  final RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  _init() {
    _getLikeData();
  }

  _getLikeData(){
    Map<String, dynamic> params = {};
    params["leaderId"] = widget.leaderId;
    httpClientContract.post<List<TaderFollowerEntity>>(
        url: UrlConst.API_FOLLOW_LEADER_FOCUS,
        parameters: params,
        showErrorMessage: true,
        showLoginDialog: false,
        onSuccess: (resp) {
          SystemUtils.endRefresh(_refreshController);
          if (CollectionUtils.isNotBlank(resp)) {
            setState(() {
              if(resp != null){
                setState(() {
                  dataList = resp!;
                });
              }
            });
          }
        },
      onError: (e){
        SystemUtils.endRefresh(_refreshController);
      }
      );
  }
}
