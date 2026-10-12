# Research: Child-Unique Scratch File Naming (Issue #900)

- **Issue:** #900 (bug, minor-audit)
- **Branch:** bug/concurrent-children-share-scratchpad-file-names-900
- **Timestamp:** 2026-10-11T10-45
- **Researcher:** task-researcher
- **Scope:** Research only. No file other than this artifact was modified.

All paths are repository-relative to the worktree root. Line citations were taken from the current tree with the Read and Grep tools.

## Tooling Limitation

The research session had Read, Grep, Glob, Write, and Edit only; no shell was available. The lifecycle record at `origin/docs/followups-2026-10-11:docs/features/potential/promoted/2026-10-11-concurrent-children-share-scratchpad-file-names.md` could not be read with `git show`, so the problem statement is taken from the delegation prompt. That record is unverified by this research. The feature folder holds only `issue.md` (all sections "(not provided in potential file)") and an unfilled bug-plan template `plan.2026-10-11T10-38.md`.

## Summary of Findings

1. No normative contract text in the repository tells a planner, executor, or orchestrator to write scratch files to the session scratchpad. That includes the fixed names `run-ps.sh`, `changed-line-coverage.ps1`, `cov-final.txt`, and `region-probe.ps1`. Case-insensitive searches for `scratch`, `SCRATCH`, `scratchpad`, `run-ps.sh`, `changed-line-coverage`, `region-probe`, `cov-final`, and `Appendix H` return no hits in any of these: `.claude/agents`, `.claude/skills`, `.agents`, `.codex`, `.github`, `extensions/drm-copilot/resources`, and `docs/features/templates`.
2. The `SCRATCH` placeholder and the "Appendix H — Scratch Scripts" pattern come from the planner, one plan at a time. Each plan defines `SCRATCH` as the bare session scratchpad and gives fixed file names under it. Plans copy the convention from one another, not from a contract (see Q2).
3. Two executors have already worked around the collision without a rule: #787 used subdirectory `exec787` and #850 used `x850`.
4. The minimal normative home is the two Claude personas that write and run plans: `.claude/agents/atomic-planner.md` and `.claude/agents/atomic-executor.md`. Their Codex skill counterparts are a low-cost parity addition. Neither file is on the overlap list for #899, #902, or #903.

## Q1 — Inventory of Scratch-Directing Text

### Search scope and method

- Pattern A, case-sensitive: `SCRATCH|scratchpad|run-ps\.sh|changed-line-coverage|region-probe|cov-final|Appendix H`. Run separately over `.claude/`, `.agents/`, `.github/`, `.codex/`, and `extensions/`: zero hits in each.
- Pattern B, case-insensitive: `scratch` over the whole tree, excluding `docs/features/**`. This found 34 files, all listed below or in the test-shell group.
- Pattern C, case-insensitive: `scratch` over `docs/features/templates`: zero hits.
- Pattern D, case-insensitive: `temporar|throwaway` over `.claude/`. The only policy hit is listed below.

### Classified hits

