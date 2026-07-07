# Post-Move Line Count Verification (P1-T3)

**Timestamp:** 2026-07-06T23-44
**Command:** `wc -l extensions/drm-copilot/src/command-runtime.ts extensions/drm-copilot/src/terminal-writer.ts`
**EXIT_CODE:** 0
**Output Summary:**
```
570 extensions/drm-copilot/src/command-runtime.ts
100 extensions/drm-copilot/src/terminal-writer.ts
```

`terminal-writer.ts` is 100 lines, well under the 500-line limit.

`command-runtime.ts` is 570 lines after removing exactly the `TerminalWriter`
seam (interface, `SUBAGENT_TREE_TERMINAL_NAME`, `PseudoterminalTerminalWriter`,
`createSubagentTreeTerminalWriter`) enumerated by Fix 1 — this does **not**
satisfy the plan's P1-T3 acceptance criterion of `<= 500`.

**Root-cause discrepancy (discovered during execution, not assumed at
planning time):** `git show main:extensions/drm-copilot/src/command-runtime.ts | wc -l`
reports **531** lines — the file already exceeded the 500-line limit on
`main` (merge-base `4db27eb`) before this feature's diff, and before this
remediation cycle. This feature's diff added `getClaudeProjectsRoot` (39
lines, retained in `command-runtime.ts` per plan task P1-T4, which leaves
`getClaudeProjectsRoot`/`getWorkspaceRoot` imports from `./command-runtime`
unchanged) plus the now-extracted `TerminalWriter` seam (98 lines). Removing
only the `TerminalWriter` seam — the sole extraction the remediation-inputs
and remediation-plan authorize under the "Do Not Do" list ("no unrelated
refactors of `command-runtime.ts`") — returns the file to 531 + 39 = 570
lines, not to the pre-feature 531-line baseline itself (which was already
over the 500-line limit).

Bringing `command-runtime.ts` to `<= 500` would require extracting
additional pre-existing (not this-feature, not enumerated-fix) content out
of the file, which the remediation-inputs "Do Not Do" list explicitly
prohibits as scope-widening. This is recorded as an unresolved discrepancy
between the plan's literal P1-T3/P2-T6 acceptance criteria and the
authorized fix scope; see the executor's final completion report for the
escalation.
