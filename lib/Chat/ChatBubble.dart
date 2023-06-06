import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble(this.message, this.isMe, this.userName, {Key? key})
      : super(key: key);


  final String message;
  final String? userName;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    Color bubbleColor = isMe ? Colors.grey[300]! : Color(0xFF6ACA89);

    Color textColor = isMe ? Colors.black : Colors.white;

    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (!isMe)
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              userName ?? 'Unknown',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
            ),
          ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  topLeft: Radius.circular(12),
                  bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
                  bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ],
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