| Location | Text | Class |
|---|---|---|
| `.claude/rules/general-code-change.md:50` | File-size exception for "temporary throwaway scripts created and deleted within an agent session" | (b) Related policy context, read-only. It permits session scripts but says nothing about where they go. Do not edit. |
| `.claude/lib/bash/parallel-cohorts.sh:51`, `.claude/lib/bash/parallel-yaml-scan.sh:84` and their bundle mirrors | Code comments: "Scratch array", "Scratch outputs" | (c) Unrelated (in-memory variables). |
| `docs/features/parallel/verification-integrity/parallel.md:89-90` | Blast-radius paths `<scratchpad>/corpus_differential.py`, `<scratchpad>/spec.before-p9t6.md` | (c) Historical parallel run artifact. |
| `tests/fixtures/blast_radius/verification-integrity/verification-integrity-485-486-487.json:96-97` | Same two `<scratchpad>/...` paths | (c) Test fixture that copies a historical run. Must not change. |
| `docs/features/epics/worktree-scoped-state-resolution/epic-kickoff.md:127-130` | "a hard-coded scratchpad `.sh` file invoked as ..." | (c) Historical epic kickoff. |
| `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1:30`, `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1:27-28` | Synthetic `C:/synthetic-out-of-root/scratchpad/...` fixture paths | (b) Test data. Out of scope. |
| `tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1:155-158`, `WorktreeItemResolution.Tests.ps1:23`, `tests/shell/test_cleanup_worktrees_*.bats`, `tests/fixtures/cleanup_worktrees/**` | `D:\scratch\`, scan-root fixtures | (c) Unrelated use of the word. |
| `docs/research/2026030*`, `20260411*`, `20260412*`, `20260626*` | "from scratch", "scratch research area" | (c) Unrelated. |
| `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/plan.2026-09-29T22-17.md:94` | "SCRATCH means the executor's session scratchpad directory, outside the repository and never committed." | (c) Historical plan. This is the origin of the convention (see Q2). |
| same plan `:107`, `:149` | "Every PowerShell script runs through scratch script A1: `sh SCRATCH/run-ps.sh SCRATCH/<script>.ps1 <args>`" | (c) Historical. Fixed name `run-ps.sh`. |
| same plan `:178`, `:838` (`## Appendix H — Scratch Scripts`), `:842` (`A1 run-ps.sh:`) | Creates the A1–A18 scripts verbatim under SCRATCH | (c) Historical. |
| `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/remediation-plan.2026-09-30T02-00.md:45,66` | Reuses "A1 run-ps.sh ... A11 changed-line-coverage ... verbatim from MPLAN Appendix H" | (c) Historical. |
| `docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787/plan.2026-10-08T13-54.md:171,305,890-892` | Creates A1–A23 under SCRATCH; `-ReportPath SCRATCH/cov-final.txt`; Appendix H carried over from the #690 plan | (c) Historical. Fixed names `cov-final.xml` and `cov-final.txt`. |
| `docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/plan.2026-10-08T13-54.md:167,227,678` | A1–A18 under SCRATCH, `SCRATCH/stage/` | (c) Historical. |
| `docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769/evidence/qa-gates/changed-line-coverage.2026-09-29T14-39.md:4` | `sh SCRATCH/run-ps.sh SCRATCH/changed-line-coverage.ps1 ...` | (c) Historical evidence. |
| `docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773/plan.2026-09-29T17-45.md:962` | "Appendix H — Final QA File Set" | (c) Historical. The appendix letter is reused for unrelated content, which shows "Appendix H" is not a template convention. |
| `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/plan.2026-10-08T22-16.md:1047` | "Appendix H — PR-Body Callout Notes" | (c) Historical. Same observation. |

**Category (a), normative guidance to change: no existing file.** The fix adds new normative text and does not edit existing scratch guidance.

### Direct evidence of the defect

- `docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787/evidence/other/scratch-smoke.2026-10-08T22-36.md:8`: "A dedicated subdirectory was used because the shared scratchpad already held unrelated files with the same names as several Appendix H scripts."
- `docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/other/c1a-reverification.2026-10-08T23-17.md:8` and `.../baseline-red-stop.2026-10-08T23-23.md:42`: "SCRATCH resolves to the session scratchpad subdirectory `x850`".
- Environment observation in this research session: the scratchpad directory supplied to this worktree-isolated subagent is under the coordinating session's ID (`...\<coordinator-session-id>\scratchpad`), not a per-worktree location. Worktree-isolated children of one session therefore resolve to the same scratchpad, which matches the issue's premise. This rests on one session's environment and was not tested across several children.

## Q2 — Origin of the Appendix H Helper-Script Guidance

The guidance exists **only in historical plans**. No persona, skill, template, rule, or prompt names `SCRATCH`, a scratch appendix, or any of the fixed file names (Q1, Patterns A–C). The earliest definition found is `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/plan.2026-09-29T22-17.md:94`. Later plans copy it explicitly: `.../787/plan.2026-10-08T13-54.md:892` says the A1–A15 set is "carried unchanged ... from `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/plan.2026-09-29T22-17.md` Appendix H". The helper-script route exists because the worktree isolation hook refuses command text containing `bash`, `pwsh`, or `wsl` (`.../690/plan.2026-09-29T22-17.md:106-107`).

