# skill-referenced-scripts-not-bundled (Plan)

- **Issue:** #762
- **Parent (optional):** none
- **Owner:** Dan Moisan
- **Last Updated:** 2026-09-28T23-50
- **Status:** Draft (pending validator and executor preflight)
- **Version:** 2.0
- **Work Mode:** full-bug (`spec.md` is the acceptance-criteria source; no `user-story.md`)
- **Supersedes:** `plan.2026-09-28T19-03.md` (kept on disk; its design intent is carried forward, its
  format is replaced)

## Scope Recap

The approved spec (`spec.md`, AC1 through AC8) and the research artifact
(`research/2026-09-28T19-15-skill-bundle-audit-research.md`) define the change:

1. Relocate the ten cleanup-worktrees bash scripts from `scripts/bash/` into
   `.claude/skills/cleanup-merged-worktrees/scripts/`, update every caller, mirror them into the
   Claude bundle, and list them in the core pack manifest.
2. Relocate `scripts/orchestration/Invoke-CiGateParser.ps1` to
   `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`, move its Pester suite, add a manifest-membership
   test, register it for Pester coverage, update `orchestrate` and `epic-orchestrate`, mirror it, and
   list it in the core pack manifest.
3. Add `.claude/skills` to the shell QC discovery roots and the kcov include pattern.
4. Add a pytest-run guard (`scripts/dev_tools/skill_bundle_contract.py` plus a thin CLI module) that
   fails when a skill references a script that is not in its bundle, and checks that every file in a
   skill folder is carried by the skill's packs. The two Python CLI references are registered as
   issue-linked exceptions (#763).

Out of scope (spec Non-Goals): the Python CLI ports (#763), the nonexistent
`Test-ModifiedWorkflowNeedsGreenRun.ps1` citation and the `ROOT_FOLDERS` divergence (#764), agents,
hooks, and rules other than the shell rule named below, consumer repositories, and pull-request
authoring (the orchestrator runs feature review and `pr-author` after this plan completes).

### Enumerated file inventory (derived from the current tree on 2026-09-28)

Moved bash scripts (source `scripts/bash/`, destination `.claude/skills/cleanup-merged-worktrees/scripts/`),
with the count of lines containing the literal `scripts/bash/cleanup` in each:
`cleanup-worktrees.sh` (8: lines 16, 21, 24, 27, 30, 43, 48, 51), `cleanup_worktrees_actions_lib.sh`
(4: lines 10, 12, 39, 331), `cleanup_worktrees_detached_lib.sh` (3: lines 19, 23, 46),
`cleanup_worktrees_report_records_lib.sh` (1: line 42), and six files with 0:
`cleanup_worktrees_dirt_lib.sh`, `cleanup_worktrees_enumerate_lib.sh`, `cleanup_worktrees_lib.sh`,
`cleanup_worktrees_preserve_eol_lib.sh`, `cleanup_worktrees_preserve_lib.sh`,
`cleanup_worktrees_scan_helper.sh`. Total 16.

Skill text: `.claude/skills/cleanup-merged-worktrees/SKILL.md` (8 lines: 9, 30, 31, 32, 148, 206, 244,
467).

bats suites under `tests/shell/` (19 files, 101 lines in total), in four groups:

- Dirt group (32): `test_cleanup_worktrees_dirt_classify.bats` (6), `test_cleanup_worktrees_dirt_clear.bats`
  (8), `test_cleanup_worktrees_dirt_content_locations.bats` (4), `test_cleanup_worktrees_dirt_failclosed.bats`
  (4), `test_cleanup_worktrees_dirt_guard_registry.bats` (4), `test_cleanup_worktrees_dirt_regression.bats` (6).
- Preserve group (20): `test_cleanup_worktrees_preserve.bats` (7), `test_cleanup_worktrees_preserve_eol.bats`
  (7), `test_cleanup_worktrees_preserve_failures.bats` (6).
- Scan and report group (10): `test_cleanup_worktrees_report_records.bats` (6),
  `test_cleanup_worktrees_scan_helper.bats` (2), `test_cleanup_worktrees_scan_seam.bats` (2).
- Core group (39): `test_cleanup_worktrees_classification.bats` (6), `test_cleanup_worktrees_cli.bats` (3),
  `test_cleanup_worktrees_consolidation.bats` (5), `test_cleanup_worktrees_deletion.bats` (7),
  `test_cleanup_worktrees_detached.bats` (7), `test_cleanup_worktrees_enumeration.bats` (4),
  `test_cleanup_worktrees_hard_failures.bats` (7).

Fixture stubs: `tests/fixtures/cleanup_worktrees/stub-bin/git` names only the basename
`cleanup-worktrees.sh` (line 95) and carries no old path; it is not edited. No other file under
`tests/fixtures/cleanup_worktrees/` names the old directory.

Callers of `scripts/orchestration/Invoke-CiGateParser.ps1`: `.claude/skills/orchestrate/SKILL.md`
line 275, `.claude/skills/epic-orchestrate/SKILL.md` line 109, the two bundle mirrors of those skills
(same lines), the parser's own `.EXAMPLE` block (line 61), and its Pester suite
`tests/scripts/orchestration/Invoke-CiGateParser.Tests.ps1` (line 11). No hook, workflow, config
file, or `.claude/settings.json` entry names it. The parser is not currently listed in the Pester
coverage path list (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, lines 23-320).

Mirrors: `extensions/drm-copilot/resources/claude-customizations/.claude/**` for every `.claude/**`
file touched; `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`
for the runsettings file (parity enforced by `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`).
Manifest: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (line 76
lists the cleanup skill; line 149 lists `Resolve-MergeableConflict.ps1`).

Deliberately excluded from the old-path rewrite and the sweep (historical records, AC4 exclusion):
everything under `docs/features/`, and the blast-radius historical-run fixtures
`tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json`,
`tests/fixtures/blast_radius/historical-runs/epic-655-followups.json`, and
`tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json`. Those three fixtures record the
file paths of past parallel runs as they were at the time; rewriting them would change the recorded
history that the blast-radius regression tests replay. No other location outside `docs/features/`
names an old path.

### Spec deviations recorded by this plan

- D1 Module split. The spec names one module. This plan puts the pure logic in
  `scripts/dev_tools/skill_bundle_contract.py` and the repository loader plus `main` in
  `scripts/dev_tools/skill_bundle_contract_cli.py`. Reason: the mandatory docstring and intent-comment
  policy makes a single module likely to exceed 500 lines, and the I/O-isolation rule in
  `.claude/rules/general-code-change.md` favors a separate loader. All spec function names are kept.
- D2 Test split. Unit tests are split across `tests/scripts/dev_tools/test_skill_bundle_contract.py`
  (extraction), `tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py` (evaluation and
  staleness), and `tests/scripts/dev_tools/test_skill_bundle_contract_cli.py` (CLI), plus the spec's
  repository guard `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`.
- D3 CI gate invocation form. The current skill prose ("Parse the JSON via", "procedure (...)") is not
  an invocation form the audit enumerates. The fix rewrites both lines to an explicit
  `pwsh -NoProfile -File <path>` invocation so the guard extracts the reference. Fail-before evidence
  for AC3 is the repository test `test_ci_gate_parser_skills_invoke_bundled_parser`, which fails until
  both skills invoke the bundled path.
- D4 Staleness reporting. Stale exceptions are reported by a separate pure function
  `find_stale_exceptions` rather than as a fourth violation reason, so `SkillBundleViolation` keeps
  exactly the three spec reasons.
- D5 bats location. The relocated scripts' bats suites stay flat in `tests/shell/`, matching the
  existing precedent for `.claude/lib/bash/` scripts (for example `tests/shell/parallel_cohorts.bats`)
  and the shell rule's statement that tests live in `tests/shell/*.bats`.

### Operator-directed policy change

Repository policy prohibits edits to rule files. This plan amends `.claude/rules/shell.md` and its
bundled mirror only because the approved spec (Proposed Fix, design summary, third bullet) directs it;
without the amendment the rule's Discovery Contract and Coverage Expectations would misstate the
discovery roots. No other file under `.claude/rules/` or `.github/instructions/` is written.

## Execution Conventions

### Terms used in every task

- FEATURE means `docs/features/active/2026-09-28-skill-referenced-scripts-not-bundled-762`.
- BUNDLE means `extensions/drm-copilot/resources/claude-customizations`.
- SKILLDIR means `.claude/skills/cleanup-merged-worktrees/scripts`.
- TS means the execution time of the task in `yyyy-MM-ddTHH-mm` form.
- SCRATCH means the executor's session scratchpad directory, outside the repository and never
  committed. Artifacts record it as the literal token SCRATCH, never as a host path.
- BASE_SHA means the merge-base commit recorded by P0-T7; FINAL_SHA means the commit recorded by
  P10-T2.
- NEW_PATH_LITERAL means the literal `.claude/skills/cleanup-merged-worktrees/scripts/cleanup`, and
  OLD_PATH_LITERAL means the literal `scripts/bash/cleanup`. Every relocation edit replaces each
  occurrence of OLD_PATH_LITERAL with NEW_PATH_LITERAL and changes nothing else on that line.
- KL-510 is the known local failure of issue #510. The node
  `test_bundled_claude_payload_contains_all_repo_runtime_contracts` in
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` compares every file under the
  repository's `.claude` directory with the bundle, and the batch-budget hooks write gitignored state
  files under the `.claude` state directory during execution. A run of that node satisfies KL-510 in
  exactly two cases. Case (a): the node prints PASSED. Case (b): the node fails, its assertion message
  is the literal "Repo file missing from bundle:" followed by a path whose first two components are
  `.claude` and `state`, and no output line contains the literal "Bundle content differs from repo
  for:". An artifact that records case (a) contains the line `KL-510: PASSED`; one that records case
  (b) contains the line `KL-510: STATE-ONLY` and quotes the assertion message verbatim. Any other
  outcome stops the task.
- KL-SHELL-2 is the set of two bats tests that fail in the local WSL baseline and are recorded in
  `FEATURE/evidence/baseline/shell-qc-full.2026-09-28T19-10.txt` (lines 4538 and 5182):
  "dirt_typechange_delta: mutating [MARCTU] to [MARCU] changes the verdict away from UNIQUE (negative
  control)" and "dirt_staged_tree_is_commit: injecting a git add call into run_report makes the widened
  non-mutation assertion fail (negative control)". A local bats run satisfies the baseline-relative
  rule when every `not ok` line names a member of KL-SHELL-2. CI (ubuntu-latest) is canonical per
  `.claude/rules/shell.md`; the CI shell job must pass with no failures.
- Every command-step evidence artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and
  `Output Summary:`. An artifact whose expected exit code is not 0 also carries `ExpectedExitCode:`.
  Test-step artifacts for coverage-bearing languages record numeric coverage values in
  `Output Summary:`.

### Evidence location

Every evidence artifact lives under `FEATURE/evidence/<kind>/` with kind one of `baseline`,
`regression-testing`, `qa-gates`, or `other`. The prior plan named `FEATURE/evidence/regression/`;
EVIDENCE_LOCATION_OVERRIDE_REJECTED: FEATURE/evidence/regression/ replaced with
FEATURE/evidence/regression-testing/. No artifact is written under `artifacts/` except the tool
outputs the toolchain itself writes there (Pester XML, kcov, LCOV), which are not evidence artifacts.

### Reused baselines

The four raw logs captured at 2026-09-28T19-10 under `FEATURE/evidence/baseline/` are reused as the
pass/fail baselines (P0-T8). They lack the required artifact fields and carry no coverage numbers, so
the contract requires new coverage-bearing baseline captures (P0-T11 through P0-T20). The tree is
unchanged since those logs apart from documentation commits, so the new captures observe the same
code state.

### Shell route

A worktree isolation hook refuses Bash-tool command text that contains the words bash, pwsh, or wsl,
heredocs, compound commands, cd-chains, or xargs. Therefore:

- Every git, gh, npm, poetry, cp, and mkdir command in this plan is one plain command with literal
  arguments.
- The executor has no PowerShell tool. Every PowerShell script runs through script A1
  (`sh SCRATCH/run-ps.sh SCRATCH/<script>.ps1 <args>`); the command text never names pwsh.
- Every WSL invocation (shfmt, shellcheck, bats, kcov) runs through scripts A11 through A13, whose
  bodies call wsl.exe; the command text never names bash or wsl.
- A command whose arguments must name a file under the refused-word directory spells that directory
  as the glob `scripts/ba?h/` in command text. The invoking shell expands the glob to the real path
  before the command runs, because the file exists; the spelling exists only because the isolation
  hook refuses the literal word. SHELLLIB denotes `scripts/ba?h/shell_qc_lib.sh` and OLDSRC denotes
  `scripts/ba?h/cleanup*` in command text. Commands that must name a refused literal as a search
  pattern run inside a scratch script (A14, A15) rather than as command text.
- Python scratch scripts run as files through `poetry run python SCRATCH/<script>.py`, never as a
  multi-line `-c` argument. Loops run inside scratch scripts only.
- If a hook denies a command in this plan, stop and report the denial text. Do not bypass the hook.

### Batch budgets, mirrors, and the 500-line limit

- Per batch and per language (Python, PowerShell): at most 3 authored production files and 3
  authored test files. Each batch begins with a batch-budget reset task (script A8).
- A bundled mirror is produced by `cp` from the edited primary file, never through Write or Edit, so
  it is byte-identical and is not a second authored file. P0-T10 records whether every mirror pair is
  byte-identical at baseline; if any pair differs at baseline, stop and report.
- No production or test file may exceed 500 lines (checked by P9-T6).

### Toolchain loop rule

Phases 7, 8, and 9 are the final QA loop, one language per phase, in the order format, lint,
type-check (Python only; not applicable to bash and PowerShell per their rule files), test with
coverage. If any step in a language fails or changes a tracked file, fix the cause and restart that
language's loop from its first task; after any fix, also re-run P6-T1 and P6-T3. A language loop is
complete only when every task in it passes in one pass.

### Commit rule

Each implementation phase ends with a commit-and-push task (CMD-GIT-ADD, CMD-GIT-COMMIT,
CMD-GIT-PUSH). Every CMD-GIT-COMMIT carries the commit attribution lines that the executor's session
requires, one `--trailer` argument per line; the executor supplies those lines from its own session
instructions. If a pre-implementation or orchestration hook denies staging, stop and report the
denial text.

### Command catalogue

Every command-bearing task names one or more entries below. Angle-bracket fields are filled from the
task text. Commands run from the repository root of this worktree.

```text
CMD-GIT-BRANCH        git rev-parse --abbrev-ref HEAD
CMD-GIT-HEAD          git rev-parse HEAD
CMD-GIT-FETCH-MAIN    git fetch origin main
CMD-GIT-MERGE-BASE    git merge-base HEAD origin/main
CMD-GIT-STATUS        git status --porcelain
CMD-GIT-STATUS-PATH   git status --porcelain -- <pathspec>
CMD-GIT-STATUS-ALL    git status --porcelain --untracked-files=all -- <pathspec>
CMD-GIT-LS            git ls-files -- <pathspec>
CMD-GIT-COUNT         git grep -c -F -e <literal> -- <paths>
CMD-GIT-ADD           git add -- <exact paths listed in the task>
CMD-GIT-COMMIT        git commit -m "<message given in the task>" --trailer "<each attribution line>"
CMD-GIT-PUSH          git push origin fix/skill-bundled-scripts

CMD-GH-RUNS-FOR-SHA   gh run list --workflow ci.yml --commit <sha> --json databaseId,event,status,conclusion,headSha
CMD-GH-DISPATCH       gh workflow run ci.yml --ref fix/skill-bundled-scripts
CMD-GH-DOWNLOAD       gh run download <run-id> -n shell-coverage -D SCRATCH/<dir>
CMD-GH-JOBS           gh run view <run-id> --json jobs
CMD-CI-WAIT           sh SCRATCH/ci-wait.sh <sha>
CMD-CI-SHELL-COV      sh SCRATCH/ci-shell-coverage-log.sh <run-id>

CMD-PY-BLACK-CHECK    poetry run black --check <paths>
CMD-PY-BLACK          poetry run black <paths>
CMD-PY-RUFF           poetry run ruff check --no-fix <paths>
CMD-PY-PYRIGHT        poetry run pyright <paths>
CMD-PY-TEST           poetry run pytest -v <test files or node IDs listed in the task>
CMD-PY-SCRIPT         poetry run python SCRATCH/<script>.py <args>
CMD-PY-CLI            poetry run python -m scripts.dev_tools.skill_bundle_contract_cli

CMD-PS-SCRIPT         sh SCRATCH/run-ps.sh SCRATCH/<script>.ps1 <args>
MCP-PS-FORMAT         mcp__drm-copilot__run_poshqc_format  (workspace_root = repository root, scan_folders = paths listed in the task)
MCP-PS-ANALYZE        mcp__drm-copilot__run_poshqc_analyze (same arguments)

CMD-SH-QC             sh SCRATCH/run-shell-qc.sh <subcommand> [flag]
CMD-SH-BATS           sh SCRATCH/run-bats.sh <bats files>
CMD-SH-DISCOVER       sh SCRATCH/run-discover.sh
CMD-SH-SWEEP          sh SCRATCH/old-path-sweep.sh <pathspecs>

CMD-TS-CI             npm --prefix extensions/drm-copilot ci
CMD-TS-TEST           npm --prefix extensions/drm-copilot run test -- test/lib/push-down
```

Observed success outputs that acceptance conditions rely on (each was observed in this repository's
recorded runs or source, not inferred): bats prints a TAP plan line `1..N` and one `ok N <name>` or
`not ok N <name>` line per test (observed in `FEATURE/evidence/baseline/shell-qc-full.2026-09-28T19-10.txt`,
plan line `1..477`); `shell-qc.sh test --coverage` prints `Bash coverage (lines): NN.N%` only when every
test directory passes (`scripts/bash/shell_qc_lib.sh` lines 291 and 375-377); `shell-qc.sh format` and
`check` print nothing on a clean run, so format is observed by a before-and-after tree comparison;
Pester scripts A2 and A3 print `PassedCount=` and `FailedCount=` lines by construction; black check
mode prints a line ending "would be left unchanged."; black write mode prints a line ending "files
left unchanged." and prints no "reformatted" line on a clean run; ruff with `--no-fix` prints "All
checks passed!"; pyright prints a summary line beginning with the error count, for example "0 errors";
pytest `-v` prints one PASSED or FAILED line per collected node; Jest prints one "Tests:" summary line;
`git grep -c` prints one `path:count` line per matching file and exits 1 with no output when nothing
matches. The PoshQC MCP tools return no stdout or exit code, so their only observable signal is whether
the call returns or raises; every PowerShell format acceptance therefore also uses the read-only check
script A6 and a before-and-after hash comparison (A5).

---

### Phase 0 — Policy Reads, Scratch Scripts, and Baselines

- [x] [P0-T1] Read `CLAUDE.md` and `.github/copilot-instructions.md` in full, in that order.
      Acceptance: both files read; recorded in P0-T5.
- [x] [P0-T2] Read, in order, `.github/instructions/general-code-change.instructions.md`,
      `.github/instructions/general-unit-test.instructions.md`,
      `.github/instructions/python-code-change.instructions.md`,
      `.github/instructions/python-unit-test.instructions.md`,
      `.github/instructions/powershell-code-change.instructions.md`, and
      `.github/instructions/powershell-unit-test.instructions.md`. Acceptance: all six read; recorded in
      P0-T5.
- [x] [P0-T3] Read, in order, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`,
      `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, and
      `.claude/rules/plan-acceptance-gates.md`. Acceptance: all five read; recorded in P0-T5.
- [x] [P0-T4] Read, in order, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`,
      `.claude/rules/self-explanatory-code-commenting.md`, `.claude/rules/powershell.md`, and
      `.claude/rules/shell.md`. Acceptance: all five read; recorded in P0-T5.
- [x] [P0-T5] Write the policy-read record FEATURE/evidence/baseline/phase0-instructions-read.TS.md.
      Acceptance: the artifact contains `Timestamp:`, `Policy Order:`, and the explicit list of the 18
      files read in P0-T1 through P0-T4 in reading order.
- [x] [P0-T6] Create the scratch scripts A1 through A20 of Appendix A verbatim (SCRATCH/run-ps.sh and siblings).
      Then smoke-test them: CMD-PS-SCRIPT with script line-counts and argument `CLAUDE.md`; CMD-SH-BATS
      with argument `--version`; CMD-SH-QC with subcommand `--help`. Write
      FEATURE/evidence/other/scratch-smoke.TS.md. Acceptance: all three runs exit 0; the first prints a
      line beginning `CLAUDE.md LineCount=`; the second prints a line beginning `Bats `; the third prints
      non-empty output. The artifact records the SHA-256 of each scratch script (A5 over the SCRATCH
      files, recorded with the SCRATCH token).
- [x] [P0-T7] Record branch state in FEATURE/evidence/baseline/branch-state.TS.md.
      Commands: CMD-GIT-BRANCH, CMD-GIT-FETCH-MAIN, CMD-GIT-HEAD, CMD-GIT-MERGE-BASE, CMD-GIT-STATUS.
      Acceptance: branch is `fix/skill-bundled-scripts`; CMD-GIT-STATUS-PATH with pathspecs
      `. ':(exclude)docs/features/active/2026-09-28-skill-referenced-scripts-not-bundled-762'` prints
      nothing (the feature folder itself carries this plan and new evidence); the merge-base is recorded
      as BASE_SHA (40 hexadecimal characters). The CMD-GIT-STATUS output is recorded for information.
- [x] [P0-T8] Record the reused raw baselines in FEATURE/evidence/baseline/reused-raw-baselines.TS.md.
      Sources: `FEATURE/evidence/baseline/shell-qc.2026-09-28T19-10.txt`,
      `FEATURE/evidence/baseline/shell-qc-full.2026-09-28T19-10.txt`,
      `FEATURE/evidence/baseline/pytest-dev-tools.2026-09-28T19-10.txt`, and
      `FEATURE/evidence/baseline/pester-ci-gate.2026-09-28T19-10.txt`. Acceptance: one section per raw
      log, each with `Timestamp: 2026-09-28T19-10`, the `Command:` stated in `plan.2026-09-28T19-03.md`
      P1-T1 through P1-T3, `EXIT_CODE:`, and `Output Summary:`; the shell section records
      `CHECK_EXIT=0`, the TAP plan `1..477`, and the two KL-SHELL-2 test names quoted verbatim from lines
      4538 and 5182 of the full log; the pytest section records "5210 passed, 6 skipped"; the Pester
      section records "Tests Passed: 15, Failed: 0".
- [x] [P0-T9] Record pre-change line counts in FEATURE/evidence/baseline/line-counts.TS.md.
      Command: CMD-PS-SCRIPT with script line-counts over OLDSRC (the ten inventory scripts),
      `.claude/skills/cleanup-merged-worktrees/SKILL.md`, `tests/shell/test_cleanup_worktrees_*.bats`,
      `tests/shell/test_shell_qc_discovery.bats`, `tests/shell/test_shell_qc_commands.bats`, SHELLLIB,
      `scripts/orchestration/Invoke-CiGateParser.ps1`, `tests/scripts/orchestration/Invoke-CiGateParser.Tests.ps1`,
      and `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. Acceptance: exit 0 and one
      `LineCount=` line per file (36 lines: 10 scripts, 1 skill text, 19 cleanup suites, 2 shell QC
      suites, the shell QC library, the parser, its suite, and the runsettings file).
- [x] [P0-T10] Record mirror-pair hashes in FEATURE/evidence/baseline/mirror-hashes.TS.md.
      Command: CMD-PS-SCRIPT with script file-hashes over each primary and its mirror for
      `.claude/skills/cleanup-merged-worktrees/SKILL.md`, `.claude/skills/orchestrate/SKILL.md`,
      `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/rules/shell.md` (mirrors under BUNDLE/.claude/),
      and `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (mirror under
      `extensions/drm-copilot/resources/powershell/PoshQC/settings/`). Acceptance: exit 0 and every pair
      has equal hashes; an unequal pair stops the plan.
- [x] [P0-T11] Python format baseline: CMD-PY-BLACK-CHECK over `scripts/dev_tools tests/scripts/dev_tools`.
      Write FEATURE/evidence/baseline/python-format.TS.md. Acceptance: the artifact records the exit code
      and the summary line verbatim.
- [x] [P0-T12] Python lint baseline: CMD-PY-RUFF over `scripts/dev_tools tests/scripts/dev_tools`. Write
      FEATURE/evidence/baseline/python-lint.TS.md. Acceptance: the artifact records the exit code and the
      summary line verbatim.
- [x] [P0-T13] Python type-check baseline: CMD-PY-PYRIGHT over `scripts/dev_tools tests/scripts/dev_tools`.
      Write FEATURE/evidence/baseline/python-typecheck.TS.md. Acceptance: the artifact records the exit
      code and the error, warning, and information counts from the pyright summary line.
- [x] [P0-T14] Python test and coverage baseline for `tests/scripts/dev_tools`, written to FEATURE/evidence/baseline/python-test-coverage.TS.md.
      Commands: `poetry run pytest tests/scripts/dev_tools --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/cov-762-baseline.json`,
      then CMD-PY-SCRIPT with script py-cov-files (A7) and arguments `SCRATCH/cov-762-baseline.json TOTAL`.
      Acceptance: the artifact records the pytest summary line (passed, failed, and skipped counts), the
      term-missing `TOTAL` row, and the A7 line `COVERAGE file=TOTAL LinePercent=<n> BranchPercent=<n>`
      with numeric values; any failing node other than a KL-510 case (b) stops the plan.
- [x] [P0-T15] PowerShell analyzer baseline for `scripts/orchestration/Invoke-CiGateParser.ps1`, written to FEATURE/evidence/baseline/powershell-analyze.TS.md.
      Command: CMD-PS-SCRIPT with script pssa-count (A9) over
      `scripts/orchestration/Invoke-CiGateParser.ps1 tests/scripts/orchestration/Invoke-CiGateParser.Tests.ps1`.
      Acceptance: exit 0 and the line `PSSA-SUMMARY DiagnosticCount=<n>` is recorded with its numeric
      value.
- [x] [P0-T16] PowerShell format baseline for `scripts/orchestration/Invoke-CiGateParser.ps1`, written to FEATURE/evidence/baseline/powershell-format.TS.md.
      Command: CMD-PS-SCRIPT with script ps-format-check (A6) over
      `scripts/orchestration/Invoke-CiGateParser.ps1 tests/scripts/orchestration/Invoke-CiGateParser.Tests.ps1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.
      Acceptance: exit 0 and the line `FORMAT-SUMMARY ChangedCount=<n>` is recorded with its numeric
      value.
- [x] [P0-T17] PowerShell test and coverage baseline for `scripts/orchestration/Invoke-CiGateParser.ps1`, written to FEATURE/evidence/baseline/powershell-test-coverage.TS.md.
      Command: CMD-PS-SCRIPT with script pester-coverage (A3),
      `-TestPath tests/scripts/orchestration/Invoke-CiGateParser.Tests.ps1`,
      `-CoveragePath scripts/orchestration/Invoke-CiGateParser.ps1`, `-CoverageOutputPath SCRATCH/ci-gate-baseline.xml`.
      Acceptance: output contains `PassedCount=15` and `FailedCount=0` and one
      `COVERAGE file=scripts/orchestration/Invoke-CiGateParser.ps1` line whose `LinePercent=` value is
      numeric.
- [x] [P0-T18] PowerShell regression baseline for `tests/scripts/claude-lib`, written to FEATURE/evidence/baseline/powershell-claude-lib.TS.md.
      Command: CMD-PS-SCRIPT with script pester-counts (A2) and `-Path tests/scripts/claude-lib`.
      Acceptance: the artifact records `TotalCount=`, `PassedCount=`, `FailedCount=`, and every
      `FAILED:` line verbatim (the baseline failure set, possibly empty).
- [x] [P0-T19] Bash coverage baseline from CI on `main`, written to FEATURE/evidence/baseline/shell-coverage-ci.TS.md.
      Commands: CMD-GH-RUNS-FOR-SHA with BASE_SHA; select the run whose `event` is `push` (for
      `5d0b93a0` this is run 36494352285); CMD-GH-JOBS with that run id; CMD-CI-SHELL-COV with that run
      id; CMD-GH-DOWNLOAD with that run id into `SCRATCH/shell-cov-baseline`; CMD-PY-SCRIPT with script
      cobertura-files (A17) and arguments `SCRATCH/shell-cov-baseline/cov.xml` SHELLLIB followed by the
      ten moved-script basenames. Acceptance: CMD-GH-JOBS shows the job
      `shell-coverage / Shell Coverage (Bats + kcov)` with conclusion `success`; the artifact records the
      run id, the run's overall conclusion, and each failing job name, marked as unrelated to this
      baseline (the overall conclusion of run 36494352285 is `failure` because of an unrelated Python
      job); the artifact records exactly one line matching `Bash coverage (lines): <n>%` with its numeric
      value (observed 93.3%), the `COBERTURA-TOTAL` line, and one `COBERTURA file=` line per requested
      file. Stop only when no push run exists for BASE_SHA, the shell-coverage job did not conclude
      `success`, or the `shell-coverage` artifact is absent; in those cases the bash coverage baseline is
      unavailable and the coverage comparison would be BLOCKED.
- [x] [P0-T20] TypeScript push-down regression baseline for `extensions/drm-copilot/test/lib/push-down`, written to FEATURE/evidence/baseline/ts-push-down-jest.TS.md.
      No TypeScript source is edited; the bundle resources these tests read are. Commands: CMD-TS-CI,
      then CMD-TS-TEST. Acceptance: the artifact records the "Tests:" summary line verbatim and every
      line beginning `FAIL ` (the baseline failure set, possibly empty).

### Phase 1 — Regression Tests First (Guard, Discovery, Manifest)

- [x] [P1-T1] Reset the Python batch budget for `scripts/dev_tools/skill_bundle_contract.py` and its
      unit tests: CMD-PS-SCRIPT with script reset-batch-budget (A8) and `-Kind python`. Write
      FEATURE/evidence/other/batch-budget-reset-p1a.TS.md. Acceptance: exit 0 and a `RESET removed=` line.
- [x] [P1-T2] Write `scripts/dev_tools/skill_bundle_contract.py` per Appendix B1. Acceptance: the file
      exists and defines `PUBLISHED_ROOT_FOLDERS`, `KNOWN_UNBUNDLED_REFERENCES`, `SkillBundleViolation`,
      `KnownUnbundledReference`, `SkillBundleInputs`, `parse_allowed_tools`, `extract_script_references`,
      `evaluate_skill_bundle`, `find_violations`, and `find_stale_exceptions`, with
      `KNOWN_UNBUNDLED_REFERENCES` holding exactly the two #763 entries of Appendix B1.
- [x] [P1-T3] Write `tests/scripts/dev_tools/test_skill_bundle_contract.py` per Appendix B2 (the 18
      named extraction and frontmatter tests; inline strings only, no filesystem access, no temporary
      files; inline strings follow the B2 fictitious-path rule). Acceptance: the file defines each B2 test name.
- [x] [P1-T4] Write `tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py` per Appendix B3
      (the 12 named evaluation and staleness tests; inline data only, following the B2 fictitious-path
      rule). Acceptance: the file defines each B3 test name.
- [x] [P1-T5] Run the unit tests in `tests/scripts/dev_tools/test_skill_bundle_contract.py` and `tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py`.
      Command: CMD-PY-TEST over those two files. Write
      FEATURE/evidence/regression-testing/guard-units-initial.TS.md. Acceptance: exit 0, every B2 and B3
      test name appears on a PASSED line, and no FAILED line is printed.
- [x] [P1-T6] Reset the Python batch budget for `scripts/dev_tools/skill_bundle_contract_cli.py` and its
      tests: CMD-PS-SCRIPT with script reset-batch-budget (A8) and `-Kind python`. Write
      FEATURE/evidence/other/batch-budget-reset-p1b.TS.md. Acceptance: exit 0 and a `RESET removed=` line.
- [x] [P1-T7] Write `scripts/dev_tools/skill_bundle_contract_cli.py` per Appendix B4. Acceptance: the
      file defines `load_repository_inputs` and `main` with the B4 signatures and output formats.
- [x] [P1-T8] Write `tests/scripts/dev_tools/test_skill_bundle_contract_cli.py` per Appendix B5 (the 4
      named CLI tests with an injected loader; no filesystem access; inline data follows the B2
      fictitious-path rule). Acceptance: the file defines each B5 test name.
- [x] [P1-T9] Write `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` per Appendix B6 (the 5
      named repository-guard tests). Acceptance: the file defines each B6 test name.
- [x] [P1-T10] Run the CLI unit tests: CMD-PY-TEST over `tests/scripts/dev_tools/test_skill_bundle_contract_cli.py`.
      Write FEATURE/evidence/regression-testing/guard-cli-units.TS.md. Acceptance: exit 0 and all four
      B5 test names appear on PASSED lines.
- [x] [P1-T11] [expect-fail] Run the repository guard `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` before the fix.
      Command: CMD-PY-TEST over that file. Write
      FEATURE/evidence/regression-testing/guard-before-fix.TS.md with `ExpectedExitCode: 1`. Acceptance:
      exit 1; exactly two lines beginning `FAILED `, naming `test_every_skill_script_reference_is_bundled`
      and `test_ci_gate_parser_skills_invoke_bundled_parser`; the first failure's message contains
      `cleanup-merged-worktrees | scripts/bash/cleanup-worktrees.sh | not-in-bundle` and no other
      violation line; the three other B6 tests are PASSED. Any other failure set stops the plan for a
      design review, because it means the extractor or the pre-fix tree differs from this plan's
      derivation.
- [x] [P1-T12] [expect-fail] Run the guard CLI `scripts/dev_tools/skill_bundle_contract_cli.py` before the fix.
      Command: CMD-PY-CLI. Write FEATURE/evidence/regression-testing/guard-cli-before-fix.TS.md with
      `ExpectedExitCode: 1`. Acceptance: exit 1, and stderr carries exactly one line beginning
      `skill-bundle `, which is
      `skill-bundle violation: cleanup-merged-worktrees | scripts/bash/cleanup-worktrees.sh | not-in-bundle`.
- [x] [P1-T13] Create the discovery fixture `tests/fixtures/shell_qc/.claude/skills/demo-skill/scripts/skill_entry.sh`
      with exactly the three lines of Appendix B8. Acceptance: CMD-GIT-STATUS-ALL over
      `tests/fixtures/shell_qc/.claude/skills` prints exactly
      `?? tests/fixtures/shell_qc/.claude/skills/demo-skill/scripts/skill_entry.sh`.
- [x] [P1-T14] Edit `tests/shell/test_shell_qc_discovery.bats` per Appendix B9 (one new test named
      "discover_shell_scripts finds a .sh file under the .claude/skills root", and the sorted-output test
      updated to seven lines). Acceptance: CMD-GIT-COUNT with literal `demo-skill/scripts/skill_entry.sh`
      over that file prints `tests/shell/test_shell_qc_discovery.bats:2`.
- [x] [P1-T15] Edit `tests/shell/test_shell_qc_commands.bats` per Appendix B10 (shellcheck call count
      6 to 7 at line 81; one include-pattern assertion added after line 129). Acceptance: CMD-GIT-COUNT
      with literal `"/.claude/skills"` over that file prints `tests/shell/test_shell_qc_commands.bats:1`.
- [x] [P1-T16] [expect-fail] Run `tests/shell/test_shell_qc_discovery.bats` and `tests/shell/test_shell_qc_commands.bats` before the library change.
      Command: CMD-SH-BATS over those two files. Write
      FEATURE/evidence/regression-testing/shell-qc-discovery-before-fix.TS.md with `ExpectedExitCode: 1`.
      Acceptance: exit 1 and exactly four `not ok` lines, naming "discover_shell_scripts finds a .sh file
      under the .claude/skills root", "discover_shell_scripts output is sorted and de-duplicated", "check
      invokes shfmt once over the full list and shellcheck once per file", and "test --coverage builds
      the kcov argv and merges the runs".
- [x] [P1-T17] Reset the PowerShell batch budget for `tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1`:
      CMD-PS-SCRIPT with script reset-batch-budget (A8) and `-Kind powershell`. Write
      FEATURE/evidence/other/batch-budget-reset-p1c.TS.md. Acceptance: exit 0 and a `RESET removed=` line.
- [x] [P1-T18] Write `tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1` per Appendix B7.
      Acceptance: the file exists with one `Describe` block and two `It` blocks named as in B7.
- [x] [P1-T19] [expect-fail] Run `tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1` before the manifest entry exists.
      Command: CMD-PS-SCRIPT with script pester-counts (A2) and that path. Write
      FEATURE/evidence/regression-testing/ci-gate-manifest-before-fix.TS.md with `ExpectedExitCode: 0`
      (A2 reports test failures in its output, not its exit code). Acceptance: exit 0 and output
      contains `TotalCount=2`, `PassedCount=0`, and `FailedCount=2`; a non-zero exit stops the task.
- [x] [P1-T20] Commit and push Phase 1 (`scripts/dev_tools/skill_bundle_contract.py` and the files below).
      Commands: CMD-GIT-ADD with `scripts/dev_tools/skill_bundle_contract.py scripts/dev_tools/skill_bundle_contract_cli.py tests/scripts/dev_tools/test_skill_bundle_contract.py tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py tests/scripts/dev_tools/test_skill_bundle_contract_cli.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py tests/fixtures/shell_qc/.claude/skills tests/shell/test_shell_qc_discovery.bats tests/shell/test_shell_qc_commands.bats tests/scripts/claude-lib/ci-gate FEATURE/evidence FEATURE/plan.2026-09-28T23-50.md`,
      CMD-GIT-COMMIT with message "test(762): add skill bundle guard and fail-before regression tests",
      CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing after the commit, and the push exits 0.

### Phase 2 — Relocate the cleanup-worktrees Scripts (AC2, AC4)

- [x] [P2-T1] Move the ten scripts into SKILLDIR (`.claude/skills/cleanup-merged-worktrees/scripts`).
      Command: `sh SCRATCH/move-cleanup-scripts.sh` (script A15). Write
      FEATURE/evidence/other/cleanup-move.TS.md. Acceptance: exit 0 and ten `MOVED` lines; CMD-GIT-LS over
      `.claude/skills/cleanup-merged-worktrees/scripts` prints exactly the ten inventory basenames under
      that directory; CMD-GIT-STATUS-PATH over `scripts .claude/skills/cleanup-merged-worktrees/scripts`
      prints exactly ten lines, each beginning `R`.
- [x] [P2-T2] Edit `.claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh`: replace
      OLD_PATH_LITERAL with NEW_PATH_LITERAL on lines 16, 21, 24, 27, 30, 43, 48, and 51 (the shellcheck
      `source=` directives). Acceptance: CMD-GIT-COUNT with NEW_PATH_LITERAL over that file prints
      `.claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh:8`.
- [x] [P2-T3] Edit `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh`:
      replace OLD_PATH_LITERAL with NEW_PATH_LITERAL on lines 19, 23, and 46 (comments). Acceptance:
      CMD-GIT-COUNT with NEW_PATH_LITERAL over that file prints a count of 3.
- [x] [P2-T4] Edit `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_actions_lib.sh`:
      replace OLD_PATH_LITERAL with NEW_PATH_LITERAL on lines 10, 12, 39, and 331 (comments).
      Acceptance: CMD-GIT-COUNT with NEW_PATH_LITERAL over that file prints a count of 4.
- [x] [P2-T5] Edit `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh`:
      replace OLD_PATH_LITERAL with NEW_PATH_LITERAL on line 42 (comment). Acceptance: CMD-GIT-COUNT with
      NEW_PATH_LITERAL over that file prints a count of 1.
- [x] [P2-T6] Sweep the moved scripts: CMD-SH-SWEEP with pathspec `.claude/skills/cleanup-merged-worktrees/scripts`.
      Write FEATURE/evidence/regression-testing/sweep-moved-scripts.TS.md. Acceptance: exit 0, no match
      line, and the final line is `SWEEP-EXIT=1`.
- [x] [P2-T7] Edit `.claude/skills/cleanup-merged-worktrees/SKILL.md`: replace OLD_PATH_LITERAL with
      NEW_PATH_LITERAL on lines 9, 30, 31, 32, 148, 206, 244, and 467; line 9 becomes
      `  - "Bash(bash .claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh *)"`.
      Acceptance: CMD-GIT-COUNT with NEW_PATH_LITERAL over that file prints a count of 8, and CMD-SH-SWEEP
      with that file as pathspec prints `SWEEP-EXIT=1`.
- [x] [P2-T8] Edit the dirt group under `tests/shell/` (six files named in the inventory): replace
      every OLD_PATH_LITERAL with NEW_PATH_LITERAL. Acceptance: CMD-GIT-COUNT with NEW_PATH_LITERAL over
      the six files prints exactly `tests/shell/test_cleanup_worktrees_dirt_classify.bats:6`,
      `tests/shell/test_cleanup_worktrees_dirt_clear.bats:8`,
      `tests/shell/test_cleanup_worktrees_dirt_content_locations.bats:4`,
      `tests/shell/test_cleanup_worktrees_dirt_failclosed.bats:4`,
      `tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats:4`, and
      `tests/shell/test_cleanup_worktrees_dirt_regression.bats:6`.
- [x] [P2-T9] Edit the preserve group under `tests/shell/` (three files named in the inventory): replace
      every OLD_PATH_LITERAL with NEW_PATH_LITERAL. Acceptance: CMD-GIT-COUNT with NEW_PATH_LITERAL over
      the three files prints exactly `tests/shell/test_cleanup_worktrees_preserve.bats:7`,
      `tests/shell/test_cleanup_worktrees_preserve_eol.bats:7`, and
      `tests/shell/test_cleanup_worktrees_preserve_failures.bats:6`.
- [x] [P2-T10] Edit the scan and report group under `tests/shell/` (three files named in the
      inventory): replace every OLD_PATH_LITERAL with NEW_PATH_LITERAL. Acceptance: CMD-GIT-COUNT with
      NEW_PATH_LITERAL over the three files prints exactly
      `tests/shell/test_cleanup_worktrees_report_records.bats:6`,
      `tests/shell/test_cleanup_worktrees_scan_helper.bats:2`, and
      `tests/shell/test_cleanup_worktrees_scan_seam.bats:2`.
- [x] [P2-T11] Edit the core group under `tests/shell/` (seven files named in the inventory): replace
      every OLD_PATH_LITERAL with NEW_PATH_LITERAL. Acceptance: CMD-GIT-COUNT with NEW_PATH_LITERAL over
      the seven files prints exactly `tests/shell/test_cleanup_worktrees_classification.bats:6`,
      `tests/shell/test_cleanup_worktrees_cli.bats:3`, `tests/shell/test_cleanup_worktrees_consolidation.bats:5`,
      `tests/shell/test_cleanup_worktrees_deletion.bats:7`, `tests/shell/test_cleanup_worktrees_detached.bats:7`,
      `tests/shell/test_cleanup_worktrees_enumeration.bats:4`, and
      `tests/shell/test_cleanup_worktrees_hard_failures.bats:7`.
- [x] [P2-T12] Sweep the test tree: CMD-SH-SWEEP with pathspecs `tests/shell tests/fixtures/cleanup_worktrees`.
      Write FEATURE/evidence/regression-testing/sweep-cleanup-tests.TS.md. Acceptance: exit 0, no match
      line, and the final line is `SWEEP-EXIT=1`.
- [x] [P2-T13] Run the 19 suites `tests/shell/test_cleanup_worktrees_*.bats` from the new script path.
      Command: CMD-SH-BATS over that glob. Write
      FEATURE/evidence/regression-testing/cleanup-bats-after-move.TS.md. Acceptance: the TAP plan line is
      recorded, and every `not ok` line (if any) names a KL-SHELL-2 member; the artifact carries
      `ExpectedExitCode: 1` when a KL-SHELL-2 member fails and no `ExpectedExitCode:` line otherwise.
- [x] [P2-T14] Commit and push Phase 2 (`.claude/skills/cleanup-merged-worktrees` and `tests/shell`).
      Commands: CMD-GIT-ADD with `.claude/skills/cleanup-merged-worktrees tests/shell FEATURE/evidence FEATURE/plan.2026-09-28T23-50.md`,
      CMD-GIT-COMMIT with message "fix(762): bundle cleanup-worktrees scripts with the cleanup-merged-worktrees skill",
      CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing after the commit, and the push exits 0.

### Phase 3 — Relocate the CI Gate Parser (AC3, AC4)

- [x] [P3-T1] Reset the PowerShell batch budget for `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` and
      its tests: CMD-PS-SCRIPT with script reset-batch-budget (A8) and `-Kind powershell`. Write
      FEATURE/evidence/other/batch-budget-reset-p3.TS.md. Acceptance: exit 0 and a `RESET removed=` line.
- [x] [P3-T2] Move the parser: `mkdir -p .claude/lib/ci-gate`, then
      `git mv scripts/orchestration/Invoke-CiGateParser.ps1 .claude/lib/ci-gate/Invoke-CiGateParser.ps1`.
      Acceptance: CMD-GIT-LS over `.claude/lib/ci-gate` prints `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`
      and CMD-GIT-LS over `scripts/orchestration` prints nothing.
- [x] [P3-T3] Move the Pester suite to `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`.
      Command: `git mv tests/scripts/orchestration/Invoke-CiGateParser.Tests.ps1 tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`.
      Acceptance: CMD-GIT-LS over `tests/scripts/orchestration` prints nothing and CMD-GIT-LS over
      `tests/scripts/claude-lib/ci-gate` lists the moved suite and `CiGate.Manifest.Tests.ps1`.
- [x] [P3-T4] Edit `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` line 61 (the `.EXAMPLE` block) so the
      path reads `./.claude/lib/ci-gate/Invoke-CiGateParser.ps1 -HeadSha $sha`. Acceptance: CMD-GIT-COUNT
      with literal `./.claude/lib/ci-gate/Invoke-CiGateParser.ps1` over that file prints a count of 1.
- [x] [P3-T5] Edit `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` line 11 so the
      relative path argument reads `"../../../../.claude/lib/ci-gate/Invoke-CiGateParser.ps1"`.
      Acceptance: CMD-GIT-COUNT with literal `../../../../.claude/lib/ci-gate/Invoke-CiGateParser.ps1`
      over that file prints a count of 1.
- [x] [P3-T6] Edit `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`: insert the five lines of
      Appendix B11 after line 319 (inside `CodeCoverage.Path`, before the closing parenthesis). Acceptance:
      CMD-PS-SCRIPT with script psd1-parse (A10) over the file prints `PSD1-OK`, and CMD-GIT-COUNT with
      literal `'.claude/lib/ci-gate/Invoke-CiGateParser.ps1'` over it prints a count of 1.
- [x] [P3-T7] Mirror `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` into the PoshQC bundle.
      Command: `cp scripts/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`.
      Acceptance: CMD-PS-SCRIPT with script file-hashes over the two paths prints equal hashes.
- [x] [P3-T8] Edit `.claude/skills/orchestrate/SKILL.md` line 275 to the exact text of Appendix B12
      (an explicit `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1` invocation).
      Acceptance: CMD-GIT-COUNT with literal `-File .claude/lib/ci-gate/Invoke-CiGateParser.ps1` (passed
      through `-e`) over that file prints a count of 1.
- [x] [P3-T9] Edit `.claude/skills/epic-orchestrate/SKILL.md` line 109 to the exact text of Appendix
      B13. Acceptance: CMD-GIT-COUNT with literal `-File .claude/lib/ci-gate/Invoke-CiGateParser.ps1`
      (passed through `-e`) over that file prints a count of 1.
- [x] [P3-T10] Run the moved suite `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`.
      Command: CMD-PS-SCRIPT with script pester-counts (A2) and that path. Write
      FEATURE/evidence/regression-testing/ci-gate-parser-after-move.TS.md. Acceptance: `PassedCount=15`
      and `FailedCount=0`.
- [x] [P3-T11] Commit and push Phase 3 (`.claude/lib/ci-gate` and the files below).
      Commands: CMD-GIT-ADD with `.claude/lib/ci-gate scripts/orchestration tests/scripts/orchestration tests/scripts/claude-lib/ci-gate scripts/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 .claude/skills/orchestrate/SKILL.md .claude/skills/epic-orchestrate/SKILL.md FEATURE/evidence FEATURE/plan.2026-09-28T23-50.md`,
      CMD-GIT-COMMIT with message "fix(762): relocate the CI gate parser into the bundled .claude/lib tree",
      CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing after the commit, and the push exits 0.

### Phase 4 — Bundle Mirror and Core Manifest (AC2, AC3)

- [x] [P4-T1] Mirror the ten scripts: `mkdir -p extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts`,
      then `cp .claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_actions_lib.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_dirt_lib.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_lib.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_eol_lib.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/`.
      Acceptance: CMD-PS-SCRIPT with script file-hashes over the ten primaries and the ten mirrors prints
      ten equal pairs.
- [x] [P4-T2] Mirror `.claude/skills/cleanup-merged-worktrees/SKILL.md` into BUNDLE.
      Command: `cp .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`.
      Acceptance: CMD-PS-SCRIPT with script file-hashes over the pair prints equal hashes.
- [x] [P4-T3] Mirror the two orchestration skill texts: `cp .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
      and `cp .claude/skills/epic-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`.
      Acceptance: CMD-PS-SCRIPT with script file-hashes over the two pairs prints two equal pairs.
- [x] [P4-T4] Mirror the parser: `mkdir -p extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate`,
      then `cp .claude/lib/ci-gate/Invoke-CiGateParser.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1`.
      Acceptance: CMD-PS-SCRIPT with script file-hashes over the pair prints equal hashes.
- [x] [P4-T5] Edit `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`:
      insert the ten lines of Appendix B14 immediately after line 76 (the cleanup skill's `SKILL.md`
      entry). Acceptance: CMD-GIT-COUNT with literal `.claude/skills/cleanup-merged-worktrees/scripts/`
      over that file prints a count of 10.
- [x] [P4-T6] Edit `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`:
      insert the line `    ".claude/lib/ci-gate/Invoke-CiGateParser.ps1",` immediately after the
      `Resolve-MergeableConflict.ps1` entry (line 149 before P4-T5; line 159 after it). Acceptance:
      CMD-GIT-COUNT with literal `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` over that file prints a
      count of 1, and CMD-PS-SCRIPT with script json-parse (A16) over the file prints `JSON-OK`.
- [x] [P4-T7] Run `tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1` after the fix.
      Command: CMD-PS-SCRIPT with script pester-counts (A2) and that path. Write
      FEATURE/evidence/regression-testing/ci-gate-manifest-after-fix.TS.md. Acceptance: `TotalCount=2`,
      `PassedCount=2`, `FailedCount=0`.
- [x] [P4-T8] Run the bundle contract tests in `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and two siblings.
      Command: CMD-PY-TEST over `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py`.
      Write FEATURE/evidence/regression-testing/bundle-contracts.TS.md. Acceptance: every node other than
      `test_bundled_claude_payload_contains_all_repo_runtime_contracts` is PASSED, and that node satisfies
      KL-510 (the artifact carries the KL-510 line and, for case (b), `ExpectedExitCode: 1`).
- [x] [P4-T9] Commit and push Phase 4 (`extensions/drm-copilot/resources/claude-customizations`).
      Commands: CMD-GIT-ADD with `extensions/drm-copilot/resources/claude-customizations FEATURE/evidence FEATURE/plan.2026-09-28T23-50.md`,
      CMD-GIT-COMMIT with message "fix(762): mirror relocated scripts into the Claude bundle and core manifest",
      CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing after the commit, and the push exits 0.

### Phase 5 — Shell QC Discovery of .claude/skills (AC5)

- [x] [P5-T1] Edit `scripts/bash/shell_qc_lib.sh` lines 76-77 and 85 per Appendix B15 (comment names the
      `.claude/skills/` root; the root loop becomes `for root in tools scripts .claude/lib/bash .claude/skills; do`).
      Acceptance: CMD-GIT-COUNT with literal `.claude/skills; do` over SHELLLIB prints a count of 1.
- [x] [P5-T2] Edit `scripts/bash/shell_qc_lib.sh` lines 333-335 per Appendix B15 (comment and the
      include pattern gains a fourth root). Acceptance: CMD-GIT-COUNT with literal
      `/.claude/skills"` over SHELLLIB prints a count of 1.
- [x] [P5-T3] Run `tests/shell/test_shell_qc_discovery.bats` and `tests/shell/test_shell_qc_commands.bats` after the library change.
      Command: CMD-SH-BATS over those two files. Write
      FEATURE/evidence/regression-testing/shell-qc-discovery-after-fix.TS.md. Acceptance: exit 0, no
      `not ok` line, and the four tests named in P1-T16 appear on `ok` lines.
- [x] [P5-T4] Observe real discovery of the SKILLDIR scripts (`.claude/skills/cleanup-merged-worktrees/scripts`).
      Command: CMD-SH-DISCOVER (script A13 sources the shell QC library and runs
      `discover_shell_scripts` from the repository root). Write
      FEATURE/evidence/regression-testing/discovery-skill-scripts.TS.md. Acceptance: exit 0 and the output
      contains exactly ten lines beginning `.claude/skills/cleanup-merged-worktrees/scripts/`, one per
      inventory basename.
- [x] [P5-T5] Edit `.claude/rules/shell.md` (operator-directed, see Operator-directed policy change):
      replace the first Discovery Contract bullet and the second Coverage Expectations bullet with the
      exact text of Appendix B16; change nothing else. Acceptance: CMD-GIT-COUNT with literal
      `.claude/skills/` over that file prints a count of 3 (the file carries none before the edit), and
      CMD-PY-TEST over `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` exits 0 with no FAILED
      line.
- [x] [P5-T6] Mirror `.claude/rules/shell.md` into BUNDLE.
      Command: `cp .claude/rules/shell.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md`.
      Acceptance: CMD-PS-SCRIPT with script file-hashes over the pair prints equal hashes.
- [x] [P5-T7] Commit and push Phase 5 (`.claude/rules/shell.md`, its mirror, and the shell QC library).
      Commands: CMD-GIT-ADD with SHELLLIB `.claude/rules/shell.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md FEATURE/evidence FEATURE/plan.2026-09-28T23-50.md`,
      CMD-GIT-COMMIT with message "fix(762): discover and cover bash scripts bundled under .claude/skills",
      CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing after the commit, and the push exits 0.

### Phase 6 — Guard Pass-After, Old-Path Sweep, and Audit Coverage (AC1, AC4, AC6, AC7)

- [x] [P6-T1] Run the repository guard `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` after the fix.
      Command: CMD-PY-TEST over that file. Write
      FEATURE/evidence/regression-testing/guard-after-fix.TS.md. Acceptance: exit 0 and all five B6 test
      names on PASSED lines (including `test_known_unbundled_references_are_not_stale` and
      `test_every_skill_folder_file_is_carried_by_skill_packs`).
- [x] [P6-T2] Run the guard CLI `scripts/dev_tools/skill_bundle_contract_cli.py` after the fix.
      Command: CMD-PY-CLI. Write FEATURE/evidence/regression-testing/guard-cli-after-fix.TS.md.
      Acceptance: exit 0 and no stderr line beginning `skill-bundle `.
- [x] [P6-T3] Full old-path sweep, written to FEATURE/evidence/qa-gates/old-path-sweep.TS.md.
      Command: CMD-SH-SWEEP with pathspecs `. ':(exclude)docs/features' ':(exclude)tests/fixtures/blast_radius/historical-runs'`.
      Acceptance: exit 0, no match line, and the final line is `SWEEP-EXIT=1`. The sweep searches tracked
      and untracked non-ignored files for the three literals `scripts/bash/cleanup`,
      `scripts/orchestration/Invoke-CiGateParser`, and `tests/scripts/orchestration/`.
- [x] [P6-T4] Confirm `scripts/orchestration` and `tests/scripts/orchestration` are empty in the index.
      Command: CMD-GIT-LS over `scripts/orchestration tests/scripts/orchestration`. Write
      FEATURE/evidence/qa-gates/old-dirs-empty.TS.md. Acceptance: exit 0 and no output.
- [x] [P6-T5] AC1 audit coverage: run `sh SCRATCH/skill-audit-coverage.sh` (script A18) against
      `FEATURE/research/2026-09-28T19-15-skill-bundle-audit-research.md`. Write
      FEATURE/evidence/qa-gates/ac1-audit-coverage.TS.md. Acceptance: exit 0, no `MISSING` line, and the
      final line is `AUDIT skills=56 missing=0`.

### Phase 7 — Final QA Loop: Bash (shell-qc via WSL)

- [x] [P7-T1] Format all discovered shell scripts (including `.claude/skills/cleanup-merged-worktrees/scripts`).
      Commands: CMD-GIT-STATUS (before), CMD-SH-QC with subcommand `format`, CMD-GIT-STATUS (after).
      Write FEATURE/evidence/qa-gates/shell-format.TS.md. Acceptance: the format run exits 0 and the two
      status outputs are identical; a difference means shfmt rewrote a file, which restarts
      this loop after the rewrite is committed.
- [x] [P7-T2] Lint all discovered shell scripts (including `.claude/skills/cleanup-merged-worktrees/scripts`).
      Command: CMD-SH-QC with subcommand `check` (shfmt diff mode, then shellcheck once per discovered
      file). Write FEATURE/evidence/qa-gates/shell-lint.TS.md. Acceptance: exit 0 and no diagnostic
      output.
- [x] [P7-T3] Test: CMD-SH-QC with subcommand `test` (runs the bats suites under `tests/shell`).
      Write FEATURE/evidence/qa-gates/shell-test.TS.md. Acceptance: the TAP plan line is `1..478` (the 477
      baseline tests plus the one test added by P1-T14), every `not ok` line names a KL-SHELL-2 member,
      and the artifact carries `ExpectedExitCode: 1` when a KL-SHELL-2 member fails. Local numeric bash
      coverage is not obtainable while a KL-SHELL-2 member fails (the wrapper prints the coverage line
      only on a fully passing run), so the coverage values for this language come from CI in P10-T5 and
      P10-T6.

### Phase 8 — Final QA Loop: PowerShell (PoshQC and Pester)

- [x] [P8-T1] Format: CMD-PS-SCRIPT with script file-hashes over `.claude/lib/ci-gate/Invoke-CiGateParser.ps1 tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
      (before); MCP-PS-FORMAT with scan_folders `.claude/lib/ci-gate`, `tests/scripts/claude-lib/ci-gate`,
      `scripts/powershell/PoshQC/settings`; the same file-hashes run (after); CMD-PS-SCRIPT with script
      ps-format-check (A6) over the same four files. Write FEATURE/evidence/qa-gates/powershell-format.TS.md.
      Acceptance: the MCP call returns without raising, the before and after hashes are identical for all
      four files, and A6 prints `FORMAT-SUMMARY ChangedCount=0`.
- [x] [P8-T2] Analyze `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` and the three other P8-T1 files.
      Commands: MCP-PS-ANALYZE with the P8-T1 scan_folders, then CMD-PS-SCRIPT with script pssa-count
      (A9) over the four P8-T1 files. Write FEATURE/evidence/qa-gates/powershell-analyze.TS.md.
      Acceptance: the MCP call returns without raising and A9 prints `PSSA-SUMMARY DiagnosticCount=0`.
- [x] [P8-T3] Test with coverage for `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`, written to FEATURE/evidence/qa-gates/powershell-test-coverage.TS.md.
      Command: CMD-PS-SCRIPT with script pester-coverage (A3), `-TestPath tests/scripts/claude-lib/ci-gate`,
      `-CoveragePath .claude/lib/ci-gate/Invoke-CiGateParser.ps1`, `-CoverageOutputPath SCRATCH/ci-gate-final.xml`.
      Acceptance: `PassedCount=17`, `FailedCount=0`, and the
      `COVERAGE file=.claude/lib/ci-gate/Invoke-CiGateParser.ps1` line's `LinePercent=` is at least 85
      and at least the P0-T17 baseline value.
- [x] [P8-T4] Regression over `tests/scripts/claude-lib`, written to FEATURE/evidence/qa-gates/powershell-claude-lib.TS.md.
      Command: CMD-PS-SCRIPT with script pester-counts (A2) and `-Path tests/scripts/claude-lib`.
      Acceptance: `TotalCount=` equals the P0-T18 value plus 17 (15 moved-in parser tests and 2 manifest
      tests), and every `FAILED:` line is a member of the P0-T18 baseline failure set.

### Phase 9 — Final QA Loop: Python (black, ruff, pyright, pytest with coverage)

- [x] [P9-T1] Format: CMD-GIT-STATUS (before), CMD-PY-BLACK over `scripts/dev_tools/skill_bundle_contract.py scripts/dev_tools/skill_bundle_contract_cli.py tests/scripts/dev_tools/test_skill_bundle_contract.py tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py tests/scripts/dev_tools/test_skill_bundle_contract_cli.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`,
      CMD-GIT-STATUS (after). Write FEATURE/evidence/qa-gates/python-format.TS.md. Acceptance: black exits 0
      and prints "6 files left unchanged." with no "reformatted" line, and the two status outputs are
      identical.
- [x] [P9-T2] Lint: CMD-PY-RUFF over the six files of P9-T1 (`scripts/dev_tools/skill_bundle_contract.py`
      and the other five). Write FEATURE/evidence/qa-gates/python-lint.TS.md. Acceptance: exit 0 and
      "All checks passed!".
- [x] [P9-T3] Type-check the six P9-T1 files and `scripts/dev_tools tests/scripts/dev_tools`.
      Commands: CMD-PY-PYRIGHT over the six files, then CMD-PY-PYRIGHT over
      `scripts/dev_tools tests/scripts/dev_tools`. Write FEATURE/evidence/qa-gates/python-typecheck.TS.md.
      Acceptance: the first run exits 0 with a summary line beginning "0 errors"; the second run's error
      count is not greater than the P0-T13 baseline count.
- [x] [P9-T4] Test with coverage for `scripts/dev_tools/skill_bundle_contract.py` and `scripts/dev_tools/skill_bundle_contract_cli.py`.
      Commands: `poetry run pytest -v tests/scripts/dev_tools/test_skill_bundle_contract.py tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py tests/scripts/dev_tools/test_skill_bundle_contract_cli.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py --cov=scripts.dev_tools.skill_bundle_contract --cov=scripts.dev_tools.skill_bundle_contract_cli --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/cov-762-new.json`,
      then CMD-PY-SCRIPT with script py-cov-files (A7) and arguments
      `SCRATCH/cov-762-new.json scripts/dev_tools/skill_bundle_contract.py scripts/dev_tools/skill_bundle_contract_cli.py`.
      Write FEATURE/evidence/qa-gates/python-test-coverage-new.TS.md. Acceptance: pytest exits 0 with no
      FAILED line and the artifact records the collected node count; for each of the two modules A7 prints
      `LinePercent=` at least 85 and `BranchPercent=` at least 75.
- [x] [P9-T5] Test with coverage for the whole `tests/scripts/dev_tools` tree, written to FEATURE/evidence/qa-gates/python-test-coverage-total.TS.md.
      Commands: `poetry run pytest tests/scripts/dev_tools --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/cov-762-final.json`,
      then CMD-PY-SCRIPT with script py-cov-files (A7) and arguments `SCRATCH/cov-762-final.json TOTAL`.
      Acceptance: the only failing node, if any, satisfies KL-510 case (b); the collected total (passed
      plus failed plus skipped) equals the P0-T14 collected total plus the P9-T4 node count; A7 prints
      `LinePercent=` at least 85 and `BranchPercent=` at least 75.
- [x] [P9-T6] File-size limit check, written to FEATURE/evidence/qa-gates/line-counts-final.TS.md.
      Command: CMD-PS-SCRIPT with script line-counts over the six P9-T1 Python files,
      `.claude/skills/cleanup-merged-worktrees/scripts/*.sh`, SHELLLIB, `tests/shell/test_shell_qc_discovery.bats`,
      `tests/shell/test_shell_qc_commands.bats`, `tests/shell/test_cleanup_worktrees_*.bats`,
      `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`, `tests/scripts/claude-lib/ci-gate/*.ps1`, and
      `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. Acceptance: every `LineCount=` value is
      at most 500, and every relocated or path-edited file's count equals its P0-T9 value (moved scripts
      are matched to their P0-T9 entry by basename) except
      `tests/shell/test_shell_qc_discovery.bats` (grows by 7 per B9),
      `tests/shell/test_shell_qc_commands.bats` (grows by 1 per B10), and
      `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (grows by 5 per B11).

### Phase 10 — CI Verification and Coverage Comparison

- [x] [P10-T1] TypeScript push-down regression for `extensions/drm-copilot/test/lib/push-down`: CMD-TS-TEST.
      Write FEATURE/evidence/qa-gates/ts-push-down-jest.TS.md. Acceptance: every `FAIL ` line is a member
      of the P0-T20 baseline failure set and the "Tests:" line records no more failed tests than the
      baseline.
- [x] [P10-T2] Commit and push any remaining changes: CMD-GIT-STATUS, then CMD-GIT-ADD with
      `FEATURE/evidence FEATURE/plan.2026-09-28T23-50.md` plus every path that CMD-GIT-STATUS listed
      (fixes made by Phase 7-9 loop restarts), CMD-GIT-COMMIT with message
      "docs(762): record final QA evidence", CMD-GIT-PUSH; then CMD-GIT-HEAD. Acceptance:
      CMD-GIT-STATUS prints nothing, the push exits 0, and the HEAD value is recorded as FINAL_SHA in
      FEATURE/evidence/qa-gates/ci-dispatch.TS.md.
- [x] [P10-T3] Dispatch CI on the branch: CMD-GH-DISPATCH (workflow `.github/workflows/ci.yml`), then
      CMD-CI-WAIT with FINAL_SHA (run in the background), then CMD-GH-RUNS-FOR-SHA with FINAL_SHA. Append
      to FEATURE/evidence/qa-gates/ci-dispatch.TS.md. Acceptance: exactly one run with event
      `workflow_dispatch` exists for FINAL_SHA, its status is `completed`, and its conclusion is `success`.
- [x] [P10-T4] Record the CI jobs from `.github/workflows/_shell-coverage.yml`, `.github/workflows/_poshqc.yml`, and `.github/workflows/_quality-checks.yml`.
      Command: CMD-GH-JOBS with the P10-T3 run id. Write FEATURE/evidence/qa-gates/ci-jobs.TS.md.
      Acceptance: the jobs named "Shell Coverage (Bats + kcov)" and "PowerShell QC", and the job defined by
      `_quality-checks.yml` (which runs pytest over `tests/`, including the guard), each have conclusion
      `success`.
- [x] [P10-T5] Bash coverage from CI (`.github/workflows/_shell-coverage.yml`), written to FEATURE/evidence/qa-gates/shell-coverage-ci.TS.md.
      Command: CMD-CI-SHELL-COV with the P10-T3 run id. Acceptance: the output contains exactly one line
      of the form `Bash coverage (lines): <n>%`, and n is at least 85.0 and at least the P0-T19 baseline
      value.
- [x] [P10-T6] Bash per-file coverage from CI for `.claude/skills/cleanup-merged-worktrees/scripts`, written to FEATURE/evidence/qa-gates/shell-coverage-files.TS.md.
      Commands: CMD-GH-DOWNLOAD with the P10-T3 run id into `SCRATCH/shell-cov-final`, then CMD-PY-SCRIPT
      with script cobertura-files (A17) and arguments `SCRATCH/shell-cov-final/cov.xml` SHELLLIB followed
      by the ten `.claude/skills/cleanup-merged-worktrees/scripts/` paths. Acceptance: no `MISSING` line
      (each of the ten skill scripts is measured under its new path, which is the AC5 coverage
      observation), and each file's `line-rate` is not lower than its P0-T19 baseline `line-rate` at the
      old path.
- [x] [P10-T7] Coverage comparison: write FEATURE/evidence/qa-gates/coverage-comparison.TS.md from the
      artifacts of P0-T14, P0-T17, P0-T19, P8-T3, P9-T4, P9-T5, P10-T5, and P10-T6. Acceptance: the
      artifact carries, for bash, PowerShell, and Python, the fields `Baseline Coverage:`,
      `Post-Change Coverage:`, `New/Changed-code Coverage:`, and `Disposition:` with numeric values
      (bash: CI line totals and per-file line-rates for the shell QC library and the ten moved scripts;
      PowerShell: parser line percent before and after; Python: dev-tools total line and branch percent
      before and after, and the two new modules' line and branch percent as the new-code value).
      `Disposition:` is `PASS` only when every threshold of P8-T3, P9-T4, P9-T5, P10-T5, and P10-T6 holds;
      otherwise `BLOCKED`.

### Phase 11 — Final QA Confirmation and Acceptance-Criteria Check-Off

- [x] [P11-T1] Re-run the guard tests in `tests/scripts/dev_tools/test_skill_bundle_contract*.py` as the closing test gate.
      Command: CMD-PY-TEST over `tests/scripts/dev_tools/test_skill_bundle_contract.py tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py tests/scripts/dev_tools/test_skill_bundle_contract_cli.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`.
      Write FEATURE/evidence/qa-gates/guard-final.TS.md. Acceptance: exit 0 and no FAILED line.
- [x] [P11-T2] Check off AC1 in `FEATURE/spec.md` (the box becomes lowercase x). Acceptance: the
      P6-T5 artifact exists with `AUDIT skills=56 missing=0`; the check-off is recorded in
      FEATURE/evidence/other/ac-checkoff.TS.md with that artifact cited.
- [x] [P11-T3] Check off AC2 in `FEATURE/spec.md`. Acceptance: the P1-T11 (fail-before), P2-T13, P4-T1,
      P4-T2, P4-T5, and P6-T1 artifacts exist with passing acceptance; cited in the ac-checkoff artifact.
- [x] [P11-T4] Check off AC3 in `FEATURE/spec.md`. Acceptance: the P1-T11 (fail-before), P1-T19
      (fail-before), P3-T10, P4-T4, P4-T7, and P6-T1 artifacts exist with passing acceptance; cited in the
      ac-checkoff artifact.
- [x] [P11-T5] Check off AC4 in `FEATURE/spec.md`. Acceptance: the P6-T3 and P6-T4 artifacts exist with
      passing acceptance; cited in the ac-checkoff artifact.
- [x] [P11-T6] Check off AC5 in `FEATURE/spec.md`. Acceptance: the P1-T16 (fail-before), P5-T3, P5-T4,
      P7-T2, and P10-T6 artifacts exist with passing acceptance; cited in the ac-checkoff artifact.
- [x] [P11-T7] Check off AC6 in `FEATURE/spec.md`. Acceptance: the P1-T5, P1-T11 (fail-before), P6-T1,
      and P10-T4 artifacts exist with passing acceptance (P10-T4 shows the guard runs in the CI Python
      stage); cited in the ac-checkoff artifact.
- [x] [P11-T8] Check off AC7 in `FEATURE/spec.md`. Acceptance: the P1-T5 artifact shows
      `test_find_stale_exceptions_reports_unmatched_exception` and
      `test_known_unbundled_references_cite_issue_763` PASSED, and the P6-T1 artifact shows
      `test_known_unbundled_references_are_not_stale` PASSED; cited in the ac-checkoff artifact.
- [x] [P11-T9] Check off AC8 in `FEATURE/spec.md`. Acceptance: every Phase 7, 8, 9, and 10 artifact
      exists with passing acceptance and the P10-T7 `Disposition:` is `PASS`; cited in the ac-checkoff
      artifact. If the disposition is `BLOCKED`, AC8 stays unchecked and the plan outcome is
      remediation-required.
- [x] [P11-T10] Commit and push the check-off in `FEATURE/spec.md`: CMD-GIT-ADD with `FEATURE/spec.md FEATURE/evidence FEATURE/plan.2026-09-28T23-50.md`,
      CMD-GIT-COMMIT with message "docs(762): check off acceptance criteria", CMD-GIT-PUSH. Acceptance:
      CMD-GIT-STATUS prints nothing and the push exits 0.

---

## Acceptance Criteria Traceability

| AC | Implementation tasks | Verifying tasks | Evidence |
| --- | --- | --- | --- |
| AC1 | research artifact (pre-existing) | P6-T5 | qa-gates/ac1-audit-coverage |
| AC2 | P2-T1..P2-T11, P4-T1, P4-T2, P4-T5 | P1-T11 (fail-before), P2-T13, P6-T1 | regression-testing/guard-after-fix |
| AC3 | P3-T2..P3-T9, P4-T3, P4-T4, P4-T6 | P1-T11, P1-T19 (fail-before), P3-T10, P4-T7, P6-T1 | regression-testing/ci-gate-manifest-after-fix |
| AC4 | P2-T2..P2-T11, P3-T2..P3-T9, P4-T2, P4-T3 | P2-T6, P2-T12, P6-T3, P6-T4 | qa-gates/old-path-sweep |
| AC5 | P1-T13..P1-T15, P5-T1, P5-T2, P5-T5, P5-T6 | P1-T16 (fail-before), P5-T3, P5-T4, P7-T2, P10-T6 | qa-gates/shell-coverage-files |
| AC6 | P1-T2, P1-T7, P1-T9 | P1-T5, P1-T11, P6-T1, P10-T4 | regression-testing/guard-after-fix |
| AC7 | P1-T2 (`KNOWN_UNBUNDLED_REFERENCES`), P1-T4 | P1-T5, P6-T1 | regression-testing/guard-units-initial |
| AC8 | Phases 7-10 | P7-T1..P10-T7 | qa-gates/coverage-comparison |

---

## Appendix A — Scratch Scripts

Scripts A1 through A20 are written verbatim under SCRATCH by P0-T6. They are never committed.

A1 run-ps.sh:

```sh
#!/bin/sh
set -eu
pwsh -NoProfile -NonInteractive -File "$@"
```

A2 pester-counts.ps1:

```powershell
param([Parameter(Mandatory)][string] $Path)
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

A3 pester-coverage.ps1:

```powershell
param(
    [Parameter(Mandatory)][string] $TestPath,
    [Parameter(Mandatory)][string[]] $CoveragePath,
    [Parameter(Mandatory)][string] $CoverageOutputPath
)
$CoveragePath = @($CoveragePath | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$configuration = New-PesterConfiguration
$configuration.Run.Path = $TestPath
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Detailed'
$configuration.CodeCoverage.Enabled = $true
$configuration.CodeCoverage.Path = $CoveragePath
$configuration.CodeCoverage.OutputPath = $CoverageOutputPath
$result = Invoke-Pester -Configuration $configuration
Write-Output "TotalCount=$($result.TotalCount)"
Write-Output "PassedCount=$($result.PassedCount)"
Write-Output "FailedCount=$($result.FailedCount)"
foreach ($failedTest in $result.Failed) { Write-Output "FAILED: $($failedTest.ExpandedPath)" }
$executed = @($result.CodeCoverage.CommandsExecuted)
$missed = @($result.CodeCoverage.CommandsMissed)
foreach ($file in $CoveragePath) {
    $fullPath = (Resolve-Path -LiteralPath $file).Path
    $hitLines = @($executed | Where-Object { $_.File -eq $fullPath } | ForEach-Object { $_.Line } | Sort-Object -Unique)
    $missLines = @($missed | Where-Object { $_.File -eq $fullPath } | ForEach-Object { $_.Line } | Sort-Object -Unique)
    $analyzed = @(@($hitLines) + @($missLines) | Sort-Object -Unique)
    $percent = if ($analyzed.Count -eq 0) { 'NA' } else { [math]::Round(100 * $hitLines.Count / $analyzed.Count, 2) }
    Write-Output "COVERAGE file=$file AnalyzedLines=$($analyzed.Count) CoveredLines=$($hitLines.Count) LinePercent=$percent"
}
```

A4 line-counts.ps1:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
foreach ($file in $Path) { Write-Output "$file LineCount=$((Get-Content -LiteralPath $file).Count)" }
```

A5 file-hashes.ps1:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
foreach ($file in $Path) { Write-Output "$file Hash=$((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash)" }
```

A6 ps-format-check.ps1 (read-only):

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

If A6 reports `Changed=True` for a file whose hash the MCP format call left unchanged, the two
formatters use different settings; stop and report rather than editing the file by hand.

A7 py-cov-files.py (the argument `TOTAL` reads the report totals):

```python
import json
import sys
from pathlib import Path

report = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
files = report["files"]
for target in sys.argv[2:]:
    if target == "TOTAL":
        summary = report["totals"]
    else:
        key = target if target in files else target.replace("/", "\\")
        data = files.get(key)
        if data is None:
            print(f"COVERAGE file={target} MISSING")
            continue
        summary = data["summary"]
    statements = summary["num_statements"]
    branches = summary["num_branches"]
    line_pct = 100.0 * summary["covered_lines"] / statements if statements else 100.0
    branch_pct = 100.0 * summary["covered_branches"] / branches if branches else 100.0
    print(f"COVERAGE file={target} LinePercent={line_pct:.2f} BranchPercent={branch_pct:.2f}")
```

A8 reset-batch-budget.ps1:

```powershell
param([Parameter(Mandatory)][ValidateSet('python', 'powershell')][string] $Kind)
$stateDirectory = '.claude/state'
if (-not (Test-Path -LiteralPath $stateDirectory)) { Write-Output 'RESET removed=0'; return }
$stateFiles = @(Get-ChildItem -LiteralPath $stateDirectory -Filter "$Kind-batch-budget.*.json" -File)
foreach ($stateFile in $stateFiles) { Write-Output "RESET file=$($stateFile.Name)"; Remove-Item -LiteralPath $stateFile.FullName }
Write-Output "RESET removed=$($stateFiles.Count)"
```

A9 pssa-count.ps1:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$records = @(foreach ($file in $Path) { Invoke-ScriptAnalyzer -Path $file -Settings $settings })
foreach ($record in $records) { Write-Output "PSSA $($record.ScriptName):$($record.Line) $($record.RuleName) $($record.Severity)" }
Write-Output "PSSA-SUMMARY DiagnosticCount=$($records.Count)"
```

A10 psd1-parse.ps1:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
$ErrorActionPreference = 'Stop'
foreach ($file in $Path) { $null = Import-PowerShellDataFile -LiteralPath $file; Write-Output "PSD1-OK file=$file" }
```

A11 run-shell-qc.sh (`pwd -W` yields the Windows path of the worktree root under the Git for Windows
`sh`):

```sh
#!/bin/sh
set -eu
root=$(pwd -W)
wsl.exe -d Ubuntu --cd "$root" -e bash -lc "bash scripts/bash/shell-qc.sh $*"
```

A12 run-bats.sh:

```sh
#!/bin/sh
set -eu
root=$(pwd -W)
wsl.exe -d Ubuntu --cd "$root" -e bats "$@"
```

A13 run-discover.sh:

```sh
#!/bin/sh
set -eu
root=$(pwd -W)
wsl.exe -d Ubuntu --cd "$root" -e bash -c 'source scripts/bash/shell_qc_lib.sh && discover_shell_scripts'
```

A14 old-path-sweep.sh (arguments are pathspecs; searches tracked and untracked non-ignored files):

```sh
#!/bin/sh
set -u
rc=0
git grep -n --untracked -F -e 'scripts/bash/cleanup' -e 'scripts/orchestration/Invoke-CiGateParser' -e 'tests/scripts/orchestration/' -- "$@" || rc=$?
echo "SWEEP-EXIT=$rc"
```

A15 move-cleanup-scripts.sh:

```sh
#!/bin/sh
set -eu
dest=.claude/skills/cleanup-merged-worktrees/scripts
mkdir -p "$dest"
for name in cleanup-worktrees.sh cleanup_worktrees_actions_lib.sh cleanup_worktrees_detached_lib.sh cleanup_worktrees_dirt_lib.sh cleanup_worktrees_enumerate_lib.sh cleanup_worktrees_lib.sh cleanup_worktrees_preserve_eol_lib.sh cleanup_worktrees_preserve_lib.sh cleanup_worktrees_report_records_lib.sh cleanup_worktrees_scan_helper.sh; do
  git mv "scripts/bash/$name" "$dest/$name"
  echo "MOVED $name"
done
```

A16 json-parse.ps1:

```powershell
param([Parameter(Mandatory)][string] $Path)
$ErrorActionPreference = 'Stop'
$null = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
Write-Output "JSON-OK file=$Path"
```

A17 cobertura-files.py (arguments: report path, then path suffixes to report):

```python
import sys
import xml.etree.ElementTree as ElementTree
from pathlib import Path

root = ElementTree.parse(Path(sys.argv[1])).getroot()
print(f"COBERTURA-TOTAL line-rate={root.get('line-rate')}")
classes = [(item.get("filename", "").replace("\\", "/"), item.get("line-rate")) for item in root.iter("class")]
for suffix in sys.argv[2:]:
    hits = [(name, rate) for name, rate in classes if name.endswith(suffix)]
    if not hits:
        print(f"COBERTURA file={suffix} MISSING")
    for name, rate in hits:
        print(f"COBERTURA file={name} line-rate={rate}")
```

A18 skill-audit-coverage.sh:

```sh
#!/bin/sh
set -eu
research=docs/features/active/2026-09-28-skill-referenced-scripts-not-bundled-762/research/2026-09-28T19-15-skill-bundle-audit-research.md
count=0
missing=0
for dir in .claude/skills/*/; do
  name=$(basename "$dir")
  count=$((count + 1))
  if ! grep -qF "$name" "$research"; then echo "MISSING $name"; missing=$((missing + 1)); fi
done
echo "AUDIT skills=$count missing=$missing"
```

A19 ci-wait.sh (argument: head SHA; exits 3 after 90 polls of 60 seconds):

```sh
#!/bin/sh
set -eu
sha="$1"
polls=0
while :; do
  statuses=$(gh run list --commit "$sha" --json status --jq '.[].status')
  if [ -n "$statuses" ] && ! printf '%s\n' "$statuses" | grep -qv '^completed$'; then
    break
  fi
  polls=$((polls + 1))
  if [ "$polls" -ge 90 ]; then
    echo "CI-WAIT-TIMEOUT sha=$sha"
    exit 3
  fi
  sleep 60
done
gh run list --commit "$sha" --json name,status,conclusion,event,databaseId
```

A20 ci-shell-coverage-log.sh (argument: run id):

```sh
#!/bin/sh
set -eu
gh run view "$1" --log | grep -E 'Bash coverage \(lines\): [0-9]'
```

## Appendix B — Implementation and Test Specifications

B1 `scripts/dev_tools/skill_bundle_contract.py` (pure logic; no filesystem, network, or subprocess
access; Google-style docstrings and intent comments per `.claude/rules/self-explanatory-code-commenting.md`):

- `PUBLISHED_ROOT_FOLDERS: tuple[str, ...] = (".claude", "config")`.
- `@dataclass(frozen=True) class SkillBundleViolation` with fields `skill: str`, `path: str`,
  `reason: str`; `reason` is one of `missing-file`, `not-in-bundle`, `not-in-skill-pack` (validated in
  `__post_init__`, raising `ValueError` otherwise).
- `@dataclass(frozen=True) class KnownUnbundledReference` with fields `skill: str`, `path: str`,
  `issue: str`.
- `KNOWN_UNBUNDLED_REFERENCES` holds exactly
  `KnownUnbundledReference("parallel-orchestrate", "scripts/dev_tools/parallel_drift_detection_cli.py", "#763")`
  and `KnownUnbundledReference("parallel-remove", "scripts/dev_tools/parallel_mutation_abandon_cli.py", "#763")`.
- `@dataclass(frozen=True) class SkillBundleInputs` with fields `skill_texts: Mapping[str, str]`
  (skill name to `SKILL.md` text), `skill_folder_files: Mapping[str, frozenset[str]]` (skill name to
  repository-relative POSIX paths of every file in that skill folder), `repository_files: frozenset[str]`,
  `bundle_files: frozenset[str]` (paths relative to BUNDLE), and `pack_paths: Mapping[str, frozenset[str]]`
  (pack name to its manifest `paths`).
- `parse_allowed_tools(skill_text: str) -> tuple[str, ...]`: locates the YAML frontmatter (text
  between a leading `---` line and the next `---` line) but does not parse the whole frontmatter,
  because some `description:` values carry an unquoted colon that `yaml.safe_load` rejects
  (`.claude/skills/csharp-change-budget-router/SKILL.md` and
  `.claude/skills/powershell-change-budget-router/SKILL.md`). It extracts only the line that begins
  `allowed-tools:` plus its indented continuation lines, and parses that block alone with
  `yaml.safe_load` (PyYAML is an existing dependency). A list value is returned as a tuple of strings;
  a scalar string value (the `allowed-tools: Bash Read` form used by two skills) is split on
  whitespace. Returns `()` when there is no frontmatter or no `allowed-tools` line; raises
  `ValueError` when a leading `---` has no closing `---`.
- `extract_script_references(skill_text: str) -> tuple[str, ...]`: scans the body and every
  `allowed-tools` entry (a `Bash(...)` entry is scanned with its wrapper removed) for these invocation
  forms and returns the sorted, de-duplicated repository-relative paths: `bash <path>`, `sh <path>`,
  `source <path>` (word-bounded, so `bash` does not also match `sh`); `pwsh ... -File <path>` on one line;
  `& <path>`; `. <path>` (dot-source, preceded by start of line, whitespace, `(`, or a backtick);
  `Import-Module <path>`; `Import-Module (Join-Path <expr> '<path>')` (single or double quotes);
  `python <path>.py` and `python3 <path>.py`; `python -m <dotted.name>` with at least one dot, resolved
  to `<dotted/name>.py`. A path token consists of letters, digits, `_`, `.`, `/`, and `-`, ends in
  `.sh`, `.ps1`, `.psm1`, or `.py`, and is followed by whitespace, a quote, a backtick, `)`, or end of
  text. A leading `./` is removed. Tokens containing `*`, `<`, `>`, `{`, `}`, or `$` are ignored
  (globs and placeholders). A backticked path with no invocation form is a citation and is not
  returned.
- `evaluate_skill_bundle(skill: str, references: Iterable[str], inputs: SkillBundleInputs) -> tuple[SkillBundleViolation, ...]`:
  for each reference, in order: not in `repository_files` gives `missing-file`; first path component
  not in `PUBLISHED_ROOT_FOLDERS`, or path not in `bundle_files`, gives `not-in-bundle`; otherwise,
  with `skill_packs` the packs whose paths contain `.claude/skills/<skill>/SKILL.md`, the reference is
  carried when it is in `pack_paths["core"]` or in every pack of `skill_packs` (a skill listed by no
  pack is carried only through `core`), else `not-in-skill-pack`. Then each file of
  `skill_folder_files[skill]` is checked with the bundle and pack rules (a missing bundle copy gives
  `not-in-bundle`, a missing pack entry gives `not-in-skill-pack`). Folder location is never a reason:
  a reference outside the skill folder that is bundled and carried produces no violation.
- `find_violations(inputs: SkillBundleInputs, *, exceptions: Iterable[KnownUnbundledReference] = KNOWN_UNBUNDLED_REFERENCES) -> tuple[SkillBundleViolation, ...]`:
  evaluates every skill in sorted order and drops violations whose `(skill, path)` matches an
  exception.
- `find_stale_exceptions(inputs: SkillBundleInputs, *, exceptions: Iterable[KnownUnbundledReference] = KNOWN_UNBUNDLED_REFERENCES) -> tuple[KnownUnbundledReference, ...]`:
  returns every exception whose `(skill, path)` does not occur among the violations computed with no
  exceptions.

Fictitious-path rule (applies to B2, B3, and B5): inline test strings must not contain the literals
`scripts/bash/cleanup`, `scripts/orchestration/Invoke-CiGateParser`, or `tests/scripts/orchestration/`,
because the P6-T3 old-path sweep searches `tests/`. Use fictitious paths such as
`scripts/tools/example.sh`, `scripts/tools/Example.ps1`, and `.claude/lib/example/example.sh`.

B2 `tests/scripts/dev_tools/test_skill_bundle_contract.py` test names (inline strings only, fictitious
paths per the rule above):
`test_parse_allowed_tools_returns_list_entries`, `test_parse_allowed_tools_returns_empty_without_frontmatter`,
`test_parse_allowed_tools_raises_on_unterminated_frontmatter`,
`test_parse_allowed_tools_ignores_unparseable_description` (a frontmatter whose `description:` value
carries an unquoted colon still yields the `allowed-tools` list),
`test_parse_allowed_tools_splits_scalar_string_value` (`allowed-tools: Bash Read` yields
`("Bash", "Read")`), `test_extract_reads_bash_allowed_tools_pattern`,
`test_extract_reads_bash_sh_and_source_forms` (parametrized over the three verbs),
`test_extract_reads_pwsh_file_form`, `test_extract_reads_call_operator_and_dot_source_forms` (parametrized
over the two operators), `test_extract_reads_import_module_path_form`,
`test_extract_reads_import_module_join_path_form`, `test_extract_reads_python_path_form`,
`test_extract_resolves_python_module_form`, `test_extract_normalizes_leading_dot_slash`,
`test_extract_ignores_placeholder_paths`, `test_extract_ignores_glob_paths`,
`test_extract_ignores_backticked_citation_without_invocation`, `test_extract_deduplicates_and_sorts_references`.

B3 `tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py` test names (inline
`SkillBundleInputs` only, fictitious paths per the rule above): `test_evaluate_reports_missing_file`,
`test_evaluate_reports_not_in_bundle_for_unpublished_root`, `test_evaluate_reports_not_in_bundle_when_bundle_lacks_file`,
`test_evaluate_reports_not_in_skill_pack_for_pack_specific_skill`, `test_evaluate_accepts_reference_listed_in_core`,
`test_evaluate_accepts_reference_listed_in_every_skill_pack`,
`test_evaluate_accepts_script_outside_skill_folder_when_bundled`,
`test_evaluate_reports_skill_folder_file_missing_from_packs`, `test_find_violations_suppresses_known_exceptions`,
`test_find_stale_exceptions_reports_unmatched_exception`, `test_find_stale_exceptions_returns_empty_when_all_match`,
`test_known_unbundled_references_cite_issue_763`.

B4 `scripts/dev_tools/skill_bundle_contract_cli.py`:

- `load_repository_inputs(repo_root: Path) -> SkillBundleInputs`: reads every
  `.claude/skills/<name>/SKILL.md`; lists every file under each `.claude/skills/<name>/` as a
  repository-relative POSIX path; sets `repository_files` to the skill-folder files plus every
  extracted reference that is an existing file under `repo_root`; lists every file under BUNDLE's
  `.claude` and `config` folders relative to BUNDLE; parses every `BUNDLE/pack-manifests/*.json` into
  `pack_paths` keyed by file stem. Raises `FileNotFoundError` when `.claude/skills` or the manifest
  folder is absent.
- `main(argv: Sequence[str] | None = None, *, loader: Callable[[Path], SkillBundleInputs] = load_repository_inputs) -> int`:
  accepts `--repo-root` (default current directory); prints one stderr line per violation,
  `skill-bundle violation: <skill> | <path> | <reason>`, and one per stale exception,
  `skill-bundle stale exception: <skill> | <path> | <issue>`; returns 1 when any line was printed, else 0.
  The module ends with the standard `if __name__ == "__main__":` guard raising `SystemExit(main())`.

B5 `tests/scripts/dev_tools/test_skill_bundle_contract_cli.py` test names (injected loader returning
inline inputs with fictitious paths per the rule above; `capsys` for stderr): `test_main_returns_zero_when_clean`,
`test_main_returns_one_and_prints_violation_lines`, `test_main_returns_one_for_stale_exception`,
`test_main_prints_nothing_to_stderr_when_clean`.

B6 `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` (reads the real repository tree,
rooted at `Path(__file__).resolve().parents[3]`; creates no files):

- `test_every_skill_script_reference_is_bundled`: `find_violations(load_repository_inputs(root))` is
  empty; the assertion message lists each violation as `<skill> | <path> | <reason>`, one per line.
- `test_ci_gate_parser_skills_invoke_bundled_parser`: for `orchestrate` and `epic-orchestrate`, the
  references extracted from `.claude/skills/<name>/SKILL.md` contain
  `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`.
- `test_every_skill_folder_file_is_carried_by_skill_packs`: evaluating every skill with an empty
  reference list yields no violation (isolates the skill-folder check).
- `test_known_unbundled_references_are_not_stale`: `find_stale_exceptions(load_repository_inputs(root))`
  is empty.
- `test_published_root_folders_match_typescript_root_folders`: the string literals of the
  `export const ROOT_FOLDERS` declaration in `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`
  (line 54) equal `PUBLISHED_ROOT_FOLDERS` in order.

B7 `tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1`: modeled on
`tests/scripts/claude-lib/model-routing/ModelRouting.Manifest.Tests.ps1`; comment-based help; repo root
resolved four levels up from `$PSScriptRoot`; reads BUNDLE `pack-manifests/core.json` with
`ConvertFrom-Json`; expected path `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`;
`Describe 'CiGate core.json manifest membership'` with `It 'lists the CI gate parser path in core.json paths'`
and `It 'lists the CI gate parser path exactly once'`; Arrange-Act-Assert comments; no temporary files.

B8 fixture `tests/fixtures/shell_qc/.claude/skills/demo-skill/scripts/skill_entry.sh`, exactly three
lines:

```sh
#!/usr/bin/env bash
set -euo pipefail
echo "claude skill script fixture"
```

B9 `tests/shell/test_shell_qc_discovery.bats`: insert after line 65 a blank line and this five-line
test (six added lines in total):

```sh
@test "discover_shell_scripts finds a .sh file under the .claude/skills root" {
    run bash -c "cd '${FIXTURE_ROOT}' && source '${LIB}' && discover_shell_scripts"
    [ "$status" -eq 0 ]
    [[ "$output" == *".claude/skills/demo-skill/scripts/skill_entry.sh"* ]]
}
```

In the sorted-output test, change `-eq 6` to `-eq 7`, change the comment to say the two `.claude`
roots sort before `scripts/` and `tools/`, keep `lines[0]` as `.claude/lib/bash/lib_entry.sh`, set
`lines[1]` to `.claude/skills/demo-skill/scripts/skill_entry.sh`, and shift the five remaining
expectations to indices 2 through 6. The sorted-output test therefore grows by one line; with the new
test the file grows by 7 lines in total. P9-T6 compares against this total.

B10 `tests/shell/test_shell_qc_commands.bats`: line 81 becomes `    [ "$shellcheck_calls" -eq 7 ]`;
after line 129 insert `    [[ "$output" == *"--include-pattern="*"/.claude/skills"* ]]`.

B11 insertion into `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` after line 319:

```powershell
            # Issue #762 relocated the CI gate parser into the bundled .claude/lib tree so
            # push-down carries it with the orchestrate and epic-orchestrate skills.
            # CodeCoverage.Path is an explicit per-file allow-list, so the relocated production
            # file is registered here to stay in the coverage denominator.
            '.claude/lib/ci-gate/Invoke-CiGateParser.ps1'
```

B12 `.claude/skills/orchestrate/SKILL.md` line 275, full replacement text:

```text
3. Parse the JSON by running `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -ChecksJson <checks-json> -HeadSha <head-sha>`, which emits the `ci_gate` object defined below and derives `ci_gate.conclusion` as `success` when all required checks pass, `failure` when any required check failed, and `pending` when any required check is still in progress.
```

B13 `.claude/skills/epic-orchestrate/SKILL.md` line 109, full replacement text:

```text
   procedure (`pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1`) directly against this PR, records
```

B14 insertion into BUNDLE `pack-manifests/core.json` after line 76:

```text
    ".claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh",
    ".claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_actions_lib.sh",
    ".claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh",
    ".claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_dirt_lib.sh",
    ".claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh",
    ".claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_lib.sh",
    ".claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_eol_lib.sh",
    ".claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh",
    ".claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh",
    ".claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh",
```

B15 `scripts/bash/shell_qc_lib.sh` edits (line count unchanged):

```sh
	# Discover shell scripts under tools/, scripts/, .claude/lib/bash/, and
	# .claude/skills/ relative to the current dir.
```

(replaces lines 76-77), `	for root in tools scripts .claude/lib/bash .claude/skills; do` (replaces line 85),

```sh
	# Scope coverage to repo scripts/tools, the Claude bash library, and scripts bundled
	# inside skill folders; exclude the test sources themselves.
	local include_pattern="$repo_root/tools,$repo_root/scripts,$repo_root/.claude/lib/bash,$repo_root/.claude/skills"
```

(replaces lines 333-335). Indentation is one tab, matching the file.

B16 `.claude/rules/shell.md` replacement bullets (the first replaces the Discovery Contract
"Search roots" bullet, the second replaces the Coverage Expectations "kcov include pattern" bullet):

```text
- Search roots: `tools/`, `scripts/`, `.claude/lib/bash/`, and `.claude/skills/`, relative to the
  current working directory; a missing root is silently skipped. The `.claude/lib/bash/` root carries
  the destination-portable bash library published by push-down, and the `.claude/skills/` root carries
  scripts bundled inside a skill folder, so those scripts are held to the same format, lint, test, and
  coverage standards as `tools/` and `scripts/`.
```

```text
- The kcov include pattern covers all four discovery roots — `tools/`, `scripts/`,
  `.claude/lib/bash/`, and `.claude/skills/` — so the Claude bash library and skill-bundled scripts are
  measured, not merely discovered. The `tests/` tree remains excluded.
```
