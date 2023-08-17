

import 'package:coinw_flutter/bean/follow/follow_leader_currency_entity.dart';
import 'package:coinw_flutter/bean/follow/follow_trader_entity.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/url_const.dart';
import 'package:module_core/core/net/http_client.dart';
import 'package:module_follow/home/child/widget/stats_chart_line1_widget.dart';
import 'package:module_follow/home/child/widget/stats_chart_line2_widget.dart';
import 'package:module_follow/home/child/widget/stats_follow_other_widget.dart';
import 'package:module_follow/home/child/widget/stats_follow_perference_widget.dart';

///统计数据
class FollowStatsDataPage extends StatefulWidget {
  static const String routeName = "FollowStatsDataPage";
  final String leaderId;
  final FollowTraderEntity? traderEntity;

  static void start(BuildContext context) {
    Navigator.pushNamed(context, routeName);
  }

  const FollowStatsDataPage({Key? key, required this.leaderId, this.traderEntity}) : super(key: key);

  @override
  State<FollowStatsDataPage> createState() => _FollowStatsDataPageState();
}

class _FollowStatsDataPageState extends State<FollowStatsDataPage>
    with _FollowStatsDataPageBloc,AutomaticKeepAliveClientMixin {

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
      child: ListView.builder(
        itemBuilder: _itemBuilder,
        itemCount: 50,
      ),
    );
  }
  Widget _itemBuilder(BuildContext context, int index){
    if(index == 0){
      return StatsChartLine1Widget(leaderId: widget.leaderId,);
    }else if(index == 1){
      return StatsChartLine2Widget(leaderId: widget.leaderId,);
    }else if(index == 2){
      //偏好数据
      return StatsFollowPerferenceWidget(leaderId:widget.leaderId);
    }else if(index == 3){
      //其他数据
      return StatsFollowOtherWidget(traderEntity: widget.traderEntity,);
    }
    return Container();
  }

  @override
  bool get wantKeepAlive => true;


}

mixin _FollowStatsDataPageBloc on State<FollowStatsDataPage> {
  bool _isInitialized = false;

  _init() {

  }


}
