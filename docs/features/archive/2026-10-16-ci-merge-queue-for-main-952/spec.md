# 2026-10-16-ci-merge-queue-for-main (Spec)

- **Issue:** #952
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-16T02-00
- **Status:** Draft
- **Version:** 0.2

## Context
The `protect-main` ruleset (id 15241672) requires branches to be up to date before merge. When several PRs are green at once, each merge forces every remaining PR to merge main in and rerun the full CI (about 15–19 minutes). Merges therefore serialize into one roughly 19-minute cycle per PR. A GitHub merge queue removes that loop.

Environment:
- OS/version: GitHub Actions (windows-latest, ubuntu-latest)
- Python version: n/a
- Command/flags used: `gh pr merge --merge` from the parallel-orchestrator, orchestrate and epic-orchestrate merge steps
- Data source or fixture: parallel run `bug-burndown-2026-10-15` (15 items; PRs #942, #944, #947, #948, #949, #950, #951)

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Inputs used for this spec:
- `issue.md` (this folder).
- `research/research.2026-10-16T01-30.md` (authoritative findings and `file:line` citations; cited below as "research").
- `ruleset/protect-main.current.2026-10-16.json` (read-only snapshot of ruleset 15241672, taken 2026-10-16 via `gh api` GET; cited below as "the snapshot").


## Repro & Evidence
Steps to Reproduce:
1. Have three or more PRs with green CI targeting `main`.
2. Merge one of them.
3. Observe that each remaining PR is now out of date and blocked until it merges `main` in and CI reruns.

Expected:
Green PRs are merged in order without a manual re-sync and full CI rerun per PR. The combined result is still validated before it lands on `main`.

Actual:
Each remaining PR needs one manual re-sync and one full CI rerun per earlier merge. Six ready PRs take about 6 × 19 minutes of mostly serial waiting.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: CI run 38846579572 took 19 minutes; the `protect-main` ruleset carries `required_status_checks` with strict up-to-date enforcement.

Additional evidence (research, verified by static reading on 2026-10-16):
- The snapshot shows `strict_required_status_checks_policy: true` and `conditions.ref_name.include: ["~DEFAULT_BRANCH"]` (no wildcard pattern, so the documented wildcard restriction on merge queues does not apply).
- `ci.yml` has no `merge_group` trigger (`.github/workflows/ci.yml:4-8`), so a queue added today would stall: no required context would report on a merge-group commit.
- The merge-gate hooks gate only commands carrying the exact token `--merge` (`.claude/hooks/enforce-epic-merge-gate.ps1:343-356`, `.codex/hooks/enforce-epic-merge-gate.ps1:144-157`). `gh pr merge <n> --auto`, bare `gh pr merge <n>`, `-m`, `--squash`/`-s`, `--rebase`/`-r`, `--admin`, and `gh api` merge or enqueue mutations are not gated today (research Q5 table).
- `scripts/dev-tools/Invoke-FullReleaseFlow.ps1:369` passes `--delete-branch`, which `gh` rejects when a queue is required, and the script reads `main` immediately after the merge call (`:375-392`).


## Scope & Non-Goals
- In scope:
  - Add a `merge_group` trigger to `.github/workflows/ci.yml` and document it in `.github/workflows/README.md`; assert it in `tests/scripts/workflows/CiWorkflow.Tests.ps1`.
  - Make the merge-gate hooks method-agnostic on both runtimes (Claude `.claude/hooks`, Codex `.codex/hooks`), including `gh api` merge and enqueue mutations, with bundle mirrors and pack-manifest entries.
  - Add a pure merge-confirmation parser `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` with bundle mirror and manifest entry.
  - Make every repository merge procedure queue-aware (Claude parallel-orchestrate, parallel-orchestrator, orchestrate S9 step 6 and PR Creation Gate condition 7, epic-orchestrate, epic-orchestrator; Codex epic-orchestrate and epic-orchestrator), with bundle mirrors.
  - Make `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` queue-aware (drop `--delete-branch`; wait for a confirmed merge before checkout, pull, and tag).
  - Ship ruleset payloads and a runbook under `ruleset/` in this feature folder (not applied by this item).
  - Pester and pytest coverage for every new or changed path.
- Out of scope / non-goals:
  - Applying any ruleset change to the repository. The coordinator applies after merge (see Rollout & Follow-up).
  - Transferring the repository to an organization.
  - Editing `.github/workflows/_poshqc.yml` (concurrent item #953 owns it) or any workflow other than `ci.yml`.
  - Editing policy files under `.claude/rules/**` or `.github/instructions/**`, including the stale statements at `.claude/rules/orchestrator-state.md:238`, `.claude/rules/parallel-orchestration.md:154`, and `.claude/rules/parallel-orchestration.md:689` (recorded as a follow-up).
  - Gating `gh` invocations issued through the Claude PowerShell tool (pre-existing gap; no `PreToolUse` matcher covers that tool).
  - Editing `.github/` customization files (agents, skills, prompts, instructions); research Q4 found no merge procedure there.
  - Editing `.claude/skills/parallel-run/SKILL.md` (delegates merging to parallel-orchestrate; research Q4).
  - Editing `.claude/skills/cleanup-merged-worktrees/SKILL.md` (human-performed merge; its strict up-to-date wording becomes stale only after a queue is applied; recorded as a follow-up).
  - Adding gh-specific flags to the shared tables in `.claude/hooks/hook-command-invocation.ps1`.
- Explicitly excluded systems, integrations, or datasets:
  - GitHub repository settings and the live ruleset 15241672.
  - Workflows outside the `ci.yml` call graph (`npm-audit-gate.yml`, `publish-extension.yml`, `publish-mcp-npm.yml`, `verify-published-releases.yml`); research Q1 and N2 show none produces a required context.

## Root Cause Analysis
- Strict up-to-date enforcement (`strict_required_status_checks_policy: true` in the snapshot) forces each remaining PR to re-sync and re-run CI after every merge. A merge queue provides the same pre-merge combined validation without requiring the author to update the branch.
- A queue cannot be enabled safely today because no workflow triggers on `merge_group`. Research Q1 established that every required context in the snapshot is produced by `ci.yml` through reusable workflows, and reusable workflows inherit the caller's event context, so only `ci.yml` needs the trigger. Research Q2 found no `github.event.pull_request.*`, `head_ref`, `base_ref`, `event_name` reads, `paths` filters, job-level `if:` conditions, concurrency groups, or custom checkout refs in the `ci.yml` call graph; no expression change is required.
- With a queue, `gh pr merge` exits 0 after enqueuing (or enabling auto-merge) rather than merging. Every repository procedure records `merge_commit_sha` immediately after `gh pr merge`, which assumes a synchronous merge (research Q4). Those procedures would record a merge that has not happened.
- The merge gates key on the literal `--merge` token. Under a queue every spelling (`--merge`, `--squash`, `--rebase`, `--auto`, bare) performs the same enqueue, so gating only `--merge` leaves ungated routes to `main`. `gh api` mutations (`enqueuePullRequest`, `enablePullRequestAutoMerge`, `mergePullRequest`, REST `pulls/<n>/merge`) are not gated at all. The PR-number reader also returns `$null` for value-flag-led and URL selectors, so those commands are evaluated as if no PR number were given (research Q5).
- Availability constraint: GitHub documents merge queues as available only for organization-owned repositories; `drmoisan/drm-copilot` is user-owned (research Summary item 1). The ruleset deliverable is therefore shipped but not applied.


## Proposed Fix

### Design summary (what changes where):
1. Workflow: `ci.yml` gains `merge_group:` with `types: [checks_requested]` and no `branches` filter. No reusable workflow changes.
2. Merge gate: scope and PR-selector logic move to a new helper file per runtime (`.claude/hooks/enforce-epic-merge-gate-command.ps1`, `.codex/hooks/enforce-epic-merge-gate-command.ps1`). Scope becomes every structural `gh pr merge` invocation except a pure `--disable-auto`, plus `gh api` invocations carrying `enqueuePullRequest`, `enablePullRequestAutoMerge`, or `mergePullRequest`, or a REST `pulls/<n>/merge` path. `--admin` is gated like any merge. The authorization logic downstream of scope is unchanged.
3. Merge confirmation: a pure parser maps one PR JSON snapshot to `merged | pending | not_queued | closed` plus `merge_commit_sha` and `merged_at`. Procedures poll it with a bounded interval and total timeout, confirm ancestry, and route failures to existing remediation paths.
4. Procedures: queue-aware text is appended after the existing pinned merge sentences in each Claude and Codex merge procedure; mirrors are updated byte-identically.
5. Release flow: `Invoke-FullReleaseFlow.ps1` drops `--delete-branch` and waits for a confirmed merge before `git checkout main`, `git pull`, and tagging.
6. Ruleset deliverables: three JSON payloads and a runbook under `ruleset/`, derived from the snapshot.

### Boundaries and invariants to preserve:
- Pinned fragments stay verbatim, including "Execute `gh pr merge --merge <PR>`" (`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:219-225`) and every fragment pinned by `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`. New text is added after them.
- `.claude/**`, `.codex/**`, and `.agents/**` edits are mirrored byte-identically under `extensions/drm-copilot/resources/claude-customizations/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/`.
- The merge gate remains checkpoint-only; it makes no live `gh` call (`enforce-epic-merge-gate.ps1:36-39`).
- Every new dot-sourced hook dependency is loaded inside its own guarded `try` with `Add-HookDependencyFailure` (`tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`).
- `merge_status: ci_green` is recorded before `gh pr merge` (unchanged); `merged` is recorded only after ancestry confirmation.
- No procedure re-issues `gh pr merge` in a loop after a `not_queued` outcome.
- Every production and test file stays within the 500-line limit of `.claude/rules/general-code-change.md`. No test creates temporary files.
- `.claude/hooks/hook-command-invocation.ps1` shared option tables are not changed.

### Dependencies or blocked work:
- Concurrent item #927 may edit `enforce-epic-merge-gate*.ps1` (unverified from the tree; research Q5). Placing new logic in a new helper file limits the overlap to the scope-filter call site, header, and deny message.
- Concurrent item #953 owns `.github/workflows/_poshqc.yml`; this item does not edit it.
- Live queue behavior depends on the repository becoming organization-owned or the API accepting the `merge_queue` rule; this does not block delivery of the item.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
Category A, workflows:
- `.github/workflows/ci.yml` (add trigger).
- `.github/workflows/README.md` (Triggers section lists `merge_group`).
- `tests/scripts/workflows/CiWorkflow.Tests.ps1` (trigger assertions and call-graph event-read assertion).

Category B, merge gate:
- New `.claude/hooks/enforce-epic-merge-gate-command.ps1` + `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-command.ps1`; entry in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
- New `.codex/hooks/enforce-epic-merge-gate-command.ps1` + `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-command.ps1`; entry in `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`.
- `.claude/hooks/enforce-epic-merge-gate.ps1` (guarded dot-source; replace scope filter `:334-356` with the helper call; route PR-number reads to the helper; update header `:3`, `:7-8`, `:34`; deny message `:415`) + bundle mirror.
- `.codex/hooks/enforce-epic-merge-gate.ps1` (same changes at `:139-157`, `:43-76`, `:191`) + bundle mirror.
- New `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1`.
- New `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1`.
- Updated pinned rows: `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1:37-41`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1:102`, `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1:95`.

Category C, merge confirmation and release flow:
- New `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` + bundle mirror + `core.json` entry.
- New `tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1`; manifest coverage in `tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1` or a sibling manifest test.
- `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (drop `--delete-branch`; add a merge wait using the existing `Invoke-Sleep` seam at `:122-141`).
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` (pinned argument strings at `:75`, `:171`, `:338`) and new `tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1`.

Category D, procedures (each with its byte-identical bundle mirror):
- `.claude/skills/parallel-orchestrate/SKILL.md` (`:391-394`, `:436-439`, conflict entries `:450` and `:470`).
- `.claude/agents/parallel-orchestrator.md` (`:288-289`, `:298-299`).
- `.claude/skills/orchestrate/SKILL.md` (S9 step 6 `:301`; PR Creation Gate condition 7 `:366`).
- `.claude/skills/epic-orchestrate/SKILL.md` (`:126-129`, `:140-141`, `:355-356`).
- `.claude/agents/epic-orchestrator.md` (`:163`).
- `.agents/skills/epic-orchestrate/SKILL.md` (`:169-172`, `:176-177`).
- `.codex/agents/epic-orchestrator.toml` (`:79-80`).
- Contract tests extended: `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`, and `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` only if a new fragment is pinned there.

Category E, ruleset deliverables (this feature folder; not applied):
- `ruleset/protect-main.merge-queue.apply.json`
- `ruleset/protect-main.non-strict.alternative.json`
- `ruleset/protect-main.rollback.json`
- `ruleset/runbook.md`

#### Functions/classes/CLI commands impacted:
- New `Test-EpicMergeGateCommandInScope` (helper file): returns whether a command line is a gated merge or enqueue action.
- New gh-aware selector reader in the helper file (replacing the body of `Get-EpicMergeGateCommandPrNumber` on Claude and `Get-CodexMergeCommandPrNumber` on Codex): skips gh value flags (`-b`, `--body`, `-F`, `--body-file`, `-t`, `--subject`, `-A`, `--author-email`, `--match-head-commit`, `-R`, `--repo`) with their values, skips boolean flags, and accepts an all-digit selector or a `/pull/<n>` URL selector. For `gh api` invocations it reads `<n>` from a `pulls/<n>/merge` path; a GraphQL mutation without a resolvable number is treated as a merge with no PR number and handled by the existing no-number branches.
- `Invoke-EpicMergeGateDecision` (Claude) and the Codex decision entry point: call the helper instead of the inline `--merge` filter.
- New `Invoke-MergeConfirmationParser` (script entry point modeled on `Invoke-CiGateParser.ps1`).
- New merge-wait function in `Invoke-FullReleaseFlow.ps1` (working name `Wait-ForPullRequestMerged`), called between the merge call and `git checkout main`.
- CLI usage in procedures: `gh pr merge <PR> --merge` (unchanged spelling, no `--delete-branch`, no `--auto`), `gh pr view <PR> --json state,mergeCommit,mergedAt,autoMergeRequest` or an equivalent `gh api graphql` query adding `isInMergeQueue`, `git fetch origin <base>`, `git merge-base --is-ancestor <oid> origin/<base>`.

#### Data flow and validation changes:
Merge confirmation, per merge attempt (research Behavior Semantics):
1. Run `gh pr merge <PR> --merge`. A non-zero exit is a merge failure handled by the existing conflict and failure paths.
2. Poll a PR snapshot and pass it to `Invoke-MergeConfirmationParser`.
3. Status mapping:
   - `state` `MERGED` with non-empty `mergeCommit.oid` → `merged`.
   - `state` `MERGED` with empty or missing `mergeCommit.oid` → fail-fast error.
   - `state` `CLOSED` → `closed` (failure).
   - `state` `OPEN` and (`isInMergeQueue` true or `autoMergeRequest` non-null) → `pending`.
   - `state` `OPEN` with neither → `not_queued` (removed from the queue or never enqueued; failure).
   - Malformed JSON or an unrecognized `state` → fail-fast error.
4. On `pending`, wait the poll interval and re-poll; when the total timeout is exhausted, record `awaiting_merge_queue` and stop without recording `merged`.
5. On `merged`, run `git fetch origin <base>` and confirm `git merge-base --is-ancestor <oid> origin/<base>` exits 0 before recording `merge_commit_sha`, `merged_at`, and `merge_status: merged`.
6. On `not_queued`, re-check `mergeable`: `CONFLICTING` enters the existing conflict path; otherwise treat it as a merge-group CI failure and route to remediation (merge `origin/main`, re-run S9), consuming a remediation attempt. Never re-issue `gh pr merge` in a loop.
7. On `closed`, stop and report a failure.

When no queue exists the first poll returns `merged`, so the procedures behave as before apart from the ancestry check.

Merge-gate scope (both runtimes):

| Command shape | In scope after this item |
|---|---|
| `gh pr merge <sel>` with any of `--merge`/`-m`, `--squash`/`-s`, `--rebase`/`-r`, `--auto`, `--admin`, or no method flag | Yes |
| `gh pr merge <sel> --disable-auto` with no other action flag | No (allowed) |
| `gh api graphql ...` whose text contains `enqueuePullRequest`, `enablePullRequestAutoMerge`, or `mergePullRequest` | Yes |
| `gh api ... repos/<o>/<r>/pulls/<n>/merge` (any method) | Yes |
| `gh api graphql` read query (for example one containing `isInMergeQueue`) without those mutation names | No (allowed) |
| Text that only mentions `gh pr merge` (not a structural invocation) | No (allowed) |

#### Error handling and logging updates:
- Parser: throws with an `Invoke-MergeConfirmationParser:` prefix on malformed JSON, unrecognized `state`, or `MERGED` with an empty merge commit, matching the fail-fast style of `Invoke-CiGateParser.ps1`.
- Merge gate deny messages name the generic merge or enqueue action rather than only `gh pr merge --merge`.
- Release flow: on timeout, `not_queued`, or `closed`, writes a specific stderr line through `Write-StderrLine` and exits non-zero before any checkout, pull, or tag step.
- Procedures record `awaiting_merge_queue` on timeout instead of a merge result.

#### Rollback/feature-flag considerations (if applicable):
- Code changes are reverted by reverting the PR. No feature flag is introduced; queue-aware procedures are correct without a queue.
- Ruleset rollback is `protect-main.rollback.json` (snapshot writable fields unchanged), applied by the runbook's rollback command.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- `Invoke-MergeConfirmationParser` input: one JSON string from `gh pr view --json state,mergeCommit,mergedAt,autoMergeRequest` or from a GraphQL `pullRequest` node with the same fields plus optional `isInMergeQueue`. Output: an object with `Status` (`merged | pending | not_queued | closed`), `MergeCommitSha` (string, empty unless `merged`), and `MergedAt` (string, empty unless `merged`).
- Ruleset payloads: JSON bodies for `PUT /repos/drmoisan/drm-copilot/rulesets/15241672` containing exactly the writable fields `name`, `target`, `enforcement`, `conditions`, `bypass_actors`, `rules`. Read-only fields of the snapshot (`id`, `source_type`, `source`, `node_id`, `created_at`, `updated_at`, `current_user_can_bypass`, `_links`) are omitted.
  - `protect-main.merge-queue.apply.json`: snapshot writable fields plus a `merge_queue` rule appended to `rules`, with `check_response_timeout_minutes: 60`, `grouping_strategy: "ALLGREEN"`, `max_entries_to_build: 5`, `max_entries_to_merge: 5`, `merge_method: "MERGE"`, `min_entries_to_merge: 1`, `min_entries_to_merge_wait_minutes: 5`. `strict_required_status_checks_policy` remains `true`.
  - `protect-main.non-strict.alternative.json`: snapshot writable fields with `strict_required_status_checks_policy: false`; no `merge_queue` rule.
  - `protect-main.rollback.json`: snapshot writable fields unchanged.
- `ruleset/runbook.md` sections: preconditions (repository organization-owned or API acceptance of `merge_queue`; this item merged so `ci.yml` triggers on `merge_group`; admin-write token); capture a fresh GET and diff it against the snapshot before applying, regenerating the payload on any difference; apply command `gh api --method PUT repos/drmoisan/drm-copilot/rulesets/15241672 --input <file>`; post-apply verification (every required context reports on a `merge_group` run; two green PRs merge without `gh pr update-branch`); expected 422 failure mode on a user-owned repository; rollback command using `protect-main.rollback.json`; the non-strict alternative as a separate operator decision that removes the re-sync loop now but loses pre-merge combined validation; a note that `gh pr merge --admin` skips the queue for the bypass actor.

#### Required configuration keys and defaults:
- `ci.yml`: `merge_group: types: [checks_requested]`, no `branches` filter.
- `merge_queue` rule parameters: as listed under Inputs/outputs.
- Procedure polling defaults (assumption; see Assumptions): poll interval 30 seconds; total timeout 90 minutes, which exceeds the queue's `check_response_timeout_minutes` plus `min_entries_to_merge_wait_minutes`.
- Release-flow merge wait: interval and timeout exposed as parameters with the same defaults, so tests can drive them with the mocked `Invoke-Sleep` seam.

#### Backward-compatibility expectations:
- Without a queue, merges confirm on the first poll; procedure outcomes are unchanged.
- Behavior change: `gh pr merge --squash`, `-s`, `--rebase`, `-r`, `-m`, `--auto`, bare, and `--admin` invocations are now denied without a valid authorization record. With a valid record they are allowed, as `--merge` is today.
- `gh pr merge --merge` spellings that previously resolved no PR number (value-flag-led, URL selector, `--merge --auto <n>`) now resolve the number; decisions for those commands follow the number-matching branches rather than the no-number branches.
- The release flow no longer deletes the remote branch through `gh`; branch deletion relies on the repository's automatic head-branch deletion setting or an explicit post-confirmation step.

#### Performance constraints (latency/throughput/memory):
- Each PR now runs `ci.yml` on `pull_request` and, once a queue exists, again on `merge_group`. No per-item latency target is set by this item.
- The merge gate adds string inspection only; no network or process call.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - The snapshot is current as of 2026-10-16. The runbook requires a fresh GET and diff before any apply.
  - Procedure polling defaults (30-second interval, 90-minute timeout) are chosen by this spec; the orchestrator did not specify values.
  - The PUT endpoint semantics for omitted fields are undocumented; payloads therefore carry every writable field (research Q3).
  - The `merge_queue` parameter values other than `merge_method`, `grouping_strategy`, `min_entries_to_merge`, and `check_response_timeout_minutes` are common UI defaults not verified against documentation (research).
- Constraints (budget, performance, compatibility):
  - Resolved decision OQ-1: GitHub documents merge queues as available only for organization-owned repositories; `drmoisan/drm-copilot` is user-owned. The item proceeds: the `merge_group` trigger, queue-aware procedures, and gate hardening are correct with or without a queue, and the gate change closes existing bypasses (`--auto`, bare, `-m`, `--squash`/`--rebase` under a queue, `gh api` mutations). The ruleset deliverable is shipped, not applied; the merge-queue payload is marked in the runbook as applicable only once the repository is organization-owned or the API accepts the rule.
  - Resolved decision OQ-2: gate scope is method-agnostic as specified in Data flow and validation changes; both runtimes; new logic in new helper files because `.claude/hooks/enforce-epic-merge-gate.ps1` is at 472 lines; no gh-specific flags in `hook-command-invocation.ps1`.
  - Resolved decision OQ-3: `--admin` is gated like any merge; the runbook notes that it skips the queue for the bypass actor.
  - Resolved decision OQ-4: the snapshot supplies `conditions` (`~DEFAULT_BRANCH`, no wildcard).
  - Resolved decision OQ-5: `strict_required_status_checks_policy` stays `true` in the merge-queue payload.
  - Resolved decision OQ-6: `Invoke-FullReleaseFlow.ps1` is in scope.
  - Resolved decision OQ-7: orchestrate S9 step 6 receives the same confirmation sentence.
  - Resolved decision OQ-8: the parser lives at `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1`.
  - Resolved decision OQ-9: `merge_group` with `types: [checks_requested]` and no `branches` filter; only `ci.yml` is edited among workflows.
  - Policy files `.claude/rules/**` and `.github/instructions/**` are read-only for this item.
  - File size limit and no-temporary-file rule per `.claude/rules/general-code-change.md` and `.claude/rules/general-unit-test.md`.
- External dependencies (services, libraries, releases):
  - GitHub Actions `merge_group` event and the rulesets REST API.
  - `gh` CLI behavior as documented in research Q3 (enqueue exits 0; `--delete-branch` rejected under a queue; `--admin` bypasses the queue).

## Data / API / Config Impact
- User-facing or API changes:
  - Merge-gate decisions widen to every merge and enqueue spelling on both runtimes.
  - Procedures record `awaiting_merge_queue` when a queued merge does not complete within the timeout.
- Data or migration considerations:
  - Checkpoint fields `merge_commit_sha`, `merged_at`, `merge_status`, and `epic_merge` keep their existing shapes; `awaiting_merge_queue` is a new recorded outcome in procedure text. No schema migration is introduced by this item.
- Logging/telemetry updates (if any):
  - Parser error messages and release-flow stderr lines as listed under Error handling.
- Compatibility notes (CLI flags, config schemas, versioning):
  - `ci.yml` trigger set grows by one event; existing `push`, `pull_request`, and `workflow_dispatch` triggers are unchanged.
  - Pack manifests gain entries for the new hook helper files and parser.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: Pester tests for the merge-gate hooks' handling of `--auto` and queue mode, and for the queue-aware merge-confirmation logic.
- [x] Integration scenario to retest: after the ruleset is applied, queue two green PRs and confirm that both merge with no manual re-sync.
- [x] Manual verification notes: confirm every required check reports on a `merge_group` event.

- Regression tests to add or update:
  - `tests/scripts/workflows/CiWorkflow.Tests.ps1`: `merge_group` present in the trigger block with `checks_requested` and no `paths`/`branches` key under it; no workflow in the `ci.yml` call graph reads `github.event.pull_request`, `github.head_ref`, `github.base_ref`, or `github.event_name`, or declares `paths`/`paths-ignore`.
  - `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` and `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1`: scope and selector cases listed in AC-7 through AC-10.
  - `tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1`: every status mapping and error case.
  - `tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1`: pending → merged proceeds; pending → timeout stops before checkout and tag; `not_queued` and `closed` stop before checkout and tag.
  - Updated: `enforce-epic-merge-gate.Tests.ps1:37-41`, `enforce-epic-merge-gate.Authorization.Tests.ps1:102`, `codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1:95`, `Invoke-FullReleaseFlow.Tests.ps1:75,171,338`.
  - Pytest: `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` pins the new queue-aware fragments and mirror byte-identity.
- Unit tests (pytest) for the fixed behavior and boundaries: documentation contract and resource-parity tests only; production changes are PowerShell and YAML.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): `--merge --auto <n>`; value-flag-led selectors; `/pull/<n>` URL selector; pure `--disable-auto`; mention-only text; GraphQL read query; `MERGED` with empty commit; malformed JSON; null `mergeCommit` and `autoMergeRequest`; unrecognized `state`.
- Error handling and logging verification: parser throws with the `Invoke-MergeConfirmationParser:` prefix; release flow writes stderr and exits non-zero on each failure outcome; gate deny messages asserted by text.
- Coverage impact and targets for changed lines/modules: PowerShell line coverage on new and changed production files meets the line threshold in `.claude/rules/general-unit-test.md` (Pester has no branch metric); no regression on changed lines; new production files remain in the coverage denominator.
- Toolchain commands to run (format → lint → type-check → test): `Invoke-Formatter` → PSScriptAnalyzer → (type check skipped for PowerShell) → Pester; Python: Black → Ruff → Pyright → pytest for touched contract tests. Restart from formatting on any failure or auto-fix.
- Manual validation steps (if required): none before merge. Post-merge queue verification is a coordinator action (Rollout & Follow-up).


## Acceptance Criteria
- [x] AC-1: `.github/workflows/ci.yml` declares a `merge_group` trigger with `types: [checks_requested]` and no `branches`, `branches-ignore`, `paths`, or `paths-ignore` filter, and its existing `push`, `pull_request`, and `workflow_dispatch` triggers are unchanged. Verified by a new test in `tests/scripts/workflows/CiWorkflow.Tests.ps1`; existing tests in that file pass.
- [x] AC-2: No workflow in the `ci.yml` call graph (`ci.yml` and the reusable workflows it calls with `uses:`) reads `github.event.pull_request`, `github.head_ref`, `github.base_ref`, or `github.event_name`, or declares a `paths`/`paths-ignore` filter. Verified by a test in `tests/scripts/workflows/CiWorkflow.Tests.ps1`.
- [x] AC-3: Every context in `required_status_checks` of the snapshot (`ruleset/protect-main.current.2026-10-16.json`) is produced by a job of `ci.yml`, which triggers on `merge_group`. Verified by a static mapping of each snapshot context to its `ci.yml` caller job and reusable-workflow job, recorded under the feature folder's `evidence/` directory.
- [x] AC-4: `.github/workflows/README.md` lists `merge_group` among the `ci.yml` triggers and states that it serves a merge queue on `main`. Verified by static inspection of the file.
- [x] AC-5: `.claude/hooks/enforce-epic-merge-gate-command.ps1` and `.codex/hooks/enforce-epic-merge-gate-command.ps1` exist; each runtime's `enforce-epic-merge-gate.ps1` dot-sources its helper inside a guarded `try` with `Add-HookDependencyFailure`; `.claude/hooks/hook-command-invocation.ps1` is unchanged. Verified by `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` passing and `git diff --name-only main` not listing `hook-command-invocation.ps1`.
- [x] AC-6: With no authorization record, the Claude merge gate denies `gh pr merge <n>` with each of `--merge`, `-m`, `--squash`, `-s`, `--rebase`, `-r`, `--auto`, `--admin`, and with no method flag; and allows `gh pr merge <n> --disable-auto` and mention-only text. Verified by `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1`.
- [x] AC-7: With no authorization record, the Claude merge gate denies `gh api graphql` invocations containing `enqueuePullRequest`, `enablePullRequestAutoMerge`, or `mergePullRequest`, and `gh api` invocations targeting `repos/<owner>/<repo>/pulls/<n>/merge`; it allows a `gh api graphql` read query containing `isInMergeQueue` and none of those mutation names. Verified by `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1`.
- [x] AC-8: The Claude PR-number reader resolves the PR number for `gh pr merge --merge --auto 5`, `gh pr merge --subject x 5 --merge`, `gh pr merge -R o/r 5 --squash`, `gh pr merge --body-file f 5 -m`, and `gh pr merge https://github.com/o/r/pull/5 --merge`, and a gated command with a matching valid authorization record for PR 5 is allowed. Verified by `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1`.
- [x] AC-9: The Codex merge gate produces the same deny and allow outcomes as AC-6 and AC-7 and the same PR-number resolution as AC-8, using the Codex `$null`-for-allow convention. Verified by `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1`.
- [x] AC-10: The pinned `--squash` case in `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` (formerly `:37-41`) expects deny without a checkpoint; the `--squash` rows in `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1` and `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1` expect allow with a valid record; every existing merge-gate Pester suite on both runtimes passes.
- [x] AC-11: The header comments and deny messages of both runtimes' `enforce-epic-merge-gate.ps1` no longer state that `--squash` is out of scope and describe the method-agnostic scope. Verified by static inspection and by deny-message text assertions in the MergeQueue test files.
- [x] AC-12: `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` maps a snapshot to `merged` (MERGED with commit), `closed`, `pending` (OPEN with `isInMergeQueue` true or non-null `autoMergeRequest`), and `not_queued` (OPEN with neither), returning `MergeCommitSha` and `MergedAt` for `merged`; it throws on MERGED with an empty commit, malformed JSON, and an unrecognized `state`; null fields are handled. Verified by `tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1`.
- [x] AC-13: The parser's bundle mirror is byte-identical and the parser is listed in the Claude pack manifest. Verified by the manifest Pester test under `tests/scripts/claude-lib/ci-gate/` and the pytest pack-manifest completeness test.
- [x] AC-14: `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` invokes `gh pr merge <n> --merge` without `--delete-branch`, and no `git checkout main`, `git pull`, or tag command runs until the merge wait confirms `merged`. Verified by updated `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` and new `tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1`.
- [x] AC-15: The release-flow merge wait proceeds on pending → merged and stops with a non-zero exit and a stderr message, before any checkout, pull, or tag, on timeout, `not_queued`, and `closed`, using the mocked `Invoke-Sleep` seam with no real waits. Verified by `tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1`.
- [x] AC-16: `.claude/skills/parallel-orchestrate/SKILL.md` and `.claude/agents/parallel-orchestrator.md` keep "Execute `gh pr merge --merge <PR>`" verbatim and add, after it, queue-aware confirmation text covering: polling with a bounded interval and total timeout; recording `awaiting_merge_queue` on timeout; `git fetch` plus `git merge-base --is-ancestor` before recording `merged`; and routing `not_queued` to the conflict or remediation path without re-issuing the merge in a loop. The skill's strict up-to-date pacing paragraph notes that a merge queue replaces the `gh pr update-branch` cycle. Verified by fragment pins in `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` and `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` passing.
- [x] AC-17: `.claude/skills/orchestrate/SKILL.md` S9 step 6 and PR Creation Gate condition 7 state that `epic_merge.merge_commit_sha` is recorded only after the merge is confirmed by polling and ancestry check. Verified by a fragment pin in `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`.
- [x] AC-18: `.claude/skills/epic-orchestrate/SKILL.md` and `.claude/agents/epic-orchestrator.md` state the same confirmation requirement for the child-to-integration and integration-to-`main` merges. Verified by a fragment pin in `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`.
- [x] AC-19: `.agents/skills/epic-orchestrate/SKILL.md` and `.codex/agents/epic-orchestrator.toml` state that the final merge SHA is recorded only after the merge is confirmed by polling and ancestry check. Verified by a fragment pin in `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`.
- [x] AC-20: Every changed or new file under `.claude/`, `.codex/`, and `.agents/` has a byte-identical bundle mirror under `extensions/drm-copilot/resources/`, and new hook helper files are listed in the corresponding pack manifests. Verified by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, and `test_push_down_codex_and_agents_pack_manifest_completeness.py` passing.
- [x] AC-21: `ruleset/protect-main.merge-queue.apply.json` contains exactly the snapshot's writable fields (`name`, `target`, `enforcement`, `conditions`, `bypass_actors`, `rules`) with values equal to the snapshot, except that `rules` has a `merge_queue` rule appended with the parameters listed under Technical specifications, and `strict_required_status_checks_policy` remains `true`. Verified by a static JSON comparison against the snapshot recorded under the feature folder's `evidence/` directory.
- [x] AC-22: `ruleset/protect-main.non-strict.alternative.json` equals the snapshot's writable fields except `strict_required_status_checks_policy: false`, with no `merge_queue` rule. Verified by a static JSON comparison recorded under `evidence/`.
- [x] AC-23: `ruleset/protect-main.rollback.json` equals the snapshot's writable fields unchanged. Verified by a static JSON comparison recorded under `evidence/`.
- [x] AC-24: `ruleset/runbook.md` contains: preconditions; a capture-fresh-GET-and-diff step; the apply command `gh api --method PUT repos/drmoisan/drm-copilot/rulesets/15241672 --input <file>`; post-apply verification (every required context reports on a `merge_group` run; two green PRs merge without `gh pr update-branch`); the expected 422 failure mode on a user-owned repository; the rollback command; the non-strict alternative as a separate operator decision with its trade-off; and the `--admin` queue-skip note. Verified by static inspection.
- [x] AC-25: The branch diff against `main` does not modify `.github/workflows/_poshqc.yml`, any other workflow except `ci.yml` and `.github/workflows/README.md`, any file under `.claude/rules/` or `.github/instructions/`, `issue.md`, the research file, the plan file, or `ruleset/protect-main.current.2026-10-16.json`. Verified by `git diff --name-only main...HEAD`.
- [x] AC-26: Every production and test file created or modified by this item is within the 500-line limit of `.claude/rules/general-code-change.md`, and no new or changed test creates temporary files. Verified by a line-count check over the changed-file list and static review of the new tests.
- [ ] AC-27: The full toolchain loop passes in a single pass for PowerShell (Invoke-Formatter, PSScriptAnalyzer, Pester) and for touched Python tests (Black, Ruff, Pyright, pytest); PowerShell line coverage for new and changed production files meets the line threshold in `.claude/rules/general-unit-test.md` with no regression on changed lines. Verified by baseline, final-QA, and coverage-comparison artifacts under the feature folder's `evidence/` directory.
  - Amendment (2026-10-16, parallel-run coordinator under the operator's standing authority): the Codex helper's full-run line coverage of 74.07% is accepted as a Pester breakpoint attribution effect (scoped codex-hooks run 54/54); not met as written for that file; the 85% floor, the no-regression clause, and the no-exclusion rule still apply. Decision record: evidence/other/r1-decision.2026-10-16T23-10.md.
- [ ] AC-28 (CI-dependent): The `pull_request` CI run of `ci.yml` on the final PR head concludes `success` for every context in `required_status_checks` of the snapshot, demonstrating that the edited `ci.yml` parses and every required job reports. Verified from CI on the PR head at S9.

## Risks & Mitigations
- Technical or operational risks:
  - User-owned availability: the `merge_queue` rule is documented as unavailable for user-owned repositories, so the queue may not be enabled and issue #952's expected behavior may not be observable until ownership changes. A PUT with the rule is expected to return 422 (not observed).
  - #927 overlap: #927 may edit `enforce-epic-merge-gate*.ps1` (scope unverified). Overlap points are the scope-filter call site (`:334-358`), header, deny message, and the shared 500-line budget.
  - Parity and bundle tests: any `.claude`, `.codex`, or `.agents` edit without its byte-identical mirror, or any reworded pinned fragment, fails the resource-contract and documentation-contract tests.
  - Double CI cost: once a queue exists, each PR runs `ci.yml` on `pull_request` and again on `merge_group`, plus `push` on `main` after merge.
  - Merge-group failures invisible to S9: S9 reads PR-head checks; a failed merge-group run leaves the head green and returns the PR to `OPEN`.
  - Gate behavior change: `--squash`, `-s`, `--rebase`, `-r`, `-m`, `--auto`, bare, and `--admin` merges now require an authorization record; ad-hoc merges that relied on the exemption are denied.
  - File-size pressure: `Invoke-FullReleaseFlow.ps1` is at 401 lines and `Invoke-FullReleaseFlow.Tests.ps1` at 426; the merge wait may approach the limit.
  - PowerShell-tool route: `gh` invoked through the Claude PowerShell tool remains ungated (pre-existing, out of scope).
- Mitigations and rollbacks:
  - Availability: ship the payloads and runbook without applying; state the precondition and expected 422 in the runbook; document the non-strict alternative as a separate decision.
  - #927: keep new logic in the new helper files; rebase on `main` before PR creation and re-run the merge-gate suites.
  - Parity: update mirrors and manifests in the same change; append text after pinned fragments instead of rewording them.
  - Merge-group failures: the `not_queued` outcome routes to the conflict or remediation path and consumes a remediation attempt; no blind re-merge.
  - File size: if the release-flow wait would exceed the limit, extract it to a dot-sourced helper script with its own tests.
  - Rollback: revert the PR for code changes; apply `protect-main.rollback.json` for ruleset changes.

## Rollout & Follow-up
- Release/rollout steps:
  - Merge this item's PR after CI is green on its head (AC-28).
  - Coordinator action (not an AC of this item): when the repository is organization-owned or the API accepts the rule, follow `ruleset/runbook.md`: capture a fresh GET, diff against the snapshot, regenerate the payload if needed, apply `protect-main.merge-queue.apply.json`.
  - Coordinator action (not an AC of this item): post-apply verification. Confirm the `merge_queue` rule in a GET; enqueue one green PR and confirm every required context reports on a `merge_group` run; queue two green PRs and confirm both merge without `gh pr update-branch`; enqueue a `BEHIND` PR to confirm the queue accepts it with `strict_required_status_checks_policy: true`, applying a follow-up payload with `false` if it is refused. Roll back with `protect-main.rollback.json` if a required context does not report within `check_response_timeout_minutes`.
  - Coordinator decision (separate): whether to apply `protect-main.non-strict.alternative.json` in the meantime.
- Post-fix monitoring or clean-up tasks:
  - Follow-up (policy edit, requires approval): correct `.claude/rules/orchestrator-state.md:238` and `.claude/rules/parallel-orchestration.md:689` to describe the method-agnostic merge gate, and `.claude/rules/parallel-orchestration.md:154` whose field list names no merge-commit field.
  - Follow-up: update `.claude/skills/cleanup-merged-worktrees/SKILL.md:206-208` once a queue is applied.
  - Follow-up (optional): update `.github/workflows/README.md:34-75`, which documents the legacy branch-protection endpoint rather than the ruleset endpoint in use.
  - Follow-up: evaluate gating `gh` invocations issued through the Claude PowerShell tool.
  - Follow-up: the merge gate's `gh api` scope reads command text only, so a GraphQL mutation supplied from a file (`gh api graphql -F query=@mutation.graphql` or `gh api --input payload.json`) is not visible to the text-based gh api scope and is not gated; evaluate fail-closed handling for an `@file` query or `--input` (issue #952 code review CR-5).
- Links: issue https://github.com/drmoisan/drm-copilot/issues/952; research `research/research.2026-10-16T01-30.md`; snapshot `ruleset/protect-main.current.2026-10-16.json`; related items #927, #953.
