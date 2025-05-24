import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class UserAvatar extends StatefulWidget {
  final double? radius;
  final String imageUrl;
  final int maxRetryAttempts;
  final Duration retryDelay;

  const UserAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 35,
    this.maxRetryAttempts = 2,
    this.retryDelay = const Duration(seconds: 2),
  });

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  int _retryCount = 0;
  bool _isOffline = false;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if(mounted){
    setState(() {
      _isOffline = connectivityResult == ConnectivityResult.none;
    });
    }

  }

  Future<void> _handleRetry() async {
    if (_retryCount >= widget.maxRetryAttempts) return;
if(mounted){
setState(() {
      _retryCount++;
      _hasError = false;
      _isLoading = true;
    });
}
    

    await Future.delayed(widget.retryDelay);
    _checkConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.radius! * 2;

    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Default placeholder image
            Image.asset(
              'assets/img/default_profile.png',
              fit: BoxFit.cover,
              width: size,
              height: size,
            ),

            // Network image with improved handling
            if (!_isOffline && !_hasError)
              CachedNetworkImage(
                imageUrl: widget.imageUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, progress) {
                  return _buildLoadingState(progress);
                },
                errorWidget: (context, url, error) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _hasError = true;
                        _isLoading = false;
                      });
                      _handleRetry();
                    }
                  });
                  return const SizedBox();
                },
              ),

            // Offline indicator
            if (_isOffline)
              Container(
                color: Colors.black54,
                width: size,
                height: size,
                child: const Icon(
                  Icons.signal_wifi_off,
                  color: Colors.white,
                  size: 24,
                ),
              ),

            // Error indicator with retry button
            if (_hasError && _retryCount >= widget.maxRetryAttempts)
              GestureDetector(
                onTap: _handleRetry,
                child: Container(
                  color: Colors.black54,
                  width: size,
                  height: size,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to retry',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(DownloadProgress? progress) {
    if (progress == null) return const SizedBox();

    final percent = progress.progress ?? 0;
    return Center(
      child: CircularProgressIndicator(
        value: percent == 0 ? null : percent,
        strokeWidth: 2,
      ),
    );
  }
}
