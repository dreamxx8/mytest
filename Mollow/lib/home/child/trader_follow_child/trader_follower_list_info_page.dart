
import 'package:coinw_flutter/bean/follow/tader_follower_entity.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/url_const.dart';
import 'package:module_core/core/net/http_client.dart';
import 'package:module_core/core/utils/collection_utils.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/empty_widget.dart';
import 'package:module_core/widget/list_divider_widget.dart';
import 'package:module_follow/home/widget/item/follower_list_item.dart';

///主页跟随者 显示前50名
class TraderFollowerListInfoPage extends StatefulWidget {
  static const String routeName = "TraderFollowerListInfoPage";
  final String leaderId;

  static void start(BuildContext context) {
    Navigator.pushNamed(context, routeName);
  }

  const TraderFollowerListInfoPage({Key? key, required this.leaderId}) : super(key: key);

  @override
  State<TraderFollowerListInfoPage> createState() => _TraderFollowerListInfoPageState();
}

class _TraderFollowerListInfoPageState extends State<TraderFollowerListInfoPage>
    with _FollowerListInfoPageBloc, AutomaticKeepAliveClientMixin {

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
    return ListView.separated(
      itemBuilder: _item,
      //physics: const ClampingScrollPhysics(),
      separatorBuilder: (context, index){
        return ListDividerWidget();
      },
      itemCount: dataList.isNotEmpty ? dataList.length + 1 : 1,
    );
  }

  Widget _item(context, index){
    if(dataList.isEmpty){
      return Container(
          height: 250,
          child: EmptyWidget());
    }
    if(index == 0){
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        ///仅显示排名前 50 的用户
        child: Text(S.of(context).follow_trader_list_header_hint, style: StRegular(12, text_main2),),
      );
    }
    TaderFollowerEntity followerEntity = dataList[index - 1];
    return FollowerListItem(followerEntity);
  }
  @override
  bool get wantKeepAlive => true;

}

mixin _FollowerListInfoPageBloc on State<TraderFollowerListInfoPage> {
  bool _isInitialized = false;
  List<TaderFollowerEntity> dataList = [];
  _init() {
    _getFollowerData();
  }


  _getFollowerData(){
    Map<String, dynamic> params = {};
    params["leaderId"] = widget.leaderId;
    httpClientContract.post<List<TaderFollowerEntity>>(
        url: UrlConst.API_FOLLOW_LEADER_FOLLOW_LIST,
        parameters: params,
        showErrorMessage: true,
        onSuccess: (resp) {
          if (resp != null) {
            setState(() {
              dataList = resp;
            });
          }
        });
  }
}
