# Coverage Delta — issue #554, re-issued after remediation cycle 1

Timestamp: 2026-08-28T00-36
Cycle Timestamp: 2026-08-27T22-47
Task: [P3-T9]
Command: `git diff -U0 1e991b86d78e4f979922b79268f19ca0e5ab19e3 -- <file>` for each of the four production files, intersected with the per-line `ci` attributes of `artifacts/pester/powershell-coverage.xml` as produced by [P3-T4]
EXIT_CODE: 0

**Supersedes** `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/coverage-delta.2026-08-27T22-36.md`,
which is **retained** for audit continuity. This artifact corrects that one's per-group counts and its
Group 2 cause statement, and reports the post-remediation numbers.

Merge base: `1e991b86d78e4f979922b79268f19ca0e5ab19e3` — the same base the superseded artifact used, so
the changed-line sets are directly comparable. Branch head at Phase 0: `34c04b4d7d1bcb0bac1273dbe5d8e82a43d0ee9a`.

---

## 1. Corrected per-group counts

The four-group characterization of the **63** uncovered added lines is restated with the corrected
measurable-line counts:

| Group | Corrected count | Previously stated |
| --- | --- | --- |
| Group 1 — the injected read seams | **16** | 18 |
| Group 2 — the non-injected arm and the Codex declared-path deny | **3** | 3 |
| Group 3 — the decision-D5 transport-constrained set | **39** | 40 |
| Group 4 — the debug-only catch | **4** | 2 |
| **Sum** | **62** | 63 |

**The total of 63 was correct and is unchanged.** The previously stated 18 / 3 / 40 / 2 did not
reproduce when recomputed from the report: Group 1 was overstated by two, Group 3 by one, and Group 4
was understated by two because it counted only one of the two surfaces' `Write-Debug` catches.

**The four corrected group counts sum to 62.** The remaining single line is
`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` **line 210**, the `return $false` of
the classifier's non-orchestrator branch, which the earlier four-group characterization did not
account for and which **finding R4 has now closed**. That reconciliation is what makes **62 plus 1
equal the correct total of 63**.

---

## 2. Group 1, named exception — the injected read seams (16 measurable lines)

The bodies of `Get-EpicCheckpointContent` and `Get-ParallelCheckpointContent` on **both** surfaces:

| Surface | Lines |
| --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 266-270 and 278-282 (measurable: 266, 267, 268, 270, 278, 279, 280, 282 — 8 lines) |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 292-296 and 304-308 (measurable: 292, 293, 294, 296, 304, 305, 306, 308 — 8 lines) |

