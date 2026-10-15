# pushed-tier-rule-not-gated-on-adoption (Plan)

- **Issue:** #823
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-03 (preflight revision round 3: git grep `-x` replaced by anchored `^...$` patterns in P0-T1 and P2-T2, `npm ci` and a `node_modules/jest` presence check added to P0-T15, and `EXIT_CODE: 1` with `ExpectedExitCode: 1` stated for the ten grep-only tasks whose last grep expects no match; preflight revision round 2: delta D1-D7 applied, including the worktree `cd` prefix and the `git grep --no-index` check form; initial atomic authoring at 2026-10-03T10-15, replacing the promotion-seeded template)
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug
- **Branch:** `bug/pushed-tier-rule-not-gated-on-adoption-823`
- **Languages in scope:** Python (one new pytest module), Markdown (16 existing rule, agent, and skill files plus two potential items)
- **Requirements source (sole AC source):** `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`, section `## Acceptance Criteria` (AC1 through AC21). Decisions D1 through D9 of the same file are binding design input.
- **Design input (not a requirements source):** `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/research/research.2026-10-03.md`. Every citation this plan takes from it was re-derived against the worktree at planning time.

**Mode note (full-bug):** `spec.md` is required and present; `user-story.md` is not required and is absent. The full QA loop applies.

**Fail-closed evidence rule:** Python policy requires coverage. Baseline and final-QC coverage tasks record numeric line and branch values. No production Python line changes in this plan (the only Python file added is under `tests/`, which `[tool.coverage.run] omit` in `pyproject.toml` excludes), so the new/changed-code coverage value is recorded as the literal `N/A - no production line changed`, and that value does not trigger the fail-closed clause. No TypeScript, PowerShell, or C# production file changes; their coverage values are recorded as context only. If any required baseline artifact, final-QC artifact, or numeric coverage value is missing, the audit verdict is BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Every evidence-producing task names its artifact path. A task is not checked off until its artifact exists and carries every required field. Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. An artifact whose expected exit code is not 0 also carries `ExpectedExitCode:`. The top-level `EXIT_CODE:` of a multi-command artifact is the exit code of the task's last command other than a grep (every `git grep --no-index` check counts as a grep); a task made only of greps records the last grep's exit code. Every other command's exit code and printed value are recorded inside `Output Summary:` as `GREP value=<v> exit=<n>` (for greps) or as a quoted summary line, in command order. No planned command task may record `EXIT_CODE: SKIPPED`.

## Terms used in every task

