# 2026-10-08-ci-gate-vacuous-on-empty-check-list (Plan)

- **Issue:** #841 (the pull request also closes #795)
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T22-17
- **Status:** Draft (revision 1.2; executor preflight round 2 delta D1 and the P6-T1 consistency fix applied; pending executor preflight round 3)
- **Version:** 1.2
- **Work Mode:** full-bug (`spec.md` is the only acceptance-criteria source, AC-1 through AC-22; no `user-story.md`)
- **Branch:** `bug/ci-gate-vacuous-on-empty-check-list-841`
- **Spec:** `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`
- **Research:** `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/research/research.2026-10-09T02-25.md`

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path in each evidence-producing task. Do not mark evidence-backed work complete without the artifact.

## Scope Recap

1. CR-1: add an opt-in `-RequireWorkflow <name>` parameter to `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` (script level, `Invoke-CiGateParser`, `Get-CiGateConclusion`). With the parameter empty, behavior is unchanged. With it set, failure outranks pending outranks a presence condition: the conclusion is `success` only when at least one observed check whose `workflow` equals the name (case-sensitive) has bucket `pass`; otherwise `pending`. A whitespace-only value throws.
2. CR-1 wiring and CR-4: S9 text in `.claude/skills/orchestrate/SKILL.md` (step 2 epic-child paragraph, step 3, `head_sha` schema bullet) and its Claude bundle mirror.
3. PA-N9: the satisfiable qualifying-run definition in `.claude/skills/feature-review-workflow/SKILL.md` and its Claude bundle mirror.
4. #795: a `## Policy Rules` section with `### modified-workflow-needs-green-run` in `.agents/skills/feature-review-workflow/SKILL.md` and its Codex bundle mirror.
5. Tests: extend the parser Pester suite; add the pytest text-contract and citation-resolution suite.

Out of scope (spec, Scope & Non-Goals): the default empty-set mapping; a general cited-rule scanner; Codex CR-1 parity in `.agents/skills/orchestrate/SKILL.md`; wording in `.claude/agents/orchestrator.md`, `.claude/rules/**`, `.github/workflows/**`, and the optional "failed required check" phrase at `.claude/skills/orchestrate/SKILL.md:342`.

## Files Written

Every repository file this plan writes is listed here and is named, in its own inline-code span, in a task whose title begins with a write verb.

Production, tests, and bundled mirrors (10):

- `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` (P2-T1 through P2-T5)
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1` (P2-T9, byte copy)
- `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` (P1-T1, P1-T2)
- `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` (P1-T3, new)
- `.claude/skills/orchestrate/SKILL.md` (P3-T2 through P3-T4)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` (P3-T5, byte copy)
- `.claude/skills/feature-review-workflow/SKILL.md` (P4-T2)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md` (P4-T3, byte copy)
- `.agents/skills/feature-review-workflow/SKILL.md` (P5-T2)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md` (P5-T3, byte copy)

Feature documents (2):

- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` (AC check-off tasks)
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/plan.2026-10-08T22-17.md` (P6-T24, P6-T25; checklist state throughout)

Committed by the preparation run, not written by this plan (1):

- `docs/features/potential/promoted/2026-10-08-ci-gate-vacuous-on-empty-check-list.md` is committed by the orchestrator's preparation commit (together with the feature folder and this plan) before execution starts. No task in this plan writes or stages it; it appears in the branch diff against `origin/main` and is accepted by P6-T15 and P6-T25.

Evidence (46), all under `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/`:

- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/phase0-instructions-read.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/branch-state.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/mirror-hashes.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/line-counts.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/powershell-format.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/powershell-analyze.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/pester-ci-gate-coverage.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/pester-claude-runtime.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/python-contract-suites.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/python-coverage.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/python-black.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/python-ruff.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/python-pyright.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/pre-change-state.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/other/scratch-smoke.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/other/pre-edit-orchestrate.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/other/pre-edit-claude-review.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/other/pre-edit-agents-review.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/regression-testing/pester-before-fix.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/regression-testing/pytest-before-fix.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/regression-testing/pester-after-parser-fix.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/regression-testing/parser-mirror-contracts.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/regression-testing/orchestrate-contracts.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/regression-testing/orchestrate-suites.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/regression-testing/claude-runtime-after-orchestrate.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/regression-testing/claude-review-contracts.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/regression-testing/claude-review-suites.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/regression-testing/agents-review-contracts.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/regression-testing/agents-review-suites.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/format-parser-phase2.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/analyze-parser-phase2.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-powershell-format.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-powershell-analyze.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-pester-coverage.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-python-black.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-python-ruff.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-python-pyright.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-python-pytest.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-python-coverage.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-contract-suites.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-claude-runtime-pester.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-mirror-hashes.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/line-counts.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/coverage-comparison.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/unchanged-files.2026-10-08T22-17.md`
- `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/ac-verification.2026-10-08T22-17.md`

Evidence filenames carry the plan-time timestamp `2026-10-08T22-17` so every name is fixed before execution; each artifact's `Timestamp:` field records the actual execution time. A QA-loop restart overwrites the same artifact and records the iteration number.

Verified as needing no change (re-derived against the tree in this pass):

- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` already lists `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` (line 165) and `.claude/skills/feature-review-workflow/SKILL.md` (line 104).
- The Codex core manifest does not list `.agents/skills/feature-review-workflow/SKILL.md`; that path is a registered pre-existing exception at `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py:105`, which this item does not change.
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:154-163` pins SHA-256 digests of `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md` only; neither file is written, so no re-baseline is needed.
- No TypeScript source or test under `extensions/drm-copilot/src` or `extensions/drm-copilot/test` names the parser or either skill (Grep), so no TypeScript twin changes.
- The new pytest file sits beside the other repository text-contract suites in `tests/scripts/dev_tools/` (for example `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`), which is the repository convention for contract tests that have no production module.
- Non-repository side effects: Pester coverage XML and reports go to SCRATCH; `poetry run pytest` writes `artifacts/python/lcov.info` through the project `addopts` value (`pyproject.toml:116`); the `mcp__drm-copilot__run_poshqc_test` call in P6-T3 writes `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`; `/artifacts` is gitignored (`.gitignore:6`), so none of these files is tracked or staged.

## Files That Must Not Change

`.claude/skills/epic-orchestrate/SKILL.md` and its Claude bundle mirror (SHA-256 pinned), `.agents/skills/orchestrate/SKILL.md` and its Codex bundle mirror, `.github/workflows/**`, `.claude/rules/**` and its Claude bundle mirror, `.github/instructions/**`, `.claude/agents/orchestrator.md`, `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, `.github/skills/feature-review-workflow/SKILL.md` and its Copilot bundle mirror, and `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`. P6-T15 proves this against `origin/main` (AC-13).

## Current-Tree Facts This Plan Relies On (re-derived 2026-10-08 by reading the files)

- `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`: help `.DESCRIPTION` lines 6-30 (vacuous rule at 19-26); `.PARAMETER NowProvider` lines 49-52; `.EXAMPLE` lines 59-61; script `param` lines 69-89 (`$NowProvider` line 85, `$AsJson` line 88); `Get-CiGateConclusion` lines 96-175 (help 97-121, `param` 124-128, empty-set return 130-134, switch 154-165 with the `'pass'` case on line 158, trailing logic 168-174); `Invoke-CiGateParser` help `.PARAMETER NowProvider`/`.PARAMETER AsJson` lines 242-245, `param` 254-274, conclusion call line 291; `process` block lines 319-329. The `workflow` property is never read.
- `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` has 15 `It` blocks; it dot-sources the script at line 12; the helper `script:ConvertChecksToJson` is lines 21-25; the empty-array test is lines 91-98; the last `Context "Get-CiGateConclusion pure helper"` is lines 200-204 and line 205 closes the `Describe`.
- `tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1` has 2 `It` blocks. The folder `tests/scripts/claude-lib/ci-gate` therefore holds 17 tests before this item and 35 after it.
- `.claude/skills/orchestrate/SKILL.md`: `## Step S9 — CI Green Gate` line 282; epic-child paragraph line 291 (ends "before `ci_gate.conclusion` is accepted as `success`."); step 3 line 293; CI-dependent AC paragraph line 298 (pinned by `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py:222-238`, not edited); `## Checkpoint Schema — CI Gate Fields` line 302; `head_sha` bullet line 307. The Claude bundle mirror carries the same lines 291, 293, 307 (Grep).
- `.claude/skills/feature-review-workflow/SKILL.md`: `## Policy Rules` line 66, `### modified-workflow-needs-green-run` line 68, SHA-exact definition line 73, `workflow_dispatch` bullet line 74, `awaiting_ci` bullet line 75, `## Ordered Procedure` line 77. The Claude bundle mirror line 73 matches.
- `.agents/skills/feature-review-workflow/SKILL.md`: headings `### Work-mode acceptance-criteria contract` line 51, `## Ordered Procedure` line 66; no `## Policy Rules` heading.
- `.agents/skills/ci-workflows/SKILL.md:40` and `.agents/skills/benchmark-baselines/SKILL.md:39` (and their Codex bundle mirrors at the same lines) cite the rule as "`modified-workflow-needs-green-run` (see `.agents/skills/feature-review-workflow/SKILL.md`)".
- `scripts/dev_tools/skill_bundle_contract.py:53-54` resolves a `pwsh ... -File <path>` reference only when it is on one line; `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py:46-66` asserts both orchestration skills reference `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`.
- Parity: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110` requires every distributable `.claude` file to equal its bundle copy (local-only `.claude/agent-memory/**`, `.claude/state/**`, `.claude/worktrees/**` excluded); `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:215-228` does the same for `.agents`/`.codex`.
- `pyproject.toml`: black and ruff line length 88 (lines 84-91); ruff selects `E,F,I,B,UP,S,TID,TCH` with `S101` ignored under `tests/**` (lines 93-106); pytest `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"` (line 116); pyright strict over `scripts`, `src`, `tests` (lines 142-152).
- Concurrency: neither the #798 nor the #824 feature folder is present on this branch (Glob), so their line ranges were not verified. Pre-edit tasks P3-T1, P4-T1, and P5-T1 re-read the current text before each edit.

## Plan Decisions

- **PD1 — Tests first.** Phase 1 adds 18 Pester `It` blocks and a 26-node pytest suite that fail against the unfixed tree; Phases 2 through 5 turn them green in stages with exact pass/fail counts per stage.
- **PD2 — Mirrors by byte copy.** Every bundle mirror is produced by `cp` from its formatted source, never by Write or Edit, and verified by scratch script A4.
- **PD3 — Format before mirror.** The parser and its tests are formatted and analyzed in Phase 2 before the mirror copy, so the final format step is expected to change nothing.
- **PD4 — Anchored minimal hunks.** Every skill edit is an Edit-tool replacement of a short anchor quoted in Appendix E or F, so concurrent edits elsewhere in the same file by #798 or #824 do not collide textually.
- **PD5 — Coverage numbers come from scratch scripts, never from MCP results.** The PoshQC MCP tools return a fixed summary with no per-test output; every PowerShell count, percentage, and diagnostic is read from scripts A2, A3, A5, A6, and A8. MCP calls are recorded only by disposition (returned or raised).
- **PD6 — Python coverage.** No Python production file changes. The Python coverage tasks (P0-T15, P6-T8) measure `scripts.dev_tools.skill_bundle_contract`, the production module exercised by the AC-12 suite, as a no-regression guard; the new pytest file is test code and is excluded from measurement by `pyproject.toml` `[tool.coverage.run] omit`.

## Execution Conventions

### Terms

- SCRATCH means the executor's session scratchpad directory, outside the repository and never committed. Artifacts record it as the literal token SCRATCH, never as a host path. In every command the executor substitutes SCRATCH with the scratchpad path written with forward slashes (for example `C:/Users/<user>/AppData/Local/Temp/.../scratchpad`), because `sh` removes unquoted backslashes from its arguments. The route `sh SCRATCH/run-ps.sh SCRATCH/<script>.ps1 <args>` with that forward-slash form was verified runnable in executor preflight round 1.
- BASE_SHA means the 40-character merge-base commit recorded by P0-T7.
- Every command-step evidence artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. An artifact whose expected exit code is not 0 also carries `ExpectedExitCode:`. PowerShell test artifacts that measure coverage record numeric `LinePercent=` values in `Output Summary:`; Python coverage artifacts record the numeric `Cover` value.

### Shell route

- The worktree isolation hook refuses Bash-tool command text containing the words bash, pwsh, or wsl, heredocs, and compound commands. Every git, poetry, and cp command in this plan is one plain command with literal arguments.
- PowerShell scratch scripts run as `sh SCRATCH/run-ps.sh SCRATCH/<script>.ps1 <args>` (script A1 calls the PowerShell executable with `-NoProfile -NonInteractive -File`). If the executor session exposes a PowerShell tool, it may run `& SCRATCH/<script>.ps1 <args>` there instead; the artifact records which route ran. Output lines are identical on both routes.
- Python commands run as `poetry run <tool> ...`.
- `git grep` searches tracked files only. Every file a `git grep` in this plan targets is tracked when the search runs. The new pytest file is checked with scratch script A7 until P1-T6 commits it.
- **Stop rule for hook denials.** If any hook denies a Write, Edit, staging, or command in this plan, stop and report the verbatim denial text. Do not bypass the hook by another route.

### Observed success outputs that acceptance conditions rely on

- Scripts A2 through A8 print their result lines by construction (Appendix A): A2 prints `TotalCount=`, `PassedCount=`, `FailedCount=`, and one `FAILED:` line per failed test, and exits 0 whether or not tests fail; A3 additionally prints `COVERAGE file=... LinePercent=` plus `HIT` and `MISSED` lines; A4 prints `PAIR-SUMMARY pairs=<n> unequal=<n>`; A5 prints `PSSA-SUMMARY DiagnosticCount=`; A6 prints `FORMAT-SUMMARY ChangedCount=`; A7 prints `<path> LineCount=<n>`; A8 prints `CHANGED-LINES ... ChangedLinePercent=`. The same A2, A3, A5, A6, and A7 bodies produced these lines in recorded runs under `docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773/evidence/`.
- `pytest -v` prints one PASSED or FAILED line per node and a final summary line such as `26 passed` or `20 failed, 6 passed`.
- The success-case lines of black, ruff, and pyright are observed on a clean sibling file in P0-T16 through P0-T18 before P6-T4 through P6-T6 assert them. The expected lines are "1 file would be left unchanged." (black `--check`), "All checks passed!" (ruff), and a summary beginning "0 errors" (pyright). If a baseline task records a different success line, the final task asserts the line the baseline recorded.
- `git grep -c` prints one `path:count` line per file with a match and exits 1 with no output when nothing matches.

### Toolchain loop rule

Phase 6 tasks P6-T1 through P6-T13 form the final QA loop: PowerShell format, analyze, test with coverage; Python black, ruff, pyright, pytest, coverage; then the regression, parity, size, and comparison checks. Type checking does not apply to PowerShell (`.claude/rules/powershell.md`). If any of P6-T1 through P6-T13 fails or changes a tracked file, fix the cause; if the parser changed, re-run the P2-T9 copy command; then restart at P6-T1. Each restart overwrites the Phase 6 artifacts and records the iteration number.

### Commit rule

Each implementation phase ends with a commit-and-push task. Staging uses explicit pathspecs only (`git add -- <paths>`); `git add -A`, `git add .`, and any force push are not used. Commits carry the attribution trailer lines the executor's session requires, supplied as an additional `-m` argument after the subject, for example `git commit -m "<subject>" -m "Co-Authored-By: <trailer value>"`; every `git commit -m "<subject>"` command in this plan is run in that form. The heredoc form and the `-F -` form are refused by the worktree isolation guard and are not used. The push command is `git push -u origin bug/ci-gate-vacuous-on-empty-check-list-841`.

### Search literal register

Searches in this plan use these fixed strings, quoted here so each is an explicit instruction: "check must succeed before", "when all required checks pass", "that the required checks were observed against", "whose head SHA matches the current branch head", "### modified-workflow-needs-green-run", "RequireWorkflow", "array without -RequireWorkflow (vacuous satisfaction)", "required-check array (vacuous satisfaction)", "(epic-child guard)", "Epic-child guard (-RequireWorkflow)", ".PARAMETER RequireWorkflow", "[string]$RequireWorkflow =", "whitespace-only value is not accepted", "$requiredWorkflowPassed = $true", "-RequireWorkflow $RequireWorkflow", "Every check returned by the unfiltered query counts", "is never treated as green", "over the queried checks", "that the queried checks were observed against", "cannot name the SHA of the commit that contains it", "git merge-base --is-ancestor", "## Ordered Procedure", "## Policy Rules", "CI Green Gate (S9)", and the per-criterion check-off markers "- [x] AC-1:" through "- [x] AC-22:".

---

### Phase 0 — Policy Reads, Scratch Scripts, and Baselines

- [x] [P0-T1] Read `CLAUDE.md` and then `.github/copilot-instructions.md` in full (policy read, order item 1). Acceptance: both read; recorded in P0-T5.
- [x] [P0-T2] Read, in order, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, and `.claude/rules/quality-tiers.md` (policy read, order items 2-3). Acceptance: all three read; recorded in P0-T5.
- [x] [P0-T3] Read, in order, `.claude/rules/powershell.md`, `.claude/rules/python.md`, and `.claude/rules/python-suppressions.md` (language policy read, order item 4). Acceptance: all three read; recorded in P0-T5.
- [x] [P0-T4] Read `.claude/rules/tonality.md` and `.claude/rules/plan-acceptance-gates.md` (policy read). Acceptance: both read; recorded in P0-T5.
- [x] [P0-T5] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/phase0-instructions-read.2026-10-08T22-17.md` (policy-read record). Acceptance: the artifact contains `Timestamp:`, `Policy Order:`, and the explicit list of the ten files read in P0-T1 through P0-T4 in reading order.
- [x] [P0-T6] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/other/scratch-smoke.2026-10-08T22-17.md` after creating the eight scratch scripts of Appendix A (A1 through A8) verbatim under SCRATCH (outside the repository) and running `sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 CLAUDE.md`. Acceptance: exit 0 and one output line beginning `CLAUDE.md LineCount=`; the artifact lists the eight script file names.
- [x] [P0-T7] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/branch-state.2026-10-08T22-17.md` (baseline branch state). Commands, each recorded: `git rev-parse --abbrev-ref HEAD`, `git fetch origin main`, `git rev-parse HEAD`, `git merge-base HEAD origin/main`, `git status --porcelain`, `git ls-files -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841`. Acceptance: the branch is `bug/ci-gate-vacuous-on-empty-check-list-841`; the merge base is recorded as BASE_SHA (40 hexadecimal characters); the `git status --porcelain` output is either empty (the expected state, because the preparation commit includes the feature folder, this plan, and the promoted record) or consists only of lines naming paths under `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/`; a line naming any other path stops the plan; the `git ls-files` output is recorded as FEATURE_TRACKED (list of tracked feature files, possibly empty).
- [x] [P0-T8] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/mirror-hashes.2026-10-08T22-17.md` (baseline mirror parity). Command: `sh SCRATCH/run-ps.sh SCRATCH/pair-hashes.ps1` with the eight paths of Appendix G1 in order. Acceptance: exit 0 and `PAIR-SUMMARY pairs=4 unequal=0`. An unequal pair stops the plan, because a later `cp` would discard a bundle-specific difference.
- [x] [P0-T9] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/line-counts.2026-10-08T22-17.md` (baseline line counts). Command: `sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 .claude/lib/ci-gate/Invoke-CiGateParser.ps1 tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 .claude/skills/orchestrate/SKILL.md .claude/skills/feature-review-workflow/SKILL.md .agents/skills/feature-review-workflow/SKILL.md`. Acceptance: exit 0 and five `LineCount=` lines; the parser and Pester values are recorded as PARSER_LINES_0 and PESTER_LINES_0, each at most 500.
- [x] [P0-T10] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/powershell-format.2026-10-08T22-17.md` (PowerShell format baseline, read-only). Command: `sh SCRATCH/run-ps.sh SCRATCH/ps-format-check.ps1 .claude/lib/ci-gate/Invoke-CiGateParser.ps1 tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1`. Acceptance: exit 0 and a `FORMAT-SUMMARY ChangedCount=` value recorded as PS_FMT_0.
- [x] [P0-T11] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/powershell-analyze.2026-10-08T22-17.md` (PSScriptAnalyzer baseline). Command: `sh SCRATCH/run-ps.sh SCRATCH/pssa-count.ps1 .claude/lib/ci-gate/Invoke-CiGateParser.ps1 tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`. Acceptance: exit 0 and a `PSSA-SUMMARY DiagnosticCount=` value recorded as PSSA_0, with every `PSSA` line verbatim.
- [x] [P0-T12] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/pester-ci-gate-coverage.2026-10-08T22-17.md` (Pester test and coverage baseline for `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`). Command: `sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/ci-gate -CoveragePath .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -CoverageOutputPath SCRATCH/cov-parser-base.xml -ReportPath SCRATCH/cov-parser-base.txt`. Acceptance: `TotalCount=17`, `FailedCount=0`, and a numeric `LinePercent=` for the parser recorded as PARSER_BASE_PCT in `Output Summary:`.
- [x] [P0-T13] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/pester-claude-runtime.2026-10-08T22-17.md` (Pester regression baseline for suites that read `.claude/skills/orchestrate/SKILL.md`). Command: `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-runtime`. Acceptance: exit 0; the artifact records `TotalCount=`, `PassedCount=`, `FailedCount=`, and every `FAILED:` line verbatim as the baseline failure set RUNTIME_FAIL_0 (possibly empty).
- [x] [P0-T14] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/python-contract-suites.2026-10-08T22-17.md` (Python contract-suite baseline). Command: the Appendix G2 command (`poetry run pytest -v` over the twelve suites listed there). Acceptance: the artifact records the summary line and every FAILED node ID verbatim as SUITES_FAIL_0. If SUITES_FAIL_0 names any node in `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`, `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`, `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`, `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py`, or `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`, stop and report, because AC-12, AC-13, AC-17, or AC-18 would be unverifiable.
- [x] [P0-T15] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/python-coverage.2026-10-08T22-17.md` (Python coverage baseline). Command: `poetry run pytest tests/scripts/dev_tools/test_skill_bundle_contract.py tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py --cov=scripts.dev_tools.skill_bundle_contract --cov-report=term-missing`. Acceptance: exit 0; the terminal table prints a row whose name ends with `skill_bundle_contract.py`; its numeric `Cover` value is recorded as PY_BASE_PCT.
- [x] [P0-T16] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/python-black.2026-10-08T22-17.md` (black baseline on a clean sibling contract test, observing the success-case output). Command: `poetry run black --check tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`. Acceptance: exit 0; the artifact records the success line verbatim (expected to contain "would be left unchanged") as BLACK_OK.
- [x] [P0-T17] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/python-ruff.2026-10-08T22-17.md` (ruff baseline on the same sibling). Command: `poetry run ruff check tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`. Acceptance: exit 0; the success line (expected "All checks passed!") is recorded verbatim as RUFF_OK.
- [x] [P0-T18] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/python-pyright.2026-10-08T22-17.md` (pyright baseline on the same sibling). Command: `poetry run pyright tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`. Acceptance: exit 0; the summary line (expected to begin "0 errors") is recorded verbatim as PYRIGHT_OK.
- [x] [P0-T19] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/pre-change-state.2026-10-08T22-17.md` (baseline reproduction of CR-1, CR-4, PA-N9, and #795). Commands, each recorded: `git grep -c -F -e 'when all required checks pass' -- .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`; `git grep -c -F -e 'that the required checks were observed against' -- .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`; `git grep -c -F -e 'whose head SHA matches the current branch head' -- .claude/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`; `git grep -c -F -e '### modified-workflow-needs-green-run' -- .agents/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md`; `git grep -c -F -e 'RequireWorkflow' -- .claude/lib/ci-gate/Invoke-CiGateParser.ps1`; `git ls-files -- tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`. Acceptance: the first three searches each print two lines ending `:1`; the fourth and fifth exit 1 with no output; `git ls-files` prints nothing, and a Glob for the new pytest path returns no file.

### Phase 1 — Regression Tests First

- [x] [P1-T1] Edit `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`: apply Appendix C1 (rename the line 91 test; its body and expectation stay unchanged). Acceptance: `git grep -c -F -e 'array without -RequireWorkflow (vacuous satisfaction)' -- tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` prints a count of 1, and `git grep -c -F -e 'required-check array (vacuous satisfaction)' -- tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` exits 1 with no output.
- [x] [P1-T2] Edit `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`: apply Appendix C2 (insert the `-RequireWorkflow parameter surface` and `-RequireWorkflow (epic-child guard)` contexts before the closing brace of the `Describe`). Acceptance: `git grep -c -F -e '(epic-child guard)' -- tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` prints a count of 1; `sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` prints a `LineCount=` value of at most 500.
- [x] [P1-T3] Create `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` with the exact content of Appendix D (one Write call). Acceptance: the Write succeeds without a hook denial, and `sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` prints a `LineCount=` value of at most 500.
- [x] [P1-T4] [expect-fail] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/regression-testing/pester-before-fix.2026-10-08T22-17.md` with `ExpectedExitCode: 0` (A2 reports test failures in its output, not its exit code). Command: `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`. Acceptance: exit 0, `TotalCount=33`, `PassedCount=15`, `FailedCount=18`, and every one of the 18 `FAILED:` lines contains the text "RequireWorkflow". Any other count stops the plan for a design review.
- [x] [P1-T5] [expect-fail] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/regression-testing/pytest-before-fix.2026-10-08T22-17.md` with `ExpectedExitCode: 1`. Command: `poetry run pytest -v tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`. Acceptance: exit 1; the summary line reports `20 failed, 6 passed`; the six PASSED nodes are the two `test_orchestrate_parser_command_stays_on_one_line` nodes, the two `test_review_rule_drops_sha_exact_definition` nodes whose IDs contain `.agents/skills/feature-review-workflow/SKILL.md`, `test_rule_resolution_reports_missing_heading`, and `test_rule_resolution_accepts_defined_heading`. Any other outcome stops the plan for a design review.
- [ ] [P1-T6] Commit and push Phase 1 (tests and feature documents). Commands: `git add -- tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841`, `git commit -m "test(841): add epic-child CI gate regression tests"`, `git push -u origin bug/ci-gate-vacuous-on-empty-check-list-841`. Acceptance: `git status --porcelain -- tests/scripts/claude-lib/ci-gate tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841` prints nothing and the push exits 0.

### Phase 2 — Parser Fix (CR-1)

- [ ] [P2-T1] Edit `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`: apply Appendix B1, B2, and B3 (script help: epic-child guard paragraph, `.PARAMETER RequireWorkflow`, epic-child `.EXAMPLE`). Acceptance: `git grep -c -F -e 'Epic-child guard (-RequireWorkflow)' -- .claude/lib/ci-gate/Invoke-CiGateParser.ps1` prints 1 and `git grep -c -F -e '.PARAMETER RequireWorkflow' -- .claude/lib/ci-gate/Invoke-CiGateParser.ps1` prints 1.
- [ ] [P2-T2] Edit `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`: apply Appendix B4 (script-level `[string]$RequireWorkflow = ''` between `$NowProvider` and `$AsJson`). Acceptance: `git grep -c -F -e '[string]$RequireWorkflow =' -- .claude/lib/ci-gate/Invoke-CiGateParser.ps1` prints 1.
- [ ] [P2-T3] Edit `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`: apply Appendix B5 through B8 (`Get-CiGateConclusion` help, parameter, whitespace rejection, guarded empty-set return, `'pass'` case, and trailing presence rule). Acceptance: `git grep -c -F -e '[string]$RequireWorkflow =' -- .claude/lib/ci-gate/Invoke-CiGateParser.ps1` prints 2; `git grep -c -F -e 'whitespace-only value is not accepted' -- .claude/lib/ci-gate/Invoke-CiGateParser.ps1` prints 1; `git grep -c -F -e '$requiredWorkflowPassed = $true' -- .claude/lib/ci-gate/Invoke-CiGateParser.ps1` prints 1; `git grep -c -F -e '.PARAMETER RequireWorkflow' -- .claude/lib/ci-gate/Invoke-CiGateParser.ps1` prints 2.
- [ ] [P2-T4] Edit `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`: apply Appendix B9 through B11 (`Invoke-CiGateParser` help, parameter, and forwarding to `Get-CiGateConclusion`). Acceptance: `git grep -c -F -e '[string]$RequireWorkflow =' -- .claude/lib/ci-gate/Invoke-CiGateParser.ps1` prints 3; `git grep -c -F -e '.PARAMETER RequireWorkflow' -- .claude/lib/ci-gate/Invoke-CiGateParser.ps1` prints 3; `git grep -c -F -e '-RequireWorkflow $RequireWorkflow' -- .claude/lib/ci-gate/Invoke-CiGateParser.ps1` prints 1.
- [ ] [P2-T5] Edit `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`: apply Appendix B12 (forward `-RequireWorkflow` from the `process` block). Acceptance: `git grep -c -F -e '-RequireWorkflow $RequireWorkflow' -- .claude/lib/ci-gate/Invoke-CiGateParser.ps1` prints 2.
- [ ] [P2-T6] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/format-parser-phase2.2026-10-08T22-17.md` after formatting the parser and its tests. Commands: `mcp__drm-copilot__run_poshqc_format` with `workspace_root` set to the worktree root and `scan_folders` set to `.claude/lib/ci-gate` and `tests/scripts/claude-lib/ci-gate`; then `git status --porcelain -- .claude/lib/ci-gate tests/scripts/claude-lib/ci-gate`; then `sh SCRATCH/run-ps.sh SCRATCH/ps-format-check.ps1 .claude/lib/ci-gate/Invoke-CiGateParser.ps1 tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`. Acceptance: the MCP call returns without raising; the status output names no path other than `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` and `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`; A6 prints `FORMAT-SUMMARY ChangedCount=0`.
- [ ] [P2-T7] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/analyze-parser-phase2.2026-10-08T22-17.md` after analyzing the parser and its tests. Commands: `mcp__drm-copilot__run_poshqc_analyze` with the P2-T6 arguments, then `sh SCRATCH/run-ps.sh SCRATCH/pssa-count.ps1 .claude/lib/ci-gate/Invoke-CiGateParser.ps1 tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`. Acceptance: the MCP call returns without raising and A5 prints `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P2-T8] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/regression-testing/pester-after-parser-fix.2026-10-08T22-17.md` (pass-after run of the Phase 1 Pester tests plus the manifest test). Command: `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/ci-gate`. Acceptance: `TotalCount=35`, `PassedCount=35`, `FailedCount=0`.
- [ ] [P2-T9] Update `extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1` by byte copy from `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`. Command: `cp .claude/lib/ci-gate/Invoke-CiGateParser.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1`. Acceptance: `sh SCRATCH/run-ps.sh SCRATCH/pair-hashes.ps1 .claude/lib/ci-gate/Invoke-CiGateParser.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1` prints `PAIR-SUMMARY pairs=1 unequal=0`.
- [ ] [P2-T10] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/regression-testing/parser-mirror-contracts.2026-10-08T22-17.md` (Claude bundle parity after the parser copy). Command: `poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. Acceptance: exit 0 and no FAILED line.
- [ ] [P2-T11] Update `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`: change only the AC-1 checkbox from unchecked to checked (verified by the two `-RequireWorkflow parameter surface` tests passing in P2-T8). Acceptance: `git grep -c -F -e '- [x] AC-1:' -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` prints 1.
- [ ] [P2-T12] Update `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`: check off AC-2 only (empty-array and null-set tests passed in P2-T8). Acceptance: `git grep -c -F -e '- [x] AC-2:' -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` prints 1.
- [ ] [P2-T13] Update `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`: check off AC-3 only (non-CI-only test passed in P2-T8). Acceptance: `git grep -c -F -e '- [x] AC-3:' -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` prints 1.
- [ ] [P2-T14] Update `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`: check off AC-4 only (two CI-pass tests passed in P2-T8). Acceptance: `git grep -c -F -e '- [x] AC-4:' -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` prints 1.
- [ ] [P2-T15] Update `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`: check off AC-5 only (CI fail and CI cancel tests passed in P2-T8). Acceptance: `git grep -c -F -e '- [x] AC-5:' -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` prints 1.
- [ ] [P2-T16] Update `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`: check off AC-6 only (CI pass plus non-CI fail test passed in P2-T8). Acceptance: `git grep -c -F -e '- [x] AC-6:' -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` prints 1.
- [ ] [P2-T17] Update `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`: check off AC-7 only (three pending-precedence tests passed in P2-T8). Acceptance: `git grep -c -F -e '- [x] AC-7:' -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` prints 1.
- [ ] [P2-T18] Update `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`: check off AC-8 only (skipping, lowercase, missing-workflow, and whitespace tests passed in P2-T8). Acceptance: `git grep -c -F -e '- [x] AC-8:' -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` prints 1.
- [ ] [P2-T19] Update `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`: check off AC-9 only (script entry-point forwarding test passed in P2-T8). Acceptance: `git grep -c -F -e '- [x] AC-9:' -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` prints 1.
- [ ] [P2-T20] Update `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`: check off AC-10 only (all 15 pre-existing tests, including the renamed empty-array test and the null-set test, passed in P2-T8). Acceptance: `git grep -c -F -e '- [x] AC-10:' -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` prints 1.
- [ ] [P2-T21] Commit and push Phase 2. Commands: `git add -- .claude/lib/ci-gate/Invoke-CiGateParser.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1 tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841`, `git commit -m "fix(841): add opt-in -RequireWorkflow guard to the CI gate parser"`, `git push -u origin bug/ci-gate-vacuous-on-empty-check-list-841`. Acceptance: `git status --porcelain -- .claude/lib/ci-gate extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate tests/scripts/claude-lib/ci-gate docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841` prints nothing and the push exits 0.

### Phase 3 — Orchestrate S9 Wording (CR-1 Wiring, CR-4)

- [ ] [P3-T1] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/other/pre-edit-orchestrate.2026-10-08T22-17.md` after re-reading the current text of `.claude/skills/orchestrate/SKILL.md` from `## Step S9 — CI Green Gate` through `## Remediation Loop — CI-Failure Handling` (concurrency guard for #798). Commands: `git grep -c -F -e 'check must succeed before' -- .claude/skills/orchestrate/SKILL.md`; `git grep -c -F -e 'when all required checks pass' -- .claude/skills/orchestrate/SKILL.md`; `git grep -c -F -e 'that the required checks were observed against' -- .claude/skills/orchestrate/SKILL.md`; `git fetch origin main`; `git log --oneline HEAD..origin/main -- .claude/skills/orchestrate/SKILL.md`. Acceptance: each of the three searches prints a count of 1; the artifact quotes the current step 2 epic-child paragraph, step 3 line, and `head_sha` bullet verbatim and records the `git log` output (informational: commits listed there indicate #798 landed on main and a merge conflict may follow, per spec Risks). A count other than 1 stops the plan, because the Appendix E anchors would no longer match.
- [ ] [P3-T2] Edit `.claude/skills/orchestrate/SKILL.md`: apply Appendix E1 (append the epic-child counting, `-RequireWorkflow CI`, and "no checks reported" sentences to the step 2 epic-child paragraph). Acceptance: `git grep -c -F -e 'Every check returned by the unfiltered query counts' -- .claude/skills/orchestrate/SKILL.md` prints 1 and `git grep -c -F -e 'is never treated as green' -- .claude/skills/orchestrate/SKILL.md` prints 1.
- [ ] [P3-T3] Edit `.claude/skills/orchestrate/SKILL.md`: apply Appendix E2 (replace the step 3 line; the parser command stays on one line). Acceptance: `git grep -c -F -e 'when all required checks pass' -- .claude/skills/orchestrate/SKILL.md` exits 1 with no output and `git grep -c -F -e 'over the queried checks' -- .claude/skills/orchestrate/SKILL.md` prints 1.
- [ ] [P3-T4] Edit `.claude/skills/orchestrate/SKILL.md`: apply Appendix E3 (the `head_sha` schema bullet). Acceptance: `git grep -c -F -e 'that the required checks were observed against' -- .claude/skills/orchestrate/SKILL.md` exits 1 with no output and `git grep -c -F -e 'that the queried checks were observed against' -- .claude/skills/orchestrate/SKILL.md` prints 1.
- [ ] [P3-T5] Update `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` by byte copy from `.claude/skills/orchestrate/SKILL.md`. Command: `cp .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`. Acceptance: `sh SCRATCH/run-ps.sh SCRATCH/pair-hashes.ps1 .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` prints `PAIR-SUMMARY pairs=1 unequal=0`.
- [ ] [P3-T6] [expect-fail] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/regression-testing/orchestrate-contracts.2026-10-08T22-17.md` with `ExpectedExitCode: 1` (the feature-review stages are still pending, so pytest exits 1 by design). Command: `poetry run pytest -v tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`. Acceptance: exit 1; summary `14 failed, 12 passed`; all eight nodes whose names begin `test_orchestrate_` are PASSED; the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and `Output Summary:` with the summary line and every FAILED node ID verbatim. Any other outcome stops the plan for a design review.
- [ ] [P3-T7] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/regression-testing/orchestrate-suites.2026-10-08T22-17.md` (suites that read the orchestrate skill). Command: `poetry run pytest -v tests/scripts/dev_tools/test_skill_bundle_contract_repo.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. Acceptance: every FAILED node (if any) is a member of SUITES_FAIL_0, and no FAILED node is in `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`, `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`, `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py`, or `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
- [ ] [P3-T8] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/regression-testing/claude-runtime-after-orchestrate.2026-10-08T22-17.md` (Pester suites that read the orchestrate skill). Command: `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-runtime`. Acceptance: every `FAILED:` line (if any) is a member of RUNTIME_FAIL_0 and `TotalCount=` equals the P0-T13 value.
- [ ] [P3-T9] Update `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`: check off AC-11 only (the six S9, schema, and superseded-wording nodes for both orchestrate copies passed in P3-T6). Acceptance: `git grep -c -F -e '- [x] AC-11:' -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` prints 1.
- [ ] [P3-T10] Update `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`: check off AC-12 only (both `test_orchestrate_parser_command_stays_on_one_line` nodes passed in P3-T6 and `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` passed in P3-T7). Acceptance: `git grep -c -F -e '- [x] AC-12:' -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` prints 1.
- [ ] [P3-T11] Commit and push Phase 3. Commands: `git add -- .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841`, `git commit -m "docs(841): require a passing CI check for epic-child S9 and describe queried checks"`, `git push -u origin bug/ci-gate-vacuous-on-empty-check-list-841`. Acceptance: `git status --porcelain -- .claude/skills/orchestrate extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841` prints nothing and the push exits 0.

### Phase 4 — Claude Feature-Review Rule (PA-N9)

- [ ] [P4-T1] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/other/pre-edit-claude-review.2026-10-08T22-17.md` after re-reading the current `## Policy Rules` section of `.claude/skills/feature-review-workflow/SKILL.md` (concurrency guard for #824). Commands: `git grep -c -F -e 'whose head SHA matches the current branch head' -- .claude/skills/feature-review-workflow/SKILL.md`; `git fetch origin main`; `git log --oneline HEAD..origin/main -- .claude/skills/feature-review-workflow/SKILL.md`. Acceptance: the search prints a count of 1; the artifact quotes the current rule bullets verbatim and records the `git log` output (informational, per spec Risks). A count other than 1 stops the plan.
- [ ] [P4-T2] Edit `.claude/skills/feature-review-workflow/SKILL.md`: apply Appendix F1 (replace only the qualifying-run bullet; the trigger sentence, the second-line-of-defense bullet, the `workflow_dispatch` bullet, and the `awaiting_ci` bullet are unchanged). Acceptance: `git grep -c -F -e 'whose head SHA matches the current branch head' -- .claude/skills/feature-review-workflow/SKILL.md` exits 1 with no output; `git grep -c -F -e 'cannot name the SHA of the commit that contains it' -- .claude/skills/feature-review-workflow/SKILL.md` prints 1; `git grep -c -F -e 'git merge-base --is-ancestor' -- .claude/skills/feature-review-workflow/SKILL.md` prints 1.
- [ ] [P4-T3] Update `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md` by byte copy from `.claude/skills/feature-review-workflow/SKILL.md`. Command: `cp .claude/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`. Acceptance: A4 over the pair prints `PAIR-SUMMARY pairs=1 unequal=0`.
- [ ] [P4-T4] [expect-fail] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/regression-testing/claude-review-contracts.2026-10-08T22-17.md` with `ExpectedExitCode: 1` (the `.agents` stage is still pending, so pytest exits 1 by design). Command: `poetry run pytest -v tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`. Acceptance: exit 1; summary `10 failed, 16 passed`; the four `test_review_rule_defines_satisfiable_qualifying_run` and `test_review_rule_drops_sha_exact_definition` nodes whose IDs contain `.claude/skills/feature-review-workflow/SKILL.md` are PASSED; the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and `Output Summary:` with the summary line and every FAILED node ID verbatim. Any other outcome stops the plan for a design review.
- [ ] [P4-T5] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/regression-testing/claude-review-suites.2026-10-08T22-17.md` (pinned-fragment and parity suites for the Claude review skill). Command: `poetry run pytest -v tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. Acceptance: exit 0 and no FAILED line.
- [ ] [P4-T6] Update `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`: check off AC-14 only (P4-T4 node results for both Claude copies). Acceptance: `git grep -c -F -e '- [x] AC-14:' -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` prints 1.
- [ ] [P4-T7] Commit and push Phase 4. Commands: `git add -- .claude/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841`, `git commit -m "docs(841): define a satisfiable qualifying run for modified-workflow-needs-green-run"`, `git push -u origin bug/ci-gate-vacuous-on-empty-check-list-841`. Acceptance: `git status --porcelain -- .claude/skills/feature-review-workflow extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841` prints nothing and the push exits 0.

### Phase 5 — Agents Feature-Review Rule (#795)

- [ ] [P5-T1] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/other/pre-edit-agents-review.2026-10-08T22-17.md` after re-reading `.agents/skills/feature-review-workflow/SKILL.md` from `### Work-mode acceptance-criteria contract` through `## Ordered Procedure`. Commands: `git grep -c -F -e '## Ordered Procedure' -- .agents/skills/feature-review-workflow/SKILL.md`; `git grep -c -F -e '## Policy Rules' -- .agents/skills/feature-review-workflow/SKILL.md`. Acceptance: the first prints 1; the second exits 1 with no output; the artifact quotes the last line of the work-mode contract verbatim. Any other result stops the plan.
- [ ] [P5-T2] Edit `.agents/skills/feature-review-workflow/SKILL.md`: apply Appendix F2 (insert `## Policy Rules` and `### modified-workflow-needs-green-run` before `## Ordered Procedure`). Acceptance: `git grep -c -F -e '### modified-workflow-needs-green-run' -- .agents/skills/feature-review-workflow/SKILL.md` prints 1; `git grep -c -F -e '## Policy Rules' -- .agents/skills/feature-review-workflow/SKILL.md` prints 1; `git grep -c -F -e 'CI Green Gate (S9)' -- .agents/skills/feature-review-workflow/SKILL.md` prints 2.
- [ ] [P5-T3] Update `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md` by byte copy from `.agents/skills/feature-review-workflow/SKILL.md`. Command: `cp .agents/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md`. Acceptance: A4 over the pair prints `PAIR-SUMMARY pairs=1 unequal=0`.
- [ ] [P5-T4] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/regression-testing/agents-review-contracts.2026-10-08T22-17.md` (pass-after run of the full pytest suite). Command: `poetry run pytest -v tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`. Acceptance: exit 0 and summary `26 passed`.
- [ ] [P5-T5] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/regression-testing/agents-review-suites.2026-10-08T22-17.md` (Codex bundle parity and manifest completeness). Command: `poetry run pytest -v tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`. Acceptance: exit 0 and no FAILED line.
- [ ] [P5-T6] Update `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`: check off AC-15 only (the placement, Codex-bullet, and qualifying-run nodes for both `.agents` copies passed in P5-T4). Acceptance: `git grep -c -F -e '- [x] AC-15:' -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` prints 1.
- [ ] [P5-T7] Update `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`: check off AC-16 only (the four `test_agents_citing_copy_resolves_rule` nodes and `test_rule_resolution_reports_missing_heading` passed in P5-T4). Acceptance: `git grep -c -F -e '- [x] AC-16:' -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` prints 1.
- [ ] [P5-T8] Commit and push Phase 5. Commands: `git add -- .agents/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841`, `git commit -m "docs(795): define modified-workflow-needs-green-run in the Codex feature-review skill"`, `git push -u origin bug/ci-gate-vacuous-on-empty-check-list-841`. Acceptance: `git status --porcelain -- .agents/skills/feature-review-workflow extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841` prints nothing and the push exits 0.

### Phase 6 — Final QA Loop, Scope Verification, and Closeout

- [ ] [P6-T1] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-powershell-format.2026-10-08T22-17.md` (QA loop step 1, PowerShell formatting). Commands: `mcp__drm-copilot__run_poshqc_format` with `workspace_root` set to the worktree root and `scan_folders` set to `.claude/lib/ci-gate` and `tests/scripts/claude-lib/ci-gate`; then `git status --porcelain -- .claude/lib/ci-gate tests/scripts/claude-lib/ci-gate`; then `sh SCRATCH/run-ps.sh SCRATCH/ps-format-check.ps1 .claude/lib/ci-gate/Invoke-CiGateParser.ps1 tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`. Acceptance (AC-19 format half): the MCP call returns without raising; the status output is empty (the formatter changed nothing); A6 prints `FORMAT-SUMMARY ChangedCount=0`. A non-empty status restarts the loop per the toolchain loop rule.
- [ ] [P6-T2] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-powershell-analyze.2026-10-08T22-17.md` (QA loop step 2, PowerShell lint). Commands: `mcp__drm-copilot__run_poshqc_analyze` with the P6-T1 arguments, then `sh SCRATCH/run-ps.sh SCRATCH/pssa-count.ps1 .claude/lib/ci-gate/Invoke-CiGateParser.ps1 tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`. Acceptance (AC-19 lint half): the MCP call returns without raising and A5 prints `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P6-T3] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-pester-coverage.2026-10-08T22-17.md` (QA loop step 3, Pester with coverage). Commands: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and `scan_folders` set to `tests/scripts/claude-lib/ci-gate`, recorded by call disposition only (returned or raised; the MCP result carries no output text, per PD5); then `sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/ci-gate -CoveragePath .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -CoverageOutputPath SCRATCH/cov-parser-final.xml -ReportPath SCRATCH/cov-parser-final.txt`. Acceptance (AC-20, AC-17 manifest part): the MCP call returns without raising; A3 prints `TotalCount=35`, `PassedCount=35`, `FailedCount=0`; the parser `LinePercent=` value, recorded as PARSER_POST_PCT, is numeric, at least 85, and at least PARSER_BASE_PCT.
- [ ] [P6-T4] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-python-black.2026-10-08T22-17.md` (QA loop step 4, Python formatting). Command: `poetry run black --check tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`. Acceptance (AC-21): exit 0 and the output contains the BLACK_OK success line recorded in P0-T16 (expected "1 file would be left unchanged."). On exit 1, run `poetry run black tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` (it prints "1 file reformatted"), record both runs, and restart the loop at P6-T1.
- [ ] [P6-T5] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-python-ruff.2026-10-08T22-17.md` (QA loop step 5, Python lint, no autofix). Command: `poetry run ruff check tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`. Acceptance (AC-21): exit 0 and the output contains the RUFF_OK line recorded in P0-T17 (expected "All checks passed!").
- [ ] [P6-T6] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-python-pyright.2026-10-08T22-17.md` (QA loop step 6, Python type checking). Command: `poetry run pyright tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`. Acceptance (AC-21): exit 0 and the summary line matches the PYRIGHT_OK form recorded in P0-T18 (expected to begin "0 errors").
- [ ] [P6-T7] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-python-pytest.2026-10-08T22-17.md` (QA loop step 7, Python unit tests). Command: `poetry run pytest -v tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`. Acceptance (AC-21, AC-11, AC-14, AC-15, AC-16): exit 0 and summary `26 passed`.
- [ ] [P6-T8] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-python-coverage.2026-10-08T22-17.md` (QA loop step 8, Python coverage no-regression guard). Command: `poetry run pytest tests/scripts/dev_tools/test_skill_bundle_contract.py tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py --cov=scripts.dev_tools.skill_bundle_contract --cov-report=term-missing`. Acceptance: exit 0; the row whose name ends with `skill_bundle_contract.py` prints a numeric `Cover` value, recorded as PY_POST_PCT and equal to PY_BASE_PCT (no Python production file changed).
- [ ] [P6-T9] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-contract-suites.2026-10-08T22-17.md` (QA loop step 9, contract and parity suites). Command: the Appendix G2 command. Acceptance (AC-12, AC-13 test half, AC-17, AC-18): every FAILED node (if any) is a member of SUITES_FAIL_0, and no FAILED node is in any of the seven AC-bearing suites named in P0-T14.
- [ ] [P6-T10] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-claude-runtime-pester.2026-10-08T22-17.md` (QA loop step 10, Pester regression). Command: `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-runtime`. Acceptance: every `FAILED:` line (if any) is a member of RUNTIME_FAIL_0 and `TotalCount=` equals the P0-T13 value.
- [ ] [P6-T11] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-mirror-hashes.2026-10-08T22-17.md` (QA loop step 11, mirror parity). Command: `sh SCRATCH/run-ps.sh SCRATCH/pair-hashes.ps1` with the eight paths of Appendix G1. Acceptance (AC-17): `PAIR-SUMMARY pairs=4 unequal=0`.
- [ ] [P6-T12] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/line-counts.2026-10-08T22-17.md` (QA loop step 12, file-size limit). Command: `sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 .claude/lib/ci-gate/Invoke-CiGateParser.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1 tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`. Acceptance (AC-22): four `LineCount=` lines, each at most 500.
- [ ] [P6-T13] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/coverage-comparison.2026-10-08T22-17.md` (QA loop step 13, coverage comparison). Command: `sh SCRATCH/run-ps.sh SCRATCH/changed-line-coverage.ps1 -ReportPath SCRATCH/cov-parser-final.txt -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -BaseSha <BASE_SHA>` (A8 computes the added-line ranges from a zero-context diff of the parser against BASE_SHA). Acceptance (AC-20): the artifact records PARSER_BASE_PCT, PARSER_POST_PCT, the A8 `ChangedLinePercent=` value, PY_BASE_PCT, and PY_POST_PCT as numbers; PARSER_POST_PCT is at least 85 and at least PARSER_BASE_PCT; `ChangedLinePercent=` is numeric and at least 85; every `CHANGED-MISSED` line number is listed; PY_POST_PCT equals PY_BASE_PCT. A missing or non-numeric value is a remediation-required outcome, not PASS.
- [ ] [P6-T14] Commit and push the QA evidence and any loop fix. Commands: `git status --porcelain`; `git add -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841` followed by every one of the ten `## Files Written` production, test, and mirror paths that the first status listed (a loop fix such as a black reformat, made and re-verified in a clean P6-T1 to P6-T13 pass); `git commit -m "docs(841): record final QA evidence"`; `git push -u origin bug/ci-gate-vacuous-on-empty-check-list-841`. Acceptance: the first `git status --porcelain` lists only paths under `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/` and paths among the ten `## Files Written` code paths (any other path stops the plan; the promoted record named in `## Files Written` was committed by the preparation run, so it does not appear in this status and is not staged here); after the commit, `git status --porcelain` prints nothing and the push exits 0.
- [ ] [P6-T15] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/unchanged-files.2026-10-08T22-17.md` (AC-13 scope verification anchored to `origin/main`). Commands, each recorded before the artifact is written: `git fetch origin main`; `git diff --name-only origin/main...HEAD`; `git status --porcelain`; and the Appendix G3 `git diff --exit-code origin/main...HEAD` command over the protected paths. Acceptance: the name-only list contains exactly the ten paths of `## Files Written` (production, tests, mirrors), the preparation-run path `docs/features/potential/promoted/2026-10-08-ci-gate-vacuous-on-empty-check-list.md`, and paths under `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/`, and no other path (this set is the P6-T15 set); `git status --porcelain` lists no path outside `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/` (the P6-T14 check-off edit to the plan file is the expected line); the Appendix G3 command exits 0 with no output.
- [ ] [P6-T16] Update `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`: check off AC-13 only (P6-T15 diff results and the surface-pin suite in P6-T9). Acceptance: `git grep -c -F -e '- [x] AC-13:' -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` prints 1.
- [ ] [P6-T17] Update `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`: check off AC-17 only (P6-T9 parity suites, P6-T3 manifest test, P6-T11 hashes). Acceptance: `git grep -c -F -e '- [x] AC-17:' -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` prints 1.
- [ ] [P6-T18] Update `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`: check off AC-18 only (P6-T9 pinned-fragment suites). Acceptance: `git grep -c -F -e '- [x] AC-18:' -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` prints 1.
- [ ] [P6-T19] Update `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`: check off AC-19 only (P6-T1 and P6-T2). Acceptance: `git grep -c -F -e '- [x] AC-19:' -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` prints 1.
- [ ] [P6-T20] Update `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`: check off AC-20 only (P6-T3 and P6-T13 coverage values). Acceptance: `git grep -c -F -e '- [x] AC-20:' -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` prints 1.
- [ ] [P6-T21] Update `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`: check off AC-21 only (P6-T4 through P6-T7). Acceptance: `git grep -c -F -e '- [x] AC-21:' -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` prints 1.
- [ ] [P6-T22] Update `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`: check off AC-22 only (P6-T12). Acceptance: `git grep -c -F -e '- [x] AC-22:' -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` prints 1, and `git grep -c -F -e '- [ ] AC-' -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md` exits 1 with no output (no criterion remains unchecked).
- [ ] [P6-T23] Write `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/ac-verification.2026-10-08T22-17.md` (acceptance-criteria verification and test-evidence index). Acceptance: one row per AC-1 through AC-22 naming the verifying test node IDs or commands and the evidence path from the AC traceability table below; the `### Acceptance Criteria Status` block of the acceptance-criteria-tracking skill with Source `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/spec.md`, Total 22, Checked off 22, Remaining 0; no criterion is listed as pending-CI (none of AC-1 through AC-22 requires PR CI).
- [ ] [P6-T24] Update `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/plan.2026-10-08T22-17.md`: mark every completed task `[x]` and set `**Status:**` to `Executed`. Acceptance: run before this task's own checkbox is set, `git grep -c -e '^- \[ \] \[P' -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/plan.2026-10-08T22-17.md` prints a count of 2 (only P6-T24 and P6-T25 remain unchecked); after this task is checked, the same command prints 1.
- [ ] [P6-T25] Update `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/plan.2026-10-08T22-17.md` (this task's checkbox) after committing and pushing the closeout. Step 1 commands: `git add -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841`, `git commit -m "docs(841): check off acceptance criteria and record verification"`, `git push -u origin bug/ci-gate-vacuous-on-empty-check-list-841`, `git diff --name-only origin/main...HEAD`. Step 1 acceptance: the push exits 0 and the name-only list contains no path outside the P6-T15 set. Step 2: set this task's checkbox to `[x]` in the plan file, then run `git add -- docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/plan.2026-10-08T22-17.md`, `git commit -m "docs(841): check off P6-T25"`, `git push -u origin bug/ci-gate-vacuous-on-empty-check-list-841`, `git status --porcelain`. Step 2 acceptance: the push exits 0 and, after that push, `git status --porcelain` prints nothing. Both commits carry the trailer per the commit rule.

## AC Traceability

| AC | Implementation | Tests | Evidence |
|---|---|---|---|
| AC-1 | P2-T1 to P2-T4 | Pester `-RequireWorkflow parameter surface` (2 `It`) | `regression-testing/pester-after-parser-fix`, `qa-gates/final-pester-coverage` |
| AC-2 | P2-T3 | Pester "returns pending for an empty check array with -RequireWorkflow CI", "returns pending for a null check set with -RequireWorkflow CI" | same |
| AC-3 | P2-T3 | Pester "returns pending when only non-CI checks pass" | same |
| AC-4 | P2-T3 | Pester "returns success when a CI check passes", "returns success when a CI check and a non-CI check both pass" | same |
| AC-5 | P2-T3 | Pester "returns failure when a CI check failed", "returns failure when a CI check was cancelled" | same |
| AC-6 | P2-T3 | Pester "returns failure when a CI check passes and a non-CI check failed" | same |
| AC-7 | P2-T3 | Pester three pending-precedence `It` blocks | same |
| AC-8 | P2-T3 | Pester skipping, lowercase, missing-workflow, whitespace `It` blocks | same |
| AC-9 | P2-T5 | Pester "forwards -RequireWorkflow from the script entry point" | same |
| AC-10 | P1-T1 (rename only) | 15 pre-existing Pester `It` blocks | same |
| AC-11 | P3-T2 to P3-T5 | pytest `test_orchestrate_s9_states_epic_child_guard`, `test_orchestrate_schema_head_sha_names_queried_checks`, `test_orchestrate_drops_required_check_wording` (2 copies each) | `regression-testing/orchestrate-contracts`, `qa-gates/final-python-pytest` |
| AC-12 | P3-T3 | pytest `test_orchestrate_parser_command_stays_on_one_line`; `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` | `regression-testing/orchestrate-suites`, `qa-gates/final-contract-suites` |
| AC-13 | no write to protected paths | `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` and the planner surface suites | `qa-gates/unchanged-files`, `qa-gates/final-contract-suites` |
| AC-14 | P4-T2, P4-T3 | pytest `test_review_rule_defines_satisfiable_qualifying_run`, `test_review_rule_drops_sha_exact_definition` (Claude copies) | `regression-testing/claude-review-contracts` |
| AC-15 | P5-T2, P5-T3 | pytest `test_agents_review_rule_sits_before_ordered_procedure`, `test_agents_review_rule_carries_codex_bullets`, qualifying-run nodes (`.agents` copies) | `regression-testing/agents-review-contracts` |
| AC-16 | P1-T3, P5-T2 | pytest `test_agents_citing_copy_resolves_rule` (4), `test_rule_resolution_reports_missing_heading` | same |
| AC-17 | P2-T9, P3-T5, P4-T3, P5-T3 | claude and codex resource contract suites; `CiGate.Manifest.Tests.ps1` | `qa-gates/final-contract-suites`, `qa-gates/final-pester-coverage`, `qa-gates/final-mirror-hashes` |
| AC-18 | anchored hunks only | completion-gate, tier-rule-adoption, remediation-docs suites | `qa-gates/final-contract-suites` |
| AC-19 | P2-T6, P2-T7 | PoshQC format and analyze | `qa-gates/final-powershell-format`, `qa-gates/final-powershell-analyze` |
| AC-20 | P1-T2, P2-T1 to P2-T5 | Pester with coverage | `baseline/pester-ci-gate-coverage`, `qa-gates/final-pester-coverage`, `qa-gates/coverage-comparison` |
| AC-21 | P1-T3 | black, ruff, pyright, pytest | `qa-gates/final-python-black`, `final-python-ruff`, `final-python-pyright`, `final-python-pytest` |
| AC-22 | all code writes | line counts | `qa-gates/line-counts` |

---

## Appendix A — Scratch Scripts (written under SCRATCH by P0-T6; never committed)

A1 `run-ps.sh`:

```sh
#!/bin/sh
set -eu
pwsh -NoProfile -NonInteractive -File "$@"
```

A2 `pester-counts.ps1`:

```powershell
param([Parameter(Mandatory)][string[]] $Path)
$Path = @($Path | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$configuration = New-PesterConfiguration
$configuration.Run.Path = $Path
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Detailed'
$result = Invoke-Pester -Configuration $configuration
Write-Output "TotalCount=$($result.TotalCount)"
Write-Output "PassedCount=$($result.PassedCount)"
Write-Output "FailedCount=$($result.FailedCount)"
foreach ($failedTest in $result.Failed) { Write-Output "FAILED: $($failedTest.ExpandedPath)" }
```

A3 `pester-coverage.ps1`:

```powershell
param(
    [Parameter(Mandatory)][string[]] $TestPath,
    [Parameter(Mandatory)][string[]] $CoveragePath,
    [Parameter(Mandatory)][string] $CoverageOutputPath,
    [string] $ReportPath = ''
)
$TestPath = @($TestPath | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$CoveragePath = @($CoveragePath | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$configuration = New-PesterConfiguration
$configuration.Run.Path = $TestPath
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Detailed'
$configuration.CodeCoverage.Enabled = $true
$configuration.CodeCoverage.Path = $CoveragePath
$configuration.CodeCoverage.OutputPath = $CoverageOutputPath
$result = Invoke-Pester -Configuration $configuration
$report = [System.Collections.Generic.List[string]]::new()
$report.Add("TotalCount=$($result.TotalCount)")
$report.Add("PassedCount=$($result.PassedCount)")
$report.Add("FailedCount=$($result.FailedCount)")
foreach ($failedTest in $result.Failed) { $report.Add("FAILED: $($failedTest.ExpandedPath)") }
$executed = @($result.CodeCoverage.CommandsExecuted)
$missed = @($result.CodeCoverage.CommandsMissed)
foreach ($file in $CoveragePath) {
    $fullPath = (Resolve-Path -LiteralPath $file).Path
    $hitLines = @($executed | Where-Object { $_.File -eq $fullPath } | ForEach-Object { $_.Line } | Sort-Object -Unique)
    $missLines = @($missed | Where-Object { $_.File -eq $fullPath } | ForEach-Object { $_.Line } | Sort-Object -Unique | Where-Object { $hitLines -notcontains $_ })
    $analyzed = @(@($hitLines) + @($missLines) | Sort-Object -Unique)
    $percent = if ($analyzed.Count -eq 0) { 'NA' } else { [math]::Round(100 * $hitLines.Count / $analyzed.Count, 2) }
    $report.Add("COVERAGE file=$file AnalyzedLines=$($analyzed.Count) CoveredLines=$($hitLines.Count) LinePercent=$percent")
    $report.Add("HIT file=$file Lines=$($hitLines -join ',')")
    $report.Add("MISSED file=$file Lines=$($missLines -join ',')")
}
$report | Write-Output
if ($ReportPath) { $report | Set-Content -LiteralPath $ReportPath -Encoding UTF8 }
```

A4 `pair-hashes.ps1` (arguments: primary, mirror, primary, mirror, ...):

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
$ErrorActionPreference = 'Stop'
if ($Path.Count % 2 -ne 0) { throw 'pair-hashes: an even number of paths is required.' }
$unequal = 0
for ($index = 0; $index -lt $Path.Count; $index += 2) {
    $primary = (Get-FileHash -LiteralPath $Path[$index] -Algorithm SHA256).Hash
    $mirror = (Get-FileHash -LiteralPath $Path[$index + 1] -Algorithm SHA256).Hash
    $equal = $primary -eq $mirror
    if (-not $equal) { $unequal++ }
    Write-Output "PAIR primary=$($Path[$index]) mirror=$($Path[$index + 1]) Equal=$equal"
}
Write-Output "PAIR-SUMMARY pairs=$($Path.Count / 2) unequal=$unequal"
```

A5 `pssa-count.ps1`:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$records = @(foreach ($file in $Path) { Invoke-ScriptAnalyzer -Path $file -Settings $settings })
foreach ($record in $records) { Write-Output "PSSA $($record.ScriptName):$($record.Line) $($record.RuleName) $($record.Severity)" }
Write-Output "PSSA-SUMMARY DiagnosticCount=$($records.Count)"
```

A6 `ps-format-check.ps1` (read-only):

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$changedCount = 0
foreach ($file in $Path) {
    $original = Get-Content -Raw -LiteralPath $file
    $formatted = Invoke-Formatter -ScriptDefinition $original -Settings $settings
    $changed = $formatted -cne $original
    if ($changed) { $changedCount++ }
    Write-Output "FORMAT file=$file Changed=$changed"
}
Write-Output "FORMAT-SUMMARY ChangedCount=$changedCount"
```

A7 `line-counts.ps1`:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
foreach ($file in $Path) { Write-Output "$file LineCount=$((Get-Content -LiteralPath $file).Count)" }
```

A8 `changed-line-coverage.ps1` (reads the A3 report; runs `git diff -U0` anchored to the supplied base commit):

```powershell
param(
    [Parameter(Mandatory)][string] $ReportPath,
    [Parameter(Mandatory)][string] $File,
    [Parameter(Mandatory)][string] $BaseSha
)
$ErrorActionPreference = 'Stop'
$report = Get-Content -LiteralPath $ReportPath
$hitText = @($report | Where-Object { $_ -like "HIT file=$File Lines=*" })[0] -replace '^.*Lines=', ''
$missText = @($report | Where-Object { $_ -like "MISSED file=$File Lines=*" })[0] -replace '^.*Lines=', ''
$hit = @($hitText -split ',' | Where-Object { $_ } | ForEach-Object { [int]$_ })
$miss = @($missText -split ',' | Where-Object { $_ } | ForEach-Object { [int]$_ })
$changed = [System.Collections.Generic.HashSet[int]]::new()
foreach ($header in @(git diff -U0 $BaseSha -- $File | Where-Object { $_ -like '@@*' })) {
    if ($header -match '\+(?<first>\d+)(,(?<len>\d+))?') {
        $first = [int]$Matches['first']
        $length = if ($Matches['len']) { [int]$Matches['len'] } else { 1 }
        for ($line = $first; $line -lt $first + $length; $line++) { [void]$changed.Add($line) }
    }
}
$changedHit = @($hit | Where-Object { $changed.Contains($_) })
$changedMiss = @($miss | Where-Object { $changed.Contains($_) })
$executable = $changedHit.Count + $changedMiss.Count
$percent = if ($executable -eq 0) { 'NA' } else { [math]::Round(100 * $changedHit.Count / $executable, 2) }
Write-Output "CHANGED-LINES file=$File ChangedLines=$($changed.Count) ExecutableChanged=$executable CoveredChanged=$($changedHit.Count) ChangedLinePercent=$percent"
Write-Output "CHANGED-MISSED file=$File Lines=$($changedMiss -join ',')"
```

## Appendix B — Parser Hunks for `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`

Each hunk is one Edit-tool replacement. Copy the old text from the file itself (whitespace must match exactly); the old text shown here was read from the file in this planning pass.

B1 (script `.DESCRIPTION`, after line 26). Old:

```text
    An empty required-check set is treated as 'success' (vacuously satisfied: no
    required check can fail or be in progress). An unrecognized bucket value is a
    fail-fast error so the parser never silently passes an enum it does not
    understand.
```

New:

```text
    An empty required-check set is treated as 'success' (vacuously satisfied: no
    required check can fail or be in progress). An unrecognized bucket value is a
    fail-fast error so the parser never silently passes an enum it does not
    understand.

    Epic-child guard (-RequireWorkflow): when -RequireWorkflow names a workflow
    (S9 passes 'CI' when the checkpoint epic_mode is true), the empty-set rule
    above does not apply. Failure and pending precedence is unchanged over every
    observed check; the conclusion is 'success' only when at least one observed
    check whose workflow property equals the name (case-sensitive) has bucket
    'pass', and 'pending' otherwise. An empty or null check set therefore yields
    'pending'. The default value ('') keeps the behavior described above.
```

B2 (script `.PARAMETER RequireWorkflow`, between `.PARAMETER NowProvider` and `.PARAMETER AsJson`). Old:

```text
    inject a fixed delegate to make verified_at deterministic.

.PARAMETER AsJson
```

New:

```text
    inject a fixed delegate to make verified_at deterministic.

.PARAMETER RequireWorkflow
    Optional workflow name (default ''). When non-empty, the conclusion is
    'success' only after at least one check whose `workflow` property equals
    this value (case-sensitive) has bucket 'pass'; an empty or null check set
    yields 'pending'. S9 passes 'CI' for an epic-child PR. A whitespace-only
    value is rejected with an error.

.PARAMETER AsJson
```

B3 (second `.EXAMPLE`). Old:

```text
.EXAMPLE
    gh pr checks --required --json bucket,name,state,link,workflow |
        ./.claude/lib/ci-gate/Invoke-CiGateParser.ps1 -HeadSha $sha
```

New:

```text
.EXAMPLE
    gh pr checks --required --json bucket,name,state,link,workflow |
        ./.claude/lib/ci-gate/Invoke-CiGateParser.ps1 -HeadSha $sha

.EXAMPLE
    gh pr checks --json bucket,name,state,link,workflow |
        ./.claude/lib/ci-gate/Invoke-CiGateParser.ps1 -HeadSha $sha -RequireWorkflow CI
```

B4 (script `param`; the old text is the unique four-space-indented block ending in the column-0 `)`). Old:

```text
    [ScriptBlock]$NowProvider = { (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ') },

    [Parameter(Mandatory = $false)]
    [switch]$AsJson
)
```

New:

```text
    [ScriptBlock]$NowProvider = { (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ') },

    [Parameter(Mandatory = $false)]
    [string]$RequireWorkflow = '',

    [Parameter(Mandatory = $false)]
    [switch]$AsJson
)
```

B5 (`Get-CiGateConclusion` help). Old:

```text
        unrecognized value, preventing a silent pass on an unknown state.

    .PARAMETER Checks
        The parsed required-check collection (each element exposing a `bucket`
        property). May be $null or empty, which yields 'success'.
```

New:

```text
        unrecognized value, preventing a silent pass on an unknown state.

        With -RequireWorkflow set, one rule follows the pending rule: when no
        check whose `workflow` property equals the name (case-sensitive) has
        bucket 'pass', the result is 'pending'. An empty or null set then yields
        'pending' instead of 'success'.

    .PARAMETER Checks
        The parsed check collection (each element exposing a `bucket`
        property). May be $null or empty, which yields 'success' unless
        -RequireWorkflow is set.

    .PARAMETER RequireWorkflow
        Optional workflow name; '' (default) disables the guard. A
        whitespace-only value throws. An element without a `workflow` property
        never matches.
```

B6 (`Get-CiGateConclusion` parameter, validation, and empty-set return). Old:

```text
            [AllowNull()]
            [object[]]$Checks
        )

        # Empty or null required-check set is vacuously satisfied: there is no check
        # that can fail or be in progress, so the gate concludes 'success'.
        if ($null -eq $Checks -or $Checks.Count -eq 0) {
            return 'success'
        }

        # Track whether any check is still in progress so we can defer the 'pending'
        # decision until after confirming nothing failed (failure outranks pending).
        $anyPending = $false
```

New:

```text
            [AllowNull()]
            [object[]]$Checks,

            [Parameter(Mandatory = $false)]
            [string]$RequireWorkflow = ''
        )

        # A non-empty, whitespace-only workflow name is invalid input. Reject it
        # rather than silently disabling the guard and restoring vacuous success.
        if ($RequireWorkflow.Length -gt 0 -and [string]::IsNullOrWhiteSpace($RequireWorkflow)) {
            throw "Invoke-CiGateParser: -RequireWorkflow must be '' or a workflow name; a whitespace-only value is not accepted."
        }

        $requireWorkflowGuard = $RequireWorkflow.Length -gt 0

        # Empty or null check set. Without the guard it is vacuously satisfied (no
        # check can fail or be in progress); with the guard no passing check from
        # the named workflow was observed, so the gate stays 'pending'.
        if ($null -eq $Checks -or $Checks.Count -eq 0) {
            if ($requireWorkflowGuard) {
                return 'pending'
            }
            return 'success'
        }

        # Track whether any check is still in progress so we can defer the 'pending'
        # decision until after confirming nothing failed (failure outranks pending).
        $anyPending = $false

        # Track whether a passing check from the named workflow was observed.
        $requiredWorkflowPassed = $false
```

B7 (the `'pass'` case, line 158; copy the exact spacing of that line from the file as the old text). Old (whitespace between `{ }` and `#` as in the file):

```text
                'pass' { }                        # passing check contributes to success; no state change
```

New:

```text
                'pass' {
                    # Under the guard, record a pass from the named workflow. The
                    # property test keeps an element without `workflow` from
                    # throwing under Set-StrictMode; such an element never matches.
                    if ($requireWorkflowGuard -and
                        ($check.PSObject.Properties.Name -contains 'workflow') -and
                        ([string]$check.workflow -ceq $RequireWorkflow)) {
                        $requiredWorkflowPassed = $true
                    }
                }
```

B8 (trailing presence rule). Old:

```text
        if ($anyPending) {
            return 'pending'
        }

        return 'success'
    }
```

New:

```text
        if ($anyPending) {
            return 'pending'
        }

        # With the guard, nothing failed or is pending, but success also requires
        # at least one passing check from the named workflow.
        if ($requireWorkflowGuard -and -not $requiredWorkflowPassed) {
            return 'pending'
        }

        return 'success'
    }
```

B9 (`Invoke-CiGateParser` help). Old:

```text
    .PARAMETER NowProvider
        See script-level parameter of the same name.
    .PARAMETER AsJson
```

New:

```text
    .PARAMETER NowProvider
        See script-level parameter of the same name.
    .PARAMETER RequireWorkflow
        See script-level parameter of the same name.
    .PARAMETER AsJson
```

B10 (`Invoke-CiGateParser` parameter; the old text is the twelve-space-indented block ending in the eight-space `)`). Old:

```text
            [ScriptBlock]$NowProvider = { (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ') },

            [Parameter(Mandatory = $false)]
            [switch]$AsJson
        )
```

New:

```text
            [ScriptBlock]$NowProvider = { (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ') },

            [Parameter(Mandatory = $false)]
            [string]$RequireWorkflow = '',

            [Parameter(Mandatory = $false)]
            [switch]$AsJson
        )
```

B11 (forwarding, line 291). Old: `        $conclusion = Get-CiGateConclusion -Checks $checks` New: `        $conclusion = Get-CiGateConclusion -Checks $checks -RequireWorkflow $RequireWorkflow`

B12 (`process` block). Old:

```text
            -NowProvider $NowProvider `
            -AsJson:$AsJson
```

New:

```text
            -NowProvider $NowProvider `
            -RequireWorkflow $RequireWorkflow `
            -AsJson:$AsJson
```

## Appendix C — Pester Hunks for `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`

C1 (line 91). Old: `        It "returns success for an empty required-check array (vacuous satisfaction)" {` New: `        It "returns success for an empty required-check array without -RequireWorkflow (vacuous satisfaction)" {`

C2 (insert two contexts before the closing brace of the `Describe`). Old:

```text
    Context "Get-CiGateConclusion pure helper" {
        It "returns success for a null check set" {
            Get-CiGateConclusion -Checks $null | Should -Be 'success'
        }
    }
}
```

New:

```powershell
    Context "Get-CiGateConclusion pure helper" {
        It "returns success for a null check set" {
            Get-CiGateConclusion -Checks $null | Should -Be 'success'
        }
    }

    Context "-RequireWorkflow parameter surface" {
        BeforeAll {
            # Parse the production script once. The AST exposes every declared
            # parameter, its default value, and the comment-based help of the
            # script and of each function without executing the script.
            $script:scriptAst = [System.Management.Automation.Language.Parser]::ParseFile($script:scriptPath, [ref]$null, [ref]$null)
            $isFunctionDefinition = { param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }
            $script:functionAsts = @($script:scriptAst.FindAll($isFunctionDefinition, $true))
        }

        It "declares -RequireWorkflow as a string defaulting to '' on the script, Invoke-CiGateParser, and Get-CiGateConclusion" {
            # Arrange: the script param block and the param blocks of both functions.
            $paramBlocks = @(
                $script:scriptAst.ParamBlock
                ($script:functionAsts | Where-Object { $_.Name -eq 'Invoke-CiGateParser' }).Body.ParamBlock
                ($script:functionAsts | Where-Object { $_.Name -eq 'Get-CiGateConclusion' }).Body.ParamBlock
            )
            $paramBlocks.Count | Should -Be 3

            foreach ($paramBlock in $paramBlocks) {
                # Act: select the RequireWorkflow declaration of this surface.
                $parameter = @($paramBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'RequireWorkflow' })

                # Assert: declared once, typed [string], defaulting to ''.
                $parameter.Count | Should -Be 1 -Because 'each surface declares -RequireWorkflow exactly once'
                $parameter[0].StaticType | Should -Be ([string])
                $parameter[0].DefaultValue.Extent.Text | Should -Be "''"
            }
        }

        It "documents .PARAMETER RequireWorkflow in the help of the script, Invoke-CiGateParser, and Get-CiGateConclusion" {
            # Arrange: the comment-based help of the script and of both functions.
            $helpBlocks = @(
                $script:scriptAst.GetHelpContent()
                ($script:functionAsts | Where-Object { $_.Name -eq 'Invoke-CiGateParser' }).GetHelpContent()
                ($script:functionAsts | Where-Object { $_.Name -eq 'Get-CiGateConclusion' }).GetHelpContent()
            )
            $helpBlocks.Count | Should -Be 3

            foreach ($help in $helpBlocks) {
                # Assert: each help block documents the RequireWorkflow parameter.
                @($help.Parameters.Keys) | Should -Contain 'RequireWorkflow'
            }
        }
    }

    Context "-RequireWorkflow (epic-child guard)" {
        BeforeAll {
            # Runs the full parser over an in-memory check set with the guard set
            # to CI and returns only the derived conclusion.
            function script:Get-GuardedConclusion {
                param([object[]]$Checks)
                $json = script:ConvertChecksToJson -Checks $Checks
                $result = Invoke-CiGateParser -ChecksJson $json -HeadSha 'sha1' -RequireWorkflow 'CI' -NowProvider $script:fixedClock
                return $result.conclusion
            }
        }

        It "returns pending for an empty check array with -RequireWorkflow CI" {
            # Act: no check is observed at all.
            $result = Invoke-CiGateParser -ChecksJson '[]' -HeadSha 'sha1' -RequireWorkflow 'CI' -NowProvider $script:fixedClock

            # Assert: an empty set never satisfies the guard.
            $result.conclusion | Should -Be 'pending'
        }

        It "returns pending for a null check set with -RequireWorkflow CI" {
            # Act / Assert: the pure helper treats $null like an empty set.
            Get-CiGateConclusion -Checks $null -RequireWorkflow 'CI' | Should -Be 'pending'
        }

        It "returns pending when only non-CI checks pass" {
            # Arrange: passing checks from other workflows only.
            $checks = @(
                @{ name = 'publish'; bucket = 'pass'; workflow = 'Publish Extension' },
                @{ name = 'verify'; bucket = 'pass'; workflow = 'Verify Published Releases' }
            )

            # Act / Assert
            script:Get-GuardedConclusion -Checks $checks | Should -Be 'pending'
        }

        It "returns success when a CI check passes" {
            # Arrange
            $checks = @(@{ name = 'build'; bucket = 'pass'; workflow = 'CI' })

            # Act / Assert
            script:Get-GuardedConclusion -Checks $checks | Should -Be 'success'
        }

        It "returns success when a CI check and a non-CI check both pass" {
            # Arrange
            $checks = @(
                @{ name = 'build'; bucket = 'pass'; workflow = 'CI' },
                @{ name = 'publish'; bucket = 'pass'; workflow = 'Publish Extension' }
            )

            # Act / Assert
            script:Get-GuardedConclusion -Checks $checks | Should -Be 'success'
        }

        It "returns failure when a CI check failed" {
            # Arrange
            $checks = @(@{ name = 'build'; bucket = 'fail'; workflow = 'CI' })

            # Act / Assert
            script:Get-GuardedConclusion -Checks $checks | Should -Be 'failure'
        }

        It "returns failure when a CI check was cancelled" {
            # Arrange
            $checks = @(@{ name = 'build'; bucket = 'cancel'; workflow = 'CI' })

            # Act / Assert
            script:Get-GuardedConclusion -Checks $checks | Should -Be 'failure'
        }

        It "returns failure when a CI check passes and a non-CI check failed" {
            # Arrange: a failing non-CI check fails the gate on an epic child.
            $checks = @(
                @{ name = 'build'; bucket = 'pass'; workflow = 'CI' },
                @{ name = 'publish'; bucket = 'fail'; workflow = 'Publish Extension' }
            )

            # Act / Assert
            script:Get-GuardedConclusion -Checks $checks | Should -Be 'failure'
        }

        It "returns pending when a CI check is pending" {
            # Arrange
            $checks = @(@{ name = 'build'; bucket = 'pending'; workflow = 'CI' })

            # Act / Assert
            script:Get-GuardedConclusion -Checks $checks | Should -Be 'pending'
        }

        It "returns pending when a CI check passes and a non-CI check is pending" {
            # Arrange
            $checks = @(
                @{ name = 'build'; bucket = 'pass'; workflow = 'CI' },
                @{ name = 'publish'; bucket = 'pending'; workflow = 'Publish Extension' }
            )

            # Act / Assert
            script:Get-GuardedConclusion -Checks $checks | Should -Be 'pending'
        }

        It "returns failure when a CI check is pending and another check failed" {
            # Arrange: failure outranks pending regardless of order.
            $checks = @(
                @{ name = 'build'; bucket = 'pending'; workflow = 'CI' },
                @{ name = 'publish'; bucket = 'fail'; workflow = 'Publish Extension' }
            )

            # Act / Assert
            script:Get-GuardedConclusion -Checks $checks | Should -Be 'failure'
        }

        It "returns pending when the only CI checks are skipping" {
            # Arrange: a skipped CI run is not an observed success.
            $checks = @(
                @{ name = 'build'; bucket = 'skipping'; workflow = 'CI' },
                @{ name = 'test'; bucket = 'skipping'; workflow = 'CI' }
            )

            # Act / Assert
            script:Get-GuardedConclusion -Checks $checks | Should -Be 'pending'
        }

        It "does not match a lowercase ci workflow name (case-sensitive)" {
            # Arrange
            $checks = @(@{ name = 'build'; bucket = 'pass'; workflow = 'ci' })

            # Act / Assert
            script:Get-GuardedConclusion -Checks $checks | Should -Be 'pending'
        }

        It "treats an element without a workflow property as non-matching without throwing" {
            # Arrange: a status context without a workflow property, alone and beside a CI pass.
            $statusOnly = @(@{ name = 'status-context'; bucket = 'pass' })
            $withCi = @(
                @{ name = 'status-context'; bucket = 'pass' },
                @{ name = 'build'; bucket = 'pass'; workflow = 'CI' }
            )

            # Act / Assert: the element never matches and never throws.
            script:Get-GuardedConclusion -Checks $statusOnly | Should -Be 'pending'
            script:Get-GuardedConclusion -Checks $withCi | Should -Be 'success'
        }

        It "throws an error naming -RequireWorkflow for a whitespace-only value" {
            # Act / Assert: a whitespace-only name is rejected instead of disabling the guard.
            { Get-CiGateConclusion -Checks @() -RequireWorkflow '   ' } |
                Should -Throw -ExpectedMessage '*-RequireWorkflow*whitespace-only*'
        }

        It "forwards -RequireWorkflow from the script entry point" {
            # Act: run the script file so its process block forwards the parameter.
            $result = & $script:scriptPath -ChecksJson '[]' -HeadSha 'x' -RequireWorkflow 'CI' -NowProvider $script:fixedClock

            # Assert
            $result.conclusion | Should -Be 'pending'
        }
    }
}
```

Counts: C2 adds 18 `It` blocks (2 surface, 16 guard). Before the fix all 18 fail (no `-RequireWorkflow` parameter exists; the whitespace test fails because the binding error text contains neither "-RequireWorkflow" with its hyphen nor "whitespace-only"); the 15 pre-existing tests pass. After the fix all 33 pass.

## Appendix D — `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` (complete file)

```python
"""Regression contract for issues #841 and #795.

Issue #841 pins three rule-text changes. In both copies of the orchestrate
skill, S9 step 3 passes ``-RequireWorkflow CI`` when ``epic_mode`` is true,
every observed check counts on an epic child, and the conclusion is described
over the queried checks (CR-1 wiring and CR-4). In every feature-review-workflow
copy that defines ``modified-workflow-needs-green-run``, the qualifying run has
a satisfiable predecessor-head alternative (PA-N9). Issue #795 pins that each
``.agents``-side copy citing the rule names a file that defines it.

Every fragment search runs over whitespace-normalized text, so a reflowed
sentence is still found. The module reads repository files only: it creates no
file, starts no process, and consults no external service.
"""

from __future__ import annotations

import re
from pathlib import Path

import pytest

# This file lives at tests/scripts/dev_tools/, three parents below the repo root.
REPO_ROOT = Path(__file__).resolve().parents[3]

CLAUDE_BUNDLE = "extensions/drm-copilot/resources/claude-customizations/"
CODEX_BUNDLE = "extensions/drm-copilot/resources/codex-and-agents-customizations/"

CLAUDE_ORCHESTRATE = ".claude/skills/orchestrate/SKILL.md"
CLAUDE_REVIEW = ".claude/skills/feature-review-workflow/SKILL.md"
AGENTS_REVIEW = ".agents/skills/feature-review-workflow/SKILL.md"
AGENTS_CI_WORKFLOWS = ".agents/skills/ci-workflows/SKILL.md"
AGENTS_BENCHMARK_BASELINES = ".agents/skills/benchmark-baselines/SKILL.md"

ORCHESTRATE_COPIES = (CLAUDE_ORCHESTRATE, CLAUDE_BUNDLE + CLAUDE_ORCHESTRATE)
AGENTS_REVIEW_COPIES = (AGENTS_REVIEW, CODEX_BUNDLE + AGENTS_REVIEW)
REVIEW_COPIES = (CLAUDE_REVIEW, CLAUDE_BUNDLE + CLAUDE_REVIEW, *AGENTS_REVIEW_COPIES)
CITING_COPIES = (
    AGENTS_CI_WORKFLOWS,
    AGENTS_BENCHMARK_BASELINES,
    CODEX_BUNDLE + AGENTS_CI_WORKFLOWS,
    CODEX_BUNDLE + AGENTS_BENCHMARK_BASELINES,
)

RULE_NAME = "modified-workflow-needs-green-run"
RULE_HEADING = "### " + RULE_NAME
S9_HEADING = "## Step S9 — CI Green Gate"
SCHEMA_HEADING = "## Checkpoint Schema — CI Gate Fields"
WORK_MODE_HEADING = "### Work-mode acceptance-criteria contract"
POLICY_RULES_HEADING = "## Policy Rules"
ORDERED_PROCEDURE_HEADING = "## Ordered Procedure"
PARSER_COMMAND_START = (
    "`pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -ChecksJson"
)
PARSER_COMMAND_END = "-HeadSha <head-sha>`"

S9_EPIC_CHILD_FRAGMENTS = (
    "-RequireWorkflow CI",
    "Every check returned by the unfiltered query counts",
    "a failing or cancelled non-`CI` check fails the gate",
    "at least one passing `CI` check",
    "`no checks reported`",
    "`-ChecksJson '[]'`",
    "is never treated as green",
    "derives `ci_gate.conclusion` over the queried checks",
)
SCHEMA_FRAGMENTS = ("the PR head SHA that the queried checks were observed against",)
SUPERSEDED_ORCHESTRATE_FRAGMENTS = (
    "derives `ci_gate.conclusion` as `success` when all required checks pass",
    "that the required checks were observed against",
)
QUALIFYING_RUN_FRAGMENTS = (
    "its head SHA equals the current branch head",
    "git merge-base --is-ancestor",
    '":!<feature-folder>"',
    "ci_gate.head_sha",
    "cannot name the SHA of the commit that contains it",
)
SHA_EXACT_DEFINITION = (
    "a workflow run whose head SHA matches the current branch head and whose"
    " conclusion is success"
)
AGENTS_RULE_FRAGMENTS = (
    "`.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`",
    "A green `workflow_dispatch` run against the branch head also satisfies"
    " the rule",
    "record a Blocking finding classified `awaiting_ci`",
    "CI Green Gate (S9)",
)
CITATION_PATTERN = re.compile(
    "`" + re.escape(RULE_NAME) + r"` \(see `(?P<path>[^`]+)`\)"
)


def read_copy(relative_path: str) -> str:
    """Return the UTF-8 text of one committed copy; reads disk, writes nothing."""

    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def normalize_whitespace(text: str) -> str:
    """Collapse every whitespace run, including line breaks, to one space."""

    return " ".join(text.split())


def missing_fragments(text: str, fragments: tuple[str, ...]) -> list[str]:
    """Return the fragments absent from ``text`` after whitespace normalization."""

    normalized = normalize_whitespace(text)
    return [item for item in fragments if normalize_whitespace(item) not in normalized]


def section(text: str, heading: str) -> str:
    """Return ``heading`` and the lines after it up to the next ``## `` heading."""

    lines = text.splitlines()
    start = lines.index(heading)
    kept = [lines[start]]
    # Collect lines until the next level-two heading; ``###`` does not end it.
    for line in lines[start + 1 :]:
        if line.startswith("## "):
            break
        kept.append(line)
    return "\n".join(kept)


def cited_rule_paths(citing_text: str) -> list[str]:
    """Return every path cited for the rule in the form ``(see `<path>`)``."""

    normalized = normalize_whitespace(citing_text)
    return [match.group("path") for match in CITATION_PATTERN.finditer(normalized)]


def unresolved_citations(citing_text: str, documents: dict[str, str]) -> list[str]:
    """Return the cited paths whose document lacks the rule heading.

    ``documents`` maps a cited path to that document's text; a cited path that
    is absent from the mapping is reported as unresolved.
    """

    unresolved: list[str] = []
    for cited_path in cited_rule_paths(citing_text):
        document = documents.get(cited_path, "")
        if RULE_HEADING not in document.splitlines():
            unresolved.append(cited_path)
    return unresolved


def bundle_root(relative_path: str) -> str:
    """Return the publishing root that a copy's citations resolve against."""

    return CODEX_BUNDLE if relative_path.startswith(CODEX_BUNDLE) else ""


@pytest.mark.parametrize("relative_path", ORCHESTRATE_COPIES)
def test_orchestrate_s9_states_epic_child_guard(relative_path: str) -> None:
    """S9 states the -RequireWorkflow CI guard and how epic-child checks count."""
    # Arrange
    s9_text = section(read_copy(relative_path), S9_HEADING)

    # Act
    missing = missing_fragments(s9_text, S9_EPIC_CHILD_FRAGMENTS)

    # Assert
    assert missing == [], f"{relative_path} S9 is missing: {missing}"


@pytest.mark.parametrize("relative_path", ORCHESTRATE_COPIES)
def test_orchestrate_schema_head_sha_names_queried_checks(relative_path: str) -> None:
    """The ci_gate.head_sha schema bullet refers to the queried checks."""
    # Arrange
    schema_text = section(read_copy(relative_path), SCHEMA_HEADING)

    # Act
    missing = missing_fragments(schema_text, SCHEMA_FRAGMENTS)

    # Assert
    assert missing == [], f"{relative_path} schema is missing: {missing}"


@pytest.mark.parametrize("relative_path", ORCHESTRATE_COPIES)
def test_orchestrate_drops_required_check_wording(relative_path: str) -> None:
    """The superseded required-check wording of step 3 and the schema is gone."""
    # Arrange
    normalized = normalize_whitespace(read_copy(relative_path))

    # Act
    present = [item for item in SUPERSEDED_ORCHESTRATE_FRAGMENTS if item in normalized]

    # Assert
    assert present == [], f"{relative_path} still carries: {present}"


@pytest.mark.parametrize("relative_path", ORCHESTRATE_COPIES)
def test_orchestrate_parser_command_stays_on_one_line(relative_path: str) -> None:
    """The S9 step 3 parser command keeps its path and -HeadSha on one line."""
    # Arrange
    lines = section(read_copy(relative_path), S9_HEADING).splitlines()

    # Act: keep the lines that carry the whole command span.
    command_lines = [
        line
        for line in lines
        if PARSER_COMMAND_START in line and PARSER_COMMAND_END in line
    ]

    # Assert
    assert len(command_lines) == 1, f"{relative_path} command lines: {command_lines}"


@pytest.mark.parametrize("relative_path", REVIEW_COPIES)
def test_review_rule_defines_satisfiable_qualifying_run(relative_path: str) -> None:
    """The rule defines the head-SHA and predecessor-head alternatives (PA-N9)."""
    # Arrange
    rule_text = section(read_copy(relative_path), RULE_HEADING)

    # Act
    missing = missing_fragments(rule_text, QUALIFYING_RUN_FRAGMENTS)

    # Assert
    assert missing == [], f"{relative_path} rule is missing: {missing}"


@pytest.mark.parametrize("relative_path", REVIEW_COPIES)
def test_review_rule_drops_sha_exact_definition(relative_path: str) -> None:
    """No copy keeps the SHA-exact sentence as the qualifying-run definition."""
    # Arrange
    normalized = normalize_whitespace(read_copy(relative_path))

    # Act
    still_sha_exact = SHA_EXACT_DEFINITION in normalized

    # Assert
    assert not still_sha_exact, f"{relative_path} keeps the SHA-exact definition"


@pytest.mark.parametrize("relative_path", AGENTS_REVIEW_COPIES)
def test_agents_review_rule_sits_before_ordered_procedure(relative_path: str) -> None:
    """The .agents rule section sits between the work-mode contract and procedure."""
    # Arrange
    lines = read_copy(relative_path).splitlines()
    headings = (
        WORK_MODE_HEADING,
        POLICY_RULES_HEADING,
        RULE_HEADING,
        ORDERED_PROCEDURE_HEADING,
    )

    # Act: -1 marks a heading that is absent.
    positions = [lines.index(item) if item in lines else -1 for item in headings]

    # Assert
    assert -1 not in positions, f"{relative_path} heading positions: {positions}"
    assert positions == sorted(positions), f"{relative_path} order: {positions}"


@pytest.mark.parametrize("relative_path", AGENTS_REVIEW_COPIES)
def test_agents_review_rule_carries_codex_bullets(relative_path: str) -> None:
    """The .agents rule carries the trigger paths and the Codex gate bullets."""
    # Arrange
    rule_text = section(read_copy(relative_path), RULE_HEADING)

    # Act
    missing = missing_fragments(rule_text, AGENTS_RULE_FRAGMENTS)

    # Assert
    assert missing == [], f"{relative_path} rule is missing: {missing}"


@pytest.mark.parametrize("relative_path", CITING_COPIES)
def test_agents_citing_copy_resolves_rule(relative_path: str) -> None:
    """Each .agents-side citer names a file that defines the rule heading (#795)."""
    # Arrange: citations in a bundle copy resolve against that bundle's root.
    citing_text = read_copy(relative_path)
    root = bundle_root(relative_path)
    cited = cited_rule_paths(citing_text)
    documents = {path: read_copy(root + path) for path in cited}

    # Act
    unresolved = unresolved_citations(citing_text, documents)

    # Assert
    assert cited == [AGENTS_REVIEW], f"{relative_path} cites: {cited}"
    assert unresolved == [], f"{relative_path} cites an undefined rule: {unresolved}"


def test_rule_resolution_reports_missing_heading() -> None:
    """A cited document that lacks the rule heading is reported as unresolved."""
    # Arrange: an in-memory citer and a cited document without the heading.
    citing_text = f"- The rule `{RULE_NAME}` (see `{AGENTS_REVIEW}`) applies."
    documents = {AGENTS_REVIEW: "## Policy Rules\n\n### another-rule\n"}

    # Act
    unresolved = unresolved_citations(citing_text, documents)

    # Assert
    assert unresolved == [AGENTS_REVIEW]


def test_rule_resolution_accepts_defined_heading() -> None:
    """A cited document that defines the rule heading resolves the citation."""
    # Arrange
    citing_text = f"- The rule `{RULE_NAME}` (see `{AGENTS_REVIEW}`) applies."
    documents = {AGENTS_REVIEW: f"## Policy Rules\n\n{RULE_HEADING}\n"}

    # Act
    unresolved = unresolved_citations(citing_text, documents)

    # Assert
    assert cited_rule_paths(citing_text) == [AGENTS_REVIEW]
    assert unresolved == []
```

Node count: 26 (four orchestrate tests over 2 copies, two review tests over 4 copies, two `.agents` tests over 2 copies, one citer test over 4 copies, two synthetic tests). Stage results derived from the current text: before any fix 20 failed and 6 passed; after Phase 3, 14 failed and 12 passed; after Phase 4, 10 failed and 16 passed; after Phase 5, 26 passed.

## Appendix E — Orchestrate Hunks for `.claude/skills/orchestrate/SKILL.md`

E1 (step 2 epic-child paragraph, line 291). Old: "every observed `CI` check must succeed before `ci_gate.conclusion` is accepted as `success`." New (the old sentence followed by three sentences on the same line):

```text
every observed `CI` check must succeed before `ci_gate.conclusion` is accepted as `success`. Every check returned by the unfiltered query counts: a failing or cancelled non-`CI` check fails the gate, and a pending one keeps it pending. Step 3 enforces this rule by passing `-RequireWorkflow CI` to the parser, which never returns `success` until at least one passing `CI` check is observed. When `gh pr checks` fails with a `no checks reported` error on the child branch, step 3 runs the parser with `-ChecksJson '[]'`; that error is never treated as green, and the parser returns `pending` for it.
```

E2 (step 3, line 293; replace the whole line, keeping it one line). Old:

```text
3. Parse the JSON by running `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -ChecksJson <checks-json> -HeadSha <head-sha>`, which emits the `ci_gate` object defined below and derives `ci_gate.conclusion` as `success` when all required checks pass, `failure` when any required check failed, and `pending` when any required check is still in progress.
```

New:

```text
3. Parse the JSON by running `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -ChecksJson <checks-json> -HeadSha <head-sha>`, appending `-RequireWorkflow CI` when `epic_mode` is `true`. The parser emits the `ci_gate` object defined below and derives `ci_gate.conclusion` over the queried checks (the required checks on a non-epic PR; every observed check on an epic child): `success` when every queried check passed or was skipped, `failure` when any queried check failed or was cancelled, and `pending` when any queried check is still in progress. With `-RequireWorkflow CI`, the parser returns `pending` instead of `success` until at least one check whose `workflow` is `CI` has passed.
```

E3 (schema bullet, line 307). Old: "the PR head SHA that the required checks were observed against" New: "the PR head SHA that the queried checks were observed against"

Lines 289, 294-298, and 342 are not edited.

## Appendix F — Feature-Review Hunks

F1 (`.claude/skills/feature-review-workflow/SKILL.md`, line 73; replace the whole line). Old:

```text
- "Green workflow run against the branch head" means a workflow run whose head SHA matches the current branch head and whose conclusion is success for the affected workflow.
```

New (one line):

```text
- "Green workflow run against the branch head" means a run of the affected workflow whose conclusion is success and which satisfies either (a) or (b): (a) its head SHA equals the current branch head; or (b) all three predecessor-head conditions hold: (1) the run's head SHA is an ancestor of, or equal to, the current branch head and contains the latest commit that changes any path outside the active feature folder (`git merge-base --is-ancestor <commit> <run-sha>`); (2) every commit after the run's head SHA changes only paths inside the active feature folder (`git log <run-sha>..HEAD -- . ":!<feature-folder>"` returns no commits); (3) the policy audit states that the orchestrator's S9 CI green gate remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head before DONE. Condition (b) exists because an in-repo evidence artifact cannot name the SHA of the commit that contains it.
```

F2 (`.agents/skills/feature-review-workflow/SKILL.md`, insertion before `## Ordered Procedure`). Old (the last work-mode line, the blank line, and the procedure heading):

```text
  - if `minor-audit` is selected and `issue.md` lacks `## Acceptance Criteria`, require remediation

## Ordered Procedure
```

New:

```text
  - if `minor-audit` is selected and `issue.md` lacks `## Acceptance Criteria`, require remediation

## Policy Rules

### modified-workflow-needs-green-run

If the branch diff modifies any path matching `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`, the policy audit emits a Blocking finding unless evidence of a green workflow run against the branch head is present in the remediation inputs.

- The rule provides a second, independent line of defense for CI-gate-modifying features, separate from and prior to the orchestrator CI Green Gate (S9).
- "Green workflow run against the branch head" means a run of the affected workflow whose conclusion is success and which satisfies either (a) or (b): (a) its head SHA equals the current branch head; or (b) all three predecessor-head conditions hold: (1) the run's head SHA is an ancestor of, or equal to, the current branch head and contains the latest commit that changes any path outside the active feature folder (`git merge-base --is-ancestor <commit> <run-sha>`); (2) every commit after the run's head SHA changes only paths inside the active feature folder (`git log <run-sha>..HEAD -- . ":!<feature-folder>"` returns no commits); (3) the policy audit states that the orchestrator CI Green Gate (S9) remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head before DONE. Condition (b) exists because an in-repo evidence artifact cannot name the SHA of the commit that contains it.
- A green `workflow_dispatch` run against the branch head also satisfies the rule, not only a PR-context run. This mitigates the chicken-and-egg case where a feature must land its CI gate before the gate can run in PR context (see spec.md Risks & Mitigations).
- When the rule fires and no qualifying green-run evidence is present, record a Blocking finding classified `awaiting_ci` (the remediation inputs carry `Remediability: awaiting_ci` and a `Remediability-Evidence:` line naming the awaited workflow) and route it to the wait path (`AWAITING_CI` when no other class is present) instead of the remediation handoff.

## Ordered Procedure
```

The trigger sentence and the last two bullets are copied verbatim from `.claude/skills/feature-review-workflow/SKILL.md` lines 70, 74, and 75.

## Appendix G — Fixed Path Lists and Commands

G1 — mirror pairs for A4 (primary, then mirror):

```text
.claude/lib/ci-gate/Invoke-CiGateParser.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1 .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md .claude/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md .agents/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md
```

G2 — contract-suite command (P0-T14, P6-T9):

```text
poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py
```

G3 — protected-path diff (P6-T15), anchored to `origin/main`:

```text
git diff --exit-code origin/main...HEAD -- .claude/skills/epic-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md .agents/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md .claude/rules extensions/drm-copilot/resources/claude-customizations/.claude/rules .github/instructions .github/workflows .claude/agents/orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json .github/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py
```
