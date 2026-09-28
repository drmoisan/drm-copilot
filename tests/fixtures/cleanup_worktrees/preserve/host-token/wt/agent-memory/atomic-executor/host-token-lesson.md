---
name: host-token-fixture-lesson
description: A checked-in source file whose bytes deliberately carry an absolute host path.
metadata:
  type: feedback
---

The absolute host path on the next line is the token the local scan must detect. The
manifest record for this file asserts host_token_scan.result of clean, so a pass that
trusted the advisory value instead of scanning would stage it.

    C:\Users\example\repos\demo\.claude\worktrees\agent-wt-0001
