# 2026-07-03-parallel-ci-subworkflows (#294) — Remediation Plan

- **Issue:** #294
- **Feature Folder:** `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/`
- **Base Plan:** `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/plan.2026-07-03T18-07.md`
- **Trigger:** `remediation-inputs.2026-07-03T23-36.md` (1 Blocking finding: `modified-workflow-needs-green-run`
  not satisfied at current branch head)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-03T23-36
- **Status:** Draft
- **Work Mode:** `full-feature` (per `issue.md` metadata) — AC source files are `spec.md` and `user-story.md`

`DIRECTIVE: PREFLIGHT VALIDATION ONLY`

## Required References

- Remediation inputs (primary input, read in full before any task below): [`remediation-inputs.2026-07-03T23-36.md`](remediation-inputs.2026-07-03T23-36.md)
- Supporting context: [`policy-audit.2026-07-03T23-36.md`](policy-audit.2026-07-03T23-36.md), [`code-review.2026-07-03T23-36.md`](code-review.2026-07-03T23-36.md), [`feature-audit.2026-07-03T23-36.md`](feature-audit.2026-07-03T23-36.md)
- Base plan and its "Task Ownership" section: [`plan.2026-07-03T18-07.md`](plan.2026-07-03T18-07.md)
- GitHub Actions Workflow Policy: [`.github/instructions/github-actions.instructions.md`](../../../../.github/instructions/github-actions.instructions.md)

## Scope Statement (Evidence-Capture-Only Remediation)

This remediation cycle makes **no `.github/workflows/**` YAML content changes**. The workflow files
are already verified correct (byte-for-byte step preservation, `actionlint`-clean, no `needs:`/inline
`steps:` in `ci.yml`) per `feature-audit.2026-07-03T23-36.md`. The sole gap is evidentiary: no
workflow run exists at the branch's current head SHA. This plan closes that gap by (a) producing a
green run at the current head, (b) refreshing two evidence artifacts in place, (c) producing a second
green run at the new head created by that evidence commit (since committing the refresh itself moves
the branch head forward), and (d) checking off the AC items that this fresh evidence now supports.

No `.github/workflows/**` YAML content change is needed or permitted by this remediation. This
constraint is non-negotiable per the remediation-inputs' "Do Not Do" section and is restated in
Phase 5.

## Task Ownership

Phase 0 policy-read tasks and Phase 5 scope-guard/QA-closure tasks (file reads, `git diff`/`git
status`, `actionlint`) are executed by `atomic-executor`. Phase 1, Phase 2, and Phase 3 tasks — which
invoke `gh workflow run`, `gh run list`, `gh run view`, `gh api`, or `git commit`/`git push` on the
feature branch — are executed directly by the **orchestrator**, not delegated to atomic-executor,
because atomic-executor's tool allowlist does not include `gh`, exactly as documented in the base
plan's "Task Ownership" section. Phase 4 (AC check-off) is executed by **atomic-executor or
feature-review**, per the `acceptance-criteria-tracking` skill; the orchestrator must not perform AC
check-off directly. Every task below carries an explicit `Owner:` line.

## Evidence Location Statement

All new evidence artifacts created by this remediation cycle are written under the canonical
`docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/<kind>/` scheme, using
`evidence/remediation-baseline/` for this cycle's baseline captures. The two artifacts named in
Fix 2/Fix 3 of `remediation-inputs.2026-07-03T23-36.md` (`evidence/qa-gates/green-run-branch-head.2026-07-03T18-07.md`
and `evidence/other/required-status-check-names.2026-07-03T18-07.md`) are updated **in place**
(new section added, prior section retained and relabeled "Superseded"), not deleted or replaced,
mirroring the existing rebase-driven refresh pattern already present in both files. No evidence is
written to any `artifacts/baselines/`, `artifacts/qa/`, or `artifacts/evidence/` path.

## Do Not Do (Restated from `remediation-inputs.2026-07-03T23-36.md`)

- Do not modify any `.github/workflows/**` YAML content in this remediation cycle.
- Do not weaken or remove the `modified-workflow-needs-green-run` rule's "head SHA must match" text.
- Do not check off any AC box without fresh, verified evidence at the actual final head SHA.
- Do not enable branch-protection required-status-checks on `main` as part of this remediation.
- Do not touch `.github/workflows/publish-extension.yml`, `.github/workflows/publish-mcp-npm.yml`,
  or any file under `src/` or `extensions/drm-copilot/src`.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Read and Remediation Baseline Capture

