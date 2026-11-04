# ci-single-required-gate-docs-only-skip (Spec)

- **Issue:** #1074
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-04T10-30
- **Status:** Draft
- **Version:** 0.2

## Context
On a docs-only change, ci.yml's fast pass leaves 8 of the 20 required contexts of ruleset 15241672 unreported, so the pull request stays BLOCKED. Replace the 20 individually required contexts with one required gate job that aggregates the results of every CI job, so the docs-only fast pass can pass without any job faking a result and the individual jobs stay visible.

Environment:
- OS/version: GitHub Actions (ubuntu-latest, windows-latest); Codespace token cannot dispatch workflows (HTTP 403).
- Python version: not applicable.
- Command/flags used: pull_request run of .github/workflows/ci.yml on a head whose last push touches only docs.
- Data source or fixture: PRs #1064, #1070 and #1072 (final docs-only check-off heads).

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Open a PR into main whose latest push changes only docs files (for example an acceptance-criteria check-off).
2. Let ci.yml run. scripts/ci/Invoke-CiChangeScope.ps1 returns code=false.
3. Read mergeStateStatus: BLOCKED; 12 of 20 required contexts reported.

Expected:
A docs-only head passes the required checks quickly (that was the purpose of the change-scope fast pass), and every required check reports.

Actual:
These required contexts never report: `poshqc / PowerShell QC shard 1`, `shard 2`, `shard 3` (poshqc-shard has a job-level `if: inputs.run-heavy`, so a skipped matrix job never expands its name and reports as `PowerShell QC shard ${{ matrix.shard }}`); `root-typescript-tests / Root TypeScript Tests (ubuntu-latest)` and `(windows-latest)`; `NPM Audit Gate / npm audit (extensions/drm-copilot)`, `(.)`, `(packages/mcp-server)` (ci.yml skips the whole called workflow with `if: needs.changes.outputs.code != 'false'`, so the nested names never appear).

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: PR #1070 head 964caff0c: 12 of 20 required contexts reported, mergeStateStatus BLOCKED; the previous head 86ef18ef1 had all 20 green.


## Scope & Non-Goals
- In scope:
  - A new top-level job `ci-required-gate` (`name: CI Required Gate`) in `.github/workflows/ci.yml` that needs every other `ci.yml` job, runs under `if: always()`, and evaluates their results.
  - A pure decision module `scripts/ci/CiRequiredGate.psm1` and an entry script `scripts/ci/Invoke-CiRequiredGate.ps1` with I/O seams, plus Pester suites `tests/scripts/ci/CiRequiredGate.Tests.ps1`, `tests/scripts/ci/Invoke-CiRequiredGate.Tests.ps1`, and `tests/scripts/workflows/CiRequiredGateWorkflow.Tests.ps1`.
  - Documentation updates: the execution-environment brief (six byte-identical copies) under `## CI Shape and Required Checks`, `.github/workflows/README.md`, and the `atomic-plan-contract` skill (`.claude` copy and the claude-customizations bundle copy) at the locations named in research section 7; the existing pin test `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` updated to match.
  - A human-facing runbook `docs/features/active/2026-11-04-ci-single-required-gate-docs-only-skip-1074/runbook/ruleset-single-required-gate.md` that documents the post-merge ruleset change, its verification, and its rollback.
  - The CI proof sequence (research section 9, steps A to E) recorded under the feature folder's `evidence/other/`.
- Out of scope / non-goals:
  - Applying the ruleset change to ruleset 15241672. This item documents it; the owner or coordinator applies it after merge.
  - Normalizing job-level skips in `_poshqc.yml`, `_root-typescript-tests.yml`, or `_npm-audit-gate.yml` (research section 4).
  - Renaming, removing, or changing the behavior of any existing `ci.yml` job or any reusable workflow.
  - Adding any new Python file. Existing Python tests may be edited only where research section 6 marks them as updated.
  - Correcting the stale `actionlint` job reference in `.github/instructions/github-actions.instructions.md` (canonical policy file; informational only).
- Explicitly excluded systems, integrations, or datasets:
  - `.github/workflows/_poshqc.yml` and every other reusable workflow file under `.github/workflows/`.
  - Rulesets or branch protection for branches other than `main`; pull requests into `epic/**` integration branches are not covered by ruleset 15241672.
  - `.github/instructions/*` and `.github/copilot-instructions.md` (canonical, not modified).

