# Changelog

All notable changes to this project will be documented in this file.

## 1.1.1 - 2026-10-13

### Fixed
- Fixed Request body reading: `text()` and `json()` are now cached and can be called multiple times safely
- Fixed CLI `--help` / `-h` not working
- Unified default host values across HTTP and Socket servers

### Changed
- Default host for HTTP server changed from `localhost` to `0.0.0.0`
- Default host for Socket server set to `0.0.0.0`
- Socket client remains `127.0.0.1`
- README updated: corrected WebSocket claims to TCP Socket

### Added
- `Http.close()` method for graceful server shutdown
- Better error handling in `Request.json()` (throws `FormatException` on invalid JSON)

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