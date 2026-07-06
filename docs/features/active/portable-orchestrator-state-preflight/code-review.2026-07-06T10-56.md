# Code Review — portable-orchestrator-state-preflight

- **Issue:** none
- **Reviewed range:** `75eac1a..12f259a`
- **Base:** `75eac1a2b03307ca2e4235fa85f18074d298c65d`
- **Head:** `12f259a4896ef667dbfd80dddb86677301780dc5`
- **Timestamp:** 2026-07-06T10-56

## Executive Summary

The change is a focused, well-documented portability refactor. Two new PowerShell modules mirror the pushed-down-relevant subset of the authoritative Python validator, and both hooks gain a capability-detection seam that preserves the injectable `$Invoker`, the fail-closed contract, and the exact block-reason strings. Docstrings are thorough and cite the exact Python reference symbols; constants are pinned to and match the Python source byte-for-byte. Coverage is complete for the new modules (100% line) and above threshold for the modified hooks.

Two findings warrant action. One is Blocking: `enforce-pr-author-skill.ps1` now exceeds the 500-line file limit (553 lines; pre-existing 508, worsened +45). The remaining findings are Low/Medium quality and parity observations that align with the approved spec. Extracting the duplicated capability-probe into the portable lib module resolves the duplication and materially reduces the file-size overage in one step.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocking | `.claude/hooks/enforce-pr-author-skill.ps1` | whole file | File is 553 lines, exceeding the 500-line hard limit in `general-code-change.md`. Baseline was 508 (already over); this change added net +45 lines. | Reduce below 500. Extract the shared capability probe (and, if needed, the preflight helper block) into `.claude/lib/orchestrator-state/OrchestratorState.psm1` or a small shared lib module that ships in `core.json`. | The file-size limit is a hard cross-language rule for production scripts; the change worsened an existing violation. | `wc -l` = 553; `git show 75eac1a:...` = 508; numstat `50 5`. |
| Low | `.claude/hooks/enforce-pr-author-skill.ps1` & `.claude/hooks/validate-orchestrator-output.ps1` | `Test-PythonOrchestratorValidatorAvailable` | The capability-detection probe (~28 lines incl. doc comment) is duplicated verbatim in both hooks. | Extract to the portable lib module and import it, or accept the duplication only if hook self-containment is a hard push-down constraint (document that rationale). | `general-code-change.md` prefers reuse over copy-paste; also reduces the Blocking file-size overage. | Identical function bodies in both hook diffs. |
| Medium | `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1` | `Test-OrchestratorStateCompletionReadiness` | The portable completion gate performs base-presence + model-routing existence checks only; it does not reproduce the Python `--require-complete` deep completion/CI/phase/per-receipt checks. In consumer repos the completion gate is therefore weaker than the drm-copilot Python path. | No code change required — this is an approved Non-Goal. Keep the in-module documentation that states the presence-level scope so operators understand consumer-repo enforcement depth. | Fail-closed is preserved for the checks performed, and the divergence is explicitly scoped by `spec.md` (Option A). | `spec.md` Non-Goals; module `.DESCRIPTION` lines 13–24. |
| Low | `artifacts/pester/powershell-coverage.xml` (config: `pester.runsettings.psd1`) | `CodeCoverage.Path` | The two new modules are listed in the coverage path but did not appear in the canonical `powershell-coverage.xml` from the inspected run; their coverage is proven only by the scoped `orchestrator-state-coverage.xml`. | Ensure the next full PoshQC test run emits the two new modules into the canonical coverage artifact so a single artifact carries the full denominator. | `general-unit-test.md` requires no production file be excluded from coverage measurement; the runsettings change is correct but the canonical artifact should reflect it. | Canonical XML packages list contains no `.claude/lib` entry; scoped XML shows both modules at 100%. |
| Info | evidence `*.md` | header timestamps | Committed evidence markdown records a run timestamp (`2026-07-06T14-03`) later than the commit time (`10:47`), a provenance inconsistency in the text. | Align evidence timestamps with actual run time in future runs. | Numeric conclusions were independently re-verified from `artifacts/pester/*`, so the finding is informational only. | Evidence headers vs `git show 12f259a` author date. |

## Positive Observations

- Fail-closed is implemented consistently: missing file, empty content, invalid JSON, non-object root, missing required keys, invalid step status, invalid `blocked_reason`, not-ready readiness, and unreceipted delegated agents all yield `ExitCode = 1` with a non-empty message.
- Constants are pinned to and match the Python source exactly (`REQUIRED_STATE_KEYS`, `STEP_STATUS_KEYS`, `VALID_STEP_STATUS`, `VALID_BLOCKED_REASONS`, `PR_CREATION_READY_STEP_KEYS`, `PR_CREATION_READY_EMPTY_LIST_KEYS`, `_DELEGATING_AGENTS`). Error strings match the Python reference verbatim, preserving downstream string-token routing.
- `Set-StrictMode -Version Latest` with a strict-mode-safe field accessor (`Get-OrchestratorStateField`) that distinguishes an absent key from a null value, matching Python `dict.get` semantics.
- The import guard (`if (-not (Get-Command ... -ErrorAction SilentlyContinue))`) prevents module reload from resetting a test-injected mock — a deliberate, correct testability affordance.
- Docstrings meet the repository documentation standard: purpose, parameters, outputs, fail-closed contract, and the exact Python reference each function mirrors.
