# 2026-10-08-bug-burndown-2026-09-29-review-nits (Plan)

- **Issue:** #846
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-09T09-00
- **Status:** Ready for preflight (revision 1.2, addressing preflight round 2)
- **Version:** 1.2
- **Work Mode:** full-bug (spec.md is the sole acceptance-criteria source; user-story.md is intentionally absent)
- **Requirements:** spec.md AC-1 through AC-40 in this feature folder; supporting inputs issue.md and research/research.2026-10-08T23-50.md

**Fail-closed evidence rule:** Every in-scope language has explicit baseline artifact tasks, final-QC artifact tasks, and coverage-comparison tasks where policy requires coverage. If any required baseline, QC, or coverage-comparison artifact is missing, the audit verdict is BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Each evidence-producing task names its artifact path. A task is not checked off until its artifact exists with every required field.

## Conventions

- Feature folder (plain text, referenced below as FEATURE): docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846. All #846 evidence is written under FEATURE/evidence/baseline, FEATURE/evidence/regression-testing, FEATURE/evidence/qa-gates, or FEATURE/evidence/other. The only evidence written outside FEATURE is the two superseding notes that spec.md names in the #764 and #609 folders.
- Evidence filename stamp: every new evidence file carries the plan-assigned stamp `2026-10-09T09-00` in its name so the path is literal. The `Timestamp:` field inside each artifact is read from the host clock at write time (for example `date +%Y-%m-%dT%H-%M` through the Bash tool) and is the authoritative run time; the filename stamp is an identifier only (deviation D-9).
- Command-step artifact fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. An artifact whose first command is expected to exit non-zero also carries `ExpectedExitCode: <int>`. Where a task records more than one command, each command gets its own `Command:` / `EXIT_CODE:` block in the order listed; the first block is the artifact's primary record.
- Working directory: the repository root of this worktree unless a task says "from extensions/drm-copilot".
- Shell: every command that is not labeled "PowerShell-tool" is written in POSIX shell quoting and is run with the Bash tool (single quotes are literal; inside double quotes a backslash is kept except before `$`, backtick, double quote, and backslash). Commands labeled "PowerShell-tool" are run with the PowerShell tool; every such command ([P0-T5] `Get-Module`, [P0-T23] to [P0-T25], [P8-T5], and Phase 12) is governed by the A7 branch rule below, and none is routed through `pwsh` in the Bash tool.
- Merge-base anchoring (deviation D-3): every scope diff is anchored to the literal merge-base SHA `e7d3779b398604af919678c16c877c8539a86cc0`, printed by `git merge-base HEAD origin/main` on 2026-10-09 (on that date HEAD, origin/main, and the branch ref all resolved to this SHA). No `$(...)` command substitution is used anywhere in this plan, because the worktree-isolation guard refuses any git command containing `$(`, and the promotion hook stops masking quoted promotion tokens in a segment that contains `$(`. A single-ref `git diff <sha>` compares that commit with the working tree, so it observes tracked changes whether or not they are committed; it is always paired with `git status --porcelain --untracked-files=all` over the same pathspec, which observes new untracked files. Spec verification commands written as `origin/main...HEAD` or `origin/main` are executed in this form. If [P0-T4] records a different `Merge-Base:` value, every anchored command uses that recorded value in place of the SHA above, and each affected artifact records the substitution.
- Promotion-hook quoting: any command text that contains the tokens potential_to_issue, new_potential_bug_entry, or new_active_feature_folder places the whole argument inside double quotes (enforce-promotion-mcp-only hook masks quoted spans only).
- New-file searches: files this plan creates are untracked until committed, so `git grep` cannot see them. Searches over new files use plain `grep`. Patterns that begin with `-` are passed with `-e`.
- Coverage commands use the dotted `--cov=<module>` form, the `=` form, `--cov-branch`, and `--cov-report=term-missing`. The terminal table prints one combined `Cover` column only, so separate line and branch percentages are read from a JSON report with the COVJSON command:
  - COVJSON (per file): `poetry run python -c "import json,sys;d=json.load(open(sys.argv[1]));[print(k,'line',round(100*s['covered_lines']/s['num_statements'],2),'branch',round(100*s['covered_branches']/s['num_branches'],2) if s['num_branches'] else 'n/a') for k,v in d['files'].items() for s in [v['summary']]]" artifacts/python/cov-targeted.json`
  - COVTOTAL (whole repository): `poetry run python -c "import json,sys;s=json.load(open(sys.argv[1]))['totals'];print('TOTAL line',round(100*s['covered_lines']/s['num_statements'],2),'branch',round(100*s['covered_branches']/s['num_branches'],2))" artifacts/python/coverage.json`
  - Each targeted pytest command writes its JSON report to artifacts/python/cov-targeted.json (gitignored output, overwritten per run); the COVJSON output is copied into the artifact immediately after each run.
