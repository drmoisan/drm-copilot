# Allowlist Removed (P8-T3, AC-10)

Timestamp: 2026-10-09T04-40
Command: git grep -n -E "RECOGNIZED_PATH_EXTENSIONS|RecognizedPathExtension" -- scripts .claude extensions tests
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: empty output; git grep exited 1 (no match). The six P0-T22 occurrences are gone from the Python extraction module, the PowerShell extraction module, and its bundled mirror.
