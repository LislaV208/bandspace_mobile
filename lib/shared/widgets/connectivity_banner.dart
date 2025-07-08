// import 'package:flutter/material.dart';

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:gap/gap.dart';

// import '../cubit/connectivity_cubit.dart';

// class ConnectivityBanner extends StatelessWidget {
//   final Widget child;
//   final bool showWhenOnline;

//   const ConnectivityBanner({super.key, required this.child, this.showWhenOnline = false});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ConnectivityCubit, ConnectivityState>(
//       builder: (context, state) {
//         return Column(
//           children: [
//             Expanded(child: child),
//             AnimatedSize(
//               duration: const Duration(milliseconds: 300),
//               child: _shouldShowBanner(state) ? _buildBanner(context, state) : const SizedBox.shrink(),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   bool _shouldShowBanner(ConnectivityState state) {
//     if (state.isUnknown) return false;
//     if (state.isOffline) return true; // Tylko offline mode
//     // Sync jest transparentny - nie pokazujemy bannera podczas sync
//     return false;
//   }

//   Widget _buildBanner(BuildContext context, ConnectivityState state) {
//     // Fallback colors when Material theme is not available
//     Color backgroundColor;
//     Color textColor;
//     IconData icon;

//     if (state.isOffline) {
//       backgroundColor = const Color(0xFFFFEBEE); // Light red
//       textColor = const Color(0xFF8C1D18); // Dark red
//       icon = Icons.wifi_off;
//     } else {
//       backgroundColor = const Color(0xFFE3F2FD); // Light blue
//       textColor = const Color(0xFF1565C0); // Dark blue
//       icon = Icons.wifi;
//     }

//     return Material(
//       child: Directionality(
//         textDirection: TextDirection.ltr,
//         child: Container(
//           width: double.infinity,
//           color: backgroundColor,
//           child: SafeArea(
//             top: false,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Row(
//                 children: [
//                   Icon(icon, size: 16, color: textColor),
//                   const Gap(8),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           state.statusText,
//                           style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14),
//                         ),
//                         if (state.isOffline && context.read<ConnectivityCubit>().getTimeSinceLastOnline() != null)
//                           Text(
//                             'Ostatnie połączenie: ${context.read<ConnectivityCubit>().getTimeSinceLastOnline()}',
//                             style: TextStyle(color: textColor.withValues(alpha: 0.8), fontSize: 11),
//                           ),
//                         if (state.isSyncing)
//                           Text(
//                             'Synchronizacja...',
//                             style: TextStyle(color: textColor.withValues(alpha: 0.8), fontSize: 11),
//                           )
//                         else if (state.lastSyncTime != null)
//                           Text(
//                             'Ostatnia sync: ${context.read<ConnectivityCubit>().getTimeSinceLastSync()}',
//                             style: TextStyle(color: textColor.withValues(alpha: 0.8), fontSize: 11),
//                           ),
//                       ],
//                     ),
//                   ),
//                   if (state.isOffline) ...[
//                     if (state.isRetrying)
//                       SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(textColor),
//                         ),
//                       )
//                     else
//                       InkWell(
//                         onTap: () => context.read<ConnectivityCubit>().retryConnection(),
//                         borderRadius: BorderRadius.circular(16),
//                         child: Padding(
//                           padding: const EdgeInsets.all(4),
//                           child: Icon(Icons.refresh, size: 16, color: textColor),
//                         ),
//                       ),
//                   ] else if (state.isOnline && !state.isSyncing) ...[
//                     // Manual sync button when online
//                     InkWell(
//                       onTap: () => context.read<ConnectivityCubit>().triggerSync(),
//                       borderRadius: BorderRadius.circular(16),
//                       child: Padding(
//                         padding: const EdgeInsets.all(4),
//                         child: Icon(Icons.sync, size: 16, color: textColor),
//                       ),
//                     ),
//                   ] else if (state.isSyncing) ...[
//                     // Sync progress indicator
//                     SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(textColor),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