## Root Cause Analysis
Two inconsistent skip patterns. quality-checks7, security-scan, build-check, shell-coverage and the extension tests keep the job running and guard steps with `if: inputs.run-heavy`, so the job reports under its required name. poshqc-shard/poshqc-static skip at job level, and root-typescript-tests and npm-audit-gate are skipped by ci.yml. Owner decision (2026-11-04): move to ONE required gate. `poshqc / PowerShell QC` already uses an aggregate pattern (needs, if: always()).


## Proposed Fix

### Design summary (what changes where):
- `.github/workflows/ci.yml` gains one job, `ci-required-gate`, with `name: CI Required Gate`, `needs:` listing every other top-level job id (`changes`, `full-run-marker`, `quality-checks7`, `security-scan`, `docs-validation`, `build-check`, `poshqc`, `shell-coverage`, `drm-copilot-extension-tests`, `root-typescript-tests`, `npm-audit-gate`), `if: always()`, `runs-on: ubuntu-latest`, and `permissions: contents: read`. Its steps are a checkout with `persist-credentials: false` and one `shell: pwsh` step that receives `NEEDS_JSON: ${{ toJSON(needs) }}` through `env:` and runs `./scripts/ci/Invoke-CiRequiredGate.ps1`.
- The decision is computed by `Get-CiRequiredGateDecision` in `scripts/ci/CiRequiredGate.psm1`, following the `CiChangeScope.psm1` / `Invoke-CiChangeScope.ps1` precedent. The entry script writes a per-job table to `$GITHUB_STEP_SUMMARY` and exits explicitly with 0 (green) or 1 (red).
- The gate reports a check run named exactly `CI Required Gate` (top-level job, no caller prefix; research section 5), which becomes the single required context after the owner applies the runbook.
- All existing jobs keep their names, `needs:`, `if:`, and inputs; no reusable workflow changes.

### Boundaries and invariants to preserve:
- The gate reads only `needs`; it reads no `github.event.pull_request`, `github.head_ref`, `github.base_ref`, or `github.event_name` field, so the event-field allowance pinned by `tests/scripts/workflows/CiWorkflow.Tests.ps1` stays unchanged.
- The gate name is not `CI full run`, so `Test-CiFullRunMarker` in `scripts/ci/Invoke-CiChangeScope.ps1` cannot select a gate run as a change-scope base.
- The scope predicate is identical to the callers' predicate: docs-only if and only if `needs.changes.outputs.code` is exactly the string `false`; any other value (`true`, empty, missing) is full scope.
- The docs-only skippable set is exactly the `ci.yml` jobs whose job-level `if:` contains `needs.changes.outputs.code != 'false'`: `full-run-marker`, `root-typescript-tests`, `npm-audit-gate` (research Numeric Derivation Evidence, claim N2).
- The gate fails closed: any input it cannot classify produces a red verdict.
- `_poshqc.yml` and its pin tests (`PoshQcWorkflow.Tests.ps1` `WF01` to `WF05`) are not edited.

### Dependencies or blocked work:
- The CI proof steps depend on the pull request existing, because `ci.yml` runs for this branch only on the `pull_request` event and the Codespace token cannot dispatch workflows.
- The ruleset change depends on this pull request being merged and on the gate having reported `success` on a `main` push run; it is out of scope for this item.
- No dependency on other open issues.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- Added: `scripts/ci/CiRequiredGate.psm1`, `scripts/ci/Invoke-CiRequiredGate.ps1`.
- Added: `tests/scripts/ci/CiRequiredGate.Tests.ps1`, `tests/scripts/ci/Invoke-CiRequiredGate.Tests.ps1`, `tests/scripts/workflows/CiRequiredGateWorkflow.Tests.ps1`.
- Added: `docs/features/active/2026-11-04-ci-single-required-gate-docs-only-skip-1074/runbook/ruleset-single-required-gate.md`.
- Modified: `.github/workflows/ci.yml` (one job added).
- Modified (six byte-identical copies): `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`.
- Modified: `.github/workflows/README.md`.
- Modified: `.claude/skills/atomic-plan-contract/SKILL.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`.
- Modified: `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` (existing Python test; no new Python file).
- Optional: a `config/poshqc-shard-weights.json` entry for the new suites.

