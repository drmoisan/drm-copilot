# quota-throttling-skill (Issue #679)

- Date captured: 2026-09-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/quota-throttling-skill/ (Issue #679)

- Issue: #679
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/679
- Last Updated: 2026-09-17
- Work Mode: minor-audit

## Problem / Why

Multi-agent orchestration runs repeatedly exhausted account quota in ways that stranded
uncommitted work: simultaneous Phase 0 cycles drained a full five-hour window in 62 minutes, a
fallback account was assumed fresh while its weekly limit was spent, and a concurrency-cap change
was used to control burn from agents that were already running. The pacing, switching, and
commit-before-the-wall practices learned from about five days of TaskMaster runs
(`bugs-2026-09-11`, `bugs-2026-09-17`) exist only in session history. No bundled skill carries
them, so every consumer repository has to rediscover them.

## Proposed Behavior

Add a Claude skill, `quota-throttling`, that states the quota throttling and account-switching
policy: account viability (weekly gate dominates), a pacing target that depends on whether a
failover account exists, the measured cost model, subtree-scoped concurrency control, measurement
discipline, the commit-before-the-wall sequence, total-weekly-exhaustion handling, switching
rules, the no-credits rule, the reserve policy, monitor design, observed failure modes, and the
coordinator/agent division of labour.

Bundle the skill in the drm-copilot extension resources so the MCP push-down
(`push_down_claude_customizations`) distributes it to consumer repositories.

## Acceptance Criteria (early draft)

- [ ] `.claude/skills/quota-throttling/SKILL.md` exists with valid skill frontmatter.
- [ ] The bundled copy under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/quota-throttling/SKILL.md` is byte-identical to the repository copy.
- [ ] The skill path is listed in `pack-manifests/core.json`, and the pack-manifest completeness test passes.

## Constraints & Risks

- Documentation-only change; no production code or hook behavior changes.
- Cost figures are machine- and repository-specific and must be labelled as measured or estimated.

## Test Conditions to Consider

- [ ] Jest pack-manifest completeness and push-down suites.
- [ ] Bundle-parity checks between `.claude/` and the extension resources.

## Next Step

- [x] Promote to GitHub issue
