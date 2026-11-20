# Code Review: Push-Down CI Workflows per Ecosystem Pack (#1050)

**Review Date:** 2026-11-19
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050`
**Feature Folder Selection Rule:** Named by the caller for canonical issue #1050; matches the branch suffix `-1050`.
**Base Branch:** `origin/epic/shared-agent-harness-layer-integration` (merge base `021a52e74999d17c6ae67ed7a32c14958448ceab`)
**Head Branch:** `feature/push-down-ci-workflows-per-ecosystem-pack-1050` (`5ab48d8308964a34b7ec79cef4ba7e0a0a8f5261`)
**Review Type:** Remediation cycle 1, R4 re-audit (full branch scope)

---

## Executive Summary

The branch adds an optional `ci_workflows` input (`off`, `reference`, `copy`; default `off`) to every push-down MCP tool. When enabled, the push-down contributes a rendered destination caller `.github/workflows/drm-copilot-ci.yml` (workflow `CI`, gate job `CI Required Gate`), the data file `.github/drm-copilot/ci-required-checks.json`, the opt-in command `.github/drm-copilot/Set-CiRequiredChecks.ps1`, and in copy mode the selected `drm-copilot-<stem>.yml` reusable-workflow copies, all through the #1029 shared layer. It adds four destination-generic reusable workflows `.github/workflows/harness-{python,powershell,typescript,dotnet}.yml` (`workflow_call` only), their byte-identical bundle copies, the PowerShell opt-in command with Pester tests, one brief bullet in the six execution-environment brief copies, and documentation.

The full diff from the merge base is 127 files (45 outside the feature folder). Compared with the previous review (`code-review.2026-11-19T13-45.md`, head `fccc2fbcd`), commit `6db294022` changes four non-feature-folder files: `.github/workflows/harness-python.yml`, its bundle copy, `push-down-ci-contract.test-helpers.ts`, and `push-down-ci-contract.test.ts`. Commit `5ab48d830` adds the dispatch evidence and checks off [P3-T5], S17, and U4.

Evidence reviewed: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (generated 2026-11-19 14:38:12 UTC at `6db294022`), the cycle inputs `remediation-inputs.2026-11-19T14-16.md` and `remediation-plan.2026-11-19T14-16.md`, the cycle evidence (task checks 14-28, `phase-gate.P1.2026-11-19T14-33.md`, `final-qc-*.2026-11-19T14-32.md`, `self-review.2026-11-19T14-32.md`, `evidence-stamp-correction.2026-11-19T14-32.md`), `ci-dispatch.2026-11-19T14-42.md`, and direct inspection of `git show 6db294022`. The reviewer confirmed with `git hash-object` that all four workflow pairs are byte-identical (`harness-python.yml` `cfaf07f5a...`), recomputed the Jest totals from `extensions/drm-copilot/coverage/lcov.info`, and read the five dispatch runs and two runs' `referenced_workflows` through the GitHub API.

**Resolution of the cycle-1 finding:**

| Previous finding | Status | Evidence |
|---|---|---|
| CI-1: `harness-python.yml` step `Check coverage thresholds` failed on the empty-string key of the coverage.py JSON report | Resolved | The step reads `ConvertFrom-Json -AsHashtable` and `$report['totals']`, `$totals['num_statements']`, `['covered_lines']`, `['num_branches']`, `['covered_branches']`; thresholds, `Write-Output`/`Write-Error` messages, and `exit 1` are unchanged. Bundle copy identical. Test `python harness threshold step parses the report with -AsHashtable` asserts no violation for the real text and a named violation for a variant without `-AsHashtable`, a variant with `$report.totals`, and a text with no such step. Python scratch run 44545593464 (referenced workflow `harness-python.yml@6db29402288ad71d99f815cf79280e0194d218fc`) concluded `success` with `Python / Python QC` and `CI Required Gate` both `success`. |

**Top 3 risks:**
1. The final-head `pull_request` CI run is in progress; until it completes, the green-run policy item stays open (awaiting CI, recorded in the policy audit).
2. The scratch dispatch proves reference mode only; copy-mode-specific steps (for example the PowerShell `tests` guard) are pinned by text tests and actionlint, not by a runner (carried over as Info).
3. The .NET Cobertura-to-JaCoCo conversion sums per-project totals (carried over as Info).

**PR readiness recommendation:** **Ready, pending the final-head CI run.** No code defect blocks the branch.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/evidence/qa-gates/phase-gate.P1.2026-11-19T14-33.md` | file name and `Timestamp:` field | The stamp `14-33` was composed before the clock was read; the clock read `14-31` at the next reading. The executor disclosed this in `evidence/other/evidence-stamp-correction.2026-11-19T14-32.md` and kept the file unchanged, which preserves append-only evidence. | None for this item. Executors read the clock before composing a stamp. | The owner rule requires every timestamp to come from the clock; the deviation is disclosed, the content is consistent with the surrounding records, and correcting it would require altering evidence. Cost-benefit (OD-4): no remediation cycle. | `evidence-stamp-correction.2026-11-19T14-32.md` |
| Info | `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/evidence/qa-gates/ci-dispatch.2026-11-19T14-42.md` | `## Method` | The caller content on the scratch branches cannot be re-read: the `scratch/ci-1050-<pack>` branches are no longer on the remote (HTTP 404). The run records and their `referenced_workflows` (harness path and SHA) remain readable. | Optional: in future dispatch evidence, record the git blob hash of each scratch caller next to the hash of the rendered `drm-copilot-ci.yml`. | The claim that the caller equals the rendered output rests on the evidence text; the harness ref and the job list are independently confirmed. | `gh api repos/drmoisan/drm-copilot/actions/runs/44545593464` |
| Info | `.github/workflows/harness-powershell.yml` (and bundle copy) | step `Run Pester tests with coverage`, copy-mode guard | The copy-mode guard executes only in a copy-mode destination; the S17 dispatch runs reference mode. Pinned by the contract helper and actionlint. | None required. | Same `Write-Error` plus `exit 1` shape as the existing input guard; low risk. Carried over. | Source inspection |
| Info | `scripts/ci/Set-CiRequiredChecks.ps1` (and bundle copy) | `Invoke-SetCiRequiredChecks`, ruleset list call | The list call depends on `gh api --slurp`; the README does not state a minimum GitHub CLI version. An older CLI fails with an explicit error before any write. | Optional: state the minimum `gh` version in the README. | Documentation only; failure is explicit and safe. Carried over. | Source inspection |
| Info | `.github/workflows/harness-dotnet.yml` (and bundle copy) | `Convert Cobertura totals to JaCoCo` steps | Totals from several Cobertura reports are summed, so a production assembly covered by two test projects is counted twice. | Consider report merging later, or document the summation. | The coverage hook reads only totals, so the format contract is met. Carried over. | Source inspection |
| Info | `extensions/drm-copilot/src/lib/push-down/push-down-ci-layer.ts` | `withCiWorkflows` | The rewrite hook replaces any payload text holding `__DRM_COPILOT_CI_JOBS__`; no test asserts only the caller template holds the marker. | Optional: add a bundle-wide assertion. | Low risk; the marker is specific. Carried over. | Source inspection |
| Info | `extensions/drm-copilot/src/repo-automation-service-contract.ts` | whole file | Reports 0% coverage (0/327); the branch adds only interface fields. | None; type-only module. | Avoids a false coverage finding. | `coverage-delta.2026-11-19T11-46.md` |