- [x] [P0-T1] Read `.github/copilot-instructions.md` in full.
  - Acceptance: File content reviewed; confirmed as step 1 of the Policy Compliance Reading Order in `CLAUDE.md`.
  - Owner: atomic-executor
- [x] [P0-T2] Read `.github/instructions/general-code-change.instructions.md` in full.
  - Acceptance: File content reviewed; confirmed as step 2 of the Policy Compliance Reading Order.
  - Owner: atomic-executor
- [x] [P0-T3] Read `.github/instructions/general-unit-test.instructions.md` in full.
  - Acceptance: File content reviewed; confirmed as step 3 of the Policy Compliance Reading Order.
  - Owner: atomic-executor
- [x] [P0-T4] Read `.github/instructions/github-actions.instructions.md` in full (the applicable domain policy for this feature's file scope, `.github/workflows/**/*.yml`).
  - Acceptance: File content reviewed; the `applyTo` frontmatter pattern is confirmed to match the workflow files this remediation cycle produces evidence about (no files are edited under this pattern).
  - Owner: atomic-executor
- [x] [P0-T5] Create a Phase 0 policy-read evidence artifact at `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/remediation-baseline/phase0-instructions-read.2026-07-03T23-36.md` containing `Timestamp:`, `Policy Order:` (numbered list matching P0-T1..P0-T4 in order), and the explicit list of the four files read.
  - Acceptance: File exists at the exact path above and contains all three required fields.
  - Owner: atomic-executor
- [ ] [P0-T6] Confirm the trigger condition by running `gh api repos/drmoisan/drm-copilot/commits/5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3/check-runs` and recording the raw JSON response to `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/remediation-baseline/baseline-current-head-no-run.2026-07-03T23-36.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: Artifact exists; `Output Summary:` states `{"total_count":0,"check_runs":[]}`, confirming zero workflow runs exist at the current head SHA `5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3` before Phase 1 begins.
  - Owner: orchestrator (direct `gh` invocation) — atomic-executor's tool allowlist does not include `gh`.
- [ ] [P0-T7] Capture a pre-remediation working-tree baseline via `git status --porcelain` and `git rev-parse HEAD`, confirming the working tree is clean and the branch head is exactly `5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3` before Phase 1 begins, and write both raw outputs to `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/remediation-baseline/baseline-git-status.2026-07-03T23-36.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: Artifact exists; `Output Summary:` confirms a clean working tree and states the exact head SHA matches `5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3`.
  - Owner: atomic-executor

### Phase 1 — Dispatch `ci.yml` Against the Branch's Current Head (No File Changes, No Commit)

- [ ] [P1-T1] Execute `gh workflow run ci.yml --ref feature/parallel-ci-subworkflows-294` to dispatch a fresh run against the branch's current head SHA `5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3`. This task makes no file changes and no commit.
  - Acceptance: The dispatch command completes without error (queued run confirmed); `git status --porcelain` immediately after this task shows no new changes (confirming no file was touched).
  - Owner: orchestrator (direct `gh` invocation) — atomic-executor's tool allowlist does not include `gh`; this task is executed directly by the orchestrator, not delegated.
- [ ] [P1-T2] Poll the dispatched run via `gh run list --branch feature/parallel-ci-subworkflows-294 --limit 1 --json databaseId,headSha,status,conclusion` until `status == completed`, and confirm the returned `headSha` equals `5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3`.
  - Acceptance: Command output shows `status: completed` and `headSha: 5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3`. If `headSha` does not match (e.g., a stale run was returned), repeat this task until a run with the matching `headSha` is observed.
  - Owner: orchestrator (direct `gh` invocation) — atomic-executor's tool allowlist does not include `gh`.
- [ ] [P1-T3] Retrieve the full per-job breakdown via `gh run view <run-id> --json status,conclusion,jobs,headSha,url` (using the run ID confirmed in P1-T2) and confirm `conclusion: success` for all 11 job runs (`quality-checks7` x4 matrix legs, `security-scan`, `docs-validation`, `build-check`, `poshqc`, `shell-coverage`, `drm-copilot-extension-tests` x2 matrix legs).
  - Acceptance: Command output lists all 11 job runs with `conclusion: success` and `headSha` matching `5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3`. This confirms a green run exists at the branch's current head as it stood at the start of this remediation cycle.
  - Owner: orchestrator (direct `gh` invocation) — atomic-executor's tool allowlist does not include `gh`.

### Phase 2 — Refresh Evidence Artifacts In Place, Commit, and Push

- [ ] [P2-T1] Update `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/qa-gates/green-run-branch-head.2026-07-03T18-07.md` in place: add a new "Current (post-remediation) run — authoritative for AC-6/13/19" section documenting the Phase 1 run's URL, head SHA `5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3`, `EXIT_CODE: 0`, and the per-job success table (11 rows) from P1-T3; relabel the file's existing "Current (post-rebase)" section (head SHA `574aaa2a086d77857a5cd7d46723f87e090558c2`) as "Superseded (pre-remediation)", retaining its content verbatim rather than deleting it.
  - Acceptance: File contains both a new "Current (post-remediation)" section (head SHA `5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3`, all 11 jobs `success`) and the prior section retained under a "Superseded" heading; no existing content is deleted.
  - Owner: orchestrator
- [ ] [P2-T2] Update `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/other/required-status-check-names.2026-07-03T18-07.md` in place: run `gh api repos/drmoisan/drm-copilot/commits/5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3/check-runs -q '.check_runs[] | {name, conclusion}'` against the head SHA confirmed in Phase 1, add a new "Current (post-remediation) head SHA" section with the resulting 11-row confirmed check-run name table, and relabel the file's existing head-SHA section (`574aaa2a...`) as "Superseded (pre-remediation)", retaining its content verbatim.
  - Acceptance: File contains both a new "Current (post-remediation)" section listing all 11 confirmed check-run `name` strings at head SHA `5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3`, and the prior section retained under a "Superseded" heading; the 11 `name` strings match the prior capture exactly (no workflow-file content changed).
  - Owner: orchestrator
- [ ] [P2-T3] Commit the two files updated in P2-T1 and P2-T2 with the message `docs(294): refresh green-run and check-run-name evidence for remediation dispatch at head 5cd712c9` and push the commit to `feature/parallel-ci-subworkflows-294`.
  - Acceptance: `git diff --stat 5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3..HEAD` (after push) shows exactly the two files from P2-T1/P2-T2 changed and no others; `git log -1 --format=%P` shows the new commit's parent is `5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3`.
  - Owner: orchestrator
- [ ] [P2-T4] Capture the new branch head SHA produced by P2-T3 via `git rev-parse HEAD` and record it to `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/remediation-baseline/post-evidence-commit-head.2026-07-03T23-36.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (the new head SHA value).
  - Acceptance: Artifact exists; `Output Summary:` states the exact new head SHA, which differs from `5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3` and is the parent-child successor recorded in P2-T3.
  - Owner: orchestrator

### Phase 3 — Dispatch `ci.yml` Against the Post-Evidence-Commit Head (Final Green Run)

- [ ] [P3-T1] Execute `gh workflow run ci.yml --ref feature/parallel-ci-subworkflows-294` a second time, dispatching against the new head SHA recorded in P2-T4 (the evidence-file commit produced by Phase 2). This is the run that will be current at review time, since no further content-changing commit is planned after it.
  - Acceptance: The dispatch command completes without error. This task's acceptance is explicitly conditioned as follows: **this must be the last content-changing commit on the branch before the next feature-review re-audit.** If any further commit lands on the branch for any reason before that re-audit, this three-step sequence (Phase 1 dispatch → Phase 2 evidence commit → Phase 3 dispatch) must repeat once more against the new final head.
  - Owner: orchestrator (direct `gh` invocation) — atomic-executor's tool allowlist does not include `gh`.
- [ ] [P3-T2] Poll and confirm the run dispatched in P3-T1 completes with `conclusion: success` for all 11 job runs, using `gh run list --branch feature/parallel-ci-subworkflows-294 --limit 1 --json databaseId,headSha,status,conclusion` followed by `gh run view <run-id> --json status,conclusion,jobs,headSha,url`, and confirm the returned `headSha` equals the value recorded in P2-T4.
  - Acceptance: Command output shows all 11 job runs with `conclusion: success` and `headSha` matching P2-T4's recorded value exactly. This satisfies `modified-workflow-needs-green-run` at the branch's actual final head, resolving the Blocking finding in `remediation-inputs.2026-07-03T23-36.md`.
  - Owner: orchestrator (direct `gh` invocation) — atomic-executor's tool allowlist does not include `gh`.

### Phase 4 — Acceptance-Criteria Check-Off (Delegated, Not Orchestrator)

- [x] [P4-T1] Verify, per the `acceptance-criteria-tracking` skill's evidence-before-check-off rule, that Phases 1–3 produced a green run whose `headSha` matches the branch's actual final head (P2-T4's recorded value) as confirmed in P3-T2, and that P2-T1/P2-T2's evidence artifacts document that run without deleting prior superseded entries.
  - Acceptance: A written confirmation (in this task's execution notes) that P3-T2's `headSha` equals P2-T4's recorded head SHA and that P2-T1/P2-T2 were updated (not created new) in place. If this confirmation cannot be made, none of P4-T2..P4-T5 below may check off any box; leave all four unchecked and record the gap instead.
  - Owner: atomic-executor or feature-review (per the `acceptance-criteria-tracking` skill) — the orchestrator must not perform AC check-off directly.
  - **Execution notes (atomic-executor, 2026-07-03T23-36):** Confirmation **cannot be made** to the
    standard this task requires. Findings:
    - P2-T4 was never executed — no `evidence/remediation-baseline/post-evidence-commit-head.*.md`
      artifact exists. There is no recorded value for "P2-T4's recorded head SHA" to compare
      against.
    - Independently (via `git rev-parse HEAD` and `git log --format=%H -3`), the current branch
      head is `5a428db4d54cb46f2980b9fbdfe8b527a101b391`, whose parent is
      `cb4399749f68a97759cd86f63eb0a44c077921d1` (the commit that added the review/remediation
      artifacts). `git show 5a428db --stat` confirms `5a428db` changed only the two P2-T1/P2-T2
      evidence files (updated in place, not created new) — that sub-fact is confirmed.
    - However, both refreshed evidence files (`evidence/qa-gates/green-run-branch-head.2026-07-03T18-07.md`
      and `evidence/other/required-status-check-names.2026-07-03T18-07.md`) document their
      "Current (post-remediation)" green run at head SHA `cb4399749f68a97759cd86f63eb0a44c077921d1`
      — i.e., the current head's **parent**, not the current head `5a428db...` itself. Per the
      orchestrator's directive, a further dispatch (run `28688561428`) was made against
      `5a428db...` and reportedly returned `conclusion: success` for all 11 job runs, but **this run
      is not captured in any evidence artifact in this repository** (an intentional gap, to avoid
      the self-referential evidence-commit trap of writing that result into a file, which would
      move the head again). atomic-executor has no `gh` tool access and cannot independently
      confirm this run.
    - This is the same class of defect (evidence one commit behind the literal current head) that
      produced the original Blocking finding in `feature-audit.2026-07-03T23-36.md` (criterion 6/13/19).
      Per that same rule's strict head-SHA-match standard, and per the acceptance-criteria-tracking
      skill's "evidence before check-off" rule, an unwritten, unverifiable (by this agent) claim of a
      run at the literal current head does not constitute audit-grade evidence.
    - **Conclusion: confirmation cannot be made.** Per this task's own acceptance text, P4-T2
      through P4-T5 remain unchecked and the gap is recorded (below and in each task's notes).
      Genuine check-off of AC 6/13/19/20 should occur at the next feature-review re-audit, which has
      live `gh api` access and can verify the check-runs at `5a428db4d54cb46f2980b9fbdfe8b527a101b391`
      directly, per the orchestrator's stated design intent.
- [ ] [P4-T2] If P4-T1's verification succeeds, check off criterion 6 in `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/user-story.md` (the `- [ ] A green workflow run against the branch head is captured before merge...` line under "Acceptance Criteria"), changing `- [ ]` to `- [x]`, citing P3-T2's confirmed head SHA and run URL. If P4-T1's verification did not succeed, leave this box unchecked.
  - Acceptance: The line in `user-story.md` reads `- [x] A green workflow run against the branch head is captured before merge...` only if P4-T1 succeeded; criterion text is otherwise unmodified.
  - Owner: atomic-executor or feature-review (per the `acceptance-criteria-tracking` skill)
  - **Execution notes:** P4-T1 did not succeed (evidence documents a run one commit behind the
    literal current head; no artifact confirms a run at `5a428db...` itself). Left unchecked in
    `user-story.md`.
- [ ] [P4-T3] If P4-T1's verification succeeds, check off criterion 13 in `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/spec.md` (the `- [ ] A green workflow run against the branch head is captured as evidence...` line), changing `- [ ]` to `- [x]`, citing the same evidence as P4-T2. If P4-T1's verification did not succeed, leave this box unchecked.
  - Acceptance: The corresponding line in `spec.md` reads `- [x] A green workflow run against the branch head is captured as evidence...` only if P4-T1 succeeded; criterion text is otherwise unmodified.
  - Owner: atomic-executor or feature-review (per the `acceptance-criteria-tracking` skill)
  - **Execution notes:** P4-T1 did not succeed. Left unchecked in `spec.md`, same gap as P4-T2.
- [ ] [P4-T4] If P4-T1's verification succeeds, check off criterion 19 in `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/spec.md` (the "Seeded Test Conditions" `- [ ] A workflow run against the branch head confirms all seven gates execute...` line), changing `- [ ]` to `- [x]`, citing the same evidence as P4-T2. If P4-T1's verification did not succeed, leave this box unchecked.
  - Acceptance: The corresponding line in `spec.md` reads `- [x] A workflow run against the branch head confirms all seven gates execute...` only if P4-T1 succeeded; criterion text is otherwise unmodified.
  - Owner: atomic-executor or feature-review (per the `acceptance-criteria-tracking` skill)
  - **Execution notes:** P4-T1 did not succeed. Left unchecked in `spec.md`, same gap as P4-T2.
- [ ] [P4-T5] If P4-T1's verification succeeds, check off criterion 20 in `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/spec.md` (the `- [ ] gh api repos/{owner}/{repo}/commits/{head_sha}/check-runs against the branch-head run confirms...` line), changing `- [ ]` to `- [x]`, citing P2-T2's refreshed `required-status-check-names.2026-07-03T18-07.md` evidence as support. If P4-T1's verification did not succeed, leave this box unchecked.
  - Acceptance: The corresponding line in `spec.md` reads `- [x] gh api repos/{owner}/{repo}/commits/{head_sha}/check-runs against the branch-head run confirms...` only if P4-T1 succeeded; criterion text is otherwise unmodified.
  - Owner: atomic-executor or feature-review (per the `acceptance-criteria-tracking` skill)
  - **Execution notes:** P4-T1 did not succeed (the refreshed `required-status-check-names.*.md`
    file also documents names confirmed against head `cb4399749...`, one commit behind current
    head). Left unchecked in `spec.md`.

### Phase 5 — Scope-Guard and Final QA Closure (Evidence-Capture-Only Remediation)

- [x] [P5-T1] Run `git diff --stat 5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3..HEAD` (the pre-remediation head as base) after Phase 2's commit and Phase 4's AC check-offs, and confirm the only files changed are `evidence/qa-gates/green-run-branch-head.2026-07-03T18-07.md`, `evidence/other/required-status-check-names.2026-07-03T18-07.md`, and (if P4-T1 succeeded) `spec.md`/`user-story.md`; confirm zero `.github/workflows/**` YAML files appear in the diff, zero changes under `src/` or `extensions/drm-copilot/src`, and `.github/workflows/publish-extension.yml`/`.github/workflows/publish-mcp-npm.yml` are absent from the diff. Record the command, `EXIT_CODE:`, and `Output Summary:` to `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/qa-gates/scope-guard-remediation.2026-07-03T23-36.md`.
  - Acceptance: Artifact exists; `Output Summary:` confirms the exact file list above with no `.github/workflows/**` YAML content changes, no `src/`/`extensions/drm-copilot/src` changes, and both publish workflow files absent from the diff. This artifact also serves as the explicit statement that branch protection on `main` was not enabled as part of this remediation (no `gh api .../protection` PATCH command appears in any task above).
  - Owner: atomic-executor
  - **Execution notes:** Artifact written. Ran both the merge-base-with-`main` diff
    (`9a36e9b3d...`..HEAD) and the remediation-cycle-only diff (`5cd712c9d1...`..HEAD, `EXIT_CODE: 0`
    both). The remediation-cycle-only diff changed exactly 11 files, all Markdown under this
    feature's folder (the two P2-T1/P2-T2 evidence files plus `spec.md`/`user-story.md` — the latter
    two changed by the reviewer's prior correction pass, not by Phase 4 check-offs since P4-T1 did
    not succeed — plus this cycle's own audit/plan docs). Zero `.github/workflows/**`, zero `src/`
    or `extensions/drm-copilot/src`, both publish workflow files absent from every range checked. No
    branch-protection PATCH command appears anywhere in the plan.
- [x] [P5-T2] Run a final `actionlint` pass (via `scripts/dev-tools/run-actionlint.ps1` or the repository's documented equivalent) across all 8 workflow files touched by the original feature (`ci.yml` plus the 7 `_<name>.yml` files) to reconfirm zero errors and zero content drift from the pre-remediation state (no workflow YAML was edited by this remediation cycle), and record the result to `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/qa-gates/final-qa-loop-actionlint-remediation.2026-07-03T23-36.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: Artifact exists; `EXIT_CODE: 0`; `Output Summary:` confirms 0 errors across all 8 files and states these files are unchanged (byte-identical) relative to the pre-remediation head, since no workflow YAML edit was made in this cycle.
  - Owner: atomic-executor
  - **Execution notes:** Ran `pwsh -NoProfile -File ./scripts/dev-tools/run-actionlint.ps1` against
    all 8 files. `EXIT_CODE: 0`, 0 errors. Artifact written; confirmed unchanged from the prior clean
    pass (`evidence/qa-gates/final-qa-loop-actionlint.2026-07-03T18-07.md`) since P5-T1 confirms 0
    `.github/workflows/**` files changed in this remediation cycle.
- [x] [P5-T3] Write a closing language-applicability statement to `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/qa-gates/final-qa-loop-language-applicability-remediation.2026-07-03T23-36.md` stating that the Python (Black/Ruff/Pyright/Pytest), TypeScript (ESLint/TSC/Vitest), PowerShell (PSScriptAnalyzer/Pester), and C# toolchain loops remain N/A for this remediation cycle (no `.py`/`.ts`/`.ps1`/`.cs` production or test file was changed, per P5-T1's confirmed diff scope), and that YAML validity (`actionlint`, P5-T2) plus the two green branch-head runs (P1-T3, P3-T2) constitute this remediation cycle's actual verification surface.
  - Acceptance: Artifact exists and explicitly states N/A for each of the four named language toolchains, citing P5-T1 as the confirming diff-scope evidence.
  - Owner: atomic-executor
  - **Execution notes:** Artifact written; all four language toolchains stated N/A, citing P5-T1.
    Also notes (for transparency) that the P2-T1/P2-T2 evidence documents the green run at the
    current head's parent commit rather than at the literal current head, per the Phase 4 execution
    notes and gap.

## Test Plan

- Unit: Not applicable. This remediation cycle is evidence-capture-only; no Python, TypeScript,
  PowerShell, or C# production or test file is created, modified, or deleted (confirmed by P5-T1's
  scope-guard diff and stated explicitly in P5-T3).
- Integration: The equivalent integration surface is a real workflow run at the branch's actual
  final head. This is covered by Phase 1 (initial dispatch at the pre-remediation head, to unblock
  further work) and Phase 3 (final dispatch at the post-evidence-commit head, which is the run that
  will be current at feature-review re-audit time).
- Manual/CLI: `gh workflow run ci.yml --ref feature/parallel-ci-subworkflows-294` (Phases 1 and 3);
  `gh api repos/drmoisan/drm-copilot/commits/{sha}/check-runs` (Phase 0 trigger confirmation, Phase 2
  refresh).
- Coverage evidence: Not applicable. No language with a mandatory coverage policy has any file in
  scope for this remediation cycle.

## Open Questions / Notes

- If Phase 3's dispatch (P3-T1) somehow fails or the resulting run does not conclude `success`, this
  plan does not proceed to Phase 4; the orchestrator repeats Phase 1→2→3 against a corrected state
  before any AC box is checked off.
- If any commit lands on `feature/parallel-ci-subworkflows-294` after Phase 3 completes and before the
  next feature-review re-audit, Phase 1→2→3 must repeat once more against the new final head before
  Phase 4 proceeds. This is stated explicitly in P3-T1's acceptance criteria.
- Fix 5 from `remediation-inputs.2026-07-03T23-36.md` (post-merge, verify each `_<name>.yml` is
  independently dispatchable) is explicitly non-blocking and out of scope for this remediation cycle;
  no task above addresses it.
