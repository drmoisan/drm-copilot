# Bug: subagentstop-validators-read-undocumented-envelope (E1: core helper and inline command)

- Issue: #897
- URL: https://github.com/drmoisan/drm-copilot/issues/897
- Epic: subagentstop-envelope (epic issue #904), child E1, wave 0, complexity band C4
- Integration branch: epic/subagentstop-envelope-integration
- Feature branch: bug/subagentstop-envelope-core-897
- Work Mode: full-bug
- Source: populated from `gh issue view 897` on 2026-10-11. The issue was adopted, not created; the folder tool produced no issue.md and no potential entry was moved or consumed.
- Work-mode note: the GitHub issue body carries `Work Mode: minor-audit`. This child is prepared in `full-bug` mode because the epic assigns band C4, the change spans a new shared helper, `.claude/settings.json`, a new hook script, tests, and bundled mirrors (more than the 1-3 file small-path budget), and the contract it defines is consumed by E2, E3 and E4. `spec.md` is the acceptance-criteria source.
- Delivery note: #897 is delivered jointly by E1, E2 and E3. Child pull requests use `Refs #897` and do not use a closing keyword.

## E1 Scope (from the epic Shared Design)

1. Measure what a real SubagentStop hook receives on stdin versus the `CLAUDE_HOOK_INPUT` environment variable, which fields are present, and whether exit 1 versus exit 2 blocks.
2. Add the shared helper `.claude/hooks/subagentstop-envelope.ps1` with `Read-SubagentStopEnvelope` and `Exit-SubagentStopBlock -Message <text>`.
3. Fix the inline SubagentStop command at `.claude/settings.json:218`, after stating per matched agent whether its completion-token pattern is correct.
4. Pester tests, bundled mirrors under `extensions/drm-copilot/resources/`, and mirror-parity tests. The nine validators are converted by E2, E3 and E4, not by E1.

## Original Issue Body (verbatim from GitHub)

## Summary
The eight `SubagentStop` validators read `$env:CLAUDE_HOOK_INPUT` and take an `output` property off the parsed root. The documented `SubagentStop` envelope arrives on stdin and exposes `last_assistant_message`, not `output`, and the documented hook environment does not include `CLAUDE_HOOK_INPUT`. These validators are therefore very likely inert for the same two reasons #501 established for the `PreToolUse` surface: wrong transport beneath wrong shape.

This entry was raised by the #501 investigation and deliberately scoped out of that fix, whose acceptance criterion AC-13 asserts these files are absent from its diff. It is recorded separately so the boundary stays honest and the defect is not lost.

## Environment
- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a - validators are PowerShell; PowerShell 7.6.5
- Command/flags used: `pwsh -NoProfile -File .claude/hooks/validate-orchestrator-output.ps1` with the payload supplied on each transport
- Data source or fixture: `.claude/settings.json` `SubagentStop` registrations at commit `c76a2990`

## Steps to Reproduce
1. Pick any of the eight validators, for example `.claude/hooks/validate-orchestrator-output.ps1`.
2. Invoke it with the documented envelope supplied on stdin, whose root carries `hook_event_name` set to the SubagentStop event and `last_assistant_message` set to text lacking any required completion-artifact path.
3. Invoke it again with the shape the code parses: the `CLAUDE_HOOK_INPUT` environment variable set to a root object carrying `output`.
4. Compare the two decisions.
5. Search the hook directory for the access pattern to enumerate every validator reading `output` off the parsed root.

## Expected Behavior
Step 2 must block. A subagent that stops without the required completion-artifact path should be refused, and steps 2 and 3 should agree because they describe the same event.

## Actual Behavior
Expected, not yet measured: step 2 passes because the property resolves to null and the validator takes its nothing-to-inspect path, while step 3 blocks correctly. The claim is inference from the verified `PreToolUse` result plus the documented envelope, not an observed run. Confirming it is the first task of this fix.

An additional defect is likely present and should be checked at the same time: the inline `SubagentStop` command registered in `.claude/settings.json` uses `Write-Error` followed by `exit 1`. Per the documented semantics, exit 1 is non-blocking; only exit 2 blocks. That command would therefore fail open even with the correct transport and shape.

Affected validators:

`validate-discovery-artifact-gate.ps1`, `validate-executor-output.ps1`, `validate-feature-review-coverage.ps1`, `validate-orchestrator-output.ps1`, `validate-planner-output.ps1`, `validate-pr-author-output.ps1`, `validate-required-artifact-output.ps1`, `validate-task-researcher-output.ps1`.

Two of these - `validate-discovery-artifact-gate.Tests.ps1` and `validate-pr-author-output.Tests.ps1` - also carry the `$LASTEXITCODE | Should -Be 1` assertion that #501 inverted for the `PreToolUse` suites, so their exit-code contract needs the same review.

**Update 2026-10-11 (main at 2ef8d361):**

- The defect is still present on main. Each validator below reads `$env:CLAUDE_HOOK_INPUT`, parses `.output`, and blocks with `exit 1` (all in `.claude/hooks/`):

| File | Reads `.output` at line | Passes `$env:CLAUDE_HOOK_INPUT` at line | `exit 1` at line |
|---|---|---|---|
| `validate-discovery-artifact-gate.ps1` | 224 | 258 | 261 |
| `validate-executor-output.ps1` | 198 | 290 | 293 |
| `validate-feature-review-coverage.ps1` | 367 | 471 | 474 |
| `validate-orchestrator-output.ps1` | 362 | 460 | 463 |
| `validate-planner-output.ps1` | 369 | 410 | 413 |
| `validate-pr-author-output.ps1` | 109 | 135 | 139 |
| `validate-required-artifact-output.ps1` | 114 | 163 | 159 and 168 |
| `validate-task-researcher-output.ps1` | 246 | 288 | 291 |
| `validate-prd-feature-output.ps1` | 80 | 95 | 96 |

- A ninth validator not in the original list is affected: `validate-prd-feature-output.ps1`, registered in `.claude/agents/prd-feature.md:20`.
- The inline command at `.claude/settings.json:218` is unchanged: it reads `$env:CLAUDE_HOOK_INPUT`, takes `$input.output`, and ends with `Write-Error '...'; exit 1`.
- PR #881 (#786) established the rule "For SubagentStop, blocking means exit code 2. A `Write-Error` followed by `exit 1` does not block." It reported that "Two handlers in `validate-orchestrator-output.ps1` (H7 #787, H8 #840) were proven fail-open and converted to the uniform helper-based block", and deferred the rest: "Exit-1 SubagentStop block paths in the other validators remain out of scope (NG1). They are tracked in the potential entry dated 2026-08-21."
- PR #856 (#787 and #840) recorded: "SubagentStop stdin/exit-2 envelope is out of scope. The Layer 2 port is therefore proven by tests only; whether the block reaches the agent at runtime depends on that separate defect."
- The two #881 conversions are runtime evidence that exit-1 blocks in this validator family fail open. The stdin-versus-environment transport claim remains unmeasured by a differential run.

## Impact / Severity
High. These validators are completion gates rather than pre-execution gates, so an inert validator does not permit a dangerous action; it permits an agent to report completion without the artifact that proves it. `validate-orchestrator-output.ps1` is the gate that refuses a DONE lacking model-routing receipts or carrying an unresolved human-interaction requirement. While it is inert, an orchestrator's completion claim is self-attested.

## Source
From: docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md (left in place; not moved or consumed by this child)