No Blocker, Major, or Minor findings in the code. No covered file in the branch diff is at or above 700 logical lines (largest `extensions/drm-copilot/jest.config.cjs`, 637 logical lines), so no Warning row applies.

---

## Implementation Audit

### TypeScript implementation audit

#### What changed well

- `findPythonCoverageStepViolations` is pure, reuses `workflowSteps`, and returns one named message per violation (step absent, `-AsHashtable` absent, property access present).
- The property-access pattern `/\.totals\b|\$totals\./` rejects both `$report.totals` and `$totals.<field>`, so a partial revert of the accessors is detected, not only a revert of the parse switch.
- Production modules are unchanged in this cycle: `push-down-ci-workflows.ts` stays pure, and `push-down-ci-layer.ts` reads only through the injected `PushDownFileSystem`.

#### Type safety and maintainability

- No `any`, no suppression; ESLint and tsc clean (`final-qc-ts-static.2026-11-19T14-32.md`).

#### Error handling and logging

- Template and fragment marker absence throws a specific error; invalid modes and both C# variants fail before any write; collisions are reported as `push-down conflict:` warnings.

### PowerShell implementation audit

- No PowerShell source file changed in this cycle. `Invoke-GhExe` separates `ErrorOutput`; `Invoke-SetCiRequiredChecks` paginates the ruleset list, names the failing call, and performs at most one `ShouldProcess`-guarded POST.
- The inline `pwsh` step in `harness-python.yml` now uses `-AsHashtable`, available in PowerShell 7 on the hosted runners; hashtable indexing returns `$null` for a missing key, and `[double]$null` is `0`, so a report without branch data takes the existing `else { 100.0 }` path, the same result as before the change.