#### Functions/classes/CLI commands impacted:
- New `Get-CiRequiredGateDecision -NeedsJson <string>` in `CiRequiredGate.psm1`: returns an object with `Passed` (bool), `Scope` (`full`, `docs-only`, or `invalid`), `Code` (raw `changes.outputs.code` value or null), `Rows` (one entry per needed job with `Job`, `Result`, `Accepted`, `Verdict`), and `SummaryText` (Markdown). The skippable set is a module constant.
- New `Invoke-CiRequiredGate -NeedsJson <string> -OutputWriter <scriptblock>` in `Invoke-CiRequiredGate.ps1`, plus a guarded entry (`if ($MyInvocation.InvocationName -ne '.')`) that reads `NEEDS_JSON` through a `-ReadVariable` seam, writes the summary through `-OutputWriter` to `$GITHUB_STEP_SUMMARY`, and calls `exit 0` or `exit 1`.
- Existing `Invoke-CiChangeScope.ps1`, `CiChangeScope.psm1`, `Test-CiFullRunMarker`, and `Find-CiChangeScopeBase` are not changed.

#### Data flow and validation changes:
- Runner produces `toJSON(needs)` -> `NEEDS_JSON` env -> entry script -> `Get-CiRequiredGateDecision` -> summary text and verdict -> `$GITHUB_STEP_SUMMARY` and process exit code -> check run `CI Required Gate`.
- Decision rules (research section 3.2), evaluated over every key of `NEEDS_JSON`:

| Condition | Gate |
|---|---|
| `NEEDS_JSON` blank, not parseable as an object, or missing `changes`, `docs-validation`, or any member of the skippable set | red (configuration error) |
| any job result is `failure` or `cancelled` | red |
| any job result outside {`success`, `skipped`} | red (unknown value, fail closed) |
| `changes` result is not `success` | red (scope cannot be trusted) |
| scope full (`code` is not exactly `false`) | green only if every needed job is `success` |
| scope docs-only (`code` is exactly `false`) | green only if `changes`, `quality-checks7`, `security-scan`, `docs-validation`, `build-check`, `poshqc`, `shell-coverage`, and `drm-copilot-extension-tests` are `success`, and `full-run-marker`, `root-typescript-tests`, and `npm-audit-gate` are each `skipped` or `success` |

#### Error handling and logging updates:
- Parse failures and missing required keys are reported as a configuration-error verdict in the summary and produce exit 1; they are not thrown past the entry script without a summary.
- The summary is a Markdown table appended to `$GITHUB_STEP_SUMMARY`: a header line stating the scope and the raw `code` value, one row per needed job with columns `Job`, `Result`, `Accepted`, `Verdict`, and a final verdict line.
- The entry script and the workflow step end on an explicit `exit 0` or `exit 1` per `.claude/rules/ci-workflows.md` (`## Deliberately-Failing Nested Command Pattern (Required)`).

