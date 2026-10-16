# 2026-10-16-planning-process-churn (Spec)

- **Issue:** #964
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-16
- **Status:** Approved for planning
- **Version:** 1.0
- **Work Mode:** full-bug (this file is the only acceptance-criteria source)
- **Design source:** `research/research.2026-10-16T22-36.md` (decisions D1 to D15 adopted unchanged, except as noted under Design, scope item 1)

## Summary

Research, planning, preflight and remediation produce large, literal-heavy plans and spend most of the agent budget on planner/preflight round trips. In run `bug-burndown-2026-10-15`, items #953, #952 and #935 used most of their agents on planning and preflight, and #962's plan grew to 1,754 lines and 99 tasks over six preflight rounds. This item changes the process so that a plan is design-level, environment constraints are known before planning, preflight completes in one pass with at most one return to the planner, research and plans carry a pre-mortem, and remediation of review findings is proportionate to the change.

## Root Cause

1. **Literal-transcript plans.** `.claude/rules/plan-acceptance-gates.md`, the `atomic-plan-contract` skill (`## Wrap-Tolerant Assertion Authoring (Mandatory)`, `## Planner Adversarial Self-Review (Mandatory)`, the `CITATION:` locator) reward exact literals, line locators and commit SHAs. Each one is a preflight failure point that goes stale when `main` moves.
2. **No shared execution-environment brief.** Tool routes, command-text restrictions, the batch budget, CI shape, contract tests and evidence rules are restated by each plan (the #962 plan restates them as eighteen preamble rules and a command-recipe section).
3. **Cold-start ping-pong.** Preflight reports a subset of defects; trivial defects return to a new planner. In addition, `.claude/hooks/validate-executor-output.ps1` (`Test-IsPreflightPlan`) detects a preflight run only from a directive line in the plan file. Orchestrators therefore paste the directive into plans, after which every execution run of that plan is classified as preflight and the completion checks in `Get-ExecutorOutputBlockDecision` are skipped (verified defect, research section 3.1).
4. **No pre-mortem.** Review checklists, per-file coverage, mirror parity, the 500-line limit, test isolation, CI-only behavior and evidence are not anticipated before review.
5. **Heavyweight remediation.** A small review fix runs the full plan, multi-round preflight, execute and review pipeline.

## Scope

### In scope

1. Execution-environment brief (skill `execution-environment`) and its wiring and mirrors.
2. Design-level plan contract, validator gates G11 to G13 (Python and TypeScript), planner hook changes.
3. Single-pass preflight with trivial/substantive classification, in-place trivial fixes and at most one return; transcript-based preflight detection.
4. Mandatory pre-mortem in feature research and plans; self-review before the first review push.
5. Proportionate remediation (`Remediation-Mode: proportionate|design`).
6. Validation: tests for every validator and hook change, and an orchestrator-owned re-plan of #962.
7. Related finding fixed in this item: `.claude/agents/task-researcher.md` lists `evidence-and-timestamp-conventions` under `tools:` and has no `skills:` key (D12).

### Out of scope

- Feature-review templates, `.claude/skills/feature-review-workflow/SKILL.md` and `.claude/agents/feature-review.md` (the self-review uses the templates as they are).
- Orchestrator-state checkpoint schema and its Python, TypeScript and PowerShell validators (no new field; `Remediation-Mode:` lives in the remediation inputs file; preflight exhaustion reuses `validator_failed` and `blocked_preflight_iteration_limit`).
- Releasing the extension so that the MCP validator applies G11 to G13 (follow-on rollout; no AC depends on it).
- #962's feature folder and branch (read-only snapshot source).

### Files deliberately not touched

| File | Reason |
|---|---|
| `scripts/dev_tools/validate_orchestration_artifacts.py`, `tests/scripts/dev_tools/test_claude_rules_frontmatter.py`, `tests/scripts/dev_tools/test_plan_gate_parity.py`, `extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts`, `scripts/dev_tools/plan_gate_observability.py`, `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts` | At or near the 500-line limit; new logic goes into new modules and new test files. |
| `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md` | SHA-256 pinned in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (`PINNED_FROZEN_SURFACE_HASHES`), preloaded-skill list pinned, and changed by #952; both defer to the orchestrate skill (D13). |
| `.claude/settings.json` | No new hook registration; the new helper is dot-sourced by existing hooks. |
| `quality-tiers.yml` | Every touched path is already classified. |
| Copilot and Codex gate statements ("do not mark complete until `PREFLIGHT: ALL CLEAR`") | They remain true under single-pass preflight; only loop mandates are edited (D14). |

## Design

### 1. Execution-environment brief (D1, D2)

- New skill `.claude/skills/execution-environment/SKILL.md`, preloaded through `skills:` frontmatter of `task-researcher`, `atomic-planner`, `atomic-executor` and `orchestrator`. `.claude/skills/orchestrate/SKILL.md` `## Prerequisites` gains an instruction to read the skill before delegating. Codex base agents `.codex/agents/{atomic-executor,atomic-planner,task-researcher,orchestrator}.toml` list it as a canonical skill; Copilot base agents reference it by an explicit read-first instruction.
- One text, byte-identical in every location listed under Mirror and Parity Obligations. It names both `.claude/hooks/...` and `.codex/hooks/...` paths where the runtimes differ, so no per-surface rewrite is needed. It carries no line numbers and no commit SHAs, and its first section states that it is updated in the same change that alters any fact it states.
- Required headings: `## Purpose and Maintenance`, `## Tool Routes by Agent`, `## Command-Text Restrictions`, `## PowerShell Route and PoshQC MCP Limits`, `## Batch Budget`, `## Hook Execution Context`, `## MCP Surfaces Run the Installed Extension`, `## CI Shape and Required Checks`, `## CI-Only Failure Classes`, `## Contract Tests That Pin Mirrored Files`, `## Preflight Defect Classes the Validator Cannot See`, `## Evidence and Documentation Rules`, `## Coverage and File-Size Gates`, `## Test Isolation Checks`.
- Content (facts and sources per research section 1.4):
  - Command-text restrictions, kept in two parts. The worktree isolation guard (refuses Bash text containing `pwsh`, `bash` or `wsl`, heredocs, and similar constructs; `sh file.sh`, `npx`, `poetry run python`, `gh` and worktree-scoped `git` pass) is stated as Claude Code runtime behavior for isolated worktrees, not as a repository hook. Repository denials are attributed to `.claude/hooks/validate-bash.ps1` and `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`.
  - Tool routes: `atomic-executor` has no PowerShell tool, so PowerShell runs through the `mcp__drm-copilot__run_poshqc_*` tools or a `sh` launcher stored under `SCRATCH`. `atomic-planner` has no Bash. PoshQC MCP results carry no output (summary composed before the child runs); counts, percentages and findings come from `artifacts/pester/pester-junit.xml`, `artifacts/pester/powershell-coverage.xml`, or a direct analyzer run.
  - Batch budget: in direct mode, a fourth distinct non-test PowerShell (or Python) production file written through `Write`/`Edit` in one session is denied outside the large, remediation or preparation route (`POWERSHELL_LARGE_PATH_REQUIRED`, `PYTHON_LARGE_PATH_REQUIRED`). Bundle mirror copies count. Scratch `.ps1` files count when they resolve inside the worktree root; files under `SCRATCH` (outside the root) are discarded without consuming a slot. Files written by Bash or a generator are not seen. Isolated subagent worktrees have no checkpoint, so direct mode applies there.
  - Hook execution context: isolated subagents run the hook scripts of their own worktree (`main`'s copy); a branch hook change is not exercised by isolated subagents until merged.
  - Installed-extension lag: MCP tools run the installed extension; branch-current plan validation is `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <path>`.
  - CI shape: workflow and job names from `.github/workflows/ci.yml`, `_poshqc.yml`, `_quality-checks.yml`, `_docs-validation.yml`, `_shell-coverage.yml`; the Linux hook-suite job (`poshqc / PowerShell hook suites (Linux)`); the PoshQC shard jobs with `poshqc / PowerShell QC` as aggregator; `merge_group`; and the required contexts of ruleset 15241672, confirmed by the orchestrator through `gh api` on 2026-10-16: `drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)`, `drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)`, `docs-validation / Documentation Validation`, `poshqc / PowerShell QC`, `shell-coverage / Shell Coverage (Bats + kcov)`, `security-scan / Security Scanning`, `quality-checks7 / Code Quality & Tests (3.10)`, `(3.11)`, `(3.12)`, `(3.13)`, `build-check / Build Package`. The brief records the confirmation date and the refresh rule.
  - Contract tests that pin mirrored files (resource contracts, pack-manifest completeness, Codex generator `--check`, pinned surface hashes, bundle parity, workflow contract tests, consuming-name scan, TypeScript toolchain instruction contracts), evidence and docs-validation rules, CI-only failure classes, and validator-blind preflight defect classes, per research section 1.4.
- New contract test `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`: byte identity of all copies, required headings, preload wiring on every surface, the required-context names, the absence of `TaskMaster` and `No-COM`, and zero G11/G12 findings when the `plan_gate_document` evaluators are applied to the brief text.

### 2. Design-level plan contract (D3, D4, D5, D9)

- The operator approved editing `.claude/rules/plan-acceptance-gates.md` and its bundle mirror for this item.
- New module pair `scripts/dev_tools/plan_gate_document.py` and `extensions/drm-copilot/src/lib/validate/plan-gate-document.ts`, same import discipline as `plan_gate_scratch.py`. One call each from `evaluate_plan_gates` (`plan_gate_discrimination.py`) and `evaluatePlanGates` (`plan-gate-discrimination.ts`), after G10. Document-level, context-free, fenced blocks skipped, no lookbehind, offending value rendered between backticks, `Line N: ` prefix. Severity constants `G11_SEVERITY`, `G12_SEVERITY`, `G13_SEVERITY` are Blocking in both runtimes, by operator-approved scope (G10 precedent).
  - **G11 line-number citation:** prose form `\b[Ll]ines?[ \t]+[0-9]+` on unfenced text with inline code masked; path form `<path>.<ext>:<digits>` including inline code, skipping tokens that contain `://`; anchor form `#L` followed by digits.
  - **G12 commit-SHA citation:** `\b[0-9a-f]{7,40}\b` with at least one digit and one letter, not preceded by `-`, `_` or `.` and not followed by `-` or `_` (adjacency checked in code). Decimal IDs, all-letter words, UUID segments, agent suffixes and SHA-256 digests do not match.
  - **G13 size:** fires when canonical task lines exceed `PLAN_TASK_GUIDELINE = 40` or physical lines exceed `PLAN_LINE_GUIDELINE = 400`, unless a `## Size Justification` heading is followed by a non-blank, non-heading line before the next `## ` heading. One finding per document.
  - Messages and the documented false-positive classes follow research section 2.2. The rule file records that the corpus measurement informed the false-positive list and did not decide the channel.
- `.claude/rules/plan-acceptance-gates.md`: G1 through G13 in title, rule table, severity sections, enforcement and authoring guidance. `tests/scripts/dev_tools/test_plan_gate_scratch_docs.py` moves the G1-through-G10 sentences to its superseded lists and pins the G1-through-G13 replacements.
- `.claude/skills/atomic-plan-contract/SKILL.md`: new `## Design-Level Plan Contract (Mandatory)` (tasks name files, symbols, behavior, tests and acceptance; anchors are symbols, headings or test names; literals only where they are the asserted value; tool routes and launchers are not restated because the brief owns them; size guideline with `## Size Justification`; `## Pre-Mortem` required). The self-review and internal-review record use symbol, heading or test locators. `## Validator Gate (Mandatory)` states G1 through G13.
- Planner hook `.claude/hooks/validate-planner-output.ps1`: calls `Test-PreMortemSection` (repairable block) and rejects a `CITATION:` locator that is a line reference (bare digits, `L` plus digits, `line` plus digits, `<path>:<digits>`).
- `atomic-planner` and `atomic-executor` gain `mcp__drm-copilot__validate_orchestration_artifacts` in `tools:`.

### 3. Single-pass preflight (D6, D7, D8)

- `Test-IsPreflightRun` replaces `Test-IsPreflightPlan`. It reads `agent_transcript_path` from the SubagentStop envelope through an injectable reader seam (`ReadTranscriptHead`), takes the first `user` entry (the delegation prompt), and tests it for `DIRECTIVE: PREFLIGHT VALIDATION ONLY`. A readable transcript is authoritative, including when the plan file carries a stale directive. If the transcript is absent or unparseable, it falls back to the plan-file check or to the output carrying exactly one `PREFLIGHT:` signal line.
- The directive lives in the delegation prompt only; `atomic-plan-contract`, the orchestrate skill and agent definitions stop instructing anyone to place it in a plan file.
- Preflight reviews the entire plan in one pass and classifies every defect. Trivial (stale or misspelled anchors, citations including G11/G12 findings, typos, literal formatting that does not change what is asserted, evidence filename spelling) is fixed in place in task text or preamble only; tasks are never added, removed or reordered. Substantive (missing or extra tasks, wrong file set or design, AC without a task, assertion change, ordering, scope) is returned.
- Output, one line per defect after the `PREFLIGHT:` and `CONVERGENCE:` lines: `PREFLIGHT-FIX: <task id or heading> | <defect class> | <change made>`, `PREFLIGHT-DEFECT: <task id or heading> | <defect class> | <required change>`, and `preflight-fix-record: <path>` pointing to `<FEATURE>/evidence/other/preflight-fixes.<timestamp>.md` when a fix was made.
- Hook rules in a preflight run (all repairable): exactly one `PREFLIGHT:` signal; `ALL CLEAR` has no `PREFLIGHT-DEFECT:` line; `REVISIONS REQUIRED` has at least one; any `PREFLIGHT-FIX:` requires an existing `preflight-fix-record:` path under `docs/features/`.
- At most one return: one planner revision carrying the full defect list, then one more preflight; a second substantive result halts with `blocked_reason: "validator_failed"` (planning) or `blocked_preflight_iteration_limit` (remediation; the pinned phrase `preflight.iterations > 1` is kept).
- Surfaces: `.claude/agents/atomic-executor.md` (`## Preflight Validation`, `## Blocking Protocol`; the `run_poshqc_*` names and `## Scratch Location` text preserved), `.claude/agents/atomic-planner.md`, `.claude/skills/epic-plan/SKILL.md` (loop sentence replaced by a reference to the single-pass rule), `.codex/agents/atomic-executor.toml` (loop and auto-handoff fragments replaced; `test_codex_agent_wrapper_contracts.py` updated in the same change), `.github/agents/atomic_executor.agent.md`.

### 4. Mandatory pre-mortem and self-review (D5, D10, D12)

- Shared helper `.claude/hooks/premortem-section.ps1`, function `Test-PreMortemSection -Content <string>`: requires a `## Pre-Mortem` heading and, inside it, a bullet beginning with each label `Review checklists`, `Coverage`, `Mirror parity`, `File size`, `Test isolation`, `CI-only behavior`, `Evidence` (case-insensitive; "not applicable" with a reason accepted). Dot-sourced with the guarded `Add-HookDependencyFailure` pattern by `validate-planner-output.ps1` and `validate-task-researcher-output.ps1`.
- The researcher hook enforces the section only for research paths under `docs/features/`; `docs/research/` one-off research is exempt. `task-researcher.md` and `research-issue` require the section; `task-researcher.md` frontmatter gains `skills:` (`evidence-and-timestamp-conventions`, `execution-environment`) and drops the skill name from `tools:`.
- Plan templates under `docs/features/templates/{bug,feature,refactor}/` gain an empty `## Pre-Mortem` skeleton with the labels.
- Test isolation in the pre-mortem includes a seeded shuffled run (Jest `--randomize --seed=<n>` with the seed recorded, reversed-order Python run, single-process Pester run over `tests/scripts`).
- Self-review: the plan's final phase walks the policy-audit, code-review and feature-audit templates against the branch diff and writes `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL or N/A row per item. `.claude/skills/orchestrate/SKILL.md` `## Pre-Feature-Review Commit` gains a first step: the newest self-review exists and has no FAIL row, otherwise a proportionate correction runs before the commit.

### 5. Proportionate remediation (D11)

- Each `remediation-inputs.<timestamp>.md` carries `Remediation-Mode: proportionate` or `Remediation-Mode: design`. Proportionate means every finding is fixable without changing a spec AC, a public interface, or the file inventory beyond the branch diff plus tests and mirrors; CI-failure findings are normally proportionate.
- Proportionate cycle: one planner delegation (short plan with `## Pre-Mortem` and a final self-review task), then one executor delegation that runs preflight with in-place trivial fixes and then executes. A substantive defect stops it with `BLOCKED at preflight (before [P0-T1])` and converts the cycle to design mode for one planner revision. The checkpoint records `preflight: {iterations: 1, final_status: "clear"}` before `execution_status`.
- Design cycle: R1 to R5 as today with the at-most-one-return rule.
- Executor hook: an execution run whose output carries `BLOCKED at preflight (before [P0-T1])`, a plan delta and no checked task is allowed; every other non-preflight `BLOCKED` stays non-repairable.
- Surfaces: orchestrate `## Remediation Loop (R1–R5)` and `## Remediation Loop — CI-Failure Handling`, `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, `.claude/agents/orchestrator.md`, `.codex/prompts/feature-review-remediate.md`, and the Codex and Copilot mirrors in the File Inventory.

### 6. Validation (D15)

- Every validator and hook change has tests (File Inventory, Tests).
- The #962 re-plan is **orchestrator-owned**, because the executor has no `Agent` tool. The orchestrator snapshots #962's `spec.md` with `git show` from `origin/main` if #962 has merged, otherwise from `origin/bug/ci-skip-evidence-only-commits-962`, into `<FEATURE>/evidence/other/replan-962/spec.md`; delegates one planner run and one preflight run non-isolated from the item worktree (so the branch hooks apply); validates with the Python CLI; and writes `<FEATURE>/evidence/other/replan-962/summary.<timestamp>.md` recording source ref, lines and tasks of the original and the re-plan, G11/G12/G13 results, validator result, preflight signal and fix count. #962's folder is not modified.

## Mirror and Parity Obligations

- Brief, byte-identical: `.claude/skills/execution-environment/SKILL.md`; `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`; `.agents/skills/execution-environment/SKILL.md`; `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`; `.github/skills/execution-environment/SKILL.md`; `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`.
- Every edited or new `.claude` file has an equal-text copy under `extensions/drm-copilot/resources/claude-customizations/.claude/`; the new skill and `premortem-section.ps1` are listed in the Claude `core.json` pack manifest; the new skill is listed in the Codex `core.json` pack manifest, normalized by `scripts/dev_tools/generate_codex_agent_variants.py`.
- Codex base agents are hand-edited; the `-c1`, `-c2`, `-c3`, `-c3-elevated`, `-c4` variants and bundle copies are regenerated by one generator run and verified with `--check`.
- `.agents` and `.github` skill and agent edits each have their bundle copy.
- Python and TypeScript G11 to G13: verbatim message parity (including an apostrophe-bearing value), severity-constant parity, and no `repr(`/`!r`/`pythonRepr(` in the new modules.
- Mirror copies are made by a `sh` copy script, which also keeps bundle `.ps1` copies outside the `Write|Edit` batch-budget matcher.

## File Inventory

"(new)" marks a new file. `<CB>` is `extensions/drm-copilot/resources/claude-customizations`, `<XB>` is `extensions/drm-copilot/resources/codex-and-agents-customizations`, `<GB>` is `extensions/drm-copilot/resources/customizations`. Each Claude, `.agents` and `.github` entry includes its bundle copy under the matching prefix.

- **Brief:** `.claude/skills/execution-environment/SKILL.md` (new), `.agents/skills/execution-environment/SKILL.md` (new), `.github/skills/execution-environment/SKILL.md` (new), `<CB>/pack-manifests/core.json`, `<XB>/pack-manifests/core.json`, `docs/engineering/claude-code-architecture.md`.
- **Claude agents:** `.claude/agents/atomic-executor.md`, `.claude/agents/atomic-planner.md`, `.claude/agents/task-researcher.md`, `.claude/agents/orchestrator.md`.
- **Claude skills and rules:** `.claude/skills/atomic-plan-contract/SKILL.md`, `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, `.claude/skills/research-issue/SKILL.md`, `.claude/skills/epic-plan/SKILL.md`, `.claude/rules/plan-acceptance-gates.md`.
- **Claude hooks:** `.claude/hooks/premortem-section.ps1` (new), `.claude/hooks/validate-planner-output.ps1`, `.claude/hooks/validate-task-researcher-output.ps1`, `.claude/hooks/validate-executor-output.ps1`.
- **Plan validators:** `scripts/dev_tools/plan_gate_document.py` (new), `scripts/dev_tools/plan_gate_discrimination.py`, `extensions/drm-copilot/src/lib/validate/plan-gate-document.ts` (new), `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts`, `extensions/drm-copilot/jest.config.cjs` (per-file `coverageThreshold` entry for `plan-gate-document.ts`, `lines: 85`, `branches: 75`, no comment).
- **Codex:** `.codex/agents/atomic-executor.toml`, `.codex/agents/atomic-planner.toml`, `.codex/agents/task-researcher.toml`, `.codex/agents/orchestrator.toml`; generated variants and `<XB>/.codex/agents/` copies; `.agents/skills/{atomic-plan-contract,orchestrate,remediation-handoff-atomic-planner,atomic-executor,atomic-planner,research-issue}/SKILL.md`; `.codex/prompts/feature-review-remediate.md`.
- **Copilot:** `.github/agents/atomic_executor.agent.md`, `.github/agents/atomic_planning.agent.md`, `.github/agents/task-researcher.agent.md`, `.github/agents/orchestrator.agent.md`, `.github/skills/atomic-plan-contract/SKILL.md`, `.github/skills/remediation-handoff-atomic-planner/SKILL.md`, `.github/prompts/generate-atomic-plan.prompt.md`.
- **Templates:** `docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md`, `docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md`, `docs/features/templates/refactor/plan.yyyy-MM-ddTHH-mm.md`.
- **Tests (new):** `tests/scripts/dev_tools/test_plan_gate_document.py`, `tests/scripts/dev_tools/test_plan_gate_document_parity.py`, `tests/scripts/dev_tools/test_plan_gate_document_docs.py`, `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`, `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py`, `extensions/drm-copilot/test/lib/validate/plan-gate-document.test.ts`, `extensions/drm-copilot/test/lib/validate/plan-gate-document-parity.test.ts`, `tests/scripts/claude-hooks/premortem-section.Tests.ps1`, `tests/scripts/claude-hooks/validate-planner-output.PreMortem.Tests.ps1`, `tests/scripts/claude-hooks/validate-task-researcher-output.PreMortem.Tests.ps1`, `tests/scripts/claude-hooks/validate-executor-output.Preflight.Tests.ps1`.
- **Tests (modified):** `tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`, `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py`, `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`, `tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1`, `tests/scripts/claude-hooks/validate-planner-output.Reentry.Tests.ps1` (valid fixtures gain `## Pre-Mortem`), `tests/scripts/claude-hooks/validate-executor-output.Tests.ps1` (only cases that depend on plan-directive detection).
- **Evidence:** under `docs/features/active/2026-10-16-planning-process-churn-964/evidence/` (`baseline/`, `qa-gates/`, `regression-testing/`, `other/`, including `other/replan-962/`).

## Constraints

- **500-line limit:** every touched non-Markdown file stays at or below 500 physical lines, measured with `wc -l` or `@(Get-Content -LiteralPath <path>).Count`, not `Measure-Object -Line`. Near-limit touched files: `extensions/drm-copilot/jest.config.cjs` (489 lines before the change), `.claude/hooks/validate-planner-output.ps1` (442), `scripts/dev_tools/plan_gate_discrimination.py` (405). Near-limit files are listed under Files deliberately not touched.
- **Batch budget:** the item touches more than the direct-mode cap of PowerShell production files, so execution runs in the item worktree under a non-terminal checkpoint whose route is `large`, `preparation` or `remediation`; bundle copies are written by the `sh` copy script.
- **Hooks are not Python:** hook changes are PowerShell only (`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`).
- **No temporary files in tests:** hook tests use injected readers and in-memory transcript text.
- **No absolute paths** in any artifact; scratch is recorded as the token `SCRATCH`.
- **No line numbers or commit SHAs** in the brief, contract text, or this item's plan; the plan carries `## Size Justification` if it exceeds the G13 guideline (generated files count as one generator task).

## Concurrency

- #952 edits `.claude/skills/orchestrate/SKILL.md` and its bundle mirror in `## Step S9 — CI Green Gate` and `## PR Creation Gate`. This item edits `## Prerequisites`, `## Preparation Mode`, `## Pre-Feature-Review Commit` and the two remediation sections. The overlap is tolerated: a textual merge is expected, and the bundle mirror is re-copied after merging.
- #953 shards `_poshqc.yml` and #962 gates workflows; neither touches this item's files. The brief describes both `_poshqc.yml` shapes by job name.
- #935: no overlap found.

## Pre-Mortem

- Review checklists: about a hundred changed files, mostly prose, across three surfaces. The final phase writes the self-review against all three templates, including tonality of every new contract sentence.
- Coverage: `plan_gate_document.py` measured by module with branch figures from `coverage.json`; `plan-gate-document.ts` gated by its own `jest.config.cjs` entry; PowerShell hook changes measured line-only from the self-hosted PoshQC coverage XML; transcript and file reads go through seams so logic is exercised rather than mocked away.
- Mirror parity: bundle copies, pack manifests, Codex generator `--check`, `.agents` resource contracts and brief byte identity are all run in the QA phase after one copy-script run.
- File size: the three near-limit touched files are measured before and after; no logic is added to the files deliberately not touched.
- Test isolation: one seeded shuffled Jest run (seed recorded), one reversed-order run of the new Python modules, one single-process Pester run over `tests/scripts`; Linux-run hook suites use `Join-Path` and no drive-letter paths.
- CI-only behavior: no test reads gitignored `artifacts/` state or `origin/main`; no CRLF or backslash fixtures; the helper survives the single-process Pester run; new skills contain no `vitest` and no `npm run` token absent from `package.json`.
- Evidence: baselines, QA gates, isolation runs, the G11 to G13 corpus measurement, the self-review and the #962 re-plan summary are written under `<FEATURE>/evidence/<kind>/` with clock-read UTC stamps.

## Acceptance Criteria

### Scope 1: Execution-environment brief

- [ ] AC-1: `.claude/skills/execution-environment/SKILL.md` exists with every required heading listed in Design scope item 1, and the `plan_gate_document` G11 and G12 evaluators report no finding on its text. Verified by `test_execution_environment_brief_contracts.py`.
- [ ] AC-2: The brief states the worktree isolation guard as Claude Code runtime behavior separate from repository hooks, states that `atomic-executor` has no PowerShell tool and names the PoshQC MCP and `sh` launcher routes, and states that PoshQC MCP results carry no output and where counts come from. Verified by `test_execution_environment_brief_contracts.py`.
- [ ] AC-3: The brief's `## Batch Budget` section states the direct-mode cap, the denial codes, the large/remediation/preparation exemption, that bundle copies count, that in-root scratch `.ps1` files count and `SCRATCH` files do not, and that Bash- or generator-written files are not seen. Verified by `test_execution_environment_brief_contracts.py`.
- [ ] AC-4: The brief's `## CI Shape and Required Checks` names the Linux hook-suite job, the PoshQC shard jobs with the `poshqc / PowerShell QC` aggregator, `merge_group`, and each ruleset 15241672 required context listed in Design scope item 1. Verified by `test_execution_environment_brief_contracts.py`.
- [ ] AC-5: All copies listed under Mirror and Parity Obligations are byte-identical, both pack manifests list the skill, and `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py` and both pack-manifest completeness tests pass.
- [ ] AC-6: `task-researcher`, `atomic-planner`, `atomic-executor` and `orchestrator` preload `execution-environment` through `skills:`; the Codex base agents named in the File Inventory list it; the Copilot base agents named in the File Inventory reference it; orchestrate `## Prerequisites` references it; `docs/engineering/claude-code-architecture.md` has a mirror-table row; `.claude/agents/epic-orchestrator.md` is unchanged. Verified by `test_execution_environment_brief_contracts.py` and the generator `--check`.
- [ ] AC-7: `.claude/agents/task-researcher.md` declares `skills:` containing `evidence-and-timestamp-conventions` and `execution-environment`, and its `tools:` no longer lists a skill name; `test_every_agent_preloaded_skill_resolves_to_an_existing_skill_file` passes.

### Scope 2: Design-level plan contract

- [x] AC-8: G11 reports one Blocking finding per prose, path and anchor form match, and none for `500 lines`, inline-code quotations in prose form, URLs with ports, or fenced blocks. Verified by `test_plan_gate_document.py` and `plan-gate-document.test.ts`.
- [x] AC-9: G12 reports full and abbreviated SHAs in prose and inline code, and none for decimal IDs, all-letter hex words, UUID segments, `-`/`_`-joined suffixes, SHA-256 digests, or fenced blocks. Verified by `test_plan_gate_document.py` and `plan-gate-document.test.ts`.
- [x] AC-10: G13 fires above 40 tasks or above 400 lines without a non-empty `## Size Justification`, does not fire at the thresholds, and does not fire above them when a non-empty justification is present; an empty justification section does not exonerate. Verified by `test_plan_gate_document.py` and `plan-gate-document.test.ts`.
- [x] AC-11: `evaluate_plan_gates` and `evaluatePlanGates` run G11 to G13 after G10; Python and TypeScript produce byte-identical messages for the parity rows, `G11_SEVERITY`, `G12_SEVERITY` and `G13_SEVERITY` are Blocking in both, and the new modules contain no `repr(`, `!r` or `pythonRepr(`. Verified by `test_plan_gate_document_parity.py` and `plan-gate-document-parity.test.ts`; all existing plan-gate tests pass unchanged.
- [ ] AC-12: `.claude/rules/plan-acceptance-gates.md` and its bundle copy state G1 through G13 with severity sections, false-positive classes and the corpus-measurement note, and are byte-identical. Verified by `test_plan_gate_document_docs.py` and the updated `test_plan_gate_scratch_docs.py`.
- [ ] AC-13: `atomic-plan-contract` (Claude, `.agents`, `.github` and bundle copies) contains `## Design-Level Plan Contract (Mandatory)`, uses symbol, heading or test locators in the self-review and internal-review record, and states G1 through G13 under `## Validator Gate (Mandatory)`. Verified by `test_plan_gate_document_docs.py`.
- [ ] AC-14: `validate-planner-output.ps1` issues a repairable block for a plan without a valid `## Pre-Mortem` section and for a `CITATION:` line-reference locator, and passes a plan with both correct. Verified by `validate-planner-output.PreMortem.Tests.ps1`; the modified planner suites pass.
- [x] AC-15: A corpus measurement of G11, G12 and G13 finding counts over committed plans under `docs/`, with observed false-positive classes, is recorded under `evidence/other/`.
- [ ] AC-16: `plan_gate_document.py` and `plan-gate-document.ts` each reach at least 85% line and 75% branch coverage, with a `jest.config.cjs` per-file threshold entry for the TypeScript module, recorded under `evidence/qa-gates/`.

### Scope 3: Single-pass preflight

- [ ] AC-17: `Test-IsPreflightRun` classifies a run as preflight when the transcript's first user entry carries the directive, as execution when it does not even if the plan file carries the directive (completion checks then enforced), and falls back to the plan-file or single `PREFLIGHT:` signal check when the transcript is absent or unparseable. Verified by `validate-executor-output.Preflight.Tests.ps1` with in-memory transcript content.
- [ ] AC-18: In a preflight run the executor hook blocks (repairably) zero or multiple `PREFLIGHT:` signals, `ALL CLEAR` with a `PREFLIGHT-DEFECT:` line, `REVISIONS REQUIRED` without one, and `PREFLIGHT-FIX:` without an existing `preflight-fix-record:` path under `docs/features/`. Verified by `validate-executor-output.Preflight.Tests.ps1`.
- [ ] AC-19: `atomic-plan-contract`, `atomic-executor.md` and `atomic-planner.md` (and their mirrors) state one-pass review (keeping "Review the entire plan in one pass"), the trivial/substantive classes, the `PREFLIGHT-FIX:`, `PREFLIGHT-DEFECT:` and `preflight-fix-record:` formats, task-text-only fixes, and that the directive belongs in the delegation prompt and not in plan files. Verified by `test_single_pass_preflight_contracts.py`.
- [ ] AC-20: The at-most-one-return rule and the `validator_failed` halt are stated in orchestrate (preparation and S4 planning) and `atomic-planner.md`; `remediation-handoff-atomic-planner` keeps `preflight.iterations > 1`; `epic-plan` references the single-pass rule. Verified by `test_single_pass_preflight_contracts.py`.
- [ ] AC-21: `.codex/agents/atomic-executor.toml` and `.github/agents/atomic_executor.agent.md` no longer contain loop-until-clear or automatic re-handoff mandates and state the single-pass rules; `test_codex_agent_wrapper_contracts.py` (updated) and `test_codex_handoff_contract_parity.py` pass.
- [ ] AC-22: `atomic-planner` and `atomic-executor` list `mcp__drm-copilot__validate_orchestration_artifacts` in `tools:`, the executor keeps its existing `mcp__drm-copilot__run_poshqc_*` entries and `## Scratch Location` text, and `claude-architecture-doc.Tests.ps1` and `test_scratch_location_contracts.py` pass.

### Scope 4: Pre-mortem and self-review

- [ ] AC-23: `Test-PreMortemSection` rejects a missing heading and each missing label, accepts case-insensitive labels and "not applicable" with a reason; both hooks load it with the guarded pattern; the helper and its bundle copy are listed in the Claude pack manifest. Verified by `premortem-section.Tests.ps1` and `hook-dependency-guard-completeness.Tests.ps1`.
- [ ] AC-24: `validate-task-researcher-output.ps1` requires the section for research under `docs/features/` and not under `docs/research/`; `task-researcher.md` and `research-issue` require the section in feature research. Verified by `validate-task-researcher-output.PreMortem.Tests.ps1` and `test_single_pass_preflight_contracts.py`.
- [ ] AC-25: The bug, feature and refactor plan templates contain a `## Pre-Mortem` skeleton with each label, and `atomic-plan-contract` requires a final-phase self-review task. Verified by `test_single_pass_preflight_contracts.py`.
- [ ] AC-26: Orchestrate `## Pre-Feature-Review Commit` begins with the self-review check (newest `self-review.*.md` exists with no FAIL row, else a proportionate correction). Verified by `test_single_pass_preflight_contracts.py`.

### Scope 5: Proportionate remediation

- [ ] AC-27: Orchestrate remediation sections, `remediation-handoff-atomic-planner`, `orchestrator.md`, `feature-review-remediate.md` and their mirrors define `Remediation-Mode: proportionate|design`, the classification rule, the proportionate cycle shape and the conversion to design mode. Verified by `test_single_pass_preflight_contracts.py`.
- [ ] AC-28: The executor hook allows an execution run carrying `BLOCKED at preflight (before [P0-T1])`, a plan delta and no checked task, and keeps every other non-preflight `BLOCKED` non-repairable. Verified by `validate-executor-output.Preflight.Tests.ps1`.

### Scope 6: Validation and quality gates

- [ ] AC-29: The full toolchain (format, lint, type-check, architecture, unit, contract, integration) passes for Python, TypeScript and PowerShell in one pass, including the generator `--check`, `test_push_down_issue_824_follow_ups.py` and `test_typescript_toolchain_instruction_contracts.py`, recorded under `evidence/qa-gates/`.
- [ ] AC-30: The seeded shuffled Jest run (seed recorded), reversed-order Python run and single-process Pester run over `tests/scripts` pass, recorded under `evidence/regression-testing/`.
- [ ] AC-31: Every touched non-Markdown file is at or below 500 physical lines, recorded under `evidence/qa-gates/`.
- [ ] AC-32: `evidence/qa-gates/self-review.<timestamp>.md` for this item covers the policy-audit, code-review and feature-audit templates and records no FAIL row before the first review push.
- [ ] AC-33 (orchestrator-owned): `evidence/other/replan-962/spec.md` and `summary.<timestamp>.md` exist; the summary records the source ref, the original and re-plan line and task counts, no G11 or G12 finding, G13 within guideline or a justification present, a passing Python CLI validation, a first preflight of `PREFLIGHT: ALL CLEAR` (in-place fixes permitted), and a re-plan smaller than the original in both lines and tasks. #962's folder is unmodified.
- [ ] AC-34 (pending-CI, orchestrator-owned at S9): every ruleset 15241672 required context succeeds on the final PR head.

## Risks

- The subagent transcript JSONL format is not a documented contract. The reader is behind a seam and degrades to the self-declared fallback rather than blocking.
- Ruleset 15241672 contexts were confirmed on 2026-10-16; if #952 or #953 merges first and changes job names, the brief is refreshed in this item before merge.
- G11 and G12 will flag plans authored before release when re-validated; the trivial-fix path absorbs them in one preflight.
- The #962 re-plan depends on agent behavior. A substantive first-preflight defect is a finding about the contract and is handled by one proportionate correction in this item, not by a new issue.
- Branch hooks are not exercised by isolated subagents until merge; hook behavior is proven by Pester and the re-plan is delegated non-isolated.
- The MCP validator applies G11 to G13 only after release and install; in-item validation uses the Python CLI.
- A textual merge with #952 in the orchestrate skill is expected; the bundle mirror is re-copied afterwards.
