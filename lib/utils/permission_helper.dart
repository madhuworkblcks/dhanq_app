import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

class PermissionHelper {
  static Future<bool> getMicrophonePermission(BuildContext context) async {
    try {
      // Check current permission status

      PermissionStatus status = await Permission.microphone.status;

      debugPrint('Initial microphone permission status: $status');

      // If already granted, return true
      if (status.isGranted) {
        debugPrint('Microphone permission already granted');
        return true;
      }

      // If permanently denied, handle it specially
      if (status.isPermanentlyDenied) {
        debugPrint('Microphone permission permanently denied');
        if (context.mounted) {
          bool shouldRetry = await handlePermanentlyDeniedPermission(context);
          if (shouldRetry) {
            // User wants to try again, check permission status
            await Future.delayed(const Duration(milliseconds: 1000));
            status = await Permission.microphone.status;
            debugPrint('Permission status after retry: $status');
            
            if (status.isGranted) {
              debugPrint('Permission granted after retry');
              return true;
            } else if (status.isDenied) {
              debugPrint('Permission changed from permanently denied to denied, can request again');
              // Try requesting permission again
              status = await Permission.microphone.request();
              debugPrint('Permission request result after retry: $status');
              return status.isGranted;
            }
          }
        }
        return false;
      }

      // For iOS, handle permission request more carefully
      if (Platform.isIOS) {
        debugPrint('Requesting microphone permission on iOS');

        // First, try to request permission
        status = await Permission.microphone.request();
        debugPrint('iOS microphone permission result: $status');

        // Handle different iOS permission states
        if (status.isGranted) {
          debugPrint('iOS microphone permission granted');
          // Wait a bit and re-check to ensure it's really granted
          await Future.delayed(const Duration(milliseconds: 1000));
          status = await Permission.microphone.status;
          debugPrint('iOS microphone permission re-check result: $status');
          return status.isGranted;
        } else if (status.isPermanentlyDenied) {
          debugPrint('iOS microphone permission permanently denied - showing settings dialog');
          if (context.mounted) {
            bool shouldRetry = await handlePermanentlyDeniedPermission(context);
            if (shouldRetry) {
              // User wants to try again, check permission status
              await Future.delayed(const Duration(milliseconds: 1000));
              status = await Permission.microphone.status;
              debugPrint('iOS permission status after retry: $status');
              
              if (status.isGranted) {
                debugPrint('iOS permission granted after retry');
                return true;
              } else if (status.isDenied) {
                debugPrint('iOS permission changed from permanently denied to denied, can request again');
                // Try requesting permission again
                status = await Permission.microphone.request();
                debugPrint('iOS permission request result after retry: $status');
                
                if (status.isGranted) {
                  // Wait and re-check
                  await Future.delayed(const Duration(milliseconds: 1000));
                  status = await Permission.microphone.status;
                  debugPrint('iOS permission final re-check result: $status');
                  return status.isGranted;
                }
              }
            }
          }
          return false;
        } else if (status.isDenied) {
          debugPrint('iOS microphone permission denied, trying retry');
          // Try one more time for iOS
          await Future.delayed(const Duration(milliseconds: 500));
          status = await Permission.microphone.request();
          debugPrint('iOS microphone permission retry result: $status');

          if (status.isGranted) {
            // Wait and re-check again
            await Future.delayed(const Duration(milliseconds: 1000));
            status = await Permission.microphone.status;
            debugPrint(
              'iOS microphone permission retry re-check result: $status',
            );
            return status.isGranted;
          } else {
            debugPrint('iOS permission still denied after retry, showing settings dialog');
            if (context.mounted) {
              await _showPermissionSettingsDialog(context);
            }
            return false;
          }
        }
      } else {
        // For Android, use the standard approach
        debugPrint('Requesting microphone permission on Android');
        status = await Permission.microphone.request();
        debugPrint('Android microphone permission result: $status');

        if (!status.isGranted) {
          if (context.mounted) {
            await _showPermissionSettingsDialog(context);
          }
          return false;
        }
      }

      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting microphone permission: $e');
      if (context.mounted) {
        await _showPermissionSettingsDialog(context);
      }
      return false;
    }
  }

