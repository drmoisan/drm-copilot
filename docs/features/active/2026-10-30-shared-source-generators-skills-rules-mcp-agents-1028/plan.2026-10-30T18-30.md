# 2026-10-30-shared-source-generators-skills-rules-mcp-agents - Plan

- **Issue:** #1028
- **Parent (optional):** epic #1018, child 3
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T18-30
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature
- **Requirements sources:** `<FEATURE>/spec.md` (36 AC), `<FEATURE>/user-story.md` (14 AC); research `<FEATURE>/research/research.2026-10-30T22-46.md`

`<FEATURE>` is `docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028`. `SCRATCH` is `<session scratchpad>/issue-1028/`; scratch file names start with `issue-1028-`, and evidence records the token `SCRATCH`, never a host path. Tool routes, launchers, the Pester route, command-text restrictions and CI shape are owned by `.claude/skills/execution-environment/SKILL.md` (the brief) and are not restated here. Evidence files are `<FEATURE>/evidence/<kind>/<name>.<timestamp>.md`; a consuming task selects the lexicographically greatest match. Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`.

## Required References

- `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/plan-acceptance-gates.md`
- `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`

## Scope Boundary

- **Parallel-run blast radius (hard boundary).** This plan changes no file in the blast radius of any item of the parallel run `bugs-1001-1002-1003-1006` (the `blast_radius.paths` of every item in `docs/features/parallel/bugs-1001-1002-1003-1006/parallel.md`). Where a generator target or source is such a path (the protected set below), its source is authored so that the rendered output equals the post-merge file bytes; the file is written with identical bytes and does not appear in the diff from the merge base of `origin/main` and `HEAD`. [P6-T10] asserts this against the full blast-radius list recorded at [P0-T6].
- Protected set (blast-radius paths a generator of this child reads or renders): `.codex/config.toml`; the six execution-environment brief copies (`.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md` and their bundle copies); `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/pr-author/SKILL.md`, the six `.claude/skills/parallel-*/SKILL.md`; `.claude/agents/epic-orchestrator.md`, `.claude/agents/pr-author.md`, `.claude/agents/parallel-planner.md`, `.claude/agents/parallel-orchestrator.md`; `.claude/rules/parallel-orchestration.md`, `.claude/rules/orchestrator-state.md`; the bundle copy of each; and both `pack-manifests/core.json` bundle files. Consequence: no generated target may be a new bundled file (a new bundled file needs a pack-manifest entry); [P0-T6] stops execution if one is required.
- Not edited (run or read only): `.claude/settings.json`, `.claude/lib/blast-radius/**`, `config/blast-radius.json`, `config/file-size-baseline.json`, `config/poshqc-scan.json`, `config/poshqc-coverage.json`, `scripts/powershell/PoshQC/**`, `scripts/dev_tools/generate_codex_agent_variants.py`, `scripts/dev-tools/Invoke-FullRelease.ps1`, `scripts/dev-tools/sync-agents-from-instructions.ps1`, the Codex native converter, `.github/copilot-instructions.md`, `.github/workflows/**`, every `tests/scripts/dev_tools/test_push_down_*` file, `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`, `docs/features/templates/policy_audit/**`.
- Child 2 files are not edited: `extensions/drm-copilot/src/lib/development-docs/**`, `.claude/lib/development-docs/**`, their bundle copies, child 2's tests and spec. Child 1 files other than `config/harness-parity-matrix.json` (`generated_from`, `generator`, and the OQ-2 rule-skill entries) are not edited.
- No new Python, no new TypeScript, no new CI job, workflow step or required context. No execution-environment brief fact changes, so no brief-update task exists.
- The only owner stop is Phase 0. No later task halts for owner input.

## Execution Segments and Batch Budget

The brief (`## Batch Budget`) caps direct-mode Write/Edit at three distinct non-test PowerShell production files per session and resolved worktree. This plan has seven hand-written PowerShell production files, so it routes as follows:

- Route A (preferred): the orchestrator runs execution from the item worktree whose `artifacts/orchestration/orchestrator-state.json` selects the `large` route, where the cap does not apply.
- Route B (isolated executor worktrees): execution is split into three segments, each run by a separate executor delegation in its own worktree that starts from the branch head pushed by the previous segment. Segment A = Phase 0 and Phase 1 (`HarnessGeneration.psm1`, `HarnessMcpConfig.psm1`, `HarnessInstructions.psm1`: 3 files). Segment B = Phases 2 and 3 (`HarnessSkillMirror.psm1`, `HarnessRuleGeneration.psm1`: 2 files, one spare slot). Segment C = Phases 4 to 6 (`HarnessAgentGeneration.psm1`, `Invoke-HarnessGeneration.ps1`: 2 files, one spare slot). A correction to a Segment A module in a later segment uses that segment's spare slot.
- Files written by a generator run, test files, scratch launchers under `SCRATCH`, JSON, Markdown and YAML are not counted. No route writes production PowerShell through Bash to avoid the hook.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Gate, Policy Reads and Baselines

- [ ] [P0-T1] Verify owner decisions: read `<FEATURE>/spec.md` `## Owner Decisions` and confirm every row OQ-1 to OQ-9, and the planner rows PQ-1 and PQ-2 from `## Owner Questions` of this plan (added to that table by the orchestrator), carries an owner answer equal to its default.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-gate.<timestamp>.md` records one line per row (`<ID> | answer | equals-default: yes/no`). If any row is pending, absent or differs, the task stays unchecked, the record ends `GATE: STOP`, and the executor reports BLOCKED; no later task runs.
- [ ] [P0-T2] Verify child 1 (#1025) is merged into `origin/epic/shared-agent-harness-layer-integration` and present in `HEAD`: `config/harness-parity-matrix.json` and `config/harness-parity-matrix.schema.json` exist; `schema_version` major is 1; `scripts/harness/HarnessParityMatrix.psm1` and `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` exist; child 1's `survey/difference-approval.md` has `Approval-Status` `approved` or `approved-with-overrides`; the E2 result or an owner deferral is recorded and E2 does not show Codex rejecting Claude-only frontmatter keys; Q2 is recorded as unlinked and Q4 as porting in child 3; entries selected per spec `### Matrix Consumption` exist (selected by `ecosystem`, `kind`, `disposition`, `owner_child`, never by parsing `id`), and Claude-only and Codex-only agents are `native` (OQ-5).
  - Acceptance: the phase0-gate record lists each check with its result; any failure ends the record with `GATE: STOP` and the executor reports BLOCKED.
- [ ] [P0-T3] Verify child 2 (#1035) is merged into the integration branch and present in `HEAD`: the `development_docs_root` key in `config/orchestration-routing.json`, `.claude/lib/development-docs/DevelopmentDocsRoot.psm1`, `extensions/drm-copilot/src/lib/development-docs/write-scopes.ts`, and a write-scope checker suite under `extensions/drm-copilot/test/lib/development-docs/` exist; child 2's spec `### Interface for epic child 3` agrees with the OQ-9 answer.
  - Acceptance: the phase0-gate record names the checker suite file found (used by [P4-T8]); any failure ends the record with `GATE: STOP`.
- [ ] [P0-T4] Verify the parallel run has merged: for every `issue_num` in the `items` list of the run manifest (`docs/features/parallel/bugs-1001-1002-1003-1006/parallel.md`, read from `main` or from `origin/parallel/bugs-1001-1002-1003-1006-plan`), the issue is closed, its pull request is merged into `main`, and the merge commit is an ancestor of `HEAD`.
  - Acceptance: the phase0-gate record lists each issue number with PR state and ancestry result; any unmerged item, or an unreadable manifest, ends the record with `GATE: STOP`.
- [ ] [P0-T5] Re-verify every entry of `## Citation Register` against the merge base of `origin/main` and `HEAD`: each path exists, each symbol, heading and test name is present in its file.
  - Acceptance: the phase0-gate record lists each register entry as `present` or `moved`; any `moved`, renamed or removed item ends the record with `GATE: STOP`.
- [ ] [P0-T6] Record the blast-radius path list and run the protected-set pre-checks: copy every `blast_radius.paths` value of every manifest item into `<FEATURE>/evidence/baseline/blast-radius-paths.<timestamp>.md`; then (a) list every approved difference in child 1's approval artifact whose port action would change a protected path (a positive ported into, or a negative removed from, the Claude copy of `epic-orchestrate`, `orchestrate`, `pr-author`, a `parallel-*` skill, or either copy of `execution-environment`); (b) list every target path selected by spec `### Matrix Consumption`, plus every Codex rule-skill target of [P3-T1], that does not exist at `HEAD`.
  - Acceptance: both lists are recorded in the phase0-gate record; a non-empty list (a) or (b) ends the record with `GATE: STOP` and the executor reports BLOCKED.
- [ ] [P0-T7] Measure the largest `.codex/agents/*.toml` file in physical lines (brief, `## Preflight Defect Classes the Validator Cannot See`, for the counting method).
  - Acceptance: the phase0-gate record names the file and its count, and ends with `GATE: PASS` when [P0-T1] to [P0-T7] all passed.
- [ ] [P0-T8] Read the policy files in the order of `.claude/skills/policy-compliance-order/SKILL.md` (CLAUDE.md, general code change, general unit test, PowerShell rules, quality tiers, plan acceptance gates).
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-instructions-read.<timestamp>.md` carries `Timestamp:`, `Policy Order:` and the list of files read.
- [ ] [P0-T9] Capture the PowerShell format baseline for `scripts` and `tests/scripts` with the PoshQC format stage in check mode (route per brief).
  - Acceptance: `<FEATURE>/evidence/baseline/powershell-format.<timestamp>.md` with the four fields; `Output Summary:` states the count of files the formatter would change.
- [ ] [P0-T10] Capture the PowerShell analyzer baseline with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `scripts` and `tests/scripts`.
  - Acceptance: `<FEATURE>/evidence/baseline/powershell-analyzer.<timestamp>.md` with the four fields and the finding count by severity.
- [ ] [P0-T11] Capture the Pester baseline over `tests/scripts` with coverage through the self-hosted PoshQC module (route per brief, `## PowerShell Route and PoshQC MCP Limits`).
  - Acceptance: `<FEATURE>/evidence/baseline/pester-coverage.<timestamp>.md` records passed, failed and skipped counts read from `artifacts/pester/pester-junit.xml` and the overall line-coverage percentage read from `artifacts/pester/powershell-coverage.xml`.
- [ ] [P0-T12] Capture the Python contract-test baseline: one Pytest run of the eleven files in `## Contract Test Set` plus `tests/scripts/dev_tools/test_claude_rules_frontmatter.py`, `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` and `tests/scripts/dev_tools/test_check_quality_tiers.py` (no Python production file changes in this plan, so no coverage argument is used).
  - Acceptance: `<FEATURE>/evidence/baseline/python-contract-tests.<timestamp>.md` with the four fields and the passed and failed counts.
- [ ] [P0-T13] Capture the Codex variant generator `--check` baseline (`scripts.dev_tools.generate_codex_agent_variants` in module form) and the `scripts.dev_tools.check_quality_tiers` baseline, one artifact each.
  - Acceptance: `<FEATURE>/evidence/baseline/codex-variants-check.<timestamp>.md` and `<FEATURE>/evidence/baseline/quality-tiers-check.<timestamp>.md`, each with the four fields.
- [ ] [P0-T14] Capture the drm-copilot extension Jest baseline (route per brief), which includes child 2's write-scope checker suite.
  - Acceptance: `<FEATURE>/evidence/baseline/extension-jest.<timestamp>.md` with the four fields and suite and test counts.

### Phase 1 — Framework, MCP Configuration and Instructions

- [ ] [P1-T1] Create `scripts/harness-generation/HarnessGeneration.psm1` with: `Get-HarnessMatrixSelection` (filters parsed matrix entries by `ecosystem`, `kind`, `disposition`, `owner_child`; never reads `id`); `ConvertTo-HarnessGeneratedText` (LF line endings, no BOM); `Compare-HarnessFileMap` (expected map of repository-relative POSIX path to text versus injected reader, listing and reparse-point probe; returns `DRIFT`, `MISSING`, `EXTRA` findings; reparse points, CRLF and BOM are drift); `Write-HarnessFileMap` (injected writer; validates the whole map before the first write); `Format-HarnessDriftReport` (one `DRIFT: <path>`, `MISSING: <path>` or `EXTRA: <path>` line per finding plus a summary line); `Invoke-HarnessGeneration` (`-Surface` of `skills`, `rules`, `mcp`, `agents`, `instructions`, `all`; `-Check`; imports the surface module from `$PSScriptRoot`; order for `all`: instructions, mcp, skills, rules, agents; returns findings and an exit code 0 or 1); `Get-HarnessRepositoryDrift` (runs every surface in check mode with the default real-file-system script blocks, starts no process, reads no git history). Default I/O script blocks are module-scope parameters' defaults, and the writer uses UTF-8 without BOM.
  - Acceptance: the module imports without error and stays at or below 500 lines (guidance tier).
- [ ] [P1-T2] Create `tests/scripts/harness-generation/HarnessGeneration.Tests.ps1` with in-memory injected listing, reading, writing and reparse probes (no temporary files; modules removed in `AfterAll`), including `It` blocks: `returns exit code 0 when no target differs`, `reports DRIFT MISSING and EXTRA by repository-relative POSIX path`, `reports a CRLF target as drift`, `reports a BOM target as drift`, `reports a reparse-point target as drift`, `writes LF text without BOM`, `fails before any write and names the source path for a malformed source` (asserts the writer mock was called zero times), `selects matrix entries by fields and ignores id`, `orders the all surface as instructions mcp skills rules agents`, `repository drift lists the path when the injected reader returns drifted content`.
  - Acceptance: the suite passes in a Pester run scoped to `tests/scripts/harness-generation` (JUnit counts recorded in `<FEATURE>/evidence/qa-gates/phase1-pester.<timestamp>.md`).
- [ ] [P1-T3] Add a `scripts/harness-generation` entry to `quality-tiers.yml` with `tier: T4` and a rationale naming repository-internal generators of generated code (`.claude/rules/quality-tiers.md` T4 list). Existing tests asserting tier entries: `tests/scripts/dev_tools/test_check_quality_tiers.py`, `test_quality_tiers_contract.py`, `test_quality_tiers_contract_classification.py` use fixtures and are unaffected (unchanged).
  - Acceptance: `scripts.dev_tools.check_quality_tiers` in module form exits 0 with no QT007 or QT008 finding, recorded in `<FEATURE>/evidence/qa-gates/quality-tiers-check.<timestamp>.md`.
- [ ] [P1-T4] Create `scripts/harness-generation/sources/mcp-servers.json` holding the `drm-copilot` server's shared keys (`command`, package name, `-y` argument) and per-target keys (Claude: unpinned args; Codex: `required`, `enabled_tools`, `default_tools_approval_mode`, per-tool approval tables), copied from the post-merge `.mcp.json` and `[mcp_servers.drm-copilot]` region of `.codex/config.toml`; the Codex version pin is not stored (OQ-4).
  - Acceptance: the file parses with `ConvertFrom-Json`; [P1-T9] proves it renders both targets byte-equal.
- [ ] [P1-T5] Create `scripts/harness-generation/HarnessMcpConfig.psm1` with `Get-HarnessMcpFileMap` (renders `.mcp.json` and its bundle `extensions/drm-copilot/resources/claude-dir-customizations/.mcp.json`; renders `.codex/config.toml` and its bundle `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml` by replacing only the region from the first `[mcp_servers.` header up to the next header that does not start with `[mcp_servers.`, located by an anchored line scan; reads the pin from `packages/mcp-server/package.json` `version`; emits the single-line `args = ["-y", "@danmoisan/drm-copilot-mcp@<version>"]` shape that `Set-CodexMcpVersionPin` matches; no general TOML parsing).
  - Acceptance: the module imports without error and stays at or below 500 lines.
- [ ] [P1-T6] Create `tests/scripts/harness-generation/HarnessMcpConfig.Tests.ps1` with `It` blocks: `leaves every byte outside the mcp_servers region unchanged` (fixture with `default_permissions`, `[permissions.*]`, `[features]`, `[agents]`, `[[hooks.*]]` before and after the region), `renders the Codex args line on a single line with the package version`, `renders the Claude args unpinned`, `reports a drifted mcp region`, `fails before any write when the source lacks a server command`.
  - Acceptance: the suite passes (JUnit counts appended to the phase1-pester evidence).
- [ ] [P1-T7] Rewrite `AGENTS.md` as the hand-authored cross-tool source: no `# Converted standing guidance` heading, no `> NOTE: This file is **generated** from:` line, no embedded copy of a `.claude/rules` file, no coverage-threshold statement (OQ-7), every cited `.agents/skills/<name>/SKILL.md` exists; Codex-specific content (`## Codex Epic Planning and Model Routing`) kept. Copy it byte-identically to `extensions/drm-copilot/resources/codex-and-agents-customizations/AGENTS.md`. Tests asserting `AGENTS.md`: `test_push_down_codex_and_agents_resource_contracts.py` (root and bundle equality; unchanged, satisfied by the copy); `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` and the converter tests use fixtures (unchanged, unaffected).
  - Acceptance: [P1-T11] passes on the committed tree.
- [ ] [P1-T8] Edit `CLAUDE.md`: keep the YAML frontmatter; the line immediately after the closing `---` is `@AGENTS.md`; remove every H2 section whose body is carried by `AGENTS.md`; rewrite `## Policy Compliance Reading Order` so the rule sources under `scripts/harness-generation/sources/rules/` are named the canonical policy source and `.claude/rules/*.md` and `.github/instructions/*.instructions.md` are named generated outputs (OQ-3); any repository threshold statement stays here (OQ-7). Tests reading root `CLAUDE.md`: the feature-review coverage hook suites under `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/` mock the read (unchanged, unaffected).
  - Acceptance: [P1-T11] passes on the committed tree and `CLAUDE.md` states no coverage threshold that `AGENTS.md` lacks.
- [ ] [P1-T9] Run MCP generation in write mode through `Invoke-HarnessGeneration -Surface mcp` from a `SCRATCH` launcher, then confirm that `.codex/config.toml`, `.mcp.json` and both bundle copies are unchanged relative to the merge base (`git diff --exit-code <merge-base> -- .codex/config.toml .mcp.json` and `git status --porcelain` both empty for those paths).
  - Acceptance: `<FEATURE>/evidence/qa-gates/mcp-first-generation.<timestamp>.md` records the written paths and both empty results; any difference is fixed in the source, not in the target.
- [ ] [P1-T10] Create `scripts/harness-generation/HarnessInstructions.psm1` with `Get-HarnessInstructionFindings` (check-only: generated-header line, converter heading, embedded `.claude/rules` copy detected by whitespace-normalized H2 body equality with any rule file, nonexistent cited skill path, missing `@AGENTS.md` line after the `CLAUDE.md` frontmatter, any whitespace-normalized H2 body of `CLAUDE.md` equal to one in `AGENTS.md`, bundle `AGENTS.md` unequal to the root), returning findings in the common shape.
  - Acceptance: the module imports without error and stays at or below 500 lines.
- [ ] [P1-T11] Create `tests/scripts/harness-generation/HarnessInstructions.Tests.ps1` with a failing-input `It` block for each finding kind of [P1-T10] and `It 'passes on a conforming AGENTS.md and CLAUDE.md pair'`; then run `-Surface instructions -Check` and `-Surface mcp -Check` against the working tree from the `SCRATCH` launcher.
  - Acceptance: the suite passes and both check runs return exit code 0, recorded in `<FEATURE>/evidence/qa-gates/phase1-checks.<timestamp>.md`.
- [ ] [P1-T12] Update `config/harness-parity-matrix.json`: for each `mcp-server` entry and the `instructions` entries of `AGENTS.md` and `CLAUDE.md` selected per spec `### Matrix Consumption`, replace a `pending-source:` value in `generated_from` with the source path and set `generator` to `harness-generation/mcp` (instructions: `harness-generation/instructions` where the entry is `generated`), keeping ordering and two-space indentation.
  - Acceptance: `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` passes, recorded in `<FEATURE>/evidence/qa-gates/matrix-gate-phase1.<timestamp>.md`.
- [ ] [P1-T13] Run the analyzer on the three new modules and three new test files with `pssa.settings.psd1`.
  - Acceptance: zero findings, recorded in `<FEATURE>/evidence/qa-gates/phase1-analyzer.<timestamp>.md`.

### Phase 2 — Skill Mirror

- [ ] [P2-T1] Create `scripts/harness-generation/HarnessSkillMirror.psm1` with `Get-HarnessSkillMirrorFileMap`: for each entry selected per spec `### Matrix Consumption` (skill mirror row), render every file of `.agents/skills/<name>/` except `agents/openai.yaml` and `references/standard.md` to `.claude/skills/<name>/` and to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/<name>/`; copy the superset frontmatter as written; apply the ordered exact-text substitutions for the Claude target from `scripts/harness-generation/sources/skills/<name>.substitutions.json` (each `find` must occur exactly once, otherwise the source is malformed); report a file in a generated folder with no source counterpart as `EXTRA`; never list or touch an unselected skill folder.
  - Acceptance: the module imports without error and stays at or below 500 lines.
- [ ] [P2-T2] Create `tests/scripts/harness-generation/HarnessSkillMirror.Tests.ps1` with `It` blocks: `does not write or delete a skill with no selected matrix entry`, `does not mirror agents/openai.yaml`, `does not mirror references/standard.md`, `reports an extra file in a generated skill folder`, `applies each Claude substitution once`, `rejects a substitution whose find text occurs zero or two times`, `writes the bundle copy with the target`.
  - Acceptance: the suite passes, recorded in `<FEATURE>/evidence/qa-gates/phase2-pester.<timestamp>.md`.
- [ ] [P2-T3] Reconcile batch A (discovery family, as assigned in child 1's survey index `Batch` column): for each skill, apply the approved positive and negative differences from child 1's approval artifact to `.agents/skills/<name>/SKILL.md` and its bundle copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/`, add the Claude-only frontmatter keys to the source (superset), and write the substitution file so that the rendered Claude text is the intended Claude copy; protected skills render byte-equal to the post-merge file.
  - Acceptance: `<FEATURE>/evidence/qa-gates/skill-ports-batch-a.<timestamp>.md` lists every Diff ID of the batch with `applied` or `not-applicable` and the reason.
- [ ] [P2-T4] Reconcile batch B (foundation-and-policy family) as in [P2-T3]; `.agents/skills/execution-environment/SKILL.md` is not edited (protected) and renders byte-equal.
  - Acceptance: `<FEATURE>/evidence/qa-gates/skill-ports-batch-b.<timestamp>.md` as in [P2-T3].
- [ ] [P2-T5] Reconcile batch C (integration family) as in [P2-T3].
  - Acceptance: `<FEATURE>/evidence/qa-gates/skill-ports-batch-c.<timestamp>.md` as in [P2-T3].
- [ ] [P2-T6] Reconcile batch D (language-routing-and-gates family) as in [P2-T3].
  - Acceptance: `<FEATURE>/evidence/qa-gates/skill-ports-batch-d.<timestamp>.md` as in [P2-T3].
- [ ] [P2-T7] Reconcile batch E (orchestration family) as in [P2-T3]; `epic-orchestrate`, `orchestrate` and `pr-author` are protected and render byte-equal.
  - Acceptance: `<FEATURE>/evidence/qa-gates/skill-ports-batch-e.<timestamp>.md` as in [P2-T3].
- [ ] [P2-T8] Reconcile batch F (authoring-and-review-wrappers family) as in [P2-T3].
  - Acceptance: `<FEATURE>/evidence/qa-gates/skill-ports-batch-f.<timestamp>.md` as in [P2-T3].
- [ ] [P2-T9] Run skill-mirror generation in write mode (one generator run writes every selected `.claude/skills/<name>/` file and bundle copy), then confirm no protected path changed relative to the merge base (`git diff --name-only <merge-base>` plus `git status --porcelain`, compared with the protected set).
  - Acceptance: `<FEATURE>/evidence/qa-gates/skills-first-generation.<timestamp>.md` lists the changed paths and records an empty intersection with the protected set.
- [ ] [P2-T10] Run `-Surface skills -Check` and the Pytest files `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_issue_824_follow_ups.py`, `test_claude_rules_frontmatter.py` and `test_parallel_orchestrator_surface_contracts.py` (all unchanged). `PINNED_FROZEN_SURFACE_HASHES` stays unchanged because both pinned files are protected and byte-equal.
  - Acceptance: check exit code 0 and zero Pytest failures, recorded in `<FEATURE>/evidence/qa-gates/phase2-contracts.<timestamp>.md`.
- [ ] [P2-T11] Update `config/harness-parity-matrix.json` for the skill-mirror entries: `generated_from` `.agents/skills/<name>/SKILL.md`, `generator` `harness-generation/skills`.
  - Acceptance: `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` passes, recorded in `<FEATURE>/evidence/qa-gates/matrix-gate-phase2.<timestamp>.md`.

### Phase 3 — Path-Scoped Rules

- [ ] [P3-T1] Create `scripts/harness-generation/HarnessRuleGeneration.psm1` with `Get-HarnessRuleFileMap` over `scripts/harness-generation/sources/rules/<name>.json` plus `<name>.md`: renders `.claude/rules/<name>.md` (YAML `paths:` list and `description:`, emitted only when the source has a Claude target); each Copilot target `.github/instructions/<file>.instructions.md` (frontmatter opened and closed by `---`, `applyTo:` string, optional `name:`, body restricted to the source's listed H2 sections, default all); the Codex rule-skill `.agents/skills/<name>/SKILL.md` when a Codex rule-skill of that stem exists (OQ-2: a folder under `.agents/skills/` whose name is a `.claude/rules` stem and is absent from `.claude/skills/`); per-target ordered exact-text substitutions (carry `CLAUDE_PRECEDENCE_FRAGMENTS` and `CODEX_PRECEDENCE_FRAGMENTS` wording); the bundle copy of each target under `claude-customizations`, `customizations` or `codex-and-agents-customizations`. A Claude glob list that is empty or contains `**` is rejected unless the source declares `claudeUnconditional: true`. No Copilot instruction file is renamed or deleted (PQ-1).
  - Acceptance: the module imports without error and stays at or below 500 lines.
- [ ] [P3-T2] Create `tests/scripts/harness-generation/HarnessRuleGeneration.Tests.ps1` with `It` blocks: `renders a paths list for Claude and an applyTo string for Copilot`, `renders the Copilot frontmatter with an opening delimiter`, `selects only the listed H2 sections for a Copilot target`, `rejects a Claude glob that makes a non-deliberate rule unconditional`, `accepts a declared unconditional rule`, `renders the Codex rule-skill with its substitutions`, `writes each bundle copy`.
  - Acceptance: the suite passes, recorded in `<FEATURE>/evidence/qa-gates/phase3-pester.<timestamp>.md`.
- [ ] [P3-T3] Create rule sources for `general-code-change`, `general-unit-test`, `tonality`, `self-explanatory-code-commenting`: body from the current Claude rule (OQ-3), Copilot targets at the existing instruction file names, Codex targets per [P3-T1]; review the current Copilot and Codex text for positives and port them, with Codex-only content kept through Codex substitutions.
  - Acceptance: `<FEATURE>/evidence/qa-gates/rule-sources-foundation.<timestamp>.md` lists each source, its targets and each ported positive.
- [ ] [P3-T4] Create rule sources for `python`, `python-suppressions`, `powershell`, `typescript`, `typescript-suppressions`, `csharp` as in [P3-T3]; each language source lists the H2 sections of its `-code-change` and `-unit-test` Copilot targets.
  - Acceptance: `<FEATURE>/evidence/qa-gates/rule-sources-language.<timestamp>.md` as in [P3-T3].
- [ ] [P3-T5] Create rule sources for `architecture-boundaries`, `benchmark-baselines`, `ci-workflows`, `mermaid`, `orchestrator-state`, `parallel-orchestration`, `plan-acceptance-gates`, `quality-tiers`, `shell` as in [P3-T3]; the four deliberate unconditional rules of `DELIBERATE_UNCONDITIONAL_RULES` declare `claudeUnconditional: true`; `orchestrator-state` and `parallel-orchestration` Claude outputs are protected and render byte-equal.
  - Acceptance: `<FEATURE>/evidence/qa-gates/rule-sources-claude-scoped.<timestamp>.md` as in [P3-T3].
- [ ] [P3-T6] Create Copilot-only rule sources for `github-actions` and `github-actions-ci-cd-best-practices` (Copilot target only).
  - Acceptance: `<FEATURE>/evidence/qa-gates/rule-sources-copilot-only.<timestamp>.md` as in [P3-T3].
- [ ] [P3-T7] Run rule generation in write mode (one run), then confirm the protected-path intersection is empty and `.github/instructions/general-unit-test.instructions.md` and its bundle copy begin with `---`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/rules-first-generation.<timestamp>.md` records the changed paths, the empty intersection and the first-line check.
- [ ] [P3-T8] Run `-Surface rules -Check` and the Pytest files `test_claude_rules_frontmatter.py`, `test_push_down_tier_rule_adoption_gate.py`, `test_typescript_toolchain_instruction_contracts.py`, `test_push_down_issue_824_follow_ups.py`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py` (all unchanged).
  - Acceptance: check exit code 0 and zero Pytest failures, recorded in `<FEATURE>/evidence/qa-gates/phase3-contracts.<timestamp>.md`.
- [ ] [P3-T9] Update `config/harness-parity-matrix.json` for every `path-scoped-rule` entry selected per spec `### Matrix Consumption` (`generated_from` the rule source Markdown, `generator` `harness-generation/rules`) and for each generated Codex rule-skill's `codex` `skill` entry (`disposition` `generated`, `generated_from` the rule source, `generator` `harness-generation/rules`, `decision_ref` `#1028:spec.md#owner-decisions`).
  - Acceptance: `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` passes, recorded in `<FEATURE>/evidence/qa-gates/matrix-gate-phase3.<timestamp>.md`.

### Phase 4 — Agents

- [ ] [P4-T1] Create `scripts/harness-generation/HarnessAgentGeneration.psm1` with `Get-HarnessAgentFileMap` over `scripts/harness-generation/sources/agents/<name>.json` plus `<name>.md`: renders `.claude/agents/<name>.md` from an ordered list of frontmatter keys with raw YAML value text (including `tools`, `skills`, `memory`, `hooks`, `model`) and the body; renders base `.codex/agents/<name>.toml` from an ordered list of top-level keys with raw TOML value text and `developer_instructions` from the body with Codex substitutions; for sources marked `variantFamily: true`, emits the alias form produced by `render_base_alias` (no `model` or `model_reasoning_effort` before `developer_instructions`; the C3 model lines after `description`, values read from `config/orchestration-routing.json` `codex_model_policy`); passes `Write(` and `Edit(` literals through verbatim (D-16, OQ-9); writes the bundle copy of each target.
  - Acceptance: the module imports without error and stays at or below 700 lines.
- [ ] [P4-T2] Create `tests/scripts/harness-generation/HarnessAgentGeneration.Tests.ps1` with `It` blocks: `renders Claude frontmatter keys in source order`, `reproduces the hooks block exactly`, `renders the Codex base TOML with developer_instructions from the body`, `emits the C3 alias form for a variant family`, `copies Write and Edit literals verbatim including the leading slash`, `fails before any write and names the source for a missing required field`, `writes each bundle copy`.
  - Acceptance: the suite passes, recorded in `<FEATURE>/evidence/qa-gates/phase4-pester.<timestamp>.md`.
- [ ] [P4-T3] Create agent sources for the first third (alphabetical) of the agents selected per spec `### Matrix Consumption` (agents row; the names present in both `.claude/agents` and `.codex/agents`), reconciling body differences under child 1's positive, negative, neutral and mechanism-only rules (OQ-5); protected Claude agents render byte-equal.
  - Acceptance: `<FEATURE>/evidence/qa-gates/agent-reconciliation-part-1.<timestamp>.md` lists each agent, each difference, its class and its disposition.
- [ ] [P4-T4] Create agent sources for the second third as in [P4-T3].
  - Acceptance: `<FEATURE>/evidence/qa-gates/agent-reconciliation-part-2.<timestamp>.md` as in [P4-T3].
- [ ] [P4-T5] Create agent sources for the remaining third as in [P4-T3]; `epic-orchestrator` and `pr-author` Claude outputs are protected and render byte-equal.
  - Acceptance: `<FEATURE>/evidence/qa-gates/agent-reconciliation-part-3.<timestamp>.md` as in [P4-T3].
- [ ] [P4-T6] Run agent generation in write mode (one run), then run `scripts.dev_tools.generate_codex_agent_variants` in write mode and confirm it changes no file (`git status --porcelain` identical before and after), then confirm the protected-path intersection is empty and `scripts/dev_tools/generate_codex_agent_variants.py` is unchanged relative to the merge base.
  - Acceptance: `<FEATURE>/evidence/qa-gates/agents-first-generation.<timestamp>.md` records the changed paths, both porcelain listings and both empty results; the largest generated `.codex/agents/*.toml` is at or below 800 lines.
- [ ] [P4-T7] Run `-Surface agents -Check`, the Codex generator `--check`, and the Pytest files `test_push_down_pack_manifest_dependency_closure.py`, `test_codex_agent_wrapper_contracts.py`, `test_codex_handoff_contract_parity.py`, `test_generate_codex_agent_variants.py`, `test_claude_rules_frontmatter.py`, `test_parallel_orchestrator_surface_contracts.py` (all unchanged).
  - Acceptance: both checks exit 0 and zero Pytest failures, recorded in `<FEATURE>/evidence/qa-gates/phase4-contracts.<timestamp>.md`.
- [ ] [P4-T8] Run `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` and child 2's write-scope checker suite named in the phase0-gate record (Jest route per brief) against the generated agent files.
  - Acceptance: both pass with zero failures, recorded in `<FEATURE>/evidence/qa-gates/phase4-write-scopes.<timestamp>.md`.
- [ ] [P4-T9] Update `config/harness-parity-matrix.json` for the agent entries selected per spec `### Matrix Consumption` (`generated_from` the agent source Markdown, `generator` `harness-generation/agents`).
  - Acceptance: `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` passes, recorded in `<FEATURE>/evidence/qa-gates/matrix-gate-phase4.<timestamp>.md`.

### Phase 5 — Entry Script and Repository Gate

- [ ] [P5-T1] Create `scripts/harness-generation/Invoke-HarnessGeneration.ps1` with parameters `-Surface` (`skills`, `rules`, `mcp`, `agents`, `instructions`, `all`) and `-Check`; it imports `HarnessGeneration.psm1`, calls `Invoke-HarnessGeneration`, prints the report and exits with its exit code; `instructions` without `-Check` fails with a message that the surface is check-only.
  - Acceptance: the script stays at or below 100 lines.
- [ ] [P5-T2] Create `tests/scripts/harness-generation/Invoke-HarnessGeneration.Tests.ps1` (module function mocked) with `It` blocks: `passes Surface and Check through`, `exits 1 and prints each finding when drift exists`, `exits 0 with a no-drift summary`, `rejects instructions without Check`.
  - Acceptance: the suite passes, recorded in `<FEATURE>/evidence/qa-gates/phase5-pester.<timestamp>.md`.
- [ ] [P5-T3] Create `tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1`: imports the modules, calls `Get-HarnessRepositoryDrift` against the working tree and fails with every drifted path in the message; a second `It` asserts that no matrix entry selected per spec `### Matrix Consumption` whose source exists holds a `pending-source:` value and that each has `generator` set. It starts no process and reads no git history.
  - Acceptance: the gate passes on the committed tree, recorded in `<FEATURE>/evidence/qa-gates/repo-gate.<timestamp>.md`.
- [ ] [P5-T4] Run the entry script with `-Check` for each of `skills`, `rules`, `mcp`, `agents`, `instructions`, and with `-Surface all` in write mode followed by `git status --porcelain`.
  - Acceptance: each check exits 0 and the porcelain listing is identical before and after the write run, recorded in `<FEATURE>/evidence/qa-gates/entry-script-checks.<timestamp>.md`.
- [ ] [P5-T5] Confirm no file under `.github/workflows/` changed relative to the merge base (`git diff --name-only <merge-base> -- .github/workflows` plus `git status --porcelain -- .github/workflows`).
  - Acceptance: both empty, recorded in `<FEATURE>/evidence/qa-gates/workflows-unchanged.<timestamp>.md`.

### Phase 6 — Final QA

- [ ] [P6-T1] Run the PoshQC format stage in write mode over `scripts/harness-generation` and `tests/scripts/harness-generation`; restart the loop from this task if it changes any file.
  - Acceptance: `git status --porcelain` is identical before and after the run, recorded in `<FEATURE>/evidence/qa-gates/powershell-format.<timestamp>.md`.
- [ ] [P6-T2] Run the analyzer with `pssa.settings.psd1` over `scripts/harness-generation` and `tests/scripts/harness-generation`.
  - Acceptance: zero findings, recorded in `<FEATURE>/evidence/qa-gates/powershell-analyzer.<timestamp>.md`.
- [ ] [P6-T3] Run the full Pester suite over `tests/scripts` with coverage through the self-hosted PoshQC module (route per brief).
  - Acceptance: zero failures read from `artifacts/pester/pester-junit.xml`, recorded in `<FEATURE>/evidence/qa-gates/pester-coverage.<timestamp>.md`.
- [ ] [P6-T4] Read per-file line coverage from `artifacts/pester/powershell-coverage.xml` for the seven files of `## Language Classification` rows 1 to 7 and compare the overall figure with the [P0-T11] baseline.
  - Acceptance: each file at or above 85% line coverage and the overall figure not below baseline, recorded per file in `<FEATURE>/evidence/qa-gates/coverage-delta.<timestamp>.md`.
- [ ] [P6-T5] Run one Pytest invocation over `## Contract Test Set` plus `test_claude_rules_frontmatter.py`, `test_push_down_tier_rule_adoption_gate.py`, `test_check_quality_tiers.py`, then `scripts.dev_tools.check_quality_tiers` and the Codex generator `--check`, one artifact each.
  - Acceptance: zero failures and both exit 0, recorded in `<FEATURE>/evidence/qa-gates/python-contracts.<timestamp>.md`, `quality-tiers-final.<timestamp>.md`, `codex-variants-final.<timestamp>.md`.
- [ ] [P6-T6] Run the drm-copilot extension Jest suite with `--randomize` and a recorded seed (route per brief).
  - Acceptance: zero failures and the seed recorded in `<FEATURE>/evidence/regression-testing/jest-shuffled.<timestamp>.md`.
- [ ] [P6-T7] Run `tests/scripts/harness-generation` in one Pester process in three seeded shuffled file orders, recording each seed and file order.
  - Acceptance: three passing runs recorded in `<FEATURE>/evidence/regression-testing/pester-shuffled.<timestamp>.md`.
- [ ] [P6-T8] Run a fresh single-process Pester run over `tests/scripts` (CI shape).
  - Acceptance: zero failures recorded in `<FEATURE>/evidence/regression-testing/pester-single-process.<timestamp>.md`.
- [ ] [P6-T9] List files added relative to the merge base (`git diff --name-only --diff-filter=A <merge-base>` plus `git status --porcelain`) and check languages.
  - Acceptance: no added `.py` or `.ts` file, and every added code file appears in `## Language Classification` with its language, recorded in `<FEATURE>/evidence/qa-gates/language-check.<timestamp>.md`.
- [ ] [P6-T10] List files changed relative to the merge base (`git diff --name-only <merge-base>` plus `git status --porcelain`) and intersect them with the blast-radius list from [P0-T6] and the not-edited and child 2 paths of `## Scope Boundary`.
  - Acceptance: every intersection is empty, recorded in `<FEATURE>/evidence/qa-gates/edit-scope.<timestamp>.md`.
- [ ] [P6-T11] Run `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` and count physical lines of every added or changed non-Markdown file.
  - Acceptance: the gate passes and no counted file exceeds 800 lines, recorded in `<FEATURE>/evidence/qa-gates/file-size.<timestamp>.md`.
- [ ] [P6-T12] Confirm the six execution-environment brief copies are unchanged relative to the merge base and byte-identical to each other.
  - Acceptance: recorded in `<FEATURE>/evidence/qa-gates/brief-parity.<timestamp>.md`.
- [ ] [P6-T13] Check off the satisfied acceptance criteria in `<FEATURE>/spec.md` and `<FEATURE>/user-story.md`, leaving the CI-dependent items for S9.
  - Acceptance: every checked item cites its evidence file; the two CI-dependent items stay unchecked.
- [ ] [P6-T14] Walk the policy-audit, code-review and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base and write `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL or N/A row per checklist item; fix any FAIL, re-run the loop from [P6-T1], and rewrite the record.
  - Acceptance: the record has no FAIL row.

## Contract Test Set

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_issue_824_follow_ups.py`, `test_codex_agent_wrapper_contracts.py`, `test_codex_handoff_contract_parity.py`, `test_generate_codex_agent_variants.py`, `test_parallel_orchestrator_surface_contracts.py`, `test_typescript_toolchain_instruction_contracts.py` (all under `tests/scripts/dev_tools/`; run, never edited).

## Citation Register

Re-verified by [P0-T5]. Items that exist only after child 1 or child 2 merge are checked by [P0-T2] and [P0-T3] instead.

- `scripts/dev_tools/generate_codex_agent_variants.py`: `render_base_alias`, `--check`; `scripts/dev_tools/resolve_codex_deployment.py`: `GENERATED_AGENT_FAMILIES`
- `scripts/dev-tools/Invoke-FullRelease.ps1`: `Set-CodexMcpVersionPin`; `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1`
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`: `PINNED_FROZEN_SURFACE_HASHES`
- `tests/scripts/dev_tools/test_claude_rules_frontmatter.py`: `DELIBERATE_UNCONDITIONAL_RULES`, `test_unconditional_rule_set_is_exactly_the_four_deliberate_files`, `test_every_agent_preloaded_skill_resolves_to_an_existing_skill_file`
- `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`: `CLAUDE_PRECEDENCE_FRAGMENTS`, `CODEX_PRECEDENCE_FRAGMENTS`
- `tests/scripts/dev_tools/test_generate_codex_agent_variants.py`: `test_generator_check_mode_reports_no_drift`, `test_render_base_alias_pins_default_c3_profile_without_renaming`
- `scripts/dev_tools/quality_tiers_contract.py`: `QT007`, `QT008`; `scripts/dev_tools/check_quality_tiers.py`; `quality-tiers.yml` entries `scripts/ci`, `scripts/dev-tools`
- `config/orchestration-routing.json`: `codex_model_policy`; `packages/mcp-server/package.json`: `version`
- `.github/workflows/_poshqc.yml`: job `poshqc-shard`; `.github/workflows/_quality-checks.yml`: step `Verify Codex agent deployment profiles`; `config/poshqc-scan.json`: `scanFolders`; `config/poshqc-coverage.json`: `roots`
- `.claude/hooks/validate-feature-review-coverage.ps1`, `.claude/hooks/validate-feature-review-coverage-metrics.ps1`, `.claude/hooks/feature-review-coverage-thresholds.ps1`; suites `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`, `validate-feature-review-coverage.Coverage.Tests.ps1`, `validate-feature-review-coverage.Issue824.Tests.ps1`, `validate-feature-review-coverage.ThresholdsGuard.Tests.ps1`, `feature-review-coverage-thresholds.Tests.ps1`
- `AGENTS.md` heading `# Converted standing guidance`; `CLAUDE.md` heading `## Policy Compliance Reading Order`; `.github/instructions/general-unit-test.instructions.md`
- Both `pack-manifests/core.json` bundle files; the six execution-environment brief copies; `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`; `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`; every file of `## Contract Test Set`

## Language Classification

Owner rule (verbatim): "Avoid new Python (existing Python is tolerated: reuse, call or extend in place only). The language depends on where the new code runs: (1) anything pushed down to destination repos, meaning skills, skill helpers, hooks and libs, must be PowerShell or bash, never TypeScript and never Python; (2) TypeScript is ONLY for MCP commands (tools in the MCP server package) and extension commands." Owner exception E2 (language-native analyzer) does not apply to any artifact.

| # | Artifact | Runs where | Rule clause applied | Language |
| --- | --- | --- | --- | --- |
| 1 | `scripts/harness-generation/HarnessGeneration.psm1` | Developer machine and CI | No-new-Python; clause (2) excludes TypeScript; clause (1) also satisfied if pushed down (OQ-1) | PowerShell |
| 2 | `scripts/harness-generation/HarnessMcpConfig.psm1` | Same | Same | PowerShell |
| 3 | `scripts/harness-generation/HarnessInstructions.psm1` | Same | Same | PowerShell |
| 4 | `scripts/harness-generation/HarnessSkillMirror.psm1` | Same | Same | PowerShell |
| 5 | `scripts/harness-generation/HarnessRuleGeneration.psm1` | Same | Same | PowerShell |
| 6 | `scripts/harness-generation/HarnessAgentGeneration.psm1` | Same | Same | PowerShell |
| 7 | `scripts/harness-generation/Invoke-HarnessGeneration.ps1` | Same | Same | PowerShell |
| 8 | `tests/scripts/harness-generation/*.Tests.ps1` (five unit suites, entry-script suite, repository gate) | CI, existing `poshqc / PowerShell QC` shards | Test code for PowerShell modules | PowerShell (Pester) |
| 9 | `scripts/harness-generation/sources/**` (MCP list, rule and agent JSON plus Markdown pairs, skill substitution files) | Data | Not code | JSON and Markdown |
| 10 | `.agents/skills/<name>/SKILL.md` edits and bundle copies; `AGENTS.md`, `CLAUDE.md` | Pushed-down and runtime text | Not code | Markdown |
| 11 | Generated outputs (`.claude/skills/**`, `.claude/rules/*.md`, `.github/instructions/*.instructions.md`, Codex rule-skills, `.mcp.json`, `.codex/config.toml` MCP region, `.claude/agents/*.md`, base `.codex/agents/*.toml`, bundle copies) | Runtime text | Generator output, not hand-written code | Markdown, JSON, TOML |
| 12 | `quality-tiers.yml` entry; `config/harness-parity-matrix.json` upkeep | Configuration | Not code | YAML, JSON |
| 13 | `scripts/dev_tools/generate_codex_agent_variants.py` | Developer machine and CI | Existing Python, called by its own CLI, not edited | Existing Python (unchanged) |
| 14 | `PINNED_FROZEN_SURFACE_HASHES` | CI | Not changed: both pinned files are protected and byte-equal | Existing Python (unchanged) |
| 15 | Child 2 write-scope checker suite | CI | Existing TypeScript test, run only (D-16 assertion) | Existing TypeScript (unchanged) |
| 16 | Session launchers under `SCRATCH` | Executor session only, not committed | No-new-Python | sh and PowerShell (uncommitted) |

## Owner Questions

Language rule: no artifact needs a language outside the rule; no owner question arises from it. The two rows below are planner questions about scope interpretation; [P0-T1] requires each to be confirmed with its default.

| ID | Question | Plan default |
| --- | --- | --- |
| PQ-1 | OQ-3's default says Copilot instruction files are generated "with the Claude split". Taken literally, this renames `.github/instructions/<lang>-code-change` and `-unit-test` files into one file per language; those names are cited by about 68 files outside this child's edit set, including `.github/copilot-instructions.md` (child 6), `.github/agents/**`, templates and converter tests. | Keep every existing Copilot instruction path (the matrix `target_paths`); one rule source per Claude rule emits each of its Copilot files with a declared H2 section list; no Copilot file is renamed or deleted. |
| PQ-2 | The orchestrator forbids edits to parallel-run blast-radius paths, which include generator targets (`.codex/config.toml`, several shared skills, agents and rules, both `core.json`). | Zero-diff rule: protected targets render byte-equal to their post-merge content; approved skill differences that would change a protected path, and any new bundled target, stop execution at [P0-T6]; `PINNED_FROZEN_SURFACE_HASHES` is not re-baselined because the pinned files do not change. |

## AC Traceability

| AC | Requirement (short) | Tasks |
| --- | --- | --- |
| S-P0-1 | Owner answers equal defaults before Phase 1 | P0-T1 |
| S-P0-2 | Child 1 and child 2 outputs present | P0-T2, P0-T3 |
| S-P0-3 | Parallel run merged; edit set re-checked | P0-T4, P0-T5, P0-T6 |
| S-FW-1 | `-Check` exit codes and per-path lines | P1-T1, P1-T2, P5-T1, P5-T2, P5-T4 |
| S-FW-2 | Malformed source fails before write | P1-T1, P1-T2, P4-T2 |
| S-FW-3 | LF, no BOM, CRLF/BOM/symlink drift | P1-T1, P1-T2 |
| S-FW-4 | `quality-tiers.yml` T4 entry, no QT007/QT008 | P1-T3 |
| S-IN-1 | `AGENTS.md` source conditions | P1-T7, P1-T10, P1-T11 |
| S-IN-2 | `CLAUDE.md` imports `@AGENTS.md`, no duplicate H2 | P1-T8, P1-T10, P1-T11 |
| S-IN-3 | No threshold in `AGENTS.md`; hook suites pass | P1-T7, P1-T8, P6-T3 |
| S-IN-4 | Bundle `AGENTS.md` equal | P1-T7, P1-T11 |
| S-MCP-1 | MCP outputs from one source; check exit 0 | P1-T4, P1-T5, P1-T9, P1-T11 |
| S-MCP-2 | Bytes outside MCP region unchanged | P1-T6, P1-T9 |
| S-MCP-3 | Pin shape and version; release tests pass | P1-T5, P1-T6, P6-T3, P6-T5 |
| S-SK-1 | Mirror equals source; check exit 0 | P2-T1, P2-T9, P2-T10 |
| S-SK-2 | Tool-only skills, `openai.yaml`, extra file | P2-T2 |
| S-SK-3 | Approved positives applied per Diff ID | P2-T3 to P2-T8 |
| S-SK-4 | Pinned hashes and surface tests | P2-T10, P4-T7 |
| S-RU-1 | Rule outputs from sources; check exit 0 | P3-T1, P3-T3 to P3-T7, P3-T8 |
| S-RU-2 | Rule contract tests unchanged; unconditional guard | P3-T2, P3-T8 |
| S-RU-3 | `general-unit-test.instructions.md` opens with `---` | P3-T7 |
| S-AG-1 | Agent outputs from sources; check exit 0 | P4-T1, P4-T3 to P4-T6, P4-T7 |
| S-AG-2 | Python variant generator no change; unedited | P4-T6, P4-T7 |
| S-AG-3 | Write-scope literals verbatim; child 2 checker passes | P4-T2, P4-T8 |
| S-AG-4 | Agent contract tests pass | P4-T7, P4-T8 |
| S-CI-1 | Repository gate runs every check mode | P1-T2, P5-T3 |
| S-CI-2 | No workflow change | P5-T5 |
| S-CI-3 | Required checks pass on PR head (S9) | P5-T3, orchestrator S9 |
| S-CI-4 | No `pending-source:` for sourced entries; child 1 gate | P1-T12, P2-T11, P3-T9, P4-T9, P5-T3 |
| S-CI-5 | Brief copies byte-identical | P6-T12 |
| S-QA-1 | 85% line coverage per new module | P6-T3, P6-T4 |
| S-QA-2 | Isolation runs | P6-T6, P6-T7, P6-T8 |
| S-QA-3 | No added `.py`/`.ts`; classification complete | P6-T9 |
| S-QA-4 | Excluded paths unchanged | P6-T10 |
| S-QA-5 | File size | P6-T11 |
| S-QA-6 | Contract tests after all generation | P6-T5 |
| U-1 | Gate stops on any failed precondition | P0-T1 to P0-T7 |
| U-2 | Check modes exit and name drift | P5-T4, P1-T2 |
| U-3 | LF, no BOM, no symlink, bundle written | P1-T2, P2-T2, P3-T2, P4-T2 |
| U-4 | Malformed source stops before writes | P1-T2 |
| U-5 | `AGENTS.md` source, `CLAUDE.md` import | P1-T7, P1-T8, P1-T11 |
| U-6 | One MCP list; rest of TOML untouched; pin works | P1-T5, P1-T6, P1-T9 |
| U-7 | Shared skills generated; exclusions | P2-T1, P2-T2, P2-T9 |
| U-8 | Rules generated; frontmatter and tier tests pass | P3-T7, P3-T8 |
| U-9 | Agents generated; variants unchanged; write scopes | P4-T6, P4-T7, P4-T8 |
| U-10 | Required check through one gate, no new job | P5-T3, P5-T5 |
| U-11 | Matrix entries record source and generator | P1-T12, P2-T11, P3-T9, P4-T9 |
| U-12 | No new Python or TypeScript | P6-T9 |
| U-13 | Coverage, isolation, file size | P6-T4, P6-T6 to P6-T8, P6-T11 |
| U-14 | Blast radius, child 2 and excluded paths unchanged | P6-T10 |

## Pre-Mortem

- Review checklists: a reviewer finds a hand-edited generated file or a stale `pending-source:` entry; the repository gate ([P5-T3]) runs every check mode and the matrix assertion, and [P6-T14] walks the three templates and blocks completion on a FAIL row.
- Coverage: render logic exercised only by the repository gate could leave a module below 85%; each module has its own in-memory unit suite ([P1-T2], [P1-T6], [P1-T11], [P2-T2], [P3-T2], [P4-T2], [P5-T2]), and [P6-T4] reads per-file figures from `artifacts/pester/powershell-coverage.xml` against the [P0-T11] baseline. No Python or TypeScript production file changes, so no Python or Jest coverage threshold applies.
- Mirror parity: every generator writes the bundle copy with its target, and the resource, manifest-completeness and dependency-closure tests run after each first generation ([P2-T10], [P3-T8], [P4-T7]) and in [P6-T5]; no new bundled file is created ([P0-T6]), so no pack manifest changes; `PINNED_FROZEN_SURFACE_HASHES` stays valid because the pinned files are protected and byte-equal. The plan changes no fact the execution-environment brief states (no CI job, required context, tool route or batch-budget rule changes), so no brief-update task exists; [P6-T12] confirms the six copies are unchanged.
- File size: one module per surface with stated ceilings; generated TOML is measured at [P0-T7] and [P4-T6]; [P6-T11] runs `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` and counts physical lines.
- Test isolation: suites use injected script blocks, create no temporary files and remove modules in `AfterAll`; [P6-T7] runs `tests/scripts/harness-generation` in three seeded shuffled file orders with seeds recorded, [P6-T8] runs a fresh single-process run over `tests/scripts`, and [P6-T6] runs a seeded shuffled Jest run with the seed recorded. No Python test module is new or changed, so the reversed-order Python run is not applicable.
- CI-only behavior: generated text is LF without BOM (the `eol=lf` attribute), paths are forward-slash relative built with `Join-Path`, no new suite lands under `tests/scripts/claude-hooks` or `tests/scripts/codex-hooks`, and the repository gate reads only the working tree, so the depth-one checkout and Linux hook job are unaffected; the gate runs in `poshqc / PowerShell QC shard 1` to `shard 3` on `windows-latest` and is aggregated by `poshqc / PowerShell QC`.
- Evidence: every task names `<FEATURE>/evidence/<kind>/<name>.<timestamp>.md`; counts come from `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`, never from PoshQC MCP summaries; scratch locations are recorded as `SCRATCH`.

## Size Justification

The plan has 75 tasks, above the 40-task guideline, because the orchestrator selected one plan for the whole child (OQ-8, orchestrator decision 1). It covers five generator surfaces, seven production files, content reconciliation in six skill batches, four rule groups and three agent groups, a seven-check Phase 0 owner gate, and per-language baseline and final QA. Each surface is self-validating within its phase, so splitting the content tasks further would add bucket tasks rather than reduce scope.

## Test Plan

- Unit: the five module suites and the entry-script suite under `tests/scripts/harness-generation/`, in-memory only.
- Integration: `HarnessGeneration.RepoGate.Tests.ps1` against the committed tree; contract tests in `## Contract Test Set`; child 2's write-scope checker; the Codex generator `--check`.
- Coverage evidence: baseline `<FEATURE>/evidence/baseline/pester-coverage.<timestamp>.md`; final `<FEATURE>/evidence/qa-gates/pester-coverage.<timestamp>.md`; comparison `<FEATURE>/evidence/qa-gates/coverage-delta.<timestamp>.md`.
