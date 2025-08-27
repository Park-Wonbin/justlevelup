import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:justlevelup/icon.dart';
import 'package:justlevelup/text.dart';

class StoreBottomSheet extends StatefulWidget {
  const StoreBottomSheet({super.key});

  @override
  State<StoreBottomSheet> createState() => _StoreBottomSheetState();
}

const items = {
  "shield10": {
    "name": "Shield",
    "price": "\$0.99",
    "count": 10,
    "desc": "prevent the character\nfrom going back to level 1",
    "icon": "item1",
  },
  "shield50": {
    "name": "Shield",
    "price": "\$1.99",
    "count": 50,
    "desc": "prevent the character\nfrom going back to level 1",
    "icon": "item1",
  },
  "candyBar": {
    "name": "Candy bar",
    "price": "\$1.99",
    "count": 1,
    "desc": "probability of destruction\n-10%",
    "icon": "item2",
  },
  "fieryHeart": {
    "name": "Fiery heart",
    "price": "\$1.99",
    "count": 1,
    "desc": "destruction rate to 0%\nfrom one minute",
    "icon": "item3",
  }
};

class _StoreBottomSheetState extends State<StoreBottomSheet> {

  showModal(dynamic item) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            elevation: 0,
            // backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(20),
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                color: Color(0xff9789cc),
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: [
                  TextWithStroke(color: Color(0xffffbb00), text: item["name"], fontSize: 15),
                  Row(
                    spacing: 16,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Color(0xffe1c0bf),
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconWithText(item["icon"], text: item["count"] > 1 ? "x${item["count"]}" : ""),
                      ),
                      Expanded(
                        child: Bounceable(
                          onTap: () {},
                          child: Column(
                            spacing: 10,
                            children: [
                              TextWithStroke(color: Colors.white, text: "BUY", fontSize: 16),
                              TextWithStroke(color: Color(0xff248700), text: item["price"], fontSize: 16),
                              SizedBox(height: 0)
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  TextWithStroke(color: Colors.white, text: item["desc"], fontSize: 10),
                ]
              ),
            ),
          );
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 145 + MediaQuery.of(context).padding.bottom, // 100 + 45 + SafeArea
      child: Stack(
        children: [
          // 하단 보라색 바탕
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xff9789cc),
                border: Border(
                  top: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Bounceable(
                        onTap: () {
                          showModal(items["shield10"]);
                        },
                        child: IconWithText("item1", text: "x10"),
                      ),
                      Bounceable(
                        onTap: () {
                          showModal(items["shield50"]);
                        },
                        child: IconWithText("item1", text: "x50"),
                      ),
                      Bounceable(
                        onTap: () {
                          showModal(items["candyBar"]);
                        },
                        child: IconWithText("item2"),
                      ),
                      Bounceable(
                        onTap: () {
                          showModal(items["fieryHeart"]);
                        },
                        child: IconWithText("item3")
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 상단 닫기 버튼 바
          Positioned(
            top: 0,
            left: 20,
            child: Container(
              width: 60,
              height: 45,
              decoration: const BoxDecoration(
                color: Color(0xff9789cc),
                border: Border(
                  top: BorderSide(color: Colors.black, width: 2),
                  left: BorderSide(color: Colors.black, width: 2),
                  right: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              child: Bounceable(
                onTap: () => Navigator.of(context).pop(),
                child: Image.asset(
                  'assets/icons/x.png',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
