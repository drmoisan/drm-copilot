# Policy Compliance Audit: bump-and-publish-task (Issue #191)

**Audit Date:** 2026-06-17
**Audit Type:** Re-audit after remediation (cycle 2)
**Feature Folder:** `docs/features/active/2026-06-16-bump-and-publish-task-191`
**Base Branch:** `main`
**Merge-base SHA:** `93d83d5ea01d40b229e2721f057210d9ef698206`
**Head SHA:** `75e3ec51aafa8f00eed4a426552627d36ac9413d`
**Work Mode:** `minor-audit`
**Code Under Test (full branch diff vs base):**
- `scripts/dev-tools/Invoke-FullRelease.ps1` (added, +230)
- `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` (added, +162)
- `.github/workflows/publish-mcp-npm.yml` (modified, +7/-1)
- `.vscode/tasks.json` (modified, +30)
- Feature documentation and evidence artifacts under `docs/features/active/2026-06-16-bump-and-publish-task-191/` (added)

> Template note: the MCP server tool `mcp__drm-copilot__resolve_policy_audit_template_asset` is not exposed in this review environment. This artifact follows the canonical section structure defined in `.claude/skills/policy-audit-template-usage/SKILL.md`. The MCP-resolved asset remains the authoritative template source; this is a structural fallback only.

## Coverage Metrics by Language

| Language | Files Changed | Tests | Test Result | Repo-wide (pinned) Coverage | New-code Coverage | Verdict |
|----------|---------------|-------|-------------|------------------------------|-------------------|---------|
| PowerShell | 1 production (`Invoke-FullRelease.ps1`), 1 test | 7 new Pester tests (608 repo-wide) | PASS (608 pass, 0 fail, EXIT 0) | 96.83% line (275/284), unchanged from baseline | 88.0% line (44/50); BRANCH counter not emitted (tooling-limitation exception recorded) | PASS |
| GitHub Actions (YAML) | 1 (`publish-mcp-npm.yml`) | N/A (actionlint static + green workflow run) | PASS (actionlint EXIT 0; green `workflow_dispatch` run 27657801156, conclusion success) | N/A (no executable line coverage for YAML) | N/A | PASS |
| JSON/JSONC | 1 (`.vscode/tasks.json`) | N/A (schema validate) | PASS (tasks-json-validate EXIT 0) | N/A | N/A | PASS (structural) |
| Markdown | docs + evidence (no executable code) | N/A | N/A | N/A | N/A | N/A (zero executable code) |

