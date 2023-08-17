
import 'package:coinw_flutter/modules/common/them/global_color_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/big_button.dart';

class FollowAgreenWidgt extends StatefulWidget {
  FollowAgreenWidgt({Key? key, this.callBack}) : super(key: key);
  VoidCallback? callBack;
  @override
  State<FollowAgreenWidgt> createState() => _FollowAgreenWidgtState();
}

class _FollowAgreenWidgtState extends State<FollowAgreenWidgt> {

  bool _select = false;


  @override
  Widget build(BuildContext context) {
    
    return Container(
      height: ScreenUtil().screenHeight - 120,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: BoxDecoration(
          color: globalColorManager.scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
      child: Column(
        children: [
          Row(
            children: [
              ///跟单协议
              Expanded(child: Text(S.of(context).follow_protocol_title, style: StBold(18, text_main), textAlign: TextAlign.center,)),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  ImageSourceConst.LIVE_ALERT_CLOSE,
                  width: 14,
                  height: 14,
                  color: globalColorManager.imageThemColor(),
                ),
              )
            ],
          ),
          SizedBox(height: 10,),
          Expanded(child: ListView(
            children: [
              Text(S.of(context).contract_follow_protocol, style: StRegular(14, text_main),)
            ],
          )),
          SizedBox(height: 15,),
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                child: Checkbox(
                    activeColor: colorTheme,
                    value: _select, onChanged: (select){
                  setState(() {
                    _select = select ?? false;
                  });
                }),
              ),
              SizedBox(width: 10,),
              ///我已仔细阅读并愿承担风险
              Expanded(child: Text(S.of(context).follow_protocol_title_hint, style: StRegular(14, text_main2),))
            ],
          ),
          SizedBox(height: 15,),
          BigButton(onPressed: (){
            Navigator.pop(context);
            if(widget.callBack != null) {
              widget.callBack!();
            }
          }, text: S.of(context).follow_protocol_sure, option: BigBtnOption(isEnable: _select),)
        ],
      ),
    );
  }
}
