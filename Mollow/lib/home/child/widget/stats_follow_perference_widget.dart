import 'package:coinw_flutter/bean/follow/follow_leader_currency_entity.dart';
import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/constant/url_const.dart';
import 'package:module_core/core/extension/string_extension.dart';
import 'package:module_core/core/net/http_client.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_follow/home/child/widget/button/follow_select_time_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///交易偏好
class StatsFollowPerferenceWidget extends StatefulWidget {
  final String leaderId;
  const StatsFollowPerferenceWidget({Key? key, required this.leaderId}) : super(key: key);

  @override
  State<StatsFollowPerferenceWidget> createState() => _StatsFollowPerferenceWidgetState();
}

class _StatsFollowPerferenceWidgetState extends State<StatsFollowPerferenceWidget>
    with _StatsFollowPerferenceWidgetBloc, AutomaticKeepAliveClientMixin {
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
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(12),
      decoration: RegularBorder(colorBorder: text_main2.withOpacity(0.1), backgroundColor: Colors.transparent, radius: 12.0),
      child: Column(
        children: _content(),
      ),
    );
  }

  List<Widget> _content(){
    List<Widget> list = [];
    list.add(_titleWidget());
    for(FollowLeaderCurrencyEntity item in _dataList){
      list.add(_itemChart(item));
    }
    for(FollowLeaderCurrencyEntity item in _dataList){
      list.add(_itemData(item));
    }

    return list;
  }

  _itemChart(FollowLeaderCurrencyEntity item){
    double percent = item.rate ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(coinName(item), style: StMedium(12, text_main),),
                const SizedBox(height: 2,),
                Text("${(percent*100).toStringAsFixed(2)}%", style: StBold(14, text_main),),
              ],
            ),
          ),
          SizedBox(
              width: _chartWidth,
              child: Stack(
                children: [
                  Container(
                    height: 24,
                    decoration: RegularBorder(backgroundColor: text_main2.withOpacity(0.1), radius: 6.0, colorBorder: transparent),
                  ),
                  Container(
                    height: 24,
                    width: _chartWidth*percent,
                    decoration: RegularBorder(backgroundColor: colorTheme, radius: 6.0, colorBorder: transparent),
                  ),
                ],
              )
          )
        ],
      ),
    );
  }


  _itemData(FollowLeaderCurrencyEntity item){
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(coinName(item), style: StBold(16, text_main),),
          const SizedBox(height: 9,),
          Row(
            children: [
              ///交易次数
              _item(3, S.of(context).follow_trade_count, "${item.tradeCount ?? 0}",CrossAxisAlignment.start),
              ///占比
              _item(3, S.of(context).follow_rate, "${item.rate ?? 0}".percent + "%",CrossAxisAlignment.start),
              ///胜率
              _item(3, S.of(context).follow_over_total_profit_win, "${item.winRate ?? 0}".percent + "%",CrossAxisAlignment.start),
              ///盈亏额
              _item(3, S.of(context).follow_profit_loss_count, (item.profitNum ?? "0").fixNumberTwoDecimal,CrossAxisAlignment.end),
            ],
          )
        ],
      ),
    );
  }
  _item(int flex, String title, String value, CrossAxisAlignment crossAxisAlignment){
    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(title, style: StRegular(12, text_main2),),
          const SizedBox(height: 6,),
          Text(value, style: StMedium(12, text_main),),
        ],
      ),
    );
  }

  String coinName(FollowLeaderCurrencyEntity item){
    String? currencyName = item.currencyName;
    if(currencyName == 'other'){
      currencyName = S.of(context).otc_black_other;
    }
    return currencyName ?? '';
  }


  _titleWidget(){
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ///交易偏好
          Text(S.of(context).follow_trade_preference, style: StMedium(14, text_main),),
          const SizedBox(width: 10,),
          _popupMenu(),
        ],
      ),
    );
  }

  Widget _popupMenu(){

    return PopupMenuButton<String>(
      offset:const Offset(20, 30),
      onSelected: (String value) {
        setState(() {
          _selectTitle = value;
          _getPerperenceData();
        });
      },
      itemBuilder: (BuildContext context) {
        return _timeTitles.map((String value) {
          return PopupMenuItem<String>(
            value: value,
            child: Text(value, style: StMedium(14, text_main),),
          );
        }).toList();
      },
      child: FollowSelectTimeWidget(_selectTitle),
    );
  }

  @override
  bool get wantKeepAlive => true;

}

mixin _StatsFollowPerferenceWidgetBloc on State<StatsFollowPerferenceWidget> {
  bool _isInitialized = false;
  late double _chartWidth;
  late List<String> _timeTitles;
  late String _selectTitle;
  List<FollowLeaderCurrencyEntity> _dataList = [];

  _init() {
    _chartWidth = ScreenUtil().screenWidth - 60 - 80;
    _timeTitles = [S.of(context).follow_stats_three_day,S.of(context).otc_nearly_a_week,S.of(context).follow_three_week];
    _selectTitle = S.of(context).otc_nearly_a_week;
    _getPerperenceData();
  }

  //获取偏好设置
  _getPerperenceData(){
    Map<String, dynamic> params = {};
    params["leaderId"] = widget.leaderId;
    int date = 7;
    if(_selectTitle == S.of(context).follow_stats_three_day){
      date= 3;
    }else if(_selectTitle == S.of(context).follow_three_week){
      date = 21;
    }
    params["recentDay"] = date;

    httpClientContract.post<List<FollowLeaderCurrencyEntity>>(
        url: UrlConst.API_FOLLOW_LEADER_CURRENCY_STATISTIC,
        parameters: params,
        showErrorMessage: true,
        showLoading: false,
        onSuccess: (resp) {
          if(resp != null){
            setState(() {
              _dataList = resp;
            });
          }
        });
  }
}
