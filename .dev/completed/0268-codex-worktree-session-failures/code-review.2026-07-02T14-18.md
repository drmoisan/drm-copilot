# Code Review: codex-worktree-session-failures (#268)

**Review Date:** 2026-07-02
**Reviewer:** Codex feature-review workflow
**Feature Folder:** `docs/features/active/2026-07-02-codex-worktree-session-failures-268`
**Feature Folder Selection Rule:** User-supplied active feature folder; corroborated by PR context scoping docs.
**Base Branch:** `main` / `origin/main` at `51867789325248793a241886033c3ce86681f9ad`
**Head Branch:** `bug/codex-worktree-session-failures-268` at `8126e749e5270c5bca37e1bf03581e04f631ff81`
**Review Type:** Initial feature review

## Executive Summary

The branch fixes Codex worktree session startup behavior by correcting trust-command PowerShell syntax, adding Codex executable preflight resolution, resolving post-Codex script execution from the source repository root, and adding repository-specific `.codex` and `.agents` copy planning in the configured PowerShell script. The TypeScript design is focused and covered by targeted Jest tests. The PowerShell script design has one blocking correctness gap.

Direct reviewer verification showed the script fails when the copy plan is empty, which occurs for same-root execution and when optional source customization folders are missing. Those scenarios are explicitly part of the first-run-safe and missing-source no-op behavior described by the spec. The existing Pester tests cover the planning function but do not execute the script body path that binds the empty array to `Invoke-CodexCustomizationCopyPlan`.

**What changed:**
The extension now resolves Codex before terminal creation, invokes Codex through a quoted PowerShell call operator, resolves the post-Codex script from the source root, and passes `-SourceRoot` and `-WorktreeRoot`. The bundled post-Codex script now calculates `.codex` and `.agents` copy operations and copies matching files without deleting unrelated destination content.

**Top 3 risks:**
1. The post-Codex script fails instead of no-oping when copy operations are empty.
2. The missing full-script no-op test allowed the defect to pass the recorded Pester gate.
3. The evidence-location validator reports a non-canonical research artifact path.

**PR readiness recommendation:** **Needs Revision** - remediation is required for the PowerShell script no-op path and evidence-location compliance.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.codex/scripts/post-codex-worktree-session.ps1` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/post-codex-worktree-session.ps1` | Lines 126-129 | The script fails when `Get-CodexCustomizationCopyPlan` returns no operations because an empty array is passed to mandatory `[object[]]$CopyOperation`. | Allow empty copy-operation input or guard the `Invoke-CodexCustomizationCopyPlan` call when `$copyOperations.Count -eq 0`; update both root and bundled copies and preserve parity. | The spec requires same-root no-op behavior and missing `.codex` or `.agents` source folders to be non-fatal no-ops. The current script body fails before completing those paths. | Direct commands failed with `Cannot bind argument to parameter 'CopyOperation' because it is an empty array.` |
| Major | `tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1` | File-level | Pester coverage tests only the copy-plan function for no-op scenarios and does not execute the full script body or `Invoke-CodexCustomizationCopyPlan` with an empty plan. | Add Pester tests that import or execute the full empty-plan path and assert it completes without error for same-root and missing-source-folder inputs. | The recorded Pester gate passed despite the script failing in required no-op scenarios, so coverage is incomplete for the acceptance boundary. | `pass-after-post-codex-script.2026-07-02T13-13.md` reports 835 tests passing; direct reviewer execution still failed. |
| Major | `artifacts/research/2026-07-02T13-17-codex-worktree-session-failures-268-research.md` | Workspace path | Evidence-location validation reports the research artifact path as non-canonical. | Move or mirror the research artifact to `docs/features/active/2026-07-02-codex-worktree-session-failures-268/research/` or another validator-approved path, update references, and rerun `python scripts\dev_tools\validate_evidence_locations.py --root .`. | The feature-review contract requires `validate_evidence_locations.py --root .`; a non-zero result is a FAIL-level policy finding. | Validator output: `VIOLATION: artifacts\research\2026-07-02T13-17-codex-worktree-session-failures-268-research.md`. |

## Implementation Audit

### TypeScript implementation audit

#### What changed well

