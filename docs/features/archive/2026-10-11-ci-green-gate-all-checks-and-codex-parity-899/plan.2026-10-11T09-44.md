# 2026-10-11-ci-green-gate-all-checks-and-codex-parity (Plan)

- **Issue:** #899 (the pull request also resolves #891)
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-11T09-44
- **Status:** Draft (awaiting executor preflight)
- **Version:** 1.0
- **Work Mode:** minor-audit (`issue.md` `## Acceptance Criteria`, AC-1 through AC-11, is the sole acceptance-criteria source; `spec.md` and `user-story.md` are not required and must not exist in the feature folder)
- **Branch:** `bug/ci-green-gate-all-checks-and-codex-parity-899`
- **Feature folder:** `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899`
- **Requirements source:** `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/issue.md`, section `## Acceptance Criteria`
- **Research (context only):** `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/research/research.2026-10-11T09-50.md`

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path in each evidence-producing task. Do not mark evidence-backed work complete without the artifact. Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. `Timestamp:` is local time read from the host clock when the command runs. The artifact file names use the fixed plan stamp `2026-10-11T09-44` so every path below is deterministic.

**Evidence location:** every artifact is written under `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/<kind>/`. No artifact is written under `artifacts/`. No artifact records an absolute host path; the PoshQC `workspace_root` argument is recorded as `.` (the worktree root).

## Scope Recap

Binding scope is `issue.md` `## Implementation Intent`.

1. Claude S9 (`.claude/skills/orchestrate/SKILL.md` `## Step S9 — CI Green Gate`): drop `--required`; every check on the PR head SHA is queried for every PR; add a no-checks rule; keep the epic-child guard and every pinned fragment.
2. Parallel Merge-on-Green (`.claude/skills/parallel-orchestrate/SKILL.md` steps 1-2): the parent always re-reads every check on the child head through `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` and records `ci_green` only on `success`.
3. Codex `## CI Green Gate` (`.agents/skills/orchestrate/SKILL.md`): all-checks population, epic-child guard keyed on an `epic/<slug>-integration` base, `-RequireWorkflow CI` through the parser, the no-checks rule, and the parser-absent fail-closed rule.
4. Population wording aligned in `.claude/agents/orchestrator.md`, `.codex/agents/orchestrator.toml` (and its generated variants), `.agents/skills/orchestrator-workflow/SKILL.md`, `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, and the parser help and comments.
5. Every edited surface is kept byte-identical to its bundle mirror.
6. Two Pester tests execute both default `NowProvider` delegates deterministically through `Mock Get-Date`.
7. One new pytest contract module, `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`, pins items 1 through 4.

## Decisions Recorded by the Planner

- **Research recommendation 9 is not applied.** `.claude/agents/parallel-orchestrator.md:51` reads "merge each item's own pull request into `main` after durably confirming that its checks are green." It names no required-only population and does not accept the child's report without a durable re-read, so the operator condition for including it is not met. The file and its mirror stay unedited.
- **Parser line 197 is not edited.** The string `"Invoke-CiGateParser: required check is missing a 'bucket' property; cannot derive conclusion."` is a runtime error message, not help or comment text. Changing it would change behavior, which `issue.md` excludes.
- **Pester culture caveat.** The parser default delegate formats with `ToString('yyyy-MM-ddTHH:mm:ssZ')`. In a .NET custom format string `:` is the culture time separator, so an exact `'2026-06-24T17:00:00Z'` assertion depends on the host culture. The new tests assert `Should -BeLike '2026-06-24T17?00?00Z'`: each `?` matches exactly one character, so the assertion holds for any single-character time separator while still requiring the mocked date and time digits. The tests additionally assert `Should -Invoke -CommandName Get-Date -Times 1 -Exactly`, which fails if the default delegate does not reach the mock. Residual, accepted risk: a host culture with a non-Gregorian calendar would change `yyyy`; the CI PoshQC job runs on `windows-latest`.
- **PowerShell verification route (Option A).** Local PowerShell checks use only `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root. Their results carry an ok flag and summary text only. No acceptance condition in this plan asserts a count, percentage, or finding from them. No `sh`, `bash`, or `pwsh` wrapper is used to run Pester, PSScriptAnalyzer, bats, or kcov. The MCP test runner reads installed-extension settings, so the executor confirms that the new Pester tests were in the executed set by (a) passing `scan_folders` = `["tests/scripts/claude-lib/ci-gate"]`, the folder that contains `Invoke-CiGateParser.Tests.ps1`, (b) a `git grep` showing both new `It` titles in that file, and (c) the CI `poshqc-test-results` artifact under AC-9.
- **PowerShell coverage.** The baseline numeric value is the committed #841 reference (`LinePercent=97.83`, 45/46, missed line 338) read with `git show`. The post-change per-file value comes from the PR `CI` run artifact `poshqc-test-results` (`artifacts/pester/powershell-coverage.xml`) and is AC-9, recorded here as pending-CI and checked off later under S9, not in Phase 2. Until AC-9 is checked off, the PowerShell coverage outcome is PENDING-CI and the overall verdict must not be reported as PASS.
- **Python coverage.** No production Python file changes. The Python coverage evidence measures `scripts.dev_tools.generate_codex_agent_variants`, the only production Python module this plan executes, at baseline and final, to show no regression. Changed-line Python coverage is not applicable (zero changed production Python lines), and Phase 2 verifies that claim.
- **Mirror mechanism.** Every source and mirror pair is LF at HEAD (verified by the planner with a CR search returning no match; P0-T3 re-records it with `git ls-files --eol`). Each mirror task applies the identical Edit-tool `old_string`/`new_string` operations to the mirror that were applied to the source; because each pair is byte-identical at baseline (P0-T4), identical edits yield identical bytes. Each mirror task verifies with `git hash-object` and the parity tests in P2-T7. The twelve Codex `orchestrator*.toml` files are not hand-edited except the canonical `.codex/agents/orchestrator.toml`; the other eleven are written by `poetry run python -m scripts.dev_tools.generate_codex_agent_variants`.
- **No scratch files.** No task creates a scratch or helper file. If an executor needs one, its name must contain `899` (for example `SCRATCH/899/<name>`); a fixed shared name is prohibited.

## Concurrency and Out-of-Scope Constraints

- #890 owns the Python engine-call text in `.claude/skills/parallel-orchestrate/SKILL.md` near lines 665-666, 821, and 829. This plan edits only lines 373-380 of that file and its mirror. #900 may edit scratch-file guidance; this plan edits no scratch-file passage.
- Unedited by this plan: `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md`, `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`, every file under `.claude/rules/` and `.github/instructions/`, every schema, validator, and hook, and `.claude/agents/parallel-orchestrator.md`.
- No force-push. No deletion of any file. No GitHub issue creation. Every commit uses `git add` of explicit paths.

## Files Written Outside the Feature Folder (28)

Edited (27):

