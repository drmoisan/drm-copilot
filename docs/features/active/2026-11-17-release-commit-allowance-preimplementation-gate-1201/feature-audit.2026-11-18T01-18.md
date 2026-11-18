# Feature Audit: Release-commit allowance leg of the preimplementation gates (#1201)

---

**Audit Date:** 2026-11-18
**Feature Folder:** `docs/features/active/2026-11-17-release-commit-allowance-preimplementation-gate-1201`
**Base Branch:** `main`
**Head Branch:** `bug/release-commit-allowance-gate`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review (concurrent with CI on PR #1202)

---

## Scope and Baseline

- **Base branch:** `main` (commit `1b9e5746eaa5e32366de695e3f511dbc28700b08`)
- **Head branch/commit:** `bug/release-commit-allowance-gate` (commit `89d0e58610eac3b66504ca2ba27a6d22a8f15312`)
- **Merge base:** `1b9e5746eaa5e32366de695e3f511dbc28700b08` (equal to `origin/main` after a fetch; 0 commits of base drift; `git merge-tree` reports no conflict)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (head SHA `89d0e586...`, matches the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-11-17-release-commit-allowance-preimplementation-gate-1201/evidence/**`
  - Additional evidence: `artifacts/pester/powershell-coverage.xml`, `artifacts/pester/pester-junit.xml`, `artifacts/python/lcov.info`, `coverage/lcov.info` (reviewer Jest run, `evidence/qa-gates/jest-gate.2026-11-18T01-22.md`), and reviewer in-process probes of the decision function
- **Feature folder used:** `docs/features/active/2026-11-17-release-commit-allowance-preimplementation-gate-1201`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`, so `spec.md` is the only AC source.
- **Scope note:** Full branch diff against the merge base (73 files). CI on the PR head was in progress at review time; AC-31 depends on it.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-17-release-commit-allowance-preimplementation-gate-1201/spec.md` — only source

### Acceptance criteria

The 32 criteria are the checkbox items AC-1 to AC-32 under `## Acceptance Criteria` in `spec.md`, grouped there as Configuration and parser (AC-1 to AC-3), Absent file and decline paths (AC-4 to AC-7), Allowed paths (AC-8 to AC-11), Denials (AC-12 to AC-20), Wiring, parity, and manifests (AC-21 to AC-23), Push-down (AC-24 to AC-26), Documentation (AC-27 to AC-29), and Quality gates (AC-30 to AC-32). The evaluation table below abbreviates each criterion; the source text is authoritative.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| AC-1 | `ConvertFrom-ReleaseAllowanceConfig` valid example and 28 invalid rows with offending key or entry | PASS | `hook-release-allowance-context.Tests.ps1` (314 tests, 0 failures, both surfaces); parser lines 186-240 read | JUnit testsuite counts in `artifacts/pester/pester-junit.xml` | Detail strings name the key or entry. |
| AC-2 | Branch matching: case-sensitive, whole-name, `?` single character | PASS | Same suite; `WildcardPattern` with `WildcardOptions::None` (line 258) | Code read | |
| AC-3 | Config seam returns `$null`/text/throws; container seam returns `Test-Path -PathType Container` | PASS | `enforce-orchestration-preimplementation-gate-release.Tests.ps1` config seam (4) and container seam (2) contexts, both surfaces | JUnit (44 tests, 0 failures) | |
| AC-4 | Absent file keeps generic deny text and zero branch, staged, container calls | PASS | Rows `AC4-add-absent`, `AC4-commit-absent` with `-Times 0 -Exactly`, both gates | JUnit (102 + 102, 0 failures) | |
| AC-5 | Blank, `*** Begin Patch`, Write path, empty checkpoint path decline with zero config reads | PASS | Seam suite decline rows (5) and decision rows `AC5-write-path`, `AC5-injected-checkpoint` | JUnit | |
| AC-6 | No `git add`/`git commit` segment: generic text, zero config reads | PASS | Row `AC6-no-git-segment`; probe `GIT_DIR=x git add package.json` also not relevant | Reviewer probe | |
| AC-7 | No pre-existing test file under `tests/scripts/claude-hooks` or `tests/scripts/codex-hooks` modified | PASS | `git diff --name-status <merge-base>..HEAD -- tests extensions/drm-copilot/test` lists only `A` entries (7 files); full Pester run 0 failures | `git -C <worktree> diff --name-status 1b9e5746..HEAD -- tests extensions/drm-copilot/test` | |
| AC-8 | Allowed `git add` forms including `git -C <R> add` | PASS | Rows `AC8-*` (6) allow on both gates | JUnit | |
| AC-9 | Allowed `git commit` forms (7 listed) | PASS | Rows `AC9-*` (8) allow | JUnit | |
| AC-10 | Add-then-commit union with empty staged index | PASS | Row `AC10-add-then-commit`, staged index read once | JUnit | |
| AC-11 | Single-allowance rule across two allowances | PASS | Rows `AC11-*` (3) including the split deny with `RELEASE_ALLOWANCE_STAGED_PATH_NOT_ALLOWED` | JUnit | |
| AC-12 | `RELEASE_ALLOWANCE_CONFIG_INVALID` for throw, invalid document, directory entry; suffix last | PASS | Rows `AC12-*` (5) including `AC12-suffix-after-bookkeeping` | JUnit | |
| AC-13 | `RELEASE_ALLOWANCE_COMMAND_NOT_MODELLED` rows | PASS | Rows `AC13-*` (8); reviewer probe adds newline, `#`, `2>`, and pipe forms, all denied | JUnit; reviewer probe | |
| AC-14 | `RELEASE_ALLOWANCE_BRANCH_NOT_MATCHED` for detached and unmatched; zero staged reads | PASS | Rows `AC14-*` (2) | JUnit | |
| AC-15 | `RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED` for each listed option | PASS | Rows `AC15-*` (42), covering every listed form plus separate-value global options, attached `-C`, `--bare`, `-p`, `--no-pager` | JUnit | Case-insensitive `-C` comparison per AD-5 recorded as a Minor code-review finding. |
| AC-16 | `RELEASE_ALLOWANCE_PATH_NOT_ALLOWED` rows | PASS | Rows `AC16-*` (12) | JUnit | |
| AC-17 | Staged path, empty, and unreadable codes | PASS | Rows `AC17-*` (5) | JUnit | |
| AC-18 | Unexpandable `-C` keeps `TARGET_WORKTREE_NOT_DERIVABLE` with no release suffix | PASS | Row `AC18-unexpandable-C` through the unmocked resolver | JUnit | |
| AC-19 | First failure in evaluation order, exactly one suffix | PASS | Rows `AC19-*` (3) with `OneSuffix` | JUnit | |
| AC-20 | Unexpected seam throw: `Allowed $false`, empty suffix, `PREIMPL_RELEASE_LEG_ERROR` debug | PASS | Seam suite rows for branch-reader and staged-reader throw | JUnit | |
| AC-21 | One guarded dot-source, one leg call after the last leg, `$release.DenySuffix` last; bundles byte-identical | PASS | Diff of both gates read; `cmp` of each bundle gate with its source; parity suite and dependency-guard completeness suite passed | `cmp`; JUnit | |
| AC-22 | SHA-256 identity across four roots; new files under 500 lines; Codex gate at or under 500 | PASS | One unique hash per file set (reviewer `sha256sum`); 495 and 166 lines; Codex gate 487 lines in repository and bundle | `sha256sum`; logical line count | |
| AC-23 | Both core manifests list both files; manifest and resource-contract pytest suites pass; codex variant check no drift | PASS | Manifest diffs read; `final-qc-pytest` 16957 passed, 0 failed; `generate_codex_agent_variants --check` exit 0 | `evidence/qa-gates/final-qc-pytest.2026-11-18T01-10.md`, `final-qc-static-python.2026-11-18T00-51.md` | |
| AC-24 | No manifest lists the allowance file; file absent from repository and bundles | PASS | `grep` of all `pack-manifests` returned no match; `git ls-files` count 0; no file at `.claude/release-commit-allowance.json` | `grep`, `git ls-files` | |
| AC-25 | Both `EXCLUDED_RELATIVE_PATHS` contain the path | PASS | Diffs of `claude-customizations.ts` and `push_down_claude_customizations.py`; Jest test and parity suite | Jest root run 5717 passed | |
| AC-26 | Push-down with no packs and with `core` leaves destination byte-identical and omits the path | PASS | `claude-customizations-release-allowance.test.ts` (2 tests) | `node run-jest.cjs --coverage` | |
| AC-27 | Execution-environment bullet and contract-test entries in six byte-identical copies | PASS | One unique SHA-256 across the six copies; bullet names the file, both codes, and the single-quote or `-F` guidance; both tests listed | `sha256sum` | |
| AC-28 | Orchestrate paragraph and orchestrator-state section; sources equal bundles | PASS | Diffs read; `cmp` of both pairs | `cmp` | |
| AC-29 | CHANGELOG `[Unreleased]`/`Added` entry | PASS | Diff of `extensions/drm-copilot/CHANGELOG.md` names the file, the refresh-after-release delivery, and opt-in by committing the file | `git diff` | |
| AC-30 | Both new files >= 85% line coverage; Jest thresholds pass | PASS | JaCoCo per-file 171/171 and 32/32 per copy (100%); Jest coverageThreshold map passed in the executor run and the reviewer root run | Reviewer parse of `artifacts/pester/powershell-coverage.xml` | Coverage file written after the last code commit. |
| AC-31 | Full toolchain loop in one pass and CI green on the PR head | UNVERIFIED | Local loop clean per `evidence/qa-gates/final-qc-*`; CI on PR #1202 pending at review time | `ci_gate.conclusion` at S9 | Pending-CI; not a blocking finding. Checked off at S9 by the item orchestrator. |
| AC-32 | No hook invokes Python; no new Python module or test | PASS | `grep -i "python\|poetry"` on both new files returned no match; branch file list holds no new `.py` file | `grep`; `git diff --name-status` | |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 31 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (AC-31, pending CI)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None. AC-31 awaits CI on PR #1202 and is checked off at S9.

**Recommended follow-up verification steps:**

1. At S9, confirm `CI Required Gate` and `CI full run` are green at head `89d0e58610eac3b66504ca2ba27a6d22a8f15312` (or the final head) and check off AC-31.
2. When adapting the leg for epic #1018, revisit the case-insensitive `-C` comparison on case-sensitive file systems (code-review Minor finding).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

AC-1 to AC-30 and AC-32 were already checked in `spec.md` by the executor; the review confirmed each as PASS, so no source-file change was needed. AC-31 remains unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-11-17-release-commit-allowance-preimplementation-gate-1201/spec.md`
- Total AC items: 32
- Checked off (delivered): 31
- Remaining (unchecked): 1
- Items remaining: AC-31 (full toolchain loop in parallel form and CI on the PR head green; CI-dependent, checked off at S9)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 32 | 31 | 1 | Checkbox-backed; AC-31 pending CI |
