# canonical-evidence-locations-non-overridable (Issue #158)

- Date captured: 2026-04-25
- Author: orchestrator
- Status: Promoted -> docs/features/active/canonical-evidence-locations-non-overridable/ (Issue #158)

- Issue: #158
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/158
- Last Updated: 2026-04-25
- Work Mode: full-feature

## Problem / Why

An end-to-end orchestration cycle in a downstream repository wrote roughly 95 evidence
files to non-canonical locations (`artifacts/baselines/`, `artifacts/qa/`,
`artifacts/coverage/`). The canonical convention defined in
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md` requires all baseline, QA-gate,
regression-testing, and issue-update evidence to live under
`<FEATURE>/evidence/<kind>/`. Nothing in the agent contracts, skills, or hooks stopped
the override. The root cause is that the orchestrator's delegation prompt told the planner
to use the non-canonical paths "if the conventions skill does not exist," and the planner
accepted that override. The executor inherited it from the approved plan.

## Proposed Behavior

Remove all discretion: no orchestrator, planner, executor, or upstream prompt may override
the canonical evidence locations, ever. The fix spans:

- **Skill reconciliation** (Part A): promote `evidence-and-timestamp-conventions` to
  non-overridable status; fix QA-gate and invoke-engineer skills; add evidence-location
  authority sections to `orchestrate` and `atomic-plan-contract` skills.
- **Agent invariants** (Part B): add a `## Evidence Location Invariant` section to all
  12 agent definition files so each agent refuses and records non-canonical path overrides.
- **Hook enforcement** (Part C): implement a `PreToolUse` hook that blocks writes to
  forbidden `artifacts/` sub-paths at the tool layer, regardless of which agent issued
  the write. Add a self-test suite.
- **Validator** (Part D): add a standalone `validate_evidence_locations.py` script that
  walks the tree and exits non-zero on any forbidden-path violation; wire it into the
  `feature-review` policy-audit step.

## Acceptance Criteria

- [x] `evidence-and-timestamp-conventions/SKILL.md` contains the `## Non-Overridable Authority` section.
- [x] All QA-gate skills (`python-qa-gate`, `csharp-qa-gate`, `powershell-qa-gate`) name `<FEATURE>/evidence/<kind>/` paths and carry the canonical-authority pointer line.
- [x] All invoke-engineer skills (`invoke-python-engineer`, `invoke-csharp-engineer`, `invoke-powershell-engineer`) name `<FEATURE>/evidence/<kind>/` paths and carry the canonical-authority pointer line.
- [x] `orchestrate/SKILL.md` contains the `## Evidence Location Authority` section with the explicit allow-list for `artifacts/`-rooted paths.
- [x] `atomic-plan-contract/SKILL.md` contains the non-overridable clause for plan tasks.
- [x] All 12 agent definition files contain the `## Evidence Location Invariant` section.
- [x] `feature-review.md` additionally contains the diff-scan FAIL-finding requirement.
- [x] The PreToolUse hook is registered, runs on Write and Edit, blocks the forbidden patterns, allows the explicit exceptions, and prints the block message format.
- [x] The hook self-test script passes all five cases listed in the spec.
- [x] The standalone validator script exists, walks the tree, exits non-zero on a seeded violation, and is referenced from the feature-review policy-audit step.
- [x] A demonstration run: with the hook installed, a deliberate attempt to `Write` to `artifacts/baselines/test.md` is blocked at the tool layer and the agent re-issues the write under the canonical path.
- [x] All four toolchain steps (format, lint, type-check, test) pass after the changes.

## Constraints & Risks

- Must not change the canonical path scheme itself (`<FEATURE>/evidence/<kind>/` is the answer).
- Must not migrate historical non-canonical evidence from other branches or repos.
- Must not change `artifacts/orchestration/`, `artifacts/research/`, or feature-audit report paths.
- Hook script must require no external dependencies beyond the language runtime on PATH.

## Test Conditions to Consider

- [x] Hook self-test: blocked path exits 1 with correct stderr message.
- [x] Hook self-test: allowed orchestration path exits 0.
- [x] Hook self-test: allowed research path exits 0.
- [x] Hook self-test: canonical evidence path exits 0.
- [x] Hook self-test: regular source-code path exits 0.
- [x] Validator: clean tree exits 0; seeded violation exits 1 with canonical replacement printed.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/` folder from the template