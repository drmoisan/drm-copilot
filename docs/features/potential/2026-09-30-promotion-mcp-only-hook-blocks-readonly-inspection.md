# promotion-mcp-only-hook-blocks-readonly-inspection (Potential)

- Date captured: 2026-09-30
- Author: Dan Moisan
- Status: Draft
- Origin: follow-up recorded by issue #509 (epic #771); hook changes were excluded from that epic

## Problem / Why

`.claude/hooks/enforce-promotion-mcp-only.ps1` blocks read-only inspection commands because it matches the promotion tool names (for example `potential_to_issue`) anywhere in a shell command's text, including search patterns, file contents passed as data, and checkpoint payloads. Read-only greps over the #509 code and checkpoints are therefore refused.

## Proposed Behavior

Restrict the hook to commands that actually invoke a promotion operation, so read-only inspection (search, listing, viewing) that merely mentions a tool name is permitted. The hook must remain PowerShell-only (no Python leg).

## Acceptance Criteria (early draft)

- [ ] A read-only `grep` whose pattern names a promotion tool is allowed.
- [ ] A command that invokes a promotion script or CLI is still denied.
- [ ] Pester tests cover both cases.

## Constraints & Risks

Enforcement hook; a narrower matcher must not open a bypass for real promotion invocations.

## Test Conditions to Consider

- [ ] Pester allow/deny cases for read-only inspection and invocation forms.

## Next Step

- [ ] Promote to GitHub issue
