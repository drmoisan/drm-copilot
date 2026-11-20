# Policy Compliance Audit: bump-and-publish-task (Issue #191)

**Audit Date:** 2026-06-17
**Feature Folder:** `docs/features/active/2026-06-16-bump-and-publish-task-191`
**Base Branch:** `main`
**Merge-base SHA:** `93d83d5ea01d40b229e2721f057210d9ef698206`
**Head SHA:** `62e7f291c69d4debce2aca82115c7907af7df295`
**Work Mode:** `minor-audit`
**Code Under Test (full branch diff vs base):**
- `scripts/dev-tools/Invoke-FullRelease.ps1` (added, +230)
- `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` (added, +162)
- `.github/workflows/publish-mcp-npm.yml` (modified, +4/-1)
- `.vscode/tasks.json` (modified, +30)
- Feature documentation and evidence artifacts under `docs/features/active/2026-06-16-bump-and-publish-task-191/` (added)

> Template note: the MCP server tool `mcp__drm-copilot__resolve_policy_audit_template_asset` is not exposed in this review environment. This artifact follows the canonical section structure defined in `.claude/skills/policy-audit-template-usage/SKILL.md`. The MCP-resolved asset remains the authoritative template source; this is a structural fallback only.

## Coverage Metrics by Language

| Language | Files Changed | Tests | Test Result | Repo-wide (pinned) Coverage | New-code Coverage | Verdict |
|----------|---------------|-------|-------------|------------------------------|-------------------|---------|
| PowerShell | 1 production (`Invoke-FullRelease.ps1`), 1 test | 7 new Pester tests (608 repo-wide) | PASS (608 pass, 0 fail, EXIT 0) | 96.83% line (275/284), unchanged from baseline | 88.0% line (44/50); BRANCH counter not emitted | PARTIAL — line PASS; branch UNVERIFIABLE from tooling output |
| GitHub Actions (YAML) | 1 (`publish-mcp-npm.yml`) | N/A (actionlint static) | PASS (actionlint EXIT 0, 0 findings) | N/A | N/A | PASS (static) — but see modified-workflow-needs-green-run |
| JSON/JSONC | 1 (`.vscode/tasks.json`) | N/A (schema validate) | PASS (tasks-json-validate EXIT 0) | N/A | N/A | PASS (structural) |
| Markdown | 14 (docs + evidence) | N/A | N/A | N/A | N/A | N/A (no executable code) |

## Executive Summary

The current feature state is **PARTIAL / NOT ready for merge**. The PowerShell production script, its Pester suite, the workflow provenance change, and the VS Code task are present and pass their respective static and unit gates as recorded in the feature evidence package and re-verified against the branch diff.

Two findings prevent a PASS verdict:

1. **BLOCKING — `modified-workflow-needs-green-run`.** The branch diff modifies `.github/workflows/publish-mcp-npm.yml` (a path matching `.github/workflows/**`). The feature-review-workflow policy rule requires evidence of a green workflow run whose head SHA matches the current branch head (`62e7f29...`) before a CI-gate-modifying change can merge. No such evidence exists in the feature folder. The branch head is not pushed to any remote (`git branch -r --contains 62e7f29` returns empty), so no qualifying PR-context or `workflow_dispatch` run against the head can be present. This is a Blocking finding and is routed to remediation inputs.

2. **PARTIAL — branch coverage unverifiable for new PowerShell code.** New-code line coverage for `Invoke-FullRelease.ps1` is 88.0% (>= 85% threshold, PASS). The Pester/CoverageGutters output format does not emit a BRANCH counter (confirmed: 0 BRANCH counters in `artifacts/pester/fullrelease-coverage.xml` and in `artifacts/pester/powershell-coverage.xml`). The uniform >= 75% branch-coverage threshold therefore cannot be numerically verified from the produced artifacts. The coverage-delta evidence argues by enumeration that all decision branches of `Invoke-FullReleaseGuarded` are exercised by the 7 tests; that argument is plausible but is not a measured branch metric. Recorded as PARTIAL.

**Policy documents evaluated:**
- `.github/copilot-instructions.md` (tone)
- `.claude/rules/general-code-change.md`
- `.claude/rules/general-unit-test.md`
- `.claude/rules/powershell.md`
- `.claude/rules/ci-workflows.md`
- `.claude/rules/quality-tiers.md`
- `.github/instructions/github-actions.instructions.md`

## Rejected Scope Narrowing

