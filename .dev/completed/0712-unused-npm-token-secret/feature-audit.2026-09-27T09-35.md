# Feature Audit: unused-npm-token-secret (#712)

---

**Audit Date:** 2026-09-27
**Feature Folder:** `docs/features/active/unused-npm-token-secret-712`
**Base Branch:** `origin/main`
**Head Branch:** `bug/unused-npm-token-secret-712`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `91cffc3b`)
- **Head branch/commit:** `bug/unused-npm-token-secret-712` (commit `bf4dc2b103d04cebc615238c60834573eb53bbfe`)
- **Merge base:** `91cffc3bc1794336069649c39132a6c704416eec` (2026-09-27 09:09:58 -0400)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (regenerated 2026-09-27 13:30:02 UTC, `Head SHA: bf4dc2b1...`, range `91cffc3b..bf4dc2b1`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` (same generation)
  - Feature evidence: `docs/features/active/unused-npm-token-secret-712/evidence/**` (36 executor files plus `evidence/qa-gates/ci-python-full-suite.2026-09-27T09-35.md` recorded by this review)
  - Additional evidence: reviewer check-only runs (Black, Ruff, Pyright, guard pytest, `git grep`, `git diff`), a regex probe run from the session scratchpad, and CI run https://github.com/drmoisan/drm-copilot/actions/runs/36322316826 job step conclusions
- **Feature folder used:** `docs/features/active/unused-npm-token-secret-712`
- **Requirements source:** `spec.md` (AC1-AC4)
- **Work mode resolution note:** `issue.md` line 9 carries `- Work Mode: full-bug`. `issue.md` line 11 notes that the GitHub issue body carried `minor-audit` and that the orchestration kickoff selected `full-bug` as the persisted mode. The persisted marker governs, so `spec.md` is the only AC source.
- **Scope note:** full `origin/main...HEAD` diff, 43 files (1 Python test module, 42 Markdown files). Operator approval supplied 2026-09-26 covers spec decisions D1-D6 and planner decisions P1-P6. The CI run was `in_progress` overall at review time; its four Python quality-check jobs had completed with success.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/unused-npm-token-secret-712/spec.md` — only source (`full-bug`)

### Acceptance criteria

1. AC1. No file under `.github/` (which includes every file under `.github/workflows/`) references the `NPM_TOKEN` secret, verified by the repository check `git grep -n NPM_TOKEN -- .github` exiting with code `1` and printing no output, run on this branch after all changes; the command, output, and exit code are recorded in `docs/features/active/unused-npm-token-secret-712/evidence/baseline/ac1-github-npm-token-grep.<ts>.md`. No file under `.github/` is modified by this change (verified by `git diff --name-only origin/main...HEAD -- .github` producing no output). (Maps issue AC1.)
2. AC2. The guard test `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` exists, and `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q` passes on the current tree, including the nodes `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_reference_no_npm_token_secret`, `::test_github_yaml_files_reference_no_node_auth_token`, and `::test_github_yaml_enumeration_is_non_vacuous`. The parametrized node `::test_find_npm_token_references_detects_reintroduced_reference` passes for every positive case, demonstrating that the helper used by the tree scan reports a reintroduced `secrets.NPM_TOKEN` or `secrets['NPM_TOKEN']` reference; `::test_find_node_auth_token_references_detects_reference` demonstrates the same for `NODE_AUTH_TOKEN` (D3). The test uses no temporary files, git subprocess, network, `origin/main`, gitignored input, or Windows-specific path, and resolves the repository root from its own file location. Black, Ruff, and Pyright report no findings for the file, and the full pytest suite meets the existing coverage thresholds; results are recorded under `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/` and `docs/features/active/unused-npm-token-secret-712/evidence/regression-testing/`. (Maps issue AC2.)
3. AC3. `docs/engineering/npm-token-rotation.runbook.md` is retained with its superseded notice, and that notice line contains exactly one occurrence of the sentence "The unused `NPM_TOKEN` repository secret is being removed under issue #712." The file is otherwise unchanged (verified by `git diff origin/main...HEAD -- docs/engineering/npm-token-rotation.runbook.md` showing a single changed line). `docs/research/2026-05-04-publish-mcp-server-to-npm-research.md` and `README.md` are unchanged. (Maps issue AC3; decision D4.)
4. AC4. The human-exception runbook `docs/features/active/unused-npm-token-secret-712/runbooks/delete-unused-npm-token-secret.runbook.md` exists and covers deletion of the `NPM_TOKEN` repository secret and revocation of the corresponding npm access token, and the human action is recorded as pending in `docs/features/active/unused-npm-token-secret-712/evidence/other/human-action-pending.<ts>.md` (status `pending`, runbook path, no credential data). Completion of the human action is not required to check off this criterion (D5). (Maps issue AC4.)

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC1 — no `NPM_TOKEN` reference under `.github/`; no `.github/` file modified | PASS | Reviewer run at `bf4dc2b1`: `git grep` exit 1, no output; `.github` diff empty. Recorded post-change in `evidence/baseline/ac1-github-npm-token-grep.2026-09-27T09-22.md` (EXIT_CODE 1) and `evidence/qa-gates/ac1-github-unmodified.2026-09-27T09-22.md`. | `git grep -n NPM_TOKEN -- .github`; `git diff --name-only origin/main...HEAD -- .github` | The executor evidence was captured at `1e573760`; the only later commit (`bf4dc2b1`) touches feature-folder Markdown only, and the reviewer re-ran both checks at `bf4dc2b1`. |
| 2 | AC2 — guard exists and passes; constraints; Black/Ruff/Pyright clean; full suite meets coverage thresholds; results recorded | PASS | Guard: reviewer `17 passed`; per-node PASSED list in `evidence/regression-testing/guard-detection.2026-09-27T09-17.md` covers all three named tree-scan nodes, all 5 `detects_reintroduced_reference` cases, and both `detects_reference` cases. Constraints: module has no temp-file, subprocess, network, git, or `origin/main` use (reviewer inspection and `evidence/regression-testing/guard-constraint-scan.2026-09-27T09-17.md`); root from `Path(__file__).resolve().parents[3]`; POSIX-relative comparisons. Black/Ruff/Pyright: reviewer check-only runs clean; `evidence/qa-gates/final-{black,ruff,pyright}.*.md`. Full suite and thresholds: local threshold gate EXIT_CODE 0 at 92.97% line / 85.68% branch (`evidence/qa-gates/final-coverage-thresholds.2026-09-27T09-21.md`); CI Linux full suite and threshold steps `success` on Python 3.10-3.13 at `bf4dc2b1` (`evidence/qa-gates/ci-python-full-suite.2026-09-27T09-35.md`). | `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q`; `poetry run black --check <file>`; `poetry run ruff check --no-fix <file>`; `poetry run pyright <file>`; `gh api repos/drmoisan/drm-copilot/actions/jobs/<job-id>` | The local full suite has one failure, `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`. The reviewer verified it as pre-existing and environmental (open issue #510): the asserted path is a gitignored `.claude/state/` hook file (`.gitignore:68`), the branch changes no file under `.claude/`, `extensions/`, or that test, and the same node passes on the fresh Linux CI checkout. It is not a defect of this change. The CI record was written by this review; the step log text was not yet retrievable because the overall run was still in progress. |
| 3 | AC3 — runbook notice carries the #712 sentence once; single-line change; README and research record unchanged | PASS | `git diff` shows one changed line (line 3) with the exact sentence appended after "Retained for historical reference only."; `evidence/qa-gates/ac3-runbook-single-line.2026-09-27T09-23.md` (`1 1`), `evidence/other/runbook-sentence-occurrence.2026-09-27T09-18.md`, `evidence/qa-gates/ac3-unchanged-files.2026-09-27T09-23.md`. | `git diff origin/main...HEAD -- docs/engineering/npm-token-rotation.runbook.md`; `git diff --name-only origin/main...HEAD -- README.md docs/research/2026-05-04-publish-mcp-server-to-npm-research.md` | Reviewer re-inspected the diff at `bf4dc2b1`. |
| 4 | AC4 — human-exception runbook exists and covers both actions; action recorded as pending without credential data | PASS | Runbook (148 lines) has "Part 1" (delete `NPM_TOKEN`, `gh secret delete` path and UI path) and "Part 2 — Identify and revoke the matching npm access token"; `evidence/other/human-action-pending.2026-09-27T09-19.md` has `Status: pending`, the runbook path, and `CredentialData: none recorded`; token-shape scan of the feature folder exits 1. | `grep -n -i -E "gh secret\|revoke" <runbook>`; `git grep -n -E "npm_[A-Za-z0-9]{30,}" -- docs/features/active/unused-npm-token-secret-712` | Satisfied at the pending stage per D5 (operator-approved). The secret deletion and token revocation are operator-owned and not required. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 4 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Orchestrator: confirm CI run 36322316826 completes with all jobs green, and reconcile plan tasks P5-T5, P5-T7, P5-T8, P6-T3, and P6-T8 against `evidence/qa-gates/ci-python-full-suite.2026-09-27T09-35.md`.
2. Operator (non-blocking, outside this branch): execute `runbooks/delete-unused-npm-token-secret.runbook.md`, comment on issue #712, and update `evidence/other/human-action-pending.2026-09-27T09-19.md` to complete.
3. Non-blocking follow-ups from the code review: widen the guard to `_authToken` / `npm_config_*authtoken` shapes, add spaced and lowercase bracket parametrized cases, correct the "tracked files" docstring wording, and fix the feature runbook's AC4 recording step (it points to `issue.md`).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

Newly checked off by this review: AC2 in `docs/features/active/unused-npm-token-secret-712/spec.md` (`- [ ] AC2.` changed to `- [x] AC2.`; criterion text unchanged). AC1, AC3, and AC4 were already checked at `bf4dc2b1` and were re-verified as PASS.

### AC Status Summary

- Source: `docs/features/active/unused-npm-token-secret-712/spec.md`
- Total AC items: 4
- Checked off (delivered): 4
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/unused-npm-token-secret-712/spec.md` | 4 | 4 | 0 | Checkbox-backed; AC2 checked by this review |