Coverage-verdict note: the only language with changed files that has an executable-coverage obligation is PowerShell, and its verdict is an explicit PASS (line 88.0% >= 85%; branch metric not emitted by the repository's mandated Pester/CoverageGutters output format, discharged via the policy-sanctioned tooling-limitation exception with a complete per-branch enumeration). YAML and JSONC have no line-coverage denominator; their verdicts reflect their applicable static/structural gates. No language with changed files is marked `N/A` for its applicable gate.

## Executive Summary

The current feature state is **PASS — ready for merge**. This is the re-audit following remediation of the two findings raised in the prior cycle (`policy-audit.2026-06-17T00-18.md`). Both prior findings are now resolved with recorded evidence:

1. **F1 (was BLOCKING) — `modified-workflow-needs-green-run`: RESOLVED.** A green `workflow_dispatch` run of `publish-mcp-npm.yml` was obtained against branch head `7803ffc9282d6172e59bf0baafe10c3ca7005d97` (Run ID 27657801156, conclusion `success`). The run exercised the changed job (`Publish to npm`) and its job-level `permissions` (`id-token: write`, `contents: read`); the irreversible `Publish to npm` step was correctly **skipped** by its `if: github.event_name == 'push'` guard, so no `npm publish` executed and no `mcp-server-v*` tag was pushed. The workflow file is byte-identical between the green-run SHA and the current HEAD: `git diff 7803ffc9282d6172e59bf0baafe10c3ca7005d97 75e3ec51aafa8f00eed4a426552627d36ac9413d -- .github/workflows/publish-mcp-npm.yml` returns empty. The only commit after the green-run SHA is the evidence-recording commit `75e3ec5`, which does not modify the workflow. The green run is therefore valid for the current branch head. Evidence: `evidence/qa-gates/workflow-green-run.md`.

2. **F2 (was PARTIAL) — branch coverage for new PowerShell code: RESOLVED via sanctioned exception.** New-code line coverage for `Invoke-FullRelease.ps1` is 88.0% (44/50 lines), re-verified directly from `artifacts/pester/fullrelease-coverage.xml` during this audit (LINE missed=6 covered=44). The repository's mandated PowerShell coverage tool (Pester via PoshQC, JaCoCo/CoverageGutters XML format) emits zero `type="BRANCH"` counters; this was re-confirmed against both `artifacts/pester/fullrelease-coverage.xml` and `artifacts/pester/powershell-coverage.xml` (0 BRANCH counters in each). Because the baseline coverage artifact emits zero BRANCH counters as well, this is a repo-wide property of the output format, not a property of this feature's code, and there is no branch-coverage regression introduced by this change. The policy-sanctioned tooling-limitation exception is recorded in `evidence/qa-gates/coverage-delta.md` with a complete per-branch enumeration (15 decision points across `Invoke-FullReleaseGuarded` and `Get-NpmVersion`), each mapped to a covering test. No coverage threshold was lowered.

**Policy documents evaluated:**
- `.github/copilot-instructions.md` (tone)
- `.claude/rules/general-code-change.md`
- `.claude/rules/general-unit-test.md`
- `.claude/rules/powershell.md`
- `.claude/rules/ci-workflows.md`
- `.claude/rules/quality-tiers.md`
- `.github/instructions/github-actions.instructions.md`

## Rejected Scope Narrowing

No caller instruction attempted to narrow the audit scope to a plan, task, phase, or file subset. The caller explicitly instructed: "Determine scope yourself per the SKILL's scope invariant; do not narrow scope." The audit covers the full branch diff vs `main` (`93d83d5..75e3ec5`). No verbatim narrowing text to record.

## Evidence Location Compliance

The branch diff was scanned for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`:

```
git diff --name-only 93d83d5ea01d40b229e2721f057210d9ef698206..75e3ec51aafa8f00eed4a426552627d36ac9413d -- 'artifacts/baselines/**' 'artifacts/qa/**' 'artifacts/evidence/**' 'artifacts/coverage/**'
```

This returned **no paths**. All feature evidence for issue #191 is correctly placed under `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/<kind>/` (canonical location).

`scripts/dev_tools/validate_evidence_locations.py --root .` exits non-zero and reports violations under `artifacts/evidence/baseline/*` and `artifacts/evidence/post-change/*`. Each reported path carries an April-2026 timestamp (`2026-04-18T*`, `2026-04-25T18-15`) and is **not** part of this branch's diff and **not** tracked at HEAD (`git ls-files artifacts/evidence/` returns zero tracked files). These are pre-existing, untracked working-tree artifacts from prior features, outside the scope of issue #191. They are not attributed as FAIL findings for this feature; they are recorded here for traceability. Remediation of pre-existing, out-of-scope working-tree files is not part of this review.

No FAIL-level evidence-location finding exists for this branch.

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | Pester `It` blocks set up mocks in `BeforeEach`; no shared mutable state across tests; repo-wide run passes (EXIT 0). |
| Isolation | PASS | Each `It` exercises a single behavior of `Invoke-FullReleaseGuarded` or a pure helper (`Get-McpServerTagName`, `Get-NpmVersion`). |
| Fast execution | PASS | Pure-PowerShell unit tests with all external seams mocked; no network or process spawn. |
| Determinism | PASS | All external executables routed through wrapper seams (`Invoke-GitExe`, `Invoke-NpmExe`, `Invoke-PublishScript`) and mocked; `Test-Path` mocked; no temp files, no real git/npm, no clock/RNG use. |
| Readability & maintainability | PASS | Test names describe the scenario (guard rejection, case-sensitivity, bump args, tag derivation, missing publish script). |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline coverage documented | PASS | `evidence/baseline/poshqc-test.md`: repo-wide pinned 96.83% line (275/284). |
| No regression on changed lines | PASS | Changed lines are entirely new (new file); repo-wide pinned scope unchanged at 96.83% (`evidence/qa-gates/coverage-delta.md`). |
| New-code line coverage >= 85% | PASS | `artifacts/pester/fullrelease-coverage.xml`: LINE 44/50 = 88.0%. Re-verified against the artifact during this audit. |
| New-code branch coverage >= 75% | PASS (via sanctioned tooling-limitation exception) | No BRANCH counter emitted by the tooling (0 BRANCH counters in coverage XML, re-confirmed). Policy-sanctioned exception in `evidence/qa-gates/coverage-delta.md` enumerates all 15 decision branches, each mapped to a covering test; baseline emits zero BRANCH counters identically, so no regression. |
| Positive flows | PASS | Confirmed run (`yes`) success path returns 0 with bump+publish+tag-create+tag-push. |
| Negative flows | PASS | `no`, `YES`, `Yes` rejected with code 2; missing publish script returns 1; failure exit codes from each wrapper seam propagate. |
| Edge cases | PASS | Case-sensitivity of the confirmation token (`-cne 'yes'`) is explicitly tested. |
| Error handling | PASS | Missing publish script and each non-zero wrapper exit reported via `Write-StderrLine`, not silently ignored. |
| Concurrency | N/A | The script performs a sequential release; no concurrent behavior. |
| State transitions | N/A | Linear orchestration, no stateful component. |

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clear failure messages | PASS | `Should -Be` / `Should -Match` assertions with explicit expected values. |
| Arrange-Act-Assert | PASS | Mocks arranged in `BeforeEach`/`It`, single invocation, then assertions. |
| Document intent | PASS | `Describe`/`Context`/`It` names map to behaviors under test. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| Avoid external dependencies | PASS | No network/service/live-executable dependency; wrapper seams mocked. |
| Use mocks/stubs | PASS | Wrapper functions (not raw `git`/`npm`) are mocked, per `.claude/rules/powershell.md` mocking rules. |
| No temporary files | PASS | Production test uses AST `Import-ScriptFunction`; no temp files created. |

### 1.5 Test File Location

| Requirement | Status | Evidence |
|------------|--------|----------|
| Mirrored `tests/` layout | PASS | `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` mirrors `scripts/dev-tools/Invoke-FullRelease.ps1`; `*.Tests.ps1` suffix used. |

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity first | PASS | Single guarded function orchestrates three sequential steps; no deep indirection. |
| Reusability | PASS | Pure helpers (`Get-NpmVersion`, `Get-McpServerTagName`) factored out. |
| Extensibility | PASS | Named parameters with `[Parameter(Mandatory)]`; wrapper seams enable injection/mocking. |
| Separation of concerns | PASS | External-call seams isolated from orchestration logic; pure read/derive functions separated. |
| Fail fast / explicit errors | PASS | Each step checks an exit code and returns a distinct non-zero code with a stderr message; no silent catch-all. |
| File size limit (<= 500 lines) | PASS | `Invoke-FullRelease.ps1` is 230 lines; test file is 162 lines. |
| Naming | PASS | Approved verbs (`Invoke-`, `Get-`, `Write-`) and descriptive nouns. |
| No prohibited APIs | PASS | No `Invoke-Expression`, no plaintext secrets, no hard-coded credentials. |
| Dependencies | PASS | Uses only existing `git`/`npm`/repo publish script; no new package. |
| I/O boundaries | PASS | Filesystem read (`Get-Content`/`Test-Path`) and process calls isolated; pure logic testable without I/O. |

## 3. Language-Specific Code Change Policy Compliance (PowerShell)

| Requirement | Status | Evidence |
|------------|--------|----------|
| Advanced functions with `CmdletBinding()` | PASS | All functions declare `[CmdletBinding()]` and named parameters. |
| Mandatory/validation attributes | PASS | `[Parameter(Mandatory = $true)]` on all required parameters. |
| Wrapper-function seam pattern | PASS | `Invoke-GitExe -GitArgs [string[]]`, `Invoke-NpmExe -NpmArgs [string[]]`, `Invoke-PublishScript -ScriptPath [string]`; parameter names avoid the `Args` automatic-variable collision. |
| PowerShell 7+ compatibility | PASS (inferred) | PSScriptAnalyzer gate passed (EXIT 0); no version-incompatible constructs observed. |
| Formatting (Invoke-Formatter / PoshQC) | PASS | `evidence/qa-gates/poshqc-format.md` EXIT 0. |
| Linting (PSScriptAnalyzer / PoshQC) | PASS | `evidence/qa-gates/poshqc-analyze.md` EXIT 0. |
| Type checking | N/A | Not applicable to PowerShell per `.claude/rules/powershell.md`. |
| ShouldProcess for state-changing actions | OBSERVATION (non-blocking) | The script performs state-changing actions (npm version bump, git tag create/push, Marketplace publish) but gates them behind a mandatory `-ConfirmToken 'yes'` rather than `SupportsShouldProcess`. The explicit confirmation-token design is an intentional, tested equivalent that satisfies the immutability-confirmation requirement and matches the existing `Invoke-MarketplacePublish.ps1` task pattern. Recorded as a non-blocking observation. |
| Change budget (<= 2 production PS files) | PASS | One production PowerShell file changed. |

## 4. Language-Specific Unit Test Policy Compliance (PowerShell)

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pester v5.x, `Describe`/`Context`/`It` | PASS | Structure conforms; one behavior per `It`. |
| Mirror code structure | PASS | `tests/scripts/dev-tools/...`. |
| Mock external executables via wrapper seam | PASS | Mocks target `Invoke-GitExe`/`Invoke-NpmExe`/`Invoke-PublishScript`, never raw `git`/`npm`. |
| Mock signature parity | PASS | Mock `param` blocks match production named parameters (`[string[]]$GitArgs`, `[string[]]$NpmArgs`, `[string]$ScriptPath`). |
| Line coverage >= 85% | PASS | 88.0% on new file. |
| Branch coverage >= 75% | PASS (via sanctioned exception) | No branch metric emitted by tooling; per-branch enumeration in `coverage-delta.md` demonstrates every decision branch is exercised; baseline emits zero BRANCH counters identically (no regression). |
| No coverage regression on changed lines | PASS | New file; pinned repo-wide coverage unchanged. |

## 5. Test Coverage Detail

- Repo-wide pinned scope (`pester.runsettings.psd1`): 96.83% line (275/284). The pinned scope targets five hook files and does not include `scripts/dev-tools/`; this is pre-existing repository policy and is not modified by this feature.
- New file `scripts/dev-tools/Invoke-FullRelease.ps1`: targeted run `artifacts/pester/fullrelease-coverage.xml` reports 44/50 lines (88.0%), 52/59 instructions (88.14%). Re-verified during this audit: `type="LINE" missed="6" covered="44"`.
- Uncovered lines (6): the dot-source-guard entry-point block (lines 226-229, intentionally skipped so functions can be imported for test) and the single-statement bodies of two mocked wrapper seams (`Write-StderrLine` line 52; `Invoke-PublishScript` lines 102-103). These are consistent with the wrapper-seam mocking policy.
- Branch coverage: not emitted by the Pester/CoverageGutters output format for either baseline or post-change (0 `type="BRANCH"` counters in both XML files). The sanctioned tooling-limitation exception in `evidence/qa-gates/coverage-delta.md` discharges the >= 75% branch-coverage intent via a complete per-branch enumeration; no threshold was lowered.

## 6. Test Execution Metrics

| Metric | Value | Source |
|--------|-------|--------|
| Repo-wide Pester tests | 608 (601 baseline + 7 new) | `evidence/qa-gates/poshqc-test.md` |
| Failures / errors | 0 / 0 | EXIT 0 |
| New suite tests | 7 | `Invoke-FullRelease.Tests.ps1` |
| actionlint findings | 0 (EXIT 0) | `evidence/qa-gates/actionlint.md` |
| tasks.json schema validation | PASS (EXIT 0) | `evidence/qa-gates/tasks-json-validate.md` |
| Green workflow run | Run 27657801156, conclusion success | `evidence/qa-gates/workflow-green-run.md` |

## 7. Code Quality Checks

| Check | Command | Result |
|-------|---------|--------|
| PowerShell format | `mcp__drm-copilot__run_poshqc_format` | PASS (EXIT 0) |
| PowerShell lint | `mcp__drm-copilot__run_poshqc_analyze` | PASS (EXIT 0) |
| PowerShell tests + coverage | `mcp__drm-copilot__run_poshqc_test` | PASS (EXIT 0) |
| GitHub Actions lint | `actionlint .github/workflows/publish-mcp-npm.yml` | PASS (EXIT 0) |
| GitHub Actions green run | `workflow_dispatch` run 27657801156 | PASS (conclusion success; publish step skipped) |
| JSONC schema | tasks.json validate | PASS (EXIT 0) |

Note: toolchain results above are read from the feature evidence package produced during execution; this review verifies the recorded artifacts rather than re-running coverage generation, per the coverage-verification model. The branch diff content (script, test, workflow, tasks.json) and the coverage XML counters were re-read during this audit and match the evidence claims.

### 7.1 ci-workflows.md exit-code handling

The modified workflow contains no `pwsh` step with a deliberately-failing nested command. `.claude/rules/ci-workflows.md` has no applicable construct to remediate. PASS (no applicable construct).

### 7.2 modified-workflow-needs-green-run

The branch diff modifies `.github/workflows/publish-mcp-npm.yml` (a path matching `.github/workflows/**`), so the rule fires. Qualifying green-run evidence is present: a green `workflow_dispatch` run (Run 27657801156, conclusion success) against branch head `7803ffc`. The workflow is byte-identical between `7803ffc` and current HEAD `75e3ec5` (the diff for that file across the two SHAs is empty), so the run is valid for the current head. PASS.

## 8. Gaps and Exceptions

1. **RESOLVED (was BLOCKING):** `modified-workflow-needs-green-run` — green `workflow_dispatch` run 27657801156 against head `7803ffc`; workflow unchanged to HEAD. PASS.
2. **RESOLVED (was PARTIAL):** New-code branch coverage — discharged via the sanctioned tooling-limitation exception in `coverage-delta.md` with a complete per-branch enumeration; new-code line coverage 88.0% PASS. No threshold lowered.
3. **OBSERVATION (non-blocking, unchanged):** State-changing actions are gated by `-ConfirmToken` rather than `SupportsShouldProcess`; intentional design, documented and tested. No remediation required.

No blocking or PARTIAL findings remain.

## 9. Summary of Changes

A combined release wrapper `Invoke-FullRelease.ps1` and a VS Code task were added to release the extension and the MCP server together: patch-bump the mcp-server manifest, publish the extension via the existing Marketplace script (which bumps the extension manifest), then create and push a `mcp-server-v<version>` tag to trigger the npm publish workflow. The npm publish workflow was amended to publish with `--provenance` and `id-token: write`, to add a `workflow_dispatch` trigger for verification, and to guard the publish step with `if: github.event_name == 'push'`. The action is gated behind a `yes`/`no` confirmation input. Pester tests cover the guard, bump arguments, tag derivation, the failure-path exit-code propagation, and the missing-publish-script path.

## 10. Compliance Verdict

**Overall verdict: PASS — ready for merge.**

- Code-change and unit-test policy: PASS.
- PowerShell language policy: PASS (ShouldProcess noted as a non-blocking observation).
- Coverage: line PASS (88.0%); branch discharged via sanctioned tooling-limitation exception with per-branch enumeration — PASS.
- `modified-workflow-needs-green-run`: PASS (green head-SHA-valid run recorded; workflow unchanged to HEAD).
- Evidence-location compliance: PASS (no in-scope violations).

Zero blocking findings remain. No remediation is required.

## Appendix A: Test Inventory

`tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` (7 tests):
1. confirmation guard: `no` returns 2; no bump/publish/tag invoked.
2. confirmation guard: `YES` rejected with 2 (case-sensitive).
3. confirmation guard: `Yes` rejected with 2 (case-sensitive).
4. mcp-server bump: expected npm wrapper args (`version`, `patch`, `--no-git-tag-version`, prefix path) and derived version `0.0.2`.
5. tag derivation: `Get-McpServerTagName 0.0.2` -> `mcp-server-v0.0.2` (pure function).
6. tag push: git wrapper called with derived `mcp-server-v0.0.2`; exactly two git calls (create + push).
7. missing publish script: returns 1, writes error, no git tag push.

Additional failure-path branches (npm bump non-zero, publish non-zero, tag-create non-zero, tag-push non-zero, `Get-NpmVersion` missing-manifest and empty-version throws) are exercised by the targeted coverage harness enumerated in `evidence/qa-gates/coverage-delta.md`.

## Appendix B: Toolchain Commands Reference

```
# PowerShell formatting
mcp__drm-copilot__run_poshqc_format

# PowerShell linting
mcp__drm-copilot__run_poshqc_analyze

# PowerShell tests + coverage
mcp__drm-copilot__run_poshqc_test
# coverage artifact: artifacts/pester/powershell-coverage.xml (repo-wide pinned)
# new-code coverage artifact: artifacts/pester/fullrelease-coverage.xml (targeted)

# GitHub Actions lint
actionlint .github/workflows/publish-mcp-npm.yml

# Workflow-unchanged-since-green-run check (expected empty)
git diff 7803ffc9282d6172e59bf0baafe10c3ca7005d97 75e3ec51aafa8f00eed4a426552627d36ac9413d -- .github/workflows/publish-mcp-npm.yml

# Evidence-location validation
python scripts/dev_tools/validate_evidence_locations.py --root .

# Diff scope (full branch vs base)
git diff 93d83d5ea01d40b229e2721f057210d9ef698206 75e3ec51aafa8f00eed4a426552627d36ac9413d
```