- `.claude/skills/orchestrate/SKILL.md` (P1-T3 through P1-T6)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` (P1-T7)
- `.claude/skills/parallel-orchestrate/SKILL.md` (P1-T8, P1-T9)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` (P1-T10)
- `.agents/skills/orchestrate/SKILL.md` (P1-T11 through P1-T14)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md` (P1-T15)
- `.claude/agents/orchestrator.md` (P1-T16)
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md` (P1-T17)
- `.codex/agents/orchestrator.toml` (P1-T18, P1-T19; rewritten idempotently by P1-T20)
- `.codex/agents/orchestrator-c1.toml`, `.codex/agents/orchestrator-c2.toml`, `.codex/agents/orchestrator-c3.toml`, `.codex/agents/orchestrator-c3-elevated.toml`, `.codex/agents/orchestrator-c4.toml` (P1-T20, generated)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator.toml`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c1.toml`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c2.toml`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c3.toml`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c3-elevated.toml`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c4.toml` (P1-T20, generated)
- `.agents/skills/orchestrator-workflow/SKILL.md` (P1-T21)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md` (P1-T22)
- `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` (P1-T23, P1-T24)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md` (P1-T25)
- `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` (P1-T26 through P1-T28; comment and help text only)
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1` (P1-T29)
- `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` (P1-T30, P1-T31)

Created (1):

- `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` (P1-T1)

Deleted: none.

Inside the feature folder: this plan (checklist state), `issue.md` (P2-T18 AC check-off), and the evidence artifacts named in each task.

## Restart Rule (Phase 2)

P2-T1 through P2-T12 form the final QC loop. If any of them fails, or if any of them changes a tracked file, fix the cause, re-apply the change identically to the affected bundle mirror when the changed file has one, and restart from P2-T1. Overwrite the P2 artifact of each re-run task with the latest run. Do not proceed to P2-T13 until P2-T1 through P2-T12 pass in one uninterrupted pass. If a hook denies a required command, stop and report the denial; do not bypass the hook.

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read the policy files in the required order and write `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/baseline/phase0-instructions-read.2026-10-11T09-44.md`.
  Order: `CLAUDE.md`; `.github/copilot-instructions.md`; `.claude/rules/tonality.md`; `.claude/rules/general-code-change.md`; `.github/instructions/general-code-change.instructions.md`; `.claude/rules/general-unit-test.md`; `.github/instructions/general-unit-test.instructions.md`; `.claude/rules/quality-tiers.md`; `.claude/rules/python.md`; `.claude/rules/python-suppressions.md`; `.github/instructions/python-code-change.instructions.md`; `.github/instructions/python-unit-test.instructions.md`; `.claude/rules/powershell.md`; `.github/instructions/powershell-code-change.instructions.md`; `.github/instructions/powershell-unit-test.instructions.md`; `.claude/rules/plan-acceptance-gates.md`.
  Acceptance: the artifact contains `Timestamp:`, `Policy Order:`, and the sixteen paths above in that order, one per line; it also records `Spec/User-Story Presence: none` after a Glob of `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/{spec.md,user-story.md}` returns no file (minor-audit fail-closed check). No policy file is modified.
- [x] [P0-T2] Capture the baseline branch state into `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/baseline/branch-state.2026-10-11T09-44.md`.
  Commands: `git fetch origin`; `git rev-parse --abbrev-ref HEAD`; `git rev-parse HEAD`; `git rev-parse origin/main`; `git status --porcelain`.
  Acceptance: `EXIT_CODE: 0` for each command; `Output Summary:` records the branch name `bug/ci-green-gate-all-checks-and-codex-parity-899` (any other value fails the task and halts execution), both SHAs, and the porcelain lines verbatim (or `none`).
- [x] [P0-T3] Capture the baseline line endings of the seven source and mirror pairs into `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/baseline/line-endings.2026-10-11T09-44.md`.
  Command: `git ls-files --eol -- .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md .claude/skills/parallel-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md .agents/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md .claude/agents/orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md .agents/skills/orchestrator-workflow/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md .claude/skills/remediation-handoff-atomic-planner/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md .claude/lib/ci-gate/Invoke-CiGateParser.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1`
  Acceptance: `EXIT_CODE: 0`; the output has 14 lines; `Output Summary:` records, per pair, whether both members show the same `w/` value (expected `w/lf` for all 14). A pair whose members differ fails the task and halts execution, because the identical-edit mirror mechanism requires matching endings.
- [x] [P0-T4] Capture the baseline mirror hashes into `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/baseline/mirror-hashes.2026-10-11T09-44.md`.
  Command: `git hash-object` over the same 14 paths, in the P0-T3 order.
  Acceptance: `EXIT_CODE: 0`; 14 hashes recorded with their paths; `Output Summary:` records `PAIRS_EQUAL=7/7`. Any unequal pair fails the task and halts execution, because the identical-edit mirror mechanism requires byte-identical pairs at baseline.
- [x] [P0-T5] Capture the baseline line counts into `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/baseline/line-counts.2026-10-11T09-44.md`.
  Command: `git grep -c "" -- .claude/lib/ci-gate/Invoke-CiGateParser.ps1 tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`
  Acceptance: `EXIT_CODE: 0`; `Output Summary:` records both printed counts verbatim and confirms both are at or below 500. P2-T11 compares the parser count against this value.
- [x] [P0-T6] Capture the baseline Python contract-suite result into `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/baseline/python-contract-suites.2026-10-11T09-44.md`.
  Command: `poetry run pytest tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py -q`
  Acceptance: the artifact records `EXIT_CODE:` and, in `Output Summary:`, the final pytest summary line verbatim (for example `N passed in S.SSs`). A baseline failure is recorded, not waived: if `EXIT_CODE` is non-zero, the executor confirms each failing node against `git hash-object` per research section 2, records the finding, and halts for the caller, because P2-T7 requires zero failures.
- [x] [P0-T7] Capture the baseline Python coverage into `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/baseline/python-coverage.2026-10-11T09-44.md`.
  Command: `poetry run pytest tests/scripts/dev_tools/test_generate_codex_agent_variants.py --cov=scripts.dev_tools.generate_codex_agent_variants --cov-branch --cov-report=term-missing -q`
  Acceptance: `EXIT_CODE: 0`; `Output Summary:` records the `TOTAL` row of the printed coverage table verbatim and the numeric value `PY_BASE_PCT=<Cover column value>` read from that row.
- [x] [P0-T8] Capture the baseline Codex variant drift check into `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/baseline/codex-variants-check.2026-10-11T09-44.md`.
  Command: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`
  Acceptance: `EXIT_CODE: 0` and empty stderr recorded. A non-zero exit fails the task and halts execution, because P1-T20 relies on a drift-free starting tree to attribute every regenerated file to this change.
- [x] [P0-T9] Capture the baseline PowerShell format state into `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/baseline/powershell-format.2026-10-11T09-44.md`.
  Commands: `git status --porcelain -- .claude/lib/ci-gate tests/scripts/claude-lib/ci-gate` (before); MCP `mcp__drm-copilot__run_poshqc_format` with `workspace_root` = worktree root and `scan_folders` = `[".claude/lib/ci-gate", "tests/scripts/claude-lib/ci-gate"]`; `git status --porcelain -- .claude/lib/ci-gate tests/scripts/claude-lib/ci-gate` (after).
  Acceptance: the artifact records the MCP ok flag, the summary text verbatim, and both porcelain outputs. The formatter is write-mode, so the success observation is the tree: the before and after porcelain outputs are both empty. A non-empty after output fails the task and halts execution, because a baseline formatter repair would detach the source from its mirror.
- [x] [P0-T10] Capture the baseline PowerShell analyzer state into `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/baseline/powershell-analyze.2026-10-11T09-44.md`.
  Command: MCP `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` = worktree root and `scan_folders` = `[".claude/lib/ci-gate", "tests/scripts/claude-lib/ci-gate"]`.
  Acceptance: the artifact records the ok flag and the summary text verbatim. No count or finding list is asserted.
- [x] [P0-T11] Capture the baseline Pester state into `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/baseline/pester-ci-gate.2026-10-11T09-44.md`.
  Command: MCP `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = worktree root and `scan_folders` = `["tests/scripts/claude-lib/ci-gate"]`.
  Acceptance: the artifact records the ok flag and the summary text verbatim. No test count or coverage figure is asserted.
- [x] [P0-T12] Capture the baseline PowerShell coverage reference into `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/baseline/powershell-coverage-reference.2026-10-11T09-44.md`.
  Commands: `git show HEAD:docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-pester-coverage.2026-10-08T22-17.md`; `git rev-parse HEAD:.claude/lib/ci-gate/Invoke-CiGateParser.ps1`.
  Acceptance: `EXIT_CODE: 0` for both; `Output Summary:` records `PS_BASE_REF_PCT=97.83`, `PS_BASE_REF_LINES=45/46`, `PS_BASE_REF_MISSED=338` (all three read from the shown file), and `BLOB_MATCH=true` when the printed blob ID equals `7c81ef17c6d627676472ca6311c8c1f4fdecdc5d` (the #841 final parser blob), otherwise `BLOB_MATCH=false`. The value is a reference baseline from CI-equivalent evidence; no MCP result is its source.
- [x] [P0-T13] Commit and push the Phase 0 evidence and plan checklist state for `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/`.
  Commands: `git add docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/`; `git commit -m "docs(899): record phase 0 baseline evidence"`; `git push origin bug/ci-green-gate-all-checks-and-codex-parity-899`.
  Acceptance: `git status --porcelain -- docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/` prints nothing, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-green-gate-all-checks-and-codex-parity-899`. No force-push.