**Best home for the new rule.** The `atomic-planner` persona authors every `SCRATCH` definition, and the `atomic-executor` persona creates and runs the files. So the rule belongs in:

- `.claude/agents/atomic-planner.md`. Its `## Requirements` list (lines 50-56) is the natural place for a sixth requirement, or a short new `## Scratch Location` section after line 56. This binds every plan, including remediation plans, which the same persona authors.
- `.claude/agents/atomic-executor.md`. A short `## Scratch Location` section after `## Toolchain Commands` (lines 74-83) covers plans written before the rule existed, such as the historical plans that define `SCRATCH` as the bare scratchpad root.

`.claude/skills/atomic-plan-contract/SKILL.md` would also work, since both personas preload it (`atomic-planner.md:13-16`, `atomic-executor.md:25-29`). It is on the avoid list, though, and the two persona files reach the same two actors without it.

## Q3 — Mirror and Parity Mechanisms

| Edited source | Mirror or counterpart | Enforcing test | Comparison |
|---|---|---|---|
| `.claude/agents/atomic-planner.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md` | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110` (every distributable `.claude` file); also `:113-123` (`PLANNER_REVIEW_RESOURCE_PATHS` at `:41-45` names this file) | Text equality at `:107`; byte equality (`read_bytes`) at `:122` |
| `.claude/agents/atomic-executor.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md` | `test_push_down_claude_resource_contracts.py:89-110` | Text equality |
| `.agents/skills/atomic-planner/SKILL.md`, `.agents/skills/atomic-executor/SKILL.md` (Codex counterparts, optional) | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/SKILL.md` | `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:215-228` (all `.agents` and `.codex` files); also `:247-253` for atomic-executor | Text equality |
| `.codex/agents/atomic-planner.toml`, `atomic-executor.toml` (not recommended) | Bundle copy plus five generated variants each (`-c1`, `-c2`, `-c3`, `-c3-elevated`, `-c4`) in both surfaces | `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py:76-120` (root equals bundle); `tests/scripts/dev_tools/test_generate_codex_agent_variants.py:181-184` (`main(["--check"]) == 0`) | Text equality plus generator drift check |

Cross-surface notes:

