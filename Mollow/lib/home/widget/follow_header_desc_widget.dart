
import 'dart:convert';
import 'dart:io';
import 'package:coinw_flutter/bean/follow/follow_trader_entity.dart';
import 'package:coinw_flutter/modules/common/them/global_color_manager.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:module_core/core/constant/url_const.dart';
import 'package:module_core/core/extension/string_extension.dart';
import 'package:module_core/core/net/http_client.dart';
import 'package:module_core/core/utils/collection_utils.dart';
import 'package:module_core/core/utils/string_utils.dart';
import 'package:module_international/generated/l10n.dart';
///个人简介
class FollowHeaderDescWidget extends StatefulWidget {
  const FollowHeaderDescWidget({Key? key, this.labelNote, this.country, this.buttonClickCallBack}) : super(key: key);
  final String? labelNote;
  final String? country;
  final VoidCallback? buttonClickCallBack;
  @override
  State<FollowHeaderDescWidget> createState() => _FollowHeaderDescWidgetState();
}

class _FollowHeaderDescWidgetState extends State<FollowHeaderDescWidget> {

  int? maxLine = 4;
  //是否已经翻译了
  bool _isTranslate = false;
  String? _translateString;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StringUtils.isNotBlank(widget.country) ? _headerTitle():Container(),
          SizedBox(height: StringUtils.isNotBlank(widget.country)?16:0,),
          Text(_getLabelNode(),
            style: StRegular(14, text_main),
            maxLines: maxLine,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: StringUtils.isNotBlank(widget.labelNote) ?16:0,),
          StringUtils.isNotBlank(widget.labelNote)?_buttons():Container(),
        ],
      ),


    );
  }


  _getLabelNode(){
    ///还没有简介哦
    if(_isTranslate){
      return StringUtils.isNotBlank(_translateString) ? _translateString! : S.of(context).follow_no_inroduction_yet;
    }else{
      return StringUtils.isNotBlank(widget.labelNote) ? widget.labelNote! : S.of(context).follow_no_inroduction_yet;
    }
  }
  
  Widget _headerTitle(){
    return Row(
      children: [
        Image.asset(
          ImageSourceConst.FOLLOW_LOCAL,
          width: 24,
          height: 24,
          color: globalColorManager.imageThemColor(),
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          widget.country ?? "",
          style: StRegular(14, text_main),
        ),
      ],
    );
  }

  Widget _buttons(){
    return Row(
      children: [
        InkWell(
          onTap: (){
            _buttonCallback();
            setState(() {
              maxLine = maxLine == 5000?4:5000;
            });
          },
            ///"收起":"全部"
            child: Text(maxLine == 5000?S.of(context).follow_pack_up:S.of(context).otc_all, style: StRegular(14, colorTheme),)),
        SizedBox(width: 20,),
        InkWell(
          onTap: (){
            _buttonCallback();
            translate();
          },
            ///"原文":"翻译"
            child: Text(_isTranslate?S.of(context).follow_text:S.of(context).follow_translate, style: StRegular(14, colorTheme),)),
      ],
    );
  }

  _buttonCallback(){
    if(widget.buttonClickCallBack != null) {
      widget.buttonClickCallBack!();
    }
  }

  //订单数据
  translate() {
    if(StringUtils.isBlank(widget.labelNote)){
      return;
    }
    if(StringUtils.isNotBlank(_translateString)){
      setState(() {
        _isTranslate = !_isTranslate;
      });
      return;
    }
    Map<String, dynamic> params = {};
    params["text"] = widget.labelNote;
    httpClientContract.post<String>(
        url: UrlConst.API_FOLLOW_TRANSLATE,
        parameters: params,
        showErrorMessage: true,
        onSuccess: (resp) {
          if(resp != null){
            setState(() {
              _isTranslate = !_isTranslate;
              _translateString = resp;
            });
            _buttonCallback();
          }
        });
  }

  String sha256Hash(String input) {
    var bytes = utf8.encode(input); // 将字符串编码为字节序列
    var digest = sha256.convert(bytes); // 使用SHA-256算法进行哈希
    return digest.toString(); // 将结果转换为字符串
  }
  
}