### Phase 1 — Constrained Implementation

Phase 1 is executed by the implementation agent the orchestrator delegates to under the minimal-audit path. Every task is one edit or one verification with its own acceptance condition. Edits within one file run bottom-up so the cited line numbers stay valid. Exact replacement texts are in Appendix C; the new test module is Appendix A; the new Pester block is Appendix B.

- [x] [P1-T1] Create `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` with the exact content of Appendix A.
  Acceptance: the file exists; `git add tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` succeeds; `git grep -c "" -- tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` prints a count at or below 500.
- [x] [P1-T2] [expect-fail] Run the new contract module before any surface edit and record `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/regression-testing/pytest-all-checks-before-edit.2026-10-11T09-44.md`.
  Command: `poetry run pytest tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py -q`
  Acceptance: the artifact records `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and the summary line `32 failed, 2 passed` (the two passing nodes are the in-memory detector tests; the 32 failing nodes are the ten section-contract cases and the 22 population-surface cases, each of which reads text this plan has not yet changed). Any other summary fails the task: it means the module does not discriminate the current tree and must be corrected before any surface edit.
- [x] [P1-T3] Edit `.claude/skills/orchestrate/SKILL.md` line 345 per Appendix C.1(e): replace `(a failed required check;` with `(a failed check;`.
  Acceptance: `git grep -n -F -e "failed required check" -- .claude/skills/orchestrate/SKILL.md` exits 1 (no match).
- [x] [P1-T4] Edit `.claude/skills/orchestrate/SKILL.md` line 296 (S9 step 3) per Appendix C.1(d): replace the parenthetical `(the required checks on a non-epic PR; every observed check on an epic child)` with `(every check on the PR head SHA, for every PR)`; leave the rest of the line, including the one-line parser command, unchanged.
  Acceptance: `git grep -n -F -e "every check on the PR head SHA, for every PR" -- .claude/skills/orchestrate/SKILL.md` prints exactly one line.
- [x] [P1-T5] Edit `.claude/skills/orchestrate/SKILL.md` line 294 (epic-child paragraph) to the exact text of Appendix C.1(c).
  Acceptance: `git grep -n -F -e "the step 2 query is the same unfiltered query" -- .claude/skills/orchestrate/SKILL.md` prints exactly one line, and `poetry run pytest tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py -q -k "orchestrate_s9 or orchestrate_drops or orchestrate_parser or orchestrate_schema"` prints `8 passed`.
- [x] [P1-T6] Edit `.claude/skills/orchestrate/SKILL.md` line 292 (S9 step 2) to the exact text of Appendix C.1(a), and insert the No-checks paragraph of Appendix C.1(b) as a new indented paragraph between step 2 and the epic-child paragraph, separated by one blank line on each side.
  Acceptance: `git grep -n -F -e "--required" -- .claude/skills/orchestrate/SKILL.md` exits 1 (no match), and `git grep -n -F -e "No-checks rule:" -- .claude/skills/orchestrate/SKILL.md` prints exactly one line.
- [x] [P1-T7] Apply the P1-T3 through P1-T6 Edit operations identically to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` and append the result to `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/other/mirror-sync.2026-10-11T09-44.md`.
  Command: `git hash-object .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
  Acceptance: the two printed hashes are identical; the artifact entry records `Command:`, `EXIT_CODE: 0`, both hashes, and `Output Summary: PAIR_EQUAL=true claude-orchestrate`.
- [x] [P1-T8] Edit `.claude/skills/parallel-orchestrate/SKILL.md` Merge-on-Green step 2, lines 377-380 (from `2. On child completion, durably confirm` through `` `merge_status: ci_green`. ``), to the exact text of Appendix C.2(b); lines 381-385 stay unchanged. The parser command span stays on one line.
  Acceptance: `git grep -n -F -e "when the check conclusion" -- .claude/skills/parallel-orchestrate/SKILL.md` exits 1 (no match), and `git grep -n -F -e "only when that parser conclusion is" -- .claude/skills/parallel-orchestrate/SKILL.md` prints exactly one line.
- [x] [P1-T9] Edit `.claude/skills/parallel-orchestrate/SKILL.md` Merge-on-Green step 1, lines 373-376, to the exact text of Appendix C.2(a).
  Acceptance: `git grep -n -F -e "its checks are green" -- .claude/skills/parallel-orchestrate/SKILL.md` exits 1 (no match); no line outside the Merge-on-Green steps 1-2 changes, observed by `git diff -U0 HEAD -- .claude/skills/parallel-orchestrate/SKILL.md`, in which every `@@` hunk header has an old-side start line between 373 and 380 (the #890 passages near lines 665-666, 821, and 829 are untouched).
- [x] [P1-T10] Apply the P1-T8 and P1-T9 Edit operations identically to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` and append the result to `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/other/mirror-sync.2026-10-11T09-44.md`.
  Command: `git hash-object .claude/skills/parallel-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md`
  Acceptance: the two printed hashes are identical; the artifact entry records `Output Summary: PAIR_EQUAL=true claude-parallel-orchestrate`.
- [x] [P1-T11] Edit `.agents/skills/orchestrate/SKILL.md` line 476 (PR Creation Gate condition 5) to the exact text of Appendix C.3(d).
  Acceptance: `git grep -n -F -e "The required CI checks pass" -- .agents/skills/orchestrate/SKILL.md` exits 1 (no match).
- [x] [P1-T12] Edit `.agents/skills/orchestrate/SKILL.md` line 460: replace `the PR head SHA the required checks were observed against` with `the PR head SHA the queried checks were observed against`; every other character of the line is unchanged.
  Acceptance: `git grep -n -F -e "the queried checks were observed against" -- .agents/skills/orchestrate/SKILL.md` prints exactly one line, and `git grep -n -F -e "with the required keys" -- .agents/skills/orchestrate/SKILL.md` still prints exactly one line.
- [x] [P1-T13] Replace `.agents/skills/orchestrate/SKILL.md` lines 455-458 (the paragraph beginning `Before PR/DONE completion, the orchestrator must observe the live PR head SHA`) with the exact block of Appendix C.3(b); the `## CI Green Gate` heading and line 460 onward stay in place.
  Acceptance: `git grep -n -F -e "Parser-absent rule:" -- .agents/skills/orchestrate/SKILL.md` prints exactly one line, and `git grep -n -F -e "--required" -- .agents/skills/orchestrate/SKILL.md` exits 1 (no match).
- [x] [P1-T14] Edit `.agents/skills/orchestrate/SKILL.md` line 425: replace `a failed required check stays` with `a failed check stays`.
  Acceptance: `git grep -n -F -e "failed required check" -- .agents/skills/orchestrate/SKILL.md` exits 1 (no match).
- [x] [P1-T15] Apply the P1-T11 through P1-T14 Edit operations identically to `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md` and append the result to `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/other/mirror-sync.2026-10-11T09-44.md`.
  Command: `git hash-object .agents/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md`
  Acceptance: the two printed hashes are identical; the artifact entry records `Output Summary: PAIR_EQUAL=true agents-orchestrate`.
- [x] [P1-T16] Edit `.claude/agents/orchestrator.md` line 133 per Appendix C.4: replace `the orchestrator monitors the required CI checks against the live PR head SHA. A failed required check is not handled` with `the orchestrator monitors every CI check on the live PR head SHA. A failed check is not handled`.
  Acceptance: `git grep -n -i -F -e "required CI check" -- .claude/agents/orchestrator.md` exits 1 (no match).
- [x] [P1-T17] Apply the P1-T16 Edit operation identically to `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md` and append the result to `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/other/mirror-sync.2026-10-11T09-44.md`.
  Command: `git hash-object .claude/agents/orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md`
  Acceptance: the two printed hashes are identical; the artifact entry records `Output Summary: PAIR_EQUAL=true claude-orchestrator-agent`.
- [x] [P1-T18] Edit `.codex/agents/orchestrator.toml` line 193 per Appendix C.5(b): replace `The MCP validator and required CI checks are the hard completion boundary.` with `The MCP validator and every CI check on the current PR head SHA are the hard completion boundary.`
  Acceptance: `git grep -n -F -e "required CI checks" -- .codex/agents/orchestrator.toml` exits 1 (no match).
- [x] [P1-T19] Edit `.codex/agents/orchestrator.toml` line 191 per Appendix C.5(a): replace `8. Required GitHub checks are green for the current PR head SHA before any PR/DONE transition.` with `8. Every GitHub check on the current PR head SHA passed or was skipped before any PR/DONE transition.`
  Acceptance: `git grep -n -F -e "Required GitHub checks" -- .codex/agents/orchestrator.toml` exits 1 (no match).
- [x] [P1-T20] Regenerate the Codex orchestrator variants from `.codex/agents/orchestrator.toml` and record `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/other/codex-variants-regenerate.2026-10-11T09-44.md`.
  Commands: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants` (write mode); `git status --porcelain -- .codex/agents extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests`; `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`.
  Acceptance: the write-mode run exits 0, and because its exit code alone cannot distinguish outcomes, the success observation is the tree: the porcelain output lists exactly twelve ` M` entries, namely `.codex/agents/orchestrator.toml`, `.codex/agents/orchestrator-c1.toml`, `.codex/agents/orchestrator-c2.toml`, `.codex/agents/orchestrator-c3.toml`, `.codex/agents/orchestrator-c3-elevated.toml`, `.codex/agents/orchestrator-c4.toml`, and the same six names under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/`, and no pack-manifest entry; the `--check` run then exits 0 with empty stderr. The artifact records all three commands, exit codes, and the porcelain output verbatim.
- [x] [P1-T21] Edit `.agents/skills/orchestrator-workflow/SKILL.md` line 439 per Appendix C.6: replace `- required GitHub checks pass for the current PR head SHA before PR/DONE completion` with `- every GitHub check on the current PR head SHA passed or was skipped before PR/DONE completion`.
  Acceptance: `git grep -n -i -F -e "required GitHub checks" -- .agents/skills/orchestrator-workflow/SKILL.md` exits 1 (no match).
- [x] [P1-T22] Apply the P1-T21 Edit operation identically to `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md` and append the result to `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/other/mirror-sync.2026-10-11T09-44.md`.
  Command: `git hash-object .agents/skills/orchestrator-workflow/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md`
  Acceptance: the two printed hashes are identical; the artifact entry records `Output Summary: PAIR_EQUAL=true agents-orchestrator-workflow`.
- [x] [P1-T23] Edit `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` line 55: replace the leading `- A required CI check fails after the PR is open` with `- A CI check fails after the PR is open`; the parenthetical that follows is unchanged.
  Acceptance: `git grep -n -F -e "A CI check fails after the PR is open" -- .claude/skills/remediation-handoff-atomic-planner/SKILL.md` prints exactly one line.
- [x] [P1-T24] Edit `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` line 17: replace `- A required CI check fails after the pull request is open.` with `- A CI check fails after the pull request is open.`
  Acceptance: `git grep -n -F -e "A required CI check" -- .claude/skills/remediation-handoff-atomic-planner/SKILL.md` exits 1 (no match).
- [x] [P1-T25] Apply the P1-T23 and P1-T24 Edit operations identically to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md` and append the result to `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/other/mirror-sync.2026-10-11T09-44.md`.
  Command: `git hash-object .claude/skills/remediation-handoff-atomic-planner/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md`
  Acceptance: the two printed hashes are identical; the artifact entry records `Output Summary: PAIR_EQUAL=true claude-remediation-handoff`.
- [x] [P1-T26] Edit the help block of `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` lines 8, 41, 46, and 75 per Appendix C.7(a): remove `--required ` from the three cited `gh pr checks` commands (lines 8, 41, 75) and replace `the required checks were observed against` with `the queried checks were observed against` (line 46). Line count is unchanged.
  Acceptance: `git grep -n -F -e "--required" -- .claude/lib/ci-gate/Invoke-CiGateParser.ps1` exits 1 (no match).
- [x] [P1-T27] Edit the help block of `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` lines 20, 21, 23, and 24 per Appendix C.7(b): `Any required check` becomes `Any check`, `any required check` becomes `any check`, `An empty required-check set` becomes `An empty check set`, and the leading `required check can fail` on line 24 becomes `check can fail`. Line count is unchanged.
  Acceptance: `git grep -n -F -e "required-check set" -- .claude/lib/ci-gate/Invoke-CiGateParser.ps1` prints exactly one line (line 121, edited by P1-T28), and `git grep -n -F -e "An empty check set" -- .claude/lib/ci-gate/Invoke-CiGateParser.ps1` prints exactly one line.
- [x] [P1-T28] Edit the comments of `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` lines 121, 191, 206, and 207 per Appendix C.7(c): `a parsed required-check set` becomes `a parsed check set`; `Inspect each required check once` becomes `Inspect each check once`; `a failed required check is` becomes `a failed check is`; `a cancelled required check is` becomes `a cancelled check is`. Line 197 (a runtime error string) is not edited.
  Acceptance: `git grep -n -i -F -e "required check" -- .claude/lib/ci-gate/Invoke-CiGateParser.ps1` prints exactly one line, and that line is line 197; `git grep -n -F -e "required-check" -- .claude/lib/ci-gate/Invoke-CiGateParser.ps1` exits 1 (no match).
- [x] [P1-T29] Apply the P1-T26 through P1-T28 Edit operations identically to `extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1` and append the result to `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/other/mirror-sync.2026-10-11T09-44.md`.
  Command: `git hash-object .claude/lib/ci-gate/Invoke-CiGateParser.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1`
  Acceptance: the two printed hashes are identical; the artifact entry records `Output Summary: PAIR_EQUAL=true claude-ci-gate-parser`.
- [x] [P1-T30] Insert the `Context "default NowProvider delegates"` block of Appendix B with its first `It` block, "uses the Invoke-CiGateParser default NowProvider when none is injected", into `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` between the closing `}` of the last existing `Context` (line 409) and the closing `}` of the `Describe` (line 410).
  Acceptance: `git grep -n -F -e "uses the Invoke-CiGateParser default NowProvider when none is injected" -- tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` prints exactly one line; the block contains no `Start-Sleep`, no `New-TemporaryFile`, no `TestDrive`, and no `gh` call.
- [x] [P1-T31] Add the second `It` block of Appendix B, "uses the script-level default NowProvider when the script runs without -NowProvider", inside the same `Context` in `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`.
  Acceptance: `git grep -n -F -e "uses the script-level default NowProvider when the script runs without -NowProvider" -- tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` prints exactly one line, and `git grep -c "" -- tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` prints a count at or below 500.
- [x] [P1-T32] Run the new contract module after all surface edits and record `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/regression-testing/pytest-all-checks-after-edit.2026-10-11T09-44.md`.
  Command: `poetry run pytest tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py -q`
  Acceptance: `EXIT_CODE: 0` and the summary line `34 passed` recorded verbatim.
- [x] [P1-T33] Commit and push the Phase 1 changes: the 28 paths listed in `## Files Written Outside the Feature Folder` plus `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/`.
  Commands: `git add` of each of the 28 explicit paths and the feature folder path; `git commit -m "fix(899): evaluate every CI check in S9, parallel merge, and the Codex gate"`; `git push origin bug/ci-green-gate-all-checks-and-codex-parity-899`.
  Acceptance: `git status --porcelain` prints nothing for the 28 paths and the feature folder, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-green-gate-all-checks-and-codex-parity-899`. No force-push.

### Phase 2 — Final QC Loop and AC Check-off

P2-T1 through P2-T12 run under the Restart Rule above. Every command in this phase is unconditional; no task may record `EXIT_CODE: SKIPPED`.

- [x] [P2-T1] Run Black in check mode on `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` and record `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/qa-gates/final-python-black.2026-10-11T09-44.md`.
  Command: `poetry run black --check tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`
  Acceptance: `EXIT_CODE: 0` and the printed line `1 file would be left unchanged.` recorded. On a non-zero exit, run `poetry run black tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`, record its `1 file reformatted` line, and restart from P2-T1.
- [x] [P2-T2] Run Ruff on `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` and record `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/qa-gates/final-python-ruff.2026-10-11T09-44.md`.
  Command: `poetry run ruff check tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`
  Acceptance: `EXIT_CODE: 0` and the printed line `All checks passed!` recorded. No suppression is added.
- [x] [P2-T3] Run Pyright on `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` and record `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/qa-gates/final-python-pyright.2026-10-11T09-44.md`.
  Command: `poetry run pyright tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`
  Acceptance: `EXIT_CODE: 0` and the printed line `0 errors, 0 warnings, 0 informations` recorded.
- [x] [P2-T4] Run the PoshQC formatter over `.claude/lib/ci-gate` and `tests/scripts/claude-lib/ci-gate` and record `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/qa-gates/final-powershell-format.2026-10-11T09-44.md`.
  Commands: `git status --porcelain -- .claude/lib/ci-gate tests/scripts/claude-lib/ci-gate` and `git hash-object .claude/lib/ci-gate/Invoke-CiGateParser.ps1 tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1 tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` (before); MCP `mcp__drm-copilot__run_poshqc_format` with `workspace_root` = worktree root and `scan_folders` = `[".claude/lib/ci-gate", "tests/scripts/claude-lib/ci-gate"]`; the same `git status --porcelain` and `git hash-object` commands (after).
  Acceptance: the MCP ok flag is true; the formatter is write-mode, so the success observation is the tree: the before and after porcelain outputs are identical (both empty on the first pass after the Phase 1 commit), and the three hashes printed after equal the three printed before. A changed hash or porcelain line means the formatter repaired drift: commit nothing yet, re-apply the change to the parser mirror if the parser changed, and restart from P2-T1.
- [x] [P2-T5] Run the PoshQC analyzer over `.claude/lib/ci-gate` and `tests/scripts/claude-lib/ci-gate` and record `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/qa-gates/final-powershell-analyze.2026-10-11T09-44.md`.
  Command: MCP `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` = worktree root and `scan_folders` = `[".claude/lib/ci-gate", "tests/scripts/claude-lib/ci-gate"]`.
  Acceptance: the ok flag is true and the summary text is recorded verbatim. No count or finding is asserted.
- [x] [P2-T6] Run the Pester suite for `tests/scripts/claude-lib/ci-gate` and record `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/qa-gates/final-pester-ci-gate.2026-10-11T09-44.md`.
  Commands: MCP `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = worktree root and `scan_folders` = `["tests/scripts/claude-lib/ci-gate"]`; `git grep -n -F -e "default NowProvider" -- tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`.
  Acceptance: the ok flag is true and the summary text is recorded verbatim; the `git grep` prints the `Context` line and both `It` title lines (three lines), which shows that the two new tests are in the file under the scanned folder. No test count or coverage figure is asserted from the MCP result; the per-test and per-file confirmation is the CI artifact under AC-9.