- No test requires `.claude/agents/atomic-planner.md` to match `.agents/skills/atomic-planner/SKILL.md` or `.codex/agents/atomic-planner.toml`. The Codex TOML body is already a converted copy that differs from the Claude persona; compare the `## Preflight Validation` sections at `.codex/agents/atomic-planner.toml:69-82` and `.claude/agents/atomic-planner.md:58-62`. Codex parity is a design choice, not a test obligation.
- Pack manifests list paths only and hold no hashes. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:6-7` already lists both agent files, and `codex-and-agents-customizations/pack-manifests/core.json:8,10` lists both `.agents` skills. A content edit needs no manifest change. A search for 64-hex-digit hashes under `config/`, `scripts/dev_tools/*.py`, `extensions/drm-copilot/resources/config/`, and `.codex/*.toml` found none, so there is no checked-in hash manifest to regenerate.
- Generated artifacts: only an edit to `.codex/agents/<family>.toml` triggers regeneration. The command is `poetry run python -m scripts.dev_tools.generate_codex_agent_variants`, which writes the root and bundle base files, all variants, and the pack manifests (`scripts/dev_tools/generate_codex_agent_variants.py:221-268`). `--check` reports drift. The recommended change set does not edit `.codex/`, so no regeneration is needed.
- Mirror production: copy the edited primary byte-for-byte; earlier plans used `cp` (`.../690/plan.2026-09-29T22-17.md:108`). The planner-review test at `test_push_down_claude_resource_contracts.py:122` compares bytes, so the mirror must match line endings exactly.
- Known local noise: node `test_bundled_claude_payload_contains_all_repo_runtime_contracts` can fail locally on gitignored `.claude/state/**` (issue #510; described in `.../690/plan.2026-09-29T22-17.md:97`). A plan should accept only that state-only failure signature.

## Q4 — Contract-Test Precedents and Recommended Home

| Precedent | Language | Pattern |
|---|---|---|
| `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py:96-108` | Python (pytest) | Reads `.claude/agents/atomic-planner.md`, `.claude/skills/atomic-plan-contract/SKILL.md`, and a hook, then asserts each required token with `in`. |
| `tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py:28-35` | Python (pytest) | Asserts prose over a tuple of mirror paths, including `.claude/agents/atomic-executor.md` and `.agents/skills/*`. Its module docstring (`:9-12`) says bundled copies are covered transitively by the push-down parity tests. |
| `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py:210-239` | Python (pytest) | Section-scoped assertions using `extract_section` from `tests/scripts/dev_tools/parallel_orchestrator_surface_test_support.py`, plus negative assertions. |
| `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1:39-48` | PowerShell (Pester) | `Get-Content -Raw` on `.claude/agents/atomic-executor.md` with `Should -Match`. |

**Recommendation:** add a new pytest module, `tests/scripts/dev_tools/test_scratch_location_contracts.py`.

- Reasons for pytest: it runs locally with `poetry run pytest` (allowed in `atomic-executor.md:14`). It needs no PoshQC MCP route and no shell wrapper. It follows the three Python precedents above, and the module stays far under the 500-line limit.
- Assertions:
  - Positive: each in-scope persona or skill contains the pinned rule phrase and the `issue-<issue-num>` subdirectory token.
  - Negative: no normative surface (`.claude/agents/*.md`, `.claude/skills/**/SKILL.md`, `.agents/skills/**/SKILL.md`) contains a bare fixed scratch path such as `SCRATCH/run-ps.sh` or `<scratchpad>/` at the root.
- Bundled copies are covered by the existing parity tests, following the precedent at `test_typescript_toolchain_instruction_contracts.py:9-12`.
- Expect-fail property: the positive assertions fail on the current tree because no surface contains the phrase (Q1). The Phase 2 regression task can therefore show a real red run.

## Q5 — Overlap Constraints and Minimal Home Set

| File | Overlap | Use for #900? |
|---|---|---|
| `.claude/skills/orchestrate/SKILL.md`, `.claude/agents/orchestrator.md`, `.agents/skills/orchestrate/SKILL.md`, `.agents/skills/orchestrator-workflow/SKILL.md`, `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` | #899 (CI Green Gate) | Avoid. Not needed: orchestrators delegate scratch-writing work to the planner and executor. |
| `.claude/skills/epic-orchestrate/SKILL.md` | #902 | Avoid. |
| `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` | #903 | Avoid. |
| `.claude/skills/atomic-plan-contract/SKILL.md` | Caller's avoid list | Avoid. The personas cover both actors. |
| `.claude/agents/atomic-planner.md`, `.claude/agents/atomic-executor.md` | None named | **Use.** |
| `.agents/skills/atomic-planner/SKILL.md`, `.agents/skills/atomic-executor/SKILL.md` | None named | Use for Codex parity (recommended, low cost). |

Residual overlap risk: both Claude personas end with `## Evidence Location Invariant` (`atomic-planner.md:68-74`, `atomic-executor.md:130-136`), which points to the conventions skill #903 edits. If #903 also edits those persona sections, a textual merge conflict is possible; this was not verified, since #903's file list in the prompt names only the skill. Placing the new text away from the end of each file reduces the risk: after `## Requirements` in the planner (before line 58) and after `## Toolchain Commands` in the executor (before line 85).

No file on the avoid list is unavoidable.

## Q6 — Per-Child Scratch Line in Child-Prompt Templates

**Recommendation: do not add a scratch line to the child-prompt templates.** The child should derive its scratch directory from the canonical issue number it already receives.

Evidence:

