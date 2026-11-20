# Feature Audit: epic-child-prs-trigger-no-ci (#658)

---

**Audit Date:** 2026-10-08 (artifact timestamp `2026-10-08T03-15` supplied by the delegating orchestrator)
**Feature Folder:** `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658`
**Base Branch:** `origin/main`
**Head Branch:** `bug/epic-child-prs-trigger-no-ci-658`
**Work Mode:** `minor-audit`
**Audit Type:** Re-audit (pass 2) after the AWAITING_CI wait branch. Prior audit: `feature-audit.2026-10-08T02-50.md`. Every criterion was re-verified independently at the current head; no pass-1 verdict was copied.

---

## Scope and Baseline

- **Base branch:** `origin/main`. The diff anchor is merge-base `08ee030d9584bf15882fbb3654c8e38f34c7c359`. `origin/main` is at `6c3649b07322374035df8c11996f4d64a043e138` (PR #835), which touches none of the changed paths.
- **Head branch/commit:** `bug/epic-child-prs-trigger-no-ci-658` at `54d4ee3ab799b1b7bd6ef5cccfdb8420eaa7c60c`. `git ls-remote origin` reports the same SHA.
- **Merge base:** `08ee030d9584bf15882fbb3654c8e38f34c7c359`
- **Evidence sources:**
  - Primary: `git diff 08ee030d...HEAD` (55 files: 5 production or test, 50 feature-folder), read directly
  - Secondary baseline diff: per-commit `git show --stat`, plus `git diff --name-only` between the relevant heads
  - Feature evidence: `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/evidence/**`
  - Additional evidence: `gh run list`, `gh run view` (run fields and the poshqc job log), `gh run download` (coverage XML to the session scratchpad), `gh pr list`; local check-only commands (actionlint, `cmp`, pytest consumer suites, evidence-location validator)
- **Feature folder used:** `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658`
- **Requirements source:** `issue.md` only (`## Acceptance Criteria`, AC-1 through AC-7)
- **Work mode resolution note:** explicit marker `- Work Mode: minor-audit` at `issue.md` line 12. `spec.md` and `user-story.md` are absent, as expected for minor-audit.
- **Changes since pass 1:** commits `dd3fc879` (pass-1 review artifacts) and `54d4ee3a` (`evidence/qa-gates/ac7-ci-green-run.2026-10-08T02-55.md` and an `ac-status-summary` pointer update). All of these paths are inside the feature folder.
- **Scope note:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are absent. They were not regenerated, because writes are restricted to the feature folder. The full branch diff was read directly.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/issue.md`: only source (minor-audit)

### Acceptance criteria

1. AC-1: `.github/workflows/ci.yml` `on.pull_request.branches` lists `main`, `development`, and `"epic/**"`, and `on.push.branches` remains exactly `[main, development]`.
2. AC-2: `.github/workflows/README.md` documents the `ci.yml` `pull_request` trigger branches, names `epic/**`, and states the epic-child reason.
3. AC-3: `.claude/skills/orchestrate/SKILL.md` S9 text rejects an empty check list for PRs based on `epic/<slug>-integration`, requires at least one `CI` check on the child head SHA, and requires every observed `CI` check to succeed.
4. AC-4: New Pester 5 suite `tests/scripts/workflows/CiWorkflow.Tests.ps1` parses `ci.yml` as text (no YAML module, process, or temporary file) and asserts the `pull_request` list; a failing run on the pre-fix file and a passing run on the fixed file are recorded under `evidence/`.
5. AC-5: `actionlint` reports no findings for `.github/workflows/ci.yml`.
6. AC-6: The bundle mirror of the orchestrate skill is byte-identical; the bundle-parity pytest passes.
7. AC-7: `modified-workflow-needs-green-run` is satisfied: a `CI` run on the fix branch head concluded `success`, recorded at PR time with run id, head SHA, and conclusion.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1: `pull_request` branches include `main`, `development`, `"epic/**"`; `push` stays `[main, development]` | PASS | `ci.yml` line 5 `branches: [main, development]`, line 7 `branches: [main, development, "epic/**"]` (read at `54d4ee3a`). The `push` test passes in CI job 113123796488 (no `[-]` line; per-file `[+]` at log line 1260). | `head -12 .github/workflows/ci.yml`; `git diff --stat 08ee030d...HEAD -- . ":!<feature folder>"` (ci.yml `2 +-`) | One-line change; push filter unchanged. |
| 2 | AC-2: README documents trigger branches, names `epic/**`, states the reason | PASS | README line 8 `## Triggers`; line 13 `pull_request into main, development, and epic/**`; line 16 names `epic/<slug>-integration`, "run the full CI gate", and issue #658 (read at `54d4ee3a`). | `sed -n 1,18p .github/workflows/README.md` | Also satisfies the github-actions requirement to document intentional trigger changes. |
| 3 | AC-3: S9 rejects an empty check list for epic-integration-based PRs; requires at least one `CI` check on the child head SHA and every observed `CI` check succeeding | PASS | `orchestrate/SKILL.md` line 291 (read at `54d4ee3a`) contains: base `epic/<slug>-integration` (`epic_mode` true); "An empty check list, including an empty `gh pr checks --required` result, is not accepted as green"; "at least one check whose `workflow` is `CI` against the child head SHA"; "every observed `CI` check must succeed". | `grep -n "Epic-child rule" .claude/skills/orchestrate/SKILL.md` | Text criterion met. Mechanical enforcement by the parser is out of scope (code-review CR-1, Non-blocking). |
| 4 | AC-4: Pester 5 text-parsing suite with recorded fail-before and pass-after | PASS | Suite re-read at `54d4ee3a`: `on:`-block isolation (lines 23-40), no YAML module, process, or temporary file. Fail-before: run 37715960709 on `632fe595`, conclusion `failure` (`gh run list`); `git show --stat 632fe595` shows `ci.yml` unmodified; recorded failure at test line 161. Pass-after: run 37717224700 on `8a1b9b8b` (recorded), reproduced by this review in run 37719545156 job 113123796488 (log line 1260 `[+]`, line 1265 `Tests Passed: 6521, Failed: 0`). | `git show --stat 632fe595`; `gh run list --branch bug/epic-child-prs-trigger-no-ci-658 --workflow CI`; `gh run view --job 113123796488 --log` | DEV-CI-FAILBEFORE, DEV-CI-PASSAFTER, and DEV-CI-BASELINE are acceptable (policy-audit Section 8). |
| 5 | AC-5: actionlint reports no findings for `ci.yml` | PASS | This review: `actionlint .github/workflows/ci.yml` produced no output, actionlint 1.7.11, at `54d4ee3a`. Executor record: `evidence/qa-gates/final-actionlint.2026-10-08T02-30.md`. | `actionlint .github/workflows/ci.yml`; `actionlint -version` | Route differs from the named wrapper (DEV-ACTIONLINT-DIRECT, acceptable). The criterion of zero findings is met. |
| 6 | AC-6: bundle mirror byte-identical; bundle-parity pytest passes | PASS | This review: `cmp` exit 0; 39 passed in 0.32s across the four consumer suites, including `test_push_down_claude_resource_contracts.py`. | `cmp .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py ... -q -p no:cacheprovider` | DEV-NONPS-COPY is acceptable. Issue #510 condition not observed. |
| 7 | AC-7: `CI` run on the fix branch head concluded `success`, recorded with run id, head SHA, and conclusion | PASS | `evidence/qa-gates/ac7-ci-green-run.2026-10-08T02-55.md`: run 37719545156, head `dd3fc879`, event `workflow_dispatch`, conclusion `success`, 17/17 jobs. Independently confirmed by this review with `gh run view 37719545156`. `git merge-base --is-ancestor 00798863 dd3fc879` succeeds. `git log 00798863..HEAD -- . ":!<feature folder>"` is empty. `git diff --name-only dd3fc879 HEAD` lists two feature-folder files only. | `gh run view 37719545156 --json databaseId,headSha,conclusion,event,workflowName,jobs`; `git merge-base --is-ancestor 00798863 dd3fc879`; `git diff --name-only dd3fc879 HEAD` | Judged under the orchestrator ruling. The recorded run covers the latest head containing any non-feature-folder change, every later commit is feature-folder-only, and the S9 obligation is stated: `orchestrate/SKILL.md` lines 295, 298, and 300 require `ci_gate.head_sha` to equal the final PR head with `conclusion == success` before DONE and merge. No PR exists yet, so S9 is pending. There is no CI run on `54d4ee3a` itself. |

---

## Summary

**Overall Feature Readiness:** READY for the PR creation gate (no Blocking findings; final-head CI match owned by S9)

**Criteria summary:**
- **PASS:** 7 criteria (AC-1 through AC-7)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

None. The remaining obligations are process steps owned by the orchestrator, not acceptance gaps:

1. S9 must record a green `CI` result whose `head_sha` equals the final PR head before DONE and merge. This includes the head that carries these pass-2 review artifacts, and any head produced by updating from `origin/main`.
2. Non-blocking follow-ups: CR-1 (parser guard), PA-N8 (pre-existing PowerShell repo-wide line coverage of 84.67% versus 85%), PA-N9 (codify the green-run ruling in the rule text).

**Deviation register assessment (pass 2):**

| Deviation | Judgment | Classification |
|---|---|---|
| DEV-PWSH-ROUTE | Acceptable | Non-blocking |
| DEV-CI-BASELINE | Acceptable | Non-blocking |
| DEV-CI-FAILBEFORE | Acceptable | Non-blocking |
| DEV-CI-PASSAFTER | Acceptable | Non-blocking |
| DEV-CI-FINALQC | Acceptable | Non-blocking |
| DEV-ACTIONLINT-DIRECT | Acceptable | Non-blocking |
| DEV-NONPS-COPY | Acceptable | Non-blocking |
| DEV-MERGE-ADAPT | Acceptable | Non-blocking |
| DEV-AC7-EARLY | Acceptable (changed from pass 1) | Non-blocking |

The rationale for each judgment is in `policy-audit.2026-10-08T03-15.md` Section 8.

**Recommended follow-up verification steps:**

1. Open the PR to `main`, optionally after updating from `origin/main`. Run S9 against the PR head and record `ci_gate` with `head_sha` equal to the PR head and `conclusion: success`.
2. File a follow-up issue for code-review CR-1 (parser-level non-empty or required-workflow guard for epic children).
3. Observe the first real epic child PR after merge to confirm the `epic/**` trigger attaches the CI checks (CR-6).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/issue.md`
- Total AC items: 7
- Checked off (delivered): 7
- Remaining (unchecked): 0
- Items remaining: none

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/issue.md` | 7 | 7 | 0 | Checkbox-backed. All seven items were already checked, and all seven are evaluated PASS. |

No source-file checkbox change was made or needed by this review. The pass-1 discrepancy (AC-7 checked but evaluated PARTIAL) is resolved: AC-7 is now evaluated PASS, so its existing `[x]` is consistent with the tracking protocol.
