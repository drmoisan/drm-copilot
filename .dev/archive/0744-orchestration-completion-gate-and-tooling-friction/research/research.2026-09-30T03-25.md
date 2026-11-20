# Research: orchestration-completion-gate-and-tooling-friction (Issue #744)

Timestamp: 2026-09-30T03-25
Issue: #744
Branch: bug/orchestration-completion-gate-and-tooling-friction-744
Work Mode: full-bug
Baseline: origin/main at ae7c7779 (PR #784 merge)
Scope: re-verify each of the nine friction points in `issue.md` against current main and classify it.

Method: read-only inspection with file search and file reads in the workspace checkout. No git commands were available to this research step, so fixing commits are named only where the orchestrator-supplied merge history or file evidence identifies them. All paths are repository-relative.

## Current State Summary

Three independent implementations of the orchestrator-state completion gate exist and must stay consistent:

- Python authority: `scripts/dev_tools/validate_orchestrator_state.py` with helpers `scripts/dev_tools/_orchestrator_state_routing.py` and siblings.
- TypeScript MCP port: `extensions/drm-copilot/src/lib/validate/orchestrator-state-*.ts` (served by the `validate_orchestration_artifacts` MCP tool).
- PowerShell hook port: `.claude/lib/orchestrator-state/*.psm1`, loaded by `.claude/hooks/validate-orchestrator-output.ps1:41` and `:259` (bundled mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/`).

The PR-context collector exists in two implementations: Python `scripts/dev_tools/pr_context/` (CLI entry `dev.pr-context` in `pyproject.toml:79`) and the in-process TypeScript port under `extensions/drm-copilot/src/lib/pr-context/`, which the `collect_pr_context` MCP tool uses (`extensions/drm-copilot/src/repo-automation-service.ts:41`, `:158-164`).

## Step-by-Step Findings

### Step 1 — `ci_gate.verified_at` required but undocumented (#709)

Validator requirement (all three implementations agree):

- Python: `scripts/dev_tools/validate_orchestrator_state.py:109` `CI_GATE_KEYS = ("conclusion", "head_sha", "verified_at")`, enforced by `_validate_completion_ci_gate` at `:192-223`, invoked at `:472-473` when `route_requires_ci_gate` is true.
- TypeScript: `extensions/drm-copilot/src/lib/validate/orchestrator-state-completion.ts:29` declares the identical key list.
- PowerShell: `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1:72` declares the identical key list.

Documentation on the Claude surface:

- `.claude/skills/orchestrate/SKILL.md:277` (S9 step 3) instructs running `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`, which emits `verified_at` (`.claude/lib/ci-gate/Invoke-CiGateParser.ps1:11`, `:51`, `:216`).
- `.claude/skills/orchestrate/SKILL.md:293` and `:312` (section "Checkpoint Schema — CI Gate Fields") list `verified_at` explicitly.
- The field was already documented before #709: `docs/features/completed/2026-06-24-missing-ci-gate-parser-script-229/evidence/baseline/phase0-s9-contract.md:14` (Timestamp 2026-06-24T17-40) transcribes `verified_at` from the S9 contract of that date.

Residual gap on the Codex surface:

- `.agents/skills/orchestrate/SKILL.md:436-441` ("CI Green Gate") says only that the checkpoint "must record the checked head SHA and CI result"; it names neither `ci_gate`, its key set, nor `pr_gate`. Its completion list at `:284-296` also omits `ci_gate` and `pr_gate`. The Codex runtime validates through the TypeScript MCP port, which requires `verified_at` (`orchestrator-state-completion.ts:29`). Bundled mirror: `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md:436`.
- `.claude/skills/orchestrate/SKILL.md:214-221` ("Completion Requirements") does not cross-reference the `ci_gate`/`pr_gate` sections; this is a navigation gap, not an omission.

Classification: ALREADY-RESOLVED on the Claude surface (documented since at least 2026-06-24; Python, TypeScript, and PowerShell key sets are identical). STILL-REPRODUCIBLE, documentation only, on the Codex surface.

Minimal fix: in `.agents/skills/orchestrate/SKILL.md` "CI Green Gate", name the `ci_gate` object and its required keys (`conclusion`, `head_sha`, `verified_at`) and the `pr_gate` keys (`pr_number`, `pr_url`, `head_branch`, `head_sha`, per `scripts/dev_tools/_orchestrator_state_routing.py:12`); add `ci_gate`/`pr_gate` to the completion list at `:284-296`. Optionally add one cross-reference line to `.claude/skills/orchestrate/SKILL.md` "Completion Requirements". Update both bundled mirrors byte-identically.

Tests: the bundle parity contracts `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` cover mirror identity. A content assertion (key names present in the Codex skill) can follow the fragment pattern in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`.

### Step 2 — Promotion receipts demanded from items taken in by issue number (#710)

Where the demand originates:

- `config/orchestration-routing.json:26-32` (small), `:53-59` (large), `:93-98` (preparation) list `new_potential_entry` and `potential_to_issue` in `required_mcp_tools`.
- Python `validate_routing_contract` (`scripts/dev_tools/_orchestrator_state_routing.py:530-595`) requires the checkpoint list to equal the route list (`:571-575`) and a successful receipt for every entry (`:587-590`). The only adjustment is the bug-type substitution in `_resolve_promotion_entry_tools` (`:357-401`).
- TypeScript: `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts:443` emits the same error; the TypeScript port has no bug-type substitution (grep for `new_potential_bug_entry` in `extensions/drm-copilot/src/lib/validate/` returns no match), which is issue #405.
- PowerShell: `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1:415` emits the same error; the substitution exists there (`:31-61`).

`delegation_receipts.promotion.*` is not demanded: Python treats the `promotion` namespace as optional and only rejects unknown nested keys (`validate_orchestrator_state.py:275-297`); the TypeScript (`orchestrator-state-core.ts:278-292`) and PowerShell (`OrchestratorStateReceipts.psm1:173-183`) ports behave the same. The unsatisfiable requirement is the `mcp_call_receipts[]` entry for the promotion tools that an issue-intake item never calls.

Exemption search: no exemption for pre-existing issues or pre-existing potential entries exists in any implementation.

- SearchScope: all files outside `docs/` (scripts, extensions, `.claude/lib`, `.claude/hooks`, `config`, tests).
- SearchPatterns: `completion_gate_residuals`, `issue_intake`, `intake_mode`, `pre_existing_issue`, `preexisting` (case-insensitive).
- SearchResult: no validator or hook match; only unrelated test identifiers (`tests/shell/test_cleanup_worktrees_consolidation.bats:22`, two TypeScript test fixtures, one Python test comment).

`completion_gate_residuals` is therefore not understood by any validator. It is tolerated only because none of the three validators rejects unknown top-level keys; it neither satisfies nor suppresses the missing-receipt error.

The receipt contract itself is documented (`.claude/skills/orchestrate/SKILL.md:365-425`, "Routing-Contract Receipt Emission", including "The orchestrator records only truthful receipts" at `:367`). The defect is that a truthful checkpoint for an issue-intake item cannot pass. Line `:369` also still names only the Python helpers as readers although the completion hook now runs the PowerShell port.

Relationship to #405: not a duplicate. #405 is the TypeScript port missing the bug-type substitution; step 2 is a missing exemption in all three ports. Both change the same seam (the `required_mcp_tools` resolution feeding `validate_routing_contract` and its two ports), so they overlap in blast radius.

Classification: STILL-REPRODUCIBLE.

Candidate approaches:

- A. Documentation only: document `completion_gate_residuals` as the recording location. Rejected: the gate still fails, so every issue-intake item still ends with a failed completion check and a relay step.
- B. Key-gated, auditable intake declaration (recommended). Add an optional top-level checkpoint object, for example `promotion_intake: { mode, issue_num, potential_entry_path, evidence }` with `mode` in `new | existing_potential_entry | existing_issue`. `existing_potential_entry` removes only the promotion-entry tool (`new_potential_entry` or its bug substitute) from the required receipt set; `existing_issue` also removes `potential_to_issue`. `issue_num` must equal the checkpoint `issue-num`; `evidence` must be non-empty. Absent key keeps current behaviour byte-identical. The declaration is a policy-level record, in the same category as `standalone_merge_authorizations` (`.claude/rules/orchestrator-state.md:125-147`). The routing matrix and the exact-list check (`_state_list`) must apply the same reduced list so the checkpoint copy and the receipt loop stay consistent, as `_resolve_promotion_entry_tools` already does.
- C. Relax the routing matrix per route. Rejected: it would drop the promotion requirement for runs that do promote.

Minimal fix (approach B) files: `scripts/dev_tools/_orchestrator_state_routing.py`; `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts`; `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1` plus its bundled mirror; `.claude/rules/orchestrator-state.md` (new key-gated invariant section); `.claude/skills/orchestrate/SKILL.md` "Routing-Contract Receipt Emission" plus mirror; `.agents/skills/orchestrate/SKILL.md` plus mirror. Tests: `tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py`; the TypeScript routing-contract tests under `extensions/drm-copilot/test/lib/validate/`; `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletionChecks.Tests.ps1` (or the routing-contract Pester suite); a cross-runtime parity case.

Sizing note: this item touches Python, TypeScript, and PowerShell validator code in the same function region #405 changes. It is recommended as a separate item sequenced with or after #405 (see "Scope Sizing").

### Step 3 — CI-dependent AC check-offs stranded after parent merge (#710 AC-8)

Evidence of the case: `docs/features/completed/preimplementation-helpers-backslash-chain-operator-710/spec.md:213` (AC-8 requires a pass "in the CI PoshQC Pester job"), which can only be verified after S9.

Codification search:

- SearchScope: `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/skills/acceptance-criteria-tracking/SKILL.md`, `.claude/agents/parallel-orchestrator.md`, `.claude/agents/orchestrator.md`, and all files outside `docs/`.
- SearchPatterns: `CI-dependent`, `check-off(s) after|before`, `stranded`, `before reporting done`, `push(es) them|the check`; per-file greps for `acceptance`, `check-off`, `CI`, `push`.
- SearchResult: no rule. Nearest text:
  - `.claude/skills/parallel-orchestrate/SKILL.md:568-569` and `.claude/agents/parallel-orchestrator.md:276-277`: each item's AC must be checked off "by that item's own run". No timing rule relative to CI or merge.
  - `.claude/skills/acceptance-criteria-tracking/SKILL.md:71`: check off "as soon as the corresponding plan task passes verification"; `:81-87`: orchestrators do not check off AC themselves. No CI-dependent case.
  - `.claude/skills/orchestrate/SKILL.md:337` (PR Creation Gate condition 2) requires all AC to pass before PR creation, which a CI-dependent AC cannot satisfy before CI exists. This is the latent contradiction that leaves the check-off to an unspecified later step.
  - `.claude/skills/parallel-orchestrate/SKILL.md:318-326`: the parent merges on child DONE after confirming `ci_green`; nothing requires the child's final pushed head to include the check-off.

Classification: STILL-REPRODUCIBLE (documentation/procedure; mitigation exists only in delegation prompts).

Minimal fix:

- `.claude/skills/orchestrate/SKILL.md`: (a) in the PR Creation Gate, state that condition 2 excludes AC whose verification depends on CI of the PR head, which are listed as pending in the AC artifact; (b) in S9, add a step after `conclusion == "success"`: check off CI-dependent AC in the item's own worktree, commit, push to the PR branch, and re-run S9 against the new head SHA before writing DONE (DONE already requires `ci_gate.head_sha` to equal the current head, `:279`, `:341`).
- `.claude/skills/parallel-orchestrate/SKILL.md` "Per-Item Merge to Main (Merge-on-Green)" step 2 and "Completion Requirements" item 4: the parent confirms that `headRefOid` equals the child's reported `ci_gate.head_sha` and that the child reported no pending CI-dependent AC before merging; the parent never commits check-offs from the coordinator root. The existing fragments pinned by `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:197-203` (including "`.claude/skills/orchestrate/SKILL.md` is **not modified by this feature**", which is feature-scoped history) must remain present or be updated deliberately in the same change.
- `.claude/agents/parallel-orchestrator.md:276-277`: same clarification.
- `.claude/skills/acceptance-criteria-tracking/SKILL.md`: add a "CI-dependent criteria" rule (owner: the item's own orchestrator run; timing: after S9 success, before DONE; the check-off commit is pushed and re-verified).
- Parallel surfaces carrying the AC-tracking protocol: `.agents/skills/acceptance-criteria-tracking/SKILL.md`, `.github/skills/acceptance-criteria-tracking/SKILL.md`, and `.agents/skills/orchestrate/SKILL.md` (Codex has no parallel-orchestrate skill; glob found none).
- Bundled mirrors: `extensions/drm-copilot/resources/claude-customizations/.claude/skills/{orchestrate,parallel-orchestrate,acceptance-criteria-tracking}/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/{orchestrate,acceptance-criteria-tracking}/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/acceptance-criteria-tracking/SKILL.md`.

Tests: fragment assertions in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` / `test_parallel_orchestrator_surface_contracts.py`, or a Pester content contract modelled on `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1`; bundle parity tests for mirrors.

### Step 4 — MCP `run_poshqc_test` uses the installed extension's settings (#707 CR-3)

Resolution chain on current main:

- MCP schema: `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions-poshqc.ts:60-80` accepts only `workspace_root` and `scan_folders`; `additionalProperties: false`.
- Argument builder: `extensions/drm-copilot/src/repo-automation-args.ts:20-55` passes only `-WorkspaceRoot` and `-ScanFoldersJson`.
- Script: `extensions/drm-copilot/resources/templates/run-poshqc-test.ps1:22-32` imports the PoshQC module relative to the script (`..\powershell\PoshQC\PoshQC.psd1`) and calls `Invoke-PoshQCTest` without `-SettingsPath`.
- Module default: `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1:3` sets `$script:PesterSettings` from the module's own root; `PoshQC.Testing.psm1:156` defaults `-SettingsPath` to it; `:296-304` loads it and expands `CodeCoverage.Path` from it.
- Consequence: when the MCP server runs from the installed extension, the coverage path set comes from the installed copy of `resources/powershell/PoshQC/settings/pester.runsettings.psd1`, not from either in-repo copy (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` or the repository's bundled mirror).
- Contrast: scan folders already honour the workspace (`PoshQC.Testing.psm1:305-318` via `config/poshqc-scan.json`, read by `PoshQC.ScanConfig.psm1:31-125`). CI imports the self-hosted module (`.github/workflows/_poshqc.yml:41-42`), which reads `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.

#527 scope (from `docs/features/potential/promoted/2026-08-23-poshqc-coverage-denominator-not-reproducible.md`; no `docs/features/active/*527*` folder exists on main): establish a reproducibility test for the PowerShell coverage denominator, diagnose file-selection versus line-classification variance, and (per the orchestrator) change the coverage file set.

What of step 4 is outside #527: the settings-source resolution (installed extension copy versus repository copy) and the MCP tool's lack of a settings argument. These are distinct code paths (TypeScript tool schema and argument builder, bundled template, module default) from the coverage file list. However, the settings source is also a plausible cause of #527's denominator variance, because the MCP run and CI read different settings files.

Classification: STILL-REPRODUCIBLE.

Candidate approaches:

- A. Repository-config resolution (recommended): add an optional `test.settingsPath` (workspace-relative, `..`-free, fail-fast validated, same rules as `test.scanFolders`) to `config/poshqc-scan.json`, resolved in `PoshQC.ScanConfig.psm1` and consumed by `Invoke-PoshQCTest` only when `-SettingsPath` is not explicitly bound; point this repository's config at `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. Advantage: automatic for every caller, matches the existing scan-folder precedent, and makes the MCP run and CI read the same file. Limitation: edits the PoshQC module in both copies (`scripts/powershell/PoshQC/` and `extensions/drm-copilot/resources/powershell/PoshQC/`, held identical by `test_poshqc_bundled_parity.py`).
- B. MCP `settings_path` argument only. Rejected as the sole mechanism: callers must remember to pass it, which is the failure mode that produced CR-3. It can be added later as an explicit override.

Files for approach A: `config/poshqc-scan.json`; `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1` and `PoshQC.Testing.psm1`; their bundled copies under `extensions/drm-copilot/resources/powershell/PoshQC/`; `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions-poshqc.ts` and `extensions/drm-copilot/src/mcp-tool-definitions.ts:296` (description text only). Tests: the Pester suites for `PoshQC.ScanConfig` and `Invoke-PoshQCTest` (injected `LoadSettings`/`TestPathExists` seams at `PoshQC.Testing.psm1:167-168`), the PoshQC bundled parity test, and the TypeScript tool-definition tests.

Sizing note: the PoshQC module and settings files are shared with #527. Recommended as a separate item sequenced after #527, or folded into #527 if its diagnostic identifies the settings source as the cause.

### Step 5 — feature-review agent has no MCP artifact validator (#714)

- `.claude/agents/feature-review.md:5-11` tools: `Read`, `Grep`, `Glob`, `Bash(git diff *)`, `Bash(git log *)`, `Write(/docs/features/active/**)`. No MCP tool.
- The workflow skill requires validation: `.claude/skills/feature-review-workflow/SKILL.md:127`, `:140` ("Validate the artifact immediately after writing it") and `:175` ("Do not claim completion until every required artifact exists and its validator passes").
- The MCP validator supports the three review artifact types: `extensions/drm-copilot/src/mcp-tool-definitions.ts:411-413` (`policy-audit`, `code-review`, `feature-audit`) and `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts:273-277`.
- Parallel surfaces already provide it: `.codex/agents/feature-reviewer.toml:31` instructs MCP validation; `.github/agents/feature-review.agent.md:6` grants `drmcopilotextension/*`.

Classification: STILL-REPRODUCIBLE (Claude surface only).

Needed: add `"mcp__drm-copilot__validate_orchestration_artifacts"` to the `tools:` list of `.claude/agents/feature-review.md`, and add one body instruction to validate each of the three artifacts with `artifact_type` `policy-audit`, `code-review`, `feature-audit` before reporting paths. Mirror: `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md`. The `Write(...)` path suffix is not relevant to this change. Tests: bundle parity; a frontmatter content assertion (none currently pins this agent's tool list; `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1:61-62` reads the file for a different property).

### Step 6 — `collect_pr_context` exit-code pairing (#708) and `#AC-N` auto-close tokens (#706 FU-706-8)

6a. Exit-code pairing:

- Python `scripts/dev_tools/pr_context/verification_evidence.py:122-130`: `Timestamp`, `Command`, `EXIT_CODE` are assigned unconditionally (last occurrence wins); `ExpectedExitCode` is guarded (`key not in parsed`, first occurrence wins). A file with several `Command`/`EXIT_CODE` pairs is therefore parsed as the LAST command and LAST exit code against the FIRST expectation. This is exactly the #708 observation, recorded in `docs/features/completed/completion-consistency-edit-reads-relative-checkpoint-708/code-review.2026-09-27T08-50.md:50` (ExpectedExitCode 8 paired with the final command's EXIT_CODE 0) and `:79`.
- TypeScript `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts:128-146`: all four fields are first-occurrence-wins, so the first command, first exit code, and first expectation are paired. The #708 shape does not reproduce in the TypeScript collector (the MCP surface). The comments at `:111-112` and `:126-127` claim this mirrors Python; Python is last-wins, so the comments are inaccurate.
- The divergence is already known and tested as a runtime-specific case: `tests/scripts/dev_tools/pr_context/test_verification_evidence.py:30-40` (shape-06 excluded from cross-runtime agreement) and `extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts:152`, `:168-174`. An unpromoted potential entry describes it: `docs/features/potential/2026-08-20-pr-context-duplicate-required-key-precedence-divergence.md` (recommends converging on first-occurrence-wins in Python and correcting the TypeScript comment).
- The skill rule (`.claude/skills/evidence-and-timestamp-conventions/SKILL.md:121-122`) says ExpectedExitCode is per-file and first-wins, but says nothing about which `Command`/`EXIT_CODE` pair the expectation applies to.
- Impact boundary: both collectors discover evidence only under `docs/features/active/<feature>/` (`verification_evidence.py:90`, `verification-evidence.ts:90`), so converging Python changes rendering only for currently active features.

Classification 6a: STILL-REPRODUCIBLE in the Python collector; not reproducible in the TypeScript collector (parity defect).

Candidate approaches:

- A. Converge Python on first-occurrence-wins for the required fields (recommended). One guarded assignment in `verification_evidence.py`; aligns with TypeScript and with the ExpectedExitCode rule, so the first gate and its expectation are always paired. Correct the TypeScript comments. Update the skill to state that the first `Command`/`EXIT_CODE` pair is the gate the expectation applies to.
- B. Per-section parsing (one record per `Command`/`EXIT_CODE` pair). Rejected for this item: changes the one-record-per-file contract in both runtimes and the rendered PR body format, and contradicts the documented per-file rule.

Files (approach A): `scripts/dev_tools/pr_context/verification_evidence.py`; `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` (comments only); `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`, `.github/skills/evidence-and-timestamp-conventions/SKILL.md` and their three bundled mirrors under `extensions/drm-copilot/resources/{claude-customizations/.claude,codex-and-agents-customizations/.agents,customizations/.github}/skills/evidence-and-timestamp-conventions/SKILL.md`. Tests: `tests/scripts/dev_tools/pr_context/test_verification_evidence.py` (shape-06 expectation changes to the first value and joins the cross-runtime agreement set; add duplicated `Command` and `Timestamp` cases, the empty-second-value case, and a two-gate file whose first gate declares a non-zero expectation); `extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts` (remove the shape-06 exclusion); `tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py` for rendered output. A fail-before run is available by running the new Python two-gate test against the unmodified parser. The potential entry above would be satisfied by this change; its lifecycle disposition is an orchestrator decision.

6b. `#AC-N` auto-close tokens:

- Python `scripts/dev_tools/pr_context/models.py:26` `ISSUE_REFERENCE_PATTERN = (?<!\w)#\d+(?!\w)`; TypeScript `extensions/drm-copilot/src/lib/pr-context/models.ts:55` is identical. Both require a digit immediately after `#`, so `#AC-1` and `AC-1` cannot match. Every extractor uses the shared pattern (`render_pr_helpers.py:111`, `feature_docs.py:43`, `render_feature_excerpts.py:33`; `render-pr-helpers.ts:171`, `feature-docs-parsers.ts:87`, `render-feature-excerpts.ts:77`).
- Pinned by tests: `tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py:49-63` (rejects `AC-12`, `#CR-1`, `#ISO-8601`) and `extensions/drm-copilot/test/lib/pr-context/issue-reference-pattern.test.ts:28`.
- The coverage annotation file `scripts/dev_tools/pr_context/render.py,cover:110` (present in the working tree; whether it is tracked was not checked) shows the prior pattern `\b[A-Z][A-Z0-9]+-\d+\b`, which did match `AC-1`; this is consistent with the #706 observation coming from a pre-#622 installed extension.

Classification 6b: ALREADY-RESOLVED by #622 (PR #703, commits a27d1513 and 58b93e12, per the supplied history), verified by the shared pattern and its rejection tests. Verification needs no extension rebuild; the repository tests are the evidence.

### Step 7 — Local versus CI missed-line counts (1114 vs 1129, #712)

Evidence: `docs/features/completed/unused-npm-token-secret-712/evidence/qa-gates/final-pytest-coverage.2026-09-27T09-20.md:9` (local `TOTAL 15841 1114 5760 573 91%`) and `:46` (CI, four `ubuntu-latest` jobs, `TOTAL 15841 1129 5760 573 91%`); `coverage-comparison.2026-09-27T09-45.md:12-14`.

Analysis:

- Statements (15841), branches (5760), and partial branches (573) are identical, so the measured file set and branch structure are identical; only the executed-statement set differs, by 15 statements more missed on Linux.
- Measurement scope is fixed by configuration: `pyproject.toml:119-134` (`source = ["src", "scripts/dev_tools"]`; `src/` holds no Python files).
- Production code has platform- and environment-conditional paths: `scripts/dev_tools/atomic_executor/cli_workspace.py:241-264` (`sys.platform` clipboard selection), `scripts/dev_tools/tk_dialog_helpers.py:133-159`, `scripts/dev_tools/push_down_copilot_customizations.py:330` (`os.name`), and many `shutil.which` probes whose outcome depends on locally installed tools (for example `new_active_feature_folder_io.py:175`, `potential_to_issue.py:118`, `fix_all_branches_extra.py:213`). `fix_all.py:268-294` is not a contributor, because its test forces `sys.platform = "linux"` (`tests/scripts/dev_tools/test_fix_all_branches.py:308-314`).
- The local run also saw untracked `.claude/state/` files (same artifact, `:14`, `:29-34`), a second environment difference.
- Exact per-line attribution was not performed; it requires diffing the per-file `coverage.json` from both environments. The pattern (identical Stmts/Branch/BrPart, small Miss delta) is consistent with environment-conditional execution, not with a measurement defect.

Classification: INVESTIGATION-ONLY / NO-CODE-CHANGE. The uniform thresholds pass in both environments (91%), and the no-regression comparison in #712 was local-versus-local (`coverage-comparison.2026-09-27T09-45.md:12-13`), which is the correct like-for-like comparison. No code change is warranted.

### Step 8 — Batch-budget hook needs a reset between batches (#709 CR-9)

- The CR-9 recommendation: `docs/features/completed/gate-suites-read-unmocked-local-epic-state-709/code-review.2026-09-27T10-31.md:129` ("batch-boundary reset for `.claude/hooks/enforce-powershell-batch-budget.ps1` so plans do not need to delete state files").
- Current main: `.claude/hooks/enforce-powershell-batch-budget.ps1:16-23`, `:293-295`, `:384-398` exempt the session from counting when the checkpoint route is `large`, `remediation`, or `preparation` and the checkpoint is non-terminal; no state is written. The route decision is the shared helper `.claude/hooks/enforce-batch-budget-route.ps1:94-139` (#773), also dot-sourced by `.claude/hooks/enforce-python-batch-budget.ps1:63`, `:398`.
- A full-bug item such as #709 runs on the `large` route, so multi-batch plans on that route are no longer counted and need no reset. The `small` route remains capped by design (it is defined as within budget). The known limitation at `enforce-powershell-batch-budget.ps1:51-53` (a stale non-terminal large-path checkpoint exempts a later direct session) is mitigated by checkpoint hygiene (#673) and is not a reset requirement.

Classification: ALREADY-RESOLVED by #769 (PR #772, commit 53413fd1) and #773 (PR #780, commit daf9c403). No hook edit is recommended.

### Step 9 — Evidence timestamps 4-18 minutes later than their commits (#706 FU-706-6)

Evidence:

- `docs/features/completed/cleanup-report-registration-lost-false-positive-706/code-review.2026-09-27T10-48.md:39`: `other/commit-final.2026-09-27T10-55.md` is in a commit dated 10:40:13 -0400.
- `docs/features/completed/cleanup-report-registration-lost-false-positive-706/evidence/qa-gates/ci-shell-coverage.2026-09-27T10-48.md:3` and `:6`: `Timestamp: 2026-09-27T10-48` in an artifact whose own dispatch time is `2026-09-27T14:28:06Z` (10:28 at -0400), and the run was created at 14:28:09Z (`:20`).
- The plan defines `<ts>` as "the artifact creation time" (`plan.2026-09-26T22-56.md:25`), so the plan did not pre-assign the values.

Cause analysis:

- Time-zone confusion is excluded: the local offset is -0400, so a UTC/local mix-up would produce a 4-hour difference, not 4-20 minutes; the filenames are local time.
- The values are not derived from the host clock at write time. The skill defines only the format (`.claude/skills/evidence-and-timestamp-conventions/SKILL.md:44-47`); it states no time source and no time zone. The most likely cause is that the writing agent composed a plausible value rather than reading the clock; this is inferred from the evidence, not verified.

Classification: INVESTIGATION-ONLY / NO-CODE-CHANGE. No validator can check a timestamp against wall-clock creation time without git metadata. An optional documentation clarification is low-cost: add to the "ISO-8601 Timestamp Format" section that the value is local time read from the host clock at write time (for example `Get-Date -Format yyyy-MM-ddTHH-mm`) and is never estimated. If adopted, it rides with the step 6a skill edits (same six files).

## Behavior Semantics (retained scope)

- Step 3: a CI-dependent AC is owned by the item's own orchestrator run; it is checked off only after S9 records `conclusion == "success"`; the check-off commit is pushed to the PR branch and S9 is re-run so `ci_gate.head_sha` equals the final head before DONE. The parent merges only when `headRefOid` equals that SHA. Failure: if the re-run fails, the standard CI-failure remediation loop applies; the cap of 3 is unchanged.
- Step 5: the reviewer validates each artifact; a validator failure is fixed in the same review before reporting.
- Step 6a: for any evidence file, the first `Timestamp`, first `Command`, first `EXIT_CODE`, and first `ExpectedExitCode` form the record in both runtimes; a file with several gates reports its first gate. Artifacts with exactly one occurrence of each field render identically before and after.
- Steps 1 and 9: documentation only; no behaviour change.

## Automation Feasibility

No item requires human interaction.

- All retained changes are repository file edits plus test runs that agents already perform (Markdown, agent frontmatter, one Python module, TypeScript comments, Python/TypeScript/Pester tests).
- `.claude/` edits need no permission prompt in this repository: `.claude/settings.json:292` sets `defaultPermissionMode` to `bypassPermissions`.
- Verification of steps 4 and 6 does not require rebuilding or reinstalling the VS Code extension. The installed MCP server continues to serve its installed payload until a rebuild and reinstall, so the fixes cannot be observed through the MCP tools in the same run; the repository unit tests are the verification mechanism and are sufficient.
- Step 7 attribution (optional) would need a CI artifact download plus a local coverage run; both are agent-runnable with `gh` and pytest.
- No `human_interaction.requirements[]` entry is anticipated.

## Numeric Derivation Evidence

No numeric count, enumeration, or population is proposed for any `spec.md` acceptance criterion in this research. The figures cited (for example the coverage totals in step 7) are quotations of recorded evidence, not proposed assertions. If a later planning step proposes a numeric acceptance criterion, it must supply the full derivation record required by the research workflow.

## Scope Sizing

Recommendation: split. Keep steps 1 (Codex documentation), 3, 5, 6a, and optionally 9 in #744. Move step 2 and step 4 to separate items.

Reasoning:

- Retained scope is coherent and bounded: documentation and agent-frontmatter edits across the Claude, Codex, and Copilot surfaces with their mirrors, one Python parser change with a comment-only TypeScript change, and content/parity/unit tests. It has one executable behaviour change (6a), which has an available fail-before test.
- Step 2 changes completion-gate logic in three runtimes (Python, TypeScript, PowerShell) in the same `required_mcp_tools` resolution seam that #405 changes. Implementing it in #744 would create a blast-radius conflict with #405 and a large cross-runtime parity surface. It should be a separate item sequenced with or after #405.
- Step 4 changes the PoshQC module and settings resolution, which share files and the causal question with #527. It should be a separate item sequenced after #527, or folded into #527 if #527's diagnostic identifies the settings source.
- Steps 6b and 8 are resolved and step 7 needs no change, so they add no scope.

## Testing Implications

- Python: pytest with branch coverage for `scripts/dev_tools/pr_context/verification_evidence.py` (T2-level pure parsing; add a hypothesis property that, for any file, the parsed record equals the parse of the text truncated after the first occurrence of each field).
- TypeScript: Jest for the pr-context parser (comment change only; remove the shape-06 exclusion so the cross-runtime table asserts agreement).
- Documentation surfaces: fragment/content assertions following `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, plus the bundle parity tests `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`. Note that the Claude parity test can fail locally on gitignored `.claude/state/` files (issue #510); CI is the authoritative run for it.
- No temporary files: all parser tests use inline markdown strings, as the existing suites do.

## Summary

| Step | Classification | Evidence | Recommended files to change |
|---|---|---|---|
| 1. `ci_gate.verified_at` undocumented | ALREADY-RESOLVED (Claude surface); STILL-REPRODUCIBLE docs-only (Codex surface) | `validate_orchestrator_state.py:109`; `orchestrator-state-completion.ts:29`; `OrchestratorStateCompletionChecks.psm1:72`; `.claude/skills/orchestrate/SKILL.md:277`, `:293`, `:312`; #229 baseline `phase0-s9-contract.md:14`; `.agents/skills/orchestrate/SKILL.md:436-441` | `.agents/skills/orchestrate/SKILL.md` + mirror; optional cross-reference in `.claude/skills/orchestrate/SKILL.md` + mirror |
| 2. Promotion receipts for issue-intake items | STILL-REPRODUCIBLE; overlaps #405 seam (not a duplicate) | `config/orchestration-routing.json:26-98`; `_orchestrator_state_routing.py:557-590`; `orchestrator-state-routing.ts:443`; `OrchestratorStateRoutingContract.psm1:415`; no validator reads `completion_gate_residuals` | Separate item: `_orchestrator_state_routing.py`, `orchestrator-state-routing.ts`, `OrchestratorStateRoutingContract.psm1` + mirror, `.claude/rules/orchestrator-state.md`, orchestrate skills + mirrors, tests in three runtimes |
| 3. CI-dependent AC check-offs stranded | STILL-REPRODUCIBLE (procedure not codified) | `parallel-orchestrate/SKILL.md:318-326`, `:568-569`; `parallel-orchestrator.md:276-277`; `acceptance-criteria-tracking/SKILL.md:71`, `:81-87`; `orchestrate/SKILL.md:337`; #710 `spec.md:213` | `.claude/skills/{orchestrate,parallel-orchestrate,acceptance-criteria-tracking}/SKILL.md`, `.claude/agents/parallel-orchestrator.md`, `.agents/skills/{orchestrate,acceptance-criteria-tracking}/SKILL.md`, `.github/skills/acceptance-criteria-tracking/SKILL.md`, all bundled mirrors, fragment tests |
| 4. `run_poshqc_test` reads installed settings | STILL-REPRODUCIBLE; settings-source part is outside #527 but shares its files and causal question | `mcp-repo-automation-tool-definitions-poshqc.ts:60-80`; `repo-automation-args.ts:20-55`; `run-poshqc-test.ps1:22-32`; `PoshQC.psm1:3`; `PoshQC.Testing.psm1:156`, `:296-304`; `_poshqc.yml:41-42` | Separate item after #527: `config/poshqc-scan.json`, `PoshQC.ScanConfig.psm1` and `PoshQC.Testing.psm1` (both copies), tool description text, Pester and parity tests |
| 5. feature-review lacks MCP validator | STILL-REPRODUCIBLE (Claude surface only) | `.claude/agents/feature-review.md:5-11`; `feature-review-workflow/SKILL.md:127`, `:140`, `:175`; `mcp-tool-definitions.ts:411-413`; `.codex/agents/feature-reviewer.toml:31` | `.claude/agents/feature-review.md` + mirror |
| 6a. Last command paired with first expectation | STILL-REPRODUCIBLE (Python only; TS/Python parity defect) | `verification_evidence.py:122-130`; `verification-evidence.ts:128-146`, `:111-112`, `:126-127`; `test_verification_evidence.py:30-40`; #708 `code-review.2026-09-27T08-50.md:50`, `:79`; potential entry 2026-08-20 | `scripts/dev_tools/pr_context/verification_evidence.py`, `verification-evidence.ts` (comments), six evidence-skill copies, Python and TS parser tests |
| 6b. `#AC-N` listed as auto-close issues | ALREADY-RESOLVED by #622 (PR #703, a27d1513, 58b93e12) | `pr_context/models.py:26`; `pr-context/models.ts:55`; `test_issue_reference_pattern.py:49-63`; `issue-reference-pattern.test.ts:28` | None |
| 7. Local vs CI missed lines (1114 vs 1129) | INVESTIGATION-ONLY / NO-CODE-CHANGE | #712 `final-pytest-coverage.2026-09-27T09-20.md:9`, `:46`; identical Stmts/Branch/BrPart; platform/tool-conditional paths in `cli_workspace.py:241-264`, `tk_dialog_helpers.py:133-159`, `shutil.which` probes | None |
| 8. Batch-budget reset between batches | ALREADY-RESOLVED by #769 (PR #772, 53413fd1) and #773 (PR #780, daf9c403) | `enforce-powershell-batch-budget.ps1:16-23`, `:384-398`; `enforce-batch-budget-route.ps1:94-139`; `enforce-python-batch-budget.ps1:63`, `:398` | None |
| 9. Evidence timestamps later than commits | INVESTIGATION-ONLY / NO-CODE-CHANGE (optional doc clarification) | #706 `code-review.2026-09-27T10-48.md:39`; `ci-shell-coverage.2026-09-27T10-48.md:3`, `:6`, `:20`; `evidence-and-timestamp-conventions/SKILL.md:44-47` | Optional: time-source sentence in the six evidence-skill copies (same files as 6a) |