- The command builder now receives a resolved Codex executable path rather than emitting a bare `codex` command.
- `newCodexWorktreeSession` resolves Codex before terminal creation, which avoids creating a terminal that later fails with a shell-level missing-command error.
- The post-Codex script path is resolved from the source root before building terminal commands, which preserves the generic extension boundary.

#### Type safety and maintainability

- The new `codexExecutablePath` input is typed as a required string in `CodexWorktreeSessionCommandInput`.
- `resolveCodexExecutable` has a narrow string input/output contract and explicit failure behavior.
- No new broad `any` usage or suppression pattern was observed in the reviewed diff.

#### Error handling and logging

- Missing Codex executable behavior now fails before terminal creation with the configured message.
- Missing PowerShell runtime behavior remains unchanged.
- The command-handler logging continues to avoid logging objective text.

### PowerShell implementation audit

#### What changed well

- The script uses `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'`.
- Copy planning is separated from copy execution and supports injected filesystem scriptblocks for tests.
- The plan preserves deterministic `.codex` before `.agents` ordering.

#### API and safety notes

- `Get-CodexCustomizationCopyPlan` is structured for no-op planning, but the script body does not handle the empty-result case safely.
- `Invoke-CodexCustomizationCopyPlan` requires a mandatory non-empty array, which is too strict for the planned no-op contract.

#### Error handling and logging

- Real copy errors propagate, which is appropriate.
- Empty-copy no-op paths currently propagate a parameter-binding error, which is not appropriate for the documented behavior.

## Test Quality Audit

The TypeScript tests are targeted and verify command formatting, Codex executable resolution, command-handler preflight behavior, and post-Codex source-root invocation. PowerShell tests verify copy-plan behavior but miss full-script no-op execution. This is a material test gap because it allowed a required no-op scenario to fail while the Pester gate remained green.

### Reviewed test and QA artifacts

- `docs/features/active/2026-07-02-codex-worktree-session-failures-268/evidence/regression-testing/pass-after-codex-worktree-builder.2026-07-02T13-13.md` - Verifies builder regressions pass.
- `docs/features/active/2026-07-02-codex-worktree-session-failures-268/evidence/regression-testing/pass-after-codex-command-handler.2026-07-02T13-13.md` - Verifies command-handler regressions pass.
- `docs/features/active/2026-07-02-codex-worktree-session-failures-268/evidence/regression-testing/pass-after-post-codex-script.2026-07-02T13-13.md` - Verifies Pester suite passes, but not the full empty-copy script path.
- `docs/features/active/2026-07-02-codex-worktree-session-failures-268/evidence/qa-gates/final-qa-sequence-verification.2026-07-02T13-13.md` - Records final QA ordering and recency as PASS.

### Quality assessment prompts

- **Determinism:** TypeScript tests use mocked VS Code APIs and fake timers; PowerShell tests use injected scriptblocks.
- **Isolation:** Most tests isolate single behaviors; PowerShell full-script no-op behavior is not isolated in tests.
- **Speed:** Recorded final test suites completed successfully within normal unit-test boundaries.
- **Diagnostics:** Jest failures would identify generated command mismatches; Pester no-op script execution should be added for clearer diagnostics.

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection found no secret material. |
| No unsafe subprocess or command construction | PASS | Codex command uses PowerShell call operator with quoted resolved executable path. |
| Input validation at boundaries | PARTIAL | Codex executable preflight is explicit; PowerShell empty copy-operation input is not handled. |
| Error handling remains explicit | PARTIAL | Missing runtime errors are explicit; required no-op script path fails with a binding error. |
| Configuration / path handling is safe | PASS | `postCodexScriptPath` source-root resolution and `codexExecutablePath` documentation are aligned. |

## Research Log

No new external research was required for this review. The review relied on the canonical PR context artifacts, feature folder documents, recorded QA evidence, coverage artifacts, diff inspection, `validate_evidence_locations.py`, and direct local PowerShell script execution.

## Verdict

Needs revision. The TypeScript portion is acceptable based on reviewed evidence, but the PowerShell post-Codex script has a blocking no-op failure and the workspace has a validator-reported evidence-location policy violation. Remediation should address both issues and rerun the relevant PowerShell, TypeScript, evidence-location, and artifact-validation gates.
