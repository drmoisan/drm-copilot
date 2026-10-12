# Bug: subagentstop-envelope-orchestrator-family

- Issue: #903 (https://github.com/drmoisan/drm-copilot/issues/903)
- Related issues: #897 (partial delivery), epic #904
- Work Mode: full-bug
- Epic: subagentstop-envelope (child E2, wave 1 in manifest numbering, complexity band C3)
- Integration branch: epic/subagentstop-envelope-integration
- Branch: bug/subagentstop-envelope-orchestrator-family-903
- Upstream dependency: E1 (#897, folder hint subagentstop-envelope-core-897, branch bug/subagentstop-envelope-core-897)
- Source: populated from `gh issue view 903` and `gh issue view 897` on 2026-10-11 because `new_active_feature_folder` produced no issue.md. No potential entry was moved, consumed, or deleted.
- Pull request linkage: `Refs #903` and `Refs #897`; no closing keywords.

## Summary

Issue #903 collects accepted non-blocking review notes from round-2 items. Issue #897 records that the SubagentStop validators read `$env:CLAUDE_HOOK_INPUT`, take `output` off the parsed root, and block with `exit 1`, while the documented SubagentStop envelope arrives as JSON on stdin with `last_assistant_message`, and only exit code 2 blocks. PR #881 (#786) established that `Write-Error` followed by `exit 1` does not block in this family.

This child (E2) converts the orchestrator, executor, planner, and required-artifact validators to the shared E1 helper and resolves the #903 notes that fall in those same files.

## Scope (from #897, the E2 slice)

All paths under `.claude/hooks/` on main at 2ef8d361 (line numbers from the #897 update of 2026-10-11; re-derive before use):

| File | Reads `.output` at line | Passes `$env:CLAUDE_HOOK_INPUT` at line | `exit 1` at line |
|---|---|---|---|
| `validate-executor-output.ps1` | 198 | 290 | 293 |
| `validate-orchestrator-output.ps1` | 362 | 460 | 463 |
| `validate-planner-output.ps1` | 369 | 410 | 413 |
| `validate-required-artifact-output.ps1` | 114 | 163 | 159 and 168 |

Plus `validate-orchestrator-output-resolution.ps1`, the Pester suites under `tests/scripts/claude-hooks/`, the bundled mirrors under `extensions/drm-copilot/resources/`, and any `.claude/agents/*.md` frontmatter registration that passes arguments to these hooks.

## Scope (from #903, same-file notes only)

- #787 `docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787/code-review.2026-10-09T00-12.md`:
  - CR-1 (Minor): `-ccontains` case mismatch at `validate-orchestrator-output-resolution.ps1:150-162`.
  - CR-3 (Minor): unguarded resolver exception at `validate-orchestrator-output.ps1:476-480` (re-derive current lines).
  - CR-7 (Info): stale "One subprocess call" comment, at line 431 when verified.
- #786 `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/code-review.2026-10-10T22-23.md`:
  - Double `OrchestratorState.psm1` import at `validate-orchestrator-output.ps1:51,59`.
  - FailClosed test nits: overly broad `SilentlyContinue`, always-true conditional in the H4-H6 catch blocks, `finally` resetting variables that no longer exist (`FailClosed.Tests.ps1:453,468`).

## Non-Goals

- Validators owned by sibling children: E3 owns `validate-discovery-artifact-gate`, `validate-pr-author-output`, `validate-prd-feature-output`, `validate-task-researcher-output`; E4 owns `validate-feature-review-coverage` and the feature-review thresholds and skills.
- The E1 helper itself and the inline SubagentStop command in `.claude/settings.json`.
- All other #903 notes, including the evidence-filename timestamp defect.
- PreToolUse hooks.

## Constraints

- Enforcement hooks gain no Python legs. Any Python invocation found in these validators is reported and removed.
- No production file exceeds 500 lines; `validate-orchestrator-output.ps1` (466 lines at epic authoring) requires a planned split.
- Line coverage >= 85% for every changed PowerShell file.
- Bundled mirrors stay byte-identical to their sources.

## Impact / Severity

High (from #897). These validators are completion gates; while inert, an agent can report completion without the artifact that proves it. `validate-orchestrator-output.ps1` is the gate that refuses a DONE lacking model-routing receipts.

## Acceptance Criteria

The authoritative acceptance criteria for this full-bug item are in `spec.md`.
