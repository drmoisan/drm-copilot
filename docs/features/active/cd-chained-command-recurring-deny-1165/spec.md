# cd-chained-command-recurring-deny (Spec)

- **Issue:** #1165
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-09T23-10
- **Status:** Implemented
- **Version:** 0.2
- **Work Mode:** full-bug (this file is the only acceptance-criteria source; no `user-story.md`)
- **Inputs:** `issue.md`, `research/research.2026-11-09T22-58.md`, `.claude/skills/execution-environment/SKILL.md`; orchestrator decisions D-1165-4 and D-1165-5.

## Context
- Summary: agents across the fleet repeatedly hit the Claude `validate-bash.ps1` deny `Forbidden Bash pattern: 'cd ... && <read command>' (or ';'-chained)`. The deny is correct, but its message names only "use an absolute path for the read", the playbook names no replacement forms, and agents not briefed with the `execution-environment` skill never see the restriction before their first Bash call.
- Observed environment(s): Claude Code sessions in this repository and in push-down destination repositories; agent-isolated worktrees and non-isolated agents working in a sibling worktree whose Bash working directory resets to the session root on each call.
- Customer impact and severity: every agent that needs to run a tool in another directory loses at least one tool round to the deny and frequently repeats it; the owner receives a recurring fleet notice ("3 agents hit the same failure ..."). No data loss; the impact is wasted rounds and operator attention.
- First observed date and version(s) impacted: reported by the owner on 2026-11-09 as recurring over several days; the coordinator session hit the same deny on 2026-11-09. All versions that carry the cd-chained leg in `.claude/hooks/validate-bash.ps1`.

## Repro & Evidence
- Steps to reproduce: pass either command to `Get-BashBlockReason` in `.claude/hooks/validate-bash.ps1` (or issue it as a Claude Code Bash call):
  1. `cd <dir> && git status --short && git log --oneline -3 && cat <file>`
  2. `cd <dir> && env -u VIRTUAL_ENV poetry install --no-interaction 2>&1 | tail -n 20`
- Expected vs actual behavior: expected is the same deny decision with a reason that names the replacement form for the detected intent (`git -C`, `poetry -C`, `npm --prefix`, absolute-path read, or a `sh` script under `SCRATCH`). Actual is a reason whose only remedy is "Rewrite as a single command using an absolute path instead of 'cd'-ing first", which does not address running `git` or `poetry` in another directory.
- Logs/screenshots/error snippets: current reason text is quoted verbatim in the research record, section 1.1.
- Frequency / determinism: deterministic for any command where a `cd` segment is followed later by a `grep|cat|head|tail|less|more|awk|sed -n` segment. Shape 2 matches only because of the trailing `| tail` filter (research section 2.1); the `env`-wrapped Poetry call alone does not match.
- Recurrence count: the repository hooks log no denials, so no repository count is available. A host-local transcript search recorded in the research record (section 6) found an approximate, non-deduplicated, non-reproducible figure; it may be cited only as context, with a path-free description.

## Scope & Non-Goals
- In scope:
  - Claude-only pure guidance helper `.claude/hooks/bash-command-shape-guidance.ps1`, dot-sourced (guarded) by `.claude/hooks/validate-bash.ps1`, that selects the deny-message guidance by detected intent. Only the guidance text of the cd-chained reason changes.
  - A launch-loaded command-shape rule on all three surfaces: `.claude/rules/bash-command-shape.md` (no `paths:`), `.agents/skills/bash-command-shape/SKILL.md` (Codex), `.github/instructions/bash-command-shape.instructions.md` (Copilot, `applyTo: "**"`, new file), each with its push-down bundle copy and manifest entry where a manifest applies.
  - The intent-to-form table in `## Command-Text Restrictions` and one sentence in `## Worktree Python Environment` of all six byte-identical `execution-environment/SKILL.md` copies, including correction of the claim that `.codex/hooks/validate-bash.ps1` carries the cd-chained deny.
  - The `WORKTREE_VENV_BLOCKED:` reason in every `worktree-poetry-venv-policy.ps1` copy gains the `poetry -C <worktree root>` form.
  - `.claude/skills/parallel-orchestrate/SKILL.md` and its bundle copy: the `git -C <worktree_path> reset --hard HEAD~1` instruction, which `validate-bash.ps1` denies, is replaced, and the conflict-resolution step references the brief table.
  - Recurrence measurement record (no repository count available).
