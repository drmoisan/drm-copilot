# [P11-T9] Coverage delta and threshold verification

Timestamp: 2026-08-08T16-32
Task: [P11-T9]

Command: comparison of the [P0-T6] and [P0-T9] baselines against the [P11-T4] and [P11-T7]
post-change values. Source artifacts:

- `evidence/baseline/phase0-python-pytest-coverage.2026-08-08T10-42.md`
- `evidence/baseline/phase0-powershell-pester-coverage.2026-08-08T10-42.md`
- `evidence/qa-gates/final-python-pytest-coverage.2026-08-08T16-26.md`
- `evidence/qa-gates/final-powershell-pester-coverage.2026-08-08T16-32.md`

EXIT_CODE: 0

## Python — repository-wide totals

| Metric | Baseline [P0-T6] | Post-change [P11-T4] | Delta | Threshold | Holds |
| --- | --- | --- | --- | --- | --- |
| TOTAL line coverage | 91.71% (12247 / 13354) | **91.72%** (12263 / 13370) | +0.01 pt | >= 85% | yes |
| TOTAL branch coverage | 83.58% (4122 / 4932) | **83.58%** (4124 / 4934) | 0.00 pt | >= 75% | yes |
| Tests passed | 2835 | 2886 | +51 | — | — |
| Tests failed | 0 | 0 | 0 | — | — |

Post-change line coverage is 91.72%, at least 85%. Post-change branch coverage is 83.58%, at least
75%. Neither total regressed.

## Python — per-file for the changed modules

| Module | Baseline | Post-change | Delta | Regressed |
| --- | --- | --- | --- | --- |
| `scripts/dev_tools/_blast_radius_extraction.py` | 100% | **100%** | 0 | no |
| `scripts/dev_tools/_blast_radius_validation.py` | 100% | **100%** | 0 | no |
| `scripts/dev_tools/_blast_radius_conflicts.py` | 98% (74/75 lines, 31/32 branches) | **100%** (58/58, 22/22) | +2 pt | no |
| `scripts/dev_tools/compute_blast_radius.py` | 100% | **100%** | 0 | no |
| `scripts/dev_tools/_blast_radius_glob.py` | n/a — created at [P1-T1]; 98% at the [P1-T9] post-split baseline | **98%** (57/58 lines, 27/28 branches) | 0 vs [P1-T9] | no |

`_blast_radius_conflicts.py` improved from 98% to 100%: its single uncovered statement at baseline
(line 195) was inside `_entries_overlap`, which [P1-T3] relocated into `_blast_radius_glob.py`.

## Python — new and changed-code coverage

Lines added or modified by this plan in production code:

| Location | Lines | Covered | Coverage |
| --- | --- | --- | --- |
| `_blast_radius_glob.py` `_directory_prefix` ([P6-T3]) | 1 statement | 1 | 100% |
| `_blast_radius_glob.py` `_prefixes_nest` ([P6-T3]) | 1 statement | 1 | 100% |
| `_blast_radius_glob.py` concrete×concrete disjuncts ([P6-T4]) | 1 statement, 4 branch outcomes | all | 100% |
| `_blast_radius_glob.py` mixed concrete×glob disjuncts ([P6-T5]) | 2 statements, 8 branch outcomes | all | 100% |
| `_blast_radius_extraction.py` `root_surfaces` plumbing (Phase 3) | 100% | — | 100% |
| `_blast_radius_validation.py` `config_root_surfaces` (Phase 3) | 100% | — | 100% |
| `compute_blast_radius.py` `root_surfaces` wiring (Phase 3) | 100% | — | 100% |

**New/changed-code coverage: 100% line, 100% branch.** Both above the 85% line and 75% branch
thresholds.

The single uncovered statement in the whole change scope is `_blast_radius_glob.py:222`, the
`return entry` fallback of `_literal_prefix`. That statement is pre-existing code relocated verbatim
at [P1-T3], not new or changed code, and it was uncovered at the same statement with the same count
of 1 at the [P1-T9] baseline.

## PowerShell — repository-wide totals

| Metric | Baseline [P0-T9] | Post-change [P11-T7] | Delta | Threshold | Holds |
| --- | --- | --- | --- | --- | --- |
| LINE | 94.34% (3148 / 3337) | **94.34%** (3148 / 3337) | 0.00 pt | >= 85% | yes |
| INSTRUCTION | 93.95% (4316 / 4594) | **93.95%** (4316 / 4594) | 0.00 pt | — | — |
| METHOD | 90.23% (240 / 266) | **90.23%** (240 / 266) | 0.00 pt | — | — |
| CLASS | 95.12% (39 / 41) | **95.12%** (39 / 41) | 0.00 pt | — | — |
| Tests passed | 1984 | 2020 | +36 | — | — |
| Tests failed | 2 | 2 | 0 | — | — |

Post-change line coverage is 94.34%, at least 85%. No counter regressed; every value is identical
to baseline.

Pester's JaCoCo-format report emits no `branches` counter, so a repository-wide PowerShell branch
percentage is not produced by the toolchain in either the baseline or the post-change run. The
branch obligation for the changed PowerShell logic is discharged behaviourally instead: every
branch outcome of the widened `Test-EntryOverlap` is asserted by the ten [P7-T2] data-table cases
in both argument orders and the four [P9-T2] monotonicity cases, and cross-checked against the
Python branch coverage of the byte-equivalent logic, which is 100%.

## PowerShell — per-module for the changed modules

| Module | Baseline | Post-change | Regressed |
| --- | --- | --- | --- |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | UNMEASURED | UNMEASURED | no |
| `.claude/lib/blast-radius/BlastRadiusGlob.psm1` | UNMEASURED | UNMEASURED | no |
| `.claude/lib/blast-radius/BlastRadiusConfig.psm1` | UNMEASURED | UNMEASURED | no |
| `.claude/lib/blast-radius/BlastRadiusValidation.psm1` | UNMEASURED | UNMEASURED | no |
| `.claude/lib/blast-radius/BlastRadius.psm1` | UNMEASURED | UNMEASURED | no |

All five are declared in the runsettings `CodeCoverage.Path` list but emit no `sourcefile` element,
because the suites consume them through `Import-Module`, which loads each into its own module scope
where coverage breakpoints do not bind. This is a pre-existing measurement condition of the F1
delivery, identical at baseline and post-change. It is an instrumentation-binding condition, not an
exclusion: no coverage `exclude` or `omit` entry was added for any of them.

Behavioural coverage of the five modules is 316 blast-radius Pester tests with zero failures at
[P8-T9], up from 284 at baseline.

## No coverage exclusion added

Verified at [P1-T11] and re-confirmed here: `git diff` of the coverage configuration
(`pyproject.toml` and any `.coveragerc`) shows no added `omit` or `exclude` entry naming any path
under `scripts/dev_tools/`, including the new `scripts/dev_tools/_blast_radius_glob.py`. That module
is in the coverage denominator and reports 98%.

## Verdict

- Post-change Python line coverage is **91.72%**, at least 85 percent.
- Post-change Python branch coverage is **83.58%**, at least 75 percent.
- Post-change PowerShell line coverage is **94.34%**, at least 85 percent.
- New/changed-code coverage is **100% line and 100% branch**.
- **No changed file regressed against its baseline percent.** One improved
  (`_blast_radius_conflicts.py`, 98% to 100%); every other changed file is flat.
- No coverage exclusion was added for any production file.
