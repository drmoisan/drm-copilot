---
name: preflight-zero-failure-and-json-append-traps
description: Two preflight checks the plan validator misses - "no removed line" diffs on JSON arrays appended after the final element, and zero-failure gates on tests/scripts-wide Pester runs on the Linux Codespace
metadata:
  type: feedback
---

Check two things in preflight that every validator rule passes:

1. A task that appends entries "after the last" element of a JSON array (for example `pack-manifests/core.json` `paths`) and asserts `git diff <base> -- <file>` shows no removed line cannot pass: the former last element gains a trailing comma. Fix in place (trivial) by moving the insertion point before the final element.
2. A task asserting zero Pester failures for a fresh single-process run over all of `tests/scripts` (or `Invoke-PoshQCParallelTest`) is unsatisfiable on the Linux Codespace (hundreds of pre-existing host-only failures; see [[linux-codespace-pester-host-failures]]). Sibling plans 1022/1023 asserted "no failure beyond the P0 baseline list" with a tests/scripts-wide baseline. A missing baseline makes this substantive, not trivial.

**Why:** Found in the issue 1034 re-preflight (2026-11-04); both passed the MCP and Python plan validators.
**How to apply:** grep each "no removed line" acceptance against the target file's tail; check every zero-failure gate's scan scope against the host failure set and confirm a matching baseline task exists.
