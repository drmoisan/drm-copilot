# 2026-10-11-concurrent-children-share-scratchpad-file-names

- Work Mode: minor-audit
## Problem / Why

Concurrent child orchestrations in one session share a single session scratchpad. Their plans write helper scripts and outputs there under fixed names such as `SCRATCH/run-ps.sh`, `SCRATCH/changed-line-coverage.ps1`, `SCRATCH/cov-final.txt`, and `SCRATCH/region-probe.ps1`. Children running in parallel can therefore overwrite each other's scratch files.

Observed evidence:

- The #787 executor found unrelated files with the same names as its Appendix H scripts already present in the shared scratchpad and moved to a private subdirectory (`docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787/evidence/other/scratch-smoke.2026-10-08T22-36.md:8`).
- The #850 executor also resolved `SCRATCH` to a private subdirectory, `x850`.
- The scratchpad directory supplied to a worktree-isolated subagent is keyed to the coordinating session's ID, not to the worktree or the child. Worktree-isolated children of one session therefore resolve to the same scratchpad. This was observed in one session and was not tested across several concurrent children.

Severity: Medium. A child can run another child's helper script, or read another child's coverage output and record it as its own evidence. This has not been observed to change a result, but no current check would detect it if it did.

Cause: the scratchpad is session-scoped, not agent-scoped. No normative persona, skill, template, rule, or prompt in the repository mentions `SCRATCH`, the scratchpad, or the fixed helper names. The convention exists only in historical plans. It was first defined in `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/plan.2026-09-29T22-17.md:94` and later plans copied it. Because each plan defines `SCRATCH` as the bare scratchpad root, it never adds a per-item prefix.

## Implementation Intent

Add a normative rule to the personas that write and run plans: every scratch or helper file lives in a directory unique to the child, derived from the canonical issue number the child already receives.

Rule semantics, from the research's Proposed Rule Semantics:

- `SCRATCH` resolves to `<session scratchpad>/issue-<issue-num>/`, where `<issue-num>` is the plan's canonical issue number. No plan directs a scratch file to the scratchpad root or uses a fixed shared name outside `SCRATCH`.
- Every scratch file, helper script, staged copy, and coverage report a plan names lives under `SCRATCH`. Subdirectories such as `SCRATCH/stage/` are permitted.
- Artifacts record the literal token `SCRATCH`, never a host path.
- Executors handle plans written before the rule as follows. The executor creates the child-unique directory before the first scratch write. When a plan defines `SCRATCH` as the bare scratchpad, the executor treats it as `<session scratchpad>/issue-<issue-num>/`.
- If two runs for the same issue ever execute at once, a run-unique suffix `issue-<issue-num>-<yyyy-MM-ddTHH-mm>` is the extension point.

Files to edit:

1. `.claude/agents/atomic-planner.md`: add the rule as a new `## Requirements` item or a `## Scratch Location` section placed before `## Preflight Validation`.
2. `.claude/agents/atomic-executor.md`: add a `## Scratch Location` section after `## Toolchain Commands`, including how to handle plans written before the rule.
3. `.agents/skills/atomic-planner/SKILL.md`: add the planner rule for Codex parity.
4. `.agents/skills/atomic-executor/SKILL.md`: add the executor rule for Codex parity.
5. Byte-identical bundled copies of items 1 through 4:
   - `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md`
   - `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md`
   - `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-planner/SKILL.md`
   - `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-executor/SKILL.md`

File to create:

6. `tests/scripts/dev_tools/test_scratch_location_contracts.py`: a pytest contract test that pins the rule in the four primary sources listed in items 1 through 4.

Child-prompt templates do not change. Children derive the directory from the canonical issue number they already carry. Adding a prompt line would break the closed five-element kickoff contract enforced by `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py`.

## Acceptance Criteria

