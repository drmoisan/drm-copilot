# issue-823-tier-rule-adoption-follow-ups (Plan)

- **Issue:** #824 (Addendum 2 only)
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-09T04-10 (revision round 1: executor preflight defects 1-6 and the formatter-scope advisory)
- **Status:** Draft
- **Version:** 1.1
- **Work Mode:** full-bug
- **Branch:** `bug/issue-823-tier-rule-adoption-follow-ups-824`
- **Languages in scope:** PowerShell (one new and one modified hook, two Pester suites), Python (one new and one modified pytest module, no production module), Bash (one modified setup script, one bats suite), Markdown (rule, skill, agent, and instruction files), JSON (one pack manifest). TypeScript has no source change; its toolchain runs as a no-regression gate for AC-8 and AC-13.
- **Requirements source (sole AC source):** `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`, section `## Acceptance Criteria` (AC-1 through AC-15).
- **Design input (not a requirements source):** `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/research/2026-10-09T02-25-issue-823-tier-rule-adoption-follow-ups-research.md` (sections 8, 9, 11, 12, 13, 14, 15). Every citation taken from it was re-derived against the worktree at planning time.

**Mode note (full-bug):** `spec.md` is required and present; `user-story.md` is not required and is absent. The full QA loop applies.

**Fail-closed evidence rule:** PowerShell and Python policy require coverage. Baseline and final-QC coverage tasks record numeric values: PowerShell repo-wide line coverage plus per-file line coverage for `.claude/hooks/validate-feature-review-coverage.ps1` and `.claude/hooks/feature-review-coverage-thresholds.ps1`; Python line and branch totals. No production Python file changes (the two Python files are under `tests/`, which `[tool.coverage.run] omit` excludes), so the Python new/changed-code value is the literal `N/A - no production Python line changed`. Bash coverage of `.codex/codex-web-setup.sh` is not measurable because `.codex/` is outside the kcov include roots (`.claude/rules/shell.md`, Coverage Expectations); it is recorded as the literal `N/A - .codex/ is outside the kcov include roots (pre-existing, follow-up)`. If any other required baseline artifact, final-QC artifact, or numeric coverage value is missing, the audit verdict is BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Every evidence-producing task names its artifact path. A task is not checked off until its artifact exists and carries every required field. Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. An artifact whose expected exit code is not 0 also carries `ExpectedExitCode:`. The top-level `EXIT_CODE:` of a multi-command artifact is the exit code of the task's last command; every other command's exit code and its key printed value are recorded inside `Output Summary:` in command order. `grep -c` prints a count and exits 1 when the count is 0, so a task whose last command is a grep expected to print 0 records `EXIT_CODE: 1` with `ExpectedExitCode: 1`. No planned command task may record `EXIT_CODE: SKIPPED`. Artifacts never record an absolute host path; where a tool prints one, the artifact records only the repository-relative tail or a count. Known emitters in this plan: the Pester `Detailed` output line "Running tests from" (from `pester-files.sh`), the pytest header line beginning "rootdir:", the PSScriptAnalyzer success line after "under", the PoshQC "Already formatted:" lines, and the JUnit `classname` attribute (Appendix G item G6 prints only its final segment).

## Terms used in every task

- FEATURE means `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824`. Evidence is written only under FEATURE/evidence/baseline/, FEATURE/evidence/regression-testing/, FEATURE/evidence/qa-gates/, and FEATURE/evidence/other/. The caller supplied no non-canonical evidence path, so no `EVIDENCE_LOCATION_OVERRIDE_REJECTED` record is required.
- TS means the execution time of the task in `yyyy-MM-ddTHH-mm` form, read from the host clock, never composed.
- RESEARCH_BASE means `e7d3779b398604af919678c16c877c8539a86cc0`, the commit the research inventory was read from.
- BASE_SHA means the commit recorded by P0-T3 before any edit. Every scope diff is anchored to it, never to `origin/main`.
- WIP_REF means `origin/wip/preserve-824-addendum2-2026-10-08`. WIP_SHA and WIP_BASE are the values P0-T5 records (the branch head and `git merge-base BASE_SHA WIP_SHA`). WIP_REF is read only; it is never merged, rebased onto, checked out, or pushed.
- HUNKS means the git-ignored scratch folder `artifacts/orchestration/wip824-hunks/`; RUN means the git-ignored scratch folder `artifacts/orchestration/wip824-run/`. Both hold non-evidence tool inputs and outputs only (`artifacts/orchestration/` is a permitted non-evidence sub-path) and are never committed.
- HAP means the hunk application procedure in Appendix A, applied to one path and its named patch file.
- CB means `extensions/drm-copilot/resources/claude-customizations`, XB means `extensions/drm-copilot/resources/codex-and-agents-customizations`, and GB means `extensions/drm-copilot/resources/customizations`. These abbreviations appear in prose only; every command and every write-task title spells the full path.
- PESTER-824 means these three files in this order: `tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1`, `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1`, `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`.
- PARITY-SET means these five pytest files: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`, `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`.
- KL-510 means the known local-only failure of `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` caused by git-ignored machine-local state (issue #510). A failure is classified KL-510 only when its sole assertion message begins with "Repo file missing from bundle:" and the named path satisfies `git check-ignore -q` with exit 0. Any other failure of that test is a real failure.
- Tokens that later tasks search for and that do not exist in the tracked tree before this plan runs (quoted here so each search is an instruction, not an assumption): "falls back independently"; "Host-Neutral Architecture Rules"; "consumer-repository runs"; "coverage below the governing thresholds defined in step 5"; "Get-FeatureReviewCoverageThreshold"; "feature-review-coverage-thresholds.ps1"; "list_root_solution_files"; "Known limitation"; "[char]0x2265"; "no\s+less\s+than"; "FALLBACK_PHRASE"; "PRE_EXISTING_NAME_EXCEPTIONS"; "pushed_rule_and_skill_files"; "coverage_threshold_context"; "vswhere_check"; "Status: Resolved by #824."; "Status: Open (out of scope for #824; no release automation is run)."; "Refs #824"; "Line coverage was 62% last release."; "-LineFloor $thresholds.Line"; "[double]$BranchFloor = 75.0"; "function Get-FeatureReviewCoverageThreshold"; "'CLAUDE.md' {"; "It 'F824-"; "\"next_step\": \"complete\"" (as a shell-escaped search for the checkpoint field value).

## Execution constraints

- Every command runs with the worktree root as the working directory. P0-T1 confirms by branch name that the working directory is this item's worktree. No command is prefixed with `cd`, and no command uses `git -C`.
- The agent worktree text-denies command lines containing the words bash, pwsh, or wsl, and heredocs. Commands in this plan therefore invoke PowerShell only through the RUN scripts with `sh <script>` (Git Bash `sh` is GNU bash), run bats through `npx --yes bats`, and syntax-check scripts with `sh -n`. If a hook or permission rule denies a command or an edit, stop and report the denial text; do not reword the command to avoid the hook and do not bypass it.
- Deliberate dependencies outside the atomic-executor frontmatter Bash allowlist (`.claude/agents/atomic-executor.md` lines 11-20 allow only `poetry run black`, `poetry run ruff`, `poetry run pyright`, `poetry run pytest`, `npx prettier`, `npx eslint`, `npx tsc`, `npx jest`, `pwsh`, and `git`): this plan also runs `sh`, `cp`, `grep`, `wc`, `ls`, `tail`, `mkdir`, `npm`, `node`, `npx --yes bats`, and `poetry run python -c`. Rationale: PoshQC MCP results carry no tool output, so the PowerShell format, analyze, and coverage values must come from the repository's PoshQC module run directly; the worktree isolation guard refuses command text containing plain `pwsh`, so that module is reached through `sh` RUN scripts; the coverage and JUnit values are read from XML and JSON reports with `poetry run python -c` one-liners; mirrors are byte copies by `cp`. P0-T1 probes each of these routes before any repository write, and a denial stops the plan there for an orchestrator decision.
- Quoting: a command span whose argument contains a `$` meant literally (a PowerShell variable name or a regex end anchor) is single-quoted, so the shell passes it unexpanded.
- File-content checks on files this plan creates use plain `grep` (never `git grep`, which cannot see untracked files). A grep pattern that begins with `-` is passed with `-e`.
- The executor does not commit, stage, or push. Scope checks compare the working tree against BASE_SHA and pair each name-listing diff with a `git status --porcelain` listing, so the union is correct whether or not the orchestrator commits between phases.
- Reuse of prior work: every reusable file is produced from WIP_REF by HAP (Appendix A), never retyped. Adaptations are applied afterwards with the Edit tool using the exact old and new text quoted in Appendices B through F. The executor does not compose wording or code.
- Bundled mirrors are produced only by `cp` from the edited repository source (byte copies), never by Write or Edit. The two bundle-only `.agents-variants/csharp-legacy` files have no repository source and are edited in place with the Edit tool.
- Markdown edits preserve the en dash in `T1–T4` and the em dashes already present; new text uses ASCII apostrophes.
- Commands expected to run longer than about eight minutes (the full pytest run, the full PoshQC test run, and the full Jest run) run in the background; the executor waits for the completion notification before reading output.
- Hard exclusions (spec "Explicitly excluded files and work"): the plan never writes `.claude/hooks/enforce-promotion-mcp-only.ps1`, `.claude/hooks/hook-command-invocation.ps1`, `.claude/hooks/hook-command-raw-invocation.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, their `.codex/` copies or bundle copies, `scripts/dev-tools/KcovFunctionCoverageGate.ps1` or its tests, `.github/workflows/_shell-coverage.yml`, `tests/scripts/workflows/ShellCoverageWorkflow.Tests.ps1`, anything under `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/`, or `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`, and never uses branch `bug/promotion-hook-raw-containment-false-positive-deny-824`. FU-823-4 (extension rebuild, publish, reinstall) is out of scope. If any task appears to require one of these, stop and report.

## Planner decisions (recorded for audit)

- PD1 - Policy-edit authority. The policy-compliance-order baseline forbids edits under `.claude/rules/` and `.github/instructions/`. Issue #824 Addendum 2 (maintainer decision recorded in the spec Constraints) authorizes, for this item only: `.claude/rules/architecture-boundaries.md` (FU-823-2), `.github/instructions/csharp-code-change.instructions.md` and `.github/instructions/csharp-unit-test.instructions.md` (FU-823-3), and, by the derivation the spec records for note A, `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md`. No other policy file is edited. P7-T2 records the PR-body callout for each.
- PD2 - Reuse mechanism. Each reusable file is applied from a per-path patch produced by `git diff WIP_BASE WIP_SHA -- <path>`. The forward `git apply --check` proves the hunks fit the current tree; the post-apply `git apply --reverse --check` proves the complete WIP post-image is present. Where main has moved a file so the forward check fails, Appendix A defines a per-hunk Edit fallback that stops when the removed lines themselves have changed. P0-T4 re-derives which write-set files moved between RESEARCH_BASE and BASE_SHA, including the #847 overlap (`.claude/hooks/validate-feature-review-coverage.ps1` and its mirror) and the #841 overlap (`.claude/skills/feature-review-workflow/SKILL.md` and its mirror).
- PD3 - Resolver comparator (spec "Data flow"; research section 8 CR-4). The adapted resolver reads a figure only when one of `>=`, the U+2265 sign, `at least`, `minimum`, `minimum of`, or `no less than` sits between "<metric> coverage" and the figure on the same line, optionally followed by a colon. A metric name joined to the other metric name by `and`, `or`, `&`, or `/` is not read, so "line and branch coverage >= 70%" matches neither metric and both defaults apply. The pattern is quoted in Appendix D. The U+2265 sign never appears literally in the PowerShell file: D2 builds it at run time with the ASCII expression `[char]0x2265`, concatenated between two single-quoted pattern fragments, so the file stays ASCII and the .NET regex engine receives the sign as an ordinary literal character. The regex escape form (a backslash followed by `u2265`) is deliberately not used: in revision round 1 the agent Edit tool was observed to decode that escape sequence in its parameters into the literal sign, which is the mechanism that put the literal sign into the round-0 D2 text, and the executor's own Edit of D2 would be exposed to the same decoding.
- PD4 - Note B is adopted verbatim from WIP_REF (one helper, one combined positive and negative unit test). The optional "threshold" paragraph refinement in research section 8 is not adopted, because the wip helper already satisfies AC-11 and the refinement would widen the scanned context without a requirement.
- PD5 - FU-823-2 scan set (AC-5). The new scan reads `.claude/rules/*.md`, `.claude/skills/**/SKILL.md`, `.agents/skills/**/SKILL.md`, their CB and XB copies, and the bundle-only variant rule and skill files (`.claude-variants/*/rules/*.md`, `.claude-variants/*/skills/**/SKILL.md`, `.agents-variants/*/skills/**/SKILL.md`). The variants are included because they are pushed skill files and the csharp-legacy variants carry `TaskMaster.sln` until FU-823-3. The pre-existing exception set is exactly `.claude/rules/typescript.md`, `.claude/rules/csharp.md`, and their two CB copies (spec Rollout & Follow-up), guarded against staleness. `EXPECTED_LISTED_COPY_COUNT` stays 36 (6 + 14 + 2 + 14) because the listed tuples do not change.
- PD6 - The bats suite cannot be run before the fix: it sources `.codex/codex-web-setup.sh`, whose last line on BASE_SHA is an unconditional `main "$@"`, so sourcing it runs the full setup (writes to `$HOME/.bashrc`, package installation). P2-T4 records a fail-before exception dossier instead; the suite first runs in P5-T16, after the source guard exists.
- PD7 - Note B cannot produce a failing run: the change is confined to the test module itself. P2-T5 records a fail-before exception dossier with a demonstration that the old whole-file expression flags an unrelated figure.
- PD8 - Coverage commands. Python uses `poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`: bare `--cov` takes its sources from `[tool.coverage.run] source` in `pyproject.toml` (line 120), and no dotted per-module target exists because no production Python module changes. Separate line and branch values are read from the JSON keys, because the terminal table prints one combined column. PowerShell coverage is produced by invoking the repository's own PoshQC module directly (RUN script `poshqc-test.sh`), not the MCP runner, because the MCP runner returns no tool output and may read installed-extension settings; values are read from `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml` (paths from `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` lines 15 and 22). The coverage population is `config/poshqc-coverage.json` (roots include `.claude/hooks`), so the new helper is measured without a settings change.
- PD9 - Batch budget. `.claude/hooks/enforce-powershell-batch-budget.ps1` counts only Write/Edit of production PowerShell paths, never test files, and denies the fourth distinct path in direct mode; it is inactive when the checkpoint route is large, remediation, or preparation and not terminal. This plan writes production PowerShell through Write/Edit at most twice (P3-T2 on the helper, and the P3-T3 fallback on the hook only when its forward check fails); `git apply` and `cp` run through Bash and are not counted. The Python budget counts no `tests/` file. No reset is therefore expected; P0-T8 records the route and the contingency.
- PD9b - The four RUN scripts are `.sh` files written to a git-ignored folder; no `.ps1` or `.py` scratch file is written, so no batch-budget slot is consumed by tooling.
- PD10 - Pre-existing failures. A test failing at BASE_SHA is recorded by name in its baseline artifact as the pre-existing set. A final gate passes when its failing set is a subset of the recorded pre-existing set and contains no test from PESTER-824, the two Python modules this plan writes, or PARITY-SET (apart from KL-510). AC-13 lists every pre-existing failure that remains.
- PD11 - TypeScript gates are no-regression gates: no TypeScript file changes, so each final TypeScript step must reproduce its baseline exit code and must not report a new finding or failing test.
- PD12 - AC-15 concerns the pull request, which the parallel orchestrator authors after this plan. P7-T2 writes the PR-body callout notes; P11-T15 leaves AC-15 unchecked and records it as pending PR authoring.

### Phase 0 — Policy Reads, Baseline Capture, and Prior-Work Fetch

- [x] [P0-T1] Verify the full-bug preconditions for FEATURE (`docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`, `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/issue.md`) and record FEATURE/evidence/baseline/phase0-mode-check.TS.md.
      Commands (route probe first, then the precondition checks): `cp --version`; `mkdir --version`; `tail --version`; `wc --version`; `npm --version`; `node --version`; `npx --version`; `poetry run python --version`; `sh -c "exit 0"`; `git branch --show-current`; `ls docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824`; `grep -c '^## Acceptance Criteria$' docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`; `grep -c "^- \[ \] AC-[0-9]" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`; `grep -c -F -e "- Work Mode: full-bug" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/issue.md`.
      Acceptance: each of the nine probe commands exits 0, and the artifact records its exit code and first output line (`sh -c "exit 0"` prints nothing). Any hook or permission denial of a probe command is recorded verbatim in `Output Summary:`, and the plan stops at P0-T1, after this artifact is written and before any other task or repository write, for an orchestrator decision; the executor does not reword or bypass a denied command. `grep` and `ls` are exercised by the precondition commands below and fall under the same denial rule. The branch command prints exactly `bug/issue-823-tier-rule-adoption-follow-ups-824` (any other value stops the plan; in particular `bug/promotion-hook-raw-containment-false-positive-deny-824` is never used); the listing contains `spec.md` and `issue.md` and no `user-story.md`; the heading grep prints 1; the AC grep prints 15; the work-mode grep prints 1.
