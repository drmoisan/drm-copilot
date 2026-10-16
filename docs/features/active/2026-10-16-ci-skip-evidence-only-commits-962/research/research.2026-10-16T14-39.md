# Research: ci-skip-evidence-only-commits (Issue #962)

- Issue: #962
- Branch: `bug/ci-skip-evidence-only-commits-962`
- Timestamp: 2026-10-16T14-39 (UTC)
- Timestamp source: this agent session had no shell tool, so the host clock could not be read. The value was read from an external UTC clock (`https://timeapi.io/api/time/current/zone?timeZone=UTC`, returned `2026-10-16T14:39:13`). It is consistent with `plan.2026-10-16T10-27.md` (America/New_York, 14:27 UTC).
- Inputs read: `issue.md`, `spec.md`, `plan.2026-10-16T10-27.md`, `.github/workflows/*.yml`, `.github/workflows/README.md`, `tests/scripts/workflows/*.Tests.ps1`, ruleset 15241672 JSON, the #952 and #953 patch files, `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` and its tests, `.claude/skills/orchestrate/SKILL.md` (S9), `.claude/skills/parallel-orchestrate/SKILL.md` (merge-on-green), `.claude/hooks/hook-docs-only-diff.ps1`, `scripts/bash/shell_qc_lib.sh`, `scripts/powershell/PoshQC/*`, `config/poshqc-coverage.json`, `quality-tiers.yml`, `pyproject.toml`, `package.json`.
- Verification markers: **[verified]** = confirmed by a file read, a grep, or a fetched first-party document in this session; **[reported]** = third-party report (GitHub community); **[unverified]** = not confirmed; must be checked by the proof plan.

## 1. Current State

### 1.1 `ci.yml`

`.github/workflows/ci.yml` (41 lines) has three triggers (`push` to main/development, `pull_request` to main/development/`epic/**`, `workflow_dispatch`; lines 3-8) and nine caller jobs, all `uses: ./.github/workflows/_*.yml` with no `needs:` edges (lines 11-41). Only `npm-audit-gate` sets `name:`, `permissions:` and `with:` (lines 35-41). There is no workflow-level `permissions:` block. **[verified]**

### 1.2 Reusable workflows and the job names they produce

| Caller job (ci.yml) | Called file | Called job id / `name:` | Matrix | Required |
|---|---|---|---|---|
| `quality-checks7` | `_quality-checks.yml` | `quality-checks7` / `Code Quality & Tests` (line 9) | `python-version: [3.10, 3.11, 3.12, 3.13]` (lines 11-13); name has no matrix expression, so GitHub appends `(3.10)` etc. | yes (4 contexts) |
| `security-scan` | `_security-scan.yml` | `security-scan` / `Security Scanning` (line 9) | none | yes |
| `docs-validation` | `_docs-validation.yml` | `docs-validation` / `Documentation Validation` (line 9) | none | yes |
| `build-check` | `_build-check.yml` | `build-check` / `Build Package` (line 9) | none | yes |
| `poshqc` | `_poshqc.yml` | `poshqc` / `PowerShell QC` (line 9); `poshqc-linux-hooks` / `PowerShell hook suites (Linux)` (line 55) | none | `poshqc` only |
| `shell-coverage` | `_shell-coverage.yml` | `shell-coverage` / `Shell Coverage (Bats + kcov)` (line 9) | none | yes |
| `drm-copilot-extension-tests` | `_drm-copilot-extension-tests.yml` | `drm-copilot Extension Tests (${{ matrix.os }})` (line 9) | `os: [windows-latest, ubuntu-latest]` (line 13) | yes (2 contexts) |
| `root-typescript-tests` | `_root-typescript-tests.yml` | `Root TypeScript Tests (${{ matrix.os }})` (line 9) | `os` x2 | no |
| `npm-audit-gate` | `_npm-audit-gate.yml` | `npm audit (${{ matrix.manifest }})` (line 25) | `manifest` x3 | no |

`_npm-audit-gate.yml` is the only reusable workflow that declares inputs; it declares the same input under both `workflow_call` and `workflow_dispatch` (lines 4-21). That is the precedent for adding a `run-heavy` input. **[verified]**

### 1.3 Ruleset 15241672

`protect-main`, enforcement `active`, target `~DEFAULT_BRANCH`. The `required_status_checks` rule has `strict_required_status_checks_policy: true` and 11 contexts, all with `integration_id` 15368. **[verified]** (see Numeric Derivation Evidence N1)

### 1.4 Existing workflow tests

