
import 'dart:async';

import 'package:coinw_flutter/modules/common/them/global_color_manager.dart';
import 'package:coinw_flutter/modules/example/bean/login_info.dart';
import 'package:coinw_flutter/modules/example/utils/user_manager.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/config/app_config.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/url_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/gt4captcha/gt4captcha.dart';
import 'package:module_core/core/net/http_client.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/big_button.dart';
import 'package:module_core/widget/custom_toast.dart';
import 'package:module_follow/home/follow_settings/widget/follow_textfield_widget.dart';



typedef PasswordAndCode = Function(String password, int type, String code);

class FollowPasswordAlertWidget extends StatefulWidget {
  FollowPasswordAlertWidget({Key? key, this.confirmClick})
      : super(key: key);

  PasswordAndCode? confirmClick;


  @override
  State<FollowPasswordAlertWidget> createState() => _FollowPasswordAlertWidgetState();
}

class _FollowPasswordAlertWidgetState extends State<FollowPasswordAlertWidget> {
  bool isInit = false;
  TextEditingController passwordController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  // 定时器
  Timer? _myTimer;
  ///发送按钮文案
  late String _sendBtnTitle;
  bool _isSending =false;
  ///用户信息
  LoginInfoUserInfo? _userInfo;
  // -1 未绑定  0 google 1 手机 2 邮箱
  int bind1 = -1;
  int bind2 = -1;

  FocusNode passwordFocus = FocusNode();
  FocusNode codeFocus = FocusNode();
  bool _canSure = false;
  @override
  void initState() {
    super.initState();
    _userInfoInit();
    passwordController.addListener(() {
      _canEnable();
    });
    codeController.addListener(() {
      _canEnable();
    });
  }

  _canEnable(){
    setState(() {
      _canSure = passwordController.text.length>1 && codeController.text.length > 3;
    });
  }

  _userInfoInit() async {
    _userInfo = await AppConfig.getUserInfo();
    final isBindGoogle = _userInfo?.isGoogleBind;
    final isBindMobile = _userInfo?.isBindMobil;
    final isBindEmail = _userInfo?.isBindEmail;
    if(isBindGoogle == true){
      bind1 = 0;
      if(isBindEmail == true){
        bind2 = 2;
        setState(() {});
        return;
      }
      if(isBindMobile == true){
        bind2 = 1;
        setState(() {});
        return;
      }
      bind2 = -1;
    }else{
      bind2 = -1;
      if(isBindMobile == true && isBindEmail == true){
        bind1 = 1;
        bind2 = 2;
        setState(() {});
        return;
      }
      if(isBindMobile == true){
        bind1 = 1;
        setState(() {});
        return;
      }
      if(isBindEmail == true){
        bind1 = 2;
        setState(() {});
        return;
      }
    }
  }

  _init(){
    _sendBtnTitle = S.of(context).assets_common_send_code;
  }

  String _getSelectTitle(int value){
    if(!isInit){
      isInit = true;
      _init();
    }
    if(value == 0){
      return S.of(context).follow_google_verify;
    }else if(value == 1){
      return S.of(context).follow_mobile_verify;
    }else if(value == 2){
      return S.of(context).follow_email_verify;
    }
    return "";
  }

