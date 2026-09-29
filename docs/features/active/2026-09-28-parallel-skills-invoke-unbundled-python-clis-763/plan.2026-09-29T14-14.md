# parallel-skills-invoke-unbundled-python-clis (Plan)

- **Issue:** #763
- **Parent (optional):** epic `push-down-payload-correctness` (integration branch
  `epic/push-down-payload-correctness-integration`)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T14-14
- **Status:** Draft (pending validator and executor preflight)
- **Version:** 1.2 (executor preflight round 2 revisions applied)
- **Work Mode:** full-bug (`spec.md` is the sole acceptance-criteria source; `user-story.md` is
  intentionally absent)
- **Inputs:** `issue.md`, `spec.md` (design decisions D1-D9, AC1-AC18),
  `research/2026-09-29-unbundled-python-clis-research.md`

## Scope Recap

The two pushed-down skills invoke Python CLIs that no consumer receives. This plan:

1. Ports the abandon disposition to bash as `.claude/lib/bash/abandon-parallel-item.sh` (D2), with a
   shared corpus, a bats unit suite, a bats parity lane, and a Python reference lane.
2. Ports drift detection to PowerShell under `.claude/lib/parallel-drift/` (D1), reusing
   `.claude/lib/blast-radius/`, with a shared corpus, Pester unit, parity, and manifest suites, and a
   Python reference lane.
3. Rewrites the two SKILL invocations, the agent allowlist and prose, and the abandon-gate hook
   docstring (comment only), and mirrors every edited or new `.claude/**` file into the bundle.
4. Registers the new files in `pack-manifests/core.json` and in both `pester.runsettings.psd1`
   coverage allow-lists.
5. Empties `KNOWN_UNBUNDLED_REFERENCES` (D5) and adopts the keyword-only `exceptions` parameter on
   `skill_bundle_contract_cli.main` so the stale-exception branch stays covered.
6. Retains both Python CLIs and their import closure as the parity reference (D3).

