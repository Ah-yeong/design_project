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
//
//


import 'package:flutter/material.dart';

class BubbleSpecialThree extends StatelessWidget {
  const BubbleSpecialThree({
    Key? key,
    required this.text,
    required this.color,
    required this.tail,
    required this.textStyle,
  }) : super(key: key);

  final String text;
  final Color color;
  final bool tail;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 5,
              height: 1,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                  bottomLeft: tail ? Radius.circular(0) : Radius.circular(4),
                  bottomRight: tail ? Radius.circular(0) : Radius.circular(4),
                ),
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              topLeft: Radius.circular(12),
              bottomRight: tail ? Radius.circular(0) : Radius.circular(12),
              bottomLeft: tail ? Radius.circular(12) : Radius.circular(0),
            ),
          ),
          width: 145,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Text(
            text,
            style: textStyle,
          ),
        ),
      ],
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble(this.message, this.isMe, {Key? key}) : super(key: key);

  final String message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        BubbleSpecialThree(
          text: message,
          color: isMe ? Colors.grey[300]! : Color(0xFF6ACA89),
          tail: !isMe,
          textStyle: TextStyle(
            color: isMe ? Colors.black : Colors.white,
          ),
        ),
      ],
    );
  }
}