**Reason accepted: real filesystem I/O.** The injection seam exists so the decision logic is testable
without touching the filesystem, as `.claude/rules/general-unit-test.md` requires ("core domain logic
must be testable without touching the network or filesystem", and "Creation and use of temporary
files in tests is strictly prohibited"). Covering these bodies would require reading the live
checkpoint, which would additionally make several allow assertions **pass vacuously**: the on-disk
`artifacts/orchestration/orchestrator-state.json` is genuinely ready during an orchestrated run, so an
allow case that fell through to it could not fail. Every gate case therefore binds its injection
parameter, and these bodies are unreachable from the suite by construction.

**Status after remediation: unchanged. All 16 lines remain uncovered and remain accepted.**

---

## 3. Group 2, named exception — two distinct causes, 3 measurable lines

The group membership and the count of **3** are unchanged. Only the stated **cause** is corrected.

**`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` line 408** is the non-injected
`else` arm of the mode-checkpoint selector:

```powershell
} elseif ($isEpic) { Get-EpicCheckpointContent } else { Get-ParallelCheckpointContent }
```

Same seam, same reason as group 1, because every Claude decision-level case binds its injection
parameter.

**`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` lines 421-422 are NOT that arm.**
They are the **`declared-checkpoint-path` deny return**. The Codex non-injected `else` arm is line
**430**, which is already counted inside the 426-443 residual of condition 5 below. Lines 421-422 are
uncovered for the **decision-D5 transport reason** — the same reason as group 3 — because no Codex
case can reach `Invoke-OrchestrationPreimplementationGateDecision`'s mode branches at all.

### What the superseded artifact got wrong, and where

`coverage-delta.2026-08-27T22-36.md` carries the incorrect cause in **two places**:

- **Line 102**, its Group 2 heading, which names the group
  `### Group 2 — the non-injected fallback branch (3 lines)`.
- **Line 110**, its cause sentence, which states that the lines are
  "the `else` arm of the same injection seam and is uncovered for the identical reason."

Its **line 104** is the line list (``.claude/...gate.ps1` line 408; `.codex/...gate.ps1` lines
421-422.`) and **is accurate**. This artifact corrects both the heading and the cause sentence and
leaves the line list standing.

**Status after remediation: unchanged. All 3 lines remain uncovered and remain accepted.**

---

## 4. Group 4, named exception — the debug-only catch (4 measurable lines)

`Get-OrchestrationModeProperty` at lines **94-95 of both `-modes.ps1` copies** —
`.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` lines 94 and 95, and
`.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` lines 94 and 95. Four lines,
not two: the superseded artifact counted only one surface.

**Reason accepted:** the catch fires only when `PSObject.Properties` itself throws, which no
JSON-derived object produces. There is no input a deterministic literal-fixture test could supply to
reach it.

**Status after remediation: unchanged. All 4 lines remain uncovered and remain accepted.**

---

## 5. The one shipping exception, tied to issue #555

The residual of former group 3, after R1 and R3 closed 24 of its 39 lines, is **exactly** the
epic/parallel decision branch at

> `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` **lines 426 through 443, 15
> measurable lines**

verified by direct probe at [P3-T8] to be the line set
`426, 427, 428, 429, 430, 432, 433, 434, 435, 436, 437, 439, 441, 442, 443`.

**Reason.** Driving this branch requires constructing a delegation payload for the Codex decision
function `Invoke-OrchestrationPreimplementationGateDecision`. **Decision D5 of `spec.md` prohibits
that**: `.codex/config.toml` registers no `PreToolUse` matcher admitting an `Agent` or `Task` tool
name, so an `Agent` delegation never reaches this hook on the Codex surface. D5 states the
prohibition literally — "fabricating an `Agent` envelope on the Codex side and asserting a decision
on it" would "assert behaviour on a code path the Codex runtime never exercises, and would produce a
green test that proves nothing about the shipped surface."

**Linkage: issue #555 owns the transport gap.** Issue #555 is explicitly out of scope for issue #554,
per `spec.md` §Scope & Non-Goals and §D5. The gap is recorded as a deliberate, tested fact by the
case `registers no PreToolUse matcher admitting an Agent or Task tool name` in
`tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`,
which reads `.codex/config.toml` and asserts the absence.

**Resulting file-level line coverage for that file: 83.33%** (135 covered of 162 measured), against
the 85% uniform threshold in `.claude/rules/quality-tiers.md`. **This is the one coverage exception
this feature ships with.** It is stated here as its own named exception with its line range, its
reason, and its #555 linkage, and it is deliberately **not absorbed into an aggregate**.

---

## 6. Post-remediation numbers

### Repository-wide line coverage

| Measurement | Value | Source |
| --- | --- | --- |
| Baseline repository-wide LINE coverage | **94.2212%** (7174 covered / 440 missed / 7614 total) | [P0-T6] |
| Post-remediation repository-wide LINE coverage | **94.6809%** (7209 covered / 405 missed / 7614 total) | [P3-T4] |
| Movement | **+0.4597 pp** (35 additional covered lines) | |

Both figures are read from the LINE counter at the report root of
`artifacts/pester/powershell-coverage.xml`, not from the Pester console headline, which reports
instruction coverage. Pester measures no branch coverage, so no branch figure exists.

### The four per-file figures

| File | Baseline | Post-remediation | Movement | vs 85% |
| --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 80.67% (121/150) | **88.00%** (132/150) | +7.33 pp | **PASS** |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 98.48% (130/132) | **98.48%** (130/132) | 0.00 pp | **PASS** |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 82.10% (133/162) | **83.33%** (135/162) | +1.23 pp | **Named #555 exception** |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 81.82% (108/132) | **98.48%** (130/132) | +16.66 pp | **PASS** |

Three of the four now pass the uniform threshold. The fourth is the named exception of condition 5.
The four `extensions/drm-copilot/resources/` mirrors are byte-identical copies of these four files
and are not separately instrumented; their coverage is the coverage of their sources, re-proved by
hash at [P3-T13].

### Changed-line coverage, computed against the merge base

| File | Measurable added | Uncovered added (before) | Uncovered added (after) | Changed-line coverage (after) |
| --- | --- | --- | --- | --- |
| `.claude/…/gate.ps1` | 42 | 10 | **9** | **78.57%** |
| `.claude/…/gate-modes.ps1` | 132 | 2 | **2** | **98.48%** |
| `.codex/…/gate.ps1` | 42 | 27 | **25** | **40.48%** |
| `.codex/…/gate-modes.ps1` | 132 | 24 | **2** | **98.48%** |
| **Aggregate** | **348** | **63** | **38** | **89.08%** |

Aggregate changed-line coverage rises from **81.90%** to **89.08%**; uncovered added lines fall from
**63** to **38**. The 38 partition exactly into the four named exception groups as they stand after
remediation: 16 (group 1) + 3 (group 2) + 15 (the #555 shipping exception) + 4 (group 4) = 38. **Zero
uncovered added lines are unattributed.**

### Post-remediation count of uncovered changed lines in each of the two modified hooks

| Modified hook | Uncovered changed lines | Composition |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | **9** | 8 group-1 read-seam lines (266, 267, 268, 270, 278, 279, 280, 282) + 1 group-2 line (408) |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | **25** | 8 group-1 read-seam lines (292, 293, 294, 296, 304, 305, 306, 308) + 2 group-2 lines (421, 422) + **15 lines of the named #555 exception** (426-443) |

Every one of those 34 lines is a member of a named exception recorded in conditions 2, 3, or 5 above.

### Finding-by-finding disposition

| Finding | Target | Before | After | Closed |
| --- | --- | --- | --- | --- |
| **R1** | `.codex/…-modes.ps1` line 197, `Find-OrchestrationDelegationTargetFolder` body, `Find-OrchestrationDelegationIssueNumber` body | 24 uncovered of 132 | **2 uncovered of 132** | **Yes** |
| **R2** | `.claude/…gate.ps1` lines 170-185 | 10 uncovered | **0 uncovered** | **Yes** |
| **R3** | `.codex/…gate.ps1` lines 352-353 | 2 uncovered | **0 uncovered** (`ci` = 1 and 2) | **Yes** |
| **R4** | `.claude/…gate.ps1` line 210 | uncovered | **covered** (`ci` = 1) | **Yes** |

Output Summary: All four Blocking findings are closed. The corrected per-group counts are
**16 / 3 / 39 / 4**, summing to 62, reconciling with `.claude/…gate.ps1` line 210 to the correct total
of **63**. Group 2's cause is corrected: the Codex members are the declared-path deny return, not the
non-injected `else` arm, which is line 430 inside the #555 residual. Repository-wide LINE coverage
rises from **94.2212%** to **94.6809%**. Per-file coverage moves to **88.00 / 98.48 / 83.33 / 98.48**.
Uncovered changed lines fall from 63 to **38**, all attributed to named exceptions. The one shipping
exception is `.codex/…gate.ps1` **lines 426-443, 15 measurable lines**, tied to **issue #555**.
