# Final QA — PowerShell Pester Tests and Coverage ([P7-T7])

Timestamp: 2026-08-09T03-43

Task: [P7-T7] Run PowerShell Pester tests in coverage mode and record numeric post-change coverage.

Feature: `docs/features/active/2026-08-07-parallel-mutation-protocol-442` (issue #442)
Branch: `feature/parallel-mutation-protocol-442`
Reconciliation base: `c939b5b8`

Command: MCP tool `mcp__drm-copilot__run_poshqc_test` with
`workspace_root: C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3b16f891ab2f782c`
(no `scan_folders` argument, so the scan set resolves from `config/poshqc-scan.json` `test.scanFolders`)

EXIT_CODE: 1

The non-zero exit code is caused entirely by ONE pre-existing, out-of-scope failure that also fails
identically at baseline (P0-T6) before any F6 edit. It is characterized in full below. Pester 5.6.1;
wall time 98.368 s.

## Raw MCP Output

```json
{
  "ok": false,
  "tool": "run_poshqc_test",
  "workspace_root": "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3b16f891ab2f782c",
  "summary": "Command exited with code 1."
}
```

The MCP wrapper prints no counts, so the numeric values below were read from the two result files the
run wrote: `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`. Both
are the existing PoshQC tool output locations, not evidence paths.

## Test Result Counts (numeric, no placeholders)

Root JUnit element:

```xml
<testsuites name="Pester" tests="2053" errors="0" failures="1" disabled="9" time="98.368">
```

| Metric | Post-change value | Baseline (P0-T6) | Delta |
| --- | --- | --- | --- |
| Total test cases | 2053 | 2031 | +22 |
| Passed | **2043** | 2021 | **+22** |
| Failed | **1** | 1 | 0 |
| Errors | 0 | 0 | 0 |
| Skipped / disabled | 9 | 9 | 0 |
| Wall time | 98.368 s | 113.834 s | -15.5 s |

Tally verification: `status="Passed"` = 2043, `status="Failed"` = 1, `status="Skipped"` = 9;
2043 + 1 + 9 = 2053, reconciling exactly with the root element.

The +22 delta is exactly the new suite `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1`:

```
<testsuite name="...\tests\scripts\claude-hooks\enforce-parallel-abandon-gate.Tests.ps1" tests="22" ... failures="0" ...>
```

22 cases, **0 failures**, all 22 `status="Passed"`. The baseline passing count of 2021 is held exactly
(2043 - 22 = 2021), so no pre-existing PowerShell test was broken by this feature.

## The Single Failure — PRE-EXISTING and OUT OF SCOPE

- Test file: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`
- Failing test: `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
- Assertion site: `enforce-pr-author-skill.Tests.ps1:142` — `$decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'`
- Failure message: `Expected strings to be the same, but they were different. Expected length: 5, Actual length: 4, Strings differ at index 0. Expected: 'allow' But was: 'deny'`

Cause and scope: the test reads the real, gitignored `artifacts/orchestration/orchestrator-state.json`
instead of a mocked read seam. An orchestrated run is live and that checkpoint has been written, so the
hook under test correctly returns `deny` where the test's fixture-free expectation assumes `allow`. The
defect is the test's missing seam, not the hook, and not anything F6 touches.

Classification: **PRE-EXISTING and OUT OF SCOPE.** Byte-identical failure identity, assertion site,
and message as the baseline (P0-T6) capture. Per the execution directive this test file is NOT edited
to force a green gate, is not fixed by this feature, and does not block completion. F6 creates no file
this test loads and modifies no `enforce-*` hook it exercises.

The second file the directive originally anticipated,
`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`, passed at baseline and passes here.

Failure-budget verdict: **no other Pester failure occurred.** Failing count is 1, identical to
baseline, so nothing is attributable to this feature.

## Coverage — Numeric Post-Change Values (no placeholders)

Report-level counters from `artifacts/pester/powershell-coverage.xml`:

```xml
  <counter type="INSTRUCTION" missed="278" covered="4316" />
  <counter type="LINE" missed="189" covered="3148" />
  <counter type="METHOD" missed="26" covered="240" />
  <counter type="CLASS" missed="2" covered="39" />
```

| Coverage metric | Post-change value | Baseline (P0-T6) | Threshold | Verdict |
| --- | --- | --- | --- | --- |
| **Line coverage** | **94.34%** (3148 covered / 3337 lines; 189 missed) | 94.34% | >= 85% | PASS, margin +9.34 pp, no regression |
| Instruction coverage | 93.95% (4316 / 4594; 278 missed) | 93.95% | not a policy threshold | unchanged |
| Method coverage | 90.23% (240 / 266; 26 missed) | 90.23% | not a policy threshold | unchanged |
| Class coverage | 95.12% (39 / 41; 2 missed) | 95.12% | not a policy threshold | unchanged |

Line-coverage arithmetic: `3148 / (3148 + 189) = 3148 / 3337 = 94.34%`.

Pester's JaCoCo output carries no `BRANCH` counter, so no PowerShell branch-coverage figure is produced
by this toolchain. The policy branch threshold is measurable for Python only; for PowerShell the line
figure above is the recorded coverage headline, consistent with the plan's P0-T6/P7-T7 wording.

## Measurement Gap — Aggregate Report Does Not Include the New Hook (recorded, not inferred)

The aggregate counters are byte-identical to baseline, and
`.claude/hooks/enforce-parallel-abandon-gate.ps1` is ABSENT from
`artifacts/pester/powershell-coverage.xml`, even though its 22 Pester cases ran and passed. The reason
is a tool-resolution property, not a defect and not zero coverage:

`mcp__drm-copilot__run_poshqc_test` resolves its Pester run settings — including the
`CodeCoverage.Path` allowlist — from the **installed extension's bundled resources**, not from the
workspace passed as `workspace_root` (the MCP tool descriptions state they run "using bundled extension
resources"). The P5-phase edit that appended the hook to the allowlist in BOTH in-repo copies
(`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its mirror under
`extensions/drm-copilot/resources/...`) is therefore correct and required by
`.claude/rules/general-unit-test.md` (no production file may be excluded from coverage), but it does
not change what the current session's MCP run measures. A future extension rebuild picks it up.

Rather than record a placeholder or infer zero, the hook's coverage was measured directly.

## Supplementary Targeted Measurement — New Hook Coverage (numeric)

Command: `pwsh -NoProfile -File <scratchpad>/measure-abandon-gate-coverage.ps1`, which invokes
`Invoke-Pester` (Pester 5.6.1) with `Run.Path` = the new test file and `CodeCoverage.Path` = the new
hook, writing its coverage XML to the session scratchpad so no artifact is added to the branch.

EXIT_CODE: 0

```
PESTER_VERSION=5.6.1
TOTAL=22 PASSED=22 FAILED=0 SKIPPED=0
ANALYZED=57 EXECUTED=48 MISSED=9
COVERAGE_PERCENT=84.2105263157895
FILES_ANALYZED=1
MISSED_LINES=56,251,251,253,254,257,257,257,259
```

JaCoCo counters from the targeted run's coverage XML:

```xml
  <counter type="INSTRUCTION" missed="9" covered="48" />
  <counter type="LINE" missed="6" covered="40" />
  <counter type="METHOD" missed="1" covered="8" />
  <counter type="CLASS" missed="0" covered="1" />
```

| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | Value | Threshold | Verdict |
| --- | --- | --- | --- |
| **Line coverage** | **86.96%** (40 covered / 46 lines; 6 missed) | >= 85% | PASS, margin +1.96 pp |
| Instruction coverage | 84.21% (48 / 57; 9 missed) | not a policy threshold | recorded |
| Method coverage | 88.89% (8 / 9; 1 missed) | not a policy threshold | recorded |
| Tests exercising the file | 22 passed / 0 failed | n/a | PASS |
| File length | 259 lines | <= 500 | PASS (see P7-T9) |

The 6 uncovered lines are the two deliberately host-bound regions, both of which are the thinnest
possible wiring per `.claude/rules/general-unit-test.md`:
- line 56 — the body of the injectable read seam `return $env:CLAUDE_TOOL_INPUT`, which tests replace
  with a mock so no live environment variable is read;
- lines 251-259 — the entry-point wiring after the dot-source guard
  `if ($MyInvocation.InvocationName -eq '.') { return }`, which by design does not execute when the
  test dot-sources the file.

No part of the decision logic is uncovered.

## Harness Note — StrictMode Artifact in a Discarded Diagnostic Run (recorded for completeness)

A first version of the supplementary measurement script set `Set-StrictMode -Version Latest` in the
harness scope. Under that setting one of the 22 cases
(`commands outside scope.allows when the JSON payload has no command field`) failed with
`The property 'command' cannot be found on this object` at hook line 231
(`[string]$toolInput.command`). This is an artifact of the harness, not of the gate:

- The repository's Pester runner does not enable `Set-StrictMode -Version Latest`, and
  `.claude/rules/powershell.md` imposes no StrictMode requirement.
- The pre-existing hook the plan required this one to be patterned on
  (`.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, P5-T1: "patterned near-verbatim") performs
  the same unguarded read, `$commandText = $toolInput.command` at its line 194, and likewise sets no
  StrictMode. The new hook matches the established repository pattern exactly.
- Claude Code invokes the hook as `pwsh -NoProfile -File ...`, where StrictMode is off by default, so
  the tested behavior matches the runtime behavior.

The StrictMode harness line was removed and the measurement rerun; all 22 cases pass. No production or
test file was changed in response, since changing the pattern is not described by any task in this plan
and the authoritative gate reports zero failures for this suite.

Output Summary: `mcp__drm-copilot__run_poshqc_test` exited **1** with **2043 passed, 1 failed, 0
errors, 9 skipped of 2053 total** cases in 98.368 s (Pester 5.6.1). Post-change **line coverage
94.34%** (3148 covered / 3337 lines, 189 missed), identical to the 94.34% baseline, so there is **no
PowerShell coverage regression**; the >= 85% threshold is met with a +9.34 pp margin. Pester emits no
BRANCH counter, so no PowerShell branch figure exists. The single failure is the **PRE-EXISTING and
OUT OF SCOPE** `enforce-pr-author-skill.Tests.ps1` "allows gh pr create --body-file" case, which reads
the real gitignored `artifacts/orchestration/orchestrator-state.json` instead of a mocked seam while an
orchestrated run is live; it fails identically at baseline, is not edited, and does not block
completion. The new suite `enforce-parallel-abandon-gate.Tests.ps1` contributes **22 passed, 0
failed**, and the baseline passing count of 2021 is held exactly. Coverage of the new hook
`.claude/hooks/enforce-parallel-abandon-gate.ps1` is **86.96% line (40/46)** and 84.21% instruction
(48/57), measured by a supplementary targeted `Invoke-Pester` run because the MCP tool resolves its
`CodeCoverage.Path` allowlist from the installed extension bundle rather than the workspace; the
in-repo allowlist edit is present in both copies and takes effect on the next extension rebuild. The 6
uncovered hook lines are the mocked read seam (line 56) and the post-dot-source-guard entry point
(lines 251-259) only.

Verdict: PASS for this feature — zero F6-attributable failures, numeric aggregate and per-file coverage
recorded, no coverage regression. The one failing test is pre-existing and explicitly out of scope.

## Confirming Re-Run After Documentation-Only Edits (Phase 7 loop rule)

After this gate ran, the only files that changed were Markdown documentation inside the feature folder.
The Phase 7 loop rule requires a clean pass after any file change, so the PowerShell test gate was rerun.

Timestamp: 2026-08-09T03-59

Command: MCP tool `mcp__drm-copilot__run_poshqc_test` (same `workspace_root`, no `scan_folders`)

EXIT_CODE: 1 — the same single pre-existing failure, not a new one.

```xml
<testsuites name="Pester" tests="2053" errors="0" failures="1" disabled="9" time="96.349">
```

| Metric | Confirming run | Primary run recorded above | Match |
| --- | --- | --- | --- |
| Total | 2053 | 2053 | yes |
| Passed | 2043 | 2043 | yes |
| Failed | 1 | 1 | yes |
| Skipped | 9 | 9 | yes |
| Failing test identity | `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists` | same | yes |
| LINE counter | `missed="189" covered="3148"` (94.34%) | same | yes |
| INSTRUCTION counter | `missed="278" covered="4316"` | same | yes |

Reproduced byte-identically, so the figures in this artifact remain accurate. Formatting and analysis were
already clean in this phase (P7-T5, P7-T6) and nothing they scan changed, so no loop restart was required.