- [x] [P2-T7] Run the Python contract suites and record `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/qa-gates/final-python-contract-suites.2026-10-11T09-44.md`.
  Command: `poetry run pytest tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py -q`
  Acceptance: `EXIT_CODE: 0`; the final summary line is recorded verbatim and contains `passed` and neither `failed` nor `error`. This run covers AC-1 through AC-6, AC-10 (including `test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror`), and AC-11.
- [x] [P2-T8] Capture the final Python coverage for `scripts/dev_tools/generate_codex_agent_variants.py` and record `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/qa-gates/final-python-coverage.2026-10-11T09-44.md`.
  Command: `poetry run pytest tests/scripts/dev_tools/test_generate_codex_agent_variants.py --cov=scripts.dev_tools.generate_codex_agent_variants --cov-branch --cov-report=term-missing -q`
  Acceptance: `EXIT_CODE: 0`; the `TOTAL` row is recorded verbatim; `PY_POST_PCT=<Cover column value>` is recorded and is at least 85 and at least `PY_BASE_PCT` from P0-T7.
- [x] [P2-T9] Verify that the Codex agent variants are in sync and record `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/qa-gates/final-codex-variants-check.2026-10-11T09-44.md`.
  Command: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`
  Acceptance: `EXIT_CODE: 0` and empty stderr recorded (AC-7).
- [x] [P2-T10] Verify the final mirror hashes of the seven hand-synced pairs and record `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/qa-gates/final-mirror-hashes.2026-10-11T09-44.md`.
  Command: `git hash-object` over the 14 paths listed in P0-T3, in the same order.
  Acceptance: `EXIT_CODE: 0`; `Output Summary:` records `PAIRS_EQUAL=7/7`, and every pair's hash differs from its P0-T4 baseline hash (each pair was edited).
- [x] [P2-T11] Verify the file-size limit for `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`, `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`, and `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`, and record `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/qa-gates/final-line-counts.2026-10-11T09-44.md`.
  Command: `git grep -c "" -- tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 .claude/lib/ci-gate/Invoke-CiGateParser.ps1`
  Acceptance: `EXIT_CODE: 0`; three counts recorded, each at or below 500; the parser count equals its P0-T5 count (line-count-preserving edits).
- [x] [P2-T12] Verify that no `--required` query remains in the edited gate surfaces and parser, and record `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/qa-gates/final-required-flag-search.2026-10-11T09-44.md`.
  Command: `git grep -n -F -e "--required" -- .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md .agents/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md .claude/lib/ci-gate/Invoke-CiGateParser.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1`
  Acceptance: `EXIT_CODE: 1` with no output, recorded with `ExpectedExitCode: 1` (git grep exits 1 when nothing matches).
- [x] [P2-T13] Verify the changed-path set against the allowed set and record `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/qa-gates/final-scope-boundary.2026-10-11T09-44.md`.
  Commands: `git fetch origin`; `git diff --name-only origin/main...HEAD`; `git status --porcelain`.
  Acceptance: the union of the diff output and the porcelain paths, excluding paths under `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/`, equals exactly the 28 paths in `## Files Written Outside the Feature Folder`. In particular `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md`, `.claude/agents/parallel-orchestrator.md`, `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`, and every path under `.claude/rules/`, `.github/instructions/`, `.claude/hooks/`, `.codex/hooks/`, and `scripts/dev_tools/` are absent (AC-11, constraints 1 and 6). The only `.py` path in the set is `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`, which confirms zero changed production Python lines. Any additional path fails the task; the executor records it with the output of `git log --oneline origin/main..HEAD -- <that path>` and halts for the caller rather than reverting or deleting it.