No caller instruction attempted to narrow the audit scope to a plan, task, phase, or file subset. The audit covers the full branch diff vs `main` (`93d83d5..62e7f29`). The caller note identifying the workflow modification was treated as a scope reminder, not a narrowing, and the full diff was audited. No verbatim narrowing text to record.

## Evidence Location Compliance

The branch diff was scanned for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. None of this branch's added or modified files reside under those non-canonical paths. All feature evidence for issue #191 is correctly placed under `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/<kind>/`.

`scripts/dev_tools/validate_evidence_locations.py --root .` reports violations under `artifacts/evidence/baseline/2026-04-18T*`, `artifacts/evidence/post-change/2026-04-18T*`, and `artifacts/evidence/*/2026-04-25T18-15`. These files are dated April 2026 and are **not** part of this branch's diff (`git diff --name-only 93d83d5 62e7f29` returns no path under `artifacts/{baselines,qa,evidence,coverage}/`). The validator exits 0. These are pre-existing repository artifacts outside the scope of issue #191 and are not attributed as FAIL findings for this feature. They are noted here for traceability; remediation of pre-existing artifacts is out of scope for this review.

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | Pester `It` blocks set up mocks in `BeforeEach`; no shared mutable state across tests; repo-wide run passes in any order (EXIT 0). |
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
| New-code branch coverage >= 75% | PARTIAL/UNVERIFIED | No BRANCH counter emitted by the tooling (0 BRANCH counters in coverage XML). Threshold cannot be measured. See Executive Summary finding 2. |
| Positive flows | PASS | Confirmed run (`yes`) success path returns 0 with bump+publish+tag-create+tag-push. |
| Negative flows | PASS | `no`, `YES`, `Yes` rejected with code 2; missing publish script returns 1. |
| Edge cases | PASS | Case-sensitivity of the confirmation token (`-cne 'yes'`) is explicitly tested. |
| Error handling | PASS | Missing publish script reported via `Write-StderrLine`, not silently ignored. |
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
| No temporary files | PASS | Coverage note states the temporary dot-source harness was removed; production test uses AST `Import-ScriptFunction`. |

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
| ShouldProcess for state-changing actions | OBSERVATION | The script performs state-changing actions (npm version bump, git tag create/push, Marketplace publish) but gates them behind a mandatory `-ConfirmToken 'yes'` rather than `SupportsShouldProcess`. `.claude/rules/powershell.md` recommends ShouldProcess; the explicit confirmation-token design is an intentional, tested equivalent that also satisfies the immutability-confirmation requirement. Recorded as a non-blocking observation (see code review). |
| Change budget (<= 2 production PS files) | PASS | One production PowerShell file changed. |

## 4. Language-Specific Unit Test Policy Compliance (PowerShell)

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pester v5.x, `Describe`/`Context`/`It` | PASS | Structure conforms; one behavior per `It`. |
| Mirror code structure | PASS | `tests/scripts/dev-tools/...`. |
| Mock external executables via wrapper seam | PASS | Mocks target `Invoke-GitExe`/`Invoke-NpmExe`/`Invoke-PublishScript`, never raw `git`/`npm`. |
| Mock signature parity | PASS | Mock `param` blocks match production named parameters (`[string[]]$GitArgs`, `[string[]]$NpmArgs`, `[string]$ScriptPath`). |
| Line coverage >= 85% | PASS | 88.0% on new file. |
| Branch coverage >= 75% | PARTIAL/UNVERIFIED | No branch metric emitted; see finding 2. |
| No coverage regression on changed lines | PASS | New file; pinned repo-wide coverage unchanged. |

## 5. Test Coverage Detail

- Repo-wide pinned scope (`pester.runsettings.psd1`): 96.83% line (275/284). The pinned scope targets five hook files and does not include `scripts/dev-tools/`; this is pre-existing repository policy and is not modified by this feature.
- New file `scripts/dev-tools/Invoke-FullRelease.ps1`: targeted run `artifacts/pester/fullrelease-coverage.xml` reports 44/50 lines (88.0%), 52/59 instructions (88.14%).
- Uncovered lines (6): the dot-source-guard entry-point block (lines 227-229, intentionally skipped so functions can be imported for test) and the single-statement bodies of two mocked wrapper seams (`Write-StderrLine` line 52; `Invoke-PublishScript` lines 102-103). These are consistent with the wrapper-seam mocking policy.
- Branch coverage: not emitted by the Pester/CoverageGutters output format for either baseline or post-change. The >= 75% threshold cannot be numerically verified.

