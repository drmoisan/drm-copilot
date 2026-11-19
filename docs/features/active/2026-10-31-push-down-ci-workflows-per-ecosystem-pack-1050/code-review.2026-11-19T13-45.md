# Code Review: Push-Down CI Workflows per Ecosystem Pack (#1050)

**Review Date:** 2026-11-19
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050`
**Feature Folder Selection Rule:** Named by the caller for canonical issue #1050; matches the branch suffix `-1050`.
**Base Branch:** `origin/epic/shared-agent-harness-layer-integration` (merge base `021a52e74999d17c6ae67ed7a32c14958448ceab`)
**Head Branch:** `feature/push-down-ci-workflows-per-ecosystem-pack-1050` (`fccc2fbcdea8947cc11cba2e063bddfe5f566981`)
**Review Type:** Re-review after the advisory-fix pass (full branch scope)

---

## Executive Summary

The branch adds an optional `ci_workflows` input (`off`, `reference`, `copy`; default `off`) to every push-down MCP tool. When enabled, the push-down contributes a rendered destination caller `.github/workflows/drm-copilot-ci.yml` (workflow `CI`, gate job `CI Required Gate`), the data file `.github/drm-copilot/ci-required-checks.json`, the opt-in command `.github/drm-copilot/Set-CiRequiredChecks.ps1`, and in copy mode the selected `drm-copilot-<stem>.yml` reusable-workflow copies, all through the #1029 shared layer. It adds four destination-generic reusable workflows `.github/workflows/harness-{python,powershell,typescript,dotnet}.yml` (`workflow_call` only), their byte-identical bundle copies, the PowerShell opt-in command with Pester tests, one brief bullet in the six execution-environment brief copies, and README/CHANGELOG documentation.

The full diff from the merge base is 102 files. Compared with the previous review (`code-review.2026-11-19T11-55.md`, head `f4cf77c6a`), the advisory-fix commits `30280af22` and `fccc2fbcd` change eight non-feature-folder files: `scripts/ci/Set-CiRequiredChecks.ps1` and its bundle copy, `tests/scripts/ci/Set-CiRequiredChecks.Tests.ps1`, `.github/workflows/harness-powershell.yml` and its bundle copy, `push-down-ci-contract.test-helpers.ts`, `push-down-ci-contract.test.ts`, and `extensions/drm-copilot/README.md`. No production TypeScript file changed in the advisory pass.

Evidence reviewed: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (generated 2026-11-19 13:44:34 UTC at the reviewed head), the advisory-fix plan and its evidence (task checks P0-T1 to P1-T4, `phase-gate.P1.2026-11-19T13-22.md`, final static records 13-34, `final-pester.2026-11-19T13-38.md`, `final-jest.2026-11-19T13-39.md`, `advisory-scope-check.2026-11-19T13-40.md`, `self-review.2026-11-19T13-40.md`), and direct inspection of the advisory diff `3d27b56e1..HEAD`. The reviewer confirmed byte identity of the five source/bundle pairs with `git hash-object` (script `acac0fbb7...`, `harness-powershell.yml` `2fcf236c2...`, and the three unchanged workflows each equal to their copies), the script's Pester counter (LINE missed 1, covered 60) in `artifacts/pester/powershell-coverage.xml`, and the per-file Jest records of the new modules in `extensions/drm-copilot/coverage/lcov.info`.

**Resolution of the previous Minor items:**

| Previous finding | Status | Evidence |
|---|---|---|
| Ruleset list read one page (`Invoke-SetCiRequiredChecks`) | Resolved | List call is `gh api repos/<repo>/rulesets --paginate --slurp`; `ConvertFrom-Json -NoEnumerate` parses one document and pages are flattened before the case-sensitive name filter. Tests `lists the rulesets with --paginate and --slurp` and `finds a same-name ruleset on the second page and issues no write`; the second failed against the unchanged script (`task-check.P1-T1.2026-11-19T12-32.md`). |
| `gh` standard error merged into parsed output (`Invoke-GhExe`) | Resolved | Error records from `2>&1` are partitioned into `ErrorOutput`; `Output` holds standard output only. Failure messages name the `gh` argument text and `ErrorOutput`; non-JSON list output throws a message naming the call before any POST. Tests `returns standard output only when the command writes a warning to standard error`, `names the gh call and its error output when listing fails`, `names the gh call when the ruleset list is not JSON`. |
| Copy mode assumed a top-level `tests` directory (`harness-powershell.yml`) | Resolved | The copy-mode step tests `Test-Path -LiteralPath tests -PathType Container` and exits 1 with `Copy mode requires a top-level tests directory.`; README bullet added. Contract helper reports a violation when the guard is missing; negative case added to `harness workflows are destination-generic`. |

**Top 3 risks:**
1. The four `harness-*.yml` workflows and the rendered caller have not run on a GitHub runner. Static checks and text contract tests pass, but runtime behavior is unproven until CI and the S17 scratch-destination dispatch (plan task [P3-T5]). S17 dispatches reference mode, so the new copy-mode guard is pinned by text only.
2. `--slurp` on `gh api` requires a GitHub CLI version that supports it; on an older destination CLI the list call fails with an explicit `Could not list ...` error that includes the CLI's message, and no write occurs. The minimum version is not documented.
3. The .NET Cobertura-to-JaCoCo conversion sums per-project totals (carried over from the previous review as Info).

**PR readiness recommendation:** **Ready for PR, pending CI.** No code defect blocks the branch. The one blocking item is the workflow green-run requirement for changed `.github/workflows/**` paths, which waits on CI (see the policy audit and `remediation-inputs.2026-11-19T13-45.md`).

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `scripts/ci/Set-CiRequiredChecks.ps1` (and bundle copy) | `Invoke-SetCiRequiredChecks`, list call (line 179) | The list call depends on `gh api --slurp`, and the README does not state a minimum GitHub CLI version. An older CLI rejects the flag; the command then throws `Could not list the rulesets ... with gh api ... --paginate --slurp:` followed by the CLI error text, before any write. | Optional: add the minimum `gh` version to the README opt-in bullet. | The failure is explicit and occurs before any write, so the behavior is safe; the gap is documentation only. The flag was likely added in GitHub CLI 2.48 (not verified in this review); the plan records that the repository's pinned CLI 2.103.3 supports it. | Source inspection; `advisory-fix-plan.2026-11-19T12-07.md` `## Decisions` |
| Info | `.github/workflows/harness-powershell.yml` (and bundle copy) | step `Run Pester tests with coverage`, lines 74-77 | The new copy-mode guard executes only on a GitHub runner in a copy-mode destination. Its presence is pinned by the contract helper and actionlint, but neither CI in this repository nor the S17 reference-mode dispatch runs it. | None required. A copy-mode scratch dispatch would execute it if the orchestrator chooses to extend [P3-T5]. | Same `Write-Error -ErrorAction Continue` plus `exit 1` shape as the existing input guard; low risk. | Source inspection; `push-down-ci-contract.test-helpers.ts` lines 251-259 |
| Info | `.github/workflows/harness-dotnet.yml` (and bundle copy) | `Convert Cobertura totals to JaCoCo` steps | Totals from several Cobertura reports are summed. When two test projects cover the same production assembly, its lines are counted twice in the denominator and numerator. | Consider ReportGenerator-style merging in a later revision, or document that the figure is a sum of per-project totals. | The JaCoCo reader in the coverage hook reads only totals, so the format contract is met; accuracy for multi-test-project solutions is approximate. Unchanged since the previous review. | Source inspection |
| Info | `extensions/drm-copilot/src/lib/push-down/push-down-ci-layer.ts` | `withCiWorkflows`, lines 207-210 | The rewrite hook replaces any payload text that contains `__DRM_COPILOT_CI_JOBS__` with the rendered caller; no test asserts that only the caller template holds the marker. | Optional: add a contract assertion over the bundle. | Low risk; the marker is specific. Unchanged since the previous review. | Source inspection |
| Info | `tests/scripts/ci/Set-CiRequiredChecks.Tests.ps1` | `Invoke-SetCiRequiredChecks` mocks | The `Invoke-GhExe` mocks declare `GhArgs` and `InputText` but not `GhCommand`; the `throws when the repository cannot be resolved` fixture omits `ErrorOutput`, which the script reads as `$null` (no strict mode is set). | None required; production callers never pass `GhCommand`, and the missing property expands to an empty string in the message. | Signature parity for exercised parameters is kept; the test passes. | Test source; `final-pester.2026-11-19T13-38.md` |
| Info | `scripts/ci/Set-CiRequiredChecks.ps1` | lines 97, 148 | Two `SuppressMessageAttribute` entries (`PSUseShouldProcessForStateChangingFunctions` on a pure factory, `PSUseSingularNouns` on a name fixed by the spec), each with a specific justification. | None. | Matches existing repository usage; PSScriptAnalyzer reports 0 findings. | `final-pwsh-static.2026-11-19T13-34.md` |
| Info | `extensions/drm-copilot/src/repo-automation-service-contract.ts` | whole file | Reports 0% coverage (0/327); the branch adds only interface fields. | None; type-only module per the coverage clarification. | Avoids a false coverage finding. | `coverage-delta.2026-11-19T11-46.md` |

No Blocker, Major, or Minor findings in the code. No covered file in the branch diff is at or above 700 logical lines (largest `extensions/drm-copilot/jest.config.cjs`, 637 logical lines), so no Warning row applies.

---

## Implementation Audit

### TypeScript implementation audit

#### What changed well

- `push-down-ci-workflows.ts` is pure (no I/O import): mode parsing, manifest inference, pack-to-job mapping, and text rendering are separate exported functions, each with direct tests.
- `resolveCiPackJobs` reuses `assertSingleCsharpToolchain`, so the both-variants rejection has one implementation.
- `push-down-ci-layer.ts` reads only through the injected `PushDownFileSystem`; all writes go through the #1029 pipeline and writer, so CI files receive the same `unchanged`/`update`/`conflict`/`unmanaged-conflict`/`orphaned` handling as other payload files.
- The contract helper gained one violation rule for the copy-mode guard, with a negative case that removes the guard line, so the guard cannot be dropped silently from either copy.

#### Type safety and maintainability

- No `any`, no type assertion beyond `as const`, no suppression. ESLint strict-type-checked and tsc are clean (`final-ts-static.2026-11-19T13-34.md`).

#### Error handling and logging

- Template and fragment marker absence throws a specific error naming the marker or stem. Invalid modes and both C# variants fail before any write.
- Collision conflicts are reported as `push-down conflict:` warning lines, consistent with the #1029 conflict reporting.

### PowerShell implementation audit

- `Invoke-GhExe` keeps its signature and `-GhCommand` test seam; the result object gains `ErrorOutput` additively. `$LASTEXITCODE` is captured immediately after the call, before the partitioning pipeline.
- `Invoke-SetCiRequiredChecks` builds each `gh` argument array once (`$viewArgs`, `$listArgs`, `$createArgs`) and reuses it in the error message, so a failure names the exact call. The `try`/`catch` around `ConvertFrom-Json` rethrows with context, consistent with the fail-fast rule.
- Page flattening handles `[[]]`, multi-page, and single-element pages; the name comparison stays case-sensitive (`-ceq`).
- The default run remains a dry run; `-Apply` performs at most one POST guarded by `ShouldProcess`; no PUT, PATCH, or DELETE call exists.

### Workflow (YAML) audit

- Each `harness-*.yml` triggers only on `workflow_call`, declares `permissions: contents: read`, contains no repository-specific path or `NPM_TOKEN` text, and writes the artifact paths in the spec Template Contract. actionlint 1.7.12 reports zero findings with no suppression (`final-yaml-static.2026-11-19T13-34.md`).
- The copy-mode guard in `harness-powershell.yml` runs before `Import-Module Pester`, so the job fails with a named message rather than a Pester path error. Under the default `pwsh` shell preference the `-ErrorAction Continue` keeps `Write-Error` non-terminating so that the explicit `exit 1` sets the step result.
- The caller gate job evaluates `toJSON(needs)` inline with `if: always()` and exits 1 for any non-`success` result.

### Python implementation audit

No Python file is added or changed on the branch.

#### What changed well

- Not applicable; the branch keeps the no-new-Python rule (S16).

#### Typing and API notes

- Not applicable.

#### Error handling and logging

- Not applicable.

---

## Test Quality Audit

The branch adds 6 Jest test files plus 1 test-helper file and edits 2 Jest test files; it adds 1 Pester suite (30 tests, five added by the advisory pass). Final runs after the advisory pass: Jest (extension) 374 suites, 6184 tests passed; Pester 29242 tests, 0 failures, 0 errors, 18 skipped. Coverage: TypeScript repo-wide 97.44% lines / 94.66% branches (baseline 97.42% / 94.63%); `Set-CiRequiredChecks.ps1` 98.36% lines (previous 98.08%).

### Reviewed test and QA artifacts

- `tests/scripts/ci/Set-CiRequiredChecks.Tests.ps1` — the paged fixture (`[[]]`, `[[{...}]]`) matches the `--slurp` output shape; the second-page case uses its own mock that returns one page without `--paginate --slurp` and two pages with them, so it distinguishes the fixed call from the unfixed one; the standard-error case uses a test-double function that writes an error record and a JSON array.
- `extensions/drm-copilot/test/lib/push-down/push-down-ci-contract.test.ts` — negative case replaces the guard line with `if ($false) {` and expects the new violation message.
- `evidence/other/task-check.P1-T1.2026-11-19T12-32.md` — fail-before run (2 failures) and pass-after run (27 passed).
- `evidence/qa-gates/advisory-scope-check.2026-11-19T13-40.md` — touched paths limited to the eight named files plus the feature folder; pair hashes equal.

### Quality assessment prompts

- **Determinism:** In-memory file systems, no timers or randomness; the Pester suite mocks the `gh` seam and starts no process.
- **Isolation:** One behavior per case; mock overrides are scoped to the `It` that needs them.
- **Speed:** The Pester suite runs in about 1.1 s in its shard.
- **Diagnostics:** Pester `-Throw` wildcards assert the call text and error output; contract divergences are named.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; the workflows reference no secret; the contract test asserts no `NPM_TOKEN` text. |
| No unsafe subprocess or command construction | ✅ PASS | TypeScript modules start no process. The PowerShell command passes arguments as an array; no `--jq` expression interpolates the ruleset name; no `Invoke-Expression`. |
| Input validation at boundaries | ✅ PASS | `ci_workflows` validated against a closed set; data file validated before any `gh` call; non-JSON list output rejected before any write. |
| Error handling remains explicit | ✅ PASS | Every `gh` failure throws with the call text and error output. |
| Configuration / path handling is safe | ✅ PASS | Only the caller and selected copies are contributed under `.github/workflows/`; repository settings change only through the opt-in `-Apply` path. |

---

## Research Log

No external research was performed. Findings derive from the repository tree, the branch diff, and the feature evidence. The GitHub CLI version that introduced `--slurp` is stated as likely, not verified.

---

## Verdict

The three Minor items of the previous review are resolved, each with named tests and a recorded fail-before run for the pagination fix; the source/bundle pairs remain byte-identical and every gate re-ran clean after the change. The code review has no Blocker, Major, or Minor finding; the remaining rows are Info. The branch is blocked only by the pending CI evidence for the changed workflow paths, recorded in the policy audit.
