# issue-823-tier-rule-adoption-follow-ups (Plan)

- **Issue:** #824 (Addendum 2 only)
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-10T05-00 (revision 2, preflight round 2 delta: P14-T3 `--stat --minimal`, ledger r and a counts with P17-T3 `--minimal` diff and r + a sum, rule 5 `REPO_BASH_LINE` stop branch; Phases 0-11 unchanged. Preflight round 1 delta: remediation-case numbering and ADDED_CASES, R4 `DIAG|` output, `cp`/W1 write-route exception, HOLD_HEAD_n string-block locator, ledger change class; Phases 0-11 unchanged. Revision 2: operator-approved scope widening for feature-review finding PA-1; Phases 12-17 and Appendices I-P added)
- **Status:** Draft
- **Version:** 1.4
- **Work Mode:** full-bug
- **Branch:** `bug/issue-823-tier-rule-adoption-follow-ups-824`
- **Languages in scope:** PowerShell (one new and one modified hook, two Pester suites), Python (one new and one modified pytest module, no production module), Bash (one modified setup script, one bats suite), Markdown (rule, skill, agent, and instruction files), JSON (one pack manifest). TypeScript has no source change; its toolchain runs as a no-regression gate for AC-8 and AC-13.
- **Requirements source (sole AC source):** `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`, section `## Acceptance Criteria` (AC-1 through AC-15; AC-16 through AC-19 are added by P12-T3 under the 2026-10-10 scope widening).
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

## Scope-widening addendum (2026-10-10; governs Phases 12-17 only)

Phases 0-11 were executed and are not reopened; their checkboxes and artifacts stand. Feature review blocked on PA-1 (`docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/policy-audit.2026-10-10T00-44.md`, `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/remediation-inputs.2026-10-10T00-44.md`): `.codex/codex-web-setup.sh` gained functions and a source guard in this item, but kcov does not measure `.codex/`. The operator decided to widen #824 scope (decision option 2 of PA-1). Phases 12-17 deliver that decision. Where this addendum conflicts with the sections above, this addendum governs Phases 12-17 and the sections above continue to govern Phases 0-11.

**Additional terms**

- WIDEN_BASE means the commit P12-T1 records before any Phase 12-17 write. Every widening scope diff is anchored to it.
- HOLD_HEAD_n means the commit a CI hold of round n records (P12-T7 for round 0, P16-T1 for round 1 and later). RUN_ID_n means the GitHub Actions run id the orchestrator supplies when it resumes the executor after round n. CI_DIR_n means `artifacts/orchestration/ci-shell-coverage/RUN_ID_n` (git-ignored, under the permitted non-evidence sub-path `artifacts/orchestration/`).
- W-SET means these 18 repository paths, the complete write set of Phases 12-17 outside FEATURE: `.claude/rules/shell.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md`, `scripts/bash/shell_qc_lib.sh`, `tests/shell/test_shell_qc_discovery.bats`, `tests/shell/test_shell_qc_commands.bats`, `tests/fixtures/shell_qc/.codex/codex_entry.sh`, `.codex/codex-web-setup.sh`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh`, `tests/shell/test_codex_web_setup_codex_installers.bats`, `tests/shell/test_codex_web_setup_codex_dotnet.bats`, `tests/shell/test_codex_web_setup_codex_verify.bats`, `tests/fixtures/codex_web_setup/dotnet-repo/global.json`, `tests/fixtures/codex_web_setup/dotnet-repo/dotnet-tools.json`, `tests/fixtures/codex_web_setup/dotnet-repo/coverage.config`, `tests/fixtures/codex_web_setup/dotnet-sdk-installed/global.json`, `tests/fixtures/codex_web_setup/dotnet-sdk-installed/.dotnet-sdk/dotnet/placeholder.txt`, `tests/fixtures/codex_web_setup/dotnet-sdk-installed/.dotnet-sdk/sdk/8.0.100/placeholder.txt`, `tests/fixtures/codex_web_setup/bashrc-with-ci.txt`. Inside FEATURE, Phases 12-17 write only `spec.md`, `plan.2026-10-08T22-16.md` (task check-off), and artifacts under FEATURE/evidence/.
- BATS-NEW means the three suites `tests/shell/test_codex_web_setup_codex_installers.bats` (C824-16 to C824-33), `tests/shell/test_codex_web_setup_codex_dotnet.bats` (C824-34 to C824-47), and `tests/shell/test_codex_web_setup_codex_verify.bats` (C824-48 to C824-61). With the 15 cases of `tests/shell/test_codex_web_setup_codex_copy.bats` (C824-1 to C824-15) the C824 set is 61 cases. Cases added under Phase 16 remediation rule 4 (C824-62 onward) belong to the suite that owns the uncovered function.
- Tokens that Phase 12-17 searches look for and that do not exist in the tracked tree before these phases run (quoted so each search is an instruction): "all five discovery roots"; "for root in tools scripts .claude/lib/bash .claude/skills .codex; do"; the token `,$repo_root/.codex"` (the trailing double quote is part of it; it appears verbatim in Appendix J item J5); the token `"/.codex --exclude-pattern="` (Appendix J item J10); the token `[ "$shellcheck_calls" -eq 8 ]` (Appendix J item J9); "and .codex/ relative to the current dir."; "discover_shell_scripts finds a .sh file under the .codex root"; ".codex/codex_entry.sh"; "codex script fixture"; "8.0.100"; "PA-1 scope widening"; "## Change Log"; "AC-16:"; "AC-17:"; "AC-18:"; "AC-19:".

**Research findings (re-derived 2026-10-10 against the worktree)**

- `.codex/` shell scripts picked up by the widened discovery: exactly one, `.codex/codex-web-setup.sh`. Derivation: the only tracked `.codex/` file with a `.sh` suffix is `.codex/codex-web-setup.sh`, and the only `.codex/` file whose first line is a shebang is the same file (`#!/usr/bin/env bash`, line 1); every other tracked `.codex/` file is `.toml`, `.md`, `.json`, `.ps1`, or another non-shell type. `.codex/state/` is git-ignored (`.gitignore` line 71) and absent from a CI checkout. P12-T2 re-derives this set mechanically with the `is_shell_script` rule. The bundled copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/` is not under any discovery root, so it is not shfmt-checked itself; it is held byte-identical to the repository copy instead.
- `.github/codex/codex-web-setup.sh` is a different file. No parity test links it to `.codex/codex-web-setup.sh`: the three suites that source it (`tests/shell/test_codex_web_setup_apt_helpers.bats` line 8, `tests/shell/test_codex_web_setup_pypi_connectivity.bats` line 8, `tests/shell/test_codex_web_setup_source_safety.bats` line 13) test it alone, and the only bundle-parity test that reads `.codex/` (`tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`, lines 215-228) compares `.codex/` with its bundle copy only. `.github/` is not a discovery root. It is therefore out of scope and not written.
- Tests that pin the root list or include pattern: `tests/shell/test_shell_qc_discovery.bats` (root tests lines 61-71; sorted-list test lines 87-99, which pins 7 entries) and `tests/shell/test_shell_qc_commands.bats` (line 81 pins 7 shellcheck calls over the fixture tree; lines 128-131 assert the include pattern). No Python, Pester, or Jest test reads the root list, the include pattern, or the shell.md discovery text.
- Formatting gap: `.codex/codex-web-setup.sh` uses 2-space indentation on 254 lines; shfmt default formatting uses one tab per level (`.claude/rules/shell.md` Coding Standards). Nine of those lines (317-320 and 322-326) are inside the multi-line double-quoted `pwsh -Command` string that starts on line 316; shfmt does not re-indent string content, so they keep their spaces. The heredoc body of `write_repo_notes` (lines 351-376) has no leading whitespace.

**Binding execution constraints for Phases 12-17**

- OPS-1: no `sh`, `bash`, or `pwsh` invocation and no RUN script (Appendix G scripts are not used); no local bats, shfmt, shellcheck, or kcov run. Bats, shfmt, shellcheck, and kcov evidence comes only from the CI run of `.github/workflows/_shell-coverage.yml` that the orchestrator dispatches at a CI hold (Appendix P). The executor has no `gh` access.
- Permitted executor commands: `git`, `poetry run pytest`, `poetry run python -c` (single-line programs only), `grep`, `wc`, `ls`, `tail`, and `cp`; file edits use the Edit and Write tools, except the byte copies by `cp` (P13-T3, P14-T2, and the re-copies in remediation rules 1 and 2) and the layout writer W1 (P14-T1). No PowerShell, Python production, or TypeScript file is written in Phases 12-17, so no PoshQC, Black, Ruff, Pyright, Prettier, ESLint, TSC, or Jest step applies to these phases; the Python parity suites still run because they read the bundled copies.
- Commit and push at every phase boundary with `git add -- <explicit paths>` (each repository path and each evidence artifact named individually; never `.`, `-A`, a directory, or a glob), `git commit -m "<subject>" -m "Refs #824"`, and `git push origin bug/issue-823-tier-rule-adoption-follow-ups-824`. Never force-push, never rebase, never merge, and delete nothing. A commit task's own evidence artifact and the plan check-off it makes are committed by the next phase's commit task; the final ones (P17-T15) are committed by the orchestrator.
- If a hook or permission rule denies any command, Write, or Edit (including `git add`, `git commit`, `git push`, a write under a `.codex/` directory, or an edit of `.claude/rules/shell.md`), stop, record the denial text verbatim in the task artifact, and report to the orchestrator. Do not reword the command and do not bypass the hook.
- Hard exclusions are amended for Phases 12-17 by the operator decision: `scripts/bash/shell_qc_lib.sh`, the two `shell.md` copies, `tests/shell/test_shell_qc_discovery.bats`, `tests/shell/test_shell_qc_commands.bats`, and the W-SET fixtures and suites are in scope. `.github/workflows/_shell-coverage.yml`, `scripts/dev-tools/KcovFunctionCoverageGate.ps1` and its tests, `tests/scripts/workflows/ShellCoverageWorkflow.Tests.ps1`, `.github/codex/codex-web-setup.sh`, and every other hard exclusion listed in Execution constraints remain excluded. Any write outside W-SET and FEATURE stops the plan for a report.
- Fail-closed evidence rule for Bash: the `N/A - .codex/ is outside the kcov include roots` literal recorded by P10-T1 is superseded. Phases 12-17 record numeric Bash coverage values from CI: the round-0 repo-wide value as baseline and the final-round repo-wide and per-file values as post-change. A missing value makes the Bash verdict REMEDIATION-REQUIRED, never PASS.
- The Execution-constraints rule "The executor does not commit, stage, or push" and the `sh`-based routes do not apply to Phases 12-17.

**Planner decisions for Phases 12-17**

- PD13 - Discovery root and include pattern. The root `.codex` is added after `.claude/skills` in `discover_shell_scripts` (line 85) and `$repo_root/.codex` is appended to `include_pattern` in `run_test_coverage` (line 350). Under `LC_ALL=C` ordering `.codex/` sorts after `.claude/` (0x6C < 0x6F) and before `scripts/`, which fixes the new position in the sorted-list test.
- PD14 - shfmt layout without a local shfmt. P14-T1 converts each leading run of two-space groups to the same number of tabs with a single-line `poetry run python -c` program, skipping the string content between the line that ends with `"& {` and the line that begins with `}"` (lines 317-326 at WIDEN_BASE). This matches shfmt default output for every construct the file uses (function bodies, `if` bodies, subshells, backslash continuations, and pipeline continuations each indent one level). The CI `shell-qc check` step (`shfmt -d`) is the authoritative check; any diff it prints is applied verbatim under the Phase 16 remediation rule.
- PD15 - Behavior unchanged. Proof is two-part: `git diff -w WIDEN_BASE -- .codex/codex-web-setup.sh` is empty after P14-T1 (whitespace-only change), and the 15 pre-existing C824 cases pass in CI. A shellcheck remediation under the Phase 16 remediation rule (a behavior-preserving rewrite of the cited line, or an inline `# shellcheck disable=SCxxxx` comment with a reason) is recorded line by line in the round ledger; those ledgered lines are the only permitted non-whitespace differences, and P17-T3 checks the count.
- PD16 - AC-14 under reformatting. Re-indenting line 337 (a `warn` text that names `vswhere.exe`) creates diff lines that mention `vswhere` without touching the `vswhere`/`vstest` block, so the P10-T3 command would now report a false positive. P14-T3 re-verifies AC-14 with `git diff -w`, which hides whitespace-only lines; P10-T3 and its artifact stand for the pre-widening tree.
- PD17 - Coverage tests. BATS-NEW covers every function of `.codex/codex-web-setup.sh` that `tests/shell/test_codex_web_setup_codex_copy.bats` does not, including each branch. External commands are replaced by shell functions; tests that need a tool to be absent limit PATH (and HOME) to the test directory, the pattern C824-11 already uses. No temporary file is created: `append_if_missing` writes to `/dev/null` or to a fixture that already holds the line, and `touch`, `mkdir`, `rm`, `mktemp`, `curl`, `bash`, `tar`, `sudo`, and `dpkg` are stubbed wherever reached. Each suite's `teardown` removes the stubs so bats-core's own cleanup runs the real commands. The "already installed" SDK branch uses a fixture in which `.dotnet-sdk/dotnet` is a directory, which satisfies `[ -x ]` without a checked-in executable.
- PD18 - CI rounds. Round 0 (P12-T7) runs on the branch before any widening edit and supplies the Bash baseline. Round 1 (P16-T1) runs after Phases 13-15. A failed round triggers the Phase 16 remediation rule and a new round. The executor stops at every hold; it never polls CI.
- PD19 - AC-6 and AC-13. AC-6 was left unchecked only because the bats suite needed a CI run (P5-T16 `PENDING-CI`); the final round supplies that run, so P17-T12 checks AC-6 when C824-1 to C824-15 pass in it. AC-13 also waits on PR CI for the Python, TypeScript, and PowerShell toolchain, which these phases do not re-run, so P17-T13 records it as pending and leaves it unchecked.

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

- [x] [P7-T1] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/issue.md` with insertions S1 through S5 of Appendix F (status marks; the prior target under `docs/features/potential/` no longer exists, so this is the redo of that WIP_REF change), and record FEATURE/evidence/other/p7-t1.TS.md.
      Commands: `grep -c -F "Status: Resolved by #824." docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/issue.md`; `grep -c -F "Status: Open (out of scope for #824; no release automation is run)." docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/issue.md`; `grep -c "^## FU-823-" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/issue.md`; `grep -c -F -e "- Work Mode: full-bug" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/issue.md`.
      Acceptance: the greps print 4, 1, 5, and 1 respectively.
- [x] [P7-T2] Write the PR-body callout notes FEATURE/evidence/other/pr-body-callouts.TS.md with the content of Appendix H (for the parallel orchestrator's PR authoring; this plan does not author the PR).
      Commands (substitute the artifact's TS): `grep -c -F "Refs #824" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/evidence/other/pr-body-callouts.TS.md`; `grep -c -F ".github/instructions/csharp-code-change.instructions.md" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/evidence/other/pr-body-callouts.TS.md`; `grep -c -F "FU-823-4" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/evidence/other/pr-body-callouts.TS.md`; `grep -c -i -E "(close[sd]?|fix(e[sd])?|resolve[sd]?) #824" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/evidence/other/pr-body-callouts.TS.md`.
      Acceptance: the first three greps each print 1 or more; the closing-keyword grep prints 0 (`EXIT_CODE: 1`, `ExpectedExitCode: 1`).

### Phase 8 — Pass-After Verification

- [x] [P8-T1] [pass-after] Run `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` after every production, policy, and mirror edit, and record FEATURE/evidence/regression-testing/pass-after-follow-ups-pytest.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
      Acceptance: exit 0 and a summary reporting 43 passed and no failed. A failure is fixed by correcting the edited production or mirror file (and re-copying the mirror), never by editing the test module; the affected Phase 3-7 task and this task are rerun.
- [x] [P8-T2] [pass-after] Run `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` and record FEATURE/evidence/regression-testing/pass-after-tier-gate-pytest.TS.md.
      Commands: `poetry run pytest "tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_retired_threshold_scan_reads_coverage_context_only"`; `poetry run pytest tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`.
      Acceptance: the node run exits 0 and reports 1 passed; the module run exits 0 and reports BASE_TIER_COUNT plus 1 passed (81 at RESEARCH_BASE) and no failed.
- [x] [P8-T3] [pass-after] Re-run PESTER-824 after all edits and record FEATURE/evidence/regression-testing/pass-after-pester-824-final.TS.md.
      Command: `sh artifacts/orchestration/wip824-run/pester-files.sh tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`.
      Acceptance: exit 0 and `Passed=32 Failed=0 FailedBlocks=0 FailedContainers=0`.
- [x] [P8-T4] Run PARITY-SET and record FEATURE/evidence/qa-gates/parity-set-pytest.TS.md.
      Commands: `poetry run pytest "tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_codex_legacy_variant_files_contain_corrected_gate_commands" "tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_bundled_claude_files_are_listed_in_some_pack_manifest"`; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`.
      Acceptance: the node run exits 0 and reports 2 passed (variant pins and manifest completeness, including the new helper); the PARITY-SET run has no failed test other than KL-510 (recorded as in P0-T14; otherwise exit 0), and its passed count is at least BASE_PARITY_PASSED plus 1 (the note B test) minus the KL-510 adjustment.
- [x] [P8-T5] Run the Jest twin `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` and record FEATURE/evidence/qa-gates/jest-manifest-twin.TS.md.
      Command: `npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts`.
      Acceptance: exit 0; the Jest `Tests:` line reports at least one passed test and no failed test.
- [x] [P8-T6] Verify byte identity of all 17 repository/bundle pairs and record FEATURE/evidence/qa-gates/mirror-identity.TS.md.
      Commands: the 16 `git diff --no-index --exit-code` commands of P0-T9 in the same order; `git diff --no-index --exit-code .claude/hooks/feature-review-coverage-thresholds.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/feature-review-coverage-thresholds.ps1`; `git status --porcelain -- extensions/drm-copilot/resources`.
      Acceptance: each of the 17 diffs exits 0 with no output; the status listing shows exactly the 20 bundle paths of the P0-T7 write set: 19 ` M` lines (the 16 re-copied mirrors, the two variant files, and `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`) and 1 `??` line (the new helper mirror). When the orchestrator has committed between phases, `git diff --name-only BASE_SHA -- extensions/drm-copilot/resources` is recorded as well and the union of the two listings must equal the same 20 paths.
- [x] [P8-T7] Verify the 500-line limit for every production and test file this plan writes, and record FEATURE/evidence/qa-gates/line-counts.TS.md.
      Command: `wc -l .claude/hooks/validate-feature-review-coverage.ps1 .claude/hooks/feature-review-coverage-thresholds.ps1 .codex/codex-web-setup.sh tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 tests/shell/test_codex_web_setup_codex_copy.bats`.
      Acceptance: exit 0 and every per-file count is at most 500; the hook count and the #823 test count are recorded explicitly as FINAL_HOOK_LINES and FINAL_TIER_LINES.

### Phase 9 — Final QA Loop

