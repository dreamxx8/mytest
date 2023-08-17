

import 'package:coinw_flutter/bean/follow/follow_trader_entity.dart';
import 'package:coinw_flutter/modules/common/web_view_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/channel/invoke_native.dart';
import 'package:module_core/core/config/app_config.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/url_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/extension/string_extension.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/custom_cached_network_image.dart';
import 'package:module_core/widget/custom_dialog.dart';
import 'package:module_follow/home/widget/follow_header_info_widget.dart';
import 'package:sprintf/sprintf.dart';

class FollowSettingsHeaderWidget extends StatelessWidget {
  FollowSettingsHeaderWidget({Key? key, this.followTrader}) : super(key: key);
  FollowTraderEntity? followTrader;
  @override
  Widget build(BuildContext context) {
    return Container(

      padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 20),
      child: Column(
        children: [
          _imageHeader(),
          const SizedBox(height: 20,),
          ///分润比例
          _itemWidget(context, S.of(context).follow_setting_dividend_ratio, _getRatio()),
          ///分润结算模式
          _itemWidget(context, S.of(context).follow_setting_dividend_mode, followTrader?.getShareTypeText(context) ?? "", tag: S.of(context).follow_setting_dividend_mode_desc),
          ///付费跟单
          followTrader?.payType == 1 ? _itemWidget(context, S.of(context).follow_setting_paid, followTrader?.payAmount ??"") : Container(),
        ],

      ),

    );
  }

  _getRatio(){
    if(followTrader != null && followTrader?.shareRate != null){
       return  followTrader!.shareRate!.percent + "%";
    }
    return '--';
  }

  _imageHeader(){
    return Row(
      children: [
        ///头像
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: CustomCachedNetworkImage(
            followTrader?.profileUrl ?? "",
            fit: BoxFit.cover,
            width: 60,
            height: 60,
            errorWidget: (context, error, stackTrace) => Image.asset(
              ImageSourceConst.IC_IMAGE_DEFAUT,
              width: 20,
              height: 20,
            ),
          ),
        ),
        const SizedBox(width: 9,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(followTrader?.nickName ?? "", style: StMedium(16, text_main),),
            const SizedBox(height: 6,),
            Text( followTrader?.country ?? "", style: StRegular(12, text_main2),),
          ],
        )
      ],
    );
  }

  _itemWidget(BuildContext context, String title, String value,{String? tag}){
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
              constraints: const BoxConstraints(
                  maxWidth: 150
              ),
              child: Text(title, style: StRegular(12, text_main2),)),
          // 分润模式说明暂时暂时不展示 23-07-04
          // tag !=null ?  InkWell(
          //   onTap: (){
          //     _alertViewShow(context, tag);
          //   },
          //   child: Container(
          //     padding: EdgeInsets.symmetric(horizontal: 6),
          //     child: Image.asset(ImageSourceConst.COMMON_ALERT_CION, width: 14, height: 14,),
          //   ),
          // ):Container(),
          Expanded(child: Text(value, style: StMedium(12, text_main),
            textAlign: TextAlign.right,),)
        ],
      ),
    );
  }

  /// 更多详细规则
  Future<void> _goProtocolWeb(BuildContext context) async {
    String? url = await InvokeNative.invoke(NativeMethodConst.METHOD_ZENDESK_WEB_URL, CommonConst.FOLLOW_SETTLEMENT_PARAM);
    if(url == null){
      return;
    }
    WebViewPage.start(context, url: url, showTitle: true);
  }
  
  _alertViewShow(BuildContext context, String tag){
    
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tag, style: StRegular(14, text_main),),
        const SizedBox(height: 10,),
        InkWell(
          onTap: (){
            _goProtocolWeb(context);
          },
          ///更多详细规则
          child: Text(S.of(context).follow_more_rule, style: StRegular(14, colorTheme),),
        ),

      ],
    );
    
    CustomDialog( content: content, confirmButtonMsg: S.of(context).otc_i_know,).show(context);
  }

}