  String _getUnselectTitle(int value){
    if(value == 0){
      return S.of(context).follow_change_to_google_verify;
    }else if(value == 1){
      return S.of(context).follow_change_to_mobile_verify;
    }else if(value == 2){
      return S.of(context).follow_change_to_email_verify;
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        passwordFocus.unfocus();
        codeFocus.unfocus();
      },
      child: Container(
        padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: globalColorManager.scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0)
              )
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// 安全验证
                  Text(S.of(context).follow_safety_verification, style: StMedium(14, text_main),),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(ImageSourceConst.LIVE_ALERT_CLOSE,
                        width: 14,
                        height: 14,
                        color: globalColorManager.imageThemColor()),
                  )
                ],
              ),
              const SizedBox(height: 15,),
              /// 交易密码
              Text(S.of(context).follow_trade_password, style: StRegular(14, text_main),),
              const SizedBox(height: 10,),
              FollowTextfiwldWidget(passwordController, hint: S.of(context).follow_trade_password_hint, obscureText: true, focusNode: passwordFocus,),
              const SizedBox(height: 24,),
              Row(
                children: [
                  Text(_getSelectTitle(bind1), style: StRegular(14, text_main),),
                  const SizedBox(width: 10,),
                  const Spacer(),
                  bind2 >= 0 ? InkWell(
                    onTap: (){
                      switchButtonClick();
                    },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_getUnselectTitle(bind2), style: StRegular(14, text_main),),
                          const SizedBox(width: 3,),
                          Image.asset(ImageSourceConst.COMMON_SWITCH, width: 13, height: 13, color: globalColorManager.imageThemColor(),),
                        ],
                      )) : Container(),
                ],
              ),
              const SizedBox(height: 10,),
              /// 请输入验证码
              FollowTextfiwldWidget(codeController, hint: S.of(context).assets_common_verify_code_hint, keyboardType: TextInputType.number, suffix: _getSendCodeWidget(), focusNode: codeFocus,),
              const SizedBox(height: 24,),
              /// 验证
              BigButton(
                text: S.of(context).follow_verify,
                option: BigBtnOption(
                  isEnable: _canSure,
                ),
                onPressed: (){
                _sureButtonClick();
              },),
              const SizedBox(height: 10,),

            ],
          )
      ),
    );
  }

  _sureButtonClick(){
    if(passwordController.text.isEmpty){
      CustomToast.showTopRead(S.of(context).otc_input_trade_pwd_2);
      return;
    }
    if(codeController.text.isEmpty){
      CustomToast.showTopRead(S.of(context).assets_common_verify_code_hint);
      return;
    }
    Navigator.pop(context);
    if(widget.confirmClick != null){
      passwordFocus.unfocus();
      codeFocus.unfocus();
      widget.confirmClick!(passwordController.text, bind1, codeController.text);
    }
  }

  Widget _getSendCodeWidget(){
    return bind1 > 0 ? InkWell(
      onTap: (){
        if (!_isSending) {
          _verifyJIYanUserNew();
        }
      },
      child: Container(
        padding: const EdgeInsets.only(right: 5),
        child: Text(_sendBtnTitle, style: StRegular(14, colorTheme),),
      ),
    ) : Container();
  }

  //调换位置
  void switchButtonClick() {
    if(bind2 < 0){
      return;
    }
    int save = bind1;
    bind1 = bind2;
    bind2 = save;
    codeController.text = "";
    setState(() {});
  }

  _verifyJIYanUserNew() async{
    Map<String, dynamic> params = Map();
    if(bind1 == 1){
      params["sendTelephoneCode"] = true;
    }else{
      params["sendTelephoneCode"] = false;
    }
    Map<String, dynamic> verifyResult = await GT4Captcha().verify();
    params["type"] = "5";
    params.addAll(verifyResult);
    UserManager.instance().isverfiyUrl = true;
    httpClient.post<dynamic>(
      url: UrlConst.API_ASSET_USER_SENDMSGCODE_NEW,
      parameters: params,
      showErrorMessage: true,
      showLoading: false,
      onSuccess: (resp) {
        _startCountDownTimer();
      },
      onError: (e) {
        print(e);
        UserManager.instance().isverfiyUrl = false;
        CustomToast.showTopRead(e.toString());
      },
    );
  }

  _startCountDownTimer() {
    if(_myTimer != null){
      return;
    }
    int num = 60;
    // 实例化Duration类 设置定时器持续时间 毫秒
    var timeout = new Duration(milliseconds: 1000);

    // 持续调用多次 每次1秒后执行
    _myTimer = Timer.periodic(timeout, (timer) {
      num--;
      print(num); // 会每隔一秒打印一次 自增的数
      if (num == 0) {
        ///发送验证码
        _sendBtnTitle = S.of(context).assets_common_send_code;
        _isSending = false;
        // 清除定时器
        _stopTimer();
      } else {
        _sendBtnTitle = "$num s";
        _isSending = true;
      }
      setState(() {});
    });
  }

  _stopTimer() {
    if (_myTimer != null) {
      if (_myTimer!.isActive) {
        _myTimer!.cancel();
        _myTimer = null;
      }
    }
  }
}


