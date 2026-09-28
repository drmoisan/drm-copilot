# Scope: Call Sites ([P9-T2])

Timestamp: 2026-09-26T22-28

Command: `git diff --numstat b67453837646fd2dd4f5ac692f76e6f7703fe798 -- extensions/drm-copilot/src/lib/pr-context/collector-core.ts scripts/dev_tools/pr_context/collector.py`

EXIT_CODE: 0

Output Summary: empty output (no row for either path). Both call-site states were `PRESENT` (`TS_CALLSITE: PRESENT`, `PY_CALLSITE: PRESENT`), so no row is the expected result; the #622-owned regions of both collectors are untouched.
