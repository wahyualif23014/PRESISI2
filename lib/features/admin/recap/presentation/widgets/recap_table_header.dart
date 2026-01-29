// import 'package:flutter/material.dart';

// class RecapTableHeader extends StatelessWidget {
//   const RecapTableHeader({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
//       ),
//       child: Row(
//         children: const [
//           Expanded(flex: 3, child: Text("WILAYAH", style: _headerStyle)),
//           Expanded(flex: 2, child: Text("POTENSI LAHAN", style: _headerStyle, textAlign: TextAlign.center)),
//           Expanded(flex: 2, child: Text("TANAM LAHAN", style: _headerStyle, textAlign: TextAlign.center)),
//           Expanded(flex: 3, child: Text("PANEN", style: _headerStyle, textAlign: TextAlign.center)),
//           Expanded(flex: 2, child: Text("SERAPAN", style: _headerStyle, textAlign: TextAlign.center)),
//         ],
//       ),
//     );
//   }
// }

// const TextStyle _headerStyle = TextStyle(
//   fontSize: 10,
//   fontWeight: FontWeight.bold,
//   color: Colors.black,
// );