- `tests/scripts/workflows/CiWorkflow.Tests.ps1` asserts only the `on:` block. Its branch-filter lookup is scoped to the trigger block (lines 23-40, 149-173). **[verified]**
- `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` partitions `_poshqc.yml` into job blocks and asserts the exact job set `poshqc,poshqc-linux-hooks` (line 51). It also asserts that `Invoke-PoshQCTest -Root` appears in the `poshqc` job (line 58). **[verified]**
- Both files note that Pester discovers tests only under `scripts`, `tests/powershell` and `tests/scripts` (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1:3`). **[verified]**

### 1.5 Prior art for a docs-only classifier

`.claude/hooks/hook-docs-only-diff.ps1` (#927) classifies a PR diff as docs-only for the merge-gate exemption. The parts relevant to #962 are:

- the hardened diff invocation `git diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative` (line 484);
- the NUL-termination check (lines 148-151);
- the ordinal prefix test (lines 117-121);
- injectable `-GitInvoker`/`-GhInvoker` seams (lines 263, 303).

The file is a hook library that depends on the command parsers and is mirrored byte-identically in four locations (line 59). #962 should copy these techniques but should not import the file. **[verified]**

## 2. Required-Check Semantics When Skipped (Question 1)

### 2.1 Documented and reported facts

- F1 **[verified, docs.github.com "Using conditions to control job execution"]**: "A job that is skipped will report its status as "Success"." and "It will not prevent a pull request from merging, even if it is a required check."
- F2 **[verified, docs.github.com "Troubleshooting required status checks"]**: a job skipped by a conditional reports "Success". A workflow skipped by path, branch or commit-message filtering reports no result, and its checks "stay in a "Pending" state and block merging." The page lists "success", "skipped" and "neutral" as successful statuses. For required checks that depend on other jobs, it recommends `always()` with `needs`.
- F3 **[verified, workflow syntax reference]**: "If a job fails or is skipped, all jobs that need it are skipped." (unless a status-check function is used in `if:`).
- F4 **[verified, "Reusing workflow configurations"]**: `jobs.<job_id>.if`, `needs`, `with`, `strategy`, `permissions` and `concurrency` are supported on a job that calls a reusable workflow.
- F5 **[reported, github.com/orgs/community/discussions/9141]**: a job-level `if:` skips a matrix job "before expanding the matrix". The skipped check is named after the unexpanded job (`build`), not the expanded legs (`build (17)`). Required checks match exact strings only, so the expanded required contexts never report.
- F6 **[verified by ruleset content]**: contexts for reusable-workflow jobs take the form `<caller job id> / <called job name>`, for example `quality-checks7 / Code Quality & Tests (3.10)`.
- F7 **[unverified]**: the context name GitHub reports when a caller job (`uses:`) is skipped by its own `if:`. It is reported to be the caller job id/name alone (for example `security-scan`), which does not match `security-scan / Security Scanning`. No first-party document describing this case was found.
- F8 **[unverified]**: the context name reported for a non-matrix job inside a called workflow that is skipped by a job-level `if:`. It is expected to be `<caller> / <called name>`, but this was not confirmed.

### 2.2 Context-by-context outcome per candidate design

Candidate A: job-level `if: needs.changes.outputs.code == 'true'` on the caller jobs in `ci.yml`.
Candidate B: the caller jobs always run. Each heavy reusable workflow takes a boolean `run-heavy` input. In required jobs every step is gated on that input, so the job and its matrix still start and their names expand exactly as in a full run. Non-required jobs are skipped with a job-level `if:`.
Candidate C: one always-run aggregator job, with the ruleset changed to require that single context.

| # | Required context | A (caller `if:`) | B (`run-heavy`, step gating) | C (aggregator + ruleset change) |
|---|---|---|---|---|
| 1 | `drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)` | never reported, "Expected — Waiting" (F5, F7) | reported, `success` (job runs; all steps skipped) | context removed from ruleset |
| 2 | `drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)` | never reported (F5, F7) | `success` | removed |
| 3 | `docs-validation / Documentation Validation` | `success` (always runs) | `success` (unchanged) | removed |
| 4 | `poshqc / PowerShell QC` | name unverified (F7); not reliable | `success`: aggregator runs (`if: always()` per #953) with steps gated; static, shard and linux-hooks jobs skipped at job level (not required) | removed |
| 5 | `shell-coverage / Shell Coverage (Bats + kcov)` | name unverified (F7) | `success` | removed |
| 6 | `security-scan / Security Scanning` | name unverified (F7) | `success` | removed |
| 7-10 | `quality-checks7 / Code Quality & Tests (3.10)` ... `(3.13)` | never reported (F5) | `success` x4 (matrix expands) | removed |
| 11 | `build-check / Build Package` | name unverified (F7) | `success` | removed |

Recommendation: **Candidate B.** It is the only candidate under which every one of the 11 required contexts reports `success` with the same name as in a full run. It does not depend on F7 or F8 and needs no ruleset change.

Rejected alternatives:
- A fails for the six matrix contexts (F5), and for the others it depends on the unverified F7.
- C requires a privileged ruleset edit, removes per-job required contexts, and interacts with the #952 merge queue configuration.
- A B-variant that skips the non-matrix required jobs at job level inside the called workflow would save a runner start per job, but it depends on F8. Defer it until F8 has been observed empirically.

### 2.3 Candidate B wiring details

- Caller jobs that produce required contexts (`quality-checks7`, `security-scan`, `build-check`, `poshqc`, `shell-coverage`, `drm-copilot-extension-tests`) get:
  - `needs: changes`
  - `if: ${{ !cancelled() }}`
  - `with: { run-heavy: ${{ needs.changes.outputs.code != 'false' }} }`

  The `!= 'false'` comparison fails closed. When `changes` fails, is skipped, or emits nothing, the input is `true`. The `!cancelled()` status function keeps a failed `changes` job from skipping the callers (F3), which would otherwise depend on F7. In YAML the expression must be wrapped in `${{ }}`, because a leading `!` is a YAML tag.
- Non-required callers (`root-typescript-tests`, `npm-audit-gate`) get `needs: changes` and `if: ${{ !cancelled() && needs.changes.outputs.code != 'false' }}`. Their naming does not matter.
- `docs-validation` is unchanged: no `needs:`, always runs.
- Each gated reusable workflow declares `run-heavy` (`type: boolean`, `default: true`) under both `workflow_call` and `workflow_dispatch`, following the `_npm-audit-gate.yml:4-21` pattern. Standalone dispatches (`.github/workflows/README.md:20-29`) therefore keep their behaviour.
- Step gating. Every step of a required job gets `if: ${{ inputs.run-heavy }}`. Steps that already have an `if:` are combined:
  - `_quality-checks.yml:39`: `inputs.run-heavy && steps.cached-poetry-dependencies.outputs.cache-hit != 'true'`
  - `_quality-checks.yml:95`: `inputs.run-heavy && matrix.python-version == '3.13'`
  - `_shell-coverage.yml:34`: `inputs.run-heavy && steps.cache-kcov.outputs.cache-hit != 'true'`
  - `if: always()` upload steps: `always() && inputs.run-heavy`

  `_shell-coverage.yml:57-62` uploads with `if-no-files-found: error`, so that step must be gated too.
- `_poshqc.yml`, after #953:
  - `poshqc-static`, `poshqc-shard` and `poshqc-linux-hooks` get the job-level `if: ${{ inputs.run-heavy }}`.
  - The aggregator `poshqc` keeps `if: always()`. Every step, including "Require the static and shard jobs to succeed" (#953 patch lines 84-92), gets `if: ${{ inputs.run-heavy }}`.
  - When `run-heavy` is false the aggregator runs no steps and succeeds. When it is true, the existing `success` check still applies, so a skipped shard on a full run still fails.

## 3. Decision Job Design (Question 2)

### 3.1 Jobs added to `ci.yml`

`changes` (name `Change scope`):

- `runs-on: ubuntu-latest`
- `permissions: { actions: read, contents: read }` (job-level; other jobs are unaffected)
- `outputs.code: ${{ steps.scope.outputs.code }}`

Steps:

1. `actions/checkout@v7` with:
   - `ref: ${{ github.event.pull_request.head.sha || github.sha }}`
   - `fetch-depth: 0`
   - `filter: blob:none`
   - `persist-credentials: false`

   `filter` and `fetch-depth` are confirmed inputs of `actions/checkout` (action.yml on `main` **[verified]**); their presence in the v7 tag is **[unverified]**. A partial clone without blobs is enough for `merge-base --is-ancestor` and for a `--name-only --no-renames` tree diff.
2. `id: scope`, `shell: pwsh` (pwsh on `ubuntu-latest` is already used at `_poshqc.yml:64-82` **[verified]**), `continue-on-error: true`, running `scripts/ci/Invoke-CiChangeScope.ps1`. Inputs come through `env:`:
   - `GH_TOKEN: ${{ github.token }}`
   - `EVENT_NAME`, `HEAD_SHA`, `HEAD_REF: ${{ github.head_ref }}`, `HEAD_REPO: ${{ github.event.pull_request.head.repo.full_name }}`, `REPOSITORY`, `RUN_ID`

   The script writes `code=<true|false>` to `$GITHUB_OUTPUT`, and the reason and base SHA to the log and `$GITHUB_STEP_SUMMARY`.

`full-run-marker` (name `CI full run`): `needs: changes`, `if: ${{ !cancelled() && needs.changes.outputs.code != 'false' }}`, one `run: echo` step. It is the durable record that a run executed the heavy jobs. It is not a required check.

### 3.2 Distinguishing a full run from a skipped-heavy run

A run counts as a green base only when both of the following are true:

1. `conclusion == success` for the whole run.
2. Its `CI full run` job concluded `success` (from `GET /repos/{o}/{r}/actions/runs/{id}/jobs?filter=latest`).

A docs-only run has `CI full run` = `skipped`, so it never qualifies. Chained docs-only commits therefore always diff against the last full run, and drift is not possible. Rejected alternatives:

- Inspecting heavy step conclusions depends on step names.
- A marker artifact adds upload/list calls and is subject to artifact retention.

### 3.3 Algorithm (fail closed at every step; reason codes for the log)

1. Event gate (pure). `EVENT_NAME != 'pull_request'` -> `code=true` (`EVENT_NOT_PULL_REQUEST`). This covers `merge_group`, `push` and `workflow_dispatch`. No API or git calls are made.
2. Fork gate (pure). `HEAD_REPO != REPOSITORY` -> `code=true` (`FORK_PULL_REQUEST`). The GITHUB_TOKEN is read-only for fork PRs **[verified, events doc]**, and branch-name collisions across repositories are avoided.
3. Run listing (I/O): `gh api "repos/$REPOSITORY/actions/workflows/ci.yml/runs?branch=$HEAD_REF&event=pull_request&status=success&per_page=50"`. Query parameters `branch`, `event`, `status=success` and `per_page` (max 100) are documented **[verified]**. Result order is not documented, so the pure selection function sorts by `run_number` descending. Runs are excluded when:
   - `id == RUN_ID`, or
   - `head_repository.full_name != REPOSITORY`.

   An API error or unparseable JSON -> `code=true` (`RUN_LIST_FAILED`).
4. Marker lookup (I/O): for each candidate in order, read the jobs of its latest attempt. The first candidate whose `CI full run` job concluded `success` is the base. If no candidate in the page qualifies -> `code=true` (`NO_FULL_GREEN_RUN`). If a jobs call fails -> `code=true` (`JOB_LIST_FAILED`).
5. Ancestry (I/O + pure):
   - `git cat-file -e <base>^{commit}` fails -> `code=true` (`BASE_NOT_PRESENT`; for example after a force push).
   - `git merge-base --is-ancestor <base> <head>` exits 1 -> `code=true` (`BASE_NOT_ANCESTOR`).
   - Any other non-zero exit -> `code=true` (`ANCESTRY_CHECK_FAILED`).

   Only the newest qualifying base is considered. The issue lists a non-ancestor as fail-closed, and scanning older runs would add a branch with little benefit.
6. Diff (I/O): `git diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative <base> <head>`. The two-point form compares the two trees directly.
   - `--no-renames` is required: without it, a move from `src/x` to `docs/x` lists only the docs-side path.
   - A non-zero exit, or non-empty output that does not end in NUL, -> `code=true` (`DIFF_FAILED`).
7. Classification (pure):
   - empty path set -> `code=true` (`EMPTY_DIFF`)
   - any path outside the allowlist -> `code=true` (`NON_ALLOWLISTED_PATH: <first path>`)
   - otherwise `code=false` (`DOCS_ONLY_SINCE_<base>`)
8. Error envelope. Any exception -> `code=true` (`UNEXPECTED_ERROR`), a `::warning::` annotation, exit 0. `continue-on-error: true` on the step covers a crash that happens before the output is written; the callers' `!= 'false'` then defaults to a full run.

### 3.4 Considerations

- Base vs merge ref. For `pull_request`, `GITHUB_SHA` is the merge commit on `refs/pull/N/merge` **[verified, events doc]**, and a run's `head_sha` is the PR head. The diff therefore compares PR heads (base head vs current head), not merge commits. If `main` moved between the green run and the evidence commit, the skipped run did not test the new merge result. The residual risk is covered as follows:
  - Without a merge queue, ruleset `strict_required_status_checks_policy: true` (ruleset JSON) requires the branch to be up to date. Re-syncing adds non-docs paths and forces a full run.
  - With #952, `merge_group` runs never skip (step 1).
  - Pushes to `main` never skip.

  This should be recorded as an accepted risk in the spec. Tying the base to the base SHA would remove most of the savings once the merge queue removes re-syncs.
- Re-runs.
  - "Re-run all jobs" re-runs `changes` and repeats the decision. The rerun's own run id is excluded, and a prior docs-only attempt never qualifies.
  - "Re-run failed jobs" reuses the earlier `changes` output.
- `pull_request` activity types: by default `opened`, `synchronize`, `reopened` **[verified]**. The first run on a new PR has no prior full-green run and is a full run.
- Permissions: `actions: read` is needed for the runs and jobs endpoints, `contents: read` for checkout. The runs endpoint is available to "anyone with read access" **[verified]**.

## 4. Allowlist (Question 3)

### 4.1 Location and format

`config/ci-docs-only-paths.json`. JSON follows the existing `config/poshqc-coverage.json` shape (`{"version":1,"roots":[...]}`, lines 1-10) and is read natively by PowerShell (`ConvertFrom-Json`). Proposed schema:

```json
{
  "version": 1,
  "include_prefixes": [
    "docs/features/active/",
    "docs/features/completed/",
    "docs/features/potential/",
    "docs/research/"
  ],
  "exclude_prefixes": [
    "docs/features/potential/template.md",
    "docs/features/templates/"
  ],
  "extensions": [".md", ".txt", ".log", ".json", ".xml"]
}
```

A path is allowlisted only if all of the following hold:

- it starts with an include prefix (ordinal, case-sensitive);
- it does not start with any exclude prefix;
- its lower-cased extension is in `extensions`;
- it has no `..` segment, no backslash, and no leading `/`.

The config file is outside the allowlist, so a change to it forces a full run. The file is read from the checked-out head, which is the same trust boundary as the workflow file itself.

### 4.2 Evidence for the entries and exclusions

- Excluded: `docs/features/templates/**`. Real-repository reads exist in `tests/scripts/dev_tools/test_minor_audit_acceptance_criteria_contracts.py:74` (`read_repo_text("docs/features/templates/README.md")`) and `tests/scripts/dev_tools/parallel_orchestrator_surface_test_support.py:43` (`docs/features/templates/parallel/parallel-status.md`). **[verified]**
- Excluded: `docs/features/potential/template.md`. It is a runtime template (`extensions/drm-copilot/resources/templates/new-potential-entry.ps1:155`). **[verified]**
- Not included: `docs/engineering/**` and `docs/discovery/**`. Tests read real files there: `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1:9` and `tests/scripts/dev_tools/discovery/test_domain_neutrality.py:17`. **[verified]**
- Not included initially: `docs/features/epics/**`. Epic tooling consumes `epic.md` at runtime. No CI test reading it was found, but it was left out for conservatism.
- Extension restriction. Linters scan the whole repository: Black and Ruff have no `docs` exclusion (`pyproject.toml:84-111`), and PoshQC format/analyze excludes only `DefaultExcludedDirs` (`scripts/powershell/PoshQC/PoshQC.psm1:5-9`). A `.py` or `.ps1` file under `docs/` would therefore be checked by heavy jobs, and skipping could hide a failure. Prettier and ESLint are scoped to `src`/`tests` (`package.json:33-36`). Existing evidence file types under `docs/features/**` are `.md`, `.json`, `.xml`, `.txt`, `.log` (one `.png`) **[verified by glob]**. The only code-like file under `docs/` is `docs/discovery/templates/domain-profile/domain-profile.yaml` **[verified by glob]**.
- Included: `docs/features/active|completed/**`. Greps for real-repository reads (`read_text`, `read_repo_text`, `Get-Content`, `readFileSync`, `open(` with `docs/features/(active|completed|potential|epics)`) returned no matches. Remaining references are string literals or synthetic paths (for example `tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py:48`, `extensions/drm-copilot/test/*.test.ts`). **[verified for the patterns searched; not a proof of absence for every read idiom]**
- Bundle parity: `extensions/drm-copilot/resources/` contains no `docs/` tree **[verified by glob]**, so allowlisted paths cannot affect the bundle-parity tests.
- `docs-validation` checks only `README.md`, `LICENSE` and two instruction files (`_docs-validation.yml:16-37`). It does not validate feature evidence. That is acceptable for the issue's scope and should be noted in the spec.

## 5. Script Language and Decomposition (Question 4)

Recommendation: **PowerShell 7**. Python is excluded by the issue. Bash is the alternative considered.

Rationale:

1. The closest precedent, the docs-only classifier with git/gh seams and Pester tests, is PowerShell (`.claude/hooks/hook-docs-only-diff.ps1`).
2. Test placement follows the mirror rule. `scripts/ci/X.ps1` maps to `tests/scripts/ci/X.Tests.ps1`, which is inside a Pester discovery root (`pester.runsettings.psd1:3`). Bats discovery, by contrast, runs `bats <dir>` non-recursively over `tests/shell` and `tests/bash` only (`scripts/bash/shell_qc_lib.sh:104-119, 262, 365`). A mirrored bats file would not run, and the flat `tests/shell/` convention departs from `.claude/rules/general-unit-test.md` (Test File Location).
3. Coverage. `config/poshqc-coverage.json` already includes the `scripts` root, so `scripts/ci/*.ps1` and `*.psm1` enter the PoshQC coverage population without configuration changes. Bash under `scripts/` would also be picked up by kcov, shellcheck and shfmt (`shell_qc_lib.sh:85, 350`).
4. JSON from the GitHub API is parsed natively, with no `jq` binary.
5. Local agent execution: Pester runs on the Windows host through the PowerShell session. Bats requires WSL.

Bash remains acceptable but was not selected because of points 2 and 5.

Decomposition:

- `scripts/ci/CiChangeScope.psm1` holds the pure functions (no I/O):
  - `Test-CiChangeScopeEventEligible -EventName -HeadRepository -Repository` -> reason or `$null`
  - `ConvertFrom-CiDocsOnlyPathConfig -Json` -> validated config (version, non-empty include list, prefixes ending in `/` or naming a file, extensions starting with `.`); throws on an invalid config
  - `Test-CiDocsOnlyPath -Path -Config` -> bool
  - `Get-CiChangeScopePathDecision -Paths -Config` -> `EMPTY_DIFF` / `NON_ALLOWLISTED_PATH` / `$null`
  - `ConvertFrom-CiNulPathList -Text` (NUL split plus the termination check)
  - `Select-CiGreenBaseCandidates -RunsJson -CurrentRunId -Repository` -> ordered candidates
  - `Test-CiFullRunMarker -JobsJson -MarkerName` -> bool
  - `New-CiChangeScopeDecision -Code -Reason -BaseSha` -> record
- `scripts/ci/Invoke-CiChangeScope.ps1` is the thin I/O entry point. It reads env, calls `gh`/`git` through injectable `-GhInvoker`/`-GitInvoker` scriptblocks (the `hook-docs-only-diff.ps1:263, 303` pattern), writes `$GITHUB_OUTPUT` and `$GITHUB_STEP_SUMMARY` through an injectable `-OutputWriter`, and applies the fail-closed envelope. A dot-source guard follows `Invoke-CiGateParser.ps1:390-401`.
- Tests:
  - `tests/scripts/ci/CiChangeScope.Tests.ps1` (pure functions)
  - `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1` (seams mocked with test-local scriptblocks; no temporary files, no process start; `$GITHUB_OUTPUT` captured through `-OutputWriter`)
  - `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`: invariants on the committed config. Every include prefix is under `docs/`; no prefix covers `docs/features/templates/`, `docs/engineering/` or `docs/discovery/`; no extension is a code extension (`.py`, `.ps1`, `.psm1`, `.psd1`, `.sh`, `.bats`, `.ts`, `.tsx`, `.js`, `.mjs`, `.cjs`, `.cs`, `.yml`, `.yaml`, `.toml`).
- Required test scenarios, from the issue: allowlist positive and negative, non-ancestor base, missing base, empty diff, mixed diff. Also:
  - each non-PR event
  - fork PR
  - API error
  - malformed JSON
  - no marker
  - marker skipped (docs-only prior run)
  - current-run exclusion
  - unsorted API order
  - rename across the boundary (`--no-renames` argument asserted)
  - non-NUL-terminated output
  - `..` / backslash / leading-slash paths
  - upper-case extension
  - invalid config
  - unexpected exception -> `code=true`
- Tier: R3 of `scripts/dev_tools/quality_tiers_contract.py:19-23` discovers `scripts/ci` as a new project, so `quality-tiers.yml` needs an entry. Recommend `T4` (CI scaffolding). `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py:198-199` rejects any T1/T2 entry. Adding a new row does not affect the `len(SPEC_TIER_ASSIGNMENTS) == 24` assertion at line 195, which checks a constant.
- Coverage: PoshQC has `CoveragePercentTarget = 0` (`pester.runsettings.psd1:26`), so CI does not enforce the 85% line threshold for PowerShell. The plan must measure changed-file coverage from `artifacts/pester/powershell-coverage.xml` and record it under `<FEATURE>/evidence/qa-gates/`.

## 6. CI-Gate Tooling (Question 5)

- `gh pr checks` bucket mapping, cli/cli `pkg/cmd/pr/checks/aggregate.go` on trunk **[verified]**:
  - `SUCCESS` -> `pass`
  - `SKIPPED`, `NEUTRAL` -> `skipping`
  - `ERROR`, `FAILURE`, `TIMED_OUT`, `ACTION_REQUIRED` -> `fail`
  - `CANCELLED` -> `cancel`
  - everything else, including `EXPECTED`, `QUEUED`, `IN_PROGRESS` -> `pending`

  The `gh` version installed on agent hosts was not checked **[unverified]**.
- `Invoke-CiGateParser.ps1`:
  - `skipping` is non-blocking (line 219). Conclusion precedence is fail/cancel -> pending -> success (lines 205-240).
  - An empty set returns `success` unless `-RequireWorkflow` is set (lines 177-182). Under `-RequireWorkflow CI`, success requires at least one `pass` from workflow `CI` (lines 213-217, 236-238).
  - Existing tests pin both behaviours: `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1:79` and `:364`. **[verified]**
- S9 (`.claude/skills/orchestrate/SKILL.md:285-300`) never treats a `no checks reported` error as green and never calls the parser with `'[]'` without `-RequireWorkflow CI` (line 294). Its success definition already reads "every queried check passed or was skipped" (line 298). Parallel merge-on-green applies the same parser and the same no-checks refusal (`.claude/skills/parallel-orchestrate/SKILL.md:376-385`). **[verified]**
- Conclusion: **no fix is required.** Skipped and neutral checks are already green. "At least one check exists" is enforced procedurally by S9 and parallel step 2, and by the parser only under `-RequireWorkflow`.
  - Under Candidate B, a docs-only run reports the required jobs as `success` (bucket `pass`), plus `Change scope` and `Documentation Validation` as `pass`. The epic guard is satisfied too.
  - Because the parser, the bundle mirror (`extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1`) and the S9 text do not change, no parity or contract test (`tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`, `test_ci_gate_epic_child_contracts.py`, `test_skill_bundle_contract_repo.py`) is affected and no CHANGELOG entry is needed.
- Limitation (not a defect against the parser's contract). `gh pr checks` lists only reported checks. A required context that never reports (a name mismatch such as Candidate A's matrix case) is invisible to the parser, so the gate could read `success` while the ruleset blocks the merge. The failure mode is a refused `gh pr merge`, not a false merge. Candidate B avoids it by construction. The proof plan checks the merge state explicitly.
- #952 `Invoke-MergeConfirmationParser.ps1`: **[unverified]**. The supplied #952 patch modifies only `.github/workflows/README.md` and `.github/workflows/ci.yml`. No `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` exists in this worktree (glob returned no match). Requirement to hand to #952: if that parser consumes `gh pr checks` buckets, it must treat `skipping` as non-blocking and must not treat an empty set as merged or green.

## 7. Composition with #952 and #953 (Question 6)

- The `merge_group` trigger never skips. The `changes` event gate returns `code=true` for every non-`pull_request` event before any API call (`github.head_ref` is empty on `merge_group`). The `CI full run` marker then runs, and all heavy jobs execute.
- Textual conflict risk:

| File | #952 | #953 | #962 edit shape | Risk |
|---|---|---|---|---|
| `.github/workflows/ci.yml` | inserts `merge_group:` / `types: [checks_requested]` after line 8 | none | leave the `on:` block untouched; add `changes` and `full-run-marker` and per-caller `needs`/`if`/`with` lines in `jobs:` (line 10 onward) | low: at least two unchanged lines (blank line 9, `jobs:` line 10) separate the hunks |
| `.github/workflows/README.md` | edits the Triggers section (lines 9-15) | none | append a new section at the end of the file; do not edit Triggers | low |
| `.github/workflows/_poshqc.yml` | none | renames `poshqc` to `poshqc-static`, adds `poshqc-shard` and the `poshqc` aggregator, edits linux-hooks | adds the `run-heavy` input and gating to every job | high if written against current `main`; none if written after #953 merges |
| `tests/scripts/workflows/CiWorkflow.Tests.ps1` | changes reported by the orchestrator; not in the supplied patch **[unverified]** | none | do not edit; put #962 assertions in a new file | none |
| `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` | none | must change (the job-set assertion at line 51 conflicts with the patched job set); not in the supplied patch **[unverified]** | do not edit; new file | none |

- Ordering: merge #952 and #953 first, as the issue states. Then rebase `bug/ci-skip-evidence-only-commits-962` on `main`, write `_poshqc.yml` gating against the sharded shape, and force-push with lease. Write #962's workflow assertions in new test files (`tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`) so that #962 never edits the files #952 and #953 change.

## 8. Proof Plan (Question 7)

Every step uses `gh`/`git` and can be run by an agent. Replace `<PR>` with #962's PR number. Record each output under `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/` with `Timestamp`, `Command` and `EXIT_CODE`.

1. Baseline timing (before). `gh run view 38896898318 --repo drmoisan/drm-copilot --json createdAt,updatedAt,conclusion,headSha` gives the PR #959 evidence-commit run named in the issue. Record the duration as `updatedAt - createdAt`.
2. Full run on code (P1). After the implementation push:
   - Run `gh run list --repo drmoisan/drm-copilot --workflow ci.yml --branch bug/ci-skip-evidence-only-commits-962 --event pull_request --limit 5 --json databaseId,headSha,status,conclusion,createdAt,updatedAt`.
   - Then run `gh run view <id1> --repo drmoisan/drm-copilot --json conclusion,jobs --jq '.conclusion, (.jobs[] | [.name,.conclusion] | @tsv)'`.
   - Expected: run `success`; `CI full run` `success`; every heavy job `success`; the `Change scope` log contains `code=true` with reason `NO_FULL_GREEN_RUN` (first run) or `NON_ALLOWLISTED_PATH`.
3. Docs-only evidence commit (P2). Commit evidence only under the feature folder, push, wait for the run, then:
   - `gh run view <id2> --json conclusion,createdAt,updatedAt,jobs --jq '.conclusion, .createdAt, .updatedAt, (.jobs[] | [.name,.conclusion] | @tsv)'`. Expected: run `success`; `Change scope` `success`; `CI full run` `skipped`; `root-typescript-tests` and `npm-audit-gate` jobs `skipped`; the 11 required job names present with `success`.
   - `gh run view <id2> --json jobs --jq '.jobs[] | select(.name | test("Code Quality")) | [.name, ([.steps[] | select(.conclusion == "success")] | length)] | @tsv'`. Expected: only runner set-up/tear-down steps succeed. Pair with `--jq '.jobs[] | select(.name | test("Code Quality")) | .steps[] | select(.name == "Run tests with Pytest") | .conclusion'`, expected `skipped`.
   - `gh run view <id2> --log --job <changes-job-id>`. Expected: the line `code=false reason=DOCS_ONLY_SINCE_<sha-of-id1-head>`.
   - `gh api repos/drmoisan/drm-copilot/commits/<head2>/check-runs --paginate --jq '.check_runs[] | [.name,.status,.conclusion] | @tsv'`. Expected: every one of the 11 ruleset contexts (N1) appears with `completed` / `success`. Compare the names line by line with the N1 member set. Whether the API `name` field includes the caller prefix is **[unverified]**. `.github/workflows/README.md:50-56` documents this endpoint as the source of composed names. If the prefix is absent, compare against the `<called name>` suffix and record that observation.
   - `gh pr checks <PR> --required --json name,bucket,state`. Expected: 11 entries, all `pass`.
   - `gh pr view <PR> --json mergeStateStatus,headRefOid`. Expected: not `BLOCKED` due to checks (`CLEAN`, or `BEHIND` if `main` moved). Record the value verbatim.
   - Timing after: `updatedAt - createdAt` of `<id2>`, compared with step 1.
4. Code change after the skip (P3). Push a commit touching a non-allowlisted path (for example a comment in `scripts/ci/CiChangeScope.psm1`). Expected: `CI full run` `success`; the `Change scope` log shows `NON_ALLOWLISTED_PATH: scripts/ci/CiChangeScope.psm1`; heavy steps `success`.
5. Fail-closed spot check (optional, P4). A commit touching `docs/features/templates/README.md` alone gives `NON_ALLOWLISTED_PATH`, and the full run executes.

## 9. Candidate File Set (Question 8)

Written by #962 (repository-relative):

1. `.github/workflows/ci.yml`: add the `changes` and `full-run-marker` jobs and the caller `needs`/`if`/`with` lines
2. `.github/workflows/_quality-checks.yml`: `run-heavy` input and step gating
3. `.github/workflows/_security-scan.yml`: same
4. `.github/workflows/_build-check.yml`: same
5. `.github/workflows/_shell-coverage.yml`: same
6. `.github/workflows/_drm-copilot-extension-tests.yml`: same
7. `.github/workflows/_poshqc.yml`: `run-heavy` input; job-level skip for static, shard and linux-hooks; step gating in the aggregator (after #953)
8. `.github/workflows/README.md`: new section describing the change-scope decision, the allowlist, the fail-closed rules and the `run-heavy` input
9. `config/ci-docs-only-paths.json`: allowlist
10. `scripts/ci/CiChangeScope.psm1`: pure functions
11. `scripts/ci/Invoke-CiChangeScope.ps1`: I/O entry point
12. `quality-tiers.yml`: `scripts/ci` entry (T4)
13. `tests/scripts/ci/CiChangeScope.Tests.ps1`
14. `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1`
15. `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`
16. `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`: text-based assertions, same technique as the existing workflow suites:
    - `changes` has `actions: read` and `contents: read`;
    - every required caller has `needs: changes` and `if: ${{ !cancelled() }}`, and passes `run-heavy` with `!= 'false'`;
    - `docs-validation` has no `needs`;
    - every gated reusable workflow declares `run-heavy` boolean default `true` under both triggers;
    - every step in every required job carries `inputs.run-heavy`;
    - the `CI full run` marker condition holds.
17. Feature-folder artifacts under `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/` (spec, plan, evidence)

Not changed (verified as unnecessary): `.github/workflows/_docs-validation.yml`; `_root-typescript-tests.yml` and `_npm-audit-gate.yml` (caller-level skip only); `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` and its bundle mirror; `.claude/skills/orchestrate/SKILL.md`; `.claude/skills/parallel-orchestrate/SKILL.md`; `extensions/drm-copilot/CHANGELOG.md` (no bundled file changes); `tests/scripts/workflows/CiWorkflow.Tests.ps1`; `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`. No `.codex/` mirror of the ci-gate parser exists (glob returned no match).

## 10. Testing Implications

- Unit (Pester): the pure-function and seam suites listed in section 5, AAA structure, no temporary files, no process starts, no network.
- Workflow invariants (Pester, text-based): `CiChangeScopeWorkflow.Tests.ps1`. These assertions are the regression test that must fail first: against the current `ci.yml` and reusable workflows, the `changes` job and the `run-heavy` input are absent.
- Lint: run `scripts/dev-tools/run-actionlint.ps1` on all changed workflows. `actionlint` checks local reusable-workflow `with:` against declared inputs. Note that `.github/instructions/github-actions.instructions.md:15` cites a CI `actionlint` job that does not exist (section 12).
- Integration: the proof plan in section 8, on #962's own PR.
- Coverage: changed-file line coverage of 85% or more for `scripts/ci/*`, measured from PoshQC coverage output and recorded under `evidence/qa-gates/`. CI does not enforce the threshold (section 5).

## 11. Automation Feasibility

| Step | Agent-executable | Notes |
|---|---|---|
| Edit workflows, scripts, config, tests | yes | file edits only |
| Pester unit and workflow suites | yes | PowerShell session (`Invoke-Pester` or the PoshQC module). Operator notes record that some hook configurations deny command text containing `pwsh`/`bash`; run Pester in-process in the PowerShell session rather than through a nested `pwsh` command **[unverified for this worktree]** |
| actionlint | yes | `scripts/dev-tools/run-actionlint.ps1` downloads the binary (requires network) |
| Rebase on #952/#953 after they merge | yes | `git fetch`, `git rebase origin/main`, `git push --force-with-lease` |
| Proof plan (section 8) | yes | `gh run list/view`, `gh api`, `gh pr checks`, `gh pr view`; pushing commits to the PR branch |
| Ruleset changes | not required | Candidate B needs no ruleset edit. Candidate C, which is rejected, would need a privileged ruleset change and was flagged as requiring human authorization |
| Merge-queue enablement | out of scope | belongs to #952 |

No human-only step is required by the recommended design.

## 12. Unrelated Defects Observed

1. `.github/instructions/github-actions.instructions.md:15` says "CI: job `actionlint` in `.github/workflows/ci.yml`". `ci.yml` has no such job (lines 10-41). The policy text and CI disagree, and workflow edits are not linted in CI. **[verified]**
2. `.github/workflows/README.md:3-5, 20-29` describes "eight reusable per-stage workflows" and omits `_npm-audit-gate.yml`, which `ci.yml:35-41` calls. Lines 79-81 say "All seven jobs", but `ci.yml` has nine caller jobs (N2). This is documentation drift. **[verified]**
3. The only substantive step in `_security-scan.yml:26-30` has `continue-on-error: true`. The required context `security-scan / Security Scanning` therefore cannot fail on a vulnerability finding. **[verified]**
4. The supplied #953 patch changes the `_poshqc.yml` job set but contains no change to `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`. Lines 51 and 58 of that test would fail against the patched workflow. The supplied patches appear to be limited to `.github/` paths, since the PoshQC module changes for `-ShardIndex` are also absent. This may already be handled on the #953 branch **[unverified]**; the #953 owner should confirm.
5. Test-location policy conflict. `.claude/rules/general-unit-test.md` requires a mirrored `tests/` tree, but the bats runner discovers only top-level files in `tests/shell` and `tests/bash` (`scripts/bash/shell_qc_lib.sh:104-119, 262`). All existing bats suites are flat under `tests/shell/`. **[verified]**
6. Coverage thresholds are not enforced in CI for PowerShell (`CoveragePercentTarget = 0`, `pester.runsettings.psd1:26`) or for bash (no threshold in `scripts/bash/`; `_shell-coverage.yml` only uploads). **[verified for the files read; enforcement elsewhere not found]**

## Numeric Derivation Evidence

### N1: required status-check contexts in ruleset 15241672 = 11

- Complete Family: every `context` entry in the `required_status_checks` rule of ruleset 15241672.
- Exhaustive Search Scope: the full JSON file `issue-962-ruleset-15241672.json` (single line), all rules.
- Inclusion Rules: objects inside `rules[type=required_status_checks].parameters.required_status_checks[]`.
- Exclusion Rules: none (no other rule carries contexts).
- Primary Search Strategy or Query Expression: read the JSON and enumerate the `required_status_checks` array elements in order.
- Primary Member Set: `drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)`; `drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)`; `docs-validation / Documentation Validation`; `poshqc / PowerShell QC`; `shell-coverage / Shell Coverage (Bats + kcov)`; `security-scan / Security Scanning`; `quality-checks7 / Code Quality & Tests (3.10)`; `quality-checks7 / Code Quality & Tests (3.11)`; `quality-checks7 / Code Quality & Tests (3.12)`; `quality-checks7 / Code Quality & Tests (3.13)`; `build-check / Build Package`.
- Primary Count: 11.
- Cross-check Search Strategy or Query Expression: ripgrep only-matching `"context":"[^"]+"` over the same file. This is a regex token match over the raw text, independent of the array structure.
- Cross-check Member Set: the same 11 strings, in the same order.
- Cross-check Count: 11.
- Member-set Comparison: the normalized sets are identical (11/11). A third, independent source, the orchestrator delegation prompt's list with the `3.10|3.11|3.12|3.13` shorthand expanded, also gives the same 11.

### N2: caller jobs in `ci.yml` = 9

- Complete Family: every job under `jobs:` in `.github/workflows/ci.yml`.
- Exhaustive Search Scope: the full file (41 lines).
- Inclusion Rules: two-space-indented keys under `jobs:`.
- Exclusion Rules: none.
- Primary Search Strategy or Query Expression: read lines 10-41 and enumerate two-space-indented job keys.
- Primary Member Set: `quality-checks7`, `security-scan`, `docs-validation`, `build-check`, `poshqc`, `shell-coverage`, `drm-copilot-extension-tests`, `root-typescript-tests`, `npm-audit-gate`.
- Primary Count: 9.
- Cross-check Search Strategy or Query Expression: grep `uses: \./\.github/workflows/` and map each match to its called file (lines 12, 15, 18, 21, 24, 27, 30, 33, 39).
- Cross-check Member Set: `_quality-checks.yml`, `_security-scan.yml`, `_docs-validation.yml`, `_build-check.yml`, `_poshqc.yml`, `_shell-coverage.yml`, `_drm-copilot-extension-tests.yml`, `_root-typescript-tests.yml`, `_npm-audit-gate.yml`, which map one-to-one to the primary job ids.
- Cross-check Count: 9.
- Member-set Comparison: identical after mapping (9/9). Of these, 7 caller jobs produce required contexts: the distinct caller prefixes of N1, which are the first 7 of the primary set. Gating applies to 6 of them, because `docs-validation` always runs.