- Out of scope / non-goals:
  - Any change to the allow/deny decision set, `$script:CdChainedReadCommandPattern`, `$script:CdChainedReadCommandWords`, `Get-CdChainedReadCommandMatch`, the destructive-pattern legs, or the leading `Forbidden Bash pattern:` token.
  - Any change to `.codex/hooks/validate-bash.ps1` or its bundle copy. It has no cd-chained leg by decision #545; adding one would add a deny.
  - D-1165-5: making the existing `paths: - "**"` rules (`general-code-change.md`, `general-unit-test.md`, `quality-tiers.md`, `tonality.md`) launch-loaded. Recorded for the owner; not changed here. The related `UNCONDITIONAL_GLOBS` treatment in `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` and the Codex converter classification (`has_repo_wide_paths_yaml`) are likewise unchanged.
  - Adding denial logging to any hook.
- Explicitly excluded systems, integrations, or datasets:
  - Root `AGENTS.md` and its bundle copy (converter output, not distributed by the Codex push-down).
  - Existing policy files `.github/copilot-instructions.md` and `.github/instructions/*.instructions.md` other than the new file.
  - Every `execution-environment/SKILL.md` section other than `## Command-Text Restrictions` and `## Worktree Python Environment` (#1158 edits the same file).
  - Hook registration structure (#1159).

## Root Cause Analysis
- Confirmed root cause:
  1. The deny reason in `Get-BashBlockReason` offers one remedy (absolute-path read) regardless of intent; the common intent is running `git`, `poetry`, or `npm` in another directory.
  2. `## Command-Text Restrictions` lists the restriction but no replacement forms, and does not state the isolated-worktree versus sibling-worktree split as an instruction.
  3. No rule loads before an agent's first Bash call: every `.claude/rules/*.md` file carries `paths:`, and path-scoped rules load only on a Read, Write, or Edit of a matching file.
  4. Contributing drivers: the `WORKTREE_VENV_BLOCKED:` reason and the brief's `## Worktree Python Environment` say "from the worktree root run ...", which a non-isolated agent reads as "cd first"; `parallel-orchestrate` instructs a `git -C ... reset --hard` that `validate-bash.ps1` denies.
- Signals/evidence: research record sections 1.1, 2.1, 3.1, 5 (verified by reading the sources and the Claude Code memory and sub-agents documentation on 2026-11-09).
- Affected components: `.claude/hooks/validate-bash.ps1`; `.claude/hooks/worktree-poetry-venv-policy.ps1` and `.codex/hooks/worktree-poetry-venv-policy.ps1`; the `execution-environment` brief copies; `.claude/skills/parallel-orchestrate/SKILL.md`; `.claude/rules/`; push-down bundles under `extensions/drm-copilot/resources/`.

## Proposed Fix

### Design summary (what changes where):
- New pure helper `.claude/hooks/bash-command-shape-guidance.ps1` defines `Get-CdChainedCommandIntent` and `Get-CdChainedRewriteGuidance`. `validate-bash.ps1` dot-sources it with the guarded single-statement form and `Get-BashBlockReason` replaces only the final "Rewrite as a single command ..." sentence of the cd-chained reason with the helper's guidance.
- New launch-loaded rule and its Codex and Copilot equivalents carry the command-shape rule and the intent-to-form table split by context.
- Brief, venv reason, and `parallel-orchestrate` text updated as listed in Scope.

### Boundaries and invariants to preserve:
- The deny decision for every command is unchanged; the destructive reasons are byte-unchanged.
- The cd-chained reason keeps its first two sentences byte-unchanged, so it still starts with `Forbidden Bash pattern: 'cd ... && <op>' (or ';'-chained).` and still contains `Read()`.
- `.codex/hooks/validate-bash.ps1` is not edited.
- The `WORKTREE_VENV_BLOCKED:` prefix and the substrings `env -u VIRTUAL_ENV poetry install` and `never repoint the main checkout's environment` are retained.
- The six brief copies stay byte-identical; heading order is unchanged.

### Dependencies or blocked work:
- #1158 edits a different section of the same brief; edits here are confined to two sections to keep hunks non-adjacent.
- #1159 may restructure hook registration; this change adds no registration.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- New: `.claude/hooks/bash-command-shape-guidance.ps1`; `.claude/rules/bash-command-shape.md`; `.agents/skills/bash-command-shape/SKILL.md`; `.github/instructions/bash-command-shape.instructions.md`; each with its bundle copy under `extensions/drm-copilot/resources/` (`claude-customizations/`, `codex-and-agents-customizations/`, `customizations/`).
- Edited: `.claude/hooks/validate-bash.ps1` and bundle copy; every `worktree-poetry-venv-policy.ps1` copy; the six `execution-environment/SKILL.md` copies; `.claude/skills/parallel-orchestrate/SKILL.md` and bundle copy; `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`; `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`.
- Tests: new `tests/scripts/claude-hooks/bash-command-shape-guidance.Tests.ps1` and `tests/scripts/claude-hooks/validate-bash.CdChainGuidance.Tests.ps1`; updated `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` and `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` (test-only Python edits; no new Python production code).

#### Functions/classes/CLI commands impacted:
- New `Get-CdChainedCommandIntent -Command <string> -ReadOp <string>` returning `[pscustomobject]@{ ReadOp; CdTarget; Tools; IsMultiStep }` (`Tools` is the ordered distinct subset of `git`, `poetry`, `npm`, `npx` after the `cd`, including tools behind wrapper-led segments such as `env`; `IsMultiStep` is `Tools.Count -ge 2`).
- New `Get-CdChainedRewriteGuidance -Intent <pscustomobject>` returning the guidance text.
- `Get-BashBlockReason`: final sentence of the cd-chained reason only.

#### Data flow and validation changes:
- Detection is unchanged: `Get-CdChainedReadCommandMatch` decides; the helper runs only after a match to build text.

#### Error handling and logging updates:
- A helper load failure is recorded through `Add-HookDependencyFailure` and produces the existing `HOOK_DEPENDENCY_LOAD_FAILED:` deny, as for the other dependencies. No logging is added.

#### Rollback/feature-flag considerations (if applicable):
- Revert the change set; no state or configuration is introduced.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Hook output envelope (`hookSpecificOutput.permissionDecision` / `permissionDecisionReason`) unchanged in shape; only the reason text of cd-chained denials changes.

#### Required configuration keys and defaults:
- None. The new rule has frontmatter `description:` and no `paths:` key; the Copilot instruction has `applyTo: "**"`, `name:`, and `description:`.

#### Backward-compatibility expectations:
- No repository consumer parses the reason beyond the Pester substrings listed in research section 8; those remain satisfied.

#### Performance constraints (latency/throughput/memory):
- The helper runs only on a cd-chained match and performs string work over the already-split segments; no additional process or file I/O.

## Assumptions, Constraints, Dependencies
- Assumptions: Claude Code loads `.claude/rules/*.md` files without `paths:` at launch for the main session and for custom subagents (documented behavior, research section 3.1). Copilot `applyTo: "**"` application to requests without file context is unverified.
- Constraints: pushed-down code is PowerShell or bash; no new Python. Test runs are parallel-only. Evidence is append-only. Claude, Codex, and Copilot surfaces and their push-down mirrors stay consistent.
- External dependencies: none.

## Data / API / Config Impact
- User-facing changes: cd-chained deny reason text; `WORKTREE_VENV_BLOCKED:` reason text; new always-loaded guidance on each surface.
- Data or migration: none.
- Logging/telemetry: none.
- Compatibility: pack manifests gain entries for the new Claude rule, Claude helper, and Codex skill.

## Test Strategy
- Regression tests: `tests/scripts/claude-hooks/validate-bash.CdChainGuidance.Tests.ps1` (table-driven decision corpus plus reason-shape assertions), with a baseline run of the same file against the unedited hook recorded before the hook edit.
- Unit tests (Pester 6) for the fixed behavior: `tests/scripts/claude-hooks/bash-command-shape-guidance.Tests.ps1` over pure strings.
- Edge cases: empty and null input; wrapper-led raw leg (`bash -c "cd /x && git log | head"`); tool behind `env`; npx without a package script form; `CdTarget` extraction from both legs.
- Error handling: helper dependency failure covered by `hook-dependency-guard-completeness.Tests.ps1` (S1 to S6) and the existing dependency-failure suites.
- Coverage: the helper is in the coverage population through `config/poshqc-coverage.json`; line coverage target 85% (root `CLAUDE.md` states no threshold; Pester has no branch gate).
- Toolchain: `Invoke-Formatter` and PSScriptAnalyzer on changed PowerShell; one `Invoke-PoshQCParallelTest` run; `Invoke-PoshQCLeakScan`; `pytest -n auto` over the touched Python test modules and the push-down contract suites; `generate_codex_agent_variants.py --check`.
- Manual validation: byte comparison of the Copilot instruction and its bundle copy (no parity test exists).

## Acceptance Criteria

### Deny message by intent (`.claude/hooks/validate-bash.ps1`, `.claude/hooks/bash-command-shape-guidance.ps1`)
- [x] `.claude/hooks/bash-command-shape-guidance.ps1` exists, defines `Get-CdChainedCommandIntent` and `Get-CdChainedRewriteGuidance`, dot-sources nothing, and is dot-sourced by `.claude/hooks/validate-bash.ps1` in a single-statement `try` whose `catch` calls `Add-HookDependencyFailure -Name 'bash-command-shape-guidance.ps1'`; `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` passes S1 to S6 on the repository root and the Claude bundle root.
  - Evidence: `evidence/qa-gates/pester-gate.2026-11-10T00-54.md` (hook-dependency-guard-completeness.Tests.ps1 731 of 731; helper parse-check test)
- [x] `tests/scripts/claude-hooks/bash-command-shape-guidance.Tests.ps1` asserts that `Get-CdChainedCommandIntent` returns `Tools` empty and `IsMultiStep` false for `cd /x && cat f`; `Tools = git` for `cd /repo/wt && git status --short && git log --oneline -3 && cat f`; `Tools = poetry` for `cd /repo/wt && env -u VIRTUAL_ENV poetry install --no-interaction 2>&1 | tail -n 20`; `Tools = npm` for an `npm` chain and `Tools = npx` for an `npx` chain; `IsMultiStep` true for a chain containing both `git` and `poetry`; `CdTarget` equal to the `cd` argument for both the walk leg and the wrapper-led raw leg (`bash -c "cd /x && git log | head"`); and a defined result without an exception for empty and `$null` input.
  - Evidence: `evidence/qa-gates/pester-gate.2026-11-10T00-54.md` (bash-command-shape-guidance.Tests.ps1, 22 of 22)
- [x] Plain read intent: for `cd /x && cat f`, the reason returned by `Get-BashBlockReason` contains `Read or Grep tool` and `against the absolute path`, and contains none of `git -C`, `poetry -C`, `npm --prefix`, or `sh <SCRATCH>/`; asserted in `tests/scripts/claude-hooks/validate-bash.CdChainGuidance.Tests.ps1`.
  - Evidence: `evidence/qa-gates/pester-gate.2026-11-10T00-54.md` (validate-bash.CdChainGuidance.Tests.ps1 reason-shape Context, 8 of 8)
- [x] git intent: for `cd /repo/wt && git status --short && git log --oneline -3 && cat f`, the reason contains `git -C <abs>` and `/repo/wt`, and does not contain `sh <SCRATCH>/`; asserted in `validate-bash.CdChainGuidance.Tests.ps1`.
  - Evidence: `evidence/qa-gates/pester-gate.2026-11-10T00-54.md` (validate-bash.CdChainGuidance.Tests.ps1 reason-shape Context, 8 of 8)
- [x] poetry intent: for `cd /repo/wt && env -u VIRTUAL_ENV poetry install --no-interaction 2>&1 | tail -n 20`, the reason contains `poetry -C <abs>`, `--directory`, and `env -u VIRTUAL_ENV`; asserted in `validate-bash.CdChainGuidance.Tests.ps1`.
  - Evidence: `evidence/qa-gates/pester-gate.2026-11-10T00-54.md` (validate-bash.CdChainGuidance.Tests.ps1 reason-shape Context, 8 of 8)
- [x] npm/npx intent: for an `npm` chain ending in a read command, the reason contains `npm --prefix <abs>`; for an `npx` chain ending in a read command, the reason contains both `npm --prefix <abs> run <script>` and `sh <SCRATCH>/<file>.sh`; asserted in `validate-bash.CdChainGuidance.Tests.ps1`.
  - Evidence: `evidence/qa-gates/pester-gate.2026-11-10T00-54.md` (validate-bash.CdChainGuidance.Tests.ps1 reason-shape Context, 8 of 8)
- [x] Multi-step intent: for a chain containing both `git` and `poetry` before a read command, the reason contains `sh <SCRATCH>/<file>.sh`, `git -C <abs>`, and `poetry -C <abs>`; asserted in `validate-bash.CdChainGuidance.Tests.ps1`.
  - Evidence: `evidence/qa-gates/pester-gate.2026-11-10T00-54.md` (validate-bash.CdChainGuidance.Tests.ps1 reason-shape Context, 8 of 8)
- [x] Every cd-chained reason (all intents above) starts with `Forbidden Bash pattern: 'cd ... && <op>' (or ';'-chained).` for its matched `<op>`, keeps the second sentence byte-unchanged (including `Read()`), contains `.claude/rules/bash-command-shape.md`, `Command-Text Restrictions`, `agent-isolated worktree`, and `sibling worktree`, and no longer contains `Rewrite as a single command using an absolute path instead of 'cd'-ing first`; asserted in `validate-bash.CdChainGuidance.Tests.ps1`.
  - Evidence: `evidence/qa-gates/pester-gate.2026-11-10T00-54.md` (validate-bash.CdChainGuidance.Tests.ps1 reason-shape Context, 8 of 8)
- [x] Decision regression: `validate-bash.CdChainGuidance.Tests.ps1` runs a table-driven corpus made of every command string in `tests/scripts/claude-hooks/validate-bash.Tests.ps1`, `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1`, and `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1` plus the intent cases above, and asserts that `[bool](Get-BashBlockReason -Command $c)` and `Get-CdChainedReadCommandMatch -Command $c` equal their pre-change values and that every destructive reason is byte-unchanged; a run of the same corpus against the unedited hook is recorded under `evidence/baseline/` before the hook edit, and the post-change run matches it.
  - Evidence: `evidence/baseline/pester-gate.2026-11-10T00-26.md` (60 of 60 before the hook edit), `evidence/qa-gates/pester-gate.2026-11-10T00-54.md` (60 of 60 after)
- [x] `$script:CdChainedReadCommandPattern`, `$script:CdChainedReadCommandWords`, and `Get-CdChainedReadCommandMatch` are textually unchanged in `.claude/hooks/validate-bash.ps1`, and `.codex/hooks/validate-bash.ps1` and its bundle copy are unmodified (`git diff main --` on those paths is empty).
  - Evidence: `evidence/qa-gates/scope-check.2026-11-10T00-57.md` (CHECK 2 and CHECK 7)
- [x] The existing suites `validate-bash.Tests.ps1`, `validate-bash.TriggerScoping.Tests.ps1`, `hook-command-consumers.Issue824.Tests.ps1`, `PreToolUseSchema.Contract.Tests.ps1`, `review-verdict-status.HookAllowance.Tests.ps1`, `hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.SpecialCases.Tests.ps1`, and the Codex `validate-bash-decision-surface`, `validate-bash-trigger-scoping`, `codex-pretooluse-integration`, `legacy-codex-hook-contracts`, and `hook-dependency-failure.Codex` suites pass without modification.
  - Evidence: `evidence/qa-gates/pester-gate.2026-11-10T00-54.md` (named suites, 0 failures), `evidence/qa-gates/scope-check.2026-11-10T00-57.md` (CHECK 1: none modified)

### Always-loaded rule on each surface
- [x] `.claude/rules/bash-command-shape.md` exists with frontmatter carrying `description:` and no `paths:` key, and its body states the command-shape rule (no `cd` chained before a read command), the intent-to-form table (plain read, `git -C <abs>`, `poetry -C <abs>` / `--directory`, `npm --prefix <abs>`, npx via `npm --prefix <abs> run <script>` or the `sh` route, multi-step via `sh <SCRATCH>/<file>.sh`), and the split between an agent-isolated worktree (no `cd`, plain tool call; `git -C <other worktree>` refused) and a non-isolated agent working in a sibling worktree (`-C` / `--prefix` / absolute-path forms or the `sh` route).
  - Evidence: `evidence/qa-gates/pytest-gate.2026-11-10T00-56.md` (test_rule_states_command_shape_rule_and_isolated_refusal, test_launch_loaded_rules_carry_description_and_no_paths_key)
- [x] `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` defines a launch-loaded rule set containing `bash-command-shape.md` that is exempt from the non-empty `paths:` requirement but must carry `description:` and must have no `paths:` key, includes the file in the deliberate unconditional set, and passes.
  - Evidence: `evidence/qa-gates/pytest-gate.2026-11-10T00-56.md` (test_claude_rules_frontmatter.py, 9 passed)
- [x] `.agents/skills/bash-command-shape/SKILL.md` exists, carries the same forms and context split, and states that the cd-chained deny is produced only on Claude Code while the shapes still apply to Codex sessions working across worktrees.
  - Evidence: `evidence/qa-gates/pytest-gate.2026-11-10T00-56.md` (test_codex_skill_frontmatter_source_and_claude_only_statement)
- [x] `.github/instructions/bash-command-shape.instructions.md` exists as a new file with `applyTo: "**"`, `name:`, and `description:` frontmatter and the same forms and context split; no existing file under `.github/instructions/` and no change to `.github/copilot-instructions.md` is part of the diff.
  - Evidence: `evidence/qa-gates/pytest-gate.2026-11-10T00-56.md` (test_copilot_instruction_frontmatter_is_always_loaded), `evidence/qa-gates/scope-check.2026-11-10T00-57.md` (CHECK 1)
- [x] Each new rule, skill, instruction, and helper file is byte-identical to its bundle copy under `extensions/drm-copilot/resources/` (`claude-customizations/`, `codex-and-agents-customizations/`, `customizations/` respectively); the Copilot pair is proven by an explicit byte comparison recorded under `evidence/`.
  - Evidence: `evidence/other/copilot-instruction-parity.2026-11-10T00-32.md`, `evidence/qa-gates/pytest-gate.2026-11-10T00-56.md` (push-down resource contract modules, test_copilot_instruction_matches_bundle_copy)
- [x] `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists `.claude/rules/bash-command-shape.md` and `.claude/hooks/bash-command-shape-guidance.ps1`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` lists `.agents/skills/bash-command-shape/SKILL.md`; `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_issue_824_follow_ups.py`, and `generate_codex_agent_variants.py --check` pass.
  - Evidence: `evidence/qa-gates/pytest-gate.2026-11-10T00-56.md` (the six push-down contract modules), `evidence/qa-gates/python-static.2026-11-10T00-40.md` (generator --check)

### Playbook, venv reason, and parallel-orchestrate
- [x] All six `execution-environment/SKILL.md` copies stay byte-identical (`test_brief_copies_are_byte_identical` passes), and in each the "Repository hooks" bullet of `## Command-Text Restrictions` no longer attributes the cd-chained deny or `Get-CdChainedReadCommandMatch` to `.codex/hooks/validate-bash.ps1`.
  - Evidence: `evidence/qa-gates/pytest-gate.2026-11-10T00-56.md` (test_brief_copies_are_byte_identical, test_brief_command_text_restrictions_states_preferred_forms)
- [x] `## Command-Text Restrictions` in each copy carries a preferred-forms table mapping intent to form, split into an agent-isolated worktree column and a sibling-worktree column, naming `git -C`, `poetry -C`, `npm --prefix`, the absolute-path read, the `sh` route, and `.claude/rules/bash-command-shape.md`, with no backticked `npm run <script>` token; `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` gains an assertion for these names and for the removed Codex attribution, and passes with its existing assertions retained.
  - Evidence: `evidence/qa-gates/pytest-gate.2026-11-10T00-56.md` (test_brief_command_text_restrictions_states_preferred_forms and the retained brief tests)
- [x] `## Worktree Python Environment` in each copy gains one sentence naming `env -u VIRTUAL_ENV poetry -C <worktree root> install` for an agent whose Bash working directory is not the worktree root, and `test_brief_worktree_python_environment_section_states_bootstrap` passes; the diff of each brief copy against `main` touches only `## Command-Text Restrictions` and `## Worktree Python Environment`.
  - Evidence: `evidence/qa-gates/pytest-gate.2026-11-10T00-56.md` (test_brief_worktree_python_environment_section_states_bootstrap), `evidence/qa-gates/scope-check.2026-11-10T00-57.md` (CHECK 3)
- [x] Every file matching `**/worktree-poetry-venv-policy.ps1` carries the same `$script:WorktreePoetryVenvBlockedReason`, which contains `poetry -C <worktree root>` and still contains the `WORKTREE_VENV_BLOCKED:` prefix, `env -u VIRTUAL_ENV poetry install`, and `never repoint the main checkout's environment`; `tests/scripts/claude-hooks/enforce-worktree-poetry-venv.Tests.ps1` and `tests/scripts/codex-hooks/enforce-worktree-poetry-venv.Tests.ps1` pass.
  - Evidence: `evidence/qa-gates/scope-check.2026-11-10T00-57.md` (CHECK 4), `evidence/qa-gates/pester-gate.2026-11-10T00-54.md` (both venv suites)
- [x] Every `parallel-orchestrate/SKILL.md` copy replaces `git -C <worktree_path> reset --hard HEAD~1` with `git -C <worktree_path> reset --keep HEAD~1` and references the `## Command-Text Restrictions` table of the `execution-environment` brief in the conflict-resolution step; `validate-bash.CdChainGuidance.Tests.ps1` asserts that `Get-BashBlockReason` returns no reason for `git -C /repo/wt reset --keep HEAD~1` and still denies `git -C /repo/wt reset --hard HEAD~1`.
  - Evidence: `evidence/qa-gates/scope-check.2026-11-10T00-57.md` (CHECK 5), `evidence/qa-gates/pytest-gate.2026-11-10T00-56.md` (test_parallel_orchestrate_step_c_uses_keep_and_references_brief_table), `evidence/qa-gates/pester-gate.2026-11-10T00-54.md` (reason-shape Context)

### Recurrence record
- [x] An append-only evidence file under `docs/features/active/cd-chained-command-recurring-deny-1165/evidence/baseline/` records that the repository hooks log no denials and that no repository count is available; any host transcript figure is labeled approximate and non-reproducible and contains no absolute path or host name.
  - Evidence: `evidence/baseline/recurrence.2026-11-10T00-09.md`

### Toolchain and documentation
- [x] Changed and new PowerShell files pass `Invoke-Formatter` with no changes and PSScriptAnalyzer (`scripts/powershell/PoshQC/settings/pssa.settings.psd1`) with zero findings; one `Invoke-PoshQCParallelTest` run is green with `ExitCode` 0 and `artifacts/pester/powershell-coverage.xml` shows at least 85% line coverage for `.claude/hooks/bash-command-shape-guidance.ps1` and no reduction on changed lines of `.claude/hooks/validate-bash.ps1`; `Invoke-PoshQCLeakScan` passes; the touched Python test modules pass under `pytest -n auto`; all runs are parallel and are recorded append-only under `evidence/`.
  - Evidence: `evidence/qa-gates/powershell-static.2026-11-10T00-38.md`, `evidence/qa-gates/pester-gate.2026-11-10T00-54.md`, `evidence/qa-gates/pytest-gate.2026-11-10T00-56.md`
- [x] No changed or new production file reaches 700 lines (`.claude/hooks/validate-bash.ps1` included), and no new Python production code is added.
  - Evidence: `evidence/qa-gates/scope-check.2026-11-10T00-57.md` (CHECK 1 and CHECK 6)
- [x] The rule, Codex skill, Copilot instruction, and brief table state the same forms and context split, and the brief contains no line-number or commit-SHA citations (`test_brief_has_no_g11_or_g12_findings` passes).
  - Evidence: `evidence/qa-gates/pytest-gate.2026-11-10T00-56.md` (test_command_shape_forms_are_consistent_across_surfaces, test_brief_has_no_g11_or_g12_findings)

## Risks & Mitigations
- Technical risks: a guidance edit could alter a decision; mirrored copies could drift; the helper could lower coverage; new tests could leak script-scope state across shards; the hook suites run on case-sensitive Linux in CI.
- Mitigations: the decision-regression corpus with a pre-change baseline; contract and byte-comparison checks for every mirror; branch-complete helper tests; dot-sourcing inside `BeforeAll` with in-memory strings and `Invoke-PoshQCLeakScan`; `Join-Path` and exact file-name case in tests. Rollback is a revert of the change set.
- Operational note: intent-specific reasons may split the Claude Code fleet notice grouping into several messages sharing the `Forbidden Bash pattern: 'cd ... &&` prefix; this is not a repository contract.

## Rollout & Follow-up
- Release/rollout: destination repositories receive the helper, the rule, the Codex skill, the Copilot instruction, and the brief through a push-down refresh after the extension release that carries them. Isolated subagents exercise the hook change only after merge to `main`.
- Post-fix follow-up: D-1165-5 (launch-loading the existing `paths: - "**"` rules) is recorded for the owner.
- Links: issue #1165; research `docs/features/active/cd-chained-command-recurring-deny-1165/research/research.2026-11-09T22-58.md`; related #545, #1158, #1159.