- FEATURE means `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823`. Evidence is written only under FEATURE/evidence/baseline/, FEATURE/evidence/regression-testing/, FEATURE/evidence/qa-gates/, and FEATURE/evidence/other/. No `artifacts/` path is an evidence location. The caller supplied no non-canonical evidence path, so no override was recorded.
- TS means the execution time of the task in `yyyy-MM-ddTHH-mm` form, read from the host clock (for example `Get-Date -Format yyyy-MM-ddTHH-mm`), never composed.
- BASE_SHA means the commit recorded by P0-T3 before any edit. Every scope diff is anchored to it.
- REGRESSION-MODULE means `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` (created by P1-T1; content in Appendix A).
- CB means `extensions/drm-copilot/resources/claude-customizations` (the Claude bundle root). XB means `extensions/drm-copilot/resources/codex-and-agents-customizations` (the Codex bundle root). These abbreviations are used in prose only; every command spells the full path.
- The EIGHT repo-local files: `.claude/rules/quality-tiers.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/agents/feature-review.md`, `.claude/skills/feature-review-workflow/SKILL.md`, `.agents/skills/quality-tiers/SKILL.md`, `.agents/skills/general-code-change/SKILL.md`, `.agents/skills/general-unit-test/SKILL.md`. Their EIGHT mirrors are the same relative paths under CB (first five) and XB (last three).
- CONTRACT-SET means these eleven existing pytest files, in this order: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, `tests/scripts/dev_tools/test_codex_full_migration_inventory.py`, `tests/scripts/dev_tools/test_claude_rules_frontmatter.py`, `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py`, `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`, `tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py`, `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`, `tests/scripts/dev_tools/test_check_quality_tiers.py`, `tests/scripts/dev_tools/test_quality_tiers_contract.py`. Selection basis: research section 6 (wording, parity, and pin tests), plus `test_typescript_toolchain_instruction_contracts.py` (reads `general-unit-test.md`, `general-code-change.md`, and the two Codex general skills at lines 28-35) and the two quality-tiers suites named by spec "Test Strategy".
- KL-510 means the known local-only failure of `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` caused by gitignored machine-local state (issue #510). A failure is classified KL-510 only when its sole assertion message begins with the literal "Repo file missing from bundle:" and the named path satisfies `git check-ignore -q <path>` with exit 0. Any other failure of that test is a real failure.
- CLAUDE-PRECEDENCE means this exact sentence group (one line in the target files, ASCII apostrophes):
  "Threshold precedence: when the repository's root `CLAUDE.md` states line or branch coverage thresholds, those thresholds govern. The 85% line and 75% branch figures are defaults that apply only when the root `CLAUDE.md` states none. This precedence applies to every restatement of these figures in other rule files, agents, and skills."
- CODEX-PRECEDENCE means this exact sentence group (one line in the target files, ASCII apostrophes):
  "Threshold precedence: when the repository's root `AGENTS.md` states line or branch coverage thresholds, those thresholds govern; when `AGENTS.md` states none, thresholds stated in the repository's root `CLAUDE.md` govern. The 85% line and 75% branch figures are defaults that apply only when neither root `AGENTS.md` nor root `CLAUDE.md` states thresholds. This precedence applies to every restatement of these figures in other skills, agents, and rule files."
- TIER-FINDING means this exact text (one line in the target files):
  "Tier classification findings: report a missing or incomplete `quality-tiers.yml` only when the repository has adopted tiers, that is, when `quality-tiers.yml` exists at the repository root on the resolved base branch or the repository's CI runs a tier-classification check. Otherwise record tier classification as not applicable; it is not a finding."

## Execution constraints

- Every Bash command runs with the #823 worktree root as its working directory. The Bash tool's working directory resets to the main checkout between calls, so the executor begins every Bash command with `cd C:/Users/DanMoisan/repos/drm-copilot-wt-823 && `. Commands in this plan are written without that prefix; the executor prepends it at execution time and records each `Command:` field exactly as written in this plan, without the prefix. Artifacts never record a host path. P0-T1 confirms by branch name that the prefix reaches the #823 worktree.
- File-content checks use `git grep --no-index`, never a bare `grep`, `cat`, `head`, or `tail`: `.claude/hooks/validate-bash.ps1` (`Get-CdChainedReadCommandMatch`) denies any command line in which a `cd` segment precedes a `grep`, `cat`, `head`, `tail`, `less`, `more`, `awk`, or `sed -n` segment, and every Bash command here starts with a `cd`. The command word of `git grep` is `git`, which that function does not deny; `ls`, `wc`, `cp`, `poetry`, `npm`, and `pwsh` are likewise outside the denied family. `--no-index` searches the named working-tree files whether they are tracked or untracked. Output convention for `git grep --no-index -c`: when the match count n is 1 or more, it prints one line `<path>:<n>` and exits 0; when n is 0, it prints nothing and exits 1. In acceptance text, "prints N" for N of 1 or more means that line ends in `:N`, and "prints 0" means empty output with exit 1. `git grep --no-index -l` prints each matching path, or nothing with exit 1 when no file matches. Ad hoc reads outside the planned commands use the Read and Grep tools with absolute paths.
- The executor does not commit, stage, or push. The orchestrator commits before review. Scope checks therefore compare the working tree against BASE_SHA and pair each anchored diff with a `git status --porcelain` check.
- Markdown edits are made with the Edit tool, one exact `old_string` to `new_string` replacement per numbered replacement, copying the `old_string` from the file as it stands. Replacement text is quoted verbatim in this plan or its appendices; the executor does not compose wording. Characters to preserve: the en dash in `T1–T4`, the em dash in the tier bullet labels, and ASCII apostrophes in all new text.
- Bundle mirrors are produced only by `cp` from the edited repo-local file, never by Write or Edit.
- No command in this plan contains the words bash or wsl, and no command uses a heredoc. P0-T14 and P8-T11 run `pwsh` through the Bash tool because the executor has no PowerShell tool; if a hook denies that command text, stop and report the denial text per the next constraint.
- Edits under `.claude/` may raise a permission prompt. If a hook or permission rule denies an edit or command, stop and report the denial text. Do not bypass it.
- Commands expected to exceed about 8 minutes (the full pytest run and the extension Jest run) are run in the background; the executor waits for the completion notification before reading output.
- Files not edited (spec "Out of scope"): everything under `.github/` (D8, AC16), `scripts/dev_tools/**`, `extensions/drm-copilot/src/**`, every `pack-manifests/*.json`, `quality-tiers.yml`, `.github/workflows/_quality-checks.yml`, the language rules and QA-gate skills that restate 85/75 (D4), the Codex and Copilot feature-review surfaces, and `.claude/hooks/validate-feature-review-coverage.ps1`. If any task appears to require editing one of them, stop and report.

## Planner decisions (recorded for audit)

- PD1 - Edit authority for `.claude/rules/`. The policy-compliance-order baseline says not to modify `.claude/rules/`. Issue #823 (`issue.md` "Proposed Fix" items 1-3, authored by the repository owner) and spec D1-D3 explicitly require edits to `.claude/rules/quality-tiers.md`, `.claude/rules/general-code-change.md`, and `.claude/rules/general-unit-test.md`. The plan edits those three rule files only, and only with the text quoted here. No file under `.github/instructions/` is edited (D8).
- PD2 - Spec assertion 2 ("does not appear unconditionally") is implemented as full absence of the legacy sentence "Adding a project without a tier classification fails CI." from every scanned copy. The replacement wording ("that stage fails CI for an unclassified project") does not contain the legacy sentence, so absence is the stricter form and cannot be satisfied by a reflow.
- PD3 - AC7 reading. In `.agents/skills/general-code-change/SKILL.md` and `.agents/skills/general-unit-test/SKILL.md`, every rewritten sentence that refers to the tier skill cites `.agents/skills/quality-tiers/SKILL.md`. In `.agents/skills/quality-tiers/SKILL.md`, the rewritten applicability sentence names its own path (it begins "Applicability: this skill" followed by the path `.agents/skills/quality-tiers/SKILL.md` in parentheses; exact text in Appendix C, C1), so all three Codex skills cite the correct path and none carries `.agents/skills/quality-tiers.md`. REGRESSION-MODULE asserts both conditions for all six Codex copies.
- PD4 - Coverage command form. The full-repository coverage run is `poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`, the form CI runs (`.github/workflows/_quality-checks.yml` lines 81-84). Bare `--cov` carries no path value and takes its sources from `[tool.coverage.run] source` in `pyproject.toml` lines 119-121, so the path-form defects that rules G1-G3 report cannot occur. No per-module `--cov=<dotted>` target applies, because no production module changes. Separate line and branch percentages are read from the JSON keys `percent_statements_covered` and `percent_branches_covered` (the keys `scripts/dev_tools/check_python_coverage_thresholds.py` lines 70-71 read), because the terminal table prints one combined Cover column. The JSON file is a tool output under `artifacts/python/`, not an evidence artifact.
- PD5 - AC21 stage mapping. Format = `black --check .`; lint = `ruff check`; type check = `pyright`; architecture and contract checks = CONTRACT-SET plus REGRESSION-MODULE plus `check_quality_tiers` plus `generate_codex_agent_variants --check` (the CI steps at `_quality-checks.yml` lines 69-77); unit tests = the full pytest run with coverage, the coverage-threshold gate, the targeted Pester suite that pins `feature-review.md` text (`tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` lines 61-66), and the extension Jest suite (run because bundled payload files under `extensions/drm-copilot/resources/` change, although research section 3 found no Jest content-parity test). No TypeScript, C#, or PowerShell production file changes, so dependency-cruiser, NetArchTest, a VS Code integration-test runner (the extension's `npm run test` is the same Jest runner as `test:coverage`, per `extensions/drm-copilot/package.json` line 211), and C# suites are not triggered; this is recorded, not skipped as a planned task.
- PD5b - Spec D7 reaches only the step 5 coverage bullet of `.claude/skills/feature-review-workflow/SKILL.md`. Step 8 of the same file (line 148 at planning time) still lists "< 80% repo-wide ... < 90% for new files" as a remediation trigger. That line is outside AC9 and AC10 and is not edited; P6-T2 records it as follow-up FU-823-5.
- PD6 - The tier examples are replaced by the neutral wording quoted in Appendix B and Appendix C (spec D6). The harm-model sentences "Behavior bugs cause silent data loss, model drift, or security holes.", "Bugs cause feature regressions but not data loss.", and "Glue around APIs the team does not own." are kept verbatim.
- PD7 - `description:` frontmatter values of the three Claude rules and the three Codex skills are unchanged; `paths:` blocks are unchanged.

### Phase 0 — Policy Reads and Baseline Capture

- [x] [P0-T1] Verify the full-bug preconditions for FEATURE (`docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`, `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/issue.md`) and record FEATURE/evidence/baseline/phase0-mode-check.TS.md.
      Commands: `git branch --show-current`; `ls docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823`; `git grep --no-index -c "^## Acceptance Criteria$" -- docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`; `git grep --no-index -c "^- \[ \] AC[0-9]" -- docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`; `git grep --no-index -c -F "Work Mode: full-bug" -- docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/issue.md`.
      Acceptance: the branch command prints exactly `bug/pushed-tier-rule-not-gated-on-adoption-823`. Any other value stops the plan, because relative-path commands would act on another checkout. Git does not allow one branch to be checked out in two worktrees, so this value identifies the #823 worktree without recording a host path. The listing contains `spec.md` and `issue.md` and does not contain `user-story.md`; the first grep prints 1; the AC grep prints 21; the work-mode grep prints 1. Any other result stops the plan.
- [x] [P0-T2] Read the policy files in the required order and record FEATURE/evidence/baseline/phase0-instructions-read.md (`docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/evidence/baseline/phase0-instructions-read.md`) with `Timestamp:`, `Policy Order:`, and the list of files read, in this order: (1) `.github/copilot-instructions.md`, `CLAUDE.md`, `.claude/rules/tonality.md`; (2) `.github/instructions/general-code-change.instructions.md`, `.claude/rules/general-code-change.md`; (3) `.github/instructions/general-unit-test.instructions.md`, `.claude/rules/general-unit-test.md`; (4) `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`; (5) `.claude/rules/quality-tiers.md`, `.claude/rules/plan-acceptance-gates.md`; (6) `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
      Acceptance: the artifact has the three required headers and lists all 14 files in that order.
- [x] [P0-T3] Record BASE_SHA and the clean pre-edit state of every path this plan edits or creates (`.claude/rules`, `.claude/agents/feature-review.md`, `.claude/skills/feature-review-workflow`, `.agents/skills/quality-tiers`, `.agents/skills/general-code-change`, `.agents/skills/general-unit-test`, their bundle mirrors, `tests/scripts/dev_tools`, `docs/features/potential/2026-09-29-issue-734-quality-tiers-follow-ups.md`), and record FEATURE/evidence/baseline/base-sha.TS.md.
      Commands: `git rev-parse HEAD`; `git status --porcelain -- .claude/rules .claude/agents/feature-review.md .claude/skills/feature-review-workflow .agents/skills/quality-tiers .agents/skills/general-code-change .agents/skills/general-unit-test extensions/drm-copilot/resources/claude-customizations/.claude/rules extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-code-change extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test tests/scripts/dev_tools docs/features/potential/2026-09-29-issue-734-quality-tiers-follow-ups.md docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md`.
      Acceptance: `git rev-parse HEAD` prints one 40-character SHA, recorded as BASE_SHA; the status command prints nothing. Any output from the status command stops the plan, because the baseline would not measure committed content.
- [x] [P0-T4] Baseline mirror identity for the eight repo-local files and their bundle mirrors (CB and XB paths named in each command), and record FEATURE/evidence/baseline/mirror-identity.TS.md.
      Commands (one per pair): `git diff --no-index --exit-code .claude/rules/quality-tiers.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md`; `git diff --no-index --exit-code .claude/rules/general-code-change.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-code-change.md`; `git diff --no-index --exit-code .claude/rules/general-unit-test.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md`; `git diff --no-index --exit-code .claude/agents/feature-review.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md`; `git diff --no-index --exit-code .claude/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`; `git diff --no-index --exit-code .agents/skills/quality-tiers/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md`; `git diff --no-index --exit-code .agents/skills/general-code-change/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-code-change/SKILL.md`; `git diff --no-index --exit-code .agents/skills/general-unit-test/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md`.
      Acceptance: each of the eight commands exits 0 and prints nothing. An unequal pair stops the plan, because the P1-T3 failure enumeration assumes identical pairs and each later copy must be a pure sync.
- [x] [P0-T5] Baseline format check over the repository (`pyproject.toml` `[tool.black]`), and record FEATURE/evidence/baseline/black-check.TS.md.
      Command: `poetry run black --check .`.
      Acceptance: exit 0 and the summary line containing "would be left unchanged" are recorded. A non-zero exit is recorded verbatim and stops the plan, because AC21 would then require out-of-scope formatting work.
- [x] [P0-T6] Baseline lint (`pyproject.toml` `[tool.ruff]`), and record FEATURE/evidence/baseline/ruff-check.TS.md.
      Command: `poetry run ruff check`.
      Acceptance: exit 0 and the line "All checks passed!" are recorded. A non-zero exit is recorded verbatim and stops the plan.
- [x] [P0-T7] Baseline type check (`pyproject.toml` `[tool.pyright]`), and record FEATURE/evidence/baseline/pyright.TS.md.
      Command: `poetry run pyright`.
      Acceptance: exit 0 and the summary line beginning "0 errors" are recorded. A non-zero exit is recorded verbatim and stops the plan.
- [x] [P0-T8] Baseline tier classification for this repository (`scripts/dev_tools/check_quality_tiers.py`, `quality-tiers.yml`), and record FEATURE/evidence/baseline/check-quality-tiers.TS.md.
      Command: `poetry run python -m scripts.dev_tools.check_quality_tiers`.
      Acceptance: exit 0 and the printed line beginning "quality-tiers: OK" (entry count included) are recorded. Any other result stops the plan.
- [x] [P0-T9] Baseline Codex agent deployment-profile check (`scripts/dev_tools/generate_codex_agent_variants.py`), and record FEATURE/evidence/baseline/codex-agent-variants.TS.md.
      Command: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`.
      Acceptance: exit 0 and empty stdout and stderr are recorded (the module prints nothing on success; drift messages go to stderr). A non-zero exit stops the plan.
- [x] [P0-T10] Baseline CONTRACT-SET run (the eleven files under `tests/scripts/dev_tools/` named in Terms), and record FEATURE/evidence/baseline/contract-set-pytest.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_codex_full_migration_inventory.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_check_quality_tiers.py tests/scripts/dev_tools/test_quality_tiers_contract.py`.
      Acceptance: the exit code and the pytest summary line (passed and failed counts) are recorded; the passed count is recorded as BASELINE_CONTRACT_PASSED. A failure classified KL-510 is recorded as `KL-510: STATE-ONLY` with `ExpectedExitCode: 1`. Any other failure stops the plan.
- [x] [P0-T11] Baseline full pytest run in coverage mode (`tests/`, sources from `pyproject.toml` `[tool.coverage.run]`), run in the background, and record FEATURE/evidence/baseline/pytest-full-coverage.TS.md.
      Execution note: the background instruction (here, P0-T15, P8-T8, P8-T12, and Execution constraints) was superseded by orchestrator directive; all commands ran in the foreground.
      Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`.
      Acceptance: the exit code, the pytest summary line, the verbatim `TOTAL` row of the terminal coverage table, and every `FAILED` line are recorded; the passed count is recorded as BASELINE_FULL_PASSED. Failures classified KL-510 are recorded as `KL-510: STATE-ONLY` (with `ExpectedExitCode: 1` when they are the only failures). Any other failure is recorded verbatim as the pre-existing failure set and stops the plan, because AC21 would then be unattainable without out-of-scope work.
- [x] [P0-T12] Baseline numeric line and branch coverage from the P0-T11 JSON report (`artifacts/python/coverage.json`), and record FEATURE/evidence/baseline/python-coverage-values.TS.md.
      Command: `poetry run python -c "import json, pathlib; t = json.loads(pathlib.Path('artifacts/python/coverage.json').read_text(encoding='utf-8'))['totals']; print('LINE', round(t['percent_statements_covered'], 2), 'BRANCH', round(t['percent_branches_covered'], 2), 'COMBINED', round(t['percent_covered'], 2))"`.
      Acceptance: exit 0 and one printed line of the form `LINE <n> BRANCH <n> COMBINED <n>`; the three numbers are recorded as BASELINE_LINE, BASELINE_BRANCH, and BASELINE_COMBINED in `Output Summary:`. An empty output or a non-numeric value stops the plan.
- [x] [P0-T13] Baseline coverage-threshold gate over the P0-T11 JSON report (`scripts/dev_tools/check_python_coverage_thresholds.py`), and record FEATURE/evidence/baseline/python-coverage-gate.TS.md.
      Command: `poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 85 --min-branch 75`.
      Acceptance: exit 0 is recorded (the script prints nothing on success and prints a breach message to stderr on failure). A non-zero exit stops the plan.
- [x] [P0-T14] Baseline targeted Pester run of the suite that pins `feature-review.md` text (`tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`), executed through the Bash tool, and record FEATURE/evidence/baseline/pester-claude-architecture-doc.TS.md.
      Command: `pwsh -NoProfile -Command '$r = Invoke-Pester -Path "tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1" -PassThru -Output Detailed; "Passed=$($r.PassedCount) Failed=$($r.FailedCount)"'`.
      Acceptance: the printed `Passed=<n> Failed=<n>` line is recorded (planning-time observation: Passed=6 Failed=0); `EXIT_CODE:` is recorded as 0 when Failed is 0 and as 1 otherwise. Failed must be 0; any failure stops the plan. PowerShell coverage is recorded as `N/A - no PowerShell file changes`.
- [x] [P0-T15] Baseline extension Jest suite in coverage mode (`extensions/drm-copilot/package.json` script `test:coverage`), run in the background, and record FEATURE/evidence/baseline/jest-extension-coverage.TS.md.
      Commands: `npm --prefix extensions/drm-copilot ci`; `ls -d extensions/drm-copilot/node_modules/jest`; `npm --prefix extensions/drm-copilot run test:coverage`.
      Acceptance: The install command exits 0 (its exit code and final summary line are recorded in `Output Summary:`); the `ls -d` command exits 0 and prints one line naming `extensions/drm-copilot/node_modules/jest`; either failing stops the plan. The artifact's top-level `EXIT_CODE:` is the `test:coverage` exit code. Rationale: `extensions/drm-copilot/node_modules` is gitignored and absent in this worktree, and CI runs `npm ci` before the Jest run. For `test:coverage`, the exit code, the Jest `Tests:` summary line, and the text-summary lines beginning `Statements`, `Branches`, and `Lines` are recorded, with the Lines and Branches percentages as BASELINE_TS_LINES and BASELINE_TS_BRANCHES. A non-zero exit is recorded verbatim with every failing test name and stops the plan.

### Phase 1 — Regression Test First (Expect-Fail)

Each task in this phase writes FEATURE/evidence/other/p1-tN.TS.md (N is the task number) unless the task names a different artifact.

- [x] [P1-T1] Create REGRESSION-MODULE (`tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`) with exactly the content of Appendix A (Write tool, LF line endings), and record FEATURE/evidence/other/p1-t1.TS.md.
      Commands: `git grep --no-index -c "^def test_" -- tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`; `git grep --no-index -c -E "tempfile|tmp_path|subprocess|os\.system|Popen|\.touch\(" -- tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`; `wc -l tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`; `poetry run pytest tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py --collect-only -q`; `git status --porcelain -- tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`.
      Acceptance: the `def test_` grep prints 17; the forbidden-pattern grep prints 0 (exit 1 is the pass condition here); the line count is at most 500 (463 expected); the collection run prints "80 tests collected" and exits 0; the status line shows the file as untracked (`??`).
- [x] [P1-T2] Format, lint, and type-check REGRESSION-MODULE (`tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`) before its first run, and record FEATURE/evidence/other/p1-t2.TS.md.
      Commands: `poetry run black tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`; `poetry run black --check tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`; `poetry run ruff check tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`; `poetry run pyright tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`.
      Acceptance: the first black command exits 0 and its output ("1 file left unchanged." or "1 file reformatted.") is recorded verbatim; the `--check` command exits 0 and prints "1 file would be left unchanged."; ruff exits 0 and prints "All checks passed!"; pyright exits 0 and prints a summary line beginning "0 errors". A ruff or pyright finding is fixed in REGRESSION-MODULE only, without changing any assertion literal or test name, and this task is rerun from its first command.
- [x] [P1-T3] [expect-fail] Run REGRESSION-MODULE (`tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`) against the unmodified rule text and record FEATURE/evidence/regression-testing/expect-fail-tier-rule-adoption-gate.TS.md with `ExpectedExitCode: 1`.
      Commands: `git status --porcelain -- .claude/rules .claude/agents/feature-review.md .claude/skills/feature-review-workflow .agents/skills/quality-tiers .agents/skills/general-code-change .agents/skills/general-unit-test extensions/drm-copilot/resources/claude-customizations/.claude/rules extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-code-change extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test`; `poetry run pytest tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`.
      Acceptance: the status command prints nothing (no rule, agent, skill, or mirror file has changed yet); pytest exits 1 and its summary line reports exactly 52 failed and 28 passed. The failing set, by test function, is exactly: `test_copy_omits_legacy_classification_sentence` for the four `general-code-change` copies (4); `test_copy_omits_unconditional_ci_sentence` for the four `quality-tiers` copies (4); every case of `test_quality_tiers_preamble_states_adoption_gate` (4), `test_quality_tiers_copy_drops_repo_scope_phrase` (4), `test_quality_tiers_copy_names_no_consuming_product` (4), `test_general_code_change_tier_section_is_conditional` (4), `test_general_unit_test_copy_drops_repo_scope_phrase` (4), `test_unit_test_categories_gate_tier_obligations` (4), `test_claude_copy_states_claude_md_precedence` (4), `test_codex_copy_states_agents_md_precedence` (4), `test_codex_skill_copy_cites_existing_tier_skill` (6), `test_feature_review_copy_gates_tier_finding` (4), and `test_review_agent_copy_uses_governing_thresholds` (2). The passing set is `test_every_scanned_copy_exists`, the 12 other cases of each of the two sentence tests, and the three negative-control tests. Every `FAILED` line of the `-ra` short summary is recorded. Any other pass/fail split stops the plan. Derivation: the legacy classification sentence is at `.claude/rules/general-code-change.md` line 29 and `.agents/skills/general-code-change/SKILL.md` line 32; the legacy CI sentence is at `.claude/rules/quality-tiers.md` lines 9 and 21 and `.agents/skills/quality-tiers/SKILL.md` lines 12 and 24; "TaskMaster" is at quality-tiers lines 14 (Claude) and 17 (Codex); "in this repository" is at quality-tiers lines 9 and 51 (Claude) and 12 and 54 (Codex); "not used in this repository" is at general-unit-test line 26 (Claude) and 29 (Codex); "uniform tier rule" is at `.claude/agents/feature-review.md` line 119 and `.claude/skills/feature-review-workflow/SKILL.md` line 111; "below 80%" and "below 90%" are at `.claude/agents/feature-review.md` lines 137-139; none of the copies carries "Threshold precedence:", the adoption-gate fragments, or `.agents/skills/quality-tiers/SKILL.md`; mirrors are identical per P0-T4.
      Restart carve-out: this planned red state does not trigger the restart rule. The restart rule applies from Phase 8.

### Phase 2 — Claude Rule Edits (Repo-Local)

Each task in this phase writes FEATURE/evidence/other/p2-tN.TS.md. Line numbers are planning-time values and serve only to locate the quoted `old_string`.

- [x] [P2-T1] Update `.claude/rules/quality-tiers.md` with replacements B1 through B5 of Appendix B (adoption gate under the H1, neutral tier examples, conditional Source of Truth, CLAUDE-PRECEDENCE in the Uniform section, Rationale sentence).
      Commands: `git grep --no-index -c -F "Applicability: this rule applies only when" -- .claude/rules/quality-tiers.md`; `git grep --no-index -c -F "Threshold precedence: when the repository's root" -- .claude/rules/quality-tiers.md`; `git grep --no-index -c -F "maps every project to one tier" -- .claude/rules/quality-tiers.md`; `git grep --no-index -c -F "Behavior bugs cause silent data loss, model drift, or security holes." -- .claude/rules/quality-tiers.md`; `git grep --no-index -c -F "description: Module rigor tier system and uniform coverage thresholds." -- .claude/rules/quality-tiers.md`; `git grep --no-index -c -F "TaskMaster" -- .claude/rules/quality-tiers.md`; `git grep --no-index -c -F "in this repository" -- .claude/rules/quality-tiers.md`; `git grep --no-index -c -F "Adding a project without" -- .claude/rules/quality-tiers.md`.
      Acceptance: the first five greps each print 1; the last three each print 0 (exit 1 is the pass condition for each of them). The artifact records `EXIT_CODE: 1` with `ExpectedExitCode: 1` (the last grep's exit code).
- [x] [P2-T2] Update `.claude/rules/general-code-change.md` with replacement GCC-1 of Appendix B (the `## Module Rigor Tiers` paragraph, planning-time line 29).
      Commands: `git grep --no-index -c -F "has not adopted tiers" -- .claude/rules/general-code-change.md`; `git grep --no-index -c "^## Module Rigor Tiers$" -- .claude/rules/general-code-change.md`; `git grep --no-index -c -F "Every project must be classified" -- .claude/rules/general-code-change.md`.
      Acceptance: the first two greps each print 1; the third prints 0 (exit 1 is the pass condition here). The artifact records `EXIT_CODE: 1` with `ExpectedExitCode: 1` (the last grep's exit code).
- [x] [P2-T3] Update `.claude/rules/general-unit-test.md` with replacements GUT-1, GUT-2, and GUT-3 of Appendix B (CLAUDE-PRECEDENCE bullet, Coverage Requirements tier sentence, Test Categories introduction).
      Commands: `git grep --no-index -c -F "Threshold precedence: when the repository's root" -- .claude/rules/general-unit-test.md`; `git grep --no-index -c -F "for the full tier system, which applies only when" -- .claude/rules/general-unit-test.md`; `git grep --no-index -c -F "tier-dependent obligations apply only when" -- .claude/rules/general-unit-test.md`; `git grep --no-index -c -F "not used in this repository" -- .claude/rules/general-unit-test.md`.
      Acceptance: the first three greps each print 1; the fourth prints 0 (exit 1 is the pass condition here). The artifact records `EXIT_CODE: 1` with `ExpectedExitCode: 1` (the last grep's exit code).

### Phase 3 — Codex Skill Edits (Repo-Local)

Each task in this phase writes FEATURE/evidence/other/p3-tN.TS.md.

- [x] [P3-T1] Update `.agents/skills/quality-tiers/SKILL.md` with replacements C1 through C5 of Appendix C (adoption gate naming `.agents/skills/quality-tiers/SKILL.md`, neutral tier examples, conditional Source of Truth, CODEX-PRECEDENCE, Rationale sentence).
      Commands: `git grep --no-index -c -F "Applicability: this skill (" -- .agents/skills/quality-tiers/SKILL.md`; `git grep --no-index -c -F "neither root" -- .agents/skills/quality-tiers/SKILL.md`; `git grep --no-index -c -F "quality-tiers/SKILL.md" -- .agents/skills/quality-tiers/SKILL.md`; `git grep --no-index -c -F "Source: legacy Claude rule" -- .agents/skills/quality-tiers/SKILL.md`; `git grep --no-index -c -F "TaskMaster" -- .agents/skills/quality-tiers/SKILL.md`; `git grep --no-index -c -F "in this repository" -- .agents/skills/quality-tiers/SKILL.md`; `git grep --no-index -c -F "Adding a project without" -- .agents/skills/quality-tiers/SKILL.md`.
      Acceptance: the first four greps each print 1; the last three each print 0 (exit 1 is the pass condition for each of them). The artifact records `EXIT_CODE: 1` with `ExpectedExitCode: 1` (the last grep's exit code).
- [x] [P3-T2] Update `.agents/skills/general-code-change/SKILL.md` with replacement XGCC-1 of Appendix C (planning-time line 32).
      Commands: `git grep --no-index -c -F "has not adopted tiers" -- .agents/skills/general-code-change/SKILL.md`; `git grep --no-index -c -F "quality-tiers/SKILL.md" -- .agents/skills/general-code-change/SKILL.md`; `git grep --no-index -c -F ".agents/skills/quality-tiers.md" -- .agents/skills/general-code-change/SKILL.md`; `git grep --no-index -c -F "Every project must be classified" -- .agents/skills/general-code-change/SKILL.md`.
      Acceptance: the first two greps each print 1; the last two each print 0 (exit 1 is the pass condition for each of them). The artifact records `EXIT_CODE: 1` with `ExpectedExitCode: 1` (the last grep's exit code).
- [x] [P3-T3] Update `.agents/skills/general-unit-test/SKILL.md` with replacements XGUT-1, XGUT-2, and XGUT-3 of Appendix C (CODEX-PRECEDENCE bullet, planning-time lines 29 and 92).
      Commands: `git grep --no-index -c -F "Threshold precedence: when the repository's root" -- .agents/skills/general-unit-test/SKILL.md`; `git grep --no-index -c -F "neither root" -- .agents/skills/general-unit-test/SKILL.md`; `git grep --no-index -c -F "quality-tiers/SKILL.md" -- .agents/skills/general-unit-test/SKILL.md`; `git grep --no-index -c -F ".agents/skills/quality-tiers.md" -- .agents/skills/general-unit-test/SKILL.md`; `git grep --no-index -c -F "not used in this repository" -- .agents/skills/general-unit-test/SKILL.md`.
      Acceptance: the first two greps each print 1; the third prints 2; the last two each print 0 (exit 1 is the pass condition for each of them). The artifact records `EXIT_CODE: 1` with `ExpectedExitCode: 1` (the last grep's exit code).

### Phase 4 — Feature-Review Guidance Edits (Repo-Local, Claude Only)

Each task in this phase writes FEATURE/evidence/other/p4-tN.TS.md.

- [x] [P4-T1] Update the `### Coverage Thresholds` section of `.claude/agents/feature-review.md` with replacements FR-1 and FR-2 of Appendix B (precedence citation replacing planning-time line 119; TIER-FINDING paragraph after planning-time line 125).
      Commands: `git grep --no-index -c -F "Coverage thresholds follow the threshold precedence" -- .claude/agents/feature-review.md`; `git grep --no-index -c -F "record tier classification as not applicable" -- .claude/agents/feature-review.md`; `git grep --no-index -c -F "version folder" -- .claude/agents/feature-review.md`; `git grep --no-index -c -F "uniform tier rule" -- .claude/agents/feature-review.md`.
      Acceptance: the first two greps each print 1; the third prints 1 or more (phrase pinned by `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` line 65); the fourth prints 0 (exit 1 is the pass condition here). The artifact records `EXIT_CODE: 1` with `ExpectedExitCode: 1` (the last grep's exit code).
- [x] [P4-T2] Update the `### Verification Procedure` section of `.claude/agents/feature-review.md` with replacement FR-3 of Appendix B (planning-time lines 137-139).
      Commands: `git grep --no-index -c -F "governing repo-wide threshold" -- .claude/agents/feature-review.md`; `git grep --no-index -c -F "below 80" -- .claude/agents/feature-review.md`; `git grep --no-index -c -F "below 90" -- .claude/agents/feature-review.md`.
      Acceptance: the first grep prints 1; the second and third each print 0 (exit 1 is the pass condition for each of them). The artifact records `EXIT_CODE: 1` with `ExpectedExitCode: 1` (the last grep's exit code).
- [x] [P4-T3] Update the step 5 coverage-threshold bullet of `.claude/skills/feature-review-workflow/SKILL.md` with replacement FRW-1 of Appendix B (planning-time line 111; only the leading parenthetical sentence changes).
      Commands: `git grep --no-index -c -F "Coverage thresholds (threshold precedence per" -- .claude/skills/feature-review-workflow/SKILL.md`; `git grep --no-index -c -F "Do not flag a missing PowerShell branch figure as FAIL:" -- .claude/skills/feature-review-workflow/SKILL.md`; `git grep --no-index -c -F "uniform tier rule" -- .claude/skills/feature-review-workflow/SKILL.md`.
      Acceptance: the first two greps each print 1; the third prints 0 (exit 1 is the pass condition here). The artifact records `EXIT_CODE: 1` with `ExpectedExitCode: 1` (the last grep's exit code).
- [x] [P4-T4] Insert the TIER-FINDING bullet into step 5 of `.claude/skills/feature-review-workflow/SKILL.md` with replacement FRW-2 of Appendix B (after planning-time line 116).
      Commands: `git grep --no-index -c -F "record tier classification as not applicable" -- .claude/skills/feature-review-workflow/SKILL.md`; `git grep --no-index -c -F "coverage verification is mandatory for all languages with changed files" -- .claude/skills/feature-review-workflow/SKILL.md`.
      Acceptance: the first grep prints 1; the second prints 1 or more (the anchor line is unchanged).

### Phase 5 — Bundled Mirrors (Byte Copies)

Each task in this phase writes FEATURE/evidence/other/p5-tN.TS.md. Each task's last command is `git status`, so its exit code is the artifact's top-level `EXIT_CODE:`.

- [x] [P5-T1] Update `extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md` by byte copy from `.claude/rules/quality-tiers.md`.
      Commands: `cp .claude/rules/quality-tiers.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md`; `git diff --no-index --exit-code .claude/rules/quality-tiers.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md`; `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md`.
      Acceptance: cp exits 0; the diff exits 0 and prints nothing; the status line shows the mirror modified (` M`).
- [x] [P5-T2] Update `extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-code-change.md` by byte copy from `.claude/rules/general-code-change.md`.
      Commands: `cp .claude/rules/general-code-change.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-code-change.md`; `git diff --no-index --exit-code .claude/rules/general-code-change.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-code-change.md`; `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-code-change.md`.
      Acceptance: cp exits 0; the diff exits 0 and prints nothing; the status line shows the mirror modified.
- [x] [P5-T3] Update `extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md` by byte copy from `.claude/rules/general-unit-test.md`.
      Commands: `cp .claude/rules/general-unit-test.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md`; `git diff --no-index --exit-code .claude/rules/general-unit-test.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md`; `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md`.
      Acceptance: cp exits 0; the diff exits 0 and prints nothing; the status line shows the mirror modified.
- [x] [P5-T4] Update `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md` by byte copy from `.claude/agents/feature-review.md`.
      Commands: `cp .claude/agents/feature-review.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md`; `git diff --no-index --exit-code .claude/agents/feature-review.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md`; `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md`.
      Acceptance: cp exits 0; the diff exits 0 and prints nothing; the status line shows the mirror modified.
- [x] [P5-T5] Update `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md` by byte copy from `.claude/skills/feature-review-workflow/SKILL.md`.
      Commands: `cp .claude/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`; `git diff --no-index --exit-code .claude/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`; `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`.
      Acceptance: cp exits 0; the diff exits 0 and prints nothing; the status line shows the mirror modified.
- [x] [P5-T6] Update `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md` by byte copy from `.agents/skills/quality-tiers/SKILL.md`.
      Commands: `cp .agents/skills/quality-tiers/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md`; `git diff --no-index --exit-code .agents/skills/quality-tiers/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md`; `git status --porcelain -- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md`.
      Acceptance: cp exits 0; the diff exits 0 and prints nothing; the status line shows the mirror modified.
- [x] [P5-T7] Update `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-code-change/SKILL.md` by byte copy from `.agents/skills/general-code-change/SKILL.md`.
      Commands: `cp .agents/skills/general-code-change/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-code-change/SKILL.md`; `git diff --no-index --exit-code .agents/skills/general-code-change/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-code-change/SKILL.md`; `git status --porcelain -- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-code-change/SKILL.md`.
      Acceptance: cp exits 0; the diff exits 0 and prints nothing; the status line shows the mirror modified.
- [x] [P5-T8] Update `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md` by byte copy from `.agents/skills/general-unit-test/SKILL.md`.
      Commands: `cp .agents/skills/general-unit-test/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md`; `git diff --no-index --exit-code .agents/skills/general-unit-test/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md`; `git status --porcelain -- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md`.
      Acceptance: cp exits 0; the diff exits 0 and prints nothing; the status line shows the mirror modified.

### Phase 6 — Potential Items

Each task in this phase writes FEATURE/evidence/other/p6-tN.TS.md.

- [x] [P6-T1] Update `docs/features/potential/2026-09-29-issue-734-quality-tiers-follow-ups.md` with insertions PI-1 and PI-2 of Appendix D (FU-734-1 resolved for the #823 Codex sentences; FU-734-4 superseded by #823).
      Commands: `git grep --no-index -c -F "Resolved by #823" -- docs/features/potential/2026-09-29-issue-734-quality-tiers-follow-ups.md`; `git grep --no-index -c -F "Superseded by #823" -- docs/features/potential/2026-09-29-issue-734-quality-tiers-follow-ups.md`; `git grep --no-index -c "^## FU-734-" -- docs/features/potential/2026-09-29-issue-734-quality-tiers-follow-ups.md`.
      Acceptance: the first two greps each print 1; the heading grep prints 4 (no entry added or removed).
- [x] [P6-T2] Create `docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md` with exactly the content of Appendix D, block PI-3 (spec follow-ups F1-F4 as FU-823-1 through FU-823-4, plus FU-823-5 from PD5b).
      Commands: `git grep --no-index -c "^## FU-823-" -- docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md`; `git grep --no-index -c -F "(spec F" -- docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md`; `git status --porcelain -- docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md`.
      Acceptance: the heading grep prints 5; the spec-reference grep prints 4; the status line shows the file as untracked (`??`).

### Phase 7 — Pass-After Verification

- [x] [P7-T1] Pass-after gate: run REGRESSION-MODULE (`tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`) after every rule, agent, skill, and mirror edit, and record FEATURE/evidence/regression-testing/pass-after-tier-rule-adoption-gate.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`.
      Acceptance: exit 0 and a summary line reporting 80 passed and no failed. A failure is fixed by correcting the edited Markdown to the quoted Appendix text (and re-copying the mirror), never by changing REGRESSION-MODULE; the affected Phase 2-5 task and this task are then rerun.
- [x] [P7-T2] Verify that no edited pushed file names a consuming product or carries a templating marker (the 16 edited files), and record FEATURE/evidence/other/p7-t2.TS.md.
      Commands: `git grep --no-index -l -F "TaskMaster" -- .claude/rules/quality-tiers.md .claude/rules/general-code-change.md .claude/rules/general-unit-test.md .claude/agents/feature-review.md .claude/skills/feature-review-workflow/SKILL.md .agents/skills/quality-tiers/SKILL.md .agents/skills/general-code-change/SKILL.md .agents/skills/general-unit-test/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-code-change.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-code-change/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md`; the same `git grep --no-index -l -F` form with the pattern `{{` over the same 16 files.
      Acceptance: each grep prints nothing and exits 1 (exit 1 with empty output is the pass condition for each). Planning-time values: "TaskMaster" occurs only in the four quality-tiers copies (removed by P2-T1, P3-T1, P5-T1, P5-T6); `{{` occurs in none of the 16 files. The artifact records `EXIT_CODE: 1` with `ExpectedExitCode: 1` (the last grep's exit code).

### Phase 8 — Final QC Loop

Restart rule: run P8-T1 through P8-T12 in order. If any of them fails, or if any step changes a tracked or new file, fix the cause, then restart from P8-T1 and rewrite every Phase 8 artifact with a new TS. The loop ends only when P8-T1 through P8-T12 pass in one uninterrupted pass. When `poetry run black --check .` fails, the fix is `poetry run black` on the files it names, followed by a restart. Each artifact records its loop iteration number in `Output Summary:`.

- [x] [P8-T1] Format check (`pyproject.toml` `[tool.black]`), and record FEATURE/evidence/qa-gates/black-check.TS.md.
      Command: `poetry run black --check .`.
      Acceptance: exit 0 and the summary line containing "would be left unchanged" (and no line containing "would reformat").
- [x] [P8-T2] Lint (`pyproject.toml` `[tool.ruff]`), and record FEATURE/evidence/qa-gates/ruff-check.TS.md.
      Command: `poetry run ruff check`.
      Acceptance: exit 0 and the line "All checks passed!".
- [x] [P8-T3] Type check (`pyproject.toml` `[tool.pyright]`), and record FEATURE/evidence/qa-gates/pyright.TS.md.
      Command: `poetry run pyright`.
      Acceptance: exit 0 and a summary line beginning "0 errors".
- [x] [P8-T4] Tier classification for this repository (`scripts/dev_tools/check_quality_tiers.py`, `quality-tiers.yml`), and record FEATURE/evidence/qa-gates/check-quality-tiers.TS.md.
      Command: `poetry run python -m scripts.dev_tools.check_quality_tiers`.
      Acceptance: exit 0 and the printed line beginning "quality-tiers: OK" with the same entry count as P0-T8.
- [x] [P8-T5] Codex agent deployment-profile check (`scripts/dev_tools/generate_codex_agent_variants.py`), and record FEATURE/evidence/qa-gates/codex-agent-variants.TS.md.
      Command: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`.
      Acceptance: exit 0.
- [x] [P8-T6] REGRESSION-MODULE run (`tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`), and record FEATURE/evidence/qa-gates/regression-module-pytest.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`.
      Acceptance: exit 0 and a summary line reporting 80 passed and no failed.
- [x] [P8-T7] CONTRACT-SET run (the eleven files under `tests/scripts/dev_tools/` named in Terms), and record FEATURE/evidence/qa-gates/contract-set-pytest.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_codex_full_migration_inventory.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_check_quality_tiers.py tests/scripts/dev_tools/test_quality_tiers_contract.py`.
      Acceptance: no failed test other than a KL-510 failure (recorded as `KL-510: STATE-ONLY` with `ExpectedExitCode: 1` when it is the only failure; otherwise exit 0); the passed count equals BASELINE_CONTRACT_PASSED plus the number of KL-510 failures in P0-T10 minus the number of KL-510 failures in this run (no test was added or removed in these files).
- [x] [P8-T8] Full pytest run in coverage mode (`tests/`, sources from `pyproject.toml` `[tool.coverage.run]`), run in the background, and record FEATURE/evidence/qa-gates/pytest-full-coverage.TS.md.
      Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`.
      Acceptance: no failed test other than KL-510 failures (recorded as in P8-T7; otherwise exit 0); the summary line, the verbatim `TOTAL` row, and the passed count are recorded; the passed count equals BASELINE_FULL_PASSED plus 80, plus the number of KL-510 failures in P0-T11 minus the number of KL-510 failures in this run.
- [x] [P8-T9] Post-change numeric line and branch coverage from the P8-T8 JSON report (`artifacts/python/coverage.json`), and record FEATURE/evidence/qa-gates/python-coverage-values.TS.md.
      Command: `poetry run python -c "import json, pathlib; t = json.loads(pathlib.Path('artifacts/python/coverage.json').read_text(encoding='utf-8'))['totals']; print('LINE', round(t['percent_statements_covered'], 2), 'BRANCH', round(t['percent_branches_covered'], 2), 'COMBINED', round(t['percent_covered'], 2))"`.
      Acceptance: exit 0 and one line `LINE <n> BRANCH <n> COMBINED <n>`, recorded as FINAL_LINE, FINAL_BRANCH, FINAL_COMBINED; FINAL_LINE >= 85; FINAL_BRANCH >= 75; FINAL_LINE >= BASELINE_LINE and FINAL_BRANCH >= BASELINE_BRANCH (no production line changed, so a drop indicates an environment change and stops the plan for a report).
- [x] [P8-T10] Coverage-threshold gate over the P8-T8 JSON report (`scripts/dev_tools/check_python_coverage_thresholds.py`), and record FEATURE/evidence/qa-gates/python-coverage-gate.TS.md.
      Command: `poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 85 --min-branch 75`.
      Acceptance: exit 0 (no stderr breach message).
- [x] [P8-T11] Targeted Pester run of the suite that pins `feature-review.md` text (`tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`), executed through the Bash tool, and record FEATURE/evidence/qa-gates/pester-claude-architecture-doc.TS.md.
      Command: `pwsh -NoProfile -Command '$r = Invoke-Pester -Path "tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1" -PassThru -Output Detailed; "Passed=$($r.PassedCount) Failed=$($r.FailedCount)"'`.
      Acceptance: the printed line shows Failed=0 and the same Passed count as P0-T14; `EXIT_CODE:` is recorded as 0. PowerShell coverage is recorded as `N/A - no PowerShell file changes`. The CI job that runs this suite with coverage is `poshqc / PowerShell QC` on `windows-latest`; this local run is the plan's gate.
- [x] [P8-T12] Extension Jest suite in coverage mode (`extensions/drm-copilot/package.json` script `test:coverage`), run in the background, and record FEATURE/evidence/qa-gates/jest-extension-coverage.TS.md.
      Command: `npm --prefix extensions/drm-copilot run test:coverage`.
      Acceptance: exit 0; the Jest `Tests:` line reports no failed test; the text-summary `Lines` and `Branches` percentages are recorded as FINAL_TS_LINES and FINAL_TS_BRANCHES and are each equal to or greater than the P0-T15 values (no TypeScript file changes).
- [x] [P8-T13] Coverage comparison for every in-scope language (inputs: P0-T12, P8-T9, P0-T15, P8-T12, P0-T14, P8-T11 artifacts), and record FEATURE/evidence/qa-gates/coverage-comparison.TS.md.
      Command: none (the artifact is a computed comparison; record `Command: none - comparison of recorded values` and `EXIT_CODE: 0`).
      Acceptance: the artifact lists, for Python: BASELINE_LINE, FINAL_LINE, BASELINE_BRANCH, FINAL_BRANCH, the two deltas, and `New/changed-code coverage: N/A - no production line changed (REGRESSION-MODULE is under tests/, omitted by [tool.coverage.run] omit)`; for TypeScript: BASELINE_TS_LINES, FINAL_TS_LINES, BASELINE_TS_BRANCHES, FINAL_TS_BRANCHES, and `New/changed-code coverage: N/A - no TypeScript file changes`; for PowerShell: `N/A - no PowerShell file changes`. Every value is numeric or one of the quoted N/A literals. A negative Python delta stops the plan.
- [x] [P8-T14] Final mirror identity for the eight pairs (CB and XB paths named in each command), and record FEATURE/evidence/qa-gates/mirror-identity.TS.md.
      Commands: the eight `git diff --no-index --exit-code` commands of P0-T4, verbatim and in the same order.
      Acceptance: each command exits 0 and prints nothing.
- [x] [P8-T15] Scope verification against BASE_SHA for AC16, AC17, and AC18, and record FEATURE/evidence/qa-gates/scope-check.TS.md.
      Commands (substitute the recorded BASE_SHA value): `git diff --name-only BASE_SHA -- .github`; `git status --porcelain -- .github`; `git diff --name-only BASE_SHA -- scripts/dev_tools extensions/drm-copilot/src extensions/drm-copilot/resources/claude-customizations/pack-manifests extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests quality-tiers.yml`; `git status --porcelain -- scripts/dev_tools extensions/drm-copilot/src extensions/drm-copilot/resources/claude-customizations/pack-manifests extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests quality-tiers.yml`; `git diff --name-only BASE_SHA -- .claude/rules .claude/agents .claude/skills .agents/skills extensions/drm-copilot/resources/claude-customizations/.claude/rules extensions/drm-copilot/resources/claude-customizations/.claude/agents extensions/drm-copilot/resources/claude-customizations/.claude/skills extensions/drm-copilot/resources/codex-and-agents-customizations/.agents docs/features/potential tests/scripts/dev_tools`; `git status --porcelain --untracked-files=all -- tests/scripts/dev_tools docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md`.
      Acceptance: the first four commands print nothing (no `.github/` file, push-down code, extension source, pack manifest, or `quality-tiers.yml` changed; `.github/workflows/_quality-checks.yml`, `scripts/dev_tools/check_quality_tiers.py`, and `scripts/dev_tools/quality_tiers_contract.py` fall inside these pathspecs); the fifth prints exactly 17 paths, which are the EIGHT repo-local files, the EIGHT mirrors, and `docs/features/potential/2026-09-29-issue-734-quality-tiers-follow-ups.md`; the last prints exactly two `??` lines, for `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` and `docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md`. Any other path stops the plan.

### Phase 9 — Acceptance-Criteria Check-Off

Each task checks one AC box in `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md` (change `- [ ] ACn:` to `- [x] ACn:`) only when every named verifying task is checked and its artifact passes. No other spec line changes. Each task appends one line `ACn checked: <verifying artifact paths>` to FEATURE/evidence/other/ac-checkoff.TS.md (one artifact for the phase, created by P9-T1).
Acceptance (each task, with n the task's AC number): `git grep --no-index -c -F "[x] ACn:" -- docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md` prints 1 after the edit (for example `git grep --no-index -c -F "[x] AC7:"` for P9-T7; the trailing colon keeps AC1 from matching AC10 through AC19), and the artifact line for that AC names every verifying artifact.

- [x] [P9-T1] Check off AC1 in `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`. Verifying tasks: P2-T1, P5-T1, P5-T6, P7-T1 (`test_quality_tiers_preamble_states_adoption_gate`, 4 cases).
- [x] [P9-T2] Check off AC2 in `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`. Verifying tasks: P2-T1, P7-T1 (`test_copy_omits_unconditional_ci_sentence`, `test_quality_tiers_copy_drops_repo_scope_phrase`).
- [x] [P9-T3] Check off AC3 in `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`. Verifying tasks: P2-T2, P7-T1 (`test_general_code_change_tier_section_is_conditional`, `test_copy_omits_legacy_classification_sentence`).
- [x] [P9-T4] Check off AC4 in `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`. Verifying tasks: P2-T1, P2-T3, P7-T1 (`test_claude_copy_states_claude_md_precedence`).
- [x] [P9-T5] Check off AC5 in `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`. Verifying tasks: P2-T3, P7-T1 (`test_unit_test_categories_gate_tier_obligations`, `test_general_unit_test_copy_drops_repo_scope_phrase`).
- [x] [P9-T6] Check off AC6 in `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`. Verifying tasks: P3-T1, P3-T2, P3-T3, P7-T1 (`test_quality_tiers_preamble_states_adoption_gate`, `test_general_code_change_tier_section_is_conditional`, `test_codex_copy_states_agents_md_precedence`).
- [x] [P9-T7] Check off AC7 in `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`. Verifying tasks: P3-T1, P3-T2, P3-T3, P7-T1 (`test_codex_skill_copy_cites_existing_tier_skill`, 6 cases); reading recorded in PD3.
- [x] [P9-T8] Check off AC8 in `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`. Verifying tasks: P2-T1, P3-T1, P7-T1 (`test_quality_tiers_copy_names_no_consuming_product`, which also asserts the three harm-model sentences).
- [x] [P9-T9] Check off AC9 in `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`. Verifying tasks: P4-T1, P4-T3, P4-T4, P7-T1 (`test_feature_review_copy_gates_tier_finding`).
- [x] [P9-T10] Check off AC10 in `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`. Verifying tasks: P4-T2, P7-T1 (`test_review_agent_copy_uses_governing_thresholds`).
- [x] [P9-T11] Check off AC11 in `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`. Verifying tasks: P5-T1 through P5-T8, P8-T14, P8-T7 (parity tests in CONTRACT-SET).
- [x] [P9-T12] Check off AC12 in `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`. Verifying tasks: P2-T1 (description grep), P8-T7 (`tests/scripts/dev_tools/test_claude_rules_frontmatter.py` passes, including `test_every_claude_rule_carries_parseable_paths_and_description` and `test_unconditional_rule_set_is_exactly_the_four_deliberate_files`).
- [x] [P9-T13] Check off AC13 in `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`. Verifying tasks: P4-T1 (`version folder` grep), P8-T7 (`test_orchestrator_state_remediation_docs.py`, `test_completion_gate_documentation_contracts.py`), P8-T11.
- [x] [P9-T14] Check off AC14 in `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`. Verifying tasks: P1-T1, P1-T2, P7-T1.
- [x] [P9-T15] Check off AC15 in `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`. Verifying tasks: P1-T3 (expect-fail artifact), P7-T1 (`test_legacy_detection_flags_wrapped_legacy_sentences` passes).
- [x] [P9-T16] Check off AC16 in `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`. Verifying task: P8-T15 (first two commands).
- [x] [P9-T17] Check off AC17 in `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`. Verifying tasks: P7-T2, P8-T15 (third and fourth commands).
- [x] [P9-T18] Check off AC18 in `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`. Verifying tasks: P8-T15, P8-T4.
- [x] [P9-T19] Check off AC19 in `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`. Verifying task: P6-T1.
- [x] [P9-T20] Check off AC20 in `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`. Verifying task: P6-T2.
- [x] [P9-T21] Check off AC21 in `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`. Verifying tasks: P8-T1 through P8-T13 in one uninterrupted loop pass (stage mapping in PD5). AC21 stays unchecked if any Phase 8 artifact records a failure other than KL-510.

## Appendix A — REGRESSION-MODULE content (verbatim)

```python
"""Regression contract for issue #823: the pushed tier rule is gated on adoption.

The push-down copies the Claude rules and the Codex skills verbatim into
consuming repositories. Before issue #823 those copies stated, without a
condition, that every project must be classified in ``quality-tiers.yml`` and
that an unclassified project fails CI, and they set coverage figures with no
precedence for a consuming repository's own root instructions. These tests pin
the adoption-gated wording in the repo-local copies and in their bundled
mirrors under ``extensions/drm-copilot/resources/``.

Every search runs over whitespace-normalized text, so a reflowed sentence is
still found. The module reads repository files only: it creates no file, starts
no process, and consults no external service.
"""

from __future__ import annotations

from pathlib import Path

import pytest

# This file lives at tests/scripts/dev_tools/, three parents below the repo root.
REPO_ROOT = Path(__file__).resolve().parents[3]

CLAUDE_BUNDLE = "extensions/drm-copilot/resources/claude-customizations/"
CODEX_BUNDLE = "extensions/drm-copilot/resources/codex-and-agents-customizations/"

CLAUDE_QUALITY_TIERS = ".claude/rules/quality-tiers.md"
CLAUDE_GENERAL_CODE_CHANGE = ".claude/rules/general-code-change.md"
CLAUDE_GENERAL_UNIT_TEST = ".claude/rules/general-unit-test.md"
CLAUDE_FEATURE_REVIEW_AGENT = ".claude/agents/feature-review.md"
CLAUDE_FEATURE_REVIEW_SKILL = ".claude/skills/feature-review-workflow/SKILL.md"
CODEX_QUALITY_TIERS = ".agents/skills/quality-tiers/SKILL.md"
CODEX_GENERAL_CODE_CHANGE = ".agents/skills/general-code-change/SKILL.md"
CODEX_GENERAL_UNIT_TEST = ".agents/skills/general-unit-test/SKILL.md"


def claude_copies(relative_path: str) -> tuple[str, str]:
    """Return the repo-local path and the Claude bundle mirror path."""

    return (relative_path, CLAUDE_BUNDLE + relative_path)


def codex_copies(relative_path: str) -> tuple[str, str]:
    """Return the repo-local path and the Codex bundle mirror path."""

    return (relative_path, CODEX_BUNDLE + relative_path)


QUALITY_TIERS_COPIES = (
    *claude_copies(CLAUDE_QUALITY_TIERS),
    *codex_copies(CODEX_QUALITY_TIERS),
)
GENERAL_CODE_CHANGE_COPIES = (
    *claude_copies(CLAUDE_GENERAL_CODE_CHANGE),
    *codex_copies(CODEX_GENERAL_CODE_CHANGE),
)
GENERAL_UNIT_TEST_COPIES = (
    *claude_copies(CLAUDE_GENERAL_UNIT_TEST),
    *codex_copies(CODEX_GENERAL_UNIT_TEST),
)
CLAUDE_PRECEDENCE_COPIES = (
    *claude_copies(CLAUDE_QUALITY_TIERS),
    *claude_copies(CLAUDE_GENERAL_UNIT_TEST),
)
CODEX_PRECEDENCE_COPIES = (
    *codex_copies(CODEX_QUALITY_TIERS),
    *codex_copies(CODEX_GENERAL_UNIT_TEST),
)
CODEX_SKILL_COPIES = (
    *codex_copies(CODEX_QUALITY_TIERS),
    *codex_copies(CODEX_GENERAL_CODE_CHANGE),
    *codex_copies(CODEX_GENERAL_UNIT_TEST),
)
FEATURE_REVIEW_COPIES = (
    *claude_copies(CLAUDE_FEATURE_REVIEW_AGENT),
    *claude_copies(CLAUDE_FEATURE_REVIEW_SKILL),
)
FEATURE_REVIEW_AGENT_COPIES = claude_copies(CLAUDE_FEATURE_REVIEW_AGENT)
ALL_COPIES = (
    *QUALITY_TIERS_COPIES,
    *GENERAL_CODE_CHANGE_COPIES,
    *GENERAL_UNIT_TEST_COPIES,
    *FEATURE_REVIEW_COPIES,
)
EXPECTED_COPY_COUNT = 16

# Legacy sentences that bound every consuming repository to tiers it never adopted.
LEGACY_CLASSIFICATION_SENTENCE = (
    "Every project must be classified in `quality-tiers.yml` at repo root."
)
LEGACY_CI_SENTENCE = "Adding a project without a tier classification fails CI."

ADOPTION_GATE_FRAGMENTS = (
    "applies only when `quality-tiers.yml` exists at the repository root",
    "is not a defect",
)
TIER_SECTION_FRAGMENTS = (
    "only when `quality-tiers.yml` exists at the repository root",
    "has not adopted tiers",
)
TEST_CATEGORIES_FRAGMENTS = (
    "tier-dependent obligations apply only when `quality-tiers.yml` exists at "
    "the repository root",
)
CLAUDE_PRECEDENCE_FRAGMENTS = (
    "Threshold precedence: when the repository's root `CLAUDE.md` states line "
    "or branch coverage thresholds, those thresholds govern.",
    "defaults that apply only when the root `CLAUDE.md` states none",
    "every restatement of these figures",
)
CODEX_PRECEDENCE_FRAGMENTS = (
    "Threshold precedence: when the repository's root `AGENTS.md` states line "
    "or branch coverage thresholds, those thresholds govern;",
    "thresholds stated in the repository's root `CLAUDE.md` govern",
    "defaults that apply only when neither root `AGENTS.md` nor root "
    "`CLAUDE.md` states thresholds",
    "every restatement of these figures",
)
CONSUMING_PRODUCT_TOKENS = ("TaskMaster", "No-COM", "SpamBayes", "Outlook")
HARM_MODEL_SENTENCES = (
    "Behavior bugs cause silent data loss, model drift, or security holes.",
    "Bugs cause feature regressions but not data loss.",
    "Glue around APIs the team does not own.",
)
BROKEN_CODEX_CITATION = ".agents/skills/quality-tiers.md"
CODEX_TIER_SKILL_CITATION = "`.agents/skills/quality-tiers/SKILL.md`"
REPOSITORY_SCOPE_PHRASE = "in this repository"
UNIT_TEST_SCOPE_PHRASE = "not used in this repository"
UNIFORM_TIER_CITATION = "uniform tier rule"
FEATURE_REVIEW_FRAGMENTS = (
    "root `CLAUDE.md`",
    "record tier classification as not applicable",
    "tier-classification check",
)
RETIRED_REVIEW_THRESHOLDS = ("80%", "90%")
GOVERNING_THRESHOLD_FRAGMENT = "governing repo-wide threshold"


def read_copy(relative_path: str) -> str:
    """Return the UTF-8 text of one committed copy; reads disk, writes nothing."""

    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def normalize_whitespace(text: str) -> str:
    """Collapse every whitespace run, including line breaks, to one space."""

    return " ".join(text.split())


def present_fragments(text: str, fragments: tuple[str, ...]) -> list[str]:
    """Return the fragments found in ``text`` after whitespace normalization."""

    normalized = normalize_whitespace(text)
    return [item for item in fragments if normalize_whitespace(item) in normalized]


def missing_fragments(text: str, fragments: tuple[str, ...]) -> list[str]:
    """Return the fragments absent from ``text`` after whitespace normalization."""

    found = present_fragments(text, fragments)
    return [item for item in fragments if item not in found]


def preamble(text: str) -> str:
    """Return the lines before the first ``## `` heading; ``###`` does not end it."""

    kept: list[str] = []
    # Collect lines until the first level-two heading.
    for line in text.splitlines():
        if line.startswith("## "):
            break
        kept.append(line)
    return "\n".join(kept)


def section(text: str, heading: str) -> str:
    """Return a ``## `` section through the next ``## `` heading, or ``""``."""

    lines = text.splitlines()
    for start, line in enumerate(lines):
        if line.rstrip() != heading:
            continue
        collected = [line]
        # Extend the section until the next level-two heading.
        for following in lines[start + 1 :]:
            if following.startswith("## "):
                break
            collected.append(following)
        return "\n".join(collected)
    return ""


def test_every_scanned_copy_exists() -> None:
    """Require all sixteen scanned copies to exist as distinct files."""

    # Arrange
    distinct = set(ALL_COPIES)

    # Act
    missing = [path for path in ALL_COPIES if not (REPO_ROOT / path).is_file()]

    # Assert
    assert len(distinct) == EXPECTED_COPY_COUNT, f"scanned set: {sorted(distinct)}"
    assert missing == [], f"scanned copies missing: {missing}"


@pytest.mark.parametrize("relative_path", ALL_COPIES)
def test_copy_omits_legacy_classification_sentence(relative_path: str) -> None:
    """Forbid the unconditional classification sentence in every copy."""

    # Arrange
    text = read_copy(relative_path)

    # Act
    found = present_fragments(text, (LEGACY_CLASSIFICATION_SENTENCE,))

    # Assert
    assert found == [], f"{relative_path} still states: {found}"


@pytest.mark.parametrize("relative_path", ALL_COPIES)
def test_copy_omits_unconditional_ci_sentence(relative_path: str) -> None:
    """Forbid the unconditional tier-classification CI sentence in every copy."""

    # Arrange
    text = read_copy(relative_path)

    # Act
    found = present_fragments(text, (LEGACY_CI_SENTENCE,))

    # Assert
    assert found == [], f"{relative_path} still states: {found}"


@pytest.mark.parametrize("relative_path", QUALITY_TIERS_COPIES)
def test_quality_tiers_preamble_states_adoption_gate(relative_path: str) -> None:
    """Require the adoption gate before the first level-two heading."""

    # Arrange
    text = preamble(read_copy(relative_path))

    # Act
    missing = missing_fragments(text, ADOPTION_GATE_FRAGMENTS)

    # Assert
    assert missing == [], f"{relative_path} preamble lacks: {missing}"


@pytest.mark.parametrize("relative_path", QUALITY_TIERS_COPIES)
def test_quality_tiers_copy_drops_repo_scope_phrase(relative_path: str) -> None:
    """Forbid the phrase that scoped the tier rule to one repository."""

    # Arrange
    text = read_copy(relative_path)

    # Act
    found = present_fragments(text, (REPOSITORY_SCOPE_PHRASE,))

    # Assert
    assert found == [], f"{relative_path} still says: {found}"


@pytest.mark.parametrize("relative_path", QUALITY_TIERS_COPIES)
def test_quality_tiers_copy_names_no_consuming_product(relative_path: str) -> None:
    """Forbid consuming-product names and keep the harm-model definitions."""

    # Arrange
    text = read_copy(relative_path)

    # Act
    product_names = [token for token in CONSUMING_PRODUCT_TOKENS if token in text]
    missing_harm_models = missing_fragments(text, HARM_MODEL_SENTENCES)

    # Assert
    assert product_names == [], f"{relative_path} names: {product_names}"
    assert missing_harm_models == [], f"{relative_path} lost: {missing_harm_models}"


@pytest.mark.parametrize("relative_path", GENERAL_CODE_CHANGE_COPIES)
def test_general_code_change_tier_section_is_conditional(relative_path: str) -> None:
    """Require the Module Rigor Tiers section to state the adoption condition."""

    # Arrange
    text = section(read_copy(relative_path), "## Module Rigor Tiers")

    # Act
    missing = missing_fragments(text, TIER_SECTION_FRAGMENTS)

    # Assert
    assert text != "", f"{relative_path} has no `## Module Rigor Tiers` section"
    assert missing == [], f"{relative_path} tier section lacks: {missing}"


@pytest.mark.parametrize("relative_path", GENERAL_UNIT_TEST_COPIES)
def test_general_unit_test_copy_drops_repo_scope_phrase(relative_path: str) -> None:
    """Forbid the sentence that scoped the tier thresholds to one repository."""

    # Arrange
    text = read_copy(relative_path)

    # Act
    found = present_fragments(text, (UNIT_TEST_SCOPE_PHRASE,))

    # Assert
    assert found == [], f"{relative_path} still says: {found}"


@pytest.mark.parametrize("relative_path", GENERAL_UNIT_TEST_COPIES)
def test_unit_test_categories_gate_tier_obligations(relative_path: str) -> None:
    """Require the Test Categories section to gate tier-dependent obligations."""

    # Arrange
    text = section(read_copy(relative_path), "## Test Categories")

    # Act
    missing = missing_fragments(text, TEST_CATEGORIES_FRAGMENTS)

    # Assert
    assert text != "", f"{relative_path} has no `## Test Categories` section"
    assert missing == [], f"{relative_path} test categories lack: {missing}"


@pytest.mark.parametrize("relative_path", CLAUDE_PRECEDENCE_COPIES)
def test_claude_copy_states_claude_md_precedence(relative_path: str) -> None:
    """Require the root CLAUDE.md coverage-threshold precedence statement."""

    # Arrange
    text = read_copy(relative_path)

    # Act
    missing = missing_fragments(text, CLAUDE_PRECEDENCE_FRAGMENTS)

    # Assert
    assert missing == [], f"{relative_path} precedence lacks: {missing}"


@pytest.mark.parametrize("relative_path", CODEX_PRECEDENCE_COPIES)
def test_codex_copy_states_agents_md_precedence(relative_path: str) -> None:
    """Require the root AGENTS.md then CLAUDE.md threshold precedence statement."""

    # Arrange
    text = read_copy(relative_path)

    # Act
    missing = missing_fragments(text, CODEX_PRECEDENCE_FRAGMENTS)

    # Assert
    assert missing == [], f"{relative_path} precedence lacks: {missing}"


@pytest.mark.parametrize("relative_path", CODEX_SKILL_COPIES)
def test_codex_skill_copy_cites_existing_tier_skill(relative_path: str) -> None:
    """Require the existing tier-skill path and forbid the non-existent one."""

    # Arrange
    text = read_copy(relative_path)

    # Act
    broken = present_fragments(text, (BROKEN_CODEX_CITATION,))
    cited = present_fragments(text, (CODEX_TIER_SKILL_CITATION,))

    # Assert
    assert broken == [], f"{relative_path} cites a missing path: {broken}"
    assert cited == [CODEX_TIER_SKILL_CITATION], f"{relative_path} lacks citation"


@pytest.mark.parametrize("relative_path", FEATURE_REVIEW_COPIES)
def test_feature_review_copy_gates_tier_finding(relative_path: str) -> None:
    """Require adoption-gated tier findings and the CLAUDE.md precedence."""

    # Arrange
    text = read_copy(relative_path)

    # Act
    retired = present_fragments(text, (UNIFORM_TIER_CITATION,))
    missing = missing_fragments(text, FEATURE_REVIEW_FRAGMENTS)

    # Assert
    assert retired == [], f"{relative_path} still cites: {retired}"
    assert missing == [], f"{relative_path} lacks: {missing}"


@pytest.mark.parametrize("relative_path", FEATURE_REVIEW_AGENT_COPIES)
def test_review_agent_copy_uses_governing_thresholds(relative_path: str) -> None:
    """Forbid the 80/90 figures and require the governing-threshold wording."""

    # Arrange
    text = read_copy(relative_path)

    # Act
    retired = [token for token in RETIRED_REVIEW_THRESHOLDS if token in text]
    governing = present_fragments(text, (GOVERNING_THRESHOLD_FRAGMENT,))

    # Assert
    assert retired == [], f"{relative_path} still states: {retired}"
    assert governing == [GOVERNING_THRESHOLD_FRAGMENT], f"{relative_path} lacks it"


def test_legacy_detection_flags_wrapped_legacy_sentences() -> None:
    """Prove the detection can fail: wrapped legacy sentences are flagged."""

    # Arrange
    synthetic = (
        "## Module Rigor Tiers\n\nTiers are defined elsewhere. Every project must"
        "\nbe classified in `quality-tiers.yml` at repo root. Adding a project\n"
        "without a tier classification fails CI.\n"
    )

    # Act
    found = present_fragments(
        synthetic, (LEGACY_CLASSIFICATION_SENTENCE, LEGACY_CI_SENTENCE)
    )

    # Assert
    assert found == [LEGACY_CLASSIFICATION_SENTENCE, LEGACY_CI_SENTENCE]


def test_legacy_detection_accepts_adoption_gated_wording() -> None:
    """Gated wording that keeps the obligation conditional is not flagged."""

    # Arrange
    synthetic = (
        "Tiers apply only when `quality-tiers.yml` exists at the repository root;"
        " in that case every project must be classified in it. A repository"
        " without `quality-tiers.yml` has not adopted tiers. A repository that"
        " runs a `tier-classification` CI stage fails CI for an unclassified"
        " project.\n"
    )

    # Act
    found = present_fragments(
        synthetic, (LEGACY_CLASSIFICATION_SENTENCE, LEGACY_CI_SENTENCE)
    )
    missing = missing_fragments(synthetic, TIER_SECTION_FRAGMENTS)

    # Assert
    assert found == []
    assert missing == []


def test_preamble_and_section_split_on_level_two_headings() -> None:
    """Level-two headings bound the preamble and sections; level three does not."""

    # Arrange
    synthetic = (
        "# Title\n\nGate text.\n\n## Tiers\n\n### Detail\nBody text.\n\n"
        "## Next\nTail text.\n"
    )

    # Act
    head = preamble(synthetic)
    tiers = section(synthetic, "## Tiers")
    absent = section(synthetic, "## Missing")

    # Assert
    assert "Gate text." in head
    assert "Body text." not in head
    assert "### Detail" in tiers
    assert "Body text." in tiers
    assert "Tail text." not in tiers
    assert absent == ""
```

## Appendix B — Claude edit text (verbatim)

### `.claude/rules/quality-tiers.md`

B1. Replace planning-time line 9 (the paragraph that begins "This rule defines the T1–T4 module rigor tier system used by all CI gates in this repository.") with these three lines (paragraph, blank line, paragraph):

```text
Applicability: this rule applies only when `quality-tiers.yml` exists at the repository root, which indicates that the repository has adopted module rigor tiers. When that file is absent, there is no tier classification requirement, no `tier-classification` CI stage, and no tier-dependent gate (the escape-hatch limits, property-test density, mutation score, contract-bump rule, determinism retry rate, golden tests, and E2E suite scope in the Tier-dependent table below), and the absence of `quality-tiers.yml` is not a defect. The coverage defaults listed under Uniform across all tiers do not depend on tier adoption; their precedence is stated in that section.

When `quality-tiers.yml` exists, this rule defines the T1–T4 module rigor tier system used by the repository's CI gates, and the tier definitions and gate matrix in this document are the tier system's source of truth.
```

B2. Replace planning-time lines 13-15 (the T1, T2, and T3 bullets) with these three lines. The T4 bullet (line 16) is unchanged.

```text
- **T1 — Critical.** Behavior bugs cause silent data loss, model drift, or security holes. Examples: classifier and scoring engines, identifier allocators and hierarchy operations, adapters that write to an external system of record, authentication and token handling, command dispatch.
- **T2 — Core.** Bugs cause feature regressions but not data loss. Examples: domain and application layers, data-transfer objects, settings store abstractions, schema definitions.
- **T3 — Adapters & UI.** Glue around APIs the team does not own. Examples: user-interface surfaces, host-platform API wrappers, third-party API and SDK wrappers, persistence I/O.
```

B3. Replace planning-time lines 20-21 (the two `## Source of Truth` bullets) with these two lines:

```text
- When `quality-tiers.yml` exists at the repository root, it maps every project to one tier.
- In a repository that runs a `tier-classification` CI stage, that stage validates that every project entry has a tier and that no unclassified project exists, and it fails CI for an unclassified project.
```

B4. Immediately after the line `### Uniform across all tiers (T1–T4)` and its following blank line, insert CLAUDE-PRECEDENCE as one line followed by one blank line, so that the bullet `- Format check: 100% pass.` follows the blank line. The bullets themselves are unchanged.

B5. In the Rationale paragraph (planning-time line 51), replace this old substring:

```text
; tier-specific lower coverage floors are not used in this repository.
```

with this new substring:

```text
; tier-specific lower coverage floors are not used. These figures are defaults under the threshold precedence stated above: a root `CLAUDE.md` that states coverage thresholds overrides them.
```

The rest of the paragraph is unchanged.

### `.claude/rules/general-code-change.md`

GCC-1. Replace planning-time line 29 (the paragraph under `## Module Rigor Tiers`) with this one line:

```text
Module rigor tiers (T1–T4) and the uniform-versus-tier-dependent gate matrix are defined in `.claude/rules/quality-tiers.md` and apply only when `quality-tiers.yml` exists at the repository root; in that case every project must be classified in it. A repository without `quality-tiers.yml` has not adopted tiers, and the tier requirements do not apply.
```

### `.claude/rules/general-unit-test.md`

GUT-1. Insert this line as the first bullet of `## Coverage Requirements`, immediately before the bullet that begins `- **Line coverage must remain >= 85%`:

```text
- Threshold precedence: when the repository's root `CLAUDE.md` states line or branch coverage thresholds, those thresholds govern. The 85% line and 75% branch figures are defaults that apply only when the root `CLAUDE.md` states none. This precedence applies to every restatement of these figures in other rule files, agents, and skills.
```

GUT-2. Replace planning-time line 26 (`- Tier-specific lower coverage thresholds are not used in this repository. See `.claude/rules/quality-tiers.md` for the full tier system.`) with:

```text
- Tier-specific lower coverage thresholds are not used. See `.claude/rules/quality-tiers.md` for the full tier system, which applies only when `quality-tiers.yml` exists at the repository root.
```

GUT-3. Replace planning-time line 89 (the introduction under `## Test Categories`) with:

```text
The following test categories apply across the repository, with tier-dependent obligations per `.claude/rules/quality-tiers.md`; those tier-dependent obligations apply only when `quality-tiers.yml` exists at the repository root:
```

### `.claude/agents/feature-review.md`

FR-1. Replace planning-time line 119 (`Coverage thresholds follow the uniform tier rule (Authoritative Decision #2) defined in `.claude/rules/quality-tiers.md`:`) with:

```text
Coverage thresholds follow the threshold precedence defined in `.claude/rules/quality-tiers.md` and `.claude/rules/general-unit-test.md`: when the repository's root `CLAUDE.md` states line or branch coverage thresholds, those thresholds govern; otherwise the default thresholds below govern. The thresholds that govern under this precedence are the governing thresholds referred to in the Verification Procedure below. The defaults are:
```

FR-2. Immediately after planning-time line 125 (`Tier-specific lower thresholds are not used.`), insert one blank line and then TIER-FINDING as one line. Line 125 itself and the following PowerShell paragraph (line 127) are unchanged, separated from the inserted line by one blank line.

FR-3. Replace planning-time lines 137-139 (the three bullets under step 3 of `### Verification Procedure`) with these three lines, keeping the three-space indentation:

```text
   - If repo-wide line or branch coverage is below the governing repo-wide thresholds defined in Coverage Thresholds, flag as FAIL and add to remediation triggers.
   - For each new file: if line or branch coverage is below the governing new-file thresholds defined in Coverage Thresholds, flag as FAIL and add to remediation triggers.
   - For each modified file: if coverage on changed lines has regressed from baseline, or line or branch coverage is below the governing modified-file thresholds defined in Coverage Thresholds, flag as FAIL and add to remediation triggers.
```

### `.claude/skills/feature-review-workflow/SKILL.md`

FRW-1. In planning-time line 111, replace this old substring:

```text
Coverage thresholds (uniform tier rule per quality-tiers.md).
```

with this new substring:

```text
Coverage thresholds (threshold precedence per `.claude/rules/quality-tiers.md` and `.claude/rules/general-unit-test.md`: when the repository's root `CLAUDE.md` states line or branch coverage thresholds, those thresholds govern; otherwise the default thresholds below govern).
```

The leading indentation and the rest of the line are unchanged.

FRW-2. Immediately after planning-time line 116 (the bullet that begins `        - If no coverage artifact exists for a language that has changed files`), insert this one line with the same eight-space indentation:

```text
        - Tier classification findings: report a missing or incomplete `quality-tiers.yml` only when the repository has adopted tiers, that is, when `quality-tiers.yml` exists at the repository root on the resolved base branch or the repository's CI runs a tier-classification check. Otherwise record tier classification as not applicable; it is not a finding.
```

## Appendix C — Codex edit text (verbatim)

### `.agents/skills/quality-tiers/SKILL.md`

Lines 1-10 (frontmatter, `# Converted rule`, `Source: legacy Claude rule `quality-tiers`.`, and `# Module Rigor Tiers`) are unchanged.

C1. Replace planning-time line 12 (the paragraph that begins "This rule defines the T1–T4 module rigor tier system used by all CI gates in this repository.") with these three lines:

```text
Applicability: this skill (`.agents/skills/quality-tiers/SKILL.md`) applies only when `quality-tiers.yml` exists at the repository root, which indicates that the repository has adopted module rigor tiers. When that file is absent, there is no tier classification requirement, no `tier-classification` CI stage, and no tier-dependent gate (the escape-hatch limits, property-test density, mutation score, contract-bump rule, determinism retry rate, golden tests, and E2E suite scope in the Tier-dependent table below), and the absence of `quality-tiers.yml` is not a defect. The coverage defaults listed under Uniform across all tiers do not depend on tier adoption; their precedence is stated in that section.

When `quality-tiers.yml` exists, this skill defines the T1–T4 module rigor tier system used by the repository's CI gates, and the tier definitions and gate matrix in this document are the tier system's source of truth.
```

C2. Replace planning-time lines 16-18 (the T1, T2, and T3 bullets) with the three lines quoted in B2, verbatim.

C3. Replace planning-time lines 23-24 (the two `## Source of Truth` bullets) with the two lines quoted in B3, verbatim.

C4. Immediately after the line `### Uniform across all tiers (T1–T4)` and its following blank line, insert CODEX-PRECEDENCE as one line followed by one blank line.

C5. In the Rationale paragraph (planning-time line 54), replace this old substring:

```text
; tier-specific lower coverage floors are not used in this repository.
```

with this new substring:

```text
; tier-specific lower coverage floors are not used. These figures are defaults under the threshold precedence stated above: a root `AGENTS.md` or root `CLAUDE.md` that states coverage thresholds overrides them.
```

The rest of the paragraph, including the citation of `.agents/skills/general-unit-test/SKILL.md`, is unchanged.

### `.agents/skills/general-code-change/SKILL.md`

XGCC-1. Replace planning-time line 32 with this one line:

```text
Module rigor tiers (T1–T4) and the uniform-versus-tier-dependent gate matrix are defined in `.agents/skills/quality-tiers/SKILL.md` and apply only when `quality-tiers.yml` exists at the repository root; in that case every project must be classified in it. A repository without `quality-tiers.yml` has not adopted tiers, and the tier requirements do not apply.
```

### `.agents/skills/general-unit-test/SKILL.md`

XGUT-1. Insert CODEX-PRECEDENCE, prefixed by `- ` (a bullet), as the first bullet of `## Coverage Requirements`, immediately before the bullet that begins `- **Line coverage must remain >= 85%`.

XGUT-2. Replace planning-time line 29 with:

```text
- Tier-specific lower coverage thresholds are not used. See `.agents/skills/quality-tiers/SKILL.md` for the full tier system, which applies only when `quality-tiers.yml` exists at the repository root.
```

XGUT-3. Replace planning-time line 92 (the introduction under `## Test Categories`) with:

```text
The following test categories apply across the repository, with tier-dependent obligations per `.agents/skills/quality-tiers/SKILL.md`; those tier-dependent obligations apply only when `quality-tiers.yml` exists at the repository root:
```

## Appendix D — Potential-item text (verbatim)

PI-1. In `docs/features/potential/2026-09-29-issue-734-quality-tiers-follow-ups.md`, insert one blank line and then this one line immediately after the FU-734-1 paragraph that ends "so that the bundled-payload parity tests continue to pass." (planning-time line 17):

```text
Status (2026-10-03): Resolved by #823 for the Codex sentences that #823 rewrote. `.agents/skills/general-code-change/SKILL.md` (Module Rigor Tiers section) and `.agents/skills/general-unit-test/SKILL.md` (Coverage Requirements and Test Categories sections), together with their bundled copies, now cite `.agents/skills/quality-tiers/SKILL.md`.
```

PI-2. In the same file, insert one blank line and then this one line immediately after the FU-734-4 paragraph that ends "because of its citation-only constraint." (planning-time line 34):

```text
Status (2026-10-03): Superseded by #823 (`docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`), which gates the pushed tier rule on the presence of `quality-tiers.yml` and defines coverage-threshold precedence. Do not promote this entry.
```

PI-3. Content of the new file `docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md`:

```markdown
# Potential: follow-ups surfaced by issue #823

- Date captured: 2026-10-03
- Author: atomic-executor (issue #823, `pushed-tier-rule-not-gated-on-adoption`)
- Source: the "Rollout & Follow-up" section of `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md` (items F1-F4), plus one item observed during planning (FU-823-5).
- Status: Draft. Not promoted. Each entry below can be promoted on its own.

---

## FU-823-1: Feature-review coverage hook ignores consumer thresholds (spec F1)

`.claude/hooks/validate-feature-review-coverage.ps1` hard-codes 85.0 line and 75.0 branch floors (approximately lines 313-327), and its docstring (line 29) states 80. Issue #823 defined threshold precedence in the pushed rule text: a consuming repository's root `CLAUDE.md` thresholds govern when present. The hook does not apply that precedence, so a consumer whose root `CLAUDE.md` sets lower thresholds still receives a FAIL verdict demanded by the hook. The hook should read the governing thresholds under the same precedence, and the docstring should be corrected.

## FU-823-2: Remaining TaskMaster and No-COM mentions in pushed files (spec F2)

`.claude/rules/architecture-boundaries.md`, `.agents/skills/architecture-boundaries/SKILL.md`, and `.claude/skills/quota-throttling/SKILL.md` (line 9), together with their bundled copies, name a consuming product. Issue #823 removed those names from the tier rule only. The architecture-boundaries rule is specific to one consumer architecture and needs a product decision before it is generalized or withdrawn from the push-down.

## FU-823-3: TaskMaster.sln C# toolchain commands in pushed files (spec F3)

`.github/instructions/csharp-code-change.instructions.md`, `.github/instructions/csharp-unit-test.instructions.md`, `.github/agents/csharp-typed-engineer.agent.md`, `.agents/skills/csharp/SKILL.md`, `.agents/skills/csharp-qa-gate/SKILL.md`, the `.agents-variants/csharp-legacy/**` bundle variants, and `.codex/codex-web-setup.sh` run `msbuild TaskMaster.sln`. A consuming repository with a different solution name receives commands that cannot run. The `.github/instructions/` files are canonical policy and need an explicit decision before any edit.

## FU-823-4: Extension republish to deliver the gated rule text (spec F4)

Consuming repositories receive the issue #823 wording only after the extension is rebuilt, published, and reinstalled, because the push-down serves the installed extension payload. After the release, confirm on the next consumer push-down that `.claude/rules/quality-tiers.md` carries the adoption gate.

## FU-823-5: Feature-review workflow remediation trigger still states 80/90 thresholds

`.claude/skills/feature-review-workflow/SKILL.md` step 8 (approximately line 149 after issue #823) lists "coverage regression below policy threshold (< 80% repo-wide per language, < 80% or regression for modified files, or < 90% for new files)" as a remediation trigger. Issue #823 aligned the step 5 coverage bullet with the governing thresholds and left this trigger, which is outside the #823 acceptance criteria. Align it with the governing thresholds in the repository copy and its bundled mirror.
```