Restart rule: run P9-T1 through P9-T17 in order. If any step fails, or if any step changes a tracked or new file, fix the cause, re-copy the bundled mirror of any changed repository file that has one (the matching Phase 3-6 `cp` task), then restart from P9-T1 and rewrite every Phase 9 artifact with a new TS. The loop ends only when P9-T1 through P9-T17 pass in one uninterrupted pass. Each artifact records its loop iteration number in `Output Summary:`. When `poetry run black --check .` fails, the fix is `poetry run black` on the named files followed by a restart.

- [x] [P9-T1] Python format check, and record FEATURE/evidence/qa-gates/black-check.TS.md.
      Command: `poetry run black --check .`.
      Acceptance: exit 0 and the summary containing "would be left unchanged" with no line containing "would reformat".
- [x] [P9-T2] PoshQC format over `.claude/hooks` and `tests/scripts/claude-hooks` with a before-and-after observation, and record FEATURE/evidence/qa-gates/poshqc-format.TS.md.
      Commands: `git status --porcelain -- .claude/hooks tests/scripts/claude-hooks`; `sh artifacts/orchestration/wip824-run/poshqc-format.sh`; `git status --porcelain -- .claude/hooks tests/scripts/claude-hooks`.
      Acceptance: the formatter exits 0; its output contains no line beginning "Formatted:"; the two status listings are identical (the expected listing is ` M .claude/hooks/validate-feature-review-coverage.ps1`, `?? .claude/hooks/feature-review-coverage-thresholds.ps1`, and the two `??` test files, or nothing when the orchestrator has committed). A "Formatted:" line or a changed listing triggers the restart rule, with one exception: the formatter scans all of `.claude/hooks`, including the hard-excluded hooks, so a "Formatted:" line or a changed listing that names any file outside the P0-T7 write set (recorded by repository-relative tail) stops the plan for a report instead; the executor does not revert or re-edit that file on its own authority.
- [x] [P9-T3] Prettier check of the extension sources, and record FEATURE/evidence/qa-gates/prettier-check.TS.md.
      Command: `node extensions/drm-copilot/node_modules/prettier/bin/prettier.cjs --check "extensions/drm-copilot/src/**/*.ts" "extensions/drm-copilot/test/**/*.ts" "extensions/drm-copilot/*.json" "extensions/drm-copilot/*.cjs"`.
      Acceptance: the exit code and summary equal BASE_PRETTIER (PD11); with a clean baseline this is exit 0 and "All matched files use Prettier code style!".
- [x] [P9-T4] Python lint, and record FEATURE/evidence/qa-gates/ruff-check.TS.md.
      Command: `poetry run ruff check`.
      Acceptance: exit 0 and "All checks passed!".
- [x] [P9-T5] PoshQC analyze over the same two folders, and record FEATURE/evidence/qa-gates/poshqc-analyze.TS.md.
      Command: `sh artifacts/orchestration/wip824-run/poshqc-analyze.sh`.
      Acceptance: exit 0 and a line beginning "PSScriptAnalyzer passed: no findings under".
- [x] [P9-T6] ESLint, and record FEATURE/evidence/qa-gates/eslint.TS.md.
      Command: `npm --prefix extensions/drm-copilot run lint`.
      Acceptance: the exit code and problem summary equal BASE_ESLINT (PD11).
- [x] [P9-T7] Python type check, and record FEATURE/evidence/qa-gates/pyright.TS.md.
      Command: `poetry run pyright`.
      Acceptance: exit 0 and a summary beginning "0 errors".
- [x] [P9-T8] TypeScript type check, and record FEATURE/evidence/qa-gates/tsc.TS.md.
      Command: `npm --prefix extensions/drm-copilot run typecheck`.
      Acceptance: the exit code and the "error TS" line count equal BASE_TSC (PD11).
- [x] [P9-T9] Shell syntax check of both setup-script copies, and record FEATURE/evidence/qa-gates/sh-syntax.TS.md.
      Commands: `sh -n .codex/codex-web-setup.sh`; `sh -n extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh`.
      Acceptance: both exit 0 with no output.
- [x] [P9-T10] Full pytest run in coverage mode, run in the background, and record FEATURE/evidence/qa-gates/pytest-full-coverage.TS.md.
      Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`.
      Acceptance: the failing set is a subset of the P0-T15 pre-existing set (KL-510 included) and contains no test from the two Python modules this plan writes or from PARITY-SET other than KL-510 (PD10); with no pre-existing failure this is exit 0. The summary line, the verbatim `TOTAL` row, and the passed count are recorded; the passed count is at least BASE_FULL_PASSED plus 44 (43 new follow-up tests and 1 note B test) minus the KL-510 adjustment.
- [x] [P9-T11] Post-change numeric Python coverage from the P9-T10 JSON report, and record FEATURE/evidence/qa-gates/python-coverage-values.TS.md.
      Command: the P0-T16 command, verbatim.
      Acceptance: exit 0 and `LINE <n> BRANCH <n> COMBINED <n>`, recorded as FINAL_PY_LINE, FINAL_PY_BRANCH, FINAL_PY_COMBINED; FINAL_PY_LINE is at least 85 and at least BASE_PY_LINE; FINAL_PY_BRANCH is at least 75 and at least BASE_PY_BRANCH.
- [x] [P9-T12] Full PoshQC test run with coverage, run in the background, plus the JUnit totals, and record FEATURE/evidence/qa-gates/poshqc-test.TS.md.
      Commands: `sh artifacts/orchestration/wip824-run/poshqc-test.sh`; the JUnit one-liner of Appendix G, item G6.
      Acceptance: the `FAILED` names are a subset of the P0-T20 pre-existing set and include no PESTER-824 case (PD10); with no pre-existing failure the test exit code is 0. TESTS is at least BASE_PS_TESTS plus 28 (11 resolver rows and 17 hook cases); FINAL_PS_TESTS and FINAL_PS_FAILURES are recorded.
- [x] [P9-T13] Post-change numeric PowerShell coverage, including changed-line coverage of the modified hook, from the P9-T12 report, and record FEATURE/evidence/qa-gates/powershell-coverage-values.TS.md.
      Commands (substitute BASE_SHA): the coverage one-liner of Appendix G, item G5; `git diff --no-color --unified=0 --output=artifacts/orchestration/wip824-hunks/hook-final.diff BASE_SHA -- .claude/hooks/validate-feature-review-coverage.ps1`; `git status --porcelain -- .claude/hooks/validate-feature-review-coverage.ps1`; the changed-line one-liner of Appendix G, item G7.
      Acceptance: G5 exits 0; `REPO_LINE` is numeric (FINAL_PS_LINE) and at least BASE_PS_LINE; the hook `FILE` value (FINAL_HOOK_COV) is at least 85 and at least BASE_HOOK_COV; the helper `FILE` value (FINAL_HELPER_COV) is numeric and at least 85 (the helper is entirely new, so this whole-file value is its new-code coverage). The diff command exits 0; the status line is ` M .claude/hooks/validate-feature-review-coverage.ps1` or nothing when the orchestrator has committed (the diff is anchored to BASE_SHA, so it carries the hook change in both states). G7 exits 0 and prints one line `CHANGED_LINES <n> EXECUTABLE_CHANGED <n> UNCOVERED_CHANGED NONE` with `CHANGED_LINES` above 0 and `EXECUTABLE_CHANGED` above 0; the line is recorded verbatim as FINAL_HOOK_CHANGED_LINES. G7 is the last command, so `EXIT_CODE: 0`. A `MISSING` value, a figure below 85, `EXECUTABLE_CHANGED 0`, or any line number listed after `UNCOVERED_CHANGED` fails the loop and is reported as remediation-required (the fix is a test that executes the listed hook line, never an edit to the measurement).
- [x] [P9-T14] Jest suite in coverage mode, run in the background, and record FEATURE/evidence/qa-gates/jest-coverage.TS.md.
      Command: `npm --prefix extensions/drm-copilot run test:coverage`.
      Acceptance: the failing set is a subset of the P0-T26 pre-existing set (exit 0 when that set is empty); FINAL_TS_LINES and FINAL_TS_BRANCHES are recorded and each is at least its baseline value.
- [x] [P9-T15] Run the bats suite on the P0-T28 branch and record FEATURE/evidence/qa-gates/bats.TS.md.
      Command (branch `BATS_LOCAL: available`): `npx --yes bats tests/shell/test_codex_web_setup_codex_copy.bats`.
      Acceptance (local branch): exit 0, `1..15`, 15 `ok` lines, no `not ok`. CI branch: the artifact repeats the P5-T16 `PENDING-CI` record with `EXIT_CODE: 0` for the recording step; this is the only permitted non-execution branch and it keeps AC-6 unchecked.
- [x] [P9-T16] Re-verify byte identity of the 17 pairs after the loop, and record FEATURE/evidence/qa-gates/mirror-identity-final.TS.md.
      Commands: the 17 diff commands of P8-T6 in the same order; `git status --porcelain -- extensions/drm-copilot/resources`.
      Acceptance: each diff exits 0 with no output.
- [x] [P9-T17] Record the loop result FEATURE/evidence/qa-gates/qc-loop-complete.TS.md.
      Command: none (record `Command: none - loop summary of P9-T1 through P9-T16` and `EXIT_CODE: 0`).
      Acceptance: the artifact names the iteration number of the clean pass and the artifact path of each of P9-T1 through P9-T16 from that same iteration, each with exit code and pass status.

### Phase 10 — Coverage Comparison and Scope Verification

- [x] [P10-T1] Write the coverage comparison FEATURE/evidence/qa-gates/coverage-comparison.TS.md (inputs: P0-T16, P9-T11, P0-T21, P9-T13, P0-T26, P9-T14).
      Command: none (record `Command: none - comparison of recorded values` and `EXIT_CODE: 0`).
      Acceptance: the artifact lists, for PowerShell: BASE_PS_LINE, FINAL_PS_LINE, the delta, BASE_HOOK_COV, FINAL_HOOK_COV, the verbatim G7 line FINAL_HOOK_CHANGED_LINES directly after FINAL_HOOK_COV, FINAL_HELPER_COV, and `New/changed-code coverage: .claude/hooks/feature-review-coverage-thresholds.ps1 <FINAL_HELPER_COV> (new file, whole-file value); .claude/hooks/validate-feature-review-coverage.ps1 <FINAL_HOOK_COV> file, changed lines UNCOVERED_CHANGED NONE` with both percentages at least 85 (PowerShell has no branch gate); for Python: BASE_PY_LINE, FINAL_PY_LINE, BASE_PY_BRANCH, FINAL_PY_BRANCH, both deltas, and `New/changed-code coverage: N/A - no production Python line changed`; for TypeScript: the four TS values and `New/changed-code coverage: N/A - no TypeScript file changes`; for Bash: `N/A - .codex/ is outside the kcov include roots (pre-existing, follow-up)`. Every value is numeric or one of the quoted N/A literals. A negative PowerShell or Python delta, a per-file value below 85, or a FINAL_HOOK_CHANGED_LINES line whose `UNCOVERED_CHANGED` value is not `NONE`, makes the artifact verdict `REMEDIATION-REQUIRED` and blocks AC-13.
- [x] [P10-T2] Verify the complete write set and the hard exclusions against BASE_SHA, and record FEATURE/evidence/qa-gates/scope-check.TS.md.
      Commands (substitute BASE_SHA): `git branch --show-current`; `git diff --name-only BASE_SHA -- . ':!docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824' ':!docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md'`; `git status --porcelain --untracked-files=all -- . ':!docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824' ':!docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md'`; `git diff --name-only BASE_SHA -- docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824`; `git status --porcelain --untracked-files=all -- docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824`; `git diff --name-only BASE_SHA -- docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md`; `git status --porcelain -- docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md`; `git diff --name-only BASE_SHA -- .claude/hooks/enforce-promotion-mcp-only.ps1 .claude/hooks/hook-command-invocation.ps1 .claude/hooks/hook-command-raw-invocation.ps1 .claude/hooks/enforce-epic-worktree-removal-gate.ps1 .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 .codex/hooks extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-raw-invocation.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json scripts/dev-tools tests/scripts/dev-tools .github/workflows tests/scripts/workflows docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824`; `git status --porcelain --untracked-files=all -- .codex/hooks scripts/dev-tools tests/scripts/dev-tools .github/workflows tests/scripts/workflows extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824`.
      Acceptance: the branch is `bug/issue-823-tier-rule-adoption-follow-ups-824`; the union of the paths printed by the second and third commands is exactly the 43 non-FEATURE paths of the P0-T7 write set (36 tracked modifications and 7 new files: the helper, its mirror, the two Pester files, the follow-ups pytest module, the bats suite, and the fixture); the union of the fourth and fifth commands contains only FEATURE paths named `issue.md`, `spec.md`, or `plan.2026-10-08T22-16.md`, paths under FEATURE `research/`, and paths under FEATURE `evidence/` (the feature folder may be committed or untracked, so either listing may be empty); the union of the sixth and seventh commands is empty (`PROMOTION_DELETE: committed` in BASE_SHA) or consists only of `docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md` from the diff and/or the status line ` D docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md` (the promotion deletion, pending or committed after BASE_SHA); the last two commands print nothing. Any other path stops the plan for a report.
- [x] [P10-T3] Verify the AC-14 `vswhere` condition on the final tree, and record FEATURE/evidence/qa-gates/vswhere-check.TS.md.
      Commands (substitute BASE_SHA): `git diff --unified=0 --output=artifacts/orchestration/wip824-hunks/codex-setup-final.diff BASE_SHA -- .codex/codex-web-setup.sh`; `git status --porcelain -- .codex/codex-web-setup.sh`; `grep -c -F "vswhere_check" .codex/codex-web-setup.sh extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh`; `grep -c -e "^[-+].*vswhere" artifacts/orchestration/wip824-hunks/codex-setup-final.diff`.
      Acceptance: the diff exits 0; the `vswhere_check` grep prints `:0` for both files; the last grep prints 0 (`EXIT_CODE: 1`, `ExpectedExitCode: 1`).

### Phase 11 — Acceptance-Criteria Check-Off

Each task checks one AC box in `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md` (change `- [ ] AC-n:` to `- [x] AC-n:`, nothing else) only when every named verifying task is checked and its artifact passes, and appends one line `AC-n checked: <verifying artifact paths>` to FEATURE/evidence/other/ac-checkoff.TS.md (one artifact for the phase, created by P11-T1). Acceptance for each task (n is the task's AC number): `grep -c -F "[x] AC-n:" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md` prints 1 after the edit (the trailing colon keeps AC-1 from matching AC-10 through AC-15), and the artifact line names every verifying artifact. An AC whose verifying artifact fails stays unchecked and the gap is recorded in the same artifact.

- [x] [P11-T1] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-1. Verifying tasks: P3-T1, P3-T2, P3-T3, P3-T5, P3-T6, P3-T4, P8-T3, P8-T6.
- [x] [P11-T2] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-2. Verifying tasks: P1-T4, P1-T5, P2-T2, P2-T3, P8-T3 (F824-1, F824-2, F824-3 and resolver rows 8 and 9 passed).
- [x] [P11-T3] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-3. Verifying tasks: P3-T3 ("80 percent" 0, fallback 1), P3-T6, P8-T1 (`test_precedence_copy_states_per_metric_fallback` for both hook copies).
- [x] [P11-T4] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-4. Verifying tasks: P4-T1 through P4-T6, P8-T1 (`test_listed_copy_names_no_consuming_product`, 6 cases), P3-T7 and P10-T2 (manifest membership unchanged apart from the helper entry).
- [x] [P11-T5] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-5. Verifying tasks: P1-T1, P2-T1, P8-T1 (`test_pushed_rule_and_skill_files_name_no_consuming_product`, `test_name_exceptions_still_name_a_consuming_product`, `test_pushed_rule_and_skill_scan_covers_the_listed_copies`).
- [x] [P11-T6] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-6. Verifying tasks: P5-T1 through P5-T15, P8-T1 (`test_surface_does_not_hard_code_solution_file`, 14 cases), P5-T16 and P9-T15 on the local branch. When P5-T16 recorded `PENDING-CI`, AC-6 stays unchecked and the artifact line reads `AC-6 pending CI: tests/shell/test_codex_web_setup_codex_copy.bats`.
- [x] [P11-T7] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-7. Verifying tasks: P1-T1, P2-T1, P8-T1 (`test_pushed_roots_carry_no_hard_coded_solution_file` and the 14 surface cases, including both `.github` copies).
- [x] [P11-T8] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-8. Verifying tasks: P8-T4, P8-T5, P8-T6, P9-T14.
- [x] [P11-T9] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-9. Verifying tasks: P6-T1, P6-T7, P8-T1 (`test_review_workflow_step_eight_uses_governing_thresholds`, 2 cases).
- [x] [P11-T10] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-10. Verifying tasks: P3-T3, P3-T6, P6-T1 through P6-T12, P8-T1 (`test_precedence_copy_states_per_metric_fallback`, 14 cases).
- [x] [P11-T11] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-11. Verifying tasks: P1-T2, P2-T5, P8-T2 (`test_retired_threshold_scan_reads_coverage_context_only`).
- [x] [P11-T12] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-12. Verifying task: P7-T1.
- [x] [P11-T13] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-13. Verifying tasks: P9-T1 through P9-T17 in one uninterrupted pass, P10-T1 (verdict not `REMEDIATION-REQUIRED`). The artifact line lists any pre-existing failure that remained (PD10).
- [x] [P11-T14] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-14. Verifying tasks: P10-T2, P10-T3, P5-T9.
- [x] [P11-T15] Record AC-15 as pending pull-request authoring in FEATURE/evidence/other/ac-checkoff.TS.md and leave `- [ ] AC-15:` unchanged in `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md` (PD12). Verifying artifact for the later check-off: FEATURE/evidence/other/pr-body-callouts.TS.md (P7-T2).
      Acceptance: `grep -c -F "[ ] AC-15:" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md` prints 1, and the artifact line reads `AC-15 pending PR: Refs #824 and callouts in evidence/other/pr-body-callouts.TS.md`.
- [x] [P11-T16] Write the AC status summary FEATURE/evidence/other/ac-status-summary.TS.md in the acceptance-criteria-tracking format (Source, Total AC items 15, Checked off, Remaining, Items remaining).
      Commands: `grep -c "^- \[x\] AC-" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`; `grep -c "^- \[ \] AC-" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`.
      Acceptance: the two counts sum to 15; the summary's Checked off and Remaining values equal them; Items remaining lists AC-15 and, when P5-T16 recorded `PENDING-CI`, AC-6.

### Phase 12 — Widening Preconditions, Spec Amendment, and Shell Baseline (CI Round 0)

The Scope-widening addendum governs this phase and every later phase. Phase 12 writes no file outside FEATURE.

