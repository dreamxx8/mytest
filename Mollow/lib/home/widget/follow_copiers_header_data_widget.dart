
import 'package:coinw_flutter/bean/follow/follow_my_profit_entity.dart';
import 'package:coinw_flutter/bean/follow/follow_user_info_entity.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/url_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/extension/string_extension.dart';
import 'package:module_core/core/net/http_client.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/custom_dialog.dart';

class FollowCopiersHeaderDataWidget extends StatelessWidget {

  final FollowMyProfitEntity? profitEntity;
  final FollowUserInfoEntity? followUserInfo;

  FollowCopiersHeaderDataWidget({Key? key, this.profitEntity, this.followUserInfo}) : super(key: key);

  Map? _shareMap;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text("更新时间 : 2023 10:10:10", style: StRegular(12, text_main2),),
          // const SizedBox(height: 12,),
          _dataWidget(context),
        ],
      ),
    );
  }

  _dataWidget(context){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 9),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child:  _dataItem("${S.of(context).follow_today_profit_all}(USDT)", (this.profitEntity?.todayProfit ?? "0").fixNumberTwoDecimal, "")),
              Container(
                width: 1,
                height: 50,
                color: text_main2.withOpacity(0.2),
                child: Row(),
              ),
              SizedBox(width: 12,),
              Expanded(child:_dataItem("${S.of(context).assets_earn_cumulative_income}(USDT)", (this.profitEntity?.cumulativeProfit ?? "0").fixNumberTwoDecimal, "")),
            ],
          ),
          const SizedBox(height: 5,),
          InkWell(
            onTap: (){
              _share(context);
            },
            child: Row(
              children: [
                ///交易员分成
                Text(S.of(context).follow_trader_rate, style: StMedium(12, text_main),),
                const SizedBox(width: 5,),
                Image.asset(ImageSourceConst.FOLLOW_OPERATION_ARROW, width: 12,height: 12,),
              ],
            ),
          )
        ],
      ),
    );
  }

  _dataItem(String title, String value, String subValue){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(title, style: StRegular(12, text_main),),
        const SizedBox(height: 6,),
        Text(value, style: StBold(18, text_main),),
        const SizedBox(height: 2,),
        //Text(subValue, style: StRegular(11, text_main2),),
      ],
    );
  }

  ///交易员
  _loadData(context) async {
    Map<String, dynamic> params = {};
    httpClientContract.post<Map>(
        url: UrlConst.API_FOLLOW_MY_LEADER_SHARE,
        parameters: params,
        showErrorMessage: true,
        showLoading: true,
        onSuccess: (resp) {
          if(resp != null){
            _shareMap = resp;
            _alertView(context);
          }
        });
  }

  _share(context){
    if(_shareMap != null){
      _alertView(context);
      return;
    }
    _loadData(context);
  }

  _alertView(BuildContext context){
    CustomDialog(
      ///"交易员分成"
      title: S.of(context).follow_trader_rate,
      confirmButtonMsg: S.of(context).otc_i_know,
      content: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ///待结算分成
                Container(width: 150 ,child: Text(S.of(context).follow_share_be_settled, style: StRegular(14, text_main2),)),
                Expanded(child: Text((_shareMap?["waitSettleShare"]) + " USDT", style: StMedium(14, text_main), textAlign: TextAlign.right,)),
              ],
            ),
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ///已结算分成
                Container(width: 150 ,child: Text(S.of(context).follow_settled_share, style: StRegular(14, text_main2),)),
                Expanded(child: Text((_shareMap?["alreadySettleShare"]) + " USDT", style: StMedium(14, text_main), textAlign: TextAlign.right,)),
              ],
            )
          ],
        ),
      ),

    ).show(context);
  }



}
