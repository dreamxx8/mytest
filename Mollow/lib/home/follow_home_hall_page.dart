

import 'package:coinw_flutter/bean/contract/bean/position_and_order_entity.dart';
import 'package:coinw_flutter/bean/contract/bean/product.dart';
import 'package:coinw_flutter/bean/follow/follow_trader_entity.dart';
import 'package:coinw_flutter/bean/follow/follow_user_info_entity.dart';
import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:coinw_flutter/modules/example/test_page.dart';
import 'package:flutter/material.dart';
import 'package:module_contract_service/data_center/contract_data_center.dart';
import 'package:module_contract_service/widget/modify_tp_sl/modify_tp_sl_widget.dart';
import 'package:module_core/core/config/app_config.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/url_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/net/http_client.dart';
import 'package:module_core/core/utils/collection_utils.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_core/core/utils/log_utils.dart';
import 'package:module_core/core/utils/sp_utils.dart';
import 'package:module_core/core/ws/web_socket_manager.dart';
import 'package:module_core/widget/big_button.dart';
import 'package:module_core/widget/bottom_pop_widget.dart';
import 'package:module_core/widget/custom_app_bar.dart';
import 'package:module_follow/home/follow_copiers_detail_page.dart';
import 'package:module_follow/home/follow_settings/follow_settings_page.dart';
import 'package:module_follow/home/follow_settings/widget/follow_password_alert.dart';
import 'package:module_follow/home/follow_trader_detail_page.dart';
import 'package:module_follow/home/widget/item/follow_list_item.dart';
///跟单大厅
class FollowHomeHallPage extends StatefulWidget {
  static const String routeName = "FlollwHomeHallPage";

  static void start(BuildContext context) {
    Navigator.pushNamed(context, routeName);
  }

  const FollowHomeHallPage({Key? key}) : super(key: key);

  @override
  State<FollowHomeHallPage> createState() => _FollowHomeHallPageState();
}

class _FollowHomeHallPageState extends State<FollowHomeHallPage>
    with _FlollwHomeHallPageBloc {

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
      wsManager.start();
    }
    return  Scaffold(
      appBar: CustomAppBar(
        context,
        title: "跟单大厅",
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: ListView.builder(
          itemBuilder: _item ,
          itemCount: _traderList.length + 1,
        ),
      ),
      floatingActionButton: _buildTestWidget(),
    );
  }

  Widget _item(BuildContext context, int index){
    if(index == 0){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5,),
          BigButton(onPressed: (){
            FollowCopiersDetailPage.start(context);
          }, text: "我的跟单"),
          const SizedBox(height: 15,),
          BigButton(onPressed: (){
            FollowTraderDetailPage.start(context, leaderId: _followUserInfoEntity?.userId);
          }, text: "我的带单"),
          const SizedBox(height: 15,),
          BigButton(onPressed: (){
            //FollowSettingsPage.start(context, "600003366");
            showBottomPop(
                context: context,
                bgColor: Colors.transparent,
                widget: FollowPasswordAlertWidget(confirmClick: (String password, int type, String code){

                },)
            );
          }, text: "跟单设置"),
        ],
      );
    }
    FollowTraderEntity traderEntity = _traderList[index - 1];
    return InkWell(
        onTap: () {
          FollowTraderDetailPage.start(context, leaderId: traderEntity.leaderId);
          //ModifyTP_SL_Widget.show(context, PositionAndOrderEntity(), Product(), isFollowOrder: true, isShowMoveTP_SL: true);
        },
        child: FollowListItem(
          traderEntity: traderEntity,
        ));
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
}

mixin _FlollwHomeHallPageBloc on State<FollowHomeHallPage> {
  bool _isInitialized = false;
  List<FollowTraderEntity> _traderList = [];
  FollowUserInfoEntity? _followUserInfoEntity;
  _init() {
    contractDataCenter.getInstrument().then((value) {
      Log.s("FollowHome", value.length.toString());
      Log.s("FollowHome", value[0].name);
    });
    contractDataCenter.start();
    _getTraderData();
    _getFollowUserInfo();
  }

  _getTraderData(){
    Map queryParameter = {};
    queryParameter["leaderKind"] = "1";
    Map<String, dynamic> params = {};
    params["page"] = 1;
    params["pageSize"] = 100;
    params["queryParameter"] = queryParameter;
    httpClientContract.post<List<FollowTraderEntity>>(
        url: UrlConst.API_FOLLOW_LEADER_LIST,
        parameters: params,
        showErrorMessage: true,
        parseKey: CommonConst.ROWS_PAGE,
        onSuccess: (resp) {
          if (CollectionUtils.isNotBlank(resp)) {
            setState(() {
              _traderList = resp!;
            });
          }
        });
  }

  _getFollowUserInfo() async{
    await httpClientContract.post<FollowUserInfoEntity>(
        url: UrlConst.API_FOLLOW_GET_USER_INFO,
        showLoading: true,
        showLoginDialog: false,
        onSuccess: (resp) {
          _followUserInfoEntity = resp;
          SPUtils.preferences.setString("user_follow_info_detail", _followUserInfoEntity.toString());
          print("getUserInfo resp = ${resp?.id}");
        },
        onError: (error){
          print("getUserInfo error = ${error?.msg}");
        }
    );
  }
}