- [x] [P12-T1] Verify the branch, the clean tree, and the remote state before any widening write, and record WIDEN_BASE in FEATURE/evidence/baseline/widening-preconditions.TS.md.
      Commands: `git branch --show-current`; `git status --porcelain --untracked-files=all`; `git rev-parse HEAD`; `git merge-base --is-ancestor 7bbd0b9b9 HEAD`; `git fetch origin bug/issue-823-tier-rule-adoption-follow-ups-824`; `git rev-parse origin/bug/issue-823-tier-rule-adoption-follow-ups-824`; `git merge-base --is-ancestor origin/bug/issue-823-tier-rule-adoption-follow-ups-824 HEAD`.
      Acceptance: the branch command prints exactly `bug/issue-823-tier-rule-adoption-follow-ups-824`; the status command prints nothing (the orchestrator commits this plan revision before it resumes the executor, so any listed path stops the plan); `git rev-parse HEAD` prints one 40-character SHA, recorded as WIDEN_BASE; both ancestry checks exit 0 (origin/main 7bbd0b9b9 is merged in, and the local branch is not behind the remote). When the remote SHA equals WIDEN_BASE the artifact records `REMOTE: equal`. When it differs, run `git push origin bug/issue-823-tier-rule-adoption-follow-ups-824`, `git fetch origin bug/issue-823-tier-rule-adoption-follow-ups-824`, and `git rev-parse origin/bug/issue-823-tier-rule-adoption-follow-ups-824`, and record `REMOTE: pushed` with the new remote SHA, which must equal WIDEN_BASE. A failed ancestry check or a rejected push stops the plan. `EXIT_CODE` is that of the last command run.
- [x] [P12-T2] Re-derive the `.codex/` shell-script set with the `is_shell_script` rule of `scripts/bash/shell_qc_lib.sh` (lines 54-73), confirm the two affected bundle pairs are byte-identical, and record the pre-widening sizes in FEATURE/evidence/baseline/codex-shell-scope.TS.md.
      Commands: reader R1 of Appendix P; `git diff --no-index --exit-code .claude/rules/shell.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md`; `git diff --no-index --exit-code .codex/codex-web-setup.sh extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh`; `grep -c "^  " .codex/codex-web-setup.sh`; `grep -c "^ " scripts/bash/shell_qc_lib.sh`; `wc -l .codex/codex-web-setup.sh scripts/bash/shell_qc_lib.sh tests/shell/test_shell_qc_discovery.bats tests/shell/test_shell_qc_commands.bats tests/shell/test_codex_web_setup_codex_copy.bats`.
      Acceptance: R1 exits 0 and prints a `TRACKED <n>` line (n recorded) followed by exactly `SHELL ['.codex/codex-web-setup.sh']`; any other SHELL list stops the plan, because W-SET and Phase 14 assume this one file. Both diffs exit 0 with no output. The first indentation grep prints 254; the second prints 0. `wc` prints 413, 394, 99, 203, and 187 for the five files in that order; any other value stops the plan, because the Appendix J old texts and the P14-T1 counts were derived from these sizes. `wc` is last, so `EXIT_CODE: 0`.
- [x] [P12-T3] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md` with insertion I1 of Appendix I (AC-16 through AC-19, unchecked; Edit tool; the operator authorized this spec write), and record FEATURE/evidence/other/p12-t3.TS.md.
      Commands: `grep -c "^- \[ \] AC-1[6-9]:" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`; `grep -c "^- \[[ x]\] AC-[0-9]*:" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`; `grep -c -F "AC-19:" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`.
      Acceptance: the greps print 4, 19, and 1. `EXIT_CODE: 0`.
- [x] [P12-T4] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md` with insertion I2 of Appendix I (the dated `## Change Log` entry recording the operator decision on PA-1), and record FEATURE/evidence/other/p12-t4.TS.md.
      Commands: `grep -c "^## Change Log$" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`; `grep -c -F "PA-1 scope widening" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`; `grep -c -F "2026-10-10" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`.
      Acceptance: the greps print 1, 1, and at least 1. `EXIT_CODE: 0`.
- [x] [P12-T5] Baseline full pytest run before any widening write outside FEATURE, run in the background, and record FEATURE/evidence/baseline/widening-pytest-full.TS.md.
      Command: `poetry run pytest`.
      Acceptance: the exit code, the summary line, and every `FAILED` line are recorded; the passed count is WIDEN_PY_PASSED and the failing names other than KL-510 are WIDEN_PY_FAILED. A failure is recorded, not a stop condition (PD10 applies to P17-T2). The rootdir header is recorded only by its repository-relative tail.
- [x] [P12-T6] Commit and push Phase 12, and record FEATURE/evidence/other/commit-p12.TS.md.
      Commands: `git add -- docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/plan.2026-10-08T22-16.md` followed by the full path of each artifact P12-T1 to P12-T5 wrote, named individually; `git commit -m "docs(824): amend spec for PA-1 scope widening and record widening baseline" -m "Refs #824"`; `git push origin bug/issue-823-tier-rule-adoption-follow-ups-824`; `git status --porcelain --untracked-files=all`; `git fetch origin bug/issue-823-tier-rule-adoption-follow-ups-824`; `git rev-parse HEAD origin/bug/issue-823-tier-rule-adoption-follow-ups-824`.
      Acceptance: `git add`, `git commit`, and `git push` each exit 0 and the push is not forced; the status command prints nothing; the last command prints two equal SHAs. `EXIT_CODE: 0`. This artifact is committed by P13-T9.
- [x] [P12-T7] [CI-HOLD] Round 0: record HOLD_HEAD_0 in FEATURE/evidence/other/ci-hold-round0.TS.md, then stop and report the line `CI-HOLD: ROUND 0 HEAD <HOLD_HEAD_0>` to the orchestrator.
      Commands: `git rev-parse HEAD`; `git fetch origin bug/issue-823-tier-rule-adoption-follow-ups-824`; `git rev-parse origin/bug/issue-823-tier-rule-adoption-follow-ups-824`.
      Acceptance: the first and last commands print the same SHA, recorded as HOLD_HEAD_0; the artifact records `HOLD: round 0`, HOLD_HEAD_0, and `RESUME-CONDITION: orchestrator completes Appendix P steps O1-O8 for HOLD_HEAD_0 and resumes the executor with CI-RESUME: ROUND 0 RUN_ID <id>`. This task is checked off when the artifact exists; the executor then stops and performs no further task until it is resumed.

### Phase 13 — CI Round-0 Readout and Shell-QC Scope Widening

Each task writes the artifact it names; edit tasks write FEATURE/evidence/other/p13-tN.TS.md (N is the task number).

- [x] [P13-T1] Read the round-0 CI files the orchestrator placed in CI_DIR_0, and record the Bash baseline in FEATURE/evidence/baseline/ci-shell-round0.TS.md.
      Commands (substitute RUN_ID_0): `ls artifacts/orchestration/ci-shell-coverage/RUN_ID_0`; reader R2 of Appendix P on `artifacts/orchestration/ci-shell-coverage/RUN_ID_0/run.json`; reader R3 on `artifacts/orchestration/ci-shell-coverage/RUN_ID_0/run.log`; reader R4 on `artifacts/orchestration/ci-shell-coverage/RUN_ID_0/run.log`; reader R5 on `artifacts/orchestration/ci-shell-coverage/RUN_ID_0/shell-coverage/cov.xml`.
      Acceptance: `ls` lists `run.json` and `run.log`; R2 prints `HEAD` equal to HOLD_HEAD_0 (any other head stops the plan, because the run did not test the held commit). R2's `CONCLUSION` and STEP lines, R3's and R4's count lines, and R5's two lines are recorded verbatim. Expected pre-widening facts, recorded and not stop conditions: R5 prints `MATCHES 0` and `GATE FAIL` (kcov does not yet measure `.codex/`), and R4 prints `C824_OK` of at most 15. R4's `REPO_BASH_LINE` is recorded as BASE_BASH_LINE. When the coverage step did not complete (R4 prints `REPO_BASH_LINE MISSING`, or `shell-coverage/cov.xml` is absent and R5 exits 1), the artifact records `BASE_BASH_LINE: UNAVAILABLE (round 0 <failed step name from R2>)`, `EXIT_CODE: 1`, and `ExpectedExitCode: 1`, and P17-T6 reports the absolute thresholds without a baseline delta. Every `NOT_OK` and `CHECK|` line that reports a failure is recorded as the round-0 pre-existing set, with the `DIAG|` lines R4 prints for it. Otherwise R5 is last and exits 0, so `EXIT_CODE: 0`.
- [x] [P13-T2] Update `.claude/rules/shell.md` with replacements J1 and J2 of Appendix J (Edit tool; operator-approved edit of this policy file, Scope-widening addendum).
      Commands: `grep -c -F "all five discovery roots" .claude/rules/shell.md`; `grep -c -F ".codex/codex-web-setup.sh" .claude/rules/shell.md`; `grep -c -F "four discovery roots" .claude/rules/shell.md`.
      Acceptance: the greps print 1, 1, and 0. The last grep prints 0, so `EXIT_CODE: 1` with `ExpectedExitCode: 1`.
- [x] [P13-T3] Update `extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md` by byte copy from `.claude/rules/shell.md`.
      Commands: `cp .claude/rules/shell.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md`; `git diff --no-index --exit-code .claude/rules/shell.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md`; `git status --porcelain -- .claude/rules/shell.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md`.
      Acceptance: `cp` exits 0; the diff exits 0 with no output; the status listing is exactly ` M .claude/rules/shell.md` and ` M extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md`. `EXIT_CODE: 0`.
- [x] [P13-T4] Update `scripts/bash/shell_qc_lib.sh` with replacements J3, J4, and J5 of Appendix J (discovery comment, discovery roots, kcov include pattern and its comment; Edit tool; tab indentation kept).
      Commands: `grep -c -F "for root in tools scripts .claude/lib/bash .claude/skills .codex; do" scripts/bash/shell_qc_lib.sh`; `grep -c -F ',$repo_root/.codex"' scripts/bash/shell_qc_lib.sh`; `grep -c -F "and .codex/ relative to the current dir." scripts/bash/shell_qc_lib.sh`; `grep -c -F "for root in tools scripts .claude/lib/bash .claude/skills; do" scripts/bash/shell_qc_lib.sh`; `grep -c "^ " scripts/bash/shell_qc_lib.sh`; `wc -l scripts/bash/shell_qc_lib.sh`.
      Acceptance: the greps print 1, 1, 1, 0, and 0 (no line begins with a space, so the edits kept tab indentation); `wc` prints 394 (each replacement keeps its line count) and is last, so `EXIT_CODE: 0`.
- [x] [P13-T5] Create `tests/fixtures/shell_qc/.codex/codex_entry.sh` with exactly the content J6 of Appendix J (Write tool, LF line endings).
      Commands: `grep -c -F "codex script fixture" tests/fixtures/shell_qc/.codex/codex_entry.sh`; `git check-ignore -q tests/fixtures/shell_qc/.codex/codex_entry.sh`; `git status --porcelain --untracked-files=all -- tests/fixtures/shell_qc`.
      Acceptance: the grep prints 1; `git check-ignore -q` exits 1 (the path is not ignored); the status listing is exactly `?? tests/fixtures/shell_qc/.codex/codex_entry.sh`. `EXIT_CODE: 0`.
- [x] [P13-T6] Update `tests/shell/test_shell_qc_discovery.bats` with replacements J7 (new `.codex` root test) and J8 (sorted list of 8 entries) of Appendix J.
      Commands: `grep -c "^@test" tests/shell/test_shell_qc_discovery.bats`; `grep -c -F "discover_shell_scripts finds a .sh file under the .codex root" tests/shell/test_shell_qc_discovery.bats`; `grep -c -F ".codex/codex_entry.sh" tests/shell/test_shell_qc_discovery.bats`; `grep -c -F -e "-eq 8 ]" tests/shell/test_shell_qc_discovery.bats`; `grep -c -F -e "-eq 7 ]" tests/shell/test_shell_qc_discovery.bats`; `wc -l tests/shell/test_shell_qc_discovery.bats`.
      Acceptance: the greps print 14, 1, 2, 1, and 0; `wc` prints 107 (99 + 6 from J7 + 2 from J8) and is last, so `EXIT_CODE: 0`.
- [x] [P13-T7] Update `tests/shell/test_shell_qc_commands.bats` with replacements J9 (eight shellcheck calls over the fixture tree) and J10 (include-pattern assertion for `.codex`) of Appendix J.
      Commands: `grep -c -F '[ "$shellcheck_calls" -eq 8 ]' tests/shell/test_shell_qc_commands.bats`; `grep -c -F '"/.codex --exclude-pattern="' tests/shell/test_shell_qc_commands.bats`; `grep -c -F '[ "$shellcheck_calls" -eq 7 ]' tests/shell/test_shell_qc_commands.bats`; `wc -l tests/shell/test_shell_qc_commands.bats`.
      Acceptance: the greps print 1, 1, and 0; `wc` prints 204 and is last, so `EXIT_CODE: 0`.
- [x] [P13-T8] Run the Claude bundle-parity suites that read the bundled `shell.md`, and record FEATURE/evidence/qa-gates/claude-bundle-parity-widening.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`.
      Acceptance: no failed test other than a KL-510 failure (classified by the KL-510 rule in Terms); with no KL-510 failure the run exits 0, and with one it exits 1 and the artifact records `KL-510: STATE-ONLY` and `ExpectedExitCode: 1`. Any other failure is fixed by correcting the Phase 13 edit and re-running P13-T3 and this task.
- [x] [P13-T9] Commit and push Phase 13, and record FEATURE/evidence/other/commit-p13.TS.md.
      Commands: `git add -- .claude/rules/shell.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md scripts/bash/shell_qc_lib.sh tests/fixtures/shell_qc/.codex/codex_entry.sh tests/shell/test_shell_qc_discovery.bats tests/shell/test_shell_qc_commands.bats docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/plan.2026-10-08T22-16.md` followed by the full path of the P12-T6 and P12-T7 artifacts and of each artifact P13-T1 to P13-T8 wrote, named individually; `git commit -m "feat(824): bring .codex into shell-qc discovery and the kcov include roots" -m "Refs #824"`; `git push origin bug/issue-823-tier-rule-adoption-follow-ups-824`; `git status --porcelain --untracked-files=all`; `git fetch origin bug/issue-823-tier-rule-adoption-follow-ups-824`; `git rev-parse HEAD origin/bug/issue-823-tier-rule-adoption-follow-ups-824`.
      Acceptance: as P12-T6. This artifact is committed by P14-T5.

### Phase 14 — shfmt Layout for `.codex/codex-web-setup.sh` and Bundle Parity

Each edit task writes FEATURE/evidence/other/p14-tN.TS.md unless it names another artifact.

- [x] [P14-T1] Update `.codex/codex-web-setup.sh` to the shfmt default layout with writer W1 of Appendix P (each leading two-space group becomes one tab; the `pwsh -Command` string content after the line ending in `"& {` through the line beginning `}"` is left byte-for-byte; PD14).
      Commands: `grep -c "^  " .codex/codex-web-setup.sh`; writer W1 of Appendix P; `grep -c "^ " .codex/codex-web-setup.sh`; `wc -l .codex/codex-web-setup.sh`; `tail -n 1 .codex/codex-web-setup.sh`.
      Acceptance: the first grep prints 254; W1 exits 0 and prints exactly `BLOCK_START_CANDIDATES 1 KEPT_BLOCK_LINES 10 CHANGED_LINES 245 SPACE_LEADING_AFTER 9 CR_BYTES 0` (this is the observation that separates a converting run from a no-op; when the task is re-run after a completed conversion, the first grep prints 9 and W1 prints `CHANGED_LINES 0` with the other four values unchanged, which is accepted); the second grep prints 9 (the nine string-content lines); `wc` prints 413; `tail` prints `if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi` (the guard C824-1 pins is unchanged). `EXIT_CODE: 0`.
- [x] [P14-T2] Update `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh` by byte copy from `.codex/codex-web-setup.sh`.
      Commands: `cp .codex/codex-web-setup.sh extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh`; `git diff --no-index --exit-code .codex/codex-web-setup.sh extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh`; `git status --porcelain -- .codex/codex-web-setup.sh extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh`.
      Acceptance: `cp` exits 0; the diff exits 0 with no output; the status listing is exactly ` M .codex/codex-web-setup.sh` and ` M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh`. `EXIT_CODE: 0`.
- [x] [P14-T3] Verify that the layout change is whitespace-only (PD15) and re-verify the AC-14 `vswhere` condition under whitespace-insensitive comparison (PD16), and record FEATURE/evidence/qa-gates/codex-setup-behavior-check.TS.md.
      Commands (substitute WIDEN_BASE, and BASE_SHA from the P0-T3 artifact): `git diff -w --exit-code WIDEN_BASE -- .codex/codex-web-setup.sh`; `git diff --stat --minimal WIDEN_BASE -- .codex/codex-web-setup.sh`; `git status --porcelain -- .codex/codex-web-setup.sh`; `git diff -w --unified=0 --no-color --output=artifacts/orchestration/codex-setup-widening-w.diff BASE_SHA -- .codex/codex-web-setup.sh`; `grep -c -e "^+.*list_root_solution_files" artifacts/orchestration/codex-setup-widening-w.diff`; `grep -c -e "^[-+].*vswhere" artifacts/orchestration/codex-setup-widening-w.diff`.
      Acceptance: the first diff exits 0 with no output (no non-whitespace change since WIDEN_BASE); `--stat --minimal` prints a summary line `1 file changed, 245 insertions(+), 245 deletions(-)` (non-vacuous: the file did change) (the default diff algorithm prints 275 and 275 for this change, so `--minimal` is required); the status line is ` M .codex/codex-web-setup.sh`; the BASE_SHA diff exits 0; the `list_root_solution_files` grep prints 3 (the added definition and two calls, which proves the BASE_SHA diff carries the #824 change); the `vswhere` grep prints 0, so `EXIT_CODE: 1` with `ExpectedExitCode: 1`.
- [x] [P14-T4] Run the Codex bundle-parity node and the follow-ups module, and record FEATURE/evidence/qa-gates/codex-bundle-parity-widening.TS.md.
      Command: `poetry run pytest "tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts" tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
      Acceptance: exit 0 and a summary reporting 44 passed (1 parity node and the 43 follow-ups cases P8-T1 recorded) and no failed test. A failure is fixed by correcting `.codex/codex-web-setup.sh` and re-running P14-T2 and this task.
- [x] [P14-T5] Commit and push Phase 14, and record FEATURE/evidence/other/commit-p14.TS.md.
      Commands: `git add -- .codex/codex-web-setup.sh extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/plan.2026-10-08T22-16.md` followed by the full path of the P13-T9 artifact and of each artifact P14-T1 to P14-T4 wrote, named individually; `git commit -m "style(824): apply the shfmt default layout to .codex/codex-web-setup.sh" -m "Refs #824"`; `git push origin bug/issue-823-tier-rule-adoption-follow-ups-824`; `git status --porcelain --untracked-files=all`; `git fetch origin bug/issue-823-tier-rule-adoption-follow-ups-824`; `git rev-parse HEAD origin/bug/issue-823-tier-rule-adoption-follow-ups-824`.
      Acceptance: as P12-T6. This artifact is committed by P15-T8.

### Phase 15 — Bats Coverage Suites and Fixtures for `.codex/codex-web-setup.sh`

Each task writes FEATURE/evidence/other/p15-tN.TS.md unless it names another artifact. Every file is written with the Write tool, with exactly the appendix content and LF line endings. None of these suites is run locally (OPS-1); they first run in the Phase 16 CI round.

