# Research: planning-process-churn (Issue #964)

- Issue: #964
- Branch: `bug/planning-process-churn-964`
- Feature folder: `docs/features/active/2026-10-16-planning-process-churn-964`
- Inputs: `issue.md` in the feature folder, `docs/features/potential/promoted/2026-10-16-planning-process-churn.md`
- Work mode: `full-bug` (spec-driven; `spec.md` is the acceptance-criteria source)
- Timestamp note: no clock tool was available to the researcher. The filename stamp was chosen to be later than the feature scaffold (`plan.2026-10-16T18-10.md`, stamped in America/New_York, which is 22-10 UTC). The orchestrator may keep it; nothing depends on its exact value.

## Summary of Recommendations

1. **Execution-environment brief** is a new skill, `execution-environment`, preloaded through the `skills:` frontmatter of `task-researcher`, `atomic-planner`, `atomic-executor`, and `orchestrator`, and listed as a canonical skill in the Codex base agents and referenced from the Copilot base agents. One text, byte-identical in six locations, pinned by a new contract test.
2. **Design-level plan contract**: three new document-level validator rules in a new module pair (`scripts/dev_tools/plan_gate_document.py`, `extensions/drm-copilot/src/lib/validate/plan-gate-document.ts`): G11 line-number citations, G12 commit-SHA citations, G13 plan size above 40 tasks or 400 lines without a `## Size Justification` section. All three ship Blocking by operator-approved scope (the G10 precedent). `## Pre-Mortem` presence is enforced by the planner SubagentStop hook, not by the validator, because a validator rule would invalidate roughly a hundred existing validator fixtures.
3. **Single-pass preflight**: the executor hook detects preflight runs from the subagent transcript (`agent_transcript_path`, first user message) instead of from a directive line pasted into the plan file. That plan-file workaround currently disables the executor completion checks during execution (verified defect, see section 3.1). Preflight reports every defect in one pass, fixes trivial defects in place with a `PREFLIGHT-FIX:` record, returns only `PREFLIGHT-DEFECT:` (substantive) items, and the orchestrator allows at most one return to the planner.
4. **Mandatory pre-mortem** in feature-associated research and in every plan, enforced by one shared PowerShell helper used by both SubagentStop hooks; a self-review artifact against the three feature-review templates is produced by the plan's final phase and checked by the orchestrator before the pre-feature-review commit.
5. **Proportionate remediation**: a `Remediation-Mode: proportionate | design` line in `remediation-inputs`. Proportionate cycles run one planner delegation and one combined preflight-and-execute executor delegation; design cycles keep R1 to R5 with the at-most-one-return rule. No checkpoint schema change is needed.
6. **Validation**: an orchestrator-owned final phase re-plans #962 from a snapshot of its spec under the new contract and validates it with the branch-current Python CLI. The existing #962 plan is 1,754 lines with 99 tasks, of which the phases and the file list occupy only the last 279 lines; a design-level plan is estimated at 35 to 45 tasks and 300 to 400 lines.

## Method and Limits

- Every finding below was read from the repository with Read, Grep, and Glob in the item worktree, which was created from `origin/main` at the time of the delegation.
- The #962 spec and plan were read from the working tree of the local worktree that has `bug/ci-skip-evidence-only-commits-962` checked out (read-only). That is the working-tree state, which may include changes that are not yet pushed. `git show` and `gh` were not available to the researcher.
- The required-check contexts of ruleset 15241672 were not queried. The list in section 1.5 is the one recorded by the #962 plan (`## 10. README corrections and section`, `### Required contexts under a docs-only run`). The orchestrator should confirm it with `gh api repos/drmoisan/drm-copilot/rulesets/15241672` (read-only) before the brief is committed.
- The SubagentStop payload fields were taken from the Claude Code hooks reference (`https://code.claude.com/docs/en/hooks`, sections `SubagentStart` and `SubagentStop`) and cross-checked against `.claude/hooks/subagentstop-envelope.ps1` (`Read-SubagentStopEnvelope`).
- Facts that come from operator memory notes and could not be reproduced from repository code (the worktree isolation guard, for example) are marked "observed runtime behavior" rather than "verified in code".

---

## 1. Execution-Environment Brief

### 1.1 Current state

No single document holds the execution environment. The facts are spread across:

- Agent frontmatter: `.claude/agents/atomic-executor.md` (`tools:`), `.claude/agents/atomic-planner.md`, `.claude/agents/task-researcher.md`.
- Hooks: `.claude/hooks/validate-bash.ps1`, `.claude/hooks/enforce-powershell-batch-budget.ps1`, `.claude/hooks/enforce-python-batch-budget.ps1`, `.claude/hooks/enforce-batch-budget-route.ps1`, `.claude/settings.json` (`hooks`).
- Rules and skills: `.claude/rules/plan-acceptance-gates.md`, `.claude/skills/atomic-plan-contract/SKILL.md` (`## Wrap-Tolerant Assertion Authoring (Mandatory)`, which already carries the Pester runner and backslash rules), `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
- Each plan's own preamble. The #962 plan restates the environment as its `## 2. Rules binding on every task` (eighteen rules: tool route, Bash command text, PoshQC MCP output, batch budget, test purity, PSSA syntax, commit form, Pester CI job, re-integration when `origin/main` moves). That restatement is what every planner rediscovers.

Related defect found while reading: `.claude/agents/task-researcher.md` lists `evidence-and-timestamp-conventions` under `tools:` and has no `skills:` key, so the evidence skill is not preloaded for the researcher. This is fixed in this item (section 4).

### 1.2 Loading mechanism: options and decision

| Option | How it loads | Assessment |
|---|---|---|
| A. New skill `.claude/skills/execution-environment/SKILL.md`, preloaded by `skills:` frontmatter | The runtime injects each `skills:` entry into the agent's standing context (stated and relied on by `tests/scripts/dev_tools/test_claude_rules_frontmatter.py`, module docstring, and `test_every_agent_preloaded_skill_resolves_to_an_existing_skill_file`) | Deterministic, no read step to forget, same convention as `atomic-plan-contract` and `policy-compliance-order`. Mirrors cleanly to `.agents/skills/` (Codex canonical-skill list) and `.github/skills/` (Copilot shared skills). **Selected.** |
| B. New rule `.claude/rules/execution-environment.md` | Rules load every turn unless `paths:`-scoped | An unscoped rule breaks `test_unconditional_rule_set_is_exactly_the_four_deliberate_files`; a scoped rule loads only when matching files are touched, which does not happen at the start of research or planning. Rejected. |
| C. `SubagentStart` hook injecting `additionalContext` | Claude Code hook output | Claude-only, adds a hook and its Pester suite, cannot be mirrored to Codex or Copilot. Rejected. |
| D. Explicit "read this file first" step in each agent body | Agent instruction | Relies on agent compliance and costs a tool call per agent. Kept only for the Copilot surface, which has no preload mechanism. |

Preload targets (Claude): `task-researcher`, `atomic-planner`, `atomic-executor`, `orchestrator`. Do not add it to `.claude/agents/epic-orchestrator.md`: `test_epic_orchestrator_preloads_exactly_three_skills` pins that list, and the file's SHA-256 is pinned in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (`PINNED_FROZEN_SURFACE_HASHES`).

The main session running `/orchestrate` loads the orchestrate skill rather than the agent file, so `.claude/skills/orchestrate/SKILL.md` `## Prerequisites` gains one line: read the `execution-environment` skill before delegating.

### 1.3 Mirror set and parity enforcement

The brief text is identical in all six locations. The text uses repository-relative paths that are valid on every surface (it names both `.claude/hooks/...` and `.codex/hooks/...` where the two runtimes differ), so no per-surface rewrite is needed.

