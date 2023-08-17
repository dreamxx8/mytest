
import 'package:coinw_flutter/bean/follow/follow_config_entity.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/big_button.dart';
import 'package:module_core/widget/custom_dialog.dart';

/// 通用dialog
class FollowMyCancelAlertWidget extends StatefulWidget {

  FollowConfigEntity followConfig;
  VoidCallback? onPress;
  FollowMyCancelAlertWidget(this.followConfig,
      {Key? key,this.onPress}) : super(key: key);

  @override
  _FollowMyCancelAlertWidgetState createState() => _FollowMyCancelAlertWidgetState();

  void show(BuildContext context, {VoidCallback? onPress}) {
    showDialog(context: context, builder: (context) => this);
  }
}

class _FollowMyCancelAlertWidgetState extends State<FollowMyCancelAlertWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x01000000),
      body: AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
          scrollable: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Stack(
            children: [
              Container(
                color: white,
                // padding: EdgeInsets.symmetric(horizontal: 0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      ///取消交易员身份
                      child: Text(S.of(context).follow_cancel_trader_status,
                          style: StMedium(18, text_main),
                          textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 10),
                    _alertView(),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: BigButton(

                            onPressed: () {
                              if(widget.onPress != null){
                                widget.onPress!();
                              }
                              Navigator.pop(context);
                            },
                            text: S.of(context).follow_cancel_trader_status,
                            option: BigBtnOption(isEnable:_canCancel()),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
             Positioned(right: 0, child: _iconClose())
            ],
          )),
    );
  }

  Widget _iconClose() {
    return InkWell(
      child: Image.asset(
        ImageSourceConst.ICON_CLOSE,
        width: 16,
        height: 16,
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }


  _canCancel(){
    return widget.followConfig.openFollow == 0 && widget.followConfig.status == 0;
  }

  _alertView(){
    return  Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(S.of(context).follow_without_orders, style: StRegular(14, text_main2),)),
              const SizedBox(width: 15,),
              Image.asset(widget.followConfig.openFollow == 0 ? ImageSourceConst.FOLLOW_SETTING_SUCCESS:ImageSourceConst.FOLLOW_SETTING_FAIL, width: 16, height: 16,),
            ],
          ),
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ///已关闭带单功能
              Expanded(child: Text(S.of(context).follow_disabled_function, style: StRegular(14, text_main2),)),
              const SizedBox(width: 15,),
              Image.asset(widget.followConfig.status == 0 ? ImageSourceConst.FOLLOW_SETTING_SUCCESS:ImageSourceConst.FOLLOW_SETTING_FAIL, width: 16, height: 16,),
            ],
          )
        ],
      ),
    );
  }
}
