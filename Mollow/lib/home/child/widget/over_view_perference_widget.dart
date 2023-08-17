
import 'package:coinw_flutter/bean/follow/follow_trader_entity.dart';
import 'package:coinw_flutter/modules/common/style/common_border.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/utils/collection_utils.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_international/generated/l10n.dart';
import 'package:module_core/widget/custom_cached_network_image.dart';
import 'package:module_core/widget/empty_widget.dart';
import 'package:module_follow/common/follow_action_manager.dart';

///交易员偏好 订单
class OverViewPerferenceWidget extends StatelessWidget {
  const OverViewPerferenceWidget({Key? key, this.traderEntity}) : super(key: key);
  final FollowTraderEntity? traderEntity;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _contentWidgets(context),
    );
  }


  List<Widget> _contentWidgets(BuildContext context){
    List<Widget> list = [];
    list.add(Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 22),
      ///Ta的偏好
      child: Text(S.of(context).follow_trader_order_perference, style: StBold(16, text_main),),),);
    if(traderEntity != null && CollectionUtils.isNotBlank(traderEntity!.preferenceCurrency)){
      traderEntity!.preferenceCurrency!.forEach((element) {
        list.add(_items(context, element,));
      });
    }else{
      list.add(EmptyWidget());
    }

    return list;
  }


  _items(BuildContext context, FollowTraderPreferenceCurrency currency){

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
      child: Row(
        children: [
          CustomCachedNetworkImage(
            currency.icon,
            fit: BoxFit.cover,
            width: 36,
            height: 36,
          ),
          const SizedBox(width: 9,),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(currency.currencyName ?? "", style: StMedium(14, text_main),textAlign: TextAlign.left,),
              // const SizedBox(height: 5,),
              // Text("334443.5555", style: StBold(16, text_main),textAlign: TextAlign.left,)
            ],
          )),
          // const SizedBox(width: 9,),
          // Text("12.3%", style: StBold(16, color_drop)),
          // const SizedBox(width: 18,),
          InkWell(
            onTap: (){
              FollowActionManager.pushFollowToContractTransction(context, currency.currencyName);
            },
            child: Container(
              constraints: const BoxConstraints(maxWidth: 100, minWidth: 60),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
              decoration: RegularBorder(colorBorder: transparent, backgroundColor: text_main2.withAlpha(25), radius: 6.0),
              child: Column(
                children: [
                  ///交易
                  Text(S.of(context).assets_home_transaction, style: StRegular(14, text_main),),
                ],
              ),
            ),
          )

        ],
      ),
    );
  }


}
