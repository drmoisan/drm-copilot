# orchestrator-remediation-loop-control (Potential Bug)

- Date captured: 2026-09-29
- Author: Dan Moisan
- Status: Draft
- GitHub issue: #484 (pre-existing; authored from the issue body because the potential file the issue cites, `docs/features/potential/2026-08-17-orchestrator-remediation-loop-control.md`, does not exist in the repository)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Work Mode: full-bug

## Summary

The orchestration state machine treats every non-PASS review as actionable remediation, including external runtime incompatibilities and unavailable coverage metrics. This causes unnecessary remediation plans, commits, re-reviews, inconsistent cycle numbering, and cycle consumption when no corrective candidate was applied.

## Environment

- OS/version: Windows 11 / PowerShell workspace
- Python version: 3.13.12 through Poetry
- Node/npm version: Node 24.14.0 / npm 11.9.0
- Command/flags used: Codex `orchestrate` workflow with authoritative MCP orchestration validation
- Data source or fixture: issue #467 checkpoint, review artifacts, published `@danmoisan/drm-copilot-mcp@1.0.24`, and repository-local validators

## Steps to Reproduce

1. Run a feature review that returns a blocker which cannot be changed by repository remediation, such as an immutable MCP runtime mismatch or unavailable source-attributable coverage metric.
2. Observe that the reviewer can return only `PASS` or `REMEDIATION_REQUIRED` and that the orchestrator unconditionally enters R1-R5 for `REMEDIATION_REQUIRED`.
3. Let remediation execution return an external/runtime failure with no candidate applied and the checkpoint restored byte-for-byte.
4. Observe that the outer workflow still stages evidence, commits, re-reviews, increments the pass counter, and consumes a remediation cycle.
5. Compare repository-local and published MCP routing inventories when a new Codex agent family was added after the package version was published.

## Expected Behavior

The reviewer classifies whether a blocking condition is autonomously remediable. External runtime mismatches, policy decisions, awaiting-CI states, and human-decision requirements halt or wait without creating a remediation plan or consuming a remediation cycle. Cycle accounting counts completed remediation attempts consistently, and runtime capability/version incompatibility is detected before execution.

## Actual Behavior

The binary review contract forced every blocker into remediation. The pass counter alternated between current and completed semantics, an unexecuted pass occupied a number, and pass 7 was consumed after `PRE_R5_STATUS: ACTIVE_RUNTIME_INCOMPATIBILITY` with `candidate_applied: false`. The published MCP 1.0.24 validator rejected valid repository `commit-steward` routing receipts, while an unrelated legacy routing gate also generated missing-receipt diagnostics.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: issue #467 records seven audit rounds, six completed remediation re-reviews, eight execution/resume delegations, one unexecuted numbered pass, and no pass 8. The final candidate passed the repository validator but could not change the immutable published MCP resolver.

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

## Acceptance Criteria

- [x] AC-1: The review verdict classifies every blocking finding as either autonomously remediable or as one of the non-remediable classes: external runtime incompatibility, policy decision, awaiting-CI state, or human-decision requirement.
- [x] AC-2: A review whose blocking findings are all non-remediable halts or waits without creating a remediation plan and without consuming a remediation cycle.
- [x] AC-3: Remediation-cycle accounting counts completed remediation attempts only; an unexecuted pass, or a pass that ends with no corrective candidate applied, does not occupy a cycle number.
- [x] AC-4: The Python, PowerShell, and TypeScript orchestrator-state validators accept and enforce the new verdict and cycle-accounting fields identically.
- [x] AC-5: Checkpoints and review artifacts that do not use the new fields validate byte-identically to the current behavior.
- [x] AC-6: Runtime capability or version incompatibility (for example a published MCP inventory that lags the repository) is detected before execution, or is recorded as a scoped follow-up when it exceeds this feature's budget.

## Suspected Cause / Notes

The review contract in `.agents/skills/` and `.claude/skills/orchestrate/SKILL.md` (`## Post-Review Outcome Evaluation`, `## Remediation Loop (R1–R5)`) defines only a binary outcome and increments `remediation_pass` unconditionally at R5.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: verdict-class validation and cycle-accounting invariants in all three validator runtimes, with shared parity fixtures.
- [ ] Integration scenario to retest: a checkpoint recording a non-remediable halt validates without a remediation cycle entry.
- [ ] Manual verification notes: none.

## Next Step

- [x] Promote to GitHub issue (bug-report template) — issue #484 already exists; not re-promoted.
- [ ] Move to active fix folder / branch