| Location | Enforcement that applies today |
|---|---|
| `.claude/skills/execution-environment/SKILL.md` | Canonical. `test_every_agent_preloaded_skill_resolves_to_an_existing_skill_file` requires it to exist once it is preloaded. |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md` | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (every distributable `.claude` file must exist in the bundle with equal text). `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_bundled_claude_files_are_listed_in_some_pack_manifest` (every bundled skill must be in a pack manifest). |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | Add `.claude/skills/execution-environment/SKILL.md` to `paths`. |
| `.agents/skills/execution-environment/SKILL.md` | Codex canonical skill. |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md` | `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`; Codex pack-manifest completeness test. |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | Add `.agents/skills/execution-environment/SKILL.md`. This file is rewritten by `scripts/dev_tools/generate_codex_agent_variants.py` (`render_manifest` emits `json.dumps(document, indent=2) + "\n"`), so add the entry and then run the generator in write mode; CI runs it with `--check` (`.github/workflows/_quality-checks.yml`, step `Verify Codex agent deployment profiles`). |
| `.github/skills/execution-environment/SKILL.md` | Copilot shared skill. No automated parity test was found for the Copilot bundle as a whole; the repository convention is a mirrored copy. |
| `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md` | Mirror copy (convention). |

New contract test (new file, recommended name `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`): the six copies are byte-identical; the brief carries its required headings; the four Claude agents preload it; the Codex base agents `atomic-executor`, `atomic-planner`, `task-researcher`, `orchestrator` list it; the Copilot base agents reference it; the brief contains none of `TaskMaster`, `No-COM` (`tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` scans every pushed rule and skill for `CONSUMING_NAMES` and expects zero occurrences in unpinned files).

`docs/engineering/claude-code-architecture.md` carries the `.github/skills` to `.claude/skills` mirror table; add a row for the new skill.

### 1.4 Verified environment facts (content of the brief)

