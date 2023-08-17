
import 'dart:async';

import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:coinw_flutter/modules/common/them/global_color_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_core/core/utils/other/comma_text_input_formatter.dart';
import 'package:module_core/widget/big_button.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/custom_dialog.dart';
import 'package:module_follow/home/follow_settings/widget/follow_textfield_widget.dart';
import 'package:sprintf/sprintf.dart';


///指定杠杆倍数
showTextFieldAlert(BuildContext context, String title, TextEditingController controller,
    { String? hint,
      String? tag,
      VoidCallback? confirmClick,
      TextInputType? keyboardType,
      Key? key}){
  Widget content = FollowSettingAlertWidget(title, controller, tag: tag, hint: hint,confirmClick: confirmClick, keyboardType: keyboardType, key: key,);
  CustomDialog(
    key: key,
    content: content,
    confirmButtonMsg: S.of(context).common_confirm,
    confirmCallback: (){
      if(confirmClick != null){
        confirmClick();
      }
    },
  ).show(context);
}

class FollowSettingAlertWidget extends StatefulWidget {
  FollowSettingAlertWidget(this.title, this.controller,
      {this.hint,
        this.tag,
        this.confirmClick,
        this.keyboardType,
      Key? key})
      : super(key: key);
  String title;
  TextEditingController controller;
  String? hint;
  String? tag;
  VoidCallback? confirmClick;
  TextInputType? keyboardType;

  Future<bool> show(BuildContext context) {
    var completer = Completer<bool>();
    showDialog(context: context, builder: (context) => this);
    return completer.future;
  }

  @override
  State<FollowSettingAlertWidget> createState() => _FollowSettingAlertWidgetState();
}

class _FollowSettingAlertWidgetState extends State<FollowSettingAlertWidget> {

  String? customHint;

  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if(widget.tag != null){
      customHint = sprintf(widget.tag!,[widget.controller.text.isNotEmpty ? widget.controller.text : "-"]);
      widget.controller.addListener(() {
        setState(() {
          customHint = sprintf(widget.tag!,[widget.controller.text.isNotEmpty ? widget.controller.text : "-"]);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0x01000000),
      body: AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(15, 15, 15, 15),
          scrollable: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Stack(
            children: [
              Container(
                color: white,
                // padding: EdgeInsets.symmetric(horizontal: 0.w),
                child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.title, style: StMedium(14, text_main),),
                            InkWell(
                              onTap: (){
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                left: 30, top: 5, bottom: 5),
                            child: Image.asset(
                                ImageSourceConst.LIVE_ALERT_CLOSE,
                                width: 14,
                                height: 14,
                                color: globalColorManager.imageThemColor()),
                          ),
                            )
                          ],
                        ),
                        const SizedBox(height: 24,),
                        FollowTextfiwldWidget(widget.controller, hint: widget.hint, keyboardType: widget.keyboardType, focusNode: focusNode,),
                        customHint != null ? Container(
                            padding: EdgeInsets.only(top: 9),
                            child: Text(customHint! , style: StRegular(12, text_main2),)) : Container(),
                        const SizedBox(height: 25,),
                        BigButton(onPressed: (){
                          focusNode.unfocus();
                          if(widget.confirmClick != null){
                            widget.confirmClick!();
                          }else{
                            Navigator.pop(context);
                          }
                        }, text: S.of(context).common_confirm)
                      ],
                    )
                ),
              ),
            ],
          )
      ),
    );
  }
}



