# Remediation Inputs: parallel-ci-subworkflows (#294)

**Timestamp:** 2026-07-03T23-36
**Feature Folder:** `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/`
**Base Branch:** `main` (`9a36e9b3dd9da626a33a45b2318165f5e49c69ec`)
**Head Branch:** `feature/parallel-ci-subworkflows-294` (`5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3`)

## Pointer to Audit Artifacts

- `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/policy-audit.2026-07-03T23-36.md`
  (Sections 6, 7, 8, 10)
- `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/code-review.2026-07-03T23-36.md`
  (Findings Table, Blocker row)
- `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/feature-audit.2026-07-03T23-36.md`
  (Acceptance Criteria Evaluation, criteria 6/13/19)

## Trigger Condition

A required CI-gate policy rule (`modified-workflow-needs-green-run`, defined in
`.claude/skills/feature-review-workflow/SKILL.md`) is not satisfied at the current branch head. The
branch diff modifies `.github/workflows/**`, which mandatorily triggers this rule.

## Root Cause (Verified, Not Assumed)

1. The feature's own evidence (`evidence/qa-gates/green-run-branch-head.2026-07-03T18-07.md`)
   documents a successful, 11-job workflow run at head SHA
   `574aaa2a086d77857a5cd7d46723f87e090558c2`.
2. One additional commit, `5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3` ("docs(294): refresh
   green-run evidence for rebased head SHA"), landed after that run. `git show --stat 5cd712c9...`
   confirms this commit touches only two evidence markdown files, not any `.github/workflows/**`
   file.
3. The current branch head is `5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3`. A live query —
   `gh api repos/drmoisan/drm-copilot/commits/5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3/check-runs`
   — returns `{"total_count":0,"check_runs":[]}`. No workflow run of any kind exists against this
   commit.
4. `gh api repos/drmoisan/drm-copilot/actions/runs --paginate -q '.workflow_runs[] | select(.head_branch=="feature/parallel-ci-subworkflows-294") | {id, head_sha, name, status, conclusion, created_at}'`
   confirms the three most recent runs on this branch are at head SHAs `574aaa2a...`,
   `1a9d2000...`, and `4125238f...` — none at `5cd712c9...`.

The `modified-workflow-needs-green-run` rule defines "branch head" as "a workflow run whose head
SHA matches the current branch head." This is not currently satisfied. This is a purely evidentiary
gap — no workflow YAML content is implicated, since the trailing commit is docs-only.

## Enumerated Fix List

1. **[Fix 1 — required]** Produce a workflow run against the current branch head.
   - **File(s):** none (no code change required)
   - **Expected behavior:** A `ci.yml` run (via `gh workflow run ci.yml --ref feature/parallel-ci-subworkflows-294`,
     or the branch's own `push`/`pull_request` trigger, or a fresh `workflow_dispatch`) completes
     with `conclusion: success` for all 11 job runs (7 gates, with `quality-checks7` contributing 4
     matrix legs and `drm-copilot-extension-tests` contributing 2), at a head SHA that matches the
     branch's actual head at the time the run is captured.
   - **Verification command(s):**
     ```
     gh workflow run ci.yml --ref feature/parallel-ci-subworkflows-294
     gh run list --branch feature/parallel-ci-subworkflows-294 --limit 1 --json databaseId,headSha,status,conclusion
     gh run view <run-id> --json status,conclusion,jobs,headSha,url
     ```
     Confirm the `headSha` field in the output matches `git rev-parse HEAD` at the time of capture,
     and every job's `conclusion` is `success`.
2. **[Fix 2 — required]** Refresh `evidence/qa-gates/green-run-branch-head.2026-07-03T18-07.md` (or
   a new timestamped file) with the new run URL, the confirmed matching head SHA, and the per-job
   `conclusion: success` breakdown table, superseding (not deleting) the prior stale entry.
3. **[Fix 3 — required]** Refresh `evidence/other/required-status-check-names.2026-07-03T18-07.md`
   (or a new timestamped file) by re-running
   `gh api repos/drmoisan/drm-copilot/commits/{new-head-sha}/check-runs -q '.check_runs[] | {name, conclusion}'`
   against the same, now-current head SHA, and confirm the 11 confirmed check-run `name` strings
   are unchanged from the prior (stale-head) capture — expected, since no workflow-file content
   changed, but must be captured as fresh evidence rather than asserted from the prior run.
4. **[Fix 4 — required]** Re-check the reverted AC checkboxes in `user-story.md` and `spec.md` (see
   `feature-audit.2026-07-03T23-36.md` "Acceptance Criteria Check-Off" — items 6, 13, 19, and 20)
   once Fix 1–3 evidence confirms the current head SHA has a green run.
5. **[Fix 5 — optional, non-blocking]** If desired, post-merge, verify each `_<name>.yml` file is
   independently dispatchable (`gh workflow run _<name>.yml`, no `--ref` required once registered on
   `main`) to close the residual gap on criteria 11/16 (see `feature-audit.2026-07-03T23-36.md`).
   This is explicitly non-blocking for this PR since it is impossible to verify pre-merge (a real,
   already-documented GitHub platform constraint).

## Do Not Do

- Do not modify any `.github/workflows/**` YAML content as part of this remediation — the workflow
  files themselves are verified correct (byte-for-byte step preservation, `actionlint` clean, no
  `needs:`/inline `steps:` in `ci.yml`). This remediation is evidence-capture only.
- Do not weaken or remove the `modified-workflow-needs-green-run` rule's "head SHA must match" text
  to make the stale evidence "count." The rule is intentionally strict per
  `.claude/rules/ci-workflows.md` and `.claude/rules/benchmark-baselines.md` (both born from prior
  incidents of exactly this kind of silent provenance gap).
- Do not silently re-check the AC boxes without fresh, verified evidence at the actual final head
  SHA — if the branch head moves again during remediation (e.g., another commit lands), repeat Fix
  1–3 against the new final head before checking the boxes.
- Do not enable branch-protection required-status-checks on `main` as part of this remediation —
  that is explicitly out of scope for issue #294 (see `spec.md`'s Non-Goals and
  `evidence/other/branch-protection-update.2026-07-03T18-07.md`).
- No scope creep: do not touch `publish-extension.yml`, `publish-mcp-npm.yml`, or any file under
  `src/` or `extensions/drm-copilot/src`.

## Non-Blocking Items Noted for Awareness (Not Required for This Remediation Cycle)

- Criteria 11/16 (standalone per-file `workflow_dispatch`) remain PARTIAL and will self-resolve only
  once this branch merges to `main` (files must be registered on the default branch before
  per-file `workflow_dispatch` by filename is possible). No action is required in this cycle.
