# Code Review: PoshQC workspace-derived coverage population (#527, absorbs #623 item 1)

---

**Review Date:** 2026-10-02
**Reviewer:** feature-review agent (pass 2, remediation cycle 1 reaudit)
**Feature Folder:** `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527`
**Feature Folder Selection Rule:** the only active feature folder changed on the branch; its suffix matches issue #527 in the branch name.
**Base Branch:** `origin/main` (resolved `ef80c57d`, merge base `71f8dcb4`)
**Head Branch:** `bug/poshqc-coverage-denominator-not-reproducible-527` at `e5d9b58f`
**Review Type:** Re-review after remediation cycle 1 (prior: `code-review.2026-10-02T05-08.md` at `70ab599d`)

---

## Executive Summary

Remediation cycle 1 addressed only the policy-audit blocker PA-B1 (Python coverage artifact). The cycle consists of two commits, `47e65f51` and `e5d9b58f`, that add seven Python coverage evidence files, three remediation preflight records, two remediation-baseline records, the remediation plan, and the pass-1 review artifacts. `git diff --name-only 70ab599d e5d9b58f -- scripts extensions tests config .gitignore` returned no path, so no production, test, fixture, mirror, or configuration file changed. The pass-1 code review therefore applies to HEAD without modification; its findings are carried forward below with unchanged severity.

The reviewer re-verified at `e5d9b58f`: the five PoshQC source/mirror pairs are byte-identical (SHA-256 prefixes `b79301b94bb0`, `1b2d124e590b`, `36715226c472`, `9123dde0cd28`, `7c966e7a3f34`); Black, Ruff, Pyright, and the parity pytest pass on the changed Python file; the working tree is clean.

**What changed in the cycle:**
- Evidence only: `evidence/qa-gates/python-*.md` (7 files), `evidence/other/remediation-preflight-round-{1,2,3}.*.md`, `evidence/remediation-baseline/*.md`, `remediation-plan.2026-10-02T05-08.md`.
- Git-ignored tool output: `artifacts/python/lcov.info` (not committed; correctly so).

**Top 3 risks (unchanged from pass 1):**
1. Consumer behavior change: a `CodeCoverage.Path` list in the module's own runsettings file is now ignored (logged), and a caller-supplied runsettings file without a `Path` list now receives a derived population. Not yet in the extension CHANGELOG.
2. The fixture acceptance (AC-11 to AC-13) and the different-cwd determinism leg (AC-01) have not run against the fixed code (operator-run, decision 2026-10-01).
3. Untracked `.ps1`/`.psm1` files under a configured root change the denominator (accepted risk; visible in the logged file count).

**PR readiness recommendation:** **Go, with non-blocking items** — no code defect blocks merge; the policy-audit blocker is closed; four acceptance criteria remain deferred by operator decision and the PR must say "Partially addresses #527".

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `scripts/powershell/PoshQC/README.md`, `extensions/drm-copilot/CHANGELOG.md` | README "Notes for standalone use"; CHANGELOG `[Unreleased]` | Carried from pass 1, unchanged. The consumer-visible behavior change is documented in the README but not in the extension changelog. Non-blocking. | Add an `[Unreleased]` entry describing the change and the migration to `config/poshqc-coverage.json`, in this PR or in the release that ships it. | Consumers who edited the shipped settings in place get only one log line as a signal. | `PoshQC.Coverage.psm1:268-297`; CHANGELOG not in the branch diff. |
| Minor | `scripts/powershell/PoshQC/PoshQC.Coverage.psm1` | 183-194 | Carried. Prefix-mismatch fallback makes `RelativePath` absolute, so ancestor directories named `build`, `dist`, or `artifacts` could exclude every file. Non-blocking. | Normalize `Root` before comparison or compute segments relative to the coverage root; add one test. | Silent empty population disables coverage for that run (logged). | Code inspection. |
| Minor | `scripts/powershell/PoshQC/PoshQC.Coverage.psm1` | 102-112 | Carried. Version and `roots`-shape errors omit the offending value that spec Error handling names. Non-blocking (AC-06 requires only the file name). | Append the received value or JSON type. | Diagnosis speed. | `spec.md` Error handling. |
| Minor | `tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1` | precedence Describe | Carried. Four boundary branches untested (blank `-SettingsFile` with a non-empty list, non-integer `version`, top-level JSON array, rooted `-ConfigRelativePath`). Non-blocking; new-file figure 95.41%. | Add data-driven cases. | Scenario completeness. | Run A XML uncovered lines 75, 96, 163, 256, 257. |
| Minor | `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` | 621-622, 745-746 | Carried. `Test-Path` mock matches any `*src*` path. Non-blocking. | Match the exact joined entry. | Mock precision. | Branch diff. |
| Minor | `scripts/powershell/PoshQC/README.md` (and mirror) | line 68 | Carried. Run paths omit `tests/scripts`. Non-blocking. | Add `tests/scripts`. | README accuracy. | runsettings line 3. |
| Nit | `scripts/powershell/PoshQC/README.md` (and mirror) | line 73 | Carried. "root-relative" ambiguous. | Say "workspace-relative". | Precision. | `PoshQC.Coverage.psm1:186-191`. |
| Nit | `scripts/powershell/PoshQC/PoshQC.Coverage.psm1` | 172-174 | Carried. "does not exist" warning for a file-valued scan folder. | Reword or check leaf type. | Diagnostic clarity. | Code inspection. |
| Info | `config/poshqc-coverage.json` | roots | Carried. Confirm that every PowerShell file under `extensions/drm-copilot/resources/` is a parity-guarded mirror of a measured file or is measured. | Follow-up check. | Coverage Exclusion Policy. | `git ls-files '*.ps1' '*.psm1'` outside the five roots. |
| Info | `<FEATURE>/evidence/qa-gates/python-coverage.2026-10-02T05-34.md`, `python-changed-files.2026-10-02T05-33.md`, `evidence/other/remediation-preflight-round-2.2026-10-02T05-40.md`, `remediation-preflight-round-3.2026-10-02T06-05.md` | file name and `Timestamp:` | New in cycle 1. All four were introduced by commit `47e65f51` at 05:30:31 -0400, so each timestamp is later than its commit; the timestamps are not clock-read. Pass 1 recorded the same class (PA-N4). Non-blocking. | Read the clock (`Get-Date -Format yyyy-MM-ddTHH-mm` or `date +%Y-%m-%dT%H-%M`) when naming evidence. | Timestamp provenance. Numeric content was re-derived by the reviewer from `artifacts/python/lcov.info` and matched exactly. | `git log --name-status 70ab599d..e5d9b58f`. |
| Info | `<FEATURE>/evidence/qa-gates/python-coverage-run-b.2026-10-02T05-30.md` | Output Summary | The combined `Cover` figure (92%) is correctly identified as statement-plus-branch, and the line and branch percentages are taken from `coverage json` totals. Recorded as a positive observation; no action. | None. | Correct interpretation of the coverage.py report avoids a common misreading. | Evidence file text; reviewer lcov reduction. |