| Fact | Source that establishes it | Status |
|---|---|---|
| Inside an agent-isolated worktree, Bash command text containing `pwsh`, `bash`, or `wsl`, heredocs, `printf --`, `cd <path> && git ...`, `git -C <other worktree>`, or embedded `jq` filter strings is refused with a message that the command "cannot be shown not to run git". `sh file.sh`, `npx`, `poetry run python script.py`, `gh`, worktree-scoped `git`, and `git commit -F <file>` pass. | Not implemented in the repository: no hook under `.claude/hooks/` contains the refusal text or a `wsl` token, and neither `.claude/settings.json` nor the user-level settings registers such a hook. It is Claude Code runtime behavior for isolated worktrees. | Observed runtime behavior (operator notes, 2026-09-07). The brief states it as runtime behavior, not as a repository hook. |
| Repository Bash denials: destructive patterns (`rm -rf`, `git push --force`, `git push -f`, `git reset --hard`, `Remove-Item -Recurse -Force`) and a `cd` followed later in the same command line by `grep`, `cat`, `head`, `tail`, `less`, `more`, `awk`, or `sed -n`. | `.claude/hooks/validate-bash.ps1` (`Get-BlockedBashPattern`, `Get-CdChainedReadCommandMatch`, `Get-BashBlockReason`) | Verified in code |
| The literal `git worktree remove` anywhere in a command is denied. | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` (registered under `PreToolUse` `Bash` in `.claude/settings.json`) | Hook registration verified; trigger text from operator notes |
| `atomic-executor` has no PowerShell tool. Its `tools:` list is Read, Grep, Glob, Edit, Write, several `Bash(...)` entries, and the four `mcp__drm-copilot__run_poshqc_*` tools. The `(pattern)` suffix on a `tools:` entry only admits the bare tool, so the executor has Bash, subject to hooks and the isolation guard, which refuses `pwsh` text. PowerShell therefore runs through the PoshQC MCP tools or through a `sh` launcher script stored under `SCRATCH`. | `.claude/agents/atomic-executor.md` frontmatter; operator measurement of agent `tools:` path suffixes | Frontmatter verified; suffix semantics observed |
| `atomic-planner` has no Bash and no MCP tools (Read, Grep, Glob, Edit, Write). It cannot run the plan validator. | `.claude/agents/atomic-planner.md` frontmatter | Verified |
| PoshQC MCP results carry no output: the summary string is composed from a fixed template before the child process runs, and the result type has no exit-code or stdout field. Counts, percentages, and findings must be read from `artifacts/pester/pester-junit.xml`, `artifacts/pester/powershell-coverage.xml`, or a direct `Invoke-ScriptAnalyzer` run. | `extensions/drm-copilot/src/repo-automation-service.ts` (`runPoshQcWorkflow`), `extensions/drm-copilot/src/repo-automation-args.ts`, `extensions/drm-copilot/src/repo-automation-service-support.ts` (`POSH_QC_TOOL_CONFIG`), `extensions/drm-copilot/src/repo-automation-service-contract.ts` (`RepoAutomationExecutionResult`) | Operator notes, 2026-09-13; the brief cites the symbols |
| MCP tools run the installed extension, not the branch: `validate_orchestration_artifacts` applies the installed rule set, and `run_poshqc_test` reads the installed extension's settings. Branch-current plan validation is `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <path>`; branch-current Pester runs import `scripts/powershell/PoshQC/PoshQC.psd1` in a `sh`-launched PowerShell. | `scripts/dev_tools/validate_orchestration_artifacts.py` (`plan` subparser with `--workspace-root`); operator notes | CLI verified; MCP behavior observed |
| Pester coverage population is derived by `Invoke-PoshQCTest`; there is no hand-maintained coverage path list. | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (comment `Issue #527: no Path list`) | Verified |
| Batch budget: in direct mode at most three distinct production files per kind (Python, PowerShell) per session; the fourth is denied with `PYTHON_LARGE_PATH_REQUIRED` or `POWERSHELL_LARGE_PATH_REQUIRED`. Test files never count (`tests/**/*.py`, `test_*.py`; `tests/**/*.ps1`, `*.Tests.ps1`). Paths outside the worktree root (for example `SCRATCH`) are discarded without consuming a slot. Only `Write`/`Edit` calls are seen (matcher `Write|Edit`); files written by a Bash command or a generator are not counted. Bundle mirror copies under `extensions/` are production files and do count. | `.claude/hooks/enforce-powershell-batch-budget.ps1` (`Invoke-PowerShellBatchBudgetDecision`, `ProdCap = 3`, `Test-PowerShellBatchBudgetPathInRoot`); `.claude/hooks/enforce-python-batch-budget.ps1` (same shape); `.claude/settings.json` matcher | Verified in code |
| The large-path exemption applies when `<root>/artifacts/orchestration/orchestrator-state.json` selects `route_id` (or `path_selected`) `large`, `remediation`, or `preparation` and is not terminal. `<root>` is the worktree that holds the hook script. An isolated subagent worktree has no checkpoint (`artifacts/` is gitignored), so direct mode applies there. State file: `.claude/state/<kind>-batch-budget.<session_id>.json`; there is no automatic reset. | `.claude/hooks/enforce-batch-budget-route.ps1` (`Test-BatchBudgetLargePathRoute`, `Get-BatchBudgetSelectedRoute`); `Invoke-PowerShellBatchBudgetHook` | Verified in code |
| Hooks for isolated subagents run inside the subagent worktree with that worktree's (that is, `origin/main`'s) hook scripts. A hook change on a branch is not exercised by isolated subagents until it is merged. | Operator probe, 2026-09-18 | Observed runtime behavior |
| Enforcement hooks must not invoke Python (bash preferred, PowerShell acceptable). | `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | Verified test exists |
| CI triggers on current `main`: `push` to `main`/`development`, `pull_request` to `main`/`development`/`epic/**`, `workflow_dispatch`; no path filters in `ci.yml`. The #952 branch adds `merge_group`. | `.github/workflows/ci.yml`; `bug/ci-merge-queue-for-main-952` worktree copy of `ci.yml` | Verified on both trees |
| CI jobs: `quality-checks7`, `security-scan`, `docs-validation`, `build-check`, `poshqc`, `shell-coverage`, `drm-copilot-extension-tests`, `root-typescript-tests`, `npm-audit-gate`. | `.github/workflows/ci.yml` | Verified |
| PowerShell CI: `poshqc / PowerShell QC` (windows-latest; format, analyze, all Pester suites with coverage) and `poshqc / PowerShell hook suites (Linux)` (ubuntu-latest; only `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`, coverage disabled). The #953 branch adds `poshqc-static` and a `poshqc-shard` matrix with `poshqc` as the aggregator. | `.github/workflows/_poshqc.yml` on `main` and on the `bug/pester-profiler-coverage-953` worktree | Verified on both trees |
| Python CI: `black --check`, `ruff check`, `pyright`, `generate_codex_agent_variants --check`, `check_quality_tiers`, `pytest --cov --cov-branch`, `check_python_coverage_thresholds`, on four Python versions. | `.github/workflows/_quality-checks.yml` | Verified |
| Docs validation in CI checks only that `README.md` and `LICENSE` exist and warns on two instruction files; there is no Markdown or link check. | `.github/workflows/_docs-validation.yml` | Verified |
| Required contexts of ruleset 15241672 (as recorded by #962): extension tests on ubuntu-latest and windows-latest, `docs-validation / Documentation Validation`, `poshqc / PowerShell QC`, `shell-coverage / Shell Coverage (Bats + kcov)`, `security-scan / Security Scanning`, `quality-checks7 / Code Quality & Tests (3.10)` to `(3.13)`, `build-check / Build Package`. | #962 plan, `### Required contexts under a docs-only run` | Not verified by the researcher; the orchestrator confirms with `gh api` |
| CI-only failure classes: (1) tests reading gitignored `artifacts/` paths pass only on a worktree that holds a live checkpoint; (2) `C:/workspace`-rooted fixtures fail `path.isAbsolute` on Linux; (3) `_shell-coverage.yml` checks out depth 1, so `origin/main` does not exist in CI; (4) the single-process Pester run in CI exposes module-scope import visibility errors that per-suite local runs hide; (5) `extensions/drm-copilot/tsconfig.jest.json` has pre-existing type errors, so "tsc on the test tree exits 0" is unsatisfiable at baseline. | Operator notes (PRs #638, #698, #748); `.github/workflows/_shell-coverage.yml` `actions/checkout` without `fetch-depth` | Classes observed; checkout shape verifiable |
| Evidence rules: canonical `<FEATURE>/evidence/<kind>/` with kinds `baseline`, `regression-testing`, `other`, `qa-gates`, `issue-updates`; UTC filename stamps read from the clock at write time; consumers select the lexicographically greatest `<name>.*.md`; plan files are stamped by tooling in America/New_York. | `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` (`## Canonical Evidence Locations`, `### Evidence Filename Timestamp`); `.claude/hooks/enforce-evidence-locations.ps1` | Verified |
| Plan validator rules G1 to G10 and their channels. | `.claude/rules/plan-acceptance-gates.md` (`## Rule Table`) | Verified |
| Preflight defect classes that pass the validator: `git grep` against a file the plan creates (untracked, so invisible); grep patterns beginning with `-` (pass through `-e`); `- [ ]`/`- [x]` diff-pair check-off assertions against an added file; CRLF fixtures under `* text=auto eol=lf`; a new TypeScript production file without its own `coverageThreshold` entry in `extensions/drm-copilot/jest.config.cjs` (the map has no `global` key); per-file coverage floors under blanket mocks; per-session batch-budget state; `origin/main` advancing during planning (anchor scope diffs on the merge base); `Invoke-Pester` without `-EnableExit` exits 0 on failure; `Measure-Object -Line` counts non-empty lines only; `--cov=<path>.py` measures nothing; branch coverage must come from `coverage.json`, not the terminal row. | Operator notes; `extensions/drm-copilot/jest.config.cjs` comment "Per-file entries only; the map has no `global` key" | Mixed; jest fact verified |
| Contract tests that commonly break on mirrored edits: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_codex_handoff_contract_parity.py`, `test_codex_agent_wrapper_contracts.py`, the generator `--check`, both pack-manifest completeness tests, `test_claude_rules_frontmatter.py`, `parallel_orchestrator_surface_expectations.py` (pinned hashes), `test_quality_checks_workflow_contracts.py` (workflow step conditions), `test_push_down_issue_824_follow_ups.py` (consuming-name scan), `test_typescript_toolchain_instruction_contracts.py` (no `vitest`, every `npm run` token must exist in the root `package.json`). | Files under `tests/scripts/dev_tools/` | Verified each exists and what it asserts |

### 1.5 Brief outline (recommended headings)

`## Purpose and Maintenance` (the brief is updated in the same change that alters any fact it states), `## Tool Routes by Agent`, `## Command-Text Restrictions` (runtime guard and repository hooks, kept separate), `## PowerShell Route and PoshQC MCP Limits`, `## Batch Budget`, `## Hook Execution Context`, `## MCP Surfaces Run the Installed Extension`, `## CI Shape and Required Checks`, `## CI-Only Failure Classes`, `## Contract Tests That Pin Mirrored Files`, `## Preflight Defect Classes the Validator Cannot See`, `## Evidence and Documentation Rules`, `## Coverage and File-Size Gates`, `## Test Isolation Checks`. CI facts name workflow files and job names and describe both the current and the #952/#953 shapes; they do not copy YAML. The brief carries no line numbers and no commit SHAs.

---

## 2. Design-Level Plan Contract

### 2.1 Current state

- Rule file: `.claude/rules/plan-acceptance-gates.md` (G1 to G10). Bundle mirror `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md` must be byte-identical (`tests/scripts/dev_tools/test_plan_gate_scratch_docs.py::test_rule_file_bundle_copy_is_byte_identical`). No `.github` or `.codex` copy of the rule exists.
- Python: `scripts/dev_tools/plan_gate_commands.py` (extractor), `plan_gate_coverage.py` (G1 to G4), `plan_gate_discrimination.py` (G5, G6, entry point `evaluate_plan_gates`, `PlanGateReport`), `plan_gate_observability.py` (G7 to G9), `plan_gate_scratch.py` (G10, document-level). `scripts/dev_tools/validate_orchestration_artifacts.py` routes the `plan` artifact type, prints Warnings with `PLAN GATE WARNING: `, and exits on the error channel.
- TypeScript: `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts`, `plan-gate-rules.ts`, `plan-gate-discrimination.ts` (`evaluatePlanGates`), `plan-gate-observability.ts`, `plan-gate-scratch.ts`, dispatched from `orchestration-artifacts.ts`.
- Parity: there is no shared fixture corpus file. Parity fixtures are duplicated verbatim in `tests/scripts/dev_tools/test_plan_gate_parity.py` and `extensions/drm-copilot/test/lib/validate/plan-gate-parity.test.ts`, with severity-constant parity assertions and the no-`repr`/no-`pythonRepr` assertions.
- Hooks: `.claude/hooks/validate-planner-output.ps1` checks output signals, plan structure (`Get-PlanStructureValidationReport`), and the bounded internal-review record (`Get-PlannerInternalReviewValidation`). The rule file states the hook carries no part of gate enforcement. `.claude/hooks/enforce-prd-feature-before-planner.ps1` gates planner delegation on prd-feature completion and is unaffected.
- The rule file's `paths:` frontmatter already covers new modules through the globs `scripts/dev_tools/plan_gate_*` and `extensions/drm-copilot/src/lib/validate/plan-gate-*`, so no frontmatter change is needed (and `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` is 499 lines and should not grow).

What pushes plans toward literals: the G5/G6 "checkable literal" guidance and `## Wrap-Tolerant Assertion Authoring (Mandatory)` reward exact tokens; `## Planner Adversarial Self-Review (Mandatory)` asks the planner to enumerate citations "naming the file and the line"; the `CITATION: <path> | <locator>` record accepts line locators; and the absence of a shared brief forces each plan to restate the tool route.

### 2.2 New rules G11, G12, G13

All three are document-level and context-free (the G10 pattern): they read the whole plan text, skip fenced code blocks with the extractor's fence pattern, split lines on CR LF, LF, and CR only, use no lookbehind (Python and JavaScript dialects agree), render the offending value between backticks, and report with a `Line N: ` prefix. They run on every invocation of `evaluate_plan_gates` / `evaluatePlanGates`, after G10.

**G11, line-number citation (Blocking).**
- Prose form, evaluated on unfenced text with inline code spans masked: `\b[Ll]ines?[ \t]+[0-9]+` (matches `line 26`, `lines 134-143`, `around line 79`; does not match `500 lines`, because the number precedes the word).
- Path form, evaluated on unfenced text including inline code: `[A-Za-z0-9_./-]+\.[A-Za-z][A-Za-z0-9]{0,5}:[0-9]+` (matches `repo-automation-args.ts:20`, `ModelRouting.psm1:42`). Post-filter in code: skip when the enclosing whitespace-delimited token contains `://` (URL with port).
- Anchor form: `#L[0-9]+`.
- One finding per match. Message: ``Line N: line-number citation `<match>` anchors on a position that moves when main moves; cite the symbol, heading, or test name instead.``
- Known false-positive classes (documented, not suppressed): prose that refers to a line of command output ("line 1 of the output"); a quoted validator message such as `Line 5:` written outside backticks.

**G12, commit-SHA citation (Blocking).**
- Pattern on unfenced text including inline code: `\b[0-9a-f]{7,40}\b`, accepted only when the token holds at least one digit and at least one letter `a`-`f`, and the character immediately before it is not `-`, `_`, or `.` and the character immediately after it is not `-` or `_`. Adjacency is checked in code, not by lookbehind.
- These conditions exclude decimal run IDs and ruleset IDs, all-letter words such as `defaced`, UUID segments and agent or worktree suffixes (joined by `-`), and SHA-256 digests (a 64-character run has no word boundary at 40, so the bounded pattern does not match inside it). A digest literal can therefore remain where it is the actual assertion.
- Message: ``Line N: commit-SHA citation `<match>` names a commit that goes stale when main moves; cite the branch, ref name, or merge base derivation instead.``
- Known false-positive classes: hexadecimal-looking identifiers that are not joined by `-` or `_` (for example a bare hex color of seven or more characters).

**G13, plan size without justification (Blocking).**
- Counts canonical task lines (`^- \[[ xX]\] \[P[0-9]+-T[0-9]+\] `, unfenced) and physical lines. Fires when tasks exceed `PLAN_TASK_GUIDELINE = 40` or lines exceed `PLAN_LINE_GUIDELINE = 400`, unless the document has a `## Size Justification` heading followed by at least one non-blank, non-heading line before the next `## ` heading.
- One finding per document, prefix `Line 1: `. Message: ``Line 1: plan size `<T> tasks, <L> lines` exceeds the guideline of 40 tasks or 400 lines and carries no `## Size Justification` section; split the item or state why the size is necessary.``
- Rationale for the numbers: the #962 item (38 acceptance criteria, about 20 files) maps to an estimated 35 to 45 design-level tasks in 300 to 400 lines (section 6). Most items are smaller. An item that needs more states why, which costs one paragraph rather than a preflight round.

**Severity decision.** The precedent (`### G10 — ships as Blocking by operator-approved scope and the pre-declared rule`) allows operator-approved scope. G11 and G12 implement the issue's explicit requirement ("No line numbers or commit SHAs; anchor on symbols or headings") under the operator ruling for this item, so they ship Blocking by operator-approved scope. The execution still records a corpus measurement (finding counts per rule over the committed plan corpus under `docs/`, with the false-positive classes observed) as evidence, in the same form as `g10-corpus-measurement`. The rule file records that the measurement informs the false-positive class list and did not decide the channel, so a later feature cannot misread it. G13 is Blocking because its exoneration is under the author's control. Each severity is one constant per runtime (`G11_SEVERITY`, `G12_SEVERITY`, `G13_SEVERITY`) with a parity assertion.

**Why the trivial-fix path neutralises the round-trip cost.** G11 and G12 findings are, by definition, trivial preflight defects (section 3.4): the preflight executor removes the citation in place and records it. The planner also gains the `mcp__drm-copilot__validate_orchestration_artifacts` tool (section 3.6) so it can validate before handoff once the release containing G11 to G13 is installed.

**Fixture impact.** Existing validator test fixtures were searched for the G11 and G12 patterns: the only matches are expected-message strings (`Line 1: SCRATCH definition ...`, `Line 5: task phase ...`) and comments, none of which are plan inputs. The one-task fixtures are far below the G13 guideline. Existing tests are therefore expected to be unaffected.

### 2.3 Pre-Mortem enforcement and citation locators (planner hook)

- A plan-validator rule requiring `## Pre-Mortem` would add a Blocking finding to almost every existing fixture: `evaluate_plan_gates(` / `evaluatePlanGates(` are called from about a hundred test sites that assert exact Blocking lists. The planner SubagentStop hook is the cheaper and earlier channel: a repairable block is delivered to the same planner session as its next instruction, so the planner adds the section without a round trip.
- Shared helper (new): `.claude/hooks/premortem-section.ps1`, function `Test-PreMortemSection -Content <string>`. It requires a `## Pre-Mortem` heading and, within that section, one bullet beginning with each label: `Review checklists`, `Coverage`, `Mirror parity`, `File size`, `Test isolation`, `CI-only behavior`, `Evidence` (case-insensitive; a label may be followed by "not applicable" and a reason). Both `validate-planner-output.ps1` and `validate-task-researcher-output.ps1` dot-source it with the guarded pattern `try { . (Join-Path $PSScriptRoot 'premortem-section.ps1') } catch { Add-HookDependencyFailure ... }` required by `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`.
- The planner hook also rejects a `CITATION:` locator that is a line reference (bare digits, `L<digits>`, `line <digits>`, or `<path>:<digits>`), consistent with G11.
- `validate-planner-output.ps1` is 442 lines; the additions (guarded load, one call, the locator check) keep it under 460.

### 2.4 Contract text changes

- `.claude/skills/atomic-plan-contract/SKILL.md`:
  - New `## Design-Level Plan Contract (Mandatory)`: tasks name files, symbols, behavior, tests, and acceptance; anchors are symbols, headings, or test names; literals appear only where they are the asserted value; tool routes, wrappers, and launchers are not restated (the `execution-environment` skill owns them); size guideline and `## Size Justification`; `## Pre-Mortem` required.
  - `## Planner Adversarial Self-Review (Mandatory)`: "naming the file and the line, test, or identifier" becomes "naming the file and the symbol, heading, or test".
  - `### Planner Internal Review Record`: the locator is a symbol, heading, or test name.
  - `## Validator Gate (Mandatory)`: correct the stale "G1 through G6" reference and state the shipped set G1 through G13.
  - `## Preflight Validation (Planner ↔ Executor)`: rewritten per section 3 (keep the sentence "Review the entire plan in one pass", pinned by `test_claude_planning_integrity_contracts.py`).
- `.claude/rules/plan-acceptance-gates.md`: title and description to G1 through G13; rule-table rows; `### G11/G12/G13` severity sections; known false-positive classes; enforcement bullets naming the new module pair; authoring-guidance bullets. Update `tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`, which pins `"G1 through G10 are the complete shipped set."`, `"The complete shipped set is therefore G1 through G10."`, and `"G1 through G10"` in the discrimination module docstring; the replacement sentences name G1 through G13 and the old ones move to the superseded lists.

### 2.5 Python and TypeScript parity

- New modules: `scripts/dev_tools/plan_gate_document.py` and `extensions/drm-copilot/src/lib/validate/plan-gate-document.ts`. Same import-cycle discipline as `plan_gate_scratch.py` (runtime import of `split_plan_lines`, `PLAN_WHITESPACE_CLASS`, `normalize_plan_whitespace` from the extractor; `PlanGateReport` under `TYPE_CHECKING` only; channel constants declared locally).
- Call sites: one import and one call each in `plan_gate_discrimination.py` (`evaluate_plan_gates`) and `plan-gate-discrimination.ts` (`evaluatePlanGates`), plus docstring updates naming G1 through G13.
- Parity rows go in new test files, because `tests/scripts/dev_tools/test_plan_gate_parity.py` is 494 lines. Byte-identical expected messages, including an apostrophe-bearing value, and the no-`repr(`/no-`!r` and no-`pythonRepr(` assertions for the new modules.
- `extensions/drm-copilot/jest.config.cjs` needs a per-file `coverageThreshold` entry for `./src/lib/validate/plan-gate-document.ts` (`lines: 85`, `branches: 75`). The file is 489 lines; a four-line entry with no comment keeps it under 500.

---

## 3. Single-Pass Preflight

### 3.1 Current state and a verified defect

- `.claude/hooks/validate-executor-output.ps1`, `Test-IsPreflightPlan`, decides "preflight run" only by searching the **plan file** for a line `DIRECTIVE: PREFLIGHT VALIDATION ONLY`. The directive is specified as part of the delegation prompt (`atomic-plan-contract`), not the plan.
- Planners and orchestrators work around this by pasting the directive into the plan file. 42 committed plan and remediation-plan files under `docs/features/` carry the line (for example the issue #932 plan, under its metadata block, with the note "The directive line above applies to preflight rounds only").
- Consequence: once the directive is in the plan, every later **execution** run of that plan is also classified as preflight, and the completion checks in `Get-ExecutorOutputBlockDecision` (all checkboxes ticked, `AC Status Summary`, commands run, per-language PASS/FAIL lines) are skipped. Without the workaround, a preflight run is classified as execution and is told to tick every task. Either way the hook enforces the wrong contract for one of the two run kinds.

### 3.2 What the SubagentStop payload contains

Per the Claude Code hooks reference, SubagentStop input carries the common fields (`session_id`, `transcript_path` of the **main** session, `cwd`, `permission_mode`, `hook_event_name`) plus `stop_hook_active`, `agent_id`, `agent_type`, `agent_transcript_path` (the subagent's own transcript, under a `subagents/` folder), `last_assistant_message`, `background_tasks`, and `session_crons`. The delegation prompt is not a field; it is the first user entry of the transcript at `agent_transcript_path`. `Read-SubagentStopEnvelope` already exposes the parsed `Envelope` object, so `agent_transcript_path` is reachable without changing the shared envelope helper.

### 3.3 Recommended detection

`Test-IsPreflightRun` replaces `Test-IsPreflightPlan` in `validate-executor-output.ps1`:

1. Read `agent_transcript_path` from the envelope through an injectable reader seam (`ReadTranscriptHead`), expand a leading `~`, read the JSONL until the first `user` entry, and test its text for the exact directive line. If the transcript is readable, this answer is authoritative, including the case where the plan file still carries a pasted directive.
2. If the transcript is absent or unparseable, fall back to the existing plan-file check, or to the output carrying exactly one `PREFLIGHT:` signal line. The fallback is self-declared; the hook documents that.

The plan-file directive is then removed from the contract: `atomic-plan-contract` states that the directive lives in the delegation prompt only and that a plan file must not carry it. A plan file that still carries the line is harmless once detection reads the transcript. The JSONL entry format is not a documented contract; the reader is isolated behind the seam, tested with in-memory content (no temporary files), and failure degrades to the fallback rather than blocking.

### 3.4 Defect classification and signal format

- **Trivial** (fixed in place by the preflight executor, recorded, never returned): stale or misspelled anchors, symbols, headings, or paths whose intent is unambiguous; citation corrections, including removal of G11 and G12 citations; typos; literal-formatting defects that do not change what is asserted (quoting, `-e` for a hyphen-leading grep pattern, plain `grep` instead of `git grep` for a file the plan creates, full repository-relative pathspecs); evidence filename spelling; the preflight defect classes of section 1.4 when the correction keeps the assertion's meaning. The executor edits task text and preamble only. It never adds, removes, or reorders tasks, so the anti-replanning rules in `.claude/agents/atomic-executor.md` remain intact.
- **Substantive** (returned to the planner): missing or extra tasks; wrong file set or design; an acceptance criterion with no implementing task; an unsatisfiable acceptance condition whose correction changes what is asserted; task-ordering errors; scope-boundary violations.
- Output lines, one per defect, after the existing `PREFLIGHT:` signal and `CONVERGENCE:` line:
  - `PREFLIGHT-FIX: <[P#-T#] or heading> | <defect class> | <change made>`
  - `PREFLIGHT-DEFECT: <[P#-T#] or heading> | <defect class> | <required change>`
  - `preflight-fix-record: <path>` when at least one fix was made; the record is `<FEATURE>/evidence/other/preflight-fixes.<timestamp>.md` with `Timestamp:`, `Plan:`, and one entry per fix.
- Hook rules in a preflight run: exactly one `PREFLIGHT:` signal; `ALL CLEAR` carries no `PREFLIGHT-DEFECT:` line; `REVISIONS REQUIRED` carries at least one; any `PREFLIGHT-FIX:` line requires a `preflight-fix-record:` path under `docs/features/` that exists. All are repairable blocks.
- The signal set is unchanged, so `preflight_status == "PREFLIGHT: ALL CLEAR"` in the epic and parallel planner state validators keeps its meaning, and `CONVERGENCE:` stays out of the planner hook (pinned by `test_claude_planning_integrity_contracts.py`).

### 3.5 At-most-one return

- Planning (S4 and preparation mode): preflight round 1 returns `ALL CLEAR` (possibly with fixes) or `REVISIONS REQUIRED` with substantive defects only. On `REVISIONS REQUIRED` the orchestrator delegates one planner revision carrying the full `PREFLIGHT-DEFECT:` list, then runs preflight round 2. If round 2 still returns a substantive defect, the orchestrator halts with `blocked_reason: "validator_failed"`, an existing mechanical member in `.claude/rules/orchestrator-state.md` (`## Blocked-Reason Vocabulary`), so no vocabulary change is needed across the Python, TypeScript, and PowerShell validators.
- Remediation cycles: the existing iteration ceiling in `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` (`final_status: "blocked_preflight_iteration_limit"` when iterations would exceed 2) already matches one return. Keep the pinned phrase `preflight.iterations > 1`.

### 3.6 Surface changes

- `.claude/agents/atomic-executor.md`: `## Preflight Validation` and `## Blocking Protocol` per 3.4 and 3.5; add `mcp__drm-copilot__validate_orchestration_artifacts` to `tools:` (preflight runs the validator); add `execution-environment` to `skills:`. Keep the four `mcp__drm-copilot__run_poshqc_*` names (pinned by `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`) and the `## Scratch Location` text (pinned by `tests/scripts/dev_tools/test_scratch_location_contracts.py`).
- `.claude/agents/atomic-planner.md`: add the MCP validator tool and the brief skill; state the at-most-one-return rule; the design-level contract by reference.
- `.claude/hooks/validate-executor-output.ps1` (324 lines; about 60 lines added): `Test-IsPreflightRun`, the signal-consistency checks, and the combined preflight-and-execute allowance of section 5.
- Codex: `.codex/agents/atomic-executor.toml` replaces "Continue the validate -> delta -> planner-revise -> validate loop until preflight can return `PREFLIGHT: ALL CLEAR`." and "automatically hand off back to `atomic-planner`..." with the single-pass rules. `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py::test_atomic_executor_wrapper_preserves_codex_preflight_return_handoff` pins those exact fragments and must be updated in the same change.
- Copilot: `.github/agents/atomic_executor.agent.md` (`### 2.0 Preflight validation-only mode`, "Loop requirement").

---

## 4. Mandatory Pre-Mortem and Self-Review

- Research: `.claude/agents/task-researcher.md` and `.claude/skills/research-issue/SKILL.md` require a `## Pre-Mortem` section (the seven labels of section 2.3) in feature-associated research. `.claude/hooks/validate-task-researcher-output.ps1` (291 lines) calls `Test-PreMortemSection` only when the research path is under `docs/features/`. One-off research under `docs/research/` is not a planning input, and the existing hook fixtures (`tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1`) use `docs/research/` paths with a one-line body, so they remain valid.
- `task-researcher.md` frontmatter fix: add `skills:` with `evidence-and-timestamp-conventions` and `execution-environment`, and remove the skill name from `tools:`. Leave the `Write(/docs/...)` entries unchanged: path suffixes in agent `tools:` entries are inert, so editing them changes nothing.
- Plans: the planner hook enforces the section (2.3). Plan templates `docs/features/templates/{bug,feature,refactor}/plan.yyyy-MM-ddTHH-mm.md` gain an empty `## Pre-Mortem` skeleton with the seven labels; no test pins these templates.
- Self-review before the first review push: the plan's final phase contains a task that walks the three feature-review templates (`docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md`, `feature-audit.yyyy-MM-ddTHH-mm.md`; bundled copies under `extensions/drm-copilot/resources/templates/policy_audit/`, resolved at review time through `resolve_policy_audit_template_asset`) against the branch diff and writes `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item. `.claude/skills/orchestrate/SKILL.md` `## Pre-Feature-Review Commit` gains a step 0: the orchestrator confirms the newest `self-review.*.md` exists and records no FAIL row; otherwise it opens a proportionate correction before the commit. The templates themselves do not change. No hook enforces the self-review task in the plan, which keeps the planner-hook fixture churn limited to the Pre-Mortem section.
- `.claude/skills/feature-review-workflow/SKILL.md` and `.claude/agents/feature-review.md` are unchanged.

---

## 5. Proportionate Remediation

Current state: `.claude/skills/orchestrate/SKILL.md` `## Remediation Loop (R1–R5)` and `## Remediation Loop — CI-Failure Handling`; `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` `## Preflight Sub-Loop`; `.claude/agents/orchestrator.md` `### Remediation Loop Checkpoint Shape` and `### Preflight Sub-State Semantics`. Validators enforce only that `execution_status` in `{in_progress, complete, failed}` requires `preflight.final_status == "clear"` (`scripts/dev_tools/_orchestrator_state_remediation_loop.py`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation.ts`, `.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1`). `preflight.iterations` is not validated.

Recommendation:

- The orchestrator writes `Remediation-Mode: proportionate` or `Remediation-Mode: design` in each `remediation-inputs.<timestamp>.md`. A cycle is **proportionate** when every autonomous finding can be fixed without changing a spec acceptance criterion, a public interface, or the item's file inventory beyond files already in the branch diff plus their tests and mirrors. CI-failure findings are normally proportionate. Otherwise the cycle is **design**.
- Proportionate cycle: R1 one planner delegation (short remediation plan with `## Pre-Mortem` and a final self-review task); R2+R3 one executor delegation that runs preflight (in-place trivial fixes) and then executes. If preflight finds a substantive defect, the executor stops with `BLOCKED at preflight (before [P0-T1])` and the cycle converts to design mode for one planner revision. Record `preflight: {iterations: 1, final_status: "clear"}` before `execution_status`, which satisfies the validators unchanged. Then the pre-R4 commit and R4 review as today.
- Design cycle: R1 to R5 as today, with the at-most-one-return rule of 3.5.
- Hook support: in `validate-executor-output.ps1`, an execution run whose output carries the canonical `BLOCKED at preflight (before [P0-T1])` text, a plan delta, and no checked task is allowed (it is a preflight block that occurred inside a combined run). Every other non-preflight `BLOCKED` stays a non-repairable block.
- No checkpoint schema field is added; the mode lives in the inputs file, so the Python, TypeScript, and PowerShell orchestrator-state validators are untouched.

---

## 6. Validation Evidence (#962)

Read from the `bug/ci-skip-evidence-only-commits-962` worktree (working tree, read-only):

- `spec.md`: 604 lines, AC-1 to AC-38; about 20 files in scope (one config, two production PowerShell files, four new Pester suites, seven workflows, the workflow README, two shell files and one bats suite, one Python contract test, `quality-tiers.yml`, two conditional suites).
- `plan.2026-10-16T10-27.md`: 1,754 lines and 99 tasks in eight phases. The phases start at `## 11. Phases`; everything above it (about 1,475 lines) is preamble.

| Plan section | Approximate lines | Literal class |
|---|---|---|
| `## 1. Terms`, `## 2. Rules binding on every task`, `## 3. Decisions fixed by this plan`, `## 4. Requirements trace` | 120 | Environment restated (tool route, guard, batch budget, PoshQC MCP, Pester job, commit form, re-integration), pinned SHAs and run IDs |
| `## 5. Command recipes (CR)` | 745 | Inline POSIX launcher and 20 PowerShell recipe bodies, success tokens (`EXIT_CODE_COMPUTED`, `RUN-CR:`) |
| `## 6.`/`## 6a.` contracts and shell edits | 190 | Line-anchored insertions ("directly after line 36") |
| `## 7. Workflow gating` | 195 | Literal YAML and line-anchored test edits with branch SHAs |
| `## 8. Test row inventory` | 120 | Enumerated test rows already implied by the spec |
| `## 9.`, `## 10.` config and README | 90 | Verbatim README text |
| `## 11. Phases` and `## Files Written` | 280 | The task list itself |

Literal counts in the same file: 52 lines carry a `line N` or `lines N` citation; 7 distinct commit SHAs appear (full and abbreviated); 131 lines reference the launcher or its success tokens; 36 fenced code blocks.

A design-level plan for the same spec, under the new contract and the brief, would contain: Phase 0 baseline (about 5 tasks), regression suites written to fail first (4), config, pure module, and tier entry (4), entry script (2), workflow gating and the two contract-test adjustments (8), README and shell follow-ups (4), final QA and self-review (6 to 8), CI-dependent proofs owned by the orchestrator (5). That is 35 to 45 tasks and an estimated 300 to 400 lines, about one fifth of the current length, with no CR section, no environment rules, and no line or SHA anchors. The acceptance for this item is stated as observable outcomes rather than an exact count: the re-plan has zero G11 and G12 findings, is within the G13 guideline or carries a justification, passes the plan validator, and its first preflight returns `PREFLIGHT: ALL CLEAR` (in-place fixes permitted).

Execution notes for the validation phase:

- It is orchestrator-owned: the executor has no `Agent` tool. The orchestrator snapshots the #962 spec into `<FEATURE>/evidence/other/replan-962/spec.md` (from `origin/main` if #962 has merged, otherwise from its branch, using `git show`), delegates one planner run and one preflight run, and writes `<FEATURE>/evidence/other/replan-962/summary.<timestamp>.md` (lines, tasks, G11/G12/G13 results, preflight signal, fix count).
- Delegate non-isolated from the item worktree so the branch hook scripts apply; isolated subagents would run `main`'s hooks.
- Validate with `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <path>`; the MCP validator applies the installed rule set, which does not yet include G11 to G13.

---

## Concurrent Overlaps

| Item | Files it changes that this item also touches | Handling |
|---|---|---|
| #952 (in flight) | `.claude/skills/orchestrate/SKILL.md` and bundle mirror (`## Step S9 — CI Green Gate` step 6, `## PR Creation Gate` condition 7). It also changes `parallel-orchestrate`, `epic-orchestrate`, `epic-orchestrator.md`, `parallel-orchestrator.md`, `.agents/skills/epic-orchestrate/SKILL.md`, `.codex/agents/epic-orchestrator.toml`, `general-code-change.md`, `general-unit-test.md`, none of which this item touches. | Tolerated. This item edits different sections (`## Prerequisites`, `## Preparation Mode`, `## Pre-Feature-Review Commit`, `## Remediation Loop (R1–R5)`, `## Remediation Loop — CI-Failure Handling`). Expect a textual merge in one file; re-copy the bundle mirror after merging. |
| #953 (in flight) | None. It shards `.github/workflows/_poshqc.yml`. | The brief describes both `_poshqc.yml` shapes by job name. |
| #962 (in flight) | None. It gates workflows with `run-heavy` and edits `.github/workflows/README.md`. | The brief names the change-scope gate generically and points to the workflow README. Its plan is the validation subject (read-only). |
| #935 (in flight) | None found in its spec. | New Pester suites follow the same isolation conventions. |

`.claude/skills/epic-orchestrate/SKILL.md` and `.claude/agents/epic-orchestrator.md` are deliberately not edited (hash-pinned and touched by #952). `.claude/skills/epic-plan/SKILL.md` gets one sentence ("iterating plan revisions until `PREFLIGHT: ALL CLEAR`" becomes a reference to the orchestrate skill's single-pass rule); it is not pinned and #952 does not list it.

---

## File Inventory

Grouped by surface. "(new)" marks a new file; every other entry is modified. Generated files are produced by one generator run.

### Execution-environment brief
- `.claude/skills/execution-environment/SKILL.md` (new)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md` (new)
- `.agents/skills/execution-environment/SKILL.md` (new)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md` (new)
- `.github/skills/execution-environment/SKILL.md` (new)
- `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md` (new)
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (entry added, then normalized by the generator)
- `docs/engineering/claude-code-architecture.md` (mirror table row)

### Claude agents (each with its bundle mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/agents/`)
- `.claude/agents/atomic-executor.md`
- `.claude/agents/atomic-planner.md`
- `.claude/agents/task-researcher.md`
- `.claude/agents/orchestrator.md`

### Claude skills and rules (each with its bundle mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/`)
- `.claude/skills/atomic-plan-contract/SKILL.md`
- `.claude/skills/orchestrate/SKILL.md`
- `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`
- `.claude/skills/research-issue/SKILL.md`
- `.claude/skills/epic-plan/SKILL.md`
- `.claude/rules/plan-acceptance-gates.md`

### Claude hooks (each with its bundle mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`)
- `.claude/hooks/premortem-section.ps1` (new; also add to `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`)
- `.claude/hooks/validate-planner-output.ps1`
- `.claude/hooks/validate-task-researcher-output.ps1`
- `.claude/hooks/validate-executor-output.ps1`

### Plan validators
- `scripts/dev_tools/plan_gate_document.py` (new)
- `scripts/dev_tools/plan_gate_discrimination.py`
- `extensions/drm-copilot/src/lib/validate/plan-gate-document.ts` (new)
- `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts`
- `extensions/drm-copilot/jest.config.cjs` (per-file threshold entry)

### Codex surface
- `.codex/agents/atomic-executor.toml`, `.codex/agents/atomic-planner.toml`, `.codex/agents/task-researcher.toml`, `.codex/agents/orchestrator.toml` (hand-edited bases)
- Generated by `poetry run python -m scripts.dev_tools.generate_codex_agent_variants`: the `-c1`, `-c2`, `-c3`, `-c3-elevated`, `-c4` variants of those four families under `.codex/agents/`, and the bases and variants under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/`
- `.agents/skills/atomic-plan-contract/SKILL.md`, `.agents/skills/orchestrate/SKILL.md`, `.agents/skills/remediation-handoff-atomic-planner/SKILL.md`, `.agents/skills/atomic-executor/SKILL.md`, `.agents/skills/atomic-planner/SKILL.md`, `.agents/skills/research-issue/SKILL.md`, each with its mirror under `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/`
- `.codex/prompts/feature-review-remediate.md` and its mirror under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/prompts/`

### Copilot surface (each with its mirror under `extensions/drm-copilot/resources/customizations/.github/`)
- `.github/agents/atomic_executor.agent.md`
- `.github/agents/atomic_planning.agent.md`
- `.github/agents/task-researcher.agent.md`
- `.github/agents/orchestrator.agent.md`
- `.github/skills/atomic-plan-contract/SKILL.md`
- `.github/skills/remediation-handoff-atomic-planner/SKILL.md`
- `.github/prompts/generate-atomic-plan.prompt.md`

Copilot and Codex statements of the form "do not mark complete until `PREFLIGHT: ALL CLEAR`" are gates, not loop mandates, and stay true under single-pass preflight; they are not edited. Only loop mandates ("repeat", "iterate", "loop until") are edited.

### Templates
- `docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md`, `docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md`, `docs/features/templates/refactor/plan.yyyy-MM-ddTHH-mm.md` (`## Pre-Mortem` skeleton)

### Tests (new unless stated)
- `tests/scripts/dev_tools/test_plan_gate_document.py` (G11, G12, G13 behavior and boundaries)
- `tests/scripts/dev_tools/test_plan_gate_document_parity.py` (verbatim parity rows, severity constants, no `repr`)
- `tests/scripts/dev_tools/test_plan_gate_document_docs.py` (rule-file and contract text for G11 to G13, bundle byte-identity)
- `tests/scripts/dev_tools/test_plan_gate_scratch_docs.py` (modified: shipped-set sentences and docstring token)
- `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`
- `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py` (contract text across Claude, Codex, and Copilot surfaces; at-most-one return; `Remediation-Mode:`; self-review step)
- `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py` (modified: executor fragments)
- `extensions/drm-copilot/test/lib/validate/plan-gate-document.test.ts`
- `extensions/drm-copilot/test/lib/validate/plan-gate-document-parity.test.ts`
- `tests/scripts/claude-hooks/premortem-section.Tests.ps1`
- `tests/scripts/claude-hooks/validate-planner-output.PreMortem.Tests.ps1`
- `tests/scripts/claude-hooks/validate-task-researcher-output.PreMortem.Tests.ps1`
- `tests/scripts/claude-hooks/validate-executor-output.Preflight.Tests.ps1` (transcript detection, fallback, signal consistency, fix record, combined-run allowance)
- `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`, `tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1`, `tests/scripts/claude-hooks/validate-planner-output.Reentry.Tests.ps1` (modified: valid-plan fixtures gain a `## Pre-Mortem` section)
- `tests/scripts/claude-hooks/validate-executor-output.Tests.ps1` (modified only where an existing case depends on plan-directive detection)

### Files deliberately not touched
`scripts/dev_tools/validate_orchestration_artifacts.py` (498 lines), `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` (499), `tests/scripts/dev_tools/test_plan_gate_parity.py` (494), `extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts` (494), `scripts/dev_tools/plan_gate_observability.py` (477), `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts` (474), `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md`, `.claude/settings.json`, orchestrator-state validators, `quality-tiers.yml` (all touched paths are already classified T3 or T4).

---

## Pre-Mortem

- Review checklists: the policy-audit, code-review, and feature-audit templates will be applied to about a hundred changed files across three surfaces. Mitigation: the final phase writes `evidence/qa-gates/self-review.<timestamp>.md` against all three templates before the first review push; the self-review explicitly covers tonality of every new contract sentence (the remediation skill's `### Cycle-Document Sweep Scope` lesson), since this item writes mostly prose.
- Coverage: new code must reach 85% line and 75% branch per file. Mitigation: `plan_gate_document.py` measured with `--cov=scripts.dev_tools.plan_gate_document --cov-report=term-missing` and `--cov-report=json:artifacts/python/coverage.json` for branch figures; `plan-gate-document.ts` gated by its own `jest.config.cjs` entry; PowerShell hook changes measured line-only from `artifacts/pester/powershell-coverage.xml` produced by the self-hosted PoshQC module (not the MCP runner); transcript and file reads go through injected seams so the logic is exercised, not mocked away.
- Mirror parity: every `.claude` edit needs its bundle copy (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`); Codex bases and variants must be regenerated and the generator `--check` must pass; `.agents` bundle copies are compared by the Codex resource-contract test; the new hook helper and skill must be in pack manifests; the brief's six copies must be byte-identical. Mitigation: mirror copies are made by one `sh` script that copies canonical to bundle paths (which also keeps bundle `.ps1` copies out of the batch budget), followed by the generator and the full parity test set in the QA phase.
- File size: near-limit files are listed in "Files deliberately not touched"; touched files near the limit are `extensions/drm-copilot/jest.config.cjs` (489 lines, four-line entry, no comment), `.claude/hooks/validate-planner-output.ps1` (442), and `scripts/dev_tools/plan_gate_discrimination.py` (405). Mitigation: measure physical line counts (`@(Get-Content -LiteralPath <path>).Count` or `wc -l`), not `Measure-Object -Line`.
- Test isolation: no temporary files (hook tests use injected readers and in-memory transcript text); Jest runs once with `--randomize --seed=<n>` and the seed recorded; the new Python test modules run once in reverse order; Pester runs once in a single fresh process over the whole `tests/scripts` tree (the CI shape). Hook Pester suites under `tests/scripts/claude-hooks` also run on Linux, so they use `Join-Path` and no drive-letter paths.
- CI-only behavior: no test reads gitignored `artifacts/` state or `origin/main`; fixtures avoid CRLF and backslash literals; the helper is dot-sourced by both hooks and imported by tests in a way that survives the single-process Pester run; new skills contain no `npm run` token that is absent from `package.json` and no `vitest` mention.
- Evidence: baselines, QA gates, the corpus measurement for G11 to G13, the preflight-fix record format example, the self-review, and the #962 re-plan summary are written under `<FEATURE>/evidence/<kind>/` with clock-read stamps; no artifact records an absolute path.
- Batch budget: about eight production PowerShell files (four hooks plus bundle copies) exceed the direct-mode cap. Mitigation: execute in the item worktree with a non-terminal checkpoint whose `route_id` is `large` (or `preparation`/`remediation`); write bundle copies with the `sh` copy script, which the `Write|Edit` matcher does not see. Python production files are two, under the cap.
- Hooks under test are the branch's: isolated subagents would run `main`'s hooks. Mitigation: hook behavior is proven by Pester; the live #962 re-plan is delegated non-isolated from the item worktree.
- Installed-extension lag: the MCP validator will not apply G11 to G13 until the extension is released and installed. Mitigation: every in-item validation uses the Python CLI; the brief states the lag.
- Self-application: this item's own plan is subject to G11 to G13 and to the planner hook's Pre-Mortem check. Its inventory exceeds 40 tasks, so its plan carries a `## Size Justification` (generated files count as one generator task).

## Automation Feasibility

Every step is agentic: file edits, the Codex generator, Python, TypeScript, and PowerShell toolchains through the documented routes, the corpus measurement, the #962 spec snapshot (`git show` by the orchestrator), planner and executor delegations, and the read-only ruleset query (`gh api repos/drmoisan/drm-copilot/rulesets/15241672`). No human-interaction step was found; no `human_interaction.requirements[]` entry is needed. Releasing the extension so that the MCP validator applies the new rules is a follow-on rollout performed by the existing automated release flow, and no acceptance criterion depends on it.

## Recommendations and Decisions

| # | Open question | Decision | Reason |
|---|---|---|---|
| D1 | Brief location and loading | Skill `execution-environment`, preloaded via `skills:` in four Claude agents; Codex canonical-skill list; Copilot explicit reference | Deterministic preload; no rules-frontmatter conflict; mirrors to all surfaces |
| D2 | Brief text per surface | One byte-identical text in six locations, pinned by a new test | Avoids drift; dual paths make it surface-neutral |
| D3 | Line-number and SHA detection | G11 and G12, document-level, Blocking by operator-approved scope, documented false-positive classes, corpus measurement recorded as evidence | Implements the issue requirement; trivial-fix path removes the round-trip cost |
| D4 | Size guideline | G13 Blocking above 40 tasks or 400 lines without `## Size Justification` | Exoneration is author-controlled; numbers derived from #962 |
| D5 | Pre-Mortem enforcement channel | Planner and researcher SubagentStop hooks via a shared helper; not the validator | Same-session repair; avoids invalidating about a hundred validator fixtures |
| D6 | Preflight detection | Transcript first user message; fallback to plan directive or output signal; stop writing the directive into plans | Fixes the verified completion-check bypass |
| D7 | Defect classification and record | `PREFLIGHT-FIX:` and `PREFLIGHT-DEFECT:` lines; `preflight-fix-record:` evidence under `evidence/other/` | Machine-checkable; signal set unchanged for epic and parallel validators |
| D8 | Returns to planner | At most one; second failure halts with `blocked_reason: "validator_failed"` (planning) or `blocked_preflight_iteration_limit` (remediation) | Existing vocabulary; no tri-language validator change |
| D9 | Validator access | Add `mcp__drm-copilot__validate_orchestration_artifacts` to `atomic-planner` and `atomic-executor` tools | Planner can self-validate; preflight can validate |
| D10 | Self-review | Final-phase task writes `evidence/qa-gates/self-review.<timestamp>.md`; orchestrator checks it before the pre-feature-review commit | Uses existing templates; no template change |
| D11 | Proportionate remediation | `Remediation-Mode:` line; proportionate = one planner plus one combined preflight-and-execute executor run | No checkpoint schema change; validators satisfied |
| D12 | Researcher frontmatter defect | Move `evidence-and-timestamp-conventions` to `skills:`; add the brief | Related finding fixed in the item |
| D13 | Epic files | Do not edit `epic-orchestrate` or `epic-orchestrator.md` | Hash-pinned; #952 overlap; they defer to the orchestrate skill |
| D14 | Codex and Copilot scope | Edit base agents, shared contract skills, and loop-mandate sentences only; regenerate Codex variants | Keeps semantics aligned without rewriting gate statements |
| D15 | Validation | Orchestrator-owned re-plan of #962 from a spec snapshot, non-isolated, Python CLI validator | Exercises the branch's hooks and rules |

## Rejected Alternatives

- Brief as an unconditional or path-scoped rule: breaks the unconditional-rule test or never loads at research time.
- Brief injected by a `SubagentStart` hook: Claude-only and adds a hook surface.
- Pre-Mortem as a validator rule: invalidates most existing validator fixtures for a check the hook performs earlier.
- G11 and G12 as Warnings: ignorable by construction; the trivial-fix path makes Blocking cheap.
- A new `blocked_reason` member for preflight exhaustion: requires synchronized Python, TypeScript, and PowerShell vocabulary changes for no added information.
- Detecting preflight from the output signal alone: self-declared, and would let an execution run bypass completion checks.
- A new checkpoint field for remediation mode: requires validator changes on three runtimes.

## Test Strategy

- Python (`pytest`): G11 positive cases for each form, negatives (`500 lines`, inline-code `Line 5:` quotation, URL with port, fenced block); G12 positives (full and abbreviated SHA in prose and inline code), negatives (decimal IDs, all-letter hex word, UUID segment, `agent-` suffix, SHA-256 digest, fenced block); G13 at and above both thresholds, with and without a non-empty justification, and with an empty justification section; ordering after G10; context-free behavior. Docs tests for the rule file and contract sentences. Brief and single-pass contract tests across surfaces.
- TypeScript (`jest`): the same behavior cases plus verbatim parity rows and severity-constant parity.
- PowerShell (Pester): `Test-PreMortemSection` (each missing label, heading absent, case-insensitive match, "not applicable" accepted); planner hook (Pre-Mortem block is repairable, line-reference locators rejected); researcher hook (feature path requires the section, `docs/research/` path does not); executor hook (transcript directive present or absent, transcript unreadable fallback, plan file carrying a stale directive during execution now enforces completion checks, signal-consistency rules, fix-record existence, combined-run preflight block allowed only with no checked task).
- QA loop per language in the order format, lint, type-check, test, with coverage; the generator `--check`; the parity and pack-manifest tests; the seeded and reversed isolation runs; physical line counts of touched files.

## Open Risks

- The subagent transcript JSONL entry format is not a documented contract. The reader is isolated behind a seam and falls back rather than blocking; a format change degrades detection to the fallback, which is self-declared.
- The ruleset 15241672 context list is taken from the #962 plan and is unconfirmed; #952 and #953 may change job names or add contexts before this item merges. The brief must be refreshed if either merges first.
- G11 and G12 will report findings on plans authored before release if they are re-validated after release (for example a prepared parallel item re-checked later). The trivial-fix path covers them, but it adds work to that one preflight.
- The #962 re-plan acceptance depends on agent behavior. If its first preflight returns a substantive defect, that is a finding about the contract, handled by one proportionate correction rather than a new issue.
- A textual merge with #952 in `.claude/skills/orchestrate/SKILL.md` is expected; the bundle mirror must be re-copied after the merge.
- The #962 files were read from a local working tree, not from the pushed branch; the line and task counts could differ slightly from the pushed revision.