- [x] [P2-T14] Record the PowerShell coverage status for `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` in `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/qa-gates/final-powershell-coverage-status.2026-10-11T09-44.md`.
  Acceptance: the artifact records `PS_BASE_REF_PCT=97.83` and `PS_BASE_REF_MISSED=338` from P0-T12, `PS_POST_PCT=PENDING-CI`, the source of the post-change value (workflow `CI`, job `PowerShell QC`, artifact `poshqc-test-results`, file `artifacts/pester/powershell-coverage.xml`, `<sourcefile name="Invoke-CiGateParser.ps1">` under the package ending `.claude/lib/ci-gate`), and the statement that AC-9 is checked off under S9 and not in this plan. It also records that the parser edits are comment and help text only, so the changed executable-line count is 0.
- [x] [P2-T15] Write the coverage comparison `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/qa-gates/coverage-comparison.2026-10-11T09-44.md`.
  Acceptance: the artifact records, for Python, `PY_BASE_PCT`, `PY_POST_PCT`, and `PY_CHANGED_LINES=N/A (0 changed production Python lines, P2-T13)`; for PowerShell, `PS_BASE_REF_PCT=97.83`, `PS_POST_PCT=PENDING-CI`, and `PS_CHANGED_EXECUTABLE_LINES=0`; and the verdict `PYTHON: PASS` when `PY_POST_PCT` is at least 85 and at least `PY_BASE_PCT`, and `POWERSHELL: PENDING-CI (AC-9)`. The overall coverage verdict is not PASS while AC-9 is pending.
