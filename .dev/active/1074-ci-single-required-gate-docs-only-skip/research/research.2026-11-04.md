# Research: single required CI gate for the docs-only fast pass (Issue #1074)

- Issue: #1074
- Branch: `bug/ci-single-required-gate`
- Date: 2026-11-04
- Inputs read: feature `issue.md`, `spec.md`, the promoted record `docs/features/potential/promoted/2026-11-04-ci-single-required-gate-docs-only-skip.md`, `.claude/skills/execution-environment/SKILL.md`, `.claude/rules/ci-workflows.md`, `.github/instructions/github-actions.instructions.md`, `.claude/skills/feature-review-workflow/SKILL.md` (`### modified-workflow-needs-green-run`), every workflow under `.github/workflows/`, `scripts/ci/Invoke-CiChangeScope.ps1`, and the test suites named in section 6.
- Facts marked `ORCHESTRATOR-CONFIRM` need `gh` or a live run; this researcher has no `gh` or `git show`.

## Summary of Recommendations

1. Add one top-level job to `.github/workflows/ci.yml`: job id `ci-required-gate`, `name: CI Required Gate`, `needs:` on all eleven other `ci.yml` jobs, `if: always()`, `runs-on: ubuntu-latest`, `permissions: contents: read`. Its single decision step runs a PowerShell script under `scripts/ci/` that receives `${{ toJSON(needs) }}` through an environment variable.
2. Put the decision logic in a pure module `scripts/ci/CiRequiredGate.psm1` and a thin entry script `scripts/ci/Invoke-CiRequiredGate.ps1`, which follows the `CiChangeScope.psm1` / `Invoke-CiChangeScope.ps1` split. Test it with Pester decision-table tests and a workflow pin suite. Do not put inline logic in YAML.
3. Do not normalize the job-level skips (`poshqc-static`, `poshqc-shard`, `poshqc-linux-hooks`, `root-typescript-tests`, `npm-audit-gate`). Adding the gate is the smallest change, and it leaves `_poshqc.yml` and its pin tests unchanged.
4. After merge, and after the gate has run green on `main`, the owner replaces the 20 required contexts of ruleset 15241672 with the single context `CI Required Gate` (integration_id 15368). The PowerShell runbook in section 8 does this. This run does not apply it.

## 1. Current State: `ci.yml` Job Inventory

### 1.1 Top-level jobs of `.github/workflows/ci.yml`

| Job id | `name:` | `needs:` | `if:` | `uses:` / runs | Check name(s) reported |
|---|---|---|---|---|---|
| `changes` | `Change scope` | none | none | runs `scripts/ci/Invoke-CiChangeScope.ps1` (step `scope`, `continue-on-error: true`, then `exit 0`); output `code` | `Change scope` |
| `full-run-marker` | `CI full run` | `changes` | `${{ !cancelled() && needs.changes.outputs.code != 'false' }}` | one `echo` step | `CI full run` (not required) |
| `quality-checks7` | none | `changes` | `${{ !cancelled() }}` | `_quality-checks.yml`, `run-heavy: ${{ needs.changes.outputs.code != 'false' }}` | `quality-checks7 / Code Quality & Tests (3.11)`, `(3.12)`, `(3.13)` |
| `security-scan` | none | `changes` | `${{ !cancelled() }}` | `_security-scan.yml`, `run-heavy` as above | `security-scan / Security Scanning` |
| `docs-validation` | none | none | none | `_docs-validation.yml` | `docs-validation / Documentation Validation` |
| `build-check` | none | `changes` | `${{ !cancelled() }}` | `_build-check.yml`, `run-heavy` as above | `build-check / Build Package` |
| `poshqc` | none | `changes` | `${{ !cancelled() }}` | `_poshqc.yml`, `run-heavy` as above | `poshqc / PowerShell QC static`, `poshqc / PowerShell QC shard 1..3`, `poshqc / PowerShell QC`, `poshqc / PowerShell hook suites (Linux)` |
| `shell-coverage` | none | `changes` | `${{ !cancelled() }}` | `_shell-coverage.yml`, `run-heavy` as above | `shell-coverage / Shell Coverage (Bats + kcov)` |
| `drm-copilot-extension-tests` | none | `changes` | `${{ !cancelled() }}` | `_drm-copilot-extension-tests.yml`, `run-heavy` as above | `drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)`, `(ubuntu-latest)` |
| `root-typescript-tests` | none | `changes` | `${{ !cancelled() && needs.changes.outputs.code != 'false' }}` | `_root-typescript-tests.yml` (no `run-heavy` input) | `root-typescript-tests / Root TypeScript Tests (windows-latest)`, `(ubuntu-latest)` |
| `npm-audit-gate` | `NPM Audit Gate` | `changes` | `${{ !cancelled() && needs.changes.outputs.code != 'false' }}` | `_npm-audit-gate.yml`, `audit-level: moderate`, `permissions: contents: read` | `NPM Audit Gate / npm audit (.)`, `(extensions/drm-copilot)`, `(packages/mcp-server)` |

`ci.yml` triggers on `push` (main, development), `pull_request` (main, development, `epic/**`), `workflow_dispatch`, and `merge_group` (`types: [checks_requested]`). It has no top-level `permissions:` block and no `concurrency:` key.

