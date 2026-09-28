# epic-orchestrator-always-on-context-footprint (Issue #559)

- Date captured: 2026-08-25
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/epic-orchestrator-always-on-context-footprint/ (Issue #559)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #559
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/559
- Last Updated: 2026-08-26
## Summary

`.claude/agents/epic-orchestrator.md` carries approximately 33,000–35,000 tokens of always-on context before it receives a delegation prompt or reads any file. Six distinct defects cause this. Five are mechanical removals of duplicated or non-applicable content; one is a missing bounded return contract that scales with epic size. Three of the six (F1, F2, F3) also affect other agents; F3 affects every agent in the repository.

## Environment

- OS/version: Windows 11 Pro 10.0.26200 (repository-neutral; defect is in committed configuration files)
- Python version: n/a (Markdown and YAML frontmatter only)
- Command/flags used: n/a — observed by measuring injected context for an `epic-orchestrator` delegation
- Data source or fixture: `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/rules/*.md`, `CLAUDE.md`

## Steps to Reproduce

1. Launch any `Agent(epic-orchestrator)` delegation.
2. Measure the context injected before the delegation prompt: the agent file, its six preloaded skills (~936 lines), every unscoped `.claude/rules/` file (685 lines across five files), and `CLAUDE.md` with its duplicated policy bodies.
3. Observe approximately 33,000–35,000 tokens of always-on context, including content the agent is explicitly forbidden to act on and citations to a `spec.md` that does not exist.

## Expected Behavior

The epic-orchestrator surface loads only the content it needs: three preloaded skills (`policy-compliance-order`, `epic-orchestrate`, `acceptance-criteria-tracking`); rules files scoped by `paths:` frontmatter to the artifacts they govern; no startup instruction to re-read already-injected files; no dangling `spec.md §N` citations; `CLAUDE.md` pointing to rules files rather than restating (and contradicting) them; and a bounded fixed-shape return contract for child `orchestrator` delegations.

## Actual Behavior

Six defects, F1–F6:

- **F1 — Startup protocol instructs re-reading already-injected content.** `.claude/agents/epic-orchestrator.md:57-58` and `.claude/skills/epic-orchestrate/SKILL.md:26-28` both instruct reading `CLAUDE.md` and `.claude/rules/` files that are auto-injected verbatim. Fix: delete `epic-orchestrator.md:57-58` (renumber remaining Startup Protocol steps contiguously) and delete the `## Prerequisites` block at `SKILL.md:22-28` in full. Add no replacement text. Acceptance: neither file instructs reading `CLAUDE.md` or `.claude/rules/`.
- **F2 — Four preloaded skills the agent is explicitly forbidden to act on.** `epic-orchestrator.md:19-25` preloads six skills (~936 lines); `atomic-plan-contract` (204), `feature-promotion-lifecycle` (121), and `evidence-and-timestamp-conventions` (176) serve delegations the agent's own Delegation Model forbids it to make. Fix: reduce `skills:` to exactly `policy-compliance-order`, `epic-orchestrate`, `acceptance-criteria-tracking`. If any prose depends on a removed preload, convert it to an explicit `Skill` invocation at the point of use rather than restoring the preload.
- **F3 — Five rules files lack `paths:` frontmatter and load into every agent.** `parallel-orchestration.md` (390 lines), `plan-acceptance-gates.md`, `orchestrator-state.md`, `ci-workflows.md`, `benchmark-baselines.md` — 685 lines total, loaded unconditionally repo-wide. Fix: add `paths:` and `description:` frontmatter to each, scoped to the artifacts each actually governs; verify suggested globs against each file's own stated scope section before applying. Suggested scopes: parallel-orchestration → `artifacts/orchestration/parallel-*`, `docs/features/parallel/**`, `scripts/dev_tools/*parallel*`, `extensions/drm-copilot/src/lib/validate/parallel-*`; orchestrator-state → `artifacts/orchestration/*orchestrator-state.json`, `scripts/dev_tools/*orchestrator_state*`; plan-acceptance-gates → `scripts/dev_tools/plan_gate_*`, `extensions/drm-copilot/src/lib/validate/plan-gate-*`, `docs/features/**/plan.*.md`; ci-workflows → `.github/workflows/**`; benchmark-baselines → `scripts/benchmarks/**`, `**/baseline*.json`. Acceptance: all fifteen rules files carry `paths:` and `description:`; only the four deliberate `"**"` rules (`general-code-change.md`, `general-unit-test.md`, `quality-tiers.md`, `tonality.md`) load unconditionally; confirm `orchestrator-state.md` still reaches the orchestrator surfaces that write those checkpoints.
- **F4 — Dangling `spec.md §N` citations.** `epic-orchestrator.md:107` (§4, §10), `epic-orchestrator.md:136` (§6), `epic-orchestrate/SKILL.md:268` (§6) cite a `spec.md` that does not exist anywhere under `docs/`. Fix: remove all three; at line 136 re-point the schema authority at `validate_epic_orchestrator_state_text`; at line 107 and `SKILL.md:268` resolve to the corresponding section of `.claude/skills/epic-orchestrate/SKILL.md`. Acceptance: no occurrence of `spec.md §` remains; every remaining cross-reference resolves to an existing path.
- **F5 — `CLAUDE.md` contradicts the rules files, and both are loaded.** Coverage floor: `CLAUDE.md:303` states >= 80% while `general-unit-test.md:23` and `quality-tiers.md:33` state >= 85% (different denominators, not just different numbers — the 80% figure is attached to a COM/VSTO/WinForms "testable denominator" exemption). Toolchain: `CLAUDE.md` specifies a four-step loop; `general-code-change.md` specifies seven stages. Mechanical half of the fix: replace duplicated policy bodies in `CLAUDE.md` with pointers to the rules files, keeping the compliance order and the C#-specific toolchain command list. Decision half: REQUIRES A HUMAN DECISION — is the floor 80% or 85%, and is the loop four stages or seven? Do not resolve autonomously; record as a `human_interaction` requirement with `response: "halt"` and deliver everything else. No coverage threshold or toolchain stage count may be silently changed.
- **F6 — No bounded return contract for child delegations.** `epic-orchestrate/SKILL.md` launches a full wave of child `orchestrator` agents whose unconstrained prose reports return into the parent's context, which then deliberately distrusts them and re-derives state from `git worktree list --porcelain`, `git branch`, and `gh pr view --json state,mergedAt,headRefOid`. This is the only defect that scales with epic size. Fix: add a bounded return contract to `epic-orchestrate/SKILL.md` — each child returns a fixed-shape result and nothing else (at minimum `issue_num`, `feature_folder`, `merge_status`, `pr_number`, `merge_commit_sha`, `blocked_reason`); state that content beyond this shape is discarded and authoritative state is re-derived regardless; add the child-facing half of the constraint to the epic-mode kickoff line at delegation time. Confirm whether the child side needs a matching edit in `.claude/skills/orchestrate/SKILL.md` and include it if so. Acceptance: the return shape is documented, the kickoff line carries the constraint, and the re-derivation requirement is stated as the rationale.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: n/a — defects are visible in the committed files at the line numbers cited above.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Approximately 33,000–35,000 tokens of unusable or contradictory context on every epic-orchestrator delegation; F3 taxes every agent in the repository; F5's contradiction, read literally with `CLAUDE.md`'s halt-on-conflict instruction, requires a compliant agent to halt at startup; F6 grows unbounded with epic size.

## Suspected Cause / Notes

Scope: `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`, the five unscoped `.claude/rules/` files named in F3, and `CLAUDE.md`. Out of scope: the `.agents/` and `.codex/` mirrors — determine whether a push-down is required as a follow-up; do not widen this change to include it.

Planner notes: F1, F2, F4 are independent single-file edits plannable as separate atomic tasks. F3 is five sibling edits with one shared verification task (glob scoping must be checked against each rule's own scope section before writing). F5's mechanical half is blocked on nothing; its decision half is blocked on the user and must not be resolved by inference. F6 changes a delegation contract consumed by `orchestrator`; check whether `.claude/skills/orchestrate/SKILL.md` needs the matching child-side edit.

## Proposed Fix / Validation Ideas

- [ ] Every `.claude/rules/*.md` frontmatter block parses as valid YAML.
- [ ] `epic-orchestrator.md` frontmatter parses and every `skills:` entry resolves to an existing `.claude/skills/<name>/SKILL.md`.
- [ ] No cross-reference in the two epic files points at a non-existent path.
- [ ] Markdown and PowerShell gates run for the files actually changed.
- [ ] Measured before-and-after always-on line count for `epic-orchestrator` (agent file + preloaded skills + unconditionally-loaded rules + `CLAUDE.md`) recorded under the feature's canonical evidence path.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
