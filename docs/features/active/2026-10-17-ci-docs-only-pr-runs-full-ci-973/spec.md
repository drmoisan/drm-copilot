# 2026-10-17-ci-docs-only-pr-runs-full-ci (Spec)

- **Issue:** #973
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-17
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (acceptance criteria source: this file only)
- **Design source:** `docs/features/active/2026-10-17-ci-docs-only-pr-runs-full-ci-973/research/research.2026-10-17T12-25.md` (Recommendations adopted)
- **Environment facts:** `.claude/skills/execution-environment/SKILL.md` (referenced, not restated)

## Context

A pull request that changes only documentation still runs the full CI suite. The #962 change-scope gate skips heavy jobs only when it can compare against an earlier full green run on the same branch, so a new docs-only pull request (no prior green run) always decides `code=true reason=NO_FULL_GREEN_RUN`. Separately, the docs-only allowlist omits `docs/features/archive/`, `docs/features/parallel/` and `docs/features/epics/`, so archive moves and run-status documents never qualify.

Environment:
- OS/version: GitHub Actions runners (`.github/workflows/ci.yml` `Change scope` job)
- Python version: n/a
- Command/flags used: `scripts/ci/Invoke-CiChangeScope.ps1` with `scripts/ci/CiChangeScope.psm1` and `config/ci-docs-only-paths.json`
- Data source or fixture: PR #972 (records consolidation, docs only), run 39031193305, job 117391813610; PR #941 (archive moves)

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Repro & Evidence

Steps to Reproduce:
1. Branch from main and change only Markdown files under `docs/features/` (for example, move a folder from `docs/features/active/` to `docs/features/archive/`).
2. Open a pull request.
3. Read the `Change scope` job log.

Expected:
When every path changed relative to the pull request's merge base with main is on the docs-only allowlist, the heavy jobs are skipped on the first run, and the 11 required status checks still report success. Archive, parallel-run and epic documentation paths are on the allowlist.

Actual:
The `Change scope` job logs `code=true reason=NO_FULL_GREEN_RUN` and every heavy job runs (PowerShell QC shards 1 to 3, the Linux hook suites, four Python legs, shell coverage). PR #972 (455 renames, 4 additions, 3 modifications, all under `docs/features/`) took a full run. With the base gap fixed, the archive renames would still fail the allowlist check (`NON_ALLOWLISTED_PATH`) because `docs/features/archive/` is not an include prefix.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: `2026-10-17T12:06:13.2781666Z code=true reason=NO_FULL_GREEN_RUN` (job 117391813610)

## Problem Statement and Root Cause

### Problem statement

A docs-only pull request into `main` cannot skip heavy CI jobs on its first run, and archive, parallel-run and epic documentation paths are never classified as docs-only. Every such pull request consumes a full CI run without changing any code.

### Root cause

1. **Base selection gap.** `Find-CiChangeScopeBase` in `scripts/ci/Invoke-CiChangeScope.ps1` selects the comparison base only from earlier full green runs on the same branch (`Select-CiGreenBaseCandidates` in `scripts/ci/CiChangeScope.psm1`). When no candidate qualifies, the function returns `NO_FULL_GREEN_RUN` and `Resolve-CiChangeScopeDecision` ends with `code=true`. The pull request's merge base with `main`, which is a commit that passed CI before it entered `main`, is never considered.
2. **Allowlist gap.** `config/ci-docs-only-paths.json` `include_prefixes` lists only `docs/features/active/`, `docs/features/completed/`, `docs/features/potential/` and `docs/research/`.
3. **Scope history.** #962 was scoped to the evidence-commit case (the second run of the triple CI run). The new-docs-only-pull-request case was not covered. This is a scope gap in #962, not a regression.
4. **Input gap.** The `changes` job in `.github/workflows/ci.yml` passes no base SHA or base ref to the `scope` step, so the script has no payload-supplied anchor from which to compute a merge base.

## Scope & Non-Goals

### In scope

- Merge-base fallback in the change-scope decision for pull requests whose base ref is exactly `main`.
- Fail-closed handling of every merge-base resolution failure with a new reason code `MERGE_BASE_UNRESOLVED`.
- Two new env inputs (`BASE_SHA`, `BASE_REF`) on the `scope` step of the `changes` job in `.github/workflows/ci.yml`.
- Three new include prefixes in `config/ci-docs-only-paths.json`.
- Test rows that pin two-sided rename classification on both the green-run diff and the merge-base diff.
- Updates to the execution-environment brief bullet and to `.github/workflows/README.md` section `## Change-Scope Decision (Issue #962)`.

### Out of scope / non-goals