- The parallel execution kickoff is a closed contract: "the delegation prompt carries exactly these five elements" (`.claude/skills/parallel-orchestrate/SKILL.md:241-267`). Element 3 is already the canonical issue number line (`:254`). A sixth element breaks `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py:210-222`, which asserts there is no `6. ` line and that the phrase "exactly these five elements" stays.
- The parallel-plan kickoff line carries "no mode marker, no digits, and no active feature-folder path" (`.claude/skills/parallel-plan/SKILL.md:140`), and its kickoff line is pinned byte-for-byte (`test_parallel_issue_adoption_skill_contracts.py:15`).
- Added prompt text must not match the hook issue-number regex `issue(?:[_-]?num(?:ber)?|\s+number)\s*[:=]\s*#?(\d+)` (`test_parallel_issue_adoption_skill_contracts.py:70-72`, `:225-239`).
- The epic kickoff lives in `.claude/skills/epic-orchestrate/SKILL.md` (`## Merge-on-Green Kickoff Parameter`, line 113), which #902 is editing.
- Every child already has the canonical issue number: `orchestrate` `## Issue Number Consistency`, cited at `parallel-orchestrate/SKILL.md:308`. A rule keyed to that number therefore needs no prompt change.

Placeholder choice: use `issue-<issue-num>`, which matches the existing `orchestrator-state.issue-<issue-num>.<yyyy-MM-ddTHH-mm>.json` naming (`parallel-orchestrate/SKILL.md:237`). It has no colon or equals sign followed by digits, so it cannot match the hook regex.

## Q7 — Plan-Validator Check

**Recommendation: out of scope for this minor-audit.** Record it as a possible follow-up.

- Rule surface: `.claude/rules/plan-acceptance-gates.md` is read-only policy. G1–G9 are "the complete shipped set" (`:44`).
- Python implementation: `scripts/dev_tools/plan_gate_discrimination.py`, `plan_gate_commands.py`, and `plan_gate_observability.py`, called from `scripts/dev_tools/validate_orchestration_artifacts.py`.
- TypeScript parity port: `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts`, `plan-gate-rules.ts`, `plan-gate-commands.ts`, and `plan-gate-observability.ts`, dispatched from `orchestration-artifacts.ts` (`plan-acceptance-gates.md:17`, `:256`).
- Parity tests: `tests/scripts/dev_tools/test_plan_gate_parity.py` and `extensions/drm-copilot/test/lib/validate/plan-gate-parity.test.ts`.
- Severity process: a new G-rule's severity is set by a pre-declared corpus measurement over all committed plans, with false-positive classification (`plan-acceptance-gates.md:62-66`, `:86-99`). The scratch pattern appears in historical active plans, so such a measurement would have to classify those plans.

Adding a rule means editing a read-only policy file, a Python validator, a TypeScript twin, two parity suites, and running a corpus measurement. That exceeds a minor-audit prose fix, and the persona rule plus contract test covers the defect.

## Rejected Alternatives

- **Child-prompt scratch line** (parallel, epic, and preparation kickoffs): this breaks the five-element contract test and touches #902's file. Rejected (Q6).
- **Rule in `atomic-plan-contract` skill**: on the avoid list, and the personas give the same coverage. Rejected.
- **Plan-validator G10**: needs a policy-file edit, a dual-language port, and a corpus measurement. Rejected for this scope (Q7).
- **Per-file issue suffix** (`run-ps-<issue>.sh`): a directory per child is simpler. One `SCRATCH` definition isolates every file, and the existing `SCRATCH/<name>` plan syntax and `SCRATCH/stage/` subpaths keep working. The #787 and #850 executors already used the directory approach (Q1). Rejected in favour of a per-child subdirectory.

## Proposed Rule Semantics

- `SCRATCH` resolves to `<session scratchpad>/issue-<issue-num>/`, where `<issue-num>` is the plan's canonical issue number. No plan directs a scratch file to the scratchpad root.
- Every scratch file, helper script, staged copy, and coverage report a plan names lives under `SCRATCH`. Subdirectories such as `SCRATCH/stage/` are allowed.
- Artifacts record the literal token `SCRATCH`, never a host path. This matches existing practice (`.../690/plan.2026-09-29T22-17.md:94`).
- Executor behaviour for plans that predate the rule: the executor creates the child-unique directory before the first scratch write. When a plan defines `SCRATCH` as the bare scratchpad, the executor treats it as the child-unique directory. This is a mechanical micro-action under `atomic-executor.md:60`, not replanning.
- Edge case: two concurrent runs for the same issue are not an expected topology. If one occurs, a run-unique suffix (`issue-<issue-num>-<yyyy-MM-ddTHH-mm>`) is the extension point. The rule can mention this in one clause.
- Success condition: no two concurrently running children resolve the same scratch path.
- Failure condition: any normative surface directs a scratch file to the scratchpad root or to a fixed name outside `SCRATCH`.

