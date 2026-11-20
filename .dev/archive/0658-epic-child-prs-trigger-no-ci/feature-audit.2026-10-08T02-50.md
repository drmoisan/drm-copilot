# Feature Audit: epic-child-prs-trigger-no-ci (#658)

---

**Audit Date:** 2026-10-08 (artifact timestamp `2026-10-08T02-50` supplied by the delegating orchestrator)
**Feature Folder:** `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658`
**Base Branch:** `origin/main`
**Head Branch:** `bug/epic-child-prs-trigger-no-ci-658`
**Work Mode:** `minor-audit`
**Audit Type:** Initial acceptance review (pass 1)

---

## Scope and Baseline

- **Base branch:** `origin/main`. The merge-base `08ee030d9584bf15882fbb3654c8e38f34c7c359` is the diff anchor. `origin/main` is now at `6c3649b07322374035df8c11996f4d64a043e138` (PR #835); that delta touches none of the changed paths.
- **Head branch/commit:** `bug/epic-child-prs-trigger-no-ci-658` (commit `9686d975d85250814aba7e149ee6ac0cfeda562a`; `origin/bug/epic-child-prs-trigger-no-ci-658` resolves to the same SHA)
- **Merge base:** `08ee030d9584bf15882fbb3654c8e38f34c7c359`
- **Evidence sources:**
  - Primary: `git diff origin/main...HEAD` (50 files), read directly
  - Secondary baseline diff: `git diff --stat origin/main...HEAD` and per-commit `git show --stat`
  - Feature evidence: `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/evidence/**` (44 files)
  - Additional evidence: check-only commands run by this review (actionlint, `cmp`, pytest consumer suites, evidence-location validator)
- **Feature folder used:** `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658`
- **Requirements source:** `issue.md` only (`## Acceptance Criteria`, AC-1 through AC-7)
- **Work mode resolution note:** explicit marker `- Work Mode: minor-audit` at `issue.md` line 12. `spec.md` and `user-story.md` are absent from the feature folder, as required for minor-audit.
- **Scope note:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are absent. They were not regenerated because the caller restricted writes to the feature folder, so the full branch diff was read directly. PowerShell execution evidence comes from CI job logs under the operator's Option A rule (`evidence/other/pwsh-task-classification.2026-10-07T16-15.md`). This review cannot run `gh run view`, so it assessed those citations for internal consistency.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/issue.md`: only source (minor-audit)

### Acceptance criteria

1. AC-1: `.github/workflows/ci.yml` `on.pull_request.branches` lists `main`, `development`, and `"epic/**"`, and `on.push.branches` remains exactly `[main, development]`. Verified by file content of `.github/workflows/ci.yml` and by AC-4.
2. AC-2: `.github/workflows/README.md` documents the `ci.yml` `pull_request` trigger branches, names `epic/**`, and states that it is included so that epic child PRs targeting `epic/<slug>-integration` run the full CI gate. Verified by file content of `.github/workflows/README.md`.
3. AC-3: `.claude/skills/orchestrate/SKILL.md` S9 CI gate text states that, for a PR whose base is an `epic/<slug>-integration` branch, an empty check list (including an empty `gh pr checks --required` result) is not accepted as green; the gate must observe at least one check from the `CI` workflow on the child head SHA and require every observed `CI` check to succeed. Verified by file content of `.claude/skills/orchestrate/SKILL.md`.
4. AC-4: New Pester 5 test `tests/scripts/workflows/CiWorkflow.Tests.ps1` parses `.github/workflows/ci.yml` as text (following the `on:`-block isolation pattern in `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`, with no YAML module, process launch, or temporary file) and asserts that the `pull_request` branch list contains `main`, `development`, and `epic/**`. Verified by a recorded failing run against the pre-fix `ci.yml` and a recorded passing run against the fixed `ci.yml` (via `Invoke-PoshQCTest`), both stored under `evidence/`.
5. AC-5: `actionlint` reports no findings for `.github/workflows/ci.yml`. Verified by running `scripts/dev-tools/run-actionlint.ps1` and recording its output under `evidence/qa-gates/`.
6. AC-6: `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` is byte-identical to `.claude/skills/orchestrate/SKILL.md`. Verified by a passing run of `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (pytest).
7. AC-7: The `modified-workflow-needs-green-run` rule is satisfied: a `CI` workflow run whose head SHA equals the fix branch head concluded `success`. Verified at PR time by recording the run id, head SHA, and conclusion (from `gh run view`) under `evidence/`.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1: `pull_request` branches include `main`, `development`, `"epic/**"`; `push` stays `[main, development]` | PASS | `ci.yml` line 5 `branches: [main, development]`, line 7 `branches: [main, development, "epic/**"]` (read at head `9686d975`); `evidence/other/ci-yml-edit.2026-10-07T22-33.md`; AC-4 pass-after run | `git diff origin/main...HEAD -- .github/workflows/ci.yml` | One-line diff; push filter byte-unchanged. |
| 2 | AC-2: README documents trigger branches, names `epic/**`, states the reason | PASS | `.github/workflows/README.md` lines 8-16: `## Triggers`; line 13 `pull_request into main, development, and epic/**`; line 16 names `epic/<slug>-integration` and "run the full CI gate" | `git diff origin/main...HEAD -- .github/workflows/README.md`; `evidence/other/readme-triggers.2026-10-07T22-35.md` (three greps each `1`) | Also satisfies the github-actions policy requirement to document intentional trigger changes. |
| 3 | AC-3: S9 text rejects empty check list for epic-integration-based PRs; requires at least one `CI` check on the child head SHA, every observed `CI` check succeeding | PASS | `.claude/skills/orchestrate/SKILL.md` line 291 contains each required element: base `epic/<slug>-integration`; "An empty check list, including an empty `gh pr checks --required` result, is not accepted as green"; "at least one check whose `workflow` is `CI` against the child head SHA"; "every observed `CI` check must succeed" | `git diff origin/main...HEAD -- .claude/skills/orchestrate/SKILL.md`; `evidence/other/orchestrate-s9-epic-rule.2026-10-07T22-38.md` | The criterion is a text criterion and is met. The parser does not yet enforce the rule mechanically (code-review CR-1, Non-blocking, out of scope per `issue.md` line 28). |
| 4 | AC-4: Pester 5 text-parsing suite; recorded fail-before and pass-after runs via `Invoke-PoshQCTest` | PASS | Suite at `tests/scripts/workflows/CiWorkflow.Tests.ps1` (on:-block isolation at lines 23-40 mirrors `PublishMcpNpmWorkflow.Tests.ps1:19-35`; hermeticity grep `0`). Fail-before: CI run 37715960709 on `632fe595` (ci.yml unmodified), one `[-]` on the `pull_request` test at line 161, counts 6520/1. Pass-after: CI run 37717224700 on `8a1b9b8b`, zero `[-]`, counts 6521/0. CI test step is `Invoke-PoshQCTest` (`.github/workflows/_poshqc.yml:42`). | `git show --stat 632fe595`; `evidence/regression-testing/fail-before-*.md`, `pass-after-*.md`, `ci-workflow-test-hermeticity.2026-10-07T22-02.md` | Deviations DEV-CI-FAILBEFORE, DEV-CI-PASSAFTER, and DEV-CI-BASELINE are acceptable: the counts arithmetic and the head-SHA/fix-ancestry relations are internally consistent. |
| 5 | AC-5: actionlint reports no findings for `ci.yml` | PASS | This review: `actionlint .github/workflows/ci.yml` exit 0, empty output, actionlint 1.7.11 at head `9686d975`. Executor: `evidence/qa-gates/final-actionlint.2026-10-08T02-30.md` (same result). | `actionlint .github/workflows/ci.yml` | The verification route differs from the AC's named wrapper (DEV-ACTIONLINT-DIRECT, acceptable: the wrapper resolves the same PATH binary and passes arguments through). The criterion itself, no findings, is met. |
| 6 | AC-6: bundle mirror byte-identical; bundle-parity pytest passes | PASS | This review: `cmp` exit 0; pytest consumer run 39 passed (14 in `test_push_down_claude_resource_contracts.py`). Executor: SHA-256 `13e87496...9982` for both files; `evidence/qa-gates/final-bundle-parity.2026-10-08T02-30.md` 14 passed. | `cmp .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py ... -q -p no:cacheprovider` | DEV-NONPS-COPY is acceptable. Issue #510 condition not observed. |
| 7 | AC-7: a `CI` run whose head SHA equals the fix branch head concluded `success`, verified at PR time | PARTIAL | `evidence/qa-gates/ac7-ci-green-run.2026-10-08T02-30.md`: run 37717224700, event `workflow_dispatch`, head `8a1b9b8b`, conclusion `success`, 17 jobs `success`. Current branch head is `9686d975`. | `git rev-parse HEAD`; `git diff --name-only 8a1b9b8b HEAD` (feature-folder docs only) | The run's head SHA does not equal the current branch head, and no PR-time record exists. The delta is documentation-only, so the risk is low, but the criterion and `modified-workflow-needs-green-run` are SHA-exact. **AC-7 is already checked `[x]` in `issue.md` but is evaluated PARTIAL (DEV-AC7-EARLY is not acceptable as full satisfaction).** Blocking finding B-1, Remediability `awaiting_ci`. |

---

## Summary

**Overall Feature Readiness:** BLOCKED (awaiting CI on the final head; no code remediation required)

**Criteria summary:**
- **PASS:** 6 criteria (AC-1 through AC-6)
- **PARTIAL:** 1 criterion (AC-7)
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. AC-7 / B-1: no green `CI` run is recorded at the final branch head. The recorded run is on `8a1b9b8b`, and the head is `9686d975`. Committing these review artifacts will move the head again, so the qualifying record must be taken against the final PR head.

**Deviation register assessment (caller-named deviations):**

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
| DEV-AC7-EARLY | Not acceptable as full satisfaction of AC-7 | Blocking (B-1, awaiting_ci) |

The rationale for each judgment is in `policy-audit.2026-10-08T02-50.md` Section 8.

**Recommended follow-up verification steps:**

1. Open (or refresh) the PR to `main`, optionally after updating the branch from `origin/main`. Then read the CI run for the final PR head with `gh run view <id> --json databaseId,headSha,conclusion,event,workflowName` and record the run id, head SHA, and conclusion under `evidence/qa-gates/`. AC-7 is PASS when the head SHA equals the PR head and the conclusion is `success`.
2. File a follow-up issue for code-review CR-1: a parser-level guard so that an epic child's S9 gate cannot conclude `success` on an empty or CI-less check set.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/issue.md`
- Total AC items: 7
- Checked off (delivered): 7 checked in the source file; 6 evaluated PASS by this review
- Remaining (unchecked): 0 in the source file
- Items remaining: AC-7 (checked in the source file but evaluated PARTIAL; see below)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/issue.md` | 7 | 6 PASS of 7 checked | 0 | Checkbox-backed. AC-7 is checked but evaluated PARTIAL. |

No source-file checkbox change was made by this review. AC-1 through AC-6 were already checked and are confirmed PASS. **AC-7 was checked by the executor under DEV-AC7-EARLY, and this review evaluates it as PARTIAL, not PASS.** Under the acceptance-criteria-tracking protocol a PARTIAL item must not be checked. As instructed, this review does not uncheck it; it reports the discrepancy for the orchestrator. The orchestrator should either uncheck AC-7 until the final-head CI record exists, or leave it checked only after recording that run.
