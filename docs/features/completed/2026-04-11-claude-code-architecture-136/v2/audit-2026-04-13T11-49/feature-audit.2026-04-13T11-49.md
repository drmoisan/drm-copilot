# Feature Audit: Claude Code architecture v2 remediation re-review (#136)

---

**Audit Date:** 2026-04-13
**Feature Folder:** `docs/features/active/2026-04-11-claude-code-architecture-136/v2`
**Base Branch:** `origin/development`
**Head Branch:** `feature/claude-code-architecture-136` plus current working tree
**Work Mode:** `full-feature`
**Audit Type:** Post-remediation acceptance verification

---

## Scope and Baseline

- **Base branch:** `origin/development` (`14708b3b0c75ebf36b314f7c1780db1625604ecb`)
- **Head branch:** `feature/claude-code-architecture-136` (`93eea9b6effb35f0842aed0f3a221ef7133ef23f`) plus current working tree
- **Primary evidence:** `artifacts/pr_context.summary.txt`
- **Secondary diff evidence:** `artifacts/pr_context.appendix.txt`
- **Feature evidence:** `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/**`
- **Fresh commands in this review:** current `validate_json`, extension-local TypeScript format/lint/typecheck, targeted Jest and Pester runs, and live multi-folder PoshQC MCP wrapper probes
- **Requirements source:** `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`; `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`
- **Work mode source:** `docs/features/active/2026-04-11-claude-code-architecture-136/issue.md` with `- Work Mode: full-feature`
- **Scope note:** Acceptance-criteria status is unchanged unless the current review produced stronger deterministic evidence. The remaining live Claude-session criteria still require transcript-level runtime proof.

---

## Acceptance Criteria Inventory

**Primary checkbox-backed source:** `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`

1. Research sufficiency is stated explicitly.
2. The Claude architecture uses a main-thread orchestrator model.
3. `/orchestrate` can be invoked live in Claude Code.
4. `/commit-message` can be invoked live in Claude Code.
5. `/pr-author` can be invoked live in Claude Code.
6. `/research-issue` can be invoked live in Claude Code.
7. Canonical `.github/skills` mapping is documented.
8. Canonical `.github/agents` disposition is documented.
9. Direct-use `.github/prompts` mapping is documented.
10. Repository-enforceable versus managed-only controls are distinguished.
11. Live subagent allowlist enforcement is verified.
12. Live checkpoint resume behavior is verified.
13. `PreToolUse` dangerous-command blocking is verified.
14. `SubagentStop` premature termination blocking is verified.
15. The sync strategy is usable by a maintainer.
16. Non-equivalences are documented without overstating runtime enforcement.

**Supporting source:** `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`

- `Definition of Done`: 10 items, currently 9 checked and 1 unchecked.
- `Seeded Test Conditions`: 7 items, currently 2 checked and 5 unchecked.
- The current re-review does not add evidence that changes any existing checked or unchecked spec item.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Notes |
|---|-----------|--------|----------|-------|
| 1 | Research sufficiency stated explicitly | PASS | `p4-t2.architecture-doc-green.2026-04-12T15-57.md` | Unchanged PASS. |
| 2 | Main-thread orchestrator model | PASS | `p4-t1.claude-runtime-green.2026-04-12T15-57.md`; `p4-t2.architecture-doc-green.2026-04-12T15-57.md` | Unchanged PASS. |
| 3 | `/orchestrate` live invocation | UNVERIFIED | `p5-t4.live-skill-validation.2026-04-12T15-57.md` | No transcript-level Claude runtime evidence was added in this review. |
| 4 | `/commit-message` live invocation | UNVERIFIED | `p5-t4.live-skill-validation.2026-04-12T15-57.md` | Unchanged. |
| 5 | `/pr-author` live invocation | UNVERIFIED | `p5-t4.live-skill-validation.2026-04-12T15-57.md` | Unchanged. |
| 6 | `/research-issue` live invocation | UNVERIFIED | `p5-t4.live-skill-validation.2026-04-12T15-57.md` | Unchanged. |
| 7 | Canonical `.github/skills` mapping | PASS | `p4-t2.architecture-doc-green.2026-04-12T15-57.md` | Unchanged PASS. |
| 8 | Canonical `.github/agents` disposition | PASS | `p4-t2.architecture-doc-green.2026-04-12T15-57.md`; `p5-t6.disallowed-agent-validation.2026-04-12T15-57.md` | Unchanged PASS. |
| 9 | Direct-use prompt mapping to skills | PASS | `p4-t2.architecture-doc-green.2026-04-12T15-57.md` | Unchanged PASS. |
| 10 | Repository-enforceable vs managed-only controls | PASS | `p4-t2.architecture-doc-green.2026-04-12T15-57.md` | Unchanged PASS. |
| 11 | Live subagent allowlist probe | UNVERIFIED | `p5-t2.permissions-and-agent-scope-validation.2026-04-12T15-57.md`; `p5-t4.live-skill-validation.2026-04-12T15-57.md` | No new live subagent transcript. |
| 12 | Live checkpoint resume behavior | UNVERIFIED | `p5-t5.checkpoint-resume-validation.2026-04-12T15-57.md` | No new live resume transcript. |
| 13 | `PreToolUse` dangerous-command block | PASS | `p4-t3.validate-bash-green.2026-04-12T15-57.md`; `p5-t3.hook-enforcement-validation.2026-04-12T15-57.md` | Unchanged PASS. |
| 14 | `SubagentStop` premature termination block | UNVERIFIED | `p5-t3.hook-enforcement-validation.2026-04-12T15-57.md` | No new live stop-gate transcript. |
| 15 | Sync strategy usability | PASS | `p4-t2.architecture-doc-green.2026-04-12T15-57.md` | Unchanged PASS. |
| 16 | Non-equivalence documentation is accurate | PASS | `p4-t2.architecture-doc-green.2026-04-12T15-57.md` | Unchanged PASS. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Acceptance-criteria summary:**
- PASS: 9
- PARTIAL: 0
- UNVERIFIED: 7
- FAIL: 0

**Repo-controlled blocker from this re-review:**

The branch still contains a deterministic wrapper defect outside the acceptance-checkbox inventory. The approved live multi-folder PoshQC MCP wrapper path is still broken, so the branch is not review-ready even though the remaining acceptance-checkbox gaps are environment-only `UNVERIFIED` items.

**Environment-only gaps that remain and are not new code defects:**

- Live invocation of `/orchestrate`, `/commit-message`, `/pr-author`, and `/research-issue`
- Live subagent allowlist probe
- Live checkpoint resume verification
- Live `SubagentStop` verification

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:

- PASS items may be checked off only when they are represented as source-file checkboxes and the evidence is already present.
- PARTIAL, FAIL, and UNVERIFIED items must remain unchecked.

No source-file checkbox updates were made in this re-review. The current review did not change any acceptance criterion from unchecked to checked, and it did not produce transcript-level runtime evidence for the remaining live criteria.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`; `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`
- Total AC items: 33
- Checked off (delivered): 20
- Remaining (unchecked): 13
- Items remaining: `/orchestrate` live invocation; `/commit-message` live invocation; `/pr-author` live invocation; `/research-issue` live invocation; live allowlist probe; live checkpoint resume; live `SubagentStop` proof; supporting spec items for live invocation, live allowlist, live resume, and live stop-gate validation
