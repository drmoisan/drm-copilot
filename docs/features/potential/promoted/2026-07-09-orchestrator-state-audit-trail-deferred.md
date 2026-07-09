# orchestrator-state-audit-trail-deferred (Issue #337)

- Date captured: 2026-07-09
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/orchestrator-state-audit-trail-deferred/ (Issue #337)

- Issue: #337
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/337
- Last Updated: 2026-07-09
## Problem / Why

The orchestration-enforcement-hardening feature (issue #253) diagnosed six enforcement gaps in `artifacts/orchestration/orchestrator-state.json` handling. Five (Gaps 1-5) plus a routing-matrix agent-name reconciliation were closed by that feature. Gap 6 — a checkpoint-transition audit trail — was explicitly deferred as "diagnostic rather than preventive" and marked out of scope for that feature's Definition of Done, and has not been separately tracked since. Without it, when a monotonic-checkpoint hook blocks a transition, there is no append-only forensic record of the sequence of prior checkpoint states that led to the block, which slows down diagnosing why an orchestration run got stuck.

## Proposed Behavior

Add an append-only audit-trail file, `artifacts/orchestration/orchestrator-state.log.jsonl`, that records each checkpoint transition (for example: `next_step` change, `step*_status` change, delegation receipt append) as one JSON line, capped at 100 entries (oldest entries pruned first). The monotonic-checkpoint hook should be able to read this log to provide forensic context when it blocks a transition.

## Acceptance Criteria (early draft)

- [ ] `artifacts/orchestration/orchestrator-state.log.jsonl` is created/appended on each recorded checkpoint transition.
- [ ] The log is capped at 100 entries; oldest entries are pruned first once the cap is exceeded.
- [ ] The monotonic-checkpoint hook (or an equivalent enforcement hook) can read the log and surface recent transition history when it blocks a checkpoint update.
- [ ] Existing checkpoints without a log file remain valid (the feature is additive, matching the backward-compatibility pattern used for other `orchestrator-state.json` extensions).

## Constraints & Risks

- Must not become a second source of truth that can diverge from `orchestrator-state.json` itself; the log is diagnostic only, not authoritative state.
- Must not introduce unbounded file growth (hence the 100-entry cap).
- Low priority per the original feature's own classification (diagnostic rather than preventive); should not block other in-flight orchestration work.

## Test Conditions to Consider

- [ ] Unit coverage areas: log-append logic, 100-entry pruning behavior, JSONL line-format validity.
- [ ] Integration scenarios: a blocked checkpoint transition surfaces the relevant recent log entries; a checkpoint with no existing log file still validates and operates correctly.
- [ ] CLI/API examples: N/A (internal orchestration artifact, no external CLI/API surface).

## Source Citations

- `docs/research/20260626-orchestration-enforcement-hardening-research.md:509-513` ("Gap 6 - Audit Trail (Low Priority, Deferred)").
- `docs/features/completed/2026-06-26-orchestration-enforcement-hardening-253/user-story.md:57`, `spec.md:25,67,96`, `issue.md:27`, `plan.2026-06-26T15-50.md:17` — consistent statements that Gap 6 is deferred/out of scope.
- Confirmed still outstanding via `docs/research/2026-07-09-remaining-technical-debt-audit.md`: no `orchestrator-state.log.jsonl` file or audit-trail logic exists in `.claude/hooks/` or `scripts/dev_tools/`, and no open GitHub issue tracks Gap 6 specifically.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/orchestrator-state-audit-trail-deferred/` folder from the template

