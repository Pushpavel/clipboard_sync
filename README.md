# clipboard_sync

A flutter app that syncs clipboards between devices in the same LAN using Interprocess
 communication (Sockets).

## What it does ? 
group of devices on same network and with clipboard_sync running, keep their clipboards in sync
. whenever a device copies a text, it will be shared with other devices.

## How it works ?
#### 🌍 Establishing connection
- each device opens a serverSocket.
- devices with no connections advertise its deviceId via UDP Broadcast.
- devices with lexicographically higher deviceId respond with its configuration.
- devices connect to the first received configuration via TCP Sockets.

#### 🔌 Syncing clipboard
- polls the system clipboard to detect changes.
- clipboard changes are shared via the established TCP Sockets.
- incoming clipboard changes are also forwarded to other devices. 
- each clipboard change message contains a timestamp, through which older messages are ignored
 when received.

## Getting Started in Flutter

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
