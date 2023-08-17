import 'dart:convert';

import 'package:coinw_flutter/bean/follow/follow_assets_entity.dart';
import 'package:coinw_flutter/bean/follow/follow_setting_entity.dart';
import 'package:coinw_flutter/bean/follow/follow_trader_entity.dart';
import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:coinw_flutter/modules/common/them/global_color_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/url_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/extension/string_extension.dart';
import 'package:module_core/core/net/http_client.dart';
import 'package:module_core/core/utils/encrypt_utils.dart';
import 'package:module_core/core/utils/event_bus_utils.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_core/core/utils/other/comma_text_input_formatter.dart';
import 'package:module_core/core/utils/string_utils.dart';
import 'package:module_core/core/utils/system_utils.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/big_button.dart';
import 'package:module_core/widget/bottom_pop_widget.dart';
import 'package:module_core/widget/custom_app_bar.dart';
import 'package:module_core/widget/custom_dialog.dart';
import 'package:module_core/widget/custom_text_field.dart';
import 'package:module_core/widget/custom_toast.dart';
import 'package:module_core/widget/custom_widget.dart';
import 'package:module_core/widget/list_divider_widget.dart';
import 'package:module_follow/home/follow_settings/widget/follow_password_alert.dart';
import 'package:module_follow/home/follow_settings/widget/follow_select_coin_widget.dart';
import 'package:module_follow/home/follow_settings/widget/follow_select_risk_widget.dart';
import 'package:module_follow/home/follow_settings/widget/follow_setting_alert.dart';
import 'package:module_follow/home/follow_settings/widget/follow_settings_header_widget.dart';
import 'package:sprintf/sprintf.dart';

///跟单设置
class FollowSettingsPage extends StatefulWidget {
  static const String routeName = "FollowSettingsPage";

  static void start(BuildContext context, String leaderId) {
    Navigator.pushNamed(context, routeName, arguments: leaderId);
  }
  bool isNative;
  String leaderId;

  FollowSettingsPage({Key? key, required this.leaderId, required this.isNative}) : super(key: key);

  @override
  State<FollowSettingsPage> createState() => _FollowSettingsPageState();
}

