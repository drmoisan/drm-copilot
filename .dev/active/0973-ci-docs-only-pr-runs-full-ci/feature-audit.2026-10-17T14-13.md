# Feature Audit: CI change-scope merge-base fallback for docs-only pull requests (#973)

---

**Audit Date:** 2026-10-17
**Feature Folder:** `docs/features/active/2026-10-17-ci-docs-only-pr-runs-full-ci-973`
**Base Branch:** `main`
**Head Branch:** `bug/ci-docs-only-pr-runs-full-ci-973`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `18d6d1ccd455a280ca3b7a47ce4976f162e8803e`)
- **Head branch/commit:** `bug/ci-docs-only-pr-runs-full-ci-973` (commit `e1a6c90eaff39e5da86d46006a1b4459593f8c4f`)
- **Merge base:** `18d6d1ccd455a280ca3b7a47ce4976f162e8803e`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-17 14:08:57 UTC at head `e1a6c90ea`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-17-ci-docs-only-pr-runs-full-ci-973/evidence/**`
  - Additional evidence: direct inspection of `git diff 18d6d1cc..HEAD`, `artifacts/pester/powershell-coverage.xml`, `wc -l` of the changed PowerShell files, and sha256 of the six brief copies
- **Feature folder used:** `docs/features/active/2026-10-17-ci-docs-only-pr-runs-full-ci-973`
- **Requirements source:** `spec.md` (section `## Acceptance Criteria`)
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-bug`; the AC source is therefore `spec.md` only.
- **Scope note:** Full branch diff against `main`. No pull request exists yet, so CI status for the head commit is not available; the three CI-dependent or post-merge criteria are evaluated as pending.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-17-ci-docs-only-pr-runs-full-ci-973/spec.md` — only source

### Acceptance criteria

1. With no full green run, base ref `main`, and an all-allowlisted merge-base diff, the decision is `code=false` with log `code=false reason=DOCS_ONLY_SINCE_MERGE_BASE_<mb>` and summary `base=<mb>`, pinned by a row in `tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1`.
2. With base ref `main` and a merge-base diff containing one non-allowlisted path, the decision is `code=true reason=NON_ALLOWLISTED_PATH: <path>`, pinned by a row in the new test file.
3. A rename from a non-allowlisted path into an allowlisted path yields `code=true reason=NON_ALLOWLISTED_PATH:` on both the green-run diff and the merge-base diff, pinned by rows in `tests/scripts/ci/CiChangeScope.Tests.ps1` and the new test file.
4. A rename from an allowlisted path to a non-allowlisted path yields `code=true reason=NON_ALLOWLISTED_PATH:` on both the green-run diff and the merge-base diff, pinned by rows in `tests/scripts/ci/CiChangeScope.Tests.ps1` and the new test file.
5. A Markdown path under `docs/features/archive/` is accepted by `Test-CiDocsOnlyPath` with the committed config and reaches `DOCS_ONLY_SINCE_MERGE_BASE_<mb>` through the merge-base path.
6. A Markdown path under `docs/features/parallel/` is accepted by `Test-CiDocsOnlyPath` with the committed config and reaches `DOCS_ONLY_SINCE_MERGE_BASE_<mb>` through the merge-base path.
7. A Markdown path under `docs/features/epics/` is accepted by `Test-CiDocsOnlyPath` with the committed config and reaches `DOCS_ONLY_SINCE_MERGE_BASE_<mb>` through the merge-base path.
8. A blank `BASE_SHA` with base ref `main` and a fallback trigger yields `code=true reason=MERGE_BASE_UNRESOLVED` with summary `base=none`.
9. A non-zero `git cat-file -e <BASE_SHA>^{commit}` exit yields `code=true reason=MERGE_BASE_UNRESOLVED`.
10. A non-zero `git merge-base <BASE_SHA> <HEAD_SHA>` exit (rows for exit 1 and exit 128) yields `code=true reason=MERGE_BASE_UNRESOLVED`.
11. `git merge-base` output that is empty, multi-line, or not a full lower-case hex SHA yields `code=true reason=MERGE_BASE_UNRESOLVED`, and `ConvertFrom-CiMergeBaseOutput` returns `''` for each such input.
12. `BASE_NOT_PRESENT` and `BASE_NOT_ANCESTOR` primary reasons with base ref `main` fall back to the merge-base path, pinned by rows in the new test file.
13. With base ref `development` or `epic/x` and no green run, the decision stays `code=true reason=NO_FULL_GREEN_RUN` and no bare `git merge-base <a> <b>` call is made.
14. `RUN_LIST_FAILED` and `JOB_LIST_FAILED` with base ref `main` remain the final reasons with `code=true`, and no merge-base resolution call is made.
15. `push`, `merge_group`, `workflow_dispatch` and a fork pull request with `BaseRef=main` still decide `EVENT_NOT_PULL_REQUEST` or `FORK_PULL_REQUEST` before any gh or git invoker call, and every existing row in `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1` passes unmodified.
16. Step `scope` of job `changes` in `.github/workflows/ci.yml` carries `BASE_SHA: ${{ github.event.pull_request.base.sha }}` and `BASE_REF: ${{ github.base_ref }}`, and `tests/scripts/workflows/CiWorkflow.Tests.ps1` and `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` pass, including the updated event-field allowlist row and the new env-line row.
17. `config/ci-docs-only-paths.json` `include_prefixes` equals the ordinal list `docs/features/active/`, `docs/features/archive/`, `docs/features/completed/`, `docs/features/epics/`, `docs/features/parallel/`, `docs/features/potential/`, `docs/research/` with `exclude_prefixes` unchanged, pinned by the updated exact-string row in `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`.
18. The brief bullet `Change-scope decision (issue #962)` is updated with the merge-base fallback, its trigger reasons, the base-`main` restriction, every include prefix named in the `config/ci-docs-only-paths.json` criterion above, `MERGE_BASE_UNRESOLVED`, and two-sided rename classification, identically in every copy listed in `## Files to Be Written`, and `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` passes (including `test_brief_copies_are_byte_identical`).
19. The push-down resource contract tests `test_push_down_claude_resource_contracts.py` and `test_push_down_codex_and_agents_resource_contracts.py` pass after the brief edit.
20. `.github/workflows/README.md` change-scope section documents the fallback in `### Decision`, lists `DOCS_ONLY_SINCE_MERGE_BASE_<merge base sha>` and `MERGE_BASE_UNRESOLVED` in the reason-code list, lists every include prefix named in the `config/ci-docs-only-paths.json` criterion above in `### Allowlist`, and covers `MERGE_BASE_UNRESOLVED` and the base-`main` restriction in `### Fail-closed rules`.
21. `scripts/ci/CiChangeScope.psm1` and `scripts/ci/Invoke-CiChangeScope.ps1` each report line coverage >= 85% in `artifacts/pester/powershell-coverage.xml`, recorded under `<FEATURE>/evidence/qa-gates/`.
22. Every changed or new PowerShell file listed in `## Files to Be Written` is at most 500 physical lines.
23. At least three seeded shuffled file-order runs of the touched Pester suites pass with each seed recorded, and one fresh single-process run over `tests/scripts` passes, recorded under `<FEATURE>/evidence/regression-testing/`.
24. (CI-dependent, verified at S9) The first CI run on the item's pull request logs `code=true reason=NON_ALLOWLISTED_PATH:` (not `NO_FULL_GREEN_RUN`) in `Change scope` with summary `base=<merge base sha>`, `CI full run` succeeds, and every required context of ruleset 15241672 listed in the execution-environment brief reports success.
25. (CI-dependent, verified at S9) A later docs-only evidence commit on the item's pull request logs `code=false reason=DOCS_ONLY_SINCE_<green head sha>` in `Change scope`, and every required context of ruleset 15241672 listed in the execution-environment brief reports success.
26. (post-merge) The first docs-only pull request into `main` after merge (this feature folder's archive move) logs `code=false reason=DOCS_ONLY_SINCE_MERGE_BASE_<sha>` in `Change scope`, the heavy jobs are skipped, and every required context of ruleset 15241672 listed in the execution-environment brief reports success.

---

## Acceptance Criteria Evaluation

Abbreviations: `MB` = `tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1`; `CS` = `tests/scripts/ci/CiChangeScope.Tests.ps1`; `EV` = `docs/features/active/2026-10-17-ci-docs-only-pr-runs-full-ci-973/evidence`.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Docs-only merge-base skip | PASS | `MB` lines 115-123 assert exact log, output `code=false`, summary `base=<mb>` | `Invoke-PoshQCTest -ScanFolders tests/scripts/ci,tests/scripts/workflows` (`EV/qa-gates/ps-tests.2026-10-17T13-39.md`, 238/238) | Row failed before the change (`EV/regression-testing/fail-before.2026-10-17T13-27.md`). |
| 2 | One non-allowlisted path on merge-base diff | PASS | `MB` lines 125-132 | same | Exact reason `NON_ALLOWLISTED_PATH: scripts/ci/x.ps1`. |
| 3 | Rename into allowlist, both diffs | PASS | `CS` U5 `into` row (green-run); `MB` lines 134-145 `into` row | same | `--no-renames` two-sided listing modeled in both. |
| 4 | Rename out of allowlist, both diffs | PASS | `CS` U5 `out of` row; `MB` `out of` row | same | |
| 5 | `docs/features/archive/` prefix | PASS | `CS` U4 row; `MB` M4 row with `-OmitConfigJson` (committed config); `CiDocsOnlyPathsConfig.Tests.ps1` per-prefix row | same | U4 uses a local seven-prefix config; the committed-config path is pinned by M4 and the config rows. |
| 6 | `docs/features/parallel/` prefix | PASS | same three rows for `parallel` | same | |
| 7 | `docs/features/epics/` prefix | PASS | same three rows for `epics` | same | |
| 8 | Blank `BASE_SHA` gives `MERGE_BASE_UNRESOLVED`, `base=none` | PASS | `MB` M5 `BASE_SHA is blank` row asserts log and summary suffix `base=none` | same | Also asserts no diff call. |
| 9 | `cat-file` non-zero | PASS | `MB` M5 `git cat-file exits 128` row | same | |
| 10 | `merge-base` exit 1 and 128 | PASS | `MB` M5 two rows | same | |
| 11 | Invalid merge-base output | PASS | `MB` M5 empty, non-SHA, two-line rows; `CS` U3 eight rejected forms return `''` | same | Upper-case and short forms covered in U3. |
| 12 | `BASE_NOT_PRESENT` / `BASE_NOT_ANCESTOR` fall back | PASS | `MB` lines 181-193 | same | Both reach `DOCS_ONLY_SINCE_MERGE_BASE_<mb>`. |
| 13 | Non-main base keeps `NO_FULL_GREEN_RUN`, no bare merge-base call | PASS | `MB` lines 195-206 | same | Call record filtered by `Get-TestBareMergeBaseCall`. |
| 14 | `RUN_LIST_FAILED` / `JOB_LIST_FAILED` terminal | PASS | `MB` lines 208-220 assert zero git calls | same | |
| 15 | Event and fork gates before any invoker call; existing rows unmodified | PASS | `MB` lines 247-261; `git diff --exit-code MB -- tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1` exit 0 | `git diff --name-only 18d6d1cc..HEAD` (file absent from list, verified by this review); `EV/regression-testing/pass-after.2026-10-17T13-33.md` | |
| 16 | `ci.yml` env lines and workflow tests | PASS | Diff shows both lines on step `scope`; `CiChangeScopeWorkflow.Tests.ps1` new row; `CiWorkflow.Tests.ps1` allowlist updated | `git diff 18d6d1cc..HEAD -- .github/workflows/ci.yml`; Pester run above | actionlint 0 findings (`EV/qa-gates/actionlint.2026-10-17T13-40.md`). |
| 17 | Seven-prefix ordinal list | PASS | `config/ci-docs-only-paths.json` diff; exact-string row in `CiDocsOnlyPathsConfig.Tests.ps1` | `git diff 18d6d1cc..HEAD -- config/ci-docs-only-paths.json` | `exclude_prefixes` untouched in diff. |
| 18 | Brief bullet updated identically in six copies | PASS | Bullet text inspected in diff; sha256 of all six copies share prefix `052d873ce29473a9`; `test_brief_copies_are_byte_identical` passed | `sha256sum` over the six paths; `EV/qa-gates/python-contract-tests.2026-10-17T13-57.md` (18 passed) | Contains fallback, three trigger reasons, base `main`, seven prefixes, `MERGE_BASE_UNRESOLVED`, rename sentence. |
| 19 | Push-down contract tests pass | PASS | 14 passed and 9 passed, 0 failed | `poetry run pytest tests/scripts/dev_tools/test_push_down_*_resource_contracts.py -q --no-cov` (`EV/qa-gates/python-contract-tests.2026-10-17T13-57.md`) | |
| 20 | Workflows README section | PASS | Diff shows fallback paragraph, both new reason codes, seven prefixes in `### Allowlist`, `MERGE_BASE_UNRESOLVED` and base-ref condition in `### Fail-closed rules` | `git diff 18d6d1cc..HEAD -- .github/workflows/README.md` | Fallback paragraph sits directly under the `### Decision` text. |
| 21 | Line coverage >= 85% for both files | PASS | 131/140 = 93.57% and 103/113 = 91.15% in `artifacts/pester/powershell-coverage.xml` class counters (verified by this review); `EV/qa-gates/ps-tests.2026-10-17T13-39.md` | Grep of `<counter type="LINE"` at the two class entries | Changed-line coverage 100% (`EV/qa-gates/coverage-delta.2026-10-17T13-39.md`). |
| 22 | All changed/new PowerShell files <= 500 lines | PASS | 395, 365, 389, 110, 272, 258, 340 | `wc -l` (rerun by this review) | |
| 23 | Three seeded shuffles and one full run | PASS | Seeds 973, 9731, 97301 at 208/208; full run 11271 passed, 0 failed | `EV/regression-testing/isolation-shuffle-seed-*.md`; `EV/regression-testing/ps-tests-full-run.2026-10-17T13-56.md` | |
| 24 | First PR CI run logs `NON_ALLOWLISTED_PATH:` with merge-base summary | UNVERIFIED | No pull request exists yet; CI status at head is not available (`artifacts/pr_context.summary.txt`, `CI status (HEAD)`) | `gh run view <run> --log` at S9 | CI-dependent; owned by the item's orchestrator at S9. Not a review blocker. |
| 25 | Later docs-only commit logs `DOCS_ONLY_SINCE_<green head sha>` | UNVERIFIED | Same as 24 | `gh run view <run> --log` at S9 | CI-dependent; owned by S9. |
| 26 | Post-merge archive-move pull request skips heavy jobs | UNVERIFIED | Requires merge to `main` | `gh run view` on the archive-move pull request | Post-merge by definition. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 23 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 3 criteria (two CI-dependent at S9, one post-merge; none can be evaluated before a pull request exists)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None. The three unverified criteria are pending-CI or post-merge by spec design (D8) and are not delivery gaps in the branch.

**Recommended follow-up verification steps:**

1. At S9, read the `Change scope` log of the first pull-request run and confirm `code=true reason=NON_ALLOWLISTED_PATH:` with summary `base=<merge base sha>` and all 11 required contexts successful; then push a docs-only evidence commit and confirm `code=false reason=DOCS_ONLY_SINCE_<green head sha>`.
2. After merge, confirm the archive-move pull request logs `DOCS_ONLY_SINCE_MERGE_BASE_<sha>` and that the `main` push run after the merge ran in full (spec D6).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria 1 to 23 evaluated as PASS were already checked (`- [x]`) in `spec.md` by the executor; no source-file change was needed by this review.
- Criteria 24 to 26 evaluated as UNVERIFIED remain unchecked. Criteria 24 and 25 are CI-dependent and are checked off by the item's own orchestrator run at S9; criterion 26 is post-merge.

### AC Status Summary

- Source: `docs/features/active/2026-10-17-ci-docs-only-pr-runs-full-ci-973/spec.md`
- Total AC items: 26
- Checked off (delivered): 23
- Remaining (unchecked): 3
- Items remaining:
  - (CI-dependent, verified at S9) The first CI run on the item's pull request logs `code=true reason=NON_ALLOWLISTED_PATH:` (not `NO_FULL_GREEN_RUN`) in `Change scope` with summary `base=<merge base sha>`, `CI full run` succeeds, and every required context of ruleset 15241672 listed in the execution-environment brief reports success.
  - (CI-dependent, verified at S9) A later docs-only evidence commit on the item's pull request logs `code=false reason=DOCS_ONLY_SINCE_<green head sha>` in `Change scope`, and every required context of ruleset 15241672 listed in the execution-environment brief reports success.
  - (post-merge) The first docs-only pull request into `main` after merge (this feature folder's archive move) logs `code=false reason=DOCS_ONLY_SINCE_MERGE_BASE_<sha>` in `Change scope`, the heavy jobs are skipped, and every required context of ruleset 15241672 listed in the execution-environment brief reports success.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-10-17-ci-docs-only-pr-runs-full-ci-973/spec.md` | 26 | 23 | 3 | Checkbox-backed; no source-file change made by this review because every PASS item was already checked. |
