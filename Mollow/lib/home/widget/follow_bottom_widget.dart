
import 'package:coinw_flutter/bean/follow/follow_leader_profit_entity.dart';
import 'package:coinw_flutter/bean/follow/follow_trader_entity.dart';
import 'package:coinw_flutter/bean/follow/follow_user_info_entity.dart';
import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:coinw_flutter/modules/common/them/global_color_manager.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/channel/invoke_native.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/url_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/extension/string_extension.dart';
import 'package:module_core/core/net/http_client.dart';
import 'package:module_core/core/utils/event_bus_utils.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/big_button.dart';
import 'package:module_core/widget/custom_dialog.dart';
import 'package:module_core/widget/custom_toast.dart';
import 'package:module_follow/common/follow_action_manager.dart';
import 'package:module_core/core/utils/login_util.dart';

///主页下边按钮
class FollowBottomWidget extends StatefulWidget {
  FollowTraderEntity? trader;
  FollowUserInfoEntity? followUserInfo;
  FollowBottomWidget(this.trader, this.followUserInfo, {Key? key,}) : super(key: key);

  @override
  State<FollowBottomWidget> createState() => _FollowBottomWidgetState();
}

class _FollowBottomWidgetState extends State<FollowBottomWidget> {

  FollowLeaderProfitEntity? profitEntity;
  bool isInit = false;

