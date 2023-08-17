
import 'package:coinw_flutter/bean/follow/tader_follower_entity.dart';
import 'package:flutter/material.dart';
import 'package:module_core/core/constant/color_const.dart';
import 'package:module_core/core/utils/lc_styles.dart';
import 'package:module_core/widget/custom_cached_network_image.dart';

///交易员关注者
class LikeTaderItem extends StatelessWidget {
  final TaderFollowerEntity followerEntity;
  const LikeTaderItem(this.followerEntity, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CustomCachedNetworkImage(
            followerEntity.profileUrl,
            width: 36,
            height: 36,
          ),
          const SizedBox(width: 10,),
          Expanded(child: Text(followerEntity.nickName ?? "", style: StBold(15, text_main),))
        ],
      ),
    );
  }
}
