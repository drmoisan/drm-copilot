# Phase 0 — Per-File Uncovered-Line Inventory (remediation cycle 1)

Timestamp: 2026-08-27T23-56
Cycle Timestamp: 2026-08-27T22-47
Task: [P0-T7]
Command: `python -c "<XML read>"` over `artifacts/pester/powershell-coverage.xml` produced by [P0-T6], summing per-`line` `ci` attributes per `sourcefile` under the `.claude/hooks` and `.codex/hooks` packages
EXIT_CODE: 0

A line is counted covered when its `ci` attribute is greater than zero and missed otherwise, which is
the JaCoCo line-counter convention the report itself uses at the file level.

## Per-file inventory — the four production files of this change

### 1. `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`

| Metric | Value |
| --- | --- |
| Covered lines | 121 |
| Missed lines | 29 |
| Measured lines | 150 |
| File line coverage | **80.67%** |

Uncovered line numbers:

```text
125, 170, 171, 174, 175, 176, 179, 180, 181, 182, 185, 210, 252, 253, 255, 266, 267, 268, 270,
278, 279, 280, 282, 408, 425, 485, 486, 487, 490
```

### 2. `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`

| Metric | Value |
| --- | --- |
| Covered lines | 130 |
| Missed lines | 2 |
| Measured lines | 132 |
| File line coverage | **98.48%** |

Uncovered line numbers:

```text
94, 95
```

### 3. `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`

| Metric | Value |
| --- | --- |
| Covered lines | 133 |
| Missed lines | 29 |
| Measured lines | 162 |
| File line coverage | **82.10%** |

Uncovered line numbers:

```text
197, 206, 292, 293, 294, 296, 304, 305, 306, 308, 352, 353, 421, 422, 426, 427, 428, 429, 430,
432, 433, 434, 435, 436, 437, 439, 441, 442, 443
```

### 4. `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`

| Metric | Value |
| --- | --- |
| Covered lines | 108 |
| Missed lines | 24 |
| Measured lines | 132 |
| File line coverage | **81.82%** |

Uncovered line numbers:

```text
94, 95, 197, 228, 230, 231, 232, 234, 235, 236, 237, 242, 243, 244, 246, 248, 249, 250, 268,
270, 271, 272, 273, 274
```

All four per-file figures reproduce the independently recomputed table in
`policy-audit.2026-08-27T22-47.md` §"Per-file, changed production files" exactly (80.67 / 98.48 /
82.10 / 81.82).

## Remediation-target status — are the target lines currently uncovered?

| Finding | Target | Present in the missed set? |
| --- | --- | --- |
| **R1** | `.codex/…-modes.ps1` line **197** (unknown-mode `return ''`) | **YES — uncovered** |
| **R1** | `.codex/…-modes.ps1` body of `Find-OrchestrationDelegationTargetFolder`, lines 228, 230-232, 234-237, 242-244, 246, 248-250 (17 lines) | **YES — entire body uncovered** |
| **R1** | `.codex/…-modes.ps1` body of `Find-OrchestrationDelegationIssueNumber`, lines 268, 270-274 (6 lines) | **YES — entire body uncovered** |
| **R2** | `.claude/…gate.ps1` lines **170 through 185** — the report emits line elements for 170, 171, 174, 175, 176, 179, 180, 181, 182, 185 (10 measurable lines) | **YES — all ten uncovered** |
| **R3** | `.codex/…gate.ps1` lines **352 and 353** | **YES — both uncovered** |
| **R4** | `.claude/…gate.ps1` line **210** | **YES — uncovered** |

Every one of the four remediation targets is confirmed uncovered at baseline, so each of R1 through
R4 addresses a real gap and the post-remediation verification tasks [P3-T6] through [P3-T8] can
observe a genuine transition.

## Cross-check of the corrected four-group characterization

The plan's [P3-T9] condition 1 requires the corrected measurable-line counts **16 / 3 / 39 / 4**.
Recomputed from the missed sets above:

| Group | Membership | Count |
| --- | --- | --- |
| 1 — injected read seams | `.claude` 266, 267, 268, 270, 278, 279, 280, 282 (8) + `.codex` 292, 293, 294, 296, 304, 305, 306, 308 (8) | **16** |
| 2 — non-injected `else` arm and the Codex declared-path deny return | `.claude` 408 (1) + `.codex` 421, 422 (2) | **3** |
| 3 — decision-D5 transport-constrained | `.codex/…gate.ps1` 352, 353 (2) + `.codex/…gate.ps1` 426-443 (15) + `.codex/…-modes.ps1` 197, 228, 230-232, 234-237, 242-244, 246, 248-250, 268, 270-274 (22) | **39** |
| 4 — `Write-Debug` catch | `.claude/…-modes.ps1` 94, 95 (2) + `.codex/…-modes.ps1` 94, 95 (2) | **4** |
| | **Sum** | **62** |
| Reconciling line | `.claude/…gate.ps1` line 210, closed by R4 | **1** |
| | **Total uncovered added lines** | **63** |

The corrected counts sum to 62 and 62 plus the single reconciling line equals the total of 63 the
pre-remediation artifact reported. The previously stated 18 / 3 / 40 / 2 does not reproduce.

## Note on pre-existing versus added uncovered lines

The 63 figure counts uncovered **added** lines. The `.claude/…gate.ps1` missed set additionally
contains the pre-existing uncovered lines 125, 252, 253, 255, 425, 485, 486, 487, and 490, and the
`.codex/…gate.ps1` missed set additionally contains pre-existing 197 and 206. Lines 170-185 of the
`.claude` copy are pre-existing lines that were covered at the merge base and became uncovered by
this branch, which is precisely finding R2.

Output Summary: Per-file covered/missed/uncovered-line inventory captured for all four production
files from the [P0-T6] report. Coverage stands at 80.67% / 98.48% / 82.10% / 81.82%. All six
remediation-target line sets (R1 x3, R2, R3, R4) are confirmed uncovered at baseline. The corrected
four-group counts 16 / 3 / 39 / 4 are recomputed and confirmed, summing to 62, with `.claude` line
210 as the reconciling 63rd line.
