# caller-site-invocation-correctness (Issue #597)

- Date captured: 2026-08-29
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/caller-site-invocation-correctness/ (Issue #597)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #597
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/597
- Last Updated: 2026-08-29
## Summary

Three `Import-Module` call sites under `.claude/**` use a relative module path, an ambient
PowerShell host assumption, no `-ErrorAction Stop`, and an unguarded `if ($result)` truthiness
read against `Test-BlastRadiusConflict`'s return value. Each of these defects makes the invocation
unreliable on a destination runtime that only guarantees `pwsh`, not an ambient `powershell.exe`
host with a permissive execution policy.

## Environment

- OS/version: Windows and Linux destination runtimes receiving the `.claude/**` push-down payload.
- Python version: N/A (PowerShell-only defect).
- Command/flags used: `Import-Module .claude/lib/blast-radius/BlastRadius.psm1 -Force` as written
  at the three sites below.
- Data source or fixture: N/A.

## Steps to Reproduce

1. Open `.claude/skills/parallel-plan/SKILL.md:185`, `.claude/skills/parallel-add/SKILL.md:64`, and
   `.claude/agents/parallel-planner.md:151`.
2. Observe each instructs `Import-Module .claude/lib/blast-radius/BlastRadius.psm1 -Force` with a
   relative path, no `pwsh` host qualifier, no `-ErrorAction Stop`, and no corrected
   `$result['conflict']` read pattern.
3. Run the instructed invocation from a working directory other than the repository root, or under
   the Windows PowerShell 5.1 default execution policy.

## Expected Behavior

Each call site should invoke `pwsh` explicitly (the default PowerShell 5.1 execution policy blocks
`Import-Module` of a `.psm1` file, so `pwsh` is mandatory), use a root-anchored module path so the
import does not depend on the caller's current working directory, pass `-ErrorAction Stop` so a
missing or broken module fails fast rather than silently, and read the conflict verdict from
`$result['conflict']` per the existing warning at
`.claude/lib/blast-radius/BlastRadius.psm1:432-441` and the sibling warning at
`.claude/skills/parallel-plan/SKILL.md:310-314`.

## Actual Behavior

All three sites use a relative path (`Import-Module .claude/lib/blast-radius/BlastRadius.psm1
-Force`) with no `pwsh` qualifier, no `-ErrorAction Stop`, and no documented execution-policy trap.
A relative-path import resolves against the caller's current working directory rather than the
repository root, so the same instruction text fails differently depending on where it is invoked
from; the missing `-ErrorAction Stop` lets a broken import continue silently; the missing `pwsh`
qualifier omits the fact that Windows PowerShell 5.1's default execution policy blocks
`Import-Module` of a `.psm1`.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: N/A — this is a documentation/instruction-text defect, not a runtime stack trace.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

Part of the `claude-runtime-portability` epic (`docs/features/epics/claude-runtime-portability/epic.md`),
Feature C (issue placeholder 903, wave 1). Depends on Feature A (issue placeholder 901, wave 0,
`blast-radius-powershell-calling-convention`), which establishes the fail-fast import convention for
`.claude/lib/**` modules that these three call sites must consume. Every edit to a `.claude/**` file
must be mirrored byte-identically into
`extensions/drm-copilot/resources/claude-customizations/.claude/**`, per
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
(lines 101-126), so each of the three corrections requires a mirrored edit, six files total. Out of
scope: `.claude/skills/parallel-plan/SKILL.md:317` (the `parallel_lane_assertion` Python invocation,
owned by Feature D/wave 2, which depends on this feature specifically because both edit this file),
and `.claude/skills/parallel-orchestrate/SKILL.md` / `.claude/skills/epic-orchestrate/SKILL.md` in
their entirety.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: N/A for production code (prose-only instruction-text correction); verify
      via a literal-token search for the corrected invocation pattern at each of the three sites and
      their bundle mirrors, plus the existing `BlastRadius.Conflict.Tests.ps1` / bundle-parity test
      suite remaining green.
- [x] Integration scenario to retest: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
- [ ] Manual verification notes: N/A.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