- [x] [P15-T1] Create the three fixture files of item K1 of Appendix K under `tests/fixtures/codex_web_setup/dotnet-repo/` (`global.json`, `dotnet-tools.json`, `coverage.config`).
      Commands: `grep -c -F "8.0.100" tests/fixtures/codex_web_setup/dotnet-repo/global.json`; `poetry run python -c "import json; [json.load(open(p, encoding='utf-8')) for p in ('tests/fixtures/codex_web_setup/dotnet-repo/global.json', 'tests/fixtures/codex_web_setup/dotnet-repo/dotnet-tools.json')]; print('JSON_OK', 2)"`; `ls tests/fixtures/codex_web_setup/dotnet-repo`.
      Acceptance: the grep prints 1; the JSON check exits 0 and prints `JSON_OK 2`; `ls` lists exactly `coverage.config`, `dotnet-tools.json`, and `global.json`. `EXIT_CODE: 0`.
- [x] [P15-T2] Create the three fixture files of item K2 of Appendix K under `tests/fixtures/codex_web_setup/dotnet-sdk-installed/` (`global.json`, `.dotnet-sdk/dotnet/placeholder.txt`, `.dotnet-sdk/sdk/8.0.100/placeholder.txt`).
      Commands: `grep -c -F "8.0.100" tests/fixtures/codex_web_setup/dotnet-sdk-installed/global.json`; `ls tests/fixtures/codex_web_setup/dotnet-sdk-installed/.dotnet-sdk`; `ls tests/fixtures/codex_web_setup/dotnet-sdk-installed/.dotnet-sdk/dotnet tests/fixtures/codex_web_setup/dotnet-sdk-installed/.dotnet-sdk/sdk/8.0.100`.
      Acceptance: the grep prints 1; the first `ls` lists exactly `dotnet` and `sdk`; the second lists `placeholder.txt` under each of the two directories. `EXIT_CODE: 0`.
- [x] [P15-T3] Create `tests/fixtures/codex_web_setup/bashrc-with-ci.txt` with exactly the content of item K3 of Appendix K.
      Commands: `grep -c -x -F "export CI=true" tests/fixtures/codex_web_setup/bashrc-with-ci.txt`; `wc -l tests/fixtures/codex_web_setup/bashrc-with-ci.txt`.
      Acceptance: the grep prints 1; `wc` prints 1. `EXIT_CODE: 0`.
- [x] [P15-T4] Create `tests/shell/test_codex_web_setup_codex_installers.bats` with exactly the content of Appendix L (C824-16 to C824-33).
      Commands: `grep -c "^@test" tests/shell/test_codex_web_setup_codex_installers.bats`; `grep -c -E "^@test \"C824-(1[6-9]|2[0-9]|3[0-3]) " tests/shell/test_codex_web_setup_codex_installers.bats`; `wc -l tests/shell/test_codex_web_setup_codex_installers.bats`.
      Acceptance: the greps print 18 and 18; the line count is at most 500. `EXIT_CODE: 0`.
- [x] [P15-T5] Create `tests/shell/test_codex_web_setup_codex_dotnet.bats` with exactly the content of Appendix M (C824-34 to C824-47).
      Commands: `grep -c "^@test" tests/shell/test_codex_web_setup_codex_dotnet.bats`; `grep -c -E "^@test \"C824-(3[4-9]|4[0-7]) " tests/shell/test_codex_web_setup_codex_dotnet.bats`; `wc -l tests/shell/test_codex_web_setup_codex_dotnet.bats`.
      Acceptance: the greps print 14 and 14; the line count is at most 500. `EXIT_CODE: 0`.
- [x] [P15-T6] Create `tests/shell/test_codex_web_setup_codex_verify.bats` with exactly the content of Appendix N (C824-48 to C824-61).
      Commands: `grep -c "^@test" tests/shell/test_codex_web_setup_codex_verify.bats`; `grep -c -E "^@test \"C824-(4[89]|5[0-9]|6[01]) " tests/shell/test_codex_web_setup_codex_verify.bats`; `wc -l tests/shell/test_codex_web_setup_codex_verify.bats`.
      Acceptance: the greps print 14 and 14; the line count is at most 500. `EXIT_CODE: 0`.
- [x] [P15-T7] Static checks of BATS-NEW and the seven new fixtures (no temporary-directory use, LF only, not ignored, all untracked-new), and record FEATURE/evidence/qa-gates/bats-suites-static.TS.md.
      Commands: `grep -c -E "BATS_TEST_TMPDIR|BATS_TMPDIR|BATS_FILE_TMPDIR|BATS_RUN_TMPDIR" tests/shell/test_codex_web_setup_codex_installers.bats tests/shell/test_codex_web_setup_codex_dotnet.bats tests/shell/test_codex_web_setup_codex_verify.bats`; reader R6 of Appendix P; `git check-ignore -v tests/shell/test_codex_web_setup_codex_installers.bats tests/shell/test_codex_web_setup_codex_dotnet.bats tests/shell/test_codex_web_setup_codex_verify.bats tests/fixtures/codex_web_setup/dotnet-repo/global.json tests/fixtures/codex_web_setup/dotnet-repo/dotnet-tools.json tests/fixtures/codex_web_setup/dotnet-repo/coverage.config tests/fixtures/codex_web_setup/dotnet-sdk-installed/global.json tests/fixtures/codex_web_setup/dotnet-sdk-installed/.dotnet-sdk/dotnet/placeholder.txt tests/fixtures/codex_web_setup/dotnet-sdk-installed/.dotnet-sdk/sdk/8.0.100/placeholder.txt tests/fixtures/codex_web_setup/bashrc-with-ci.txt`; `git status --porcelain --untracked-files=all -- tests/shell tests/fixtures/codex_web_setup`.
      Acceptance: the grep prints `:0` for each of the three suites; R6 exits 0 and prints `CHECKED 10 CR_FILES 0 []`; `git check-ignore -v` exits 1 with no output (no path is ignored); the status listing is exactly ten `??` lines, one for each of the three suites and the seven fixtures named above. `EXIT_CODE: 0`.
- [ ] [P15-T8] Commit and push Phase 15, and record FEATURE/evidence/other/commit-p15.TS.md.
      Commands: `git add -- tests/shell/test_codex_web_setup_codex_installers.bats tests/shell/test_codex_web_setup_codex_dotnet.bats tests/shell/test_codex_web_setup_codex_verify.bats tests/fixtures/codex_web_setup/dotnet-repo/global.json tests/fixtures/codex_web_setup/dotnet-repo/dotnet-tools.json tests/fixtures/codex_web_setup/dotnet-repo/coverage.config tests/fixtures/codex_web_setup/dotnet-sdk-installed/global.json tests/fixtures/codex_web_setup/dotnet-sdk-installed/.dotnet-sdk/dotnet/placeholder.txt tests/fixtures/codex_web_setup/dotnet-sdk-installed/.dotnet-sdk/sdk/8.0.100/placeholder.txt tests/fixtures/codex_web_setup/bashrc-with-ci.txt docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/plan.2026-10-08T22-16.md` followed by the full path of the P14-T5 artifact and of each artifact P15-T1 to P15-T7 wrote, named individually; `git commit -m "test(824): add bats coverage suites and fixtures for .codex/codex-web-setup.sh" -m "Refs #824"`; `git push origin bug/issue-823-tier-rule-adoption-follow-ups-824`; `git status --porcelain --untracked-files=all`; `git fetch origin bug/issue-823-tier-rule-adoption-follow-ups-824`; `git rev-parse HEAD origin/bug/issue-823-tier-rule-adoption-follow-ups-824`.
      Acceptance: as P12-T6. This artifact is committed by P16-T7.

### Phase 16 — CI Shell Round (Hold, Readout, Remediation Until Clean)

Round rule: the first round of this phase is round 1. Every round runs P16-T1 through P16-T6 and writes its artifacts with the round number n in the file name. A round fails when any of P16-T2 to P16-T5 fails its acceptance. After a failed round, apply the remediation rule below, then commit and push the remediation (`git add --` followed by each remediated W-SET path, the plan, and each artifact of the round, named individually; `git commit -m "fix(824): CI shell round n remediation" -m "Refs #824"` with n substituted; `git push origin bug/issue-823-tier-rule-adoption-follow-ups-824`), increase n by 1, and restart at P16-T1. P16-T1 to P16-T6 are checked off as each completes within a round (P16-T1 before the executor stops at the hold); after a failed round the executor clears those six checkboxes before restarting at P16-T1, so at the end they reflect the passing round only. After three failed rounds, stop and report the ledger to the orchestrator instead of starting a fourth. P16-T7 runs once, after a round whose verdict is PASS.

Remediation rule (every fix is recorded in the round ledger with path, line, failure kind, the removed count r and added count a (the lines this fix removes and adds that still differ when whitespace is ignored, counting only lines with non-whitespace content), change class (`non-whitespace` when r + a is above 0, otherwise `whitespace-only`), and reason; only W-SET paths may change):
1. shfmt difference (R3 `SHFMT_DIFF_FILES` above 0): apply the diff hunks R3 printed under `CHECK|` for the named file verbatim with the Edit tool; when the file is `.codex/codex-web-setup.sh`, re-run the P14-T2 commands. A hunk that touches the guard line pinned by C824-1, or a line inside the `pwsh -Command` string, stops the plan for a report.
2. shellcheck finding (R3 `SHELLCHECK_FINDINGS` above 0): rewrite the cited line so the finding no longer applies without changing behavior; when no behavior-preserving rewrite exists, add `# shellcheck disable=SCxxxx  # <reason>` on the line directly above, with the code and a reason substituted. Re-copy the bundle as in item 1. A finding in a file outside W-SET stops the plan for a report.
3. `not ok` in a BATS-NEW case: correct that case's stubs or assertions so they match the unchanged production behavior shown in the failure output. Never delete a case, never add `skip`, and never reduce a case to a status-only check. A `not ok` in C824-1 to C824-15, in `tests/shell/test_shell_qc_discovery.bats` or `tests/shell/test_shell_qc_commands.bats` that the Phase 13 edits do not explain, or in any other suite, stops the plan for a report. The failure output is the `NOT_OK|` and `DIAG|` lines R4 prints for that round.
4. Coverage below the gate (R5 `MATCHES 1` and `GATE FAIL`): add cases to the BATS-NEW suite that owns the functions holding the `UNCOVERED` line numbers, numbered from the next free C824 number, each suite staying at or below 500 lines. When every remaining uncovered line lies inside the `pwsh -Command` string (the lines after the line ending in `"& {` through the line beginning `}"` in the file at HOLD_HEAD_n; WIDEN_BASE lines 317-326 when no line was inserted above them), stop and report, because AC-14 forbids changing that block. Each added case is named `C824-<n> <description>` with n consecutive from 62. The P16-T6 ledger records the cumulative number added as ADDED_CASES (0 when none).
5. `MATCHES 0` with a successful coverage step, a missing `shell-coverage/cov.xml` after a successful upload step, or a failed step other than the check, test, and upload steps (tool installation or the kcov build); or `REPO_BASH_LINE` below 85.0 while R5 prints `GATE PASS` and R4 prints `NOT_OK 0`: stop and report; these are not fixable inside W-SET.

- [ ] [P16-T1] [CI-HOLD] Round n: record HOLD_HEAD_n in FEATURE/evidence/other/ci-hold-round<n>.TS.md (n substituted), then stop and report the line `CI-HOLD: ROUND <n> HEAD <HOLD_HEAD_n>` to the orchestrator.
      Commands: `git status --porcelain --untracked-files=all -- . ':!docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824'`; `git rev-parse HEAD`; `git fetch origin bug/issue-823-tier-rule-adoption-follow-ups-824`; `git rev-parse origin/bug/issue-823-tier-rule-adoption-follow-ups-824`.
      Acceptance: the status command prints nothing (every W-SET change is committed and pushed); the two SHAs are equal and are recorded as HOLD_HEAD_n; the artifact records `HOLD: round n`, HOLD_HEAD_n, and `RESUME-CONDITION: orchestrator completes Appendix P steps O1-O8 for HOLD_HEAD_n and resumes the executor with CI-RESUME: ROUND n RUN_ID <id>`. The executor then stops and performs no further task until it is resumed. `EXIT_CODE: 0`.
- [ ] [P16-T2] Read the run summary of round n and record FEATURE/evidence/qa-gates/ci-run-round<n>.TS.md.
      Command (substitute RUN_ID_n): reader R2 of Appendix P on `artifacts/orchestration/ci-shell-coverage/RUN_ID_n/run.json`.
      Acceptance: R2 exits 0; `HEAD` equals HOLD_HEAD_n; `CONCLUSION success`; the STEP lines for `Run shell-qc check (shfmt diff + shellcheck)`, `Run shell-qc test with coverage`, and `Upload shell coverage artifacts` each end in `| success`. Every STEP line is recorded verbatim.
- [ ] [P16-T3] Read the `shell-qc check` step output of round n (shfmt diff and shellcheck over the widened discovery set, which now includes `.codex/codex-web-setup.sh`), and record FEATURE/evidence/qa-gates/ci-shell-qc-check-round<n>.TS.md.
      Command (substitute RUN_ID_n): reader R3 of Appendix P on `artifacts/orchestration/ci-shell-coverage/RUN_ID_n/run.log`.
      Acceptance: R3 exits 0 and its first line reports `CHECK_LINES` above 0 (the step is present in the log) with `SHELLCHECK_FINDINGS 0 SHFMT_DIFF_FILES 0`. The `CHECK|` lines are recorded only when a count is above 0.
- [ ] [P16-T4] Read the bats results and the repo-wide Bash coverage line of round n, and record FEATURE/evidence/qa-gates/ci-bats-round<n>.TS.md.
      Command (substitute RUN_ID_n): reader R4 of Appendix P on `artifacts/orchestration/ci-shell-coverage/RUN_ID_n/run.log`.
      Acceptance: R4 exits 0 and prints `NOT_OK 0`; `C824_OK` and `C824_MAX` both equal 61 plus the ledgered ADDED_CASES (every C824 case, including C824-1 to C824-15, is `ok`); and an `OK` count above that value, and a numeric `REPO_BASH_LINE` of at least 85.0, recorded as FINAL_BASH_LINE. `DIAG|` lines are recorded verbatim when `NOT_OK` is above 0.
- [ ] [P16-T5] Read the kcov Cobertura report of round n for `.codex/codex-web-setup.sh` against the 0.85 line-rate threshold, and record FEATURE/evidence/qa-gates/ci-kcov-codex-setup-round<n>.TS.md.
      Command (substitute RUN_ID_n): reader R5 of Appendix P on `artifacts/orchestration/ci-shell-coverage/RUN_ID_n/shell-coverage/cov.xml`.
      Acceptance: R5 exits 0; its first line reports `MATCHES 1`, a `CLASS_LINE_RATE` of at least 0.85, and `GATE PASS`; the `PCT` value is recorded as FINAL_CODEX_SETUP_PCT, `CLASS_LINE_RATE` as FINAL_CODEX_SETUP_RATE, and `ROOT_LINE_RATE` alongside FINAL_BASH_LINE (the two describe the same merged report). The `UNCOVERED` line is recorded verbatim.
- [ ] [P16-T6] Update the round ledger FEATURE/evidence/qa-gates/ci-shell-rounds.TS.md (created in round 1 and extended in each later round; this is the only Phase 16 artifact that is not written anew per round).
      Command: none (record `Command: none - ledger of CI shell rounds` and `EXIT_CODE: 0`).
      Acceptance: the ledger has one entry per round with n, RUN_ID_n, HOLD_HEAD_n, PASS or FAIL for each of P16-T2 to P16-T5 with its artifact path, every remediation applied (path, line, failure kind, r, a, change class, reason), the cumulative ADDED_CASES value (0 when none), and `ROUND VERDICT: PASS` or `ROUND VERDICT: FAIL`. The last entry reads `ROUND VERDICT: PASS`, and no more than three rounds are listed.
- [ ] [P16-T7] Commit and push the Phase 16 evidence, and record FEATURE/evidence/other/commit-p16.TS.md.
      Commands: `git add -- docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/plan.2026-10-08T22-16.md` followed by the full path of the P15-T8 artifact and of every Phase 16 artifact not yet committed, named individually; `git commit -m "docs(824): record CI shell round evidence" -m "Refs #824"`; `git push origin bug/issue-823-tier-rule-adoption-follow-ups-824`; `git status --porcelain --untracked-files=all`; `git fetch origin bug/issue-823-tier-rule-adoption-follow-ups-824`; `git rev-parse HEAD origin/bug/issue-823-tier-rule-adoption-follow-ups-824`.
      Acceptance: as P12-T6. This artifact is committed by P17-T15.

### Phase 17 — Final Widening Verification, PR-Body Callouts, and AC Check-Off

Check-off tasks P17-T8 to P17-T12 each change one line of `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md` from `- [ ] AC-n:` to `- [x] AC-n:` (nothing else), only when every named verifying task is checked and its artifact passes, and append one line `AC-n checked: <verifying artifact paths>` to FEATURE/evidence/other/ac-checkoff-widening.TS.md (created by P17-T8). Acceptance for each: `grep -c -F "[x] AC-n:" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md` prints 1 after the edit (n substituted; the trailing colon keeps AC-1 from matching AC-16 through AC-19), and the artifact line names every verifying artifact. An AC whose verification failed stays unchecked and the gap is recorded in the same artifact.

- [ ] [P17-T1] Run PARITY-SET and the follow-ups module on the final tree, and record FEATURE/evidence/qa-gates/parity-set-widening.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
      Acceptance: no failed test other than KL-510; with no KL-510 failure the run exits 0, and with one it exits 1 and the artifact records `KL-510: STATE-ONLY` and `ExpectedExitCode: 1`. The summary line is recorded.