- Observed success literals (taken from recorded runs in the #338 evidence folder, not inferred): Black check prints `would be left unchanged` with no `would reformat` line; Ruff prints `All checks passed!`; Pyright prints `0 errors, 0 warnings, 0 informations`; Prettier check prints `All matched files use Prettier code style!`. Pester, ESLint, and tsc success output has not been observed by this planner, so tasks over those tools assert exit code plus the specific counts the task names and record the summary output verbatim.
- Assumption A7 branch (Pester and PowerShell analysis): each PowerShell task first runs the stated cmdlet through the PowerShell tool. Branch A7-LOCAL: the cmdlet runs, and acceptance is as stated. Branch A7-CI: the invocation is denied by a hook, or Pester 5 or PSScriptAnalyzer is unavailable as recorded in [P0-T5], or the PowerShell tool is not in the executor's tool set (the artifact then records `PowerShell tool unavailable` as the error text); the artifact records the attempted command, the observed exit code, the verbatim denial or error text, and `Outcome: LOCAL-PESTER-UNAVAILABLE`, and the dependent acceptance criteria (AC-30, AC-31, AC-38, and, under either branch, AC-34) stay unchecked and are listed as pending-CI. Under A7-CI the CI job `poshqc / PowerShell QC` on the PR head is authoritative and the item's orchestrator checks those criteria off at S9 per the CI-Dependent Criteria rule of the acceptance-criteria-tracking skill. This plan does not create a PR and does not monitor CI.
- Batch budget: the Python hook (enforce-python-batch-budget.ps1, synopsis lines 25-29 and decision line 302) never counts test files and caps direct mode at three distinct production Python files; this plan edits two production Python files (scripts/dev_tools/check_quality_tiers.py and scripts/dev_tools/potential_to_issue.py). The PowerShell hook (enforce-powershell-batch-budget.ps1 line 299) never counts files under tests/ or named `*.Tests.ps1`; this plan edits no production PowerShell file. No budget reset is required and none is scheduled; [P0-T27] records this analysis.
- Mirror copies: the three bundled acceptance-criteria-tracking SKILL.md mirrors are produced by byte copy from their edited source with `cp --` through the Bash tool, never by hand edit, and each copy is verified with `cmp --`.
- Commits: this plan contains no commit, PR, or CI-monitoring task. When the orchestration commit step commits this work it uses explicit pathspecs taken from the "Files Written by This Plan" section, including the paths named in its pre-existing inputs paragraph when they are still untracked, and never force-pushes.
- CI-dependent AC-34 (spec assumption A5): the #338 A1 disposition requires the PR CI `Enforce Python coverage thresholds` step result, which does not exist during execution. Under both A7 branches AC-34 stays unchecked at the end of this plan and is listed as pending-CI; the executing orchestrator appends the CI run result to the closure-dispositions record and checks AC-34 off at S9.
- Pending list (used by [P13-T11] and [P13-T12]): the set of acceptance criteria left unchecked at the end of execution for a recorded reason. It always contains AC-34; under A7-CI it also contains AC-30, AC-31, and AC-38; and each `Outcome: PRE-EXISTING-FAILURE-ONLY` recorded in Phase 10 or Phase 11 adds its dependent criteria (see the pre-existing-failure rule in those loop rules). The counts in [P13-T11] and [P13-T12] are derived from this list, not fixed in advance.
- Paths that this plan does not write are written in plain text (not as inline code) outside read-task windows, so the blast-radius extractor does not read them as write claims.

## Deviations from spec.md (recorded before execution)

- D-1 (AC-2): the baseline `--collect-only` run names only the pre-split file, because the classification file does not exist at baseline and pytest exits 4 on a missing path. The post-change run names both files.
- D-2 (AC-21): line 75 of both feature-review-workflow SKILL.md copies (.claude/skills/feature-review-workflow/SKILL.md and its claude-customizations mirror) was changed after #764 merged; on 2026-10-09 the line reads "- When the rule fires and no qualifying green-run evidence is present, record a Blocking finding classified `awaiting_ci` ...". The corrected anchored command therefore exits 1 on the current tree. [P7-T4] records the current-tree run with `ExpectedExitCode: 1`, and [P7-T5] demonstrates the corrected command against the pre-change tree of each path, derived mechanically from `git log -S`.
- D-3: every scope diff is anchored to the literal merge-base SHA `e7d3779b398604af919678c16c877c8539a86cc0` (printed by `git merge-base HEAD origin/main` on 2026-10-09); no `$(...)` substitution is used; a single-ref `git diff <sha>` is always paired with `git status --porcelain --untracked-files=all` over the same pathspec; spec verification commands written as `origin/main...HEAD` or `origin/main` are executed in this form (see Conventions, including the recorded-value substitution rule).
- D-4 (AC-36): the AC-9 suite exercises documentation contracts and changes no production module. It is run with `--cov=scripts.dev_tools.validate_orchestrator_state` (a module the suite imports) and `--cov-report=term-missing` to satisfy the command form; no threshold is asserted for that unchanged module. The AC-6 run is subsumed by the AC-4 command, which includes test_check_quality_tiers.py.
- D-5 (value retention versus negative greps): AC-19 and AC-29 forbid specific phrases that the retained original values would contain. The retained values are therefore paraphrased: #623 Status retains "Draft, revision 1.2, awaiting preflight round 3"; #510 retains the former line numbers as "previously cited as 21, 67, and 68" and the former path as "previously named under the coverage evidence folder". The #764 issue.md line 5 is set to the exact text AC-23 requires, and its prior value is retained in the closure-dispositions record.
- D-6 (AC-32): the runbook command uses the literal placeholder `<version>` that spec.md AC-32 specifies; the research proposal used a concrete version.
- D-9: evidence filename stamps are plan-assigned (see Conventions).
- D-10 (AC-40): three planning inputs were created before [P0-T1] by promotion and research, not by this plan: the feature folder's issue.md, its research file, and the promoted potential-bug record. They are named in the pre-existing inputs paragraph of "Files Written by This Plan", are included in the commit pathspec if still untracked, and are accepted by the [P13-T2] comparison through that paragraph. The spec AC-40 file list ("Files the Implementation Writes") is reconciled against the union of that section's listed paths and its pre-existing inputs paragraph.

## AC Traceability

| AC | Implementation task(s) | Verification task(s) | Check-off task |
|---|---|---|---|
| AC-1 | P1-T1, P1-T2, P1-T3 | P2-T5 | P2-T6 |
| AC-2 | P1-T2, P1-T3, P2-T1, P2-T2, P2-T3 | P1-T4, P2-T4 | P2-T7 |
| AC-3 | P2-T1 | P2-T5 | P2-T8 |
| AC-4 | P2-T2, P2-T3 | P3-T5, P10-T4 | P3-T8 |
| AC-5 | P3-T3 | P3-T4, P10-T3 | P10-T13 |
| AC-6 | P3-T1 | P3-T2, P3-T4 | P3-T9 |
| AC-7 | P3-T3 | P3-T6 | P3-T10 |
| AC-8 | P4-T3 to P4-T8 | P4-T9 | P4-T15 |
| AC-9 | P4-T1, P4-T6 to P4-T8 | P4-T2, P4-T10, P10-T7 | P4-T16 |
| AC-10 | P4-T11 | P4-T14 | P4-T17 |
| AC-11 | P4-T12, P4-T13 | P4-T14 | P4-T18 |
| AC-12 | P5-T1 | P5-T5 | P5-T7 |
| AC-13 | P5-T2, P5-T3 | P5-T4 | P5-T8 |
| AC-14 | none (protected file) | P5-T6, P13-T3 | P13-T6 |
| AC-15 | P5-T1 to P5-T3 | P11-T5 | P11-T9 |
| AC-16 | P6-T1 | P6-T2, P13-T4 | P13-T7 |
| AC-17 | P6-T1 | P0-T14, P6-T2 | P6-T11 |
| AC-18 | none (test kept) | P6-T3, P10-T6 | P6-T12 |
| AC-19 | P6-T4, P6-T5 | P6-T6 | P6-T13 |
| AC-20 | P6-T7, P6-T8 | P6-T9, P6-T10 | P6-T14 |
| AC-21 | P7-T1, P7-T2, P7-T3 | P7-T4, P7-T5, P7-T6 | P7-T29 |
| AC-22 | P7-T7 | P7-T9 | P7-T30 |
| AC-23 | P7-T8 | P7-T9 | P7-T31 |
| AC-24 | P7-T10 | P7-T15 | P7-T32 |
| AC-25 | P7-T11 to P7-T14 | P7-T16 | P7-T33 |
| AC-26 | P7-T17 | P7-T18 | P7-T34 |
| AC-27 | P7-T20 | P7-T19, P7-T21 | P7-T35 |
| AC-28 | P7-T22 | P7-T23 | P7-T36 |
| AC-29 | P7-T24 to P7-T27 | P7-T28 | P7-T37 |
| AC-30 | P8-T1 | P8-T5, P12-T3 | P8-T10 |
| AC-31 | P8-T2, P8-T3, P8-T4 | P8-T5, P8-T6 | P8-T11 |
| AC-32 | P8-T7 | P8-T8 | P8-T12 |
| AC-33 | none (no workflow change) | P8-T9 | P8-T13 |
| AC-34 | P13-T4 | P13-T4, P13-T5, PR CI step (S9) | P13-T8 (left open; checked off at S9 by the orchestrator) |
| AC-35 | none (measurement) | P0-T15, P0-T16, P10-T8, P10-T9, P10-T10 | P10-T14 |
| AC-36 | all Python tasks | P10-T1 to P10-T7 | P10-T15 |
| AC-37 | P5-T1 to P5-T3 | P11-T1 to P11-T5 | P11-T10 |
| AC-38 | P8-T1 to P8-T4 | P12-T1, P12-T2 | P12-T5 |
| AC-39 | all code and test tasks | P13-T1 | P13-T9 |
| AC-40 | all tasks (D-10 pre-existing inputs reconciled) | P13-T2 | P13-T10 |

### Phase 0 — Policy reads and baseline capture

- [x] [P0-T1] Read the policy files in the required order and note the rules that apply to Python, TypeScript, and PowerShell test and code changes: `CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/powershell.md`, `.claude/rules/tonality.md`, `.claude/rules/plan-acceptance-gates.md`.
  - Acceptance: every listed file was opened in full in the listed order; the list is reproduced in [P0-T3].
- [x] [P0-T2] Read the feature inputs and governing skills in full: `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md`, `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/issue.md`, `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/research/research.2026-10-08T23-50.md`, `.claude/skills/acceptance-criteria-tracking/SKILL.md`, `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, `.claude/skills/atomic-plan-contract/SKILL.md`, `.claude/hooks/enforce-python-batch-budget.ps1`, `.claude/hooks/enforce-powershell-batch-budget.ps1`, `.claude/hooks/enforce-promotion-mcp-only.ps1`.
  - Acceptance: spec.md AC-1 through AC-40 and assumptions A1 through A9 were read; the files are listed in [P0-T3].
- [x] [P0-T3] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/phase0-instructions-read.md` with `Timestamp:` (host clock), `Policy Order:` (CLAUDE.md, then general code change, general unit test, then Python, TypeScript, PowerShell rules), and the explicit list of every file read in [P0-T1] and [P0-T2].
  - Acceptance: the file exists and contains the three fields and 29 listed file paths.
- [x] [P0-T4] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/git-merge-base.2026-10-09T09-00.md` recording, as separate command blocks, `git fetch origin main`, `git rev-parse HEAD`, `git merge-base HEAD origin/main`, and `git status --porcelain --untracked-files=all`.
  - Acceptance: `git merge-base HEAD origin/main` exits 0 and prints one 40-character SHA, recorded as `Merge-Base:`, and equals `e7d3779b398604af919678c16c877c8539a86cc0`. If it differs (for example after the branch is rebased onto a newer main before execution), every anchored command uses the recorded `Merge-Base:` value in place of that SHA, and each affected artifact records the substitution. The porcelain output is recorded verbatim as the pre-change working-tree state; the three pre-existing inputs named in "Files Written by This Plan" are expected to be tracked by then and are recorded if they appear.
- [x] [P0-T5] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/toolchain-availability.2026-10-09T09-00.md` recording, as separate command blocks, `poetry run python --version`, `poetry run pytest --version`, `node --version`, `npm --version`, `test -d extensions/drm-copilot/node_modules` (Bash; exit 0 means present, exit 1 means absent), and `Get-Module -ListAvailable -Name Pester, PSScriptAnalyzer | Select-Object Name, Version` (PowerShell tool, under the A7 branch rule: when the PowerShell tool is not in the executor's tool set, the block records `PowerShell tool unavailable`, which selects A7-CI).
  - Branch: if the node_modules check exits 1, run `npm ci` from extensions/drm-copilot, record it as an additional block, and confirm with `git status --porcelain -- extensions/drm-copilot/package-lock.json` that it printed nothing. If `poetry run python --version` fails, run `poetry install --no-interaction`, record it, and confirm with `git status --porcelain -- poetry.lock pyproject.toml` that it printed nothing.
  - Acceptance: Python, pytest, node, and npm versions are recorded with exit 0; the node_modules check exit code is recorded; the Pester and PSScriptAnalyzer versions (or their absence, or `PowerShell tool unavailable`, either of which selects A7-CI for Phase 0, Phase 8, and Phase 12 PowerShell tasks) are recorded.
- [x] [P0-T6] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-black-check.2026-10-09T09-00.md` from `poetry run black --check .`.
  - Acceptance: exit code and the summary line are recorded verbatim; on exit 0 the summary contains `would be left unchanged`. A non-zero exit is recorded with the listed files as pre-existing drift (baseline is read-only; nothing is reformatted here).
- [x] [P0-T7] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-ruff-check.2026-10-09T09-00.md` from `poetry run ruff check .`.
  - Acceptance: exit code and output summary recorded; on exit 0 the output is `All checks passed!`.
- [x] [P0-T8] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-pyright.2026-10-09T09-00.md` from `poetry run pyright`.
  - Acceptance: exit code and the diagnostics summary line are recorded verbatim (on exit 0: `0 errors, 0 warnings, 0 informations`).
- [x] [P0-T9] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-collect-quality-tiers.2026-10-09T09-00.md` from `poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract.py --collect-only -q` (deviation D-1).
  - Acceptance: exit 0; the final `N tests collected` line is recorded as `Baseline-Collected: N` (research derives 47; the observed value governs).
- [x] [P0-T10] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-test-names-quality-tiers.2026-10-09T09-00.md` from `grep -n -E "^def test_" tests/scripts/dev_tools/test_quality_tiers_contract.py`.
  - Acceptance: exit 0; 28 lines printed at lines 48, 68, 82, 95, 114, 163, 174, 192, 206, 215, 224, 233, 253, 262, 271, 287, 299, 312, 350, 363, 373, 396, 406, 419, 434, 446, 460, 480; the 28 function names are recorded as a sorted list.
- [x] [P0-T11] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-cov-quality-tiers.2026-10-09T09-00.md` from `poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_check_quality_tiers.py --cov=scripts.dev_tools.quality_tiers_contract --cov=scripts.dev_tools.check_quality_tiers --cov-branch --cov-report=term-missing "--cov-report=json:artifacts/python/cov-targeted.json"` followed by the COVJSON command.
  - Acceptance: exit 0; the term-missing rows for quality_tiers_contract.py and check_quality_tiers.py are recorded verbatim; the quality_tiers_contract.py `Missing` column lists 124, 155, and 199; COVJSON line and branch percentages are recorded for both modules as `Baseline-Line:` and `Baseline-Branch:`.
- [x] [P0-T12] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-cov-filesystem.2026-10-09T09-00.md` from `poetry run pytest "tests/scripts/dev_tools/test_potential_to_issue_filesystem.py" "--cov=scripts.dev_tools.potential_to_issue_filesystem" --cov-branch --cov-report=term-missing "--cov-report=json:artifacts/python/cov-targeted.json"` followed by the COVJSON command.
  - Acceptance: exit 0; `8 passed`; term-missing row and COVJSON line and branch percentages recorded.
- [x] [P0-T13] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-cov-promotion.2026-10-09T09-00.md` from `poetry run pytest "tests/scripts/dev_tools/test_potential_to_issue.py" "tests/scripts/dev_tools/test_potential_to_issue_branches.py" "tests/scripts/dev_tools/test_potential_to_issue_bug_bodies.py" "tests/scripts/dev_tools/test_potential_to_issue_cli_and_adapters.py" "tests/scripts/dev_tools/test_potential_to_issue_content.py" "tests/scripts/dev_tools/test_potential_to_issue_filesystem.py" "tests/scripts/dev_tools/test_potential_to_issue_missing_label_regression.py" "tests/scripts/dev_tools/test_potential_to_issue_move_verification.py" "tests/scripts/dev_tools/test_potential_to_issue_work_modes.py" "--cov=scripts.dev_tools.potential_to_issue" --cov-branch --cov-report=term-missing "--cov-report=json:artifacts/python/cov-targeted.json"` followed by the COVJSON command.
  - Acceptance: exit 0; pass count, term-missing row, and COVJSON line and branch percentages recorded.
- [x] [P0-T14] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-cov-bug-entry-before.2026-10-09T09-00.md` (AC-17 before-run) from `poetry run pytest "tests/scripts/dev_tools/test_new_potential_bug_entry.py" "--cov=scripts.dev_tools.new_potential_bug_entry" --cov-branch --cov-report=term-missing`.
  - Acceptance: exit 0; the module's `Missing` column is recorded verbatim and contains the arcs `181->exit`, `183->exit`, `185->exit`, and `187->exit` (the one-line Protocol stubs at lines 181, 183, 185, 187). If any of the four is absent, stop and report, because AC-17 then has no before-state to compare.
- [x] [P0-T15] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-cov-whole-repo.2026-10-09T09-00.md` from `poetry run pytest --cov --cov-branch --cov-report=term "--cov-report=json:artifacts/python/coverage.json"` followed by the COVTOTAL command.
  - Acceptance: exit code, the pytest summary line (passed, skipped, deselected, failed counts), the `TOTAL` row, and COVTOTAL `TOTAL line` and `branch` values are recorded as `Baseline-Total-Line:` and `Baseline-Total-Branch:`. A non-zero exit is recorded with every failing node ID; AC-35 then stays unchecked unless the final run exits 0.
- [x] [P0-T16] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-coverage-thresholds.2026-10-09T09-00.md` from `poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 85 --min-branch 75`.
  - Acceptance: exit code and stdout and stderr recorded verbatim (research expects no output on success; the observed output governs).
- [x] [P0-T17] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ts-prettier-check.2026-10-09T09-00.md` from `npx prettier --check "src/**/*.ts" "test/**/*.ts"` run from extensions/drm-copilot.
  - Acceptance: exit code and summary recorded; on exit 0 the output contains `All matched files use Prettier code style!`.
- [x] [P0-T18] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ts-lint.2026-10-09T09-00.md` from `npm run lint` run from extensions/drm-copilot.
  - Acceptance: exit code and output recorded verbatim (problem count line if any).
- [x] [P0-T19] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ts-typecheck.2026-10-09T09-00.md` from `npm run typecheck` run from extensions/drm-copilot.
  - Acceptance: exit code and output recorded verbatim.
- [x] [P0-T20] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ts-jest-subagent-tree.2026-10-09T09-00.md` from `npm run test:unit -- subagent-tree-command` run from extensions/drm-copilot.
  - Acceptance: exit 0; output contains `Test Suites: 1 passed, 1 total` and `Tests: 14 passed, 14 total` (whitespace between the label and the count is normalized when comparing).
- [x] [P0-T21] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ts-it-titles.2026-10-09T09-00.md` from `grep -n -E "^\s+it\(" extensions/drm-copilot/test/subagent-tree-command.test.ts` run from the repository root.
  - Acceptance: exit 0; 14 lines at lines 162, 181, 197, 219, 239, 257, 278, 320, 349, 367, 388, 425, 445, 466, recorded verbatim with their titles.
- [x] [P0-T22] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ts-jest-coverage.2026-10-09T09-00.md` from `npm run test:coverage` run from extensions/drm-copilot.
  - Acceptance: exit code, the `Test Suites:` and `Tests:` lines, and the text-summary `Statements`, `Branches`, `Functions`, and `Lines` percentages are recorded as `Baseline-Lines:` and `Baseline-Branches:`; any line containing `coverage threshold` is recorded verbatim (none is expected).
- [x] [P0-T23] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ps-pester-workflow.2026-10-09T09-00.md` from the PowerShell-tool command `$r = Invoke-Pester -Path tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 -Output Detailed -PassThru; "Passed=$($r.PassedCount) Failed=$($r.FailedCount)"` under the A7 branch rule.
  - Acceptance (A7-LOCAL): the printed line is `Passed=10 Failed=0` and the ten `It` names are recorded. Acceptance (A7-CI): the artifact records the attempt, the denial or error text, and `Outcome: LOCAL-PESTER-UNAVAILABLE`.
- [x] [P0-T24] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ps-formatter-check.2026-10-09T09-00.md` from the PowerShell-tool command `$s = Get-Content -Raw -LiteralPath tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1; $f = Invoke-Formatter -ScriptDefinition $s -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; $s -ceq $f` under the A7 branch rule.
  - Acceptance: the printed `True` or `False` is recorded (read-only comparison; no file is written). On `False`, the differing lines are recorded from `Compare-Object ($s -split '\r?\n') ($f -split '\r?\n')` as pre-existing drift.
- [x] [P0-T25] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ps-analyzer.2026-10-09T09-00.md` from the PowerShell-tool command `@(Invoke-ScriptAnalyzer -Path tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1).Count` under the A7 branch rule.
  - Acceptance: the printed finding count is recorded; when non-zero, each finding's RuleName and Line is recorded.
- [x] [P0-T26] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/line-counts.2026-10-09T09-00.md` from `grep -c "" tests/scripts/dev_tools/test_quality_tiers_contract.py scripts/dev_tools/check_quality_tiers.py tests/scripts/dev_tools/test_check_quality_tiers.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py "scripts/dev_tools/potential_to_issue.py" extensions/drm-copilot/test/subagent-tree-command.test.ts tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`.
  - Acceptance: exit 0; seven `path:count` lines recorded; test_quality_tiers_contract.py reports 495 and subagent-tree-command.test.ts reports 500.
- [x] [P0-T27] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/batch-budget-analysis.2026-10-09T09-00.md` stating the cap (3 distinct production Python files per session in direct mode; test files never counted, hook line 302; PowerShell test files never counted, hook line 299), the two production Python files this plan edits, `Resets scheduled: 0`, and the instruction to stop and report if either hook denies a write.
  - Acceptance: the file exists with `Timestamp:` and the four statements.

### Phase 1 — #734 CR-3: split the quality-tiers contract tests (pure move)

- [x] [P1-T1] Create `tests/scripts/dev_tools/quality_tiers_contract_test_support.py` holding the two helpers formerly private to the contract test file, renamed public.
  - Content: a module docstring ("Shared helpers for the quality-tiers contract test modules."), `from __future__ import annotations`, `from scripts.dev_tools.quality_tiers_contract import QualityTierEntry, QualityTierError, QualityTierManifest`, and:

    ```python
    def qt_codes(errors: list[QualityTierError]) -> list[str]:
        """Return the QT codes of ``errors`` in their reported order."""
        return [error.code for error in errors]


    def make_manifest(*entries: tuple[str, str]) -> QualityTierManifest:
        """Build an in-memory manifest from ``(path, tier)`` pairs."""
        items = tuple(QualityTierEntry(path, tier, "rationale") for path, tier in entries)
        return QualityTierManifest(version=1, entries=items)
    ```

  - Acceptance: `grep -n -e "^def qt_codes" -e "^def make_manifest" tests/scripts/dev_tools/quality_tiers_contract_test_support.py` prints exactly two lines; `poetry run black --check tests/scripts/dev_tools/quality_tiers_contract_test_support.py` prints `1 file would be left unchanged`; `poetry run ruff check tests/scripts/dev_tools/quality_tiers_contract_test_support.py` prints `All checks passed!`.
- [x] [P1-T2] Create `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py` containing, moved verbatim, the block of the pre-split contract test file from `SPEC_TIER_ASSIGNMENTS` (former line 321) through the end of `test_committed_quality_tiers_yml_assigns_spec_tiers` (former line 495).
  - Changes inside the moved block: every `_codes(` becomes `qt_codes(` and every `_manifest(` becomes `make_manifest(`. The CR-1 rename is not applied in this task.
  - Header: module docstring ("Unit tests for the quality-tiers classification and entry checks. Only the two committed-tree tests read the committed quality-tiers.yml, read-only."), `from __future__ import annotations`, `from pathlib import Path`, `import pytest`, the imports `find_classification_errors`, `find_entry_errors`, `parse_quality_tiers` from scripts.dev_tools.quality_tiers_contract, `from tests.scripts.dev_tools.quality_tiers_contract_test_support import make_manifest, qt_codes`, and `REPO_ROOT = Path(__file__).resolve().parents[3]`.
  - Acceptance: `grep -c -E "^def test_" tests/scripts/dev_tools/test_quality_tiers_contract_classification.py` prints 10; `grep -c -e "^def _codes" -e "^def _manifest" tests/scripts/dev_tools/test_quality_tiers_contract_classification.py` prints 0.
- [x] [P1-T3] Edit `tests/scripts/dev_tools/test_quality_tiers_contract.py` to remove the moved block (former lines 321-495), remove the `_codes` and `_manifest` definitions (former lines 37-45), replace every remaining `_codes(` with `qt_codes(`, add `from tests.scripts.dev_tools.quality_tiers_contract_test_support import qt_codes`, and remove imports and constants left unused (`Path`, `REPO_ROOT`, `QualityTierManifest`, `find_classification_errors`, `find_entry_errors`).
  - Acceptance: `grep -c -E "^def test_" tests/scripts/dev_tools/test_quality_tiers_contract.py` prints 18; `grep -c -e "^def _codes" -e "^def _manifest" tests/scripts/dev_tools/test_quality_tiers_contract.py` prints 0; `poetry run ruff check tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py` prints `All checks passed!`.
- [x] [P1-T4] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/quality-tiers-split-collect.2026-10-09T09-00.md` from `poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py --collect-only -q` and, as a second block, `poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py -q`.
  - Acceptance: the collected count equals `Baseline-Collected` from [P0-T9]; the second command exits 0 with `N passed` where N equals that same count.

### Phase 2 — #734 CR-1 and CR-2

- [x] [P2-T1] Edit `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py` to rename `test_find_classification_errors_empty_project_set_reports_qt007_for_every_entry` to the annotated signature quoted here: "def test_find_classification_errors_empty_projects_reports_qt007() -> None:". The docstring and body are unchanged.
  - Acceptance: `grep -rn --include="*.py" -e "test_find_classification_errors_empty_project_set_reports_qt007_for_every_entry" tests/` prints nothing; `grep -rn --include="*.py" -F -e "def test_find_classification_errors_empty_projects_reports_qt007() -> None:" tests/` prints exactly one line. (`--include="*.py"` excludes the compiled `__pycache__` files, which retain the old name.)
- [x] [P2-T2] Add three `pytest.param` entries at the end of the parameter list of `test_parse_quality_tiers_rejects_schema_violation_with_qt003` in `tests/scripts/dev_tools/test_quality_tiers_contract.py`:

    ```python
            pytest.param(
                "version: true\nprojects:\n" + _VALID_ENTRY_TEXT, id="version-bool"
            ),
            pytest.param(
                'version: "1"\nprojects:\n' + _VALID_ENTRY_TEXT, id="version-string"
            ),
            pytest.param("version: 1\n", id="missing-projects"),
    ```

  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract.py -k "version-bool or version-string or missing-projects" -q` exits 0 with `3 passed`.
- [x] [P2-T3] Add `test_parse_quality_tiers_non_scalar_key_reports_qt002` to `tests/scripts/dev_tools/test_quality_tiers_contract.py`, placed after `test_parse_quality_tiers_rejects_non_mapping_root_with_qt002`:

    ```python
    def test_parse_quality_tiers_non_scalar_key_reports_qt002() -> None:
        """A mapping key that is not a scalar yields QT002 and no manifest."""
        # Arrange
        text = "? [a, b]\n: 1\nversion: 1\n"

        # Act
        manifest, errors = parse_quality_tiers(text)

        # Assert
        assert manifest is None
        assert qt_codes(errors) == ["QT002"]
    ```

  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract.py -k "non_scalar_key" -q` exits 0 with `1 passed`. (No message substring is asserted; spec R3.)
- [x] [P2-T4] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/quality-tiers-names-after.2026-10-09T09-00.md` from `poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py --collect-only -q` and, as a second block, `grep -h -E "^def test_" tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py`.
  - Acceptance (AC-2): collected count equals `Baseline-Collected` + 4; the second block prints 29 names, and the recorded name-by-name comparison against the [P0-T10] sorted list shows exactly one removed name (`test_find_classification_errors_empty_project_set_reports_qt007_for_every_entry`) and exactly two added names (`test_find_classification_errors_empty_projects_reports_qt007`, `test_parse_quality_tiers_non_scalar_key_reports_qt002`).
- [x] [P2-T5] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/quality-tiers-helper-and-rename.2026-10-09T09-00.md` recording, as separate blocks: `grep -n -e "^def _codes" -e "^def _manifest" tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py tests/scripts/dev_tools/quality_tiers_contract_test_support.py` (`ExpectedExitCode: 1`, prints nothing); `grep -n -e "^def qt_codes" -e "^def make_manifest" tests/scripts/dev_tools/quality_tiers_contract_test_support.py` (two lines); `grep -rn --include="*.py" -e "test_find_classification_errors_empty_project_set_reports_qt007_for_every_entry" tests/` (exit 1, nothing); `grep -rn --include="*.py" -F -e "def test_find_classification_errors_empty_projects_reports_qt007() -> None:" tests/` (one line); `poetry run black --check tests/scripts/dev_tools/test_quality_tiers_contract_classification.py` (`would be left unchanged`); `poetry run ruff check tests/scripts/dev_tools/test_quality_tiers_contract_classification.py` (`All checks passed!`).
  - Acceptance: every block shows the stated result (AC-1 and AC-3 verification; plain grep is used because the new files are untracked).
- [x] [P2-T6] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-1 (change only `- [ ]` to `- [x]`) after [P2-T5] passes.
- [x] [P2-T7] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-2 after [P1-T4] and [P2-T4] pass.
- [x] [P2-T8] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-3 after [P2-T5] passes.

### Phase 3 — #734 CR-4: QT009 reports git stderr

- [x] [P3-T1] Edit `tests/scripts/dev_tools/test_check_quality_tiers.py`: add the field `stderr: bytes = b""` after `stdout: bytes` in `FakeRunResult`, and add two tests after `test_main_returns_one_with_qt009_when_git_exits_nonzero`:

    ```python
    def test_qt009_message_includes_git_stderr(
        capsys: pytest.CaptureFixture[str],
    ) -> None:
        """A non-zero git exit reports git's stderr text on the single QT009 line."""

        # Arrange
        def fake_run(argv: Sequence[str], **kwargs: object) -> FakeRunResult:
            del argv, kwargs
            return FakeRunResult(
                returncode=128, stdout=b"", stderr=b"fatal: not a git repository\n"
            )

        lister = functools.partial(
            list_tracked_files, which=lambda name: "git", run=fake_run
        )

        # Act
        exit_code = main(
            [], read_manifest_text=_reader(SMALL_MANIFEST_TEXT), list_tracked_files=lister
        )

        # Assert
        lines = _assert_failure_output(capsys)
        assert exit_code == 1
        assert len(lines) == 1, f"expected one QT009 line: {lines}"
        assert lines[0].startswith("QT009: ")
        assert "fatal: not a git repository" in lines[0]


    def test_qt009_message_collapses_multiline_git_stderr(
        capsys: pytest.CaptureFixture[str],
    ) -> None:
        """Multi-line git stderr is collapsed onto the single QT009 line."""

        # Arrange
        def fake_run(argv: Sequence[str], **kwargs: object) -> FakeRunResult:
            del argv, kwargs
            return FakeRunResult(
                returncode=128,
                stdout=b"",
                stderr=b"fatal: first line\nhint: second line\n",
            )

        lister = functools.partial(
            list_tracked_files, which=lambda name: "git", run=fake_run
        )

        # Act
        exit_code = main(
            [], read_manifest_text=_reader(SMALL_MANIFEST_TEXT), list_tracked_files=lister
        )

        # Assert
        lines = _assert_failure_output(capsys)
        assert exit_code == 1
        assert len(lines) == 1, f"expected one QT009 line: {lines}"
        assert lines[0].startswith("QT009: ")
        assert "fatal: first line hint: second line" in lines[0]
    ```

  - Acceptance: `grep -c -E "^def test_" tests/scripts/dev_tools/test_check_quality_tiers.py` prints 16 (baseline 14); the production file is untouched at this point: `git diff --numstat e7d3779b398604af919678c16c877c8539a86cc0 -- scripts/dev_tools/check_quality_tiers.py` prints nothing and `git status --porcelain -- scripts/dev_tools/check_quality_tiers.py` prints nothing.
- [x] [P3-T2] [expect-fail] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/qt009-fail-before.2026-10-09T09-00.md` from `poetry run pytest tests/scripts/dev_tools/test_check_quality_tiers.py -k "qt009_message" -q` run against the unchanged production file, with `ExpectedExitCode: 1`.
  - Acceptance: exit 1; output reports `2 failed`; the assertion failure for `test_qt009_message_includes_git_stderr` (missing `fatal: not a git repository`) is quoted in the Output Summary (AC-6 observed fail-before run).
- [x] [P3-T3] Edit `scripts/dev_tools/check_quality_tiers.py`: add a read-only `stderr` property to the `GitRunResult` Protocol after `stdout`, in the same multi-line form, and replace the non-zero-exit raise in `list_tracked_files`:

    ```python
        @property
        def stderr(self) -> bytes:
            """Captured standard error."""
            ...
    ```

    ```python
        if result.returncode != 0:
            # Collapse git's stderr to one line: _report prints one QTnnn line per
            # error, and an embedded newline would emit a line without the prefix.
            detail = " ".join(result.stderr.decode("utf-8", errors="replace").split())
            message = f"git ls-files exited with code {result.returncode}"
            if detail:
                message = f"{message}: {detail}"
            raise OSError(message)
    ```

  - Acceptance: `poetry run black --check scripts/dev_tools/check_quality_tiers.py` prints `1 file would be left unchanged`; `poetry run ruff check scripts/dev_tools/check_quality_tiers.py` prints `All checks passed!`; the file is not denied by the Python batch-budget hook (first counted production file).
- [x] [P3-T4] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/qt009-pass-after.2026-10-09T09-00.md` from `poetry run pytest tests/scripts/dev_tools/test_check_quality_tiers.py -q` and, as a second block, `poetry run pyright scripts/dev_tools/check_quality_tiers.py tests/scripts/dev_tools/test_check_quality_tiers.py tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py tests/scripts/dev_tools/quality_tiers_contract_test_support.py`.
  - Acceptance: first block exit 0 with `16 passed` (includes both new tests and the existing `test_main_returns_one_with_qt009_when_git_exits_nonzero`, which drives the empty-stderr branch); second block prints `0 errors, 0 warnings, 0 informations`.
- [x] [P3-T5] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/quality-tiers-coverage.2026-10-09T09-00.md` from `poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py tests/scripts/dev_tools/test_check_quality_tiers.py --cov=scripts.dev_tools.quality_tiers_contract --cov=scripts.dev_tools.check_quality_tiers --cov-branch --cov-report=term-missing "--cov-report=json:artifacts/python/cov-targeted.json"` followed by the COVJSON command.
  - Acceptance (AC-4): exit 0; the quality_tiers_contract.py `Missing` column contains none of 124, 155, 199 (the file is unchanged, so the line numbers are stable); check_quality_tiers.py COVJSON line >= 85 and branch >= 75; both term-missing rows recorded verbatim.
- [x] [P3-T6] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/quality-tiers-cli.2026-10-09T09-00.md` from `poetry run python -m scripts.dev_tools.check_quality_tiers`.
  - Acceptance (AC-7): exit 0; stdout is exactly one line beginning `quality-tiers: OK (`, recorded verbatim.
- [x] [P3-T7] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/qt009-message-form.2026-10-09T09-00.md` from `poetry run pytest tests/scripts/dev_tools/test_check_quality_tiers.py -k "qt009" -v`.
  - Acceptance (AC-5 behavior half): exit 0; the PASSED node IDs recorded are `test_main_returns_one_with_qt009_when_runner_raises_oserror`, `test_main_returns_one_with_qt009_when_git_exits_nonzero`, `test_main_returns_one_with_qt009_when_git_not_found`, `test_main_reports_entry_errors_alongside_qt009`, `test_qt009_message_includes_git_stderr`, and `test_qt009_message_collapses_multiline_git_stderr` (6 passed).
- [x] [P3-T8] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-4 after [P3-T5] passes.
- [x] [P3-T9] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-6 after [P3-T2] and [P3-T4] pass.
- [x] [P3-T10] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-7 after [P3-T6] passes.

### Phase 4 — #744: skill cross-reference, pin test, and evidence notes

The replacement sentence used by [P4-T3] through [P4-T5] is quoted here verbatim; it replaces the whole line "Orchestrators do not directly check off AC items. Instead:":

```text
Orchestrators do not directly check off AC items. The one exception is a CI-dependent criterion, which the item's own orchestrator run checks off at S9 as described in `### CI-Dependent Criteria` above. For every other criterion, orchestrators instead:
```

- [x] [P4-T1] Add `test_acceptance_criteria_tracking_skill_cross_references_ci_dependent_exception` to `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`, placed after `test_acceptance_criteria_tracking_skill_defines_ci_dependent_rule`:

    ```python
    @pytest.mark.parametrize(
        "skill_path",
        [path for _, path in AC_TRACKING_SKILLS],
        ids=[skill_id for skill_id, _ in AC_TRACKING_SKILLS],
    )
    def test_acceptance_criteria_tracking_skill_cross_references_ci_dependent_exception(
        skill_path: Path,
    ) -> None:
        """The orchestrator check-off rule names the CI-dependent exception."""
        # Arrange
        fragments = (
            "Orchestrators do not directly check off AC items. The one exception is a"
            " CI-dependent criterion",
            "as described in `### CI-Dependent Criteria` above. For every other"
            " criterion, orchestrators instead:",
        )

        # Act / Assert
        _assert_section_contains(skill_path, "## Check-Off Protocol", fragments)
    ```

  - Acceptance: `grep -c -F -e "def test_acceptance_criteria_tracking_skill_cross_references_ci_dependent_exception" tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` prints 1; `poetry run black --check tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` prints `1 file would be left unchanged`.
- [x] [P4-T2] [expect-fail] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/ac-pin-fail-before.2026-10-09T09-00.md` from `poetry run pytest tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py -k "cross_references_ci_dependent_exception" -q` run before any SKILL.md edit, with `ExpectedExitCode: 1`.
  - Acceptance: exit 1; output reports `3 failed` (ids claude, agents, github), each naming the missing fragment.
- [x] [P4-T3] Replace the sentence line in `.claude/skills/acceptance-criteria-tracking/SKILL.md` (line 91, section "### When Orchestrators Enforce AC Tracking") with the quoted replacement sentence; no other byte changes.
  - Acceptance: `git diff --numstat e7d3779b398604af919678c16c877c8539a86cc0 -- .claude/skills/acceptance-criteria-tracking/SKILL.md` prints `1	1	.claude/skills/acceptance-criteria-tracking/SKILL.md`.
- [x] [P4-T4] Replace the sentence line in `.agents/skills/acceptance-criteria-tracking/SKILL.md` (line 89) with the quoted replacement sentence; no other byte changes.
  - Acceptance: `git diff --numstat e7d3779b398604af919678c16c877c8539a86cc0 -- .agents/skills/acceptance-criteria-tracking/SKILL.md` prints `1	1	.agents/skills/acceptance-criteria-tracking/SKILL.md`.
- [x] [P4-T5] Replace the sentence line in `.github/skills/acceptance-criteria-tracking/SKILL.md` (line 89) with the quoted replacement sentence; no other byte changes.
  - Acceptance: `git diff --numstat e7d3779b398604af919678c16c877c8539a86cc0 -- .github/skills/acceptance-criteria-tracking/SKILL.md` prints `1	1	.github/skills/acceptance-criteria-tracking/SKILL.md`.
- [x] [P4-T6] Replace `extensions/drm-copilot/resources/claude-customizations/.claude/skills/acceptance-criteria-tracking/SKILL.md` by byte copy from the edited .claude source with the Bash tool: `cp -- .claude/skills/acceptance-criteria-tracking/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/acceptance-criteria-tracking/SKILL.md`.
  - Acceptance: `cmp -- .claude/skills/acceptance-criteria-tracking/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/acceptance-criteria-tracking/SKILL.md` exits 0 and prints nothing.
- [x] [P4-T7] Replace `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/acceptance-criteria-tracking/SKILL.md` by byte copy from the edited .agents source with the Bash tool: `cp -- .agents/skills/acceptance-criteria-tracking/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/acceptance-criteria-tracking/SKILL.md`.
  - Acceptance: `cmp -- .agents/skills/acceptance-criteria-tracking/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/acceptance-criteria-tracking/SKILL.md` exits 0 and prints nothing.
- [x] [P4-T8] Replace `extensions/drm-copilot/resources/customizations/.github/skills/acceptance-criteria-tracking/SKILL.md` by byte copy from the edited .github source with the Bash tool: `cp -- .github/skills/acceptance-criteria-tracking/SKILL.md extensions/drm-copilot/resources/customizations/.github/skills/acceptance-criteria-tracking/SKILL.md`.
  - Acceptance: `cmp -- .github/skills/acceptance-criteria-tracking/SKILL.md extensions/drm-copilot/resources/customizations/.github/skills/acceptance-criteria-tracking/SKILL.md` exits 0 and prints nothing.
- [x] [P4-T9] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/ac-tracking-sentence.2026-10-09T09-00.md` from `git grep -c -F -e "The one exception is a CI-dependent criterion" -- .claude/skills/acceptance-criteria-tracking/SKILL.md .agents/skills/acceptance-criteria-tracking/SKILL.md .github/skills/acceptance-criteria-tracking/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/acceptance-criteria-tracking/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/acceptance-criteria-tracking/SKILL.md extensions/drm-copilot/resources/customizations/.github/skills/acceptance-criteria-tracking/SKILL.md` and, as a second block, `git grep -n -F -e "check off AC items. Instead:" -- .claude/skills/acceptance-criteria-tracking/SKILL.md .agents/skills/acceptance-criteria-tracking/SKILL.md .github/skills/acceptance-criteria-tracking/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/acceptance-criteria-tracking/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/acceptance-criteria-tracking/SKILL.md extensions/drm-copilot/resources/customizations/.github/skills/acceptance-criteria-tracking/SKILL.md`.
  - Acceptance (AC-8): first block exit 0 with six lines, each ending `:1`; second block exit 1 and prints nothing (recorded in its block as expected exit 1).
- [x] [P4-T10] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/ac-pin-pass-after.2026-10-09T09-00.md` from `poetry run pytest tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_minor_audit_acceptance_criteria_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_csharp_orchestration_contracts.py -v`.
  - Acceptance (AC-9): exit 0; zero failed; the PASSED lines include `test_acceptance_criteria_tracking_skill_cross_references_ci_dependent_exception[claude]`, `[agents]`, and `[github]`, `test_acceptance_criteria_tracking_skill_defines_ci_dependent_rule` (three ids), `test_edited_surface_matches_bundled_mirror[claude-ac-tracking]`, `[agents-ac-tracking]`, `[github-ac-tracking]`, and `test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
- [x] [P4-T11] Edit `docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/regression-testing/pester-doc-contracts.2026-09-30T03-18.md`: change line 3 to `Timestamp: 2026-10-02T01-43` and insert as the new line 4 exactly: "Timestamp-Correction: original value 2026-10-02T01-44 was later than the file's observed write time 01:43:48 recorded in code-review.2026-10-02T02-55.md (CR-5); corrected under #846."
  - Acceptance: `git diff --numstat e7d3779b398604af919678c16c877c8539a86cc0 -- docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/regression-testing/pester-doc-contracts.2026-09-30T03-18.md` reports 2 added and 1 deleted.
- [x] [P4-T12] Edit `docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/qa-gates/acceptance-criteria-checkoff.2026-09-30T03-18.md` by inserting, immediately after line 3 (`Timestamp: 2026-10-02T01-52`), one new line exactly: "Note (added under #846, policy-audit PA-2): this file is a summary artifact of other evidence; no command was executed to produce it, so it carries no Command or EXIT_CODE row." No existing line is changed.
  - Acceptance: `git diff --numstat e7d3779b398604af919678c16c877c8539a86cc0 -- docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/qa-gates/acceptance-criteria-checkoff.2026-09-30T03-18.md` reports 1 added and 0 deleted.
- [x] [P4-T13] Edit `docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/other/ac-status-summary-local.2026-09-30T03-18.md` by inserting, immediately after line 3 (`Timestamp: 2026-10-02T01-55`), the same note line as [P4-T12]. No existing line is changed.
  - Acceptance: `git diff --numstat e7d3779b398604af919678c16c877c8539a86cc0 -- docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/other/ac-status-summary-local.2026-09-30T03-18.md` reports 1 added and 0 deleted.
- [x] [P4-T14] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-744-checks.2026-10-09T09-00.md` recording, as separate blocks: `git grep -n -e "^Timestamp" -- docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/regression-testing/pester-doc-contracts.2026-09-30T03-18.md` (two lines, at lines 3 and 4); `git diff --numstat e7d3779b398604af919678c16c877c8539a86cc0 -- docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/qa-gates/acceptance-criteria-checkoff.2026-09-30T03-18.md docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/other/ac-status-summary-local.2026-09-30T03-18.md` (deleted column 0 for both); `git grep -n -e "^Command:" -e "^EXIT_CODE:" -- docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/qa-gates/acceptance-criteria-checkoff.2026-09-30T03-18.md docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/other/ac-status-summary-local.2026-09-30T03-18.md` (exit 1, nothing); `git grep -n -F -e "summary artifact" -- docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/qa-gates/acceptance-criteria-checkoff.2026-09-30T03-18.md docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/other/ac-status-summary-local.2026-09-30T03-18.md` (exactly one line per file).
  - Acceptance (AC-10, AC-11): every block shows the stated result.
- [x] [P4-T15] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-8 after [P4-T9] passes.
- [x] [P4-T16] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-9 after [P4-T2] and [P4-T10] pass.
- [x] [P4-T17] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-10 after [P4-T14] passes.
- [x] [P4-T18] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-11 after [P4-T14] passes.

### Phase 5 — #647 CR-3 (second half): split the subagent-tree command tests

The file in this phase that belongs to item #844 (the orchestration-handoff-authority-service test under extensions/drm-copilot/test/lib/validate) is not opened for writing at any point.

- [x] [P5-T1] Create `extensions/drm-copilot/test/subagent-tree-command-test-support.ts` exporting, moved verbatim from the pre-split test file: the constants `WORKSPACE_ROOT`, `CLAUDE_PROJECTS_ROOT`, `MATCHING_DIR` (former lines 15-23, with their doc comments), the classes `FakeTerminalWriter` and `FakeFileTimes` (former lines 75-103), and the functions `agentToolUseLine` and `addRootSession` (former lines 126-146), each prefixed with `export`.
  - Imports, exactly: `import type { TerminalWriter } from "../src/terminal-writer";`, `import type { FileTimes } from "../src/lib/file-system";`, `import { InMemoryFileSystem } from "./lib/subagent-tree/in-memory-file-system";`. No `jest.mock` call, no import of `vscode` or `../src/command-runtime`, and no value import of `../src/terminal-writer`.
  - Acceptance: `grep -c -E "^export " extensions/drm-copilot/test/subagent-tree-command-test-support.ts` prints 7; `grep -c "jest.mock" extensions/drm-copilot/test/subagent-tree-command-test-support.ts` prints 0.
- [x] [P5-T2] Create `extensions/drm-copilot/test/subagent-tree-command.quick-pick.test.ts` containing: the `@jest/globals` import block; `import type` lines for `TerminalWriter` and `FileTimes`; the `InMemoryFileSystem` import; its own copy of the `type CommandHandler = () => Promise<void> | void;` alias (former line 13, used by the mock declarations and `activateAndGetHandler`); imports of `CLAUDE_PROJECTS_ROOT`, `MATCHING_DIR`, `WORKSPACE_ROOT`, `FakeFileTimes`, `FakeTerminalWriter`, `addRootSession` from `./subagent-tree-command-test-support`; its own copy of the mock declarations and the three `jest.mock` blocks (former lines 25-71); the `registerSubagentTreeCommand` import; its own copy of `activateAndGetHandler` (former lines 105-124); and `describe("drm-copilot showSubagentTree command quick pick", ...)` with the same `beforeEach` and `afterEach` bodies (former lines 149-160) and the four `it` blocks moved verbatim from former lines 388-499.
  - Names outside the copied ranges, re-derived against the pre-split file: the quick-pick file needs `CommandHandler` (line 13; used at lines 25, 34, 110), the `TerminalWriter` and `FileTimes` types (lines 9-10; used by `activateAndGetHandler` at lines 108-109), and `InMemoryFileSystem` (line 11; used at line 107 and in the moved `it` blocks); the `PickItem`, `PickResult`, `PickFn`, and `RootFn` aliases (lines 26-29) are inside the copied mock range; `agentToolUseLine` is not used by former lines 388-499 and is not imported.
  - Acceptance: `grep -c -E "^\s+it\(" extensions/drm-copilot/test/subagent-tree-command.quick-pick.test.ts` prints 4; `grep -c -E "^type CommandHandler" extensions/drm-copilot/test/subagent-tree-command.quick-pick.test.ts` prints 1.
- [x] [P5-T3] Edit `extensions/drm-copilot/test/subagent-tree-command.test.ts`: remove the four `it` blocks moved in [P5-T2] (former lines 388-499) and the constants, classes, and helper functions moved in [P5-T1], and import those names from `./subagent-tree-command-test-support`. The `type CommandHandler` alias (line 13), the `import type` lines for `TerminalWriter` and `FileTimes`, the `InMemoryFileSystem` import, the mock declarations, the three `jest.mock` blocks, `activateAndGetHandler`, the `describe` hooks, and the ten `it` blocks at former lines 162-367 stay unchanged (the kept file still uses all seven moved names, including `agentToolUseLine` at former line 288 and `FakeFileTimes` at former line 109).
  - Acceptance: `grep -c -E "^\s+it\(" extensions/drm-copilot/test/subagent-tree-command.test.ts` prints 10; `grep -c -E "^(class|function) (FakeTerminalWriter|FakeFileTimes|agentToolUseLine|addRootSession)" extensions/drm-copilot/test/subagent-tree-command.test.ts` prints 0.
- [x] [P5-T4] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/ts-split-jest.2026-10-09T09-00.md` from `npm run test:unit -- subagent-tree-command` run from extensions/drm-copilot and, as a second block, `grep -h -E "^\s+it\(" extensions/drm-copilot/test/subagent-tree-command.test.ts extensions/drm-copilot/test/subagent-tree-command.quick-pick.test.ts` run from the repository root.
  - Acceptance (AC-13): first block exit 0 with `Test Suites: 2 passed, 2 total` and `Tests: 14 passed, 14 total`; second block prints 14 lines whose sorted text equals the sorted 14 [P0-T21] lines with their `N:` line-number prefix removed, with the first ten printed lines coming from the kept file and the last four from the quick-pick file (grep reads the two files in the order given).
- [x] [P5-T5] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/ts-support-imports.2026-10-09T09-00.md` from `grep -n -e "from \"vscode\"" -e "command-runtime\"" -e "terminal-writer\"" extensions/drm-copilot/test/subagent-tree-command-test-support.ts` and, as a second block, `npm run typecheck` run from extensions/drm-copilot.
  - Acceptance (AC-12): the first block prints exactly one line, whose text after the `N:` line-number prefix begins `import type { TerminalWriter }`; the second block exits 0.
- [x] [P5-T6] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/protected-file-844.2026-10-09T09-00.md` from `git diff --name-only e7d3779b398604af919678c16c877c8539a86cc0 -- extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts` and, as a second block, `git status --porcelain --untracked-files=all -- extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts`.
  - Acceptance (AC-14 interim): both blocks exit 0 and print nothing.
- [x] [P5-T7] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-12 after [P5-T5] passes.
- [x] [P5-T8] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-13 after [P5-T4] passes.

### Phase 6 — #623: coverage configuration, plan text, and documentation parity

- [x] [P6-T1] Edit `pyproject.toml`: insert one line immediately after the closing `]` of `[tool.coverage.report] exclude_lines` (line 140), exactly: `partial_also = ["^\\s*(async\\s+)?def\\s.*:\\s*\\.\\.\\.\\s*(#.*)?$"]`. No other line changes; no `omit`, `exclude_lines`, `exclude_also`, or `[tool.coverage.run]` change.
  - Acceptance (AC-16 diff half): `git diff --numstat e7d3779b398604af919678c16c877c8539a86cc0 -- pyproject.toml` prints `1	0	pyproject.toml`; `git diff -U0 e7d3779b398604af919678c16c877c8539a86cc0 -- pyproject.toml` shows one `+partial_also = ` content line and no removed content line (the diff's file-header lines are not content lines).
- [x] [P6-T2] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/partial-also-after.2026-10-09T09-00.md` (AC-17 after-run) from `poetry run pytest "tests/scripts/dev_tools/test_new_potential_bug_entry.py" "--cov=scripts.dev_tools.new_potential_bug_entry" --cov-branch --cov-report=term-missing`.
  - Acceptance: exit 0; the module's `Missing` column is recorded verbatim and contains none of `181->exit`, `183->exit`, `185->exit`, `187->exit`; the before-and-after `Missing` columns from [P0-T14] and this run are shown side by side; the `Stmts` value is identical in both runs (no line left the denominator).
- [x] [P6-T3] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/filesystem-coverage-after.2026-10-09T09-00.md` from `poetry run pytest "tests/scripts/dev_tools/test_potential_to_issue_filesystem.py" "--cov=scripts.dev_tools.potential_to_issue_filesystem" --cov-branch --cov-report=term-missing "--cov-report=json:artifacts/python/cov-targeted.json"`, then the COVJSON command, then `git diff --name-only e7d3779b398604af919678c16c877c8539a86cc0 -- "tests/scripts/dev_tools/test_potential_to_issue_filesystem.py"`, then `git status --porcelain -- "tests/scripts/dev_tools/test_potential_to_issue_filesystem.py"`.
  - Acceptance (AC-18): pytest exit 0 with `8 passed`; COVJSON line >= 85 and branch >= 75; both git blocks print nothing; `grep -c -F -e "def test_file_system_protocol_members_declare_no_behavior" "tests/scripts/dev_tools/test_potential_to_issue_filesystem.py"` prints 1.
- [x] [P6-T4] Edit `docs/features/active/promotion-receipt-destination-unverified-623/plan.2026-09-29T19-06.md` header: set line 6 to `- **Last Updated:** ` followed by the host-clock value in yyyy-MM-ddTHH-mm form, and replace line 7 with exactly: "- **Status:** Complete (revision 1.2; preflight cleared; all tasks checked; merged; status corrected under #846; previous value: Draft, revision 1.2, awaiting preflight round 3)".
  - Acceptance: `git grep -n -F -e "pending validator and executor preflight round 3" -- docs/features/active/promotion-receipt-destination-unverified-623/plan.2026-09-29T19-06.md` exits 1 and prints nothing.
- [x] [P6-T5] Append to the end of line 228 ([P5-T3]) of `docs/features/active/promotion-receipt-destination-unverified-623/plan.2026-09-29T19-06.md`, after confirming `grep -c -E "^def test_" "tests/scripts/dev_tools/test_potential_to_issue_filesystem.py"` prints 8 (assumption A3; stop and report if it prints any other value), exactly: " Correction (#846): the file holds eight tests at HEAD. The eighth, test_file_system_protocol_members_declare_no_behavior, was added during execution to cover Protocol stub branch arcs (evidence/qa-gates/py-test-coverage-pass1-failed.2026-09-30T08-46.md). #846 kept that test and added the repository-wide partial_also coverage setting in pyproject.toml. The corrected P5-T5 expectation is 8 passed." The original text "exactly seven tests" stays in place.
  - Acceptance: `git grep -c -F -e "exactly seven tests" -- docs/features/active/promotion-receipt-destination-unverified-623/plan.2026-09-29T19-06.md` prints a count of 1.
- [x] [P6-T6] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-623-plan-checks.2026-10-09T09-00.md` from `git grep -n -F -e "#846" -- docs/features/active/promotion-receipt-destination-unverified-623/plan.2026-09-29T19-06.md` and, as a second block, `git grep -n -F -e "pending validator and executor preflight round 3" -- docs/features/active/promotion-receipt-destination-unverified-623/plan.2026-09-29T19-06.md`.
  - Acceptance (AC-19): first block prints exactly two lines, at line 7 and line 228; second block exits 1 and prints nothing.
- [x] [P6-T7] Edit `scripts/dev_tools/potential_to_issue.py` docstring line 94 (`exit_code (int): Final process-style exit code.`) into, keeping the 8-space indentation and the 12-space continuation indentation:

    ```text
            exit_code (int): Final process-style exit code: 0 on success; the gh
                create exit code when issue creation fails; 1 when the promoted
                file is missing after the move.
    ```

  - Acceptance: `grep -c -F -e "1 when the promoted" "scripts/dev_tools/potential_to_issue.py"` prints 1; the Python batch-budget hook allows the write (second counted production file).
- [x] [P6-T8] Edit `scripts/dev_tools/potential_to_issue.py` by inserting, immediately above the line `if not filesystem.exists(dest_path):` (line 348 before [P6-T7]), these three comment lines at 4-space indentation, matching the TypeScript comment at promotion.ts lines 440-442 except for "raised" in place of "thrown":

    ```text
        # Verify the move produced the destination before reporting success. A
        # missing destination is a non-zero outcome (not a raised error) so the
        # caller still receives every emitted line, including the created issue URL.
    ```

  - Acceptance: `grep -c -F -e "not a raised error" "scripts/dev_tools/potential_to_issue.py"` prints 1.
- [x] [P6-T9] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/promotion-docs.2026-10-09T09-00.md` recording, as separate blocks: `git diff --numstat e7d3779b398604af919678c16c877c8539a86cc0 -- "scripts/dev_tools/potential_to_issue.py"` (6 added, 1 deleted); `git diff -U0 e7d3779b398604af919678c16c877c8539a86cc0 -- "scripts/dev_tools/potential_to_issue.py"` (every `+` and `-` content line is a docstring or `#` comment line, quoted in the summary); `poetry run black --check "scripts/dev_tools/potential_to_issue.py"` (`would be left unchanged`); `poetry run ruff check "scripts/dev_tools/potential_to_issue.py"` (`All checks passed!`); `poetry run pyright "scripts/dev_tools/potential_to_issue.py"` (`0 errors, 0 warnings, 0 informations`); `poetry run pytest "tests/scripts/dev_tools/test_potential_to_issue_move_verification.py" -q` (exit 0).
  - Acceptance (AC-20): every block shows the stated result.
- [x] [P6-T10] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/promotion-coverage.2026-10-09T09-00.md` from the same pytest command as [P0-T13] followed by the COVJSON command.
  - Acceptance: exit 0; the pass count equals [P0-T13]; COVJSON line >= 85 and branch >= 75 for the promotion module; line and branch values equal the [P0-T13] values (no executable change).
- [x] [P6-T11] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-17 after [P0-T14] and [P6-T2] pass.
- [x] [P6-T12] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-18 after [P6-T3] passes.
- [x] [P6-T13] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-19 after [P6-T6] passes.
- [x] [P6-T14] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-20 after [P6-T9] and [P6-T10] pass.

### Phase 7 — Documentation and evidence corrections (#764, #338, #609, #543, #527, #510)

The anchored pattern used in this phase, quoted verbatim: `^- When the rule fires and no qualifying green-run evidence is present, record a Blocking finding and route it through the standard remediation handoff\.$`

- [x] [P7-T1] Edit line 39 ([P1-T1] acceptance) of `docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/plan.2026-09-30T05-00.md`: replace the inline command beginning `git grep -nxF` with `git grep -n -e "^- When the rule fires and no qualifying green-run evidence is present, record a Blocking finding and route it through the standard remediation handoff\.$" -- .claude/skills/feature-review-workflow/SKILL.md`, and append to the end of the line exactly: " (Corrected under #846: the original command was git grep -nxF with the same quoted text; that form is invalid because git grep has no -x option and exits 129.)"
  - Acceptance: line 39 contains `git grep -n -e "^- When` and ends with `exits 129.)`.
- [x] [P7-T2] Edit line 40 ([P1-T2] acceptance) of `docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/plan.2026-09-30T05-00.md` the same way, with the path operand extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md and the same appended correction note.
  - Acceptance: line 40 contains `git grep -n -e "^- When` and ends with `exits 129.)`.
- [x] [P7-T3] Edit line 66 (AC mapping row) of `docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/plan.2026-09-30T05-00.md`: replace the cell text "P1-T1 exact-line `git grep -nxF`" with "P1-T1 anchored `git grep -n -e "^...$"` exact-line check (corrected under #846 from the invalid git grep -nxF form)".
  - Acceptance: line 66 still has six `|` cell delimiters and contains `corrected under #846`.
- [x] [P7-T4] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/764-corrected-grep-current.2026-10-09T09-00.md` with `ExpectedExitCode: 1` from `git grep -n -e "^- When the rule fires and no qualifying green-run evidence is present, record a Blocking finding and route it through the standard remediation handoff\.$" -- .claude/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`.
  - Acceptance (deviation D-2): exit 1 with no output, and the summary records that line 75 of both copies now carries the later `awaiting_ci` wording (quoted from `git grep -n -F -e "When the rule fires and no qualifying green-run evidence is present" -- .claude/skills/feature-review-workflow/SKILL.md`, recorded as a second block). An exit of 0 instead is also acceptable and is recorded as such (it would mean the #764 text is present on the current tree).
- [x] [P7-T5] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/764-corrected-grep-historical.2026-10-09T09-00.md` recording the mechanical derivation and run for each of the two SKILL.md paths separately: `git log --format=%H -S"route it through the standard remediation handoff." -- .claude/skills/feature-review-workflow/SKILL.md` (the first printed SHA is X1, the newest commit that changed the count of that literal), then `git grep -n -e "^- When the rule fires and no qualifying green-run evidence is present, record a Blocking finding and route it through the standard remediation handoff\.$" "X1^" -- .claude/skills/feature-review-workflow/SKILL.md` with X1 substituted; and the same two commands for extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md (yielding X2).
  - Acceptance (AC-21 validity of the corrected form): each `git grep` against its parent tree exits 0 and prints exactly one line ending in `handoff.`; X1 and X2 and their subject lines (from `git log -1 --format="%h %s"`) are recorded. If either `git log -S` prints no SHA, stop and report.
- [x] [P7-T6] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-764-plan-checks.2026-10-09T09-00.md` from `git grep -c -e "-nxF" -- docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/plan.2026-09-30T05-00.md` and, as a second block, `git grep -c -e "#846.*-nxF" -- docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/plan.2026-09-30T05-00.md`.
  - Acceptance (AC-21 residual form check): both blocks print the count 3, so every remaining `-nxF` occurrence is inside a #846 correction note (lines 39, 40, 66).
- [x] [P7-T7] Create `docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/evidence/other/evidence-filename-timestamps.2026-10-09T09-00.md` (superseding note, no rename) with: `Timestamp:` (host clock); `Command: git grep -n -e "^Timestamp:" -- docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/evidence/`; `EXIT_CODE:`; `Output Summary:` (12 lines printed, 11 of them in files stamped 2026-09-30T05-20); `Supersedes: none (clarifies the filename stamps)`; a table of the 11 files with columns File, Filename stamp, Recorded Timestamp, whose separator row is written exactly `| --- | --- | --- |`; and the statement "The filename stamp 2026-09-30T05-20 was the plan-assigned stamp; the Timestamp field is the authoritative run time. No file is renamed (written under #846)."
  - Table rows, verified on 2026-10-09 (folder-relative path; recorded Timestamp): evidence/baseline/baseline-citation-grep.2026-09-30T05-20.md 2026-09-30T09-50; evidence/baseline/baseline-code-source-diff.2026-09-30T05-20.md 2026-09-30T09-50; evidence/baseline/baseline-pytest.2026-09-30T05-20.md 2026-09-30T09-49; evidence/baseline/baseline-rootfolders-diff.2026-09-30T05-20.md 2026-09-30T09-50; evidence/baseline/minor-audit-preconditions.2026-09-30T05-20.md 2026-09-30T09-48; evidence/qa-gates/final-citation-grep.2026-09-30T05-20.md 2026-09-30T09-58; evidence/qa-gates/final-pytest.2026-09-30T05-20.md 2026-09-30T09-58; evidence/qa-gates/final-rootfolders-diff.2026-09-30T05-20.md 2026-09-30T09-58; evidence/qa-gates/final-toolchain-applicability.2026-09-30T05-20.md 2026-09-30T09-58; evidence/regression-testing/edit-diff.2026-09-30T05-20.md 2026-09-30T09-55; evidence/regression-testing/targeted-parity-test.2026-09-30T05-20.md 2026-09-30T09-55. The executor re-reads each value from the recorded command output; a mismatch is recorded with the observed value.
  - Acceptance: `grep -c -F -e "2026-09-30T05-20.md" docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/evidence/other/evidence-filename-timestamps.2026-10-09T09-00.md` prints at least 11.
- [x] [P7-T8] Edit line 5 of `docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/issue.md` to read exactly "- Status: Promoted -> docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/ (Issue #764)". The prior value is retained in the closure-dispositions record (deviation D-5).
  - Acceptance: `git diff --numstat e7d3779b398604af919678c16c877c8539a86cc0 -- docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/issue.md` reports 1 added and 1 deleted.
- [x] [P7-T9] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-764-checks.2026-10-09T09-00.md` recording, as separate blocks: `git grep -n -F -e "Promoted -> docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/" -- docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/issue.md` (one line, line 5); `git diff --name-status --diff-filter=DR e7d3779b398604af919678c16c877c8539a86cc0 -- docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/` (nothing); `git status --porcelain --untracked-files=all -- docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/` (every listed entry is one of the three #764 paths this plan writes, with status `??` or ` M`, and no entry has a `D` or `R` status; an empty result is acceptable when the work has been committed); `grep -c -F -e "| " docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/evidence/other/evidence-filename-timestamps.2026-10-09T09-00.md` (at least 13 table lines: header, separator, 11 rows).
  - Acceptance (AC-22, AC-23): every block shows the stated result.
- [x] [P7-T10] Edit line 44 (AC-3) of `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/issue.md`, keeping the `- [x]` checkbox: replace the location clause so it names the three test files extensions/drm-copilot/test/lib/new-potential-bug-entry-launcher.test.ts, extensions/drm-copilot/test/lib/new-active-feature-folder/io.test.ts, and extensions/drm-copilot/test/lib/new-active-feature-folder/io-launcher.test.ts and states that the default lookup helper tests are in io-launcher.test.ts; replace the command with npm run test:unit -- test/lib/new-potential-bug-entry-launcher.test.ts test/lib/new-active-feature-folder/io.test.ts test/lib/new-active-feature-folder/io-launcher.test.ts; and append " (AC text corrected under #846; the original text named only io.test.ts; verifying run: evidence/regression-testing/ac3-jest-new-tests.2026-10-08T02-45.md.)". In the file, every path and the command are formatted as inline code.
  - Acceptance: `git grep -c -F -e "io-launcher.test.ts" -- docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/issue.md` prints a count of at least 1, and `git grep -n -F -e "- [x] New TypeScript tests pass" -- docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/issue.md` prints one line.
- [x] [P7-T11] Edit line 66 of `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/issue.md`: replace the parenthetical "(`new_potential_bug_entry.py`, `new_active_feature_folder_io.py`, and their bundled mirrors)" with "(`new_potential_bug_entry.py`, `new_active_feature_folder_io.py`, `new-potential-bug-entry.ts`, `io-launcher.ts`)".
  - Acceptance: line 66 contains `io-launcher.ts` and does not contain `bundled`.
- [x] [P7-T12] Edit line 68 of `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/issue.md`: delete the substring " (root and bundled copies)" so the line ends "from both `_resolve_code_cli()` docstrings."
  - Acceptance: line 68 does not contain `bundled`.
- [x] [P7-T13] Edit line 38 of `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/issue.md`: replace "in both the root and bundled copies of `_resolve_code_cli()`." with "in both `_resolve_code_cli()` docstrings, in `new_potential_bug_entry.py` and `new_active_feature_folder_io.py`."
  - Acceptance: line 38 does not contain `bundled`.
- [x] [P7-T14] Add to `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/issue.md`, under `## Actual Behavior` immediately after the paragraph edited in [P7-T13], a blank line and the line exactly: "Correction (#846): no bundled mirror copies of the two Python modules exist (code-review.2026-10-08T07-05.md CR-3)."
  - Acceptance: `git grep -c -F -e "Correction (#846): no bundled mirror copies" -- docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/issue.md` prints a count of 1.
- [x] [P7-T15] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/ac3-338-jest.2026-10-09T09-00.md` from `npm run test:unit -- test/lib/new-potential-bug-entry-launcher.test.ts test/lib/new-active-feature-folder/io.test.ts test/lib/new-active-feature-folder/io-launcher.test.ts` run from extensions/drm-copilot.
  - Acceptance (AC-24): exit 0; `Test Suites: 3 passed, 3 total`; the `Tests:` line is recorded verbatim (61 total is derived from the recorded #338 run, 34 skipped + 27 passed under `-t launcher-gap`; the observed value governs, with zero failed).
- [x] [P7-T16] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-338-checks.2026-10-09T09-00.md` from `git grep -n -i -e "bundled" -- docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/issue.md`.
  - Acceptance (AC-25): exit 0 and exactly one line printed, the correction note from [P7-T14].
- [x] [P7-T17] Create `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/evidence/other/ac-status-summary.2026-10-09T09-00.md` containing, in order:
  - Title line "# AC status summary (superseding; written under #846)".
  - `Timestamp:` (host clock); `Command: git grep -c -e "^- \[x\] " -- docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/spec.md`; `EXIT_CODE:` (observed); `Output Summary:` (the printed `path:count` line; 17 was observed by the planner on 2026-10-09).
  - A second command block for the total: `git grep -c -e "^- \[[ x]\] " -- docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/spec.md` (17 observed by the planner).
  - Shell-guard branch: the #609 folder name contains a shell name, and the agent-worktree command-text guard may deny a command containing it. If either command is denied, run the equivalent quoted-pathspec form instead, `git grep -c -e "^- \[x\] " -- 'docs/features/active/2026-08-30-*-609/spec.md'` (and the same form for the total), record that form in `Command:`, and add a `Command-Note:` line naming the denial. Git resolves the quoted pathspec to the same single spec.md, so the printed count is the same.
  - `Supersedes:` listing evidence/other/ac-gaps.2026-09-29T18-45.md, evidence/other/ac-status-summary.2026-09-29T18-45.md, evidence/qa-gates/coverage-comparison.2026-09-29T18-45.md, evidence/regression-testing/fail-before-exception.2026-09-29T18-45.md, with the statement that those four files are retained unchanged as point-in-time records.
  - `### Acceptance Criteria Status` with Source (the #609 spec.md), Total AC items, Checked off (delivered), Remaining (unchecked), and Items remaining, each taken from the two command outputs.
  - A resolution table: AC-6 resolved by evidence/regression-testing/bats-unit-before.2026-10-02T03-53.md (fail-first CI run 36961456506; pass-after run 36960736942); AC-14 resolved by evidence/qa-gates/ci-per-file-coverage.2026-10-02T03-44.md (per-file line-rate 0.989 on the PR head and on main).
  - Acceptance: `grep -c -e "^### Acceptance Criteria Status" docs/features/active/2026-08-30-*-609/evidence/other/ac-status-summary.2026-10-09T09-00.md` (the unquoted shell glob expands to the single new file) prints 1 and the Checked and Total values equal the two recorded command outputs.
- [x] [P7-T18] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-609-checks.2026-10-09T09-00.md` from `git diff --name-only e7d3779b398604af919678c16c877c8539a86cc0 -- 'docs/features/active/2026-08-30-*-609/evidence/other/ac-gaps.2026-09-29T18-45.md' 'docs/features/active/2026-08-30-*-609/evidence/other/ac-status-summary.2026-09-29T18-45.md' 'docs/features/active/2026-08-30-*-609/evidence/qa-gates/coverage-comparison.2026-09-29T18-45.md' 'docs/features/active/2026-08-30-*-609/evidence/regression-testing/fail-before-exception.2026-09-29T18-45.md'` and, as a second block, `git status --porcelain --untracked-files=all -- 'docs/features/active/2026-08-30-*-609/'`. The quoted pathspecs are resolved by git (the wildcard matches only the #609 folder) and keep the folder's shell-name segment out of the command text.
  - Acceptance (AC-26): first block prints nothing; second block prints either nothing (work already committed) or exactly one line, `?? ` followed by the new summary path.
- [x] [P7-T19] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/543-commit-dates.2026-10-09T09-00.md` from `git log -1 --format="%H %ad %cd" 0c6abb95` and, as a second block (assumption A6), `git log --format="%h %ad" -S"### Reset 1 (P2-T4)" -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md`.
  - Acceptance: first block prints the full SHA 0c6abb952153b38726ae65a5c0b438adc37e6e8b with its author and committer dates (research expects an author time of 05:14:57 -0400); second block lists at least one commit, and the oldest listed commit's author time is recorded as `Reset1-First-Commit:` with the decision `A6-APPLY` when that time is earlier than 2026-10-02 05:18 local to the recorded offset, otherwise `A6-SKIP`.
- [x] [P7-T20] Edit `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md`: set line 3 to `Timestamp: 2026-10-02T05-14` and replace line 4 with exactly: "Timestamp-Correction: original value 2026-10-02T05-01 was a reused reading rather than a clock reading; a first correction to 2026-10-02T05-18 (observed file write time, remediation-inputs.2026-10-02T07-08.md) was later than commit 0c6abb95 (authored 2026-10-02 05:14:57 -04:00), which already contained this row; the value is now that commit time, an upper bound on the write time (corrected under #846, code-review.2026-10-07T09-34.md CR-11)." If [P7-T19] observed a different author time for 0c6abb95, the observed time is used in both lines instead.
  - Branch A6-APPLY: also set line 32 to `Timestamp:` followed by the `Reset1-First-Commit` time in yyyy-MM-ddTHH-mm form, and append to line 33 " Corrected under #846: the prior value 2026-10-02T05-18 was later than the first commit containing this section, so the value is now that commit time." Branch A6-SKIP: lines 32-33 are unchanged and the observation is recorded in the closure-dispositions record.
  - Acceptance: `git grep -n -e "^Timestamp" -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md` shows `Timestamp: 2026-10-02T05-14` at line 3 and the new correction at line 4.
- [x] [P7-T21] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-543-checks.2026-10-09T09-00.md` from `git diff --name-only e7d3779b398604af919678c16c877c8539a86cc0 -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/` and, as a second block, `git status --porcelain --untracked-files=all -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/`.
  - Acceptance (AC-27): the first block prints exactly the python-batch-budget evidence path; the second block prints nothing other than that same path with status ` M` (no `??` entry).
- [x] [P7-T22] Add a `### Changed` subsection to `extensions/drm-copilot/CHANGELOG.md` directly under `## [Unreleased]` (line 8), separated by blank lines, before `## [0.0.1] - 2026-05-02`. Text (from research section "Item #527"; in the file, Invoke-PoshQCTest, config/poshqc-coverage.json, the JSON shape, CodeCoverage.Path, settings/pester.runsettings.psd1, and -SettingsPath are formatted as inline code):

    ```text
    ### Changed

    - PoshQC code-coverage population (issue #527): Invoke-PoshQCTest derives the measured
      file set from the workspace. Declare coverage roots in config/poshqc-coverage.json at
      the workspace root ({"version": 1, "roots": [...]}). A CodeCoverage.Path list in the
      module's shipped settings/pester.runsettings.psd1 is now ignored, and the ignore is
      logged. A caller-supplied settings file (-SettingsPath) with a non-empty
      CodeCoverage.Path is still honored. Without the configuration file, the population
      falls back to the effective test scan folders. Migration: move any coverage paths that
      were added to the shipped settings file into config/poshqc-coverage.json.
    ```

  - Acceptance: `git diff --numstat e7d3779b398604af919678c16c877c8539a86cc0 -- extensions/drm-copilot/CHANGELOG.md` reports 0 deleted lines.
- [x] [P7-T23] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-527-checks.2026-10-09T09-00.md` from `git grep -n -E -e "^##+ " -- extensions/drm-copilot/CHANGELOG.md` and, as a second block, `git grep -n -F -e "config/poshqc-coverage.json" -- extensions/drm-copilot/CHANGELOG.md`.
  - Acceptance (AC-28): the first three heading lines printed are, in order, `## [Unreleased]` (line 8), `### Changed`, and `## [0.0.1] - 2026-05-02`; the second block prints at least one line.
- [x] [P7-T24] Edit lines 6 and 7 of `docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/spec.md`: line 6 becomes `- **Last Updated:** ` followed by the host-clock value in yyyy-MM-ddTHH-mm form; line 7 becomes exactly "- **Status:** Implemented (all 13 acceptance criteria checked; reviewed in code-review.2026-10-07T15-30.md; status corrected under #846, previously Draft)".
  - Acceptance: line 7 begins `- **Status:** Implemented`.
- [x] [P7-T25] Edit line 45 of `docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/spec.md`: replace "gitignored at `.gitignore` line 68" with "gitignored at `.gitignore` line 70 (corrected under #846; previously cited as 68)".
  - Acceptance: line 45 contains `line 70 (corrected under #846`.
- [x] [P7-T26] Edit line 61 of `docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/spec.md`: "(`.gitignore` line 21)" becomes "(`.gitignore` line 23)"; "`agent-memory` (line 67), `state` (line 68), and `worktrees` (line 21)" becomes "`agent-memory` (line 69), `state` (line 70), and `worktrees` (line 23)"; append " (Line numbers corrected under #846; previously cited as 21, 67, and 68.)" to the end of the line. These values were re-read from .gitignore on 2026-10-09 (line 23 `.claude/worktrees`, line 69 `.claude/agent-memory`, line 70 `.claude/state/`).
  - Acceptance: line 61 contains `(line 69)`, `(line 70)`, and `(line 23)`.
- [x] [P7-T27] Edit line 174 of `docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/spec.md`: in the stored rc-file path, replace the segment `evidence/coverage/coveragerc-helper.ini` with `evidence/other/coveragerc-helper.ini`, and insert " (path corrected under #846; previously named under the coverage evidence folder)" immediately after the closing backtick of that path. The checkbox stays checked.
  - Acceptance: line 174 contains `evidence/other/coveragerc-helper.ini` and begins `- [x] `.
- [x] [P7-T28] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-510-checks.2026-10-09T09-00.md` with `ExpectedExitCode: 1` from `git grep -n -e "line 68" -e "line 67" -e "line 21" -e "evidence/coverage/" -e "Status:\*\* Draft" -- docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/spec.md` and, as a second block, `git grep -n -e "line 23" -e "line 69" -e "line 70" -e "evidence/other/coveragerc-helper.ini" -- docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/spec.md`.
  - Acceptance (AC-29): first block exits 1 and prints nothing; second block prints lines 45, 61, and 174.
- [x] [P7-T29] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-21 after [P7-T4], [P7-T5], and [P7-T6] pass.
- [x] [P7-T30] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-22 after [P7-T7] and [P7-T9] pass.
- [x] [P7-T31] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-23 after [P7-T9] passes.
- [x] [P7-T32] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-24 after [P7-T10] and [P7-T15] pass.
- [x] [P7-T33] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-25 after [P7-T16] passes.
- [x] [P7-T34] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-26 after [P7-T17] and [P7-T18] pass.
- [x] [P7-T35] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-27 after [P7-T19], [P7-T20], and [P7-T21] pass.
- [x] [P7-T36] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-28 after [P7-T23] passes.
- [x] [P7-T37] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-29 after [P7-T28] passes.

### Phase 8 — #723: Pester pin, tightened exit assertions, and runbook command

The workflow file under test (.github/workflows/publish-mcp-npm.yml) is read by the tests and is not written by this plan.

- [ ] [P8-T1] Add a new `It` block to `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`, inserted immediately before the final closing `}` of the `Describe` block:

    ```powershell
        # Issue #723 refinement, closed under #846: the poll step's error message states that the
        # publish step succeeded. That statement holds only while the poll step keeps the default
        # success() status check (no always(), failure(), or cancelled() in its if: expression),
        # the publish step cannot report success after a failure (no continue-on-error), and the
        # poll step runs after the publish step.
        It "runs the registry poll step only after a successful publish step" {
            $script:pollStep | Should -Not -BeNullOrEmpty
            $script:publishStep | Should -Not -BeNullOrEmpty

            $pollConditions = @(($script:pollStep.Text -split "`n") | Where-Object { $_ -match '^\s+if:' })
            $pollConditions.Count | Should -Be 1
            $pollConditions[0] | Should -Not -Match 'always\(\)|failure\(\)|cancelled\(\)'

            $script:publishStep.Text | Should -Not -Match 'continue-on-error'
            $script:pollStep.Index | Should -BeGreaterThan $script:publishStep.Index
        }
    ```

  - Acceptance: `grep -c -F -e "runs the registry poll step only after a successful publish step" tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` prints 1; the write is not denied by the PowerShell test-purity hook.
- [ ] [P8-T2] Replace the equality-step assertion at line 110 of `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` (`$script:equalityStep.Text | Should -Match '(?m)^\s*exit 1\s*$'`) with these two lines at the same indentation:

    ```powershell
            [regex]::Matches($script:equalityStep.Text, '(?m)^\s*exit 1\s*$').Count | Should -Be 1
            $script:equalityStep.Text | Should -Match '(?s)if \(\$tagVersion -ne \$manifestVersion\) \{[^}]*::error::[^}]*\bexit 1\b[^}]*\}'
    ```

  - Acceptance: `grep -c -F -e 'if \(\$tagVersion -ne \$manifestVersion\) \{' tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` prints 1.
- [ ] [P8-T3] Replace the poll-step assertion at line 125 of `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` (`$script:pollStep.Text | Should -Match '(?m)^\s*exit 1\s*$'`) with:

    ```powershell
            [regex]::Matches($script:pollStep.Text, '(?m)^\s*exit 1\s*$').Count | Should -Be 1
            $script:pollStep.Text | Should -Match '(?s)if \(-not \$resolved\) \{[^}]*::error::[^}]*\bexit 1\b[^}]*\}'
    ```

  - Acceptance: `grep -c -F -e 'if \(-not \$resolved\) \{' tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` prints 1.
- [ ] [P8-T4] Replace the poll-step assertion `$text | Should -Match '(?m)^\s*exit 1\s*$'` (line 224 before [P8-T2] and [P8-T3]; located by content) in `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` with:

    ```powershell
            [regex]::Matches($text, '(?m)^\s*exit 1\s*$').Count | Should -Be 1
            $text | Should -Match '(?s)if \(-not \$resolved\) \{[^}]*::error::[^}]*\bexit 1\b[^}]*\}'
    ```

  - Acceptance: `grep -c -F -e 'if \(-not \$resolved\) \{' tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` prints 2 (the [P8-T3] line and this line); `grep -c -F -e "exit 1\s*\$').Count | Should -Be 1" tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` prints 3 (the [P8-T2], [P8-T3], and [P8-T4] count assertions); the generic all-pwsh-steps rule (the `$exitsExplicitly` line) is unchanged.
- [ ] [P8-T5] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/pester-workflow-after.2026-10-09T09-00.md` from the PowerShell-tool command `$r = Invoke-Pester -Path tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 -Output Detailed -PassThru; "Passed=$($r.PassedCount) Failed=$($r.FailedCount)"` under the A7 branch rule.
  - Acceptance (A7-LOCAL; AC-30, AC-31 Pester half): the printed line is `Passed=11 Failed=0` and the Detailed output lists `runs the registry poll step only after a successful publish step` as passed. Acceptance (A7-CI): `Outcome: LOCAL-PESTER-UNAVAILABLE` recorded with the denial or error text.
- [ ] [P8-T6] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-723-exit1-checks.2026-10-09T09-00.md` with `ExpectedExitCode: 1` from `git grep -n -F -e "Should -Match '(?m)^\s*exit 1\s*$'" -- tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`.
  - Acceptance (AC-31 text half): exit 1 and nothing printed.
- [ ] [P8-T7] Add the `npm view` command to `docs/engineering/missed-npm-publish.runbook.md` in section "Red verify step after a green publish step", immediately after line 134 ("Check the exact version on the registry instead of re-running the publish, because re-publishing an existing version fails."): a blank line, a fenced code block containing the single line `npm view @danmoisan/drm-copilot-mcp@<version> version` (deviation D-6), a blank line, and the sentence "Substitute the version under investigation for `<version>`."
  - Acceptance: `git diff --numstat e7d3779b398604af919678c16c877c8539a86cc0 -- docs/engineering/missed-npm-publish.runbook.md` reports 0 deleted lines.
- [ ] [P8-T8] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-723-runbook-checks.2026-10-09T09-00.md` from `git grep -n -F -e "npm view @danmoisan/drm-copilot-mcp@" -- docs/engineering/missed-npm-publish.runbook.md` and, as a second block, `git grep -n -E -e "^## " -- docs/engineering/missed-npm-publish.runbook.md`.
  - Acceptance (AC-32): the first block prints at least one line whose line number is greater than that of `## Red verify step after a green publish step` and less than that of the next `## ` heading (`## VERSION_CONSUMED_ELSEWHERE`), both read from the second block.
- [ ] [P8-T9] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/workflow-unchanged.2026-10-09T09-00.md` from `git diff --name-only e7d3779b398604af919678c16c877c8539a86cc0 -- .github/workflows/`, then `git status --porcelain --untracked-files=all -- .github/workflows/`, then `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q`.
  - Acceptance (AC-33): the two git blocks print nothing; pytest exits 0 with zero failed.
- [ ] [P8-T10] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-30 only under A7-LOCAL after [P8-T5] passes; under A7-CI leave AC-30 unchecked and list it as pending-CI in [P13-T11].
- [ ] [P8-T11] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-31 only under A7-LOCAL after [P8-T5] and [P8-T6] pass; under A7-CI leave AC-31 unchecked and list it as pending-CI in [P13-T11].
- [ ] [P8-T12] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-32 after [P8-T8] passes.
- [ ] [P8-T13] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-33 after [P8-T9] passes.

### Phase 9 — Fail-before exception dossier

- [ ] [P9-T1] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/fail-before-exception.2026-10-09T09-00.md` with `Timestamp:`, `WhyFailingRunImpossible:`, and an alternative-proof section covering each change without an observed failing run: (1) #723 new `It` block and tightened `exit 1` assertions (they pin invariants that already hold; a failing run requires a workflow edit, which is out of scope; proof: [P0-T23] and [P8-T5] or the A7-CI record); (2) #734 CR-2 cases (new tests of existing behavior; proof: [P0-T11] Missing lists 124, 155, 199 and [P3-T5] does not); (3) #623 partial_also (configuration only; proof: [P0-T14] versus [P6-T2]); (4) the #647 test split (no behavior change; proof: [P0-T20] versus [P5-T4]); (5) documentation and evidence corrections for #744 CR-5 and PA-2, #764, #338, #609, #543, #527, #510, and #723 N1 (no executable behavior; proof: the doc-check artifacts of Phases 4, 7, and 8). It also states the two observed fail-before runs: [P3-T2] (#734 CR-4) and [P4-T2] (#744 CR-1 pin).
  - Acceptance: the file exists with the three required elements and five numbered entries, each citing an artifact path under FEATURE/evidence.

### Phase 10 — Python final QC loop

Loop rule: run [P10-T1] through [P10-T9] in order. If any step fails, or a remediation command rewrites a file, fix the cause, record the iteration number in every artifact, and restart at [P10-T1]. The loop ends when one pass completes with every step passing. Architecture-boundary, contract, and integration stages are not configured for these files and are recorded in [P10-T11].

Pre-existing-failure rule: a step whose Phase 0 baseline ([P0-T6] for [P10-T1], [P0-T7] for [P10-T2], [P0-T8] for [P10-T3], [P0-T15] for [P10-T8], [P0-T16] for [P10-T9]) exited non-zero passes the final pass when every failing file, diagnostic, or node ID it reports was already recorded in that baseline and none names a file in "Files Written by This Plan". It records `Outcome: PRE-EXISTING-FAILURE-ONLY`, does not restart the loop, no out-of-scope file is edited to clear it, and the dependent criteria stay unchecked and are added to the pending list in [P13-T11]: AC-36 for [P10-T1] and [P10-T2]; AC-5 and AC-36 for [P10-T3]; AC-35 for [P10-T8] and [P10-T9]. ([P0-T6] and [P0-T7] are included beside the three named baselines so that black and ruff drift in files outside this plan cannot force a write to those files.) A verification task whose acceptance cannot be met only because of a recorded PRE-EXISTING-FAILURE-ONLY outcome (for example [P10-T10] when [P10-T8] did not exit 0) stays unchecked, is listed in [P13-T11] with that reason, and is counted in [P13-T12].

- [ ] [P10-T1] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-black-check.2026-10-09T09-00.md` from `poetry run black --check .`.
  - Acceptance: exit 0; the summary contains `would be left unchanged` and no `would reformat` line; or `Outcome: PRE-EXISTING-FAILURE-ONLY` under the pre-existing-failure rule. Remediation on failure: record the `would reformat` paths; run `poetry run black` on only those listed paths that appear in "Files Written by This Plan" (observe each `reformatted` line), then restart the loop; any other listed path is handled under the pre-existing-failure rule and is not rewritten.
- [ ] [P10-T2] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-ruff-check.2026-10-09T09-00.md` from `poetry run ruff check .`.
  - Acceptance: exit 0 and `All checks passed!`; or `Outcome: PRE-EXISTING-FAILURE-ONLY` under the pre-existing-failure rule. No `--fix` is run over paths outside "Files Written by This Plan".
- [ ] [P10-T3] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-pyright.2026-10-09T09-00.md` from `poetry run pyright`.
  - Acceptance: exit 0 and `0 errors, 0 warnings, 0 informations` (AC-5 type-check half); or `Outcome: PRE-EXISTING-FAILURE-ONLY` under the pre-existing-failure rule.
- [ ] [P10-T4] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-cov-quality-tiers.2026-10-09T09-00.md` from the [P3-T5] pytest command followed by the COVJSON command.
  - Acceptance: exit 0; quality_tiers_contract.py `Missing` contains none of 124, 155, 199; check_quality_tiers.py line >= 85 and branch >= 75 (COVJSON); both values and the [P0-T11] baselines recorded side by side.
- [ ] [P10-T5] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-cov-promotion.2026-10-09T09-00.md` from the [P0-T13] pytest command followed by the COVJSON command.
  - Acceptance: exit 0; promotion module line >= 85 and branch >= 75; values recorded beside [P0-T13].
- [ ] [P10-T6] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-cov-filesystem.2026-10-09T09-00.md` from the [P0-T12] pytest command followed by the COVJSON command.
  - Acceptance: exit 0 with `8 passed`; line >= 85 and branch >= 75; values recorded beside [P0-T12].
- [ ] [P10-T7] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-contract-tests.2026-10-09T09-00.md` from `poetry run pytest tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_minor_audit_acceptance_criteria_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_csharp_orchestration_contracts.py --cov=scripts.dev_tools.validate_orchestrator_state --cov-branch --cov-report=term-missing` (deviation D-4).
  - Acceptance: exit 0 with zero failed; the coverage row is recorded for form only (unchanged module, no threshold asserted).
- [ ] [P10-T8] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-cov-whole-repo.2026-10-09T09-00.md` from `poetry run pytest --cov --cov-branch --cov-report=term "--cov-report=json:artifacts/python/coverage.json"` followed by the COVTOTAL command.
  - Acceptance: exit 0, or `Outcome: PRE-EXISTING-FAILURE-ONLY` under the pre-existing-failure rule (every failing node ID already recorded in [P0-T15]); the pytest summary line, the `TOTAL` row, and COVTOTAL line and branch values recorded as `Post-Total-Line:` and `Post-Total-Branch:`.
- [ ] [P10-T9] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-coverage-thresholds.2026-10-09T09-00.md` from `poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 85 --min-branch 75`.
  - Acceptance: exit 0, or `Outcome: PRE-EXISTING-FAILURE-ONLY` under the pre-existing-failure rule (the same diagnostics already recorded in [P0-T16]); stdout and stderr recorded verbatim.
- [ ] [P10-T10] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-coverage-comparison.2026-10-09T09-00.md` reporting baseline ([P0-T15]) versus post-change ([P10-T8]) total line and branch, per-module baseline versus post values from [P0-T11], [P0-T12], [P0-T13] and [P10-T4] to [P10-T6], and new or changed-code coverage: for check_quality_tiers.py, the changed executable lines (the `detail`, `message`, `if detail`, and `raise` lines of the non-zero branch) are absent from the [P10-T4] `Missing` column (100% of changed executable lines covered); for the promotion module, the change is docstring and comments only (no changed executable line).
  - Acceptance (AC-35 no-regression half): Post-Total-Line >= Baseline-Total-Line and Post-Total-Branch >= Baseline-Total-Branch; post totals >= 85 line and >= 75 branch; every changed production module >= 85 line and >= 75 branch.
- [ ] [P10-T11] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-stages-not-applicable.2026-10-09T09-00.md` recording that the architecture-boundary, contract or schema compatibility, and integration stages of the seven-stage loop are not configured for the Python files in scope (no Python architecture tool; no schema or API contract in scope; no external-system adapter in scope), with `Timestamp:` and the loop iteration count from [P10-T1].
  - Acceptance: the file exists with the three stage statements and the iteration count.
- [ ] [P10-T12] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-loop-summary.2026-10-09T09-00.md` listing each [P10-T1] through [P10-T9] artifact with its EXIT_CODE and any `Outcome:` line for the final pass, and the pass number.
  - Acceptance: nine rows, all from the same pass number, each showing EXIT_CODE 0 or `Outcome: PRE-EXISTING-FAILURE-ONLY`; every PRE-EXISTING-FAILURE-ONLY row names its dependent criteria.
- [ ] [P10-T13] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-5 after [P3-T7] passes and [P10-T3] exits 0; when [P10-T3] recorded PRE-EXISTING-FAILURE-ONLY, AC-5 stays unchecked and is on the pending list.
- [ ] [P10-T14] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-35 after [P10-T8] and [P10-T9] exit 0 and [P10-T10] passes; otherwise AC-35 stays unchecked and is on the pending list.
- [ ] [P10-T15] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-36 after [P10-T12] records EXIT_CODE 0 for [P10-T1] through [P10-T7]; otherwise AC-36 stays unchecked and is on the pending list.

### Phase 11 — TypeScript final QC loop

Loop rule: run [P11-T1] through [P11-T5] in order from extensions/drm-copilot. If any step fails or a remediation rewrites a file, fix the cause, record the iteration number, and restart at [P11-T1]. No task in this plan runs `npm run format`, `npm run lint -- --fix`, or any other write-mode formatter or fixer over paths outside "Files Written by This Plan".

Pre-existing-failure rule: a step whose Phase 0 baseline ([P0-T17] for [P11-T1], [P0-T18] for [P11-T2], [P0-T19] for [P11-T3], [P0-T22] for [P11-T5]) exited non-zero passes the final pass when every failing file, diagnostic, or node ID it reports was already recorded in that baseline and none names a file in "Files Written by This Plan". It records `Outcome: PRE-EXISTING-FAILURE-ONLY`, does not restart the loop, no out-of-scope file is edited to clear it, and the dependent criteria stay unchecked and are added to the pending list in [P13-T11]: AC-37 for each of those steps, and also AC-15 for [P11-T5]. A verification task whose acceptance cannot be met only because of a recorded PRE-EXISTING-FAILURE-ONLY outcome (for example [P11-T6] when [P11-T5] did not exit 0) stays unchecked, is listed in [P13-T11] with that reason, and is counted in [P13-T12].

- [ ] [P11-T1] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-prettier-check.2026-10-09T09-00.md` from `npx prettier --check "src/**/*.ts" "test/**/*.ts"`.
  - Acceptance: exit 0 and `All matched files use Prettier code style!`; or `Outcome: PRE-EXISTING-FAILURE-ONLY` under the pre-existing-failure rule. Remediation on failure: record the `[warn]` paths printed by the failing check; if every listed path is one of test/subagent-tree-command.test.ts, test/subagent-tree-command.quick-pick.test.ts, test/subagent-tree-command-test-support.ts (paths relative to extensions/drm-copilot, as Prettier prints them), run `npx prettier --write` on those listed paths only, then restart the loop; the observation is the recorded before-list and the restarted check printing `All matched files use Prettier code style!`. Any other listed path is handled under the pre-existing-failure rule and is not rewritten (when the list mixes both kinds, only the listed paths of the three named files are rewritten).
- [ ] [P11-T2] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-lint.2026-10-09T09-00.md` from `npm run lint`.
  - Acceptance: exit 0, or `Outcome: PRE-EXISTING-FAILURE-ONLY` under the pre-existing-failure rule; output recorded verbatim with no error or warning line naming test/subagent-tree-command.test.ts, test/subagent-tree-command.quick-pick.test.ts, or test/subagent-tree-command-test-support.ts.
- [ ] [P11-T3] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-typecheck.2026-10-09T09-00.md` from `npm run typecheck`.
  - Acceptance: exit 0 (covers `tsc -p ./` and `typecheck:test`), or `Outcome: PRE-EXISTING-FAILURE-ONLY` under the pre-existing-failure rule.
- [ ] [P11-T4] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-jest-subagent-tree.2026-10-09T09-00.md` from `npm run test:unit -- subagent-tree-command`.
  - Acceptance: exit 0; `Test Suites: 2 passed, 2 total` and `Tests: 14 passed, 14 total`.
- [ ] [P11-T5] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-jest-coverage.2026-10-09T09-00.md` from `npm run test:coverage`.
  - Acceptance (AC-15): exit 0, or `Outcome: PRE-EXISTING-FAILURE-ONLY` under the pre-existing-failure rule; no output line contains `coverage threshold` together with `src/subagent-tree-command.ts`; the `Tests:` line shows the [P0-T22] total; text-summary `Lines` and `Branches` percentages recorded as `Post-Lines:` and `Post-Branches:`.
- [ ] [P11-T6] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-coverage-comparison.2026-10-09T09-00.md` reporting Baseline-Lines and Baseline-Branches ([P0-T22]) beside Post-Lines and Post-Branches ([P11-T5]) and stating that no production TypeScript file changed (changed-code coverage not applicable; collectCoverageFrom in jest.config.cjs is src only, so the new test-support module under test/ is outside the coverage population and needs no threshold entry).
  - Acceptance: Post-Lines >= Baseline-Lines and Post-Branches >= Baseline-Branches; post values >= 85 and >= 75.
- [ ] [P11-T7] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-stages-not-applicable.2026-10-09T09-00.md` recording that dependency-cruiser is not configured in extensions/drm-copilot and that contract and integration stages do not apply to a test-only split, with the [P11-T1] iteration count.
  - Acceptance: the file exists with both statements.
- [ ] [P11-T8] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-loop-summary.2026-10-09T09-00.md` listing [P11-T1] through [P11-T5] with their EXIT_CODE and any `Outcome:` line from one pass.
  - Acceptance: five rows, same pass number, each showing EXIT_CODE 0 or `Outcome: PRE-EXISTING-FAILURE-ONLY`; every PRE-EXISTING-FAILURE-ONLY row names its dependent criteria.
- [ ] [P11-T9] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-15 after [P11-T5] exits 0 and meets its acceptance; when [P11-T5] recorded PRE-EXISTING-FAILURE-ONLY, AC-15 stays unchecked and is on the pending list.
- [ ] [P11-T10] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-37 after [P11-T8] records EXIT_CODE 0 for all five rows; otherwise AC-37 stays unchecked and is on the pending list.

### Phase 12 — PowerShell final QC (test file only)

Loop rule: run [P12-T1] through [P12-T3] in order under the A7 branch rule. If the formatter comparison prints `False`, write the formatted text back with the PowerShell-tool command `Set-Content -LiteralPath tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 -Value $f -NoNewline` (the comparison then prints `True` on the rerun) and restart at [P12-T1].

- [ ] [P12-T1] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ps-formatter-check.2026-10-09T09-00.md` from the [P0-T24] PowerShell-tool command.
  - Acceptance (A7-LOCAL): prints `True`. Acceptance (A7-CI): the A7-CI record.
- [ ] [P12-T2] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ps-analyzer.2026-10-09T09-00.md` from the [P0-T25] PowerShell-tool command.
  - Acceptance (A7-LOCAL): prints `0`. Acceptance (A7-CI): the A7-CI record.
- [ ] [P12-T3] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ps-pester.2026-10-09T09-00.md` from the [P8-T5] PowerShell-tool command.
  - Acceptance (A7-LOCAL): `Passed=11 Failed=0`. Acceptance (A7-CI): the A7-CI record.
- [ ] [P12-T4] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ps-coverage-not-applicable.2026-10-09T09-00.md` recording that no production PowerShell file changed (only a `*.Tests.ps1` file), so the Pester line-coverage gate measures no changed production line, and that Pester measures no branch coverage.
  - Acceptance: the file exists with both statements.
- [ ] [P12-T5] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-38 only under A7-LOCAL after [P12-T1] and [P12-T2] pass; under A7-CI leave AC-38 unchecked and list it as pending-CI in [P13-T11].

### Phase 13 — Scope, line counts, closure record, and AC status

- [ ] [P13-T1] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/line-counts.2026-10-09T09-00.md` from `grep -c "" tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py tests/scripts/dev_tools/quality_tiers_contract_test_support.py scripts/dev_tools/check_quality_tiers.py tests/scripts/dev_tools/test_check_quality_tiers.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py "scripts/dev_tools/potential_to_issue.py" extensions/drm-copilot/test/subagent-tree-command.test.ts extensions/drm-copilot/test/subagent-tree-command.quick-pick.test.ts extensions/drm-copilot/test/subagent-tree-command-test-support.ts tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`.
  - Acceptance (AC-39): exit 0; eleven `path:count` lines, each count at most 500.
- [ ] [P13-T2] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/scope-diff.2026-10-09T09-00.md` from `git diff --name-status e7d3779b398604af919678c16c877c8539a86cc0`, then `git status --porcelain --untracked-files=all`, then `git diff --name-status --diff-filter=DR e7d3779b398604af919678c16c877c8539a86cc0`.
  - Acceptance (AC-40; deviation D-10): every path in the union of the first two blocks appears in the "Files Written by This Plan" section below, as a listed path or in its pre-existing inputs paragraph (A6-SKIP and A7 branches can only shrink the set); the third block prints nothing; no `D` or `R` status appears in the second block. The protected #844 test file, every path under .github/workflows/, extensions/drm-copilot/jest.config.cjs, extensions/drm-copilot/tsconfig.jest.json, .gitignore, scripts/dev_tools/potential_to_issue_content.py, and the four superseded #609 files are absent from both blocks.
- [ ] [P13-T3] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/protected-file-844.2026-10-09T09-00.md` from the two [P5-T6] commands rerun after all other phases.
  - Acceptance (AC-14): both print nothing.
- [ ] [P13-T4] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/other/closure-dispositions.2026-10-09T09-00.md` recording, as a Markdown table with the columns Finding, Disposition, Rationale, Evidence and the separator row written exactly `| --- | --- | --- | --- |`, for each finding below a disposition (fixed, corrected, superseded, or closed without change), a one-sentence rationale, and the evidence path, each path existing on disk:
  - #734 CR-1 (fixed: P2-T5 artifact); CR-2 (fixed: quality-tiers-coverage artifact); CR-3 (fixed: split, P1-T4 and P2-T4 artifacts); CR-4 (fixed: qt009 fail-before and pass-after artifacts).
  - #744 CR-1 (fixed: ac-tracking-sentence and ac-pin artifacts); CR-5 (corrected in file: doc-744-checks); PA-2 (closed by an added summary-artifact note; no Command or EXIT_CODE row added because no command produced either file: doc-744-checks).
  - #647 CR-3 second half (fixed: ts-split-jest); CR-3 first half (closed without change here: delivered by item #844; protected-file-844 artifact shows the file is untouched).
  - #623 Protocol stubs (fixed by partial_also; Coverage Exclusion Policy reasoning: no file and no line leaves the coverage denominator, the Stmts value is unchanged in partial-also-after, and only the def-to-exit arc of a declaration-only body is reported as fully covered; the test is retained); plan text (corrected: doc-623-plan-checks); documentation parity (fixed: promotion-docs).
  - #764 -nxF (corrected: doc-764-plan-checks, 764-corrected-grep-historical; observation that line 75 has since changed: 764-corrected-grep-current); filename stamps (superseded by the evidence-filename-timestamps note); issue.md line 5 (corrected; prior value "- Status: Promoted -> docs/features/active/feature-review-skill-cites-nonexistent-validator/ (Issue #764)" retained here); upstream path-generation defect in scripts/dev_tools/potential_to_issue_content.py (out-of-scope follow-up; no issue or potential entry created).
  - #338 CR-1 (corrected: ac3-338-jest); CR-3 (corrected: doc-338-checks); A1 (closed by this item's whole-repository Python coverage evidence, citing the local py-cov-whole-repo and py-coverage-thresholds artifacts under FEATURE/evidence/qa-gates, and by the PR CI step "Enforce Python coverage thresholds" in the quality-checks workflow, named here with the text "CI run result: pending; appended by the executing orchestrator at S9"); residual live-Windows observation (remains closed as scope_change, citing the #338 record evidence/other/ac1-ac2-scope-change-closure.2026-10-08T02-44.md).
  - #609 (superseded by the new ac-status-summary note: doc-609-checks).
  - #543 CR-11 (corrected: 543-commit-dates, doc-543-checks; the A6 decision and its observation).
  - #527 (fixed: doc-527-checks).
  - #510 (corrected: doc-510-checks).
  - #723 refinement (closed without workflow change: the poll step's if: expression contains no status-check function, so the default success() applies and the "publish step succeeded" statement is true by construction; pinned by the P8-T1 test); N1 (fixed: doc-723-runbook-checks); N3 (fixed: doc-723-exit1-checks and pester-workflow-after).
  - Acceptance (AC-34): 27 disposition rows (the 26 findings above plus the #764 follow-up row); `grep -c -E "^\| " docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/other/closure-dispositions.2026-10-09T09-00.md` prints at least 29 (header and separator included); every cited path exists (checked in [P13-T5]).
- [ ] [P13-T5] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/closure-paths-exist.2026-10-09T09-00.md` from the Bash command `ls -d --` followed by every evidence path cited in [P13-T4], each written as a full repository-relative path.
  - Acceptance: exit 0; every cited path is printed; no `No such file or directory` line.
- [ ] [P13-T6] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-14 after [P5-T6] and [P13-T3] pass.
- [ ] [P13-T7] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-16 after [P6-T1], [P6-T2], and [P13-T4] pass.
- [ ] [P13-T8] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` AC-34 status only after [P13-T4] and [P13-T5] pass: AC-34 is left unchecked under both A7 branches and is listed as pending-CI in [P13-T11], because its #338 A1 row depends on the PR CI "Enforce Python coverage thresholds" step result (spec assumption A5). The executing orchestrator appends the CI run result to the closure-dispositions record and checks AC-34 off at S9. This task remains `[ ]` at the end of this plan.
- [ ] [P13-T9] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-39 after [P13-T1] passes.
- [ ] [P13-T10] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` to check off AC-40 after [P13-T2] passes.
- [ ] [P13-T11] Write `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ac-status.2026-10-09T09-00.md` from `grep -c -e "^- \[x\] AC-" docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md` and, as a second block, `grep -n -e "^- \[ \] AC-" docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md`, followed by an `### Acceptance Criteria Status` block (Source, Total AC items 40, Checked off, Remaining, Items remaining).
  - Acceptance: with K the number of entries in the pending list (Conventions), the first block prints 40 minus K and the second block prints exactly the pending-list criteria, each with its reason (pending-CI: AC-34 citing the PR CI "Enforce Python coverage thresholds" step, and under A7-CI AC-30, AC-31, AC-38 citing CI job poshqc / PowerShell QC on the PR head, all checked off at S9 by the item's orchestrator; pre-existing failure: the criteria named by each PRE-EXISTING-FAILURE-ONLY row of [P10-T12] or [P11-T8]). With no PRE-EXISTING-FAILURE-ONLY outcome: A7-LOCAL first block prints 39 and second block prints exactly AC-34; A7-CI first block prints 36 and second block prints exactly AC-30, AC-31, AC-34, AC-38. The block also lists every verification task left unchecked under the pre-existing-failure rule. Any other count leaves this task unchecked and lists the gap.
- [ ] [P13-T12] Update `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/plan.2026-10-08T23-42.md` checkbox state for [P0-T1] through [P13-T11] so every task whose acceptance passed is `[x]` and every other task stays `[ ]`, set the plan Status line to `Executed; pending-CI: AC-34` under A7-LOCAL or `Executed; pending-CI: AC-30, AC-31, AC-34, AC-38` under A7-CI, appending `; pre-existing-failure: ` followed by the affected criteria when any PRE-EXISTING-FAILURE-ONLY outcome was recorded, and then mark this task `[x]`.
  - Acceptance: after this task is marked, `grep -c -E "^- \[ \] \[P" docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/plan.2026-10-08T23-42.md` prints the number of open tasks listed in [P13-T11]: the check-off task of each pending-list criterion (per the AC Traceability table) plus each verification task left unchecked under the pre-existing-failure rule. With no PRE-EXISTING-FAILURE-ONLY outcome it prints 1 under A7-LOCAL ([P13-T8]), or 4 under A7-CI ([P8-T10], [P8-T11], [P12-T5], [P13-T8]).

## Files Written by This Plan

Production code:
- `scripts/dev_tools/check_quality_tiers.py`
- `scripts/dev_tools/potential_to_issue.py`

Tests and test support:
- `tests/scripts/dev_tools/test_quality_tiers_contract.py`
- `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py` (new)
- `tests/scripts/dev_tools/quality_tiers_contract_test_support.py` (new)
- `tests/scripts/dev_tools/test_check_quality_tiers.py`
- `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`
- `extensions/drm-copilot/test/subagent-tree-command.test.ts`
- `extensions/drm-copilot/test/subagent-tree-command.quick-pick.test.ts` (new)
- `extensions/drm-copilot/test/subagent-tree-command-test-support.ts` (new)
- `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`

Configuration and release notes:
- `pyproject.toml` (separator-free root file that is not a configured root surface: the radius derivation and the declared-radius normalisation both drop it, so it cannot be represented in this item's radius; the run planner serialises this item manually against any sibling item that writes this path)
- `extensions/drm-copilot/CHANGELOG.md`

Skill copies and bundled mirrors:
- `.claude/skills/acceptance-criteria-tracking/SKILL.md` (listed in the config/blast-radius.json mandate_reads set, which the radius derivation and declared-radius normalisation drop; the run planner serialises this item manually against any sibling item that writes this path)
- `.agents/skills/acceptance-criteria-tracking/SKILL.md` (listed in the config/blast-radius.json mandate_reads set, which the radius derivation and declared-radius normalisation drop; the run planner serialises this item manually against any sibling item that writes this path)
- `.github/skills/acceptance-criteria-tracking/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/acceptance-criteria-tracking/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/acceptance-criteria-tracking/SKILL.md`
- `extensions/drm-copilot/resources/customizations/.github/skills/acceptance-criteria-tracking/SKILL.md`

Engineering documentation:
- `docs/engineering/missed-npm-publish.runbook.md`

Other feature folders:
- `docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/regression-testing/pester-doc-contracts.2026-09-30T03-18.md`
- `docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/qa-gates/acceptance-criteria-checkoff.2026-09-30T03-18.md`
- `docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/other/ac-status-summary-local.2026-09-30T03-18.md`
- `docs/features/active/promotion-receipt-destination-unverified-623/plan.2026-09-29T19-06.md`
- `docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/plan.2026-09-30T05-00.md`
- `docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/issue.md`
- `docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/evidence/other/evidence-filename-timestamps.2026-10-09T09-00.md` (new)
- `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/issue.md`
- `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/evidence/other/ac-status-summary.2026-10-09T09-00.md` (new)
- `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md`
- `docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/spec.md`

This feature folder (#846):
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/plan.2026-10-08T23-42.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/phase0-instructions-read.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/git-merge-base.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/toolchain-availability.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-black-check.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-ruff-check.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-pyright.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-collect-quality-tiers.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-test-names-quality-tiers.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-cov-quality-tiers.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-cov-filesystem.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-cov-promotion.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-cov-bug-entry-before.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-cov-whole-repo.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-coverage-thresholds.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ts-prettier-check.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ts-lint.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ts-typecheck.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ts-jest-subagent-tree.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ts-it-titles.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ts-jest-coverage.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ps-pester-workflow.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ps-formatter-check.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ps-analyzer.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/line-counts.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/batch-budget-analysis.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/quality-tiers-split-collect.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/quality-tiers-names-after.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/quality-tiers-helper-and-rename.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/qt009-fail-before.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/qt009-pass-after.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/quality-tiers-coverage.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/quality-tiers-cli.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/qt009-message-form.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/ac-pin-fail-before.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/ac-tracking-sentence.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/ac-pin-pass-after.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-744-checks.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/ts-split-jest.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/ts-support-imports.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/protected-file-844.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/partial-also-after.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/filesystem-coverage-after.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-623-plan-checks.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/promotion-docs.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/promotion-coverage.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/764-corrected-grep-current.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/764-corrected-grep-historical.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-764-plan-checks.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-764-checks.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/ac3-338-jest.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-338-checks.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-609-checks.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/543-commit-dates.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-543-checks.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-527-checks.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-510-checks.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/pester-workflow-after.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-723-exit1-checks.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-723-runbook-checks.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/workflow-unchanged.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/fail-before-exception.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-black-check.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-ruff-check.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-pyright.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-cov-quality-tiers.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-cov-promotion.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-cov-filesystem.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-contract-tests.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-cov-whole-repo.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-coverage-thresholds.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-coverage-comparison.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-stages-not-applicable.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-loop-summary.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-prettier-check.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-lint.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-typecheck.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-jest-subagent-tree.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-jest-coverage.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-coverage-comparison.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-stages-not-applicable.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-loop-summary.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ps-formatter-check.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ps-analyzer.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ps-pester.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ps-coverage-not-applicable.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/line-counts.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/scope-diff.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/protected-file-844.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/closure-paths-exist.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ac-status.2026-10-09T09-00.md`
- `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/other/closure-dispositions.2026-10-09T09-00.md`

Pre-existing inputs (plain text; deviation D-10): docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/issue.md; docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/research/research.2026-10-08T23-50.md; docs/features/potential/promoted/2026-10-08-bug-burndown-2026-09-29-review-nits.md. These three files were created before [P0-T1] by promotion and research and are not written by this plan. The orchestrator commits them in the preparation run, so they are expected to be tracked at execution. They are included in the commit pathspec if still untracked, and they are accepted by the [P13-T2] comparison through this paragraph.

Not written by this plan (plain text): extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts; extensions/drm-copilot/jest.config.cjs; extensions/drm-copilot/tsconfig.jest.json; any file under .github/workflows/; .gitignore; scripts/dev_tools/potential_to_issue_content.py; tests/scripts/dev_tools/test_potential_to_issue_filesystem.py; the four superseded #609 evidence files; any #543 folder file other than python-batch-budget.2026-10-02T05-01.md; poetry.lock; any pack manifest.
