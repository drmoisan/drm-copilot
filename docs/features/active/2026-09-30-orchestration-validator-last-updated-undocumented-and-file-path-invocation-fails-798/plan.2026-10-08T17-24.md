# orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails (Plan)

- **Issue:** #798
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T20-05 (preflight revision round 3: deltas R2-D1 through R2-D4 and the optional F2 approval-record note applied in place)
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug
- **Branch:** `bug/orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798`
- **Languages in scope:** Python (one production line change plus two new pytest modules), Markdown (three `.claude/` files and their three bundled mirrors). No TypeScript, PowerShell, or C# source changes.
- **Requirements source (sole AC source):** `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md`, section `## Acceptance Criteria` (21 checkbox items, numbered AC-1 through AC-21 in document order by this plan). Decisions D1 through D6 of the same file are binding design input.
- **Design input (not a requirements source):** `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/research/research.2026-10-08T17-28.md`. Every citation this plan takes from it was re-derived against the worktree at planning time.

**Mode note (full-bug):** `spec.md` is required and present; `user-story.md` is not required and is absent by design. The full QA loop applies.

**Fail-closed evidence rule:** Python policy requires coverage. Baseline and final-QC coverage tasks record numeric line and branch values for `scripts/dev_tools/validate_orchestration_artifacts.py` and for the `scripts.dev_tools` total, plus a changed-line check. If any required baseline artifact, final-QC artifact, or numeric coverage value is missing, the audit verdict is BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Every evidence-producing task names its artifact path. A task is not checked off until its artifact exists and carries every required field. Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. An artifact whose expected exit code is not 0 also carries `ExpectedExitCode:`. The top-level `EXIT_CODE:` of a multi-command artifact is the exit code of the last command in the task's Commands list, greps included. Every other command's exit code and printed value are recorded inside `Output Summary:` in command order. No planned command task may record `EXIT_CODE: SKIPPED`; the only non-execution outcome is the explicitly authorized `NOT-TRIGGERED` branch of P3-T3.

## Files Written

Every repository file this plan writes, one per line. Items marked conditional are written only under the stated condition.