- [x] `.claude/agents/atomic-planner.md` contains a normative rule, placed before `## Preflight Validation`, stating that `SCRATCH` resolves to `<session scratchpad>/issue-<issue-num>/` (where `<issue-num>` is the plan's canonical issue number), that every scratch file, helper script, staged copy, and coverage report a plan names lives under `SCRATCH`, and that no plan directs a scratch file to the scratchpad root or to a fixed shared name.
- [x] `.claude/agents/atomic-executor.md` contains a `## Scratch Location` section, placed after `## Toolchain Commands` and before `## Evidence Location Invariant`, stating the same `<session scratchpad>/issue-<issue-num>/` rule, requiring the executor to create that directory before the first scratch write, and requiring the executor to treat a pre-rule plan's bare-scratchpad `SCRATCH` definition as `<session scratchpad>/issue-<issue-num>/`.
- [x] `.agents/skills/atomic-planner/SKILL.md` and `.agents/skills/atomic-executor/SKILL.md` each contain the corresponding planner or executor rule using the literal `issue-<issue-num>` subdirectory token.
- [x] The new rule text in all four edited sources requires artifacts to record the literal token `SCRATCH` rather than a host path. It contains no backticked `npm run <x>` token, no `issue number: <digits>` shape, and no literal `docs/features/active/` path.
- [x] Each bundled copy (`extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-planner/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-executor/SKILL.md`) is byte-identical to its primary source. `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` pass; the only accepted local failure is the issue #510 gitignored `.claude/state/**` signature in `test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
- [x] `tests/scripts/dev_tools/test_scratch_location_contracts.py` exists. It asserts that `.claude/agents/atomic-planner.md`, `.claude/agents/atomic-executor.md`, `.agents/skills/atomic-planner/SKILL.md`, and `.agents/skills/atomic-executor/SKILL.md` each contain the pinned rule phrase and the `issue-<issue-num>` token. It also asserts that no file under `.claude/agents/*.md`, `.claude/skills/**/SKILL.md`, or `.agents/skills/**/SKILL.md` directs a scratch file to a bare fixed scratchpad path such as `SCRATCH/run-ps.sh` or a root-level `<scratchpad>/` path.
- [x] A recorded red run of `tests/scripts/dev_tools/test_scratch_location_contracts.py` against the pre-change sources shows the positive assertions failing, and a recorded green run after the edits shows the module passing. Both runs are stored under the feature folder's `evidence/` tree.
- [x] Historical plans and evidence under feature folders other than this one are not modified. The diff contains no file under `docs/features/` outside `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/`.
- [x] The diff contains no edit to `.claude/rules/**`, `.github/instructions/**`, `.claude/skills/atomic-plan-contract/SKILL.md`, `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, `.claude/skills/orchestrate/SKILL.md`, `.claude/agents/orchestrator.md`, `.agents/skills/orchestrate/SKILL.md`, `.agents/skills/orchestrator-workflow/SKILL.md`, `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, `.claude/skills/epic-orchestrate/SKILL.md`, `.codex/agents/*.toml`, any child-prompt template, or any plan-validator source.
- [x] The Python toolchain passes on the new test module: `poetry run black --check`, `poetry run ruff check`, and `poetry run pyright` report no errors. `poetry run pytest` passes for `test_scratch_location_contracts.py`, `test_claude_planning_integrity_contracts.py`, `test_typescript_toolchain_instruction_contracts.py`, `test_push_down_claude_resource_contracts.py` (with the #510 exception above), `test_push_down_codex_and_agents_resource_contracts.py`, and `test_codex_handoff_contract_parity.py`. Python baseline and final coverage artifacts are recorded under the feature folder's `evidence/` tree.
- [x] PR CI is green, including the Pester suite `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`, which reads `.claude/agents/atomic-executor.md`. The CI run is cited as evidence.

## Dependencies / Risks

- **Concurrent-edit overlap with #899 (CI Green Gate).** #899 edits `.claude/skills/orchestrate/SKILL.md`, `.claude/agents/orchestrator.md`, `.agents/skills/orchestrate/SKILL.md`, `.agents/skills/orchestrator-workflow/SKILL.md`, and `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`. This item must not touch them. Orchestrators delegate scratch writing to the planner and executor, so these files are not needed.
- **Concurrent-edit overlap with #902.** #902 edits `.claude/skills/epic-orchestrate/SKILL.md`, which holds the epic kickoff. This item must not touch it. That is one reason the rule is keyed to the canonical issue number and not added as a child-prompt line.
- **Concurrent-edit overlap with #903.** #903 edits `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, which this item must not touch.
- **`## Evidence Location Invariant` placement risk.** Both Claude personas end with an `## Evidence Location Invariant` section (`atomic-planner.md:68-74`, `atomic-executor.md:130-136`) that refers to the conventions skill #903 edits. If #903 also edits those persona sections, a textual merge conflict is possible; the research could not confirm whether it does. To reduce the risk, place the new text away from the end of each file: before `## Preflight Validation` in the planner, and after `## Toolchain Commands` in the executor.
- **Byte-level parity.** `test_push_down_claude_resource_contracts.py:122` compares bytes for planner-review resources, including `atomic-planner.md`. Mirrors must be byte-for-byte copies with matching line endings.
- **Known local noise.** `test_bundled_claude_payload_contains_all_repo_runtime_contracts` can fail locally on gitignored `.claude/state/**` (issue #510). Only that state-only signature is acceptable locally.
- **Codex TOML personas not updated.** `.codex/agents/atomic-planner.toml` and `atomic-executor.toml` are deliberately left unchanged, because an edit would trigger generator churn across their variant files and no parity test requires it. Codex agents that rely only on the TOML bodies will not see the rule. The `.agents/skills/` edits cover the Codex skill surface.
- **Plan-validator check out of scope (deferred).** A G-rule that rejects bare-scratchpad `SCRATCH` definitions would require editing read-only `.claude/rules/plan-acceptance-gates.md`, the Python validator, its TypeScript twin, two parity suites, and a corpus measurement over committed plans. It is deferred as a possible follow-up. Until then, the persona rule is enforced only by the contract test and agent compliance, not by plan preflight.
- **Same-issue concurrency.** Two concurrent runs for the same issue are not an expected topology. If one occurs, the `issue-<issue-num>` directory would be shared. The run-unique suffix `issue-<issue-num>-<yyyy-MM-ddTHH-mm>` is the documented extension point.

## Verification Steps

1. Before the persona edits, create `tests/scripts/dev_tools/test_scratch_location_contracts.py` and run `poetry run pytest tests/scripts/dev_tools/test_scratch_location_contracts.py`. Record the expected failure of the positive assertions under `evidence/`.
2. Edit the four primary sources, then copy each to its bundled location byte-for-byte.
3. Rerun `poetry run pytest` on `test_scratch_location_contracts.py`, `test_claude_planning_integrity_contracts.py`, `test_typescript_toolchain_instruction_contracts.py`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, and `test_codex_handoff_contract_parity.py`. Confirm they pass, accepting only the #510 state-only signature locally.
4. Run `poetry run black --check`, `poetry run ruff check`, and `poetry run pyright` on the new test module, and confirm there are no errors.
5. Record Python baseline and final coverage artifacts under `evidence/`.
6. Inspect `git diff --name-only main...HEAD` and confirm that no excluded path (see Acceptance Criteria) and no historical feature folder appears.
7. Confirm that PR CI is green, including `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`, and cite the run.

## Evidence Checklist
- [x] baseline
- [x] targeted verification
- [x] end-state

## Source

- GitHub issue #900: https://github.com/drmoisan/drm-copilot/issues/900
- Lifecycle record: `docs/features/potential/promoted/2026-10-11-concurrent-children-share-scratchpad-file-names.md` on ref `origin/docs/followups-2026-10-11` (cited only; not copied)
- Research: `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/research/scratch-file-naming.2026-10-11T10-45.md`
