# Coverage Delta — issue #554, re-issued at remediation cycle 2

Timestamp: 2026-08-28T02-09
Task: [P3-T7]
Command: `python -c "<ElementTree read of artifacts/pester/powershell-coverage.xml for per-file LINE counters and uncovered line numbers, intersected with the added-line set of git diff -U0 1e991b86d78e4f979922b79268f19ca0e5ab19e3 -- <hook path> for each of the two modified hooks>"`
EXIT_CODE: 0

**Supersedes** `evidence/qa-gates/coverage-delta.2026-08-27T22-47.md`, which is **retained
unaltered** and receives **no correction notice**. That artifact's statement that "zero uncovered
added lines are unattributed" is true as worded. Its defect was the **omission** of the two uncovered
*pre-existing* lines, which subsection 1 below supplies. Retention was verified: a
`git diff --name-only HEAD` against that path produces empty output.

## Comparison anchor

Every changed-line computation in this artifact is taken against the **fixed cycle-1 comparison
anchor**:

```
1e991b86d78e4f979922b79268f19ca0e5ab19e3
```

pinned and ancestry-verified at [P0-T3] (`git merge-base --is-ancestor` returned 0). It is **never**
taken against the current `git merge-base HEAD origin/main` value
`c62af7a71eb2dbc8c8086c9cbf1c30c22551590a`, which the merge of `origin/main` into this branch moved.
Substituting that value would silently change the two uncovered-changed-line counts reported in
subsection 6.

---

## 1. Pre-existing-line disclosure — new in this issue

The superseded artifact reconciled only the **changed** lines of each modified hook. This subsection
reconciles the **full missed set** of `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`.

**The two lines.** Codex **line 197** (the non-`orchestrator` subagent-type `return $false`) and
Codex **line 206** (the all-conjuncts-hold `return $true`), both inside
`Test-PreparationModeDelegation`.

**Both were COVERED at the merge base `1e991b86`.** Merge-base line 213, inside
`Test-ImplementationDelegation`, called `Test-PreparationModeDelegation`. Merge-base
`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` reached the non-`orchestrator`
return through that call site at its lines 367 (`subagent_type = 'atomic-executor'`) and 373
(`'task-researcher'`), and reached the all-conjuncts return at its line 242 with an `orchestrator`
payload carrying both preparation markers.

**This branch removed that call site**, orphaning `Test-PreparationModeDelegation` on **both**
surfaces. The two lines lost coverage as a direct consequence. The two surviving direct callers
supply a null payload and an `orchestrator` payload carrying one marker, so they reach only the null
branch and the marker-loop return.

**The loss is remediation-cycle-2 Blocking finding B5.**

**B5 is CLOSED** by the two cases added at [P1-T2] and [P1-T3] to
`tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`.
The [P3-T6] per-line probe reads `ci="1"` for both lines: both are covered.

### The partition of the cycle-1-exit missed set

The file's full missed set at cycle-1 exit was **27**. It partitions exactly as:

| Partition | Count | Members |
| --- | --- | --- |
| Changed lines (added or modified against `1e991b86`) | **25** | `292, 293, 294, 296, 304, 305, 306, 308, 421, 422, 426, 427, 428, 429, 430, 432, 433, 434, 435, 436, 437, 439, 441, 442, 443` |
| Pre-existing lines — this pair | **2** | `197, 206` |
| **Total** | **27** | |

**After B5 the missed set is exactly the 25 changed lines.** The pre-existing partition is empty.
Confirmed by [P3-T6]: `uncovered pre-existing: 0`.

---

## 2. Group 1, named exception — the injected read seams (16 measurable lines)

The bodies of `Get-EpicCheckpointContent` and `Get-ParallelCheckpointContent` on both surfaces:

| Surface | Function | Lines |
| --- | --- | --- |
| `.claude/…gate.ps1` | `Get-EpicCheckpointContent` | 266-270 |
| `.claude/…gate.ps1` | `Get-ParallelCheckpointContent` | 278-282 |
| `.codex/…gate.ps1` | `Get-EpicCheckpointContent` | 292-296 |
| `.codex/…gate.ps1` | `Get-ParallelCheckpointContent` | 304-308 |

**Reason:** real filesystem I/O. The injection seam exists precisely so the decision logic is
testable without touching the filesystem, and covering these bodies would additionally make several
allow assertions pass **vacuously** against the live checkpoint.

**Status: unchanged. All 16 remain uncovered and accepted.**

---

## 3. Group 2, named exception — two distinct causes (3 measurable lines)

| Location | Lines | Cause |
| --- | --- | --- |
| `.claude/…gate.ps1` | 408 | the non-injected `else` arm of the mode-checkpoint selector — same seam and same reason as group 1 |
| `.codex/…gate.ps1` | 421-422 | the `declared-checkpoint-path` deny return — uncovered for the decision-D5 transport reason |

**Status: unchanged. All 3 remain uncovered and accepted.**

