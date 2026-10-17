# Policy Compliance Audit: validate-orchestrator-output session-relative checkpoint read (#787, bundling #840)

---

**Audit Date:** 2026-10-09 (timestamp 2026-10-09T00-12)
**Branch:** `bug/validate-orchestrator-output-session-relative-read-exec-787`
**Head:** `a9fcabc5ad2b2c79db5cabf4dacfe7b635127e3f`
**Base:** `origin/epic/enforcement-hook-precision-integration` @ `497cb504ad9a4e5435dc8946333ebc28baea50c4` (merge base equals base tip)
**Diff command:** `git diff origin/epic/enforcement-hook-precision-integration...HEAD`
**Work mode:** `full-bug` (`issue.md` line 8); AC source: `spec.md` only
**PR context:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, generated 2026-10-09 04:04:56 UTC at head `a9fcabc5`, so they are current for this head.
**Code Under Test:** `.claude/hooks/validate-orchestrator-output.ps1` (modified), `.claude/hooks/validate-orchestrator-output-resolution.ps1` (new), `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1` (new), `.claude/hooks/enforce-epic-wave-barrier.ps1` (comment only), their bundled mirrors, and the test, fixture, manifest, and documentation files listed in section 9.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 4 production files (2 new, 2 modified) plus 4 mirrors; 9 test files (5 new, 4 modified) | 7659 tests (MCP runner JUnit report) | PASS (residuals only): 7657 pass, 2 fail (both baseline KL-HERMETIC, #737) | 94.55% lines (hook, per-file baseline); sibling and port were new files | 94.62% lines (hook); 98.96% lines (sibling); 100% lines (port); repo-wide 96.48% lines | 96.43% changed lines (hook); 98.96% (sibling, new); 100% (port, new) |
| Python | 2 test files (1 new, 1 modified); 0 production files | 6633 tests (full pytest) | PASS: 6633 pass, 0 fail | 93.67% lines, 87.09% branches (repo-wide) | 93.71% lines, 87.16% branches (repo-wide) | N/A - test files only; no production Python file changed |
| TypeScript | 0 files | 32 tests (two existing lanes, 16 each) | PASS: 16/16 and 16/16 | N/A - no TypeScript file changed on the branch | N/A - no TypeScript file changed on the branch | N/A - no TypeScript file changed on the branch |
| C# | 0 files | N/A | N/A | N/A - no C# file changed on the branch | N/A - no C# file changed on the branch | N/A - no C# file changed on the branch |
| JSON | 2 files (1 new fixture, 1 modified manifest) | N/A | PASS (consumed by parity and manifest suites) | N/A (data and config files) | N/A (data and config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - no TypeScript file changed on the branch; the existing TypeScript lanes were recorded at baseline as 16/16 and 16/16 in `evidence/baseline/ts-wave-barrier.2026-10-08T22-36.md`.
- TypeScript post-change coverage artifact: N/A - no TypeScript file changed on the branch; the same lanes passed 16/16 and 16/16 post-change in `evidence/qa-gates/final-ts.2026-10-08T22-36.md`.
- PowerShell baseline coverage artifact: `evidence/baseline/coverage-powershell.2026-10-08T22-36.md` (hook 94.55% lines; sibling and port recorded as NEW-FILE).
- PowerShell post-change coverage artifact: `evidence/qa-gates/final-ps-coverage.2026-10-08T22-36.md` (hook 94.62%, sibling 98.96%, port 100%) and `artifacts/pester/powershell-coverage.xml` (repo-wide 96.48%, hook 94.62%).
- Per-language comparison summary: Section 1.2.1 of this audit; `evidence/qa-gates/coverage-comparison.2026-10-08T22-36.md` (PowerShell) and `evidence/qa-gates/coverage-comparison-python.2026-10-08T22-36.md` (Python).

---

## Executive Summary

All policy areas PASS. No blocking finding. Coverage: PowerShell PASS, Python PASS. TypeScript and C# have zero changed files on the branch.

113 files changed (5124 insertions, 263 deletions). Of these, 86 are feature-folder evidence and plan/spec documents; the remaining 27 non-evidence files are listed in section 9. No TypeScript or C# file changed. No Python production file changed.

**Policy documents evaluated:**

| Policy | Read | Notes |
|---|---|---|
| `CLAUDE.md` | Yes | Tone and architecture |
| `.claude/rules/general-code-change.md` | Yes | Toolchain loop, 500-line cap, I/O isolation |
| `.claude/rules/general-unit-test.md` | Yes | Coverage, exclusion policy, no temp files |
| `.claude/rules/quality-tiers.md` | Yes | Uniform 85% line; no PowerShell branch gate |
| `.claude/rules/powershell.md` | Yes | PowerShell toolchain |
| `.claude/rules/python.md` | Referenced | Python changes are test-only |

**Language-specific policies evaluated:**
- PowerShell code change and unit test policy: evaluated (sections 3A, 4A).
- Python code change and unit test policy: evaluated for the test-only changes (sections 3B, 4B).
- TypeScript and C#: N/A (zero changed files).
- JSON: two data/config files; consumed by passing suites (section 3C).

Toolchain loop: format, lint, type check, architecture boundary, unit tests, contract/schema, and integration stages all passed in a single recorded pass (section 7). The only unit-test failures are two pre-existing KL-HERMETIC residuals recorded in the Phase 0 baseline (section 8).

**Temporary artifacts cleanup:**
- Scratch scripts were kept outside the repository; no scratch file is in the branch diff (see code review, departure 7).

---

## Rejected Scope Narrowing

None detected. The caller prompt named the integration base, the feature folder, and specific items to evaluate. It did not narrow the audit to a plan, phase, or file subset, and it did not declare any language out of scope. The audit covers the full branch diff.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence and isolation** | PASS | Tests are in-memory and mock the seams at module scope (code review, Tests section). Each new suite targets one surface: sibling resolution, two-worktree resolution, wave-barrier wiring, port unit, port parity. |
| **Determinism** | PASS | Row P6: no `Start-Sleep`, `Get-Date`, or `Start-Process` in the nine new or changed Pester files. Synthetic `/synthetic-worktrees/` roots are used throughout. |
| **Readability** | PASS | Rows are identified by stable IDs (R1-R14, S2-1 to S2-12, H1-H12, U1-U12, D1-D5) referenced by the spec and the feature audit. |

### 1.2 Coverage and Scenarios

Coverage artifacts were inspected, not regenerated.

**PowerShell — PASS**

- Artifact: `artifacts/pester/powershell-coverage.xml` (JaCoCo, written 2026-10-08 23:50, after the last code commit).
- Repo-wide line coverage: LINE missed=422, covered=11571, so 11571 / 11993 = **96.48%** (threshold 85%). PASS.
- No branch threshold applies to PowerShell (Pester does not measure branch coverage).
- Per-file detail is in section 5.

**Python — PASS**

- Artifact: `artifacts/python/lcov.info` (written 2026-10-08 23:59).
- Repo-wide: LH 16452 / LF 17556 = **93.71%** line; BRH 5524 / BRF 6338 = **87.16%** branch (thresholds 85% / 75%). PASS.
- Baseline 93.67% / 87.09%; no regression.
- Changed Python files are test files only. Test files are excluded from coverage by policy, so no per-file production threshold applies. No production Python file changed.

**TypeScript — N/A** (zero changed `.ts` files on the branch).

**C# — N/A** (zero changed `.cs` files on the branch).

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | PowerShell hook 94.55% (`evidence/baseline/coverage-powershell.2026-10-08T22-36.md`); Python 93.67% line / 87.09% branch (`evidence/baseline/python-pytest-coverage.2026-10-08T22-36.md`). |
| **No Coverage Regression** | PASS | Hook 94.55% to 94.62%; Python line 93.67% to 93.71%, branch 87.09% to 87.16%. |
| **New Code Coverage** | PASS | Sibling 98.96%, port 100%, hook changed lines 96.43%; all at least 85%. |
| **Positive, negative, edge, and error flows** | PASS | Resolved epic/parallel/item targets (R1-R12); `NoTarget`/`Ambiguous` blocks (R5-R10); leaf cross-check rejections (S2-1 to S2-5); unevaluable classes (U9-U12, D3-D5, H8-H11); import failures (S2-12, H12). |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 94.55% lines (hook) -> Post-change: 94.62% lines (hook). Change: +0.07% lines (no regression); repo-wide post-change 96.48% lines. New/changed-code coverage: 96.43% changed lines (hook); 98.96% (sibling, new file); 100% (port, new file). Disposition: PASS. Evidence: `evidence/baseline/coverage-powershell.2026-10-08T22-36.md`, `evidence/qa-gates/final-ps-coverage.2026-10-08T22-36.md`, `evidence/qa-gates/final-changed-line-coverage.2026-10-08T22-36.md`, `evidence/qa-gates/coverage-comparison.2026-10-08T22-36.md`, `artifacts/pester/powershell-coverage.xml`.
- Python: Baseline: 93.67% lines, 87.09% branches -> Post-change: 93.71% lines, 87.16% branches. Change: +0.04% lines, +0.07% branches (no regression). New/changed-code coverage: N/A - test files only; no production Python file changed. Disposition: PASS. Evidence: `evidence/baseline/python-pytest-coverage.2026-10-08T22-36.md`, `evidence/qa-gates/coverage-comparison-python.2026-10-08T22-36.md`, `artifacts/python/lcov.info`.
- TypeScript: Baseline: N/A (no TypeScript file changed; lanes 16/16 and 16/16) -> Post-change: N/A (lanes 16/16 and 16/16). Change: none. New/changed-code coverage: N/A - no TypeScript file changed. Disposition: N/A. Evidence: `evidence/baseline/ts-wave-barrier.2026-10-08T22-36.md`, `evidence/qa-gates/final-ts.2026-10-08T22-36.md`.
- C#: Baseline: N/A -> Post-change: N/A. Change: none. New/changed-code coverage: N/A - no C# file changed. Disposition: N/A. Evidence: branch diff contains no `.cs` file.

### 1.3 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No temporary files in tests (P6)** | PASS | Scan of the nine new or changed Pester files found no `TestDrive`, `New-TemporaryFile`, `GetTemp*`, `$env:TEMP`, `Set-Content`, `Out-File`, `New-Item`, `Start-Sleep`, `Get-Date`, or `Start-Process`. The only file reads are read-only reads of committed files (fixture corpus; registration files in S2-6). |
| **Test location (P7)** | PASS | All new tests are under `tests/`, mirroring `.claude/hooks/` and `.claude/lib/orchestrator-state/`. |
| **Coverage exclusion policy (P15)** | PASS | No `exclude` entry was added. The branch does not touch `config/poshqc-coverage.json` or either `pester.runsettings.psd1`. |

### 1.4 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission review** | PASS | This document, with `code-review.2026-10-09T00-12.md` and `feature-audit.2026-10-09T00-12.md`, is the required review set. |

---

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **500-line file cap (P1)** | PASS | Independent `wc -l`: hook 482, sibling 314, port 346, wave-barrier hook 380, largest test 437 (`validate-orchestrator-output.Tests.ps1`), fixture 334, Python lane 135, pin module 376. All at most 500. |
| **Policy files unmodified (P9)** | PASS | No file under `.claude/rules/` or `.github/instructions/` is in the diff. |
| **Owned-module boundary, `WorktreeRunResolution.psm1` (P10)** | PASS | No file under `.claude/lib/worktree-resolution/` is in the diff. |
| **Bundled mirror parity (P11)** | PASS | Independent SHA-256 of all six primary/mirror pairs: every pair is identical (for example, hook `5961ed29…`, sibling `6d88f247…`, port `0d4a2da3…`, SKILL `66c7baa9…`, agent `d5e5e3b0…`, wave-barrier hook `2709a1f1…`). |
| **Codex copies (P12)** | PASS | `.codex/hooks/enforce-epic-wave-barrier.ps1` and `.codex/agents/epic-orchestrator.toml` exist. A grep for `Layer 2`, `SubagentStop`, `validate_epic_orchestrator_state`, and `wave_barrier_ordering` returns no match, so they make no Layer 2 claim. The spec excludes them explicitly. No Codex copy exists for the hook, sibling, or port. |
| **Error handling, fail closed (P13)** | PASS | Unresolved targets, cross-check failures, and import failures block before any read. Layer 2 errors block with `EPIC_WAVE_BARRIER_UNEVALUABLE:`. One minor gap is noted in the code review (CR-3): an unexpected resolver exception fails closed without the lead token. |
| **Dependencies (P14)** | PASS | No new package. `System.Text.Json` and `System.Numerics` are .NET BCL types already used in production. |
| **Design principles** | PASS | Resolution logic is isolated in a dot-sourced sibling with small single-purpose functions; Layer 2 is a separate module; I/O seams are mockable (code review, Production Code section). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter (P2)** | PASS | `evidence/qa-gates/final-ps-format.2026-10-08T22-36.md`: ChangedCount=0 over 211 files; MCP `run_poshqc_format` ok. |
| **Linting with PSScriptAnalyzer (P3)** | PASS | `evidence/qa-gates/final-ps-analyze.2026-10-08T22-36.md`: PSSA DiagnosticCount=0; MCP `run_poshqc_analyze` ok. |
| **No Python in hooks (P8)** | PASS | A case-insensitive grep for the alternation of `python`, `subprocess`, `Start-Process`, and `Invoke-Expression` over the three production files matches only comments. `enforcement-hooks-no-python-invocation.Tests.ps1` passed in the JUnit report (27/0). |
| **Type check** | N/A | Not applicable for PowerShell. |

### Section 3B: Python Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Black, Ruff, Pyright (P5)** | PASS | black (577 unchanged), ruff (clean), pyright (0 errors). Evidence: `evidence/qa-gates/final-py-black.2026-10-08T22-36.md`, `final-py-ruff`, `final-py-pyright`. |
| **Scope** | PASS | Python changes are test-only: `tests/scripts/dev_tools/test_epic_wave_barrier_parity_corpus.py` (new) and pin digests in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`. |

### Section 3C: JSON

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Fixture and manifest** | PASS | `tests/fixtures/epic_wave_barrier/layer2-parity-edge-cases.json` (new, 334 lines) is consumed by the passing parity suites; `pack-manifests/core.json` (two entries) is covered by `OrchestratorState.Manifest.Tests.ps1` 6/0 and the bundle-parity suites 17/17. |

### Section 3D: TypeScript and C#

N/A. Zero changed `.ts` or `.cs` files on the branch.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **PowerShell tests (P4)** | PASS (residuals only) | Independently read `artifacts/pester/pester-junit.xml` (written 23:53, after the last code commit at 23:32): tests=7659, failures=2, errors=0. The two failing suites are `enforce-pr-author-skill.Tests.ps1` and `codex-pretooluse-integration.Tests.ps1`, one case each. Both case names appear verbatim in the Phase 0 SET-FULL baseline (`evidence/baseline/pester-set-full.2026-10-08T22-36.md` lines 33 and 72, class KL-HERMETIC, #737). Every new or changed suite on this branch reports 0 failures in the same report. |
| **Pester v5 structure and location** | PASS | New suites use `Describe`/`It` with `BeforeAll` mocks and live under `tests/scripts/claude-hooks/` and `tests/scripts/claude-lib/orchestrator-state/`. |

### Section 4B: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pytest (P5)** | PASS | pytest 6633 passed / 0 failed (`evidence/qa-gates/final-py-pytest.2026-10-08T22-36.md`). The parity lane runs the corpus through `validate_epic_orchestrator_state_text` (30 nodes, all passed). |

---

## 5. Test Coverage Detail

| File | Status | Line coverage | Source | Verdict |
|---|---|---|---|---|
| `.claude/hooks/validate-orchestrator-output.ps1` | Modified | 123/130 = **94.62%** (baseline 94.55%; no regression) | Repo artifact, verified directly: missed lines 61, 176, 476-479, 482 | PASS |
| `.claude/hooks/validate-orchestrator-output-resolution.ps1` | New | 95/96 = **98.96%** (missed line 89) | Executor per-file run, `evidence/qa-gates/final-ps-coverage.2026-10-08T22-36.md` | PASS |
| `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1` | New | 108/108 = **100%** | Same evidence file | PASS |
| `.claude/hooks/enforce-epic-wave-barrier.ps1` | Modified (comment only) | No executable line changed | `evidence/qa-gates/wave-comment-only.2026-10-08T22-36.md` | PASS (no changed executable lines) |

Changed-line coverage (`evidence/qa-gates/final-changed-line-coverage.2026-10-08T22-36.md`): hook 96.43%, sibling 98.96%, port 100%.

Source note for the two new files: neither appears in the MCP runner's coverage artifact. This is a pre-existing gap in the MCP runner's coverage population, not an exclusion introduced by this branch. `config/poshqc-coverage.json` lists `.claude/hooks` and `.claude/lib` as roots, which derives 187 files. The artifact contains 127, and the pre-existing #565 file `.claude/hooks/feature-folder-resolution.ps1` is also absent. The per-file figures for the two new files therefore come from the executor's self-hosted Pester `CodeCoverage.Path` run, which is recorded with its exact command. The suites that run in that measurement pass in the independently read JUnit report: sibling suite 12/0, WorktreeResolution 14/0, WaveBarrier 12/0, port unit 20/0, parity 7/0. The hook figure in that run (94.62%) matches the repo artifact exactly, which supports the reliability of the same run's sibling and port figures. This is recorded as a non-blocking observation (CR-6), not a FAIL: the files are in the configured population, and the measurement exists.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Pester, MCP runner (full repo) | 7659 tests, 2 failures, 0 errors | PASS (2 baseline residuals) |
| Pester, self-hosted per-file coverage run | 120 tests, 120 passed, 0 failed | PASS |
| pytest (full) | 6633 passed, 0 failed | PASS |
| pytest targeted (bundle parity and lanes) | 149 passed; bundle-parity suites 17/17 | PASS |
| Python parity lane | 30 nodes passed | PASS |
| TypeScript lanes | 16/16 and 16/16 | PASS |
| PowerShell repo-wide line coverage | 96.48% | PASS |
| Python repo-wide coverage | 93.71% lines, 87.16% branches | PASS |

---

## 7. Code Quality Checks

| Stage | Result | Evidence |
|---|---|---|
| Format (PS, Python) | PASS | `final-ps-format`, `final-py-black` |
| Lint (PS, Python) | PASS | `final-ps-analyze`, `final-py-ruff` |
| Type check (Python) | PASS | `final-py-pyright` |
| Architecture boundary | PASS | WRR unchanged (`wrr-unchanged`); no-Python guard passed |
| Unit tests | PASS (baseline residuals only) | JUnit report (independently read); `final-pester`; `final-py-pytest` |
| Contract / schema | PASS | Bundle-parity suites 17/17 (`final-py-targeted`); `OrchestratorState.Manifest.Tests.ps1` 6/0; TS pack-manifest lanes 16/16 (`final-ts`) |
| Integration | PASS | Python parity lane against the authority (30 nodes) |

No stage changed a tracked file in the recorded pass (`evidence/qa-gates/final-loop.2026-10-08T22-36.md`).

---

## 8. Gaps and Exceptions

### Identified Gaps

None blocking. Non-blocking observations recorded in the code review:
- CR-3: an unexpected resolver exception fails closed (exit 1) without the `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` lead token.
- CR-6: the MCP PoshQC coverage artifact omits about 60 files of the configured population, including both new files; pre-existing tooling gap, not caused by this branch.

### Approved Exceptions

None.

### Residual Test Failures (pre-existing)

- KL-HERMETIC (#737): one case each in `enforce-pr-author-skill.Tests.ps1` and `codex-pretooluse-integration.Tests.ps1`, both recorded in the Phase 0 SET-FULL baseline.

---

## Evidence Location Compliance

- `git diff --name-only <base>...HEAD -- artifacts` returns no file. No branch file is written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0.
- All 86 evidence files are under `docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787/evidence/{baseline,regression-testing,qa-gates,other}/`.

Verdict: PASS. No FAIL findings.

---

## 9. Summary of Changes

113 files changed (5124 insertions, 263 deletions). Of these, 86 are feature-folder evidence and plan/spec documents. The 27 non-evidence files are:

| Language / kind | Files | New | Modified |
|---|---|---|---|
| PowerShell production | `.claude/hooks/validate-orchestrator-output.ps1`, `.claude/hooks/validate-orchestrator-output-resolution.ps1`, `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1`, `.claude/hooks/enforce-epic-wave-barrier.ps1` (comment only) | 2 | 2 |
| PowerShell production mirrors | the four files above under `extensions/drm-copilot/resources/claude-customizations/.claude/` | 2 | 2 |
| PowerShell tests | 5 new, 4 modified under `tests/scripts/claude-hooks/` and `tests/scripts/claude-lib/orchestrator-state/` | 5 | 4 |
| Python tests | `tests/scripts/dev_tools/test_epic_wave_barrier_parity_corpus.py` (new), `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (pin digests) | 1 | 1 |
| JSON | `tests/fixtures/epic_wave_barrier/layer2-parity-edge-cases.json` (new), `pack-manifests/core.json` (two entries) | 1 | 1 |
| Markdown | `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md`, their mirrors, `spec.md`, `plan.*.md` | 0 | 6 |

No TypeScript or C# file changed. No Python production file changed.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT (PASS)

All policy areas PASS. No blocking finding. Coverage: PowerShell PASS, Python PASS.

### Policy-by-Policy Summary

| # | Policy area | Verdict | Section |
|---|---|---|---|
| P1 | 500-line file cap | PASS | 2 |
| P2 | PowerShell format | PASS | 3A |
| P3 | PowerShell analyze | PASS | 3A |
| P4 | PowerShell tests | PASS (residuals only) | 4A |
| P5 | Python toolchain | PASS | 3B, 4B |
| P6 | No temporary files in tests | PASS | 1.3 |
| P7 | Test location | PASS | 1.3 |
| P8 | No Python in hooks | PASS | 3A |
| P9 | Policy files unmodified | PASS | 2 |
| P10 | Owned-module boundary (`WorktreeRunResolution.psm1`) | PASS | 2 |
| P11 | Bundled mirror parity | PASS | 2 |
| P12 | Codex copies | PASS | 2 |
| P13 | Error handling (fail closed) | PASS | 2 |
| P14 | Dependencies | PASS | 2 |
| P15 | Coverage exclusion policy | PASS | 1.3 |
| Coverage | PowerShell / Python | PASS / PASS | 1.2, 1.2.1, 5 |
| Evidence locations | Canonical paths | PASS | Evidence Location Compliance |

### Recommendation

Ready for the normal PR flow. No remediation inputs are required.

---

## Appendix A: Test Inventory

| Test file | Status | Result (JUnit unless noted) | Scope |
|---|---|---|---|
| `tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1` | New | 14/0 | Two-worktree resolution rows R1-R14 |
| `tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1` | New | 12/0 | Sibling rows S2-1 to S2-12 |
| `tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1` | New | 12/0 | Layer 2 wiring rows H1-H12 |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Tests.ps1` | New | 20/0 | Port unit rows |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1` | New | 7/0 | Corpus parity rows, D1-D5 |
| `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` | Modified | 25/0 | Main hook suite (490 to 437 lines) |
| `tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1` | Modified | 17/0 | Dispatch; gained a `BeforeAll` mock only |
| `tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1` | Modified | 6/0 | Model routing; gained a `BeforeAll` mock only |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1` | Modified | 6/0 | Manifest registration (+1) |
| `tests/scripts/dev_tools/test_epic_wave_barrier_parity_corpus.py` | New | 30 nodes passed (pytest) | Corpus against the Python authority |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | Modified | Consumed by passing pytest suites | Pin digest re-baseline |
| `enforcement-hooks-no-python-invocation.Tests.ps1` | Unchanged (guard) | 27/0 | No-Python guard |

## Appendix B: Toolchain Commands Reference

Commands as recorded in the evidence files (`SCRATCH` denotes the out-of-repository scratch directory):

```text
# PowerShell formatting
mcp__drm-copilot__run_poshqc_format (scan_folders = .claude/hooks, .claude/lib/orchestrator-state, tests/scripts/claude-hooks, tests/scripts/claude-lib/orchestrator-state)
sh SCRATCH/run-ps.sh SCRATCH/ps-format-check.ps1 <PS-ALL: 13 files>

# PowerShell linting
mcp__drm-copilot__run_poshqc_analyze (same scan_folders)
sh SCRATCH/run-ps.sh SCRATCH/pssa-count.ps1 <PS-ALL: 13 files>

# PowerShell tests and coverage
mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root)
sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath <SET-HOOK list>,<port unit and parity suites> -CoveragePath <hook, sibling, port>
sh SCRATCH/run-ps.sh SCRATCH/changed-line-coverage.ps1 -BaseRef 497cb504ad9a4e5435dc8946333ebc28baea50c4 -File <hook, sibling, port>

# Python
poetry run black --check .
poetry run ruff check .
poetry run pyright
poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/py-coverage-final.json

# TypeScript lanes (no TypeScript file changed)
npm --prefix extensions/drm-copilot test -- test/lib/validate/epic-orchestrator-state-wave-barrier.test.ts
npm --prefix extensions/drm-copilot test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts

# Evidence locations
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```