- [x] [P2-T16] Write the AC verification artifact `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/qa-gates/ac-verification.2026-10-11T09-44.md`.
  Acceptance: the artifact has one row for each of AC-1 through AC-11 from `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/issue.md`, each naming its verifying test or command and its evidence artifact path from this plan; AC-1 through AC-8, AC-10, and AC-11 are PASS only when their cited artifacts show the passing result; AC-9 is listed as `PENDING-CI` with the S9 check-off owner.
- [x] [P2-T17] Write the reduced-audit handoff record `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/other/reduced-audit-handoff.2026-10-11T09-44.md`.
  Acceptance: the artifact names the minor-audit review as the next step, the acceptance-criteria source (`issue.md` `## Acceptance Criteria`), the Phase 0 artifact paths, the P2 artifact paths, and the pending-CI item AC-9.
- [x] [P2-T18] Check off AC-1 through AC-8, AC-10, and AC-11 and the three `## Evidence Checklist` items in `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/issue.md`; leave AC-9 unchecked.
  Acceptance: `git grep -c -F -e "- [x] AC-" -- docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/issue.md` prints a count of 10, and `git grep -c -F -e "- [ ] AC-9" -- docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/issue.md` prints a count of 1.
- [x] [P2-T19] Commit and push the Phase 2 evidence, the plan checklist state, the AC check-off, and any Phase 2 restart repair to the 28 paths listed in `## Files Written Outside the Feature Folder`.
  Commands: `git add` of each of the 28 explicit paths listed in `## Files Written Outside the Feature Folder` (no effect on a path the Phase 2 loop did not change) and `git add docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/`; `git commit -m "docs(899): record final QC evidence and AC check-off"`; `git push origin bug/ci-green-gate-all-checks-and-codex-parity-899`.
  Acceptance: `git status --porcelain` prints nothing, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-green-gate-all-checks-and-codex-parity-899`. No force-push.

## Appendix A — `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`

The executor writes this content exactly (Black may reflow it in P2-T1; any reflow restarts the loop). The module defines 34 test cases: ten section-contract cases (five functions over two copies each), 22 population-surface cases, and two in-memory detector cases.

```python
"""Regression contract for issues #899 and #891.

Issue #899 pins that the CI green gate evaluates every check on the pull-request
head: the Claude S9 query carries no ``--required`` flag, S9 states that a
``no checks reported`` error is never green for any pull request, the parallel
Merge-on-Green step always re-reads every check through the CI gate parser, and
no orchestrator surface in scope restates a required-only check population.
Issue #891 pins that the Codex ``## CI Green Gate`` invokes the same parser,
passes ``-RequireWorkflow CI`` for an epic child, and fails closed when the
parser file is absent.

Every fragment search runs over whitespace-collapsed text, so a reflowed
sentence is still found. The module reads repository files only: it creates no
file, starts no process, and consults no external service.
"""

from __future__ import annotations

from pathlib import Path

import pytest

from tests.scripts.dev_tools.parallel_orchestrator_surface_test_support import (
    collapse_whitespace,
    extract_section,
    read_repo_text,
)

CLAUDE_BUNDLE = Path("extensions/drm-copilot/resources/claude-customizations")
CODEX_BUNDLE = Path("extensions/drm-copilot/resources/codex-and-agents-customizations")

CLAUDE_ORCHESTRATE = Path(".claude/skills/orchestrate/SKILL.md")
PARALLEL_ORCHESTRATE = Path(".claude/skills/parallel-orchestrate/SKILL.md")
CODEX_ORCHESTRATE = Path(".agents/skills/orchestrate/SKILL.md")
CLAUDE_ORCHESTRATOR_AGENT = Path(".claude/agents/orchestrator.md")
REMEDIATION_SKILL = Path(".claude/skills/remediation-handoff-atomic-planner/SKILL.md")
CODEX_ORCHESTRATOR_WORKFLOW = Path(".agents/skills/orchestrator-workflow/SKILL.md")
CODEX_ORCHESTRATOR_AGENTS: tuple[Path, ...] = tuple(
    Path(f".codex/agents/orchestrator{suffix}.toml")
    for suffix in ("", "-c1", "-c2", "-c3", "-c3-elevated", "-c4")
)

S9_HEADING = "## Step S9 — CI Green Gate"
MERGE_ON_GREEN_HEADING = "## Per-Item Merge to Main (Merge-on-Green)"
CODEX_GATE_HEADING = "## CI Green Gate"
REQUIRED_FLAG = "--required"

S9_ALL_CHECKS_FRAGMENTS = (
    "Invoke `gh pr checks --json bucket,name,state,link,workflow`",
    "The query covers every check on the head SHA for every PR",
    "over the queried checks (every check on the PR head SHA, for every PR)",
)
S9_NO_CHECKS_FRAGMENTS = (
    "No-checks rule:",
    "fails with a `no checks reported` error, that error is never treated as"
    " green for any PR",
    "The parser is never run with `-ChecksJson '[]'` without `-RequireWorkflow CI`",
)
MERGE_ON_GREEN_FRAGMENTS = (
    "durably confirm pull-request state and check conclusion with"
    " `gh pr view --json state,mergedAt,headRefOid` and an unconditional re-read"
    " of every check",
    "Run `gh pr checks <PR> --json bucket,name,state,link,workflow`",
    "`pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1"
    " -ChecksJson <checks-json> -HeadSha <headRefOid>`",
    "Record `merge_status: ci_green` only when that parser conclusion is `success`",
    "every check on its head SHA passed or was skipped",
)
MERGE_ON_GREEN_SUPERSEDED = (
    "when the check conclusion must be re-read",
    "its checks are green",
)
CODEX_GATE_FRAGMENTS = (
    "every GitHub check on that head SHA through `gh`",
    "`gh pr view --json headRefOid,baseRefName`",
    "Invoke `gh pr checks --json bucket,name,state,link,workflow`",
    "`pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1"
    " -ChecksJson <checks-json> -HeadSha <head-sha>`",
    "appending `-RequireWorkflow CI` when the PR base branch is an"
    " `epic/<slug>-integration` branch",
    "Every check returned by the unfiltered query counts",
    "a failing or cancelled non-`CI` check fails the gate",
    "at least one passing `CI` check",
    "fails with a `no checks reported` error, that error is never treated as"
    " green for any PR",
    "`-ChecksJson '[]'` and `-RequireWorkflow CI`",
)
CODEX_PARSER_ABSENT_FRAGMENTS = (
    "Parser-absent rule:",
    "`.claude/lib/ci-gate/Invoke-CiGateParser.ps1` does not exist in the repository",
    "the orchestrator does not derive `success` by hand",
    "stop and persist blocked state",
)
REQUIRED_ONLY_PHRASES = (
    "required ci check",
    "required github check",
    "failed required check",
    "required checks pass",
    "required checks were observed",
    "required checks on a non-epic pr",
)


def _with_mirror(bundle: Path, source: Path) -> tuple[Path, Path]:
    """Return a source path paired with its mirror path inside a bundle."""

    return source, bundle / source


def _posix_id(path: Path) -> str:
    """Return the POSIX form of a path for a readable parametrize id."""

    return path.as_posix()


