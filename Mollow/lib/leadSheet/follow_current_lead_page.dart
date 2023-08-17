import 'package:coinw_flutter/bean/bbs/bean/bbs_leader_current_follow_list_entity.dart';
import 'package:coinw_flutter/bean/bbs/bean/bbs_leader_my_documentary_entity.dart';
import 'package:coinw_flutter/bean/market/bean/market_info_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/channel/invoke_native.dart';
import 'package:module_core/core/config/app_config.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/url_const.dart';
import 'package:module_core/core/constant/value_const.dart';
import 'package:module_core/core/net/http_client.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_core/core/utils/scroll_view.dart';
import 'package:module_core/core/utils/string_utils.dart';
import 'package:module_core/widget/custom_app_bar.dart';
import 'package:module_core/widget/custom_refresher_widget.dart';
import 'package:module_core/widget/empty_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:module_international/generated/l10n.dart';
import 'dart:convert' as convert;
import 'package:decimal/decimal.dart';

class FollowCurrentLeadPage extends StatefulWidget {
  static const String routeName = "FollowCurrentLeadPage";

  static void start(BuildContext context, {ValueSetter? callback}) {
    Navigator.pushNamed(context, routeName, arguments: callback);
  }

  /// 点击回调
  final ValueSetter? callback;

  const FollowCurrentLeadPage({
    Key? key,
    this.callback,
  }) : super(key: key);

  @override
  State<FollowCurrentLeadPage> createState() => _FollowCurrentLeadPageState();
}

class _FollowCurrentLeadPageState extends State<FollowCurrentLeadPage> with _FollowCurrentLeadPageBloc {
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
        title: S.of(context).bbs_follow_current_tape,
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        header: customRefresherHeader(context),
        onRefresh: () {
          _requestList();
        },
        child: ListView.separated(
          itemBuilder: _itemBuilder,
          physics: DefScrollPhysics.def,
          itemCount: _data.isEmpty ? 1 : _data.length,
          separatorBuilder: (BuildContext context, int index) => const Divider(color: background_gray, thickness: 10),
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    if (_data.isEmpty) {
      return EmptyWidget(
        //没有任何数据哦
        text: S.of(context).common_no_data,
        height: MediaQuery.of(context).size.height,
      );
    }
    BbsLeaderCurrentFollowListEntity entity = _data[index];
    var positionMode = _getPositionMode(context, entity);
    var rate = (entity.profitRate != null && entity.profitRate!.isNotEmpty)
        ? "${(StringUtils.doubleParse(entity.profitRate) * 100).toStringAsFixed(2)}%"
        : "--";
    var color =
        StringUtils.doubleParse(entity.profitRate) >= 0 ? AppConfig.getRiseUpColor() : AppConfig.getRiseFallColor();
    return InkWell(
      onTap: () {
        if (widget.callback != null) {
          widget.callback!(entity);
        }
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${entity.instrument!.toUpperCase()}/USDT${S.of(context).bbs_follow_perpetuity}", style: StBold(16, text_main)),
            const SizedBox(height: 10),
            Row(
              children: [
                Text("${entity.leverage ?? "--"}${S.of(context).bbs_follow_leverage}", style: StMediumDin(12, text_main)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: positionMode[1],
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  child: Text(
                    positionMode[0],
                    style: StRegular(10, white),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _topBottomText(entity.openPrice ?? "--", "${S.of(context).bbs_follow_open_price}(USDT)", flex: 3),
                _topBottomText(entity.followProfit ?? "--", "${S.of(context).bbs_follow_follower_income}(USDT)"),
                _topBottomText(rate, S.of(context).bbs_mine_follow_yield,
                    crossAxisAlignment: CrossAxisAlignment.end, textColor: color),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _topBottomText(entity.profitShare ?? "--", "${S.of(context).bbs_follow_profit_sharing}(USDT)", flex: 3),
                _topBottomText((entity.followNum ?? 0).toString(), S.of(context).bbs_follow_number_followers, flex: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBottomText(String topText, String bottomText,
      {CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start, Color textColor = text_main, int flex = 2}) {
    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(topText, style: StMediumDin(12, textColor)),
          const SizedBox(height: 4),
          Text(bottomText, style: StRegular(12, text_main2)),
        ],
      ),
    );
  }
}

mixin _FollowCurrentLeadPageBloc on State<FollowCurrentLeadPage> {
  bool _isInitialized = false;

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  List<BbsLeaderCurrentFollowListEntity> _data = [];

  String? _leaderId = "";

  _init() {
    _requestList();
  }

  void _requestList() {
    if ((_leaderId ?? "").isNotEmpty) {
      _getLeaderCurrentFollowListData();
      return;
    }
    _getLeaderId().then((value) {
      _leaderId = value;
      _getLeaderCurrentFollowListData();
    });
  }

  _getLeaderCurrentFollowListData({showLoading = false}) async {
    Map<String, dynamic> params = {};
    params['queryParameter'] = _leaderId;

    await httpClientContract.post<List<BbsLeaderCurrentFollowListEntity>>(
      url: UrlConst.API_FOLLOW_GET_CURRENT_POSITION_LIST,
      parameters: params,
      showLoading: showLoading,
      onSuccess: (resp) {
        if (resp != null) {
          setState(() {
            _data = resp;
          });
        }
      },
      onError: (e) {},
    );
    _refreshController.loadComplete();
    _refreshController.refreshCompleted();
  }

  Future<String?> _getLeaderId() async {
    Map<String, dynamic> params = {};
    var uid = await InvokeNative.invoke(NativeMethodConst.METHOD_UID);
    params['uid'] = uid;

    var resultMap = await httpClientContract.request<BbsLeaderMyDocumentaryEntity>(
      url: UrlConst.API_FOLLOW_MY_DOCUMENTARY,
      method: HttpClient.POST,
      parameters: params,
    );

    String? leaderId = "";
    if (resultMap != null) {
      leaderId = resultMap.leaderId;
    }
    return leaderId;
  }

  /// 仓位方向
  _getPositionMode(BuildContext context, BbsLeaderCurrentFollowListEntity entity) {
    Color color;
    var text1 = "";
    var text2 = "";
    if (entity.positionModel == 0) {
      text1 = S.of(context).bbs_isolated;
    } else {
      text1 = S.of(context).bbs_cross;
    }
    if (entity.status == "open") {
      if ("long" == entity.direction) {
        color = AppConfig.getRiseUpColor();
        text2 = S.of(context).bbs_open_long;
      } else {
        color = AppConfig.getRiseFallColor();
        text2 = S.of(context).bbs_open_short;
      }
    } else {
      if ("long" == entity.direction) {
        color = AppConfig.getRiseFallColor();
        text2 = S.of(context).bbs_close_long;
      } else {
        color = AppConfig.getRiseUpColor();
        text2 = S.of(context).bbs_close_short;
      }
    }
    return [text1 + text2, color];
  }
}