### Workflow (YAML) audit

- Each `harness-*.yml` triggers only on `workflow_call`, declares `permissions: contents: read`, and contains no repository-specific path or `NPM_TOKEN` text. actionlint 1.7.12 reports zero findings (`final-qc-workflows.2026-11-19T14-32.md`).
- Runner proof: five scratch runs `success`; `git diff --stat 9d75fe2be 5ab48d830` over `.github`, `scripts`, `extensions/drm-copilot/src`, and `extensions/drm-copilot/resources` lists only the two `harness-python.yml` files, so the four runs at `9d75fe2be` exercised the same powershell, typescript, and dotnet workflow text as the head.

### Python implementation audit

No Python file is added or changed on the branch.

#### What changed well

- Not applicable; the branch keeps the no-new-Python rule (S16). The Python harness change is workflow YAML with an inline PowerShell step.

#### Typing and API notes

- Not applicable.

#### Error handling and logging

- Not applicable.

---

## Test Quality Audit

The branch adds 6 Jest test files plus 1 test-helper file and edits 2 Jest test files; it adds 1 Pester suite (30 tests). Cycle 1 adds one Jest case. Final runs: Jest (extension) 374 suites, 6185 tests passed (`final-qc-jest.2026-11-19T14-32.md`); Pester 29242 tests, 0 failures (`final-pester.2026-11-19T13-38.md`). Coverage: TypeScript repo-wide 97.44% lines / 94.67% branches (reviewer recomputation; baseline 97.42% / 94.63%); `Set-CiRequiredChecks.ps1` 98.36% lines.

### Reviewed test and QA artifacts

- `extensions/drm-copilot/test/lib/push-down/push-down-ci-contract.test.ts` — new case uses `String.prototype.replace` with literal search strings; the replacement text `$report.totals` contains no `$`-substitution pattern (`$&`, `` $` ``, `$'`, `$<n>`), so the negative variant is built as intended.
- `evidence/qa-gates/final-qc-workflows.2026-11-19T14-32.md` — actionlint 0 findings; `cmp` identical.
- `evidence/qa-gates/ci-dispatch.2026-11-19T14-42.md` — five runs; reviewer confirmed conclusions and job lists.

### Quality assessment prompts

- **Determinism:** in-memory strings and file systems; no timers or randomness.
- **Isolation:** one behavior per case.
- **Speed:** the new case is string inspection.
- **Diagnostics:** violation messages name the pack, step, and rule.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; contract test asserts no `NPM_TOKEN` text. |
| No unsafe subprocess or command construction | ✅ PASS | TypeScript modules start no process; the PowerShell command passes argument arrays; the threshold step reads a fixed path. |
| Input validation at boundaries | ✅ PASS | `ci_workflows` validated against a closed set; data file validated before any `gh` call. |
| Error handling remains explicit | ✅ PASS | Threshold failures keep `Write-Error` and `exit 1`; `gh` failures throw with the call text. |
| Configuration / path handling is safe | ✅ PASS | Only the caller and selected copies are contributed under `.github/workflows/`; repository settings change only through `-Apply`. The dispatch changed no repository setting (evidence `## Method`). |

---

## Research Log

No external research was performed. Findings derive from the repository tree, the branch diff, the feature evidence, and read-only GitHub API queries for the dispatch runs and PR #1210 check state.

---

## Verdict

CI-1 is resolved with a minimal change, byte-identical bundle copy, a contract test with negative variants, and a successful runner execution at the fixed ref. The code review has no Blocker, Major, or Minor finding; all rows are Info. The branch waits only on the final-head `pull_request` CI run recorded in the policy audit.