- [x] [P0-T2] Read the policy files in the required order and record FEATURE/evidence/baseline/phase0-instructions-read.md with `Timestamp:`, `Policy Order:`, and the list of files read, in this order: (1) `CLAUDE.md`, `.github/copilot-instructions.md`, `.claude/rules/tonality.md`; (2) `.github/instructions/general-code-change.instructions.md`, `.claude/rules/general-code-change.md`; (3) `.github/instructions/general-unit-test.instructions.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`; (4) `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/rules/powershell.md`; (5) `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`; (6) `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.claude/rules/typescript.md`; (7) `.claude/rules/shell.md`; (8) the policy files this plan edits: `.github/instructions/csharp-code-change.instructions.md`, `.github/instructions/csharp-unit-test.instructions.md`, `.claude/rules/csharp.md`, `.claude/rules/architecture-boundaries.md`; (9) `.claude/rules/plan-acceptance-gates.md`, `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, `.claude/skills/acceptance-criteria-tracking/SKILL.md`.
      Acceptance: the artifact has the three required headers and lists all 26 files in that order.
- [x] [P0-T3] Record BASE_SHA and the clean pre-edit state outside FEATURE, and confirm RESEARCH_BASE is an ancestor; record FEATURE/evidence/baseline/base-sha.TS.md.
      Commands: `git rev-parse HEAD`; `git merge-base --is-ancestor e7d3779b398604af919678c16c877c8539a86cc0 HEAD`; `git status --porcelain -- . ':!docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824' ':!docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md'`; `git status --porcelain -- docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md`.
      Acceptance: `git rev-parse HEAD` prints one 40-character SHA, recorded as BASE_SHA; the ancestry check exits 0; the first status command prints nothing. The second status command prints either nothing, recorded as `PROMOTION_DELETE: committed` (the promotion deletion of the potential file is already in BASE_SHA), or exactly the one line ` D docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md`, recorded as `PROMOTION_DELETE: pending` (the deletion is in the working tree only; the orchestrator commits it, the executor never restores, stages, or commits it). A non-zero ancestry check, any output from the first status command, or any other output from the second status command stops the plan. The last command exits 0, so `EXIT_CODE: 0`.
- [x] [P0-T4] Re-derive which write-set files moved between RESEARCH_BASE and BASE_SHA, including the #847 and #841 overlaps, and record FEATURE/evidence/baseline/overlap-check.TS.md.
      Commands (substitute the recorded BASE_SHA): `git diff --stat e7d3779b398604af919678c16c877c8539a86cc0 BASE_SHA -- .claude/hooks/validate-feature-review-coverage.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1 .claude/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`; `git diff --stat e7d3779b398604af919678c16c877c8539a86cc0 BASE_SHA -- .claude/rules .claude/agents/feature-review.md .claude/skills/quota-throttling .agents/skills .github/instructions/csharp-code-change.instructions.md .github/instructions/csharp-unit-test.instructions.md .github/agents/csharp-typed-engineer.agent.md .codex/codex-web-setup.sh extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`; `git log --oneline e7d3779b398604af919678c16c877c8539a86cc0..BASE_SHA -- .claude/hooks/validate-feature-review-coverage.ps1 .claude/skills/feature-review-workflow/SKILL.md`; `git status --porcelain -- .claude/hooks .claude/skills/feature-review-workflow`.
      Acceptance: every command exits 0; the artifact records, per path, `MOVED` (the path appears in a `--stat` listing) or `UNMOVED`, and lists the commits the `git log` command prints. A `MOVED` path is not a stop condition: its HAP task applies the forward check first and uses the Appendix A fallback only when that check fails. The status command prints nothing.
- [x] [P0-T5] Fetch WIP_REF and record WIP_SHA, WIP_BASE, and the reuse inventory; record FEATURE/evidence/baseline/wip-ref.TS.md.
      Commands (substitute recorded values): `git fetch origin wip/preserve-824-addendum2-2026-10-08`; `git rev-parse --verify origin/wip/preserve-824-addendum2-2026-10-08`; `git merge-base BASE_SHA WIP_SHA`; `mkdir -p artifacts/orchestration/wip824-hunks`; `git diff --name-status WIP_BASE WIP_SHA -- .claude/hooks/feature-review-coverage-thresholds.ps1 .claude/hooks/validate-feature-review-coverage.ps1 .claude/rules/architecture-boundaries.md .claude/rules/general-unit-test.md .claude/rules/quality-tiers.md .claude/agents/feature-review.md .claude/skills/feature-review-workflow/SKILL.md .claude/skills/quota-throttling/SKILL.md .agents/skills/architecture-boundaries/SKILL.md .agents/skills/csharp/SKILL.md .agents/skills/csharp-qa-gate/SKILL.md .agents/skills/general-unit-test/SKILL.md .agents/skills/quality-tiers/SKILL.md .github/instructions/csharp-code-change.instructions.md .github/instructions/csharp-unit-test.instructions.md .github/agents/csharp-typed-engineer.agent.md .codex/codex-web-setup.sh tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 tests/shell/test_codex_web_setup_codex_copy.bats tests/fixtures/codex_web_setup/populated-packages/packages/placeholder.txt extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`; `git status --porcelain -- artifacts/orchestration`.
      Acceptance: the fetch exits 0; `rev-parse` prints one SHA (WIP_SHA); `merge-base` prints one SHA (WIP_BASE); the name-status listing prints exactly 24 lines: `A` for the helper, the four new test files, and the fixture (6), and `M` for the other 18 paths. The status command prints nothing (the folder is git-ignored). A missing path or an extra status letter stops the plan.
- [x] [P0-T6] Create the four RUN scripts `artifacts/orchestration/wip824-run/pester-files.sh`, `artifacts/orchestration/wip824-run/poshqc-format.sh`, `artifacts/orchestration/wip824-run/poshqc-analyze.sh`, and `artifacts/orchestration/wip824-run/poshqc-test.sh` with exactly the content of Appendix G (Write tool, LF line endings), and record FEATURE/evidence/baseline/run-scripts.TS.md.
      Commands: `git check-ignore -q artifacts/orchestration/wip824-run/pester-files.sh`; `sh -n artifacts/orchestration/wip824-run/pester-files.sh`; `sh -n artifacts/orchestration/wip824-run/poshqc-format.sh`; `sh -n artifacts/orchestration/wip824-run/poshqc-analyze.sh`; `sh -n artifacts/orchestration/wip824-run/poshqc-test.sh`.
      Acceptance: every command exits 0. These scripts are git-ignored tooling, not repository deliverables.
- [x] [P0-T7] Author the write-set declaration FEATURE/evidence/other/write-set.TS.md listing every repository file this plan writes, one per line, exactly these 46 paths: `.claude/hooks/feature-review-coverage-thresholds.ps1`, `.claude/hooks/validate-feature-review-coverage.ps1`, `.claude/rules/architecture-boundaries.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/agents/feature-review.md`, `.claude/skills/feature-review-workflow/SKILL.md`, `.claude/skills/quota-throttling/SKILL.md`, `.agents/skills/architecture-boundaries/SKILL.md`, `.agents/skills/csharp/SKILL.md`, `.agents/skills/csharp-qa-gate/SKILL.md`, `.agents/skills/general-unit-test/SKILL.md`, `.agents/skills/quality-tiers/SKILL.md`, `.github/instructions/csharp-code-change.instructions.md`, `.github/instructions/csharp-unit-test.instructions.md`, `.github/agents/csharp-typed-engineer.agent.md`, `.codex/codex-web-setup.sh`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/feature-review-coverage-thresholds.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/rules/architecture-boundaries.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/quota-throttling/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/architecture-boundaries/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-qa-gate/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh`, `extensions/drm-copilot/resources/customizations/.github/instructions/csharp-code-change.instructions.md`, `extensions/drm-copilot/resources/customizations/.github/instructions/csharp-unit-test.instructions.md`, `extensions/drm-copilot/resources/customizations/.github/agents/csharp-typed-engineer.agent.md`, `tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1`, `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1`, `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`, `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`, `tests/shell/test_codex_web_setup_codex_copy.bats`, `tests/fixtures/codex_web_setup/populated-packages/packages/placeholder.txt`, `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/issue.md`, `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md` (AC check-off only), `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/plan.2026-10-08T22-16.md` (task check-off only). Evidence artifacts under FEATURE/evidence/ are written in addition. The promotion deletion of `docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md` is orchestrator work and is not part of this write set (P0-T3 and P10-T2 account for it).
      Command: `grep -c -e "^- " docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/evidence/other/write-set.TS.md` (substitute the artifact's TS).
      Acceptance: the artifact lists each path as a `- ` bullet, contains no other line beginning with `- `, and the grep prints 46. The list is the authoritative write set for P10-T2.
- [x] [P0-T8] Record the batch-budget route and the PowerShell write count for this plan (PD9), and record FEATURE/evidence/baseline/batch-budget.TS.md.
      Commands: `ls .claude/state`; `grep -c -E "\"route_id\": \"(large|remediation|preparation)\"" artifacts/orchestration/orchestrator-state.json`; `grep -c -F "\"next_step\": \"complete\"" artifacts/orchestration/orchestrator-state.json`; `ls artifacts/orchestration/orchestrator-state.json`.
      Acceptance: the artifact records the state-file names the first `ls` prints (a non-zero exit with "No such file or directory" is recorded in `Output Summary:` as `NO STATE DIRECTORY`), the route grep count (1 means the budget is inactive; 0 means direct mode applies), and the terminal grep count (0 expected). None of these values is a stop condition, because the plan's maximum of two production PowerShell Write/Edit paths stays under the direct-mode cap of three. The last `ls` exits 0 (the checkpoint exists), so `EXIT_CODE: 0`. It records `PLANNED PRODUCTION POWERSHELL WRITE/EDIT PATHS: 2 maximum (cap 3)`. Contingency: if any later Write or Edit is denied with `POWERSHELL_LARGE_PATH_REQUIRED`, stop and report the denial text to the orchestrator; the executor does not delete the state file on its own authority.
- [x] [P0-T9] Baseline mirror identity for the 16 repository/bundle pairs that later tasks re-copy, and record FEATURE/evidence/baseline/mirror-identity.TS.md.
      Commands (one per pair, then status): `git diff --no-index --exit-code .claude/hooks/validate-feature-review-coverage.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1`; `git diff --no-index --exit-code .claude/rules/architecture-boundaries.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/architecture-boundaries.md`; `git diff --no-index --exit-code .claude/rules/general-unit-test.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md`; `git diff --no-index --exit-code .claude/rules/quality-tiers.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md`; `git diff --no-index --exit-code .claude/agents/feature-review.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md`; `git diff --no-index --exit-code .claude/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`; `git diff --no-index --exit-code .claude/skills/quota-throttling/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/quota-throttling/SKILL.md`; `git diff --no-index --exit-code .agents/skills/architecture-boundaries/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/architecture-boundaries/SKILL.md`; `git diff --no-index --exit-code .agents/skills/csharp/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp/SKILL.md`; `git diff --no-index --exit-code .agents/skills/csharp-qa-gate/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-qa-gate/SKILL.md`; `git diff --no-index --exit-code .agents/skills/general-unit-test/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md`; `git diff --no-index --exit-code .agents/skills/quality-tiers/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md`; `git diff --no-index --exit-code .codex/codex-web-setup.sh extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh`; `git diff --no-index --exit-code .github/instructions/csharp-code-change.instructions.md extensions/drm-copilot/resources/customizations/.github/instructions/csharp-code-change.instructions.md`; `git diff --no-index --exit-code .github/instructions/csharp-unit-test.instructions.md extensions/drm-copilot/resources/customizations/.github/instructions/csharp-unit-test.instructions.md`; `git diff --no-index --exit-code .github/agents/csharp-typed-engineer.agent.md extensions/drm-copilot/resources/customizations/.github/agents/csharp-typed-engineer.agent.md`; `git status --porcelain -- extensions/drm-copilot/resources`.
      Acceptance: each of the 16 diffs exits 0 and prints nothing, and the status command prints nothing. An unequal pair stops the plan, because each later `cp` must be a pure sync and must not carry unrelated drift.
- [x] [P0-T10] Baseline line counts, the pack-manifest entry count, and the tier-module test count; record FEATURE/evidence/baseline/sizes.TS.md.
      Commands: `wc -l .claude/hooks/validate-feature-review-coverage.ps1 tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py .codex/codex-web-setup.sh`; `poetry run python -c "import json; d=json.load(open('extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json', encoding='utf-8')); print('PATHS', len(d['paths']))"`; `grep -c -F "hook-command-raw-invocation" extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`; `poetry run pytest tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py --collect-only -q`.
      Acceptance: the line counts are recorded as BASE_HOOK_LINES (459 at RESEARCH_BASE), BASE_TIER_LINES (463 at RESEARCH_BASE), and BASE_SETUP_LINES (384 at RESEARCH_BASE); different values are recorded, not a stop condition, provided each is at most 500. The manifest command prints `PATHS <n>`, recorded as BASE_MANIFEST_PATHS. The raw-invocation grep count is recorded as BASE_RAW_ENTRY (0 at RESEARCH_BASE; another #824 item may add it). The collection run prints "80 tests collected", recorded as BASE_TIER_COUNT; another count is recorded and used in place of 80 in P1-T2 and P8-T2.
- [x] [P0-T11] Baseline Python format check (`pyproject.toml` `[tool.black]`), and record FEATURE/evidence/baseline/black-check.TS.md.
      Command: `poetry run black --check .`.
      Acceptance: exit 0 and the summary line containing "would be left unchanged". A non-zero exit is recorded verbatim and stops the plan.
- [x] [P0-T12] Baseline Python lint (`pyproject.toml` `[tool.ruff]`), and record FEATURE/evidence/baseline/ruff-check.TS.md.
      Command: `poetry run ruff check`.
      Acceptance: exit 0 and the line "All checks passed!". A non-zero exit stops the plan.
- [x] [P0-T13] Baseline Python type check (`pyproject.toml` `[tool.pyright]`), and record FEATURE/evidence/baseline/pyright.TS.md.
      Command: `poetry run pyright`.
      Acceptance: exit 0 and a summary line beginning "0 errors". A non-zero exit stops the plan.
- [x] [P0-T14] Baseline PARITY-SET run (the five files named in Terms), and record FEATURE/evidence/baseline/parity-set-pytest.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`.
      Acceptance: the exit code and the summary line are recorded; the passed count is BASE_PARITY_PASSED. A KL-510 failure is recorded as `KL-510: STATE-ONLY` with `ExpectedExitCode: 1` when it is the only failure. Any other failure is recorded by name as the pre-existing set (PD10).
- [x] [P0-T15] Baseline full pytest run in coverage mode (sources from `pyproject.toml` `[tool.coverage.run]`), run in the background, and record FEATURE/evidence/baseline/pytest-full-coverage.TS.md.
      Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`.
      Acceptance: the exit code, the summary line, the verbatim `TOTAL` row, and every `FAILED` line are recorded; the passed count is BASE_FULL_PASSED; failures other than KL-510 are recorded by name as the pre-existing Python set (PD10).
- [x] [P0-T16] Baseline numeric Python line and branch coverage from the P0-T15 JSON report, and record FEATURE/evidence/baseline/python-coverage-values.TS.md.
      Command: `poetry run python -c "import json, pathlib; t = json.loads(pathlib.Path('artifacts/python/coverage.json').read_text(encoding='utf-8'))['totals']; print('LINE', round(t['percent_statements_covered'], 2), 'BRANCH', round(t['percent_branches_covered'], 2), 'COMBINED', round(t['percent_covered'], 2))"`.
      Acceptance: exit 0 and one line `LINE <n> BRANCH <n> COMBINED <n>`; the values are BASE_PY_LINE, BASE_PY_BRANCH, BASE_PY_COMBINED. Empty or non-numeric output stops the plan.
- [x] [P0-T17] Baseline targeted Pester run of the existing hook suite `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1` through the RUN script, and record FEATURE/evidence/baseline/pester-hook-suite.TS.md.
      Command: `sh artifacts/orchestration/wip824-run/pester-files.sh tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`.
      Acceptance: exit 0 and the summary line `Passed=4 Failed=0 FailedBlocks=0 FailedContainers=0`. Any failure stops the plan.
- [x] [P0-T18] Baseline PoshQC format over the two folders this plan touches (`.claude/hooks`, `tests/scripts/claude-hooks`), with a before-and-after tree observation, and record FEATURE/evidence/baseline/poshqc-format.TS.md.
      Commands: `git status --porcelain -- .claude/hooks tests/scripts/claude-hooks`; `sh artifacts/orchestration/wip824-run/poshqc-format.sh`; `git status --porcelain -- .claude/hooks tests/scripts/claude-hooks`.
      Acceptance: the formatter exits 0; both status commands print nothing; the formatter output contains no line beginning "Formatted:" (the success case prints only "Already formatted:" lines). The artifact records the count of "Already formatted:" lines, not their host paths. A rewritten file stops the plan, because pre-existing format drift would make the final gate unsatisfiable without out-of-scope edits; this includes any rewrite of a hard-excluded hook, which the executor reports and does not revert on its own authority.
- [x] [P0-T19] Baseline PoshQC analyze over the same two folders, and record FEATURE/evidence/baseline/poshqc-analyze.TS.md.
      Command: `sh artifacts/orchestration/wip824-run/poshqc-analyze.sh`.
      Acceptance: exit 0 and an output line beginning "PSScriptAnalyzer passed: no findings under" (the host path after "under" is not recorded). A finding stops the plan.
- [x] [P0-T20] Baseline full PoshQC test run with coverage (`config/poshqc-scan.json` folders, `config/poshqc-coverage.json` roots), run in the background, plus the JUnit totals; record FEATURE/evidence/baseline/poshqc-test.TS.md.
      Commands: `sh artifacts/orchestration/wip824-run/poshqc-test.sh`; the JUnit one-liner of Appendix G, item G6.
      Acceptance: the test exit code is recorded (non-zero when any test failed, because the settings set `Run.Exit`); the one-liner exits 0 and prints `ROOT <tag> TESTS <n> FAILURES <n> ERRORS <n> DISABLED <n>` followed by one `FAILED` line per failing test case. The totals are BASE_PS_TESTS and BASE_PS_FAILURES; every `FAILED` name is recorded as the pre-existing PowerShell set (PD10). A `None` value in the totals line stops the plan.
- [x] [P0-T21] Baseline numeric PowerShell coverage from the P0-T20 report, and record FEATURE/evidence/baseline/powershell-coverage-values.TS.md.
      Command: the coverage one-liner of Appendix G, item G5.
      Acceptance: exit 0; one line `REPO_LINE <n> SOURCEFILES <n>` (recorded as BASE_PS_LINE) and two `FILE` lines: `.claude/hooks/validate-feature-review-coverage.ps1 <n>` (BASE_HOOK_COV, numeric) and `.claude/hooks/feature-review-coverage-thresholds.ps1 MISSING` (the helper does not exist yet). A non-numeric BASE_PS_LINE or BASE_HOOK_COV stops the plan.
- [x] [P0-T22] Install the extension dependencies and confirm Jest resolves, and record FEATURE/evidence/baseline/npm-ci.TS.md.
      Commands: `npm --prefix extensions/drm-copilot ci`; `ls -d extensions/drm-copilot/node_modules/jest extensions/drm-copilot/node_modules/prettier`.
      Acceptance: both exit 0; the `ls` output names both directories. Rationale: `node_modules` is git-ignored and may be absent in this worktree.
- [x] [P0-T23] Baseline Prettier check of the extension sources (the globs of the extension `format` script, spelled from the repository root), and record FEATURE/evidence/baseline/prettier-check.TS.md.
      Command: `node extensions/drm-copilot/node_modules/prettier/bin/prettier.cjs --check "extensions/drm-copilot/src/**/*.ts" "extensions/drm-copilot/test/**/*.ts" "extensions/drm-copilot/*.json" "extensions/drm-copilot/*.cjs"`.
      Acceptance: the exit code and the final summary line are recorded as BASE_PRETTIER (the clean-case line is "All matched files use Prettier code style!"; a non-zero exit is recorded with the listed files, not a stop condition, per PD11).
- [x] [P0-T24] Baseline ESLint (`extensions/drm-copilot/package.json` script `lint`), and record FEATURE/evidence/baseline/eslint.TS.md.
      Command: `npm --prefix extensions/drm-copilot run lint`.
      Acceptance: the exit code and the problem-count summary (or its absence on a clean run) are recorded as BASE_ESLINT.
- [x] [P0-T25] Baseline TypeScript type check (`extensions/drm-copilot/package.json` script `typecheck`), and record FEATURE/evidence/baseline/tsc.TS.md.
      Command: `npm --prefix extensions/drm-copilot run typecheck`.
      Acceptance: the exit code and the count of lines containing "error TS" are recorded as BASE_TSC.
- [x] [P0-T26] Baseline Jest suite in coverage mode (`extensions/drm-copilot/package.json` script `test:coverage`), run in the background, and record FEATURE/evidence/baseline/jest-coverage.TS.md.
      Command: `npm --prefix extensions/drm-copilot run test:coverage`.
      Acceptance: the exit code, the Jest `Tests:` line, and the text-summary lines beginning `Statements`, `Branches`, and `Lines` are recorded; the Lines and Branches percentages are BASE_TS_LINES and BASE_TS_BRANCHES; every failing test name is recorded as the pre-existing TypeScript set (PD10).
- [x] [P0-T27] Baseline syntax check of both setup-script copies, and record FEATURE/evidence/baseline/sh-syntax.TS.md.
      Commands: `sh -n .codex/codex-web-setup.sh`; `sh -n extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh`.
      Acceptance: both exit 0 with no output.
- [x] [P0-T28] Probe the local bats route (no suite is run), and record FEATURE/evidence/baseline/bats-probe.TS.md.
      Command: `npx --yes bats --version`.
      Acceptance: the exit code and the printed version are recorded; exit 0 with a line beginning "Bats" records `BATS_LOCAL: available`; any other outcome (including a hook denial, recorded verbatim) records `BATS_LOCAL: unavailable`. Either value is a pass for this task; P5-T16 and P9-T15 branch on it.

### Phase 1 — Regression Tests First (Written From Prior Work)

Each task in this phase writes FEATURE/evidence/other/p1-tN.TS.md (N is the task number). No test is run in this phase except collection; the bats suite is not run (PD6).

- [x] [P1-T1] Write `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` by HAP with patch `p18-test-follow-ups.patch`, then apply adaptations F1 through F6 of Appendix B with the Edit tool.
      Commands: the five HAP commands of Appendix A for this path; `grep -c "^def test_" tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; `grep -c -F "FALLBACK_TOKEN" tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; `grep -c -F "noqa" tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; `grep -c -F "FALLBACK_PHRASE" tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; `grep -c -F "PRE_EXISTING_NAME_EXCEPTIONS" tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; `grep -c -F "EXPECTED_LISTED_COPY_COUNT = 36" tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; `grep -c -E "tempfile|tmp_path|subprocess|os\.system|Popen" tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; `wc -l tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; `poetry run pytest tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py --collect-only -q`.
      Acceptance: the HAP acceptance of Appendix A holds (new-file patch, so no fallback); before the edits the reverse check passes, and after F1-F6 the greps print: `def test_` 11; `FALLBACK_TOKEN` 0; `noqa` 0; `FALLBACK_PHRASE` 2; `PRE_EXISTING_NAME_EXCEPTIONS` 4; `EXPECTED_LISTED_COPY_COUNT = 36` 1; the forbidden-pattern grep 0. The line count is at most 500. Collection prints "43 tests collected" and exits 0. The last command is the collection run, so `EXIT_CODE: 0`.
- [x] [P1-T2] Update `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` by HAP with patch `p19-test-tier-gate.patch` (review note B, adopted verbatim per PD4).
      Commands: the five HAP commands of Appendix A for this path; `grep -c '^import re$' tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`; `grep -c -F "coverage_threshold_context" tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`; `grep -c "^def test_" tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`; `wc -l tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`; `poetry run pytest tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py --collect-only -q`.
      Acceptance: HAP acceptance holds; `import re` 1; `coverage_threshold_context` 4; `def test_` 18; the line count is at most 500 (BASE_TIER_LINES plus 30 expected); collection reports BASE_TIER_COUNT plus 1 tests (81 at RESEARCH_BASE).
- [x] [P1-T3] Format, lint, and type-check `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` and `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` before their first run.
      Commands: `poetry run black tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`; `poetry run black --check tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`; `poetry run ruff check tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`; `poetry run pyright tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`.
      Acceptance: the first black command exits 0 and its summary ("2 files left unchanged." or a line containing "reformatted") is recorded verbatim; the `--check` command exits 0 and prints "2 files would be left unchanged."; ruff exits 0 and prints "All checks passed!"; pyright exits 0 with a summary beginning "0 errors". A ruff or pyright finding is fixed in the named file without changing any test name, assertion literal, or constant value, and this task is rerun from its first command.
- [x] [P1-T4] Write `tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1` by HAP with patch `p20-test-resolver.patch`, then apply adaptations C1 and C2 of Appendix C with the Edit tool (comparator rows, combined-phrase limitation row, adjusted out-of-range row).
      Commands: the five HAP commands of Appendix A for this path; `grep -c -F "@{ Id = " tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1`; `grep -c -F "Line coverage was 62% last release." tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1`; `grep -c -F "Line and branch coverage >= 70%." tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1`; `grep -c -E "New-TemporaryFile|GetTempFileName|Set-Content|Out-File" tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1`; `wc -l tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1`.
      Acceptance: HAP acceptance holds; the row grep prints 11; each quoted-row grep prints 1; the forbidden-pattern grep prints 0; the line count is at most 500. The last grep before `wc` expects 0, and `wc` exits 0, so `EXIT_CODE: 0`.
- [x] [P1-T5] Write `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1` by HAP with patch `p21-test-hook-824.patch` (verbatim).
      Commands: the five HAP commands of Appendix A for this path; `grep -c -F "It 'F824-" tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1`; `grep -c -F "'CLAUDE.md' {" tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1`; `grep -c -E "New-TemporaryFile|GetTempFileName|Set-Content|Out-File" tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1`; `wc -l tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1`.
      Acceptance: HAP acceptance holds; the `It 'F824-` grep prints 10 (F824-1 through F824-9 and the F824-V row template); the `CLAUDE.md` mock-case grep prints 3 (F824-1, F824-2, F824-3); the forbidden-pattern grep prints 0; the line count is at most 500.
- [x] [P1-T6] Write `tests/shell/test_codex_web_setup_codex_copy.bats` by HAP with patch `p22-test-bats.patch` (verbatim; not run in this phase, PD6).
      Commands: the five HAP commands of Appendix A for this path; `grep -c "^@test" tests/shell/test_codex_web_setup_codex_copy.bats`; `grep -c -E "mktemp|BATS_TEST_TMPDIR|BATS_TMPDIR" tests/shell/test_codex_web_setup_codex_copy.bats`.
      Acceptance: HAP acceptance holds; the `@test` grep prints 15; the temporary-file grep prints 0 (`EXIT_CODE: 1`, `ExpectedExitCode: 1`).
- [x] [P1-T7] Write `tests/fixtures/codex_web_setup/populated-packages/packages/placeholder.txt` by HAP with patch `p23-fixture.patch` (verbatim, LF line endings).
      Commands: the five HAP commands of Appendix A for this path; `git check-attr text eol -- tests/fixtures/codex_web_setup/populated-packages/packages/placeholder.txt`; `grep -c $'\r' tests/fixtures/codex_web_setup/populated-packages/packages/placeholder.txt`.
      Acceptance: HAP acceptance holds; `check-attr` prints `text: auto` and `eol: lf` (the repository rule `* text=auto eol=lf`, so no `.gitattributes` exemption is needed); the carriage-return grep prints 0 (`EXIT_CODE: 1`, `ExpectedExitCode: 1`).

### Phase 2 — Expect-Fail Evidence (Before Any Fix)

Restart carve-out: the planned red states in this phase do not trigger the Phase 9 restart rule.

- [x] [P2-T1] [expect-fail] Run `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` against the unmodified production text and record FEATURE/evidence/regression-testing/expect-fail-follow-ups-pytest.TS.md with `ExpectedExitCode: 1`.
      Commands: `git status --porcelain -- .claude .agents .github .codex extensions/drm-copilot/resources`; `poetry run pytest tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
      Acceptance: the status command prints nothing (no production, rule, skill, or mirror file has changed); pytest exits 1 and reports exactly 38 failed and 5 passed. The failing set is exactly: `test_listed_copy_names_no_consuming_product` (6), `test_surface_does_not_hard_code_solution_file` (14), `test_pushed_roots_carry_no_hard_coded_solution_file` (1), `test_review_workflow_step_eight_uses_governing_thresholds` (2), `test_precedence_copy_states_per_metric_fallback` (14), `test_pushed_rule_and_skill_files_name_no_consuming_product` (1). The passing set is `test_every_follow_up_copy_exists`, `test_consuming_product_detection_flags_a_reintroduced_name`, `test_step_eight_extraction_stops_at_step_nine`, `test_pushed_rule_and_skill_scan_covers_the_listed_copies`, and `test_name_exceptions_still_name_a_consuming_product`. Every `FAILED` line of the `-ra` summary is recorded. Any other split stops the plan. Derivation: the six listed copies name `TaskMaster` or `No-COM` (research section 1.2); the 14 solution surfaces carry `TaskMaster.sln` (research section 11 N1); step 8 of both workflow copies carries "< 80%" at line 149; no file carries "falls back independently"; the four exception files carry `No-COM` (`.claude/rules/typescript.md` line 57, `.claude/rules/csharp.md` lines 5 and 10).
- [x] [P2-T2] [expect-fail] Run the resolver suite `tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1` before the helper exists and record FEATURE/evidence/regression-testing/expect-fail-resolver-pester.TS.md with `ExpectedExitCode: 1`.
      Commands: `ls .claude/hooks/feature-review-coverage-thresholds.ps1`; `sh artifacts/orchestration/wip824-run/pester-files.sh tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1`.
      Acceptance: `ls` exits non-zero (the helper is absent); the runner exits 1 and prints a summary line with `Passed=0` and either `Failed=11` or a non-zero `FailedBlocks` or `FailedContainers` value (the `BeforeAll` dot-source of the absent helper fails). Any passing test stops the plan.
- [x] [P2-T3] [expect-fail] Run `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1` together with `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1` against the unmodified hook and record FEATURE/evidence/regression-testing/expect-fail-hook-pester.TS.md with `ExpectedExitCode: 1`.
      Command: `sh artifacts/orchestration/wip824-run/pester-files.sh tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`.
      Acceptance: exit 1 and the summary line `Passed=19 Failed=2 FailedBlocks=0 FailedContainers=0`; the detailed output marks exactly `F824-1` and `F824-3` as failed (the only lines containing `[-] F824-` are those two). Derivation: on BASE_SHA the hook compares line coverage with the fixed 85.0 (line 313), so the 80 percent line figure of F824-1 blocks where the stated 70 percent should allow, and F824-3 reports the line floor that its assertion excludes; F824-2 and the remaining 15 cases do not depend on the stated thresholds.
- [x] [P2-T4] Record the bats fail-before exception dossier FEATURE/evidence/regression-testing/fail-before-exception.bats.TS.md (PD6).
      Commands: `tail -n 1 .codex/codex-web-setup.sh`; `grep -c -F "list_root_solution_files" .codex/codex-web-setup.sh`; `grep -c -F "TaskMaster.sln" .codex/codex-web-setup.sh`.
      Acceptance: the dossier carries `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, and `WhyFailingRunImpossible:` stating that the suite's `setup` sources `.codex/codex-web-setup.sh`, whose last line on BASE_SHA runs `main` unconditionally, so a pre-fix run would execute the full setup against the host. Alternative proof: `tail` prints `main "$@"` (C824-1 asserts the guard line instead); the discovery-function grep prints 0 (C824-2 through C824-7 call functions that do not exist); the solution grep prints 6 (C824-8, C824-12, and C824-15 assert behavior that the fixed name contradicts). The last grep prints 6, so `EXIT_CODE: 0`.
- [x] [P2-T5] Record the note B fail-before exception dossier FEATURE/evidence/regression-testing/fail-before-exception.note-b.TS.md (PD7).
      Command: `poetry run python -c "t = 'Throttle new work at 80% of the quota window.'; print('OLD_SCAN_FLAGS', [x for x in ('80%', '90%') if x in t])"`.
      Acceptance: the dossier carries the four schema fields and `WhyFailingRunImpossible:` stating that note B changes only the assertion inside the test module, so no production state can make the narrowed test fail first. Alternative proof: the command exits 0 and prints `OLD_SCAN_FLAGS ['80%']`, showing that the BASE_SHA whole-text expression flags a figure unrelated to coverage; `test_retired_threshold_scan_reads_coverage_context_only` (added by P1-T2) asserts that the same sentence is not flagged after narrowing and that a coverage sentence still is.

### Phase 3 — FU-823-1: Threshold Precedence in the Feature-Review Hook

Each task writes FEATURE/evidence/other/p3-tN.TS.md unless it names another artifact.

- [x] [P3-T1] Create `.claude/hooks/feature-review-coverage-thresholds.ps1` by HAP with patch `p01-helper.patch` (prior-work resolver, adapted in P3-T2).
      Commands: the five HAP commands of Appendix A for this path; `grep -c -F "function Get-FeatureReviewCoverageThreshold" .claude/hooks/feature-review-coverage-thresholds.ps1`.
      Acceptance: HAP acceptance holds (new-file patch, no fallback); the grep prints 1.
- [x] [P3-T2] Update `.claude/hooks/feature-review-coverage-thresholds.ps1` with adaptations D1 and D2 of Appendix D (comparator requirement and documented combined-phrase limitation, PD3). This is the first production PowerShell Edit (PD9).
      Commands: `grep -c -F "no\s+less\s+than" .claude/hooks/feature-review-coverage-thresholds.ps1`; `grep -c -F "[char]0x2265" .claude/hooks/feature-review-coverage-thresholds.ps1`; `grep -c -F "Known limitation" .claude/hooks/feature-review-coverage-thresholds.ps1`; `grep -c -F "[^\r\n%]*?(?<![\d.])(?<pct>" .claude/hooks/feature-review-coverage-thresholds.ps1`; `poetry run python -c "import pathlib; b = pathlib.Path('.claude/hooks/feature-review-coverage-thresholds.ps1').read_bytes(); print('NON_ASCII_BYTES', sum(1 for x in b if x > 127))"`; `wc -l .claude/hooks/feature-review-coverage-thresholds.ps1`.
      Acceptance: the first three greps each print 1 (the `[char]0x2265` grep matches only the D2 pattern line); the fourth prints 0 (the unconstrained WIP pattern is gone); the byte check exits 0 and prints `NON_ASCII_BYTES 0` (the helper is ASCII only); the line count is at most 500, and `wc` is the last command, so `EXIT_CODE: 0`.
- [x] [P3-T3] Update `.claude/hooks/validate-feature-review-coverage.ps1` by HAP with patch `p02-hook.patch` (verbatim: docstring with precedence, defaults, and the per-metric fallback; dot-source of the helper; `-LineFloor`/`-BranchFloor` parameters; resolution once per run; governing figures in the reason strings). When P0-T4 recorded this path as MOVED and the forward check fails, use the Appendix A fallback.
      Commands: the five HAP commands of Appendix A for this path; `grep -c -F "80 percent" .claude/hooks/validate-feature-review-coverage.ps1`; `grep -c -F "falls back independently" .claude/hooks/validate-feature-review-coverage.ps1`; `grep -c -F "Get-FeatureReviewCoverageThreshold" .claude/hooks/validate-feature-review-coverage.ps1`; `grep -c -F "feature-review-coverage-thresholds.ps1" .claude/hooks/validate-feature-review-coverage.ps1`; `grep -c -F -e '-LineFloor $thresholds.Line' .claude/hooks/validate-feature-review-coverage.ps1`; `grep -c -F '[double]$BranchFloor = 75.0' .claude/hooks/validate-feature-review-coverage.ps1`; `grep -c -E '^ {4}\$BranchFloor = 75\.0' .claude/hooks/validate-feature-review-coverage.ps1`; `wc -l .claude/hooks/validate-feature-review-coverage.ps1`.
      Acceptance: HAP acceptance holds (or the fallback is recorded); greps print: "80 percent" 0; "falls back independently" 1; the resolver name 2; the helper file name 2; the `-LineFloor` call 1; the parameter default 1; the removed hard-coded assignment 0. The line count is at most 500 (BASE_HOOK_LINES plus 12 expected; a #847 change on BASE_SHA is included in the count, and a count above 500 stops the plan for a report).
- [x] [P3-T4] [pass-after] Run PESTER-824 after the helper and hook changes and record FEATURE/evidence/regression-testing/pass-after-pester-824.TS.md.
      Command: `sh artifacts/orchestration/wip824-run/pester-files.sh tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`.
      Acceptance: exit 0 and the summary line `Passed=32 Failed=0 FailedBlocks=0 FailedContainers=0` (11 resolver rows, 17 hook cases, 4 existing cases). A failure is fixed in the helper or hook only (never by editing a test), then P3-T2 or P3-T3 acceptance and this task are rerun.
- [x] [P3-T5] Update `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/feature-review-coverage-thresholds.ps1` by byte copy from `.claude/hooks/feature-review-coverage-thresholds.ps1`.
      Commands: `cp .claude/hooks/feature-review-coverage-thresholds.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/feature-review-coverage-thresholds.ps1`; `git diff --no-index --exit-code .claude/hooks/feature-review-coverage-thresholds.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/feature-review-coverage-thresholds.ps1`; `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/feature-review-coverage-thresholds.ps1`.
      Acceptance: `cp` exits 0; the diff exits 0 with no output; the status line shows the mirror as new (`??`).
- [x] [P3-T6] Update `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1` by byte copy from `.claude/hooks/validate-feature-review-coverage.ps1`.
      Commands: `cp .claude/hooks/validate-feature-review-coverage.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1`; `git diff --no-index --exit-code .claude/hooks/validate-feature-review-coverage.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1`; `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1`.
      Acceptance: `cp` exits 0; the diff exits 0 with no output; the status line shows the mirror modified (` M`).
- [x] [P3-T7] Update `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` with replacement M1 of Appendix D (adds only the helper entry; the WIP_REF `hook-command-raw-invocation.ps1` entry is not applied).
      Commands: `grep -c -F "\".claude/hooks/feature-review-coverage-thresholds.ps1\"," extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`; `grep -c -F "hook-command-raw-invocation" extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`; `poetry run python -c "import json; d=json.load(open('extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json', encoding='utf-8')); print('PATHS', len(d['paths']))"`.
      Acceptance: the helper-entry grep prints 1; the raw-invocation grep prints BASE_RAW_ENTRY (this task adds none); the JSON command exits 0 and prints `PATHS` followed by BASE_MANIFEST_PATHS plus 1.

### Phase 4 — FU-823-2: Neutral Names in the Listed Pushed Files

Each task writes FEATURE/evidence/other/p4-tN.TS.md.

- [x] [P4-T1] Update `.claude/rules/architecture-boundaries.md` by HAP with patch `p03-rule-architecture.patch` (canonical-policy edit authorized by PD1).
      Commands: the five HAP commands of Appendix A for this path; `grep -c -F "Host-Neutral Architecture Rules" .claude/rules/architecture-boundaries.md`; `grep -c -F "Outlook PIA" .claude/rules/architecture-boundaries.md`; `grep -c -E "TaskMaster|No-COM" .claude/rules/architecture-boundaries.md`.
      Acceptance: HAP acceptance holds; the heading grep prints 1; the substance grep prints 1 or more (rule substance kept); the name grep prints 0 (`EXIT_CODE: 1`, `ExpectedExitCode: 1`).
- [x] [P4-T2] Update `.agents/skills/architecture-boundaries/SKILL.md` by HAP with patch `p09-agents-architecture.patch`.
      Commands: the five HAP commands of Appendix A for this path; `grep -c -F "Host-Neutral Architecture Rules" .agents/skills/architecture-boundaries/SKILL.md`; `grep -c -F "Outlook PIA" .agents/skills/architecture-boundaries/SKILL.md`; `grep -c -E "TaskMaster|No-COM" .agents/skills/architecture-boundaries/SKILL.md`.
      Acceptance: as P4-T1 (`EXIT_CODE: 1`, `ExpectedExitCode: 1`).
- [x] [P4-T3] Update `.claude/skills/quota-throttling/SKILL.md` by HAP with patch `p08-skill-quota-throttling.patch`.
      Commands: the five HAP commands of Appendix A for this path; `grep -c -F "consumer-repository runs" .claude/skills/quota-throttling/SKILL.md`; `grep -c -E "TaskMaster|No-COM" .claude/skills/quota-throttling/SKILL.md`.
      Acceptance: HAP acceptance holds; the first grep prints 1; the second prints 0 (`EXIT_CODE: 1`, `ExpectedExitCode: 1`).
- [x] [P4-T4] Update `extensions/drm-copilot/resources/claude-customizations/.claude/rules/architecture-boundaries.md` by byte copy from `.claude/rules/architecture-boundaries.md`.
      Commands: `cp .claude/rules/architecture-boundaries.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/architecture-boundaries.md`; `git diff --no-index --exit-code .claude/rules/architecture-boundaries.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/architecture-boundaries.md`; `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/rules/architecture-boundaries.md`.
      Acceptance: `cp` exits 0; the diff exits 0 with no output; the status line shows ` M`.
- [x] [P4-T5] Update `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/architecture-boundaries/SKILL.md` by byte copy from `.agents/skills/architecture-boundaries/SKILL.md`.
      Commands: `cp .agents/skills/architecture-boundaries/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/architecture-boundaries/SKILL.md`; `git diff --no-index --exit-code .agents/skills/architecture-boundaries/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/architecture-boundaries/SKILL.md`; `git status --porcelain -- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/architecture-boundaries/SKILL.md`.
      Acceptance: `cp` exits 0; the diff exits 0 with no output; the status line shows ` M`.
- [x] [P4-T6] Update `extensions/drm-copilot/resources/claude-customizations/.claude/skills/quota-throttling/SKILL.md` by byte copy from `.claude/skills/quota-throttling/SKILL.md`.
      Commands: `cp .claude/skills/quota-throttling/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/quota-throttling/SKILL.md`; `git diff --no-index --exit-code .claude/skills/quota-throttling/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/quota-throttling/SKILL.md`; `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/skills/quota-throttling/SKILL.md`.
      Acceptance: `cp` exits 0; the diff exits 0 with no output; the status line shows ` M`.

### Phase 5 — FU-823-3: Solution-Neutral C# Commands

Each task writes FEATURE/evidence/other/p5-tN.TS.md unless it names another artifact.

- [x] [P5-T1] Update `.github/instructions/csharp-code-change.instructions.md` by HAP with patch `p14-github-csharp-code-change.patch` (canonical-policy edit authorized by PD1).
      Commands: the five HAP commands of Appendix A for this path; `grep -c -F "msbuild <solution>.sln" .github/instructions/csharp-code-change.instructions.md`; `grep -c -F "TaskMaster.sln" .github/instructions/csharp-code-change.instructions.md`.
      Acceptance: HAP acceptance holds; the placeholder grep prints 4; the solution grep prints 0 (`EXIT_CODE: 1`, `ExpectedExitCode: 1`).
- [x] [P5-T2] Update `.github/instructions/csharp-unit-test.instructions.md` by HAP with patch `p15-github-csharp-unit-test.patch` (canonical-policy edit authorized by PD1).
      Commands: the five HAP commands of Appendix A for this path; `grep -c -F "msbuild <solution>.sln" .github/instructions/csharp-unit-test.instructions.md`; `grep -c -F "TaskMaster.sln" .github/instructions/csharp-unit-test.instructions.md`.
      Acceptance: HAP acceptance holds; the placeholder grep prints 2; the solution grep prints 0 (`EXIT_CODE: 1`, `ExpectedExitCode: 1`).
- [x] [P5-T3] Update `.github/agents/csharp-typed-engineer.agent.md` by HAP with patch `p16-github-csharp-agent.patch`.
      Commands: the five HAP commands of Appendix A for this path; `grep -c -F "msbuild <solution>.sln" .github/agents/csharp-typed-engineer.agent.md`; `grep -c -F "TaskMaster.sln" .github/agents/csharp-typed-engineer.agent.md`.
      Acceptance: as P5-T2.
- [x] [P5-T4] Update `.agents/skills/csharp/SKILL.md` by HAP with patch `p10-agents-csharp.patch`.
      Commands: the five HAP commands of Appendix A for this path; `grep -c -F "msbuild <solution>.sln" .agents/skills/csharp/SKILL.md`; `grep -c -F "TaskMaster.sln" .agents/skills/csharp/SKILL.md`.
      Acceptance: as P5-T2.
- [x] [P5-T5] Update `.agents/skills/csharp-qa-gate/SKILL.md` by HAP with patch `p11-agents-csharp-qa-gate.patch`.
      Commands: the five HAP commands of Appendix A for this path; `grep -c -F "msbuild <solution>.sln" .agents/skills/csharp-qa-gate/SKILL.md`; `grep -c -F "TaskMaster.sln" .agents/skills/csharp-qa-gate/SKILL.md`.
      Acceptance: as P5-T2.
- [x] [P5-T6] Update `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp/SKILL.md` in place (bundle-only, no repository source) with the Edit tool, `replace_all` of the token `TaskMaster.sln` by `<solution>.sln`, changing nothing else.
      Commands: `grep -c -F "msbuild <solution>.sln /t:Rebuild /m" extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp/SKILL.md`; `git diff --numstat BASE_SHA -- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp/SKILL.md`; `git status --porcelain -- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp/SKILL.md`; `grep -c -F "TaskMaster.sln" extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp/SKILL.md`.
      Acceptance: the placeholder grep prints 2; numstat prints `2	2` followed by the path (only the two command lines changed); status shows ` M`; the last grep prints 0 (`EXIT_CODE: 1`, `ExpectedExitCode: 1`). The pinned strings of `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` lines 280-293 are verified by P8-T4.
- [x] [P5-T7] Update `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md` in place with the Edit tool, `replace_all` of `TaskMaster.sln` by `<solution>.sln`, changing nothing else.
      Commands: `grep -c -F "msbuild <solution>.sln /t:Rebuild /m" extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`; `git diff --numstat BASE_SHA -- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`; `git status --porcelain -- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`; `grep -c -F "TaskMaster.sln" extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`.
      Acceptance: as P5-T6.
- [x] [P5-T8] Update `.codex/codex-web-setup.sh` by HAP with patch `p17-codex-setup.patch` (solution discovery, restore guard, verify guard, notes placeholder, `BASH_SOURCE` source guard; the `vswhere` collapse it also contains is reverted by P5-T9).
      Commands: the five HAP commands of Appendix A for this path; `grep -c -F "list_root_solution_files" .codex/codex-web-setup.sh`; `grep -c -F -e "-SolutionPath <solution>.sln" .codex/codex-web-setup.sh`; `tail -n 1 .codex/codex-web-setup.sh`; `grep -c -F "TaskMaster.sln" .codex/codex-web-setup.sh`.
      Acceptance: HAP acceptance holds; the discovery grep prints 3 (definition and two calls); the notes-placeholder grep prints 3; `tail` prints `if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi`; the solution grep prints 0 (`EXIT_CODE: 1`, `ExpectedExitCode: 1`).
- [x] [P5-T9] Update `.codex/codex-web-setup.sh` with replacement E1 of Appendix E (restores the original multi-line `vswhere`/`vstest` block; FU-823-3 does not require the collapse) and verify the final diff carries no `vswhere` line.
      Commands (substitute BASE_SHA): `grep -c -F "vswhere_check" .codex/codex-web-setup.sh`; `grep -c -F '\$vswherePath = Join-Path' .codex/codex-web-setup.sh`; `git diff --unified=0 --output=artifacts/orchestration/wip824-hunks/codex-setup-final.diff BASE_SHA -- .codex/codex-web-setup.sh`; `git status --porcelain -- .codex/codex-web-setup.sh`; `sh -n .codex/codex-web-setup.sh`; `grep -c -e "^[-+].*vswhere" artifacts/orchestration/wip824-hunks/codex-setup-final.diff`.
      Acceptance: the `vswhere_check` grep prints 0; the `$vswherePath = Join-Path` grep prints 1; the diff command exits 0; status shows ` M`; `sh -n` exits 0; the last grep prints 0 (no added or removed diff line mentions `vswhere`), so `EXIT_CODE: 1` with `ExpectedExitCode: 1`.
- [x] [P5-T10] Update `extensions/drm-copilot/resources/customizations/.github/instructions/csharp-code-change.instructions.md` by byte copy from `.github/instructions/csharp-code-change.instructions.md`.
      Commands: `cp .github/instructions/csharp-code-change.instructions.md extensions/drm-copilot/resources/customizations/.github/instructions/csharp-code-change.instructions.md`; `git diff --no-index --exit-code .github/instructions/csharp-code-change.instructions.md extensions/drm-copilot/resources/customizations/.github/instructions/csharp-code-change.instructions.md`; `git status --porcelain -- extensions/drm-copilot/resources/customizations/.github/instructions/csharp-code-change.instructions.md`.
      Acceptance: `cp` exits 0; the diff exits 0 with no output; status shows ` M`.
- [x] [P5-T11] Update `extensions/drm-copilot/resources/customizations/.github/instructions/csharp-unit-test.instructions.md` by byte copy from `.github/instructions/csharp-unit-test.instructions.md`.
      Commands: `cp .github/instructions/csharp-unit-test.instructions.md extensions/drm-copilot/resources/customizations/.github/instructions/csharp-unit-test.instructions.md`; `git diff --no-index --exit-code .github/instructions/csharp-unit-test.instructions.md extensions/drm-copilot/resources/customizations/.github/instructions/csharp-unit-test.instructions.md`; `git status --porcelain -- extensions/drm-copilot/resources/customizations/.github/instructions/csharp-unit-test.instructions.md`.
      Acceptance: as P5-T10.
- [x] [P5-T12] Update `extensions/drm-copilot/resources/customizations/.github/agents/csharp-typed-engineer.agent.md` by byte copy from `.github/agents/csharp-typed-engineer.agent.md`.
      Commands: `cp .github/agents/csharp-typed-engineer.agent.md extensions/drm-copilot/resources/customizations/.github/agents/csharp-typed-engineer.agent.md`; `git diff --no-index --exit-code .github/agents/csharp-typed-engineer.agent.md extensions/drm-copilot/resources/customizations/.github/agents/csharp-typed-engineer.agent.md`; `git status --porcelain -- extensions/drm-copilot/resources/customizations/.github/agents/csharp-typed-engineer.agent.md`.
      Acceptance: as P5-T10.
- [x] [P5-T13] Update `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp/SKILL.md` by byte copy from `.agents/skills/csharp/SKILL.md`.
      Commands: `cp .agents/skills/csharp/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp/SKILL.md`; `git diff --no-index --exit-code .agents/skills/csharp/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp/SKILL.md`; `git status --porcelain -- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp/SKILL.md`.
      Acceptance: as P5-T10.
- [x] [P5-T14] Update `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-qa-gate/SKILL.md` by byte copy from `.agents/skills/csharp-qa-gate/SKILL.md`.
      Commands: `cp .agents/skills/csharp-qa-gate/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-qa-gate/SKILL.md`; `git diff --no-index --exit-code .agents/skills/csharp-qa-gate/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-qa-gate/SKILL.md`; `git status --porcelain -- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-qa-gate/SKILL.md`.
      Acceptance: as P5-T10.
- [x] [P5-T15] Update `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh` by byte copy from `.codex/codex-web-setup.sh`.
      Commands: `cp .codex/codex-web-setup.sh extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh`; `git diff --no-index --exit-code .codex/codex-web-setup.sh extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh`; `git status --porcelain -- extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh`; `sh -n extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh`.
      Acceptance: `cp` exits 0; the diff exits 0 with no output; status shows ` M`; `sh -n` exits 0.
- [x] [P5-T16] [pass-after] Run the bats suite `tests/shell/test_codex_web_setup_codex_copy.bats` after the source guard exists, on the branch P0-T28 recorded, and record FEATURE/evidence/regression-testing/pass-after-bats.TS.md.
      Command (branch `BATS_LOCAL: available`): `npx --yes bats tests/shell/test_codex_web_setup_codex_copy.bats`.
      Acceptance (local branch): exit 0 and the TAP output shows `1..15` and 15 `ok` lines with no `not ok` line. CI branch (taken only when P0-T28 recorded `BATS_LOCAL: unavailable`, or when the command above is denied by a hook, with the denial text recorded): the artifact records `PENDING-CI: tests/shell/test_codex_web_setup_codex_copy.bats runs in .github/workflows/_shell-coverage.yml (shell-qc test --coverage) on the PR head`, `EXIT_CODE: 0` for the recording step, and names AC-6 as pending that CI result; P11-T6 then leaves AC-6 unchecked. A local `not ok` line is fixed in `.codex/codex-web-setup.sh` only (then P5-T9, P5-T15, and this task are rerun), never by editing the suite.

### Phase 6 — FU-823-5 and Review Note A: Governing Thresholds and Per-Metric Fallback

Each task writes FEATURE/evidence/other/p6-tN.TS.md.

- [x] [P6-T1] Update `.claude/skills/feature-review-workflow/SKILL.md` by HAP with patch `p07-skill-feature-review-workflow.patch` (step 5 fallback sentence; step 8 trigger). When P0-T4 recorded this path as MOVED (#841) and the forward check fails, use the Appendix A fallback.
      Commands: the five HAP commands of Appendix A for this path; `grep -c -F "falls back independently" .claude/skills/feature-review-workflow/SKILL.md`; `grep -c -F "coverage below the governing thresholds defined in step 5" .claude/skills/feature-review-workflow/SKILL.md`; `grep -c -F "< 80% repo-wide" .claude/skills/feature-review-workflow/SKILL.md`.
      Acceptance: HAP acceptance holds (or the fallback is recorded); the first two greps each print 1; the last prints 0 (`EXIT_CODE: 1`, `ExpectedExitCode: 1`).
- [x] [P6-T2] Update `.claude/rules/quality-tiers.md` by HAP with patch `p05-rule-quality-tiers.patch` (note A; policy edit per PD1).
      Commands: the five HAP commands of Appendix A for this path; `grep -c -F "falls back independently" .claude/rules/quality-tiers.md`; `grep -c -F "Threshold precedence: when the repository's root" .claude/rules/quality-tiers.md`.
      Acceptance: HAP acceptance holds; the fallback grep prints 2 (precedence paragraph and rationale); the precedence grep prints 1 (the #823 sentence is kept, so the #823 fragments still match).
- [x] [P6-T3] Update `.claude/rules/general-unit-test.md` by HAP with patch `p04-rule-general-unit-test.patch` (note A; policy edit per PD1).
      Commands: the five HAP commands of Appendix A for this path; `grep -c -F "falls back independently" .claude/rules/general-unit-test.md`; `grep -c -F "Threshold precedence: when the repository's root" .claude/rules/general-unit-test.md`.
      Acceptance: HAP acceptance holds; both greps print 1.
- [x] [P6-T4] Update `.claude/agents/feature-review.md` by HAP with patch `p06-agent-feature-review.patch` (note A).
      Commands: the five HAP commands of Appendix A for this path; `grep -c -F "falls back independently" .claude/agents/feature-review.md`; `grep -c -F "version folder" .claude/agents/feature-review.md`; `grep -c -E "80%|90%" .claude/agents/feature-review.md`.
      Acceptance: HAP acceptance holds; the fallback grep prints 1; the pinned phrase grep prints 1 or more (`tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` pins it); the retired-figure grep prints 0 (`EXIT_CODE: 1`, `ExpectedExitCode: 1`).
- [x] [P6-T5] Update `.agents/skills/quality-tiers/SKILL.md` by HAP with patch `p13-agents-quality-tiers.patch` (note A, Codex chain wording).
      Commands: the five HAP commands of Appendix A for this path; `grep -c -F "falls back independently" .agents/skills/quality-tiers/SKILL.md`.
      Acceptance: HAP acceptance holds; the grep prints 2.
- [x] [P6-T6] Update `.agents/skills/general-unit-test/SKILL.md` by HAP with patch `p12-agents-general-unit-test.patch` (note A, Codex chain wording).
      Commands: the five HAP commands of Appendix A for this path; `grep -c -F "falls back independently" .agents/skills/general-unit-test/SKILL.md`.
      Acceptance: HAP acceptance holds; the grep prints 1.
- [x] [P6-T7] Update `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md` by byte copy from `.claude/skills/feature-review-workflow/SKILL.md`.
      Commands: `cp .claude/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`; `git diff --no-index --exit-code .claude/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`; `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`.
      Acceptance: `cp` exits 0; the diff exits 0 with no output; status shows ` M`.
- [x] [P6-T8] Update `extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md` by byte copy from `.claude/rules/quality-tiers.md`.
      Commands: `cp .claude/rules/quality-tiers.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md`; `git diff --no-index --exit-code .claude/rules/quality-tiers.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md`; `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md`.
      Acceptance: as P6-T7.
- [x] [P6-T9] Update `extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md` by byte copy from `.claude/rules/general-unit-test.md`.
      Commands: `cp .claude/rules/general-unit-test.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md`; `git diff --no-index --exit-code .claude/rules/general-unit-test.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md`; `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md`.
      Acceptance: as P6-T7.
- [x] [P6-T10] Update `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md` by byte copy from `.claude/agents/feature-review.md`.
      Commands: `cp .claude/agents/feature-review.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md`; `git diff --no-index --exit-code .claude/agents/feature-review.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md`; `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md`.
      Acceptance: as P6-T7.
- [x] [P6-T11] Update `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md` by byte copy from `.agents/skills/quality-tiers/SKILL.md`.
      Commands: `cp .agents/skills/quality-tiers/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md`; `git diff --no-index --exit-code .agents/skills/quality-tiers/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md`; `git status --porcelain -- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md`.
      Acceptance: as P6-T7.
- [x] [P6-T12] Update `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md` by byte copy from `.agents/skills/general-unit-test/SKILL.md`.
      Commands: `cp .agents/skills/general-unit-test/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md`; `git diff --no-index --exit-code .agents/skills/general-unit-test/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md`; `git status --porcelain -- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md`.
      Acceptance: as P6-T7.

### Phase 7 — Follow-Ups Record and PR-Body Callouts

- [ ] [P7-T1] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/issue.md` with insertions S1 through S5 of Appendix F (status marks; the prior target under `docs/features/potential/` no longer exists, so this is the redo of that WIP_REF change), and record FEATURE/evidence/other/p7-t1.TS.md.
      Commands: `grep -c -F "Status: Resolved by #824." docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/issue.md`; `grep -c -F "Status: Open (out of scope for #824; no release automation is run)." docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/issue.md`; `grep -c "^## FU-823-" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/issue.md`; `grep -c -F -e "- Work Mode: full-bug" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/issue.md`.
      Acceptance: the greps print 4, 1, 5, and 1 respectively.
- [ ] [P7-T2] Write the PR-body callout notes FEATURE/evidence/other/pr-body-callouts.TS.md with the content of Appendix H (for the parallel orchestrator's PR authoring; this plan does not author the PR).
      Commands (substitute the artifact's TS): `grep -c -F "Refs #824" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/evidence/other/pr-body-callouts.TS.md`; `grep -c -F ".github/instructions/csharp-code-change.instructions.md" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/evidence/other/pr-body-callouts.TS.md`; `grep -c -F "FU-823-4" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/evidence/other/pr-body-callouts.TS.md`; `grep -c -i -E "(close[sd]?|fix(e[sd])?|resolve[sd]?) #824" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/evidence/other/pr-body-callouts.TS.md`.
      Acceptance: the first three greps each print 1 or more; the closing-keyword grep prints 0 (`EXIT_CODE: 1`, `ExpectedExitCode: 1`).

### Phase 8 — Pass-After Verification

- [ ] [P8-T1] [pass-after] Run `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` after every production, policy, and mirror edit, and record FEATURE/evidence/regression-testing/pass-after-follow-ups-pytest.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
      Acceptance: exit 0 and a summary reporting 43 passed and no failed. A failure is fixed by correcting the edited production or mirror file (and re-copying the mirror), never by editing the test module; the affected Phase 3-7 task and this task are rerun.
- [ ] [P8-T2] [pass-after] Run `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` and record FEATURE/evidence/regression-testing/pass-after-tier-gate-pytest.TS.md.
      Commands: `poetry run pytest "tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_retired_threshold_scan_reads_coverage_context_only"`; `poetry run pytest tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`.
      Acceptance: the node run exits 0 and reports 1 passed; the module run exits 0 and reports BASE_TIER_COUNT plus 1 passed (81 at RESEARCH_BASE) and no failed.
- [ ] [P8-T3] [pass-after] Re-run PESTER-824 after all edits and record FEATURE/evidence/regression-testing/pass-after-pester-824-final.TS.md.
      Command: `sh artifacts/orchestration/wip824-run/pester-files.sh tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`.
      Acceptance: exit 0 and `Passed=32 Failed=0 FailedBlocks=0 FailedContainers=0`.
- [ ] [P8-T4] Run PARITY-SET and record FEATURE/evidence/qa-gates/parity-set-pytest.TS.md.
      Commands: `poetry run pytest "tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_codex_legacy_variant_files_contain_corrected_gate_commands" "tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_bundled_claude_files_are_listed_in_some_pack_manifest"`; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`.
      Acceptance: the node run exits 0 and reports 2 passed (variant pins and manifest completeness, including the new helper); the PARITY-SET run has no failed test other than KL-510 (recorded as in P0-T14; otherwise exit 0), and its passed count is at least BASE_PARITY_PASSED plus 1 (the note B test) minus the KL-510 adjustment.
- [ ] [P8-T5] Run the Jest twin `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` and record FEATURE/evidence/qa-gates/jest-manifest-twin.TS.md.
      Command: `npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts`.
      Acceptance: exit 0; the Jest `Tests:` line reports at least one passed test and no failed test.
- [ ] [P8-T6] Verify byte identity of all 17 repository/bundle pairs and record FEATURE/evidence/qa-gates/mirror-identity.TS.md.
      Commands: the 16 `git diff --no-index --exit-code` commands of P0-T9 in the same order; `git diff --no-index --exit-code .claude/hooks/feature-review-coverage-thresholds.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/feature-review-coverage-thresholds.ps1`; `git status --porcelain -- extensions/drm-copilot/resources`.
      Acceptance: each of the 17 diffs exits 0 with no output; the status listing shows exactly the 20 bundle paths of the P0-T7 write set: 19 ` M` lines (the 16 re-copied mirrors, the two variant files, and `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`) and 1 `??` line (the new helper mirror). When the orchestrator has committed between phases, `git diff --name-only BASE_SHA -- extensions/drm-copilot/resources` is recorded as well and the union of the two listings must equal the same 20 paths.
- [ ] [P8-T7] Verify the 500-line limit for every production and test file this plan writes, and record FEATURE/evidence/qa-gates/line-counts.TS.md.
      Command: `wc -l .claude/hooks/validate-feature-review-coverage.ps1 .claude/hooks/feature-review-coverage-thresholds.ps1 .codex/codex-web-setup.sh tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 tests/shell/test_codex_web_setup_codex_copy.bats`.
      Acceptance: exit 0 and every per-file count is at most 500; the hook count and the #823 test count are recorded explicitly as FINAL_HOOK_LINES and FINAL_TIER_LINES.

### Phase 9 — Final QA Loop

Restart rule: run P9-T1 through P9-T17 in order. If any step fails, or if any step changes a tracked or new file, fix the cause, re-copy the bundled mirror of any changed repository file that has one (the matching Phase 3-6 `cp` task), then restart from P9-T1 and rewrite every Phase 9 artifact with a new TS. The loop ends only when P9-T1 through P9-T17 pass in one uninterrupted pass. Each artifact records its loop iteration number in `Output Summary:`. When `poetry run black --check .` fails, the fix is `poetry run black` on the named files followed by a restart.

- [ ] [P9-T1] Python format check, and record FEATURE/evidence/qa-gates/black-check.TS.md.
      Command: `poetry run black --check .`.
      Acceptance: exit 0 and the summary containing "would be left unchanged" with no line containing "would reformat".
- [ ] [P9-T2] PoshQC format over `.claude/hooks` and `tests/scripts/claude-hooks` with a before-and-after observation, and record FEATURE/evidence/qa-gates/poshqc-format.TS.md.
      Commands: `git status --porcelain -- .claude/hooks tests/scripts/claude-hooks`; `sh artifacts/orchestration/wip824-run/poshqc-format.sh`; `git status --porcelain -- .claude/hooks tests/scripts/claude-hooks`.
      Acceptance: the formatter exits 0; its output contains no line beginning "Formatted:"; the two status listings are identical (the expected listing is ` M .claude/hooks/validate-feature-review-coverage.ps1`, `?? .claude/hooks/feature-review-coverage-thresholds.ps1`, and the two `??` test files, or nothing when the orchestrator has committed). A "Formatted:" line or a changed listing triggers the restart rule, with one exception: the formatter scans all of `.claude/hooks`, including the hard-excluded hooks, so a "Formatted:" line or a changed listing that names any file outside the P0-T7 write set (recorded by repository-relative tail) stops the plan for a report instead; the executor does not revert or re-edit that file on its own authority.
- [ ] [P9-T3] Prettier check of the extension sources, and record FEATURE/evidence/qa-gates/prettier-check.TS.md.
      Command: `node extensions/drm-copilot/node_modules/prettier/bin/prettier.cjs --check "extensions/drm-copilot/src/**/*.ts" "extensions/drm-copilot/test/**/*.ts" "extensions/drm-copilot/*.json" "extensions/drm-copilot/*.cjs"`.
      Acceptance: the exit code and summary equal BASE_PRETTIER (PD11); with a clean baseline this is exit 0 and "All matched files use Prettier code style!".
- [ ] [P9-T4] Python lint, and record FEATURE/evidence/qa-gates/ruff-check.TS.md.
      Command: `poetry run ruff check`.
      Acceptance: exit 0 and "All checks passed!".
- [ ] [P9-T5] PoshQC analyze over the same two folders, and record FEATURE/evidence/qa-gates/poshqc-analyze.TS.md.
      Command: `sh artifacts/orchestration/wip824-run/poshqc-analyze.sh`.
      Acceptance: exit 0 and a line beginning "PSScriptAnalyzer passed: no findings under".
- [ ] [P9-T6] ESLint, and record FEATURE/evidence/qa-gates/eslint.TS.md.
      Command: `npm --prefix extensions/drm-copilot run lint`.
      Acceptance: the exit code and problem summary equal BASE_ESLINT (PD11).
- [ ] [P9-T7] Python type check, and record FEATURE/evidence/qa-gates/pyright.TS.md.
      Command: `poetry run pyright`.
      Acceptance: exit 0 and a summary beginning "0 errors".
- [ ] [P9-T8] TypeScript type check, and record FEATURE/evidence/qa-gates/tsc.TS.md.
      Command: `npm --prefix extensions/drm-copilot run typecheck`.
      Acceptance: the exit code and the "error TS" line count equal BASE_TSC (PD11).
- [ ] [P9-T9] Shell syntax check of both setup-script copies, and record FEATURE/evidence/qa-gates/sh-syntax.TS.md.
      Commands: `sh -n .codex/codex-web-setup.sh`; `sh -n extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh`.
      Acceptance: both exit 0 with no output.
- [ ] [P9-T10] Full pytest run in coverage mode, run in the background, and record FEATURE/evidence/qa-gates/pytest-full-coverage.TS.md.
      Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`.
      Acceptance: the failing set is a subset of the P0-T15 pre-existing set (KL-510 included) and contains no test from the two Python modules this plan writes or from PARITY-SET other than KL-510 (PD10); with no pre-existing failure this is exit 0. The summary line, the verbatim `TOTAL` row, and the passed count are recorded; the passed count is at least BASE_FULL_PASSED plus 44 (43 new follow-up tests and 1 note B test) minus the KL-510 adjustment.
- [ ] [P9-T11] Post-change numeric Python coverage from the P9-T10 JSON report, and record FEATURE/evidence/qa-gates/python-coverage-values.TS.md.
      Command: the P0-T16 command, verbatim.
      Acceptance: exit 0 and `LINE <n> BRANCH <n> COMBINED <n>`, recorded as FINAL_PY_LINE, FINAL_PY_BRANCH, FINAL_PY_COMBINED; FINAL_PY_LINE is at least 85 and at least BASE_PY_LINE; FINAL_PY_BRANCH is at least 75 and at least BASE_PY_BRANCH.
- [ ] [P9-T12] Full PoshQC test run with coverage, run in the background, plus the JUnit totals, and record FEATURE/evidence/qa-gates/poshqc-test.TS.md.
      Commands: `sh artifacts/orchestration/wip824-run/poshqc-test.sh`; the JUnit one-liner of Appendix G, item G6.
      Acceptance: the `FAILED` names are a subset of the P0-T20 pre-existing set and include no PESTER-824 case (PD10); with no pre-existing failure the test exit code is 0. TESTS is at least BASE_PS_TESTS plus 28 (11 resolver rows and 17 hook cases); FINAL_PS_TESTS and FINAL_PS_FAILURES are recorded.
- [ ] [P9-T13] Post-change numeric PowerShell coverage, including changed-line coverage of the modified hook, from the P9-T12 report, and record FEATURE/evidence/qa-gates/powershell-coverage-values.TS.md.
      Commands (substitute BASE_SHA): the coverage one-liner of Appendix G, item G5; `git diff --no-color --unified=0 --output=artifacts/orchestration/wip824-hunks/hook-final.diff BASE_SHA -- .claude/hooks/validate-feature-review-coverage.ps1`; `git status --porcelain -- .claude/hooks/validate-feature-review-coverage.ps1`; the changed-line one-liner of Appendix G, item G7.
      Acceptance: G5 exits 0; `REPO_LINE` is numeric (FINAL_PS_LINE) and at least BASE_PS_LINE; the hook `FILE` value (FINAL_HOOK_COV) is at least 85 and at least BASE_HOOK_COV; the helper `FILE` value (FINAL_HELPER_COV) is numeric and at least 85 (the helper is entirely new, so this whole-file value is its new-code coverage). The diff command exits 0; the status line is ` M .claude/hooks/validate-feature-review-coverage.ps1` or nothing when the orchestrator has committed (the diff is anchored to BASE_SHA, so it carries the hook change in both states). G7 exits 0 and prints one line `CHANGED_LINES <n> EXECUTABLE_CHANGED <n> UNCOVERED_CHANGED NONE` with `CHANGED_LINES` above 0 and `EXECUTABLE_CHANGED` above 0; the line is recorded verbatim as FINAL_HOOK_CHANGED_LINES. G7 is the last command, so `EXIT_CODE: 0`. A `MISSING` value, a figure below 85, `EXECUTABLE_CHANGED 0`, or any line number listed after `UNCOVERED_CHANGED` fails the loop and is reported as remediation-required (the fix is a test that executes the listed hook line, never an edit to the measurement).
- [ ] [P9-T14] Jest suite in coverage mode, run in the background, and record FEATURE/evidence/qa-gates/jest-coverage.TS.md.
      Command: `npm --prefix extensions/drm-copilot run test:coverage`.
      Acceptance: the failing set is a subset of the P0-T26 pre-existing set (exit 0 when that set is empty); FINAL_TS_LINES and FINAL_TS_BRANCHES are recorded and each is at least its baseline value.
- [ ] [P9-T15] Run the bats suite on the P0-T28 branch and record FEATURE/evidence/qa-gates/bats.TS.md.
      Command (branch `BATS_LOCAL: available`): `npx --yes bats tests/shell/test_codex_web_setup_codex_copy.bats`.
      Acceptance (local branch): exit 0, `1..15`, 15 `ok` lines, no `not ok`. CI branch: the artifact repeats the P5-T16 `PENDING-CI` record with `EXIT_CODE: 0` for the recording step; this is the only permitted non-execution branch and it keeps AC-6 unchecked.
- [ ] [P9-T16] Re-verify byte identity of the 17 pairs after the loop, and record FEATURE/evidence/qa-gates/mirror-identity-final.TS.md.
      Commands: the 17 diff commands of P8-T6 in the same order; `git status --porcelain -- extensions/drm-copilot/resources`.
      Acceptance: each diff exits 0 with no output.
- [ ] [P9-T17] Record the loop result FEATURE/evidence/qa-gates/qc-loop-complete.TS.md.
      Command: none (record `Command: none - loop summary of P9-T1 through P9-T16` and `EXIT_CODE: 0`).
      Acceptance: the artifact names the iteration number of the clean pass and the artifact path of each of P9-T1 through P9-T16 from that same iteration, each with exit code and pass status.

### Phase 10 — Coverage Comparison and Scope Verification

- [ ] [P10-T1] Write the coverage comparison FEATURE/evidence/qa-gates/coverage-comparison.TS.md (inputs: P0-T16, P9-T11, P0-T21, P9-T13, P0-T26, P9-T14).
      Command: none (record `Command: none - comparison of recorded values` and `EXIT_CODE: 0`).
      Acceptance: the artifact lists, for PowerShell: BASE_PS_LINE, FINAL_PS_LINE, the delta, BASE_HOOK_COV, FINAL_HOOK_COV, the verbatim G7 line FINAL_HOOK_CHANGED_LINES directly after FINAL_HOOK_COV, FINAL_HELPER_COV, and `New/changed-code coverage: .claude/hooks/feature-review-coverage-thresholds.ps1 <FINAL_HELPER_COV> (new file, whole-file value); .claude/hooks/validate-feature-review-coverage.ps1 <FINAL_HOOK_COV> file, changed lines UNCOVERED_CHANGED NONE` with both percentages at least 85 (PowerShell has no branch gate); for Python: BASE_PY_LINE, FINAL_PY_LINE, BASE_PY_BRANCH, FINAL_PY_BRANCH, both deltas, and `New/changed-code coverage: N/A - no production Python line changed`; for TypeScript: the four TS values and `New/changed-code coverage: N/A - no TypeScript file changes`; for Bash: `N/A - .codex/ is outside the kcov include roots (pre-existing, follow-up)`. Every value is numeric or one of the quoted N/A literals. A negative PowerShell or Python delta, a per-file value below 85, or a FINAL_HOOK_CHANGED_LINES line whose `UNCOVERED_CHANGED` value is not `NONE`, makes the artifact verdict `REMEDIATION-REQUIRED` and blocks AC-13.
- [ ] [P10-T2] Verify the complete write set and the hard exclusions against BASE_SHA, and record FEATURE/evidence/qa-gates/scope-check.TS.md.
      Commands (substitute BASE_SHA): `git branch --show-current`; `git diff --name-only BASE_SHA -- . ':!docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824' ':!docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md'`; `git status --porcelain --untracked-files=all -- . ':!docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824' ':!docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md'`; `git diff --name-only BASE_SHA -- docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824`; `git status --porcelain --untracked-files=all -- docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824`; `git diff --name-only BASE_SHA -- docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md`; `git status --porcelain -- docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md`; `git diff --name-only BASE_SHA -- .claude/hooks/enforce-promotion-mcp-only.ps1 .claude/hooks/hook-command-invocation.ps1 .claude/hooks/hook-command-raw-invocation.ps1 .claude/hooks/enforce-epic-worktree-removal-gate.ps1 .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 .codex/hooks extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-raw-invocation.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json scripts/dev-tools tests/scripts/dev-tools .github/workflows tests/scripts/workflows docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824`; `git status --porcelain --untracked-files=all -- .codex/hooks scripts/dev-tools tests/scripts/dev-tools .github/workflows tests/scripts/workflows extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824`.
      Acceptance: the branch is `bug/issue-823-tier-rule-adoption-follow-ups-824`; the union of the paths printed by the second and third commands is exactly the 43 non-FEATURE paths of the P0-T7 write set (36 tracked modifications and 7 new files: the helper, its mirror, the two Pester files, the follow-ups pytest module, the bats suite, and the fixture); the union of the fourth and fifth commands contains only FEATURE paths named `issue.md`, `spec.md`, or `plan.2026-10-08T22-16.md`, paths under FEATURE `research/`, and paths under FEATURE `evidence/` (the feature folder may be committed or untracked, so either listing may be empty); the union of the sixth and seventh commands is empty (`PROMOTION_DELETE: committed` in BASE_SHA) or consists only of `docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md` from the diff and/or the status line ` D docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md` (the promotion deletion, pending or committed after BASE_SHA); the last two commands print nothing. Any other path stops the plan for a report.
- [ ] [P10-T3] Verify the AC-14 `vswhere` condition on the final tree, and record FEATURE/evidence/qa-gates/vswhere-check.TS.md.
      Commands (substitute BASE_SHA): `git diff --unified=0 --output=artifacts/orchestration/wip824-hunks/codex-setup-final.diff BASE_SHA -- .codex/codex-web-setup.sh`; `git status --porcelain -- .codex/codex-web-setup.sh`; `grep -c -F "vswhere_check" .codex/codex-web-setup.sh extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh`; `grep -c -e "^[-+].*vswhere" artifacts/orchestration/wip824-hunks/codex-setup-final.diff`.
      Acceptance: the diff exits 0; the `vswhere_check` grep prints `:0` for both files; the last grep prints 0 (`EXIT_CODE: 1`, `ExpectedExitCode: 1`).

### Phase 11 — Acceptance-Criteria Check-Off

Each task checks one AC box in `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md` (change `- [ ] AC-n:` to `- [x] AC-n:`, nothing else) only when every named verifying task is checked and its artifact passes, and appends one line `AC-n checked: <verifying artifact paths>` to FEATURE/evidence/other/ac-checkoff.TS.md (one artifact for the phase, created by P11-T1). Acceptance for each task (n is the task's AC number): `grep -c -F "[x] AC-n:" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md` prints 1 after the edit (the trailing colon keeps AC-1 from matching AC-10 through AC-15), and the artifact line names every verifying artifact. An AC whose verifying artifact fails stays unchecked and the gap is recorded in the same artifact.

- [ ] [P11-T1] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-1. Verifying tasks: P3-T1, P3-T2, P3-T3, P3-T5, P3-T6, P3-T4, P8-T3, P8-T6.
- [ ] [P11-T2] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-2. Verifying tasks: P1-T4, P1-T5, P2-T2, P2-T3, P8-T3 (F824-1, F824-2, F824-3 and resolver rows 8 and 9 passed).
- [ ] [P11-T3] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-3. Verifying tasks: P3-T3 ("80 percent" 0, fallback 1), P3-T6, P8-T1 (`test_precedence_copy_states_per_metric_fallback` for both hook copies).
- [ ] [P11-T4] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-4. Verifying tasks: P4-T1 through P4-T6, P8-T1 (`test_listed_copy_names_no_consuming_product`, 6 cases), P3-T7 and P10-T2 (manifest membership unchanged apart from the helper entry).
- [ ] [P11-T5] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-5. Verifying tasks: P1-T1, P2-T1, P8-T1 (`test_pushed_rule_and_skill_files_name_no_consuming_product`, `test_name_exceptions_still_name_a_consuming_product`, `test_pushed_rule_and_skill_scan_covers_the_listed_copies`).
- [ ] [P11-T6] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-6. Verifying tasks: P5-T1 through P5-T15, P8-T1 (`test_surface_does_not_hard_code_solution_file`, 14 cases), P5-T16 and P9-T15 on the local branch. When P5-T16 recorded `PENDING-CI`, AC-6 stays unchecked and the artifact line reads `AC-6 pending CI: tests/shell/test_codex_web_setup_codex_copy.bats`.
- [ ] [P11-T7] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-7. Verifying tasks: P1-T1, P2-T1, P8-T1 (`test_pushed_roots_carry_no_hard_coded_solution_file` and the 14 surface cases, including both `.github` copies).
- [ ] [P11-T8] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-8. Verifying tasks: P8-T4, P8-T5, P8-T6, P9-T14.
- [ ] [P11-T9] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-9. Verifying tasks: P6-T1, P6-T7, P8-T1 (`test_review_workflow_step_eight_uses_governing_thresholds`, 2 cases).
- [ ] [P11-T10] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-10. Verifying tasks: P3-T3, P3-T6, P6-T1 through P6-T12, P8-T1 (`test_precedence_copy_states_per_metric_fallback`, 14 cases).
- [ ] [P11-T11] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-11. Verifying tasks: P1-T2, P2-T5, P8-T2 (`test_retired_threshold_scan_reads_coverage_context_only`).
- [ ] [P11-T12] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-12. Verifying task: P7-T1.
- [ ] [P11-T13] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-13. Verifying tasks: P9-T1 through P9-T17 in one uninterrupted pass, P10-T1 (verdict not `REMEDIATION-REQUIRED`). The artifact line lists any pre-existing failure that remained (PD10).
- [ ] [P11-T14] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-14. Verifying tasks: P10-T2, P10-T3, P5-T9.
- [ ] [P11-T15] Record AC-15 as pending pull-request authoring in FEATURE/evidence/other/ac-checkoff.TS.md and leave `- [ ] AC-15:` unchanged in `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md` (PD12). Verifying artifact for the later check-off: FEATURE/evidence/other/pr-body-callouts.TS.md (P7-T2).
      Acceptance: `grep -c -F "[ ] AC-15:" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md` prints 1, and the artifact line reads `AC-15 pending PR: Refs #824 and callouts in evidence/other/pr-body-callouts.TS.md`.
- [ ] [P11-T16] Write the AC status summary FEATURE/evidence/other/ac-status-summary.TS.md in the acceptance-criteria-tracking format (Source, Total AC items 15, Checked off, Remaining, Items remaining).
      Commands: `grep -c "^- \[x\] AC-" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`; `grep -c "^- \[ \] AC-" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`.
      Acceptance: the two counts sum to 15; the summary's Checked off and Remaining values equal them; Items remaining lists AC-15 and, when P5-T16 recorded `PENDING-CI`, AC-6.

## Appendix A — Hunk Application Procedure (HAP) and Patch Table

For a path P and its patch file N (under `artifacts/orchestration/wip824-hunks/`), the five HAP commands are, in order (substitute recorded WIP_BASE and WIP_SHA):

1. `git diff --output=artifacts/orchestration/wip824-hunks/N WIP_BASE WIP_SHA -- P`
2. `git apply --check artifacts/orchestration/wip824-hunks/N`
3. `git apply artifacts/orchestration/wip824-hunks/N`
4. `git apply --reverse --check artifacts/orchestration/wip824-hunks/N`
5. `git status --porcelain -- P`

HAP acceptance: command 1 exits 0; commands 2, 3, and 4 exit 0 (an empty patch cannot pass command 2, because `git apply --check` rejects input with no valid patch) (command 4 proves the complete WIP_REF post-image of P is present); command 5 prints ` M P` for a modified file or `?? P` for a new file (or nothing when the orchestrator has already committed P, in which case `git diff --stat BASE_SHA -- P` is recorded instead and must list P).

Fallback (only for a modified-file patch whose command 2 exits non-zero, typically a MOVED path from P0-T4): record `HAP-FALLBACK: N` and the `git apply --check` error text; apply each hunk of N with the Edit tool, where old_string is the hunk's context (` `) and removed (`-`) lines with the one-character prefix stripped and new_string is the same hunk's context and added (`+`) lines with the prefix stripped; skip commands 3 and 4; the task's own greps then decide. If the removed lines of any hunk are not present verbatim in P (main changed the same lines), stop and report the hunk for an orchestrator decision. The fallback is never used for a new-file patch (p01, p18, p20, p21, p22, p23): a failing check there means P already exists, and the plan stops.

| Patch file N | Path P | WIP_REF verdict (research section 8) |
| --- | --- | --- |
| `p01-helper.patch` | `.claude/hooks/feature-review-coverage-thresholds.ps1` | new; adapted by Appendix D |
| `p02-hook.patch` | `.claude/hooks/validate-feature-review-coverage.ps1` | verbatim; #847 overlap |
| `p03-rule-architecture.patch` | `.claude/rules/architecture-boundaries.md` | verbatim |
| `p04-rule-general-unit-test.patch` | `.claude/rules/general-unit-test.md` | verbatim |
| `p05-rule-quality-tiers.patch` | `.claude/rules/quality-tiers.md` | verbatim |
| `p06-agent-feature-review.patch` | `.claude/agents/feature-review.md` | verbatim |
| `p07-skill-feature-review-workflow.patch` | `.claude/skills/feature-review-workflow/SKILL.md` | verbatim; #841 overlap |
| `p08-skill-quota-throttling.patch` | `.claude/skills/quota-throttling/SKILL.md` | verbatim |
| `p09-agents-architecture.patch` | `.agents/skills/architecture-boundaries/SKILL.md` | verbatim |
| `p10-agents-csharp.patch` | `.agents/skills/csharp/SKILL.md` | verbatim |
| `p11-agents-csharp-qa-gate.patch` | `.agents/skills/csharp-qa-gate/SKILL.md` | verbatim |
| `p12-agents-general-unit-test.patch` | `.agents/skills/general-unit-test/SKILL.md` | verbatim |
| `p13-agents-quality-tiers.patch` | `.agents/skills/quality-tiers/SKILL.md` | verbatim |
| `p14-github-csharp-code-change.patch` | `.github/instructions/csharp-code-change.instructions.md` | verbatim |
| `p15-github-csharp-unit-test.patch` | `.github/instructions/csharp-unit-test.instructions.md` | verbatim |
| `p16-github-csharp-agent.patch` | `.github/agents/csharp-typed-engineer.agent.md` | verbatim |
| `p17-codex-setup.patch` | `.codex/codex-web-setup.sh` | adapted by Appendix E |
| `p18-test-follow-ups.patch` | `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` | new; adapted by Appendix B |
| `p19-test-tier-gate.patch` | `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` | verbatim |
| `p20-test-resolver.patch` | `tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1` | new; adapted by Appendix C |
| `p21-test-hook-824.patch` | `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1` | new; verbatim |
| `p22-test-bats.patch` | `tests/shell/test_codex_web_setup_codex_copy.bats` | new; verbatim |
| `p23-fixture.patch` | `tests/fixtures/codex_web_setup/populated-packages/packages/placeholder.txt` | new; verbatim |

Not applied from WIP_REF: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (P3-T7 adds only the helper entry by Edit), every bundled mirror (regenerated by `cp`), the two variant files (edited in place), the `docs/features/potential/` status marks (redone in `issue.md` by P7-T1), and every out-of-scope WIP_REF path listed in research section 8.

## Appendix B — Adaptations to `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`

Each item is one Edit replacement; old text is copied from the file as P1-T1 applied it.

F1 old:
```python
FALLBACK_TOKEN = "falls back independently"  # noqa: S105 - test fixture data
```
F1 new:
```python
FALLBACK_PHRASE = "falls back independently"
```

F2 old:
```python
    assert FALLBACK_TOKEN in normalized, f"{relative_path} lacks {FALLBACK_TOKEN}"
```
F2 new:
```python
    assert FALLBACK_PHRASE in normalized, f"{relative_path} lacks {FALLBACK_PHRASE}"
```

F3 old:
```python
EXPECTED_LISTED_COPY_COUNT = 36
```
F3 new:
```python
EXPECTED_LISTED_COPY_COUNT = 36

PUSHED_RULE_AND_SKILL_GLOBS: tuple[tuple[str, str], ...] = (
    (".claude/rules", "*.md"),
    (".claude/skills", "**/SKILL.md"),
    (".agents/skills", "**/SKILL.md"),
    (CLAUDE_BUNDLE + ".claude/rules", "*.md"),
    (CLAUDE_BUNDLE + ".claude/skills", "**/SKILL.md"),
    (CLAUDE_BUNDLE + ".claude-variants", "*/rules/*.md"),
    (CLAUDE_BUNDLE + ".claude-variants", "*/skills/**/SKILL.md"),
    (CODEX_BUNDLE + ".agents/skills", "**/SKILL.md"),
    (CODEX_BUNDLE + ".agents-variants", "*/skills/**/SKILL.md"),
)
# Pushed files outside the FU-823-2 listed set that still name a product. They
# are out of scope for issue #824 and recorded as a follow-up; the staleness
# test below fails once an entry no longer names one.
PRE_EXISTING_NAME_EXCEPTIONS: frozenset[str] = frozenset(
    {
        ".claude/rules/typescript.md",
        ".claude/rules/csharp.md",
        CLAUDE_BUNDLE + ".claude/rules/typescript.md",
        CLAUDE_BUNDLE + ".claude/rules/csharp.md",
    }
)
```

F4 old:
```python
    return sorted(found)


def step_eight(text: str) -> str:
```
F4 new:
```python
    return sorted(found)


def pushed_rule_and_skill_files() -> list[str]:
    """Return the sorted relative paths of every pushed rule and skill file."""

    found: set[str] = set()
    for root, pattern in PUSHED_RULE_AND_SKILL_GLOBS:
        for candidate in (REPO_ROOT / root).glob(pattern):
            if candidate.is_file():
                found.add(candidate.relative_to(REPO_ROOT).as_posix())
    return sorted(found)


def step_eight(text: str) -> str:
```

F5 old (the last line of the file):
```python
    assert step == "8. **Eight**\n   - eight body"
```
F5 new:
```python
    assert step == "8. **Eight**\n   - eight body"


def test_pushed_rule_and_skill_scan_covers_the_listed_copies() -> None:
    """The pushed-file scan reaches every FU-823-2 listed copy."""

    # Arrange
    listed = set(PRODUCT_NAME_COPIES)

    # Act
    scanned = set(pushed_rule_and_skill_files())

    # Assert
    missed = sorted(listed - scanned)
    assert missed == [], f"scan misses listed copies: {missed}"


def test_pushed_rule_and_skill_files_name_no_consuming_product() -> None:
    """FU-823-2: no pushed rule or skill file names a consuming product."""

    # Arrange
    scanned = [
        path
        for path in pushed_rule_and_skill_files()
        if path not in PRE_EXISTING_NAME_EXCEPTIONS
    ]

    # Act
    offenders = [
        path
        for path in scanned
        if any(name in read_copy(path) for name in CONSUMING_NAMES)
    ]

    # Assert
    assert offenders == [], f"pushed files naming a product: {offenders}"


def test_name_exceptions_still_name_a_consuming_product() -> None:
    """Each documented exception still names a product, so the set is not stale."""

    # Arrange
    exceptions = sorted(PRE_EXISTING_NAME_EXCEPTIONS)

    # Act
    stale = [
        path
        for path in exceptions
        if not (REPO_ROOT / path).is_file()
        or not any(name in read_copy(path) for name in CONSUMING_NAMES)
    ]

    # Assert
    assert stale == [], f"remove stale entries from the exception set: {stale}"
```

F6 old (module docstring):
```python
feature-review workflow's step 8 defers to the governing thresholds, and every
threshold-precedence copy states the per-metric fallback.
```
F6 new:
```python
feature-review workflow's step 8 defers to the governing thresholds, and every
threshold-precedence copy states the per-metric fallback. A scan of every pushed
rule and skill file guards against the product names reappearing; the files in
``PRE_EXISTING_NAME_EXCEPTIONS`` are out of scope for issue #824 and are
checked for staleness.
```

## Appendix C — Adaptations to `tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1`

C1 old (comment-based help):
```powershell
    return. The rows cover an absent text, a text without figures, both figures, a
    line-only figure, a branch-only figure, a decimal figure, and an out-of-range figure.
```
C1 new:
```powershell
    return. The rows cover an absent text, a text without figures, both figures, a
    line-only figure, a branch-only figure, a decimal figure, an out-of-range figure,
    a prose figure without a comparator (not read), the combined line-and-branch
    limitation (neither metric read), a minimum phrase, and two no-less-than
    statements on one line.
```

C2 old (row 7):
```powershell
        @{ Id = 7; Label = 'a figure above 100'; Text = 'Line coverage: 150%'; Line = 85; Branch = 75; LineSource = 'default'; BranchSource = 'default' }
```
C2 new (rows 7 through 11):
```powershell
        @{ Id = 7; Label = 'a figure above 100'; Text = 'Line coverage >= 150%'; Line = 85; Branch = 75; LineSource = 'default'; BranchSource = 'default' }
        @{ Id = 8; Label = 'a prose figure without a comparator'; Text = 'Line coverage was 62% last release.'; Line = 85; Branch = 75; LineSource = 'default'; BranchSource = 'default' }
        @{ Id = 9; Label = 'the combined line-and-branch limitation'; Text = 'Line and branch coverage >= 70%.'; Line = 85; Branch = 75; LineSource = 'default'; BranchSource = 'default' }
        @{ Id = 10; Label = 'a minimum phrase'; Text = 'Branch coverage minimum: 60%'; Line = 85; Branch = 60; LineSource = 'default'; BranchSource = 'claude-md' }
        @{ Id = 11; Label = 'two no-less-than statements on one line'; Text = 'Line coverage no less than 72% and branch coverage no less than 61%.'; Line = 72; Branch = 61; LineSource = 'claude-md'; BranchSource = 'claude-md' }
```

Row 7 now carries a comparator so that it still exercises the 0-100 range check rather than the comparator rule.

## Appendix D — Adaptations to `.claude/hooks/feature-review-coverage-thresholds.ps1` and the Claude Core Pack Manifest

D1 old (function help):
```powershell
        For each metric M in 'line' and 'branch', the text is searched with
        '(?im)\bM\s+coverage\b[^\r\n%]*?(?<![\d.])(?<pct>\d{1,3}(?:\.\d+)?)\s*%'. The first
        match whose value parses (invariant culture) to a number from 0 to 100 sets that
        metric and its source to 'claude-md'. Otherwise the metric keeps its default (line
        85, branch 75) and its source is 'default'.
```
D1 new:
```powershell
        For each metric M in 'line' and 'branch', a figure is read only when a comparator
        or floor phrase links it to the metric: the text must contain 'M coverage', then
        any text on the same line without a percent sign, then one of '>=', the U+2265
        sign, 'at least', 'minimum', 'minimum of', or 'no less than', an optional colon,
        and the figure followed by a percent sign. Prose such as 'line coverage was 62%
        last release' is not read. The first match whose value parses (invariant culture)
        to a number from 0 to 100 sets that metric and its source to 'claude-md'.
        Otherwise the metric keeps its default (line 85, branch 75) and its source is
        'default'.

        Known limitation: a combined statement such as 'line and branch coverage >= 70%'
        matches neither metric, because the metric name must be followed directly by
        'coverage' and must not be joined to the other metric name by 'and', 'or', '&',
        or '/'. Both metrics then keep their defaults, which is the stricter direction.
```

D2 old:
```powershell
            $pattern = '(?im)\b' + $metric + '\s+coverage\b[^\r\n%]*?(?<![\d.])(?<pct>\d{1,3}(?:\.\d+)?)\s*%'
```
D2 new:
```powershell
            $pattern = '(?im)(?<!\b(?:line|branch)\s*(?:and|or|&|/)\s*)\b' + $metric + '\s+coverage\b[^\r\n%]*?(?:>=|' + [char]0x2265 + '|\bat\s+least\b|\bminimum(?:\s+of)?\b|\bno\s+less\s+than\b)\s*:?\s*(?<![\d.])(?<pct>\d{1,3}(?:\.\d+)?)\s*%'
```

The D2 new text is ASCII only: the U+2265 comparator alternative is the expression `[char]0x2265` between the closing quote of one pattern fragment and the opening quote of the next, and the executor must not substitute the literal sign or an escape sequence. PowerShell evaluates `[char]0x2265` to U+2265 and string concatenation places it in the pattern, where the .NET regex engine matches it literally. Planning-time trace of the Appendix C rows against D2: row 3 reads 70 and 60 (">=" after "must remain"); row 4 reads 70 (": >="); row 5 reads 65; row 6 reads 82.5 ("at least"); row 7 matches 150, which the 0-100 check rejects (the look-behind `(?<![\d.])` prevents a partial "50" match); row 8 finds no comparator before the first percent sign and reads nothing; row 9: "Line" is followed by "and", not "coverage", and "branch coverage" is preceded by "Line and ", which the negative look-behind rejects, so neither metric is read; row 10 reads 60 ("minimum" then ":"); row 11 reads 72 and, because "branch" is preceded by "72% and " rather than a metric name, 61. The hook-suite texts (F824-1, F824-3: "must remain >= 70%") read as stated.

M1 (pack manifest; Edit tool on `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`) old:
```json
    ".claude/hooks/enforce-promotion-mcp-only.ps1",
```
M1 new:
```json
    ".claude/hooks/enforce-promotion-mcp-only.ps1",
    ".claude/hooks/feature-review-coverage-thresholds.ps1",
```

## Appendix E — Adaptation to `.codex/codex-web-setup.sh` (drop the `vswhere`/`vstest` collapse)

E1 old (three lines as P5-T8 applied them):
```bash
  local vswhere_check="\$vswherePath = Join-Path \${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'; if (-not (Test-Path \$vswherePath)) { throw 'vswhere.exe was not found. Install Visual Studio 2022 (or Build Tools) with Test Platform components.' }"
  local vstest_check="\$vstestPath = & \$vswherePath -latest -products * -find 'Common7\IDE\Extensions\TestPlatform\vstest.console.exe' | Select-Object -First 1; if (-not \$vstestPath) { throw 'vstest.console.exe not found via vswhere. Install Visual Studio Test Platform components.' }"
  pwsh -NoProfile -ExecutionPolicy Bypass -Command "& { ${vswhere_check}; ${vstest_check} }" >/dev/null || fail "Visual Studio test tooling required by the MSTest tasks is unavailable."
```
E1 new (the BASE_SHA block, lines 287-297 at RESEARCH_BASE, verbatim):
```bash
  pwsh -NoProfile -ExecutionPolicy Bypass -Command "& {
    \$vswherePath = Join-Path \${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    if (-not (Test-Path \$vswherePath)) {
      throw 'vswhere.exe was not found. Install Visual Studio 2022 (or Build Tools) with Test Platform components.'
    }

    \$vstestPath = & \$vswherePath -latest -products * -find 'Common7\IDE\Extensions\TestPlatform\vstest.console.exe' | Select-Object -First 1
    if (-not \$vstestPath) {
      throw 'vstest.console.exe not found via vswhere. Install Visual Studio Test Platform components.'
    }
  }" >/dev/null || fail "Visual Studio test tooling required by the MSTest tasks is unavailable."
```

After E1, `verify_windows_visual_studio_task_capability` differs from BASE_SHA only by the added solution guard line and the `-SolutionPath "${SOLUTION_FILE}"` operand; P5-T9 and P10-T3 verify that no diff line mentions `vswhere`.

## Appendix F — Status Marks in `issue.md`

Each insertion places the quoted status line, followed by one blank line, immediately after the named heading line and its following blank line (that is, directly before the first paragraph of the entry). No other line changes; the `- Work Mode: full-bug` marker is untouched.

- S1, after `## FU-823-1: Feature-review coverage hook ignores consumer thresholds (spec F1)`: `Status: Resolved by #824.`
- S2, after `## FU-823-2: Remaining TaskMaster and No-COM mentions in pushed files (spec F2)`: `Status: Resolved by #824.`
- S3, after `## FU-823-3: TaskMaster.sln C# toolchain commands in pushed files (spec F3)`: `Status: Resolved by #824.`
- S4, after `## FU-823-4: Extension republish to deliver the gated rule text (spec F4)`: `Status: Open (out of scope for #824; no release automation is run).`
- S5, after `## FU-823-5: Feature-review workflow remediation trigger still states 80/90 thresholds`: `Status: Resolved by #824.`

## Appendix G — RUN Scripts and One-Line Readers

G1 `artifacts/orchestration/wip824-run/pester-files.sh`:
```sh
#!/bin/sh
# Runs Pester 5 over the test files given as arguments and prints one summary line.
# Exits 1 when any test, block, or container failed, otherwise 0.
list=""
for test_file in "$@"; do
	list="${list}${list:+,}'${test_file}'"
done
pwsh -NoProfile -Command "\$c = New-PesterConfiguration; \$c.Run.Path = @(${list}); \$c.Run.PassThru = \$true; \$c.Output.Verbosity = 'Detailed'; \$r = Invoke-Pester -Configuration \$c; Write-Output ('Passed=' + \$r.PassedCount + ' Failed=' + \$r.FailedCount + ' FailedBlocks=' + \$r.FailedBlocksCount + ' FailedContainers=' + \$r.FailedContainersCount); if (\$r.FailedCount -gt 0 -or \$r.FailedBlocksCount -gt 0 -or \$r.FailedContainersCount -gt 0) { exit 1 }; exit 0"
```

G2 `artifacts/orchestration/wip824-run/poshqc-format.sh`:
```sh
#!/bin/sh
pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path -ScanFolders @('.claude/hooks','tests/scripts/claude-hooks')"
```

G3 `artifacts/orchestration/wip824-run/poshqc-analyze.sh`:
```sh
#!/bin/sh
pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path -ScanFolders @('.claude/hooks','tests/scripts/claude-hooks')"
```

G4 `artifacts/orchestration/wip824-run/poshqc-test.sh`:
```sh
#!/bin/sh
pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path"
```

G5 PowerShell coverage reader (one line; sums source-file LINE counters and reports the two target files by repository-relative tail, so no host path is printed):
```sh
poetry run python -c "import xml.etree.ElementTree as E; r=E.parse('artifacts/pester/powershell-coverage.xml').getroot(); rows=[(('/'+p.get('name','')+'/'+s.get('name','')).replace(chr(92),'/'),int(k.get('missed')),int(k.get('covered'))) for p in r.iter('package') for s in p.findall('sourcefile') for k in s.findall('counter') if k.get('type')=='LINE']; m=sum(x[1] for x in rows); c=sum(x[2] for x in rows); print('REPO_LINE', round(100*c/(m+c),2), 'SOURCEFILES', len(rows)); [print('FILE', t, next((round(100*x[2]/(x[1]+x[2]),2) for x in rows if x[0].endswith('/'+t) and x[1]+x[2]>0), 'MISSING')) for t in ('.claude/hooks/validate-feature-review-coverage.ps1','.claude/hooks/feature-review-coverage-thresholds.ps1')]"
```

G6 Pester JUnit reader (one line; Pester writes the test file's absolute host path into `classname`, so only its final path segment, the test file name, is printed):
```sh
poetry run python -c "import xml.etree.ElementTree as E; r=E.parse('artifacts/pester/pester-junit.xml').getroot(); print('ROOT', r.tag, 'TESTS', r.get('tests'), 'FAILURES', r.get('failures'), 'ERRORS', r.get('errors'), 'DISABLED', r.get('disabled')); [print('FAILED', t.get('classname','').replace(chr(92),'/').rpartition('/')[2]+' :: '+t.get('name','')) for t in r.iter('testcase') if t.find('failure') is not None or t.find('error') is not None]"
```

G7 Changed-line coverage reader for `.claude/hooks/validate-feature-review-coverage.ps1` (one line; reads the new-side line numbers of every hunk in the `--unified=0` diff that P9-T13 writes to `artifacts/orchestration/wip824-hunks/hook-final.diff`, then the per-line `ci` (covered instructions) values of that source file in `artifacts/pester/powershell-coverage.xml`):
```sh
poetry run python -c "import re, xml.etree.ElementTree as E; d=open('artifacts/orchestration/wip824-hunks/hook-final.diff',encoding='utf-8').read(); ch={n for a,b in re.findall(r'^@@ -\S+ \+(\d+)(?:,(\d+))? @@',d,re.M) for n in range(int(a),int(a)+(int(b) if b else 1))}; r=E.parse('artifacts/pester/powershell-coverage.xml').getroot(); ln=[l for p in r.iter('package') for s in p.findall('sourcefile') if ('/'+p.get('name','')+'/'+s.get('name','')).replace(chr(92),'/').endswith('/.claude/hooks/validate-feature-review-coverage.ps1') for l in s.findall('line')]; ex=[int(l.get('nr')) for l in ln if int(l.get('nr')) in ch]; un=[int(l.get('nr')) for l in ln if int(l.get('nr')) in ch and int(l.get('ci','0'))==0]; print('CHANGED_LINES', len(ch), 'EXECUTABLE_CHANGED', len(ex), 'UNCOVERED_CHANGED', un if un else 'NONE')"
```

G7 derivation notes: (1) Hunk headers have the form `@@ -<old> +<start>[,<count>] @@`. An omitted count means one line, so `int(b) if b else 1` yields 1; a count of `0` marks a deletion-only hunk, `b` is the non-empty string `'0'`, `int(b)` is 0, and `range(start, start)` contributes no new-side line, which is correct because a deletion leaves no line to cover. (2) The source file is selected by the same composed-path rule as G5 (`'/' + package + '/' + sourcefile`, backslashes normalized), not by the package name alone: PoshQC's `Convert-PoshQCCoverageToRelative` writes relative names only to a separate `.koverage.xml` copy (`scripts/powershell/PoshQC/PoshQC.Testing.psm1` line 287), so `powershell-coverage.xml` keeps Pester's own package names, and the leading `'/'` makes the suffix match hold whether that name is absolute or relative (the reviewer's draft tested `package.endswith('/.claude/hooks')` without the leading slash, which fails for a relative name `.claude/hooks`). (3) A missing or renamed source file yields `EXECUTABLE_CHANGED 0`, which fails the P9-T13 acceptance rather than passing vacuously. (4) The helper `.claude/hooks/feature-review-coverage-thresholds.ps1` is entirely new, so every one of its lines is a changed line and its whole-file value from G5 (FINAL_HELPER_COV, at least 85) is its new-code coverage measure; G7 is not run for it.

## Appendix H — PR-Body Callout Notes (content of FEATURE/evidence/other/pr-body-callouts.TS.md)

The artifact carries `Timestamp:` and these sections, in plain wording, and must not contain a GitHub closing keyword followed by `#824`:

1. Issue reference: the PR body references the issue with the exact line `Refs #824`. Issue #824 stays open because its main bug, Addendum 1, and FU-823-4 are delivered separately.
2. Canonical policy edits (each called out): `.github/instructions/csharp-code-change.instructions.md` and `.github/instructions/csharp-unit-test.instructions.md` (FU-823-3; maintainer authorization in issue #824 Addendum 2, for this item only; `TaskMaster.sln` replaced by the `<solution>.sln` placeholder); `.claude/rules/architecture-boundaries.md` (FU-823-2; names neutralized, substance unchanged); `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md` (review note A; the per-metric fallback sentence is required on every surface that carries the precedence wording; the canonical `.github/instructions/general-unit-test.instructions.md` does not carry that wording and is unchanged).
3. FU-823-4 (extension rebuild, publish, and reinstall) remains open and out of scope; consumers receive these changes only after it.
4. Out-of-scope follow-ups (spec Rollout & Follow-up): `.codex/hooks/validate-feature-review-coverage.ps1` and its mirror keep a separate 80 percent floor; 80/90 figures remain in `.agents/skills/feature-review-workflow/SKILL.md`, `.github/skills/feature-review-workflow/SKILL.md`, `.codex/agents/feature-review.toml`, and their mirrors; `No-COM` remains in `.claude/rules/typescript.md` and `.claude/rules/csharp.md` and their mirrors (held in the AC-5 exception set), and the `typescript.md` cross-reference no longer matches the renamed heading; `.codex/` is outside shell-qc discovery and kcov include roots; optionally, a new potential entry for FU-823-4.
5. Verification status: AC-15 is pending this PR; AC-6 is pending CI when P5-T16 recorded `PENDING-CI`.

## Planner Self-Review Record

SELF-REVIEW: RE-DERIVED THIS PASS

Revision round 1 (executor preflight defects 1-6 and the formatter-scope advisory). Citations touched by this revision and their sibling regions, re-derived in this pass against the current worktree:
- `artifacts/orchestration/wip824-addendum2.patch` line 139 (WIP helper help text carrying the unconstrained pattern, replaced by D1) and line 163 (the WIP `$pattern` assignment, D2 old text); a non-ASCII search of the patch finds no character inside the helper hunk (lines 110-183) or the Pester hunks (lines 686-1015), and no `u2265` or `[char]0x2265` token anywhere, so after D1 and D2 the `[char]0x2265` grep matches only the D2 line and the helper is ASCII only.
- Plan text (this file): a non-ASCII search after the edits finds only the en dash (Execution constraints) and the em dashes in headings; a search for a backslash-u-four-hex sequence finds none. Observed mechanism for defect 1: an Edit whose new text contained the backslash-u escape wrote the literal U+2265 sign, and a doubled backslash wrote two backslashes; D2 therefore uses `[char]0x2265`.
- `artifacts/orchestration/wip824-addendum2.patch` line 262: the single added `-LineFloor $thresholds.Line` call; `.claude/hooks/validate-feature-review-coverage.ps1` has no `LineFloor` text on the current tree (only line 323 `$BranchFloor = 75.0`), so the single-quoted P3-T3 grep prints 1 after HAP.
- Double-quoted command spans containing `$` (sweep): P3-T3 converted to single quotes; P0-T1 `'^## Acceptance Criteria$'` and P1-T2 `'^import re$'` converted to single quotes; the remaining matches (`main "$@"`, the `BASH_SOURCE` guard line, `-SolutionPath "${SOLUTION_FILE}"`) are acceptance or appendix text, not commands; the RUN scripts' `\$` escapes and `${list}` expansion are intentional.
- `docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md`: absent from the working tree (Glob), consistent with the pending promotion deletion; FEATURE contains `issue.md`, `spec.md`, `plan.2026-10-08T22-16.md`, and `research/2026-10-09T02-25-issue-823-tier-rule-adoption-follow-ups-research.md` (Glob), matching the widened P10-T2 FEATURE allowance.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` lines 15 (`artifacts/pester/pester-junit.xml`) and 22 (`artifacts/pester/powershell-coverage.xml`): the G6 and G7 inputs.
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1` line 287 (`Convert-PoshQCCoverageToRelative` writes a separate `.koverage.xml` copy) and `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1` lines 297-313 (Pester package names are absolute before conversion and relative such as `scripts/dev-tools` after): basis for the G7 composed-path match with a leading `'/'`, and for the G6 classname tail.
- `.claude/agents/atomic-executor.md` lines 11-20: the frontmatter Bash allowlist named in the new Execution-constraints bullet.
- `.claude/hooks/validate-feature-review-coverage.ps1` lines 29 ("below 80 percent"), 313 (`-lt 85.0`), 323 (`$BranchFloor = 75.0`): sibling region of the P3-T3 grep and of the G7 target file.
- `.codex/codex-web-setup.sh` lines 10, 265, 285, 340-342 (`TaskMaster.sln`) and 384 (`main "$@"`): sibling region of the P2-T4 and P5-T8 quoting sweep; unchanged.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lines 54, 55, 61; `.claude/skills/feature-review-workflow/SKILL.md` lines 143, 149, 158; `spec.md` AC lines 212 and 226: re-read to confirm the CITATION records below remain current.
- G7 hunk arithmetic: for `@@ -12,3 +11,0 @@` the capture is `('11','0')` and `range(11, 11)` is empty; for `@@ -5 +5 @@` the capture is `('5','')` and the range is `{5}`. `--no-color` is added to the P9-T13 diff so a `color.ui=always` configuration cannot prefix the `@@` lines with escape codes.

Initial-authoring citations not touched by this revision (carried as recorded in the round-0 pass; the subset also listed above was re-read this pass):
- `.claude/hooks/validate-feature-review-coverage.ps1`: 459 lines; docstring lines 29-30 ("below 80 percent"); `Test-LanguageCoverageRow` parameters lines 258-265; hard-coded `85.0` line 313 and reason line 318; `$BranchFloor = 75.0` line 323 and reason line 327; per-language loop lines 430-439; dot-source guard lines 449-451; `Get-ArtifactFileContent` lines 41-63.
- `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`: 4 `It` blocks (lines 14, 25, 58, 100); mocks return `Exists = $false` by default (lines 40, 81-83), so the added `CLAUDE.md` read does not change them.
- `.codex/codex-web-setup.sh`: 384 lines; `TaskMaster.sln` at lines 10, 265, 285, 340, 341, 342; `vswhere` block lines 287-297; unconditional `main "$@"` line 384.
- `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`: last content line 463; `RETIRED_REVIEW_THRESHOLDS` line 136; whole-text scan line 393; 17 `def test_` functions (lines 195-443).
- `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`: `PRE_EXISTING_UNRELATED_EXCEPTIONS` lines 52-58; staleness test lines 162-177.
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`: variant files lines 276-279; required and forbidden substrings lines 280-293.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: `enforce-promotion-mcp-only.ps1` line 54, `hook-command-invocation.ps1` line 55, `validate-feature-review-coverage.ps1` line 61.
- `.claude/hooks/enforce-powershell-batch-budget.ps1`: test-file exclusion line 299, cap check lines 309-316, large-route exemption lines 393-399; `.claude/hooks/enforce-python-batch-budget.ps1` lines 25-27 (test files never counted).
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`: JUnit output line 15, coverage output line 22, `CoveragePercentTarget = 0` line 26; `config/poshqc-coverage.json` roots include `.claude/hooks`; `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` format log lines 62-64 and analyze success line 185.
- `pyproject.toml`: `addopts` line 116 (LCOV reporter only), coverage `source` line 120, `omit` lines 122-124.
- `.gitattributes` line 1 (`* text=auto eol=lf`); `.gitignore` line 6 (`/artifacts`) and line 70 (`.claude/state/`).
- `extensions/drm-copilot/package.json` scripts lines 207-213; `extensions/drm-copilot/run-jest.cjs` forwards positional arguments (lines 21-28).
- `.claude/skills/feature-review-workflow/SKILL.md`: step 5 precedence line 111, step 8 heading line 143, retired trigger line 149, step 9 line 158.
- `.claude/rules/quality-tiers.md` lines 31 and 55; `.claude/rules/general-unit-test.md` line 23; `.claude/agents/feature-review.md` line 119; `.agents/skills/quality-tiers/SKILL.md` lines 34 and 58; `.agents/skills/general-unit-test/SKILL.md` line 26.
- `TaskMaster`/`No-COM` occurrences in `.claude/`, `.agents/`, `.github/`, `.codex/`, and `extensions/drm-copilot/resources/` (Grep): exactly the listed FU-823-2 files, the 14 FU-823-3 surfaces, and the four exception files (`.claude/rules/typescript.md` line 57, `.claude/rules/csharp.md` lines 5 and 10, and their CB copies); no `.claude-variants` file matches.
- `artifacts/orchestration/wip824-addendum2.patch` (local export of WIP_REF used to read hunk content at planning time): helper lines 110-183, hook lines 184-265, codex script lines 368-478 (collapse at 451-456), follow-ups test lines 1016-1284, tier-test lines 1285-1345, Pester files lines 686-1015, bats lines 1346-1538.
- `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: AC-1 through AC-15 lines 212-226; `issue.md` FU headings lines 12, 16, 20, 24, 28 and Work Mode line 10.
- `artifacts/orchestration/orchestrator-state.json`: `route_id` `preparation`, `next_step` `S4_atomic_planning`, `base_sha` e7d3779b.
- Sibling-region checks: the new follow-ups scan tests depend on `read_copy`, `CONSUMING_NAMES`, `PRODUCT_NAME_COPIES`, `CLAUDE_BUNDLE`, and `CODEX_BUNDLE`, all defined in the WIP_REF module; the comparator rows were traced against D2 (Appendix D trace); the existing `tests/shell/test_codex_web_setup_*.bats` suites target `.github/codex/codex-web-setup.sh`, not the `.codex` copy, so they are unaffected.

PLANNER-INTERNAL-REVIEW: PASS
CITATION-TO-TREE: PASS
CITATION: .claude/hooks/validate-feature-review-coverage.ps1 | lines 29-30, 258-265, 313, 318, 323, 327, 430-439, 449-451
CITATION: artifacts/orchestration/wip824-addendum2.patch | lines 139, 163, 262 (local git-ignored export of WIP_REF)
CITATION: scripts/powershell/PoshQC/PoshQC.Testing.psm1 | line 287
CITATION: tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1 | lines 297-313
CITATION: .claude/agents/atomic-executor.md | frontmatter tools lines 11-20
CITATION: .codex/codex-web-setup.sh | lines 10, 265, 285, 287-297, 340-342, 384
CITATION: tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py | lines 136, 393, 463
CITATION: tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py | lines 52-58, 162-177
CITATION: tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py | lines 276-293
CITATION: extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json | lines 54-55, 61
CITATION: .claude/hooks/enforce-powershell-batch-budget.ps1 | lines 299, 309-316, 393-399
CITATION: scripts/powershell/PoshQC/settings/pester.runsettings.psd1 | lines 15, 22, 26
CITATION: .claude/skills/feature-review-workflow/SKILL.md | lines 111, 143, 149, 158
CITATION: docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md | Acceptance Criteria lines 212-226
AC-TRACEABILITY: PASS
SCOPE-BOUNDARY: PASS
AC-INVENTORY: AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7, AC-8, AC-9, AC-10, AC-11, AC-12, AC-13, AC-14, AC-15
AC-MAPPING: AC-1 | IMPLEMENTATION: P3-T1, P3-T2, P3-T3, P3-T5, P3-T6 | TESTS: P3-T4, P8-T3 | EVIDENCE: evidence/regression-testing/pass-after-pester-824-final.TS.md
AC-MAPPING: AC-2 | IMPLEMENTATION: P1-T4, P1-T5 | TESTS: P2-T2, P2-T3, P8-T3 | EVIDENCE: evidence/regression-testing/expect-fail-hook-pester.TS.md
AC-MAPPING: AC-3 | IMPLEMENTATION: P3-T3, P3-T6 | TESTS: P8-T1 | EVIDENCE: evidence/other/p3-t3.TS.md
AC-MAPPING: AC-4 | IMPLEMENTATION: P4-T1, P4-T2, P4-T3, P4-T4, P4-T5, P4-T6 | TESTS: P8-T1, P10-T2 | EVIDENCE: evidence/regression-testing/pass-after-follow-ups-pytest.TS.md
AC-MAPPING: AC-5 | IMPLEMENTATION: P1-T1 | TESTS: P2-T1, P8-T1 | EVIDENCE: evidence/regression-testing/expect-fail-follow-ups-pytest.TS.md
AC-MAPPING: AC-6 | IMPLEMENTATION: P5-T1, P5-T2, P5-T3, P5-T4, P5-T5, P5-T6, P5-T7, P5-T8, P5-T9, P5-T10, P5-T11, P5-T12, P5-T13, P5-T14, P5-T15 | TESTS: P5-T16, P8-T1, P9-T15 | EVIDENCE: evidence/regression-testing/pass-after-bats.TS.md
AC-MAPPING: AC-7 | IMPLEMENTATION: P1-T1 | TESTS: P2-T1, P8-T1 | EVIDENCE: evidence/regression-testing/pass-after-follow-ups-pytest.TS.md
AC-MAPPING: AC-8 | IMPLEMENTATION: P3-T5, P3-T6, P3-T7, P4-T4, P5-T10, P6-T7 | TESTS: P8-T4, P8-T5, P8-T6, P9-T14 | EVIDENCE: evidence/qa-gates/parity-set-pytest.TS.md
AC-MAPPING: AC-9 | IMPLEMENTATION: P6-T1, P6-T7 | TESTS: P8-T1 | EVIDENCE: evidence/other/p6-t1.TS.md
AC-MAPPING: AC-10 | IMPLEMENTATION: P3-T3, P6-T1, P6-T2, P6-T3, P6-T4, P6-T5, P6-T6 | TESTS: P8-T1 | EVIDENCE: evidence/regression-testing/pass-after-follow-ups-pytest.TS.md
AC-MAPPING: AC-11 | IMPLEMENTATION: P1-T2 | TESTS: P2-T5, P8-T2 | EVIDENCE: evidence/regression-testing/fail-before-exception.note-b.TS.md
AC-MAPPING: AC-12 | IMPLEMENTATION: P7-T1 | TESTS: P7-T1 | EVIDENCE: evidence/other/p7-t1.TS.md
AC-MAPPING: AC-13 | IMPLEMENTATION: P9-T1 | TESTS: P9-T10, P9-T12, P9-T13, P9-T14, P10-T1 | EVIDENCE: evidence/qa-gates/qc-loop-complete.TS.md
AC-MAPPING: AC-14 | IMPLEMENTATION: P5-T9 | TESTS: P10-T2, P10-T3 | EVIDENCE: evidence/qa-gates/scope-check.TS.md
AC-MAPPING: AC-15 | IMPLEMENTATION: P7-T2 | TESTS: P11-T15 | EVIDENCE: evidence/other/pr-body-callouts.TS.md
UNRESOLVED-GAPS: NONE