- [ ] [P17-T2] Full pytest run on the final tree, run in the background, and record FEATURE/evidence/qa-gates/widening-pytest-full.TS.md.
      Command: `poetry run pytest`.
      Acceptance: every failing test is in WIDEN_PY_FAILED or is KL-510, and none is in PARITY-SET (apart from KL-510) or in `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; the passed count is at least WIDEN_PY_PASSED. With no failure in P12-T5 this is exit 0. The summary line and every `FAILED` line are recorded.
- [ ] [P17-T3] Verify byte identity of the two widened bundle pairs and that `.codex/codex-web-setup.sh` differs from WIDEN_BASE only by whitespace and any ledgered `non-whitespace` shellcheck remediation, and record FEATURE/evidence/qa-gates/widening-mirror-identity.TS.md.
      Commands (substitute WIDEN_BASE): `git diff --no-index --exit-code .claude/rules/shell.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md`; `git diff --no-index --exit-code .codex/codex-web-setup.sh extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh`; `git diff -w --minimal --unified=0 --no-color --output=artifacts/orchestration/codex-setup-final-w.diff WIDEN_BASE -- .codex/codex-web-setup.sh`; `git status --porcelain -- .codex/codex-web-setup.sh`; `grep -c -e "^+.*shellcheck disable=" artifacts/orchestration/codex-setup-final-w.diff`; `grep -c -e "^[-+][^-+]" artifacts/orchestration/codex-setup-final-w.diff`.
      Acceptance: both identity diffs exit 0 with no output; the `-w` diff exits 0; the status command prints nothing (the change is committed, and the diff is anchored to WIDEN_BASE, so it carries the change in that state); the directive grep prints the number of `shellcheck disable` directives the P16-T6 ledger records for this file (0 when none); the changed-line grep prints exactly the sum of r + a over the ledger entries for this file (0 when none). `whitespace-only` entries are excluded because `-w` hides them, and each printed line is matched to its ledger entry in the artifact. When the changed-line grep prints 0 it exits 1, so `EXIT_CODE: 1` with `ExpectedExitCode: 1`; otherwise `EXIT_CODE: 0`. A changed line that the ledger does not record is a behavior change and blocks AC-18.
- [ ] [P17-T4] Verify the 500-line limit for every shell and bats file the widening wrote or depends on, and record FEATURE/evidence/qa-gates/widening-line-counts.TS.md.
      Command: `wc -l .codex/codex-web-setup.sh extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh scripts/bash/shell_qc_lib.sh tests/fixtures/shell_qc/.codex/codex_entry.sh tests/shell/test_shell_qc_discovery.bats tests/shell/test_shell_qc_commands.bats tests/shell/test_codex_web_setup_codex_copy.bats tests/shell/test_codex_web_setup_codex_installers.bats tests/shell/test_codex_web_setup_codex_dotnet.bats tests/shell/test_codex_web_setup_codex_verify.bats`.
      Acceptance: exit 0 and every per-file count is at most 500.
- [ ] [P17-T5] Verify the widening write set and the remaining hard exclusions against WIDEN_BASE, and record FEATURE/evidence/qa-gates/widening-scope-check.TS.md.
      Commands (substitute WIDEN_BASE): `git diff --name-only WIDEN_BASE -- . ':!docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824'`; `git status --porcelain --untracked-files=all -- . ':!docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824'`; `git diff --name-only WIDEN_BASE -- docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824`; `git status --porcelain --untracked-files=all -- docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824`; `git diff --name-only WIDEN_BASE -- .github .claude/hooks .codex/hooks .codex/agents scripts/dev-tools tests/scripts`; `git branch --show-current`.
      Acceptance: the union of the paths printed by the first two commands is exactly the 18 W-SET paths; the union of the third and fourth contains only `spec.md`, `plan.2026-10-08T22-16.md`, and paths under FEATURE `evidence/`; the fifth prints nothing; the branch is `bug/issue-823-tier-rule-adoption-follow-ups-824`. Any other path stops the plan for a report. `EXIT_CODE: 0`.
- [ ] [P17-T6] Write the Bash coverage comparison FEATURE/evidence/qa-gates/bash-coverage-comparison.TS.md (inputs: P13-T1 and the passing round's P16-T4 and P16-T5 artifacts).
      Command: none (record `Command: none - comparison of recorded values` and `EXIT_CODE: 0`).
      Acceptance: the artifact lists BASE_BASH_LINE (or its UNAVAILABLE literal), FINAL_BASH_LINE, and their delta; `.codex/codex-web-setup.sh` baseline `NOT MEASURED (round 0 MATCHES 0)` and post-change FINAL_CODEX_SETUP_PCT with FINAL_CODEX_SETUP_RATE; `New/changed-code coverage: .codex/codex-web-setup.sh <FINAL_CODEX_SETUP_PCT> (the shfmt layout changed every indented line, so the whole-file value is the changed-line value)`; and `Branch coverage: N/A - kcov measures no bash branch coverage; no bash branch gate applies`. The verdict is `PASS` when FINAL_CODEX_SETUP_RATE is at least 0.85 and FINAL_BASH_LINE is at least 85.0, otherwise `REMEDIATION-REQUIRED`. The repo-wide delta is reported and not gated, because bringing a newly measured file into the denominator changes the population; the uniform 85% threshold is the gate.
- [ ] [P17-T7] Write the PR-body callout addendum FEATURE/evidence/other/pr-body-callouts-widening.TS.md with the content of Appendix O (AC-15 requires the PR body to call out every `.claude/rules/` edit, which now includes `.claude/rules/shell.md`).
      Commands (substitute the artifact's TS): `grep -c -F "Refs #824" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/evidence/other/pr-body-callouts-widening.TS.md`; `grep -c -F ".claude/rules/shell.md" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/evidence/other/pr-body-callouts-widening.TS.md`; `grep -c -F "PA-1" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/evidence/other/pr-body-callouts-widening.TS.md`; `grep -c -i -E "(close[sd]?|fix(e[sd])?|resolve[sd]?) #824" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/evidence/other/pr-body-callouts-widening.TS.md`.
      Acceptance: the first three greps each print 1 or more; the closing-keyword grep prints 0, so `EXIT_CODE: 1` with `ExpectedExitCode: 1`.
- [ ] [P17-T8] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-16. Verifying tasks: P12-T2, P13-T2, P13-T3, P13-T8, P17-T1, P17-T3.
- [ ] [P17-T9] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-17. Verifying tasks: P13-T4, P13-T5, P13-T6, P13-T7, and the passing round's P16-T2, P16-T3, P16-T4 (`NOT_OK 0`, so both shell-qc suites passed in CI), and P16-T5 (`MATCHES 1`, so the widened include pattern took effect).
- [ ] [P17-T10] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-18. Verifying tasks: P14-T1, P14-T2, P14-T3, P14-T4, the passing round's P16-T3 (`SHELLCHECK_FINDINGS 0 SHFMT_DIFF_FILES 0`) and P16-T4 (C824-1 to C824-15 `ok`), and P17-T3.
- [ ] [P17-T11] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-19. Verifying tasks: P15-T1 through P15-T7, the passing round's P16-T4 (`C824_OK` equal to `C824_MAX` and to 61 plus the ledgered ADDED_CASES) and P16-T5 (`GATE PASS`), and P17-T6 (verdict `PASS`).
- [ ] [P17-T12] Update `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: check off AC-6 (PD19). Verifying tasks: P5-T1 through P5-T15 and P8-T1 (already passing), the passing round's P16-T4 (C824-1 to C824-15 `ok` in CI, which replaces the P5-T16 `PENDING-CI` record), and P17-T3.
- [ ] [P17-T13] Record AC-13 as pending PR CI in FEATURE/evidence/other/ac-checkoff-widening.TS.md and leave `- [ ] AC-13:` unchanged in `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md` (PD19).
      Command: `grep -c -F "[ ] AC-13:" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`.
      Acceptance: the grep prints 1, and the artifact line reads `AC-13 pending PR CI: the Python, TypeScript, and PowerShell toolchain on the PR head; the shell portion is supplied by the passing CI shell round` followed by the passing round's P16-T4 artifact path.
- [ ] [P17-T14] Write the AC status summary FEATURE/evidence/other/ac-status-summary-widening.TS.md in the acceptance-criteria-tracking format (Source, Total AC items 19, Checked off, Remaining, Items remaining).
      Commands: `grep -c "^- \[x\] AC-" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`; `grep -c "^- \[ \] AC-" docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`.
      Acceptance: the two counts sum to 19; the summary's Checked off and Remaining values equal them; Items remaining lists AC-13 and AC-15, plus any AC whose verification failed in P17-T8 to P17-T12.
- [ ] [P17-T15] Commit and push Phase 17, and record FEATURE/evidence/other/commit-p17.TS.md.
      Commands: `git add -- docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/plan.2026-10-08T22-16.md` followed by the full path of the P16-T7 artifact and of each artifact P17-T1 to P17-T14 wrote, named individually; `git commit -m "docs(824): record widening verification and acceptance-criteria check-off" -m "Refs #824"`; `git push origin bug/issue-823-tier-rule-adoption-follow-ups-824`; `git status --porcelain --untracked-files=all`; `git fetch origin bug/issue-823-tier-rule-adoption-follow-ups-824`; `git rev-parse HEAD origin/bug/issue-823-tier-rule-adoption-follow-ups-824`.
      Acceptance: as P12-T6. This artifact and the P17-T15 check-off are committed by the orchestrator.

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

## Appendix I — Spec Amendment for the PA-1 Scope Widening (P12-T3, P12-T4)

I1 (P12-T3). Edit `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`. Old text (the end of the AC-15 line, the blank line, and the next heading):

```text
states that FU-823-4 remains open, and lists the out-of-scope follow-ups.

## Files Written by the Implementation
```

New text: the same first line, then four new lines, then the blank line and the heading unchanged. Each of the four new lines consists of the six characters hyphen, space, left bracket, space, right bracket, space (an unchecked Markdown checkbox, as on the AC-1 to AC-15 lines) followed by the text quoted below, in this order:

```text
AC-16: Scope widening (operator decision on PA-1, 2026-10-10) — `.claude/rules/shell.md` and its bundled copy `extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md` name `.codex/` as a shell-qc discovery root and a kcov include root, and the two copies are byte-identical.
AC-17: Scope widening — `scripts/bash/shell_qc_lib.sh` discovers shell scripts under `.codex/` (`discover_shell_scripts`) and passes `.codex` in the kcov include pattern (`run_test_coverage`); `tests/shell/test_shell_qc_discovery.bats` and `tests/shell/test_shell_qc_commands.bats` assert the widened root list and include pattern against the fixture `tests/fixtures/shell_qc/.codex/codex_entry.sh`, and they pass in the CI shell-coverage run.
AC-18: Scope widening — `.codex/codex-web-setup.sh` passes `shell-qc check` (shfmt diff and shellcheck) in the CI shell-coverage run with its behavior unchanged, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh` stays byte-identical to it.
AC-19: Scope widening — kcov measures `.codex/codex-web-setup.sh` in the CI shell-coverage run (`shell-coverage` artifact `cov.xml`) at >= 85% line coverage (Cobertura line-rate >= 0.85; bash has no branch gate), and every bats suite that exercises it (`tests/shell/test_codex_web_setup_codex_*.bats`) passes in that run.
```

I2 (P12-T4). Edit the same file. Old text (the end of the last line of the file, the Links bullet):

```text
prior work branch `origin/wip/preserve-824-addendum2-2026-10-08`.
```

New text: the same line, then one blank line, the heading line `## Change Log`, one blank line, and this single bullet line (one line, not wrapped):

```text
- 2026-10-10: PA-1 scope widening (operator decision). Feature review blocked on PA-1 (`policy-audit.2026-10-10T00-44.md`, `remediation-inputs.2026-10-10T00-44.md`): `.codex/codex-web-setup.sh` gained functions and a source guard in this item, but kcov did not measure `.codex/`. The operator chose to widen #824 scope rather than record a waiver. In scope as of this entry: `.codex/` shell scripts join the shell-qc discovery roots and the kcov include roots (`.claude/rules/shell.md`, its bundled copy, and `scripts/bash/shell_qc_lib.sh`, with `tests/shell/test_shell_qc_discovery.bats`, `tests/shell/test_shell_qc_commands.bats`, and the fixture `tests/fixtures/shell_qc/.codex/codex_entry.sh`); `.codex/codex-web-setup.sh` and its bundled copy are brought into shfmt and shellcheck compliance with behavior unchanged; and kcov measures `.codex/codex-web-setup.sh` at >= 85% line coverage through new bats suites under `tests/shell/` and fixtures under `tests/fixtures/codex_web_setup/`. The operator decision authorizes the edit of `.claude/rules/shell.md` and its bundled copy for this item only. The hard exclusion of "any other shell-coverage workflow work" is narrowed accordingly; `.github/workflows/_shell-coverage.yml`, `scripts/dev-tools/KcovFunctionCoverageGate.ps1` and its tests, and `tests/scripts/workflows/ShellCoverageWorkflow.Tests.ps1` remain excluded. `.github/codex/codex-web-setup.sh` is a separate file and is not changed. The Risks entry and the Rollout follow-up stating that `.codex/` is outside the kcov include roots are superseded. Acceptance criteria AC-16 through AC-19 were added; their bats, shfmt, shellcheck, and kcov evidence comes from the CI shell-coverage workflow.
```

## Appendix J — Shell-QC Scope Edits (P13-T2 to P13-T7)

J1 (`.claude/rules/shell.md`, Discovery Contract). Old text:

```text
- Search roots: `tools/`, `scripts/`, `.claude/lib/bash/`, and `.claude/skills/`, relative to the
  current working directory; a missing root is silently skipped. The `.claude/lib/bash/` root carries
  the destination-portable bash library published by push-down, and the `.claude/skills/` root carries
  scripts bundled inside a skill folder, so those scripts are held to the same format, lint, test, and
  coverage standards as `tools/` and `scripts/`.
```

New text:

```text
- Search roots: `tools/`, `scripts/`, `.claude/lib/bash/`, `.claude/skills/`, and `.codex/`, relative
  to the current working directory; a missing root is silently skipped. The `.claude/lib/bash/` root
  carries the destination-portable bash library published by push-down, the `.claude/skills/` root
  carries scripts bundled inside a skill folder, and the `.codex/` root carries the Codex runtime
  scripts (for example `.codex/codex-web-setup.sh`), so those scripts are held to the same format,
  lint, test, and coverage standards as `tools/` and `scripts/`.
```

J2 (`.claude/rules/shell.md`, Coverage Expectations; the dashes are the existing em dashes). Old text:

```text
- The kcov include pattern covers all four discovery roots — `tools/`, `scripts/`,
  `.claude/lib/bash/`, and `.claude/skills/` — so the Claude bash library and skill-bundled scripts are
  measured, not merely discovered. The `tests/` tree remains excluded.
```

New text:

```text
- The kcov include pattern covers all five discovery roots — `tools/`, `scripts/`,
  `.claude/lib/bash/`, `.claude/skills/`, and `.codex/` — so the Claude bash library, skill-bundled
  scripts, and Codex runtime scripts are measured, not merely discovered. The `tests/` tree remains
  excluded.
```

J3 (`scripts/bash/shell_qc_lib.sh`, lines 76-77; each line begins with one tab character). Old text:

```text
	# Discover shell scripts under tools/, scripts/, .claude/lib/bash/, and
	# .claude/skills/ relative to the current dir.
```

New text:

```text
	# Discover shell scripts under tools/, scripts/, .claude/lib/bash/, .claude/skills/,
	# and .codex/ relative to the current dir.
```

J4 (`scripts/bash/shell_qc_lib.sh`, line 85; one leading tab). Old text:

```text
	for root in tools scripts .claude/lib/bash .claude/skills; do
```

New text:

```text
	for root in tools scripts .claude/lib/bash .claude/skills .codex; do
```

J5 (`scripts/bash/shell_qc_lib.sh`, lines 348-350; each line begins with one tab character). Old text:

```text
	# Scope coverage to repo scripts/tools, the Claude bash library, and scripts bundled
	# inside skill folders; exclude the test sources themselves.
	local include_pattern="$repo_root/tools,$repo_root/scripts,$repo_root/.claude/lib/bash,$repo_root/.claude/skills"
```

New text:

```text
	# Scope coverage to repo scripts/tools, the Claude bash library, scripts bundled inside
	# skill folders, and the Codex runtime scripts; exclude the test sources themselves.
	local include_pattern="$repo_root/tools,$repo_root/scripts,$repo_root/.claude/lib/bash,$repo_root/.claude/skills,$repo_root/.codex"
```

J6 (`tests/fixtures/shell_qc/.codex/codex_entry.sh`, new file; three lines, LF, trailing newline):

```bash
#!/usr/bin/env bash
set -euo pipefail
echo "codex script fixture"
```

J7 (`tests/shell/test_shell_qc_discovery.bats`, insert a test before the node_modules test; four-space indentation). Old text:

```text
@test "discover_shell_scripts prunes the excluded node_modules directory" {
```

New text:

```text
@test "discover_shell_scripts finds a .sh file under the .codex root" {
    run bash -c "cd '${FIXTURE_ROOT}' && source '${LIB}' && discover_shell_scripts"
    [ "$status" -eq 0 ]
    [[ "$output" == *".codex/codex_entry.sh"* ]]
}

@test "discover_shell_scripts prunes the excluded node_modules directory" {
```

J8 (`tests/shell/test_shell_qc_discovery.bats`, sorted-list test, lines 90-98). Old text:

```text
    [ "${#lines[@]}" -eq 7 ]
    # Under LC_ALL=C the two .claude roots sort before scripts/ and tools/ (0x2E < 0x73).
    [ "${lines[0]}" = ".claude/lib/bash/lib_entry.sh" ]
    [ "${lines[1]}" = ".claude/skills/demo-skill/scripts/skill_entry.sh" ]
    [ "${lines[2]}" = "scripts/env_s_bash" ]
    [ "${lines[3]}" = "scripts/sh_shebang" ]
    [ "${lines[4]}" = "scripts/uppercase_bash" ]
    [ "${lines[5]}" = "scripts/with_shebang" ]
    [ "${lines[6]}" = "tools/format_me.sh" ]
```

New text:

```text
    [ "${#lines[@]}" -eq 8 ]
    # Under LC_ALL=C the three dot-prefixed roots sort before scripts/ and tools/ (0x2E < 0x73),
    # and .claude/ sorts before .codex/ (0x6C < 0x6F).
    [ "${lines[0]}" = ".claude/lib/bash/lib_entry.sh" ]
    [ "${lines[1]}" = ".claude/skills/demo-skill/scripts/skill_entry.sh" ]
    [ "${lines[2]}" = ".codex/codex_entry.sh" ]
    [ "${lines[3]}" = "scripts/env_s_bash" ]
    [ "${lines[4]}" = "scripts/sh_shebang" ]
    [ "${lines[5]}" = "scripts/uppercase_bash" ]
    [ "${lines[6]}" = "scripts/with_shebang" ]
    [ "${lines[7]}" = "tools/format_me.sh" ]
```

J9 (`tests/shell/test_shell_qc_commands.bats`, line 81). Old text `    [ "$shellcheck_calls" -eq 7 ]`; new text `    [ "$shellcheck_calls" -eq 8 ]` (the fixture tree now holds eight shell scripts).

J10 (`tests/shell/test_shell_qc_commands.bats`, after line 130). Old text:

```text
    [[ "$output" == *"--include-pattern="*"/.claude/skills"* ]]
```

New text (the old line, then one added line; the kcov stub `tests/fixtures/shell_qc/stub-bin/kcov` echoes its argv on one line, so the `.codex` entry is the last include-pattern element and is followed by the exclude option):

```text
    [[ "$output" == *"--include-pattern="*"/.claude/skills"* ]]
    [[ "$output" == *"/.claude/skills,"*"/.codex --exclude-pattern="* ]]
```

## Appendix K — Fixtures for the `.codex/codex-web-setup.sh` Coverage Suites (P15-T1 to P15-T3)

Every file ends with one LF; no file carries a carriage return.

K1 (`tests/fixtures/codex_web_setup/dotnet-repo/`; a repository root with a pinned SDK, a tool manifest, and `coverage.config`, but no installed SDK):

`global.json`:

```json
{
  "sdk": {
    "version": "8.0.100"
  }
}
```

`dotnet-tools.json`:

