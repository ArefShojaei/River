# Changelog

All notable changes to this project will be documented in this file.

## 1.1.0 - 2026-09-25

### Added
- Improved SocketServer and SocketClient with better event handling
- Support for local events: `connect`, `disconnect`, `connect_error`
- Better broadcast and broadcastExcept methods
- More robust TCP message framing with LineSplitter

### Fixed
- Fixed event handling consistency between client and server
- Improved disconnect cleanup

### Changed
- Refactored socket event system to be closer to Socket.IO style

## 1.0.0 - 2026-09-16

- Initial release