- Any change to event or fork gating (`push`, `merge_group`, `workflow_dispatch`, fork pull requests).
- Any change to the green-run primary path, its reason codes, or its terminal failure codes.
- A merge-base fallback for pull requests into `development` or `epic/**`.
- Any change to the required-context set, the ruleset, or the `CI full run` marker job.
- Any production change to rename handling (the existing diff argument list already lists both sides of a rename).
- New exclude prefixes.
- Changes to `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1` (intentionally not written; see Test Strategy).

### Explicitly excluded systems, integrations, or datasets

- GitHub rulesets and branch protection settings.
- The `pull_request_target` trigger (not used by `ci.yml`).
- Remote-tracking refs (`origin/<base>`); the design does not depend on them.

## Design Decisions (binding)

- **D1:** the merge-base fallback applies only when the PR base ref is exactly `main`; `development` and `epic/**` bases keep the #962 behavior.
- **D2:** fallback triggers are NO_FULL_GREEN_RUN, BASE_NOT_PRESENT, BASE_NOT_ANCESTOR; RUN_LIST_FAILED, JOB_LIST_FAILED, ANCESTRY_CHECK_FAILED remain terminal full runs.
- **D3:** `git diff --name-only --no-renames` lists both the old and the new path of a rename (confirmed locally by the orchestrator), so two-sided rename classification is pinned by tests, not by a production change; the merge-base path reuses the same diff argument list.
- **D4:** the merge base is computed from the payload base SHA (new `BASE_SHA` and `BASE_REF` env lines in the `changes` job of .github/workflows/ci.yml) with `git cat-file -e` then `git merge-base <BASE_SHA> <HEAD_SHA>`, output validated as one full SHA; failure of any step gives `code=true` reason `MERGE_BASE_UNRESOLVED`; success with an all-allowlisted diff gives `code=false` reason `DOCS_ONLY_SINCE_MERGE_BASE_<sha>`.
- **D5:** add `docs/features/archive/`, `docs/features/parallel/`, `docs/features/epics/` to `include_prefixes` in config/ci-docs-only-paths.json; no new exclude prefix.
- **D6:** `push`, `merge_group`, `workflow_dispatch` and fork pull requests keep never-skip semantics from #962 unchanged; push CI on main after a docs-only merge always runs in full.
- **D7:** the execution-environment brief bullet `Change-scope decision (issue #962)` (six byte-identical copies listed in research section 7) and `.github/workflows/README.md` `## Change-Scope Decision (Issue #962)` are updated in the same change.
- **D8 (S9 proof):** the positive skip path cannot be exercised before merge because the script runs from the PR head and any PR carrying the new script has code in its merge-base diff. CI-dependent criteria verified at S9 on the item's own PR: (a) the first CI run's `Change scope` log shows `code=true reason=NON_ALLOWLISTED_PATH:` (not `NO_FULL_GREEN_RUN`) with summary `base=<merge base sha>`, `CI full run` succeeds and all 11 required contexts report success; (b) a later docs-only evidence commit on the same PR logs `code=false reason=DOCS_ONLY_SINCE_<green head sha>` with all 11 required contexts success (the #962 primary path is intact). A separate post-merge criterion: the first docs-only pull request into main after merge (this feature folder's archive move) logs `code=false reason=DOCS_ONLY_SINCE_MERGE_BASE_<sha>`, heavy jobs skipped, all 11 required contexts success.

Supplementary decisions adopted from the research Recommendations:

- The green-run base stays the primary comparison; the merge base is a fallback only.
- `BaseSha` and `BaseRef` are not added to the required-context throw list (`CI_CHANGE_SCOPE_CONTEXT_INVALID`). They are read only at the fallback step, so a blank value cannot produce `UNEXPECTED_ERROR` on the primary path.
- The merge-base diff is an explicit two-dot diff from the computed merge base, not `git diff base...head`, so that the merge-base SHA is logged and resolution failure has a distinct reason.
- No new production `.ps1` or `.psm1` file is created.

## Proposed Fix

### Design summary (what changes where)

| Area | Change | File |
|---|---|---|
| Pure decision helpers | Add `Test-CiMergeBaseFallbackApplicable` and `ConvertFrom-CiMergeBaseOutput`; export both. No I/O. | `scripts/ci/CiChangeScope.psm1` |
| Orchestration | Read `BASE_SHA` and `BASE_REF`; add `Find-CiChangeScopeMergeBase`; extract the shared diff-and-classify helper `Get-CiChangeScopeDiffDecision`; insert the fallback step into `Resolve-CiChangeScopeDecision`; update `.DESCRIPTION`. | `scripts/ci/Invoke-CiChangeScope.ps1` |
| Workflow input | Add `BASE_SHA` and `BASE_REF` env lines to step `scope` of job `changes`. | `.github/workflows/ci.yml` |
| Allowlist | Add three include prefixes. | `config/ci-docs-only-paths.json` |
| Documentation | Brief bullet (all copies) and workflows README section. | see Files to Be Written |

### Decision order after the fix (`Resolve-CiChangeScopeDecision`)

1. **Event and fork gate (unchanged).** `merge_group`, `push`, `workflow_dispatch` give `EVENT_NOT_PULL_REQUEST`. A fork gives `FORK_PULL_REQUEST`. Neither invoker is called.
2. **Required context check (unchanged).** A blank `HeadSha`, `HeadRef`, `Repository` or `RunId` throws `CI_CHANGE_SCOPE_CONTEXT_INVALID`. `BaseSha` and `BaseRef` are not in this list.
3. **Config parse (unchanged).**
4. **Green-run base (unchanged).** `RUN_LIST_FAILED` and `JOB_LIST_FAILED` are terminal full runs. On the green-run path, `ANCESTRY_CHECK_FAILED`, `DIFF_FAILED`, `EMPTY_DIFF` and `NON_ALLOWLISTED_PATH` are terminal. A docs-only green-run diff gives `code=false reason=DOCS_ONLY_SINCE_<green head sha>`.
5. **Fallback trigger set.** The primary reason is one of `NO_FULL_GREEN_RUN`, `BASE_NOT_PRESENT`, `BASE_NOT_ANCESTOR`.
6. **Fallback applicability.** `BaseRef -ceq 'main'`. Otherwise the primary reason is returned unchanged with `code=true`.
7. **Merge-base resolution.** `BaseSha` non-blank; `git cat-file -e <BaseSha>^{commit}` exits 0; `git merge-base <BaseSha> <HeadSha>` exits 0 and its output is exactly one full SHA. Any failure gives `code=true reason=MERGE_BASE_UNRESOLVED` with `BaseSha` blank.
8. **Merge-base diff.** Same argument list as the primary diff (`--name-only -z --no-renames --no-color --no-ext-diff --no-relative <mb> <head>`). Failure gives `DIFF_FAILED`; an empty diff gives `EMPTY_DIFF`; any rejected path gives `NON_ALLOWLISTED_PATH: <path>`; otherwise `code=false reason=DOCS_ONLY_SINCE_MERGE_BASE_<mb>`. In every step-8 outcome `BaseSha` is the merge base and the summary records `base=<mb>`.
9. **Envelope (unchanged).** Any throw gives `UNEXPECTED_ERROR` plus a `::warning::` line.

### Reason codes

| Reason | `code` | Status | Origin step |
|---|---|---|---|
| `EVENT_NOT_PULL_REQUEST` | true | unchanged | 1 |
| `FORK_PULL_REQUEST` | true | unchanged | 1 |
| `RUN_LIST_FAILED` | true | unchanged, terminal (no fallback) | 4 |
| `JOB_LIST_FAILED` | true | unchanged, terminal (no fallback) | 4 |
| `NO_FULL_GREEN_RUN` | true | unchanged; now a fallback trigger; final only when the base ref is not `main` | 4/6 |
| `BASE_NOT_PRESENT` | true | unchanged; now a fallback trigger; final only when the base ref is not `main` | 4/6 |
| `BASE_NOT_ANCESTOR` | true | unchanged; now a fallback trigger; final only when the base ref is not `main` | 4/6 |
| `ANCESTRY_CHECK_FAILED` | true | unchanged, terminal (no fallback) | 4 |
| `DIFF_FAILED` | true | unchanged; now also emitted on the merge-base path | 4/8 |
| `EMPTY_DIFF` | true | unchanged; now also emitted on the merge-base path | 4/8 |
| `NON_ALLOWLISTED_PATH: <path>` | true | unchanged; now also emitted on the merge-base path | 4/8 |
| `DOCS_ONLY_SINCE_<sha>` | false | unchanged (green-run path) | 4 |
| `MERGE_BASE_UNRESOLVED` | true | **new** | 7 |
| `DOCS_ONLY_SINCE_MERGE_BASE_<sha>` | false | **new**; satisfies the existing `DOCS_ONLY_SINCE_` guard in `New-CiChangeScopeDecision` | 8 |
| `UNEXPECTED_ERROR` | true | unchanged | 9 |

### Boundaries and invariants to preserve

- `scripts/ci/CiChangeScope.psm1` performs no I/O and runs no git or gh command (pinned by the `module structure` row).
- `Invoke-CiChangeScopeNative` remains the only process boundary.
- `code=false` is produced only with a reason that starts with `DOCS_ONLY_SINCE_` (enforced by `New-CiChangeScopeDecision`).
- The fork gate runs before any payload value other than the event name and repositories is consulted.
- The output order `Output`, `Log`, `Summary` is unchanged.
- The step stays `continue-on-error: true`; downstream jobs treat any missing or non-`false` output as a full run (unchanged #962 contract).

### Dependencies or blocked work

None. #962 is merged. The fix depends only on the `actions/checkout@v7` configuration already in the `changes` job (`fetch-depth: 0`, `filter: blob:none`).

### Implementation strategy (what changes, not sequencing)

#### Files/modules to change

See `## Files to Be Written`.

#### Functions/classes/CLI commands impacted

- `scripts/ci/CiChangeScope.psm1`
  - New `Test-CiMergeBaseFallbackApplicable -PrimaryReason <string> -BaseRef <string>`: `$true` only when the reason is in the D2 trigger set and `BaseRef -ceq 'main'`.
  - New `ConvertFrom-CiMergeBaseOutput -Text <string>`: returns the SHA when the text is exactly one line of 40 lower-case hex characters (64 accepted for SHA-256 repositories), with at most one trailing LF; otherwise `''`.
  - `Export-ModuleMember` lists both new functions.
- `scripts/ci/Invoke-CiChangeScope.ps1`
  - `Get-CiChangeScopeContext` reads `BASE_SHA` and `BASE_REF` through the existing `-ReadVariable` seam.
  - New `Find-CiChangeScopeMergeBase -BaseSha -HeadSha -GitInvoker` returns `{ Reason; BaseSha }`.
  - New `Get-CiChangeScopeDiffDecision -BaseSha -HeadSha -Config -GitInvoker -DocsOnlyReasonPrefix`, used by both the green-run path and the merge-base path.
  - `Resolve-CiChangeScopeDecision` gains steps 5 to 8.

#### Data flow and validation changes

GitHub event payload (`pull_request.base.sha`, `base_ref`) -> `ci.yml` env -> `Get-CiChangeScopeContext` -> `Resolve-CiChangeScopeDecision` -> fallback applicability (pure) -> `Find-CiChangeScopeMergeBase` (git via invoker) -> `ConvertFrom-CiMergeBaseOutput` (pure validation) -> `Get-CiChangeScopeDiffDecision` -> `New-CiChangeScopeDecision`.

#### Error handling and logging updates

- Every merge-base resolution failure maps to `MERGE_BASE_UNRESOLVED` (fail closed, `code=true`).
- The log line and step summary carry the new reason codes and `base=<mb>` on step-8 outcomes.
- No new warning path; the envelope's `UNEXPECTED_ERROR` warning is unchanged.

#### Rollback/feature-flag considerations

No feature flag. Rollback is a revert of the change. Every failure mode of the new code yields `code=true`, so a defect in the fallback cannot cause an unintended skip without also producing a `DOCS_ONLY_SINCE_` reason from a fully allowlisted diff.

### Technical specifications (interfaces/contracts)

#### Inputs/outputs and formats (env contract of step `scope`)

| Variable | Source expression | Required | Use |
|---|---|---|---|
| `GH_TOKEN` | unchanged | yes (pull requests) | gh run and job listing |
| `EVENT_NAME` | unchanged | yes | event gate |
| `HEAD_SHA` | unchanged | yes | diff head |
| `HEAD_REF` | unchanged | yes | run-list branch filter |
| `HEAD_REPO` | unchanged | yes | fork gate |
| `REPOSITORY` | unchanged | yes | fork gate, API paths |
| `RUN_ID` | unchanged | yes | excludes the current run |
| `BASE_SHA` | `${{ github.event.pull_request.base.sha }}` | **new**, optional | merge-base anchor; blank gives `MERGE_BASE_UNRESOLVED` only when the fallback applies |
| `BASE_REF` | `${{ github.base_ref }}` | **new**, optional | compared to `main` only (`-ceq`); never passed to git |

`BASE_SHA` and `BASE_REF` are empty on `merge_group`, `push` and `workflow_dispatch`; the decision returns at step 1 before reading them.

Outputs are unchanged in shape: `GITHUB_OUTPUT` line `code=<true|false>`, log line `code=<x> reason=<r>`, summary `Change scope: code=<x>; reason=<r>; base=<sha or none>`.

#### Required configuration keys and defaults

`config/ci-docs-only-paths.json` `include_prefixes` after the fix (ordinal sort): `docs/features/active/`, `docs/features/archive/`, `docs/features/completed/`, `docs/features/epics/`, `docs/features/parallel/`, `docs/features/potential/`, `docs/research/`. `exclude_prefixes` and `extensions` unchanged. `version` stays 1.

#### Backward-compatibility expectations

- All existing reason codes keep their spelling and `code` value.
- Pull requests into `development` and `epic/**` behave exactly as under #962.
- Existing rows in `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1` pass unmodified because their contexts carry no `BaseRef` key.

#### Performance constraints

The fallback adds at most three git invocations (`cat-file`, `merge-base`, `diff`) against local objects. No additional API calls. No measurable change to the `Change scope` job duration is expected.

## Security and Trust Analysis

- **Trust assumption.** The fallback trusts that the merge-base commit on `main` was validated. `main` accepts merges only after the required contexts of ruleset 15241672 pass, and every push to `main` runs a full CI run (D6). A docs-only pull request changes no code, so its `success` makes no claim about code.
- **Input provenance.** `BASE_SHA` and `BASE_REF` come from the GitHub event payload, not from the head commit. `BASE_REF` is only compared to the literal `main` and is never passed to a process, so ref-name injection is not possible. `BASE_SHA` is passed to git only after the event and fork gates, and only as an argument array element through `Invoke-CiChangeScopeNative`; the merge-base output is validated as one full SHA before use.
- **Stale base SHA fails safe.** If `base.sha` is older than a `main` merge that the head already contains, `git merge-base` returns `base.sha`, and the diff includes `main`'s intervening changes. That can only add paths, turning a skip into a full run, never the reverse.
- **Allowlist self-protection.** `config/ci-docs-only-paths.json` is under `config/`, which is not an include prefix, so a pull request that edits the allowlist always runs in full (pinned by the existing row 'Test-CiDocsOnlyPath rejects config/ci-docs-only-paths.json').

### Residual risks

1. **Untested combinations on `main`.** Under non-strict required checks, `main` can contain a combination of pull requests that was never tested together. A docs-only pull request then reports green while `main`'s push run may be red. Visibility comes from the `main` push run. This risk predates and does not depend on this fix.
2. **Non-main bases.** `epic/**` has no push CI and the protection status of `development` is unconfirmed. Mitigation: D1 restricts the fallback to base `main`.
3. **Forks.** The fork gate stays first, so fork payload values are never consulted (D6).
4. **Partial or shallow history.** A checkout without the base commit yields `MERGE_BASE_UNRESOLVED` (full run), not a skip. If the item's own pull request logs `MERGE_BASE_UNRESOLVED`, the checkout configuration requires investigation before merge.

## Assumptions, Constraints, Dependencies

- Assumptions: the `changes` job checkout keeps `fetch-depth: 0` and `filter: blob:none`; commits and trees are present, which is all that `git merge-base` and `git diff --name-only --no-renames` require. When GitHub refreshes `pull_request.base.sha` on `synchronize` is unconfirmed; the safety argument does not depend on it.
- Constraints: 500-line limit per PowerShell file (projected: `CiChangeScope.psm1` about 400, `Invoke-CiChangeScope.ps1` about 340, `CiChangeScope.Tests.ps1` about 385, `CiDocsOnlyPathsConfig.Tests.ps1` about 115, new merge-base test file about 250). `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1` is not extended. Batch budget: two PowerShell production files.
- External dependencies: GitHub Actions event payload fields `pull_request.base.sha` and `base_ref`.

## Data / API / Config Impact

- User-facing or API changes: two new reason codes in the `Change scope` log and summary.
- Data or migration considerations: none.
- Logging/telemetry updates: summary `base=<mb>` on merge-base outcomes.
- Compatibility notes: `config/ci-docs-only-paths.json` schema unchanged; three new prefix values.

## Files to Be Written

Repository-relative; from the research Recommendations list.

- `scripts/ci/CiChangeScope.psm1`
- `scripts/ci/Invoke-CiChangeScope.ps1`
- `.github/workflows/ci.yml`
- `config/ci-docs-only-paths.json`
- `tests/scripts/ci/CiChangeScope.Tests.ps1`
- `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`
- `tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1` (new)
- `tests/scripts/workflows/CiWorkflow.Tests.ps1`
- `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`
- `.github/workflows/README.md`
- `.claude/skills/execution-environment/SKILL.md`
- `.agents/skills/execution-environment/SKILL.md`
- `.github/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`

Intentionally not written: `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1`.

Documentation content requirements:
- Brief bullet `Change-scope decision (issue #962)` under `## CI Shape and Required Checks`, identical in every brief copy listed above: states the merge-base fallback, its trigger reasons, that it applies only to base `main`, the seven include prefixes, `MERGE_BASE_UNRESOLVED` in the full-run list, and that both sides of a rename are classified; the "no earlier full green run" full-run condition becomes conditional on the base not being `main` or the merge base being unresolved; the merge-base reason is written with a placeholder (`DOCS_ONLY_SINCE_MERGE_BASE_<merge base sha>`), with no line-number or commit-SHA citation; all tokens required by `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` are retained.
- `.github/workflows/README.md` `## Change-Scope Decision (Issue #962)` (heading may become `(Issues #962 and #973)`): `### Decision` gains the fallback paragraph; the reason-code list gains `DOCS_ONLY_SINCE_MERGE_BASE_<merge base sha>` and `MERGE_BASE_UNRESOLVED`; `### Allowlist` lists the seven prefixes; `### Fail-closed rules` covers `MERGE_BASE_UNRESOLVED` and the base-ref restriction.

## Test Strategy

Seeded from issue:

- [x] Unit coverage areas: when no full green run exists on the branch, fall back to the PR merge base with main as the comparison base (main merges only after passing CI under the non-strict ruleset, and push CI on main is confirmed after every merge); decide `code=false` with a `DOCS_ONLY_SINCE_` reason only when every changed path, including both sides of each rename, is allowlisted. Add `docs/features/archive/`, `docs/features/parallel/` and `docs/features/epics/` to `include_prefixes`. Pester rows for: merge-base fallback skip, merge-base fallback with one non-allowlisted path (full run), rename whose source or destination is outside the allowlist (full run), each new prefix, and fail-closed behavior when the merge base cannot be resolved.
- [x] Integration scenario to retest: a docs-only PR (archive move) whose first CI run skips the heavy jobs with all 11 required checks green; then a commit touching a non-allowlisted path on the same PR returns to a full run.
- [ ] Manual verification notes: confirm push CI on main still runs in full after a docs-only merge, or document the intended main-push behavior. Answered by design (D6) and by the existing never-skip rows; live confirmation is one `gh run view` of the `main` push run after merge.

### Updated existing rows (with dispositions)

| File | Row | Disposition |
|---|---|---|
| `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1` | 'configures exactly the D3 include prefixes and extensions (AC-15)' | **Update** exact string to the seven-prefix ordinal list. Add a `-ForEach` row asserting each new prefix is listed. 'does not let any include prefix cover <Path>' rows stay valid. |
| `tests/scripts/ci/CiChangeScope.Tests.ps1` | 'defines only the eight pure functions ... (AC-17)' | **Update** `$expected` with `Test-CiMergeBaseFallbackApplicable` and `ConvertFrom-CiMergeBaseOutput`; adjust the wording. |
| `tests/scripts/workflows/CiWorkflow.Tests.ps1` | 'reads no pull-request event field and declares no path filter anywhere in the ci.yml call graph' | **Update** `$allowedEventFieldLines` with `BASE_SHA: ${{ github.event.pull_request.base.sha }}` and `BASE_REF: ${{ github.base_ref }}`; adjust the comment. Without this update the row fails as soon as `ci.yml` changes. |
| `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` | existing rows | **Unchanged**; add one row (below). |
| `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1` | all rows | **Unchanged**; contexts carry no `BaseRef`, so the fallback does not apply and every existing reason is preserved. |
| `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` | all rows | **Unchanged**; must pass after the brief edit. |

### New rows in existing files

- `tests/scripts/ci/CiChangeScope.Tests.ps1`:
  - `Test-CiDocsOnlyPath` accepts a path under each new prefix (local config containing them).
  - `Get-CiChangeScopePathDecision` gives `NON_ALLOWLISTED_PATH` for a two-sided rename list in each direction across the allowlist boundary.
  - `Test-CiMergeBaseFallbackApplicable` truth table: each trigger reason with `main` gives true; `development`, `epic/x`, `''`, `Main` give false; `RUN_LIST_FAILED`, `JOB_LIST_FAILED`, `ANCESTRY_CHECK_FAILED` with `main` give false.
  - `ConvertFrom-CiMergeBaseOutput`: valid SHA returned; empty, multi-line, short, upper-case, non-hex and whitespace-padded input return `''`.
- `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`: step `scope` of job `changes` carries both new env lines with the exact expressions.

### New test file `tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1`

Dot-sources the entry script; compact in-memory fakes; the fake git invoker distinguishes `merge-base --is-ancestor` from bare `merge-base <a> <b>`. Rows:

1. No green run, base `main`, docs-only merge-base diff: `code=false`, log `code=false reason=DOCS_ONLY_SINCE_MERGE_BASE_<mb>`, summary `base=<mb>`.
2. Same with one non-allowlisted path: `NON_ALLOWLISTED_PATH: <path>`.
3. Rename out of the allowlist and rename into the allowlist: full run in each direction.
4. Each new prefix (`archive`, `parallel`, `epics`) through the merge-base path using the committed config.
5. `MERGE_BASE_UNRESOLVED` for: blank `BaseSha`; `cat-file` non-zero; `merge-base` exit 1; `merge-base` exit 128; empty output; non-SHA output; multi-line output.
6. `BASE_NOT_ANCESTOR` and `BASE_NOT_PRESENT` primary reasons fall back with base `main`.
7. Base `development` and `epic/x` keep `NO_FULL_GREEN_RUN`, and no bare `merge-base` call is made.
8. `RUN_LIST_FAILED` and `JOB_LIST_FAILED` do not fall back, with base `main`.
9. Merge-base diff failure gives `DIFF_FAILED`; empty merge-base diff gives `EMPTY_DIFF`.
10. The merge-base diff uses the same flag list plus `<mb> <head>`.
11. `push`, `merge_group`, `workflow_dispatch` and a fork pull request with `BaseRef=main` decide before any invoker call.
12. `Get-CiChangeScopeContext` reads `BASE_SHA` and `BASE_REF`.

Rows use fakes, not blanket mocks; helpers live in `BeforeAll`; no environment variables are changed and no files are created.

### Gates

- Toolchain loop per `.claude/rules/general-code-change.md` and `.claude/rules/powershell.md` (format, lint, tests; type check skipped for PowerShell).
- Line coverage >= 85% for each changed PowerShell production file (`scripts/ci/CiChangeScope.psm1`, `scripts/ci/Invoke-CiChangeScope.ps1`), read from `artifacts/pester/powershell-coverage.xml`. No branch gate applies to PowerShell.
- File size <= 500 lines for every changed or new PowerShell file, confirmed by physical line count.
- Isolation per the execution-environment brief: at least three seeded shuffled file-order runs of the touched Pester suites (`CiChangeScope.Tests.ps1`, `CiDocsOnlyPathsConfig.Tests.ps1`, `Invoke-CiChangeScope.Tests.ps1`, `Invoke-CiChangeScopeMergeBase.Tests.ps1`, `CiWorkflow.Tests.ps1`, `CiChangeScopeWorkflow.Tests.ps1`) with each seed recorded, and one fresh single-process run over `tests/scripts`.
- Contract tests after the brief edit: `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`.
- Evidence written under `<FEATURE>/evidence/regression-testing/` and `<FEATURE>/evidence/qa-gates/` with UTC timestamps and no absolute paths.

## Acceptance Criteria

- [x] With no full green run, base ref `main`, and an all-allowlisted merge-base diff, the decision is `code=false` with log `code=false reason=DOCS_ONLY_SINCE_MERGE_BASE_<mb>` and summary `base=<mb>`, pinned by a row in `tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1`.
- [x] With base ref `main` and a merge-base diff containing one non-allowlisted path, the decision is `code=true reason=NON_ALLOWLISTED_PATH: <path>`, pinned by a row in the new test file.
- [x] A rename from a non-allowlisted path into an allowlisted path yields `code=true reason=NON_ALLOWLISTED_PATH:` on both the green-run diff and the merge-base diff, pinned by rows in `tests/scripts/ci/CiChangeScope.Tests.ps1` and the new test file.
- [x] A rename from an allowlisted path to a non-allowlisted path yields `code=true reason=NON_ALLOWLISTED_PATH:` on both the green-run diff and the merge-base diff, pinned by rows in `tests/scripts/ci/CiChangeScope.Tests.ps1` and the new test file.
- [x] A Markdown path under `docs/features/archive/` is accepted by `Test-CiDocsOnlyPath` with the committed config and reaches `DOCS_ONLY_SINCE_MERGE_BASE_<mb>` through the merge-base path.
- [x] A Markdown path under `docs/features/parallel/` is accepted by `Test-CiDocsOnlyPath` with the committed config and reaches `DOCS_ONLY_SINCE_MERGE_BASE_<mb>` through the merge-base path.
- [x] A Markdown path under `docs/features/epics/` is accepted by `Test-CiDocsOnlyPath` with the committed config and reaches `DOCS_ONLY_SINCE_MERGE_BASE_<mb>` through the merge-base path.
- [x] A blank `BASE_SHA` with base ref `main` and a fallback trigger yields `code=true reason=MERGE_BASE_UNRESOLVED` with summary `base=none`.
- [x] A non-zero `git cat-file -e <BASE_SHA>^{commit}` exit yields `code=true reason=MERGE_BASE_UNRESOLVED`.
- [x] A non-zero `git merge-base <BASE_SHA> <HEAD_SHA>` exit (rows for exit 1 and exit 128) yields `code=true reason=MERGE_BASE_UNRESOLVED`.
- [x] `git merge-base` output that is empty, multi-line, or not a full lower-case hex SHA yields `code=true reason=MERGE_BASE_UNRESOLVED`, and `ConvertFrom-CiMergeBaseOutput` returns `''` for each such input.
- [x] `BASE_NOT_PRESENT` and `BASE_NOT_ANCESTOR` primary reasons with base ref `main` fall back to the merge-base path, pinned by rows in the new test file.
- [x] With base ref `development` or `epic/x` and no green run, the decision stays `code=true reason=NO_FULL_GREEN_RUN` and no bare `git merge-base <a> <b>` call is made.
- [x] `RUN_LIST_FAILED` and `JOB_LIST_FAILED` with base ref `main` remain the final reasons with `code=true`, and no merge-base resolution call is made.
- [x] `push`, `merge_group`, `workflow_dispatch` and a fork pull request with `BaseRef=main` still decide `EVENT_NOT_PULL_REQUEST` or `FORK_PULL_REQUEST` before any gh or git invoker call, and every existing row in `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1` passes unmodified.
- [x] Step `scope` of job `changes` in `.github/workflows/ci.yml` carries `BASE_SHA: ${{ github.event.pull_request.base.sha }}` and `BASE_REF: ${{ github.base_ref }}`, and `tests/scripts/workflows/CiWorkflow.Tests.ps1` and `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` pass, including the updated event-field allowlist row and the new env-line row.
- [x] `config/ci-docs-only-paths.json` `include_prefixes` equals the ordinal list `docs/features/active/`, `docs/features/archive/`, `docs/features/completed/`, `docs/features/epics/`, `docs/features/parallel/`, `docs/features/potential/`, `docs/research/` with `exclude_prefixes` unchanged, pinned by the updated exact-string row in `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`.
- [x] The brief bullet `Change-scope decision (issue #962)` is updated with the merge-base fallback, its trigger reasons, the base-`main` restriction, every include prefix named in the `config/ci-docs-only-paths.json` criterion above, `MERGE_BASE_UNRESOLVED`, and two-sided rename classification, identically in every copy listed in `## Files to Be Written`, and `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` passes (including `test_brief_copies_are_byte_identical`).
- [x] The push-down resource contract tests `test_push_down_claude_resource_contracts.py` and `test_push_down_codex_and_agents_resource_contracts.py` pass after the brief edit.
- [x] `.github/workflows/README.md` change-scope section documents the fallback in `### Decision`, lists `DOCS_ONLY_SINCE_MERGE_BASE_<merge base sha>` and `MERGE_BASE_UNRESOLVED` in the reason-code list, lists every include prefix named in the `config/ci-docs-only-paths.json` criterion above in `### Allowlist`, and covers `MERGE_BASE_UNRESOLVED` and the base-`main` restriction in `### Fail-closed rules`.
- [x] `scripts/ci/CiChangeScope.psm1` and `scripts/ci/Invoke-CiChangeScope.ps1` each report line coverage >= 85% in `artifacts/pester/powershell-coverage.xml`, recorded under `<FEATURE>/evidence/qa-gates/`.
- [x] Every changed or new PowerShell file listed in `## Files to Be Written` is at most 500 physical lines.
- [x] At least three seeded shuffled file-order runs of the touched Pester suites pass with each seed recorded, and one fresh single-process run over `tests/scripts` passes, recorded under `<FEATURE>/evidence/regression-testing/`.
- [x] (CI-dependent, verified at S9) The first CI run on the item's pull request logs `code=true reason=NON_ALLOWLISTED_PATH:` (not `NO_FULL_GREEN_RUN`) in `Change scope` with summary `base=<merge base sha>`, `CI full run` succeeds, and every required context of ruleset 15241672 listed in the execution-environment brief reports success.
- [ ] (CI-dependent, verified at S9) A later docs-only evidence commit on the item's pull request logs `code=false reason=DOCS_ONLY_SINCE_<green head sha>` in `Change scope`, and every required context of ruleset 15241672 listed in the execution-environment brief reports success.
- [ ] (post-merge) The first docs-only pull request into `main` after merge (this feature folder's archive move) logs `code=false reason=DOCS_ONLY_SINCE_MERGE_BASE_<sha>` in `Change scope`, the heavy jobs are skipped, and every required context of ruleset 15241672 listed in the execution-environment brief reports success.

## Risks & Mitigations

- Missing the `CiWorkflow.Tests.ps1` event-field allowlist update breaks CI as soon as `ci.yml` changes. Mitigation: listed as a required update with an AC.
- Brief copy drift across bundled resources. Mitigation: byte-identity contract test and push-down contract tests are AC gates.
- Checkout lacking the base commit would make every docs-only pull request fall to `MERGE_BASE_UNRESOLVED`. Mitigation: S9 criterion (a) detects this on the item's own pull request before merge.
- Rollback: revert the change; all new failure modes already fail closed.

## Rollout & Follow-up

- Release/rollout steps: merge after S9 criteria (a) and (b) are verified.
- Post-fix monitoring: verify the post-merge criterion on the archive-move closure pull request; confirm the `main` push run after merge runs in full (D6).
- Links: issue #973; predecessor #962; evidence PRs #972 and #941; design in `research/research.2026-10-17T12-25.md`.