## 6. Test Execution Metrics

| Metric | Value | Source |
|--------|-------|--------|
| Repo-wide Pester tests | 608 (601 baseline + 7 new) | `evidence/qa-gates/poshqc-test.md` |
| Failures / errors | 0 / 0 | EXIT 0 |
| New suite tests | 7 | `Invoke-FullRelease.Tests.ps1` |
| actionlint findings | 0 (EXIT 0) | `evidence/qa-gates/actionlint.md` |
| tasks.json schema validation | PASS (EXIT 0) | `evidence/qa-gates/tasks-json-validate.md` |

## 7. Code Quality Checks

| Check | Command | Result |
|-------|---------|--------|
| PowerShell format | `mcp__drm-copilot__run_poshqc_format` | PASS (EXIT 0) |
| PowerShell lint | `mcp__drm-copilot__run_poshqc_analyze` | PASS (EXIT 0) |
| PowerShell tests + coverage | `mcp__drm-copilot__run_poshqc_test` | PASS (EXIT 0) |
| GitHub Actions lint | `actionlint .github/workflows/publish-mcp-npm.yml` | PASS (EXIT 0) |
| JSONC schema | tasks.json validate | PASS (EXIT 0) |

Note: results above are read from the feature evidence package produced during execution; this review verifies the recorded artifacts rather than re-running coverage generation, per the coverage-verification model. The branch diff content (script, test, workflow, tasks.json) was re-read and matches the evidence claims.

### 7.1 ci-workflows.md exit-code handling

The modified workflow contains no `pwsh` step with a deliberately-failing nested command. `.claude/rules/ci-workflows.md` has no applicable construct to remediate. PASS (no applicable construct).

## 8. Gaps and Exceptions

1. **BLOCKING:** `modified-workflow-needs-green-run` — no green workflow run against head `62e7f29...` for the modified `.github/workflows/publish-mcp-npm.yml`. Routed to `remediation-inputs.2026-06-17T00-18.md`.
2. **PARTIAL:** New-code branch coverage cannot be numerically verified; the tooling emits no BRANCH counter. The coverage-delta evidence argues all branches are exercised, but no measured metric supports the >= 75% threshold.
3. **OBSERVATION (non-blocking):** State-changing actions are gated by `-ConfirmToken` rather than `SupportsShouldProcess`; intentional design, documented and tested.

## 9. Summary of Changes

A combined release wrapper `Invoke-FullRelease.ps1` and a VS Code task were added to release the extension and the MCP server together: patch-bump the mcp-server manifest, publish the extension via the existing Marketplace script (which bumps the extension manifest), then create and push a `mcp-server-v<version>` tag to trigger the npm publish workflow. The npm publish workflow was amended to publish with `--provenance` and `id-token: write`. The action is gated behind a `yes`/`no` confirmation input. Pester tests cover the guard, bump arguments, tag derivation, and the missing-publish-script path.

## 10. Compliance Verdict

**Overall verdict: PARTIAL — NOT ready for merge.**

- Code-change and unit-test policy: PASS.
- PowerShell language policy: PASS (ShouldProcess noted as observation).
- Coverage: line PASS (88.0%); branch UNVERIFIED (no metric emitted) — recorded PARTIAL.
- `modified-workflow-needs-green-run`: FAIL (BLOCKING) — no green head-SHA run for the modified workflow.

Remediation is required. See `remediation-inputs.2026-06-17T00-18.md`.

## Appendix A: Test Inventory

`tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` (7 tests):
1. confirmation guard: `no` returns 2; no bump/publish/tag invoked.
2. confirmation guard: `YES` rejected with 2 (case-sensitive).
3. confirmation guard: `Yes` rejected with 2 (case-sensitive).
4. mcp-server bump: expected npm wrapper args (`version`, `patch`, `--no-git-tag-version`, prefix path) and derived version `0.0.2`.
5. tag derivation: `Get-McpServerTagName 0.0.2` -> `mcp-server-v0.0.2` (pure function).
6. tag push: git wrapper called with derived `mcp-server-v0.0.2`; exactly two git calls (create + push).
7. missing publish script: returns 1, writes error, no git tag push.

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

# Evidence-location validation
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .

# Diff scope (full branch vs base)
git diff 93d83d5ea01d40b229e2721f057210d9ef698206 62e7f291c69d4debce2aca82115c7907af7df295
```
