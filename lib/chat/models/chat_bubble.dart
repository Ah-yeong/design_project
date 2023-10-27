import 'package:design_project/main.dart';
import 'package:design_project/resources/resources.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble(this.message, this.isMe, this.userName, this.time,
      {Key? key, this.longBubble, this.isDayDivider, this.invisibleTime, this.unreadUserCount, this.uuid})
      : super(key: key);

  final int? unreadUserCount;
  final bool? invisibleTime;
  final bool? isDayDivider;
  final bool? longBubble;
  final String time;
  final String message;
  final String? userName;
  final bool isMe;
  final String? uuid;

  @override
  Widget build(BuildContext context) {
    Color bubbleColor = !isMe ? Colors.grey[300]! : Color(0xFF6ACA89);
    bool _invisibleTime = invisibleTime ?? false;
    bool _isDayDivider = isDayDivider ?? false;
    bool _longBubble = longBubble ?? false;
    int _unreadUserCount = unreadUserCount ?? 0;
    Color textColor = !isMe ? Colors.black : Colors.white;
    return !_isDayDivider
        ? Row(
           mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 50,
                child: !_longBubble && !isMe ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: colorLightGrey,
                      backgroundImage: userTempImage[uuid],
                    ),
                  ),
                ) : const SizedBox(),
              ),
              Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMe && !_longBubble)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        userName ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isMe && _unreadUserCount != 0)
                                Text(
                                  _unreadUserCount.toString(),
                                  style: TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.bold),
                                ),
                              if (isMe && !_invisibleTime)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: bubbleColor,
                              borderRadius: BorderRadius.only(
                                topRight: isMe && !_longBubble ? Radius.circular(0) : Radius.circular(12),
                                topLeft: !isMe && !_longBubble ? Radius.circular(0) : Radius.circular(12),
                                bottomRight: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                            margin: EdgeInsets.fromLTRB(8, 3, 8, _invisibleTime ? 0 : 2.5),
                            child: Text(
                              message,
                              style: TextStyle(
                                color: textColor,
                              ),
                            ),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 6.6 / 10,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (!isMe && _unreadUserCount != 0)
                                Text(
                                  _unreadUserCount.toString(),
                                  style: TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.bold),
                                ),
                              if (!isMe && !_invisibleTime)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              )
            ],
          )
        : Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: const Divider(thickness: 1,),
                  )),
                  Text(
                    time
                        .replaceAll("Mon", "월요일")
                        .replaceAll("Tue", "화요일")
                        .replaceAll("Wed", "수요일")
                        .replaceAll("Thu", "목요일")
                        .replaceAll("Fri", "금요일")
                        .replaceAll("Sat", "토요일")
                        .replaceAll("Sun", "일요일"),
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: colorGrey
                    ),
                  ),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: const Divider(thickness: 1,),
                  )),
                ],
              )
            ),
          );
  }
}

// import 'package:flutter/material.dart';
// import 'package:chat_bubbles/chat_bubbles.dart';
//
// class ChatBubble extends StatelessWidget {
//   const ChatBubble(this.message, this.isMe, this.userName, {Key? key})
//       : super(key: key);
//
//
//   final String message;
//   final String? userName;
//   final bool isMe;
//
//   @override
//   Widget build(BuildContext context) {
//     Color bubbleColor = isMe ? Colors.grey[300]! : Color(0xFF6ACA89);
//
//     Color textColor = isMe ? Colors.black : Colors.white;
//
//     return Row(
//       mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             color: bubbleColor,
//             borderRadius: BorderRadius.only(
//               topRight: Radius.circular(12),
//               topLeft: Radius.circular(12),
//               bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
//               bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
//             ),
//           ),
//           padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//           margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 userName ?? 'Unknown',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey,
//                 ),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 message,
//                 style: TextStyle(
//                   color: textColor,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class ChatBubble extends StatelessWidget {
//   //const ChatBubble(this.message, this.isMe, {Key? key}) : super(key: key);
//   const ChatBubble(this.message, this.isMe, this.userName, {Key? key})
//       : super(key: key);
//
//
//   final String message;
//   final String? userName;
//   final bool isMe;
//   //DateTime now = DateTime.now();
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Row(
//       mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,  //나 : 왼쪽 / 상대방 : 오른쪽 배치
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             color: isMe ? Colors.grey[300] : Color(0xFF6ACA89), //나 : grey / 상대방 : blue
//             borderRadius: BorderRadius.only(  //채팅 말풍선? 위치 지정
//                 topRight: Radius.circular(12),
//                 topLeft: Radius.circular(12),
//                 bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
//                 bottomLeft:  isMe ? Radius.circular(12) : Radius.circular(0)
//             ),
//           ),
//           padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//           margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//           child: Text(
//             message,
//             style: TextStyle(
//                 color: isMe ? Colors.black : Colors.white //나 : black / 상대방 : white
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// import 'package:flutter/material.dart';
//
// class ChatBubble extends StatelessWidget {
//   const ChatBubble(this.message, this.isMe, {Key? key}) : super(key: key);
//
//   final String message;
//   final bool isMe;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,  //나 : 왼쪽 / 상대방 : 오른쪽 배치
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             color: isMe ? Colors.grey[300] : Color(0xFF6ACA89), //나 : grey / 상대방 : blue
//             borderRadius: BorderRadius.only(  //채팅 말풍선? 위치 지정
//                 topRight: Radius.circular(12),
//                 topLeft: Radius.circular(12),
//                 bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
//                 bottomLeft:  isMe ? Radius.circular(12) : Radius.circular(0)
//             ),
//           ),
//           width: 145,
//           padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//           margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//           child: Text(
//             message,
//             style: TextStyle(
//                 color: isMe ? Colors.black : Colors.white //나 : black / 상대방 : white
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

/////////////////////////////////////////////////////////////////////////
//채팅 - 말풍선
// class ChatBubble extends StatelessWidget {
//   const ChatBubble(this.message, this.isMe, {Key? key}) : super(key: key);
//
//   final String message;
//   final bool isMe;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//       children: [
//         BubbleSpecialOne(
//           text: message,
//           color: isMe ? Colors.grey[300]! : Color(0xFF6ACA89),
//           tail: true,
//           textStyle: TextStyle(
//             color: isMe ? Colors.black : Colors.white,
//           ),
//           isSender: isMe,
//         ),
//       ],
//     );
//   }
// }
