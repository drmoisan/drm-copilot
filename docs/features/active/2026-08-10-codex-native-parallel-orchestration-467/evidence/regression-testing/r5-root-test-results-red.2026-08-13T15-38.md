# R5 Root Test Results Expected-Red Evidence

Timestamp: 2026-08-13T17-52-04:00
Command: `git diff --exit-code fe0413d4aca1e76b2d02d05701fba79a887d5405 HEAD -- testResults.xml`
EXIT_CODE: 1
Output Summary: The root `testResults.xml` has an unintended feature delta. The base contains a 124-test report from the primary checkout, while HEAD contains a one-test focused report from this feature worktree with 18 not-run cases. The counts, runtime versions, dates, and working-directory metadata differ, so the root file is environment-specific local output rather than authoritative final feature evidence.

## Report comparison

| Field | Base `fe0413d4...` | HEAD |
|---|---|---|
| Total | 124 | 1 |
| Errors | 0 | 0 |
| Failures | 0 | 0 |
| Not run | 0 | 18 |
| Inconclusive | 0 | 0 |
| Ignored | 0 | 0 |
| Skipped | 0 | 0 |
| Invalid | 0 | 0 |
| Date/time | 2026-05-24 14:50:23 | 2026-08-12 05:39:40 |
| CLR version | 10.0.5 | 10.0.9 |
| Working directory | `C:\Users\DanMoisan\repos\drm-copilot` | `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-10T19-25` |
| Primary suite | broad repository Pester suite | `tests/scripts/codex-hooks/parallel-provenance.Tests.ps1` |

Shared metadata remained Windows 11 build 10.0.26200, machine `MEGALODON4`, user `DanMoisan`, and NUnit schema version 2.5.8.0.

- Current file size: 3,780 bytes.
- Current SHA-256: `BE86A1B70B9694BA7A916E286AC4C9918734166AA1B492485B270819120E5D08`.
- The command's diff replaces 365 base lines with 33 HEAD lines and reports no newline at end of the HEAD file.

Acceptance result: PASS for `[expect-fail]`; the unintended feature delta and its environment-specific metadata are demonstrated.