No Blocker findings. One Major finding (non-blocking, carried from pass 1).

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

Unchanged from pass 1: precedence evaluated once and returned as `{ Source; Paths }`; D2 settings-file comparison implemented exactly; ordinal sort with case-insensitive de-duplication; #409 empty-population semantics preserved; relative `-Root` resolved once; mirrors byte-identical (re-verified at `e5d9b58f`).

#### API and safety notes

- No exported surface change; `PoshQC.psd1` unchanged.
- No `Mandatory` parameters by design (plan D1).
- Config validation rejects rooted and `..` entries.

#### Error handling and logging

- Malformed configuration fails fast naming `config/poshqc-coverage.json`.
- Nonexistent roots emit one warning each; JSON parse errors are wrapped and rethrown.

### Python implementation audit

#### What changed well

- One tuple entry in `POSHQC_PARITY_PATHS`. Black, Ruff, Pyright, and Pytest pass (reviewer re-run at `e5d9b58f`).
- Cycle 1 measured repo-wide Python coverage at 93.53% line and 86.77% branch with the repository-configured sources (`src`, `scripts/dev_tools`); the `omit` list contains test and environment paths only.

#### Typing and API notes

- No new public Python API surface.

#### Error handling and logging

- No change.

---

## Test Quality Audit

No test file changed in the cycle. The pass-1 assessment stands: the new suites drive production code through injected seams and `InModuleScope` cmdlet mocks, write nothing to disk, and the fail-first CI run shows the route-level tests failing on assertions against pre-fix code.

### Reviewed test and QA artifacts

- `evidence/qa-gates/python-coverage-run-a.2026-10-02T05-29.md`, `python-coverage-run-b.2026-10-02T05-30.md` — two full-suite runs, 6377 passed, 6 skipped each; consistent counts across runs.
- `evidence/qa-gates/python-coverage-totals.2026-10-02T05-31.md`, `python-coverage-lcov-check.2026-10-02T05-32.md` — totals cross-checked against LCOV `BRDA` counts; reviewer reduction of `LF`/`LH`/`BRF`/`BRH` matched (17244/16129, 6230/5406).
- `evidence/qa-gates/python-changed-files.2026-10-02T05-33.md` — confirms the test module is the only Python file in the diff; reviewer re-ran the diff with the same result.

### Quality assessment prompts

- **Determinism:** unchanged; the Python runs reproduced identical pass/skip counts.
- **Isolation:** unchanged.
- **Speed:** unchanged.
- **Diagnostics:** unchanged.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Cycle diff is documentation only; pass-1 diff inspection stands. |
| No unsafe subprocess or command construction | PASS | No code change. |
| Input validation at boundaries | PASS | Unchanged. |
| Error handling remains explicit | PASS | Unchanged. |
| Configuration / path handling is safe | PASS (with Minor finding) | Unchanged; prefix-mismatch edge case carried. |
| Evidence artifacts free of absolute host paths | PASS | Cycle 1 evidence uses `<ROOT>` placeholders. |

---

## Research Log

No external research was required in this pass.

---

## Verdict

Remediation cycle 1 changed no code and closed the only blocking item from pass 1 with verifiable evidence. All pass-1 code-review findings remain open at their original non-blocking severities, and one new Info item records the cycle 1 evidence timestamp provenance.

Code-review blocking findings: 0.