  @override
  Widget build(BuildContext context) {
    if(!isInit){
      isInit = true;
      _getShareRate();
    }
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 15),
      child: Row(
          children: [
            _itemLike(widget.trader?.isComment == 1),
            _itemUnlike(widget.trader?.isComment == 0),
            _itemSlices(widget.trader?.isFocus == 1),
            const SizedBox(width: 5,),
            _followButton(),
          ],
      ),
    );
  }

  _followButton() {
    if(widget.followUserInfo == null || widget.followUserInfo?.identity == 0 || isMySheet){
      return Expanded(
        child: BigButton(
          onPressed: () {
            LoginUtil.isLoginAndDoSomething(() {
              if(isMySheet && widget.trader != null){
                FollowActionManager.pushFollowLeaderSetting(context, profitEntity?.shareRate);
                return;
              }
              if (widget.trader != null && widget.trader!.leaderId != null && _getBtnActionText() != S.of(context).follow_full) {
                FollowActionManager.pushFollowTrader(context, widget.trader!.leaderId!);
              }
            });
          },
          text: _getBtnActionText(),
          option: BigBtnOption(height: 40, radius: 6.0),
        ),
      );
    } else {
      return Expanded(
        child: Container(),
      );
    }

  }

  _itemLike(bool isSelect){
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        LoginUtil.isLoginAndDoSomething((){
          // 交易员不能点赞
          if(widget.followUserInfo?.identity == 1){
            return;
          }
          if(widget.trader == null) {
            return;
          }
          _commentTrader(1);
        });
      },
      child: SizedBox(
        width: 44,
        child: _item(
          isSelect
              ? ImageSourceConst.FOLLOW_LIKE
              : ImageSourceConst.FOLLOW_LIKE_NO,
          (widget.trader?.like ?? 0).toString(),
          isSelect
        ),
      ),
    );
  }

  _itemUnlike(bool isSelect) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        LoginUtil.isLoginAndDoSomething((){
          // 自己不能给自己点赞
          // 交易员不能点赞
          if(widget.followUserInfo?.identity == 1){
            return;
          }
          if(widget.trader == null){
            return;
          }
          _commentTrader(0);
        });
      },
      child: SizedBox(
        width: 44,
        child: _item(
          isSelect
              ? ImageSourceConst.FOLLOW_UNLIKE
              : ImageSourceConst.FOLLOW_UNLIKE_NO,
          (widget.trader?.dislike ?? 0).toString(),
          isSelect
        ),
      ),
    );
  }

  _itemSlices(bool isSelect) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        LoginUtil.isLoginAndDoSomething((){
          // 交易员不能点赞
          if(widget.followUserInfo?.identity == 1){
            return;
          }
          if(widget.trader == null){
            return;
          }
          //跟随后不能点赞
          if(widget.trader?.isBinding == 1){
            return;
          }
          _focusTrader(widget.trader!.isFocus == 1 ? 0 : 1);
        });
      },
      child: SizedBox(
        width: 44,
        child: _item(
          isSelect
              ? ImageSourceConst.FOLLOW_SLICES
              : ImageSourceConst.FOLLOW_SLICES_NO,
          widget.trader?.focusCount ?? "0",
            isSelect
        ),
      ),
    );
  }

  _item(String image, String value, bool isSelect){
    return Column(
      children: [
        Image.asset(
          image,
          width: 20,
          height: 20,
          color: isSelect ? null : globalColorManager.imageThemColor(),
        ),
        const SizedBox(
          height: 2,
        ),
        Text(
          value.fixNumberDecimal(0),
          style: StMedium(12, text_main),
        )
      ],
    );
  }

  // 评价交易员 type:0踩 1赞
  _commentTrader(type) {
    ///您仅有一次评价机会
    if(widget.trader?.isComment == 2){
      CustomDialog(
        title: S.of(context).bbs_mine_prompt,
        msg: S.of(context).follow_appraise_hint,
        showCancelButton: true,
        cancelButtonMsg: S.of(context).common_cancel,
        confirmCallback: (){
          Map<String, dynamic> params = {};
          params["leaderId"] = widget.trader?.leaderId ?? "";
          params["type"] = type;
          httpClientContract.post(
              url: UrlConst.API_FOLLOW_COMMENT_TRADER,
              parameters: params,
              showLoading: true,
              showErrorMessage: true,
              onSuccess: (resp) {
                ///操作成功
                CustomToast.showTopBlue(S.of(context).follow_operate_success);
                eventBus.fire(EventFollowRefreshTraderDetail());
              });
        },
      ).show(context);
    } else {
      ///您已经评价过了
      CustomDialog(
        msg: S.of(context).follow_cannot_appraise_hint,
        confirmButtonMsg: S.of(context).otc_i_know,
      ).show(context);
    }

  }

  // 关注交易员 type 0取消关注， 1关注
  _focusTrader(type) {
    Map<String, dynamic> params = {};
    params["leaderId"] = widget.trader?.leaderId ?? "";
    params["type"] = type;
    httpClientContract.post(
        url: UrlConst.API_FOLLOW_FOCUS_TRADER,
        parameters: params,
        showLoading: true,
        showErrorMessage: true,
        onSuccess: (resp) {
          if(type == 1){
            ///关注成功
            CustomToast.showTopBlue(S.of(context).follow_focus_success_hint);
            eventBus.fire(EventFollowRefreshTraderDetail());
          } else if(type == 0){
            ///已取消关注
            CustomToast.showTopBlue(S.of(context).follow_cancel_focus_hint);
            eventBus.fire(EventFollowRefreshTraderDetail());
          }

        });
  }

  _getBtnActionText() {
    if(isMySheet){
      ///带单设置
      return S.of(context).follow_trader_setting;
    }
    if(widget.followUserInfo == null){
      ///跟随
      return S.of(context).follow_copy;
    }
    if(widget.trader?.isBinding == 1){
      ///编辑
      return S.of(context).otc_edit;
    } else {
      if (int.parse(widget.trader?.followerCount ?? "0") >=
          (widget.trader?.followCountLimit ?? 10)) {
        ///满员
        return S.of(context).follow_full;
      } else {
        ///跟随
        return S.of(context).follow_copy;
      }
    }
  }

  //是否是自己的主页
  bool get isMySheet{
    return widget.trader?.leaderId == widget.followUserInfo?.userId;
  }


  _getShareRate(){
    Map<String, dynamic> params = {};
    httpClientContract.post<FollowLeaderProfitEntity>(
        url: UrlConst.API_FOLLOW_LEADER_PROFIT,
        parameters: params,
        showErrorMessage: false,
        showLoading: false,
        showLoginDialog: false,
        onSuccess: (resp) {
          setState(() {
            profitEntity = resp;
          });
        });
  }


}
