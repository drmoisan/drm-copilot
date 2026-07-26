# Phase 0 — Baseline PoshQC Test + Coverage, Authoritative Path (Remediation Cycle 2)

- **Issue:** #415
- **Task:** [P0-T6]
- **Plan:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-26T18-10.md`
- **Baseline SHA:** `37d0ecb46c222ddd3f20d1e26e5742ecf26acd73`

Timestamp: 2026-07-26T14-37

Command: `pwsh -NoProfile -Command "Import-Module 'C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T16-53/scripts/powershell/PoshQC/PoshQC.psm1' -Force; Invoke-PoshQCTest -Root 'C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T16-53'"`

EXIT_CODE: 0

This is the C2 authoritative path, mirroring the CI invocation at `.github/workflows/_poshqc.yml:38-42`.
It consumes the repo-resident `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, not the stale
runsettings bundled in the npx-cached MCP package (RD-5).

## Test Result

```
Tests completed in 90.21s
Tests Passed: 1659, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 94.02% / 0%. 4,246 analyzed Commands in 39 Files.
Wrote Koverage coverage copy: .../artifacts/pester/powershell-coverage.koverage.xml
LASTEXITCODE=0
```

| Metric | Value |
|---|---|
| Passed | 1659 |
| Failed | 0 |
| Skipped | 9 |
| Inconclusive | 0 |
| NotRun | 0 |
| Elapsed | 90.21 s |

`CoveragePercentTarget` is `0` in the runsettings, which is why the console line reads `94.02% / 0%`;
the threshold enforcement for this plan is the policy gate (>= 85%), applied against the numbers below.

## Repo-Wide Coverage Headline (numeric)

Extracted from `artifacts/pester/powershell-coverage.xml` (JaCoCo), report-level counters:

| Counter | Covered | Missed | Total | Percent |
|---|---|---|---|---|
| INSTRUCTION | 3992 | 254 | 4246 | **94.02%** |
| **LINE** | **2869** | **173** | **3042** | **94.31%** |
| METHOD | 221 | 25 | 246 | 89.84% |
| CLASS | 37 | 2 | 39 | 94.87% |

Repo-wide LINE coverage at baseline: **94.31%** (2869 / 3042). Verdict versus the >= 85% policy gate: PASS.

## Per-File Coverage — Currently Measured `.codex/hooks` Set (C3, package-qualified)

Extraction key: `package/@name` ending in `.codex/hooks` AND `sourcefile/@name`.
Package resolved: `C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T16-53/.codex/hooks`.
Counter: LINE. Missed line numbers from `sourcefile/line[@ci='0']/@nr`.

| Sourcefile | Covered | Missed | Total | Percent | Missed lines |
|---|---|---|---|---|---|
| `check-powershell-test-purity.ps1` | 62 | 0 | 62 | 100.00% | — |
| `check-python-test-purity.ps1` | 67 | 0 | 67 | 100.00% | — |
| `codex-pretooluse-file-mapping.ps1` | 101 | 0 | 101 | 100.00% | — |
| `enforce-checkpoint-monotonic.ps1` | 103 | 1 | 104 | 99.04% | 261 |
| `enforce-completion-consistency.ps1` | 136 | 0 | 136 | 100.00% | — |
| `enforce-completion-helpers.ps1` | 33 | 10 | 43 | 76.74% | 52, 79, 87, 93, 100, 135, 144, 152, 156, 160 |
| `enforce-evidence-locations.ps1` | 41 | 0 | 41 | 100.00% | — |
| `enforce-orchestration-preimplementation-gate.ps1` | 98 | 0 | 98 | 100.00% | — |
| `enforce-powershell-batch-budget.ps1` | 84 | 3 | 87 | 96.55% | 247, 248, 249 |
| `enforce-python-batch-budget.ps1` | 84 | 3 | 87 | 96.55% | 245, 246, 247 |

### Cycle-1 changed-file reference band

The files changed by cycle 1 (per `git diff --stat fb483b84..HEAD`) that appear in this measured set are:
`check-powershell-test-purity.ps1`, `check-python-test-purity.ps1`, `codex-pretooluse-file-mapping.ps1`,
`enforce-checkpoint-monotonic.ps1`, `enforce-completion-consistency.ps1`, `enforce-evidence-locations.ps1`,
`enforce-orchestration-preimplementation-gate.ps1`, `enforce-powershell-batch-budget.ps1`,
`enforce-python-batch-budget.ps1`. Their observed band is **96.55% – 100.00%**, matching the reference band
stated in the plan. This band must not regress at [P4-T3], [P5-T3], [P6-T3], and [P7-T3].

`enforce-completion-helpers.ps1` (76.74%) is **not** a cycle-1 changed file — it does not appear in the
merge-base..HEAD diff. It is pre-existing measured surface carried into the baseline unchanged and is
outside the scope of this plan. It is recorded here so that any later movement in the repo-wide number can be
attributed correctly.

## Auditable Negative Record — the two hooks this plan changes are ABSENT from measurement

Command: `pwsh -NoProfile -File <scratchpad>/cov2-absence.ps1 -CoverageXml artifacts/pester/powershell-coverage.xml`
EXIT_CODE: 0

```
SearchScope: coverage XML packages whose name ends with ".codex/hooks"
SearchPatterns: enforce-epic-child-worktree-binding.ps1, enforce-epic-planning-only.ps1

SearchResult[enforce-epic-child-worktree-binding.ps1]: none   (whole-XML literal occurrences: 0)
SearchResult[enforce-epic-planning-only.ps1]: none   (whole-XML literal occurrences: 0)

Measured .codex/hooks sourcefile set:
  check-powershell-test-purity.ps1
  check-python-test-purity.ps1
  codex-pretooluse-file-mapping.ps1
  enforce-checkpoint-monotonic.ps1
  enforce-completion-consistency.ps1
  enforce-completion-helpers.ps1
  enforce-evidence-locations.ps1
  enforce-orchestration-preimplementation-gate.ps1
  enforce-powershell-batch-budget.ps1
  enforce-python-batch-budget.ps1
```

- `SearchScope:` the coverage XML packages ending `.codex/hooks` (one package resolved) plus, as a
  second independent method, a literal-string scan of the entire coverage XML.
- `SearchPatterns:` `enforce-epic-child-worktree-binding.ps1`, `enforce-epic-planning-only.ps1`.
- `SearchResult:` **none** by both methods (0 sourcefile entries; 0 literal occurrences anywhere in the file).

Both hooks that the C1 and A1 fixes will modify are therefore absent from the coverage denominator at
baseline. This is the R-COV gap that [P4-T1] closes by appending both paths to `CodeCoverage.Path` in both
`pester.runsettings.psd1` copies.

## Output Summary

Authoritative local run exits 0. 1659 passed, 0 failed, 9 skipped. Repo-wide LINE coverage
**94.31%** (2869 / 3042 lines; 4246 analyzed commands across 39 files) — PASS against the >= 85% gate.
Ten `.codex/hooks` files are measured; the nine cycle-1 changed files sit in the **96.55% – 100.00%** band.
The two hooks this plan changes, `enforce-epic-child-worktree-binding.ps1` and
`enforce-epic-planning-only.ps1`, are confirmed ABSENT from the measured set by two independent search
methods, establishing the R-COV baseline gap.
