import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';

class SettingsDropdown extends StatefulWidget {
  @override
  _SettingsDropdownState createState() => _SettingsDropdownState();
}

class _SettingsDropdownState extends State<SettingsDropdown> {
  bool isSoundOff = false;
  bool isLocationOff = false;

  void _showWarningDialog(
      String title, String message, VoidCallback onConfirm, VoidCallback openSettings) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm(); 
                openSettings();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.settings),
      onCanceled: () {
        // Dismiss dropdown if the user taps outside
        Navigator.pop(context);
      },
      onSelected: (value) {
        if (value == 'sound') {
          _showWarningDialog(
            isSoundOff ? 'Turn On Sound' : 'Turn Off Sound',
            isSoundOff
                ? 'This will turn on the SOS alert.'
                : 'This will turn off the SOS alert.',
            () {
              setState(() {
                isSoundOff = !isSoundOff; // Toggle state
              });
            },
            () {
              AppSettings.openSoundSettings();
            }
          );
        } else if (value == 'location') {
          _showWarningDialog(
            isLocationOff ? 'Turn On Location Sharing' : 'Turn Off Location Sharing',
            isLocationOff
                ? 'This will turn on location sharing. Your emergency contact will be able to locate you.'
                : 'This will turn off location sharing. Your emergency contact will not be able to locate you.',
            () {
              setState(() {
                isLocationOff = !isLocationOff; // Toggle state
              });
            },
            () {
              AppSettings.openLocationSettings();
            }
          );
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'sound',
          child: Row(
            children: [
              Icon(
                isSoundOff ? Icons.volume_off : Icons.volume_up,
                color: Colors.green,
              ),
              SizedBox(width: 8),
              Text('Sound'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'location',
          child: Row(
            children: [
              Icon(
                isLocationOff ? Icons.location_off : Icons.location_on,
                color: Colors.green,
              ),
              SizedBox(width: 8),
              Text('Live Location'),
            ],
          ),
        ),
      ],
    );
  }
}