### 1.2 Nested jobs and skip behavior under `run-heavy: false` (`code == 'false'`)

| Called workflow | Nested job id: `name:` | Matrix | Skip mechanism under docs-only | Context reports? |
|---|---|---|---|---|
| `_quality-checks.yml` | `quality-checks7`: `Code Quality & Tests` | `python-version: ["3.11", "3.12", "3.13"]` | job runs; every step gated on `inputs.run-heavy` | yes, `success` (the matrix suffix is appended automatically) |
| `_security-scan.yml` | `security-scan`: `Security Scanning` | none | job runs; every step gated; the step `Check for security vulnerabilities` has `continue-on-error: true` | yes, `success` |
| `_build-check.yml` | `build-check`: `Build Package` | none | job runs; every step gated | yes, `success` |
| `_shell-coverage.yml` | `shell-coverage`: `Shell Coverage (Bats + kcov)` | none | job runs; every step gated | yes, `success` |
| `_drm-copilot-extension-tests.yml` | `drm-copilot-extension-tests`: `drm-copilot Extension Tests (${{ matrix.os }})` | `os: [windows-latest, ubuntu-latest]` | job runs; every step gated | yes, `success` |
| `_docs-validation.yml` | `docs-validation`: `Documentation Validation` | none | no input; always runs in full | yes |
| `_poshqc.yml` | `poshqc-static`: `PowerShell QC static` | none | job-level `if: ${{ inputs.run-heavy }}` | yes, reported as skipped; the name has no matrix expression |
| `_poshqc.yml` | `poshqc-shard`: `PowerShell QC shard ${{ matrix.shard }}` | `shard: [1, 2, 3]` | job-level `if: ${{ inputs.run-heavy }}` | **no**. A matrix job skipped at job level is never expanded, so the three `shard N` contexts never appear (issue #1074, PR #1070 head) |
| `_poshqc.yml` | `poshqc`: `PowerShell QC` | none | `needs: [poshqc-static, poshqc-shard]`, `if: always()`; every step gated, including the step `Require the static and shard jobs to succeed` | yes, `success` |
| `_poshqc.yml` | `poshqc-linux-hooks`: `PowerShell hook suites (Linux)` | none | job-level `if: ${{ inputs.run-heavy }}` | yes, reported as skipped |
| `_root-typescript-tests.yml` | `root-typescript-tests`: `Root TypeScript Tests (${{ matrix.os }})` | `os: [windows-latest, ubuntu-latest]` | the caller is skipped in `ci.yml`, so the called workflow never starts | **no** (2 contexts) |
| `_npm-audit-gate.yml` | `npm-audit`: `npm audit (${{ matrix.manifest }})` | `manifest: [".", extensions/drm-copilot, packages/mcp-server]` | the caller is skipped in `ci.yml` | **no** (3 contexts) |

This matches the issue record: 20 required contexts, 12 reported, and 8 never reported (3 shards, 2 root TypeScript, 3 npm audit).

### 1.3 Stale facts found during the read

- The execution-environment brief, `## CI Shape and Required Checks`, lists 10 required contexts confirmed on 2026-10-16. The ruleset now has 20, according to the orchestrator's 2026-11-04 read. The brief's docs-only bullet also says "every required context reports `success` without running its suite". That is false for the 8 contexts above.
- `.github/workflows/README.md`, `### Required contexts under a docs-only run`, tabulates only the 10 older contexts. `## Required-Status-Check Rename Procedure` uses the classic branch-protection endpoint (`/branches/{branch}/protection/required_status_checks`), but this repository enforces required checks through a ruleset.
- `.github/instructions/github-actions.instructions.md` names "CI: job `actionlint` in `.github/workflows/ci.yml`". No such job exists in `ci.yml`. The instruction file is canonical and is not modified here. This note is informational only.

## 2. Result Semantics (GitHub documentation)

Verified by WebFetch on 2026-11-04:

- Contexts reference (`docs.github.com/en/actions/reference/workflows-and-actions/contexts`), `needs` table: "`needs.<job_id>.result` ... The result of a job that the current job depends on. Possible values are `success`, `failure`, `cancelled`, or `skipped`."
- Same page, steps context: `steps.<step_id>.outcome` is "The result of a completed step before continue-on-error is applied", and `steps.<step_id>.conclusion` is the result "after continue-on-error is applied". "When a continue-on-error step fails, the outcome is failure, but the final conclusion is success."
- Workflow syntax (`.../workflow-syntax`), `jobs.<job_id>.needs`: "If a job fails or is skipped, all jobs that need it are skipped", unless the dependent job uses a condition such as `always()`. `jobs.<job_id>.steps[*].continue-on-error`: "Prevents a job from failing when a step fails."
- Troubleshooting required status checks (`docs.github.com/en/pull-requests/.../troubleshooting-required-status-checks`), `## Handling skipped but required checks`: "A job is skipped by a conditional": the job reports "Success". "A workflow is skipped by path filtering": the checks stay "Pending". "A job depends on a failed job": the dependent job is skipped and "may not block merging"; the fix is to use `always()` with `needs` for required checks that depend on other jobs. `## Checks from some workflow jobs are not evaluated`: checks from a `workflow_dispatch` run do not appear in a pull request's checks section.
- Reusable workflows reference (`.../reusable-workflows`): a caller job may use only `name`, `uses`, `with`, `secrets`, `strategy`, `needs`, `if`, `concurrency`, `permissions`, and `cache-mode`.

Consequences for the gate:

- **Caller of a reusable workflow.** The documentation does not state how `needs.<caller>.result` is aggregated from the called jobs. Observed platform behavior, and the basis of this design: `skipped` when the caller's own `if:` is false (for example `root-typescript-tests` and `npm-audit-gate` under docs-only); `failure` when any called job failed; `cancelled` when the run was cancelled; otherwise `success`. In the docs-only path, every caller the gate requires to be `success` has at least one nested job that runs and succeeds. `poshqc` is the only caller whose nested jobs are partly skipped at job level, and its `poshqc` aggregator job runs and succeeds. `ORCHESTRATOR-CONFIRM`: the value of `needs.poshqc.result` in a docs-only run is expected to be `success`. The jobs API lists only leaf jobs, so the gate's own summary table from the docs-only proof run (section 9, run D) is the confirming evidence. If it reports `skipped`, the gate turns red on that run, and the plan must treat that as a design input, not as a failure of the proof.
- **`continue-on-error` steps.** `security-scan`'s scan step can fail while its job concludes `success`, so `needs.security-scan.result` is `success`. This matches current required-check behavior and needs no special case.
- **Gate condition.** The gate must use `if: always()`. Without it, a failed or skipped needed job would skip the gate, and the skipped gate would report success to the ruleset. That is the case the troubleshooting page describes. `always()` also runs the gate when the run is cancelled, so it reports `failure` instead of leaving a stale result.

## 3. Gate Decision Table and Placement

### 3.1 Inputs

- `NEEDS_JSON` = `${{ toJSON(needs) }}`: one object keyed by job id, each value holding `result` and `outputs`.
- Scope predicate: identical to the callers' predicate. Docs-only if and only if `needs.changes.outputs.code` is exactly the string `false`. Any other value (`true`, empty, missing) means full scope, as with `!= 'false'` in `ci.yml`.
- Docs-only skippable set (constant): `full-run-marker`, `root-typescript-tests`, `npm-audit-gate`. These are exactly the `ci.yml` jobs whose `if:` contains `needs.changes.outputs.code != 'false'`.

### 3.2 Rules (applied to every key of `NEEDS_JSON`)

| Condition | Rule | Gate |
|---|---|---|
| `NEEDS_JSON` blank, not parseable as an object, or missing `changes`, `docs-validation`, or any member of the skippable set | configuration error | **red** |
| any job result is `failure` or `cancelled` | the owner's rule | **red** |
| any job result outside {`success`, `skipped`} | unknown value, fail closed | **red** |
| `changes` result is not `success` (includes a failed checkout; the `scope` step itself cannot fail the job because of `continue-on-error: true`) | the scope cannot be trusted | **red** |
| scope **full** (`code != 'false'`, including a missing or failed decision) | every needed job must be `success` (all eleven) | green only if all are `success` |
| scope **docs-only** (`code == 'false'`) | `changes`, `quality-checks7`, `security-scan`, `docs-validation`, `build-check`, `poshqc`, `shell-coverage`, and `drm-copilot-extension-tests` must be `success`. `full-run-marker`, `root-typescript-tests`, and `npm-audit-gate` may be `skipped` or `success` | green only if all hold |

Event handling follows from `scripts/ci/Invoke-CiChangeScope.ps1` (`Test-CiChangeScopeEventEligible`). `push`, `merge_group`, and `workflow_dispatch` always give `code=true`, so they always take the full row. A `workflow_dispatch` run's checks do not count toward a pull request (section 2), but the gate's verdict there is still meaningful. A fork pull request gives `code=true`, so it also takes the full row.

`changes` failing: the callers' `if: ${{ !cancelled() }}` still runs them in full (`'' != 'false'`), and the gate is red because `changes` is not `success`. This fails closed. A rerun of the run is the remedy.

`full-run-marker` in the full scope must be `success`. Its only step is an `echo`, so a non-success result is an infrastructure fault, and the gate correctly treats it as red.

The summary is a Markdown table appended to `$GITHUB_STEP_SUMMARY`: a header line with the scope and the raw `code` value, then one row per needed job with the columns `Job`, `Result`, `Accepted`, and `Verdict`, then the final verdict line. The script ends with an explicit `exit 0` or `exit 1`, as `.claude/rules/ci-workflows.md` (`## Deliberately-Failing Nested Command Pattern (Required)`) requires for `pwsh` steps that end on an explicit verdict.

### 3.3 Proposed job text (for the planner, not final)

```yaml
  ci-required-gate:
    name: CI Required Gate
    needs:
      - changes
      - full-run-marker
      - quality-checks7
      - security-scan
      - docs-validation
      - build-check
      - poshqc
      - shell-coverage
      - drm-copilot-extension-tests
      - root-typescript-tests
      - npm-audit-gate
    if: always()
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - name: Check out repository
        uses: actions/checkout@v7
        with:
          persist-credentials: false

      - name: Evaluate the CI job results
        shell: pwsh
        env:
          NEEDS_JSON: ${{ toJSON(needs) }}
        run: ./scripts/ci/Invoke-CiRequiredGate.ps1
```

The gate reads no `github.event.pull_request`, `github.head_ref`, `github.base_ref`, or `github.event_name` field. This keeps `CiWorkflow.Tests.ps1`'s event-field test green: it allows exactly seven such lines in `ci.yml`, all in `changes`. The value travels through `env:`, not through direct interpolation into `run:`.

### 3.4 Inline versus script (recommendation: script plus Pester)

- **Inline `pwsh` in `ci.yml`**: fewest files changed. However, the logic can only be exercised by live CI runs, and once the ruleset change lands it becomes the single required check, so a logic error would pass every pull request. Text pins can check its shape but not its decisions. `.github/instructions/github-actions.instructions.md` (`Best practices`) prefers not inlining complex scripts.
- **Script under `scripts/ci/`** (selected): the precedent is `scripts/ci/CiChangeScope.psm1` (pure), `scripts/ci/Invoke-CiChangeScope.ps1` (I/O seams `-OutputWriter` and `-ReadVariable`, plus the dot-source guard `if ($MyInvocation.InvocationName -ne '.')`), and their tests under `tests/scripts/ci/`. With this split, every row of the decision table becomes an offline Pester case, the summary rendering can be asserted exactly, and the entry point is a few uncovered lines. `config/poshqc-coverage.json` includes `scripts`, so both new files are measured against the 85% line floor. `config/poshqc-scan.json` scans `tests/scripts`, so the new test files are sharded automatically. A `config/poshqc-shard-weights.json` entry is optional.
- Files: `scripts/ci/CiRequiredGate.psm1` (`Get-CiRequiredGateDecision -NeedsJson <string>` returns `Passed`, `Scope`, `Code`, `Rows`, and `SummaryText`; the skippable set is a module constant) and `scripts/ci/Invoke-CiRequiredGate.ps1` (`Invoke-CiRequiredGate -NeedsJson -OutputWriter` and the guarded entry, which reads `NEEDS_JSON`, writes the summary, and exits 0 or 1). That is two new production PowerShell files, within the direct-mode batch budget of three.

Rejected alternatives: inline YAML logic (untestable offline); a third-party "all needs succeeded" action (adds an unapproved dependency, and it cannot verify the change-scope output, which the owner requires); bash in YAML (same testability problem, and it diverges from the PowerShell precedent).

## 4. Normalizing Job-Level Skips (recommendation: do not normalize)

- With a single required context, the unreported nested contexts no longer block anything. The gate sees `needs.root-typescript-tests.result == 'skipped'` and `needs.npm-audit-gate.result == 'skipped'` directly, and it sees `needs.poshqc.result`, which the `poshqc` aggregator already derives from the static and shard results.
- Normalizing would mean step-gating `poshqc-shard`, `poshqc-static`, and `poshqc-linux-hooks`, and adding `run-heavy` to `_root-typescript-tests.yml` and `_npm-audit-gate.yml`. That would change pinned behavior: `CiChangeScopeWorkflow.Tests.ps1` (`skips <Caller> at job level when code is false (AC-19)`, `skips every _poshqc.yml job other than poshqc at job level unless run-heavy (AC-21)`) and the `poshqc` aggregator's precondition. It would also start three or more Windows runners on every docs-only run, contrary to the fast-pass purpose (issue #962). The owner's decision states that the underlying jobs keep their names and behavior.
- Selected: add the gate only. `_poshqc.yml` is not edited, so `PoshQcWorkflow.Tests.ps1` (`WF01-POSHQC-MERGE-JOB-RUNS-ALWAYS`, `WF02`, `WF03`) stays valid without change.

## 5. Check-Context Name of the Gate

- A top-level job that does not call a reusable workflow reports a check run named exactly by its `name:`. The existing top-level jobs `Change scope` and `CI full run` report under those exact names. `scripts/ci/Invoke-CiChangeScope.ps1` (`Find-CiChangeScopeBase`, through `Test-CiFullRunMarker`) relies on that by matching the job name `CI full run` in the jobs API. The context for the new job is therefore `CI Required Gate`, with no `ci-required-gate / ` prefix. The prefix form `<caller job id> / <called job name>` applies only to jobs inside a called workflow.
- The gate name must not equal `CI full run`; otherwise `Test-CiFullRunMarker` could select a docs-only run as a base.
- Confirmation from a real run (`ORCHESTRATOR-CONFIRM`), using forms the worktree guard accepts (no `--jq` filter string):
  - `gh pr checks <pr number> --json name,bucket,workflow`: expect one element with `name` `CI Required Gate` and `workflow` `CI`.
  - `gh api "repos/drmoisan/drm-copilot/commits/<head sha>/check-runs?check_name=CI%20Required%20Gate"`: expect `total_count` 1, `check_runs[0].name` `CI Required Gate`, and `check_runs[0].app.id` 15368. That value must equal the ruleset entry's `integration_id`. Parse the output with `ConvertFrom-Json` in PowerShell.

## 6. Tests That Pin `ci.yml` or `_poshqc.yml`

| Test file | What it asserts | Disposition |
|---|---|---|
| `tests/scripts/workflows/CiWorkflow.Tests.ps1` | trigger set (`pull_request` main/development/`epic/**`, `push` exactly main/development, `merge_group` checks_requested with no filter); no pull-request event field and no path filter anywhere in the `ci.yml` call graph, apart from seven allowed lines in `changes` | unchanged because unaffected, provided the gate reads only `needs` |
| `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` | the `changes` job shape (AC-18); `full-run-marker` name/needs/if; callers' `needs: changes`, `if: ${{ !cancelled() }}`, `run-heavy` (AC-19); job-level skips of `root-typescript-tests` and `npm-audit-gate`; `docs-validation` has no needs or if; `run-heavy` input and step gating in six reusable files (AC-20); `_poshqc.yml` gating (AC-21); security-scan `continue-on-error` (AC-36) | unchanged because unaffected (no caller or reusable file changes). The job-block parser tolerates a new job id |
| `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` | exactly four `_poshqc.yml` jobs; aggregator name, runner, and needs; Linux hook job; shard matrix; `WF01`..`WF05` (aggregator `if: always()`, result-gate step, mutation detection, shard count) | unchanged because `_poshqc.yml` is not edited. It is the precedent for the new gate's mutation-style tests |
| `tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1` | reads `_poshqc.yml`'s `poshqc-linux-hooks` block (Pester version) | unchanged |
| `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1`, `tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1`, `tests/scripts/ci/CiChangeScope.Tests.ps1` | decision logic; mocks the `ci.yml` runs path and the `CI full run` job name | unchanged; the gate name must not be `CI full run` |
| `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` | `_REQUIRED_CONTEXTS` (10 contexts) and `test_brief_ci_section_names_jobs_and_required_contexts` tokens, including "ruleset 15241672", "2026-10-16", "Refresh rule", and "every required context reports `success` without running its suite"; byte identity of six copies | **updated**: add `` `CI Required Gate` ``; replace the 10-context tuple and the date token to match the rewritten brief bullet; drop or replace the now-false phrase. This edits an existing Python test; no new Python file is created |
| `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` | `_quality-checks.yml` step conditions | unchanged |
| `tests/scripts/dev_tools/test_host_environment_contracts.py` | Node, Poetry, and shell pins in reusable workflows | unchanged |
| `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` | enumerates all workflow files for npm token use | unchanged (the gate uses no token) |
| `tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1`, `tests/scripts/dev_tools/test_quality_tiers_contract.py`, `tests/scripts/dev_tools/codex_native_converter/test_classifier.py`, `.../test_end_to_end.py` | use the `ci.yml` path as a non-docs fixture string | unchanged |
| New: `tests/scripts/ci/CiRequiredGate.Tests.ps1` | one case per row of the section 3.2 table; summary text | **added** |
| New: `tests/scripts/ci/Invoke-CiRequiredGate.Tests.ps1` | env read, summary write through the injected writer, verdict-to-exit mapping, dot-source guard | **added** |
| New: `tests/scripts/workflows/CiRequiredGateWorkflow.Tests.ps1` | the gate job exists with `name: CI Required Gate`, `if: always()`, `runs-on: ubuntu-latest`, and `NEEDS_JSON: ${{ toJSON(needs) }}`; its `needs` set equals the set of all other `ci.yml` job ids (derived from the file, so a future job cannot be left out); the module's skippable constant equals the set of `ci.yml` jobs whose `if:` contains `needs.changes.outputs.code != 'false'`; the gate job has no `run-heavy`. Mutation cases in the `WF03` style (needs entry removed, `always()` removed) | **added**. Put this in a new file, not appended to `CiChangeScopeWorkflow.Tests.ps1`, which is already 340 lines |

## 7. Documents and Skills That Describe the CI Job Set or Required Checks

| File(s) | Heading / location | Update |
|---|---|---|
| Execution-environment brief, six byte-identical copies: `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, and `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md` | `## CI Shape and Required Checks`: the bullets "Jobs in `ci.yml` and their check names" (add `CI Required Gate`), "Docs-only behavior (`code=false`)" (state which contexts never report, and that the gate passes), "Required contexts of ruleset 15241672 ..." (replace with the 20 contexts confirmed 2026-11-04, and state that after the owner's post-merge ruleset edit the single required context is `CI Required Gate`), "Refresh rule", and "Skipped-check semantics" (add: a matrix job skipped at job level reports no expanded context; a skipped caller reports no nested contexts) | required in the same change (`## Purpose and Maintenance`) |
| `.github/workflows/README.md` | `## Required-Status-Check Rename Procedure` (step 3 uses the classic branch-protection endpoint; replace it with the ruleset GET/PUT of section 8); `### The `run-heavy` input`; `### Required contexts under a docs-only run` (table plus the "Non-required jobs" sentence); new section `## CI Required Gate (Issue #1074)` with the section 3.2 table | required |
| `.claude/skills/atomic-plan-contract/SKILL.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` | `## Wrap-Tolerant Assertion Authoring (Mandatory)`, bullet "**Name the runner and job for a Pester acceptance criterion.**": "`poshqc / PowerShell QC` is the aggregating required check" becomes "the aggregating check, whose result `CI Required Gate` requires" | required. The `.agents` and `.github` copies do not contain this sentence (verified by Grep) |
| `.claude/rules/*`, `.claude/agents/*`, `.github/agents/*`, `.codex/*`, `docs/engineering/*` | Grep for `PowerShell QC`, `Code Quality & Tests`, `Change scope`, `CI full run`, and `15241672` found no other occurrence | none |
| `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`, `.claude/skills/orchestrate/SKILL.md` (S9) | S9 reads `gh pr checks --json bucket,name,state,link,workflow` over every check, required or not | none. The gate adds one more check; a red gate is already a `fail` bucket |

## 8. Ruleset Runbook (manual, owner or coordinator, after merge)

Reference: GitHub REST "Repository rules" (`docs.github.com/en/rest/repos/rules`), read 2026-11-04. `PUT /repos/{owner}/{repo}/rulesets/{ruleset_id}` accepts the body parameters `name`, `target`, `enforcement`, `bypass_actors`, `conditions`, and `rules`. The page does not say whether omitted fields are preserved, so the body sends all six. The GET response also carries `id`, `source_type`, `source`, `node_id`, `_links`, `current_user_can_bypass`, `created_at`, and `updated_at`, which the PUT body omits. "The bypass_actors property is only returned if the user making the API request has write access to the ruleset", so the script refuses to continue when it is absent. The `required_status_checks` rule parameters are `required_status_checks` (items `context`, `integration_id`), `strict_required_status_checks_policy`, and `do_not_enforce_on_create`.

Precondition: the gate has run green on a `main` push run, and `gh api "repos/drmoisan/drm-copilot/commits/<main head sha>/check-runs?check_name=CI%20Required%20Gate"` shows `app.id` 15368.

PowerShell 7, jq-free. `SCRATCH` is the session scratch directory; record only the token in evidence.

```powershell
# (a) Save the current ruleset for rollback.
$stamp  = Get-Date -AsUTC -Format yyyy-MM-ddTHH-mm
$before = Join-Path $env:SCRATCH "issue-1074-ruleset-15241672-before.$stamp.json"
gh api repos/drmoisan/drm-copilot/rulesets/15241672 | Set-Content -LiteralPath $before -Encoding utf8NoBOM
if ($LASTEXITCODE -ne 0) { throw 'GET of ruleset 15241672 failed' }

# Builds a PUT body with only the six writable fields; read-only GET fields are dropped.
function New-RulesetPutBody {
    param([hashtable] $Ruleset, [scriptblock] $TransformRule = { param($Rule) $Rule })
    if (-not $Ruleset.ContainsKey('bypass_actors')) { throw 'bypass_actors absent: the token lacks write access to the ruleset' }
    [ordered]@{
        name          = $Ruleset.name
        target        = $Ruleset.target
        enforcement   = $Ruleset.enforcement
        bypass_actors = @($Ruleset.bypass_actors)
        conditions    = $Ruleset.conditions
        rules         = @($Ruleset.rules | ForEach-Object { & $TransformRule $_ })
    }
}

# (b) Replace the required contexts with the single gate; every other rule and parameter is kept.
$ruleset = Get-Content -Raw -LiteralPath $before | ConvertFrom-Json -AsHashtable
if (@($ruleset.rules | Where-Object { $_.type -eq 'required_status_checks' }).Count -ne 1) { throw 'expected exactly one required_status_checks rule' }
$body = New-RulesetPutBody -Ruleset $ruleset -TransformRule {
    param($Rule)
    if ($Rule.type -eq 'required_status_checks') {
        $Rule.parameters.required_status_checks = @(@{ context = 'CI Required Gate'; integration_id = 15368 })
    }
    $Rule
}
$after = Join-Path $env:SCRATCH "issue-1074-ruleset-15241672-after.$stamp.json"
$body | ConvertTo-Json -Depth 32 | Set-Content -LiteralPath $after -Encoding utf8NoBOM
gh api --method PUT repos/drmoisan/drm-copilot/rulesets/15241672 --input $after
if ($LASTEXITCODE -ne 0) { throw 'PUT of ruleset 15241672 failed; nothing changed or run (c)' }

# Verify: one context, same strict flag, same rule types, same bypass actors and conditions.
$check = gh api repos/drmoisan/drm-copilot/rulesets/15241672 | ConvertFrom-Json -AsHashtable
$rsc = @($check.rules | Where-Object { $_.type -eq 'required_status_checks' })[0].parameters
"contexts: " + (@($rsc.required_status_checks | ForEach-Object { "$($_.context)#$($_.integration_id)" }) -join ', ')
"strict: $($rsc.strict_required_status_checks_policy); rule types: " + (@($check.rules | ForEach-Object type) -join ',')

# (c) Rollback: PUT the saved ruleset unchanged (read-only fields dropped by the same builder).
$saved = Get-Content -Raw -LiteralPath $before | ConvertFrom-Json -AsHashtable
$rollback = Join-Path $env:SCRATCH "issue-1074-ruleset-15241672-rollback.$stamp.json"
New-RulesetPutBody -Ruleset $saved | ConvertTo-Json -Depth 32 | Set-Content -LiteralPath $rollback -Encoding utf8NoBOM
gh api --method PUT repos/drmoisan/drm-copilot/rulesets/15241672 --input $rollback
```

Expected preserved values (orchestrator read, 2026-11-04): `name` `protect-main`, `target` `branch`, `enforcement` `active`, conditions include `~DEFAULT_BRANCH`, one User bypass actor with mode `pull_request`, and rules `deletion`, `non_fast_forward`, `pull_request` (0 approvals, `allowed_merge_methods` `[merge]`), and `required_status_checks` (`strict_required_status_checks_policy` false, `do_not_enforce_on_create` false). The rollback file is the only exact restore source. The 20 contexts in this note are a secondary reconstruction source. `ConvertTo-Json -Depth 32` avoids the default depth-2 truncation, and `-AsHashtable` keeps empty arrays such as `conditions.ref_name.exclude` as arrays.

## 9. Proof Strategy (both directions, `modified-workflow-needs-green-run`)

Constraints: the Codespace token cannot dispatch workflows, and a `workflow_dispatch` run's checks would not count for the pull request anyway. Until the ruleset edit, the pull request still requires the 20 contexts, so a docs-only head stays BLOCKED by design. The change-scope base is the newest successful `ci.yml` run on the branch whose `CI full run` succeeded (`Find-CiChangeScopeBase`), with the merge-base fallback for `main`.

| Step | Push | Expected change scope | Expected gate | Proves |
|---|---|---|---|---|
| A | implementation commits (`ci.yml`, `scripts/ci/*`, tests, docs) | full (non-allowlisted paths) | green; every row `success` | code path, all green |
| B | throwaway commit adding one step `run: exit 1` to the `docs-validation` job of `_docs-validation.yml` (no test pins that file; every other job stays green) | full | **red**; summary row `docs-validation` `failure` | a failing job turns the gate red |
| C | `git revert` of B | full: the newest full green base is A's head, and the A..C tree diff is empty (`EMPTY_DIFF` gives `code=true`) | green | revert restores green |
| D | docs-only commit under the feature folder (evidence for A to C) | docs-only: `DOCS_ONLY_SINCE_<C head>` | green, with `full-run-marker`, `root-typescript-tests`, and `npm-audit-gate` rows `skipped` and `poshqc` `success`; the pull request is still BLOCKED by the 8 legacy contexts (expected) | docs-only path green; confirms `needs.poshqc.result` (section 2) |
| E | final commit that touches a non-allowlisted path, for example the held-back `.github/workflows/README.md` or brief edits, plus the evidence for D | full | green; all 20 legacy contexts report | final head carries a full CI run, so the pull request is mergeable before the ruleset edit |

After E, commit nothing further to the branch. S9 records E's `ci_gate` in the gitignored checkpoint. The policy audit satisfies the rule through condition (a) (run head equals branch head) or (b). Any further feature-folder commit would be docs-only, and the pull request would be BLOCKED again until the ruleset edit. Post-merge: confirm the gate on the `main` push run, apply section 8, then confirm on the next docs-only pull request that `mergeStateStatus` is not BLOCKED. Evidence goes under `<FEATURE>/evidence/other/`, in a separate pull request, because the feature branch is merged by then.

## 10. Automation Feasibility

- The ruleset PUT needs admin rights on the repository. Neither the executor, the researcher, nor the Codespace token is expected to have them, and `.claude/settings.json` and the hooks govern but do not grant them. The step is therefore a documented manual step for the owner or the coordinator, run after merge and after a green gate on `main`. This run does not execute it.
- Everything else is automatable inside the run: the YAML job, the two scripts, three new Pester files, the brief and README edits, the proof sequence of section 9 (pushes only, no dispatch), and the read-only `gh` confirmations (`ORCHESTRATOR-CONFIRM` items in sections 2 and 5).

## Numeric Derivation Evidence

### Claim N1: the gate needs exactly 11 jobs (every other `ci.yml` job)

- Complete Family: top-level job ids under `jobs:` in `.github/workflows/ci.yml` on the branch base.
- Exhaustive Search Scope: the whole file `.github/workflows/ci.yml`.
- Inclusion Rules: a line of exactly two spaces, an identifier, and a colon, located after `jobs:`.
- Exclusion Rules: trigger keys under `on:` (`push:` matched by the same pattern), and the new gate itself.
- Primary Search Strategy or Query Expression: Grep `^  [a-z0-9-]+:$` over `ci.yml`, dropping the match under `on:`.
- Primary Member Set: changes, full-run-marker, quality-checks7, security-scan, docs-validation, build-check, poshqc, shell-coverage, drm-copilot-extension-tests, root-typescript-tests, npm-audit-gate.
- Primary Count: 11.
- Cross-check Search Strategy or Query Expression: Grep `^    needs: changes$|^    uses: |^    if: ` over `ci.yml`. This gives the 9 jobs carrying `needs: changes`, plus the jobs with no `needs:`, which are `changes` (runs its own steps) and `docs-validation` (a `uses:` with no `needs:`).
- Cross-check Member Set: full-run-marker, quality-checks7, security-scan, build-check, poshqc, shell-coverage, drm-copilot-extension-tests, root-typescript-tests, npm-audit-gate, changes, docs-validation.
- Cross-check Count: 11.
- Member-set Comparison: the sorted sets are identical; there are no duplicates and nothing is missing.

### Claim N2: 3 jobs may be skipped on a docs-only run

- Complete Family: `ci.yml` jobs whose execution depends on the change scope at job level.
- Exhaustive Search Scope: every `if:` line of the eleven jobs in N1.
- Inclusion Rules: a job-level `if:` containing `needs.changes.outputs.code != 'false'`.
- Exclusion Rules: `run-heavy:` inputs (step-level gating inside called workflows, where the caller still runs).
- Primary Search Strategy or Query Expression: the Grep `^    if: ` lines read in N1, filtered for `code != 'false'`.
- Primary Member Set: full-run-marker, root-typescript-tests, npm-audit-gate.
- Primary Count: 3.
- Cross-check Search Strategy or Query Expression: the README sentence in `### Required contexts under a docs-only run` ("`CI full run` is `skipped`, and the `root-typescript-tests` and `npm-audit-gate` callers are `skipped`") and the `CiChangeScopeWorkflow.Tests.ps1` cases `declares full-run-marker ...` and `skips <Caller> at job level when code is false (AC-19)` (ForEach `root-typescript-tests`, `npm-audit-gate`).
- Cross-check Member Set: full-run-marker, root-typescript-tests, npm-audit-gate.
- Cross-check Count: 3.
- Member-set Comparison: identical.

### Claim N3: 8 of the 20 required contexts never report on a docs-only run

- Complete Family: the 20 contexts of ruleset 15241672 (orchestrator read, 2026-11-04).
- Exhaustive Search Scope: all 20 contexts against the section 1.2 skip mechanisms.
- Inclusion Rules: the context belongs to a matrix job skipped at job level, or to a nested job of a caller skipped in `ci.yml`.
- Exclusion Rules: a non-matrix job skipped at job level (it reports as skipped), and a job that runs with its steps gated.
- Primary Search Strategy or Query Expression: workflow reading. `_poshqc.yml` `poshqc-shard` matrix `[1, 2, 3]` gives 3; `_root-typescript-tests.yml` matrix `os` gives 2; `_npm-audit-gate.yml` matrix `manifest` gives 3.
- Primary Member Set: `poshqc / PowerShell QC shard 1`, `shard 2`, `shard 3`; `root-typescript-tests / Root TypeScript Tests (ubuntu-latest)`, `(windows-latest)`; `NPM Audit Gate / npm audit (.)`, `(extensions/drm-copilot)`, `(packages/mcp-server)`.
- Primary Count: 8.
- Cross-check Search Strategy or Query Expression: the issue record (`issue.md` `## Actual Behavior`), the observed PR #1070 head (12 of 20 reported), and arithmetic over the ruleset list (20 minus the 12 reported: 10 brief contexts plus `poshqc / PowerShell QC static` and `poshqc / PowerShell hook suites (Linux)`).
- Cross-check Member Set: the same eight contexts listed in `## Actual Behavior`.
- Cross-check Count: 8.
- Member-set Comparison: identical.

## Pre-Mortem

- Review checklists: the policy audit fires `modified-workflow-needs-green-run` because `.github/workflows/ci.yml` changes. Mitigation: the plan carries the section 9 A to E sequence and names E's run as the green run against the branch head. `.claude/rules/ci-workflows.md` requires an explicit `exit 0` or `exit 1` in the gate's `pwsh` step and the entry script. `.github/instructions/github-actions.instructions.md` requires actionlint: run `scripts/dev-tools/run-actionlint.ps1` on the changed `ci.yml`.
- Coverage: the two new `scripts/ci` files are in the PoshQC coverage population (`config/poshqc-coverage.json` includes `scripts`), with an 85% line floor. Mitigation: keep all logic in the pure module, test every decision-table row, and read per-file coverage from `artifacts/pester/powershell-coverage.xml` of a branch-current `Invoke-PoshQCTest` run, not from the MCP result.
- Mirror parity: the plan changes facts the brief states (a new CI job; the required-context set), so all six byte-identical brief copies must change in one task, together with `test_execution_environment_brief_contracts.py` (`_REQUIRED_CONTEXTS` and the CI-section tokens). `atomic-plan-contract` changes in its `.claude` and claude-bundle copies (`test_push_down_claude_resource_contracts.py`). Bundle copies count against the batch budget: two new PowerShell production files plus no edited PowerShell files stays at two of three.
- File size: `ci.yml` grows from 115 lines to about 140, and `CiChangeScopeWorkflow.Tests.ps1` (340 lines) is not extended. New files are expected to be under 300 lines each. Not near any tier.
- Test isolation: the new tests read workflow text from disk and pass JSON strings in memory. They must not touch `$env:GITHUB_STEP_SUMMARY` or `$env:NEEDS_JSON` directly; use the `-ReadVariable` and `-OutputWriter` seams, as in `Invoke-CiChangeScope.Tests.ps1`. Run the seeded shuffled Pester file-order checks (three seeds) over the three new suites and `CiChangeScopeWorkflow.Tests.ps1`, plus a fresh single-process run over `tests/scripts`.
- CI-only behavior: the semantics of `needs.<caller>.result` for a partly skipped reusable workflow (`poshqc`) are observable only on a runner, and `toJSON(needs)` formatting is runner-produced. Mitigation: proof step D confirms both through the gate's summary table. Workflow tests use `Join-Path` and forward-slash relative paths (the Linux hook job does not run these suites, but the shards run on Windows). Until the owner applies section 8, a docs-only final head is BLOCKED, so step E must be a full-run head.
- Evidence: proof-run evidence (run URLs, gate summary excerpts, the context name, and the app id) goes under `<FEATURE>/evidence/other/` with UTC write-time stamps and no absolute paths. The ruleset JSON files stay in `SCRATCH`, and evidence records only the token. No evidence commit follows step E.
