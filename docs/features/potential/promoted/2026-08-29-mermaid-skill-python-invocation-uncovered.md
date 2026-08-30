# mermaid-skill-python-invocation-uncovered (Issue #601)

- Date captured: 2026-08-29
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/mermaid-skill-python-invocation-uncovered/ (Issue #601)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #601
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/601
- Last Updated: 2026-08-30
## Summary

`.claude/skills/mermaid-diagram/SKILL.md:28` invokes a Python toolchain call that is not covered by the epic `claude-runtime-portability` (issues #596-599), which addressed the other four executable Python invocations under `.claude/`.

## Environment

- OS/version: N/A (runtime-surface documentation defect, not a runtime failure)
- Python version: N/A
- Command/flags used: N/A
- Data source or fixture: N/A

## Steps to Reproduce

1. Grep `.claude/skills/mermaid-diagram/SKILL.md` for a Python invocation at line 28.
2. Compare against the four sites already fixed by the `claude-runtime-portability` epic: `epic-orchestrate/SKILL.md`, `parallel-orchestrate/SKILL.md`, `parallel-plan/SKILL.md` (2 sites).
3. Observe this fifth site was out of scope for that epic and remains untouched.

## Expected Behavior

Every executable Python invocation under `.claude/` should route to an existing PowerShell/bash port, consistent with the fix applied to the other four sites, so consumer repos lacking a Python toolchain (e.g. TaskMaster, C#/PowerShell-only) can run it.

## Actual Behavior

The mermaid-diagram skill still assumes a working Python toolchain at this call site. It was identified during `/epic-plan` preparation for `claude-runtime-portability` but deliberately left out of that epic's scope to avoid re-triggering preflight on an already-cleared feature.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: N/A — identified via static grep during epic planning, not a runtime error report.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

Same root cause as the `claude-runtime-portability` epic (issues #596-599): skills authored assuming `poetry run python -m scripts.dev_tools.*` works everywhere, but consumer repos without a Python toolchain (TaskMaster) cannot run it. Fix direction should follow the pattern used in that epic's Feature D (issue #599): route to the existing PowerShell/bash port instead of the Python call, if a suitable port exists; otherwise the port needs to be written first.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: confirm the replacement invocation path is covered wherever `mermaid-diagram` skill behavior is tested.
- [ ] Integration scenario to retest: run `/mermaid-diagram` end-to-end in a repo without a Python toolchain.
- [ ] Manual verification notes: confirm no other consumer of this skill relies on the specific Python call being replaced.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
