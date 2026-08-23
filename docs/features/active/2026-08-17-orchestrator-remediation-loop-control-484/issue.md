# orchestrator-remediation-loop-control (Issue #484)

- Date captured: 2026-08-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/orchestrator-remediation-loop-control/ (Issue #484)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #484
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/484
- Last Updated: 2026-08-17
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

## Suspected Cause / Notes

- Review output combines delivery verdict and remediation action into one binary field.
- The remediation loop lacks a terminal pre-R4 transition when no delta is applied.
- Canonical `remediation_loop.cycles[]` accounting is optional and bypassed by ad hoc fields.
- The legacy `require_model_routing` gate is incorrectly applied to Codex-native checkpoints.
- Published MCP bundle capability is not compared with repository routing policy before remediation.
- Codex receipt validation runs twice under strict mode, duplicating diagnostics.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas
  - Review outcome/actionability matrix and remediation artifact requirements
  - Canonical remediation-cycle schema, transitions, count arithmetic, and blocker fingerprints
  - Pre-R4 no-candidate/runtime-incompatibility halt behavior
  - Legacy-versus-Codex routing gate separation and unique diagnostics
  - Human exception binding and one-time consumption
- [x] Integration scenario to retest
  - Python, TypeScript, and MCP validator parity on shared checkpoint fixtures
  - Source routing catalog versus built MCP bundle capability digest
  - Full orchestrator flow where an external blocker produces no remediation plan or cycle consumption
- [x] Manual verification notes
  - Publishing and pinning a new MCP package must occur only after the package is built, tested, and published; the branch must not pin an unpublished version.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
