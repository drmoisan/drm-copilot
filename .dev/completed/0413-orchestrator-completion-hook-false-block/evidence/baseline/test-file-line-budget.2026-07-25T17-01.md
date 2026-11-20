# Test-File Line Budget (issue #413)

Timestamp: 2026-07-25T17-01

File under budget: `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`

Hard cap: **500 lines** (`.claude/rules/general-code-change.md`, "File Size Limit" — applies to
test code as well as production code).

Command: `wc -l tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`

EXIT_CODE: 0

## [P1-T4] Pre-edit measurement and binding decision

- Measured pre-edit line count: **449** (matches the expected value recorded in the plan).
- Headroom to the cap: 51 lines.

Projected post-edit count, from the plan's `## Test-File Line Budget Decision` block:

| Change | Net lines |
|---|---|
| [P2-T1] replace the defect-asserting `It` (approx. lines 266-276) in place | approx. 0 |
| [P2-T2] add the end-to-end ALLOW `It` block | approx. +20 |
| [P2-T3] add the exit-2 fail-closed unit `It` block | approx. +8 |
| **Projected total** | **approx. 477** |

Projected post-edit count: **approximately 477**, which is 23 lines under the cap.

**Decision (binding, restated from the approved plan):** all test changes go in the existing
file `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`. No sibling test file
is created.

**Contingency (fires only if the actual post-edit count would exceed 500):** move the new
issue-413 regression tests to a sibling file
`tests/scripts/claude-hooks/validate-orchestrator-output.routing-contract.Tests.ps1` in the
same directory (satisfying the `tests/` mirror-layout rule in
`.claude/rules/general-unit-test.md`), then re-run [P4-T1].

Output Summary: pre-edit 449 lines; projected post-edit approximately 477; cap 500;
decision is to keep all changes in the existing file. [P4-T5] records the actual post-edit
count below.

## [P4-T5] Post-edit measurement

Timestamp: 2026-07-25T17-17

Command: `wc -l tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`

EXIT_CODE: 0

Output Summary:

```text
486 tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1
```

- Measured post-edit line count: **486**
- Cap: 500. **486 <= 500 — PASS.** Headroom remaining: 14 lines.
- Pre-edit was 449, so the net change is **+37 lines** (projected +28; the difference comes
  from the multi-line `[pscustomobject]` stub formatting used in the two success-line tests
  and their explanatory Arrange comments).
- The **contingency did not fire**. No sibling file
  `tests/scripts/claude-hooks/validate-orchestrator-output.routing-contract.Tests.ps1` was
  created; all test changes remain in the existing file as the binding decision required.

For reference, the changed production hook `.claude/hooks/validate-orchestrator-output.ps1`
measures **350** lines post-edit, also within the 500-line cap.
