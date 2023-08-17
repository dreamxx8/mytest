
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/big_button.dart';
import 'package:module_core/widget/bottom_pop_widget.dart';
import 'package:module_core/widget/custom_text_field.dart';
import 'package:sprintf/sprintf.dart';

class FollowMyCancelVerifyWidget extends StatefulWidget {
  FollowMyCancelVerifyWidget({Key? key, this.type = 1, this.userInfo = "", this.callBack}) : super(key: key);
  ValueChanged<String>? callBack;
  @override
  State<FollowMyCancelVerifyWidget> createState() => _FollowMyCancelVerifyWidgetState();
  //1 手机 0 邮箱
  int type;
  String userInfo;

  void show(BuildContext context) {
    showBottomPop(context: context, isDismissible: false, widget: this);
  }
}

class _FollowMyCancelVerifyWidgetState extends State<FollowMyCancelVerifyWidget> {

  final TextEditingController _textEditingController = TextEditingController();
  FocusNode _focus = FocusNode();
  bool isEnable = false;
  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(() {
      if(_textEditingController.text.length >= 4){
        isEnable = true;
      }else{
        isEnable = false;
      }
      setState(() {});
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topRight: Radius.circular(12), topLeft:  Radius.circular(12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Spacer(),
              _iconClose(),
            ],
          ),
          Row(
            ///"短信验证":"邮箱验证"
            children: [
              Expanded(child: Text(widget.type == 1 ?S.of(context).assets_common_phone_verify:S.of(context).follow_email_verify, style: StMedium(18, text_main),textAlign: TextAlign.center,)),
            ],
          ),
          const SizedBox(height: 12,),
          Row(
            children: [
              Image.asset(ImageSourceConst.COMMON_VERIFY_CODE_ICON, width: 24, height: 24,),
              const SizedBox(width: 12,),
              Expanded(child: Text(_getSubTitle(), style: StRegular(14, text_main2),),),
            ],
          ),
          const SizedBox(height: 12,),
          ///请输入验证码
          CustomTextField(controller: _textEditingController, hint: S.of(context).assets_common_verify_code_hint, focusNode: _focus,),

           const SizedBox(height: 32,),
          SafeArea(
            child: BigButton(onPressed: (){
              //键盘消失
              _focus.unfocus();
              if(widget.callBack != null){
                widget.callBack!(_textEditingController.text);
              }
            }, text: S.of(context).common_confirm, option: BigBtnOption(isEnable: isEnable),),
          )
        ],
      ),
    );
  }

  String _getSubTitle(){
    if(widget.type == 1){
      ///"请输入您在手机 ${widget.userInfo} 收到的6位验证码"
      return sprintf(S.of(context).follow_verfiy_phone_hint, [widget.userInfo]);
    }else{
      ///"请输入您在邮箱 ${widget.userInfo} 收到的6位验证码"
      return sprintf(S.of(context).follow_verfiy_email_hint, [widget.userInfo]);

    }
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

}



