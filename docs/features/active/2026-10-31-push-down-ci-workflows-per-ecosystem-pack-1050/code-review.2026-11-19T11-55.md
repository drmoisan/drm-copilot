# Code Review: Push-Down CI Workflows per Ecosystem Pack (#1050)

**Review Date:** 2026-11-19
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050`
**Feature Folder Selection Rule:** Named by the caller for canonical issue #1050; matches the branch suffix `-1050`.
**Base Branch:** `origin/epic/shared-agent-harness-layer-integration` (merge base `021a52e74999d17c6ae67ed7a32c14958448ceab`)
**Head Branch:** `feature/push-down-ci-workflows-per-ecosystem-pack-1050` (`f4cf77c6a374e3c8369d6e6abe5506c3d135d5a6`)
**Review Type:** Opening review (full branch scope)

---

## Executive Summary

The branch adds an optional `ci_workflows` input (`off`, `reference`, `copy`; default `off`) to every push-down MCP tool. When enabled, the push-down contributes a rendered destination caller `.github/workflows/drm-copilot-ci.yml` (workflow `CI`, gate job `CI Required Gate`), the data file `.github/drm-copilot/ci-required-checks.json`, the opt-in command `.github/drm-copilot/Set-CiRequiredChecks.ps1`, and in copy mode the selected `drm-copilot-<stem>.yml` reusable-workflow copies, all through the #1029 shared layer. It adds four destination-generic reusable workflows `.github/workflows/harness-{python,powershell,typescript,dotnet}.yml` (`workflow_call` only), their byte-identical bundle copies, the PowerShell opt-in command with Pester tests, one brief bullet in the six execution-environment brief copies, and README/CHANGELOG documentation.

The full diff from the merge base is 89 files: 2 new TypeScript production modules (`push-down-ci-workflows.ts`, 338 lines; `push-down-ci-layer.ts`, 218 lines), 8 edited TypeScript production files, 7 new or edited Jest test files plus one test-helper file, 1 new PowerShell script with its byte-identical bundle copy and 1 Pester test file, 4 new harness workflows with bundle copies, the caller template and 4 job fragments, 1 JSON data file, 6 brief copies, 3 documentation files, and feature-folder documents and evidence. No `.py` file and no hook file changed.

Evidence reviewed: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (generated 2026-11-19 11:53:34 UTC at the reviewed head), the feature evidence tree (baselines, task checks, phase gates, final-QC static, Jest, pytest, Pester, coverage delta, scope check, self-review), and direct inspection of every new production file. The reviewer confirmed byte identity of the five source/bundle pairs with `git hash-object` (each pair equal) and the per-file Jest figures of the two new modules from `extensions/drm-copilot/coverage/lcov.info` (`push-down-ci-workflows.ts` LF 338 / LH 338, BRF 69 / BRH 67; `push-down-ci-layer.ts` LF 218 / LH 218, BRF 30 / BRH 29).

**Top 3 risks:**
1. The four `harness-*.yml` workflows and the rendered caller have not run on a GitHub runner. Static checks (actionlint 1.7.12, text contract tests) pass, but the runtime behavior of each pack job is unproven until the S17 scratch-destination dispatch (plan task [P3-T5]).
2. `Set-CiRequiredChecks.ps1` lists rulesets with one unpaginated `gh api repos/<repo>/rulesets` call; in a repository with more rulesets than one page returns, a same-name ruleset outside the first page is not detected before the POST.
3. The copy-mode PowerShell job and the .NET Cobertura-to-JaCoCo conversion embed destination-layout assumptions (a `tests` directory; per-project Cobertura totals summed without de-duplicating shared sources) that only a destination run exercises.

**PR readiness recommendation:** **Ready for PR, pending CI.** No code defect blocks the branch. The one blocking item is the workflow green-run requirement for changed `.github/workflows/**` paths, which waits on CI (see the policy audit and `remediation-inputs.2026-11-19T11-55.md`).

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `scripts/ci/Set-CiRequiredChecks.ps1` (and bundle copy `extensions/drm-copilot/resources/ci-workflows/Set-CiRequiredChecks.ps1`) | `Invoke-SetCiRequiredChecks`, line 171 | The existing-ruleset check reads one page of `gh api repos/$repo/rulesets` (no `--paginate`). A same-name ruleset beyond the first page is not found, and the command proceeds to the POST. | Add `--paginate` to the list call (and, because paginated output concatenates JSON arrays, use `--jq '.[] | select(.name == ...)'` or `--slurp`), and add a Pester case whose mocked list output spans two pages. | S14 and AD-7 state that an existing same-name ruleset produces no write. The defect affects only repositories with many rulesets; GitHub rejects a duplicate ruleset name server-side in current behavior, so the observable effect is likely a thrown "Creating the ruleset failed" error rather than a second ruleset. Non-blocking. | Source inspection, lines 171-179; test `reports an existing ruleset of the same name and issues no write` uses a one-element list |
| Minor | `scripts/ci/Set-CiRequiredChecks.ps1` | `Invoke-GhExe`, lines 60-65 | The wrapper merges standard error into standard output (`2>&1`), and the list result is parsed with `ConvertFrom-Json`. A `gh` warning on standard error with exit code 0 makes the parse fail with a JSON error instead of the command's own message. | Capture standard error separately, or parse only standard output for the list call. | The seam follows the repository wrapper pattern; the effect is a less specific error message, not a wrong write. | Source inspection |
| Minor | `.github/workflows/harness-powershell.yml` (and bundle copy) | step `Run Pester tests with coverage`, lines 70-89 | Copy mode sets `Run.Path = 'tests'` unconditionally. A destination with PowerShell sources but no top-level `tests` directory fails this step. | Either document the `tests/` layout requirement in the README copy-mode section or guard the step with a clear error message. | Matches the repository test-location rule, so destinations following the pushed-down rules are not affected; only nonconforming layouts are. | Source inspection |
| Info | `.github/workflows/harness-dotnet.yml` (and bundle copy) | `Convert Cobertura totals to JaCoCo` steps | Totals from several Cobertura reports are summed. When two test projects cover the same production assembly, its lines are counted twice in the denominator and numerator. | Consider ReportGenerator-style merging in a later revision, or document that the figure is a sum of per-project totals. | The JaCoCo reader in the coverage hook reads only totals, so the format contract is met; accuracy for multi-test-project solutions is approximate. | Source inspection |
| Info | `extensions/drm-copilot/src/lib/push-down/push-down-ci-layer.ts` | `withCiWorkflows`, lines 207-210 | The rewrite hook replaces any payload text that contains `__DRM_COPILOT_CI_JOBS__` with the rendered caller. The comment states that only the caller template holds the marker; no test asserts that invariant over the bundle. | Optional: add a contract assertion that no other bundled payload file contains the marker. | Low risk; the marker is specific and the contract test already enumerates the CI bundle. | Source inspection; `push-down-ci-contract.test.ts` `CI bundle is complete and copies match` |
| Info | `tests/scripts/ci/Set-CiRequiredChecks.Tests.ps1` | `BeforeAll`, lines 11-16; mock at lines 135-141 | The suite dot-sources the script instead of the AST import pattern named in plan task [P1-T3]; the header comment states the reason (Pester attributes coverage to the file). The `Invoke-GhExe` mock declares `GhArgs` and `InputText` but not `GhCommand`. | None required; production callers never pass `GhCommand`. Adding the parameter to the mock would complete signature parity. | The dot-source guard (`$MyInvocation.InvocationName -ne '.'`) makes dot-sourcing side-effect free, and the AST shape test pins the single guarded call. | Test file header; `final-pester.2026-11-19T11-46.md` (25 tests, 0 failures) |
| Info | `scripts/ci/Set-CiRequiredChecks.ps1` | lines 92, 143 | Two `SuppressMessageAttribute` entries (`PSUseShouldProcessForStateChangingFunctions` on a pure factory, `PSUseSingularNouns` on a name fixed by the spec), each with a specific justification. | None. | The same pattern is used in `scripts/ci/CiChangeScope.psm1` and other repository modules; PSScriptAnalyzer reports 0 findings. | `final-pwsh-static.2026-11-19T11-02.md` |
| Info | `extensions/drm-copilot/src/repo-automation-service-contract.ts` | whole file | Reports 0% coverage (0/327); the branch adds only interface fields. | None; type-only module per the coverage clarification. | Avoids a false coverage finding. | `coverage-delta.2026-11-19T11-46.md` |

No Blocker or Major findings in the code. No covered file in the branch diff is at or above 700 logical lines (largest `extensions/drm-copilot/jest.config.cjs`, 637 physical lines; logical count is not greater), so no Warning row applies.

---

## Implementation Audit

### TypeScript implementation audit

#### What changed well

- `push-down-ci-workflows.ts` is pure (no I/O import): mode parsing, manifest inference, pack-to-job mapping, and text rendering are separate exported functions, each with direct tests. The parse error names the received value as S1 requires.
- `resolveCiPackJobs` reuses `assertSingleCsharpToolchain`, so the both-variants rejection has one implementation, and it maps the Copilot `csharp` pack with its recorded variant.
- `push-down-ci-layer.ts` reads only through the injected `PushDownFileSystem`; all writes go through the #1029 pipeline and writer, so CI files receive the same `unchanged`/`update`/`conflict`/`unmanaged-conflict`/`orphaned` handling as other payload files.
- The protected-path mechanism (`unmanagedProtectedPaths` on `PushDownLayer`, consumed in `planPayloadFile`) is a four-line, optional extension that leaves existing layers unaffected.
- The collision check is anchored at column 0 (`^name:`), so job-level `name:` keys are ignored; the caller's own path is excluded; the check runs while layers are built, so dry runs report it.
- Run-option forwarding uses the existing conditional-spread pattern through the MCP input, service call, and harness, so omitting `ci_workflows` leaves earlier call shapes unchanged.

#### Type safety and maintainability

- No `any`, no type assertion beyond `as const`, no suppression. `CiWorkflowsMode` is derived from the `CI_WORKFLOWS_MODES` tuple. ESLint strict-type-checked and tsc are clean (`final-ts-static.2026-11-19T11-02.md`).
- `repo-automation-service-push-down.ts` restates the mode as a literal union rather than importing `CiWorkflowsMode`; this matches that module's existing pattern of not importing push-down library types.

#### Error handling and logging

- Template and fragment marker absence throws a specific error naming the marker or stem. Invalid modes and both C# variants fail before any write (harness test `rejects a selection union holding both C# variants`).
- Collision conflicts are reported as `push-down conflict:` warning lines and are not raised as errors, consistent with the #1029 conflict reporting.

### PowerShell implementation audit

- `Set-CiRequiredChecks.ps1` uses `CmdletBinding(SupportsShouldProcess)`, an `Invoke-GhExe -GhArgs` wrapper seam, and a dot-source guard. The default run is a dry run, `-Apply` performs at most one POST guarded by `ShouldProcess`, and the script contains no PUT, PATCH, or DELETE call.
- Data validation rejects non-JSON, non-object, missing, empty, blank, and non-string `required_contexts` with a `malformed` message before any `gh` call.
- The bundle copy is byte-identical (`git hash-object` 6537b7ff8 for both).

### Workflow (YAML) audit

- Each `harness-*.yml` triggers only on `workflow_call`, declares `permissions: contents: read`, contains no repository-specific path or `NPM_TOKEN` text, and writes the artifact paths in the spec Template Contract. actionlint 1.7.12 reports zero findings with no suppression (`final-yaml-static.2026-11-19T11-02.md`).
- The PowerShell workflow fails explicitly when `poshqc` is true and either harness input is empty, before the side checkout.
- The caller gate job evaluates `toJSON(needs)` inline with `if: always()` and exits 1 for any non-`success` result; with no pack job the `needs` key is omitted and the gate passes on an empty map.
- Python coverage thresholds are inputs (defaults 85 and 75) checked by an inline `pwsh` step over `coverage.json` totals.

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

The branch adds 6 Jest test files plus 1 test-helper file and edits 2 Jest test files; it adds 1 Pester suite. Final runs: Jest (extension) 374 suites, 6184 tests passed (baseline 6119); pytest 17122 passed; Pester 29237 tests, 0 failures (baseline 29212). Coverage: TypeScript repo-wide 97.44% lines / 94.66% branches (baseline 97.42% / 94.63%); new modules 100% lines, 97.10% and 96.67% branches; `Set-CiRequiredChecks.ps1` 98.08% lines.

### Reviewed test and QA artifacts

- `extensions/drm-copilot/test/lib/push-down/push-down-ci-workflows.test.ts` — parse, inference, pack-job mapping (including Codex and Copilot C# variants), and rendering cases for each mode, including the PowerShell input split between reference and copy modes.
- `extensions/drm-copilot/test/lib/push-down/push-down-harness.ci-workflows.test.ts` — in-memory harness cases for S1, S2, S4-S10: off/omitted/reuse, orphaned after explicit off, both-variant rejection, reference/copy delivery with manifest entries and hashes, exact data file in three runs, idempotence, dry run, payload-version update, `unmanaged-conflict` with `overwriteUnmanaged: true` at the data file and the caller, edited managed caller kept as `conflict`, workflows-folder confinement, and collision including dry run.
- `extensions/drm-copilot/test/lib/push-down/push-down-ci-contract.test.ts` — real-tree text contract: destination-generic workflows, caller/data/merge-gate/coverage-hook literal agreement with a negative diverging-template case, PowerShell input declarations, bundle completeness and byte identity, brief bullet placement, and no `gh` in the new modules.
- `extensions/drm-copilot/test/mcp-tool-inputs.push-down-ci-workflows.test.ts` — MCP input parsing for each tool.
- `tests/scripts/ci/Set-CiRequiredChecks.Tests.ps1` — 25 tests: script shape, direct run, wrapper body through a test double, body construction, malformed data (7 cases), and every S14 behavior with a mocked `Invoke-GhExe`.
- `evidence/qa-gates/final-scope-check.2026-11-19T11-47.md` — no `mkdtemp`, `tmpdir`, or `writeFileSync` token in any new test file.

### Quality assessment prompts

- **Determinism:** In-memory file systems with POSIX roots, CRLF built in code, no timers or randomness; the Pester suite mocks the `gh` seam and starts no process.
- **Isolation:** One behavior per case; harness cases seed their own file system.
- **Speed:** The five new Jest files ran in one launcher call (`jest-new-files.2026-11-19T10-36.md`); Pester suite timing is within the parallel gate.
- **Diagnostics:** Contract divergences are returned as a list of named mismatches; Pester assertions name the expected argument string.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; the workflows reference no secret; the contract test asserts no `NPM_TOKEN` text. |
| No unsafe subprocess or command construction | ✅ PASS | TypeScript modules start no process (contract test `new push-down CI modules invoke no gh`). The PowerShell command passes arguments as an array to `gh`; workflow inputs reach `pwsh` steps through `env:` rather than inline expression interpolation. |
| Input validation at boundaries | ✅ PASS | `ci_workflows` validated against a closed set at the MCP boundary; data file validated before any `gh` call. |
| Error handling remains explicit | ✅ PASS | Specific errors before any write; conflicts reported rather than overwritten. |
| Configuration / path handling is safe | ✅ PASS | Only the caller and selected copies are contributed under `.github/workflows/`; CI paths are excluded from `overwrite_unmanaged`; repository settings change only through the opt-in `-Apply` path. |

---

## Research Log

No external research was required. Findings derive from the repository tree, the branch diff, and the feature evidence. The statement that GitHub rejects duplicate ruleset names is recorded as likely, not verified in this review.

---

## Verdict

The implementation is cohesive, reuses the #1029 pipeline for every write and conflict decision, and is covered by unit, harness, contract, and Pester tests with coverage above every threshold. The code review has no blocking finding; three Minor items (ruleset list pagination, `gh` standard-error handling, copy-mode `tests` directory assumption) are recommended for fixing inside this item before merge. The branch is blocked only by the pending CI evidence for the changed workflow paths, recorded in the policy audit.
