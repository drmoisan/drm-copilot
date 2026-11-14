# 2026-11-14-owner-directive-pass-down-fails-on-non-ascii-text (Spec)

- **Issue:** #1187
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-14T13-12
- **Status:** Draft
- **Version:** 0.1

## Context
On Windows the owner-directive pass-down PreToolUse hook (`.claude/hooks/enforce-owner-directive-pass-down.ps1`, issue #1157) cannot match a recorded directive whose `text` contains a non-ASCII character such as an em dash. It therefore denies every worker or orchestrator delegation for that item with `OWNER_DIRECTIVE_RELAY_REQUIRED`, even when the brief relays the directive verbatim. The #1158 run could proceed only by re-recording the directive with an ASCII hyphen and a recomputed hash, which changes the owner's words.

Environment:
- OS/version: Windows 11, Claude Code runtime, PowerShell 7
- Python version: not applicable
- Command/flags used: `Agent(<worker>)` delegation whose prompt carries a fenced `Owner directives:` block relaying a directive that contains U+2014
- Data source or fixture: reported by the #1158 run (PR #1184 body, ORCH-D5)

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Record an owner directive whose text contains an em dash (U+2014) in an item checkpoint, with `text_sha256` over the UTF-8 bytes.
2. Delegate a worker from that item with the directive relayed verbatim in the `Owner directives:` block.
3. Observe the delegation denied as if the directive were not relayed.

Expected:
A directive relayed byte-for-byte is recognised whatever characters it contains; the hook compares text and hashes over UTF-8 consistently on every platform.

Actual:
The delegation is denied on Windows. Recording only ASCII text works around it, but owner directives are recorded verbatim, so the workaround alters the record.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: see PR #1184, `## Decisions` (ORCH-D5) and `## Follow-ups`.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
Likely an encoding mismatch on Windows: the hook payload, the checkpoint read, or the hash input is decoded or re-encoded with a non-UTF-8 code page (for example the console default), so the relayed text or its SHA-256 differs from the stored value. Check `[Console]::InputEncoding`, `Get-Content` without `-Encoding utf8`, and any string-to-bytes conversion in the hook and `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1`. The stop-hook coverage check and the ledger validation may share the defect.


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

- [ ] Read stdin and files as UTF-8 explicitly and hash UTF-8 bytes in every owner-directive path
- [ ] Pester rows with em dash, curly quotes and a non-BMP character in directive text (relay accepted; altered text still denied)
- [ ] Verify the stop-hook pass-down check and the ledger validator on the same inputs

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