  static Future<void> _showPermissionSettingsDialog(
    BuildContext context,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Microphone Permission Required'),
          content: const Text(
            'This app needs microphone access for voice input and speech-to-text functionality. Please grant microphone permission in settings to continue.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Check if microphone permission is available without requesting
  static Future<bool> isMicrophonePermissionGranted() async {
    try {
      PermissionStatus status = await Permission.microphone.status;
      debugPrint('Checking microphone permission status: $status');
      
      // For iOS, if status is denied (not permanently denied), we might still be able to request it
      if (Platform.isIOS && status.isDenied) {
        debugPrint('iOS permission is denied, but can be requested again');
        return false;
      }
      
      bool isGranted = status.isGranted;
      debugPrint('Microphone permission isGranted: $isGranted');
      return isGranted;
    } catch (e) {
      debugPrint('Error checking microphone permission: $e');
      return false;
    }
  }

  /// Get detailed microphone permission status for debugging
  static Future<PermissionStatus> getDetailedMicrophoneStatus() async {
    try {
      PermissionStatus status = await Permission.microphone.status;
      debugPrint('Detailed microphone permission status: $status');
      debugPrint('Status details - isGranted: ${status.isGranted}, isDenied: ${status.isDenied}, isPermanentlyDenied: ${status.isPermanentlyDenied}, isRestricted: ${status.isRestricted}');
      return status;
    } catch (e) {
      debugPrint('Error getting detailed microphone status: $e');
      return PermissionStatus.denied;
    }
  }

  /// Force refresh microphone permission status with delay
  static Future<bool> refreshMicrophonePermissionStatus() async {
    try {
      // Add a small delay to allow iOS to update permission status
      await Future.delayed(const Duration(milliseconds: 500));
      PermissionStatus status = await Permission.microphone.status;
      debugPrint('Refreshed microphone permission status: $status');
      return status.isGranted;
    } catch (e) {
      debugPrint('Error refreshing microphone permission: $e');
      return false;
    }
  }





  /// Detect and handle iOS permission inconsistency
  static Future<bool> handleIOSPermissionInconsistency(BuildContext context) async {
    try {
      debugPrint('=== HANDLING iOS PERMISSION INCONSISTENCY ===');
      
      // Get current status
      PermissionStatus status = await Permission.microphone.status;
      debugPrint('Current permission status: $status');
      
      // Check if we're in an inconsistent state (denied but not permanently denied)
      bool isInconsistent = status.isDenied && !status.isPermanentlyDenied;
      debugPrint('Permission inconsistency detected: $isInconsistent');
      
      if (isInconsistent) {
        debugPrint('iOS permission is in inconsistent state, trying direct speech_to_text...');
        
        // Try to initialize speech_to_text directly
        final speechToText = SpeechToText();
        bool available = await speechToText.initialize(
          onError: (error) => debugPrint('Direct speech_to_text error: $error'),
          onStatus: (status) => debugPrint('Direct speech_to_text status: $status'),
        );
        
        debugPrint('Direct speech_to_text available: $available');
        
        if (available) {
          debugPrint('Speech_to_text works despite permission showing as denied');
          return true;
        }
      }
      
      // If not inconsistent or speech_to_text not available, show settings dialog
      debugPrint('Permission is consistent or speech_to_text not available, showing settings dialog');
      if (context.mounted) {
        bool shouldRetry = await handlePermanentlyDeniedPermission(context);
        if (shouldRetry) {
          // Wait and try speech_to_text again
          await Future.delayed(const Duration(milliseconds: 2000));
          
          final speechToText = SpeechToText();
          bool availableAfterSettings = await speechToText.initialize(
            onError: (error) => debugPrint('Speech_to_text error after settings: $error'),
            onStatus: (status) => debugPrint('Speech_to_text status after settings: $status'),
          );
          
          debugPrint('Speech_to_text available after settings: $availableAfterSettings');
          return availableAfterSettings;
        }
      }
      
      return false;
    } catch (e) {
      debugPrint('Error in iOS permission inconsistency handling: $e');
      return false;
    }
  }

  /// Handle iOS permission quirk where first denial becomes permanently denied
  static Future<bool> handleIOSPermissionQuirk(BuildContext context) async {
    try {
      debugPrint('=== HANDLING iOS PERMISSION QUIRK ===');
      
      // Get current status
      PermissionStatus status = await Permission.microphone.status;
      debugPrint('Initial iOS permission status: $status');
      
      // If already granted, return true
      if (status.isGranted) {
        debugPrint('iOS permission already granted');
        return true;
      }
      
      // If it's denied, try requesting (might become permanently denied)
      if (status.isDenied) {
        debugPrint('iOS permission is denied, requesting...');
        status = await Permission.microphone.request();
        debugPrint('iOS permission request result: $status');
        
        if (status.isGranted) {
          debugPrint('iOS permission granted after request');
          return true;
        }
        
        // If it became permanently denied, show settings dialog
        if (status.isPermanentlyDenied) {
          debugPrint('iOS permission became permanently denied, showing settings dialog');
          if (context.mounted) {
            bool shouldRetry = await handlePermanentlyDeniedPermission(context);
            if (shouldRetry) {
              // Wait longer and check multiple times
              for (int i = 0; i < 3; i++) {
                await Future.delayed(const Duration(milliseconds: 2000));
                status = await Permission.microphone.status;
                debugPrint('iOS permission status after settings (attempt ${i + 1}): $status');
                
                if (status.isGranted) {
                  debugPrint('iOS permission granted after settings (attempt ${i + 1})');
                  return true;
                }
              }
              
              // If still not granted, try requesting again
              debugPrint('Permission still not granted after settings, trying to request again...');
              status = await Permission.microphone.request();
              debugPrint('Permission request after settings: $status');
              
              if (status.isGranted) {
                debugPrint('Permission granted after second request');
                return true;
              }
            }
          }
          return false;
        }
      }
      
      // If it's already permanently denied
      if (status.isPermanentlyDenied) {
        debugPrint('iOS permission is already permanently denied');
        if (context.mounted) {
          bool shouldRetry = await handlePermanentlyDeniedPermission(context);
          if (shouldRetry) {
            // Wait longer and check multiple times
            for (int i = 0; i < 3; i++) {
              await Future.delayed(const Duration(milliseconds: 2000));
              status = await Permission.microphone.status;
              debugPrint('iOS permission status after settings (attempt ${i + 1}): $status');
              
              if (status.isGranted) {
                debugPrint('iOS permission granted after settings (attempt ${i + 1})');
                return true;
              }
            }
            
            // If still not granted, try requesting again
            debugPrint('Permission still not granted after settings, trying to request again...');
            status = await Permission.microphone.request();
            debugPrint('Permission request after settings: $status');
            
            if (status.isGranted) {
              debugPrint('Permission granted after second request');
              return true;
            }
          }
        }
        return false;
      }
      
      debugPrint('iOS permission quirk handling failed');
      return false;
    } catch (e) {
      debugPrint('Error in iOS permission quirk handling: $e');
      return false;
    }
  }

  /// Check if microphone permission is permanently denied
  static Future<bool> isMicrophonePermissionPermanentlyDenied() async {
    try {
      PermissionStatus status = await Permission.microphone.status;
      debugPrint('Checking if microphone permission is permanently denied: $status');
      return status.isPermanentlyDenied;
    } catch (e) {
      debugPrint('Error checking permanently denied status: $e');
      return false;
    }
  }

  /// Reset microphone permission (useful for testing)
  static Future<void> resetMicrophonePermission() async {
    try {
      await Permission.microphone.request();
      debugPrint('Microphone permission reset requested');
    } catch (e) {
      debugPrint('Error resetting microphone permission: $e');
    }
  }

  /// Comprehensive permission status check for debugging
  static Future<void> debugAllPermissions() async {
    debugPrint('=== COMPREHENSIVE PERMISSION DEBUG ===');
    
    try {
      // Check microphone permission
      PermissionStatus micStatus = await Permission.microphone.status;
      debugPrint('Microphone Status: $micStatus');
      debugPrint('  - isGranted: ${micStatus.isGranted}');
      debugPrint('  - isDenied: ${micStatus.isDenied}');
      debugPrint('  - isPermanentlyDenied: ${micStatus.isPermanentlyDenied}');
      debugPrint('  - isRestricted: ${micStatus.isRestricted}');
      
      // Check speech recognition permission (iOS)
      if (Platform.isIOS) {
        PermissionStatus speechStatus = await Permission.speech.status;
        debugPrint('Speech Recognition Status: $speechStatus');
        debugPrint('  - isGranted: ${speechStatus.isGranted}');
        debugPrint('  - isDenied: ${speechStatus.isDenied}');
        debugPrint('  - isPermanentlyDenied: ${speechStatus.isPermanentlyDenied}');
      }
      
      // Check if we can request microphone permission
      bool canRequest = await Permission.microphone.shouldShowRequestRationale;
      debugPrint('Can request microphone permission: $canRequest');
      
    } catch (e) {
      debugPrint('Error in comprehensive permission debug: $e');
    }
    
    debugPrint('=== END PERMISSION DEBUG ===');
  }

  /// Check if permission is permanently denied and show appropriate dialog
  static Future<bool> handlePermanentlyDeniedPermission(BuildContext context) async {
    debugPrint('Handling permanently denied microphone permission');
    
    if (context.mounted) {
      return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Microphone Permission Required'),
            content: const Text(
              'Microphone access is currently blocked. To use voice input, please:\n\n'
              '1. Go to Settings > Privacy & Security > Microphone\n'
              '2. Find "Dhanq App" in the list\n'
              '3. Enable the toggle switch\n\n'
              'Then return to the app and try again.',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Open Settings'),
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: const Text('Try Again'),
                onPressed: () async {
                  Navigator.of(context).pop(true);
                },
              ),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        },
      ) ?? false;
    }
    return false;
  }
}
