import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:popsign/core/helpers/extension.dart';
import 'package:popsign/core/theme/styles.dart';

import '../theme/app_colors.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final bool isBackButton;
  const CustomAppBar({
    super.key,
    required this.title,
    required this.isBackButton,
  });

  @override
  Widget build(BuildContext context) {
    return Row(

      mainAxisSize: MainAxisSize.max,
      children: [
        if (isBackButton == true)
          GestureDetector(
            onTap: () {
              context.pop();
            },
            child: Container(
              width: 40.w,
              height: 40.h,
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 8.w),
              decoration: BoxDecoration(
                color: AppColors.darkGray,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: const Icon(
                size: 18,
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ),
          ),
        // horizontalSpace(5),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.font22BoldWhiteInter.copyWith(
              overflow: TextOverflow.ellipsis,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
        SizedBox(width: 48.w),
      ],
    );
    // return ListTile(
    //   leading: isBackButton
    //       ? GestureDetector(
    //           onTap: () {
    //             context.pop();
    //           },
    //           child: Container(
    //             width: 40.w,
    //             height: 40.h,
    //             alignment: Alignment.center,
    //             padding: EdgeInsets.only(left: 8.w),
    //             decoration: BoxDecoration(
    //               color: AppColors.darkGray,
    //               borderRadius: BorderRadius.circular(10.r),
    //             ),
    //             child: const Icon(
    //               size: 18,
    //               Icons.arrow_back_ios,
    //               color: Colors.white,
    //             ),
    //           ),
    //         )
    //       : SizedBox.shrink(),
    //   title: Text(
    //     title,
    //     style: AppTextStyles.font22BoldWhiteInter.copyWith(
    //       overflow: TextOverflow.ellipsis,
    //     ),
    //     textAlign: TextAlign.center,
    //     maxLines: 2,
    //   ),
    // );
  }
}