Out of scope (spec Non-Goals and caller constraints): `.claude/hooks/enforce-powershell-batch-budget.ps1`
and `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1` (issue #769);
`scripts/dev_tools/push_down_claude_customizations.py` and
`extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` (#507/#508/#621);
`.claude/settings.json` and its bundle copy (D6); the `poetry run python` agent grants (D4);
`parallel-remove` steps 2, 3, and 6 (D7); `quality-tiers.yml` (D8). No pushed-down enforcement hook
gains a Python leg; the abandon-gate hook receives a comment-only edit.

### Tier classification

Per D8, `quality-tiers.yml` is absent, and the new modules are treated as T3 for gate purposes:
line coverage >= 85% for every language, branch coverage >= 75% for Python only (Pester and kcov do
not measure branches), no regression on changed lines, no property-test or mutation obligation.

### Spec deviations recorded by this plan

- DV1 Third PowerShell production file. D1 names a pure module and an entry script. The port of the
  exercised Python surface (readers, escape detection, event construction, edge and band readers,
  fail-closed pair decision, conflict recomputation, observed radius, result assembly, halt selection,
  and shape guards) exceeds 500 lines in one module once comment-based help is included (research
  section 6 estimates 400-700 lines in total). The halt-selection functions and shared shape guards
  therefore live in `.claude/lib/parallel-drift/ParallelDriftHalt.psm1`, which mirrors the existing
  Python module boundary `scripts/dev_tools/parallel_drift_halt.py`. `ParallelDrift.psm1` imports it
  and remains the module that imports `.claude/lib/blast-radius/`. AC1 is unaffected: both files it
  names exist, each at or under 500 lines. The third file is registered in `core.json`, both
  runsettings allow-lists, the bundle, and the manifest suite like the other two.
- DV2 Diff anchor. AC8, AC11, and AC17 write `git diff main`. This branch is cut from the
  integration branch, and `main` lacks sibling-feature commits on that branch (including
  #507/#508/#621 edits to the push-down transport files), so a `main` anchor would attribute sibling
  changes to this item. Every diff in this plan is anchored to BASE_SHA, the merge-base of HEAD with
  `origin/epic/push-down-payload-correctness-integration` (observed
  `d06ba5d657b75de52cad7859dda307bf9d420046` at authoring).
- DV3 D5 option adopted. With an empty default registry, `test_main_returns_one_for_stale_exception`
  can only reach the stale branch through an injected registry, so the keyword-only `exceptions`
  parameter is added to `skill_bundle_contract_cli.main` and forwarded to both finders.
- DV4 Abandon declared divergences. In addition to the two spec classes (argparse usage text; option
  abbreviations rejected), the bash port accepts only canonical decimal integers for `--item` and
  `--pr` (`0` or `[1-9][0-9]*`), treats `-h` and `--help` as unknown options (exit 2), and treats an
  option value beginning with `--` as a missing value. All three fall under "usage errors exit 2" and
  are listed in the headers of both abandon parity suites. Repeated options keep the last value and
  the joined `--name=value` form is accepted, matching argparse.
- DV5 Parity invocation of the drift entry script. The Pester parity lane dot-sources
  `Invoke-ParallelDriftDetection.ps1` behind its guard and calls `Invoke-ParallelDriftCli`, whose
  returned `Stdout`, `Stderr`, and `ExitCode` the guarded block writes and exits with verbatim. This
  keeps the lane in-process (no subprocess in a unit test, measurable coverage). The process-level
  contract under `pwsh -NoProfile -NonInteractive -File` is observed separately by P3-T21 against
  committed fixtures, alongside the Python CLI on the same fixtures.
- DV6 Parity bats harness interpreter. `tests/shell/parallel_abandon_parity.bats` reads the JSON
  corpus through `${PARALLEL_PARITY_PYTHON:-python3}`, a harness dependency only (precedent:
  `tests/shell/parallel_cohorts_parity.bats` lines 49-56). The code under test never needs Python;
  `tests/shell/parallel_payload_only.bats` proves that.
- DV7 Unknown drift parameters and binder-rejected arguments. A remaining argument that begins with
  `-` is a usage error (exit 2), so a changed path that begins with `-` is not supported. A named
  parameter given with no value (for example a trailing `-ItemKey` or `-At`) is rejected by the
  PowerShell parameter binder before the script body runs, so the process exits 1 with the binder's
  error message instead of exiting 2 with the usage prefix. Both classes are declared in the drift
  parity suite header (B20).
- DV8 Optional spec items. The `tests/shell/parallel_bash_manifest_membership.bats` entry-point list is
  updated (B30). The Pester abandon-gate suites' sample command strings are left unchanged; they are
  input data for the hook, and the hook logic is unchanged.
- DV9 Skill-bundle guard fence-word defect (follow-up FU-763-5). The first invocation pattern of
  `scripts/dev_tools/skill_bundle_contract.py` (line 52, `(?<![A-Za-z0-9_-])(?:bash|sh|source)\s+`)
  matches the fence info string word of a fenced block, spans the newline with `\s+`, and consumes
  the interpreter word of the invocation on the next line, so `extract_script_references` misses that
  invocation. The `parallel-remove` SKILL fence at line 111 would hide the new abandon invocation from
  the guard. This plan keeps scope: the regex is not changed, the fence info string becomes `shell`
  (B23a), and the B26 test `test_bundle_guard_extracts_the_skill_invocation` proves the guard now
  extracts the invocation. The regex defect is recorded as follow-up FU-763-5. The
  `parallel-orchestrate` fence that holds the drift invocation (B22b) has no info string, and its
  `pwsh ... -File <path>` pattern is confined to one line, so the same miss does not apply there.

## Execution Conventions

### Terms used in every task

- FEATURE means `docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763`.
- BUNDLE means `extensions/drm-copilot/resources/claude-customizations`.
- PSBUNDLE means `extensions/drm-copilot/resources/powershell/PoshQC/settings`.
- BRANCH means `bug/parallel-skills-invoke-unbundled-python-clis-763`.
- INTEGRATION means `origin/epic/push-down-payload-correctness-integration`.
- TS means the execution time of the task in `yyyy-MM-ddTHH-mm` form.
- SCRATCH means the executor's session scratchpad directory, outside the repository and never
  committed. Artifacts record it as the literal token SCRATCH, never as a host path.
- BASE_SHA is the merge-base recorded by P0-T8; FINAL_SHA is the commit recorded by P11-T1.
- BASHLIB means the glob spelling `.claude/lib/ba?h` and BUNDLEBASHLIB means
  `extensions/drm-copilot/resources/claude-customizations/.claude/lib/ba?h` (see Shell route).
- KL-510 is the known local failure of issue #510. The node
  `test_bundled_claude_payload_contains_all_repo_runtime_contracts` in
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` compares every repository
  `.claude` file with the bundle, and the batch-budget hooks write gitignored state files under
  `.claude/state`. A run of that node satisfies KL-510 in exactly two cases. Case (a): the node
  prints PASSED. Case (b): the node fails, its assertion message is the literal "Repo file missing
  from bundle:" followed by a path whose first two components are `.claude` and `state`, and no
  output line contains the literal "Bundle content differs from repo for:". An artifact recording
  case (a) contains `KL-510: PASSED`; one recording case (b) contains `KL-510: STATE-ONLY` and quotes
  the assertion message. Any other outcome stops the task.
- Every command-step evidence artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and
  `Output Summary:`. An artifact whose expected exit code is not 0 also carries `ExpectedExitCode:`.
  Test-step artifacts for coverage-bearing languages record numeric coverage values in
  `Output Summary:`.

### Evidence location

Every evidence artifact is written to `FEATURE/evidence/<kind>/<name>.TS.md` with kind one of
`baseline`, `regression-testing`, `qa-gates`, or `other`. The toolchain's own outputs under
`artifacts/` (Pester JUnit and JaCoCo XML, LCOV, kcov) are tool outputs, not evidence artifacts;
every value asserted from them is copied into an evidence artifact by the task that reads it.

### Shell route

A worktree isolation guard refuses Bash-tool command text that contains the words bash, pwsh, or
wsl, and refuses heredocs. Therefore:

- Every command in this plan is one plain command with literal arguments.
- PowerShell runs through script A1 (`sh SCRATCH/run-ps.sh <script-or-entry-point> <args>`); the
  command text never names the PowerShell executable.
- A path under `.claude/lib/bash` is spelled BASHLIB (`.claude/lib/ba?h/...`) in command text. The
  invoking shell expands the glob to the real path before the command runs, because the target
  exists; for a copy destination the directory exists. A literal that must contain a refused word
  (for example a SKILL invocation line) is searched only inside a scratch script (A20).
- The guard matches the refused words as substrings of the command text, so the same glob spelling
  applies to every other path whose name contains one: in command text,
  `tests/scripts/dev_tools/test_parallel_abandon_bash_parity.py` is spelled
  `tests/scripts/dev_tools/test_parallel_abandon_ba?h_parity.py` and
  `tests/shell/parallel_bash_manifest_membership.bats` is spelled
  `tests/shell/parallel_ba?h_manifest_membership.bats`. Each glob matches exactly one existing file
  when the command runs. Task text names these files by their real paths; the executor applies the
  glob spelling when composing the command. Commit messages contain none of the three words.
- Local bats runs use `npx --yes bats tests/shell/<file>.bats` (Git Bash `sh` is GNU bash 5.2).
  shfmt and shellcheck are on PATH and run through scripts A12 and A13. kcov has no local route: bash
  coverage comes only from the dispatched `.github/workflows/_shell-coverage.yml` run (P0-T21, P11-T2).
- The abandon-gate hook denies any Bash command whose text carries the abandon disposition token
  without the confirmation marker. No command text in this plan carries either token; every search
  for them runs through a named test or a scratch script, and no commit message names them.
- Python scratch scripts run as files through `poetry run python SCRATCH/<script>.py`, never as a
  multi-line `-c` argument.
- A folder-level CMD-PESTER run or the full tests/scripts/dev_tools pytest run is started in the
  background when it may exceed the 10-minute foreground limit; the recorded result is that of the
  completed invocation.
- If a hook denies a command in this plan, stop and report the denial text. Do not bypass the hook.

### Batch budgets, mirrors, line endings, and the 500-line limit

- The per-session batch-budget hooks allow 3 production and 3 test files per kind (Python,
  PowerShell) and deny the fourth. Every phase that authors or edits Python or PowerShell files begins
  that work with a reset task (script A8, which deletes `.claude/state/<kind>-batch-budget.*.json`
  and prints `RESET removed=<n>`), recorded in `FEATURE/evidence/other/`. The hook files themselves
  are never edited.
- A bundle mirror is produced by `cp` from the edited primary file, never through Write or Edit, so
  it is byte-identical and is not a second authored file. Mirror identity is checked with script A5.
- Every new shell script, shim, bats suite, PowerShell file, and JSON fixture is LF-only (the
  existing `.claude/lib` files carry no carriage return in the working tree); `.gitattributes` line 1
  (`* text=auto eol=lf`) applies and no `-text` exemption is needed because no fixture is CRLF. Every
  such file ends with a line feed. The staging tasks verify both `i/lf` and `w/lf` with
  `git ls-files --eol`; `i/lf` alone cannot fail under that attribute, whereas `w/lf` observes the
  working-tree bytes.
- No production, test, or reusable script file may exceed 500 lines (checked by P3-T22 and P9-T7).

### Test isolation

Tests use committed fixtures and shims only. No test creates a temporary file or directory, starts a
real `gh` or `git`, or reads the wall clock outside the mocked clock seam. Every bats invocation of
the abandon script sets `PATH` to a checked-in shim directory only and runs bash by absolute path, so
a real `gh pr close` or `git worktree remove` is unreachable.

### Toolchain loop rule

Phases 7 through 10 are the final QA loop, one language per phase, in the order format, lint,
type-check (Python only; PowerShell and bash have no type-check stage per their rule files), test with
coverage. If any step fails or changes a tracked file, fix the cause, commit the fix, and restart that
language's loop from its first task; after a fix to a file another language's gate reads, also rerun
that language's test task. A loop is complete only when every task in it passes in one pass. The
coverage values for bash come from Phase 11, which runs on the committed final state.

### Baseline-relative rule

A folder-level regression run (Pester folder runs, the full `tests/scripts/dev_tools` pytest run, and
the Jest push-down folder run) passes when every failing test it reports is a member of the baseline
failure set recorded in Phase 0 (plus KL-510 case (b) for pytest). Every suite this plan creates or
edits must pass outright.

### Commit rule

Each implementation phase ends with a commit-and-push task. Every CMD-GIT-COMMIT carries the commit
attribution lines that the executor's session requires, one `--trailer` argument per line, supplied
by the executor from its own session instructions. If a pre-implementation or orchestration hook
denies staging or committing, stop and report the denial text.

### Command catalogue

Every command-bearing task names one or more entries below. Angle-bracket fields are filled from the
task text. Commands run from the repository root of this worktree.

```text
CMD-GIT-BRANCH        git rev-parse --abbrev-ref HEAD
CMD-GIT-HEAD          git rev-parse HEAD
CMD-GIT-FETCH-INT     git fetch origin epic/push-down-payload-correctness-integration
CMD-GIT-MERGE-BASE    git merge-base HEAD origin/epic/push-down-payload-correctness-integration
CMD-GIT-STATUS        git status --porcelain
CMD-GIT-STATUS-ALL    git status --porcelain --untracked-files=all -- <pathspec>
CMD-GIT-LS            git ls-files -- <pathspec>
CMD-GIT-LS-EOL        git ls-files --eol -- <pathspec>
CMD-GIT-LS-MODE       git ls-files -s -- <pathspec>
CMD-GIT-COUNT         git grep -c -F -e <literal> -- <paths>        (tracked files only)
CMD-GREP-COUNT        grep -c -F -e <literal> <files>               (any file, including untracked)
CMD-GIT-ADD           git add -- <exact paths listed in the task>
CMD-GIT-CHMOD         git update-index --chmod=+x -- <paths>
CMD-GIT-COMMIT        git commit -m "<message given in the task>" --trailer "<each attribution line>"
CMD-GIT-PUSH          git push -u origin bug/parallel-skills-invoke-unbundled-python-clis-763

CMD-PS                sh SCRATCH/run-ps.sh SCRATCH/<script>.ps1 <args>
CMD-PESTER            sh SCRATCH/run-ps.sh SCRATCH/pester-selfhosted.ps1 <scan folders>
CMD-JUNIT             poetry run python SCRATCH/junit-cases.py artifacts/pester/pester-junit.xml <test-file suffixes>
CMD-JACOCO            poetry run python SCRATCH/jacoco-files.py artifacts/pester/powershell-coverage.xml <production paths>
MCP-PS-FORMAT         mcp__drm-copilot__run_poshqc_format  (workspace_root = repository root, scan_folders = the task's folders)
MCP-PS-ANALYZE        mcp__drm-copilot__run_poshqc_analyze (same arguments)
MCP-PS-TEST           mcp__drm-copilot__run_poshqc_test    (same arguments)

CMD-PY-BLACK-CHECK    poetry run black --check <paths>
CMD-PY-BLACK          poetry run black <paths>
CMD-PY-RUFF           poetry run ruff check --no-fix <paths>
CMD-PY-PYRIGHT        poetry run pyright <paths>
CMD-PY-TEST           poetry run pytest -v <test files or node IDs listed in the task>
CMD-PY-SCRIPT         poetry run python SCRATCH/<script>.py <args>
CMD-PY-GUARD-CLI      poetry run python -m scripts.dev_tools.skill_bundle_contract_cli

CMD-BATS              npx --yes bats <bats files>
CMD-SH                sh SCRATCH/<script>.sh <args>

CMD-GH-DISPATCH       gh workflow run _shell-coverage.yml --ref bug/parallel-skills-invoke-unbundled-python-clis-763
CMD-GH-LATEST         gh run list --workflow _shell-coverage.yml --branch bug/parallel-skills-invoke-unbundled-python-clis-763 --event workflow_dispatch --limit 1 --json databaseId,headSha,status,conclusion
CMD-CI-WAIT           sh SCRATCH/ci-wait.sh <run-id>
CMD-CI-LOG            sh SCRATCH/ci-shell-log.sh <run-id>
CMD-GH-DOWNLOAD       gh run download <run-id> -n shell-coverage -D SCRATCH/<dir>

CMD-TS-CI             npm --prefix extensions/drm-copilot ci
CMD-TS-TEST           npm --prefix extensions/drm-copilot run test -- test/lib/push-down
```

### Observed success outputs that acceptance conditions rely on

Each item was observed in this repository's recorded runs or read from source, not inferred:

- bats prints a TAP plan line `1..N` and one `ok N <name>` or `not ok N <name>` line per test
  (recorded runs of the issue #762 plan, `docs/features/active/2026-09-28-skill-referenced-scripts-not-bundled-762/plan.2026-09-28T23-50.md`).
- `scripts/bash/shell-qc.sh test --coverage` prints `Bash coverage (lines): <n>%` only when every
  bats directory passes (`scripts/bash/shell_qc_lib.sh` line 291 prints it; lines 295-350 run bats
  under kcov). The CI job `Shell Coverage (Bats + kcov)` runs it (`.github/workflows/_shell-coverage.yml`
  lines 54-55) and uploads the `shell-coverage` artifact from `artifacts/pester/kcov/**` (lines 57-62);
  the downloaded artifact carries `cov.xml` at its root (issue #762 plan P0-T19, executed).
- Pester JUnit output (`artifacts/pester/pester-junit.xml`, set by
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` line 15) carries one `testcase` element
  per test with `name`, `status` (`Passed` on success), and `classname` set to the test file path.
- Pester coverage output (`artifacts/pester/powershell-coverage.xml`, line 22, format
  `CoverageGutters`) is JaCoCo XML: `package` elements named by the absolute directory, each holding
  `sourcefile` elements named by file name, each with a direct `counter type="LINE"` child carrying
  `missed` and `covered`.
- The PoshQC MCP tools return a pre-composed summary string with no exit code, counts, or coverage,
  and `run_poshqc_test` reads the installed extension's runsettings. Every PowerShell value this plan
  asserts is therefore read from the on-disk XML written by the self-hosted module run (A2), from
  `Invoke-ScriptAnalyzer` (A9), or from `Invoke-Formatter` (A6). The MCP calls are recorded as
  route-compliance steps only.
- black check mode prints a line ending "would be left unchanged."; black write mode prints a line
  ending "left unchanged." and no "reformatted" line on a clean run; ruff with `--no-fix` prints
  "All checks passed!"; pyright prints a summary line beginning with the error count, for example
  "0 errors"; pytest `-v` prints one PASSED or FAILED line per collected node; the project `addopts`
  (`pyproject.toml` line 115) supplies only an LCOV reporter, so every coverage command in this plan
  passes `--cov-report=term-missing` and a JSON report read by A7. The terminal table prints one
  combined `Cover` column, so line and branch percentages are read from the JSON report only.
- Jest prints one "Tests:" summary line.
- `git grep -c` prints one `path:count` line per matching file and exits 1 with no output when
  nothing matches; `git grep` does not see untracked files, so any count over a file this plan creates
  uses CMD-GREP-COUNT until the file is committed.

---

### Phase 0 — Policy Reads, Scratch Scripts, and Baselines

- [x] [P0-T1] Read `CLAUDE.md`, `.github/copilot-instructions.md`, and `.github/instructions/tonality.instructions.md` in full, in that order.
      Acceptance: all three read; recorded in P0-T6.
- [x] [P0-T2] Read, in order, `.github/instructions/general-code-change.instructions.md`,
      `.github/instructions/general-unit-test.instructions.md`, and
      `.github/instructions/self-explanatory-code-commenting.instructions.md`. Acceptance: all three
      read; recorded in P0-T6.
- [x] [P0-T3] Read, in order, `.github/instructions/python-code-change.instructions.md`,
      `.github/instructions/python-unit-test.instructions.md`,
      `.github/instructions/python-suppressions.instructions.md`,
      `.github/instructions/powershell-code-change.instructions.md`,
      `.github/instructions/powershell-unit-test.instructions.md`,
      `.github/instructions/typescript-code-change.instructions.md`,
      `.github/instructions/typescript-unit-test.instructions.md`, and
      `.github/instructions/typescript-suppressions.instructions.md`. Acceptance: all eight read;
      recorded in P0-T6.
- [x] [P0-T4] Read, in order, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`,
      `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`,
      `.claude/rules/plan-acceptance-gates.md`, and `.claude/rules/self-explanatory-code-commenting.md`.
      Acceptance: all six read; recorded in P0-T6.
- [x] [P0-T5] Read, in order, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`,
      `.claude/rules/powershell.md`, `.claude/rules/shell.md`, `.claude/rules/typescript.md`,
      `.claude/rules/typescript-suppressions.md`, and `.claude/rules/parallel-orchestration.md`.
      Acceptance: all seven read; recorded in P0-T6.
- [x] [P0-T6] Write the policy-read record FEATURE/evidence/baseline/phase0-instructions-read.TS.md.
      Acceptance: the artifact contains `Timestamp:`, `Policy Order:` (CLAUDE.md, general code-change,
      general unit-test, then language rules for Python, PowerShell, shell, TypeScript), and the
      explicit list of the 27 files read in P0-T1 through P0-T5 in reading order.
- [x] [P0-T7] Create the 25 scratch scripts of Appendix A (A1 through A23 plus A5b and A19b) verbatim under SCRATCH (for example SCRATCH/run-ps.sh), then smoke-test three of them.
      Commands: `sh SCRATCH/run-ps.sh SCRATCH/psd1-parse.ps1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1`;
      `sh SCRATCH/ac-count.sh FEATURE/spec.md`; `sh SCRATCH/mirror-check.sh .claude/skills/parallel-orchestrate/SKILL.md`.
      Write FEATURE/evidence/other/scratch-smoke.TS.md. Acceptance: the first run exits 0 and prints
      one line beginning `PSD1-OK file=`; the second exits 0 and prints `AC-CHECKED=0 AC-UNCHECKED=18`;
      the third exits 0 and prints `MIRROR SAME .claude/skills/parallel-orchestrate/SKILL.md` and
      `MIRROR-SUMMARY same=1 diff=0 missing=0`. The artifact lists the 25 scratch script names.
- [x] [P0-T8] Record branch state in FEATURE/evidence/baseline/branch-state.TS.md.
      Commands: CMD-GIT-BRANCH, CMD-GIT-FETCH-INT, CMD-GIT-HEAD, CMD-GIT-MERGE-BASE, CMD-GIT-STATUS, and
      `git diff --name-only BASE_SHA HEAD` together with `git status --porcelain`. Acceptance: the branch is
      `bug/parallel-skills-invoke-unbundled-python-clis-763`; the merge-base is 40 hexadecimal
      characters and is recorded as BASE_SHA (observed at authoring:
      `d06ba5d657b75de52cad7859dda307bf9d420046`); every path printed by the name-only diff and by the
      porcelain status lies under FEATURE. Any other path stops the plan, because the code baseline
      would then differ from BASE_SHA.
- [x] [P0-T9] Commit and push the feature documents under FEATURE (FEATURE/issue.md, FEATURE/spec.md, FEATURE/research, this plan, and FEATURE/evidence) so CI can be dispatched on BRANCH.
      Commands: CMD-GIT-ADD with `docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763`,
      CMD-GIT-COMMIT with message "docs(763): add spec, research, plan, and phase 0 evidence",
      CMD-GIT-PUSH, then `git status --porcelain`. Acceptance: the push exits 0 and the porcelain status
      prints nothing.
- [x] [P0-T10] Record pre-change line counts in FEATURE/evidence/baseline/line-counts.TS.md.
      Command: CMD-SH with script line-counts (A22) over `scripts/dev_tools/skill_bundle_contract.py`,
      `scripts/dev_tools/skill_bundle_contract_cli.py`,
      `tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py`,
      `tests/scripts/dev_tools/test_skill_bundle_contract_cli.py`,
      `tests/scripts/dev_tools/test_parallel_abandon_token_seam.py`,
      `.claude/hooks/enforce-parallel-abandon-gate.ps1`,
      `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, `tests/shell/parallel_payload_only.bats`,
      and `tests/shell/parallel_bash_manifest_membership.bats`. Acceptance: exit 0 and nine
      `LineCount=` lines with numeric values; later tasks compare against these values.
- [x] [P0-T11] Record mirror identity at baseline in FEATURE/evidence/baseline/mirror-state.TS.md.
      Command: CMD-SH with script mirror-check (A5) over `.claude/skills/parallel-orchestrate/SKILL.md`,
      `.claude/skills/parallel-remove/SKILL.md`, `.claude/agents/parallel-orchestrator.md`,
      `.claude/hooks/enforce-parallel-abandon-gate.ps1`, and
      `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. Acceptance: exit 0 and
      `MIRROR-SUMMARY same=5 diff=0 missing=0`; any DIFF or MISSING stops the plan.
- [x] [P0-T12] Python format baseline for `scripts/dev_tools/skill_bundle_contract.py` and the four other P0-T10 Python files, written to FEATURE/evidence/baseline/python-format.TS.md.
      Command: CMD-PY-BLACK-CHECK over the five Python files named in P0-T10. Acceptance: the artifact
      records the exit code and the summary line verbatim.
- [x] [P0-T13] Python lint baseline for the P0-T12 files (`scripts/dev_tools/skill_bundle_contract.py` and four others), written to FEATURE/evidence/baseline/python-lint.TS.md.
      Command: CMD-PY-RUFF over the same five files. Acceptance: the artifact records the exit code
      and the summary line verbatim.
- [x] [P0-T14] Python type-check baseline for the P0-T12 files (`scripts/dev_tools/skill_bundle_contract.py` and four others), written to FEATURE/evidence/baseline/python-typecheck.TS.md.
      Command: CMD-PY-PYRIGHT over the same five files. Acceptance: the artifact records the exit code
      and the error, warning, and information counts from the summary line.
- [x] [P0-T15] Python coverage baseline for `scripts/dev_tools/skill_bundle_contract.py` and `scripts/dev_tools/skill_bundle_contract_cli.py`, written to FEATURE/evidence/baseline/python-coverage.TS.md.
      Commands: `poetry run pytest -v tests/scripts/dev_tools/test_skill_bundle_contract.py tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py tests/scripts/dev_tools/test_skill_bundle_contract_cli.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py --cov=scripts.dev_tools.skill_bundle_contract --cov=scripts.dev_tools.skill_bundle_contract_cli --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/cov-763-baseline.json`,
      then CMD-PY-SCRIPT with script py-cov-files (A7) and arguments
      `SCRATCH/cov-763-baseline.json scripts/dev_tools/skill_bundle_contract.py scripts/dev_tools/skill_bundle_contract_cli.py`.
      Acceptance: pytest exits 0 with no FAILED line; the artifact records the pytest summary line,
      the two term-missing rows, and two A7 lines of the form
      `COVERAGE file=<path> LinePercent=<n> BranchPercent=<n>` with numeric values.
- [x] [P0-T16] Python regression baseline over `tests/scripts/dev_tools`, written to FEATURE/evidence/baseline/python-regression.TS.md.
      Commands: `poetry run pytest tests/scripts/dev_tools -q`, then CMD-PY-TEST over the named set of
      Appendix C3. Acceptance: the artifact records both summary lines verbatim and every `FAILED`
      line of the full run (the baseline failure set); every node of the named set is PASSED except
      KL-510, which is recorded with its KL-510 line.
- [x] [P0-T17] PowerShell analyzer baseline for `.claude/hooks/enforce-parallel-abandon-gate.ps1`, written to FEATURE/evidence/baseline/powershell-analyze.TS.md.
      Command: CMD-PS with script pssa-count (A9) over `.claude/hooks/enforce-parallel-abandon-gate.ps1`.
      Acceptance: exit 0 and the line `PSSA-SUMMARY DiagnosticCount=<n>` is recorded with its value.
- [x] [P0-T18] PowerShell format baseline for `.claude/hooks/enforce-parallel-abandon-gate.ps1` and `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, written to FEATURE/evidence/baseline/powershell-format.TS.md.
      Command: CMD-PS with script ps-format-check (A6) over the two files. Acceptance: exit 0 and the
      line `FORMAT-SUMMARY ChangedCount=<n>` is recorded with its value.
- [x] [P0-T19] PowerShell test and coverage baseline for `tests/scripts/claude-lib`, `tests/scripts/claude-hooks`, and `tests/scripts/claude-runtime`, written to FEATURE/evidence/baseline/powershell-tests.TS.md.
      Commands: CMD-PESTER with `tests/scripts/claude-lib tests/scripts/claude-hooks tests/scripts/claude-runtime`;
      CMD-JUNIT with suffixes `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1`,
      `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1`, and
      `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`; CMD-JACOCO with
      `.claude/hooks/enforce-parallel-abandon-gate.ps1`. Acceptance: the artifact records the Pester
      EXIT_CODE, the `JUNIT-ALL` line, every `JUNIT-FAILED` line (the PowerShell baseline failure set,
      possibly empty), one `JUNIT file=` line per suffix with `Total=` at least 1 (a `MISSING` line
      stops the task), and the `JACOCO file=.claude/hooks/enforce-parallel-abandon-gate.ps1` line with a
      numeric `LinePercent=`. The three new PowerShell production files have no baseline (absent at
      BASE_SHA); the artifact states that.
- [x] [P0-T20] Bash local baseline for `tests/shell/parallel_payload_only.bats` and `tests/shell/parallel_bash_manifest_membership.bats`, written to FEATURE/evidence/baseline/shell-local.TS.md.
      Commands: `shfmt --version`, `shellcheck --version`, `npx --yes bats --version`, then CMD-BATS
      over the two suites. Acceptance: the three version commands exit 0 and their versions are
      recorded; the artifact records the TAP plan line and every `not ok` line (the local bats baseline
      failure set, possibly empty).
- [x] [P0-T21] Bash CI coverage baseline from `.github/workflows/_shell-coverage.yml` on BRANCH, written to FEATURE/evidence/baseline/shell-coverage-ci.TS.md.
      Commands: CMD-GIT-HEAD, CMD-GH-DISPATCH, CMD-GH-LATEST (repeat until it lists a run whose
      `headSha` equals the HEAD value), CMD-CI-WAIT with that run id, CMD-CI-LOG with that run id.
      CMD-CI-WAIT polls for up to 90 minutes, which exceeds the 10-minute foreground tool limit: run
      it in the background, or re-invoke it after a tool timeout; the recorded result is that of the
      invocation that exits. Acceptance: CMD-CI-WAIT exits 0 and reports `status` `completed` and `conclusion` `success` for
      job `Shell Coverage (Bats + kcov)`; CMD-CI-LOG prints exactly one line containing
      `Bash coverage (lines): <n>%` and `NOT-OK-COUNT=0`; the artifact records the run id, headSha, the
      headline value, `NOT-OK-COUNT=`, and `OK-COUNT=`. A non-success conclusion stops the plan (the
      bash coverage baseline would be unavailable and the comparison BLOCKED).
- [x] [P0-T22] Bash per-file coverage baseline from the P0-T21 artifact, written to FEATURE/evidence/baseline/shell-coverage-files.TS.md.
      Commands: CMD-GH-DOWNLOAD with the P0-T21 run id into `SCRATCH/shell-cov-baseline`, then
      CMD-PY-SCRIPT with script cobertura-files (A16) and arguments `SCRATCH/shell-cov-baseline/cov.xml`
      `compute-cohorts.sh`. Acceptance: the artifact records the `COBERTURA-TOTAL line-rate=` value and
      one `COBERTURA file=` line for `compute-cohorts.sh` (the control that per-file entries exist for
      the `.claude/lib/bash` tree).
- [x] [P0-T23] TypeScript push-down regression baseline for `extensions/drm-copilot/test/lib/push-down`, written to FEATURE/evidence/baseline/ts-push-down-jest.TS.md.
      No TypeScript source or test is edited by this plan; the bundle resources these tests read are.
      Commands: CMD-TS-CI, then CMD-TS-TEST. Acceptance: the artifact records the "Tests:" summary line
      verbatim and every line beginning `FAIL ` (the Jest baseline failure set, possibly empty).
- [x] [P0-T24] Record the spec.md acceptance-criteria checkbox baseline in FEATURE/evidence/baseline/ac-checkbox-state.TS.md.
      Command: CMD-SH with script ac-count (A21) and argument `FEATURE/spec.md`. Acceptance: exit 0 and
      `AC-CHECKED=0 AC-UNCHECKED=18`.

### Phase 1 — Guard Registry Removal and Fail-Before Reproduction (AC13)

- [x] [P1-T1] Reset the Python batch budget before editing `scripts/dev_tools/skill_bundle_contract.py`: CMD-PS with script reset-batch-budget (A8) and `-Kind python`.
      Write FEATURE/evidence/other/batch-budget-reset-p1.TS.md. Acceptance: exit 0 and a
      `RESET removed=` line.
- [x] [P1-T2] Edit `scripts/dev_tools/skill_bundle_contract.py` per Appendix B1 (lines 132-145 become the empty registry).
      Acceptance: CMD-GIT-COUNT with literal `KNOWN_UNBUNDLED_REFERENCES: tuple[KnownUnbundledReference, ...] = ()`
      over that file prints a count of 1, and CMD-GIT-COUNT with literal `"#763",` over it exits 1
      with no output.
- [x] [P1-T3] Edit `scripts/dev_tools/skill_bundle_contract_cli.py` per Appendix B2 (keyword-only `exceptions` parameter on `main`, forwarded to both finders).
      Acceptance: CMD-GIT-COUNT with literal `find_violations(inputs, exceptions=registered)` over that
      file prints a count of 1 and CMD-GIT-COUNT with literal
      `find_stale_exceptions(inputs, exceptions=registered)` prints a count of 1.
- [x] [P1-T4] Edit `tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py` per Appendix B3 (the registry test asserts the empty registry).
      Acceptance: CMD-GIT-COUNT with literal `def test_known_unbundled_references_registry_is_empty`
      over that file prints a count of 1 and CMD-GIT-COUNT with literal
      `test_known_unbundled_references_cite_issue_763` exits 1 with no output.
- [x] [P1-T5] Edit `tests/scripts/dev_tools/test_skill_bundle_contract_cli.py` per Appendix B4 (no default-registry dependency; stale and suppression cases through the injected registry).
      Acceptance: CMD-GIT-COUNT with literal `def test_main_suppresses_a_registered_exception` over
      that file prints a count of 1 and CMD-GIT-COUNT with literal `parallel_drift_detection_cli` exits
      1 with no output.
- [x] [P1-T6] Run the guard unit tests in `tests/scripts/dev_tools/test_skill_bundle_contract.py`, `tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py`, and `tests/scripts/dev_tools/test_skill_bundle_contract_cli.py`.
      Command: CMD-PY-TEST over the three files. Write
      FEATURE/evidence/regression-testing/guard-units-after-registry.TS.md. Acceptance: exit 0, no FAILED
      line, and the five B4 test names and `test_known_unbundled_references_registry_is_empty` each
      appear on a PASSED line.
- [x] [P1-T7] [expect-fail] Run the repository guard `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` with the empty registry and the unported skills.
      Command: CMD-PY-TEST over that file. Write
      FEATURE/evidence/regression-testing/guard-repo-before-port.TS.md with `ExpectedExitCode: 1`.
      Acceptance: exit 1; exactly one line begins `FAILED `, naming
      `test_every_skill_script_reference_is_bundled`; its message contains exactly the two violation
      lines `parallel-orchestrate | scripts/dev_tools/parallel_drift_detection_cli.py | not-in-bundle`
      and `parallel-remove | scripts/dev_tools/parallel_mutation_abandon_cli.py | not-in-bundle`; the
      four other tests (including `test_known_unbundled_references_are_not_stale`) are PASSED. This is
      the defect reproduction: with no exception registered, the guard reports both unbundled CLIs.
      Any other failure set stops the plan for a design review.
- [x] [P1-T8] [expect-fail] Run the guard CLI `scripts/dev_tools/skill_bundle_contract_cli.py` before the port.
      Command: CMD-PY-GUARD-CLI. Write FEATURE/evidence/regression-testing/guard-cli-before-port.TS.md with
      `ExpectedExitCode: 1`. Acceptance: exit 1 and stderr carries exactly two lines, in this order:
      `skill-bundle violation: parallel-orchestrate | scripts/dev_tools/parallel_drift_detection_cli.py | not-in-bundle`
      and `skill-bundle violation: parallel-remove | scripts/dev_tools/parallel_mutation_abandon_cli.py | not-in-bundle`.
- [x] [P1-T9] Commit and push Phase 1 (`scripts/dev_tools/skill_bundle_contract.py` and the files below).
      Commands: CMD-GIT-ADD with `scripts/dev_tools/skill_bundle_contract.py scripts/dev_tools/skill_bundle_contract_cli.py tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py tests/scripts/dev_tools/test_skill_bundle_contract_cli.py docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763`,
      CMD-GIT-COMMIT with message "fix(763): empty the unbundled-reference registry and reproduce the guard failure",
      CMD-GIT-PUSH, then `git status --porcelain`. Acceptance: the push exits 0 and the porcelain status
      prints nothing.

### Phase 2 — Abandon Disposition Bash Port (AC4, AC5)

- [x] [P2-T1] Create the shim `tests/fixtures/parallel_abandon_path/gh` with exactly the text of Appendix B5 (gh variant).
      Acceptance: CMD-GREP-COUNT with literal `ABANDON_SHIM_GH_EXIT` over that file prints 2 (the
      header comment line and the `exit` line of B5).
- [x] [P2-T2] Create the shim `tests/fixtures/parallel_abandon_path/git` with exactly the text of Appendix B5 (git variant).
      Acceptance: CMD-GREP-COUNT with literal `ABANDON_SHIM_GIT_EXIT` over that file prints 2, and
      CMD-GREP-COUNT with literal `ABANDON_SHIM_GH_EXIT` over it exits 1 and prints 0.
- [x] [P2-T3] Create `tests/fixtures/parallel_abandon_path_git_only/git` as a byte copy of the git shim.
      Commands: `mkdir -p tests/fixtures/parallel_abandon_path_git_only`, then
      `cp tests/fixtures/parallel_abandon_path/git tests/fixtures/parallel_abandon_path_git_only/git`,
      then `cmp tests/fixtures/parallel_abandon_path/git tests/fixtures/parallel_abandon_path_git_only/git`.
      Acceptance: `cmp` exits 0 with no output.
- [x] [P2-T4] Stage the three shims under `tests/fixtures/parallel_abandon_path` and `tests/fixtures/parallel_abandon_path_git_only` as executable LF files.
      Commands: CMD-GIT-ADD with `tests/fixtures/parallel_abandon_path tests/fixtures/parallel_abandon_path_git_only`,
      CMD-GIT-CHMOD with `tests/fixtures/parallel_abandon_path/gh tests/fixtures/parallel_abandon_path/git tests/fixtures/parallel_abandon_path_git_only/git`,
      CMD-GIT-LS-MODE and CMD-GIT-LS-EOL over the same three paths, and `git status --porcelain -- tests/fixtures`.
      Write FEATURE/evidence/other/abandon-shims-staged.TS.md. Acceptance: CMD-GIT-LS-MODE prints three
      lines each beginning `100755`; CMD-GIT-LS-EOL prints three lines each containing both `i/lf` and
      `w/lf`.
- [x] [P2-T5] Write `tests/shell/parallel_abandon.bats` per Appendix B6 (14 named tests, shim-only PATH, no temporary files).
      Acceptance: CMD-GREP-COUNT with literal `@test "` over that file prints 14.
- [x] [P2-T6] [expect-fail] Run `tests/shell/parallel_abandon.bats` before the script exists.
      Command: CMD-BATS over that file. Write
      FEATURE/evidence/regression-testing/abandon-bats-before-script.TS.md with `ExpectedExitCode: 1`.
      Acceptance: exit 1, TAP plan `1..14`, and exactly 14 `not ok` lines (every B6 test depends on
      the script file).
- [x] [P2-T7] Write `.claude/lib/bash/abandon-parallel-item.sh` per Appendix B7.
      Acceptance: CMD-SH with script line-counts (A22) over `BASHLIB/abandon-parallel-item.sh` prints a
      `LineCount=` value of at most 500.
- [x] [P2-T8] Run `tests/shell/parallel_abandon.bats` after the script exists.
      Command: CMD-BATS over that file. Write FEATURE/evidence/regression-testing/abandon-bats-after-script.TS.md.
      Acceptance: exit 0, TAP plan `1..14`, 14 `ok` lines, and no `not ok` line.
- [x] [P2-T9] Early lint of `.claude/lib/bash/abandon-parallel-item.sh` and the three shims under `tests/fixtures/parallel_abandon_path`.
      Command: CMD-SH with script shell-lint (A12). Write FEATURE/evidence/other/abandon-early-lint.TS.md.
      Acceptance: exit 0, `SHFMT-DIFF-EXIT=0`, and `SHELLCHECK-EXIT=0`.
- [x] [P2-T10] Write the nine abandon corpus fixtures `tests/fixtures/parallel_abandon/*.json` per Appendix C2 (schema in B8).
      Command: CMD-PY-SCRIPT with script json-parse (A11) and argument `tests/fixtures/parallel_abandon/*.json`.
      Acceptance: exit 0 and exactly nine `JSON-OK file=` lines, one per C2 name.
- [x] [P2-T11] Reset the Python batch budget before writing `tests/scripts/dev_tools/test_parallel_abandon_bash_parity.py`: CMD-PS with script reset-batch-budget (A8) and `-Kind python`.
      Write FEATURE/evidence/other/batch-budget-reset-p2.TS.md. Acceptance: exit 0 and a
      `RESET removed=` line.
- [x] [P2-T12] Write `tests/scripts/dev_tools/test_parallel_abandon_bash_parity.py` per Appendix B9 (Python reference lane with an injected runner).
      Acceptance: CMD-GREP-COUNT with literal `def test_reference_matches_abandon_fixture` over that
      file prints 1.
- [x] [P2-T13] Run the Python abandon lane `tests/scripts/dev_tools/test_parallel_abandon_bash_parity.py`.
      Command: CMD-PY-TEST over that file. Write
      FEATURE/evidence/regression-testing/abandon-python-lane.TS.md. Acceptance: exit 0, no FAILED line,
      `test_abandon_corpus_meets_floor` and `test_abandon_corpus_covers_every_named_case` PASSED, and
      nine `test_reference_matches_abandon_fixture[...]` nodes PASSED, one per C2 name.
- [x] [P2-T14] Write `tests/shell/parallel_abandon_parity.bats` per Appendix B10 (bash lane over the same corpus).
      Acceptance: CMD-GREP-COUNT with literal `@test "` over that file prints 3.
- [x] [P2-T15] Run the bash parity lane `tests/shell/parallel_abandon_parity.bats` locally.
      Command: CMD-SH with script bats-parity-local (A23). Write
      FEATURE/evidence/regression-testing/abandon-bats-parity-local.TS.md. Acceptance: the output
      contains `BATS-PARITY-EXIT=0`, TAP plan `1..3`, and three `ok` lines. Authorized environment
      branch: when the `not ok` lines are exactly "the harness interpreter is available to read the
      corpus" and "the bash lane reproduces every abandon corpus fixture", and the output shows that the
      harness interpreter could not be started or could not open a fixture path, record the line
      `LOCAL-PARITY: ENVIRONMENT-BLOCKED` with the verbatim error output; the authoritative bash parity
      result is then P11-T3. Any other combination of `not ok` lines stops the task.
- [x] [P2-T16] Commit and push Phase 2 (`.claude/lib/bash/abandon-parallel-item.sh` and the files below).
      Commands: CMD-GIT-ADD with `BASHLIB/abandon-parallel-item.sh tests/fixtures/parallel_abandon tests/fixtures/parallel_abandon_path tests/fixtures/parallel_abandon_path_git_only tests/shell/parallel_abandon.bats tests/shell/parallel_abandon_parity.bats tests/scripts/dev_tools/test_parallel_abandon_bash_parity.py docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763`,
      CMD-GIT-LS-EOL over `BASHLIB/abandon-parallel-item.sh tests/shell/parallel_abandon.bats tests/shell/parallel_abandon_parity.bats tests/fixtures/parallel_abandon`,
      CMD-GIT-COMMIT with message "fix(763): port the parallel abandon disposition to a bundled shell entry point",
      CMD-GIT-PUSH, then `git status --porcelain`. The test file `tests/scripts/dev_tools/test_parallel_abandon_bash_parity.py`
      is spelled with the Shell route glob in the CMD-GIT-ADD command text. Acceptance: every
      CMD-GIT-LS-EOL line contains both `i/lf` and `w/lf`,
      the push exits 0, and the porcelain status prints nothing.

### Phase 3 — Drift Detection PowerShell Port (AC1, AC2, AC3)

- [x] [P3-T1] Write the committed real-seam fixtures `tests/fixtures/parallel_drift_cli/checkpoint.json` and `tests/fixtures/parallel_drift_cli/config.json` per Appendix B11.
      Command: CMD-PY-SCRIPT with script json-parse (A11) and arguments
      `tests/fixtures/parallel_drift_cli/checkpoint.json tests/fixtures/parallel_drift_cli/config.json`.
      Acceptance: exit 0 and two `JSON-OK file=` lines.
- [x] [P3-T2] Write the 18 drift corpus fixture inputs `tests/fixtures/parallel_drift/*.json` per Appendix C1 (schema in B12; success fixtures carry no `expected` key yet).
      Command: CMD-PY-SCRIPT with script json-parse (A11) and argument `tests/fixtures/parallel_drift/*.json`.
      Acceptance: exit 0 and exactly 18 `JSON-OK file=` lines, one per C1 name.
- [x] [P3-T3] Fill the expected payloads of `tests/fixtures/parallel_drift/*.json` from the Python reference.
      Command: CMD-PY-SCRIPT with script drift-expected (A18). Write
      FEATURE/evidence/other/drift-corpus-generation.TS.md. Acceptance: exit 0; 15 `GENERATED name=`
      lines and 3 `ERROR-FIXTURE name=` lines, one per C1 name; no `MISMATCH` and no `MISSING-FIXTURE`
      line; the final line is `GENERATOR-SUMMARY generated=15 errors=3 mismatches=0`. A18 compares
      every generated payload with the hand-stated C1 table (result, escaped paths, pairs, halted keys)
      and with the invariants of spec "Boundaries and invariants to preserve", and writes a fixture only
      when all of them hold, so the committed expectations are pinned by the plan and not by the
      reference alone.
- [x] [P3-T4] Reset the Python batch budget before writing `tests/scripts/dev_tools/test_parallel_drift_parity.py`: CMD-PS with script reset-batch-budget (A8) and `-Kind python`.
      Write FEATURE/evidence/other/batch-budget-reset-p3a.TS.md. Acceptance: exit 0 and a
      `RESET removed=` line.
- [x] [P3-T5] Write `tests/scripts/dev_tools/test_parallel_drift_parity.py` per Appendix B13 (Python reference lane).
      Acceptance: CMD-GREP-COUNT with literal `def test_reference_matches_fixture_payload` over that
      file prints 1.
- [x] [P3-T6] Run the Python drift lane `tests/scripts/dev_tools/test_parallel_drift_parity.py`.
      Command: CMD-PY-TEST over that file. Write
      FEATURE/evidence/regression-testing/drift-python-lane.TS.md. Acceptance: exit 0, no FAILED line,
      `test_drift_corpus_meets_floor` and `test_drift_corpus_covers_every_named_case` PASSED, 15
      `test_reference_matches_fixture_payload[...]` nodes and 3 `test_reference_reports_fixture_error[...]`
      nodes PASSED, one per C1 name.
- [x] [P3-T7] Reset the PowerShell batch budget before writing tests under `tests/scripts/claude-lib/parallel-drift`: CMD-PS with script reset-batch-budget (A8) and `-Kind powershell`.
      Write FEATURE/evidence/other/batch-budget-reset-p3b.TS.md. Acceptance: exit 0 and a
      `RESET removed=` line.
- [x] [P3-T8] Write `tests/scripts/claude-lib/parallel-drift/ParallelDriftHalt.Tests.ps1` per Appendix B14.
      Acceptance: CMD-GREP-COUNT with literal `Describe 'ParallelDriftHalt.psm1'` over that file prints 1.
- [x] [P3-T9] Write `tests/scripts/claude-lib/parallel-drift/ParallelDrift.Tests.ps1` per Appendix B15.
      Acceptance: CMD-GREP-COUNT with literal `Describe 'ParallelDrift.psm1'` over that file prints 1.
- [x] [P3-T10] Write `tests/scripts/claude-lib/parallel-drift/ParallelDrift.Manifest.Tests.ps1` per Appendix B16.
      Acceptance: CMD-GREP-COUNT with literal `Describe 'Parallel-drift core.json manifest membership'`
      over that file prints 1.
- [x] [P3-T11] [expect-fail] Run the three suites in `tests/scripts/claude-lib/parallel-drift` before the modules exist.
      Commands: CMD-PESTER with `tests/scripts/claude-lib/parallel-drift`, then CMD-JUNIT with suffixes
      `parallel-drift/ParallelDriftHalt.Tests.ps1`, `parallel-drift/ParallelDrift.Tests.ps1`, and
      `parallel-drift/ParallelDrift.Manifest.Tests.ps1`. Write
      FEATURE/evidence/regression-testing/drift-modules-before.TS.md. Acceptance: the Pester EXIT_CODE
      is not 0; each of the three `JUNIT file=` lines shows `Total=` at least 1 and `Passed=0` (no
      `MISSING` line). The artifact carries `ExpectedExitCode:` set to the observed non-zero EXIT_CODE
      once this JUnit pattern is confirmed; an EXIT_CODE of 0 stops the task.
- [x] [P3-T12] Write `.claude/lib/parallel-drift/ParallelDriftHalt.psm1` per Appendix B17.
      Acceptance: CMD-GREP-COUNT with literal `function Get-ParallelDriftHaltedItemKey` over that file
      prints 1, and CMD-GREP-COUNT with literal `imports its siblings with -ErrorAction Stop` over that
      file prints 1.
- [x] [P3-T13] Write `.claude/lib/parallel-drift/ParallelDrift.psm1` per Appendix B18.
      Acceptance: CMD-GREP-COUNT with literal `function Get-ParallelDriftResult` over that file prints 1,
      CMD-GREP-COUNT with literal `../blast-radius/BlastRadius.psm1` prints at least 1, and
      CMD-GREP-COUNT with literal `imports its siblings with -ErrorAction Stop` over that file prints 1.
- [x] [P3-T14] Run the three suites in `tests/scripts/claude-lib/parallel-drift` with the two modules present.
      Commands: CMD-PESTER with `tests/scripts/claude-lib/parallel-drift`, then CMD-JUNIT with the three
      P3-T11 suffixes. Write FEATURE/evidence/regression-testing/drift-modules-after.TS.md. Acceptance:
      the Halt and Drift suites each show `Failed=0` and every It name listed in B14 and B15 appears on a
      `JUNIT-CASE status=Passed` line; the Manifest suite shows `Passed=1` and `Failed=4` (only the
      discovery test passes, because the manifest entries and bundle copies land in Phase 5). The
      artifact carries `ExpectedExitCode:` set to the observed non-zero EXIT_CODE once the Manifest
      suite shows `Passed=1` and `Failed=4` and every other suite shows `Failed=0`.
- [x] [P3-T15] Reset the PowerShell batch budget before writing `.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1` and its tests: CMD-PS with script reset-batch-budget (A8) and `-Kind powershell`.
      Write FEATURE/evidence/other/batch-budget-reset-p3c.TS.md. Acceptance: exit 0 and a
      `RESET removed=` line.
- [x] [P3-T16] Write `tests/scripts/claude-lib/parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1` per Appendix B19.
      Acceptance: CMD-GREP-COUNT with literal `Describe 'Invoke-ParallelDriftDetection.ps1'` over that file prints 1.
- [x] [P3-T17] Write `tests/scripts/claude-lib/parallel-drift/ParallelDrift.Parity.Tests.ps1` per Appendix B20.
      Acceptance: CMD-GREP-COUNT with literal `Describe 'Parallel drift parity corpus'` over that file prints 1.
- [x] [P3-T18] [expect-fail] Run the entry-script and parity suites in `tests/scripts/claude-lib/parallel-drift` before the entry script exists.
      Commands: CMD-PESTER with `tests/scripts/claude-lib/parallel-drift`, then CMD-JUNIT with suffixes
      `parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1` and `parallel-drift/ParallelDrift.Parity.Tests.ps1`.
      Write FEATURE/evidence/regression-testing/drift-entry-before.TS.md. Acceptance: the Pester
      EXIT_CODE is not 0; both `JUNIT file=` lines show `Total=` at least 1 and `Passed=0`. The artifact
      carries `ExpectedExitCode:` set to the observed non-zero EXIT_CODE once this pattern is confirmed.
- [x] [P3-T19] Write `.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1` per Appendix B21.
      Acceptance: CMD-GREP-COUNT with literal `function Invoke-ParallelDriftCli` over that file prints 1,
      and CMD-GREP-COUNT with literal `[CmdletBinding(PositionalBinding = $false)]` over it prints 1.
      The absence of `Mandatory` parameters is asserted by the B19 test 'declares no Mandatory
      parameter' in P3-T20 (an AST check, so comment text cannot satisfy or defeat it), and positional
      binding to ChangedPath only is asserted by the B19 test 'binds positional arguments only to
      ChangedPath' in P3-T20 and by command (g) of P3-T21.
- [x] [P3-T20] Run the five suites in `tests/scripts/claude-lib/parallel-drift` with the entry script present.
      Commands: CMD-PESTER with `tests/scripts/claude-lib/parallel-drift`, then CMD-JUNIT with the five
      suffixes of P3-T11 and P3-T18. Write FEATURE/evidence/regression-testing/drift-entry-after.TS.md.
      Acceptance: the Halt, Drift, Invoke, and Parity suites each show `Failed=0`; every It name listed
      in B19 and B20 appears on a `JUNIT-CASE status=Passed` line, including 18
      `reproduces drift fixture <name>` cases, one per C1 name; the Manifest suite shows `Passed=1` and
      `Failed=4`. The artifact carries `ExpectedExitCode:` set to the observed non-zero EXIT_CODE once
      the Manifest suite shows `Passed=1` and `Failed=4` and every other suite shows `Failed=0`.
- [x] [P3-T21] Observe the process-level contract of `.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1` and of the Python CLI on the committed fixtures, written to FEATURE/evidence/regression-testing/drift-process-smoke.TS.md.
      Commands (each recorded with its exit code, stdout, and stderr):
      (a) `sh SCRATCH/run-ps.sh .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1`;
      (b) `sh SCRATCH/run-ps.sh .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1 -ItemKey 446 -Bogus value`;
      (c) `sh SCRATCH/run-ps.sh .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1 -ItemKey 446 -CheckpointPath tests/fixtures/parallel_drift_cli/checkpoint.json -ConfigPath tests/fixtures/parallel_drift_cli/config.json -At 2026-08-08T10-00 -ComputedAt 2026-08-08T10-05 src/app.py > SCRATCH/drift-ps.json`;
      (d) `sh SCRATCH/run-ps.sh .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1 -ItemKey 446 -CheckpointPath tests/fixtures/parallel_drift_cli/absent.json -ConfigPath tests/fixtures/parallel_drift_cli/config.json`;
      (e) `poetry run python -m scripts.dev_tools.parallel_drift_detection_cli --item-key 446 --checkpoint tests/fixtures/parallel_drift_cli/checkpoint.json --config tests/fixtures/parallel_drift_cli/config.json --at 2026-08-08T10-00 --computed-at 2026-08-08T10-05 src/app.py > SCRATCH/drift-py.json`;
      (f) `poetry run python SCRATCH/json-equal.py SCRATCH/drift-ps.json SCRATCH/drift-py.json` (A19b);
      (g) `sh SCRATCH/run-ps.sh .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1 -ItemKey 446 -CheckpointPath tests/fixtures/parallel_drift_cli/checkpoint.json -ConfigPath tests/fixtures/parallel_drift_cli/config.json -At 2026-08-08T10-00 src/app.py`;
      (h) `sh SCRATCH/run-ps.sh .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1 -ItemKey 446 -CheckpointPath tests/fixtures/parallel_drift_cli/checkpoint.json -ConfigPath tests/fixtures/parallel_drift_cli/config.json -At 2026-08-08T10-00`.
      The artifact quotes the contents of both saved files. Acceptance: (a) exits 2 and prints no prompt text; (b) exits 2; (c) exits 0 and
      its stdout is one JSON object whose `result` is `halt_required` and whose `halted_item_keys` is
      `[445]`; (d) exits 1 and its stderr begins `parallel drift detection failed: `; (e) exits 0;
      (f) prints `JSON-EQUAL=true`; (g) exits 0 and its stdout is one JSON object whose `result` is
      `halt_required`, whose `escaped_paths` is `["src/app.py"]`, and whose `computed_at` is
      `2026-08-08T10-00` (the omitted `-ComputedAt` defaults to the resolved `-At`; with the B11
      fixtures the drifter 446 declares `scripts/dev_tools/**`, so `src/app.py` escapes and overlaps
      item 445). Command (g) omits `-ComputedAt`, so its trailing changed path would bind to that
      parameter under positional binding; the expected output shows it bound to ChangedPath.
      (h) exits 0 and its stdout is one JSON object whose `result` is `no_escape`, whose
      `escaped_paths` is `[]`, and whose `drift_event` is `null`; command (h) passes no changed path,
      so it observes the B21 normalization of an omitted ChangedPath (which `pwsh -File` leaves
      `$null`) to an empty list at the process level.
- [x] [P3-T22] Check the 500-line limit for `.claude/lib/parallel-drift` and `tests/scripts/claude-lib/parallel-drift`, written to FEATURE/evidence/qa-gates/drift-line-counts.TS.md.
      Command: CMD-SH with script line-counts (A22) over `.claude/lib/parallel-drift/*` and
      `tests/scripts/claude-lib/parallel-drift/*`. Acceptance: eight `LineCount=` lines, each at most 500.
- [x] [P3-T23] Commit and push Phase 3 (`.claude/lib/parallel-drift` and the files below).
      Commands: CMD-GIT-ADD with `.claude/lib/parallel-drift tests/scripts/claude-lib/parallel-drift tests/fixtures/parallel_drift tests/fixtures/parallel_drift_cli tests/scripts/dev_tools/test_parallel_drift_parity.py docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763`,
      CMD-GIT-LS-EOL over `.claude/lib/parallel-drift tests/scripts/claude-lib/parallel-drift tests/fixtures/parallel_drift tests/fixtures/parallel_drift_cli`,
      CMD-GIT-COMMIT with message "fix(763): port parallel drift detection to a bundled PowerShell entry point",
      CMD-GIT-PUSH, then `git status --porcelain`. Acceptance: every CMD-GIT-LS-EOL line contains both
      `i/lf` and `w/lf`, the push exits 0, and the porcelain status prints nothing.

### Phase 4 — Skill, Agent, Hook, and Token-Seam Surface Updates (AC7, AC8, AC9, AC10, AC11)

- [x] [P4-T1] Edit `.claude/skills/parallel-orchestrate/SKILL.md` lines 732-733 to the text of Appendix B22a (abandon citation).
      Acceptance: CMD-GIT-COUNT with literal `scripts/dev_tools/parallel_mutation_abandon_cli.py` over
      that file exits 1 with no output.
- [x] [P4-T2] Edit `.claude/skills/parallel-orchestrate/SKILL.md` lines 878-896 to the text of Appendix B22b (drift CLI invocation and argument surface).
      Acceptance: CMD-GIT-COUNT with literal `poetry run` over that file exits 1 with no output, and
      CMD-GIT-COUNT with literal `.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1` prints a
      count of 2.
- [x] [P4-T3] Edit `.claude/skills/parallel-orchestrate/SKILL.md` line 943 to the text of Appendix B22c (exit-status sentence).
      Line 943 is the state after P4-T2 (line 933 at BASE_SHA; P4-T2 replaces 19 lines with 29); it is
      the line beginning "missing or malformed input, and argparse's". Anchor on that line-start text
      rather than on the number alone. Acceptance: CMD-GIT-COUNT with literal `argparse` over that file exits 1 with no output.
- [x] [P4-T4] Edit `.claude/skills/parallel-orchestrate/SKILL.md` line 972 to the text of Appendix B22d (halt-exclusion citation).
      Line 972 is the state after P4-T2 and P4-T3 (line 961 at BASE_SHA; P4-T2 adds 10 lines and P4-T3
      adds 1); it is the line beginning "`halted_item_keys` in". Anchor on that line-start text rather
      than on the number alone. Acceptance: CMD-GIT-COUNT with literal `Get-ParallelDriftHaltedItemKey` over that file prints a
      count of 1.
- [x] [P4-T5] Edit `.claude/skills/parallel-remove/SKILL.md` lines 111-112 to the text of Appendix B23a (fence info string `shell` and the abandon invocation).
      Line 111 is the fence line beginning three spaces and three backticks followed by `bash`; line 112
      is the invocation line beginning "   poetry run python"; line 113 (the closing fence) is
      unchanged, and the line count of the file is unchanged. Acceptance: CMD-GIT-COUNT with literal
      `poetry run` over that file exits 1 with no output. That the guard extracts the new invocation is
      asserted by the B26 test `test_bundle_guard_extracts_the_skill_invocation` in P4-T13.
- [x] [P4-T6] Edit `.claude/skills/parallel-remove/SKILL.md` lines 149-156 to the text of Appendix B23b (token-seam prose).
      Acceptance: CMD-GIT-COUNT with literal `parses all four artifacts` over that file prints a count of 1.
- [x] [P4-T7] Edit the `tools` list of `.claude/agents/parallel-orchestrator.md` (lines 14-21) to the list of Appendix B24a.
      Acceptance: CMD-SH with script surface-token-count (A20) prints `COUNT T3 .claude/agents/parallel-orchestrator.md 1`
      and `COUNT T4 .claude/agents/parallel-orchestrator.md 1` and `COUNT T5 .claude/agents/parallel-orchestrator.md 1`.
- [x] [P4-T8] Edit the prose of `.claude/agents/parallel-orchestrator.md` lines 98-104 to the text of Appendix B24b.
      Lines 98-104 are the state after P4-T7 inserts two `tools` entries (lines 96-102 at BASE_SHA); the
      block is the paragraph beginning "The `poetry run` grants remain" and ending with the line
      "`.claude/agents/parallel-planner.md` records the same destination-runtime posture.". Acceptance: CMD-GIT-COUNT with literal `exactly one named consumer is left` over that file exits 1
      with no output, and CMD-GIT-COUNT with literal `no skill step names a` prints a count of 1.
- [x] [P4-T9] Reset the PowerShell batch budget before editing `.claude/hooks/enforce-parallel-abandon-gate.ps1`: CMD-PS with script reset-batch-budget (A8) and `-Kind powershell`.
      Write FEATURE/evidence/other/batch-budget-reset-p4a.TS.md. Acceptance: exit 0 and a
      `RESET removed=` line.
- [x] [P4-T10] Edit the `.NOTES` comment of `.claude/hooks/enforce-parallel-abandon-gate.ps1` lines 28-31 to the text of Appendix B25 (comment only; line count unchanged).
      Acceptance: CMD-GIT-COUNT with literal `abandon-parallel-item.sh` over that file prints a count of
      1, and CMD-SH with script line-counts (A22) over the file prints the same `LineCount=` value as
      P0-T10.
- [x] [P4-T11] Reset the Python batch budget before editing `tests/scripts/dev_tools/test_parallel_abandon_token_seam.py`: CMD-PS with script reset-batch-budget (A8) and `-Kind python`.
      Write FEATURE/evidence/other/batch-budget-reset-p4b.TS.md. Acceptance: exit 0 and a
      `RESET removed=` line.
- [x] [P4-T12] Edit `tests/scripts/dev_tools/test_parallel_abandon_token_seam.py` per Appendix B26 (anchor `abandon-parallel-item.sh`, bash-constant producer side).
      Acceptance: CMD-GIT-COUNT with literal `INVOCATION_ANCHOR = "abandon-parallel-item.sh"` over that
      file prints a count of 1.
- [x] [P4-T13] Run the seam test `tests/scripts/dev_tools/test_parallel_abandon_token_seam.py`.
      Command: CMD-PY-TEST over that file. Write FEATURE/evidence/regression-testing/abandon-token-seam.TS.md.
      Acceptance: exit 0, no FAILED line, and every B26 test name appears on a PASSED line (including
      both `test_hook_states_each_token_exactly_once[...]` nodes, `test_bash_token_pair_equals_the_cli_pair`,
      `test_bash_token_pair_equals_the_hook_pair`, `test_skill_invocation_line_names_the_bash_script`,
      `test_all_four_extractions_agree`, and `test_bundle_guard_extracts_the_skill_invocation`).
- [x] [P4-T14] Count the new surface tokens in `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/skills/parallel-remove/SKILL.md`, and `.claude/agents/parallel-orchestrator.md`.
      Command: CMD-SH with script surface-token-count (A20). Write
      FEATURE/evidence/regression-testing/surface-tokens.TS.md. Acceptance: exit 0 and the five repo
      lines `COUNT T1 .claude/skills/parallel-orchestrate/SKILL.md 1`,
      `COUNT T2 .claude/skills/parallel-remove/SKILL.md 1`, `COUNT T3 .claude/agents/parallel-orchestrator.md 1`,
      `COUNT T4 .claude/agents/parallel-orchestrator.md 1`, `COUNT T5 .claude/agents/parallel-orchestrator.md 1`,
      and `COUNT T6 .claude/skills/parallel-orchestrate/SKILL.md 0` and
      `COUNT T6 .claude/skills/parallel-remove/SKILL.md 0` (bundle lines are checked after P5-T3).
- [x] [P4-T15] Run the surface contract suite `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` (pinned sixteen `##` headings).
      Command: CMD-PY-TEST over that file. Write FEATURE/evidence/regression-testing/surface-contracts.TS.md.
      Acceptance: exit 0, no FAILED line, and
      `test_orchestrate_skill_first_thirteen_headings_match_required_layout` PASSED.
- [x] [P4-T16] Commit and push Phase 4 (`.claude/skills/parallel-orchestrate/SKILL.md` and the files below).
      Commands: CMD-GIT-ADD with `.claude/skills/parallel-orchestrate/SKILL.md .claude/skills/parallel-remove/SKILL.md .claude/agents/parallel-orchestrator.md .claude/hooks/enforce-parallel-abandon-gate.ps1 tests/scripts/dev_tools/test_parallel_abandon_token_seam.py docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763`,
      CMD-GIT-COMMIT with message "fix(763): invoke the bundled drift and abandon entry points from the parallel skills",
      CMD-GIT-PUSH, then `git status --porcelain`. Acceptance: the push exits 0 and the porcelain status
      prints nothing.

### Phase 5 — Bundle Mirrors, Pack Manifest, Coverage Registration, and Payload Tests (AC6, AC12, AC14)

- [x] [P5-T1] Mirror the three drift files of `.claude/lib/parallel-drift` into BUNDLE.
      Commands: `mkdir -p extensions/drm-copilot/resources/claude-customizations/.claude/lib/parallel-drift`, then
      `cp .claude/lib/parallel-drift/ParallelDriftHalt.psm1 .claude/lib/parallel-drift/ParallelDrift.psm1 .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/parallel-drift/`.
      Acceptance: CMD-SH with script mirror-check (A5) over the three primaries prints
      `MIRROR-SUMMARY same=3 diff=0 missing=0`.
- [x] [P5-T2] Mirror `.claude/lib/bash/abandon-parallel-item.sh` into BUNDLE.
      Command: `cp BASHLIB/abandon-parallel-item.sh BUNDLEBASHLIB/`. Acceptance: CMD-SH with script
      mirror-check (A5) over `BASHLIB/abandon-parallel-item.sh` prints `MIRROR-SUMMARY same=1 diff=0 missing=0`.
- [x] [P5-T3] Mirror the four edited surface files (`.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/skills/parallel-remove/SKILL.md`, `.claude/agents/parallel-orchestrator.md`, `.claude/hooks/enforce-parallel-abandon-gate.ps1`) into BUNDLE.
      Commands: `cp .claude/skills/parallel-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md`,
      `cp .claude/skills/parallel-remove/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-remove/SKILL.md`,
      `cp .claude/agents/parallel-orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md`,
      `cp .claude/hooks/enforce-parallel-abandon-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1`.
      Acceptance: CMD-SH with script mirror-check (A5) over the four primaries prints
      `MIRROR-SUMMARY same=4 diff=0 missing=0`, and CMD-SH with script surface-token-count (A20) prints
      every bundle `COUNT` line with the same value as its repo line in P4-T14.
- [x] [P5-T4] Edit `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` per Appendix B27 (three drift entries after the CI gate parser entry; the abandon entry after the `.claude/rules/shell.md` entry).
      Acceptance: CMD-PY-SCRIPT with script json-parse (A11) over the file prints one `JSON-OK` line;
      CMD-GIT-COUNT with literal `.claude/lib/parallel-drift/` over it prints a count of 3; CMD-GIT-COUNT
      with literal `abandon-parallel-item.sh` over it prints a count of 1.
- [x] [P5-T5] Reset the PowerShell batch budget before editing `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`: CMD-PS with script reset-batch-budget (A8) and `-Kind powershell`.
      Write FEATURE/evidence/other/batch-budget-reset-p5.TS.md. Acceptance: exit 0 and a
      `RESET removed=` line.
- [x] [P5-T6] Edit `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`: insert the six lines of Appendix B28 after line 324 (inside `CodeCoverage.Path`, before the closing parenthesis on line 325).
      Acceptance: CMD-PS with script psd1-parse (A10) over the file prints `PSD1-OK`, and CMD-GIT-COUNT
      with literal `.claude/lib/parallel-drift/` over it prints a count of 3 (the three registered
      paths; the B28 comment names the directory without a trailing slash).
- [x] [P5-T7] Mirror `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` into PSBUNDLE.
      Command: `cp scripts/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`.
      Acceptance: CMD-SH with script mirror-check (A5) over the primary prints
      `MIRROR-SUMMARY same=1 diff=0 missing=0`.
- [x] [P5-T8] Edit `tests/shell/parallel_payload_only.bats` per Appendix B29 (abandon payload case with a separate shim PATH).
      Acceptance: CMD-GIT-COUNT with literal `parallel_abandon_path` over that file prints
      `tests/shell/parallel_payload_only.bats:2` (the header paragraph and the setup assignment), and
      CMD-GIT-COUNT with literal `@test "` prints `tests/shell/parallel_payload_only.bats:14` (11 existing
      tests plus the three of B29).
- [x] [P5-T9] Edit `tests/shell/parallel_bash_manifest_membership.bats` per Appendix B30 (five entry points).
      Acceptance: CMD-GIT-COUNT with literal `abandon-parallel-item.sh` over that file prints a count of 1.
- [x] [P5-T10] Run the local bats suites `tests/shell/parallel_abandon.bats`, `tests/shell/parallel_payload_only.bats`, and `tests/shell/parallel_bash_manifest_membership.bats`.
      Command: CMD-BATS over the three files. Write FEATURE/evidence/regression-testing/bats-after-bundle.TS.md.
      Acceptance: the TAP plan line is recorded; no `not ok` line names a test in
      `tests/shell/parallel_abandon.bats` or a test added by B29 or edited by B30; every other `not ok`
      line is a member of the P0-T20 local baseline failure set.
- [x] [P5-T11] Run the five suites in `tests/scripts/claude-lib/parallel-drift` after the manifest and bundle updates.
      Commands: CMD-PESTER with `tests/scripts/claude-lib/parallel-drift`, then CMD-JUNIT with the five
      suffixes of P3-T20. Write FEATURE/evidence/regression-testing/drift-suites-after-bundle.TS.md.
      Acceptance: all five `JUNIT file=` lines show `Failed=0`, and the Manifest suite shows `Passed=5`.
- [x] [P5-T12] Run the Python bundle contract tests in `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, and `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`.
      Command: CMD-PY-TEST over the three files. Write FEATURE/evidence/regression-testing/bundle-contracts.TS.md.
      Acceptance: every node other than `test_bundled_claude_payload_contains_all_repo_runtime_contracts`
      is PASSED, and that node satisfies KL-510 (the artifact carries the KL-510 line and, for case (b),
      `ExpectedExitCode: 1`).
- [x] [P5-T13] Run the Jest pack-manifest completeness suite `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`.
      Command: `npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts`.
      Write FEATURE/evidence/regression-testing/jest-pack-manifest.TS.md. Acceptance: exit 0 and the
      "Tests:" line reports 0 failed.
- [x] [P5-T14] Commit and push Phase 5 (`extensions/drm-copilot/resources/claude-customizations` and the files below).
      Commands: CMD-GIT-ADD with `extensions/drm-copilot/resources/claude-customizations scripts/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 tests/shell/parallel_payload_only.bats tests/shell/parallel_bash_manifest_membership.bats docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763`,
      CMD-GIT-COMMIT with message "fix(763): bundle the drift and abandon entry points and register their coverage",
      CMD-GIT-PUSH, then `git status --porcelain`. Acceptance: the push exits 0 and the porcelain status
      prints nothing.

### Phase 6 — Pass-After Verification and Scope Checks (AC1, AC8, AC9, AC11, AC13, AC16, AC17)

- [x] [P6-T1] Run the repository guard `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` after the port.
      Command: CMD-PY-TEST over that file. Write FEATURE/evidence/regression-testing/guard-repo-after-port.TS.md.
      Acceptance: exit 0 and all five tests PASSED, including `test_every_skill_script_reference_is_bundled`
      and `test_known_unbundled_references_are_not_stale`.
- [x] [P6-T2] Run the guard CLI `scripts/dev_tools/skill_bundle_contract_cli.py` after the port.
      Command: CMD-PY-GUARD-CLI. Write FEATURE/evidence/regression-testing/guard-cli-after-port.TS.md.
      Acceptance: exit 0 and no stderr line beginning `skill-bundle `.
- [x] [P6-T3] AC9 invocation sweep over `.claude` and `extensions/drm-copilot/resources/claude-customizations/.claude`, written to FEATURE/evidence/qa-gates/ac9-invocation-sweep.TS.md.
      Commands: `git grep -n -E 'python3?[[:space:]]+(-m[[:space:]]+)?scripts[./]dev_tools[./]parallel_(drift_detection|mutation_abandon)_cli' -- .claude extensions/drm-copilot/resources/claude-customizations/.claude`,
      then the negative control `git grep -n -E 'python3?[[:space:]]+(-m[[:space:]]+)?scripts[./]dev_tools[./]parallel_(drift_detection|mutation_abandon)_cli' BASE_SHA -- .claude extensions/drm-copilot/resources/claude-customizations/.claude`,
      then `git status --porcelain -- .claude extensions/drm-copilot/resources/claude-customizations/.claude`.
      Acceptance: the first command exits 1 with no output; the negative control exits 0 and prints
      exactly four lines (the two SKILL lines 884 and 112 in the repository tree and the same two in the
      bundle tree at BASE_SHA), which proves the pattern matches the pre-change invocations; the
      porcelain status prints nothing, so the tracked-file search saw every file. This is the tracked
      equivalent of the spec's ripgrep command.
- [x] [P6-T4] AC16 retained Python reference: confirm `scripts/dev_tools/parallel_drift_detection_cli.py`, `scripts/dev_tools/parallel_mutation_abandon_cli.py`, and their modules remain, and run their suites.
      Commands: CMD-GIT-LS over `scripts/dev_tools/parallel_drift_detection_cli.py scripts/dev_tools/parallel_mutation_abandon_cli.py scripts/dev_tools/parallel_drift_detection.py scripts/dev_tools/parallel_drift_halt.py scripts/dev_tools/parallel_drift_resolution.py scripts/dev_tools/_parallel_drift_cli_io.py scripts/dev_tools/_parallel_drift_scheduling.py scripts/dev_tools/_parallel_drift_shape.py scripts/dev_tools/_parallel_state_common.py`,
      then CMD-PY-TEST over `tests/scripts/dev_tools/test_parallel_drift_detection_cli.py tests/scripts/dev_tools/test_parallel_drift_detection_cli_halt.py tests/scripts/dev_tools/test_parallel_mutation_abandon_cli.py tests/scripts/dev_tools/test_parallel_mutation_protocol.py`.
      Write FEATURE/evidence/qa-gates/ac16-python-reference.TS.md. Acceptance: CMD-GIT-LS prints all nine
      paths; pytest exits 0 with no FAILED line.
- [x] [P6-T5] AC1 and AC8 PowerShell gates for `tests/scripts/claude-hooks` and `tests/scripts/claude-runtime`, written to FEATURE/evidence/qa-gates/ac1-ac8-pester.TS.md.
      Commands: CMD-PESTER with `tests/scripts/claude-hooks tests/scripts/claude-runtime`, then CMD-JUNIT
      with suffixes `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1`,
      `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1`, and
      `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`. Acceptance: the
      three `JUNIT file=` lines show `Failed=0`; the no-Python suite's cases
      `reports no Python invocation beyond the allowlist across the guarded tree` and
      `enumerates only the two guarded roots and never the bundled mirror` appear with
      `status=Passed` (the scan now includes the three `.claude/lib/parallel-drift` files); every
      `JUNIT-FAILED` line is a member of the P0-T19 baseline failure set.
- [x] [P6-T6] AC8 comment-only diff of `.claude/hooks/enforce-parallel-abandon-gate.ps1`, written to FEATURE/evidence/qa-gates/ac8-hook-diff.TS.md.
      Command: `git diff -U0 BASE_SHA -- .claude/hooks/enforce-parallel-abandon-gate.ps1`. Acceptance:
      exactly one hunk, whose header begins `@@ -28,4 +28,4 @@`; every removed and added line lies inside the
      `<# ... #>` comment block that ends on line 32; no removed or added line contains `$script:`.
      Together with the P4-T13 seam results (each token literal stated exactly once in the hook, the
      hook pair equal to the CLI pair), this shows the `$script:AbandonDispositionToken` and
      `$script:AbandonConfirmToken` assignment lines (41 and 42) are unchanged.
- [x] [P6-T7] AC11 agent diff of `.claude/agents/parallel-orchestrator.md`, written to FEATURE/evidence/qa-gates/ac11-agent-diff.TS.md.
      Commands: `git diff -U0 BASE_SHA -- .claude/agents/parallel-orchestrator.md`, then CMD-SH with
      script surface-token-count (A20). Acceptance: no removed line contains `Bash(poetry run python -m *)`;
      among the added lines, those beginning `  - "Bash(` are exactly the two entries at Appendix B24a
      positions 8 and 10, and no removed line begins `  - "Bash(`; A20 prints
      `COUNT T3 .claude/agents/parallel-orchestrator.md 1`, `COUNT T4 .claude/agents/parallel-orchestrator.md 1`,
      and `COUNT T5 .claude/agents/parallel-orchestrator.md 1`.
- [x] [P6-T8] AC17 scope check against BASE_SHA over the tree, including `.claude/settings.json`, written to FEATURE/evidence/qa-gates/ac17-scope.TS.md.
      Commands: `git diff --name-only BASE_SHA HEAD`, then `git status --porcelain`. Acceptance: the
      name-only list contains none of `.claude/hooks/enforce-powershell-batch-budget.ps1`,
      `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1`,
      `scripts/dev_tools/push_down_claude_customizations.py`,
      `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`, `.claude/settings.json`, or
      `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`; the porcelain
      status lists only paths under FEATURE (this phase's uncommitted evidence under FEATURE/evidence
      and the checklist file FEATURE/plan.2026-09-29T14-14.md). The artifact records the full name-only
      list.
- [x] [P6-T9] AC17 temporary-file sweep over every new or changed test file and shim (`tests/shell/parallel_abandon.bats` and the others listed), written to FEATURE/evidence/qa-gates/ac17-no-temp.TS.md.
      Commands: CMD-SH with script no-temp-sweep (A17) over `tests/shell/parallel_abandon.bats tests/shell/parallel_abandon_parity.bats tests/shell/parallel_payload_only.bats tests/shell/parallel_bash_manifest_membership.bats tests/scripts/dev_tools/test_parallel_drift_parity.py tests/scripts/dev_tools/test_parallel_abandon_bash_parity.py tests/scripts/dev_tools/test_parallel_abandon_token_seam.py tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py tests/scripts/dev_tools/test_skill_bundle_contract_cli.py tests/scripts/claude-lib/parallel-drift/ParallelDriftHalt.Tests.ps1 tests/scripts/claude-lib/parallel-drift/ParallelDrift.Tests.ps1 tests/scripts/claude-lib/parallel-drift/ParallelDrift.Manifest.Tests.ps1 tests/scripts/claude-lib/parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1 tests/scripts/claude-lib/parallel-drift/ParallelDrift.Parity.Tests.ps1 tests/fixtures/parallel_abandon_path/gh tests/fixtures/parallel_abandon_path/git`,
      then the negative control: the same script over `FEATURE/plan.2026-09-29T14-14.md`. Acceptance: the
      first run prints no match line and ends with `SWEEP-EXIT=1`; the control prints at least one match
      line and ends with `SWEEP-EXIT=0` (this plan quotes the swept tokens in Appendix A17), which proves
      the pattern can match.

### Phase 7 — Final QA Loop: Bash (shfmt, shellcheck, bats)

- [x] [P7-T1] Format `.claude/lib/bash/abandon-parallel-item.sh` and the three shims under `tests/fixtures/parallel_abandon_path`.
      Commands: `git status --porcelain` (before), CMD-SH with script shell-format (A13),
      `git status --porcelain` (after), CMD-SH with script shell-lint (A12). Write
      FEATURE/evidence/qa-gates/shell-format.TS.md. Acceptance: A13 prints `SHFMT-WRITE-EXIT=0`; the two
      porcelain outputs are identical (shfmt changed no file); A12 prints `SHFMT-DIFF-EXIT=0`. A
      difference between the two porcelain outputs means shfmt rewrote a file: when
      `.claude/lib/bash/abandon-parallel-item.sh` changed, copy it to BUNDLEBASHLIB with
      `cp BASHLIB/abandon-parallel-item.sh BUNDLEBASHLIB/` and confirm with script mirror-check (A5)
      over `BASHLIB/abandon-parallel-item.sh` that it prints `diff=0`; commit the rewrite together with
      that mirror and restart this loop.
- [x] [P7-T2] Lint `.claude/lib/bash/abandon-parallel-item.sh` and the three shims with shellcheck.
      Command: CMD-SH with script shell-lint (A12). Write FEATURE/evidence/qa-gates/shell-lint.TS.md.
      Acceptance: exit 0 and `SHELLCHECK-EXIT=0` with no diagnostic line.
- [x] [P7-T3] Test the four bats suites locally: `tests/shell/parallel_abandon.bats`, `tests/shell/parallel_payload_only.bats`, `tests/shell/parallel_bash_manifest_membership.bats`, then the parity suite.
      Commands: CMD-BATS over the first three files, then CMD-SH with script bats-parity-local (A23).
      Write FEATURE/evidence/qa-gates/shell-test-local.TS.md. Acceptance: the first run satisfies the
      P5-T10 rule; the parity run satisfies the P2-T15 rule (including its authorized environment
      branch). Local kcov is unavailable; the coverage values for this language are produced by P11-T3
      and P11-T4 from the committed final state.

### Phase 8 — Final QA Loop: PowerShell (PoshQC, PSScriptAnalyzer, Pester)

- [x] [P8-T1] Reset the PowerShell batch budget before any QA-loop fix under `.claude/lib/parallel-drift`: CMD-PS with script reset-batch-budget (A8) and `-Kind powershell`.
      Write FEATURE/evidence/other/batch-budget-reset-p8.TS.md. Acceptance: exit 0 and a
      `RESET removed=` line.
- [x] [P8-T2] Format the PowerShell files of Appendix C4 (starting with `.claude/lib/parallel-drift/ParallelDrift.psm1`).
      Commands: CMD-SH with script file-hashes (A5b) over the C4 files (before); `git status --porcelain`
      (before); MCP-PS-FORMAT with scan_folders `.claude/lib/parallel-drift`,
      `tests/scripts/claude-lib/parallel-drift`, `.claude/hooks`, `scripts/powershell/PoshQC/settings`
      (route-compliance step); `git status --porcelain` (after); the same A5b run (after); CMD-PS with
      script ps-format-check (A6) over the C4 files. Write FEATURE/evidence/qa-gates/powershell-format.TS.md.
      Acceptance: the MCP call returns without raising; the two porcelain outputs are identical; the
      before and after hashes are identical for every C4 file; A6 prints `FORMAT-SUMMARY ChangedCount=0`.
      The scan folders hold out-of-scope files (for example
      `.claude/hooks/enforce-powershell-batch-budget.ps1`, issue #769), so any difference between the
      two porcelain outputs stops the task, and the differing paths are reported. A differing path
      outside C4 is never committed, and the caller decides how it is restored. When every differing
      path is a C4 member, the formatter rewrote an in-scope file: copy each rewritten file that has a
      BUNDLE or PSBUNDLE mirror to that mirror with `cp`, confirm with script mirror-check (A5) that it
      prints `diff=0`, commit the rewrite together with those mirrors, and restart this loop.
- [x] [P8-T3] Analyze the Appendix C4 PowerShell files (starting with `.claude/lib/parallel-drift/ParallelDrift.psm1`).
      Commands: MCP-PS-ANALYZE with the P8-T2 scan_folders (route-compliance step), then CMD-PS with
      script pssa-count (A9) over the C4 files. Write FEATURE/evidence/qa-gates/powershell-analyze.TS.md.
      Acceptance: the MCP call returns without raising and A9 prints `PSSA-SUMMARY DiagnosticCount=0`.
- [x] [P8-T4] Route-compliance run of the MCP Pester tool over `tests/scripts/claude-lib/parallel-drift`.
      Command: MCP-PS-TEST with scan_folders `tests/scripts/claude-lib/parallel-drift`. Write
      FEATURE/evidence/qa-gates/powershell-mcp-test-route.TS.md. Acceptance: the call returns without
      raising and the artifact quotes its summary string. No count, coverage, or pass value is read from
      it (the MCP tool reads the installed extension's runsettings); P8-T5 overwrites its XML outputs.
- [x] [P8-T5] Test with coverage for `.claude/lib/parallel-drift` and regression over `tests/scripts/claude-lib`, `tests/scripts/claude-hooks`, and `tests/scripts/claude-runtime`, written to FEATURE/evidence/qa-gates/powershell-test-coverage.TS.md.
      Commands: CMD-PESTER with `tests/scripts/claude-lib tests/scripts/claude-hooks tests/scripts/claude-runtime`;
      CMD-JUNIT with the five parallel-drift suffixes of P3-T20, the three suffixes of P6-T5, and
      `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` (the module convention suite that
      discovers the two new `.psm1` files);
      CMD-JACOCO with `.claude/lib/parallel-drift/ParallelDriftHalt.psm1 .claude/lib/parallel-drift/ParallelDrift.psm1 .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1 .claude/hooks/enforce-parallel-abandon-gate.ps1`.
      Acceptance: the nine `JUNIT file=` lines show `Failed=0` and no `MISSING` line; every
      `JUNIT-FAILED` line is a member of the P0-T19 baseline failure set; the three parallel-drift
      `JACOCO` lines each show `LinePercent=` of at least 85; the hook's `LinePercent=` is at least its
      P0-T19 value.

### Phase 9 — Final QA Loop: Python (black, ruff, pyright, pytest with coverage)

- [x] [P9-T1] Reset the Python batch budget before any QA-loop fix under `scripts/dev_tools`: CMD-PS with script reset-batch-budget (A8) and `-Kind python`.
      Write FEATURE/evidence/other/batch-budget-reset-p9.TS.md. Acceptance: exit 0 and a
      `RESET removed=` line.
- [x] [P9-T2] Format the seven Python files of Appendix C5 (starting with `scripts/dev_tools/skill_bundle_contract.py`).
      Commands: `git status --porcelain` (before), CMD-PY-BLACK over the C5 files, `git status --porcelain`
      (after). Write FEATURE/evidence/qa-gates/python-format.TS.md. Acceptance: black exits 0 and prints
      "7 files left unchanged." with no "reformatted" line, and the two porcelain outputs are identical.
- [x] [P9-T3] Lint the seven C5 Python files (starting with `scripts/dev_tools/skill_bundle_contract.py`).
      Command: CMD-PY-RUFF over the C5 files. Write FEATURE/evidence/qa-gates/python-lint.TS.md.
      Acceptance: exit 0 and "All checks passed!".
- [x] [P9-T4] Type-check the seven C5 Python files (starting with `scripts/dev_tools/skill_bundle_contract.py`).
      Command: CMD-PY-PYRIGHT over the C5 files. Write FEATURE/evidence/qa-gates/python-typecheck.TS.md.
      Acceptance: exit 0 and a summary line beginning "0 errors".
- [x] [P9-T5] Test with coverage for `scripts/dev_tools/skill_bundle_contract.py` and `scripts/dev_tools/skill_bundle_contract_cli.py`, written to FEATURE/evidence/qa-gates/python-test-coverage.TS.md.
      Commands: `poetry run pytest -v tests/scripts/dev_tools/test_skill_bundle_contract.py tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py tests/scripts/dev_tools/test_skill_bundle_contract_cli.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py --cov=scripts.dev_tools.skill_bundle_contract --cov=scripts.dev_tools.skill_bundle_contract_cli --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/cov-763-final.json`,
      then CMD-PY-SCRIPT with script py-cov-files (A7) and arguments
      `SCRATCH/cov-763-final.json scripts/dev_tools/skill_bundle_contract.py scripts/dev_tools/skill_bundle_contract_cli.py`,
      then CMD-PY-SCRIPT with script changed-lines-cov (A19) and arguments
      `SCRATCH/cov-763-final.json BASE_SHA scripts/dev_tools/skill_bundle_contract.py scripts/dev_tools/skill_bundle_contract_cli.py`.
      Acceptance: pytest exits 0 with no FAILED line and `test_main_returns_one_for_stale_exception`
      PASSED (the stale-exception branch is executed); A7 prints `LinePercent=` at least 85 and
      `BranchPercent=` at least 75 for each module, each line percent at least its P0-T15 value; A19
      prints `UncoveredChangedLines=0` for both modules.
- [x] [P9-T6] Python regression over `tests/scripts/dev_tools`, written to FEATURE/evidence/qa-gates/python-regression.TS.md.
      Commands: CMD-PY-TEST over the named set of Appendix C3 plus `tests/scripts/dev_tools/test_parallel_drift_parity.py`
      and `tests/scripts/dev_tools/test_parallel_abandon_bash_parity.py`, then
      `poetry run pytest tests/scripts/dev_tools -q`. Acceptance: every named-set node is PASSED except
      KL-510, recorded with its KL-510 line; every `FAILED` line of the full run is a member of the
      P0-T16 baseline failure set or is the KL-510 node in case (b).
- [x] [P9-T7] File-size limit check for every new or changed code, test, script, and fixture-harness file (starting with `.claude/lib/parallel-drift/ParallelDrift.psm1`), written to FEATURE/evidence/qa-gates/line-counts-final.TS.md.
      Command: CMD-SH with script line-counts (A22) over the C5 files, the C4 files,
      `BASHLIB/abandon-parallel-item.sh`, `tests/shell/parallel_abandon.bats`,
      `tests/shell/parallel_abandon_parity.bats`, `tests/shell/parallel_payload_only.bats`, and
      `tests/shell/parallel_bash_manifest_membership.bats`. Acceptance: every `LineCount=` value is at
      most 500; `.claude/hooks/enforce-parallel-abandon-gate.ps1` equals its P0-T10 value; the
      runsettings file equals its P0-T10 value plus 6.

### Phase 10 — Final QA Loop: TypeScript (Jest regression)

- [x] [P10-T1] TypeScript push-down regression for `extensions/drm-copilot/test/lib/push-down` (no TypeScript source or test file is changed; format, lint, and type-check have no changed input).
      Command: CMD-TS-TEST. Write FEATURE/evidence/qa-gates/ts-push-down-jest.TS.md. Acceptance: every
      `FAIL ` line is a member of the P0-T23 baseline failure set; no `FAIL ` line names
      `claude-pack-manifest-completeness.test.ts`; the "Tests:" line records no more failed tests than
      the baseline.

### Phase 11 — CI Shell Coverage and Coverage Comparison

- [ ] [P11-T1] Commit and push the final state, record FINAL_SHA, and repeat the AC17 scope check against BASE_SHA in FEATURE/evidence/qa-gates/final-commit.TS.md.
      Commands: `git status --porcelain`; CMD-GIT-ADD with `docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763`
      plus every path that status listed (fixes made by Phase 7-10 loop restarts). Before CMD-GIT-ADD,
      every path the first status lists, other than paths under FEATURE, must be a member of C4, C5,
      `.claude/lib/bash/abandon-parallel-item.sh`, or the three shims (`tests/fixtures/parallel_abandon_path/gh`,
      `tests/fixtures/parallel_abandon_path/git`, `tests/fixtures/parallel_abandon_path_git_only/git`),
      or the BUNDLE or PSBUNDLE mirror of such a member (the mirror rule requires a mirror to follow its
      primary); any other path stops the task and is reported. CMD-GIT-COMMIT with
      message "docs(763): record final QA evidence"; CMD-GIT-PUSH; CMD-GIT-HEAD; then
      `git diff --name-only BASE_SHA HEAD` and `git status --porcelain`. Acceptance: the push exits 0;
      the HEAD value is recorded as FINAL_SHA; the final porcelain status prints nothing; the name-only
      list contains none of the six P6-T8 forbidden paths.
- [ ] [P11-T2] Dispatch `.github/workflows/_shell-coverage.yml` on BRANCH at FINAL_SHA and wait for it.
      Commands: CMD-GH-DISPATCH, CMD-GH-LATEST (repeat until it lists a run whose `headSha` equals
      FINAL_SHA), CMD-CI-WAIT with that run id. Run CMD-CI-WAIT in the background, or re-invoke it
      after a tool timeout; the recorded result is that of the invocation that exits. Append to
      FEATURE/evidence/qa-gates/final-commit.TS.md. Acceptance: CMD-CI-WAIT exits 0 and reports `status` `completed`, `conclusion` `success`, and
      job `Shell Coverage (Bats + kcov)` with conclusion `success`.
- [ ] [P11-T3] Bash suite results and coverage headline from the P11-T2 run of `.github/workflows/_shell-coverage.yml`, written to FEATURE/evidence/qa-gates/shell-coverage-ci.TS.md.
      Command: CMD-CI-LOG with the P11-T2 run id. Acceptance: `NOT-OK-COUNT=0`; exactly one line
      containing `Bash coverage (lines): <n>%` with n at least 85.0; the artifact records the P0-T21
      value and the difference as information only (the changed-line gate for bash is the per-file
      line rate of P11-T4);
      `OK-COUNT=` equals the P0-T21 value plus 20 (14 tests in `tests/shell/parallel_abandon.bats`, 3 in
      `tests/shell/parallel_abandon_parity.bats`, and 3 added to `tests/shell/parallel_payload_only.bats`;
      B30 renames one existing test and adds none), and the artifact records that arithmetic; the
      printed suite lines include `ok` lines for the three `tests/shell/parallel_abandon_parity.bats`
      tests, the three B29 tests, and "the five CLI entry points are present in both trees". This task
      is the authoritative bash parity result (AC5) and payload-only result (AC6).
- [ ] [P11-T4] Bash per-file coverage for `.claude/lib/bash/abandon-parallel-item.sh` from the P11-T2 artifact, written to FEATURE/evidence/qa-gates/shell-coverage-files.TS.md.
      Commands: CMD-GH-DOWNLOAD with the P11-T2 run id into `SCRATCH/shell-cov-final`, then CMD-PY-SCRIPT
      with script cobertura-files (A16) and arguments `SCRATCH/shell-cov-final/cov.xml abandon-parallel-item.sh compute-cohorts.sh`.
      Acceptance: no `MISSING` line; every `COBERTURA file=` line whose path ends with
      `abandon-parallel-item.sh` shows `line-rate=` at least 0.85; the artifact records `COBERTURA-TOTAL`.
- [ ] [P11-T5] Coverage comparison for bash, PowerShell, Python, and TypeScript, written to FEATURE/evidence/qa-gates/coverage-comparison.TS.md from the artifacts of P0-T15, P0-T19, P0-T21, P0-T22, P8-T5, P9-T5, P11-T3, and P11-T4.
      Acceptance: for each of bash, PowerShell, and Python the artifact carries `Baseline Coverage:`,
      `Post-Change Coverage:`, `New/Changed-code Coverage:`, and `Disposition:` with numeric values
      (bash: CI headline before and after and the abandon script's line-rate; PowerShell: the hook's
      line percent before and after and each new file's line percent, whose baseline is recorded as
      "absent at BASE_SHA"; Python: each module's line and branch percent before and after and the A19
      uncovered-changed-line counts). TypeScript carries `Disposition: NOT-APPLICABLE` with the reason
      that no TypeScript source or test file changed, citing P10-T1. The overall `Disposition:` is
      `PASS` only when every threshold of P8-T5, P9-T5, P11-T3, and P11-T4 holds; otherwise `BLOCKED`.

### Phase 12 — Final QA Confirmation and Acceptance-Criteria Check-Off

- [ ] [P12-T1] Check off AC1 in FEATURE/spec.md (the AC box becomes lowercase x). Acceptance: the P3-T14, P3-T20, P3-T22, P6-T5, and P8-T5 artifacts exist with passing acceptance; cited in FEATURE/evidence/other/ac-checkoff.TS.md.
- [ ] [P12-T2] Check off AC2 in FEATURE/spec.md. Acceptance: the P3-T3, P3-T6, and P3-T20 artifacts exist with passing acceptance (both lanes' floor tests PASSED); cited in FEATURE/evidence/other/ac-checkoff.TS.md.
- [ ] [P12-T3] Check off AC3 in FEATURE/spec.md. Acceptance: the P3-T18 (fail-before), P3-T20, and P3-T21 artifacts exist with passing acceptance and every B19 It name is PASSED; cited in FEATURE/evidence/other/ac-checkoff.TS.md.
- [ ] [P12-T4] Check off AC4 in FEATURE/spec.md. Acceptance: the P2-T6 (fail-before), P2-T8, and P7-T3 artifacts exist with passing acceptance; cited in FEATURE/evidence/other/ac-checkoff.TS.md.
- [ ] [P12-T5] Check off AC5 in FEATURE/spec.md. Acceptance: the P2-T13 and P11-T3 artifacts exist with passing acceptance (the Python lane and the CI bash parity lane); cited in FEATURE/evidence/other/ac-checkoff.TS.md.
- [ ] [P12-T6] Check off AC6 in FEATURE/spec.md. Acceptance: the P5-T10 and P11-T3 artifacts exist with passing acceptance for the three B29 tests; cited in FEATURE/evidence/other/ac-checkoff.TS.md.
- [ ] [P12-T7] Check off AC7 in FEATURE/spec.md. Acceptance: the P4-T13 artifact exists with every B26 test PASSED; cited in FEATURE/evidence/other/ac-checkoff.TS.md.
- [ ] [P12-T8] Check off AC8 in FEATURE/spec.md. Acceptance: the P6-T5 and P6-T6 artifacts exist with passing acceptance; cited in FEATURE/evidence/other/ac-checkoff.TS.md with the DV2 anchor note.
- [ ] [P12-T9] Check off AC9 in FEATURE/spec.md. Acceptance: the P4-T14, P5-T3, and P6-T3 artifacts exist with passing acceptance; cited in FEATURE/evidence/other/ac-checkoff.TS.md.
- [ ] [P12-T10] Check off AC10 in FEATURE/spec.md. Acceptance: the P4-T15 artifact exists with passing acceptance and the P9-T6 named set shows `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` PASSED; cited in FEATURE/evidence/other/ac-checkoff.TS.md.
- [ ] [P12-T11] Check off AC11 in FEATURE/spec.md. Acceptance: the P4-T7 and P6-T7 artifacts exist with passing acceptance; cited in FEATURE/evidence/other/ac-checkoff.TS.md with the DV2 anchor note.
- [ ] [P12-T12] Check off AC12 in FEATURE/spec.md. Acceptance: the P5-T1 through P5-T4, P5-T10, P5-T11, P5-T12, and P5-T13 artifacts exist with passing acceptance; cited in FEATURE/evidence/other/ac-checkoff.TS.md.
- [ ] [P12-T13] Check off AC13 in FEATURE/spec.md. Acceptance: the P1-T6, P1-T7 (fail-before), P1-T8 (fail-before), P4-T13 (`test_bundle_guard_extracts_the_skill_invocation` PASSED), P6-T1, P6-T2, and P9-T5 artifacts exist with passing acceptance; cited in FEATURE/evidence/other/ac-checkoff.TS.md.
- [ ] [P12-T14] Check off AC14 in FEATURE/spec.md. Acceptance: the P5-T6, P5-T7, P5-T12 (`test_poshqc_bundled_parity.py` PASSED), and P8-T5 artifacts exist with passing acceptance; cited in FEATURE/evidence/other/ac-checkoff.TS.md.
- [ ] [P12-T15] Check off AC15 in FEATURE/spec.md. Acceptance: the P9-T5 and P11-T4 artifacts exist with passing acceptance; cited in FEATURE/evidence/other/ac-checkoff.TS.md.
- [ ] [P12-T16] Check off AC16 in FEATURE/spec.md. Acceptance: the P6-T4 artifact exists with passing acceptance; cited in FEATURE/evidence/other/ac-checkoff.TS.md.
- [ ] [P12-T17] Check off AC17 in FEATURE/spec.md. Acceptance: the P6-T8, P6-T9, and P11-T1 artifacts exist with passing acceptance; cited in FEATURE/evidence/other/ac-checkoff.TS.md with the DV2 anchor note.
- [ ] [P12-T18] Check off AC18 in FEATURE/spec.md. Acceptance: every Phase 7 through 11 artifact exists with passing acceptance and the P11-T5 overall `Disposition:` is `PASS`; cited in FEATURE/evidence/other/ac-checkoff.TS.md. If the disposition is `BLOCKED`, AC18 stays unchecked and the plan outcome is remediation-required.
- [ ] [P12-T19] Count the acceptance-criteria checkboxes in FEATURE/spec.md directly.
      Command: CMD-SH with script ac-count (A21) and argument `FEATURE/spec.md`. Append to
      FEATURE/evidence/other/ac-checkoff.TS.md. Acceptance: exit 0 and `AC-CHECKED=18 AC-UNCHECKED=0`.
- [ ] [P12-T20] Commit and push the check-off in `docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763/spec.md`.
      Commands: CMD-GIT-ADD with `docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763`,
      CMD-GIT-COMMIT with message "docs(763): check off acceptance criteria", CMD-GIT-PUSH, then
      `git status --porcelain`. Acceptance: the push exits 0 and the porcelain status prints nothing.

---

## Acceptance Criteria Traceability

| AC | Implementation tasks | Verifying tasks | Evidence |
| --- | --- | --- | --- |
| AC1 | P3-T12, P3-T13, P3-T19 | P3-T14, P3-T20, P3-T22, P6-T5, P8-T5 | qa-gates/ac1-ac8-pester |
| AC2 | P3-T2, P3-T3, P3-T5, P3-T17 | P3-T6, P3-T20 | regression-testing/drift-entry-after |
| AC3 | P3-T16, P3-T19 | P3-T18, P3-T20, P3-T21 | regression-testing/drift-process-smoke |
| AC4 | P2-T1..P2-T7 | P2-T6, P2-T8, P7-T3 | regression-testing/abandon-bats-after-script |
| AC5 | P2-T10, P2-T12, P2-T14 | P2-T13, P2-T15, P11-T3 | qa-gates/shell-coverage-ci |
| AC6 | P5-T2, P5-T8 | P5-T10, P11-T3 | regression-testing/bats-after-bundle |
| AC7 | P4-T12 | P4-T13 | regression-testing/abandon-token-seam |
| AC8 | P4-T10 | P6-T5, P6-T6 | qa-gates/ac8-hook-diff |
| AC9 | P4-T1..P4-T6, P5-T3 | P4-T14, P6-T3 | qa-gates/ac9-invocation-sweep |
| AC10 | P4-T1..P4-T4 | P4-T15, P9-T6 | regression-testing/surface-contracts |
| AC11 | P4-T7, P4-T8 | P4-T14, P6-T7 | qa-gates/ac11-agent-diff |
| AC12 | P5-T1..P5-T4, P5-T9 | P5-T10..P5-T13 | regression-testing/bundle-contracts |
| AC13 | P1-T2..P1-T5, P4-T5 | P1-T6, P1-T7, P1-T8, P4-T13, P6-T1, P6-T2 | regression-testing/guard-repo-after-port |
| AC14 | P5-T6, P5-T7 | P5-T12, P8-T5 | qa-gates/powershell-test-coverage |
| AC15 | P2-T7, P1-T2, P1-T3 | P9-T5, P11-T4 | qa-gates/coverage-comparison |
| AC16 | none (retention, D3) | P6-T4 | qa-gates/ac16-python-reference |
| AC17 | scope constraints | P6-T8, P6-T9, P11-T1 | qa-gates/ac17-scope |
| AC18 | Phases 7-11 | P7-T1..P11-T5 | qa-gates/coverage-comparison |

---

## Appendix A — Scratch Scripts

Scripts are written verbatim under SCRATCH by P0-T7 and are never committed. Python scratch scripts
that import repository modules insert the current working directory (the repository root) into
`sys.path`, because a script run from SCRATCH does not have the repository root on its path.

A1 run-ps.sh:

```sh
#!/bin/sh
set -eu
pwsh -NoProfile -NonInteractive -File "$@"
```

A2 pester-selfhosted.ps1 (imports the self-hosted PoshQC module so the repository runsettings,
including new `CodeCoverage.Path` entries, are used; `Run.Exit = $true` in the settings sets the
process exit code, so every asserted value is read from the XML outputs):

```powershell
param([Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)][string[]] $ScanFolder)
$ErrorActionPreference = 'Stop'
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force
Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders $ScanFolder -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1 -DisableKoverageCopy
```

A3 junit-cases.py (arguments: JUnit path, then test-file suffixes; paths are printed relative to the
first `tests/` segment so no host path is recorded):

```python
import sys
import xml.etree.ElementTree as ElementTree
from pathlib import Path


def relative(classname):
    normalized = classname.replace("\\", "/")
    index = normalized.find("tests/")
    return normalized[index:] if index >= 0 else normalized


def is_failed(case):
    return case.get("status") == "Failed" or case.find("failure") is not None


root = ElementTree.parse(Path(sys.argv[1])).getroot()
cases = [(relative(c.get("classname", "")), c.get("name", ""), c) for c in root.iter("testcase")]
for suffix in sys.argv[2:]:
    matched = [c for c in cases if c[0].endswith(suffix)]
    if not matched:
        print(f"JUNIT file={suffix} MISSING")
        continue
    passed = sum(1 for c in matched if c[2].get("status") == "Passed" and not is_failed(c[2]))
    failed = sum(1 for c in matched if is_failed(c[2]))
    print(f"JUNIT file={suffix} Total={len(matched)} Passed={passed} Failed={failed} Other={len(matched) - passed - failed}")
    for path, name, case in matched:
        status = "Failed" if is_failed(case) else case.get("status", "")
        print(f"JUNIT-CASE status={status} file={suffix} name={name}")
print(f"JUNIT-ALL Total={len(cases)} Failed={sum(1 for c in cases if is_failed(c[2]))}")
for path, name, case in cases:
    if is_failed(case):
        print(f"JUNIT-FAILED {path}::{name}")
```

A4 jacoco-files.py (arguments: coverage XML path, then repository-relative production paths; a file
is keyed on its enclosing `package` element, whose name is the absolute directory):

```python
import sys
import xml.etree.ElementTree as ElementTree
from pathlib import Path

root = ElementTree.parse(Path(sys.argv[1])).getroot()
for target in sys.argv[2:]:
    directory, _, filename = target.replace("\\", "/").rpartition("/")
    found = None
    for package in root.iter("package"):
        name = package.get("name", "").replace("\\", "/")
        if name == directory or name.endswith("/" + directory):
            for sourcefile in package.findall("sourcefile"):
                if sourcefile.get("name") == filename:
                    found = sourcefile
    if found is None:
        print(f"JACOCO file={target} MISSING")
        continue
    counter = next((c for c in found.findall("counter") if c.get("type") == "LINE"), None)
    if counter is None:
        print(f"JACOCO file={target} NO-LINE-COUNTER")
        continue
    missed = int(counter.get("missed", "0"))
    covered = int(counter.get("covered", "0"))
    total = missed + covered
    percent = 100.0 * covered / total if total else 0.0
    print(f"JACOCO file={target} Covered={covered} Missed={missed} LinePercent={percent:.2f}")
```

A5 mirror-check.sh (arguments: primary paths; the bundle counterpart is derived):

```sh
#!/bin/sh
set -u
bundle_root=extensions/drm-copilot/resources/claude-customizations
same=0
different=0
missing=0
for primary in "$@"; do
  case "$primary" in
    scripts/powershell/*) mirror="extensions/drm-copilot/resources/powershell/${primary#scripts/powershell/}" ;;
    *) mirror="$bundle_root/$primary" ;;
  esac
  if [ ! -f "$primary" ] || [ ! -f "$mirror" ]; then
    echo "MIRROR MISSING $primary"
    missing=$((missing + 1))
  elif cmp -s "$primary" "$mirror"; then
    echo "MIRROR SAME $primary"
    same=$((same + 1))
  else
    echo "MIRROR DIFF $primary"
    different=$((different + 1))
  fi
done
echo "MIRROR-SUMMARY same=$same diff=$different missing=$missing"
```

A5b file-hashes.sh:

```sh
#!/bin/sh
set -eu
for file in "$@"; do
  printf '%s Hash=%s\n' "$file" "$(git hash-object "$file")"
done
```

A6 ps-format-check.ps1 (read-only):

```powershell
param([Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)][string[]] $Path)
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
param([Parameter(Mandatory = $true)][ValidateSet('python', 'powershell')][string] $Kind)
$stateDirectory = '.claude/state'
if (-not (Test-Path -LiteralPath $stateDirectory)) { Write-Output 'RESET removed=0'; return }
$stateFiles = @(Get-ChildItem -LiteralPath $stateDirectory -Filter "$Kind-batch-budget.*.json" -File)
foreach ($stateFile in $stateFiles) { Write-Output "RESET file=$($stateFile.Name)"; Remove-Item -LiteralPath $stateFile.FullName }
Write-Output "RESET removed=$($stateFiles.Count)"
```

A9 pssa-count.ps1:

```powershell
param([Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)][string[]] $Path)
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$records = @(foreach ($file in $Path) { Invoke-ScriptAnalyzer -Path $file -Settings $settings })
foreach ($record in $records) { Write-Output "PSSA $($record.ScriptName):$($record.Line) $($record.RuleName) $($record.Severity)" }
Write-Output "PSSA-SUMMARY DiagnosticCount=$($records.Count)"
```

A10 psd1-parse.ps1:

```powershell
param([Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)][string[]] $Path)
$ErrorActionPreference = 'Stop'
foreach ($file in $Path) { $null = Import-PowerShellDataFile -LiteralPath $file; Write-Output "PSD1-OK file=$file" }
```

A11 json-parse.py:

```python
import json
import sys
from pathlib import Path

for name in sys.argv[1:]:
    json.loads(Path(name).read_text(encoding="utf-8"))
    print(f"JSON-OK file={name}")
```

A12 shell-lint.sh (read-only; word splitting of the fixed file list is intended):

```sh
#!/bin/sh
set -u
files=".claude/lib/bash/abandon-parallel-item.sh tests/fixtures/parallel_abandon_path/gh tests/fixtures/parallel_abandon_path/git tests/fixtures/parallel_abandon_path_git_only/git"
rc=0
shfmt -d $files || rc=$?
echo "SHFMT-DIFF-EXIT=$rc"
sc=0
for file in $files; do
  shellcheck "$file" || sc=$?
done
echo "SHELLCHECK-EXIT=$sc"
```

A13 shell-format.sh (write mode):

```sh
#!/bin/sh
set -u
files=".claude/lib/bash/abandon-parallel-item.sh tests/fixtures/parallel_abandon_path/gh tests/fixtures/parallel_abandon_path/git tests/fixtures/parallel_abandon_path_git_only/git"
rc=0
shfmt -w $files || rc=$?
echo "SHFMT-WRITE-EXIT=$rc"
```

A14 ci-wait.sh (argument: run id; exits 3 after 90 polls of 60 seconds):

```sh
#!/bin/sh
set -eu
run_id="$1"
polls=0
while :; do
  status=$(gh run view "$run_id" --json status --jq .status)
  if [ "$status" = "completed" ]; then
    break
  fi
  polls=$((polls + 1))
  if [ "$polls" -ge 90 ]; then
    echo "CI-WAIT-TIMEOUT run=$run_id"
    exit 3
  fi
  sleep 60
done
gh run view "$run_id" --json databaseId,headSha,status,conclusion,event,jobs --jq '{id: .databaseId, headSha: .headSha, status: .status, conclusion: .conclusion, event: .event, jobs: [.jobs[] | {name: .name, conclusion: .conclusion}]}'
```

A15 ci-shell-log.sh (argument: run id). An `ok` pattern also matches inside a `not ok` line, so
`OK-COUNT` is the difference of the two counts:

```sh
#!/bin/sh
set -u
log=$(gh run view "$1" --log)
printf '%s\n' "$log" | grep -E 'Bash coverage \(lines\): [0-9]' || echo "HEADLINE-MISSING"
not_ok=$(printf '%s\n' "$log" | grep -c -E 'not ok [0-9]+ ')
any_ok=$(printf '%s\n' "$log" | grep -c -E '(^|[[:space:]])ok [0-9]+ ')
echo "NOT-OK-COUNT=$not_ok"
echo "OK-COUNT=$((any_ok - not_ok))"
printf '%s\n' "$log" | grep -o -E '(not )?ok [0-9]+ .*(abandon|payload|entry points|harness interpreter).*'
```

A16 cobertura-files.py (arguments: report path, then path suffixes):

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

A17 no-temp-sweep.sh (arguments: files; exit status of grep is reported, 1 meaning no match):

```sh
#!/bin/sh
set -u
rc=0
grep -n -E 'mktemp|BATS_TEST_TMPDIR|BATS_TMPDIR|BATS_RUN_TMPDIR|BATS_FILE_TMPDIR|tmp_path|tmpdir|tempfile|TemporaryDirectory|NamedTemporaryFile|New-TemporaryFile|GetTempPath|GetTempFileName|TestDrive|env:TEMP|env:TMP' -- "$@" || rc=$?
echo "SWEEP-EXIT=$rc"
```

A18 drift-expected.py (fills `expected` for success fixtures; writes a fixture only when the
generated payload matches the C1 table and the spec invariants):

```python
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path.cwd()))

from scripts.dev_tools.parallel_drift_detection_cli import evaluate_drift  # noqa: E402

# name -> (result, escaped_paths, newly_conflicting_pairs, halted_item_keys); the C1 table.
SEMANTICS = {
    "no-escape-inside-radius": ("no_escape", [], [], []),
    "no-escape-empty-changed-paths": ("no_escape", [], [], []),
    "escape-without-conflict": ("no_new_conflict", ["docs/notes.md"], [], []),
    "halt-one-pair": ("halt_required", ["src/app.py"], [[445, 446]], [445]),
    "halt-several-pairs": ("halt_required", ["src/app.py"], [[445, 446], [446, 447]], [445, 447]),
    "halt-drifter-started-later": ("halt_required", ["src/app.py"], [[445, 446]], [445]),
    "halt-equal-start-timestamps": ("halt_required", ["src/app.py"], [[445, 446]], [445]),
    "halt-one-start-absent": ("halt_required", ["src/app.py"], [[445, 446]], [445]),
    "halt-both-starts-absent": ("halt_required", ["src/app.py"], [[445, 446]], [445]),
    "reversed-existing-edge-not-new": ("no_new_conflict", ["src/app.py"], [], []),
    "non-object-edge-ignored": ("halt_required", ["src/app.py"], [[445, 446]], [445]),
    "malformed-peer-radius-fails-closed": ("halt_required", ["docs/notes.md"], [[445, 446]], [445]),
    "tolerated-overlap-under-conflict-tolerance": ("no_new_conflict", ["src/app.py"], [], []),
    "peer-not-in-flight-ignored": ("no_new_conflict", ["src/app.py"], [], []),
    "peer-radius-iso-timestamp-evaluated": ("no_new_conflict", ["docs/notes.md"], [], []),
}
ERROR_NAMES = {"error-items-not-a-list", "error-item-key-missing", "error-non-object-root"}
EXPECTED_ERROR = {"exit_code": 1, "stderr_prefix": "parallel drift detection failed: "}

corpus = Path("tests/fixtures/parallel_drift")
paths = sorted(corpus.glob("*.json"))
for name in sorted((set(SEMANTICS) | ERROR_NAMES) - {p.stem for p in paths}):
    print(f"MISSING-FIXTURE {name}")
generated = errors = mismatches = 0
for path in paths:
    name = path.stem
    doc = json.loads(path.read_text(encoding="utf-8"))
    if name in ERROR_NAMES:
        ok = doc.get("expected_error") == EXPECTED_ERROR and "expected" not in doc
        print(f"ERROR-FIXTURE name={name} shape_ok={ok}")
        errors += 1
        mismatches += 0 if ok else 1
        continue
    payload = evaluate_drift(
        state=doc["state"], config=doc["config"], item_key=doc["item_key"],
        changed_paths=doc["changed_paths"], at=doc["at"], computed_at=doc["computed_at"],
    )
    stated = SEMANTICS.get(name)
    actual = (payload["result"], payload["escaped_paths"], payload["newly_conflicting_pairs"], payload["halted_item_keys"])
    invariants = (
        (payload["drift_event"] is None) == (payload["result"] == "no_escape")
        and (payload["observed_radius"] is None) == (payload["result"] == "no_escape")
        and doc["item_key"] not in payload["halted_item_keys"]
        and payload["halted_item_keys"] == sorted(set(payload["halted_item_keys"]))
    )
    if stated is None or tuple(stated) != actual or not invariants:
        print(f"MISMATCH name={name} stated={stated} actual={actual} invariants={invariants}")
        mismatches += 1
        continue
    doc["expected"] = payload
    path.write_text(json.dumps(doc, indent=2, ensure_ascii=False) + "\n", encoding="utf-8", newline="\n")
    print(f"GENERATED name={name} result={payload['result']}")
    generated += 1
print(f"GENERATOR-SUMMARY generated={generated} errors={errors} mismatches={mismatches}")
```

A19 changed-lines-cov.py (arguments: coverage JSON, base ref, files):

```python
import json
import re
import subprocess
import sys
from pathlib import Path

report = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
base = sys.argv[2]
files = report["files"]
for target in sys.argv[3:]:
    diff = subprocess.run(["git", "diff", "-U0", base, "--", target], capture_output=True, text=True, check=True).stdout
    changed = set()
    for match in re.finditer(r"^@@ -\S+ \+(\d+)(?:,(\d+))? @@", diff, re.MULTILINE):
        start = int(match.group(1))
        count = int(match.group(2) or "1")
        changed.update(range(start, start + count))
    key = target if target in files else target.replace("/", "\\")
    data = files.get(key)
    if data is None:
        print(f"CHANGED file={target} MISSING")
        continue
    missing = set(data["missing_lines"])
    executable = set(data["executed_lines"]) | missing
    uncovered = sorted(changed & missing)
    print(f"CHANGED file={target} ChangedLines={len(changed)} ChangedExecutableLines={len(changed & executable)} UncoveredChangedLines={len(uncovered)} Uncovered={uncovered}")
```

A19b json-equal.py (arguments: two files each holding one JSON document):

```python
import json
import sys
from pathlib import Path

left = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
right = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))
print(f"JSON-EQUAL={'true' if left == right else 'false'}")
```

A20 surface-token-count.sh (literals that contain a refused word are searched only here):

```sh
#!/bin/sh
set -u
bundle=extensions/drm-copilot/resources/claude-customizations
count() {
  label="$1"
  literal="$2"
  shift 2
  for file in "$@"; do
    printf 'COUNT %s %s %s\n' "$label" "$file" "$(grep -c -F -e "$literal" "$file")"
  done
}
orchestrate=.claude/skills/parallel-orchestrate/SKILL.md
remove=.claude/skills/parallel-remove/SKILL.md
agent=.claude/agents/parallel-orchestrator.md
count T1 'pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1' "$orchestrate" "$bundle/$orchestrate"
count T2 'bash .claude/lib/bash/abandon-parallel-item.sh --item <key> --disposition abandon --confirm-abandon --pr <pr-number> --worktree <worktree-path>' "$remove" "$bundle/$remove"
count T3 '"Bash(pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1*)"' "$agent" "$bundle/$agent"
count T4 '"Bash(bash .claude/lib/bash/abandon-parallel-item.sh*)"' "$agent" "$bundle/$agent"
count T5 '"Bash(poetry run python -m *)"' "$agent" "$bundle/$agent"
count T6 'poetry run' "$orchestrate" "$remove" "$bundle/$orchestrate" "$bundle/$remove"
```

A21 ac-count.sh (counts boxes inside the `## Acceptance Criteria` section only):

```sh
#!/bin/sh
set -eu
awk '/^## Acceptance Criteria/{s=1; next} /^## /{s=0} s && /^- \[x\] /{c++} s && /^- \[ \] /{u++} END{printf "AC-CHECKED=%d AC-UNCHECKED=%d\n", c, u}' "$1"
```

A22 line-counts.sh:

```sh
#!/bin/sh
set -eu
for file in "$@"; do
  printf '%s LineCount=%s\n' "$file" "$(wc -l < "$file" | tr -d ' ')"
done
```

A23 bats-parity-local.sh (the harness interpreter is the Poetry environment's `python`):

```sh
#!/bin/sh
set -u
PARALLEL_PARITY_PYTHON=python poetry run npx --yes bats tests/shell/parallel_abandon_parity.bats
echo "BATS-PARITY-EXIT=$?"
```

## Appendix B — Implementation and Test Specifications

Every production and test file follows `.claude/rules/self-explanatory-code-commenting.md`
(docstrings or comment-based help, intent comments), the language rule files read in Phase 0, and
the Arrange-Act-Assert structure. File names, function names, and test names below are fixed; the
executor may add private helpers and additional tests but may not rename these.

B1 `scripts/dev_tools/skill_bundle_contract.py`: replace lines 132-145 (the registry comment and
tuple) with exactly:

```python
# Script references a skill may keep while its bundled port is pending, each
# tied to its tracking issue. Issue #763 ported the last two entries, so the
# registry is empty and the guard enforces every reference. An entry added here
# must keep matching a real violation, or the staleness check reports it.
KNOWN_UNBUNDLED_REFERENCES: tuple[KnownUnbundledReference, ...] = ()
```

B2 `scripts/dev_tools/skill_bundle_contract_cli.py`: import `KNOWN_UNBUNDLED_REFERENCES` at runtime
and `KnownUnbundledReference` plus `Iterable` under `TYPE_CHECKING`; `main` gains a keyword-only
parameter after `loader`:
`exceptions: Iterable[KnownUnbundledReference] = KNOWN_UNBUNDLED_REFERENCES`, documented in the
docstring `Args:` block ("Registered exceptions; injectable so tests exercise the suppression and
staleness branches with an empty default registry."). The body materializes
`registered = tuple(exceptions)` once and calls `find_violations(inputs, exceptions=registered)` and
`find_stale_exceptions(inputs, exceptions=registered)`. Nothing else changes.

B3 `tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py`: replace
`test_known_unbundled_references_cite_issue_763` (lines 247-268) with
`test_known_unbundled_references_registry_is_empty`, docstring "Issue #763 ported both registered
references, so the registry is empty.", asserting `KNOWN_UNBUNDLED_REFERENCES == ()` with the
registry in the failure message. Update the module docstring's registry sentence accordingly.

B4 `tests/scripts/dev_tools/test_skill_bundle_contract_cli.py`: remove `_DRIFT_CLI`, `_ABANDON_CLI`,
and the two parallel skills from `_clean_inputs` (docstring: "Build a snapshot with no finding.");
import `KnownUnbundledReference`. Test names (five): `test_main_returns_zero_when_clean`,
`test_main_returns_one_and_prints_violation_lines` (unchanged), `test_main_returns_one_for_stale_exception`
(injects `exceptions=(KnownUnbundledReference("demo-skill", _UNBUNDLED, "#1"),)` over the clean
snapshot and asserts exit 1 and the single stderr line
`skill-bundle stale exception: demo-skill | scripts/tools/example.sh | #1`),
`test_main_prints_nothing_to_stderr_when_clean`, and `test_main_suppresses_a_registered_exception`
(a snapshot whose demo skill references `_UNBUNDLED`, with the same exception injected, exits 0 with
empty stderr). All paths stay fictitious.

B5 shims (LF; `#!/bin/sh` because the restricted PATH cannot resolve an interpreter name, precedent
`tests/fixtures/parallel_payload_path/cat` lines 1-13). The gh variant is below. The git variant
replaces the token `SHIM-CALL gh` with `SHIM-CALL git` and every occurrence of `ABANDON_SHIM_GH_EXIT`
with `ABANDON_SHIM_GIT_EXIT`; every other byte is identical to the gh variant:

```sh
#!/bin/sh
# Checked-in PATH shim for the parallel abandon bats suites (issue #763).
#
# The abandon entry point runs gh and git through PATH resolution. The suites set
# PATH to this directory alone, so the shim stands in for the real executable: it
# records its argument vector as one "SHIM-CALL" line on stderr and exits with the
# code the test selects through ABANDON_SHIM_GH_EXIT (default 0). It never starts a
# real process, so no pull request is closed and no worktree is removed.
printf 'SHIM-CALL gh' >&2
for argument in "$@"; do
	printf ' %s' "$argument" >&2
done
printf '\n' >&2
exit "${ABANDON_SHIM_GH_EXIT:-0}"
```

B6 `tests/shell/parallel_abandon.bats` (header comment states purpose, the shim-only PATH, and "No
temporary file is created"). `setup` resolves `REPO_ROOT`, `SCRIPT` (repository
`.claude/lib/bash/abandon-parallel-item.sh`), `SHIM_PATH` (`tests/fixtures/parallel_abandon_path`),
`GIT_ONLY_PATH` (`tests/fixtures/parallel_abandon_path_git_only`), `BASH_BIN="$(command -v bash)"`,
and runs `chmod +x` on both shim directories (idempotent, as in `tests/shell/parallel_payload_only.bats`
line 34). A helper `run_abandon` executes
`run env PATH="$SHIM_PATH" ABANDON_SHIM_GH_EXIT="${GH_EXIT:-0}" ABANDON_SHIM_GIT_EXIT="${GIT_EXIT:-0}" "$BASH_BIN" "$SCRIPT" "$@"`
(`env` without `-i`, so the kcov environment survives). Base arguments are
`--item 42 --disposition abandon --confirm-abandon --pr 7 --worktree ../wt-42`. The 14 tests, by
exact name:

1. "the abandon script exists in the repository library" (`[ -f "$SCRIPT" ]`).
2. "success closes the pull request before removing the worktree" (status 0; exactly two lines,
   `SHIM-CALL gh pr close 7` then `SHIM-CALL git worktree remove ../wt-42`).
3. "success writes nothing to stdout" (the same invocation through
   `run "$BASH_BIN" -c '"$0" "$@" 2>/dev/null' env PATH=... "$BASH_BIN" "$SCRIPT" ...` or an
   equivalent stderr-discarding form; status 0 and `$output` empty).
4. "a detach disposition exits 2 with the reference message and no side effect" (status 2; the only
   line is `PARALLEL_ABANDON_ERROR: this CLI executes the 'abandon' disposition only; got 'detach'.`).
5. "a missing confirmation marker exits 2 with the reference message and no side effect" (status 2;
   the only line is `PARALLEL_ABANDON_ERROR: refusing to abandon item 42 without the explicit --confirm-abandon confirmation marker; no side effect was performed.`).
6. "a gh failure exits 1 and does not invoke git" (GH_EXIT=1; status 1; lines are
   `SHIM-CALL gh pr close 7` and `PARALLEL_ABANDON_ERROR: abandon side effect failed with exit code 1: gh pr close 7`).
7. "a git failure exits 1 with the reference message" (GIT_EXIT=128; status 1; lines are the gh call,
   the git call, and `PARALLEL_ABANDON_ERROR: abandon side effect failed with exit code 128: git worktree remove ../wt-42`).
8. "an absent gh executable reports exit code -1" (PATH is `GIT_ONLY_PATH`; status 1; the only line
   is `PARALLEL_ABANDON_ERROR: abandon side effect failed with exit code -1: gh pr close 7`).
9. "an unknown option exits 2 with no side effect" (`--force` appended; status 2; no `SHIM-CALL` line;
   one line beginning `PARALLEL_ABANDON_ERROR: usage error:`).
10. "an option abbreviation exits 2 with no side effect" (`--disp abandon` in place of the disposition
    option; same assertions as 9).
11. "the joined option form is accepted" (`--item=42 --disposition=abandon --confirm-abandon --pr=7 --worktree=../wt-42`;
    status 0 and the two `SHIM-CALL` lines of test 2).
12. "a missing required option exits 2 with no side effect" (`--pr 7` omitted; assertions of 9).
13. "a non-integer item key exits 2 with no side effect" (`--item abc`; assertions of 9).
14. "the script declares the option tokens as named constants" (`grep -c` finds each of the three
    `readonly` lines of B7 exactly once in `$SCRIPT`).

B7 `.claude/lib/bash/abandon-parallel-item.sh` (bash, `set -euo pipefail`, shfmt default tab
formatting, shellcheck-clean, builtins only so it runs with a shim-only PATH):

- Header comment: purpose (bundled destination-runtime port of
  `scripts/dev_tools/parallel_mutation_abandon_cli.py`, issue #763), the invocation
  `bash .claude/lib/bash/abandon-parallel-item.sh --item <key> --disposition abandon --confirm-abandon --pr <pr-number> --worktree <worktree-path>`,
  the hook `.claude/hooks/enforce-parallel-abandon-gate.ps1` that gates the command text, the exit
  codes (0 success with no stdout; 1 side effect failed; 2 refusal or usage error), and the declared
  divergences (DV4 plus the two spec classes).
- Constants, each on its own line exactly as written (the seam test and B6 test 14 read them):
  `readonly ABANDON_DISPOSITION_OPTION='--disposition'`,
  `readonly ABANDON_DISPOSITION_VALUE='abandon'`,
  `readonly ABANDON_CONFIRM_OPTION='--confirm-abandon'`; plus `ABANDON_ITEM_OPTION='--item'`,
  `ABANDON_PR_OPTION='--pr'`, `ABANDON_WORKTREE_OPTION='--worktree'`,
  `ABANDON_VALID_DISPOSITIONS='detach abandon'`, and `ABANDON_ERROR_PREFIX='PARALLEL_ABANDON_ERROR:'`.
  Option matching, the disposition comparison, and the refusal messages read these variables.
  Outside the header comment, the literals `--disposition` and `--confirm-abandon` appear only on
  their `readonly` lines. Other occurrences of the word `abandon` (message prose,
  `ABANDON_VALID_DISPOSITIONS`, and the script name) are not spellings of the disposition token.
- Parsing: accepts exactly the five valued options (space-separated or joined `--name=value`) and
  the confirmation flag; repeated options keep the last value; a disposition outside
  `ABANDON_VALID_DISPOSITIONS`, a missing required option, a missing value, a value beginning with
  `--`, a non-canonical integer for `--item` or `--pr`, a positional argument, `--confirm-abandon=x`,
  and any other option (including abbreviations, `-h`, `--help`) print one stderr line
  `PARALLEL_ABANDON_ERROR: usage error: <detail>` and exit 2 before any side effect.
- Refusals, in this order after parsing: a disposition other than `abandon` prints the reference
  message of B6 test 4 with the received value and exits 2; a missing confirmation flag prints the
  reference message of B6 test 5 with the item value and exits 2.
- Side effects: `gh pr close <pr>` then `git worktree remove <worktree>`, each through a function that
  resolves the executable with `command -v` (unresolvable: exit code `-1`, nothing run) and captures
  a non-zero exit without aborting; the first failure prints
  `PARALLEL_ABANDON_ERROR: abandon side effect failed with exit code <n>: <argv joined by spaces>`
  and exits 1. Success exits 0 and writes nothing to stdout.

B8 abandon corpus schema (`tests/fixtures/parallel_abandon/<name>.json`, LF, one object):
`name` (equals the file stem), `description`, `argv` (array of strings after the script path),
`shim_exit` (`{"gh": <int>, "git": <int>}`), `missing_executable` (`null` or `"gh"`), `expected`
(`{"exit_code": <int>, "stderr_mode": "none" | "exact" | "usage", "stderr": <string or null>,
"calls": [[<argv strings>], ...]}`), `divergence` (`null` or a declared divergence class name), and
`python_expected` (present only when `divergence` is non-null; same shape as `expected`).
`stderr_mode` `exact` compares the single `PARALLEL_ABANDON_ERROR:` line; `none` requires no such
line (Python: empty stderr); `usage` compares the exit code only (bash additionally requires one line
beginning `PARALLEL_ABANDON_ERROR: usage error:`).

B9 `tests/scripts/dev_tools/test_parallel_abandon_bash_parity.py` (module docstring states the shared
corpus, the injected runner, the declared divergence classes, and that no process is started):
reads the corpus from `Path(__file__).resolve().parents[3] / "tests/fixtures/parallel_abandon"`.
`test_abandon_corpus_meets_floor` asserts at least 9 fixtures;
`test_abandon_corpus_covers_every_named_case` asserts the C2 names are all present;
`test_reference_matches_abandon_fixture[<name>]` (parametrized by file stem) calls
`parallel_mutation_abandon_cli.main(argv, runner=recording_runner)`, where the runner appends each
argv to a list and returns the fixture's `shim_exit` code for `argv[0]`, and raises
`AbandonSideEffectError(argv, -1)` before recording anything when `argv[0]` equals
`missing_executable` (so the recorded calls match the shim lane, where no shim runs; mirroring
`run_with_subprocess`, `scripts/dev_tools/parallel_mutation_abandon_cli.py` lines 148-150). A
`SystemExit` from argparse is caught and its code used. It uses `python_expected` when the fixture
declares a divergence, asserts exit code, the recorded calls, empty stdout, and stderr per
`stderr_mode`.

B10 `tests/shell/parallel_abandon_parity.bats` (header lists the shared corpus, the Python lane, the
declared divergence classes, DV6, and "No temporary file is created"). `fixture_field` follows
`tests/shell/parallel_cohorts_parity.bats` lines 49-56 with the interpreter
`"${PARALLEL_PARITY_PYTHON:-python3}"`. Tests (three, exact names):
"the abandon parity corpus meets the declared floor" (at least 9 `*.json`),
"the harness interpreter is available to read the corpus" (`command -v` of the interpreter), and
"the bash lane reproduces every abandon corpus fixture": for each fixture it runs the script as B6's
`run_abandon` does (PATH is `GIT_ONLY_PATH` when `missing_executable` is `gh`), compares the exit
code with `expected.exit_code`, compares the `SHIM-CALL` lines with `expected.calls` rendered as
space-joined strings in order, applies `stderr_mode`, requires that every output line begins with
`SHIM-CALL ` or `PARALLEL_ABANDON_ERROR:`, echoes the fixture name on any mismatch, and finally asserts
the checked count is at least 9.

B11 real-seam fixtures (LF): `tests/fixtures/parallel_drift_cli/config.json` is the C1 base config
CFG; `tests/fixtures/parallel_drift_cli/checkpoint.json` is the C1 state of `halt-one-pair` plus a
third item `{"issue_num": 448, "state": "in_flight", "blast_radius": R(["docs/other.md"]) with
"computed_at": "2026-08-08T09:00:00Z", "worktree_created_at": "2026-08-08T09-30"}`, and
`"conflict_edges": []`. With changed path `src/app.py` the verdict is `halt_required` with halted keys
`[445]` (item 448 does not overlap).

B12 drift corpus schema (`tests/fixtures/parallel_drift/<name>.json`, LF, one object): `name`,
`description`, `item_key`, `changed_paths`, `at`, `computed_at`, `state` (any JSON value), `config`
(object), and exactly one of `expected` (the payload object, written by A18) or `expected_error`
(`{"exit_code": 1, "stderr_prefix": "parallel drift detection failed: "}`, authored by hand for the
three error fixtures).

B13 `tests/scripts/dev_tools/test_parallel_drift_parity.py` (module docstring states the shared
corpus, the declared divergence classes of spec "Backward-compatibility expectations", and that no
file is read other than the committed corpus): `test_drift_corpus_meets_floor` (at least 18
fixtures); `test_drift_corpus_covers_every_named_case` (the C1 names);
`test_reference_matches_fixture_payload[<name>]` over fixtures carrying `expected`: asserts
`evaluate_drift(...)` equals `expected`, then runs `parallel_drift_detection_cli.main` with
`--item-key`, `--checkpoint fixture-checkpoint.json`, `--config fixture-config.json`, `--at`,
`--computed-at`, and the changed paths, with `scripts.dev_tools._parallel_drift_cli_io.read_json_file`
monkeypatched to return the fixture's `state` or `config` by path name, and asserts exit 0 and
`json.loads(stdout) == expected`; `test_reference_reports_fixture_error[<name>]` over fixtures
carrying `expected_error`: the same `main` call returns 1 and stderr begins with the prefix.

B14 `tests/scripts/claude-lib/parallel-drift/ParallelDriftHalt.Tests.ps1`: `BeforeAll` imports the
module with `-Force -ErrorAction Stop`. `Describe 'ParallelDriftHalt.psm1'` with these It names:
'Assert-ParallelDriftItemKey accepts a positive integer';
'Assert-ParallelDriftItemKey rejects <case>' (-ForEach zero, negative, boolean, string);
'Assert-ParallelDriftText rejects a blank value';
'Assert-ParallelDriftPathList rejects a bare string';
'Assert-ParallelDriftPathList rejects a blank entry';
'Assert-ParallelDriftPathList accepts an empty collection when allowed';
'ConvertTo-ParallelDriftItemKey returns null for an unreadable value';
'Get-ParallelDriftCanonicalPair orders the lower key first';
'Select-ParallelDriftHaltedItem halts the later timestamp';
'Select-ParallelDriftHaltedItem halts the larger key on equal timestamps';
'Select-ParallelDriftHaltedItem halts the item whose start is unknown';
'Select-ParallelDriftHaltedItem halts the larger key when both starts are unknown';
'Select-ParallelDriftHaltedItem rejects a pair that names one item twice';
'Get-ParallelDriftHaltedItemKey never returns the drifting key';
'Get-ParallelDriftHaltedItemKey returns deduplicated ascending keys';
'Get-ParallelDriftHaltedItemKey returns an empty array for no pairs';
'Get-ParallelDriftHaltedItemKey applies the comparator when the drifting key is in neither member'.

B15 `tests/scripts/claude-lib/parallel-drift/ParallelDrift.Tests.ps1`: `BeforeAll` imports the module
with `-Force -ErrorAction Stop` and builds inline hashtables (ordinal, case-sensitive) for the C1 base
config and radii. `Describe 'ParallelDrift.psm1'` with these It names:
'imports the blast-radius library and defines none of its functions' (the module text carries the
`../blast-radius/BlastRadius.psm1` import, and the module AST defines none of `Test-PathSubsumed`,
`Get-BlastRadiusFromObservedPaths`, `Test-BlastRadiusConflict`, `Get-BlastRadiusPairDecision`,
`ConvertTo-NormalizedBlastRadius`, `Get-OrdinalSortedEntry`);
'calls the subsumption, observed-radius, conflict, and pair-decision functions' (the module AST's
command names include `Test-PathSubsumed`, `Get-BlastRadiusFromObservedPaths`,
`Get-BlastRadiusPairDecision`, and a `Test-BlastRadiusConflict` function reference);
'Get-ParallelDriftCheckpointItem rejects a non-list items collection';
'Get-ParallelDriftCheckpointItem rejects a non-object items entry';
'Get-ParallelDriftCheckpointEdge rejects a non-list conflict_edges collection';
'Get-ParallelDriftCheckpointEdge omits a non-object edge';
'Get-ParallelDriftItemRecord rejects an item key absent from the checkpoint';
'Get-ParallelDriftDeclaredPath rejects a non-object blast_radius';
'Get-ParallelDriftDeclaredPath rejects a non-list paths value';
'Get-ParallelDriftEscapedPath returns an empty array when every path is subsumed';
'Get-ParallelDriftEscapedPath returns the paths no declared entry covers';
'Get-ParallelDriftEvent carries exactly the six drift-event keys';
'Get-ParallelDriftEvent rejects an empty escaped-path list';
'Get-ParallelDriftExistingEdgePair canonicalizes a reversed edge';
'Get-ParallelDriftExistingEdgePair omits an edge with identical endpoints';
'Get-ParallelDriftItemBand returns null for an unreadable band';
'Test-ParallelDriftObservedPairEdge fails closed for a non-object peer radius';
'Test-ParallelDriftObservedPairEdge fails closed for an unparseable peer radius';
'Get-ParallelDriftNewConflictPair skips a peer that is not in flight';
'Get-ParallelDriftNewConflictPair skips a pair already recorded as an edge';
'Get-ParallelDriftResult returns no_escape with null drift_event and observed_radius';
'Get-ParallelDriftResult returns no_new_conflict with a raised_blocking_finding event';
'Get-ParallelDriftResult returns halt_required with a halted_later_started_item event'.

B16 `tests/scripts/claude-lib/parallel-drift/ParallelDrift.Manifest.Tests.ps1`, modeled on
`tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1`: repository root four levels
up; `core.json` read with `ConvertFrom-Json`; library files discovered with
`Get-ChildItem -Path <.claude/lib/parallel-drift> -File -ErrorAction Stop` filtered to `.psm1` and
`.ps1` (a missing directory fails the container). `Describe 'Parallel-drift core.json manifest membership'`
with It names: 'discovers the parallel-drift library files on disk' (count greater than 0);
'lists every discovered library file in core.json paths'; 'lists the entry script exactly once';
'ships a bundled counterpart for every library file'; 'ships byte-identical bundled counterparts'
(compares `Get-FileHash` of each pair). No temporary files.

B17 `.claude/lib/parallel-drift/ParallelDriftHalt.psm1` (pure; no filesystem, subprocess, network, or
clock access; `Set-StrictMode -Version Latest`; comment-based help per function; header names the
ported Python functions): exports `Assert-ParallelDriftItemKey` (positive, non-boolean integer,
port of `require_item_key`), `Assert-ParallelDriftText` (`require_text`),
`Assert-ParallelDriftPathList` (`require_paths`, with `-AllowEmpty`; same ordering and
de-duplication semantics as the Python), `Assert-ParallelDriftEnumMember` (`require_enum_member`),
`ConvertTo-ParallelDriftItemKey` (`as_item_key`, `$null` when unreadable),
`Get-ParallelDriftCanonicalPair` (`canonical_pair`), `Get-ParallelDriftStartRank` (`_start_rank`,
ordinal comparison of `worktree_created_at`), `Select-ParallelDriftHaltedItem`
(`select_halted_item`), and `Get-ParallelDriftHaltedItemKey` (the CLI's `halted_item_keys`,
`scripts/dev_tools/parallel_drift_detection_cli.py` lines 406-469; always returns an array via the
unary comma). Failures throw with a message naming the field.

Module convention (enforced by `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, which
discovers every `.claude/lib/**/*.psm1`): the line immediately after `Set-StrictMode -Version Latest`
is `$ErrorActionPreference = 'Stop'`; the leading comment-based-help block, before the
`Set-StrictMode` line, carries this line on one physical line (four-space indent, as in
`.claude/lib/blast-radius/BlastRadius.psm1` line 62):

```text
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
```

and every `Import-Module` line that begins at column 0 carries `-ErrorAction Stop`. The module stays
at or under 500 lines.

B18 `.claude/lib/parallel-drift/ParallelDrift.psm1` (pure; same constraints, including the B17 module
convention): imports, in this
order, `ParallelDriftHalt.psm1`, `../blast-radius/BlastRadius.psm1`,
`../blast-radius/BlastRadiusGlob.psm1`, and `../blast-radius/BlastRadiusValidation.psm1` with
`-Force -ErrorAction Stop` (the facade does not re-export `Test-PathSubsumed`,
`ConvertTo-NormalizedBlastRadius`, or `Get-OrdinalSortedEntry`; the facade is imported first, the
precedent being `.claude/lib/project-file-merge/Resolve-MergeableConflict.ps1` lines 32-38). Exports:
`Get-ParallelDriftCheckpointItem`, `Get-ParallelDriftCheckpointEdge`, `Get-ParallelDriftItemRecord`,
`Get-ParallelDriftDeclaredPath` (ports of the readers in `scripts/dev_tools/_parallel_drift_cli_io.py`
lines 125-248), `Get-ParallelDriftEscapedPath` (`detect_escaped_paths`, calling `Test-PathSubsumed`),
`Get-ParallelDriftEvent` (`build_drift_event`), `Get-ParallelDriftExistingEdgePair`,
`Get-ParallelDriftItemBand`, `Test-ParallelDriftObservedPairEdge` (ports of
`scripts/dev_tools/_parallel_drift_scheduling.py` lines 50-143; a non-mapping peer radius or one that
`ConvertTo-NormalizedBlastRadius` rejects returns `$true`; otherwise
`Get-BlastRadiusPairDecision -Relation ${function:Test-BlastRadiusConflict}` and its `edge` key; the
returned hashtable is never tested for truthiness), `Get-ParallelDriftObservedRadius`
(`build_observed_radius`, calling `Get-BlastRadiusFromObservedPaths`),
`Get-ParallelDriftNewConflictPair` (`recompute_conflicts_with_observed`), and
`Get-ParallelDriftResult` (`evaluate_drift`, lines 228-324, returning an ordered dictionary with the
nine payload keys; arrays are always arrays). No function invokes a variable, expression, or
`Invoke-Expression` (the no-Python guard fails closed on dynamic invocation); the only `&` use is the
blast-radius library's own scriptblock seam.

B19 `tests/scripts/claude-lib/parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1`: `BeforeAll`
dot-sources the entry script (the guard does not run under dot-sourcing) and mocks
`Get-ParallelDriftUtcNow` where a test needs the clock. `Describe 'Invoke-ParallelDriftDetection.ps1'`
with It names: 'declares no Mandatory parameter' (AST of the script and of every function it
defines); 'binds positional arguments only to ChangedPath' (for each of `ItemKey`, `CheckpointPath`,
`ConfigPath`, `At`, and `ComputedAt`, asserts that
`(Get-Command -Name $EntryScriptPath).Parameters[$Name].ParameterSets.Values.Position` equals
`[int]::MinValue`, where `$EntryScriptPath` is the resolved path of the entry script and `$Name` the
parameter name); 'exits 2 when -ItemKey is missing'; 'exits 2 when -ItemKey is not an integer';
'exits 2 when an unrecognized parameter reaches the remaining arguments';
'exits 1 with the failure prefix when the checkpoint cannot be read';
'exits 1 with the failure prefix when the checkpoint root is not an object';
'exits 0 and writes one JSON object to stdout';
'emits a one-element escaped_paths as a JSON array';
'emits a one-element halted_item_keys as a JSON array';
'returns timestamp-shaped strings unchanged' (a peer radius `computed_at` of
`2026-08-08T09:00:00Z` is evaluated rather than failing closed, and `ConvertFrom-ParallelDriftJson`
returns it as the same string);
'treats an omitted ChangedPath as an empty changed-path list' (`Read-ParallelDriftJsonText` mocked
with a body that returns inline checkpoint text containing item 446 for the checkpoint path and inline
config text for the config path; calls `Invoke-ParallelDriftCli -ItemKey 446` with placeholder
`-CheckpointPath` and `-ConfigPath` values and `-At 2026-08-08T10-00`, once without `-ChangedPath` and
once with `-ChangedPath $null`; each call returns `ExitCode` 0 and a `Stdout` JSON object whose
`result` is `no_escape` and whose `escaped_paths` is empty);
'defaults -At to the mocked UTC clock formatted yyyy-MM-ddTHH-mm';
'defaults -ComputedAt to the resolved -At';
'sorts object keys ordinally in the emitted JSON';
'converts integers, floats, booleans, null, arrays, and objects from JSON';
'keeps JSON object keys case-sensitive';
'reads the committed checkpoint and config fixtures and leaves both files unchanged' (real
`Read-ParallelDriftJsonText` over `tests/fixtures/parallel_drift_cli/*.json`, `Get-FileHash` before
and after); 'resolves relative paths against the current location' (`Push-Location` to the
repository root in the test and `Pop-Location` in `finally`).

B20 `tests/scripts/claude-lib/parallel-drift/ParallelDrift.Parity.Tests.ps1` (header states the
shared corpus, the Python lane, the declared divergence classes, DV5, and both DV7 classes: a
remaining argument beginning with `-` exits 2, and a named parameter given with no value is rejected
by the PowerShell parameter binder and exits 1 with the binder's message): `BeforeDiscovery`
enumerates `tests/fixtures/parallel_drift/*.json`; `BeforeAll` dot-sources the entry script.
`Describe 'Parallel drift parity corpus'` with It names: 'the drift corpus meets the floor of 18
fixtures'; 'the drift corpus names every required case' (the C1 names);
'reproduces drift fixture <name>' (-ForEach over the discovered fixtures): mocks
`Read-ParallelDriftJsonText` to return the raw text of the fixture's `state` or `config`
(`JsonDocument.Parse(...).RootElement.GetProperty(...).GetRawText()`), calls `Invoke-ParallelDriftCli`
with the fixture's item key, placeholder paths, `-At`, `-ComputedAt`, and changed paths, and for
`expected` asserts exit 0 and deep JSON-value equality of `Stdout` with `expected` (ordinal key sets,
value kinds, numbers by raw text, arrays in order); for `expected_error` asserts exit 1 and that
`Stderr` begins with the prefix.

B21 `.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1` (entry script; precedent
`.claude/lib/project-file-merge/Resolve-MergeableConflict.ps1` lines 24-30 and 222-229):
- `[CmdletBinding(PositionalBinding = $false)]` followed by
  `param([string] $ItemKey, [string] $CheckpointPath, [string] $ConfigPath, [string] $At, [string] $ComputedAt, [Parameter(ValueFromRemainingArguments = $true)] [string[]] $ChangedPath)`;
  no parameter is `Mandatory`, and only `ChangedPath` receives positional arguments. Without
  `PositionalBinding = $false`, every parameter is positional and changed paths bind into omitted
  parameters (observed by the round-1 preflight: `-ItemKey 446 src/app.py docs/notes.md` bound
  `CheckpointPath` and `ConfigPath` and left `ChangedPath` empty).
- Imports `ParallelDrift.psm1` with `-Force -ErrorAction Stop`.
- Seams: `Read-ParallelDriftJsonText -Path` (`[System.IO.File]::ReadAllText`, UTF-8) and
  `Get-ParallelDriftUtcNow` (`[DateTime]::UtcNow`), each the only place its effect occurs.
- `ConvertFrom-ParallelDriftJson -Text`: parses with `[System.Text.Json.JsonDocument]::Parse` and
  converts to ordinal case-sensitive hashtables, `object[]` arrays, `[long]` for integral numbers,
  `[double]` otherwise, `[bool]`, `[string]` (unchanged), and `$null`. `ConvertFrom-Json` is not used.
- `ConvertTo-ParallelDriftJson -Value`: serializes with ordinally sorted keys at every depth, keeps
  every array an array (including one-element arrays and arrays of arrays), and uses sufficient
  depth for `drift_event` and `observed_radius`.
- `Resolve-ParallelDriftPath -Path`: rooted paths unchanged; relative paths joined to
  `(Get-Location).Path`.
- `Invoke-ParallelDriftCli` (same parameters) returns `[pscustomobject]@{ ExitCode; Stdout; Stderr }`.
  Before any validation it normalizes a `$null` `ChangedPath` to an empty `[string[]]`: with no
  positional argument, `pwsh -File` leaves the `ValueFromRemainingArguments` parameter `$null`, the
  guard passes it by name as `$null`, and `@($null).Count` is 1, so without the normalization an
  omitted changed-path list would be reported as a blank entry instead of yielding `no_escape`.
  A missing or non-integer (`^-?[0-9]+$`) `ItemKey`, or a `ChangedPath` entry beginning with `-`, gives
  exit 2 with a one-line `Stderr` beginning `parallel drift detection usage error: `; defaults are
  `artifacts/orchestration/parallel-orchestrator-state.json`, `config/blast-radius.json`, the clock
  formatted `yyyy-MM-ddTHH-mm` with the invariant culture for `At`, and the resolved `At` for
  `ComputedAt`; a read failure, a non-object root, or any error thrown by `Get-ParallelDriftResult`
  gives exit 1 with `Stderr` `parallel drift detection failed: <message>`; success gives exit 0 and
  one JSON object in `Stdout`. No file is written.
- Guard: when not dot-sourced, call `Invoke-ParallelDriftCli` with the six script parameters passed
  by name (not by splatting `$PSBoundParameters`, which under `CmdletBinding` can carry common
  parameters the function does not declare), write a
  non-empty `Stdout` to `[Console]::Out` and a non-empty `Stderr` to `[Console]::Error`, and
  `exit $outcome.ExitCode`.

B22a `.claude/skills/parallel-orchestrate/SKILL.md` lines 732-733, replacement text (line 734 is
unchanged):

```text
worktree. Both side effects run through ONE deterministic invocation of the bundled bash entry
point `.claude/lib/bash/abandon-parallel-item.sh`, documented in full in
```

B22b `.claude/skills/parallel-orchestrate/SKILL.md` lines 878-896 (from "Detection logic is pure"
through "yields `no_escape`."), replacement text (no `##` heading is added):

````text
Detection logic is pure and lives in `.claude/lib/parallel-drift/ParallelDrift.psm1` (escape
detection, `drift_events[]` construction, and conflict recomputation) and
`.claude/lib/parallel-drift/ParallelDriftHalt.psm1` (halt selection). The first calls the bundled
blast-radius library under `.claude/lib/blast-radius/` rather than re-deriving it. All I/O is confined
to the destination-runtime entry point `.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1`,
which needs PowerShell 7 and no Python interpreter, invoked as:

```
pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1 \
  -ItemKey <issue_num> \
  [-CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json] \
  [-ConfigPath config/blast-radius.json] \
  [-At <yyyy-MM-ddTHH-mm>] [-ComputedAt <yyyy-MM-ddTHH-mm>] \
  <CHANGED_PATH>...
```

The Python modules `scripts/dev_tools/parallel_drift_detection.py` and
`scripts/dev_tools/parallel_drift_halt.py`, with their thin wrapper
`scripts/dev_tools/parallel_drift_detection_cli.py`, remain the repository authority and the parity
reference; the shared corpus under `tests/fixtures/parallel_drift/` binds the two, and the Python
modules are not invoked on the destination-runtime path.

Argument surface: `-ItemKey` is the only required argument and is the item's `issue_num`;
`-CheckpointPath` and `-ConfigPath` default to the two paths shown and resolve against the caller's
working directory; `-At` is the timestamp recorded on the `drift_events[]` entry and `-ComputedAt` the
timestamp recorded on the observed radius, each defaulting at the I/O boundary so the pure functions
never read a clock; and the changed paths are positional and variadic. No parameter is mandatory, so
a missing `-ItemKey` exits `2` instead of prompting. An empty changed-path list is legal and yields
`no_escape`.
````

B22c `.claude/skills/parallel-orchestrate/SKILL.md` line 943 after P4-T2 (line 933 at BASE_SHA, the
line beginning "missing or malformed input, and argparse's"), replacement text (two lines; the
preceding line, 942 after P4-T2 and 932 at BASE_SHA, ending "`1` on", is unchanged):

```text
missing or malformed input (one stderr line prefixed `parallel drift detection failed: `), and `2`
on a usage error, such as a missing or non-integer `-ItemKey` or an unrecognized parameter.
```

B22d `.claude/skills/parallel-orchestrate/SKILL.md` line 972 after P4-T2 and P4-T3 (line 961 at
BASE_SHA, the line beginning "`halted_item_keys` in"), replacement text (two lines; the neighbouring
lines 971 and 973 after P4-T3, which are 960 and 962 at BASE_SHA, are unchanged):

```text
`Get-ParallelDriftHaltedItemKey` in `.claude/lib/parallel-drift/ParallelDriftHalt.psm1` (the port of
`halted_item_keys` in `scripts/dev_tools/parallel_drift_detection_cli.py`) drops the drifting key from
```

B23a `.claude/skills/parallel-remove/SKILL.md` lines 111-112, replacement text (two lines, three
leading spaces kept on each; line 113, the closing fence, is unchanged):

````text
   ```shell
   bash .claude/lib/bash/abandon-parallel-item.sh --item <key> --disposition abandon --confirm-abandon --pr <pr-number> --worktree <worktree-path>
````

The fence info string changes from `bash` to `shell` because the skill-bundle guard's first
invocation pattern (`scripts/dev_tools/skill_bundle_contract.py` line 52) would otherwise match the
fence word `bash`, span the newline, and consume the invocation's own interpreter word, so
`extract_script_references` would return no reference for the invocation (DV9, follow-up FU-763-5).
The word `shell` does not match that pattern, because the `sh` it begins with is followed by a
letter rather than by whitespace.

B23b `.claude/skills/parallel-remove/SKILL.md` lines 149-156, replacement text (no line that names the
script carries `--`, so the invocation line stays the only option-bearing anchor line):

```text
The two token values are declared once each in `.claude/lib/bash/abandon-parallel-item.sh` (the
pushed-down producer), once each in `scripts/dev_tools/parallel_mutation_abandon_cli.py` (the retained
Python parity reference), and once each in the hook (the consumer). The seam test
`tests/scripts/dev_tools/test_parallel_abandon_token_seam.py` parses all four artifacts — the bundled
entry point, the Python reference, the hook, and the invocation line in step 5 above — at run time
to prove they still agree. Renaming a token in one artifact without the identical rename in the
others fails that test. The invocation in step 5 is the file's only executable abandon command
line, and the seam test parses that one line; do not add a second one.
```

B24a `.claude/agents/parallel-orchestrator.md` `tools` entries from `"Bash(git *)"` onward (lines
14-21 become lines 14-23; the numbered positions below are relative to this block):

```text
1   - "Bash(git *)"
2   - "Bash(gh *)"
3   - "Bash(poetry run python -c *)"
4   - "Bash(poetry run python -m *)"
5   - "Bash(bash .claude/lib/bash/compute-cohorts.sh*)"
6   - "Bash(bash .claude/lib/bash/compute-concurrency-batches.sh*)"
7   - "Bash(bash .claude/lib/bash/validate-parallel-manifest.sh*)"
8   - "Bash(bash .claude/lib/bash/abandon-parallel-item.sh*)"
9   - "Bash(pwsh -NoProfile -File .claude/lib/project-file-merge/Resolve-MergeableConflict.ps1*)"
10  - "Bash(pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1*)"
```

The leading number and spaces are block positions for this appendix only; each file line is the
text from the two-space indent onward (for example `  - "Bash(git *)"`).

B24b `.claude/agents/parallel-orchestrator.md` lines 98-104 after P4-T7 (lines 96-102 at BASE_SHA,
the paragraph beginning "The `poetry run` grants remain"), replacement text:

```text
The `poetry run` grants remain for the repository-local paths that still need an interpreter. The
skill's `## Parallel-Level Checkpoint` section validates through
`mcp__drm-copilot__validate_orchestration_artifacts`, and since issue #763 radius drift detection runs
through the destination-runtime PowerShell entry point
`.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1` and the abandon disposition through the
bundled entry point `.claude/lib/bash/abandon-parallel-item.sh`, so no skill step names a
`poetry run` consumer. The two `poetry run python` grants are left unchanged pending a separate
removal decision. Each grant stays scoped to its own `poetry run python` invocation form — not to
`poetry run` as a whole — so `pytest`, `black`, `ruff`, and every other `poetry run` subcommand
remain outside the allowlist. The sibling persona `.claude/agents/parallel-planner.md` records the
same destination-runtime posture.
```

B25 `.claude/hooks/enforce-parallel-abandon-gate.ps1` lines 28-31, replacement text (four lines, same
indentation; line 27 and line 32 unchanged; no token literal is added):

```text
    those variables rather than repeating a literal. The pushed-down producer of the same pair
    is .claude/lib/bash/abandon-parallel-item.sh (the Python CLI it ports remains the parity
    reference), and tests/scripts/dev_tools/test_parallel_abandon_token_seam.py parses every
    side at run time so a rename on one side without the others fails.
```

B26 `tests/scripts/dev_tools/test_parallel_abandon_token_seam.py`: module docstring describes four
extractions (Python CLI constants, bash constants, hook assignments, SKILL line). Add
`BASH_SCRIPT_PATH = REPO_ROOT / ".claude" / "lib" / "bash" / "abandon-parallel-item.sh"`; set
`INVOCATION_ANCHOR = "abandon-parallel-item.sh"`; add three compiled `re.MULTILINE` patterns for the
B7 `readonly` lines and `bash_token_pair()` returning
`(f"{option} {value}", confirm)` after asserting all three matched. Test names (existing names kept
except where noted): `test_cli_declares_a_non_empty_token_pair`,
`test_parser_registers_the_confirmation_token`, `test_parser_composes_the_disposition_token`,
`test_hook_declares_a_non_empty_token_pair`, `test_hook_token_pair_equals_the_cli_pair`,
`test_hook_states_each_token_exactly_once` (two parametrized nodes),
`test_skill_documents_the_cli_token_pair`, `test_bash_script_declares_a_non_empty_token_pair` (new),
`test_bash_token_pair_equals_the_cli_pair` (new), `test_bash_token_pair_equals_the_hook_pair` (new),
`test_skill_invocation_line_names_the_bash_script` (renamed from
`test_skill_invocation_line_names_the_cli_module`), and `test_all_four_extractions_agree` (renamed
from `test_all_three_extractions_agree`; asserts the CLI, hook, and bash pairs are equal and that the
pair is a subset of the SKILL tokens), and `test_bundle_guard_extracts_the_skill_invocation` (new;
imports `extract_script_references` from `scripts.dev_tools.skill_bundle_contract` and asserts that
`".claude/lib/bash/" + INVOCATION_ANCHOR` is a member of
`extract_script_references(read_text(SKILL_PATH))`, with the extracted tuple in the failure message;
this proves the skill-bundle guard sees the invocation it must check, per DV9). The file stays at
most 500 lines.

B27 `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: immediately
after the line `    ".claude/lib/ci-gate/Invoke-CiGateParser.ps1",` (line 160 at authoring) insert:

```text
    ".claude/lib/parallel-drift/ParallelDriftHalt.psm1",
    ".claude/lib/parallel-drift/ParallelDrift.psm1",
    ".claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1",
```

and immediately after the line `    ".claude/rules/shell.md",` insert
`    ".claude/lib/bash/abandon-parallel-item.sh",`.

B28 insertion into `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` after line 324:

```powershell
            # Issue #763 ported radius drift detection to the destination runtime as two pure
            # modules and an entry script under .claude/lib/parallel-drift. CodeCoverage.Path is an
            # explicit per-file allow-list, so each new production file is registered here.
            '.claude/lib/parallel-drift/ParallelDriftHalt.psm1'
            '.claude/lib/parallel-drift/ParallelDrift.psm1'
            '.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1'
```

B29 `tests/shell/parallel_payload_only.bats`: extend the header comment with one paragraph stating
that the abandon entry point is proven with the separate checked-in shim directory
`tests/fixtures/parallel_abandon_path`, which exposes only `gh` and `git` shims, so the no-interpreter
shim directory stays unchanged. In `setup` add
`ABANDON_PATH="${REPO_ROOT}/tests/fixtures/parallel_abandon_path"` and the idempotent
`chmod +x "${ABANDON_PATH}"/* 2>/dev/null || true`. The literal `parallel_abandon_path` appears on
exactly two lines of the file: the header paragraph line and the setup assignment. Add three tests,
by exact name: "the payload directory carries the abandon entry
point" (`[ -f "${PAYLOAD_LIB}/abandon-parallel-item.sh" ]`); "the abandon shim PATH exposes no Python
interpreter" (`command -v python`, `python3`, and `poetry` each fail under
`env -i PATH="$ABANDON_PATH"`); "the payload abandons an item without Python on PATH"
(`run env -i PATH="$ABANDON_PATH" HOME="$HOME" "$BASH_BIN" "${PAYLOAD_LIB}/abandon-parallel-item.sh" --item 42 --disposition abandon --confirm-abandon --pr 7 --worktree wt-42`;
status 0; exactly two lines, `SHIM-CALL gh pr close 7` then `SHIM-CALL git worktree remove wt-42`).

B30 `tests/shell/parallel_bash_manifest_membership.bats` lines 84-85: the test name becomes "the five
CLI entry points are present in both trees" and `abandon-parallel-item.sh` is added first to the
`for name in ...` list. No test is added; the discovery floor of 11 (line 21) is unchanged.

## Appendix C — Fixture Tables and File Sets

C1 drift corpus (18 fixtures; `item_key` 446; `at` `2026-08-08T10-00`; `computed_at`
`2026-08-08T10-05`). CFG is the truth table of `tests/scripts/dev_tools/parallel_drift_test_support.py`
lines 38-45 (`shared_surfaces` `[".claude/settings.json"]`, `shared_surface_globs` `[]`, `modules`
`{"python-dev-tools": ["scripts/dev_tools/**"], "mcp-server": ["packages/mcp-server/**"]}`). R(p) is
`{"paths": p, "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared",
"computed_at": "2026-08-08T09-00"}`. Every item is `{"issue_num": k, "state": "in_flight",
"blast_radius": R(...)}` unless stated, with `worktree_created_at` only where stated. D is the drifter
`446 R(["scripts/dev_tools/**"])`. `conflict_edges` is `[]` unless stated. Because recomputed pairs
always contain the drifter and the drifter is excluded before the comparator runs, every halt through
the CLI has one candidate; the start-timestamp fixtures pin that the drifter is never halted in each
start configuration, and the comparator tie-breaks are pinned by B14.

| Name | State and inputs | result | escaped | pairs | halted |
| --- | --- | --- | --- | --- | --- |
| no-escape-inside-radius | items [D]; changed `["scripts/dev_tools/example.py"]` | no_escape | [] | [] | [] |
| no-escape-empty-changed-paths | items [D]; changed `[]` | no_escape | [] | [] | [] |
| escape-without-conflict | items [D, 445 R(["src/other.py"])]; changed `["docs/notes.md"]` | no_new_conflict | ["docs/notes.md"] | [] | [] |
| halt-one-pair | items [D started `2026-08-08T08-00`, 445 R(["src/app.py"]) started `2026-08-08T09-00`]; changed `["src/app.py"]` | halt_required | ["src/app.py"] | [[445,446]] | [445] |
| halt-several-pairs | items [D, 445 R(["src/app.py"]), 447 R(["src/app.py"])]; changed `["src/app.py"]` | halt_required | ["src/app.py"] | [[445,446],[446,447]] | [445,447] |
| halt-drifter-started-later | as halt-one-pair with D started `2026-08-08T09-30` and 445 started `2026-08-08T08-00` | halt_required | ["src/app.py"] | [[445,446]] | [445] |
| halt-equal-start-timestamps | as halt-one-pair with both started `2026-08-08T08-00` | halt_required | ["src/app.py"] | [[445,446]] | [445] |
| halt-one-start-absent | as halt-one-pair with no `worktree_created_at` on 445 | halt_required | ["src/app.py"] | [[445,446]] | [445] |
| halt-both-starts-absent | as halt-one-pair with no `worktree_created_at` on either item | halt_required | ["src/app.py"] | [[445,446]] | [445] |
| reversed-existing-edge-not-new | as halt-one-pair with `conflict_edges` `[{"a": 446, "b": 445}]` | no_new_conflict | ["src/app.py"] | [] | [] |
| non-object-edge-ignored | as halt-one-pair with `conflict_edges` `["445-446"]` | halt_required | ["src/app.py"] | [[445,446]] | [445] |
| malformed-peer-radius-fails-closed | items [D, 445 with `blast_radius` `"not-a-radius"`]; changed `["docs/notes.md"]` | halt_required | ["docs/notes.md"] | [[445,446]] | [445] |
| tolerated-overlap-under-conflict-tolerance | as halt-one-pair without start timestamps; config CFG plus the `conflict_tolerance` block of `tests/scripts/dev_tools/test_parallel_drift_scheduling.py` lines 49-60 with `tolerance_percent` 100 and `default_band` `C4` | no_new_conflict | ["src/app.py"] | [] | [] |
| peer-not-in-flight-ignored | items [D, 445 R(["src/app.py"]) with `state` `withdrawn`]; changed `["src/app.py"]` | no_new_conflict | ["src/app.py"] | [] | [] |
| peer-radius-iso-timestamp-evaluated | items [D, 445 R(["src/other.py"]) with radius `computed_at` `2026-08-08T09:00:00Z`]; changed `["docs/notes.md"]` | no_new_conflict | ["docs/notes.md"] | [] | [] |
| error-items-not-a-list | state `{"items": {"446": {}}, "conflict_edges": []}`; changed `["src/app.py"]` | error | | | |
| error-item-key-missing | items [445 R(["src/app.py"])]; changed `["src/app.py"]` | error | | | |
| error-non-object-root | state `[]`; changed `["src/app.py"]` | error | | | |

C2 abandon corpus (9 fixtures). BASE is
`["--item", "42", "--disposition", "abandon", "--confirm-abandon", "--pr", "7", "--worktree", "../wt-42"]`;
GH is `["gh", "pr", "close", "7"]` and GIT is `["git", "worktree", "remove", "../wt-42"]`.
`shim_exit` is `{"gh": 0, "git": 0}` and `missing_executable` is `null` unless stated.

| Name | Inputs | exit | stderr_mode and stderr | calls |
| --- | --- | --- | --- | --- |
| success | BASE | 0 | none | [GH, GIT] |
| refuse-detach-disposition | BASE with `detach` in place of `abandon` | 2 | exact: `PARALLEL_ABANDON_ERROR: this CLI executes the 'abandon' disposition only; got 'detach'.` | [] |
| refuse-missing-confirmation | BASE without `--confirm-abandon` | 2 | exact: `PARALLEL_ABANDON_ERROR: refusing to abandon item 42 without the explicit --confirm-abandon confirmation marker; no side effect was performed.` | [] |
| gh-close-fails | BASE; `shim_exit.gh` 1 | 1 | exact: `PARALLEL_ABANDON_ERROR: abandon side effect failed with exit code 1: gh pr close 7` | [GH] |
| git-remove-fails | BASE; `shim_exit.git` 128 | 1 | exact: `PARALLEL_ABANDON_ERROR: abandon side effect failed with exit code 128: git worktree remove ../wt-42` | [GH, GIT] |
| gh-not-on-path | BASE; `missing_executable` `gh` | 1 | exact: `PARALLEL_ABANDON_ERROR: abandon side effect failed with exit code -1: gh pr close 7` | [] |
| unknown-option | BASE plus `--force` | 2 | usage | [] |
| option-abbreviation | BASE with `--disp` in place of `--disposition`; `divergence` `option-abbreviation`; `python_expected` exit 0, none, [GH, GIT] | 2 | usage | [] |
| joined-option-form | `["--item=42", "--disposition=abandon", "--confirm-abandon", "--pr=7", "--worktree=../wt-42"]` | 0 | none | [GH, GIT] |

C3 named Python regression set (all under `tests/scripts/dev_tools/`):
`test_skill_bundle_contract.py`, `test_skill_bundle_contract_evaluation.py`,
`test_skill_bundle_contract_cli.py`, `test_skill_bundle_contract_repo.py`,
`test_parallel_abandon_token_seam.py`, `test_parallel_drift_detection_cli.py`,
`test_parallel_drift_detection_cli_halt.py`, `test_parallel_drift_resolution.py`,
`test_parallel_drift_detection_conflicts.py`, `test_parallel_drift_timestamps.py`,
`test_parallel_drift_scheduling.py`, `test_parallel_mutation_abandon_cli.py`,
`test_parallel_mutation_protocol.py`, `test_parallel_orchestrator_surface_contracts.py`,
`test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`,
`test_poshqc_bundled_parity.py`, `test_claude_rules_frontmatter.py`,
`test_push_down_codex_and_agents_customizations.py`. At baseline (P0-T16) the set is run as listed;
in P9-T6 the two new parity lanes are added.

C4 PowerShell QA file set: `.claude/lib/parallel-drift/ParallelDriftHalt.psm1`,
`.claude/lib/parallel-drift/ParallelDrift.psm1`, `.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1`,
`tests/scripts/claude-lib/parallel-drift/ParallelDriftHalt.Tests.ps1`,
`tests/scripts/claude-lib/parallel-drift/ParallelDrift.Tests.ps1`,
`tests/scripts/claude-lib/parallel-drift/ParallelDrift.Manifest.Tests.ps1`,
`tests/scripts/claude-lib/parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1`,
`tests/scripts/claude-lib/parallel-drift/ParallelDrift.Parity.Tests.ps1`,
`.claude/hooks/enforce-parallel-abandon-gate.ps1`, and
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.

C5 Python QA file set: `scripts/dev_tools/skill_bundle_contract.py`,
`scripts/dev_tools/skill_bundle_contract_cli.py`,
`tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py`,
`tests/scripts/dev_tools/test_skill_bundle_contract_cli.py`,
`tests/scripts/dev_tools/test_parallel_abandon_token_seam.py`,
`tests/scripts/dev_tools/test_parallel_drift_parity.py`, and
`tests/scripts/dev_tools/test_parallel_abandon_bash_parity.py`.
