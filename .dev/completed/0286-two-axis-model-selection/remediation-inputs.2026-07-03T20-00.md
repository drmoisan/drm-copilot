# Remediation Inputs (S9 CI-Failure) — two-axis-model-selection (Issue #286)

- Timestamp: 2026-07-03T20-00
- Cycle: 2 (post-PR CI-failure handling per orchestrate SKILL `## Remediation Loop — CI-Failure Handling`)
- PR: #295 (https://github.com/drmoisan/drm-copilot/pull/295)
- CI run: https://github.com/drmoisan/drm-copilot/actions/runs/28685430030 (conclusion: failure)
- Head SHA under test: 51936fcbb30dcaf105d4234a31da4f2b178fa52f

Two required checks failed. Each is converted to a synthetic Blocking finding. Both are deterministic, in-scope defects introduced by this feature's runtime-file edits, and both were invisible to the local toolchain (the TS Jest suite is not runnable locally — no npm/node/node_modules; the Pester structural guard is a grep that the new documentation text collides with).

## Blocking Findings (count: 2)

### CI-1 — PowerShell QC: `context: fork` literal trips `claude-runtime-structure` guard

- Severity: Blocking.
- Failing check: `PowerShell QC` (workflow CI). Failing job: https://github.com/drmoisan/drm-copilot/actions/runs/28685430030/job/85077130701
- Test: `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1` — "requires .claude/skills/orchestrate/SKILL.md to avoid context fork and orchestrator agent routing".
- Observed: `Expected regular expression 'context:\s*fork' to not match` — the guard forbids the literal `context: fork` sequence in the orchestrate skill (it asserts the orchestrate skill is not routed via a context fork).
- Root cause: the P7 `## Model Selection` documentation added a "fork caveat" that contains the literal string `context: fork` at:
  - `.claude/skills/orchestrate/SKILL.md:86`
  - `.claude/skills/epic-orchestrate/SKILL.md:123`
  The grep-based structural test cannot distinguish descriptive prose from an actual frontmatter directive.
- Required remediation: reword the fork caveat in both SKILL.md files (and their bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/`) so the text no longer matches `context:\s*fork`, while preserving the meaning (a fork-routed skill inherits the parent model and ignores a model override). Confirm the reworded text does not reintroduce the pattern anywhere in either skill. Verify locally via the Pester suite (`mcp__drm-copilot__run_poshqc_test` over `tests/scripts/claude-runtime`).
- Closure acceptance: `claude-runtime-structure.Tests.ps1` passes; no `context:\s*fork` match in either skill (repo-root and bundled); byte-identity mirrors intact.

### CI-2 — Extension Tests (ubuntu-latest): new agents missing from pack manifest

- Severity: Blocking.
- Failing check: `drm-copilot Extension Tests (ubuntu-latest)` (workflow CI; windows-latest counterpart CANCELLED via fail-fast). Failing job: https://github.com/drmoisan/drm-copilot/actions/runs/28685430030/job/85077130692
- Test: `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` — "lists every bundled .claude agent, skill, and hook file in some pack manifest"; `expect(missing).toEqual([])` failed (2 elements present).
- Root cause: the two new bundled agents are not listed in any `extensions/drm-copilot/resources/claude-customizations/pack-manifests/*.json`:
  - `.claude/agents/commit-message.md`
  - `.claude/agents/human-exception-runbook.md`
  (The two new skills `commit-message` and `human-exception-runbook` are already present in `core.json`; only the agent files are missing. `pr-author.md` remains a documented pre-existing exception and must not be added by this change.)
- Required remediation: add `.claude/agents/commit-message.md` and `.claude/agents/human-exception-runbook.md` to the `core` pack manifest `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (the core-orchestration pack that already lists orchestrator, atomic-planner, atomic-executor, feature-review, task-researcher, prd-feature, etc.). Confirm whether any repo-root source-of-truth or a parity contract governs the pack-manifests; if so, update in lockstep. Do not add the agents to language-specific packs.
- Closure acceptance: the completeness test's `missing` set is empty for the two new agents; the pack-manifest change is consistent with any governing parity contract. (Authoritative verification is the CI Jest run on the next push, because the TS suite is not runnable in this local environment.)

## Notes

- Both fixes are additive/textual and do not alter the feature's Python logic, validators, or acceptance criteria.
- After remediation and re-commit, the branch head SHA changes; S9 must be re-run against the new head. The `remediation_pass` counter is shared with local-finding passes; cap is 3.