```json
{
  "version": 1,
  "isRoot": true,
  "tools": {}
}
```

`coverage.config` (one line):

```text
Fixture: a repository root that carries coverage.config, for tests/shell/test_codex_web_setup_codex_verify.bats (issue #824).
```

K2 (`tests/fixtures/codex_web_setup/dotnet-sdk-installed/`; a repository root whose repo-local SDK 8.0.100 is already present):

`global.json`: the same five lines as K1 `global.json`.

`.dotnet-sdk/dotnet/placeholder.txt` (one line):

```text
Fixture: .dotnet-sdk/dotnet is a directory, so the [ -x ] test in install_dotnet_sdk passes without a checked-in executable (issue #824).
```

`.dotnet-sdk/sdk/8.0.100/placeholder.txt` (one line):

```text
Fixture: the installed SDK 8.0.100 directory for tests/shell/test_codex_web_setup_codex_dotnet.bats (issue #824).
```

K3 (`tests/fixtures/codex_web_setup/bashrc-with-ci.txt`; one line):

```text
export CI=true
```

## Appendix L — `tests/shell/test_codex_web_setup_codex_installers.bats` (P15-T4)

```bash
#!/usr/bin/env bats
# ------------------------------------------------------------------------------
# test_codex_web_setup_codex_installers.bats
#
# Purpose:
#   Cover the installer functions of .codex/codex-web-setup.sh (the Codex copy,
#   not the GitHub Codex copy): install_apt_packages, install_powershell,
#   install_nuget, and install_actionlint, including every skip and failure
#   branch (issue #824, kcov scope widening for PA-1).
#
# Determinism: every external command an installer reaches (apt-get, id, sudo,
# mktemp, curl, dpkg, rm, tar, mono, pwsh, nuget, actionlint) is replaced by a
# shell function that prints its arguments to stderr. A test that needs a tool
# to be absent runs through run_with_stub_path, which limits PATH and HOME to
# this test directory (it holds no executable), so only the functions the test
# defines satisfy `command -v`. Nothing is downloaded or installed and no
# temporary file is created. teardown removes the stubs before bats-core runs
# its own cleanup.
# ------------------------------------------------------------------------------

# Canonical absolute path, so kcov reports the sourced file as <repo>/.codex/codex-web-setup.sh.
SCRIPT_UNDER_TEST="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/.codex/codex-web-setup.sh"

setup() {
    # Sourcing defines the functions without running main (C824-1 pins the guard).
    source "${SCRIPT_UNDER_TEST}"
}

teardown() {
    unset -f actionlint apt-get curl dpkg id mktemp mono nuget pwsh rm sudo tar
}

# Run a command with PATH and HOME limited to this test directory.
run_with_stub_path() {
    local PATH="${BATS_TEST_DIRNAME}"
    local HOME="${BATS_TEST_DIRNAME}"
    "$@"
}

# Print a replaced command's name and arguments to stderr, which run captures.
record() {
    printf '%s\n' "$*" >&2
}

@test "C824-16 install_apt_packages warns and skips when apt-get is unavailable" {
    # Act
    run run_with_stub_path install_apt_packages
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"apt-get is unavailable; skipping OS package installation."* ]]
}

@test "C824-17 install_apt_packages installs directly when running as root" {
    # Arrange
    id() { printf '%s\n' 0; }
    apt-get() { record "apt-get $*"; }
    # Act
    run run_with_stub_path install_apt_packages
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installing Codex Web dependencies with apt-get..."* ]]
    [[ "$output" == *"apt-get update"* ]]
    [[ "$output" == *"apt-get install -y ca-certificates curl git jq lsb-release mono-complete ripgrep unzip zip"* ]]
    [[ "$output" != *"sudo"* ]]
}

@test "C824-18 install_apt_packages runs apt-get through sudo when not root" {
    # Arrange
    id() { printf '%s\n' 1000; }
    sudo() { record "sudo $*"; }
    apt-get() { record "apt-get $*"; }
    # Act
    run run_with_stub_path install_apt_packages
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"sudo apt-get update"* ]]
    [[ "$output" == *"sudo apt-get install -y ca-certificates"* ]]
}

@test "C824-19 install_apt_packages warns and skips when not root and sudo is unavailable" {
    # Arrange
    id() { printf '%s\n' 1000; }
    apt-get() { record "apt-get $*"; }
    # Act
    run run_with_stub_path install_apt_packages
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"apt-get requires root and sudo is unavailable; skipping OS package installation."* ]]
    [[ "$output" != *"apt-get update"* ]]
}

@test "C824-20 install_powershell skips when pwsh is already available" {
    # Arrange
    pwsh() { record "pwsh $*"; }
    # Act
    run install_powershell
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"PowerShell is already available; skipping."* ]]
}

@test "C824-21 install_powershell warns and skips when apt-get is unavailable" {
    # Act
    run run_with_stub_path install_powershell
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"apt-get is unavailable; skipping PowerShell installation."* ]]
}

@test "C824-22 install_powershell warns and skips when not root and sudo is unavailable" {
    # Arrange
    id() { printf '%s\n' 1000; }
    apt-get() { record "apt-get $*"; }
    # Act
    run run_with_stub_path install_powershell
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"PowerShell installation requires root; skipping."* ]]
}

@test "C824-23 install_powershell registers the Microsoft repository and installs through sudo" {
    # Arrange: lsb_release is absent, so the Ubuntu version falls back to 24.04.
    id() { printf '%s\n' 1000; }
    sudo() { record "sudo $*"; }
    apt-get() { record "apt-get $*"; }
    mktemp() { printf '%s\n' /nonexistent/packages-microsoft-prod.deb; }
    curl() { record "curl $*"; }
    rm() { record "rm $*"; }
    # Act
    run run_with_stub_path install_powershell
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Registering Microsoft package repository for PowerShell (Ubuntu 24.04)..."* ]]
    [[ "$output" == *"curl -fsSL https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -o /nonexistent/packages-microsoft-prod.deb"* ]]
    [[ "$output" == *"sudo dpkg -i /nonexistent/packages-microsoft-prod.deb"* ]]
    [[ "$output" == *"rm -f /nonexistent/packages-microsoft-prod.deb"* ]]
    [[ "$output" == *"sudo apt-get install -y powershell"* ]]
}

@test "C824-24 install_powershell warns and skips when the repository package download fails" {
    # Arrange
    id() { printf '%s\n' 0; }
    apt-get() { record "apt-get $*"; }
    mktemp() { printf '%s\n' /nonexistent/packages-microsoft-prod.deb; }
    curl() { return 1; }
    rm() { record "rm $*"; }
    # Act
    run run_with_stub_path install_powershell
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"rm -f /nonexistent/packages-microsoft-prod.deb"* ]]
    [[ "$output" == *"Could not download Microsoft package repo; skipping PowerShell installation."* ]]
    [[ "$output" != *"apt-get install"* ]]
}

@test "C824-25 install_nuget skips when nuget is already available" {
    # Arrange
    nuget() { record "nuget $*"; }
    # Act
    run install_nuget
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"nuget is already available; skipping."* ]]
}

@test "C824-26 install_nuget warns when mono is unavailable" {
    # Act
    run run_with_stub_path install_nuget
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"mono is unavailable; cannot install nuget wrapper."* ]]
}

@test "C824-27 install_nuget writes the mono wrapper through sudo when not root" {
    # Arrange: the sudo stub drains the wrapper text that tee would receive.
    id() { printf '%s\n' 1000; }
    mono() { record "mono $*"; }
    curl() { record "curl $*"; }
    sudo() {
        if [ "${1:-}" = "tee" ]; then
            while IFS= read -r _wrapper_line; do :; done
        fi
        record "sudo $*"
    }
    # Act
    run run_with_stub_path install_nuget
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Downloading nuget.exe and creating mono wrapper..."* ]]
    [[ "$output" == *"curl -fsSL https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -o /usr/local/bin/nuget.exe"* ]]
    [[ "$output" == *"sudo tee /usr/local/bin/nuget"* ]]
    [[ "$output" == *"sudo chmod +x /usr/local/bin/nuget"* ]]
    [[ "$output" == *"nuget wrapper installed at /usr/local/bin/nuget."* ]]
}

@test "C824-28 install_nuget warns when the nuget.exe download fails" {
    # Arrange
    id() { printf '%s\n' 0; }
    mono() { record "mono $*"; }
    curl() { return 1; }
    # Act
    run run_with_stub_path install_nuget
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Could not download nuget.exe; skipping."* ]]
    [[ "$output" != *"nuget wrapper installed"* ]]
}

@test "C824-29 install_actionlint skips when actionlint is already available" {
    # Arrange
    actionlint() { record "actionlint $*"; }
    # Act
    run install_actionlint
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"actionlint is already available; skipping."* ]]
}

@test "C824-30 install_actionlint warns when tar is unavailable" {
    # Act
    run run_with_stub_path install_actionlint
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"tar is unavailable; skipping actionlint installation."* ]]
}

@test "C824-31 install_actionlint warns when not root and sudo is unavailable" {
    # Arrange
    id() { printf '%s\n' 1000; }
    tar() { record "tar $*"; }
    # Act
    run run_with_stub_path install_actionlint
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"actionlint installation requires root or sudo; skipping."* ]]
}

@test "C824-32 install_actionlint installs the pinned release through sudo" {
    # Arrange
    id() { printf '%s\n' 1000; }
    sudo() { record "sudo $*"; }
    tar() { record "tar $*"; }
    mktemp() { printf '%s\n' /nonexistent/actionlint-tmp; }
    curl() { record "curl $*"; }
    rm() { record "rm $*"; }
    # Act
    run run_with_stub_path install_actionlint
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installing actionlint v1.7.7..."* ]]
    [[ "$output" == *"tar -xzf /nonexistent/actionlint-tmp/actionlint.tar.gz -C /nonexistent/actionlint-tmp actionlint"* ]]
    [[ "$output" == *"sudo install -m 0755 /nonexistent/actionlint-tmp/actionlint /usr/local/bin/actionlint"* ]]
    [[ "$output" == *"actionlint installed at /usr/local/bin/actionlint."* ]]
    [[ "$output" == *"rm -rf /nonexistent/actionlint-tmp"* ]]
}

@test "C824-33 install_actionlint warns when the release download fails" {
    # Arrange
    id() { printf '%s\n' 0; }
    tar() { record "tar $*"; }
    mktemp() { printf '%s\n' /nonexistent/actionlint-tmp; }
    curl() { return 1; }
    rm() { record "rm $*"; }
    # Act
    run run_with_stub_path install_actionlint
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Could not download actionlint; skipping."* ]]
    [[ "$output" == *"rm -rf /nonexistent/actionlint-tmp"* ]]
}
```

## Appendix M — `tests/shell/test_codex_web_setup_codex_dotnet.bats` (P15-T5)

```bash
#!/usr/bin/env bats
# ------------------------------------------------------------------------------
# test_codex_web_setup_codex_dotnet.bats
#
# Purpose:
#   Cover the .NET setup functions of .codex/codex-web-setup.sh (the Codex copy,
#   not the GitHub Codex copy): read_global_json_sdk_version, append_if_missing,
#   install_dotnet_sdk, install_dotnet_tools, and install_dotnet_coverage,
#   including every skip and failure branch (issue #824, kcov scope widening for
#   PA-1).
#
# Determinism: repository roots are the committed fixtures under
# tests/fixtures/codex_web_setup/ or this test directory. External commands that
# would download, install, or write (curl, bash, dotnet, dotnet-coverage, mkdir,
# mktemp, rm, touch) are replaced by shell functions that print to stderr, and
# append_if_missing is replaced wherever a caller would write to ~/.bashrc.
# append_if_missing itself is exercised against /dev/null and a fixture that
# already holds the line, so no file changes. No temporary file is created.
# ------------------------------------------------------------------------------

# Canonical absolute path, so kcov reports the sourced file as <repo>/.codex/codex-web-setup.sh.
SCRIPT_UNDER_TEST="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/.codex/codex-web-setup.sh"
FIXTURES="$(cd "${BATS_TEST_DIRNAME}/../fixtures/codex_web_setup" && pwd)"

setup() {
    # Sourcing defines the functions without running main (C824-1 pins the guard).
    source "${SCRIPT_UNDER_TEST}"
}

teardown() {
    unset -f append_if_missing bash curl dotnet dotnet-coverage grep mkdir mktemp rm touch
}

# Run a command with PATH and HOME limited to this test directory.
run_with_stub_path() {
    local PATH="${BATS_TEST_DIRNAME}"
    local HOME="${BATS_TEST_DIRNAME}"
    "$@"
}

# Print a replaced command's name and arguments to stderr, which run captures.
record() {
    printf '%s\n' "$*" >&2
}

@test "C824-34 read_global_json_sdk_version fails when global.json is absent" {
    # Arrange
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    # Act
    run read_global_json_sdk_version
    # Assert
    [ "$status" -eq 1 ]
    [ -z "$output" ]
}

@test "C824-35 read_global_json_sdk_version prints the pinned SDK version" {
    # Arrange
    REPO_ROOT="${FIXTURES}/dotnet-repo"
    # Act
    run read_global_json_sdk_version
    # Assert
    [ "$status" -eq 0 ]
    [ "$output" = "8.0.100" ]
}

@test "C824-36 append_if_missing appends a line the file does not contain" {
    # Arrange: /dev/null never contains the line, so the append branch runs and nothing is kept.
    touch() { record "touch $*"; }
    # Act
    run append_if_missing /dev/null 'export CI=true'
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"touch /dev/null"* ]]
}

@test "C824-37 append_if_missing leaves a file that already contains the line" {
    # Arrange
    touch() { record "touch $*"; }
    # Act
    run append_if_missing "${FIXTURES}/bashrc-with-ci.txt" 'export CI=true'
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"touch ${FIXTURES}/bashrc-with-ci.txt"* ]]
    run grep -c -x 'export CI=true' "${FIXTURES}/bashrc-with-ci.txt"
    [ "$output" = "1" ]
}

@test "C824-38 install_dotnet_sdk warns and skips when global.json names no SDK version" {
    # Arrange
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    append_if_missing() { record "append $*"; }
    # Act
    run install_dotnet_sdk
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Could not read the SDK version from global.json; skipping repo-local .NET SDK installation."* ]]
    [[ "$output" != *"append"* ]]
}

@test "C824-39 install_dotnet_sdk reuses a repo-local SDK that is already installed" {
    # Arrange: the fixture's .dotnet-sdk/dotnet is a directory, which satisfies [ -x ].
    REPO_ROOT="${FIXTURES}/dotnet-sdk-installed"
    append_if_missing() { record "append $*"; }
    # Act
    run install_dotnet_sdk
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Repo-local .NET SDK 8.0.100 is already available at ${FIXTURES}/dotnet-sdk-installed/.dotnet-sdk."* ]]
    [[ "$output" == *"export DOTNET_ROOT=\"${FIXTURES}/dotnet-sdk-installed/.dotnet-sdk\""* ]]
}

@test "C824-40 install_dotnet_sdk downloads and runs the installer when the SDK is missing" {
    # Arrange
    REPO_ROOT="${FIXTURES}/dotnet-repo"
    append_if_missing() { record "append $*"; }
    mktemp() { printf '%s\n' /nonexistent/dotnet-install.sh; }
    curl() { record "curl $*"; }
    bash() { record "bash $*"; }
    rm() { record "rm $*"; }
    # Act
    run install_dotnet_sdk
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installing repo-local .NET SDK 8.0.100 into ${FIXTURES}/dotnet-repo/.dotnet-sdk..."* ]]
    [[ "$output" == *"curl -fsSL https://dot.net/v1/dotnet-install.sh -o /nonexistent/dotnet-install.sh"* ]]
    [[ "$output" == *"bash /nonexistent/dotnet-install.sh --version 8.0.100 --install-dir ${FIXTURES}/dotnet-repo/.dotnet-sdk"* ]]
    [[ "$output" == *"rm -f /nonexistent/dotnet-install.sh"* ]]
    [[ "$output" == *"export PATH=\"${FIXTURES}/dotnet-repo/.dotnet-sdk:\$PATH\""* ]]
}

@test "C824-41 install_dotnet_tools fails when dotnet is unavailable" {
    # Arrange
    REPO_ROOT="${FIXTURES}/dotnet-repo"
    # Act
    run run_with_stub_path install_dotnet_tools
    # Assert
    [ "$status" -eq 1 ]
    [[ "$output" == *"dotnet is unavailable; cannot restore the required dotnet tool manifest."* ]]
}

@test "C824-42 install_dotnet_tools fails when the tool manifest is missing" {
    # Arrange
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    dotnet() { record "dotnet $*"; }
    # Act
    run install_dotnet_tools
    # Assert
    [ "$status" -eq 1 ]
    [[ "$output" == *"Required dotnet tool manifest not found at ${BATS_TEST_DIRNAME}/dotnet-tools.json."* ]]
}

@test "C824-43 install_dotnet_tools restores the repo-local tool manifest" {
    # Arrange
    REPO_ROOT="${FIXTURES}/dotnet-repo"
    dotnet() { record "dotnet $*"; }
    # Act
    run install_dotnet_tools
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Restoring repo-local dotnet tools from dotnet-tools.json..."* ]]
    [[ "$output" == *"dotnet tool restore --tool-manifest ${FIXTURES}/dotnet-repo/dotnet-tools.json"* ]]
}

@test "C824-44 install_dotnet_coverage fails when dotnet is unavailable" {
    # Act
    run run_with_stub_path install_dotnet_coverage
    # Assert
    [ "$status" -eq 1 ]
    [[ "$output" == *"dotnet is unavailable; cannot install dotnet-coverage."* ]]
}

@test "C824-45 install_dotnet_coverage skips when dotnet-coverage is already available" {
    # Arrange
    dotnet() { record "dotnet $*"; }
    dotnet-coverage() { record "dotnet-coverage $*"; }
    mkdir() { record "mkdir $*"; }
    append_if_missing() { record "append $*"; }
    # Act
    run install_dotnet_coverage
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"mkdir -p "*"/.dotnet/tools"* ]]
    [[ "$output" == *"dotnet-coverage is already available; skipping."* ]]
}

@test "C824-46 install_dotnet_coverage updates the global tool when it is already listed" {
    # Arrange: the grep stub reports that dotnet tool list names dotnet-coverage.
    dotnet() { record "dotnet $*"; }
    grep() { return 0; }
    mkdir() { record "mkdir $*"; }
    append_if_missing() { record "append $*"; }
    # Act
    run run_with_stub_path install_dotnet_coverage
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installing dotnet-coverage as a global dotnet tool..."* ]]
    [[ "$output" == *"dotnet tool update --global dotnet-coverage"* ]]
}

@test "C824-47 install_dotnet_coverage installs the global tool when it is not listed" {
    # Arrange: the grep stub reports that dotnet tool list does not name dotnet-coverage.
    dotnet() { record "dotnet $*"; }
    grep() { return 1; }
    mkdir() { record "mkdir $*"; }
    append_if_missing() { record "append $*"; }
    # Act
    run run_with_stub_path install_dotnet_coverage
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"dotnet tool install --global dotnet-coverage"* ]]
    [[ "$output" != *"dotnet tool update"* ]]
}
```

