
import 'package:coinw_flutter/bean/follow/follow_assets_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:module_bbs/mine/bbs_mine_setting_page.dart';
import 'package:module_contract_service/wrap/position_wrap.dart';
import 'package:module_core/core/channel/invoke_native.dart';
import 'package:module_core/core/config/app_config.dart';
import 'package:module_core/core/constant/url_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/net/http_client.dart';
import 'package:module_core/core/utils/login_util.dart';
import 'package:module_core/widget/bottom_pop_widget.dart';
import 'package:module_follow/home/follow_settings/follow_settings_page.dart';
import 'package:module_follow/home/follow_settings/widget/follow_agreen_widget.dart';
import 'package:module_follow/home/trader_settings/trader_settings_page.dart';

class FollowActionManager{

  static void pushUserEditInfo(BuildContext context){
    BbsMineSettingPage.startFollow(context);
  }

  //跳转原生 今日预估分润
  static void pushLeaderTodayProfit(BuildContext context){
    InvokeNative.invoke(NativeMethodConst.METHOD_PUSH_TODAY_PROFIT);
  }

  //跳转原生 累计分润
  static void pushLeaderTotalProfit(BuildContext context){
    InvokeNative.invoke(NativeMethodConst.METHOD_PUSH_TOTAL_PROFIT);
  }

  // 跳转到跟随订单(带单详情)
  static void pushFollowOrder(BuildContext context, int? orderId, bool isHistory){
    if(orderId == null){
      return;
    }
    Map<String, dynamic> params = {"orderId": orderId, "isHistory": isHistory};
    InvokeNative.invoke(NativeMethodConst.METHOD_PUSH_FOLLOW_HISTORY, params);
  }

  // 跳转到跟随页面
  static void pushFollowTrader(BuildContext context, String leaderId){
    LoginUtil.isLoginAndDoSomething((){
      //InvokeNative.invoke(NativeMethodConst.SHOW_NATIVE_FOLLOW_SETTING, leaderId);
      ///获取账户信息
        Map<String, dynamic> params = {};
        httpClientContract.post<FollowAssetsEntity>(
            url: UrlConst.API_FOLLOW_CONTRACT_ACCOUNT,
            parameters: params,
            showErrorMessage: true,
            showLoading: true,
            onSuccess: (resp) {
              if(resp == null ){
                return;
              }
              if (resp.firstFollow == 1) {
                FollowSettingsPage.start(context, leaderId);
              } else {
                //弹出提示
                showBottomPop(
                    context: context,
                    bgColor: Colors.transparent,
                    widget: FollowAgreenWidgt(
                      callBack: () {
                        FollowSettingsPage.start(context, leaderId);
                      },
                    ));
              }
            },
            onError:  (e){
            }
        );
    });

  }

  // 跳转到申请交易员
  static void pushFollowApply(BuildContext context){
    LoginUtil.isLoginAndDoSomething((){
      InvokeNative.invoke(NativeMethodConst.METHOD_PUSH_FOLLOW_APPLY);
    });
  }

  // 跳转带单设置
  static void pushFollowLeaderSetting(BuildContext context, String? rate){
    //InvokeNative.invoke(NativeMethodConst.METHOD_PUSH_TRADER_SETTING, rate ?? "");
    TraderSettingsPage.start(context);
  }

  // 跳转合约交易
  static void pushFollowToContractTransction(BuildContext context, String? coinName){
    if(coinName == null){
      return;
    }
    InvokeNative.invoke(NativeMethodConst.METHOD_PUSH_CONTRACT_TRANSCATION, coinName);
  }

  //跳转导航首页
  static void popRootView(){
    InvokeNative.invoke(NativeMethodConst.METHOD_POP_ROOT_VIEW_CONTROLLER);
  }

}