// import 'package:flutter/material.dart';

// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:bandspace_mobile/features/track_player/cubit/track_player_cubit.dart';
// import 'package:bandspace_mobile/features/track_player/cubit/track_player_state.dart';

// class NewTrackListWidget extends StatelessWidget {
//   const NewTrackListWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<TrackPlayerCubit, TrackPlayerState>(
//       builder: (context, state) {
//         return ListView.builder(
//           padding: EdgeInsets.zero,
//           itemCount: state.tracks.length,
//           itemBuilder: (context, index) {
//             final track = state.tracks[index];
//             final bool isSelected = state.currentTrackIndex == index;

//             return ListTile(
//               selected: isSelected,
//               selectedTileColor: Theme.of(
//                 context,
//               ).colorScheme.primary.withOpacity(0.1),
//               title: Text(track.title),
//               subtitle: Text(track.createdBy.name),
//               enabled: track.mainVersion != null,
//               onTap: () {
//                 if (track.mainVersion != null) {
//                   context.read<TrackPlayerCubit>().onTrackSelected(index);
//                 }
//               },
//               trailing:
//                   isSelected && (state.playerUiStatus == PlayerUiStatus.playing)
//                   ? const Icon(Icons.volume_up)
//                   : null,
//             );
//           },
//         );
//       },
//     );
//   }
// }