CLAUDE_ORCHESTRATE_COPIES = _with_mirror(CLAUDE_BUNDLE, CLAUDE_ORCHESTRATE)
PARALLEL_ORCHESTRATE_COPIES = _with_mirror(CLAUDE_BUNDLE, PARALLEL_ORCHESTRATE)
CODEX_ORCHESTRATE_COPIES = _with_mirror(CODEX_BUNDLE, CODEX_ORCHESTRATE)
POPULATION_SURFACES: tuple[Path, ...] = (
    *CLAUDE_ORCHESTRATE_COPIES,
    *_with_mirror(CLAUDE_BUNDLE, CLAUDE_ORCHESTRATOR_AGENT),
    *_with_mirror(CLAUDE_BUNDLE, REMEDIATION_SKILL),
    *CODEX_ORCHESTRATE_COPIES,
    *_with_mirror(CODEX_BUNDLE, CODEX_ORCHESTRATOR_WORKFLOW),
    *(
        path
        for agent in CODEX_ORCHESTRATOR_AGENTS
        for path in _with_mirror(CODEX_BUNDLE, agent)
    ),
)


def section_text(relative_path: Path, heading: str) -> str:
    """Return the whitespace-collapsed body of one ``##`` section of a file."""

    return collapse_whitespace(extract_section(read_repo_text(relative_path), heading))


def missing_fragments(text: str, fragments: tuple[str, ...]) -> list[str]:
    """Return the fragments absent from collapsed ``text``, in declared order."""

    return [item for item in fragments if collapse_whitespace(item) not in text]


def required_only_phrases(text: str) -> list[str]:
    """Return the required-only population phrases present in ``text``.

    The comparison is case-insensitive and runs over whitespace-collapsed text,
    so a phrase split across a line wrap is still reported.
    """

    folded = collapse_whitespace(text).lower()
    return [phrase for phrase in REQUIRED_ONLY_PHRASES if phrase in folded]


@pytest.mark.parametrize("relative_path", CLAUDE_ORCHESTRATE_COPIES, ids=_posix_id)
def test_s9_queries_every_check_without_required_flag(relative_path: Path) -> None:
    """S9 queries every check on the PR head and carries no --required flag."""
    # Arrange
    s9_text = section_text(relative_path, S9_HEADING)

    # Act
    missing = missing_fragments(s9_text, S9_ALL_CHECKS_FRAGMENTS)
    carries_required_flag = REQUIRED_FLAG in s9_text

    # Assert
    assert not carries_required_flag, f"{relative_path.as_posix()} S9 has --required"
    assert missing == [], f"{relative_path.as_posix()} S9 is missing: {missing}"


@pytest.mark.parametrize("relative_path", CLAUDE_ORCHESTRATE_COPIES, ids=_posix_id)
def test_s9_states_no_checks_error_is_never_green(relative_path: Path) -> None:
    """S9 states that a no-checks-reported error is never green for any PR."""
    # Arrange
    s9_text = section_text(relative_path, S9_HEADING)

    # Act
    missing = missing_fragments(s9_text, S9_NO_CHECKS_FRAGMENTS)

    # Assert
    assert missing == [], f"{relative_path.as_posix()} S9 is missing: {missing}"


@pytest.mark.parametrize("relative_path", PARALLEL_ORCHESTRATE_COPIES, ids=_posix_id)
def test_merge_on_green_always_rereads_every_check(relative_path: Path) -> None:
    """The parent re-reads every check through the parser before ci_green."""
    # Arrange
    merge_text = section_text(relative_path, MERGE_ON_GREEN_HEADING)

    # Act
    missing = missing_fragments(merge_text, MERGE_ON_GREEN_FRAGMENTS)
    superseded = [item for item in MERGE_ON_GREEN_SUPERSEDED if item in merge_text]

    # Assert
    assert missing == [], f"{relative_path.as_posix()} merge step is missing: {missing}"
    assert superseded == [], f"{relative_path.as_posix()} still carries: {superseded}"


@pytest.mark.parametrize("relative_path", CODEX_ORCHESTRATE_COPIES, ids=_posix_id)
def test_codex_ci_green_gate_invokes_parser_with_epic_child_guard(
    relative_path: Path,
) -> None:
    """The Codex gate queries every check and parses it with the epic guard."""
    # Arrange
    gate_text = section_text(relative_path, CODEX_GATE_HEADING)

    # Act
    missing = missing_fragments(gate_text, CODEX_GATE_FRAGMENTS)
    carries_required_flag = REQUIRED_FLAG in gate_text

    # Assert
    assert not carries_required_flag, f"{relative_path.as_posix()} gate has --required"
    assert missing == [], f"{relative_path.as_posix()} gate is missing: {missing}"


@pytest.mark.parametrize("relative_path", CODEX_ORCHESTRATE_COPIES, ids=_posix_id)
def test_codex_ci_green_gate_fails_closed_without_parser(relative_path: Path) -> None:
    """The Codex gate persists blocked state when the parser file is absent."""
    # Arrange
    gate_text = section_text(relative_path, CODEX_GATE_HEADING)

    # Act
    missing = missing_fragments(gate_text, CODEX_PARSER_ABSENT_FRAGMENTS)

    # Assert
    assert missing == [], f"{relative_path.as_posix()} gate is missing: {missing}"


@pytest.mark.parametrize("relative_path", POPULATION_SURFACES, ids=_posix_id)
def test_surface_restates_no_required_only_population(relative_path: Path) -> None:
    """No orchestrator surface in scope restates a required-only population."""
    # Arrange
    text = read_repo_text(relative_path)

    # Act
    found = required_only_phrases(text)

    # Assert
    assert found == [], f"{relative_path.as_posix()} restates: {found}"


def test_required_only_phrases_reports_wrapped_superseded_wording() -> None:
    """The detector reports a required-only phrase split across a line wrap."""
    # Arrange
    text = "A failed required\ncheck is not handled outside the loop."

    # Act
    found = required_only_phrases(text)

    # Assert
    assert found == ["failed required check"]


def test_required_only_phrases_accepts_all_checks_wording() -> None:
    """The detector accepts all-checks wording and the unrelated required keys."""
    # Arrange
    text = (
        "Every GitHub check on the current PR head SHA passed or was skipped;"
        " the object has the required keys `conclusion` and `head_sha`."
    )

    # Act
    found = required_only_phrases(text)

    # Assert
    assert found == []
```

## Appendix B — Pester block for `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`

Inserted after the closing `}` of the last existing `Context` and before the closing `}` of the `Describe`, preceded by one blank line. Indentation matches the existing file (four spaces per level).

```powershell
    Context "default NowProvider delegates" {
        It "uses the Invoke-CiGateParser default NowProvider when none is injected" {
            # Arrange: replace Get-Date with a fixed UTC instant so the default
            # delegate never reads the wall clock.
            Mock -CommandName Get-Date -MockWith { [datetime]::new(2026, 6, 24, 17, 0, 0, [System.DateTimeKind]::Utc) }

            # Act: call the function without -NowProvider so its param-block default runs.
            $result = Invoke-CiGateParser -ChecksJson '[]' -HeadSha 'sha1'

            # Assert: each '?' matches the culture time separator, so the result
            # does not depend on the host culture; the digits come from the mock.
            $result.verified_at | Should -BeLike '2026-06-24T17?00?00Z'
            Should -Invoke -CommandName Get-Date -Times 1 -Exactly
        }

        It "uses the script-level default NowProvider when the script runs without -NowProvider" {
            # Arrange: the same fixed UTC instant for the script-level default delegate.
            Mock -CommandName Get-Date -MockWith { [datetime]::new(2026, 6, 24, 17, 0, 0, [System.DateTimeKind]::Utc) }

            # Act: run the script file without -NowProvider so the process block
            # forwards the script-level default delegate to Invoke-CiGateParser.
            $result = & $script:scriptPath -ChecksJson '[]' -HeadSha 'x'

            # Assert
            $result.verified_at | Should -BeLike '2026-06-24T17?00?00Z'
            Should -Invoke -CommandName Get-Date -Times 1 -Exactly
        }
    }