## Appendix N — `tests/shell/test_codex_web_setup_codex_verify.bats` (P15-T6)

```bash
#!/usr/bin/env bats
# ------------------------------------------------------------------------------
# test_codex_web_setup_codex_verify.bats
#
# Purpose:
#   Cover the verification functions and main of .codex/codex-web-setup.sh (the
#   Codex copy, not the GitHub Codex copy): verify_formatting_capability,
#   is_windows_powershell_host, the Visual Studio test-tooling failure of
#   verify_windows_visual_studio_task_capability, verify_build_and_test_capability,
#   verify_required_task_tooling, and main (issue #824, kcov scope widening for
#   PA-1).
#
# Determinism: dotnet, dotnet-coverage, pwsh, and git are replaced by shell
# functions; main runs with every step it calls replaced by a function that
# records the step name, so nothing is installed and ~/.bashrc is not written.
# A test that needs a tool to be absent runs through run_with_stub_path, which
# limits PATH and HOME to this test directory. No temporary file is created.
# ------------------------------------------------------------------------------

# Canonical absolute path, so kcov reports the sourced file as <repo>/.codex/codex-web-setup.sh.
SCRIPT_UNDER_TEST="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/.codex/codex-web-setup.sh"
FIXTURES="$(cd "${BATS_TEST_DIRNAME}/../fixtures/codex_web_setup" && pwd)"

setup() {
    # Sourcing defines the functions without running main (C824-1 pins the guard).
    source "${SCRIPT_UNDER_TEST}"
}

teardown() {
    unset -f dotnet dotnet-coverage git pwsh
}

# Run a command with PATH and HOME limited to this test directory.
run_with_stub_path() {
    local PATH="${BATS_TEST_DIRNAME}"
    local HOME="${BATS_TEST_DIRNAME}"
    "$@"
}

# Print a replaced command's name and arguments to stderr, which run captures.
record() {
    printf '%s\n' "$*" >&2
}

@test "C824-48 verify_formatting_capability fails when dotnet is unavailable" {
    # Act
    run run_with_stub_path verify_formatting_capability
    # Assert
    [ "$status" -eq 1 ]
    [[ "$output" == *"Verifying formatting capability..."* ]]
    [[ "$output" == *"dotnet is not available after setup."* ]]
}

@test "C824-49 verify_formatting_capability fails when pwsh is unavailable" {
    # Arrange
    dotnet() { record "dotnet $*"; }
    # Act
    run run_with_stub_path verify_formatting_capability
    # Assert
    [ "$status" -eq 1 ]
    [[ "$output" == *"pwsh is not available after setup."* ]]
}

@test "C824-50 verify_formatting_capability fails when CSharpier is not runnable" {
    # Arrange
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    dotnet() { return 1; }
    pwsh() { record "pwsh $*"; }
    # Act
    run verify_formatting_capability
    # Assert
    [ "$status" -eq 1 ]
    [[ "$output" == *"CSharpier is not runnable via 'dotnet tool run csharpier'."* ]]
}

@test "C824-51 verify_formatting_capability passes when dotnet, pwsh, and CSharpier are runnable" {
    # Arrange
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    dotnet() { record "dotnet $*"; }
    pwsh() { record "pwsh $*"; }
    # Act
    run verify_formatting_capability
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"dotnet tool run csharpier --version"* ]]
}

@test "C824-52 is_windows_powershell_host succeeds when pwsh reports a Windows host" {
    # Arrange
    pwsh() { return 0; }
    # Act
    run is_windows_powershell_host
    # Assert
    [ "$status" -eq 0 ]
}

@test "C824-53 is_windows_powershell_host fails when pwsh reports a non-Windows host" {
    # Arrange
    pwsh() { return 1; }
    # Act
    run is_windows_powershell_host
    # Assert
    [ "$status" -eq 1 ]
}

@test "C824-54 verify_windows_visual_studio_task_capability fails when the Visual Studio test tooling is unavailable" {
    # Arrange: the MSBuild probe (-File) succeeds and the vswhere/vstest probe (-Command) fails.
    pwsh() { [ "${4:-}" = "-File" ]; }
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    SOLUTION_FILE="Alpha.sln"
    # Act
    run verify_windows_visual_studio_task_capability
    # Assert
    [ "$status" -eq 1 ]
    [[ "$output" == *"Visual Studio test tooling required by the MSTest tasks is unavailable."* ]]
    [[ "$output" != *"MSBuild tooling required"* ]]
}

@test "C824-55 verify_build_and_test_capability fails when pwsh is unavailable" {
    # Act
    run run_with_stub_path verify_build_and_test_capability
    # Assert
    [ "$status" -eq 1 ]
    [[ "$output" == *"Verifying restore/build/lint/type-check/test capability..."* ]]
    [[ "$output" == *"pwsh is not available after setup."* ]]
}

@test "C824-56 verify_build_and_test_capability fails when dotnet-coverage is unavailable" {
    # Arrange
    pwsh() { record "pwsh $*"; }
    # Act
    run run_with_stub_path verify_build_and_test_capability
    # Assert
    [ "$status" -eq 1 ]
    [[ "$output" == *"dotnet-coverage is not available after setup."* ]]
}

@test "C824-57 verify_build_and_test_capability fails when coverage.config is missing" {
    # Arrange
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    pwsh() { record "pwsh $*"; }
    dotnet-coverage() { record "dotnet-coverage $*"; }
    # Act
    run verify_build_and_test_capability
    # Assert
    [ "$status" -eq 1 ]
    [[ "$output" == *"coverage.config is missing from the repository root."* ]]
}

@test "C824-58 verify_build_and_test_capability warns and skips the Visual Studio checks on a non-Windows host" {
    # Arrange
    REPO_ROOT="${FIXTURES}/dotnet-repo"
    pwsh() { return 1; }
    dotnet-coverage() { record "dotnet-coverage $*"; }
    verify_windows_visual_studio_task_capability() { record "vs-verification-called"; }
    # Act
    run verify_build_and_test_capability
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Skipping Windows-only Visual Studio task verification because this host is not Windows."* ]]
    [[ "$output" != *"vs-verification-called"* ]]
}

@test "C824-59 verify_build_and_test_capability runs the Visual Studio checks on a Windows host" {
    # Arrange
    REPO_ROOT="${FIXTURES}/dotnet-repo"
    pwsh() { return 0; }
    dotnet-coverage() { record "dotnet-coverage $*"; }
    verify_windows_visual_studio_task_capability() { record "vs-verification-called"; }
    # Act
    run verify_build_and_test_capability
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"vs-verification-called"* ]]
}

@test "C824-60 verify_required_task_tooling runs the formatting and the build checks" {
    # Arrange
    verify_formatting_capability() { record "formatting-checked"; }
    verify_build_and_test_capability() { record "build-checked"; }
    # Act
    run verify_required_task_tooling
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"formatting-checked"*"build-checked"* ]]
}

@test "C824-61 main runs every setup step in order and reports completion" {
    # Arrange: every step main calls is replaced, so main writes nothing and installs nothing.
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    append_if_missing() { record "append $2"; }
    install_apt_packages() { record "step install_apt_packages"; }
    install_powershell() { record "step install_powershell"; }
    install_nuget() { record "step install_nuget"; }
    install_dotnet_sdk() { record "step install_dotnet_sdk"; }
    install_dotnet_tools() { record "step install_dotnet_tools"; }
    install_dotnet_coverage() { record "step install_dotnet_coverage"; }
    verify_required_task_tooling() { record "step verify_required_task_tooling"; }
    install_actionlint() { record "step install_actionlint"; }
    restore_packages_if_needed() { record "step restore_packages_if_needed"; }
    write_repo_notes() { record "step write_repo_notes"; }
    git() { record "git $*"; }
    # Act
    run main
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Bootstrapping a Codex Web environment for ${BATS_TEST_DIRNAME}"* ]]
    [[ "$output" == *"append export CI=true"*"append export NUGET_XMLDOC_MODE=skip"* ]]
    [[ "$output" == *"step install_apt_packages"*"step install_powershell"*"step install_nuget"*"step install_dotnet_sdk"*"step install_dotnet_tools"*"step install_dotnet_coverage"*"step verify_required_task_tooling"*"step install_actionlint"*"step restore_packages_if_needed"* ]]
    [[ "$output" == *"git config --global core.autocrlf input"*"step write_repo_notes"*"Setup complete."* ]]
}
```

## Appendix O — PR-Body Callout Addendum (content of FEATURE/evidence/other/pr-body-callouts-widening.TS.md)

The artifact carries `Timestamp:` and these sections, in plain wording, with the bracketed values substituted from the named artifacts, and must not contain a GitHub closing keyword followed by `#824`. It supplements, and does not replace, the P7-T2 callouts artifact.

1. Issue reference: unchanged. The PR body references the issue with the exact line `Refs #824` and uses no closing keyword for #824.
2. Additional policy edit: `.claude/rules/shell.md` and its bundled copy `extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md` add `.codex/` to the shell-qc discovery roots and the kcov include roots. Authority: the operator decision on feature-review finding PA-1 (2026-10-10), which widened #824 scope instead of recording a waiver and authorizes this edit for these two files only (spec.md Change Log, 2026-10-10).
3. Shell toolchain change: `scripts/bash/shell_qc_lib.sh` adds the `.codex` discovery root and appends `.codex` to the kcov include pattern; `tests/shell/test_shell_qc_discovery.bats`, `tests/shell/test_shell_qc_commands.bats`, and the fixture `tests/fixtures/shell_qc/.codex/codex_entry.sh` cover the change. `.github/workflows/_shell-coverage.yml` is unchanged.
4. `.codex/codex-web-setup.sh` now uses the shfmt default layout (a whitespace-only change, plus any shellcheck remediation listed in the P16-T6 ledger); its bundled copy stays byte-identical. `.github/codex/codex-web-setup.sh` is a separate file with no parity test against `.codex/codex-web-setup.sh` and is unchanged.
5. Coverage: kcov measures `.codex/codex-web-setup.sh` at [FINAL_CODEX_SETUP_PCT]% line coverage (line-rate [FINAL_CODEX_SETUP_RATE]) in CI run [RUN_ID of the passing round]; repo-wide Bash line coverage is [FINAL_BASH_LINE]%. Three new bats suites (`tests/shell/test_codex_web_setup_codex_installers.bats`, `tests/shell/test_codex_web_setup_codex_dotnet.bats`, `tests/shell/test_codex_web_setup_codex_verify.bats`) add cases C824-16 to C824-[C824_MAX of the passing round].
6. Follow-up list amendment: the out-of-scope follow-up stating that `.codex/` is outside shell-qc discovery and the kcov include roots is resolved by this PR and is removed from the follow-ups list. The other follow-ups in the P7-T2 callouts artifact are unchanged.

## Appendix P — CI Hold Protocol, Readers, and the Layout Writer

Orchestrator steps at a CI hold (the executor never runs these; it has no `gh` access). Substitute n, HOLD_HEAD_n, and RUN_ID_n. In a PowerShell session, write the two redirected files as UTF-8 (pipe to `Out-File -Encoding utf8 <path>` instead of `>`).

- O1. Confirm the remote head: `git ls-remote origin refs/heads/bug/issue-823-tier-rule-adoption-follow-ups-824` prints HOLD_HEAD_n.
- O2. Dispatch: `gh workflow run _shell-coverage.yml --ref bug/issue-823-tier-rule-adoption-follow-ups-824`.
- O3. Identify the run: `gh run list --workflow _shell-coverage.yml --branch bug/issue-823-tier-rule-adoption-follow-ups-824 --event workflow_dispatch --limit 5 --json databaseId,headSha,createdAt,status`; RUN_ID_n is the newest run whose `headSha` equals HOLD_HEAD_n.
- O4. Wait for completion: `gh run watch RUN_ID_n --exit-status`. A non-zero exit means the run failed; continue with O5-O8, because the executor reads the failure.
- O5. `mkdir -p artifacts/orchestration/ci-shell-coverage/RUN_ID_n`, then `gh run view RUN_ID_n --json databaseId,headSha,conclusion,jobs > artifacts/orchestration/ci-shell-coverage/RUN_ID_n/run.json`.
- O6. `gh run view RUN_ID_n --log > artifacts/orchestration/ci-shell-coverage/RUN_ID_n/run.log`.
- O7. `gh run download RUN_ID_n -n shell-coverage -D artifacts/orchestration/ci-shell-coverage/RUN_ID_n/shell-coverage` (the artifact root holds `cov.xml`). When the run uploaded no `shell-coverage` artifact because an earlier step failed, skip the download and say so in O8.
- O8. Resume the executor with the line `CI-RESUME: ROUND n RUN_ID RUN_ID_n`, followed by `ARTIFACT: absent` when O7 found no artifact.

Executor readers. Each is one line; substitute RUN_ID with RUN_ID_n. Observed output formats these readers rely on: `gh run view --log` lines are `<job name>`, tab, `<step name>`, tab, `<timestamp ending in Z>`, space, content (recorded in `docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/qa-gates/final-shell-coverage-ci.2026-10-08T21-25.md` line 9); bats under CI prints TAP lines `ok <n> <name>` and `not ok <n> <name>` (recorded in `docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741/evidence/regression-testing/pass-after-scan-roots.2026-10-02T04-06.md` lines 13-20); the shell-qc coverage step ends with `Bash coverage (lines): NN.N%`, and earlier lines of the same text in that step are not results, so the last match is used (same 794 artifact, line 8); kcov writes repository-relative Cobertura `filename` attributes and `<line number=... hits=...>` rows (same 794 artifact, lines 12-15).

R1 `.codex/` shell-script set (P12-T2; applies the `is_shell_script` rule: a `.sh` suffix, or a first-line shebang whose interpreter, after an `env` and its option flags, is `bash` or `sh`):

```sh
poetry run python -c "import subprocess; fs = subprocess.run(['git', 'ls-files', '--', '.codex'], capture_output=True, text=True, check=True).stdout.splitlines(); first = lambda p: open(p, encoding='utf-8', errors='replace').readline().strip().lower(); toks = lambda l: [t.rsplit('/', 1)[-1] for t in l[2:].split() if not t.startswith('-')] if l.startswith('#!') else []; interp = lambda ts: (ts[1] if len(ts) > 1 else '') if ts and ts[0] == 'env' else (ts[0] if ts else ''); print('TRACKED', len(fs)); print('SHELL', [p for p in fs if p.lower().endswith('.sh') or interp(toks(first(p))) in ('bash', 'sh')])"
```

R2 run summary (prints the run id, head SHA, conclusion, and one line per step):

```sh
poetry run python -c "import json, sys; d = json.load(open(sys.argv[1], encoding='utf-8-sig')); print('RUN', d.get('databaseId'), 'HEAD', d.get('headSha'), 'CONCLUSION', d.get('conclusion')); [print('STEP', s.get('name'), '|', s.get('conclusion')) for j in d.get('jobs', []) for s in j.get('steps', [])]" artifacts/orchestration/ci-shell-coverage/RUN_ID/run.json
```