- `scripts/dev_tools/validate_orchestration_artifacts.py`
- `.claude/rules/orchestrator-state.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`
- `.claude/skills/orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
- `.claude/agents/orchestrator.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md`
- `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py`
- `tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`
- `pyproject.toml` (conditional: only under fallback F2 of P3-T3, and only with a recorded user approval)
- `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` (AC checkbox state only, Phase 7)
- `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/plan.2026-10-08T17-24.md` (task checkbox state only)
- `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/evidence/` (evidence artifacts; each evidence-producing task names its file)

Tool outputs that are not repository files (gitignored by `/artifacts` in `.gitignore` line 6): `artifacts/python/coverage-798.json` and the `addopts` LCOV file `artifacts/python/lcov.info`. The Pester runner script of P0-T14 and P6-T6 is written to the executor's session scratchpad, outside the repository, and is not a repository file.

Files that must not change (spec "Files to Write"): `scripts/dev_tools/validate_orchestrator_state.py`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`, `.claude/lib/orchestrator-state/OrchestratorState.psm1`, `.claude/hooks/validate-orchestrator-output.ps1`. Also out of scope: every `.agents/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/` file, the orchestrate skill's `## Step S9 — CI Green Gate` section (concurrent issue #841), and the rule's `## Issue-Adoption Scope and Backward Compatibility` and `## Invariants (issue_adoption object)` sections (concurrent issue #849).

## Terms used in every task

- FEATURE means `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798`. Evidence is written only under FEATURE/evidence/baseline/, FEATURE/evidence/regression-testing/, FEATURE/evidence/qa-gates/, and FEATURE/evidence/other/. No `artifacts/` path is an evidence location. The caller supplied no non-canonical evidence path, so no override was recorded.
- TS means the execution time of the task in `yyyy-MM-ddTHH-mm` form, read from the host clock, never composed.
- MERGE_BASE means the commit printed by `git merge-base origin/main HEAD` in P0-T3. Every scope diff is anchored to it.
- DISPATCHER means `scripts/dev_tools/validate_orchestration_artifacts.py`.
- INVOCATION-MODULE means `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py` (created by P1-T1; content in Appendix A).
- DOCS-MODULE means `tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py` (created by P1-T2; content in Appendix B).
- RULE, SKILL, and AGENT mean `.claude/rules/orchestrator-state.md`, `.claude/skills/orchestrate/SKILL.md`, and `.claude/agents/orchestrator.md`. Their MIRRORS are the same relative paths under `extensions/drm-copilot/resources/claude-customizations/`.
- EXISTING-SET means these 16 existing pytest files, in this order: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`, `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py`, `tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py`, `tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py`, `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`, `tests/scripts/dev_tools/test_validate_orchestration_artifacts_codex_topology_cli.py`, `tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py`, `tests/scripts/dev_tools/test_validate_orchestration_artifacts_model_routing.py`, `tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py`, `tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py`, `tests/scripts/dev_tools/test_validate_orchestration_artifacts_pr_creation_readiness.py`, `tests/scripts/dev_tools/test_validate_orchestration_artifacts_state_shape.py`, `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py`, `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`, `tests/scripts/dev_tools/test_claude_rules_frontmatter.py`. Selection basis: spec "Existing tests that must stay green" (first 13; the eight `test_validate_orchestration_artifacts*.py` modules that exist at planning time are named individually so the new INVOCATION-MODULE is not counted), plus three modules that read AGENT or RULE text (`Grep` of `tests/scripts/dev_tools` for those paths).
- PESTER-SET means `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1` (reads the SKILL `## Checkpoint Handling` and `## Issue Number Consistency` sections at lines 78 and 118-157) and `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1` (reads SKILL and AGENT).
- KL-510 means the known local-only failure of `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` caused by gitignored machine-local state (issue #510). A failure is classified KL-510 only when its sole assertion message begins with the literal "Repo file missing from bundle:" and the named path satisfies `git check-ignore -q <path>` with exit 0. Any other failure of that test is a real failure.
- COVERAGE-RUN means `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage-798.json`. The dotted `--cov=scripts.dev_tools` form collects data for every module under `scripts/dev_tools/` (rules G1-G4); `--cov-report=term-missing` prints the terminal table (rule G9); the JSON report supplies separate line and branch values, because the terminal table prints one combined `Cover` column.

## Execution constraints

- Every Bash command runs with the #798 worktree root as its working directory. The executor begins every Bash command with a `cd` to that root and records each `Command:` field exactly as written in this plan, without the prefix. Artifacts never record a host path. P0-T1 confirms by branch name that the prefix reaches the #798 worktree.
- File-content checks use `git grep --no-index`, never a bare `grep`, `cat`, `head`, or `tail`, because `.claude/hooks/validate-bash.ps1` denies a command line in which a `cd` segment precedes one of those read commands. `git grep --no-index -c` prints `<path>:<n>` and exits 0 when n is 1 or more, and prints nothing and exits 1 when n is 0. In acceptance text, "prints N" for N of 1 or more means that line ends in `:N`; "prints 0" means empty output with exit 1. `git grep --no-index -n` prints `<path>:<line>:<text>` per match. No command pattern in this plan contains a backtick, because bash double quotes would treat it as command substitution; a `.` stands in for a backtick where a pattern must span one.
- The executor does not commit, stage, or push before Phase 8. Scope checks compare the working tree against MERGE_BASE and pair each name-listing diff with a `git status --porcelain` check.
- Before execution starts, the orchestrator's preparation commit has already committed FEATURE (including this plan, `spec.md`, `issue.md`, and the research folder) together with the promoted lifecycle record `docs/features/potential/promoted/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails.md`. Both are tracked during execution and appear in any name-only diff against MERGE_BASE or `origin/main`; no task assumes they are untracked. Evidence files and checkbox edits the executor adds under FEATURE are new or modified relative to that commit.
- Shared-environment hazard: this worktree has no `.venv` of its own, so `poetry run` uses the main checkout's shared `.venv`, whose editable-install `.pth` entry can name another checkout of this repository and make that checkout's `scripts` package importable. Every real interpreter invocation of DISPATCHER (P0-T7, P6-T10) therefore passes `-S`, which skips site-packages; the DISPATCHER import chain needs only the standard library and the repository's own `scripts` package. INVOCATION-MODULE drops every `sys.path` entry that can supply a regular `scripts` package before each file-path run (PD4).
- Markdown and Python edits are made with the Edit tool, one exact `old_string` to `new_string` replacement per numbered replacement, copying `old_string` from the file as it stands. Replacement text is quoted verbatim in the appendices; the executor does not compose wording. New files are created with the Write tool from the appendix content, with LF line endings.
- Bundle mirrors are produced only by `cp` from the edited repo-local file, never by Write or Edit.
- Pester runs through a one-line runner script, because atomic-executor has no PowerShell tool and the agent-worktree guard denies Bash command text containing `pwsh`. The executor writes the runner with the Write tool to its session scratchpad directory (outside the repository) and invokes it from Bash as `sh <file>`. The runner body is exactly the line quoted in P0-T14. A `Command:` field records that body, never the scratchpad path; `EXIT_CODE:` is the runner's exit code, which equals the Failed count. If a hook or permission rule denies any edit or command, stop and report the denial text. Do not bypass it.
- Edits under `.claude/` may raise a permission prompt; that is expected and is not a reason to change the edit.
- The full COVERAGE-RUN is long; it may run in the background, and the executor waits for the completion notification before reading output.
- Concurrency: issues #841 and #849 edit SKILL, RULE, and their mirrors. This plan edits only RULE `## Required Top-Level Keys` (new) and `## Bare-Module CLI Contract`, SKILL `## Checkpoint Handling` and `## Issue Number Consistency`, and AGENT `## Checkpoint Persistence`. It makes no edit inside SKILL `## Step S9 — CI Green Gate` (#841) or inside RULE `## Issue-Adoption Scope and Backward Compatibility` and `## Invariants (issue_adoption object)` (#849). P6-T12 verifies this mechanically.

## Planner decisions (recorded for audit)

- PD1 - Edit authority for `.claude/rules/orchestrator-state.md`. The policy-compliance-order baseline says not to modify `.claude/rules/`. Spec D1 and D5 (approved scope for issue #798) require the RULE edits. The plan edits that one rule file only, and only with the text quoted in Appendix D. No `.github/instructions/` file is edited.
- PD2 - Bootstrap form. Primary form is spec D5 verbatim (Appendix C1): one comment line and one augmented assignment to `sys.path`, conditional on `not __package__`, plus one blank separator line, so DISPATCHER grows from 495 to 498 lines. `runpy.run_path(..., run_name="__main__")` sets `__package__` to an empty string (the run name has no dot), and the interpreter sets it to `None` for `python <file>`; both are falsy. `-m` and normal import set it to `"scripts.dev_tools"`.
- PD3 - Fallback order. `.claude/rules/python-suppressions.md` does not pre-authorize a file-level E402 ignore and requires non-suppression attempts first. P3-T3 therefore tries F1, a non-suppression form (a `sys.path.extend(...)` call expression statement, which the Ruff E402 exemption also covers per research section 1.6), before F2, the spec D5 fallback (`if not __package__:` block plus a `pyproject.toml` per-file `E402` ignore). F2 runs only when a user approval record exists; otherwise the run halts with `blocked_reason: policy_hold`. This narrows, and does not contradict, spec D5.
- PD4 - Test isolation design. INVOCATION-MODULE isolates import state with a context manager rather than a fixture, so the expected result of `dispatcher.main(...)` in the committed-fixture test is computed outside the isolated state. The context manager rebinds `sys.path` to a filtered copy and restores the original list object; it evicts `scripts` and every `scripts.*` module and restores the original module objects. The committed fixture is passed as an absolute path built from the repository root plus the spec's relative path, so the test does not depend on the working directory. The filter also drops every entry that can supply a regular `scripts` package, because the shared environment's editable-install `.pth` entry can name another checkout.
- PD5 - Additional DOCS-MODULE tests beyond the spec list: `test_required_keys_section_sits_between_foreign_schema_and_scope_sections` (AC-8 placement) and `test_rule_section_names_authority_and_check_semantics` (AC-8 content). They verify AC-8 items that no spec-named test covers.
- PD6 - Toolchain scope and seven-stage mapping. Format, lint, and type-check stages run on the three changed Python files (DISPATCHER, INVOCATION-MODULE, DOCS-MODULE); a repository-wide `black --check .` is not a gate because recent work on `main` (issue #802) recorded a pre-existing repository-wide format failure outside this scope. Architecture-boundary stage: no Python architecture test covers `scripts/dev_tools`; not applicable. Unit stage: INVOCATION-MODULE, DOCS-MODULE, EXISTING-SET, PESTER-SET, and the full COVERAGE-RUN. Contract stage: the bundle-mirror and skill-bundle contract tests inside EXISTING-SET plus the mirror byte-identity check. Integration stage: the real file-path and `-m` invocations of DISPATCHER in P6-T10.
- PD7 - The spec AC items carry no identifiers. This plan numbers them AC-1 through AC-21 in document order; planning-time spec lines are 248, 249, 250, 251, 252, 253, 254, 255, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 272, 273. P0-T1 re-derives the list as AC_LINES.
- PD8 - Append versus prepend (decision: keep append, as spec D5 states). Under a shared environment whose editable-install `.pth` entry names another checkout, an appended root sits after site-packages, so a plain (non `-S`) file-path run imports that checkout's `scripts` modules. A prepend form was considered and rejected. Ruff's E402 `sys.path` exemption covers a statement that is a single call expression on `sys.path`; `sys.path.insert(0, ...)` as such a statement runs unconditionally and would change `sys.path` under `-m`, breaking AC-3, while the conditional prepend forms (an `if` block, a conditional-expression statement, or a slice assignment `sys.path[:0] = ...`) are not single call expressions. The only exempt, inert-under-`-m` prepend form found nests a side-effecting `sys.path.insert` call inside the argument of a no-op `sys.path.extend([])` call; that form conflicts with the simplicity-first rule in `.claude/rules/general-code-change.md` and with spec D5's stated reason for appending (an appended root does not shadow an installed distribution). The plan keeps C1 and its fallbacks unchanged, so DISPATCHER stays at 498 lines (499 under F2) and the pre-fix failure of P2-T1 stays valid. Residual hazard, recorded as a follow-up outside this issue's scope: a file-path run of DISPATCHER in an environment whose editable-install `.pth` names another checkout executes that checkout's modules; candidate remedies are a per-worktree `.venv` or a decision to prepend with an explicit `if` block and an approved E402 per-file ignore. The orchestrator files the follow-up through the normal promotion route; this plan does not write it.

## AC Traceability

| AC | Short form | Implementation | Tests / verification | Check-off |
|---|---|---|---|---|
| AC-1 | file-path `--help` exits 0; fails before fix | P3-T1 | P2-T1, P3-T4, P6-T4 | P7-T1 |
| AC-2 | file-path fixture run equals `main()` | P3-T1 | P3-T4, P6-T4, P6-T10 | P7-T2 |
| AC-3 | `-m` run leaves `sys.path` unchanged | P3-T1 | P2-T1, P6-T4 | P7-T3 |
| AC-4 | root appended exactly once | P3-T1 | P2-T1, P6-T4 | P7-T4 |
| AC-5 | no subprocess/temp files; state restored | P1-T1, P1-T2 | P1-T6, P6-T13 | P7-T5 |
| AC-6 | single conditional bootstrap; <= 500 lines | P3-T1, P3-T3 | P3-T1, P6-T13 | P7-T6 |
| AC-7 | ruff clean; no `noqa`; fallback rules | P3-T1, P3-T3 | P3-T2, P6-T2, P6-T13 | P7-T7 |
| AC-8 | rule section placement and content | P4-T1 | P2-T2, P5-T6, P6-T4 | P7-T8 |
| AC-9 | `last_updated` defined | P4-T1 | P5-T6, P6-T4 | P7-T9 |
| AC-10 | key parity tests pass | P4-T1 | P2-T2, P5-T6, P6-T4 | P7-T10 |
| AC-11 | negative-control parity test | P1-T2 | P2-T2, P6-T4 | P7-T11 |
| AC-12 | skill Checkpoint Handling item | P5-T1 | P5-T6, P6-T6 | P7-T12 |
| AC-13 | skill `issue-num`; S9 unchanged | P5-T2 | P5-T6, P6-T6, P6-T12 | P7-T13 |
| AC-14 | skill has no invocation text | P5-T1, P5-T2 | P6-T5, P6-T13 | P7-T14 |
| AC-15 | agent persona lists every key | P5-T4 | P5-T6, P6-T4 | P7-T15 |
| AC-16 | both dispatcher forms documented | P4-T2 | P5-T6, P6-T4 | P7-T16 |
| AC-17 | issue_adoption sections unchanged | P4-T1, P4-T2 | P6-T12 | P7-T17 |
| AC-18 | mirrors byte-identical; push-down tests | P4-T3, P5-T3, P5-T5 | P6-T5, P6-T11 | P7-T18 |
| AC-19 | no validator behavior change | P3-T1 | P6-T5, P6-T12 | P7-T19 |
| AC-20 | full toolchain; coverage thresholds | P3-T1 | P6-T1 through P6-T10 | P7-T20 |
| AC-21 | each new test module <= 500 lines | P1-T1, P1-T2 | P1-T6, P6-T13 | P7-T21 |

### Phase 0 — Policy Reads and Baseline Capture

- [x] [P0-T1] Verify the full-bug preconditions and the branch for FEATURE (`docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md`, `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/issue.md`), and record FEATURE/evidence/baseline/phase0-mode-check.TS.md.
      Commands: `git branch --show-current`; `ls docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798`; `git grep --no-index -c "^## Acceptance Criteria$" -- docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md`; `git grep --no-index -n "^- \[ \] " -- docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md`; `git grep --no-index -c -F "Work Mode: full-bug" -- docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/issue.md`.
      Acceptance: the branch command prints exactly `bug/orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798`; any other value stops the plan. The listing contains `issue.md`, `spec.md`, and `research`, and does not contain `user-story.md`. The heading grep prints 1. The AC listing prints exactly 21 lines; their line numbers are recorded in order as AC_LINES (planning-time values in PD7); any other count stops the plan. The work-mode grep prints 1.
- [x] [P0-T2] Read the policy files in the required order and record FEATURE/evidence/baseline/phase0-instructions-read.md with `Timestamp:`, `Policy Order:`, and the list of files read, in this order: (1) `CLAUDE.md`, `.claude/rules/tonality.md`; (2) `.claude/rules/general-code-change.md`; (3) `.claude/rules/general-unit-test.md`; (4) `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`; (5) `.claude/rules/quality-tiers.md`, `.claude/rules/plan-acceptance-gates.md`; (6) `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, `.claude/skills/acceptance-criteria-tracking/SKILL.md`.
      Acceptance: the artifact has the three required headers and lists all 10 files in that order.
- [x] [P0-T3] Record MERGE_BASE, the clean pre-edit state of every path this plan writes, and the section anchor lines, and record FEATURE/evidence/baseline/merge-base.TS.md.
      Commands: `git rev-parse HEAD`; `git merge-base origin/main HEAD`; `git diff --name-only MERGE_BASE HEAD -- scripts/dev_tools/validate_orchestration_artifacts.py .claude/rules/orchestrator-state.md .claude/skills/orchestrate/SKILL.md .claude/agents/orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude pyproject.toml tests/scripts/dev_tools`; `git status --porcelain --untracked-files=all -- scripts/dev_tools/validate_orchestration_artifacts.py .claude/rules/orchestrator-state.md .claude/skills/orchestrate/SKILL.md .claude/agents/orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude pyproject.toml tests/scripts/dev_tools`; `git ls-files --error-unmatch -- docs/features/potential/promoted/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails.md docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/issue.md docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/plan.2026-10-08T17-24.md`; `git grep --no-index -n "^## Step S9 " -- .claude/skills/orchestrate/SKILL.md`; `git grep --no-index -n "^## Issue-Adoption Scope" -- .claude/rules/orchestrator-state.md`.
      Acceptance: each of the first two commands prints one 40-character SHA; the second is recorded as MERGE_BASE (substituted literally into the third command). The anchored diff and the status command each print nothing; any output stops the plan, because the section anchors below would then not describe MERGE_BASE. The ls-files command exits 0 and prints the four paths; a non-zero exit stops the plan, because P6-T12, P8-T1, and P8-T2 assume the preparation commit has been made. The ls-files command is not the last command, so the artifact's top-level `EXIT_CODE:` is the issue-adoption grep's exit code, 0. The S9 grep prints one line whose line number is recorded as S9_LINE (planning-time 282); the issue-adoption grep prints one line whose line number is recorded as ADOPTION_LINE (planning-time 227).
- [x] [P0-T4] Baseline mirror identity for RULE, SKILL, and AGENT against their MIRRORS, and record FEATURE/evidence/baseline/mirror-identity.TS.md.
      Commands: `git diff --no-index --exit-code .claude/rules/orchestrator-state.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`; `git diff --no-index --exit-code .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`; `git diff --no-index --exit-code .claude/agents/orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md`.
      Acceptance: each command exits 0 and prints nothing. An unequal pair stops the plan, because each later `cp` must be a pure sync.
- [x] [P0-T5] Baseline the DISPATCHER shape (`scripts/dev_tools/validate_orchestration_artifacts.py`), and record FEATURE/evidence/baseline/dispatcher-shape.TS.md.
      Commands: `wc -l scripts/dev_tools/validate_orchestration_artifacts.py`; `git grep --no-index -c -F "__package__" -- scripts/dev_tools/validate_orchestration_artifacts.py`; `git grep --no-index -c -F "noqa" -- scripts/dev_tools/validate_orchestration_artifacts.py`; `git grep --no-index -n "^from scripts.dev_tools" -- scripts/dev_tools/validate_orchestration_artifacts.py`.
      Acceptance: `wc -l` prints 495; the `__package__` grep prints 0; the `noqa` grep prints 0 (exit 1 is the pass condition for both); the last grep prints its first match at line 16 (`from scripts.dev_tools.epic_planner_readiness import build_epic_readiness_context`) and exits 0. Any other value stops the plan, because Appendix C1 is written against these lines.
- [x] [P0-T6] Classify how the environment resolves the `scripts` package when no working directory is on the path, and record FEATURE/evidence/baseline/scripts-package-origin.TS.md.
      Command: `poetry run python -I -c "import importlib.util; s = importlib.util.find_spec('scripts'); print('SCRIPTS_ORIGIN', None if s is None else s.origin)"`.
      Acceptance: exit 0 and one printed line beginning `SCRIPTS_ORIGIN`. The artifact records only the classification, never the printed path: `NONE` when the value is `None`; `ROOT-EDITABLE` when the value is the worktree's own `scripts/__init__.py`; `FOREIGN` otherwise. The classification is informational and no classification stops the plan: P0-T7 and P6-T10 run with `-S`, which skips site-packages, and INVOCATION-MODULE drops every `sys.path` entry that can supply a regular `scripts` package (PD4). A `FOREIGN` result is the residual hazard recorded in PD8.
- [x] [P0-T7] Reproduce the file-path invocation defect against the unmodified DISPATCHER (`scripts/dev_tools/validate_orchestration_artifacts.py`), and record FEATURE/evidence/regression-testing/file-path-invocation-repro.TS.md.
      Command: `poetry run python -S scripts/dev_tools/validate_orchestration_artifacts.py --help`.
      Acceptance: the command exits 1, the last stderr line begins with `ModuleNotFoundError`, and the artifact carries `ExpectedExitCode: 1`. Any other outcome stops the plan. `-S` keeps the shared environment's editable-install `.pth` entry off `sys.path`, so the run cannot import another checkout's `scripts` package.
- [x] [P0-T8] Baseline format check of DISPATCHER (`scripts/dev_tools/validate_orchestration_artifacts.py`), and record FEATURE/evidence/baseline/black-check.TS.md.
      Command: `poetry run black --check scripts/dev_tools/validate_orchestration_artifacts.py`.
      Acceptance: exit 0 and the line "1 file would be left unchanged." are recorded. A non-zero exit stops the plan.
- [x] [P0-T9] Baseline lint of DISPATCHER (`scripts/dev_tools/validate_orchestration_artifacts.py`), and record FEATURE/evidence/baseline/ruff-check.TS.md.
      Command: `poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py`.
      Acceptance: exit 0 and the line "All checks passed!" are recorded. A non-zero exit stops the plan.
- [x] [P0-T10] Baseline type check of DISPATCHER (`scripts/dev_tools/validate_orchestration_artifacts.py`), and record FEATURE/evidence/baseline/pyright.TS.md.
      Command: `poetry run pyright scripts/dev_tools/validate_orchestration_artifacts.py`.
      Acceptance: exit 0 and the summary line beginning "0 errors" are recorded. A non-zero exit stops the plan.
- [x] [P0-T11] Baseline EXISTING-SET run (the 16 files under `tests/scripts/dev_tools/` named in Terms), and record FEATURE/evidence/baseline/existing-set-pytest.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_codex_topology_cli.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_model_routing.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_pr_creation_readiness.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_state_shape.py tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py`.
      Acceptance: the exit code and the pytest summary line are recorded; the passed count is recorded as BASELINE_EXISTING_PASSED. A failure classified KL-510 is recorded as `KL-510: STATE-ONLY` with `ExpectedExitCode: 1` when it is the only failure. Any other failure stops the plan.
- [x] [P0-T12] Baseline full pytest run in coverage mode (COVERAGE-RUN over `tests/`), and record FEATURE/evidence/baseline/pytest-full-coverage.TS.md.
      Command: `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage-798.json`.
      Acceptance: the exit code, the pytest summary line, the verbatim terminal-table row for `scripts/dev_tools/validate_orchestration_artifacts.py`, the verbatim `TOTAL` row, and every `FAILED` line are recorded; the passed count is recorded as BASELINE_FULL_PASSED. KL-510 failures are recorded as `KL-510: STATE-ONLY` (with `ExpectedExitCode: 1` when they are the only failures). Any other failure is recorded verbatim as the pre-existing failure set and stops the plan for a report.
- [x] [P0-T13] Baseline numeric coverage for DISPATCHER and the `scripts.dev_tools` total from the P0-T12 JSON report (`artifacts/python/coverage-798.json`), and record FEATURE/evidence/baseline/python-coverage-values.TS.md.
      Command: `poetry run python -c "import json, pathlib; d = json.loads(pathlib.Path('artifacts/python/coverage-798.json').read_text(encoding='utf-8')); f = next(v for k, v in d['files'].items() if k.replace(chr(92), '/').endswith('scripts/dev_tools/validate_orchestration_artifacts.py')); s = f['summary']; t = d['totals']; print('FILE_LINE', round(100 * s['covered_lines'] / s['num_statements'], 2), 'FILE_BRANCH', round(100 * s['covered_branches'] / s['num_branches'], 2), 'TOTAL_LINE', round(t['percent_statements_covered'], 2), 'TOTAL_BRANCH', round(t['percent_branches_covered'], 2))"`.
      Acceptance: exit 0 and one printed line of the form `FILE_LINE <n> FILE_BRANCH <n> TOTAL_LINE <n> TOTAL_BRANCH <n>`; the four numbers are recorded as BASELINE_FILE_LINE, BASELINE_FILE_BRANCH, BASELINE_TOTAL_LINE, and BASELINE_TOTAL_BRANCH in `Output Summary:`. An empty output or a non-numeric value stops the plan. When BASELINE_FILE_LINE is below 85 or BASELINE_FILE_BRANCH is below 75, the plan stops for a report, because AC-20 would then require out-of-scope test work.
- [x] [P0-T14] Baseline PESTER-SET (`tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1`, `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1`) through the scratchpad runner script, and record FEATURE/evidence/baseline/pester-claude-runtime.TS.md.
      Runner body (written with the Write tool to the executor's session scratchpad, outside the repository; invoked from Bash as `sh <file>`; recorded as the `Command:` field): `pwsh -NoProfile -Command '$r = Invoke-Pester -Path "tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1","tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1" -PassThru -Output Detailed; "Passed=$($r.PassedCount) Failed=$($r.FailedCount)"; exit $r.FailedCount'`.
      Acceptance: the printed `Passed=<n> Failed=<n>` line is recorded; the passed count is recorded as BASELINE_PESTER_PASSED (17 when the executor last observed it during preflight); `EXIT_CODE:` is the runner's exit code, which equals the Failed count. Failed must be 0 and the exit code 0; any failure stops the plan. PowerShell coverage is recorded as `N/A - no PowerShell file changes`.

### Phase 1 — Regression Tests First

Each task in this phase writes FEATURE/evidence/other/p1-tN.TS.md (N is the task number).

- [x] [P1-T1] Create `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py` with exactly the content of Appendix A (Write tool, LF line endings).
      Commands: `git grep --no-index -c "^def test_" -- tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py`; `git status --porcelain -- tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py`.
      Acceptance: the grep prints 4; the status line shows the file as untracked (`??`).
- [x] [P1-T2] Create `tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py` with exactly the content of Appendix B (Write tool, LF line endings).
      Commands: `git grep --no-index -c "^def test_" -- tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`; `git status --porcelain -- tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`.
      Acceptance: the grep prints 10; the status line shows the file as untracked (`??`).
- [x] [P1-T3] Format INVOCATION-MODULE and DOCS-MODULE (`tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py`, `tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`) before their first run.
      Commands: `poetry run black tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`; `poetry run black --check tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`.
      Acceptance: the first command exits 0 and its summary line ("2 files left unchanged." or a line containing "reformatted") is recorded verbatim; the `--check` command exits 0 and prints "2 files would be left unchanged.".
- [x] [P1-T4] Lint INVOCATION-MODULE and DOCS-MODULE (`tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py`, `tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`).
      Command: `poetry run ruff check tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`.
      Acceptance: exit 0 and the line "All checks passed!". A finding is fixed in the test file only, without changing any assertion literal or test name and without adding a `noqa` comment, and P1-T3 is rerun.
- [x] [P1-T5] Type-check INVOCATION-MODULE and DOCS-MODULE (`tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py`, `tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`).
      Command: `poetry run pyright tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`.
      Acceptance: exit 0 and a summary line beginning "0 errors". A finding is fixed in the test file only, without changing any assertion literal or test name, and P1-T3 is rerun.
- [x] [P1-T6] Verify collection counts, size, and the absence of process and temporary-file use in both new modules (`tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py`, `tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`).
      Commands: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py --collect-only -q`; `poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py --collect-only -q`; `wc -l tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`; `git grep --no-index -c -E "subprocess|tempfile|tmp_path|mkstemp|NamedTemporaryFile|mem_fs_path|write_text|write_bytes|os\.system|Popen" -- tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`.
      Acceptance: the first collection prints "4 tests collected"; the second prints "52 tests collected" (22 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 22 + 1); both exit 0; `wc -l` reports each file at or under 500 lines; the forbidden-pattern grep prints nothing (exit 1 is the pass condition here). The artifact records `EXIT_CODE: 1` with `ExpectedExitCode: 1` (the last grep's exit code).

### Phase 2 — Fail-Before Evidence

The restart rule does not apply to the planned red states in this phase.

- [x] [P2-T1] [expect-fail] Run INVOCATION-MODULE (`tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py`) against the unmodified DISPATCHER and record FEATURE/evidence/regression-testing/expect-fail-invocation.TS.md with `ExpectedExitCode: 1`.
      Commands: `git status --porcelain -- scripts/dev_tools/validate_orchestration_artifacts.py`; `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py`.
      Acceptance: the status command prints nothing (DISPATCHER unchanged); pytest exits 1 and its summary line reports exactly 3 failed and 1 passed. The failing set is exactly `test_file_path_invocation_help_exits_zero`, `test_file_path_invocation_validates_committed_fixture`, and `test_file_path_bootstrap_appends_repo_root_once`, as named by the three `FAILED` lines of the `-ra` short summary, and the failure tracebacks contain exactly three lines beginning `E   ModuleNotFoundError`. The short-summary lines carry no message because each node ID exceeds the 80-column terminal width. The passing test is `test_module_invocation_leaves_sys_path_unchanged`. Every `FAILED` line is recorded. Any other split stops the plan, because a test that passes before the fix does not discriminate.
- [x] [P2-T2] [expect-fail] Run DOCS-MODULE (`tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`) against the unmodified RULE, SKILL, and AGENT and record FEATURE/evidence/regression-testing/expect-fail-required-keys-docs.TS.md with `ExpectedExitCode: 1`.
      Commands: `git status --porcelain -- .claude/rules/orchestrator-state.md .claude/skills/orchestrate/SKILL.md .claude/agents/orchestrator.md`; `poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`.
      Acceptance: the status command prints nothing; pytest exits 1 and reports exactly 37 failed and 15 passed. Failing set: all 22 cases of `test_required_key_is_documented_in_rule`; `test_rule_documented_keys_equal_required_state_keys`; `test_required_keys_section_sits_between_foreign_schema_and_scope_sections`; `test_rule_section_names_authority_and_check_semantics`; `test_rule_documents_last_updated_semantics`; `test_orchestrate_skill_references_last_updated_and_rule_section`; `test_orchestrate_skill_records_hyphenated_issue_num_key`; `test_rule_documents_both_dispatcher_invocation_forms`; and the 8 cases of `test_orchestrator_agent_checkpoint_persistence_lists_required_keys` for `relativeFile`, `long-name`, `work-mode`, `plan-path`, `step6_status`, `step7_status`, `step8_status`, `step9_status`. Passing set: `test_parity_comparison_detects_undocumented_and_extra_keys` and the other 14 agent-persona cases. Derivation: RULE has no `## Required Top-Level Keys` heading and its line 173 names only the `-m` dispatcher form; SKILL `## Checkpoint Handling` (lines 29-36) never names `last_updated` and line 270 reads "Record as `issue_num`"; AGENT lines 175-179 backtick 14 of the 22 keys and write the step statuses as a range. Every `FAILED` line is recorded. Any other split stops the plan.

### Phase 3 — Dispatcher File-Path Bootstrap

Each task in this phase writes FEATURE/evidence/other/p3-tN.TS.md unless it names a different artifact.

- [x] [P3-T1] Fix `scripts/dev_tools/validate_orchestration_artifacts.py` with replacement C1 of Appendix C (one comment line, one bootstrap statement, and one blank separator line between the stdlib imports ending at line 14 and the first `scripts.dev_tools` import at line 16).
      Commands: `wc -l scripts/dev_tools/validate_orchestration_artifacts.py`; `git grep --no-index -n -F "sys.path +=" -- scripts/dev_tools/validate_orchestration_artifacts.py`; `git grep --no-index -c -F "__package__" -- scripts/dev_tools/validate_orchestration_artifacts.py`; `git grep --no-index -n "^from scripts.dev_tools" -- scripts/dev_tools/validate_orchestration_artifacts.py`; `git grep --no-index -c -F "noqa" -- scripts/dev_tools/validate_orchestration_artifacts.py`.
      Acceptance: `wc -l` prints 498; the `sys.path +=` grep prints exactly one line, at line 17; the `__package__` grep prints 1; the first `from scripts.dev_tools` match is at line 19; the `noqa` grep prints 0 (exit 1 is the pass condition here). The artifact records `EXIT_CODE: 1` with `ExpectedExitCode: 1`. The new statement is quoted here so the literal check is exonerated: "sys.path += [str(Path(__file__).resolve().parents[2])] if not __package__ else []".
- [x] [P3-T2] Format-check, lint, and type-check the fixed DISPATCHER (`scripts/dev_tools/validate_orchestration_artifacts.py`).
      Commands: `poetry run black --check scripts/dev_tools/validate_orchestration_artifacts.py`; `poetry run pyright scripts/dev_tools/validate_orchestration_artifacts.py`; `poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py`.
      Acceptance: black exits 0 and prints "1 file would be left unchanged."; pyright exits 0 with a summary line beginning "0 errors"; ruff exits 0 and prints "All checks passed!". When ruff reports `E402` or `I001` against the bootstrap, the result is recorded verbatim and P3-T3 runs its fallback branch. Any other finding is fixed without a suppression and this task is rerun.
- [x] [P3-T3] Update `pyproject.toml` and `scripts/dev_tools/validate_orchestration_artifacts.py` with the E402 fallback (conditional: runs only when P3-T2 recorded an `E402` or `I001` finding against the bootstrap).
      Skip branch (explicitly authorized): when P3-T2 recorded "All checks passed!", record FEATURE/evidence/other/p3-t3.TS.md with `Command: none - fallback not triggered`, `EXIT_CODE: 0`, and `Output Summary: NOT-TRIGGERED (P3-T2 ruff clean; pyproject.toml unchanged)`, and check the task off.
      Fallback F1 (no suppression): replace the bootstrap statement with replacement C2 of Appendix C, then run `poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py`. When it prints "All checks passed!", F1 is final and `pyproject.toml` is not edited.
      Fallback F2 (suppression; runs only when F1 is still flagged): a file-level `E402` ignore is not pre-authorized by `.claude/rules/python-suppressions.md`. Search FEATURE/evidence/other/ for `e402-approval.*.md`. A valid approval record carries `Approver:` (the user who approved), `Timestamp:` (ISO-8601), `Scope: per-file E402 ignore for scripts/dev_tools/validate_orchestration_artifacts.py only`, and `Rationale:` (citing the failed F1 ruff output); a record missing any of the four fields counts as absent. When no valid approval record exists, stop and report with `blocked_reason: policy_hold`, naming the F1 ruff output. When one exists, apply replacements C3 and C4 of Appendix C, then run `poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py` and `wc -l scripts/dev_tools/validate_orchestration_artifacts.py`.
      Acceptance: one branch is recorded. For F1 or F2, ruff exits 0 and prints "All checks passed!"; the `wc -l` value is at most 500 (498 for F1, 499 for F2); for F2 the only `pyproject.toml` change is the C4 entry. After F1 or F2, P3-T1's `__package__` and `noqa` checks and P3-T2 are rerun and pass.
- [x] [P3-T4] Pass-after gate for INVOCATION-MODULE (`tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py`), and record FEATURE/evidence/regression-testing/pass-after-invocation.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py`.
      Acceptance: exit 0 and a summary line reporting 4 passed and no failed. A failure is fixed in DISPATCHER (never in INVOCATION-MODULE) and P3-T1 through this task are rerun.

### Phase 4 — Rule Edits

Each task in this phase writes FEATURE/evidence/other/p4-tN.TS.md. Line numbers are planning-time values. No edit in this phase touches RULE `## Issue-Adoption Scope and Backward Compatibility` or `## Invariants (issue_adoption object)` (concurrent issue #849).

- [x] [P4-T1] Update `.claude/rules/orchestrator-state.md` with replacement D1 of Appendix D (new `## Required Top-Level Keys` section inserted between `## Foreign Schema Warning (do not copy verbatim)` at line 29 and `## Scope and Backward Compatibility` at line 35). This edit does not touch the issue_adoption sections (#849).
      Commands: `wc -l .claude/rules/orchestrator-state.md`; `git grep --no-index -n "^## Required Top-Level Keys$" -- .claude/rules/orchestrator-state.md`; `git grep --no-index -n "^## Scope and Backward Compatibility$" -- .claude/rules/orchestrator-state.md`; `git grep --no-index -n "^## Issue-Adoption Scope" -- .claude/rules/orchestrator-state.md`.
      Acceptance: `wc -l` prints 306 (the planning-time `wc -l` value 275 plus 31 inserted lines; Appendix D1 inserts 31 newline-terminated lines ahead of the unchanged Scope heading line); the new heading is at line 35; the Scope heading is at line 66; the issue-adoption heading is at ADOPTION_LINE plus 31 (planning-time 258).
- [x] [P4-T2] Update the `## Bare-Module CLI Contract` paragraph of `.claude/rules/orchestrator-state.md` with replacement D2 of Appendix D (the dispatcher sentence, planning-time line 173, line 204 after P4-T1). This edit does not touch the issue_adoption sections (#849).
      Commands: `git grep --no-index -c -F "python scripts/dev_tools/validate_orchestration_artifacts.py orchestrator-state" -- .claude/rules/orchestrator-state.md`; `git grep --no-index -c -F "supported in the module form only" -- .claude/rules/orchestrator-state.md`; `wc -l .claude/rules/orchestrator-state.md`; `git grep --no-index -c -F "stays available and accepts the same flags." -- .claude/rules/orchestrator-state.md`.
      Acceptance: the first two greps each print 1; `wc -l` still prints 306 (D2 replaces text inside one line); the old-sentence grep prints 0 (exit 1 is the pass condition here). The artifact records `EXIT_CODE: 1` with `ExpectedExitCode: 1`. Literals created by this task, quoted for the gate: "python scripts/dev_tools/validate_orchestration_artifacts.py orchestrator-state" and "supported in the module form only".
- [x] [P4-T3] Update `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` by byte copy from `.claude/rules/orchestrator-state.md`.
      Commands: `cp .claude/rules/orchestrator-state.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`; `git diff --no-index --exit-code .claude/rules/orchestrator-state.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`; `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`.
      Acceptance: cp exits 0; the diff exits 0 and prints nothing; the status line shows the mirror modified (` M`).

### Phase 5 — Orchestrate Skill and Agent Persona Edits

Each task in this phase writes FEATURE/evidence/other/p5-tN.TS.md unless it names a different artifact. No edit in this phase touches SKILL `## Step S9 — CI Green Gate` (concurrent issue #841).

- [x] [P5-T1] Update the `## Checkpoint Handling` section of `.claude/skills/orchestrate/SKILL.md` with replacement E1 of Appendix E (new item 5 after item 4, which ends at line 36). No edit is made inside `## Step S9 — CI Green Gate` (#841), and the inserted text contains no `python` invocation text.
      Commands: `wc -l .claude/skills/orchestrate/SKILL.md`; `git grep --no-index -n -F "Required checkpoint keys (issue #798)" -- .claude/skills/orchestrate/SKILL.md`; `git grep --no-index -n "^## Step S9 " -- .claude/skills/orchestrate/SKILL.md`.
      Acceptance: `wc -l` prints 447 (446 plus one); the new item is at line 37; the S9 heading is at S9_LINE plus 1 (planning-time 283). Literal created by this task: "Required checkpoint keys (issue #798)".
- [x] [P5-T2] Update the `## Issue Number Consistency` sentence of `.claude/skills/orchestrate/SKILL.md` with replacement E2 of Appendix E (planning-time line 270, line 271 after P5-T1). The `<issue_num>` placeholder in the delegation-prompt line is not changed, and no edit is made inside `## Step S9 — CI Green Gate` (#841).
      Commands: `git grep --no-index -c "Record as .issue-num" -- .claude/skills/orchestrate/SKILL.md`; `git grep --no-index -c -F "Canonical issue number for this feature is <issue_num>." -- .claude/skills/orchestrate/SKILL.md`; `wc -l .claude/skills/orchestrate/SKILL.md`; `git grep --no-index -c "Record as .issue_num" -- .claude/skills/orchestrate/SKILL.md`.
      Acceptance: the first grep prints 1; the placeholder grep prints 1; `wc -l` still prints 447; the last grep prints 0 (exit 1 is the pass condition here). The artifact records `EXIT_CODE: 1` with `ExpectedExitCode: 1`.
- [x] [P5-T3] Update `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` by byte copy from `.claude/skills/orchestrate/SKILL.md`.
      Commands: `cp .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`; `git diff --no-index --exit-code .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`; `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`.
      Acceptance: cp exits 0; the diff exits 0 and prints nothing; the status line shows the mirror modified (` M`).
- [x] [P5-T4] Update the `## Checkpoint Persistence` key list of `.claude/agents/orchestrator.md` with replacement E3 of Appendix E (planning-time lines 176-179).
      Commands: `git grep --no-index -c -F "Step statuses: " -- .claude/agents/orchestrator.md`; `git grep --no-index -c -F "Required Top-Level Keys" -- .claude/agents/orchestrator.md`; `git grep --no-index -c "step5_status. through" -- .claude/agents/orchestrator.md`.
      Acceptance: the first two greps each print 1; the range grep prints 0 (exit 1 is the pass condition here). The artifact records `EXIT_CODE: 1` with `ExpectedExitCode: 1`.
- [x] [P5-T5] Update `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md` by byte copy from `.claude/agents/orchestrator.md`.
      Commands: `cp .claude/agents/orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md`; `git diff --no-index --exit-code .claude/agents/orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md`; `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md`.
      Acceptance: cp exits 0; the diff exits 0 and prints nothing; the status line shows the mirror modified (` M`).
- [x] [P5-T6] Pass-after gate for DOCS-MODULE (`tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`), and record FEATURE/evidence/regression-testing/pass-after-required-keys-docs.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`.
      Acceptance: exit 0 and a summary line reporting 52 passed and no failed. A failure is fixed by correcting the edited Markdown to the quoted appendix text and re-copying the affected mirror, never by changing DOCS-MODULE; the affected Phase 4 or Phase 5 task and this task are then rerun.

### Phase 6 — Final QC Loop

Restart rule: run P6-T1 through P6-T13 in order. If any of them fails, or if any step changes a tracked or new file, fix the cause, then restart from P6-T1 and rewrite every Phase 6 artifact with a new TS. The loop ends only when P6-T1 through P6-T13 pass in one uninterrupted pass. When P6-T1 fails, the fix is `poetry run black` on the files it names, followed by a restart. Each artifact records its loop iteration number in `Output Summary:`. Artifacts are written to FEATURE/evidence/qa-gates/.

- [x] [P6-T1] Format check of the three changed Python files (DISPATCHER, INVOCATION-MODULE, DOCS-MODULE), and record FEATURE/evidence/qa-gates/black-check.TS.md.
      Command: `poetry run black --check scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`.
      Acceptance: exit 0 and the line "3 files would be left unchanged." (and no line containing "would reformat").
- [x] [P6-T2] Lint of the three changed Python files, and record FEATURE/evidence/qa-gates/ruff-check.TS.md.
      Command: `poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`.
      Acceptance: exit 0 and the line "All checks passed!".
- [x] [P6-T3] Type check of the three changed Python files, and record FEATURE/evidence/qa-gates/pyright.TS.md.
      Command: `poetry run pyright scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`.
      Acceptance: exit 0 and a summary line beginning "0 errors".
- [x] [P6-T4] Run INVOCATION-MODULE and DOCS-MODULE together, and record FEATURE/evidence/qa-gates/new-modules-pytest.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`.
      Acceptance: exit 0 and a summary line reporting 56 passed and no failed.
- [x] [P6-T5] Run EXISTING-SET (the 16 files named in Terms), and record FEATURE/evidence/qa-gates/existing-set-pytest.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_codex_topology_cli.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_model_routing.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_pr_creation_readiness.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_state_shape.py tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py`.
      Acceptance: no failed test other than a KL-510 failure (recorded as `KL-510: STATE-ONLY` with `ExpectedExitCode: 1` when it is the only failure; otherwise exit 0). The passed count equals BASELINE_EXISTING_PASSED plus the number of KL-510 failures in P0-T11 minus the number in this run. The node IDs `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py::test_every_skill_script_reference_is_bundled` and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_handoff_runtime_has_bundle_pack_and_effective_install_parity` are each recorded as passed, and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` is recorded as passed or as KL-510.
- [x] [P6-T6] Run PESTER-SET (`tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1`, `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1`) through the scratchpad runner script, and record FEATURE/evidence/qa-gates/pester-claude-runtime.TS.md.
      Runner body (the same line as P0-T14, written with the Write tool to the executor's session scratchpad, outside the repository; invoked from Bash as `sh <file>`; recorded as the `Command:` field): `pwsh -NoProfile -Command '$r = Invoke-Pester -Path "tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1","tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1" -PassThru -Output Detailed; "Passed=$($r.PassedCount) Failed=$($r.FailedCount)"; exit $r.FailedCount'`.
      Acceptance: the printed line shows Failed=0 and Passed equal to BASELINE_PESTER_PASSED; `EXIT_CODE:` is the runner's exit code and is 0. PowerShell coverage is recorded as `N/A - no PowerShell file changes`.
- [x] [P6-T7] Full pytest run in coverage mode (COVERAGE-RUN over `tests/`), and record FEATURE/evidence/qa-gates/pytest-full-coverage.TS.md.
      Command: `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage-798.json`.
      Acceptance: no failed test other than KL-510 failures (recorded as in P6-T5; otherwise exit 0); the summary line, the verbatim terminal-table row for `scripts/dev_tools/validate_orchestration_artifacts.py`, the verbatim `TOTAL` row, and the passed count are recorded; the passed count equals BASELINE_FULL_PASSED plus 56, plus the number of KL-510 failures in P0-T12 minus the number in this run.
- [x] [P6-T8] Post-change numeric coverage and changed-line coverage for DISPATCHER from the P6-T7 JSON report (`artifacts/python/coverage-798.json`), and record FEATURE/evidence/qa-gates/python-coverage-values.TS.md.
      Command: `poetry run python -c "import json, pathlib; d = json.loads(pathlib.Path('artifacts/python/coverage-798.json').read_text(encoding='utf-8')); f = next(v for k, v in d['files'].items() if k.replace(chr(92), '/').endswith('scripts/dev_tools/validate_orchestration_artifacts.py')); s = f['summary']; t = d['totals']; print('FILE_LINE', round(100 * s['covered_lines'] / s['num_statements'], 2), 'FILE_BRANCH', round(100 * s['covered_branches'] / s['num_branches'], 2), 'TOTAL_LINE', round(t['percent_statements_covered'], 2), 'TOTAL_BRANCH', round(t['percent_branches_covered'], 2), 'MISSING_16_TO_19', [n for n in f['missing_lines'] if 16 <= n <= 19], 'EXECUTED_17', 17 in f['executed_lines'])"`.
      Acceptance: exit 0 and one printed line; the values are recorded as FINAL_FILE_LINE, FINAL_FILE_BRANCH, FINAL_TOTAL_LINE, FINAL_TOTAL_BRANCH. FINAL_FILE_LINE >= 85; FINAL_FILE_BRANCH >= 75; FINAL_FILE_LINE >= BASELINE_FILE_LINE; FINAL_FILE_BRANCH >= BASELINE_FILE_BRANCH; `MISSING_16_TO_19 []`; `EXECUTED_17 True`. Lines 16-19 hold the bootstrap in every form (C1: statement at line 17; C2: line 17; C3: lines 17-18), so an empty missing list there means every changed executable line is covered.
- [x] [P6-T9] Coverage comparison for every in-scope language (inputs: P0-T13 and P6-T8 artifacts), and record FEATURE/evidence/qa-gates/coverage-comparison.TS.md.
      Command: none (record `Command: none - comparison of recorded values` and `EXIT_CODE: 0`).
      Acceptance: the artifact lists, for Python, BASELINE_FILE_LINE, FINAL_FILE_LINE, BASELINE_FILE_BRANCH, FINAL_FILE_BRANCH, BASELINE_TOTAL_LINE, FINAL_TOTAL_LINE, BASELINE_TOTAL_BRANCH, FINAL_TOTAL_BRANCH, the four deltas, and `New/changed-code coverage: lines 16-19 of scripts/dev_tools/validate_orchestration_artifacts.py fully covered (MISSING_16_TO_19 [])`; for TypeScript and PowerShell, `N/A - no source changes`. Every value is numeric or one of the quoted literals. A negative file delta stops the plan.
- [x] [P6-T10] Integration check: run DISPATCHER in both real invocation forms against the committed fixture, and record FEATURE/evidence/qa-gates/invocation-forms.TS.md.
      Commands: `poetry run python -S scripts/dev_tools/validate_orchestration_artifacts.py --help`; `poetry run python -S scripts/dev_tools/validate_orchestration_artifacts.py orchestrator-state tests/fixtures/orchestrator_state_remediation_loop_backcompat/no_remediation_loop.json`; `poetry run python -S -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state tests/fixtures/orchestrator_state_remediation_loop_backcompat/no_remediation_loop.json`.
      Why `-S`: it skips site-packages, so the shared environment's editable-install `.pth` entry, which can name another checkout, cannot supply `scripts`. The file-path runs then import the repository's own `scripts` package only through the DISPATCHER bootstrap, and the module run imports it from the working directory; the DISPATCHER import chain needs nothing outside the standard library and that package.
      Acceptance: the `--help` command exits 0 and its output contains `orchestrator-state`; the second and third commands exit with the same code and print the same stdout line and the same stderr lines, which are recorded verbatim. The artifact's top-level `EXIT_CODE:` is the third command's exit code, with `ExpectedExitCode:` set to that value when it is not 0.
- [x] [P6-T11] Final mirror identity for RULE, SKILL, and AGENT, and record FEATURE/evidence/qa-gates/mirror-identity.TS.md.
      Commands: `git diff --no-index --exit-code .claude/rules/orchestrator-state.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`; `git diff --no-index --exit-code .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`; `git diff --no-index --exit-code .claude/agents/orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md`.
      Acceptance: each command exits 0 and prints nothing.
- [x] [P6-T12] Scope and section-boundary verification against MERGE_BASE for AC-13, AC-17, and AC-19, and record FEATURE/evidence/qa-gates/scope-check.TS.md.
      Commands (substitute the recorded MERGE_BASE value; the two `:(exclude)` pathspecs remove FEATURE and the promoted lifecycle record, both committed by the orchestrator's preparation commit after MERGE_BASE): `git diff --name-only MERGE_BASE -- . ":(exclude)docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798" ":(exclude)docs/features/potential/promoted/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails.md"`; `git status --porcelain --untracked-files=all -- . ":(exclude)docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798" ":(exclude)docs/features/potential/promoted/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails.md"`; `git diff --name-only MERGE_BASE -- scripts/dev_tools/validate_orchestrator_state.py extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts .claude/lib/orchestrator-state/OrchestratorState.psm1 .claude/hooks/validate-orchestrator-output.ps1`; `git diff -U0 MERGE_BASE -- .claude/skills/orchestrate/SKILL.md`; `git diff -U0 MERGE_BASE -- .claude/rules/orchestrator-state.md`.
      Acceptance: the first command prints exactly the seven paths `scripts/dev_tools/validate_orchestration_artifacts.py`, `.claude/rules/orchestrator-state.md`, `.claude/skills/orchestrate/SKILL.md`, `.claude/agents/orchestrator.md`, and the three MIRRORS (plus `pyproject.toml` only when P3-T3 ran F2). The status command prints a ` M` line for each of those paths and exactly two `??` lines, for `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py` and `tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`. The third command prints nothing (AC-19). In the SKILL diff, every `@@` hunk header's old range (start plus count minus one) ends before S9_LINE, so no hunk touches `## Step S9 — CI Green Gate` (AC-13); planning-time headers are an insertion after line 36 and a one-line change at line 270. In the RULE diff, every hunk's old range ends before ADOPTION_LINE, so no hunk touches the two issue_adoption sections (AC-17); planning-time headers are an insertion after line 34 and a one-line change at line 173. All `@@` headers are recorded verbatim. Any other path or hunk stops the plan.
- [x] [P6-T13] Size, suppression, invocation-text, and test-isolation checks (DISPATCHER, INVOCATION-MODULE, DOCS-MODULE, SKILL), and record FEATURE/evidence/qa-gates/size-and-text-checks.TS.md.
      Commands: `wc -l scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`; `git grep --no-index -c -F "__package__" -- scripts/dev_tools/validate_orchestration_artifacts.py`; `git grep --no-index -c -E "python3? -m scripts\.|python3? scripts/" -- .claude/skills/orchestrate/SKILL.md`; `git grep --no-index -c -E "subprocess|tempfile|tmp_path|mkstemp|NamedTemporaryFile|mem_fs_path|write_text|write_bytes|os\.system|Popen" -- tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`; `git grep --no-index -c -F "noqa" -- scripts/dev_tools/validate_orchestration_artifacts.py`.
      Acceptance: `wc -l` reports DISPATCHER at 498 (499 under F2) and each test module at or under 500; the `__package__` grep prints 1 (one conditional bootstrap); the invocation-text grep, the forbidden-pattern grep, and the `noqa` grep each print nothing (exit 1 is the pass condition for each). The artifact records `EXIT_CODE: 1` with `ExpectedExitCode: 1`.

### Phase 7 — Acceptance-Criteria Check-Off

Each task changes one AC box in `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` from `- [ ]` to `- [x]` on the line recorded for that AC in AC_LINES, only when every named verifying task is checked and its artifact passes. No other spec text changes. Each task appends one line `AC-n checked: <verifying artifact paths>` to FEATURE/evidence/other/ac-checkoff.TS.md (one artifact for the phase, created by P7-T1). Acceptance for each task: `git grep --no-index -n "^- \[x\] " -- docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` prints a line whose line number is the AC's recorded line, and the artifact line names every verifying artifact. An AC that cannot be verified stays unchecked and is listed as a gap in the artifact.

- [x] [P7-T1] Update `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` to check off AC-1 (planning-time line 248). Verifying tasks: P2-T1, P3-T4, P6-T4.
- [x] [P7-T2] Update `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` to check off AC-2 (line 249). Verifying tasks: P3-T4, P6-T4, P6-T10.
- [x] [P7-T3] Update `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` to check off AC-3 (line 250). Verifying tasks: P2-T1, P6-T4.
- [x] [P7-T4] Update `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` to check off AC-4 (line 251). Verifying tasks: P2-T1, P6-T4.
- [x] [P7-T5] Update `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` to check off AC-5 (line 252). Verifying tasks: P1-T6, P6-T13, P6-T7 (the full run passes with both modules in it, so no later test observed altered import state).
- [x] [P7-T6] Update `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` to check off AC-6 (line 253). Verifying tasks: P3-T1, P6-T13.
- [x] [P7-T7] Update `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` to check off AC-7 (line 254). Verifying tasks: P3-T2, P3-T3, P6-T2, P6-T13.
- [x] [P7-T8] Update `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` to check off AC-8 (line 255). Verifying tasks: P4-T1, P5-T6, P6-T4 (`test_required_keys_section_sits_between_foreign_schema_and_scope_sections`, `test_rule_section_names_authority_and_check_semantics`, `test_required_key_is_documented_in_rule`).
- [x] [P7-T9] Update `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` to check off AC-9 (line 259). Verifying tasks: P5-T6, P6-T4 (`test_rule_documents_last_updated_semantics`).
- [x] [P7-T10] Update `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` to check off AC-10 (line 260). Verifying tasks: P2-T2, P5-T6, P6-T4.
- [x] [P7-T11] Update `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` to check off AC-11 (line 261). Verifying tasks: P2-T2, P6-T4 (`test_parity_comparison_detects_undocumented_and_extra_keys`).
- [x] [P7-T12] Update `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` to check off AC-12 (line 262). Verifying tasks: P5-T1, P5-T6, P6-T6.
- [x] [P7-T13] Update `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` to check off AC-13 (line 263). Verifying tasks: P5-T2, P5-T6, P6-T6, P6-T12 (SKILL hunk check).
- [x] [P7-T14] Update `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` to check off AC-14 (line 264). Verifying tasks: P6-T5 (`test_every_skill_script_reference_is_bundled`), P6-T13 (invocation-text grep).
- [x] [P7-T15] Update `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` to check off AC-15 (line 265). Verifying tasks: P5-T4, P5-T6, P6-T4.
- [x] [P7-T16] Update `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` to check off AC-16 (line 266). Verifying tasks: P4-T2, P5-T6, P6-T4 (`test_rule_documents_both_dispatcher_invocation_forms`).
- [x] [P7-T17] Update `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` to check off AC-17 (line 267). Verifying task: P6-T12 (RULE hunk check).
- [x] [P7-T18] Update `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` to check off AC-18 (line 268). Verifying tasks: P6-T11, P6-T5. When P6-T5 recorded `test_bundled_claude_payload_contains_all_repo_runtime_contracts` as KL-510, AC-18 is CI-dependent: it stays unchecked, is listed as pending-CI in the artifact, and is checked off by the orchestrator after the CI green gate (S9) records success, per `.claude/skills/acceptance-criteria-tracking/SKILL.md` "CI-Dependent Criteria".
- [x] [P7-T19] Update `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` to check off AC-19 (line 269). Verifying tasks: P6-T12 (third command), P6-T5.
- [x] [P7-T20] Update `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` to check off AC-20 (line 272). Verifying tasks: P6-T1 through P6-T10 in one uninterrupted loop pass. AC-20 stays unchecked if any Phase 6 artifact records a failure other than KL-510.
- [x] [P7-T21] Update `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` to check off AC-21 (line 273). Verifying tasks: P1-T6, P6-T13.

### Phase 8 — Commit, Rebase, Push, and PR Handoff

This phase is executed by the orchestrator session after feature review, not by the plan executor. Each task writes FEATURE/evidence/other/p8-tN.TS.md.

- [ ] [P8-T1] Commit the change set: stage each path in the Files Written list that changed (explicit paths, no directory-wide add outside FEATURE) and commit.
      Commands: `git add scripts/dev_tools/validate_orchestration_artifacts.py .claude/rules/orchestrator-state.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md .claude/agents/orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798`; `git commit` with a message that names issue #798; `git status --porcelain`.
      Acceptance: the commit exits 0; `pyproject.toml` is added only when P3-T3 ran F2; the final status command prints nothing. The promoted lifecycle record `docs/features/potential/promoted/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails.md` and the FEATURE documents present before execution are already committed by the preparation commit, so this task does not stage the promoted record; the FEATURE path in the `git add` stages only the evidence files and checkbox edits added during execution. A porcelain line for the promoted record means it was modified during execution and stops the task for a report.
- [ ] [P8-T2] Rebase onto `origin/main` and re-establish mirror identity (concurrent issues #841 and #849 touch SKILL, RULE, and their mirrors).
      Commands: `git fetch origin main`; `git rebase origin/main`; on a conflict in SKILL or RULE, keep both sides' changes in the repo-local source, then `cp` each source over its mirror (the three `cp` commands of P4-T3, P5-T3, and P5-T5) and continue the rebase; then `git diff --no-index --exit-code .claude/rules/orchestrator-state.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`, `git diff --no-index --exit-code .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`, and `git diff --no-index --exit-code .claude/agents/orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md`; `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`; `git diff --name-only origin/main HEAD -- . ":(exclude)docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798"`; `git status --porcelain`.
      Acceptance: the rebase completes; each mirror diff exits 0; pytest reports no failure other than KL-510; the name-only diff prints exactly the seven Files Written source and mirror paths (`scripts/dev_tools/validate_orchestration_artifacts.py`, RULE, SKILL, AGENT, and the three MIRRORS), the two test files, and the promoted lifecycle record `docs/features/potential/promoted/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails.md` (committed by the preparation commit; FEATURE is excluded by the pathspec), plus `pyproject.toml` only under F2; the status command prints nothing.
- [ ] [P8-T3] Push the branch: `git push -u origin bug/orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798` for a first push, or a lease-protected force push after the P8-T2 rebase (issued through the PowerShell tool, because the Bash hook denylist rejects the lease flag).
      Acceptance: the push exits 0 and `git status -sb` shows the branch even with its upstream.
- [ ] [P8-T4] Delegate PR authoring to `pr-author` per `.claude/skills/orchestrate/SKILL.md` `## PR Authoring (pr-author Handoff)`, then run the CI green gate (S9). When AC-18 was left pending-CI by P7-T18, check it off after `ci_gate.conclusion` is `success`, push, and re-run the gate on the new head.
      Acceptance: a PR exists against `main`; the S9 gate records success on the final head SHA.

## Appendix A — INVOCATION-MODULE content (verbatim)

File: `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py`

```python
"""Invocation-contract tests for the orchestration-artifact dispatcher (issue #798).

Purpose:
    Pin the two supported invocation forms of
    ``scripts/dev_tools/validate_orchestration_artifacts.py``: the module form
    (``python -m scripts.dev_tools.validate_orchestration_artifacts``) and the
    file-path form (``python scripts/dev_tools/validate_orchestration_artifacts.py``).

    ``runpy.run_path`` reproduces the file-path form in process: it executes the
    file with no package context, as the interpreter does for a script path.
    Before each file-path run, every ``sys.path`` entry that names the
    repository root or can supply a regular ``scripts`` package is removed, and
    ``scripts`` plus every ``scripts.*`` module is evicted from ``sys.modules``,
    so the run can import the first-party package only through the dispatcher's
    own bootstrap. The second filter covers a shared virtual environment whose
    editable-install entry names another checkout of this repository. Without
    the bootstrap the run raises ``ModuleNotFoundError``.

Invariants / Constraints:
    No child process and no temporary file is used. ``sys.path`` and the
    original ``scripts.*`` module objects are restored after every isolated run.
"""

from __future__ import annotations

import os
import runpy
import sys
from contextlib import contextmanager
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

import scripts.dev_tools.validate_orchestration_artifacts as dispatcher

if TYPE_CHECKING:
    from collections.abc import Generator
    from types import ModuleType

# This file lives at tests/scripts/dev_tools/, three parents below the repo root.
REPO_ROOT = Path(__file__).resolve().parents[3]
SCRIPT = REPO_ROOT / "scripts" / "dev_tools" / "validate_orchestration_artifacts.py"
MODULE_NAME = "scripts.dev_tools.validate_orchestration_artifacts"
FIXTURE = (
    REPO_ROOT
    / "tests"
    / "fixtures"
    / "orchestrator_state_remediation_loop_backcompat"
    / "no_remediation_loop.json"
)


def resolves_to_repo_root(entry: str) -> bool:
    """Return whether a ``sys.path`` entry names the repository root.

    An empty entry names the working directory, as the import system reads it.
    """

    resolved = Path(entry or ".").resolve()
    return os.path.normcase(str(resolved)) == os.path.normcase(str(REPO_ROOT))


def is_scripts_module(name: str) -> bool:
    """Return whether a ``sys.modules`` key belongs to the ``scripts`` package."""

    return name == "scripts" or name.startswith("scripts.")


def provides_scripts_package(entry: str) -> bool:
    """Return whether a ``sys.path`` entry can supply a regular ``scripts`` package.

    A shared virtual environment can carry an editable-install entry that names
    another checkout of this repository; that entry would satisfy the import.
    """

    return (Path(entry or ".") / "scripts" / "__init__.py").is_file()


def repo_root_entry_count() -> int:
    """Return how many ``sys.path`` entries name the repository root."""

    return sum(1 for entry in sys.path if resolves_to_repo_root(entry))


@contextmanager
def isolated_import_state() -> Generator[None, None, None]:
    """Remove every route to the ``scripts`` package, then restore it on exit.

    ``sys.path`` is rebound to a copy that omits each entry naming the
    repository root and each entry that can supply a regular ``scripts``
    package, and ``scripts`` plus every ``scripts.*`` module is removed from
    ``sys.modules``. On exit the original ``sys.path`` list object is
    rebound, every ``scripts.*`` module imported inside the block is discarded,
    and the original module objects are put back.
    """

    original_path = sys.path
    saved_modules: dict[str, ModuleType] = {
        name: module for name, module in sys.modules.items() if is_scripts_module(name)
    }
    sys.path = [
        entry
        for entry in original_path
        if not resolves_to_repo_root(entry) and not provides_scripts_package(entry)
    ]
    for name in saved_modules:
        del sys.modules[name]
    try:
        yield
    finally:
        sys.path = original_path
        for name in [name for name in sys.modules if is_scripts_module(name)]:
            del sys.modules[name]
        sys.modules.update(saved_modules)


def run_file_path_form(monkeypatch: pytest.MonkeyPatch, arguments: list[str]) -> object:
    """Run the dispatcher by file path as ``__main__`` and return its exit code."""

    monkeypatch.setattr(sys, "argv", [str(SCRIPT), *arguments])
    with pytest.raises(SystemExit) as exit_info:
        runpy.run_path(str(SCRIPT), run_name="__main__")
    return exit_info.value.code


def test_file_path_invocation_help_exits_zero(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """File-path invocation prints usage and exits 0 without a package context.

    Before the bootstrap existed, this run raised ModuleNotFoundError.
    """

    # Arrange / Act
    with isolated_import_state():
        exit_code = run_file_path_form(monkeypatch, ["--help"])

    # Assert
    captured = capsys.readouterr()
    assert exit_code == 0, f"--help must exit 0, got {exit_code!r}"
    assert "orchestrator-state" in captured.out, "usage must list orchestrator-state"


def test_file_path_invocation_validates_committed_fixture(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """File-path invocation matches main() in exit code, stdout, and stderr."""

    # Arrange
    arguments = ["orchestrator-state", str(FIXTURE)]
    expected_code = dispatcher.main(arguments)
    expected = capsys.readouterr()

    # Act
    with isolated_import_state():
        exit_code = run_file_path_form(monkeypatch, arguments)

    # Assert
    actual = capsys.readouterr()
    assert exit_code == expected_code, "both forms must return the same exit code"
    assert actual.out == expected.out, "both forms must write the same stdout"
    assert actual.err == expected.err, "both forms must write the same stderr"


@pytest.mark.filterwarnings("ignore:.*found in sys.modules.*:RuntimeWarning")
def test_module_invocation_leaves_sys_path_unchanged(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """Module invocation exits 0 on --help and leaves sys.path as it found it."""

    # Arrange
    monkeypatch.setattr(sys, "argv", [MODULE_NAME, "--help"])
    snapshot = list(sys.path)

    # Act
    with pytest.raises(SystemExit) as exit_info:
        runpy.run_module(MODULE_NAME, run_name="__main__")

    # Assert
    captured = capsys.readouterr()
    assert exit_info.value.code == 0, "module-form --help must exit 0"
    assert "orchestrator-state" in captured.out, "usage must list orchestrator-state"
    assert sys.path == snapshot, "module invocation must not modify sys.path"


def test_file_path_bootstrap_appends_repo_root_once(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """The bootstrap appends the repository root exactly once, at the end."""

    # Arrange / Act
    with isolated_import_state():
        entries_before = repo_root_entry_count()
        exit_code = run_file_path_form(monkeypatch, ["--help"])
        entries_after = repo_root_entry_count()
        last_entry = sys.path[-1]

    # Assert
    assert entries_before == 0, "isolation must remove the repository root first"
    assert exit_code == 0, f"--help must exit 0, got {exit_code!r}"
    assert entries_after == 1, f"expected one root entry, found {entries_after}"
    assert resolves_to_repo_root(last_entry), "the root must be appended last"
```

## Appendix B — DOCS-MODULE content (verbatim)

File: `tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`

```python
"""Documentation-parity tests for the required checkpoint keys (issue #798).

Purpose:
    ``REQUIRED_STATE_KEYS`` in ``scripts/dev_tools/validate_orchestrator_state.py``
    names the top-level keys that plain validation requires in an orchestrator
    checkpoint. These tests pin that tuple, in both directions, to the
    ``## Required Top-Level Keys`` section of
    ``.claude/rules/orchestrator-state.md``. They also pin the related
    statements in the orchestrate skill, in the orchestrator agent persona, and
    in the rule's ``## Bare-Module CLI Contract``.

Invariants / Constraints:
    Committed documents are read in place. No file is created, no process is
    started, and no external service is consulted. Phrase checks run over
    whitespace-collapsed section text, so a reflow cannot break them.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools.validate_orchestrator_state import REQUIRED_STATE_KEYS

if TYPE_CHECKING:
    from collections.abc import Iterable

# This file lives at tests/scripts/dev_tools/, three parents below the repo root.
REPO_ROOT = Path(__file__).resolve().parents[3]
RULE = REPO_ROOT / ".claude" / "rules" / "orchestrator-state.md"
SKILL = REPO_ROOT / ".claude" / "skills" / "orchestrate" / "SKILL.md"
AGENT = REPO_ROOT / ".claude" / "agents" / "orchestrator.md"

REQUIRED_KEYS_HEADING = "## Required Top-Level Keys"
PRECEDING_HEADING = "## Foreign Schema Warning (do not copy verbatim)"
FOLLOWING_HEADING = "## Scope and Backward Compatibility"
KEY_BULLET = re.compile(r"^- `([^`]+)`")


def read_lines(path: Path) -> list[str]:
    """Return the lines of a committed document, read in place."""

    return path.read_text(encoding="utf-8").splitlines()


def heading_index(lines: list[str], heading: str) -> int | None:
    """Return the index of the line equal to ``heading``, or ``None``."""

    return next(
        (index for index, line in enumerate(lines) if line.strip() == heading), None
    )


def section(path: Path, heading: str) -> str:
    """Return the body of ``heading`` up to the next level-2 heading.

    An empty string is returned when the heading is absent.
    """

    lines = read_lines(path)
    start = heading_index(lines, heading)
    if start is None:
        return ""
    body: list[str] = []
    for line in lines[start + 1 :]:
        if line.startswith("## "):
            break
        body.append(line)
    return "\n".join(body)


def collapse(text: str) -> str:
    """Collapse every run of whitespace to one space."""

    return " ".join(text.split())


def documented_keys(section_text: str) -> list[str]:
    """Return the key named by each backticked bullet, in document order."""

    keys: list[str] = []
    for line in section_text.splitlines():
        match = KEY_BULLET.match(line)
        if match is not None:
            keys.append(match.group(1))
    return keys


def compare_key_sets(
    required: Iterable[str], documented: Iterable[str]
) -> tuple[list[str], list[str]]:
    """Return the undocumented required keys and the documented extra keys."""

    required_set = set(required)
    documented_set = set(documented)
    return sorted(required_set - documented_set), sorted(documented_set - required_set)


def rule_keys() -> list[str]:
    """Return the keys documented in the rule's required-keys section."""

    return documented_keys(section(RULE, REQUIRED_KEYS_HEADING))


@pytest.mark.parametrize("key", REQUIRED_STATE_KEYS)
def test_required_key_is_documented_in_rule(key: str) -> None:
    """Each key the validator requires is a backticked bullet in the rule."""

    # Act
    keys = rule_keys()

    # Assert
    assert key in keys, f"`{key}` missing from {REQUIRED_KEYS_HEADING}"


def test_rule_documented_keys_equal_required_state_keys() -> None:
    """The rule lists exactly the required keys, each once."""

    # Act
    keys = rule_keys()
    undocumented, extra = compare_key_sets(REQUIRED_STATE_KEYS, keys)

    # Assert
    assert keys, f"{REQUIRED_KEYS_HEADING} lists no keys"
    assert undocumented == [], f"required keys missing from the rule: {undocumented}"
    assert extra == [], f"rule lists keys the validator does not require: {extra}"
    assert len(keys) == len(set(keys)), "each key must be listed once"


def test_parity_comparison_detects_undocumented_and_extra_keys() -> None:
    """The comparison reports a key on either side that the other lacks."""

    # Arrange
    required = list(REQUIRED_STATE_KEYS)

    # Act
    undocumented_case = compare_key_sets([*required, "synthetic_required"], required)
    extra_case = compare_key_sets(required, [*required, "synthetic_documented"])
    matching_case = compare_key_sets(required, list(reversed(required)))

    # Assert
    assert undocumented_case == (["synthetic_required"], []), "missing key not found"
    assert extra_case == ([], ["synthetic_documented"]), "extra key not found"
    assert matching_case == ([], []), "equal sets must report no mismatch"


def test_required_keys_section_sits_between_foreign_schema_and_scope_sections() -> None:
    """The new section follows the foreign-schema warning and precedes scope."""

    # Arrange
    lines = read_lines(RULE)

    # Act
    preceding = heading_index(lines, PRECEDING_HEADING)
    current = heading_index(lines, REQUIRED_KEYS_HEADING)
    following = heading_index(lines, FOLLOWING_HEADING)

    # Assert
    assert preceding is not None, f"{PRECEDING_HEADING} heading missing"
    assert current is not None, f"{REQUIRED_KEYS_HEADING} heading missing"
    assert following is not None, f"{FOLLOWING_HEADING} heading missing"
    assert preceding < current < following, "required-keys section is out of place"


def test_rule_section_names_authority_and_check_semantics() -> None:
    """The section names the authority, both ports, and the check semantics."""

    # Act
    text = collapse(section(RULE, REQUIRED_KEYS_HEADING))

    # Assert
    for phrase in (
        "`REQUIRED_STATE_KEYS`",
        "`scripts/dev_tools/validate_orchestrator_state.py`",
        "`extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`",
        "`.claude/lib/orchestrator-state/OrchestratorState.psm1`",
        "unconditional",
        "presence-only",
        "`Checkpoint missing required key: <key>`",
    ):
        assert phrase in text, f"{REQUIRED_KEYS_HEADING} must contain {phrase}"


def test_rule_documents_last_updated_semantics() -> None:
    """The section defines the format and the refresh rule of last_updated."""

    # Act
    text = collapse(section(RULE, REQUIRED_KEYS_HEADING))

    # Assert
    for phrase in (
        "`last_updated`",
        "ISO-8601",
        "UTC",
        "rewritten on every checkpoint write",
        "including halts",
        "do not parse the value",
    ):
        assert phrase in text, f"{REQUIRED_KEYS_HEADING} must contain {phrase}"


def test_orchestrate_skill_references_last_updated_and_rule_section() -> None:
    """Checkpoint Handling names last_updated, its refresh rule, and the rule."""

    # Act
    text = collapse(section(SKILL, "## Checkpoint Handling"))

    # Assert
    assert "`last_updated`" in text, "Checkpoint Handling must name last_updated"
    assert "rewritten on every checkpoint write" in text, "refresh rule missing"
    assert "Required Top-Level Keys" in text, "rule section reference missing"


def test_orchestrate_skill_records_hyphenated_issue_num_key() -> None:
    """Issue Number Consistency records the hyphenated checkpoint key."""

    # Act
    text = collapse(section(SKILL, "## Issue Number Consistency"))

    # Assert
    assert "Record as `issue-num`" in text, "the checkpoint key must be issue-num"
    assert "Record as `issue_num`" not in text, "issue_num is not a checkpoint key"


@pytest.mark.parametrize("key", REQUIRED_STATE_KEYS)
def test_orchestrator_agent_checkpoint_persistence_lists_required_keys(
    key: str,
) -> None:
    """Checkpoint Persistence in the agent persona names each required key."""

    # Act
    text = section(AGENT, "## Checkpoint Persistence")

    # Assert
    assert f"`{key}`" in text, f"`{key}` missing from Checkpoint Persistence"


def test_rule_documents_both_dispatcher_invocation_forms() -> None:
    """The CLI contract documents both dispatcher forms and the -m validator."""

    # Act
    text = collapse(section(RULE, "## Bare-Module CLI Contract"))

    # Assert
    for phrase in (
        "python -m scripts.dev_tools.validate_orchestration_artifacts",
        "python scripts/dev_tools/validate_orchestration_artifacts.py",
        "python -m scripts.dev_tools.validate_orchestrator_state",
    ):
        assert phrase in text, f"Bare-Module CLI Contract must contain {phrase}"
```

## Appendix C — DISPATCHER replacements

C1 (P3-T1, primary). In `scripts/dev_tools/validate_orchestration_artifacts.py`:

old_string:

```text
from pathlib import Path

from scripts.dev_tools.epic_planner_readiness import build_epic_readiness_context
```

new_string:

```text
from pathlib import Path

# File-path invocation has no package context; make the repo root importable.
sys.path += [str(Path(__file__).resolve().parents[2])] if not __package__ else []

from scripts.dev_tools.epic_planner_readiness import build_epic_readiness_context
```

C2 (P3-T3 fallback F1, no suppression). Replace the C1 statement line only:

old_string:

```text
sys.path += [str(Path(__file__).resolve().parents[2])] if not __package__ else []
```

new_string:

```text
sys.path.extend([str(Path(__file__).resolve().parents[2])] if not __package__ else [])
```

C3 (P3-T3 fallback F2, only with a recorded approval). Replace the bootstrap statement line (C1 or C2 form, whichever is present) with:

```text
if not __package__:
    sys.path.append(str(Path(__file__).resolve().parents[2]))
```

C4 (P3-T3 fallback F2, only with a recorded approval). In `pyproject.toml`, append after the last line of `[tool.ruff.lint.per-file-ignores]` (planning-time line 112):

```text
# File-path invocation (issue #798) needs a sys.path bootstrap before the first-party imports.
"scripts/dev_tools/validate_orchestration_artifacts.py" = ["E402"]
```

## Appendix D — RULE replacements

D1 (P4-T1). In `.claude/rules/orchestrator-state.md`, old_string is the single line `## Scope and Backward Compatibility`; new_string is the block below followed by that same line. The block is 31 lines including its trailing blank line.

```text
## Required Top-Level Keys

Plain validation requires every key below at the top level of the orchestrator-state checkpoint. The authority is `REQUIRED_STATE_KEYS` in `scripts/dev_tools/validate_orchestrator_state.py`. The TypeScript port in `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` and the PowerShell port in `.claude/lib/orchestrator-state/OrchestratorState.psm1` carry the same keys in the same order.

- `objective`
- `change_budget_estimate`
- `path_selected`
- `promotion-type`
- `short-name`
- `relativeFile`
- `long-name`
- `issue-num`
- `feature-folder`
- `work-mode`
- `plan-path`
- `completed_steps`
- `next_step`
- `last_updated`
- `step5_status`
- `step6_status`
- `step7_status`
- `step8_status`
- `step9_status`
- `step10_status`
- `delegation_receipts`
- `blocked_reason`

The check is unconditional: it runs with or without `--require-complete`, `--require-pr-creation-ready`, `--require-model-routing`, `--require-codex-model-routing`, and `--require-codex-topology`, and it is skipped only for a `portable_orchestration_handoff` envelope. The check is presence-only: a key whose value is any JSON value, including `null`, satisfies it. Each absent key produces one error line, `Checkpoint missing required key: <key>`. Some keys carry further validation when present, such as the step-status vocabulary for the `step*_status` keys and the Blocked-Reason Vocabulary below for `blocked_reason`.

`last_updated` records when the checkpoint was last written. Write it as an ISO-8601 UTC date-time string, for example `2026-10-08T17:28:00Z`. The value is rewritten on every checkpoint write: after every completed step and every state transition, including halts. The validators check presence only and do not parse the value, so a non-UTC, placeholder, or `null` value still passes the required-key check.

```

D2 (P4-T2). In `.claude/rules/orchestrator-state.md` `## Bare-Module CLI Contract`, replace this sentence (the rest of the paragraph is unchanged and stays on the same single line):

old_string:

```text
The dispatcher `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state` stays available and accepts the same flags.
```

new_string:

```text
The dispatcher stays available and accepts the same flags in two invocation forms: the module form `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state`, run from the repository root, and the file-path form `python scripts/dev_tools/validate_orchestration_artifacts.py orchestrator-state`. Both forms reach the same `main()`, so their flags, output lines, and exit codes are identical, and a relative artifact path resolves against the working directory in both. The file-path form derives the repository root from the script location and appends it to `sys.path` only when the script runs without a package context. The bare-module validator is supported in the module form only.
```

## Appendix E — SKILL and AGENT replacements

E1 (P5-T1). In `.claude/skills/orchestrate/SKILL.md` `## Checkpoint Handling`:

old_string:

```text
so a foreign one there is state a gate can answer from.
```

new_string:

```text
so a foreign one there is state a gate can answer from.
5. **Required checkpoint keys (issue #798).** Every checkpoint write carries each top-level key listed in `.claude/rules/orchestrator-state.md` under `## Required Top-Level Keys`; plain validation reports each absent key as `Checkpoint missing required key: <key>` under every flag combination. The list includes `last_updated`, an ISO-8601 UTC date-time string (for example `2026-10-08T17:28:00Z`) that is rewritten on every checkpoint write: after every completed step and every state transition, including halts.
```

E2 (P5-T2). In `.claude/skills/orchestrate/SKILL.md` `## Issue Number Consistency`:

old_string:

```text
Record as `issue_num` in the checkpoint.
```

new_string:

```text
Record as `issue-num` in the checkpoint; the hyphenated key is the one listed in `.claude/rules/orchestrator-state.md` under `## Required Top-Level Keys`.
```

E3 (P5-T4). In `.claude/agents/orchestrator.md` `## Checkpoint Persistence`:

old_string:

```text
- Variables: `promotion-type`, `short-name`, `issue-num`, `feature-folder`
- `completed_steps`, `next_step`, `last_updated`
- Step statuses: `step5_status` through `step10_status`
- `delegation_receipts`, `blocked_reason`
```

new_string:

```text
- Variables: `promotion-type`, `short-name`, `relativeFile`, `long-name`, `issue-num`, `feature-folder`, `work-mode`, `plan-path`
- `completed_steps`, `next_step`, `last_updated` (ISO-8601 UTC date-time string, rewritten on every checkpoint write)
- Step statuses: `step5_status`, `step6_status`, `step7_status`, `step8_status`, `step9_status`, `step10_status`
- `delegation_receipts`, `blocked_reason`
- The complete required-key set and the `last_updated` contract are defined in `.claude/rules/orchestrator-state.md` under `## Required Top-Level Keys`.
```

## Planner Self-Review and Internal Review Record

SELF-REVIEW: RE-DERIVED THIS PASS

Revision round 3 (deltas R2-D1 through R2-D4, plus the optional F2 approval-record note). Citations re-derived against the current worktree in this pass:

S1. `pyproject.toml` line 116 - `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"`; `-ra` is in effect for every pytest run, so P2-T1's short summary lists the three `FAILED` node IDs (R2-D1).
S2. `pyproject.toml` lines 86 and 90 - Black and Ruff target `py310`; lines 94-103 select `E`, `F`, `I`, `B`, `UP`, `S`, `TID`, `TCH`. Under `py310`, `Generator[None, None, None]` is not reported by pyupgrade's default-type-argument rule, which applies only from `py313`; `line-length = 88` (lines 85, 89) admits the 88-character `run_file_path_form` signature (R2-D2).
S3. Appendix A (this plan) - `Iterator` no longer occurs anywhere in the plan; `Generator` is imported only under `TYPE_CHECKING`, and `from __future__ import annotations` keeps the annotation unevaluated at runtime. INVOCATION-MODULE shrinks by two lines; no task asserts its exact line count (P1-T6 and P6-T13 assert at or under 500 only). Test count (`^def test_` 4) and the forbidden-pattern grep (P1-T6, P6-T13) are unchanged.
S4. Evidence accounting rule (line 19) re-checked against every multi-command task: P0-T1, P0-T3, P0-T4, P0-T5, P1-T1, P1-T2, P1-T3, P3-T2, P4-T1, P4-T3, P5-T1, P5-T3, P5-T5, P6-T11, P6-T12 (last command `git diff -U0`, exit 0), P8-T1 give 0; P1-T6, P3-T1, P4-T2, P5-T2, P5-T4, P6-T13 give 1 and state `ExpectedExitCode: 1`; P2-T1 and P2-T2 give pytest's 1; P6-T10 gives its third command's code; P3-T3 F2 ends with `wc -l` (0) (R2-D3).
S5. `docs/features/potential/promoted/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails.md`, FEATURE `spec.md`, FEATURE `issue.md`, and FEATURE `plan.2026-10-08T17-24.md` - all four exist in the worktree (P0-T3 ls-files paths, R2-D4). The ls-files command is fifth of seven in P0-T3; the last command is the issue-adoption grep.
S6. `.claude/rules/orchestrator-state.md` line 227 `## Issue-Adoption Scope and Backward Compatibility` and `.claude/skills/orchestrate/SKILL.md` line 282 `## Step S9 — CI Green Gate` - re-derived for the P0-T3 sibling greps (ADOPTION_LINE 227, S9_LINE 282); each prints one line, so P0-T3's top-level `EXIT_CODE:` is 0.
S7. `.claude/rules/python-suppressions.md` lines 15 and 17-21 - explicit user approval per suppression, after documented failed attempts naming the rule code, each approach tried, and why suppression remains; the F2 approval-record fields (`Approver:`, `Timestamp:`, `Scope:`, `Rationale:`) follow from these lines.

Sibling-region re-check for this round: P2-T1's 3-failed/1-passed split and failing-set names are unchanged by R2-D1 (only the evidence locus moved from summary lines to traceback `E` lines); P0-T7 asserts the stderr `ModuleNotFoundError` of a real interpreter run, not a pytest summary, so the 80-column limit does not apply to it; P0-T3's diff and status commands and their stop condition are unchanged; P6-T12's two `:(exclude)` pathspecs and P8-T1/P8-T2 now rest on a checked precondition; P3-T3's F2 halt path (`blocked_reason: policy_hold`) is unchanged and now treats an incomplete approval record as absent.

Revision round 2 (deltas D1-D5), carried forward and not re-derived in this pass. Citations re-derived in round 2:

R1. `scripts/dev_tools/validate_orchestration_artifacts.py` - stdlib imports lines 11-14 (`argparse`, `re`, `sys`, `pathlib.Path`); first `scripts.dev_tools` import line 16; last first-party import line 43; `__main__` guard lines 494-495; the file ends with a newline after line 495, so `wc -l` prints 495 (P0-T5, P3-T1 arithmetic 498, P6-T13).
R2. DISPATCHER import chain (P0-T7, P6-T10 under `-S`) - the six `scripts/dev_tools` modules with top-level third-party imports (`validate_discovery_schema_artifacts.py`, `validate_discovery_profile.py`, `skill_bundle_contract.py`, `quality_tiers_contract.py`, `parallel_manifest_contract.py`, `discovery/domain_profile.py`) are not named by DISPATCHER lines 16-43; `parallel_manifest_contract` is imported only by `parallel_lane_assertion.py` line 50, which no module imports.
R3. `.claude/rules/orchestrator-state.md` - file ends with a newline after line 275, so `wc -l` prints 275 (P4-T1 306, P4-T2 306); headings re-derived: `## Foreign Schema Warning (do not copy verbatim)` line 29, `## Scope and Backward Compatibility` line 35, `## Bare-Module CLI Contract` line 171, dispatcher sentence line 173, `## Issue-Adoption Scope and Backward Compatibility` line 227, `## Invariants (issue_adoption object)` line 233, `## Enforcement` line 264.
R4. Appendix D1 block - 31 lines (heading, blank, authority paragraph, blank, 22 key bullets, blank, check paragraph, blank, `last_updated` paragraph, trailing blank); inserted ahead of the Scope heading, so Scope moves 35 to 66 and Issue-Adoption 227 to 258.
R5. `.claude/skills/orchestrate/SKILL.md` - ends with a newline after line 446, so `wc -l` prints 446 (P5-T1 447 unchanged).
R6. `tests/conftest.py` - `_ensure_repo_root_on_sys_path` line 39 prepends the root with `sys.path.insert(0, ...)` at line 61, so the module-level `dispatcher` import in INVOCATION-MODULE resolves to this checkout ahead of a shared-environment `.pth` entry.
R7. `tests/__init__.py`, `tests/scripts/__init__.py`, `tests/scripts/dev_tools/__init__.py` - all absent, so no `tests/` entry is dropped by `provides_scripts_package` and a namespace portion cannot satisfy `scripts.dev_tools.epic_planner_readiness` (P2-T1 still raises `ModuleNotFoundError`).
R8. `docs/features/potential/promoted/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails.md` - exists (P6-T12 exclude pathspec, P8-T1, P8-T2).
R9. `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1` and `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1` - both exist (P0-T14, P6-T6 runner body).
R10. `tests/fixtures/orchestrator_state_remediation_loop_backcompat/no_remediation_loop.json` - exists (P6-T10 commands).
R11. `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` - D5 lines 95-105 (append, not prepend, line 102; fallback line 104; 500-line limit line 105); AC-4 text line 251 requires the root to appear exactly once and does not name a position (PD8).

Sibling-region re-check for this round: Appendix A `test_file_path_bootstrap_appends_repo_root_once` still holds (the new filter removes no root entry beyond what `resolves_to_repo_root` removed, and the bootstrap still appends last); P2-T1's 3-failed/1-passed split still holds (pre-fix, the filtered path has no regular `scripts` package); P1-T1's `^def test_` count stays 4 (the new helper is not a test); P1-T6's forbidden-pattern grep still matches nothing (`is_file` is not in the pattern set); P6-T12's SKILL and RULE hunk checks are unaffected by the new exclude pathspecs; P8-T2's expected list now names the promoted record, and its porcelain companion is unchanged.

Citations carried from round 1 and not touched by this round's edits (still listed for the bounded record; items 1, 4 except line count, 5, 7-17 and 19 were not re-derived in this pass):

1. `scripts/dev_tools/validate_orchestrator_state.py` - `REQUIRED_STATE_KEYS` lines 54-77 (22 members, `last_updated` line 68); required-key loop lines 329-331; portable-envelope skip lines 322-323.
2. `scripts/dev_tools/validate_orchestration_artifacts.py` - 495 lines; stdlib imports lines 11-14; first `scripts.dev_tools` import line 16; last first-party import line 43; `build_parser` line 195 with `orchestrator-state` subparser line 241; `main` lines 457-491; `__main__` guard lines 494-495; no `noqa`, `sys.path`, or `__package__` occurrence; `_plan_structure_errors` lines 131-192 (task-line detection rule used to keep non-task lines from starting with `- [`).
3. `.claude/rules/orchestrator-state.md` - `wc -l` 275 lines (corrected in round 2; see R3); `## Foreign Schema Warning (do not copy verbatim)` line 29; `## Scope and Backward Compatibility` line 35 (unique as a whole-line heading); `## Bare-Module CLI Contract` line 171 with the dispatcher sentence on line 173; `## Issue-Adoption Scope and Backward Compatibility` line 227; `## Invariants (issue_adoption object)` line 233; `## Enforcement` line 264; no `last_updated` occurrence.
4. `.claude/skills/orchestrate/SKILL.md` - `## Checkpoint Handling` lines 29-36 with item 4 ending "gate can answer from." on line 36 (unique); `## Issue Number Consistency` line 268; "Record as `issue_num` in the checkpoint." line 270; `<issue_num>` placeholder line 274; `## Step S9 — CI Green Gate` line 282; no `python -m scripts.` or `python scripts/` text.
5. `.claude/agents/orchestrator.md` - `## Checkpoint Persistence` lines 171-184; key bullets lines 175-179 backtick 14 keys; range wording "`step5_status` through `step10_status`" line 178 (only occurrence of `step5_status` followed by "through").
6. `tests/conftest.py` - `_ensure_repo_root_on_sys_path` lines 39-64 (prepends the root).
7. `tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py` - `runpy.run_module` precedent with the `RuntimeWarning` filter lines 352-371.
8. `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` - `test_bundled_claude_payload_contains_all_repo_runtime_contracts` line 89; `test_handoff_runtime_has_bundle_pack_and_effective_install_parity` line 126.
9. `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` - `test_every_skill_script_reference_is_bundled` line 29.
10. `scripts/dev_tools/skill_bundle_contract.py` - `PUBLISHED_ROOT_FOLDERS` line 38; invocation patterns lines 50-68 (E1 and E2 text contains no `python`, `bash`, `sh`, `source`, `&`, or dot-source token that these patterns extract).
11. `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1` - `## Checkpoint Handling` row line 78 (item 4 text retained); `## Issue Number Consistency` rows lines 116-157 (placeholder line and gate names retained).
12. `tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py` - rule-section extraction precedent lines 172-274.
13. `pyproject.toml` - Ruff `select` lines 93-103 (includes `E`, `I`, `S`); `per-file-ignores` lines 105-112 (`tests/**/*` ignores `S101`); `addopts` line 116 (LCOV only); coverage `source` line 120; `exclude_lines` lines 129-140; Pyright strict line 143.
14. `scripts/dev_tools/plan_gate_observability.py` - `black-write` markers line 166; `ruff-fix` markers line 172 (`ruff check` without `--no-fix` is treated as write mode, so each ruff task quotes "All checks passed!").
15. `tests/fixtures/orchestrator_state_remediation_loop_backcompat/no_remediation_loop.json` - committed fixture carrying all 22 keys.
16. `.gitignore` - `/artifacts` line 6.
17. `tests/__init__.py` absent; `scripts/__init__.py` and `scripts/dev_tools/__init__.py` present (a namespace `scripts` portion under `tests/` cannot shadow the regular package at the appended root).
18. `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md` - `## Acceptance Criteria` line 246; 21 `- [ ] ` items at lines 248-255, 259-269, 272-273.
19. `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`, `.../skills/orchestrate/SKILL.md`, `.../agents/orchestrator.md` - all three MIRRORS exist; no other bundle copy of RULE or AGENT exists.

Round 1 sibling-region re-check (the Scope/adoption arithmetic was re-derived again in round 2 as R3-R4): the P2-T2 expected split (37 failed, 15 passed) was re-derived from item 5 (14 backticked keys, not 18 as the research count by range implied); the P4-T1 line arithmetic (31 inserted lines, Scope 35 to 66, adoption 227 to 258, Bare-Module sentence 173 to 204) and the P5-T1 arithmetic (S9 282 to 283) were re-derived from items 3 and 4.

PLANNER-INTERNAL-REVIEW: PASS
CITATION-TO-TREE: PASS
AC-TRACEABILITY: PASS
SCOPE-BOUNDARY: PASS
CITATION: scripts/dev_tools/validate_orchestrator_state.py | REQUIRED_STATE_KEYS lines 54-77, last_updated line 68, loop lines 329-331
CITATION: scripts/dev_tools/validate_orchestration_artifacts.py | stdlib imports lines 11-14, first scripts import line 16, main lines 457-491, guard lines 494-495, 495 lines
CITATION: .claude/rules/orchestrator-state.md | 275 lines by wc -l, Foreign Schema Warning line 29, Scope line 35, Bare-Module CLI Contract line 173, Issue-Adoption line 227, issue_adoption invariants line 233
CITATION: docs/features/potential/promoted/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails.md | promoted lifecycle record committed by the preparation commit
CITATION: tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1 | PESTER-SET member run by the scratchpad runner
CITATION: .claude/skills/orchestrate/SKILL.md | Checkpoint Handling lines 29-36, issue_num sentence line 270, placeholder line 274, Step S9 line 282
CITATION: .claude/agents/orchestrator.md | Checkpoint Persistence lines 171-184, key bullets lines 175-179
CITATION: tests/conftest.py | _ensure_repo_root_on_sys_path lines 39-64
CITATION: tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py | runpy.run_module precedent lines 352-371
CITATION: tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py | bundle parity tests lines 89 and 126
CITATION: tests/scripts/dev_tools/test_skill_bundle_contract_repo.py | test_every_skill_script_reference_is_bundled line 29
CITATION: scripts/dev_tools/skill_bundle_contract.py | PUBLISHED_ROOT_FOLDERS line 38, invocation patterns lines 50-68
CITATION: tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1 | section rows lines 78 and 116-157
CITATION: pyproject.toml | ruff target-version py310 line 90, ruff select lines 93-103, per-file-ignores lines 105-112, addopts with -ra line 116, pyright strict line 143
CITATION: .claude/rules/python-suppressions.md | explicit user approval line 15, escalation path lines 17-21
CITATION: docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/issue.md | P0-T3 ls-files precondition path
CITATION: scripts/dev_tools/plan_gate_observability.py | black-write markers line 166, ruff-fix markers line 172
CITATION: tests/fixtures/orchestrator_state_remediation_loop_backcompat/no_remediation_loop.json | committed fixture with all 22 required keys
CITATION: docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md | Acceptance Criteria lines 246-273
AC-INVENTORY: AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7, AC-8, AC-9, AC-10, AC-11, AC-12, AC-13, AC-14, AC-15, AC-16, AC-17, AC-18, AC-19, AC-20, AC-21
AC-MAPPING: AC-1 | IMPLEMENTATION: P3-T1 | TESTS: P1-T1, P2-T1, P3-T4, P6-T4 | EVIDENCE: P2-T1, P3-T4, P6-T4, P7-T1
AC-MAPPING: AC-2 | IMPLEMENTATION: P3-T1 | TESTS: P1-T1, P3-T4, P6-T4 | EVIDENCE: P3-T4, P6-T4, P6-T10, P7-T2
AC-MAPPING: AC-3 | IMPLEMENTATION: P3-T1 | TESTS: P1-T1, P2-T1, P6-T4 | EVIDENCE: P2-T1, P6-T4, P7-T3
AC-MAPPING: AC-4 | IMPLEMENTATION: P3-T1 | TESTS: P1-T1, P2-T1, P6-T4 | EVIDENCE: P2-T1, P6-T4, P7-T4
AC-MAPPING: AC-5 | IMPLEMENTATION: P1-T1, P1-T2 | TESTS: P1-T6, P6-T13 | EVIDENCE: P1-T6, P6-T7, P6-T13, P7-T5
AC-MAPPING: AC-6 | IMPLEMENTATION: P3-T1, P3-T3 | TESTS: P3-T1, P6-T13 | EVIDENCE: P3-T1, P6-T13, P7-T6
AC-MAPPING: AC-7 | IMPLEMENTATION: P3-T1, P3-T3 | TESTS: P3-T2, P6-T2 | EVIDENCE: P3-T2, P3-T3, P6-T2, P6-T13, P7-T7
AC-MAPPING: AC-8 | IMPLEMENTATION: P4-T1, P4-T3 | TESTS: P1-T2, P2-T2, P5-T6 | EVIDENCE: P4-T1, P5-T6, P6-T4, P7-T8
AC-MAPPING: AC-9 | IMPLEMENTATION: P4-T1 | TESTS: P1-T2, P5-T6 | EVIDENCE: P5-T6, P6-T4, P7-T9
AC-MAPPING: AC-10 | IMPLEMENTATION: P4-T1 | TESTS: P1-T2, P2-T2, P5-T6 | EVIDENCE: P2-T2, P5-T6, P6-T4, P7-T10
AC-MAPPING: AC-11 | IMPLEMENTATION: P1-T2 | TESTS: P2-T2, P6-T4 | EVIDENCE: P2-T2, P6-T4, P7-T11
AC-MAPPING: AC-12 | IMPLEMENTATION: P5-T1, P5-T3 | TESTS: P1-T2, P5-T6, P6-T6 | EVIDENCE: P5-T1, P5-T6, P6-T6, P7-T12
AC-MAPPING: AC-13 | IMPLEMENTATION: P5-T2, P5-T3 | TESTS: P1-T2, P5-T6, P6-T6 | EVIDENCE: P5-T2, P6-T12, P7-T13
AC-MAPPING: AC-14 | IMPLEMENTATION: P5-T1, P5-T2 | TESTS: P6-T5 | EVIDENCE: P6-T5, P6-T13, P7-T14
AC-MAPPING: AC-15 | IMPLEMENTATION: P5-T4, P5-T5 | TESTS: P1-T2, P5-T6 | EVIDENCE: P5-T4, P5-T6, P6-T4, P7-T15
AC-MAPPING: AC-16 | IMPLEMENTATION: P4-T2 | TESTS: P1-T2, P5-T6 | EVIDENCE: P4-T2, P5-T6, P6-T4, P7-T16
AC-MAPPING: AC-17 | IMPLEMENTATION: P4-T1, P4-T2 | TESTS: P6-T12 | EVIDENCE: P6-T12, P7-T17
AC-MAPPING: AC-18 | IMPLEMENTATION: P4-T3, P5-T3, P5-T5 | TESTS: P6-T5 | EVIDENCE: P6-T5, P6-T11, P7-T18
AC-MAPPING: AC-19 | IMPLEMENTATION: P3-T1 | TESTS: P6-T5, P6-T7 | EVIDENCE: P6-T5, P6-T12, P7-T19
AC-MAPPING: AC-20 | IMPLEMENTATION: P3-T1 | TESTS: P6-T1, P6-T2, P6-T3, P6-T4, P6-T5, P6-T6, P6-T7, P6-T10 | EVIDENCE: P0-T13, P6-T8, P6-T9, P7-T20
AC-MAPPING: AC-21 | IMPLEMENTATION: P1-T1, P1-T2 | TESTS: P1-T6 | EVIDENCE: P1-T6, P6-T13, P7-T21
UNRESOLVED-GAPS: NONE
PREFLIGHT: ALL CLEAR