```

## Appendix C — Exact Replacement Texts

Each block below is the complete replacement for the cited span. Inline-code spans that contain a full `pwsh -NoProfile -File` command stay on one physical line.

### C.1 `.claude/skills/orchestrate/SKILL.md` (S9) and its Claude bundle mirror

(a) Line 292, step 2, becomes:

```text
2. Invoke `gh pr checks --json bucket,name,state,link,workflow` (or an equivalent JSON-emitting command) against that head SHA. The query covers every check on the head SHA for every PR, whether or not branch protection marks the check as required. `gh` is the only sanctioned channel for querying GitHub Actions state.
```

(b) New paragraph inserted after step 2 and before the epic-child paragraph (three-space indent, one blank line before and after):

```text
   No-checks rule: when `gh pr checks` fails with a `no checks reported` error, that error is never treated as green for any PR. On a non-epic PR the gate stays `pending` and step 4 continues the bounded poll. On an epic child, step 3 runs the parser with `-ChecksJson '[]'` and `-RequireWorkflow CI`, which returns `pending`. The parser is never run with `-ChecksJson '[]'` without `-RequireWorkflow CI`, because its default path returns `success` for an empty set.
```

(c) Line 294, epic-child paragraph, becomes:

```text
   Epic-child rule: when the PR base branch is an `epic/<slug>-integration` branch (checkpoint `epic_mode` is `true`), the step 2 query is the same unfiltered query; integration branches carry no required-status-check protection. An empty check list is not accepted as green for such a PR: the gate must observe at least one check whose `workflow` is `CI` against the child head SHA, and every observed `CI` check must succeed before `ci_gate.conclusion` is accepted as `success`. Every check returned by the unfiltered query counts: a failing or cancelled non-`CI` check fails the gate, and a pending one keeps it pending. Step 3 enforces this rule by passing `-RequireWorkflow CI` to the parser, which never returns `success` until at least one passing `CI` check is observed. When `gh pr checks` fails with a `no checks reported` error on the child branch, step 3 runs the parser with `-ChecksJson '[]'`; that error is never treated as green, and the parser returns `pending` for it.
```

(d) Line 296, step 3: only the parenthetical changes, from `(the required checks on a non-epic PR; every observed check on an epic child)` to `(every check on the PR head SHA, for every PR)`.

(e) Line 345: `(a failed required check; a poll timeout follows the wait branch per S9 step 4)` becomes `(a failed check; a poll timeout follows the wait branch per S9 step 4)`.

### C.2 `.claude/skills/parallel-orchestrate/SKILL.md` (Merge-on-Green) and its Claude bundle mirror

(a) Lines 373-376, step 1, become:

```text
1. The item's child orchestration runs unmodified, with `epic_mode` `false` or absent, and finishes
   at its own DONE. The child's PR Creation Gate condition 6 already requires
   `ci_gate.conclusion == "success"`, so at child DONE the item's pull request is open against
   `main` and every check on its head SHA passed or was skipped. The child is never instructed to
   merge its own pull request.
```

(b) Lines 377-380, the first sentence of step 2, become (lines 381-385 follow unchanged):

```text
2. On child completion, durably confirm pull-request state and check conclusion with
   `gh pr view --json state,mergedAt,headRefOid` and an unconditional re-read of every check on
   that head, never from an in-memory completion notification or from the child's DONE report
   alone. Run `gh pr checks <PR> --json bucket,name,state,link,workflow` and parse its output with
   `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -ChecksJson <checks-json> -HeadSha <headRefOid>`.
   Record `merge_status: ci_green` only when that parser conclusion is `success`; on `failure` or
   `pending`, or when `gh pr checks` fails with a `no checks reported` error, do not record
   `merge_status: ci_green` and do not run `gh pr merge`.
```

### C.3 `.agents/skills/orchestrate/SKILL.md` (`## CI Green Gate`) and its Codex bundle mirror

(a) Line 425: `a failed required check stays` becomes `a failed check stays`.

(b) Lines 455-458 become:

```text
Before PR/DONE completion, the orchestrator must observe the live PR head SHA
and every GitHub check on that head SHA through `gh`. The checkpoint must record
the checked head SHA and CI result. DONE is blocked unless every check on the
current PR head SHA passed or was skipped.

Gate procedure:

1. Resolve the live PR head SHA and the PR base branch with `gh pr view --json headRefOid,baseRefName`.
2. Invoke `gh pr checks --json bucket,name,state,link,workflow` against that head SHA. The query covers every check on the head SHA for every PR, whether or not branch protection marks the check as required.
3. Parse the JSON by running `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -ChecksJson <checks-json> -HeadSha <head-sha>`, appending `-RequireWorkflow CI` when the PR base branch is an `epic/<slug>-integration` branch. The parser derives `ci_gate.conclusion` over every queried check: `success` when every check passed or was skipped, `failure` when any check failed or was cancelled, and `pending` when any check is still in progress.
4. Epic-child rule: when the PR base branch is an `epic/<slug>-integration` branch, an empty check list is not accepted as green. Every check returned by the unfiltered query counts: a failing or cancelled non-`CI` check fails the gate, and a pending one keeps it pending. With `-RequireWorkflow CI`, the parser never returns `success` until at least one passing `CI` check is observed.
5. No-checks rule: when `gh pr checks` fails with a `no checks reported` error, that error is never treated as green for any PR. On an epic child, the parser runs with `-ChecksJson '[]'` and `-RequireWorkflow CI`, which returns `pending`; on any other PR the gate stays `pending` within the bounded poll.
6. Parser-absent rule: when `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` does not exist in the repository, the orchestrator does not derive `success` by hand; it must stop and persist blocked state before PR/DONE completion.
```

(c) Line 460: `the PR head SHA the required checks were observed against` becomes `the PR head SHA the queried checks were observed against`. The phrase `with the required keys` on the same line is unchanged.

(d) Line 476 becomes:

```text
5. Every check on the current PR head SHA passed or was skipped (`ci_gate.conclusion` is `success`).
```

### C.4 `.claude/agents/orchestrator.md` line 133 and its Claude bundle mirror

The line begins: `After the PR is opened, the orchestrator monitors every CI check on the live PR head SHA. A failed check is not handled outside the loop:` and continues unchanged from `it transitions into`.

### C.5 `.codex/agents/orchestrator.toml` (canonical; variants are generated)

(a) Line 191 becomes `8. Every GitHub check on the current PR head SHA passed or was skipped before any PR/DONE transition.`

(b) Line 193 begins `The MCP validator and every CI check on the current PR head SHA are the hard completion boundary.` and continues unchanged from `There is no fallback.`

### C.6 `.agents/skills/orchestrator-workflow/SKILL.md` line 439 and its Codex bundle mirror

The line becomes `- every GitHub check on the current PR head SHA passed or was skipped before PR/DONE completion`.

### C.7 `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` and its Claude bundle mirror (help and comments only)

(a) Line 8: `` `gh pr checks --json bucket,name,state,link,workflow` and produces ``. Line 41: `` The JSON array string emitted by `gh pr checks --json ...`. Each ``. Line 46: `The PR head SHA the queried checks were observed against. Recorded verbatim`. Line 75: `gh pr checks --json bucket,name,state,link,workflow |`.

(b) Line 20: `- Any check with bucket 'fail' or 'cancel'  -> conclusion 'failure'`. Line 21: `- Else any check with bucket 'pending'       -> conclusion 'pending'`. Line 23: `An empty check set is treated as 'success' (vacuously satisfied: no`. Line 24: `check can fail or be in progress). An unrecognized bucket value is a`. Each line keeps its existing leading indentation.

(c) Line 121: `Pure derivation of ci_gate.conclusion from a parsed check set.` Line 191: `# Inspect each check once, classifying by its bucket value. Failure`. Line 206 trailing comment: `# a failed check is terminal-non-success`. Line 207 trailing comment: `# a cancelled check is treated conservatively as failure`. Each line keeps its existing leading indentation and code.
