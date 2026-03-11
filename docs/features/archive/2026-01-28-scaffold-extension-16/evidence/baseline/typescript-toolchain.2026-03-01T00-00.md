# Baseline TypeScript Toolchain Evidence

## Command 1
Timestamp: 2026-03-02T00:22:22Z
Command: npm --prefix extensions/scaffold-extension run format
EXIT_CODE: 1
Output Summary: Failed with ENOENT because `extensions/scaffold-extension/package.json` was missing.

## Command 2
Timestamp: 2026-03-02T00:22:54Z
Command: npm --prefix extensions/scaffold-extension run lint
EXIT_CODE: 1
Output Summary: Failed with ENOENT because `extensions/scaffold-extension/package.json` was missing.

## Command 3
Timestamp: 2026-03-02T00:23:10Z
Command: npm --prefix extensions/scaffold-extension run typecheck
EXIT_CODE: 1
Output Summary: Failed with ENOENT because `extensions/scaffold-extension/package.json` was missing.

## Command 4
Timestamp: 2026-03-02T00:23:20Z
Command: npm --prefix extensions/scaffold-extension run test
EXIT_CODE: 1
Output Summary: Failed with ENOENT because `extensions/scaffold-extension/package.json` was missing.
