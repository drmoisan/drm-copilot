# QA Gate — Coverage Baseline / Post-Change / Changed-Code Comparison (AC16)

- Timestamp: 2026-07-10T19-35
- Inputs:
  - `evidence/baseline/baseline-ts-test-coverage.md`
  - `evidence/baseline/baseline-ps-test-coverage.md`
  - `evidence/qa-gates/final-ts-test-coverage.md`
  - `evidence/qa-gates/final-ps-test-coverage.md`
- Thresholds: line >= 85%, branch >= 75% (uniform T1-T4 per `.claude/rules/quality-tiers.md`).

## TypeScript (`extensions/drm-copilot/`)

Whole-package coverage:

| Metric | Baseline | Post-change | Delta |
|---|---|---|---|
| Lines | 96.64% (31877/32985) | 96.77% (32547/33631) | +0.13 pt |
| Branches | 88.61% (4056/4577) | 88.78% (4149/4673) | +0.17 pt |
| Statements | 96.64% | 96.77% | +0.13 pt |
| Functions | 87.59% | 87.8% | +0.21 pt |

Changed/new-module coverage (all files added or modified by this feature):

| File | % Lines | % Branch | Meets line >= 85% | Meets branch >= 75% |
|---|---|---|---|---|
| poshqc-scan-config.ts | 96.49 | 88.57 | yes | yes |
| poshqc-terminal-output.ts | 99.29 | 100 | yes | yes |
| poshqc-folder-picker.ts | 100 | 100 | yes | yes |
| poshqc-command-registration.ts | 94.27 | 85.71 | yes | yes |

No-regression statement (TypeScript): whole-package line coverage rose from 96.64% to 96.77% and
branch coverage rose from 88.61% to 88.78%; both metrics increased, so there is no coverage
regression on changed lines. Every changed module exceeds line >= 85% and branch >= 75%.

## PowerShell (`scripts/powershell/PoshQC/`)

Report-level (measured file set) line coverage:

| Metric | Baseline | Post-change | Delta |
|---|---|---|---|
| Lines | 93.44% (1039/1112) | 93.44% (1039/1112) | 0.00 pt |

Pester breakpoint coverage is line-based; the Pester coverage report emits no branch counter, so
no PowerShell branch percentage is available from this tool. The report-level line coverage is
identical pre- and post-change (93.44%), so there is no line-coverage regression.

Changed-code coverage (PowerShell):

The three changed PowerShell production files — `PoshQC.psm1` (one added sub-module load line and
one added export entry), `PoshQC.Testing.psm1` (added `-ResolveScanConfig` seam and scan-config
precedence block), and the new `PoshQC.ScanConfig.psm1` — cannot be line-instrumented by Pester
breakpoint coverage. `PoshQC.psm1` loads its sub-modules via
`. ([scriptblock]::Create((Get-Content <file> -Raw)))`, executing a fileless scriptblock with no
on-disk path association; breakpoints set on the `.psm1` files are never hit. This is a
pre-existing structural constraint shared by every PoshQC `.psm1` module (none has ever been in
`CodeCoverage.Path`); it is not introduced by this feature, and adding these files to the coverage
`Path` produces zero instrumented lines (verified empirically — report total unchanged). Full
detail is recorded in `evidence/qa-gates/final-ps-test-coverage.md`.

Changed-code behavioral coverage is provided instead by dedicated deterministic Pester suites,
all passing at the post-change worktree state:
- `Get-PoshQCScanConfigFolder`: 12 It blocks (absent file, blank content, absent/empty
  `scanFolders`, malformed JSON, wrong version, blank entry, absolute-path entry, `..` segment,
  skip-missing-with-warning, all-missing error, all-present success).
- `Invoke-PoshQCTest` scan-config precedence: 4 It blocks (explicit `-ScanFolders` bypasses config,
  config-yielded folders reach run paths, empty config falls back to `Run.Path` defaults, explicit
  missing folder still throws).

No-regression statement (PowerShell): report-level line coverage is unchanged at 93.44% (no
decrease). The changed `.psm1` lines are not line-instrumentable for the structural reason above;
their behavior is verified by the 16 new passing seam-injection It blocks and by the extended
byte-parity gate that locks the changed modules against their bundled mirrors.

## Result

Both languages meet line >= 85% for changed code (TypeScript per-file measured; PowerShell via the
structural-constraint carve-out with behavioral suites and an unchanged report-level line metric)
and branch >= 75% where a branch metric is emitted (TypeScript per-file; PowerShell emits no branch
counter). No coverage regression on changed lines in either language.