---

## 4. Group 4, named exception — the debug-only catch (4 measurable lines)

`Get-OrchestrationModeProperty` at lines **94-95 of both `-modes.ps1` copies**, that is
`.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` lines 94-95 and
`.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` lines 94-95.

**Reason:** the catch fires only when `PSObject.Properties` itself throws, which no JSON-derived
object produces.

**Status: unchanged.**

---

## 5. The one shipping exception, tied to issue #555

**Name:** the Codex epic/parallel decision branch.

**Location and line range:** `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`,
**lines 426 through 443**, **15 measurable lines**, enumerated:

```
426, 427, 428, 429, 430, 432, 433, 434, 435, 436, 437, 439, 441, 442, 443
```

**Reason:** driving the branch requires constructing a delegation payload for the Codex decision
function, which **decision D5 prohibits** because `.codex/config.toml` registers no `PreToolUse`
matcher admitting an `Agent` or `Task` tool name. No `Agent` envelope is fabricated on the Codex
side.

**Linkage: issue #555** owns the transport gap, and it is **explicitly out of scope for issue
#554**.

### The exception persists after B5 closes

The file ships at **84.57 percent**, which is **still below the 85 percent uniform threshold** of
`.claude/rules/quality-tiers.md`. The shortfall is **wholly owned by this fifteen-line exception**:
of the 25 residual missed lines, 15 are these, and covering them alone would take the file to
`152/162 = 93.83 percent`, above the threshold.

**The exception therefore PERSISTS after B5 closes.** B5 raised the file from 83.33 percent to 84.57
percent and did not, and could not, remove this shortfall, because B5 concerns two pre-existing lines
elsewhere in the file.

**It is stated here as its own named exception and is NOT absorbed into an aggregate** with groups 1,
2, or 4.

**It MUST be disclosed in the pull-request description.**

---

## 6. Post-B5 numbers

### Repository-wide LINE coverage

| Point | Value | Source |
| --- | --- | --- |
| Cycle-1 exit (this cycle's baseline) | **94.68 percent** (7209 / 7614) | [P0-T6] |
| Post-B5 | **94.71 percent** (7211 / 7614) | [P3-T4] |
| Movement | **+0.03 percentage points**, +2 covered lines | |

Both figures are read from the `LINE` counter at the report root of
`artifacts/pester/powershell-coverage.xml`, not from the Pester console instruction-coverage
headline. Pester measures no branch coverage, so no branch figure is reported.

### Per-file figures

| File | Cycle-1 exit | Post-B5 | Movement |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 88.00 (132/150) | **88.00** (132/150) | unchanged |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 83.33 (135/162) | **84.57** (137/162) | **+1.24 pp** |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 98.48 (130/132) | **98.48** (130/132) | unchanged |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 98.48 (130/132) | **98.48** (130/132) | unchanged |

`.codex/…gate.ps1` moves from **83.33** to **84.57**; the other three are unchanged at **88.00**,
**98.48**, and **98.48**.

### Uncovered changed lines in the two modified hooks

Computed against the **fixed cycle-1 comparison anchor**
`1e991b86d78e4f979922b79268f19ca0e5ab19e3`, by intersecting each file's uncovered-line set with the
added-line set of `git diff -U0 1e991b86d78e4f979922b79268f19ca0e5ab19e3 -- <path>`:

| File | Changed lines vs anchor | Uncovered changed lines | Members |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 120 | **9** | `266, 267, 268, 270, 278, 279, 280, 282, 408` |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 125 | **25** | `292, 293, 294, 296, 304, 305, 306, 308, 421, 422, 426, 427, 428, 429, 430, 432, 433, 434, 435, 436, 437, 439, 441, 442, 443` |

Both counts are **unchanged at 9 and 25**, because B5 concerns **pre-existing lines only**. Every one
of the 9 is a group-1 or group-2 member; every one of the 25 is a group-1, group-2, or issue-#555
member. **Zero uncovered changed lines are unattributed**, which restates the superseded artifact's
still-true claim.

The uncovered **pre-existing** count for `.codex/…gate.ps1` is now **0**, down from 2. The uncovered
pre-existing count for `.claude/…gate.ps1` is 9 (`125, 252, 253, 255, 425, 485, 486, 487, 490`),
unchanged by this cycle and outside B5's scope.

---

Output Summary: Codex gate hook rises from **83.33** to **84.57 percent** as B5 closes; lines 197 and
206 are covered, and the file's missed set is exactly the 25 changed lines. Repository-wide LINE
coverage rises from **94.68** to **94.71 percent**. Uncovered changed lines are unchanged at **9 and
25** against the pinned anchor `1e991b86`. The **issue #555** exception at lines **426-443**, 15
measurable lines, **persists**, owns the entire sub-threshold shortfall, is stated as its own named
exception, and **must be disclosed in the pull-request description**. EXIT_CODE 0.
