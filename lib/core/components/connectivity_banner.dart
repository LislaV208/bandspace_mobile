import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../cubit/connectivity_cubit.dart';

class ConnectivityBanner extends StatelessWidget {
  final Widget child;
  final bool showWhenOnline;

  const ConnectivityBanner({
    super.key,
    required this.child,
    this.showWhenOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _shouldShowBanner(state) ? null : 0,
              child: _shouldShowBanner(state)
                  ? _buildBanner(context, state)
                  : const SizedBox.shrink(),
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }

  bool _shouldShowBanner(ConnectivityState state) {
    if (state.isUnknown) return false;
    if (state.isOffline) return true;
    if (state.isOnline && showWhenOnline) return true;
    return false;
  }

  Widget _buildBanner(BuildContext context, ConnectivityState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Color backgroundColor;
    Color textColor;
    IconData icon;
    
    if (state.isOffline) {
      backgroundColor = colorScheme.errorContainer;
      textColor = colorScheme.onErrorContainer;
      icon = Icons.wifi_off;
    } else {
      backgroundColor = colorScheme.primaryContainer;
      textColor = colorScheme.onPrimaryContainer;
      icon = Icons.wifi;
    }

    return Container(
      width: double.infinity,
      color: backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: textColor,
              ),
              const Gap(8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.statusText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (state.isOffline && context.read<ConnectivityCubit>().getTimeSinceLastOnline() != null)
                      Text(
                        'Ostatnie połączenie: ${context.read<ConnectivityCubit>().getTimeSinceLastOnline()}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: textColor.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              if (state.isOffline) ...[
                if (state.isRetrying)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                else
                  InkWell(
                    onTap: () => context.read<ConnectivityCubit>().retryConnection(),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.refresh,
                        size: 16,
                        color: textColor,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}