## Testing Implications

- Phase 2 (`[expect-fail]`): create `tests/scripts/dev_tools/test_scratch_location_contracts.py` and run it with `poetry run pytest`. The positive assertions fail before the persona edits.
- Phase 3: edit the four sources and copy the four mirrors byte-identically.
- Phase 4: rerun the new test, `test_claude_planning_integrity_contracts.py`, `test_typescript_toolchain_instruction_contracts.py`, `test_push_down_claude_resource_contracts.py` (accept only the #510 state-only signature locally), `test_push_down_codex_and_agents_resource_contracts.py`, and `test_codex_handoff_contract_parity.py`. Run Python format, lint, and type check (`poetry run black`, `poetry run ruff`, `poetry run pyright`) on the new test file.
- Coverage: the change adds no production executable code; the new file is test code. Line and branch coverage of production code is unchanged. A plan should still record a Python baseline and final coverage artifact under `<FEATURE>/evidence/` to satisfy the fail-closed evidence rule.
- `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1:39-48` reads `atomic-executor.md` but asserts only MCP tool tokens. It is unaffected as long as those tokens stay, and CI verifies it. No local Pester run is needed.
- Text constraints on the new prose:
  - No backticked `npm run <x>` token. `test_typescript_toolchain_instruction_contracts.py:42` checks such tokens in `atomic-executor.md`.
  - No `issue number: <digits>` shape.
  - No literal `docs/features/active/` path.

## Recommended Change Set

Edit:

1. `.claude/agents/atomic-planner.md`: add the child-unique scratch rule (a sixth `## Requirements` item or a `## Scratch Location` section placed before `## Preflight Validation`, line 58).
2. `.claude/agents/atomic-executor.md`: add a `## Scratch Location` section after `## Toolchain Commands` (before line 85), including the pre-rule plan handling.
3. `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md`: byte-identical copy of item 1.
4. `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md`: byte-identical copy of item 2.
5. `.agents/skills/atomic-planner/SKILL.md`: the same rule for Codex parity (new section after `## Plan Requirements`, line 22-35).
6. `.agents/skills/atomic-executor/SKILL.md`: the same executor rule for Codex parity.
7. `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-planner/SKILL.md`: byte-identical copy of item 5.
8. `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-executor/SKILL.md`: byte-identical copy of item 6.

Create:

9. `tests/scripts/dev_tools/test_scratch_location_contracts.py`: pytest contract test (Q4).

Do not edit:

- `.claude/rules/**` and `.github/instructions/**` (read-only policy).
- `.codex/agents/*.toml` (generator churn across 12 files per family, and no parity obligation).
- Any child-prompt template (Q6).
- The plan validator and the G-rules (Q7).
- Historical feature folders.
- Every file on the #899, #902, and #903 overlap lists, and `.claude/skills/atomic-plan-contract/SKILL.md`.
- Pack manifests (path-only; no change needed).

If the caller wants a Claude-only minimum, items 5–8 can be dropped. No test requires Claude-to-Codex parity, but Codex planners would then keep producing bare-scratchpad `SCRATCH` definitions.

## Automation Feasibility

The work can be done entirely by agents:

- All edits are Markdown prose in persona and skill files plus one new pytest module.
- Mirrors are byte-identical copies.
- Verification runs through `poetry run pytest`, `black`, `ruff`, and `pyright`, which the `atomic-executor` allowlist permits (`.claude/agents/atomic-executor.md:11-14`).
- No PowerShell or bats wrapper script, no generator run, no MCP PoshQC call, and no operator action is needed.
- The one Pester suite that reads an edited file (`claude-architecture-doc.Tests.ps1`) is verified in CI.
- The only known local-only failure mode is the #510 gitignored-state signature in `test_bundled_claude_payload_contains_all_repo_runtime_contracts`. A plan can handle it with an explicit acceptance clause.
