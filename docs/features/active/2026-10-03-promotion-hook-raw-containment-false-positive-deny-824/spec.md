# promotion-hook-raw-containment-false-positive-deny (Spec)

- **Issue:** #824
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-03T08-09
- **Status:** Draft
- **Version:** 0.1

## Context
`.claude/hooks/enforce-promotion-mcp-only.ps1` denies read-only wrapped `pwsh` commands whose raw text merely contains the letters "gh", "issue" and "new" anywhere. The raw-containment fallback in `.claude/hooks/hook-command-invocation.ps1` is documented as loose, on the basis that a false positive only forces a checkpoint check. The promotion hook turns that loose match into an unconditional deny with no checkpoint check and no escape path.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a (PowerShell hooks)
- Command/flags used: Bash tool command routed through the PreToolUse hook
- Data source or fixture: main at 93725814

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Send this read-only Bash command, which invokes no `gh`, through the PreToolUse hook:
   `pwsh -NoProfile -Command '$parts = New-Object System.Collections.Generic.List[string]; foreach ($t in @("a phrase that runs through the text", "The call is guarded (issue #1)")) { Write-Output $t }'`
2. Observe the hook decision.

Expected:
Allow. Only an actual `gh issue create|new` invocation, or a genuinely unresolvable segment, is denied.

Actual:
Deny with PROMOTION_MCP_ONLY_BLOCKED (gh issue creation reason).

The hook calls `Test-CommandLineInvocation -CommandWord 'gh' -SubcommandPath @('issue','create'|'new')`. For any wrapper-led segment (for example `pwsh -NoProfile -Command '...'`) or segment containing a live substitution, `Resolve-CommandLineInvocation` falls back to `Test-CommandLineRawContainment`. That fallback uses ordinal, case-insensitive substring containment of each word anywhere in the raw text and ignores word boundaries, order and adjacency. "gh" matches inside through/high/length, "issue" matches inside a string, and "new" matches `New-Object`, `::new()` or newline.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: `PROMOTION_MCP_ONLY_BLOCKED`


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
- An atomic plan's read-only phrase-count verification command was blocked twice in one plan. Each time, execution halted and needed a maintainer-approved one-time bypass. Plans may not reword commands to avoid a hook, so no workaround is permitted.
- Other hooks that call `Test-CommandLineInvocation` / `Resolve-CommandLineInvocation` with an unconditional deny on the containment path likely share the defect: the commit/add/remove scanners and the gh pr create scanners.


## Proposed Fix

### Design summary (what changes where):

### Boundaries and invariants to preserve:

### Dependencies or blocked work:

### Implementation strategy (what changes, not sequencing):
	
#### Files/modules to change:

#### Functions/classes/CLI commands impacted:

#### Data flow and validation changes:

#### Error handling and logging updates:

#### Rollback/feature-flag considerations (if applicable):

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

#### Required configuration keys and defaults:

#### Backward-compatibility expectations:

#### Performance constraints (latency/throughput/memory):

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
- Constraints (budget, performance, compatibility):
- External dependencies (services, libraries, releases):

## Data / API / Config Impact
- User-facing or API changes:
- Data or migration considerations:
- Logging/telemetry updates (if any):
- Compatibility notes (CLI flags, config schemas, versioning):

## Test Strategy
Seeded from issue:

Required change:

1. Do not deny on raw containment alone in the promotion hook. For wrapper-led and substitution segments, require token-aware evidence of an actual invocation in the raw text, including the text inside a `-Command` / `-c` argument. For example: `(?i)(?<![\w-])gh\s+issue\s+(?:create|new)\b`.
2. Keep fail-closed behavior for genuinely unresolvable cases: an Unbalanced segment, or an obfuscated invocation the token-aware pattern cannot rule out. If loose containment must remain as a last resort, route it to the checkpoint check its comment describes, not to an unconditional deny.
3. Audit the other hooks that hard-block on the containment path (commit/add/remove scanners, gh pr create scanners) and apply the same correction wherever a non-structural match produces a hard block.
4. Do not weaken detection of real bypasses.

Acceptance criteria:

- [ ] The reproduction command above is allowed.
- [ ] Still denied: `gh issue create ...`; `gh issue new ...`; `GH  Issue  Create` (case and spacing variants); `pwsh -NoProfile -Command 'gh issue create --title x'`; `pwsh -c "& gh issue new"`; `bash -c "gh issue create"`; a `gh api repos/o/r/issues -X POST` call.
- [ ] A wrapped payload containing "through", "issue" and "New-Object", but no `gh issue create|new` token sequence, is allowed.
- [ ] Pester tests cover every case above, including a negative control that fails if the substring-containment deny path is restored.
- [ ] `Test-CommandLineRawContainment`'s documented contract ("a false positive only forces a checkpoint check") matches what its callers do, or the comment is corrected.
- [ ] The PowerShell toolchain passes: format, analyze, then test with coverage.

- Regression tests to add or update:
- Unit tests (pytest) for the fixed behavior and boundaries:
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
- Error handling and logging verification:
- Coverage impact and targets for changed lines/modules:
- Toolchain commands to run (format → lint → type-check → test):
- Manual validation steps (if required):


## Acceptance Criteria
- [ ] Repro steps now produce the expected behavior in all documented environments.
- [ ] Regression test(s) added and passing (list file path and test name).
- [ ] Edge cases and invalid inputs are handled with correct errors or fallbacks.
- [ ] No unintended behavior changes outside the defined scope.
- [ ] Required logs/telemetry updated and validated (if applicable).
- [ ] Performance constraints met or explicitly waived with rationale.
- [ ] Full toolchain pass completed (format → lint → type-check → test).
- [ ] Docs/config references updated to match the new behavior.

## Risks & Mitigations
- Technical or operational risks:
- Mitigations and rollbacks:

## Rollout & Follow-up
- Release/rollout steps:
- Post-fix monitoring or clean-up tasks:
- Links: issue, PRs, related docs
