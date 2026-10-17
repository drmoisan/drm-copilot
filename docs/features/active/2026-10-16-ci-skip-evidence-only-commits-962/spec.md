# 2026-10-16-ci-skip-evidence-only-commits (Spec)

- **Issue:** #962
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-16 (UTC date; the time of day was not recorded because this authoring session had no shell or clock tool)
- **Status:** Approved-for-planning
- **Version:** 1.0
- **Work Mode:** full-bug (this file is the sole acceptance-criteria source; no `user-story.md` is produced)
- **Design evidence:** `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/research/research.2026-10-16T14-39.md` (cited below as "research §n")

## Context

Each item currently needs three full CI runs, each taking about 12–19 minutes, before it can merge cleanly:

1. the run that proves the code green;
2. a run triggered by the commit that records that CI evidence (docs only);
3. a run after the branch is re-synced with main.

The merge queue (#952) removes run 3. This item removes run 2. When every file changed since the branch's last full green CI run is on an evidence or docs allowlist, the heavy CI steps are skipped, docs validation runs, and every required status check still reports success. Evidence documentation is still committed in full.

Environment:
- OS/version: GitHub Actions (`windows-latest`, `ubuntu-latest`)
- Python version: n/a
- Command/flags used: `.github/workflows/ci.yml` on `pull_request` events
- Data source or fixture: #953 / PR #959, whose CI runs 38896856766, 38896898318 and 38899482473 cover a single code state

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Repro & Evidence

Steps to Reproduce:
1. Push code to an item branch and wait for a green CI.
2. Commit the CI evidence under `docs/features/<item>/` and push.
3. Observe that a full CI run starts, although the code tree is identical to the one just tested.

Expected:
A push whose diff since the last full green run touches only allowlisted evidence or docs paths runs no heavy steps. All 11 required contexts of ruleset 15241672 still report success.

Actual:
Every push runs the full matrix, which takes about 12–19 minutes.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: PR #959 CI runs 38896856766, 38896898318 and 38899482473 cover a single code state. Run 38896898318 is the evidence-commit run, and AC-33 uses it as the "before" timing baseline.

## Scope & Non-Goals

- In scope:
  - A `changes` decision job (`Change scope`) and a `full-run-marker` job (`CI full run`) in `.github/workflows/ci.yml`.
  - A `run-heavy` boolean input with step gating in the six reusable workflows that produce required contexts and are gated: `_quality-checks.yml`, `_security-scan.yml`, `_build-check.yml`, `_poshqc.yml`, `_shell-coverage.yml`, and `_drm-copilot-extension-tests.yml`.
  - Job-level skips for the non-required callers `root-typescript-tests` and `npm-audit-gate`.
  - PowerShell 7 decision logic in `scripts/ci/`, the allowlist config `config/ci-docs-only-paths.json`, Pester suites under `tests/scripts/ci/`, and a new workflow-invariant suite `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`.
  - A `quality-tiers.yml` entry for `scripts/ci`.
  - An appended section in `.github/workflows/README.md`.
  - Related follow-ups added by coordinator decision D14 (AC-35 to AC-38): the two count statements and the dispatch table of `.github/workflows/README.md` (D14-a), a blocking `_security-scan.yml` scan step with a working `poetry export` (D14-b), recursive bats discovery in `scripts/bash/shell_qc_lib.sh` (D14-c), and an 85% bash line-coverage threshold (D14-d).
- Out of scope / non-goals: see `## Out of Scope`.
- Explicitly excluded systems, integrations, or datasets:
  - Ruleset 15241672. No ruleset change is made.
  - Merge-queue enablement, which belongs to #952.
  - `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`, its bundle mirror, `.claude/skills/orchestrate/SKILL.md`, and `.claude/skills/parallel-orchestrate/SKILL.md` (see D4).

## Root Cause Analysis

`ci.yml` has no change-scope decision. It has nine caller jobs and no `needs:` edges (research §1.1, N2), so every `pull_request` push runs every heavy job, including pushes that only add evidence files under `docs/features/`.

A plain job-level `if:` on the caller jobs (research §2.2, Candidate A) does not fix this safely:

- A job-level `if:` skips a matrix job before the matrix expands. The skipped check then carries the unexpanded name, so the six matrix-derived required contexts never report (research §2.1 F5).
- The context name that a skipped `uses:` caller reports is unverified (research §2.1 F7).

The fix therefore has to keep every required job running under its full-run name, and make only its steps conditional.

## Decisions

- **D1. Required-check design: research Candidate B (research §2.2, §2.3).**
  - The six required caller jobs (`quality-checks7`, `security-scan`, `build-check`, `poshqc`, `shell-coverage`, `drm-copilot-extension-tests`) always run. Each carries:
    - `needs: changes`
    - `if: ${{ !cancelled() }}`
    - `with: run-heavy: ${{ needs.changes.outputs.code != 'false' }}`
  - Each of their reusable workflows declares a boolean input `run-heavy` (default `true`) under both `workflow_call` and `workflow_dispatch`, following the `_npm-audit-gate.yml` precedent. Every step of every required job is gated on that input.
  - As a result, all 11 required contexts of ruleset 15241672 report `success` under their full-run names.
  - The non-required callers `root-typescript-tests` and `npm-audit-gate` are skipped at job level when `code` is `false`.
  - `docs-validation` is unchanged and always runs.
  - The ruleset is not changed.
  - The design does not depend on the unverified facts F7 or F8 (research §2.1).

  Per-context behaviour under a docs-only run (`code=false`). The context set and its count of 11 come from research N1; the six gated callers are the seven distinct caller prefixes of N1 minus `docs-validation` (research N2 member-set comparison).

  | # | Required context (ruleset 15241672) | Caller job | Mechanism under `code=false` | Reported conclusion |
  |---|---|---|---|---|
  | 1 | `drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)` | `drm-copilot-extension-tests` | job and matrix start; every step skipped by `inputs.run-heavy` | `success` |
  | 2 | `drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)` | `drm-copilot-extension-tests` | same as row 1 | `success` |
  | 3 | `docs-validation / Documentation Validation` | `docs-validation` | unchanged; runs in full | `success` (on a passing docs check) |
  | 4 | `poshqc / PowerShell QC` | `poshqc` | the `poshqc` job runs with every step gated (in the sharded shape of #953 it is the aggregator and keeps `if: always()`); every other `_poshqc.yml` job is skipped at job level (not required) | `success` |
  | 5 | `shell-coverage / Shell Coverage (Bats + kcov)` | `shell-coverage` | job runs; every step skipped, including the `if-no-files-found: error` upload | `success` |
  | 6 | `security-scan / Security Scanning` | `security-scan` | job runs; every step skipped | `success` |
  | 7 | `quality-checks7 / Code Quality & Tests (3.10)` | `quality-checks7` | matrix expands; every step skipped | `success` |
  | 8 | `quality-checks7 / Code Quality & Tests (3.11)` | `quality-checks7` | same as row 7 | `success` |
  | 9 | `quality-checks7 / Code Quality & Tests (3.12)` | `quality-checks7` | same as row 7 | `success` |
  | 10 | `quality-checks7 / Code Quality & Tests (3.13)` | `quality-checks7` | same as row 7 | `success` |
  | 11 | `build-check / Build Package` | `build-check` | job runs; every step skipped | `success` |

  Non-required jobs under `code=false`: `Change scope` is `success`; `CI full run` is `skipped`; the `root-typescript-tests` and `npm-audit-gate` callers are `skipped`.

- **D2. Decision jobs and algorithm (research §3.1–§3.3).**
  - `changes` (name `Change scope`):
    - `runs-on: ubuntu-latest`; job-level `permissions: { actions: read, contents: read }`; `outputs.code: ${{ steps.scope.outputs.code }}`.
    - Checkout uses `ref: ${{ github.event.pull_request.head.sha || github.sha }}`, `fetch-depth: 0`, `filter: blob:none` and `persist-credentials: false`.
    - Step `id: scope` runs `scripts/ci/Invoke-CiChangeScope.ps1` with `shell: pwsh` and `continue-on-error: true`. It receives `GH_TOKEN`, `EVENT_NAME`, `HEAD_SHA`, `HEAD_REF`, `HEAD_REPO`, `REPOSITORY` and `RUN_ID` through `env:`.
  - `full-run-marker` (name `CI full run`): `needs: changes`, `if: ${{ !cancelled() && needs.changes.outputs.code != 'false' }}`, one `run: echo` step. It is not a required check.
  - The algorithm follows research §3.3, with these reason codes: `EVENT_NOT_PULL_REQUEST`, `FORK_PULL_REQUEST`, `RUN_LIST_FAILED`, `JOB_LIST_FAILED`, `NO_FULL_GREEN_RUN`, `BASE_NOT_PRESENT`, `BASE_NOT_ANCESTOR`, `ANCESTRY_CHECK_FAILED`, `DIFF_FAILED`, `EMPTY_DIFF`, `NON_ALLOWLISTED_PATH: <first path>`, `DOCS_ONLY_SINCE_<base>`, and `UNEXPECTED_ERROR`.
  - The decision fails closed (`code=true`) in each of these cases:
    - every non-`pull_request` event (`merge_group`, `push`, `workflow_dispatch`);
    - fork PRs;
    - run-list or job-list API errors, or unparseable JSON;
    - no full-green run in the page;
    - a base that is missing or not an ancestor, or an ancestry check that fails;
    - a diff failure or non-NUL-terminated output;
    - an empty diff;
    - any non-allowlisted path;
    - any unexpected error.
  - A run counts as a green base only when the run concluded `success` and its `CI full run` job concluded `success`. A run whose `CI full run` job was skipped never counts as a green base.
- **D3. Language and layout (research §4.1, §5).**
  - The decision logic is written in PowerShell 7. No Python or bash is added for it.
  - Pure functions go in `scripts/ci/CiChangeScope.psm1`. The thin I/O entry point is `scripts/ci/Invoke-CiChangeScope.ps1`, with injectable `-GhInvoker`, `-GitInvoker` and `-OutputWriter` seams and a dot-source guard.
  - Pester tests live under `tests/scripts/ci/`, following the mirror rule.
  - The allowlist is `config/ci-docs-only-paths.json`, using the research §4.1 schema:
    - include prefixes: `docs/features/active/`, `docs/features/completed/`, `docs/features/potential/`, `docs/research/`;
    - exclude prefixes: `docs/features/templates/`, `docs/features/potential/template.md`;
    - extensions: `.md`, `.txt`, `.log`, `.json`, `.xml`;
    - paths containing a `..` segment, a backslash, or a leading `/` are rejected.
  - `quality-tiers.yml` gains a `scripts/ci` entry at tier `T4`.
- **D4. CI-gate tooling is not changed (research §6).**
  - `Invoke-CiGateParser.ps1`, orchestrate S9, and parallel merge-on-green already treat `skipped` and `neutral` checks as non-blocking, and they refuse an empty check set.
  - This branch does not modify the parser, its bundle mirror, or the two skill files.
  - AC-28 verifies this.
- **D5. Dependency composition (research §7; amended by coordinator decision 1 of 2026-10-16).**
  - #952 (`merge_group` trigger in `ci.yml`) and #953 (PR #959, sharded `_poshqc.yml` with the `poshqc / PowerShell QC` aggregator) are not prerequisites. Execution starts without them and records, before the first edit to `ci.yml` or `_poshqc.yml`, whether each is present in `origin/main`.
  - Execution brings `origin/main` into this branch with `git merge origin/main`, not with a rebase or a force push. This supersedes the rebase-and-force-push wording in research §7 and §11.
  - The `_poshqc.yml` gating is selected by the shape present on the branch head:
    - unsharded shape (`poshqc`, `poshqc-linux-hooks`): the `poshqc` job, which reports the required context, has every step gated and no job-level condition; `poshqc-linux-hooks` skips at job level when `run-heavy` is false;
    - sharded shape (#953): the `poshqc-static`, `poshqc-shard` and `poshqc-linux-hooks` jobs skip at job level when `run-heavy` is false; the `poshqc` aggregator keeps `if: always()`, and every one of its steps is gated, so a skipped shard on a full run still fails the aggregator.
  - If `origin/main` gains #952 or #953 before this item merges, the branch merges `origin/main` again and the affected gating and test adjustments are re-applied and re-verified. This is a recorded re-integration, not a halt.
  - At authoring time, `origin/main` and this branch have no `merge_group` trigger in `ci.yml`, and `_poshqc.yml` has the unsharded `poshqc` / `poshqc-linux-hooks` job set.
- **D6. Existing workflow tests (research §7, §9 item 16).**
  - #962 does not edit `tests/scripts/workflows/CiWorkflow.Tests.ps1` or `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`, unless #962's gating breaks an existing assertion in one of them. If it does, the change is limited to that assertion and is recorded in the execution evidence.
  - #962's workflow invariants go in the new file `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`.
- **D7. Accepted risk: the diff compares PR heads (research §3.4).**
  - A skipped run does not test a newer merge result with `main`.
  - Mitigations:
    - `strict_required_status_checks_policy: true` requires the branch to be up to date, and a re-sync adds non-allowlisted paths;
    - `merge_group` runs never skip;
    - pushes to `main` never skip.
- **D8. Coverage.**
  - Changed-file line coverage for `scripts/ci/*` must be at least 85%.
  - It is measured from PoshQC coverage output (`artifacts/pester/powershell-coverage.xml`) and recorded under `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/qa-gates/`.
  - CI does not enforce the PowerShell threshold (`CoveragePercentTarget = 0`; research §5).
- **D9. Workflow README.**
  - A section is appended to `.github/workflows/README.md`. It documents the change-scope decision, the allowlist, the fail-closed rules, the `run-heavy` input, and the per-context table from D1.
  - The Triggers section is not edited, so the change composes with #952. The only pre-existing lines that change are the D14-a corrections of AC-35.

## Proposed Fix

### Design summary (what changes where):

- `ci.yml`:
  - adds the `changes` and `full-run-marker` jobs (D2);
  - adds the caller `needs`/`if`/`with` lines (D1);
  - leaves the `on:` block untouched.
- The six gated reusable workflows declare `run-heavy` and gate their steps (D1, D5).
- The decision logic is in `scripts/ci/` and the allowlist in `config/` (D3).

### Boundaries and invariants to preserve:

- All 11 required contexts report `success` under their full-run names on every run in which the work passes.
- A full run behaves exactly as it does today: `run-heavy` defaults to `true`, and `!= 'false'` fails closed.
- Standalone `workflow_dispatch` of a reusable workflow behaves exactly as it does today (default `true`).
- `docs-validation` always runs.
- The `on:` block of `ci.yml` and the Triggers section of `.github/workflows/README.md` are not edited.

### Dependencies or blocked work:

- None blocking. #952 and #953 compose with this item through `git merge origin/main` (D5).

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

Research §9 items 1–16:
- `.github/workflows/ci.yml`
- `.github/workflows/_quality-checks.yml`, `_security-scan.yml`, `_build-check.yml`, `_shell-coverage.yml`, `_drm-copilot-extension-tests.yml`, `_poshqc.yml`
- `.github/workflows/README.md`
- `config/ci-docs-only-paths.json`
- `scripts/ci/CiChangeScope.psm1`, `scripts/ci/Invoke-CiChangeScope.ps1`
- `quality-tiers.yml`
- `tests/scripts/ci/CiChangeScope.Tests.ps1`, `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1`, `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`
- `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`
- D14 follow-ups: `scripts/bash/shell_qc_lib.sh`, `scripts/bash/shell-qc.sh`, `tests/shell/test_shell_qc_commands.bats` (the README and `_security-scan.yml` are already listed)

#### Functions/classes/CLI commands impacted:

Pure functions in `CiChangeScope.psm1` (research §5):
- `Test-CiChangeScopeEventEligible`
- `ConvertFrom-CiDocsOnlyPathConfig`
- `Test-CiDocsOnlyPath`
- `Get-CiChangeScopePathDecision`
- `ConvertFrom-CiNulPathList`
- `Select-CiGreenBaseCandidates`
- `Test-CiFullRunMarker`
- `New-CiChangeScopeDecision`

The entry script `Invoke-CiChangeScope.ps1` takes the `-GhInvoker`, `-GitInvoker` and `-OutputWriter` seams.

#### Data flow and validation changes:

The decision flow is: event gate, then fork gate, then run listing, then marker lookup, then ancestry, then diff, then classification, all inside an error envelope (research §3.3).

#### Error handling and logging updates:

- Each decision writes `code=<true|false>` to `$GITHUB_OUTPUT`.
- It logs the line `code=<true|false> reason=<REASON>` and writes the reason and base SHA to `$GITHUB_STEP_SUMMARY`.
- An unexpected exception emits a `::warning::` annotation, returns `code=true` with reason `UNEXPECTED_ERROR`, and exits 0.

#### Rollback/feature-flag considerations (if applicable):

- Revert the `ci.yml` caller lines, or set the callers' `run-heavy` to `true`, to restore unconditional full runs.
- No ruleset state needs to be restored.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- Environment inputs: `GH_TOKEN`, `EVENT_NAME`, `HEAD_SHA`, `HEAD_REF`, `HEAD_REPO`, `REPOSITORY`, `RUN_ID`.
- Output: the job output `code` (`true` | `false`).
- Reusable-workflow input: `run-heavy` (`type: boolean`, `default: true`).

#### Required configuration keys and defaults:

- `config/ci-docs-only-paths.json` keys: `version` (1), `include_prefixes`, `exclude_prefixes`, `extensions`.

#### Backward-compatibility expectations:

- Callers that omit `run-heavy` get the full run.
- Required-context names do not change.

#### Performance constraints (latency/throughput/memory):

- The `changes` job uses one run-list call and at most one jobs call per candidate in a page of 50.
- A partial clone (`filter: blob:none`) bounds checkout cost.
- The intended outcome is a docs-only run that is materially shorter than baseline run 38896898318. AC-33 records both durations, and no fixed threshold is asserted.

## Assumptions, Constraints, Dependencies

- Assumptions:
  - A job that runs and skips all of its steps reports `success` under its normal name (research §2.1 F1, F2).
  - `filter` and `fetch-depth` are supported by the pinned `actions/checkout` tag (research §3.1, unverified; AC-32 exercises it on the PR).
- Constraints:
  - No Python or bash is used for the decision logic.
  - No ruleset change.
  - No temporary files in tests.
  - Each file is at most 500 lines.
- External dependencies:
  - #952 and #953 compose through `git merge origin/main` whenever they reach `origin/main` (D5);
  - the GitHub Actions REST API runs and jobs endpoints with `GITHUB_TOKEN`.

## Data / API / Config Impact

- User-facing or API changes:
  - New non-required checks `Change scope` and `CI full run`.
  - New reusable-workflow input `run-heavy`.
- Data or migration considerations: none.
- Logging/telemetry updates:
  - the `Change scope` log line and step summary;
  - a `::warning::` annotation on unexpected errors.
- Compatibility notes:
  - the new `config/ci-docs-only-paths.json` (version 1);
  - the `quality-tiers.yml` entry `scripts/ci` (T4).

## Test Strategy

- Unit coverage areas: research §5 required scenarios, covering:
  - each non-PR event;
  - fork PR;
  - run-list and job-list API errors;
  - malformed JSON;
  - no marker, and a skipped marker;
  - current-run exclusion;
  - unsorted API order;
  - non-ancestor, missing base, and failed ancestry check;
  - rename across the boundary and the diff argument set;
  - non-NUL-terminated output;
  - empty and mixed diffs;
  - allowlist positive and negative cases;
  - path traversal, backslash, and leading-slash paths;
  - upper-case extension;
  - invalid config;
  - unexpected exception.
- Regression tests to add or update:
  - `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` (fails against the pre-change workflows);
  - the three `tests/scripts/ci/*.Tests.ps1` suites.
- Unit tests (Pester) for the fixed behavior and boundaries: see AC-1 through AC-17.
- Edge cases and negative scenarios: see AC-12, AC-13, AC-14, AC-16.
- Error handling and logging verification: see AC-3, AC-4, AC-7, AC-8, AC-16.
- Coverage impact and targets for changed lines/modules: D8, AC-27.
- Toolchain commands to run, in order:
  1. PoshQC format;
  2. PoshQC analyze;
  3. type-check (not applicable to PowerShell);
  4. Pester;
  5. `scripts/dev-tools/run-actionlint.ps1` on the changed workflows.
- Manual validation steps: none. The integration checks are the CI-dependent ACs, which are agent-executable through `## Proof Procedure`.

## Acceptance Criteria

- [x] AC-1: Event gate. For each `EVENT_NAME` of `merge_group`, `push` and `workflow_dispatch`, `Invoke-CiChangeScope.ps1` writes `code=true` with reason `EVENT_NOT_PULL_REQUEST`, and the injected `-GhInvoker` and `-GitInvoker` are each invoked zero times. Verified by named Pester tests in `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1`, with matching pure-function tests of `Test-CiChangeScopeEventEligible` in `tests/scripts/ci/CiChangeScope.Tests.ps1`.
- [x] AC-2: Fork gate. For a `pull_request` event whose `HEAD_REPO` differs from `REPOSITORY`, the entry script writes `code=true` with reason `FORK_PULL_REQUEST`, and neither invoker is called. Verified by a named Pester test.
- [x] AC-3: Run-list failure. When the injected `gh` run-list call returns a non-zero exit, or output that is not valid JSON, the entry script writes `code=true` with reason `RUN_LIST_FAILED`. Verified by two named Pester tests, one per failure form.
- [x] AC-4: Job-list failure. When the run list parses but a jobs call for a candidate run fails, the entry script writes `code=true` with reason `JOB_LIST_FAILED`. Verified by a named Pester test.
- [x] AC-5: Candidate selection. `Select-CiGreenBaseCandidates` excludes the run whose id equals `RUN_ID` and runs whose `head_repository.full_name` differs from `REPOSITORY`. It returns the remaining runs ordered by `run_number` descending when the input is in unsorted order. Verified by named Pester tests covering current-run exclusion, foreign-head-repository exclusion, and an unsorted input fixture.
- [x] AC-6: Full-run marker. `Test-CiFullRunMarker` returns true only when the jobs payload contains a job named `CI full run` with conclusion `success`. It returns false for `skipped`, for any other conclusion, and when the job is absent. When no candidate in the page qualifies, including a page whose only successful runs have a skipped `CI full run`, the entry script writes `code=true` with reason `NO_FULL_GREEN_RUN`. When an older candidate qualifies and a newer one does not, the older candidate is chosen as the base. Verified by named Pester tests.
- [x] AC-7: Ancestry. For each of the following injected `git` outcomes, the entry script writes `code=true` with the stated reason:
  - `git cat-file -e <base>^{commit}` fails: `BASE_NOT_PRESENT`;
  - `git merge-base --is-ancestor` exits 1: `BASE_NOT_ANCESTOR`;
  - `git merge-base --is-ancestor` exits with any other non-zero code: `ANCESTRY_CHECK_FAILED`.

  Verified by three named Pester tests.
- [x] AC-8: Diff invocation. The diff call made through `-GitInvoker` contains each of the arguments `--name-only`, `-z`, `--no-renames`, `--no-color`, `--no-ext-diff` and `--no-relative`, plus the base and head SHAs. A non-zero diff exit, or non-empty output that does not end in NUL, produces `code=true` with reason `DIFF_FAILED`. Verified by named Pester tests, including one that asserts the argument set and one per failure form.
- [x] AC-9: Empty diff. An empty path set from the diff produces `code=true` with reason `EMPTY_DIFF`. Verified by a named Pester test of `Get-CiChangeScopePathDecision` and a named entry-script test.
- [x] AC-10: Mixed diff. A path set that contains at least one allowlisted path and at least one non-allowlisted path (for example `docs/features/active/x/evidence/a.md` plus `scripts/ci/CiChangeScope.psm1`) produces `code=true` with reason `NON_ALLOWLISTED_PATH: <first non-allowlisted path>`. Verified by a named Pester test.
- [x] AC-11: Docs-only diff. When every path is allowlisted and the base qualifies and is an ancestor, the entry script:
  - writes `code=false` to the injected `-OutputWriter` output target;
  - logs `code=false reason=DOCS_ONLY_SINCE_<base sha>`;
  - writes the reason and base SHA to the step-summary target.

  Verified by a named Pester test that captures both targets through `-OutputWriter`.
- [x] AC-12: Allowlist positive cases. `Test-CiDocsOnlyPath` returns true for representative paths under each include prefix (`docs/features/active/`, `docs/features/completed/`, `docs/features/potential/`, `docs/research/`), for each configured extension (`.md`, `.txt`, `.log`, `.json`, `.xml`), and for an upper-case extension (for example `docs/features/active/x/evidence/RUN.MD`). Verified by named Pester tests.
- [x] AC-13: Allowlist negative cases. `Test-CiDocsOnlyPath` returns false for each of the following, each covered by a named Pester test:
  - `docs/features/templates/README.md`;
  - `docs/features/potential/template.md`;
  - a path under `docs/engineering/`;
  - a path under `docs/discovery/`;
  - a code extension under an include prefix (at least `.ps1`, `.py` and `.yml`);
  - a path containing a `..` segment;
  - a path containing a backslash;
  - a path with a leading `/`;
  - a prefix with different case (for example `Docs/features/active/x.md`);
  - a path outside `docs/` (for example `config/ci-docs-only-paths.json`).
- [x] AC-14: Invalid config.
  - `ConvertFrom-CiDocsOnlyPathConfig` throws a specific error for each of: malformed JSON, `version` not equal to 1, an empty or missing `include_prefixes`, and an extension that does not start with `.`.
  - When the entry script receives an invalid config, it writes `code=true` with reason `UNEXPECTED_ERROR` and emits a `::warning::` annotation.

  Verified by named Pester tests.
- [x] AC-15: Committed config. `config/ci-docs-only-paths.json` exists with the D3 content. `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1` asserts, against the committed file, that:
  - every include prefix starts with `docs/`;
  - no include prefix covers `docs/features/templates/`, `docs/engineering/` or `docs/discovery/`;
  - `docs/features/templates/` and `docs/features/potential/template.md` are excluded;
  - no configured extension is one of `.py`, `.ps1`, `.psm1`, `.psd1`, `.sh`, `.bats`, `.ts`, `.tsx`, `.js`, `.mjs`, `.cjs`, `.cs`, `.yml`, `.yaml` or `.toml`.

  The suite passes.
- [x] AC-16: Unexpected exception. When an injected seam throws an unexpected exception, the entry script writes `code=true` with reason `UNEXPECTED_ERROR`, emits a `::warning::` annotation, and exits 0. Verified by a named Pester test.
- [x] AC-17: Structure. The following hold, verified by file inspection and by the passing suites:
  - `scripts/ci/CiChangeScope.psm1` contains only the pure functions listed under `## Proposed Fix`, with no `gh`, `git`, file or network calls.
  - `scripts/ci/Invoke-CiChangeScope.ps1` exposes `-GhInvoker`, `-GitInvoker` and `-OutputWriter` parameters and has a dot-source guard.
  - Tests live in `tests/scripts/ci/CiChangeScope.Tests.ps1`, `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1` and `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`.
  - No test creates temporary files or starts a process.
  - No Python or bash file is added for the decision logic.
  - Every new production and test file is 500 lines or fewer.
- [x] AC-18: `ci.yml` decision jobs. `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` asserts and passes on the following:
  - `ci.yml` contains a `changes` job named `Change scope` with:
    - `permissions` `actions: read` and `contents: read`;
    - `outputs.code` bound to `steps.scope.outputs.code`;
    - a checkout step with `fetch-depth: 0`, `filter: blob:none` and `persist-credentials: false`;
    - a `pwsh` step with `id: scope` and `continue-on-error: true` that runs `scripts/ci/Invoke-CiChangeScope.ps1`.
  - `ci.yml` contains a `full-run-marker` job named `CI full run` with `needs: changes` and `if: ${{ !cancelled() && needs.changes.outputs.code != 'false' }}`.
- [x] AC-19: `ci.yml` callers. `CiChangeScopeWorkflow.Tests.ps1` asserts and passes on the following:
  - each of `quality-checks7`, `security-scan`, `build-check`, `poshqc`, `shell-coverage` and `drm-copilot-extension-tests` has `needs: changes` and `if: ${{ !cancelled() }}`, and passes `run-heavy: ${{ needs.changes.outputs.code != 'false' }}`;
  - `root-typescript-tests` and `npm-audit-gate` have `needs: changes` and an `if:` that requires `needs.changes.outputs.code != 'false'`;
  - `docs-validation` has no `needs:` and no `if:`.
- [x] AC-20: Reusable-workflow gating. `CiChangeScopeWorkflow.Tests.ps1` asserts and passes on the following, for each of `_quality-checks.yml`, `_security-scan.yml`, `_build-check.yml`, `_shell-coverage.yml`, `_drm-copilot-extension-tests.yml` and `_poshqc.yml`:
  - the file declares `run-heavy` with `type: boolean` and `default: true` under both `workflow_call` and `workflow_dispatch`;
  - every step of every job that produces a required context carries an `if:` that references `inputs.run-heavy`;
  - the combined conditions from research §2.3 are present for `_quality-checks.yml` (poetry cache-miss step and the `3.13`-only step), for `_shell-coverage.yml` (kcov cache-miss step), and for every `if: always()` step of a job that has no job-level `run-heavy` gate (`always() && inputs.run-heavy`); a step in a job gated at job level keeps its condition unchanged.
- [x] AC-21: `_poshqc.yml` gating in the shape present on the branch head (unsharded, or sharded after #953). `CiChangeScopeWorkflow.Tests.ps1` asserts and passes on the following:
  - every `_poshqc.yml` job other than `poshqc` (`poshqc-linux-hooks`, and in the sharded shape also `poshqc-static` and `poshqc-shard`) carries a job-level `if: ${{ inputs.run-heavy }}`;
  - the `poshqc` job carries no job-level `run-heavy` condition; in the sharded shape it keeps `if: always()`;
  - every `poshqc` step carries `inputs.run-heavy`, including, in the sharded shape, the step that requires the static and shard jobs to succeed.
- [ ] AC-22: Unchanged surfaces. `git diff --name-only origin/main...HEAD` lists none of the following:
  - `.github/workflows/_docs-validation.yml`;
  - `.github/workflows/_root-typescript-tests.yml`;
  - `.github/workflows/_npm-audit-gate.yml`;
  - `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`;
  - `extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1`;
  - `.claude/skills/orchestrate/SKILL.md`;
  - `.claude/skills/parallel-orchestrate/SKILL.md`.

  In addition:
  - the `on:` block of `.github/workflows/ci.yml` is identical to `origin/main`;
  - `tests/scripts/workflows/CiWorkflow.Tests.ps1` and `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` are either unchanged, or changed only in an assertion that #962's gating broke, with that change recorded in the execution evidence (D6).
- [x] AC-23: Regression test fails first. Before the workflow edits, `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` fails against the pre-change workflows (missing `changes` job and `run-heavy` input). After the edits it passes. Both runs are recorded under the feature `evidence/` folder with `Timestamp`, `Command` and `EXIT_CODE`.
- [x] AC-24: Workflow README (D9). `.github/workflows/README.md` has a new section, appended at the end of the file, that documents:
  - the change-scope decision and its reason codes;
  - the allowlist file and its rules;
  - the fail-closed rules;
  - the `run-heavy` input and its default;
  - the per-context table of all 11 required contexts with their docs-only behaviour (the D1 table).

  The Triggers section is identical to `origin/main`.
- [ ] AC-25: actionlint. `scripts/dev-tools/run-actionlint.ps1` reports zero findings for every workflow file changed by this branch. The output is recorded under the feature `evidence/qa-gates/` folder.
- [ ] AC-26: PowerShell toolchain.
  - PoshQC format reports no changes required, and PoshQC analyze reports zero findings, for every new or changed `.ps1`, `.psm1` and `.Tests.ps1` file.
  - All Pester suites under `tests/scripts/ci/` and `tests/scripts/workflows/` pass in a single pass.
  - The results are recorded under the feature `evidence/qa-gates/` folder.
- [ ] AC-27: Coverage (D8). Line coverage of `scripts/ci/CiChangeScope.psm1` and `scripts/ci/Invoke-CiChangeScope.ps1`, measured from PoshQC coverage output, is at least 85% for each file. The measured values are recorded under `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/qa-gates/`.
- [ ] AC-28: CI-gate tooling unchanged and verified (D4).
  - `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` passes unchanged. This includes the existing tests that pin `skipping` as non-blocking (around line 79) and the `-RequireWorkflow` empty-set refusal (around line 364); the executor records both test names.
  - `git diff --name-only origin/main...HEAD` lists neither the parser, its bundle mirror, nor either skill file named in AC-22.
- [x] AC-29: Tier classification. `quality-tiers.yml` contains an entry with `path: "scripts/ci"`, `tier: T4` and a rationale. `scripts/dev_tools/check_quality_tiers.py` and `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py` pass.
- [ ] AC-30: Dependency composition (D5).
  - Before the first edit to `ci.yml` or `_poshqc.yml`, the executor records the `origin/main` SHA, the heads of the #952 and #953 branches, and whether each dependency is present in `origin/main`.
  - The branch contains `origin/main` through `git merge origin/main` (a merge commit, or a recorded "already up to date" state when the branch already contains it).
  - No rebase or force push is performed on `bug/ci-skip-evidence-only-commits-962`.
  - If `origin/main` gained #952 or #953 after execution started, a recorded re-integration exists: `origin/main` merged again and the affected gating and test adjustments re-verified.
- [ ] AC-31: Evidence location. Every evidence artifact produced by execution is written under `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/<kind>/`.
- [ ] AC-32 (CI-AC-1): First implementation push runs full CI. On #962's own PR, the run for the first implementation push has:
  - run conclusion `success`;
  - `CI full run` `success`;
  - every heavy job `success`;
  - a `Change scope` log line `code=true` with reason `NO_FULL_GREEN_RUN` or `NON_ALLOWLISTED_PATH: <path>`.

  Proof Procedure steps P1.1–P1.3. (CI-dependent; verified at S9 on the PR head by the item's orchestrator)
- [ ] AC-33 (CI-AC-2): Docs-only evidence commit skips heavy steps. A subsequent commit that changes only allowlisted paths under the feature folder produces a run in which:
  - the `Change scope` log shows `code=false reason=DOCS_ONLY_SINCE_<base sha>`, where `<base sha>` is the head of the AC-32 run (or of a later full run);
  - `CI full run` is `skipped`;
  - the `root-typescript-tests` and `npm-audit-gate` jobs are `skipped`;
  - the heavy steps are `skipped` (for example, `Run tests with Pytest` in each `Code Quality & Tests` job);
  - every one of the 11 required contexts reports `success`, in both `gh api .../check-runs` and `gh pr checks <PR> --required`, which returns 11 entries, all `pass`;
  - `gh pr view <PR> --json mergeStateStatus` is not blocked by checks (recorded verbatim).

  The run duration (`updatedAt - createdAt`) is recorded next to the baseline run 38896898318 from PR #959. Proof Procedure steps P0 and P2.1–P2.7. (CI-dependent; verified at S9 on the PR head by the item's orchestrator)
- [ ] AC-34 (CI-AC-3): Code change after a skip runs full CI. A subsequent commit that touches a non-allowlisted path produces a run in which:
  - `CI full run` is `success`;
  - the heavy jobs are `success`;
  - the `Change scope` log shows `code=true reason=NON_ALLOWLISTED_PATH: <path>`.

  Proof Procedure step P3. (CI-dependent; verified at S9 on the PR head by the item's orchestrator)
- [x] AC-35 (D14-a): Workflow README counts. `.github/workflows/README.md` states that `ci.yml` composes nine reusable per-stage workflows, its Per-Stage Dispatch table lists `_npm-audit-gate.yml`, and the sentence that began "All seven jobs in" begins "The seven jobs it extracted from". No other pre-existing line changes. Verified by the plan's README check.
- [ ] AC-36 (D14-b): Security scan is blocking. In `.github/workflows/_security-scan.yml`, a step named `Install the Poetry export plugin` runs `poetry self add poetry-plugin-export` directly before the step `Check for security vulnerabilities`, that step declares `shell: bash`, and the `security-scan` job carries no `continue-on-error`. Both steps are gated by `inputs.run-heavy`. Verified by a named Pester test tagged `(AC-36)` in `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`. The safety result of the first full PR run is recorded; if it reports findings, each finding is recorded under the feature `evidence/other/` folder, a remediation cycle restores `continue-on-error: true` on the scan step only, and this criterion stays unchecked until that cycle completes. (CI-dependent; verified at S9 by the item's orchestrator)
- [ ] AC-37 (D14-c): Recursive bats discovery. `scripts/bash/shell_qc_lib.sh` passes `--recursive` to bats in both `run_test` and `run_test_coverage`. The bats tests `test passes --recursive to bats for each test directory` and `test --coverage passes --recursive to bats under kcov` in `tests/shell/test_shell_qc_commands.bats` pass in the `shell-coverage / Shell Coverage (Bats + kcov)` job, and the number of tests that job runs equals the number of `@test` lines under `tests/shell/` at the run head. (CI-dependent; verified at S9 by the item's orchestrator)
- [ ] AC-38 (D14-d): Bash coverage threshold. `scripts/bash/shell_qc_lib.sh` defines `check_coverage_threshold`, which `run_test_coverage` calls after the coverage summary, with the minimum taken from `SHELL_QC_MIN_LINE_COVERAGE` (default 85). Six named bats tests (below, equal to, and above the minimum; a non-integer minimum; a minimum above 100; a missing report) pass in the `shell-coverage / Shell Coverage (Bats + kcov)` job, whose log for the first full PR run prints `Bash coverage <NN.N>% meets the minimum line coverage of 85%.`. Every changed shell file is 500 lines or fewer. (CI-dependent; verified at S9 by the item's orchestrator)

## Proof Procedure

Source: research §8. Replace `<PR>` with #962's PR number and `<idN>`/`<headN>` with the values observed in the earlier steps. Record each command's output under `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/` with `Timestamp`, `Command` and `EXIT_CODE`.

**P0: Baseline timing (before), for AC-33.**

```text
gh run view 38896898318 --repo drmoisan/drm-copilot --json createdAt,updatedAt,conclusion,headSha
```

Record the duration as `updatedAt - createdAt`.

**P1: Full run on code (AC-32).** Run these after the first implementation push.

```text
gh run list --repo drmoisan/drm-copilot --workflow ci.yml --branch bug/ci-skip-evidence-only-commits-962 --event pull_request --limit 5 --json databaseId,headSha,status,conclusion,createdAt,updatedAt
gh run view <id1> --repo drmoisan/drm-copilot --json conclusion,jobs --jq '.conclusion, (.jobs[] | [.name,.conclusion] | @tsv)'
gh run view <id1> --repo drmoisan/drm-copilot --json jobs --jq '.jobs[] | select(.name | test("Change scope")) | .databaseId'
gh run view <id1> --repo drmoisan/drm-copilot --log --job <changes-job-id-1>
```

Expected:
- the run is `success`;
- `CI full run` is `success`;
- every heavy job is `success`;
- the `Change scope` log contains `code=true` with reason `NO_FULL_GREEN_RUN` or `NON_ALLOWLISTED_PATH`.

**P2: Docs-only evidence commit (AC-33).** Commit evidence only under the feature folder, push, and wait for the run `<id2>` on head `<head2>`. Then run the following steps.

1. Run conclusion, timing and job conclusions.

   ```text
   gh run view <id2> --repo drmoisan/drm-copilot --json conclusion,createdAt,updatedAt,jobs --jq '.conclusion, .createdAt, .updatedAt, (.jobs[] | [.name,.conclusion] | @tsv)'
   ```

   Expected:
   - the run is `success`;
   - `Change scope` is `success`;
   - `CI full run` is `skipped`;
   - the `root-typescript-tests` and `npm-audit-gate` jobs are `skipped`;
   - the 11 required job names are present with `success`.

2. Count of succeeded steps in each `Code Quality` job.

   ```text
   gh run view <id2> --repo drmoisan/drm-copilot --json jobs --jq '.jobs[] | select(.name | test("Code Quality")) | [.name, ([.steps[] | select(.conclusion == "success")] | length)] | @tsv'
   ```

   Expected: only the runner set-up and tear-down steps succeed.

3. Heavy-step conclusion.

   ```text
   gh run view <id2> --repo drmoisan/drm-copilot --json jobs --jq '.jobs[] | select(.name | test("Code Quality")) | .steps[] | select(.name == "Run tests with Pytest") | .conclusion'
   ```

   Expected: `skipped`.

4. Decision log.

   ```text
   gh run view <id2> --repo drmoisan/drm-copilot --json jobs --jq '.jobs[] | select(.name | test("Change scope")) | .databaseId'
   gh run view <id2> --repo drmoisan/drm-copilot --log --job <changes-job-id-2>
   ```

   Expected: the line `code=false reason=DOCS_ONLY_SINCE_<sha of the id1 head>`.

5. Check runs on the head commit.

   ```text
   gh api repos/drmoisan/drm-copilot/commits/<head2>/check-runs --paginate --jq '.check_runs[] | [.name,.status,.conclusion] | @tsv'
   ```

   Expected: each of the 11 ruleset contexts (D1 table) appears as `completed` / `success`. Compare the names line by line with the D1 table. Whether the API `name` field includes the caller prefix is unverified (research §8). If the prefix is absent, compare against the called-job-name suffix and record that observation.

6. Required checks.

   ```text
   gh pr checks <PR> --repo drmoisan/drm-copilot --required --json name,bucket,state
   ```

   Expected: 11 entries, all `pass`.

7. Merge state.

   ```text
   gh pr view <PR> --repo drmoisan/drm-copilot --json mergeStateStatus,headRefOid
   ```

   Expected: not `BLOCKED` because of checks (`CLEAN`, or `BEHIND` if `main` moved). Record the value verbatim.

Timing (after): record `updatedAt - createdAt` of `<id2>` next to the P0 value.

**P3: Code change after the skip (AC-34).** Push a commit that touches a non-allowlisted path (for example, a comment in `scripts/ci/CiChangeScope.psm1`), then repeat the P1 commands for the new run `<id3>`.

Expected:
- `CI full run` is `success`;
- the heavy jobs are `success`;
- the `Change scope` log shows `code=true reason=NON_ALLOWLISTED_PATH: scripts/ci/CiChangeScope.psm1`.

**P4 (optional): fail-closed spot check.** A commit that touches only `docs/features/templates/README.md` produces reason `NON_ALLOWLISTED_PATH`, and the full run executes. This step is not an acceptance criterion.

## Out of Scope

The following defects were observed in research §12 and are not fixed by this item:

1. `.github/instructions/github-actions.instructions.md:15` cites a CI `actionlint` job in `ci.yml`. No such job exists, so workflow edits are not linted in CI. This item runs actionlint locally (AC-25) but does not add a CI job.
2. Moved into scope by coordinator decision D14-a (AC-35): `.github/workflows/README.md` described "eight reusable per-stage workflows" and "All seven jobs" and omitted `_npm-audit-gate.yml`; those lines are corrected.
3. Moved into scope by coordinator decision D14-b (AC-36): the only substantive step in `_security-scan.yml` had `continue-on-error: true`, and `poetry export` was unavailable under Poetry 2.x, so the scan could neither fail nor read any package. The step is made blocking with a working export; if the first full PR run reports findings, the remediation rule of AC-36 applies.
4. The supplied #953 patch does not update `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` (lines 51 and 58). Resolving this belongs to #953 (unverified whether it is already handled there).
5. Moved into scope by coordinator decision D14-c (AC-37): the bats runner discovered only top-level files in `tests/shell` and `tests/bash`.
6. CI does not enforce a coverage threshold for PowerShell (`CoveragePercentTarget = 0`); that part remains owned by #953. The bash part is moved into scope by coordinator decision D14-d (AC-38).

Also out of scope:
- research Candidates A and C;
- any ruleset 15241672 change;
- merge-queue enablement (#952);
- the deferred B-variant that would skip non-matrix required jobs at job level inside the called workflow (depends on F8);
- extending the allowlist to `docs/features/epics/`, `docs/engineering/` or `docs/discovery/`;
- the #952 `Invoke-MergeConfirmationParser.ps1` requirement in research §6, which is handed to #952.

## Risks & Mitigations

- Technical or operational risks:
  - A skipped run does not test the merge result with a newer `main` (D7).
  - An unverified context name in the check-runs API (research §8).
  - `filter: blob:none` may be unsupported by the pinned checkout tag (research §3.1).
  - The allowlist may admit a path that a heavy job reads. Research §4.2 found no real-repository reads under the included prefixes for the idioms searched; that search is not a proof of absence.
- Mitigations and rollbacks:
  - Strict up-to-date policy, plus `merge_group` and push-to-main never skipping (D7).
  - The CI-dependent ACs AC-32 to AC-34 observe the real context names and checkout behaviour.
  - Extension restriction and exclusions (D3).
  - Rollback by reverting the caller lines in `ci.yml` (see Rollback above).

## Rollout & Follow-up

- Release/rollout steps:
  1. Record whether #952 and #953 are in `origin/main` (they are not prerequisites).
  2. Integrate with `git merge origin/main`, and again whenever `origin/main` gains #952 or #953 before this item merges.
  3. Implement.
  4. Prove on #962's own PR (`## Proof Procedure`).
  5. Merge.
- Post-fix monitoring or clean-up tasks:
  - Observe the docs-only run duration on the next items.
  - Revisit the B-variant once F8 has been observed empirically.
- Links:
  - Issue: https://github.com/drmoisan/drm-copilot/issues/962
  - Related: #952; #953 / PR #959
  - Research: `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/research/research.2026-10-16T14-39.md`