#### Rollback/feature-flag considerations (if applicable):
- Before the ruleset change, the gate is an additional, non-required check; reverting the `ci.yml` job and the two scripts removes it with no effect on required checks.
- After the ruleset change, rollback is the runbook's section 6 (restore the saved ruleset JSON) followed, if needed, by reverting the code. The ruleset must be restored before the gate job is removed, otherwise every pull request waits on a context that no longer reports.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Input: `NEEDS_JSON`, a JSON object keyed by job id; each value has `result` (`success`, `failure`, `cancelled`, `skipped`) and `outputs` (object; `changes.outputs.code` is a string).
- Output: Markdown appended to the file named by `$GITHUB_STEP_SUMMARY`; process exit code 0 (green) or 1 (red).
- Gate check context: `CI Required Gate`, reported by the GitHub Actions app (`app.id` 15368, which must equal the ruleset entry's `integration_id`).

#### Required configuration keys and defaults:
- `NEEDS_JSON` (required; absence or blank value gives red).
- `GITHUB_STEP_SUMMARY` (provided by the runner; the seam allows tests to inject a writer).
- No new repository configuration file. The skippable set is a module constant pinned against `ci.yml` by the workflow suite.

#### Backward-compatibility expectations:
- Every existing check context keeps its name and continues to report as before, so the current 20-context ruleset keeps working unchanged until the owner applies the runbook.
- `push`, `merge_group`, and `workflow_dispatch` events and fork pull requests always give `code=true` and take the full-scope rule.

#### Performance constraints (latency/throughput/memory):
- The gate adds one `ubuntu-latest` job with a checkout and one short `pwsh` step after all other jobs finish; it adds no Windows runner and no heavy suite to the docs-only path.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - `needs.<caller>.result` for a reusable-workflow caller is `skipped` when the caller's own `if:` is false, `failure` when any called job failed, `cancelled` when the run was cancelled, and otherwise `success` (observed platform behavior; research section 2). `needs.poshqc.result` in a docs-only run is expected to be `success`; proof step D confirms it.
  - The executor has no repository admin rights and does not apply the ruleset change.
- Constraints (budget, performance, compatibility):
  - PowerShell or bash only for new code; no new Python.
  - Direct-mode batch budget: two new production PowerShell files.
  - No absolute paths in any artifact; public repository.
  - Tests must not touch `$env:GITHUB_STEP_SUMMARY` or `$env:NEEDS_JSON` directly and must not create temporary files.
- External dependencies (services, libraries, releases):
  - GitHub Actions runner semantics for `needs`, `always()`, and `toJSON`.
  - GitHub REST "Repository rules" endpoints for the runbook (`GET`/`PUT /repos/{owner}/{repo}/rulesets/{ruleset_id}`).

## Data / API / Config Impact
- User-facing or API changes: a new check `CI Required Gate` appears on every `ci.yml` run; after the owner's post-merge ruleset edit it is the single required context for pull requests into `main`.
- Data or migration considerations: the ruleset migration is manual and documented in the runbook, with a saved backup (`ruleset-15241672.backup.json`, not committed) as the exact rollback source.
- Logging/telemetry updates (if any): the per-job gate summary table in the run summary.
- Compatibility notes (CLI flags, config schemas, versioning): no CLI or schema change; `.github/workflows/README.md` `## Required-Status-Check Rename Procedure` moves from the classic branch-protection endpoint to the ruleset endpoint.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: add one gate job (for example `CI Required Gate`) to ci.yml with `needs:` on every CI job and `if: always()`; it fails when any needed job's result is `failure` or `cancelled`, accepts `skipped` only for jobs the change scope intentionally skipped, writes a per-job result table to the run summary, and passes on the docs-only path. Keep all underlying jobs visible. Update the workflow pin tests (for example PoshQcWorkflow.Tests.ps1) and any docs describing required checks.
- [x] Integration scenario to retest: (1) a code-touching PR: gate green only when every job is green, red when any job fails (prove with a deliberately failing job on the branch); (2) a docs-only PR: gate green with the heavy jobs skipped; the modified-workflow-needs-green-run rule applies.
- [ ] Manual verification notes: the ruleset change (replace the 20 contexts with the single gate) is a branch-protection edit that must happen AFTER the gate has run green on main; the coordinator or owner applies it with `gh api` on ruleset 15241672. The plan must give the exact command and a rollback command and must not apply it.

- Regression tests to add or update:
  - Added `tests/scripts/ci/CiRequiredGate.Tests.ps1`: one case per decision-table row, plus exact summary-text assertions.
  - Added `tests/scripts/ci/Invoke-CiRequiredGate.Tests.ps1`: env read through `-ReadVariable`, summary write through `-OutputWriter`, verdict-to-exit mapping, dot-source guard.
  - Added `tests/scripts/workflows/CiRequiredGateWorkflow.Tests.ps1`: gate job shape, `needs` set derived from the file, skippable-constant parity with `ci.yml`, and mutation cases (a `needs` entry removed, `always()` removed) in the `PoshQcWorkflow.Tests.ps1` `WF03` style.
  - Updated `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`: `_REQUIRED_CONTEXTS` and the CI-section tokens of `test_brief_ci_section_names_jobs_and_required_contexts`.
  - Unchanged and expected to pass: `CiWorkflow.Tests.ps1`, `CiChangeScopeWorkflow.Tests.ps1`, `PoshQcWorkflow.Tests.ps1`, `PoshQC.RunSettings.Tests.ps1`, and the `CiChangeScope` suites.
- Unit tests (pytest) for the fixed behavior and boundaries: not applicable for new behavior (PowerShell under Pester); the only pytest change is the existing brief contract test above.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - `NEEDS_JSON` blank, whitespace, invalid JSON, a JSON array, or a JSON scalar.
  - Missing `changes`, `docs-validation`, or any skippable-set key.
  - `code` values `false`, `true`, empty string, absent, and `False` (case differs; full scope).
  - Results `failure`, `cancelled`, an unknown string, and null.
  - Docs-only with a non-skippable job `skipped` (red); full scope with a skippable job `skipped` (red); `changes` `failure` with all other jobs `success` (red).
- Error handling and logging verification: assert the configuration-error verdict line appears in `SummaryText` and the exit code is 1 for malformed input; assert the summary has one row per needed job.
- Coverage impact and targets for changed lines/modules: line coverage >= 85% for each of `scripts/ci/CiRequiredGate.psm1` and `scripts/ci/Invoke-CiRequiredGate.ps1`, read per file from `artifacts/pester/powershell-coverage.xml` of a branch-current `Invoke-PoshQCTest` run (not from an MCP result summary). Branch coverage is not gated for PowerShell.
- Toolchain commands to run (format → lint → type-check → test):
  - `Invoke-Formatter` check, then PSScriptAnalyzer, then Pester with coverage through the PoshQC tooling (type checking is skipped for PowerShell).
  - `scripts/dev-tools/run-actionlint.ps1` on `.github/workflows/ci.yml`.
  - Poetry pytest on `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` and the push-down resource contract tests covering the bundle copies.
  - Seeded shuffled Pester file-order runs (three seeds) over the three new suites and `CiChangeScopeWorkflow.Tests.ps1`.
- Manual validation steps (if required):
  - CI proof sequence after the pull request is opened (research section 9): (A) implementation head full run, gate green; (B) a throwaway commit that makes one needed job fail, gate red; (C) revert of B, full run, gate green; (D) docs-only evidence commit, gate green with `full-run-marker`, `root-typescript-tests`, and `npm-audit-gate` rows `skipped` and `poshqc` `success`; (E) final commit touching a path outside `config/ci-docs-only-paths.json`, full run with every currently required context green. Evidence goes under `evidence/other/`.
  - The ruleset change itself is post-merge and manual (runbook).


## Acceptance Criteria
- [x] `.github/workflows/ci.yml` contains a job `ci-required-gate` with `name: CI Required Gate`, `if: always()`, `runs-on: ubuntu-latest`, `permissions: contents: read`, and a `shell: pwsh` step that passes `NEEDS_JSON: ${{ toJSON(needs) }}` through `env:` and runs `./scripts/ci/Invoke-CiRequiredGate.ps1`.
- [x] `tests/scripts/workflows/CiRequiredGateWorkflow.Tests.ps1` asserts that the gate's `needs:` set equals the set of every other top-level job id in `ci.yml`, derived from the file, and passes.
- [x] `tests/scripts/workflows/CiRequiredGateWorkflow.Tests.ps1` includes mutation cases showing the pin fails when one `needs:` entry is removed and when `if: always()` is removed.
- [x] `tests/scripts/workflows/CiRequiredGateWorkflow.Tests.ps1` asserts that the module's skippable-set constant equals the set of `ci.yml` jobs whose job-level `if:` contains `needs.changes.outputs.code != 'false'` (`full-run-marker`, `root-typescript-tests`, `npm-audit-gate`).
- [x] `scripts/ci/CiRequiredGate.psm1` exports `Get-CiRequiredGateDecision -NeedsJson` returning `Passed`, `Scope`, `Code`, `Rows`, and `SummaryText`, and performs no file, environment, or network I/O.
- [x] A Pester case in `tests/scripts/ci/CiRequiredGate.Tests.ps1` shows the docs-only scope (`code` exactly `false`) passes when `changes`, `quality-checks7`, `security-scan`, `docs-validation`, `build-check`, `poshqc`, `shell-coverage`, and `drm-copilot-extension-tests` are `success` and `full-run-marker`, `root-typescript-tests`, and `npm-audit-gate` are each `skipped` or `success`.
- [x] A Pester case shows the docs-only scope fails when any job outside the skippable set is `skipped`.
- [x] A Pester case shows the full scope passes only when every needed job is `success`, and fails when any job, including a skippable-set job, is `skipped`.
- [x] Pester cases show that `code` values `true`, empty string, absent, and any value other than exactly `false` select the full scope.
- [x] A Pester case shows the gate fails when any needed job result is `failure`.
- [x] A Pester case shows the gate fails when any needed job result is `cancelled`.
- [x] A Pester case shows the gate fails when any needed job result is a value outside {`success`, `failure`, `cancelled`, `skipped`}, including null.
- [x] A Pester case shows the gate fails when the `changes` result is not `success`, even when every other job is `success`.
- [x] Pester cases show the gate fails with a configuration-error verdict when `NEEDS_JSON` is blank, is not parseable JSON, is a JSON array or scalar, or lacks `changes`, `docs-validation`, or any skippable-set key.
- [x] A Pester case asserts `SummaryText` exactly: a header line with the scope and the raw `code` value, one table row per needed job with columns `Job`, `Result`, `Accepted`, and `Verdict`, and a final verdict line.
- [x] `tests/scripts/ci/Invoke-CiRequiredGate.Tests.ps1` shows the entry reads `NEEDS_JSON` through the `-ReadVariable` seam and writes the summary through the `-OutputWriter` seam without reading or writing the real `$env:NEEDS_JSON` or `$env:GITHUB_STEP_SUMMARY`.
- [x] `scripts/ci/Invoke-CiRequiredGate.ps1` ends with an explicit `exit 0` for a passing decision and `exit 1` otherwise, per `.claude/rules/ci-workflows.md`, and a Pester case asserts that verdict-to-exit mapping and the dot-source guard.
- [ ] The `ci.yml` diff against the base branch adds only the `ci-required-gate` job, and every existing job keeps its id, `name:`, `needs:`, `if:`, `uses:`, and `with:` values.
- [x] `tests/scripts/workflows/CiWorkflow.Tests.ps1`, `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`, and `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` pass without modification.
- [ ] `.github/workflows/_poshqc.yml` and every other reusable workflow file under `.github/workflows/` have no diff against the base branch.
- [x] The execution-environment brief section `## CI Shape and Required Checks` names `CI Required Gate` in the job list, states which contexts never report on a docs-only run and that the gate passes there, replaces the stale required-context list with the contexts read from ruleset 15241672 on 2026-11-04, states that the single required context after the owner's ruleset edit is `CI Required Gate`, and updates the refresh rule and skipped-check semantics bullets.
- [x] The execution-environment brief copies `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, and `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md` are byte-identical after the change.
- [x] `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` is updated for the rewritten brief (`_REQUIRED_CONTEXTS` includes `CI Required Gate` and the CI-section tokens match the new text) and the module passes under pytest.
- [x] `.github/workflows/README.md` contains a section `## CI Required Gate (Issue #1074)` with the decision table, an updated `### Required contexts under a docs-only run`, and a `## Required-Status-Check Rename Procedure` that uses the ruleset endpoint instead of the classic branch-protection endpoint.
- [x] Both copies of the `atomic-plan-contract` skill (`.claude/skills/` and the claude-customizations bundle) state in the Pester runner-and-job bullet that `poshqc / PowerShell QC` is the aggregating check whose result `CI Required Gate` requires, and the push-down resource contract tests pass.
- [ ] `scripts/dev-tools/run-actionlint.ps1` reports zero findings on `.github/workflows/ci.yml`, with the output recorded under `evidence/qa-gates/`.
- [ ] The PowerShell toolchain passes in a single pass (Invoke-Formatter leaves no changes, PSScriptAnalyzer reports zero findings, and Pester passes for the three new suites and the existing workflow and `CiChangeScope` suites), with results recorded under `evidence/qa-gates/`.
- [ ] Line coverage is at least 85% for each of `scripts/ci/CiRequiredGate.psm1` and `scripts/ci/Invoke-CiRequiredGate.ps1`, read per file from `artifacts/pester/powershell-coverage.xml` of a branch-current run and recorded under `evidence/qa-gates/`.
- [ ] Seeded shuffled Pester file-order runs with three seeds over the three new suites and `CiChangeScopeWorkflow.Tests.ps1` all pass, with seeds recorded under `evidence/qa-gates/`.
- [ ] No new Python file is added by this change.
- [ ] `runbook/ruleset-single-required-gate.md` exists in the feature folder with these sections in this order: Preconditions and timing; Gate context name and current required contexts; Read and save the ruleset; Apply the change (API and web UI); Verification; Rollback; What does not change.
- [ ] The runbook's preconditions section states that the change is applied only after the pull request is merged and the gate has reported `success` on a `main` push run, gives the exact `gh run list` and `gh api .../check-runs?check_name=CI%20Required%20Gate` confirmation commands, and explains that applying it earlier blocks every pull request on a context that does not yet report.
- [ ] The runbook's context-name section lists the full set of contexts currently required by ruleset 15241672 and states the gate context name and `app.id` 15368 as verified from a real `ci.yml` run on this branch (CI-dependent).
- [ ] The runbook's read-and-save section gives `gh api repos/drmoisan/drm-copilot/rulesets/15241672 > ruleset-15241672.backup.json` and states that the backup file is not committed.
- [ ] The runbook's apply section gives a `gh api --method PUT` command with a complete JSON body built from the backup by `pwsh` and by a `jq` equivalent, which replaces only `required_status_checks` with the single `CI Required Gate` context (`integration_id` 15368) and preserves `name`, `target`, `enforcement`, `conditions`, `bypass_actors`, and every other rule and parameter.
- [ ] The runbook's apply section gives the web UI path (Settings > Rules > Rulesets > protect-main > required status checks) and states the required token permission (repository Administration: write, or repository admin).
- [ ] The runbook's verification section describes a throwaway docs-only pull request (gate green, pull request mergeable, individual jobs still listed) and a code pull request (gate red when a needed job fails) with expected results.
- [ ] The runbook's rollback section gives the exact `gh api --method PUT` command that restores the saved backup and the web UI equivalent, and its final section states that pull requests into `epic/**` integration branches are not covered by ruleset 15241672.
- [ ] Every JSON body in the runbook is validated by a dry parse (`ConvertFrom-Json`) with the result recorded under `evidence/qa-gates/`, and no `PUT` against ruleset 15241672 is executed by this item.
- [ ] (CI-dependent) Proof A: a full `ci.yml` run on the implementation head reports `CI Required Gate` as `success` with every summary row `success`, recorded under `evidence/other/`.
- [ ] (CI-dependent) Proof B: a throwaway commit that makes one needed job fail produces a run in which `CI Required Gate` is `failure` and the summary row for that job shows `failure`, recorded under `evidence/other/`.
- [ ] (CI-dependent) Proof C: the revert of the proof B commit produces a full run in which `CI Required Gate` is `success`, recorded under `evidence/other/`.
- [ ] (CI-dependent) Proof D: a docs-only evidence commit produces a run in which `CI Required Gate` is `success` and the gate summary table shows `full-run-marker`, `root-typescript-tests`, and `npm-audit-gate` as `skipped` and `poshqc` as `success`, recorded under `evidence/other/`.
- [ ] (CI-dependent) The proof B failing change is absent from the final pull request head tree.
- [ ] (CI-dependent) The final pull request head commit touches at least one path outside the `config/ci-docs-only-paths.json` allowlist, and its full `ci.yml` run reports every context currently required by ruleset 15241672 as `success`, together with `CI Required Gate`.

## Risks & Mitigations
- Technical or operational risks:
  - A logic defect in the gate would pass every pull request once it is the single required check.
  - `needs.poshqc.result` could be `skipped` rather than `success` on a docs-only run, making the gate red on docs-only heads.
  - Applying the ruleset change before the gate reports on `main` would block every pull request.
  - A future `ci.yml` job could be added without being added to the gate's `needs:`, leaving it unenforced.
  - Until the ruleset change, a docs-only final head remains BLOCKED by the legacy contexts.
- Mitigations and rollbacks:
  - Decision logic is in a pure module with one Pester case per decision-table row and the coverage floor.
  - Proof step D observes `needs.poshqc.result` through the gate summary; a `skipped` value is treated as a design input for a remediation cycle, not as a proof failure.
  - The runbook's preconditions section requires a confirmed green gate on `main` before the change; the saved backup and the rollback command restore the previous ruleset.
  - The workflow suite derives the expected `needs:` set from `ci.yml`, so an omitted future job fails the pin.
  - Proof step E is a full-run head, so the pull request is mergeable under the legacy contexts.

## Rollout & Follow-up
- Release/rollout steps:
  - Merge the pull request after proof steps A to E are recorded.
  - Confirm `CI Required Gate` is `success` on the `main` push run (runbook section 1).
  - The owner or coordinator applies the runbook (save, apply, verify).
- Post-fix monitoring or clean-up tasks:
  - On the next docs-only pull request after the ruleset change, confirm `mergeStateStatus` is not BLOCKED; record that evidence under the feature's `evidence/other/` in a separate pull request.
  - When the ruleset changes, refresh the brief's required-context bullet per its refresh rule.
- Links: issue https://github.com/drmoisan/drm-copilot/issues/1074; research `research/research.2026-11-04.md`; runbook `runbook/ruleset-single-required-gate.md`; related PRs #1064, #1070, #1072; `.github/workflows/README.md` `## Change-Scope Decision (Issue #962)`.