R3 `shell-qc check` step (counts the step's lines, the lines carrying a shellcheck code, and the shfmt diff file headers; prints every step line, prefixed `CHECK|`, only when a count is above 0):

```sh
poetry run python -c "import re, sys; rows = [l.split(chr(9), 2) for l in open(sys.argv[1], encoding='utf-8-sig', errors='replace').read().splitlines()]; c = [re.sub(r'^\S+Z ', '', r[2]) for r in rows if len(r) == 3 and r[1].startswith('Run shell-qc check')]; sc = [x for x in c if re.search(r'SC[0-9]{4}', x)]; df = [x for x in c if x.startswith('--- ')]; print('CHECK_LINES', len(c), 'SHELLCHECK_FINDINGS', len(sc), 'SHFMT_DIFF_FILES', len(df)); [print('CHECK|', x) for x in (c if sc or df else [])]" artifacts/orchestration/ci-shell-coverage/RUN_ID/run.log
```

R4 bats results and repo-wide Bash coverage (the coverage step's TAP lines and its last coverage summary; when any `not ok` line exists it also prints every step line beginning `# `, prefixed `DIAG|`, which are the bats failure diagnostics observed in `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/regression-testing/fail-before-bats.2026-10-01T16-32.md` lines 44-48):

```sh
poetry run python -c "import re, sys; rows = [l.split(chr(9), 2) for l in open(sys.argv[1], encoding='utf-8-sig', errors='replace').read().splitlines()]; t = [re.sub(r'^\S+Z ', '', r[2]) for r in rows if len(r) == 3 and r[1].startswith('Run shell-qc test with coverage')]; nok = [x for x in t if re.match(r'not ok [0-9]+ ', x)]; ok = [x for x in t if re.match(r'ok [0-9]+ ', x)]; ids = sorted({int(m.group(1)) for x in ok for m in [re.match(r'ok [0-9]+ C824-([0-9]+) ', x)] if m}); cov = [m.group(1) for x in t for m in [re.search(r'Bash coverage \(lines\): ([0-9.]+)%', x)] if m]; print('TEST_LINES', len(t), 'OK', len(ok), 'NOT_OK', len(nok), 'C824_OK', len(ids), 'C824_MAX', ids[-1] if ids else 0, 'REPO_BASH_LINE', cov[-1] if cov else 'MISSING'); [print('NOT_OK|', x) for x in nok]; [print('DIAG|', x) for x in (t if nok else []) if x.startswith('# ')]" artifacts/orchestration/ci-shell-coverage/RUN_ID/run.log
```

R5 kcov Cobertura reader for `.codex/codex-web-setup.sh` (selects the class whose `filename` is `.codex/codex-web-setup.sh` or ends in `/.codex/codex-web-setup.sh`, so `.github/codex/codex-web-setup.sh` cannot match; the gate is the class `line-rate` at or above 0.85; the hit ratio over the class's `line` rows and the uncovered line numbers are printed as a cross-check):

```sh
poetry run python -c "import sys, xml.etree.ElementTree as E; r = E.parse(sys.argv[1]).getroot(); fn = lambda c: c.get('filename', '').replace(chr(92), '/'); m = [c for c in r.iter('class') if fn(c) == '.codex/codex-web-setup.sh' or fn(c).endswith('/.codex/codex-web-setup.sh')]; ls = [l for c in m for l in c.iter('line')]; hit = [l for l in ls if int(l.get('hits', '0')) > 0]; un = [int(l.get('number')) for l in ls if int(l.get('hits', '0')) == 0]; rate = float(m[0].get('line-rate')) if len(m) == 1 else None; pct = round(100 * len(hit) / len(ls), 2) if ls else None; print('ROOT_LINE_RATE', r.get('line-rate'), 'MATCHES', len(m), 'CLASS_LINE_RATE', rate if rate is not None else 'MISSING', 'LINES', len(ls), 'HIT', len(hit), 'PCT', pct if pct is not None else 'MISSING', 'GATE', 'PASS' if rate is not None and rate >= 0.85 else 'FAIL'); print('UNCOVERED', un if un else 'NONE')" artifacts/orchestration/ci-shell-coverage/RUN_ID/shell-coverage/cov.xml
```

R6 carriage-return check over BATS-NEW and the seven new fixtures (P15-T7):

```sh
poetry run python -c "import pathlib, sys; ps = sys.argv[1:]; bad = [p for p in ps if b'\r' in pathlib.Path(p).read_bytes()]; print('CHECKED', len(ps), 'CR_FILES', len(bad), bad)" tests/shell/test_codex_web_setup_codex_installers.bats tests/shell/test_codex_web_setup_codex_dotnet.bats tests/shell/test_codex_web_setup_codex_verify.bats tests/fixtures/codex_web_setup/dotnet-repo/global.json tests/fixtures/codex_web_setup/dotnet-repo/dotnet-tools.json tests/fixtures/codex_web_setup/dotnet-repo/coverage.config tests/fixtures/codex_web_setup/dotnet-sdk-installed/global.json tests/fixtures/codex_web_setup/dotnet-sdk-installed/.dotnet-sdk/dotnet/placeholder.txt tests/fixtures/codex_web_setup/dotnet-sdk-installed/.dotnet-sdk/sdk/8.0.100/placeholder.txt tests/fixtures/codex_web_setup/bashrc-with-ci.txt
```

W1 layout writer for `.codex/codex-web-setup.sh` (P14-T1; PD14). It splits the file on LF, finds the one line ending in `"& {` (index a) and the first later line whose stripped text begins with `}"` (index b), leaves lines a+1 through b unchanged, replaces every other line's leading run of two-space groups with the same number of tabs, writes the result back with LF line endings, and prints its counts:

```sh
poetry run python -c "import pathlib, re; p = pathlib.Path('.codex/codex-web-setup.sh'); L = p.read_bytes().decode('utf-8').split(chr(10)); S = [i for i, l in enumerate(L) if l.endswith(chr(34) + '& {')]; a = S[0]; b = next(i for i in range(a + 1, len(L)) if L[i].lstrip().startswith('}' + chr(34))); O = [l if a < i <= b else re.sub('^(  )+', lambda m: chr(9) * (len(m.group(0)) // 2), l) for i, l in enumerate(L)]; p.write_bytes(chr(10).join(O).encode('utf-8')); print('BLOCK_START_CANDIDATES', len(S), 'KEPT_BLOCK_LINES', b - a, 'CHANGED_LINES', sum(1 for x, y in zip(L, O) if x != y), 'SPACE_LEADING_AFTER', sum(1 for l in O if l.startswith(' ')), 'CR_BYTES', p.read_bytes().count(13))"
```

W1 derivation at WIDEN_BASE: the file has 413 lines and 254 lines that begin with spaces, all in multiples of two; the only line ending in `"& {` is line 316 (index 315), and the first later line beginning `}"` after stripping is line 326 (index 325), so `KEPT_BLOCK_LINES` is 10 (lines 317-326, one of them the empty line 321). Nine of the kept lines begin with spaces, so `CHANGED_LINES` is 254 - 9 = 245 and `SPACE_LEADING_AFTER` is 9.

## Planner Self-Review Record

SELF-REVIEW: RE-DERIVED THIS PASS

Revision 2, preflight round 2 delta (2026-10-10; executor preflight round 2 defects 1-3). Citations touched by this delta and their sibling regions, re-derived in this pass:
- `.codex/codex-web-setup.sh`: 254 lines begin with a space (count search); line 316 is the only line ending in `"& {` and line 326 begins `}"` after stripping; of lines 317-326, nine begin with spaces (321 is empty), so W1 changes 245 lines and the 168 unchanged lines bound the minimal diff at 245 removals and 245 additions. The default-algorithm value 275/275 is the executor's scratch-copy observation from preflight round 2 and is cited as such in P14-T3; it was not re-run by the planner, which has no shell tool in this pass.
- P14-T3 (Commands and Acceptance): the `--stat --minimal` command and the `245` summary line are the only `--stat`/`245` mentions in Phases 12-17; the other `245` mentions (P14-T1 W1 output, W1 derivation in Appendix P) count changed lines, not diff-stat lines, and are unchanged. The Phase 0 `--stat` listing (P0 task near line 117) and the HAP `git diff --stat BASE_SHA` fallback are outside this delta and assert path presence only.
- Ledger-field consumers: remediation-rule header (now path, line, failure kind, r, a, change class, reason), P16-T6 acceptance (same field list), P17-T3 acceptance (sum of r + a), PD15 ("P17-T3 checks the count", still accurate), P17-T3 title ("ledgered `non-whitespace` shellcheck remediation", consistent with change class derived from r + a), Appendix O item 4 (refers to the ledger generically). The P17-T3 sentence excluding `whitespace-only` entries remains true because those entries carry r + a = 0.
- P17-T3 changed-line grep `^[-+][^-+]` over the `-w --minimal --unified=0` diff: header lines `---`/`+++` are excluded by the pattern, and `@@` lines do not begin with `-` or `+`.
- Rule 5 stop branch: `REPO_BASH_LINE` and `NOT_OK` are printed by R4 and `GATE` by R5 (Appendix P R4 and R5 programs); the directive text attributed `NOT_OK 0` to R5, so the inserted clause names R4 for `NOT_OK 0`. Sibling consumers of the 85.0 line threshold: P16-T4 acceptance (`REPO_BASH_LINE` at least 85.0) and P17-T6 verdict; rule 4 covers `GATE FAIL` and rule 3 covers `NOT_OK` above 0, so the new branch covers the remaining case in which the round fails on P16-T4 alone.

Revision 2, preflight round 1 delta (2026-10-10; executor preflight defects 1-5). Citations touched by this delta and their sibling regions, re-derived in this pass against the worktree:
- `.codex/codex-web-setup.sh` line 316 (the only line ending in `"& {`) and line 326 (the only line beginning `}"` after stripping): basis of the rule 4 HOLD_HEAD_n locator, which names the same block W1 skips; the WIDEN_BASE fallback 317-326 is unchanged.
- `tests/shell/test_codex_web_setup_codex_copy.bats`: 15 `@test "C824-` cases (C824-1 to C824-15); with BATS-NEW C824-16 to C824-61 (Appendix N ends at C824-61), the first free number for rule 4 is 62.
- `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/regression-testing/fail-before-bats.2026-10-01T16-32.md` lines 44-48: observed bats failure output, a `not ok` line followed by lines beginning `# ` (`# (in test file ...)`, `#   ... failed`, `# Last output:`); basis of the R4 `DIAG|` filter.
- Plan sibling sweep (this file): every remaining `61` reference in Phases 12-17 and Appendices I-P is either the base count (BATS-NEW term, P15-T6 creation grep, Appendix N case C824-61) or now expressed as 61 plus ADDED_CASES (P16-T4, P17-T11) or as the passing round's C824_MAX (Appendix O item 5); the spec text in Appendix I (AC-16 to AC-19) names no case count. R4 consumers: P13-T1 (records `DIAG|` with round-0 failures), P16-T4, rule 3. Ledger field consumers: remediation rule header, P16-T6 (change class and ADDED_CASES), P17-T3 (title and changed-line count by `non-whitespace` class). The only `317-326` mentions are PD14, rule 4 (fallback), and the W1 derivation, all describing WIDEN_BASE. Write-route consumers of the amended "Permitted executor commands" bullet: P13-T3, P14-T1, P14-T2, rules 1 and 2.

Revision 2 (2026-10-10, operator-approved PA-1 scope widening; Phases 12-17 and Appendices I-P). Every citation this revision added or relies on, and the sibling region of each, was re-derived in this pass against the worktree at HEAD 45f5326bf:
- `scripts/bash/shell_qc_lib.sh`: 394 lines; no line begins with a space; `is_shell_script` lines 54-73; `discover_shell_scripts` lines 75-102 with the comment at lines 76-77 and the root list at line 85; `run_test_coverage` comment lines 348-349 and `include_pattern` line 350; the J3-J5 old texts were compared against these lines by a tab-anchored search of both files (identical).
- `.claude/rules/shell.md`: Discovery Contract lines 46-59 (search roots lines 48-52, the J1 old text); Coverage Expectations lines 61-71 (lines 66-68, the J2 old text); Coding Standards lines 80-94 (shfmt tab indentation line 87, 500-line limit line 90, no temporary files and checked-in fixtures lines 91-94). The bundled copy carries the same text at lines 48 and 66 (search over both files).
- `tests/shell/test_shell_qc_discovery.bats`: 99 lines, 13 `@test` blocks; root tests lines 61-71; node_modules test line 73 (J7 anchor); sorted-list test lines 87-99 pinning 7 entries at lines 90-98 (J8 old text).
- `tests/shell/test_shell_qc_commands.bats`: 203 lines; shellcheck-call count at line 81 (J9); include-pattern assertions lines 128-131 (J10 anchor line 130); setup lines 9-22 (fixture root and stub directory).
- `tests/fixtures/shell_qc/`: 19 files; `stub-bin/kcov` line 6 echoes its argv on one line (basis of the J10 assertion); `.claude/skills/demo-skill/scripts/skill_entry.sh` (model for J6).
- `.codex/codex-web-setup.sh`: 413 lines; 254 lines begin with spaces, all in multiples of two, and none with a tab; discovery functions lines 10-30 and globals lines 32-35; installers lines 72-272; `restore_packages_if_needed` lines 274-294; `verify_windows_visual_studio_task_capability` lines 312-327 with the multi-line string from line 316 (the only line ending in `"& {`) to line 326 (the only line beginning `}"` after stripping); `warn` text naming `vswhere.exe` at line 337 (PD16); heredoc lines 350-377; `main` lines 380-411; guard line 413. Every stub, message, and argument string in Appendices L, M, and N was traced to these lines.
- `.codex/` tracked content: one `.sh` file and one shebang line (`.codex/codex-web-setup.sh` line 1); every other file is `.toml`, `.md`, `.json`, `.ps1`, or another non-shell type (searches over `.codex/`).
- `tests/shell/test_codex_web_setup_codex_copy.bats`: 187 lines, 15 cases; canonical script path line 19; source in `setup` lines 22-25; the restricted-PATH pattern of C824-11 lines 128-142 (model for `run_with_stub_path`).
- `tests/shell/test_codex_web_setup_apt_helpers.bats` line 8, `tests/shell/test_codex_web_setup_pypi_connectivity.bats` line 8, `tests/shell/test_codex_web_setup_source_safety.bats` line 13: these source `.github/codex/codex-web-setup.sh`, not the `.codex` copy.
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`: `is_publishable_runtime_path` lines 106-109, `list_scoped_files` lines 112-123, and the repo-to-bundle text comparison lines 215-228 (the `.codex/codex-web-setup.sh` parity test).
- `.github/workflows/_shell-coverage.yml`: `workflow_dispatch` trigger line 5; check step line 51-52; coverage step lines 54-55; artifact `shell-coverage` from `artifacts/pester/kcov/**` lines 57-62.
- `.gitignore`: `/artifacts` line 6; `coverage/` line 61; `.codex/state/` line 71; no pattern matches the W-SET fixture paths (searches for json, config, txt, sdk, dotnet, and bashrc).
- `docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/qa-gates/final-shell-coverage-ci.2026-10-08T21-25.md` lines 8-15 and `docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741/evidence/regression-testing/pass-after-scan-roots.2026-10-02T04-06.md` lines 13-20: observed success-case formats for the R3, R4, and R5 readers (log columns, last coverage summary, Cobertura class and line rows, TAP lines).
- `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md`: AC-1 to AC-15 lines 212-226 (AC-6, AC-13, AC-15 unchecked); I1 anchor at the end of line 226 and the heading at line 228; I2 anchor at line 308 (last line).
- `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/remediation-inputs.2026-10-10T00-44.md` lines 18-28 (PA-1 and option 2) and lines 37-39 (the do-not-do list this operator decision overrides for the named files).
- Sibling checks: P10-T3 (`vswhere` grep on an unanchored-whitespace diff) would report the line 337 re-indent, so P14-T3 re-verifies AC-14 with `git diff -w`; P11-T16 counted 15 ACs and is not re-run, so P17-T14 counts 19; the old Execution-constraints rules on `sh` routes and on not committing are scoped out of Phases 12-17 by the addendum.

Revision round 1 record (historical; executor preflight defects 1-6 and the formatter-scope advisory). Citations touched by that revision and their sibling regions, re-derived in that pass:
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

Initial-authoring citations (historical; carried as recorded in the round-0 pass, and not relied on by Phases 12-17 except where re-derived in the revision 2 list above):
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
CITATION: scripts/bash/shell_qc_lib.sh | lines 54-73, 75-102 (roots line 85), 348-350 (include_pattern line 350); 394 lines
CITATION: .claude/rules/shell.md | lines 46-59, 61-71, 80-94
CITATION: extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md | lines 48, 66
CITATION: tests/shell/test_shell_qc_discovery.bats | lines 61-73, 87-99; 99 lines
CITATION: tests/shell/test_shell_qc_commands.bats | lines 9-22, 74-83, 120-134; 203 lines
CITATION: tests/fixtures/shell_qc/stub-bin/kcov | line 6
CITATION: .codex/codex-web-setup.sh | lines 1-35, 72-272, 274-294, 312-327, 337, 350-377, 380-413; 413 lines
CITATION: tests/shell/test_codex_web_setup_codex_copy.bats | lines 18-25, 128-142; 187 lines
CITATION: tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py | lines 106-123, 215-228
CITATION: .github/workflows/_shell-coverage.yml | lines 3-5, 51-62
CITATION: .gitignore | lines 6, 61, 71
CITATION: docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/qa-gates/final-shell-coverage-ci.2026-10-08T21-25.md | lines 8-15
CITATION: docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741/evidence/regression-testing/pass-after-scan-roots.2026-10-02T04-06.md | lines 13-20
CITATION: docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/regression-testing/fail-before-bats.2026-10-01T16-32.md | lines 44-48
CITATION: docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md | Acceptance Criteria lines 212-226; Links line 308
CITATION: docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/remediation-inputs.2026-10-10T00-44.md | lines 18-28, 37-39
AC-TRACEABILITY: PASS
SCOPE-BOUNDARY: PASS
AC-INVENTORY: AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7, AC-8, AC-9, AC-10, AC-11, AC-12, AC-13, AC-14, AC-15, AC-16, AC-17, AC-18, AC-19
AC-MAPPING: AC-1 | IMPLEMENTATION: P3-T1, P3-T2, P3-T3, P3-T5, P3-T6 | TESTS: P3-T4, P8-T3 | EVIDENCE: evidence/regression-testing/pass-after-pester-824-final.TS.md
AC-MAPPING: AC-2 | IMPLEMENTATION: P1-T4, P1-T5 | TESTS: P2-T2, P2-T3, P8-T3 | EVIDENCE: evidence/regression-testing/expect-fail-hook-pester.TS.md
AC-MAPPING: AC-3 | IMPLEMENTATION: P3-T3, P3-T6 | TESTS: P8-T1 | EVIDENCE: evidence/other/p3-t3.TS.md
AC-MAPPING: AC-4 | IMPLEMENTATION: P4-T1, P4-T2, P4-T3, P4-T4, P4-T5, P4-T6 | TESTS: P8-T1, P10-T2 | EVIDENCE: evidence/regression-testing/pass-after-follow-ups-pytest.TS.md
AC-MAPPING: AC-5 | IMPLEMENTATION: P1-T1 | TESTS: P2-T1, P8-T1 | EVIDENCE: evidence/regression-testing/expect-fail-follow-ups-pytest.TS.md
AC-MAPPING: AC-6 | IMPLEMENTATION: P5-T1, P5-T2, P5-T3, P5-T4, P5-T5, P5-T6, P5-T7, P5-T8, P5-T9, P5-T10, P5-T11, P5-T12, P5-T13, P5-T14, P5-T15 | TESTS: P5-T16, P8-T1, P9-T15, P16-T4, P17-T12 | EVIDENCE: evidence/qa-gates/ci-bats-round<n>.TS.md (passing round)
AC-MAPPING: AC-7 | IMPLEMENTATION: P1-T1 | TESTS: P2-T1, P8-T1 | EVIDENCE: evidence/regression-testing/pass-after-follow-ups-pytest.TS.md
AC-MAPPING: AC-8 | IMPLEMENTATION: P3-T5, P3-T6, P3-T7, P4-T4, P5-T10, P6-T7 | TESTS: P8-T4, P8-T5, P8-T6, P9-T14 | EVIDENCE: evidence/qa-gates/parity-set-pytest.TS.md
AC-MAPPING: AC-9 | IMPLEMENTATION: P6-T1, P6-T7 | TESTS: P8-T1 | EVIDENCE: evidence/other/p6-t1.TS.md
AC-MAPPING: AC-10 | IMPLEMENTATION: P3-T3, P6-T1, P6-T2, P6-T3, P6-T4, P6-T5, P6-T6 | TESTS: P8-T1 | EVIDENCE: evidence/regression-testing/pass-after-follow-ups-pytest.TS.md
AC-MAPPING: AC-11 | IMPLEMENTATION: P1-T2 | TESTS: P2-T5, P8-T2 | EVIDENCE: evidence/regression-testing/fail-before-exception.note-b.TS.md
AC-MAPPING: AC-12 | IMPLEMENTATION: P7-T1 | TESTS: P7-T1 | EVIDENCE: evidence/other/p7-t1.TS.md
AC-MAPPING: AC-13 | IMPLEMENTATION: P9-T1 | TESTS: P9-T10, P9-T12, P9-T13, P9-T14, P10-T1 | EVIDENCE: evidence/qa-gates/qc-loop-complete.TS.md
AC-MAPPING: AC-14 | IMPLEMENTATION: P5-T9 | TESTS: P10-T2, P10-T3 | EVIDENCE: evidence/qa-gates/scope-check.TS.md
AC-MAPPING: AC-15 | IMPLEMENTATION: P7-T2, P17-T7 | TESTS: P11-T15 | EVIDENCE: evidence/other/pr-body-callouts-widening.TS.md
AC-MAPPING: AC-16 | IMPLEMENTATION: P13-T2, P13-T3 | TESTS: P12-T2, P13-T8, P17-T1, P17-T3, P17-T8 | EVIDENCE: evidence/qa-gates/widening-mirror-identity.TS.md
AC-MAPPING: AC-17 | IMPLEMENTATION: P13-T4, P13-T5, P13-T6, P13-T7 | TESTS: P16-T2, P16-T3, P16-T4, P16-T5, P17-T9 | EVIDENCE: evidence/qa-gates/ci-bats-round<n>.TS.md (passing round)
AC-MAPPING: AC-18 | IMPLEMENTATION: P14-T1, P14-T2 | TESTS: P14-T3, P14-T4, P16-T3, P16-T4, P17-T3, P17-T10 | EVIDENCE: evidence/qa-gates/ci-shell-qc-check-round<n>.TS.md (passing round)
AC-MAPPING: AC-19 | IMPLEMENTATION: P15-T1, P15-T2, P15-T3, P15-T4, P15-T5, P15-T6 | TESTS: P15-T7, P16-T4, P16-T5, P17-T6, P17-T11 | EVIDENCE: evidence/qa-gates/ci-kcov-codex-setup-round<n>.TS.md (passing round)
UNRESOLVED-GAPS: NONE