class _FollowSettingsPageState extends State<FollowSettingsPage>
    with _FollowSettingsPageBloc {
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
    }
    return Scaffold(
        appBar: CustomAppBar(
          context,
          /// 跟单设置
          title: S.of(context).follow_settings,
          backAction: (){
            if (widget.isNative) {
              SystemUtils.backToSystomApp();
            } else {
              Navigator.pop(context);
            }
          },
          rightWidget: StringUtils.isNotBlank(_followSetting?.followUserId) ? InkWell(
            onTap: () {
              _cancelFollowAlert();
            },
            child: Row(
              children: [
                Center(
                  child: Text(
                    /// 取消跟随
                    S.of(context).follow_setting_cancel_follow,
                    style: StRegular(14, text_main2),
                  ),
                ),
                const SizedBox(width: 15)
              ],
            ),
          ) : null,
        ),
        body: GestureDetector(
          onTap: (){
            _clearKeyBoard();
          },
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    FollowSettingsHeaderWidget(
                      followTrader: _followTrader,
                    ),
                    customLine(
                        height: 10, color: globalColorManager.dividerColor),
                    _settingWidget(),
                  ],
                ),
              ),
              SafeArea(child: _sureButtonWidget(),)
            ],
          ),
        ));
  }

  ///设置
  _settingWidget() {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///参数设置
          Text(
            S.of(context).follow_setting_title,
            style: StRegular(12, text_main2),
          ),
          const SizedBox(
            height: 15,
          ),
          _marginSetting(),
          ///仓位类型
          _itemWidget(S.of(context).follow_setting_position_type, _positionType, tag: S.of(context).follow_setting_position_type_hint, callback: (){
            _clickPositionType();
          }),
          ListDividerWidget(lineColor: line_main.withOpacity(0.05),),
          ///杠杆
          _itemWidget(S.of(context).follow_setting_lever, FollowSettingEntity.getLevelText(context, _lever, _leverage), tag: S.of(context).follow_setting_lever_hint, callback: (){
            _clickLever();
          }),
          ListDividerWidget(lineColor: line_main.withOpacity(0.05)),
          ///单笔保证金
          _itemWidget(S.of(context).follow_setting_deposit, "$_amountType $_multiplierAmount", tag: sprintf(S.of(context).follow_setting_deposit_hint, [_followSetting?.limitMinQuota ?? "", _followSetting?.limitMaxQuota ?? ""]), callback: (){
            _clickDeposit();
          }),
          ListDividerWidget(lineColor: line_main.withOpacity(0.05)),
          ///跟单合约
          _itemWidget(
              S.of(context).follow_contract, _getContracts(), callback: (){
            _clickFollowOrderCoin();
          }),
          ListDividerWidget(lineColor: line_main.withOpacity(0.05)),
          ///风险控制
          _itemWidget(S.of(context).follow_risk_manager, _getRiskData(), callback: (){
            _clickFollowRiskManager();
          }),
          _needPayFee() ? const SizedBox(
            height: 10,
          ) : Container(),
          _needPayFee() ? Text(
            S.of(context).follow_setting_alert,
            style: StRegular(11, text_main2),
          ) : Container(),
          _needPayFee() ? SizedBox(height: 18,) : Container(),
          ListDividerWidget(lineColor: line_main.withOpacity(0.05)),
        ],
      ),
    );
  }

  ///确定
  _sureButtonWidget() {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: _needPayFee() ? Row(
        children: [
          Text(
            "${S.of(context).otc_pay}: ",
            style: StRegular(14, text_main),
          ),
          Text(
            "${_followTrader?.payAmount ?? ""} USDT",
            style: StMedium(18, text_main),
          ),
          const SizedBox(
            width: 10,
          ),
          Spacer(),
          BigButton(
            onPressed: () {
              _showPassword();
            },
            text: S.of(context).common_ok,
            option: BigBtnOption(width: 120, height: 40),
          )
        ],
      ) :  BigButton(
        onPressed: () {
          _alertShareType();
        },
        text: S.of(context).common_ok,
        option: BigBtnOption(height: 40),
      ),
    );
  }

  ///跟单本金
  _marginSetting() {
    return Column(
      children: [
        Row(
          children: [
            ///跟单本金  追加跟单本金
            Text(
              StringUtils.isBlank(_followSetting?.followUserId) ? S.of(context).follow_setting_principal : S.of(context).follow_setting_principal_append,
              style: StMedium(16, text_main),
            ),
            InkWell(
              onTap: () {
                _alertViewShow(context, sprintf(S.of(context).follow_setting_principal_hint, [_followSetting?.limitMaxFollowPrincipal ?? "5000"]) );
              },
              child: Container(
                padding: const EdgeInsets.only(left: 6, right: 30, top: 5),
                child: Image.asset(
                  ImageSourceConst.COMMON_ALERT_CION,
                  width: 16,
                  height: 16,
                ),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 12,
        ),
        Container(
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
            decoration:
                RegularRadius(color: text_main2.withOpacity(0.1), radius: 6.0),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: marginController,
                  focusNode: _focusNode,
                  style: StMedium(14, text_main),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [CommaTextInputFormatter()],
                        decoration: customTextFieldDecoration(hint: _marginHint)
                )),
                Text(
                  "USDT",
                  style: StMedium(14, text_main),
                ),
                const SizedBox(
                  width: 5,
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: text_main2.withOpacity(0.2),
                ),
                const SizedBox(
                  width: 5,
                ),
                InkWell(
                  onTap: () {
                    _maxButtonClick();
                  },
                  child: Text(
                    S.of(context).common_all,
                    style: StRegular(14, colorTheme),
                  ),
                ),
              ],
            )),
        const SizedBox(
          height: 9,
        ),
        Row(
          children: [
            ///合约账户可用
            Text(
              S.of(context).follow_setting_contract_available,
              style: StRegular(12, text_main2),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              "${_followAssets?.balance != null ? _followAssets!.balance!.keepTwoDecimal() : '--'} USDT",
              style: StMedium(12, text_main),
            ),
          ],
        ),
        const SizedBox(
          height: 18,
        ),
        ListDividerWidget(),
      ],
    );
  }

  _itemWidget(String title, String value, {String? tag , VoidCallback? callback}) {
    return GestureDetector(
      onTap: (){
        if(callback != null){
          callback();
        }
      },
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                constraints: const BoxConstraints(maxWidth: 150),
                padding: const EdgeInsets.only(top: 14),
                child: Text(
                  title,
                  style: StMedium(16, text_main),
                )),
            tag != null
                ? InkWell(
                    onTap: () {
                      _alertViewShow(context, tag);
                    },
                    child: Container(
                      padding: const EdgeInsets.only(left: 6,top: 18,right: 30, bottom: 10),
                      child: Image.asset(
                        ImageSourceConst.COMMON_ALERT_CION,
                        width: 14,
                        height: 14,
                      ),
                    ),
                  )
                : Container(),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 18, bottom: 18),
                child: Text(
                  value,
                  style: StRegular(12, text_main2),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Image.asset(
                ImageSourceConst.ICON_ARROW_GRAY_RIGHT,
                height: 16,
                width: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _alertViewShow(BuildContext context, String tag) {
    _clearKeyBoard();
    Widget content = Container(
      child: Text(tag, style: StRegular(14, text_main),),
    );
    CustomDialog(
      content: content,
      confirmButtonMsg: S.of(context).otc_i_know,
    ).show(context);
  }

  ///点击仓位类型
  _clickPositionType() {
    _clearKeyBoard();
    List<String> typeList = FollowSettingEntity.getPositionTextList(context);
    bottomSelectPop(context, typeList, _positionType,
        (value, index) {
      setState(() {
        _positionType = value;
      });
    });
  }

  ///点击杠杆
  _clickLever() {
    _clearKeyBoard();
    List<String> typeList = FollowSettingEntity.getLevelTextList(context);
    bottomSelectPop(context, typeList, FollowSettingEntity.getLevel(context, _lever), (value, index) {
      /// 指定杠杆
      if (value == S.of(context).follow_setting_lever_assign) {
        FollowSettingAlertWidget(S.of(context).follow_setting_lever_assign, levelController, hint: S.of(context).follow_setting_lever_enter_hint, keyboardType: TextInputType.number, confirmClick: (){
          if(levelController.text.isEmpty){
            /// 请输入杠杆倍数
            CustomToast.showTopRead(S.of(context).follow_setting_lever_enter_hint);
            return;
          }
          Navigator.pop(context);
          setState(() {
            _lever = 1;
            _leverage = levelController.text;
          });
        }).show(context);
      }else{
        setState(() {
          _lever = 0;
        });
      }

    });
  }

  ///点击单笔保证金
  _clickDeposit() {
    _clearKeyBoard();
    ///"倍率", "固定额度"
    List<String> typeList = FollowSettingEntity.getAmountTypeTextList(context);

    bottomSelectPop(context, typeList, _amountType, (value, index) {
      if (value == S.of(context).follow_setting_magnification) {
        String hint = sprintf(S.of(context).follow_setting_scale_hint,[_followSetting?.limitMinMultiply,_followSetting?.limitMaxMultiply]);
        FollowSettingAlertWidget content = FollowSettingAlertWidget(S.of(context).follow_setting_magnification, ratioController,
          tag: S.of(context).follow_setting_scale_tips,
          hint: hint,
          keyboardType:  TextInputType.numberWithOptions(decimal: true), confirmClick: (){
            double ratio = StringUtils.doubleParse(ratioController.text);
            double min = StringUtils.doubleParse(_followSetting?.limitMinMultiply);
            double max = StringUtils.doubleParse(_followSetting?.limitMaxMultiply);
            if(ratio < min || ratio > max){
              CustomToast.showTopRead(hint);
              return;
            }
            Navigator.pop(context);
            _amountType = value;
            _multiplierAmount = ratioController.text;
            setState(() {});
          },);
        content.show(context);

      } else if (value == S.of(context).follow_setting_fixed_amount) {
        String hint = sprintf(S.of(context).follow_setting_amount_range_hint,[_followSetting?.limitMinQuota,_followSetting?.limitMaxQuota]);
        FollowSettingAlertWidget content = FollowSettingAlertWidget(S.of(context).follow_setting_fixed_amount, lockController,
          tag: S.of(context).follow_setting_amount_range_tips,
          hint: hint,
          keyboardType:  TextInputType.numberWithOptions(decimal: true), confirmClick: (){
          double ratio = StringUtils.doubleParse(lockController.text);
          double min = StringUtils.doubleParse(_followSetting?.limitMinQuota);
          double max = StringUtils.doubleParse(_followSetting?.limitMaxQuota);
          if(ratio < min || ratio > max){
            CustomToast.showTopRead(hint);
            return;
          }
          Navigator.pop(context);
          _amountType = value;
          _multiplierAmount = lockController.text;
          setState(() {});
        },);
        content.show(context);
        }
    });
  }

  ///点击合约带单
  _clickFollowOrderCoin() {
    _clearKeyBoard();
    showBottomPop(
        context: context,
        bgColor: Colors.transparent,
        widget: FollowSelectCoinWidget(followTrader: _followTrader, selectList: _selectCurrencyList,
          callBack: (currencys){
            setState(() {
              _selectCurrencyList = currencys;
            });
          },
        )
    );
  }

  ///单击riskmanager
  _clickFollowRiskManager() {
    _clearKeyBoard();
    showBottomPop(
        context: context,
        bgColor: Colors.transparent,
        widget: FollowSelectRiskWidget(followSetting: _selectRisk, callBack: (risk){
          setState(() {
            _selectRisk = risk;
          });
        },)
    );
  }

  _showPassword(){
    _clearKeyBoard();
    showBottomPop(
        context: context,
        bgColor: Colors.transparent,
        widget: FollowPasswordAlertWidget(confirmClick: (String password, int type, String code){
          _password = password;
          _verificationType = type > 0 ? 1 : 2;
          _verificationCode = code;
          _alertShareType();
        },)
    );
  }

  ///最大
  _maxButtonClick(){
    double balance = StringUtils.doubleParse(_followAssets?.balance);
    int allLimit = _limit > 0 ? _limit : 0;
    setState(() {
      marginController.text = balance > allLimit ? allLimit.toString() : balance.toString();
    });
  }




}

mixin _FollowSettingsPageBloc on State<FollowSettingsPage> {
    bool _isInitialized = false;
    ///跟单保证金
    TextEditingController marginController = TextEditingController();
    FocusNode _focusNode = FocusNode();
    ///杠杆
    TextEditingController levelController = TextEditingController();
    ///倍率
    TextEditingController ratioController = TextEditingController();
    ///固定金额
    TextEditingController lockController = TextEditingController();
    ///被选择的带单币对
    List<FollowCurrency> _selectCurrencyList = [];
    GlobalKey globalKey = GlobalKey();
    GlobalKey globalKey2 = GlobalKey();
    FollowTraderEntity? _followTrader;
    FollowSettingEntity? _followSetting;
    FollowAssetsEntity? _followAssets;
    //风险项
    FollowSettingEntity? _selectRisk;
    //仓位类型(仓位模式 0:逐仓 1:全仓 2 跟随交易员)
    String _positionType = "";
    //杠杆 （跟随0，指定1）
    int _lever = 1;
    String _leverage = "5";
    //金额类型(1:固定；2倍数)
    String _amountType = "";
    //金额或者倍数
    String _multiplierAmount = "";
    String _marginHint = "";

    int? _verificationType;
    String _verificationCode = "";
    String _password = "";
    ///跟单本金最大值
    int _limit = 5000;
    _init() {
      _getLeaderDetail();
      _getAccountDetail();
    }
    ///拼接合约带单
    String _getContracts(){
      String currencys = "";
      for (FollowCurrency value in _selectCurrencyList) {
        currencys += "${value.currencyName}USDT ";
      }
      return currencys;
    }

    ///拼接风险控制
    String _getRiskData(){
      if(_selectRisk == null){
        return "";
      }
      List<String> values = [];
      if(StringUtils.isNotBlank(_selectRisk?.stopProfitRate)){
        /// 止盈比例,
        values.add(sprintf("${S.of(context).follow_setting_tp_rate}: %s%", [_selectRisk!.stopProfitRate!.percent]));
      }
      if(StringUtils.isNotBlank(_selectRisk?.stopLossRate)){
        /// 止损比例
        values.add(sprintf("${S.of(context).follow_setting_sl_rate}: %s%", [_selectRisk!.stopLossRate!.percent]));
      }
      if(StringUtils.isNotBlank(_selectRisk?.maxPosition)){
        /// 最大持仓金额:
        values.add("${S.of(context).follow_setting_max_hold_amount} ${_selectRisk?.maxPosition} USDT");
      }

      return values.join("\n");

    }

    _alertShareType(){
      if(_followTrader?.shareType == 1){
        print(sprintf(S.of(context).follow_setting_risk_hint, [_followTrader?.nickName ?? ""]));
        CustomDialog(
          title: S.of(context).bbs_mine_prompt,
          msg: sprintf(S.of(context).follow_setting_risk_hint, [_followTrader?.nickName ?? ""]),
          confirmButtonMsg: S.of(context).common_ok,
          cancelButtonMsg: S.of(context).common_cancel,
          showCancelButton: true,
          confirmCallback: () {
            _settingSave();
          },
        ).show(context);
      }else{
        _settingSave();
      }
    }

    _settingSave(){
      _clearKeyBoard();
      Map param = {};
      String currencyJson = jsonEncode(_selectCurrencyList);

      param["positionModel"] = FollowSettingEntity.getPositionValue(context, _positionType);
      param["currencyJson"] = currencyJson;
      param["leaderId"] = widget.leaderId;
      param["lever"] = _lever;
      param["leverage"] = _leverage;
      param["amountType"] = FollowSettingEntity.getAmountTypeToValue(context, _amountType);
      param["multiplierAmount"] = _multiplierAmount;
      param["followPrincipal"] = marginController.text;
      param["stopProfitRate"] = _selectRisk?.stopProfitRate ?? "";
      param["stopLossRate"] = _selectRisk?.stopLossRate ?? "";
      param["maxPosition"] = _selectRisk?.maxPosition ?? "";
      if(_needPayFee()){
        param["password"] = EncryptUtils.encryptionWeb(_password);
        param["verificationType"] = _verificationType;
        param["verificationCode"] = _verificationCode;
        param["payAmount"] = _followTrader?.payAmount ?? "";
      }
      httpClientContract.post(
          url: UrlConst.API_FOLLOW_SETTING,
          parameters: param,
          showErrorMessage: true,
          showLoading: true,
          onSuccess: (resp) {
            CustomToast.show(S.of(context).follow_setting_success);
            eventBus.fire(EventFollowSettingCallback());
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pop(context);
            });
        },
          onError:  (e){
          }
      );
    }

    ///获取数据
    _getSettingData(){
      Map<String, dynamic> params = {};
      params["leaderId"] = widget.leaderId;
      httpClientContract.post<FollowSettingEntity>(
          url: UrlConst.API_FOLLOW_SETTING_ECHO,
          parameters: params,
          showErrorMessage: true,
          onSuccess: (resp) {
            if(resp != null){
              FollowSettingEntity riskData = FollowSettingEntity();
              riskData.stopProfitRate = resp.stopProfitRate;
              riskData.stopLossRate = resp.stopLossRate;
              riskData.maxPosition = resp.maxPosition;
              _followSetting = resp;
              _selectCurrencyList = FollowSelectCoinWidget.currencyList(resp.currencyJson);
              _selectRisk = riskData;
              _positionType = resp.getPositionText(context);
              _lever = resp?.lever?? 1;
              _leverage = StringUtils.isNotBlank(resp.leverage) ? resp.leverage! : "5";
              _amountType = resp.getAmountTypeText(context);
              _multiplierAmount = resp.multiplierAmount ?? "";
              _limit = (resp.getLimitMaxFollowPrincipal() - resp.getAccountEquity()).ceil();
              _marginHint = sprintf("${S.of(context).follow_setting_principal_input_hint}%s~%s", [0,_limit]);
              setState(() {});
            }
          },
          onError:  (e){
          }
      );
    }

    ///获取交易员详情
    _getLeaderDetail(){
      Map<String, dynamic> params = {};
      params["leaderId"] = widget.leaderId;
      httpClientContract.post<FollowTraderEntity>(
          url: UrlConst.API_FOLLOW_LEADER_DETAIL,
          parameters: params,
          showErrorMessage: true,
          onSuccess: (resp) {
            if(resp != null){
              _followTrader = resp;
              _getSettingData();
              setState(() {});
            }
          },
          onError:  (e){
          }
      );
    }

    ///获取账户信息
    _getAccountDetail(){
      Map<String, dynamic> params = {};
      httpClientContract.post<FollowAssetsEntity>(
          url: UrlConst.API_FOLLOW_CONTRACT_ACCOUNT,
          parameters: params,
          showErrorMessage: true,
          onSuccess: (resp) {
            if(resp != null){
              setState(() {
                _followAssets = resp;
              });
            }
          },
          onError:  (e){
          }
      );
    }

    ///取消跟随
    _getCancelOrder(){
      Map<String, dynamic> params = {};
      params["followUserId"] = _followSetting?.followUserId ?? "";
      httpClientContract.post<FollowAssetsEntity>(
          url: UrlConst.API_FOLLOW_CANCEL,
          parameters: params,
          showErrorMessage: true,
          showLoading: true,
          onSuccess: (resp) {
            /// 取消跟随成功
            eventBus.fire(EventFollowSettingCallback());
            CustomToast.show(S.of(context).follow_setting_cancel_follow_success);
            Navigator.pop(context);
        },
          onError:  (e){
          }
      );
    }


    ///取消跟随弹窗
    _cancelFollowAlert(){
      Widget content = Column(
        children: [
          Image.asset(ImageSourceConst.OTC_ORDER_APPEAL, width: 60, height: 60,),
          const SizedBox(height: 15,),
          /// 取消跟随后，跟随当前交易员的订单将自动平仓
          Text(S.of(context).follow_setting_cancel_follow_tips, style: StRegular(14, text_main), textAlign: TextAlign.center,),
        ],
      );
      CustomDialog(
        content: content,
        confirmButtonMsg: S.of(context).common_ok,
        cancelButtonMsg: S.of(context).common_cancel,
        showCancelButton: true,
        confirmCallback: () {
          _getCancelOrder();
        },
      ).show(context);
    }

    //如果已跟单或者未开启更单 则不要开启付费跟单
    bool _needPayFee(){
      if(_followTrader?.payType == 1 && StringUtils.isBlank(_followSetting?.followUserId)){
        return true;
      }
      return false;
    }

    _clearKeyBoard(){
      _focusNode.unfocus();
    }

}
