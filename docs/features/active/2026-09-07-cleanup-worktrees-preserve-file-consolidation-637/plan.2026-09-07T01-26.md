# cleanup-worktrees-preserve-file-consolidation (Plan)

- **Issue:** #637
- **Parent:** epic `cleanup-merged-worktrees-hardening` (child F; gap 5)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-07T01-26
- **Status:** Ready for preflight
- **Version:** 1.0
- **Work Mode:** `full-bug` — `spec.md` is the authoritative acceptance-criteria source.
- **Branch:** assigned at execution time by the epic orchestrator and not knowable at planning time.
  `[P0-T2]` records the branch this plan actually runs on, verbatim, and every later task that needs
  a branch name reads that recorded value.
- **Requirements sources:** `docs/features/active/2026-09-07-cleanup-worktrees-preserve-file-consolidation-637/spec.md`
  (43 acceptance criteria, AC-01 through AC-43), `user-story.md`, `issue.md`,
  `research/2026-09-07-preserve-file-consolidation-research.md`.

**Fail-closed evidence rule:** every baseline, gate, and final-QC command task names one evidence
artifact carrying `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. If any required
artifact is missing or incomplete, the verdict is BLOCKED or INCOMPLETE, never PASS. The approved
checklist state stays unchecked for any task whose artifact is absent or incomplete.

**Evidence accounting rule:** all evidence resolves under
`docs/features/active/2026-09-07-cleanup-worktrees-preserve-file-consolidation-637/evidence/<kind>/`
using the kinds `baseline`, `regression-testing`, `qa-gates`, and `other`. Paths under `artifacts/`
are forbidden for evidence. No non-canonical evidence path was supplied by the delegation, so no
override was rejected. `<timestamp>` in an artifact name is the ISO-8601 `yyyy-MM-ddTHH-mm` value at
execution time. When a task's acceptance passes and its text names `Satisfies **AC-nn**`, change
that criterion's `- [ ]` to `- [x]` in
`docs/features/active/2026-09-07-cleanup-worktrees-preserve-file-consolidation-637/spec.md` in the
same step, altering no other character of the criterion text.

## Toolchain invocation shape — used verbatim in every command task

Every command in this plan that reaches the bash toolchain runs through the wrapped form below. A
bare `wsl` invocation matches no Bash grant available to the executor and is denied wherever it
runs. Two classes of command do not use this form and are each specified in their own paragraph
below: every `git` invocation, and the Python push-down contract suite.

    pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bash scripts/bash/shell-qc.sh check'"

Substitute `format`, `test`, or `test --coverage` for `check` as the stage requires. When the output
is read back in Git Bash it is piped through `tr -d '\0'` before parsing, because WSL output can
carry NUL bytes; for a command that runs through this wrapped form, the recorded `EXIT_CODE:` is
always the exit code of the `pwsh` invocation itself, never of a trailing filter in a pipeline. For
a Windows-side `git` span the recorded `EXIT_CODE:` is the exit code of the single `git` invocation
the task names as decisive, and every other invocation's exit code is recorded in
`Output Summary:`, per the git-route rule below. Available in that environment: `bats` 1.13.0, `kcov` 43,
`shfmt`, `shellcheck`. If the wrapped form is refused, `[P0-T2]` governs: record the refusal, leave
`[P0-T2]` unchecked, and report to the orchestrator. The CI route
`gh workflow run _shell-coverage.yml --ref <the branch name [P0-T2] recorded>` is available only
for the coverage stage of `[P0-T5]` and `[P10-T6]`, read from the uploaded `cov.xml`, and only when
the orchestrator authorizes it after that report. It is not a substitute for any targeted `bats`
gate in this plan, because it produces no per-test TAP output. CI is canonical when local and CI
disagree on a coverage value.

**The `<WSLROOT>` token is a placeholder, not a path, and no span may be run with the placeholder
text still in it.** This plan is authored in preparation mode and is executed later, in a separate
run, in a worktree the epic orchestrator creates; that worktree's path is not knowable at planning
time, so no absolute path to it is written into this plan. Every WSL span in this plan carries
`<WSLROOT>` where the worktree root belongs, because a WSL span genuinely needs an absolute
`/mnt/c/...` path and cannot rely on the executor's Windows working directory. `[P0-T2]` resolves
that path at run time, records it verbatim in its artifact, and **the executor substitutes the
recorded literal for every `<WSLROOT>` occurrence in a span before running that span.** The
resolution is mechanical: `[P0-T2]` runs `git rev-parse --show-toplevel`, which prints the
Windows-form worktree root, records that value as `ResolvedWindowsRoot:`, and derives the WSL literal
by replacing the leading drive letter and its colon with `/mnt/` followed by the lower-cased drive
letter, leaving the remaining forward-slash-separated segments unchanged. The derived value is
recorded as `ResolvedWslRoot:` and is confirmed to exist by a probe span before any later span
consumes it. If the derived path does not exist under `/mnt/c/`, or the probe span does not exit 0,
the executor stops and reports rather than proceeding.

Windows-side spans need no equivalent placeholder. Every `git` span in this plan runs with no `-C`
operand so that it operates on the executor's own worktree through its working directory, and the
`Set-Location` span carried by each of `[P0-T6]`, `[P8-T5]`, and `[P10-T8]` consumes the
`ResolvedWindowsRoot:` value that `[P0-T2]` recorded.

The route was observed to be refused inside an agent-isolated worktree on 2026-09-07; the refusal
originated at the harness level rather than from a repository hook, and it is not established as a
property of any other environment. `[P0-T2]` is the probe that establishes whether the route
executes in the environment this plan is run in, and no later gate in this plan may be recorded as
passing before that probe has executed a command. The wrapped `pwsh` form remains this plan's
toolchain shape because `.claude/settings.json` line 7 grants `Bash(pwsh *)` and the file grants no
`wsl` prefix, so an executor that is not isolation-guarded reaches the bash toolchain through this
form and through no other.

The execution worktree is a linked git worktree: its `.git` is a file whose single line is a
`gitdir:` key followed by a Windows-form absolute path into the administrative repository, and the
admin-side `gitdir` file it points at is Windows-form in the same way. Git running inside WSL does
not treat a drive-lettered path as absolute, so it resolves the value relative to the worktree
directory, finds no repository, and exits with `fatal: not a git repository`. **No `git` invocation
in this plan runs inside the `wsl -d Ubuntu` leg.**

Every git observation runs on the Windows side as `git` followed directly by its subcommand, with
**no `-C` operand and no path operand naming the repository**, so that git resolves the repository
from the executor's own working directory. That form matches the `Bash(git *)` grant at
`.claude/settings.json` line 5. The `-C` form is deliberately not used: a `-C` operand redirects git
out of the agent's own worktree, which is the shape the harness-level worktree-isolation guard
objects to, and it would require an absolute path this plan cannot know at authoring time. The
wrapped form `pwsh -NoProfile -Command "git <subcommand>"` matches the `Bash(pwsh *)` grant at line 7
and is the fallback.

One git subcommand per invocation: a chained `git ... && git ...` line was refused on 2026-09-07 by
a harness-level worktree-isolation guard as a form too complex to verify, while a single
`git <subcommand>` invocation executed. When a task needs more than one git observation, run one
invocation per observation, record the decisive invocation in the artifact's `Command:` and
`EXIT_CODE:` fields, and record every other invocation with its own exit code inside
`Output Summary:`.

The `bats` gates are unaffected by the preceding paragraph. They drive the checked-in stub at
`tests/fixtures/cleanup_worktrees/stub-bin/git` through `CLEANUP_WT_GIT_BIN` and touch no real
repository, so they continue to run inside the WSL leg through the wrapped form.

A `grep`, `cat`, `head`, `tail`, `awk`, or `sed -n` span must not be chained after a `cd` in the
same command line; `.claude/hooks/validate-bash.ps1` line 89 denies that shape. Address the file by
absolute path instead.

The second exception: the Python push-down contract suite runs on the Windows side as
`pwsh -NoProfile -Command "poetry run pytest ..."` with no WSL leg, because `.claude/rules/shell.md`
records that the bash toolchain has no Python or Poetry dependency and the Python toolchain is not
installed inside the WSL image. That form still matches the `Bash(pwsh *)` grant.

That suite is run without a coverage argument in `[P0-T6]`, `[P8-T5]`, and `[P10-T8]`, which
departs from the canonical Python test command at `.claude/rules/python.md` line 16
(`poetry run pytest --cov --cov-branch --cov-report=term-missing`). The rationale is recorded here
so it is answerable at audit without re-deriving it. This work changes no Python production file:
the only Python artifact in scope is the contract suite itself, and it is executed as a contract
check over a Markdown mirror pair rather than as coverage-bearing exercise of Python production
code. The coverage language actually in scope is bash, whose baseline and final-QC coverage tasks
are `[P0-T5]` and `[P10-T6]` and whose numeric comparison is `[P10-T7]`. Adding `--cov` to the
push-down invocation would collect coverage for a module set this work does not change and would
publish a number no acceptance criterion reads.

## How targeted test gates are asserted, and why they can fail

Most acceptance conditions in this plan name a bats test and assert its result rather than searching
for prose. Targeted runs use `bats -t` to force TAP output deterministically and `-f <regex>` to
select the test. A filter that matches nothing still exits 0 and prints the plan line `1..0`, so an
exit code alone is not a discriminating observation. **Every targeted gate that asserts a passing
test therefore asserts three things: the exit code is 0, the TAP plan line printed is the expected
`1..N`, and the output carries no `not ok` line.** The three `[expect-fail]` fail-before tasks
`[P2-T3]`, `[P2-T4]`, and `[P2-T5]` are the deliberate inverse of that form: each asserts a non-zero
exit code, the expected `1..N` plan line, and the presence of a `not ok 1` line, and each records
`ExpectedExitCode: 1`. Filter regexes are deliberately space-free so no nested quoting is needed
inside the wrapped command.

Full-suite runs happen only in Phase 10. Phases 2 through 7 leave the suite intermediate: the three
fail-before tests authored in Phase 2 remain red until Phases 4, 6, and 7 respectively. No gate in
those phases runs the whole suite, because such a gate would be unsatisfiable at the point it runs.

Two splits are pre-authorized by `spec.md` D1 and are decided at `[P5-T9]`: a library split into
`scripts/bash/cleanup_worktrees_preserve_eol_lib.sh` and a suite split into
`tests/shell/test_cleanup_worktrees_preserve_eol.bats`. If either pre-authorized split is taken,
every subsequent gate command names both files in the same `bats` invocation, in the order
`tests/shell/test_cleanup_worktrees_preserve.bats tests/shell/test_cleanup_worktrees_preserve_eol.bats`,
and the expected TAP plan line is the count of matching tests across both. The split and the
affected task IDs are recorded in `evidence/other/library-split-decision.<timestamp>.md`. The split
applies to file lists as well as to `bats` invocations: every later task that enumerates the library
or the suite by name enumerates both files.

## Write-mode observation for `shell-qc.sh format`

`bash scripts/bash/shell-qc.sh format` calls `shfmt -w` (`scripts/bash/shell_qc_lib.sh` line 222).
`shfmt -w` writes files in place and prints nothing on either a clean run or a repairing run, so its
stdout carries no literal that distinguishes the two and its exit code is 0 in both cases. Every
task in this plan that runs the format stage therefore states a **before-and-after tree
observation**: a porcelain status listing, scoped to the roots the format stage can rewrite and
spelled in full below, is captured immediately before and immediately after the
format invocation and both captures are recorded in the artifact, and the acceptance condition is
that the two captures are byte-identical.

That comparison is corroborating rather than primary. A porcelain listing prints the same `??`
line for an untracked file and the same ` M` line for an already-modified file whether or not
`shfmt -w` changed its bytes, so it discriminates only for files that are tracked and clean. The
primary no-rewrite evidence is the pre-format `shfmt -d` observation recorded by `[P10-T1]`: a
pre-format run that printed no diff hunk establishes that the writer which followed it had nothing
to rewrite.

Both porcelain captures run on the Windows side as
`git status --porcelain -- scripts tools .claude/lib/bash`,
per the git-route rule in `## Toolchain invocation shape`. The pathspec names the three roots
`discover_shell_scripts` walks at `scripts/bash/shell_qc_lib.sh` line 85, which are the only paths
`shfmt -w` can rewrite. Scoping is required, not cosmetic: an unscoped capture also observes the
evidence artifact `[P10-T1]` writes between the two captures, and the two listings could then
never be byte-identical. `tools` does not exist in this tree; `git status` exits 0 on a pathspec
operand that matches nothing, so its inclusion is harmless and future-proof.

Because the format stage rewrites tracked source, it is
**not** run during Phase 0 baseline capture; its read-only counterpart `shfmt -d`, which is the
first stage of `bash scripts/bash/shell-qc.sh check`, supplies the baseline drift signal instead.
Running the writer at baseline would repair pre-existing drift and turn the Phase 10 gate into a
blanket waiver.

## Placement and scope constraints carried from `spec.md`

- All new production code lands in `scripts/bash/cleanup_worktrees_preserve_lib.sh`, sourced last by
  `scripts/bash/cleanup-worktrees.sh`. **No change is made to `scripts/bash/cleanup_worktrees_lib.sh`**,
  which stands at 479 of 500 lines and is contended by siblings #630, #631, and #632.
- **No change is made to `.claude/hooks/**`**, owned by children #545, #635, and #591.
- The `SKILL.md` change is exactly one appended bullet in `## Report Line Contract`, anchored to the
  `ACTION|<verb>|<target>|<result>` bullet, because children B, C, D, and G also edit that file.
- Every production, test, and reusable script file stays at or below 500 lines. Markdown is exempt.
- The upstream manifest contract is owned by issue **#635**, whose feature folder does not exist in
  this working tree. `spec.md` restates every consumed field of `preserved_files[]`, so this plan
  builds against `spec.md` and cites #635 by number for provenance only. **No task assumes the
  manifest file exists on disk**; every test drives a checked-in fixture manifest through
  `CLEANUP_WT_MANIFEST_PATH`.
- **Fixture invariants, applying to every fixture group created by any task in this plan.** Every
  happy-path record in every fixture manifest carries a complete `host_token_scan` object holding
  `result` and `pattern_set_id`, with `pattern_set_id` set to `cleanup-wt-host-tokens-v1`. Every
  scenario directory whose record is expected to reach the staging phase carries a
  `check-ignore.<key>.rc` file containing `1`, because the stub's `respond` defaults to exit 0 when
  no `.rc` file exists while `git check-ignore -q` exits 0 when the path **is** ignored. Every
  happy-path record's `memory_index_line` is JSON null unless the test the fixture drives requires
  an index, in which case the fixture also carries the index target.

### Phase 0 — Baseline capture and policy reading

- [ ] [P0-T1] Read, in this order, `CLAUDE.md`, `.github/copilot-instructions.md`,
      `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`,
      `.claude/rules/quality-tiers.md`, `.claude/rules/shell.md`, `.claude/rules/python.md`,
      `.claude/rules/plan-acceptance-gates.md`, and `.claude/rules/tonality.md`, and write
      `docs/features/active/2026-09-07-cleanup-worktrees-preserve-file-consolidation-637/evidence/baseline/phase0-instructions-read.md`.
      Acceptance: that file exists and carries a `Timestamp:` field, a `Policy Order:` field, and an
      explicit list naming all nine files above.
- [ ] [P0-T2] Resolve the execution roots, confirm the workspace, capture the route probe, and
      capture the git baseline. This task runs six separate invocations, in this order.
      **Span 1 — resolve the Windows root**, on the Windows side with no `-C` operand:
      `git rev-parse --show-toplevel`. Record the printed value verbatim as `ResolvedWindowsRoot:`.
      Derive the WSL literal from it by replacing the leading drive letter and its colon with `/mnt/`
      followed by the lower-cased drive letter and leaving every remaining forward-slash-separated
      segment unchanged, and record the derived value verbatim as `ResolvedWslRoot:`. Substitute that
      recorded literal for `<WSLROOT>` in every later span of this plan before running it; no span
      may be run with the placeholder text still in it.
      **Span 2 — confirm the workspace**, on the Windows side:
      `pwsh -NoProfile -Command "Test-Path -LiteralPath 'docs/features/active/2026-09-07-cleanup-worktrees-preserve-file-consolidation-637/spec.md','docs/features/active/2026-09-07-cleanup-worktrees-preserve-file-consolidation-637/plan.2026-09-07T01-26.md','scripts/bash/cleanup_worktrees_lib.sh'"`.
      This span prints one line per path. If any printed line is not `True`, stop and report a
      workspace mismatch to the orchestrator; do not proceed to any later task.
      **Span 3 — the route probe**, which carries no git and establishes whether the wrapped
      invocation reaches the bash toolchain in this environment and that the derived root exists:
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && pwd && bats --version'"`.
      **Spans 4, 5, and 6 — the git baseline**, each run separately on the Windows side per the
      git-route rule in `## Toolchain invocation shape`:
      `git rev-parse HEAD`;
      then
      `git rev-parse --abbrev-ref HEAD`;
      then
      `git status --porcelain`.
      Acceptance: `evidence/baseline/baseline-git-state.<timestamp>.md` exists with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, and an `Output Summary:` recording the `ResolvedWindowsRoot:` value,
      the `ResolvedWslRoot:` value, the three lines span 2 printed, the printed working directory and
      `bats` version from the route probe, the HEAD sha, the branch name printed by span 5 recorded
      verbatim, the full porcelain status text (recorded as `clean` when empty), and the exit code of
      each of the six invocations separately. Each of the three lines span 2 printed is `True`, and
      the working directory span 3 printed equals the recorded `ResolvedWslRoot:` value. The
      artifact's `Command:` and `EXIT_CODE:` record the route probe, which is the decisive invocation
      for this task. No assertion is made about what the branch name is: the execution branch is
      assigned by the epic orchestrator and is recorded here rather than checked. If the derived
      `ResolvedWslRoot:` path does not exist under `/mnt/c/`, or span 3 exits non-zero, stop and
      report rather than proceeding. If the wrapped invocation is refused rather than executed,
      record `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and an `Output Summary:` whose first line is
      `ROUTE REFUSED` followed by the verbatim refusal text, leave this task unchecked, and report to
      the orchestrator that the plan's toolchain route is unavailable. The `ROUTE REFUSED` branch
      applies to the route probe span only. A non-zero result from a Windows-side git span is not a
      route refusal and is recorded separately in `Output Summary:`. Do not substitute an unwrapped
      `wsl` form, and do not record any later gate as passing without an executed command.
- [ ] [P0-T3] Capture the format-drift and lint baseline. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bash scripts/bash/shell-qc.sh check'"`.
      Acceptance: `evidence/baseline/baseline-shell-qc-check.<timestamp>.md` exists with
      `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` that states the exit code and
      records, separately, whether the `shfmt -d` stage printed any diff hunk and how many
      `shellcheck` findings were printed.
- [ ] [P0-T4] Capture the bats baseline. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bash scripts/bash/shell-qc.sh test'"`.
      Acceptance: `evidence/baseline/baseline-shell-qc-test.<timestamp>.md` exists with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, and an `Output Summary:` recording the passing and failing test
      counts printed by the run.
- [ ] [P0-T5] Capture the bash coverage baseline. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bash scripts/bash/shell-qc.sh test --coverage'"`.
      The successful run prints one headline of the shape `Bash coverage (lines): NN.N%` and no
      branch column, because kcov measures line coverage only. Acceptance:
      `evidence/baseline/baseline-shell-qc-coverage.<timestamp>.md` exists with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, and an `Output Summary:` recording that headline verbatim including
      its numeric value, and recording that `artifacts/pester/kcov/cov.xml` was produced, and
      recording whether the produced `artifacts/pester/kcov/cov.xml` carries a per-file entry whose
      `filename` names an existing `scripts/bash/*.sh` file together with a `line-rate` attribute,
      quoting one such entry verbatim when present.
      The headline is produced by `print_coverage_summary` at `scripts/bash/shell_qc_lib.sh` lines
      277-291, which formats the parsed line-rate unconditionally once it is past its own guard, and
      which prints nothing at all when `extract_cobertura_line_rate` cannot read a `line-rate`
      attribute from `cov.xml`. Two degraded outcomes therefore exist and each has a branch. If the
      headline prints with an empty percent value, or if no headline is printed at all, record the
      observed output verbatim, record `EXIT_CODE:` as observed, note that
      `artifacts/pester/kcov/cov.xml` was unparseable, leave this task unchecked, and report to the
      orchestrator that the coverage baseline is unavailable. `[P10-T7]`'s baseline value is mandatory
      and no substitution is permitted for it.
- [ ] [P0-T6] Capture the push-down parity baseline. Run
      `pwsh -NoProfile -Command "Set-Location -LiteralPath 'RESOLVED-WINDOWS-ROOT'; poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q"`,
      substituting the `ResolvedWindowsRoot:` value that `[P0-T2]` recorded for the quoted
      `RESOLVED-WINDOWS-ROOT` token before running the span. The `Set-Location` span states the
      working directory explicitly rather than relying on an ambient one. `poetry` is not on the
      cd-chained-read command list at `.claude/hooks/validate-bash.ps1` line 89, and `Set-Location`
      is not the `cd` token that list matches, so an explicit directory change is permitted here.
      `.claude/rules/python.md` line 16 makes `poetry run pytest` the
      repository-canonical spelling of the `python -m pytest` invocation AC-35 names. Acceptance:
      `evidence/baseline/baseline-pushdown-parity.<timestamp>.md` exists with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, and an `Output Summary:` recording the summary line verbatim,
      including the passed count, and the failed count when the summary line prints one. A fully
      passing `-q` run prints no failed count; record `failed: 0 (not printed)` in that case.
- [ ] [P0-T7] Record the format-stage baseline substitution. Write
      `evidence/baseline/baseline-format-stage-note.<timestamp>.md` stating that
      `bash scripts/bash/shell-qc.sh format` is a write-mode command deliberately not executed at
      baseline, naming `shfmt -w` at `scripts/bash/shell_qc_lib.sh` line 222 as the writer, and
      copying the `shfmt -d` drift observation from the P0-T3 artifact as the baseline signal for
      that stage. Acceptance: the file exists and carries `Timestamp:`,
      `Command: bash scripts/bash/shell-qc.sh format (deliberately not executed at baseline)`,
      `EXIT_CODE: 0`, `ExpectedExitCode: 0`, and an `Output Summary:` carrying the rationale
      sentence, the `shfmt -w` writer citation at `scripts/bash/shell_qc_lib.sh` line 222, and the
      drift observation copied from the `[P0-T3]` artifact.
- [ ] [P0-T8] Confirm the staging precondition. `[P1-T5]` and `[P9-T3]` each issue a `git add` that
      is not a bookkeeping-exempt form under
      `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` lines 229-270, so both
      are governed by the preimplementation gate: `[P1-T5]`'s pathspec is under `tests/fixtures/`,
      which is outside the five exempt orchestration-bookkeeping trees that helper enumerates, and
      `[P9-T3]`'s `-A` is a dash-leading token on the `add` subcommand, which the helper's positively
      modelled option table denies. Read `artifacts/orchestration/orchestrator-state.json` and record
      its presence and readiness state. That file is gitignored and is read-only context for this
      task; it is never staged and never committed by any task in this plan.
      Acceptance: `evidence/baseline/baseline-staging-precondition.<timestamp>.md` exists and carries
      `Timestamp:`,
      `Command: (read-only inspection of artifacts/orchestration/orchestrator-state.json; no command executed)`,
      `EXIT_CODE: 0`, `ExpectedExitCode: 0`, and an `Output Summary:`
      recording whether the checkpoint file exists
      and what readiness state it declares. If the checkpoint is absent or not ready, leave this task
      unchecked and report to the orchestrator that `[P1-T5]` and `[P9-T3]` cannot execute; do not
      proceed past Phase 1.

### Phase 1 — Test infrastructure: git stub cases, `.gitattributes` exception, fixtures, suite scaffold

- [ ] [P1-T1] Add an `add` case to `tests/fixtures/cleanup_worktrees/stub-bin/git`. The file today
      has no `add` case and no `check-ignore` case; both fall to the default arm `*) exit 0 ;;` at
      lines 205-207, so a scenario cannot express a failed add or an ignored path. Add a case that
      derives the KEY `add.<sanitized path>` from the last non-flag operand and calls `respond`.
      Acceptance: the file contains an `add)` case arm and `wc -l` on the file reports 500 or fewer.
- [ ] [P1-T2] Add a `check-ignore` case to `tests/fixtures/cleanup_worktrees/stub-bin/git` deriving
      the KEY `check-ignore.<sanitized path>` from the last non-flag operand and calling `respond`.
      Acceptance: the file contains a `check-ignore)` case arm and `wc -l` reports 500 or fewer.
- [ ] [P1-T3] Extend the stub's KEY-scheme header comment block (lines 20-41) with one line for
      `add` and one line for `check-ignore`, and add a sentence recording the trap that `respond`
      defaults to exit 0 when no `.rc` file exists while `git check-ignore -q` exits 0 when the path
      **is** ignored, so every happy-path scenario directory must carry a
      `check-ignore.<key>.rc` file containing `1`. Acceptance: the header block names both new KEY
      forms and carries that sentence.
- [ ] [P1-T4] Append one line to `.gitattributes`, which is today exactly one line reading
      `* text=auto eol=lf`. The appended line is exactly:
      `tests/fixtures/cleanup_worktrees/preserve/eol-crlf/** -text`. Acceptance: run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'grep -c -F -- -text <WSLROOT>/.gitattributes && grep -c -F -- preserve/eol-crlf <WSLROOT>/.gitattributes && tail -n 1 <WSLROOT>/.gitattributes'"`;
      exit code 0, both counts print `1`, and the printed final line equals the quoted line above
      character for character. The two search literals asserted are `-text` and
      `preserve/eol-crlf`; they are split so the command needs no nested quoting, and the `tail`
      span supplies the whole-line comparison. Record
      `evidence/qa-gates/gate-ac21-gitattributes.<timestamp>.md` with `Timestamp:`, `Command:`,
      `EXIT_CODE:`, and an `Output Summary:` carrying both counts and the final line verbatim.
      Satisfies **AC-21**.
- [ ] [P1-T5] Create the CRLF index fixture at
      `tests/fixtures/cleanup_worktrees/preserve/eol-crlf/MEMORY.md`, every line terminated with a
      carriage return followed by a line feed. Acceptance: the file exists,
      `git status --porcelain -- tests/fixtures/cleanup_worktrees/preserve/eol-crlf`
      lists it, and the byte sequence carriage-return-line-feed is present in the checked-out file.
      Then run, on the Windows side and one subcommand per invocation:
      `git add -- tests/fixtures/cleanup_worktrees/preserve/eol-crlf/MEMORY.md`,
      then
      `git rev-parse :tests/fixtures/cleanup_worktrees/preserve/eol-crlf/MEMORY.md`,
      then
      `git hash-object --no-filters tests/fixtures/cleanup_worktrees/preserve/eol-crlf/MEMORY.md`.
      Acceptance: the `add` invocation exits 0, and both object-name invocations exit 0 and print the
      same 40-character object name, so the index blob is byte-identical to the CRLF working file.
      A worktree-against-index difference check is not a substitute here, because that comparison
      applies the same end-of-line conversion to both sides and reports no difference even when the
      index blob was normalized. That equality is
      false whenever the `.gitattributes` exception is absent, misspelled, or ordered before the
      `* text=auto eol=lf` line. Record
      `evidence/qa-gates/gate-ac20-crlf-index-blob.<timestamp>.md` with `Timestamp:`, `Command:`,
      `EXIT_CODE:`, and an `Output Summary:` recording both object names. The artifact's `Command:`
      and `EXIT_CODE:` record the `hash-object` invocation; the exit codes of the `status`, `add`,
      and `rev-parse` invocations are recorded in `Output Summary:`.
- [ ] [P1-T6] Create the `jq` stub at `tests/fixtures/cleanup_worktrees/preserve/stub-bin/jq`,
      wired through the new `CLEANUP_WT_JQ_BIN` seam. It replays canned tab-separated stdout and an
      exit code from the scenario directory named by `CLEANUP_WT_STUB_SCENARIO`, mirroring the
      existing git stub's `respond` contract, and echoes its argv to stderr as a `stub-jq: <argv>`
      line. No test invokes a real `jq`. Acceptance: the file exists, is executable, and `wc -l`
      reports 500 or fewer.
- [ ] [P1-T7] Create `tests/shell/test_cleanup_worktrees_preserve.bats` with a `setup()` block that
      derives `REPO_ROOT` from `BATS_TEST_DIRNAME`, and defines `ELIB`, `LIB`, `ALIB`, `PLIB`
      (`scripts/bash/cleanup_worktrees_preserve_lib.sh`), `WRAP`
      (`scripts/bash/cleanup-worktrees.sh`), `STUB`, `JQSTUB`, and `PRES`
      (`tests/fixtures/cleanup_worktrees/preserve`). There is no shared bats helper library in this
      tree, so the block duplicates the idiom used by
      `tests/shell/test_cleanup_worktrees_consolidation.bats` lines 9-18 and adds the new paths.
      The setup block ends with `chmod +x "${STUB}" "${JQSTUB}" 2>/dev/null || true`, mirroring
      `tests/shell/test_cleanup_worktrees_consolidation.bats` line 17, because `preserve_resolve_jq`
      accepts `CLEANUP_WT_JQ_BIN` only when the value is executable and a non-executable stub would
      fall through to a real `jq`. Acceptance: the file exists, begins with the bats shebang line,
      the setup block carries that `chmod +x` line naming both stubs, and `wc -l` reports 500 or
      fewer.
- [ ] [P1-T8] Add the two stub-replay tests named by AC-32 to
      `tests/shell/test_cleanup_worktrees_preserve.bats`:
      `the git stub replays a scenario response for add` and
      `the git stub replays a scenario response for check-ignore`, each driving the stub directly
      through `CLEANUP_WT_STUB_SCENARIO` against a new scenario directory under
      `tests/fixtures/cleanup_worktrees/preserve/stub-keys/` and asserting the replayed exit code
      and the `stub-git:` argv line. Acceptance: both test names appear in the file.
- [ ] [P1-T9] Gate the stub-replay tests. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bats -t -f replays tests/shell/test_cleanup_worktrees_preserve.bats'"`.
      Acceptance: exit code 0, the TAP plan line printed is `1..2`, no `not ok` line appears, and
      `evidence/qa-gates/gate-ac32-stub-replays.<timestamp>.md` records `Timestamp:`, `Command:`,
      `EXIT_CODE:`, and an `Output Summary:` carrying the TAP plan line and the two `ok` lines.
      Satisfies **AC-32**.
- [ ] [P1-T10] Add the test `the crlf fixture still contains a carriage return in the working tree`
      to `tests/shell/test_cleanup_worktrees_preserve.bats`, asserting against
      `tests/fixtures/cleanup_worktrees/preserve/eol-crlf/MEMORY.md` that a carriage return byte is
      present in the checked-out file. Acceptance: the test name appears in the file.
- [ ] [P1-T11] Gate the CRLF fixture-integrity test. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bats -t -f carriage tests/shell/test_cleanup_worktrees_preserve.bats'"`.
      Acceptance: exit code 0, the TAP plan line printed is `1..1`, no `not ok` line appears, and
      `evidence/qa-gates/gate-ac20-crlf-fixture.<timestamp>.md` records the four required fields with
      the TAP plan line in `Output Summary:`. Satisfies **AC-20**.

### Phase 2 — Fail-before regression evidence

- [ ] [P2-T1] Create the three fixture groups the fail-before tests drive:
      `tests/fixtures/cleanup_worktrees/preserve/untracked/`,
      `tests/fixtures/cleanup_worktrees/preserve/eol-stale/`, and
      `tests/fixtures/cleanup_worktrees/preserve/host-token/`. Each carries a fixture manifest whose
      `tool` is `cleanup-merged-worktrees` and whose `schema_version` is `1`, the canned tab-separated
      `jq` stub output for that manifest, the named source file, and a
      `check-ignore.<key>.rc` file containing `1`. Every happy-path record in every fixture manifest
      carries a complete `host_token_scan` object holding `result` and `pattern_set_id`, with
      `pattern_set_id` set to the identifier `cleanup-wt-host-tokens-v1`, so that the record-validation
      work in Phase 3 and the content scan in Phase 7 do not retroactively invalidate fixtures
      authored here. The `untracked/` fixture's record carries `memory_index_line` set to JSON null,
      so that the test P4-T12 gates requires no index work before Phase 5. The `eol-stale/` fixture
      carries a string `memory_index_line`, because the test it drives is gated in P6-T8 after the
      index work lands; the `host-token/` fixture's value is immaterial, because the hard stop
      precedes every write. Acceptance: all three directories exist and each contains a fixture
      manifest file and a `check-ignore` response file.
- [ ] [P2-T2] Add the three tests named by AC-08, AC-16, and AC-22 to
      `tests/shell/test_cleanup_worktrees_preserve.bats`:
      `an untracked preserve record is staged and reported`,
      `a stale advisory crlf value does not override an LF target`, and
      `a host token match aborts the pass before any staging`. This task authors the tests and runs
      no command. Their fail-before evidence is recorded by P2-T3, P2-T4, and P2-T5, which carry the
      `[expect-fail]` tag and the artifacts. Acceptance: all three test names appear in the file.
- [ ] [P2-T3] [expect-fail] Record fail-before evidence for the untracked-staging case. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bats -t -f untracked tests/shell/test_cleanup_worktrees_preserve.bats'"`.
      Acceptance: exit code is non-zero, the TAP plan line printed is `1..1`, the output carries a
      `not ok 1` line, and
      `evidence/regression-testing/fail-before-untracked.<timestamp>.md` records `Timestamp:`,
      `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, and an `Output Summary:` carrying the
      `not ok 1` line.
- [ ] [P2-T4] [expect-fail] Record fail-before evidence for the stale advisory line-ending case. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bats -t -f stale tests/shell/test_cleanup_worktrees_preserve.bats'"`.
      Acceptance: exit code is non-zero, the TAP plan line printed is `1..1`, the output carries a
      `not ok 1` line, and `evidence/regression-testing/fail-before-stale-eol.<timestamp>.md` records
      the four required fields plus `ExpectedExitCode: 1`.
- [ ] [P2-T5] [expect-fail] Record fail-before evidence for the host-token hard-stop case. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bats -t -f aborts tests/shell/test_cleanup_worktrees_preserve.bats'"`.
      Acceptance: exit code is non-zero, the TAP plan line printed is `1..1`, the output carries a
      `not ok 1` line, and `evidence/regression-testing/fail-before-host-token.<timestamp>.md`
      records the four required fields plus `ExpectedExitCode: 1`. Together with P2-T3 and P2-T4 this
      satisfies **AC-42**.

### Phase 3 — Preserve library: tool seam, manifest ingestion, record validation

- [ ] [P3-T1] Create `scripts/bash/cleanup_worktrees_preserve_lib.sh` with a header comment stating
      that it defines functions only and runs no work at source time, and that it is sourced after
      `cleanup_worktrees_enumerate_lib.sh`, `cleanup_worktrees_lib.sh`, and
      `cleanup_worktrees_actions_lib.sh` because it depends on `cleanup_wt_git` and
      `consolidation_worktree_path`. Acceptance: the file exists, contains no top-level statement
      other than function definitions and comments, and `wc -l` reports 500 or fewer.
- [ ] [P3-T2] Add `preserve_resolve_jq` to `scripts/bash/cleanup_worktrees_preserve_lib.sh`. It
      resolves `CLEANUP_WT_JQ_BIN` when that value is non-empty and executable, otherwise
      `command -v jq`, and when neither resolves writes a diagnostic naming the tool to stderr and
      returns 127, mirroring `cleanup_wt_git`'s resolution and 127 contract at
      `scripts/bash/cleanup_worktrees_enumerate_lib.sh` lines 34 through 54, whose own diagnostic at
      line 53 reads `cleanup-worktrees: no git binary resolved (CLEANUP_WT_GIT_BIN=%s)` and whose
      `return 127` sits at line 54. The diagnostic this task writes carries the single-line token
      `no jq binary resolved`, which this task creates and which `[P3-T6]`'s AC-05 test asserts on
      stderr. Acceptance: the function name `preserve_resolve_jq` appears in the file, the 127 return
      is present in its body, and the token `no jq binary resolved` appears in the diagnostic it
      writes to stderr.
- [ ] [P3-T3] Add `preserve_read_manifest` to `scripts/bash/cleanup_worktrees_preserve_lib.sh`. It
      invokes the resolved `jq` once, emitting one tab-separated record per `preserved_files[]` entry
      in the fixed column order defined by `spec.md` D3, and requires the top-level `tool` to equal
      `cleanup-merged-worktrees` and `schema_version` to equal `1`. A parse failure or either
      top-level check failing emits `ACTION|preserve-manifest|<manifest-path>|REJECTED` and returns 1
      with nothing staged. Acceptance: the function name `preserve_read_manifest` appears in the
      file and the result token `REJECTED` appears in its body.
- [ ] [P3-T4] Add `preserve_validate_record` to `scripts/bash/cleanup_worktrees_preserve_lib.sh`
      implementing the `spec.md` D4 field matrix: `worktree_path`, `source_path` (repo-relative, not
      absolute, no `..` segment), `change_class` in `untracked`/`modified`, `disposition` exactly
      `PRESERVE`, `verdict` in the five-value set, `target_path` (repo-relative, never guessed),
      `memory_index_line` key present and either a string or JSON null, `evidence` non-empty. Each
      violation skips the record and emits
      `ACTION|preserve-stage|<target-path>|SKIPPED-INVALID`. `change_class` is validated for
      vocabulary but does not change the staging action. Acceptance: the function name
      `preserve_validate_record` appears in the file and the result token `SKIPPED-INVALID` appears
      in its body.
- [ ] [P3-T5] Extend `preserve_validate_record` so that an absent `host_token_scan`, a
      `host_token_scan` that is not a JSON object, a `host_token_scan` missing `result`, a
      `host_token_scan` missing `pattern_set_id`, or a `result` outside the two-value set
      `clean`/`tokens_present` refuses to stage that record and reports it. Acceptance: the file's
      `preserve_validate_record` body branches on the JSON type column of `host_token_scan` and on
      the two allowed `result` values.
- [ ] [P3-T6] Add the tests named by AC-01, AC-05, AC-06, AC-26, and AC-28 to
      `tests/shell/test_cleanup_worktrees_preserve.bats`:
      `preserve library defines functions only and runs no work at source time`,
      `an unresolvable jq returns 127 and stages nothing`,
      `a manifest with a wrong tool or schema_version is rejected and stages nothing`,
      `an absent or malformed host_token_scan refuses to stage the record`, and
      `each missing or out of vocabulary field skips the record and reports`, the last with one case
      per field in the D4 table. **Every test authored here drives a function that this phase
      creates, so no Phase 3 gate depends on a function a later phase adds.** The function under test
      for `an unresolvable jq returns 127 and stages nothing` is `preserve_resolve_jq`, which
      `[P3-T2]` creates in this phase; the test calls it directly rather than through any driver.
      `[P3-T10]` drives `preserve_read_manifest`, created by `[P3-T3]`. `[P3-T11]` drives
      `preserve_validate_record`, created by `[P3-T4]` and extended by `[P3-T5]`. `[P3-T12]` drives
      `preserve_validate_record`, created by `[P3-T4]`. `[P3-T8]` sources the library file and calls
      no function at all.
      The test `an unresolvable jq returns 127 and stages nothing` must be
      independent of whether a real `jq` is installed on the host. It sets `CLEANUP_WT_JQ_BIN` to a
      path that is not executable AND sets `PATH` to the checked-in fixture directory
      `tests/fixtures/cleanup_worktrees/preserve/no-jq`, which contains no `jq`. `command -v` is a
      bash builtin, so the function under test needs no external tool on `PATH`.
      **The test asserts two things, not one: that the status is 127, and that stderr carries the
      single-line token `no jq binary resolved` that `[P3-T2]` writes.** The second assertion is
      required because bash returns 127 for `command not found`, so a failed source, a misspelled
      function name, or a not-yet-existing function all produce 127 and would otherwise pass the test
      without the resolution logic having run. A bash `command not found` 127 prints
      `command not found` rather than that diagnostic, so the two sources of 127 are distinguishable
      and the assertion can fail. Acceptance: all five test names appear in the file, and the AC-05
      test body carries both the status-127 assertion and the `no jq binary resolved` stderr
      assertion.
- [ ] [P3-T7] Create the fixture groups these five tests drive under
      `tests/fixtures/cleanup_worktrees/preserve/`: `bad-schema/`, `bad-tool/`, `no-jq/`,
      `scan-malformed/`, and `field-matrix/` with one sub-scenario per D4 field. `no-jq/` contains no
      executable named `jq` and is used as the `PATH` value for that test. Acceptance: each of
      `bad-schema/`, `bad-tool/`, `scan-malformed/`, and `field-matrix/` exists and carries its
      fixture manifest and canned `jq` stub output. `no-jq/` exists and carries a single `.gitkeep`
      file and no executable named `jq`; the placeholder file is required because git does not track
      an empty directory and the fixture must survive a fresh checkout.
- [ ] [P3-T8] Gate the source-guard test. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bats -t -f defines tests/shell/test_cleanup_worktrees_preserve.bats'"`.
      Acceptance: exit code 0, the TAP plan line printed is `1..1`, no `not ok` line appears, and
      `evidence/qa-gates/gate-ac01-source-guard.<timestamp>.md` records the four required fields.
      Satisfies **AC-01**.
- [ ] [P3-T9] Gate the unresolvable-`jq` test. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bats -t -f unresolvable tests/shell/test_cleanup_worktrees_preserve.bats'"`.
      The test this gate runs drives `preserve_resolve_jq`, which `[P3-T2]` creates in this phase,
      and asserts both that the status is 127 and that stderr carries the single-line token
      `no jq binary resolved`. Acceptance: exit code 0, the TAP plan line printed is `1..1`, no
      `not ok` line appears, and `evidence/qa-gates/gate-ac05-jq-127.<timestamp>.md` records the four
      required fields with an `Output Summary:` recording that the test asserted both the 127 status
      and the presence of that diagnostic token on stderr. Satisfies **AC-05**.
- [ ] [P3-T10] Gate the manifest-rejection test. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bats -t -f schema_version tests/shell/test_cleanup_worktrees_preserve.bats'"`.
      Acceptance: exit code 0, the TAP plan line printed is `1..1`, no `not ok` line appears, and
      `evidence/qa-gates/gate-ac06-manifest-rejected.<timestamp>.md` records the four required
      fields. Satisfies **AC-06**.
- [ ] [P3-T11] Gate the malformed-scan test. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bats -t -f malformed tests/shell/test_cleanup_worktrees_preserve.bats'"`.
      Acceptance: exit code 0, the TAP plan line printed is `1..1`, no `not ok` line appears, and
      `evidence/qa-gates/gate-ac26-scan-malformed.<timestamp>.md` records the four required fields.
      Satisfies **AC-26**.
- [ ] [P3-T12] Gate the field-matrix test. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bats -t -f vocabulary tests/shell/test_cleanup_worktrees_preserve.bats'"`.
      Acceptance: exit code 0, the TAP plan line printed is `1..1`, no `not ok` line appears, and
      `evidence/qa-gates/gate-ac28-field-matrix.<timestamp>.md` records the four required fields.
      Satisfies **AC-28**.

### Phase 4 — Staging driver, dispatch arm, usage text, exit codes

- [ ] [P4-T1] Add `preserve_plan` to `scripts/bash/cleanup_worktrees_preserve_lib.sh`. It performs no
      writes: it reads and validates the manifest, validates each record, verifies each named source
      file exists in the named worktree, runs
      `cleanup_wt_git -C <consolidation-worktree> check-ignore -q -- <target_path>`, and emits the
      `PRESERVE|` records plus the `ACTION|preserve-stage|...` result records on an internal plan
      stream. Records are processed in `LC_ALL=C` order of the pair (`worktree_path`,
      `source_path`), not manifest array order. Acceptance: the function name `preserve_plan`
      appears in the file, its body sorts under `LC_ALL=C` before iterating, and every line in
      `scripts/bash/cleanup_worktrees_preserve_lib.sh` that contains the token `git ` also contains
      the token `cleanup_wt_git`, so no git invocation bypasses the seam. The condition is stated
      positively rather than as an absence of a bare `git ` because the token `cleanup_wt_git `
      itself contains the substring `git `, which makes a bare-token absence search unable to fail.
- [ ] [P4-T2] Emit `ACTION|preserve-stage|<target-path>|MISSING-SOURCE` from `preserve_plan` when the
      named source file does not exist in the named worktree: skip and report, contributing to exit
      1, never a hard stop. The source file is read with plain file I/O and never through git,
      because the repository-root `.claude/agent-memory` tree is gitignored at `.gitignore` line 67.
      Acceptance: the result token `MISSING-SOURCE` appears in the file.
- [ ] [P4-T3] Emit `ACTION|preserve-stage|<target-path>|IGNORED-TARGET` from `preserve_plan` when
      `cleanup_wt_git -C <consolidation-worktree> check-ignore -q` reports the destination is
      ignored: do not copy, do not stage, contribute
      to exit 1. **No force flag is passed to the `cleanup_wt_git ... add` call under any
      condition.** Acceptance: the result token `IGNORED-TARGET` appears in the file, and no line in
      `scripts/bash/cleanup_worktrees_preserve_lib.sh` containing the token `cleanup_wt_git` also
      contains the token `--force` or the standalone word-bounded token `-f` as a git operand. The
      gate is
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'grep -n -F -- cleanup_wt_git <WSLROOT>/scripts/bash/cleanup_worktrees_preserve_lib.sh'"`
      with each matched line inspected; the matched-line listing is recorded in `Output Summary:`.
      A file-scoped search for `-f` alone is deliberately not used, because `[P4-T1]` and `[P4-T2]`
      require existence checks ordinarily written with a `-f` file test, so such a search always
      matches and could not fail. Record
      `evidence/qa-gates/gate-no-force-flag.<timestamp>.md` with `Timestamp:`, `Command:`,
      `EXIT_CODE:`, and an `Output Summary:` carrying every matched line verbatim with its line
      number and the verdict for each.
- [ ] [P4-T4] Add `preserve_commit_plan` to `scripts/bash/cleanup_worktrees_preserve_lib.sh` as the
      only writing function. It consumes the plan stream and performs exactly four kinds of
      operation: `mkdir -p` of the destination directory, a verbatim byte copy of the source to
      `<consolidation-worktree>/<target_path>` with no line-ending transformation, the `MEMORY.md`
      append or creation, and `cleanup_wt_git -C <consolidation-worktree> add -- <target_path>` plus
      the index path when it changed. A non-zero copy or add emits
      `ACTION|preserve-stage|<target-path>|FAILED`. Acceptance: the function name
      `preserve_commit_plan` appears in the file and the result token `FAILED` appears in its body.
- [ ] [P4-T5] Add `run_preserve` to `scripts/bash/cleanup_worktrees_preserve_lib.sh` implementing the
      `spec.md` D5 exit-code contract: 0 when every valid record staged with no skip, no index
      creation, and no token match; 1 when at least one record was skipped, refused, or failed or an
      index was created; 3 on the host-token hard stop; 127 when a required tool could not be
      resolved. Before any record is read it fails closed on its two preconditions: a resolved
      consolidation worktree path that is not an existing directory emits
      `ACTION|preserve-stage||MISSING-WORKTREE` and returns 1, and a resolved manifest path that is
      not an existing readable file emits `ACTION|preserve-manifest|<manifest-path>|MISSING` and
      returns 1. The arm never creates the worktree. Acceptance: the function name `run_preserve`
      appears in the file and the result tokens `MISSING-WORKTREE` and `MISSING` both appear in its
      body.
- [ ] [P4-T6] Add the fourth `source` block to `scripts/bash/cleanup-worktrees.sh` for
      `cleanup_worktrees_preserve_lib.sh`, placed after the existing
      `cleanup_worktrees_actions_lib.sh` block at lines 22-24 and using the same three-line shape
      (`# shellcheck source=...`, `# shellcheck disable=SC1091`, `source "$SCRIPT_DIR/<file>"`).
      Acceptance: the file contains a `source` line naming `cleanup_worktrees_preserve_lib.sh` and it
      appears after the `cleanup_worktrees_actions_lib.sh` source line.
- [ ] [P4-T7] Add the `preserve | --preserve` dispatch arm to `main` in
      `scripts/bash/cleanup-worktrees.sh`. `main` today dispatches only `"" | report`,
      `--apply | apply`, `--help | -h | help`, and `*)` which prints usage to stderr and returns 2,
      and it reads only `${1:-}` with no `shift`, no `$2`, and no option loop. The new arm takes no
      operand and calls `run_preserve`, capturing its return code into `exit_code` exactly as the
      existing arms do. The unknown-argument arm is left byte-unchanged. Acceptance: the file
      contains a `preserve | --preserve)` case arm and the `*)` arm still contains `usage >&2` and
      `return 2`.
- [ ] [P4-T8] Update the `usage()` heredoc in `scripts/bash/cleanup-worktrees.sh` to add the new
      command, the two new environment overrides, and the new record shape. The overrides added are
      the single-line token `CLEANUP_WT_MANIFEST_PATH`, defaulting to
      `artifacts/orchestration/cleanup-worktrees-manifest.json`, and the single-line token
      `CLEANUP_WT_JQ_BIN`, with no default. The record-shape list at lines 42-45 gains
      `PRESERVE|<worktree-path>|<source-path>|<verdict>`. Acceptance:
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'grep -c -F -- CLEANUP_WT_MANIFEST_PATH <WSLROOT>/scripts/bash/cleanup-worktrees.sh'"`
      prints a value of at least 1 and exits 0, and
      `evidence/qa-gates/gate-ac04-usage-manifest-override.<timestamp>.md` records `Timestamp:`,
      `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying the printed count. The literal
      asserted is `CLEANUP_WT_MANIFEST_PATH`, which this task creates in that heredoc.
- [ ] [P4-T9] Create the fixture groups for the Phase 4 tests under
      `tests/fixtures/cleanup_worktrees/preserve/`: `modified/`, `order/` (an out-of-order manifest),
      `missing-source/`, `ignored-target/`, `no-worktree/`, and `exit-codes/`. Every happy-path
      record uses `memory_index_line` set to JSON null so that no index work is required before Phase
      5, and every happy-path scenario directory carries `check-ignore.<key>.rc` containing `1`.
      Acceptance: each named directory exists and carries its fixture manifest, canned `jq` stub
      output, and `check-ignore` response file.
- [ ] [P4-T10] Add the tests named by AC-02, AC-03, AC-04, AC-07, AC-09, AC-10, AC-12, AC-29, AC-30,
      and AC-31 to `tests/shell/test_cleanup_worktrees_preserve.bats`:
      `preserve subcommand dispatches to the preserve driver`,
      `an unknown subcommand still prints usage to stderr and returns 2`,
      `the manifest path is taken from CLEANUP_WT_MANIFEST_PATH`,
      `a missing consolidation worktree reports MISSING-WORKTREE and stages nothing`,
      `a modified preserve record is staged and reported`,
      `records are emitted in LC_ALL=C order regardless of manifest order`,
      `a null memory_index_line stages the file and touches no index`,
      `a missing source file is reported as MISSING-SOURCE`,
      `an ignored target path is refused without a force flag`, and
      `the preserve exit codes distinguish clean, skipped, and blocked runs`. The ignored-target test
      asserts the output contains `IGNORED-TARGET` and that no `stub-git:` line in the output carries
      `add` as its subcommand operand, which is the observable consequence of the refusal: on this
      path no staging call is made, so a force-flag search would hold whatever the implementation
      did. The prohibition on `-f` and `--force` is asserted at source level by `[P4-T3]`. Because
      the stub echoes its whole argv at `tests/fixtures/cleanup_worktrees/stub-bin/git` line 45 and
      strips `-C <path>` only afterwards at line 79, the line that must not appear has the shape
      `stub-git: -C <path> add -- <target-path>`; the test matches the extended regular expression
      `stub-git: .*[[:space:]]add[[:space:]]`, and a search for the literal `stub-git: add` would
      match nothing whether or not the add ran. Phase 2's
      `an untracked preserve record is staged and reported` is expected to turn green in this phase
      and is gated in P4-T12. Acceptance: all ten test names appear in the file.
- [ ] [P4-T11] Exercise the writing phase without any temporary file, per `spec.md` D11: a test sets
      `CLEANUP_WT_CONSOLIDATION_PATH=/dev` and drives a manifest fixture in the `exit-codes/` group
      whose `target_path` is the one-segment repo-relative string `null` — not JSON null, which D4
      would reject as an invalid record — so the destination resolves to `/dev/null` and the
      destination directory resolves to `/dev`. That record's `memory_index_line` is JSON null, so no
      index work is attempted at `/dev/MEMORY.md`, and its scenario directory carries
      `check-ignore.<key>.rc` containing `1`. `mkdir -p /dev` succeeds against the existing
      directory, the byte copy writes to the null device, and the `cleanup_wt_git ... add` argv stays
      observable through the stub's `stub-git:` stderr log. `/dev/null` is a character device, not a
      temporary file. Acceptance: the suite contains no `mktemp` call and no `BATS_TEST_TMPDIR`
      reference, and the `/dev` seam is used by at least one test.
- [ ] [P4-T12] Gate the untracked-staging test that Phase 2 recorded failing. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bats -t -f untracked tests/shell/test_cleanup_worktrees_preserve.bats'"`.
      Acceptance: exit code 0, the TAP plan line printed is `1..1`, no `not ok` line appears, and
      `evidence/qa-gates/gate-ac08-untracked-staged.<timestamp>.md` records the four required fields.
      Satisfies **AC-08**.
- [ ] [P4-T13] Gate the dispatch and usage tests. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bats -t -f dispatches tests/shell/test_cleanup_worktrees_preserve.bats && bats -t -f unknown tests/shell/test_cleanup_worktrees_preserve.bats && bats -t -f CLEANUP_WT_MANIFEST_PATH tests/shell/test_cleanup_worktrees_preserve.bats'"`.
      Acceptance: exit code 0, each of the three runs prints the TAP plan line `1..1`, no `not ok`
      line appears in any of them, and `evidence/qa-gates/gate-ac02-ac03-ac04-dispatch.<timestamp>.md`
      records the four required fields with all three plan lines in `Output Summary:`. Satisfies
      **AC-02**, **AC-03**, and **AC-04**.
- [ ] [P4-T14] Gate the precondition, ordering, and per-record outcome tests. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bats -t -f MISSING-WORKTREE tests/shell/test_cleanup_worktrees_preserve.bats && bats -t -f modified tests/shell/test_cleanup_worktrees_preserve.bats && bats -t -f LC_ALL tests/shell/test_cleanup_worktrees_preserve.bats && bats -t -f memory_index_line tests/shell/test_cleanup_worktrees_preserve.bats'"`.
      Acceptance: exit code 0, each of the four runs prints the TAP plan line `1..1`, no `not ok`
      line appears in any of them, and
      `evidence/qa-gates/gate-ac07-ac09-ac10-ac12.<timestamp>.md` records the four required fields
      with all four plan lines in `Output Summary:`. Satisfies **AC-07**, **AC-09**, **AC-10**, and
      **AC-12**.
- [ ] [P4-T15] Gate the missing-source, ignored-target, and exit-code tests. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bats -t -f MISSING-SOURCE tests/shell/test_cleanup_worktrees_preserve.bats && bats -t -f ignored tests/shell/test_cleanup_worktrees_preserve.bats && bats -t -f distinguish tests/shell/test_cleanup_worktrees_preserve.bats'"`.
      Acceptance: exit code 0, each of the three runs prints the TAP plan line `1..1`, no `not ok`
      line appears in any of them, and
      `evidence/qa-gates/gate-ac29-ac30-ac31-outcomes.<timestamp>.md` records the four required
      fields with all three plan lines in `Output Summary:`. Satisfies **AC-29**, **AC-30**, and
      **AC-31**.

### Phase 5 — Obligation (a): carrying the `MEMORY.md` index line

- [ ] [P5-T1] Add `preserve_index_has_entry` to `scripts/bash/cleanup_worktrees_preserve_lib.sh`. A
      duplicate exists when the destination index already contains a line whose markdown link target
      — the text between `](` and `)` — equals the basename of `target_path`. Acceptance: the
      function name `preserve_index_has_entry` appears in the file.
- [ ] [P5-T2] Add `preserve_render_index_append` to `scripts/bash/cleanup_worktrees_preserve_lib.sh`.
      It appends the source bytes of `memory_index_line` verbatim at end of file, with no separator
      normalization; only the line terminator is supplied by this library. In this phase the
      terminator is a line feed; Phase 6 replaces that with the re-derived value. The destination
      index is the `MEMORY.md` sibling of `target_path`, derived from `target_path`'s directory and
      never from the source's. Acceptance: the function name `preserve_render_index_append` appears
      in the file.
- [ ] [P5-T3] Wire the index outcomes into `preserve_plan` and `preserve_commit_plan`: emit
      `ACTION|preserve-index|<index-path>|OK` on a normal append,
      `ACTION|preserve-index|<index-path>|CREATED` when the destination index did not exist, and
      `ACTION|preserve-index|<index-path>|SKIPPED-DUPLICATE` on a duplicate. Index creation
      contributes to exit 1; a duplicate does not affect the exit code and the file is still copied
      and staged. A `memory_index_line` of JSON null copies and stages the file and reads, creates,
      and appends no index. No `metadata.scope` frontmatter is synthesized under any condition.
      Acceptance: the result tokens `CREATED` and `SKIPPED-DUPLICATE` both appear in the file.
- [ ] [P5-T4] Create the fixture groups for this phase under
      `tests/fixtures/cleanup_worktrees/preserve/`: `index-append/` (an existing LF-terminated index
      target), `index-absent/` (no index at the destination), and `index-duplicate/` (an index
      already carrying a link to the target basename). Acceptance: each named directory exists and
      carries its fixture manifest, canned `jq` stub output, index target where applicable, and
      `check-ignore` response file.
- [ ] [P5-T5] Add the tests named by AC-11, AC-13, and AC-14 to
      `tests/shell/test_cleanup_worktrees_preserve.bats`:
      `the memory index line is appended verbatim to the destination index`,
      `an absent destination index is created and reported as CREATED`, and
      `a duplicate index entry is skipped and does not change the exit code`. Acceptance: all three
      test names appear in the file.
- [ ] [P5-T6] Gate the verbatim-append test. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bats -t -f verbatim tests/shell/test_cleanup_worktrees_preserve.bats'"`.
      Acceptance: exit code 0, the TAP plan line printed is `1..1`, no `not ok` line appears, and
      `evidence/qa-gates/gate-ac11-index-verbatim.<timestamp>.md` records the four required fields.
      Satisfies **AC-11**.
- [ ] [P5-T7] Gate the index-creation test. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bats -t -f CREATED tests/shell/test_cleanup_worktrees_preserve.bats'"`.
      Acceptance: exit code 0, the TAP plan line printed is `1..1`, no `not ok` line appears, and
      `evidence/qa-gates/gate-ac13-index-created.<timestamp>.md` records the four required fields.
      Satisfies **AC-13**.
- [ ] [P5-T8] Gate the duplicate-index test. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bats -t -f duplicate tests/shell/test_cleanup_worktrees_preserve.bats'"`.
      Acceptance: exit code 0, the TAP plan line printed is `1..1`, no `not ok` line appears, and
      `evidence/qa-gates/gate-ac14-index-duplicate.<timestamp>.md` records the four required fields.
      Satisfies **AC-14**.
- [ ] [P5-T9] Confirm the placement constraint still holds after this phase. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && wc -l scripts/bash/cleanup_worktrees_preserve_lib.sh tests/shell/test_cleanup_worktrees_preserve.bats'"`.
      `wc -l` over two named files prints three lines: one count per file and a `total` line.
      Acceptance: both printed per-file line counts are 500 or fewer. Record
      `evidence/qa-gates/gate-library-line-cap.<timestamp>.md` with `Timestamp:`, `Command:`,
      `EXIT_CODE:`, and an `Output Summary:` carrying all three printed lines — the count for
      `scripts/bash/cleanup_worktrees_preserve_lib.sh`, the count for
      `tests/shell/test_cleanup_worktrees_preserve.bats`, and the `total` line — unconditionally. The
      split-decision artifact is additional and is written only when the split is taken. If the
      library count exceeds 460, apply the pre-authorized split from `spec.md` D1 by moving
      `preserve_derive_line_ending`, `preserve_render_index_append`, and `preserve_index_has_entry`
      into `scripts/bash/cleanup_worktrees_preserve_eol_lib.sh`, sourced immediately before the
      preserve library in `scripts/bash/cleanup-worktrees.sh`. If the suite count exceeds 460, apply
      the same `spec.md` D1 pre-authorized suite split into
      `tests/shell/test_cleanup_worktrees_preserve_eol.bats`. Record either split in
      `evidence/other/library-split-decision.<timestamp>.md`. At the point this task runs,
      `preserve_derive_line_ending` does not yet exist; the split moves the two functions that do. If
      the library split is taken, `scripts/bash/cleanup_worktrees_preserve_eol_lib.sh` is also
      subject to the source-time guard of `[P3-T1]`, and every subsequent task that names "the
      preserve library" in connection with `preserve_derive_line_ending`,
      `preserve_render_index_append`, or `preserve_index_has_entry` — specifically `[P6-T1]`,
      `[P6-T2]`, `[P6-T3]`, `[P6-T4]`, and `[P6-T5]` — targets
      `scripts/bash/cleanup_worktrees_preserve_eol_lib.sh` instead, and its acceptance searches that
      file. If the suite split is taken, `tests/shell/test_cleanup_worktrees_preserve_eol.bats` is
      named alongside `tests/shell/test_cleanup_worktrees_preserve.bats` in every later `bats` gate
      command — `[P6-T8]`, `[P6-T9]`, `[P6-T10]`, `[P7-T10]`, `[P7-T11]`, `[P7-T12]` — and is added
      to the file list of `[P9-T5]` and to the suite-wide acceptance of `[P4-T11]`.
      `[P6-T7]` also targets `tests/shell/test_cleanup_worktrees_preserve_eol.bats` when the suite
      split is taken, because all four tests it authors are line-ending tests and adding them to the
      file the split just relieved would defeat the split; its acceptance then searches that file.
      `[P7-T9]` is unaffected and continues to target
      `tests/shell/test_cleanup_worktrees_preserve.bats`, because its tests are not line-ending
      tests. When the library split is taken, `[P10-T7]` reads a `line-rate` for both
      `scripts/bash/cleanup_worktrees_preserve_lib.sh` and
      `scripts/bash/cleanup_worktrees_preserve_eol_lib.sh` and records the covered-to-valid ratio
      across the two as the changed-code figure, and `[P3-T6]`'s test
      `preserve library defines functions only and runs no work at source time` is extended to
      source the second library as a second case, with `[P3-T8]` re-run and a fresh
      `evidence/qa-gates/gate-ac01-source-guard.<timestamp>.md` written before Phase 6 continues.

### Phase 6 — Obligation (b): line-ending re-derivation, where the advisory value never wins

- [ ] [P6-T1] Add `preserve_derive_line_ending` to the preserve library. Given a path it echoes
      exactly one token: `absent` when the path does not exist or exists with zero bytes; `lf` when
      terminated lines exist and none ends with a carriage-return-line-feed pair; `crlf` when
      terminated lines exist and every one does; `mixed` when some but not all do. The advisory
      manifest field `line_ending` is never read as an input to this decision. Acceptance: the
      function name `preserve_derive_line_ending` appears in the library and its body emits all four
      tokens.
- [ ] [P6-T2] Replace the fixed line-feed terminator in `preserve_render_index_append` with the
      re-derived value: `lf` appends with a line feed; `crlf` appends with a carriage-return-line-feed
      pair; `absent` creates the index containing the index line terminated with a line feed, because
      `.gitattributes` guarantees line-feed endings for every tracked path in this repository.
      Acceptance: the append terminator in the library is selected from the value returned by
      `preserve_derive_line_ending` and no literal terminator is hard-coded on the append path.
- [ ] [P6-T3] Handle the unterminated final line: before appending, when the target's final byte is
      not a line feed, write the derived terminator first, so that a file whose last line lacks a
      terminator does not have the new index line concatenated onto its existing last entry.
      Acceptance: the library reads the target's final byte before appending and emits the terminator
      when it is not a line feed.
- [ ] [P6-T4] Implement the mixed-endings refusal: emit
      `ACTION|preserve-index|<index-path>|EOL-MIXED`, skip that record entirely with no copy, no
      stage, and no append, and contribute to exit 1. Acceptance: the result token `EOL-MIXED`
      appears in the library.
- [ ] [P6-T5] Implement the advisory mismatch signal: when the manifest's advisory `line_ending`
      value differs from the re-derived value, emit
      `ACTION|preserve-eol|<index-path>|ADVISORY-MISMATCH` and proceed with the **re-derived** value.
      Acceptance: the result token `ADVISORY-MISMATCH` appears in the library and the advisory value
      is not consulted on the write path.
- [ ] [P6-T6] Create the fixture groups for this phase under
      `tests/fixtures/cleanup_worktrees/preserve/`: `eol-mixed/` (an index target with both ending
      conventions) and `eol-unterminated/` (an index target whose final line has no terminator). The
      `eol-crlf/` fixture from P1-T5 and the `eol-stale/` fixture from P2-T1 are reused. Acceptance:
      both named directories exist and carry their fixture manifests, canned `jq` stub output, index
      targets, and `check-ignore` response files.
- [ ] [P6-T7] Add the tests named by AC-15, AC-17, AC-18, and AC-19 to
      `tests/shell/test_cleanup_worktrees_preserve.bats`:
      `an unterminated final line receives a terminator before the append`,
      `an advisory line ending mismatch emits ADVISORY-MISMATCH`,
      `a crlf target receives a crlf terminated index line`, and
      `a mixed line ending target is refused and reported as EOL-MIXED`. Phase 2's
      `a stale advisory crlf value does not override an LF target` is expected to turn green in this
      phase and is gated in P6-T8. Acceptance: all four test names appear in the file.
- [ ] [P6-T8] Gate the stale-advisory test that Phase 2 recorded failing. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bats -t -f stale tests/shell/test_cleanup_worktrees_preserve.bats'"`.
      Acceptance: exit code 0, the TAP plan line printed is `1..1`, no `not ok` line appears, and
      `evidence/qa-gates/gate-ac16-stale-advisory.<timestamp>.md` records the four required fields.
      Satisfies **AC-16**.
- [ ] [P6-T9] Gate the unterminated-line and advisory-mismatch tests. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bats -t -f unterminated tests/shell/test_cleanup_worktrees_preserve.bats && bats -t -f ADVISORY-MISMATCH tests/shell/test_cleanup_worktrees_preserve.bats'"`.
      Acceptance: exit code 0, both runs print the TAP plan line `1..1`, no `not ok` line appears in
      either, and `evidence/qa-gates/gate-ac15-ac17-eol.<timestamp>.md` records the four required
      fields with both plan lines in `Output Summary:`. Satisfies **AC-15** and **AC-17**.
- [ ] [P6-T10] Gate the CRLF-target and mixed-endings tests. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bats -t -f crlf[[:space:]]target tests/shell/test_cleanup_worktrees_preserve.bats && bats -t -f EOL-MIXED tests/shell/test_cleanup_worktrees_preserve.bats'"`.
      Acceptance: exit code 0, both runs print the TAP plan line `1..1`, no `not ok` line appears in
      either, and `evidence/qa-gates/gate-ac18-ac19-eol.<timestamp>.md` records the four required
      fields with both plan lines in `Output Summary:`. Satisfies **AC-18** and **AC-19**.

### Phase 7 — Obligation (c): the host-token refusal as a hard stop

- [ ] [P7-T1] Add `preserve_scan_host_tokens` to the preserve library implementing the pattern set
      identified as `cleanup-wt-host-tokens-v1`. Matching is POSIX extended regular expression under
      `LC_ALL=C`, case-insensitive, treating input as text with `grep -a`, evaluated one pattern at a
      time in ascending identifier order so the first match can be named in the diagnostic.
      Acceptance: the function name `preserve_scan_host_tokens` appears in the library.
- [ ] [P7-T2] Add the six patterns HT1 through HT6 to `preserve_scan_host_tokens`, transcribed from
      the `spec.md` D5 normative table: HT1 a Windows absolute user-profile path with an account
      segment in either separator form and any drive letter; HT2 the WSL mount form of the same path;
      HT3 a POSIX home directory with an account segment; HT4 a Windows 8.3 short-name path segment
      requiring both delimiters so that ordinary revision syntax is not matched; HT5 an email
      address; HT6 the literal Windows environment-variable spellings for account and host. UNC paths
      and bare hostnames are deliberately excluded per D5. Acceptance: the library carries six
      distinct pattern definitions labelled HT1 through HT6.
- [ ] [P7-T3] Scope the scan exactly as `spec.md` D5 requires: it reads the bytes of the file named
      by the pair (`worktree_path`, `source_path`) and the bytes of the `memory_index_line` string
      that will be appended, and nothing else. It does not read the manifest, the existing content of
      the destination index, any other file on the consolidation branch, the repository tree, the
      push-down bundle, environment variables, command lines, or the consolidation worktree path.
      Acceptance: the only inputs to `preserve_scan_host_tokens` are the source file path and the
      index-line string.
- [ ] [P7-T4] Make the scan a read-only pre-pass over every valid record that runs before any write
      of any kind. Acceptance: `preserve_plan` calls `preserve_scan_host_tokens` for every valid
      record and `preserve_commit_plan` is not invoked until that pre-pass has completed for all
      records.
- [ ] [P7-T5] Implement the hard stop: if any valid record's source bytes or `memory_index_line`
      matches any pattern, or any valid record carries `host_token_scan.result` equal to
      `tokens_present`, the write phase is not entered at all — no file is copied, no index is
      appended to or created, and no `git add` is invoked, for any record and not only the matching
      one. The pass emits the `PRESERVE|` record for every valid record it examined, plus
      `ACTION|preserve-stage|<target-path>|HOST-TOKEN-BLOCKED` for each matching record with the
      matched pattern identifier written to stderr, and returns exit code 3. Acceptance: the result
      token `HOST-TOKEN-BLOCKED` appears in the library and the exit code 3 is returned on that path.
- [ ] [P7-T6] Implement the unconditional local scan required by `spec.md` D12: a
      `host_token_scan.result` of `tokens_present` short-circuits to a refusal without scanning, and
      a `result` of `clean` does **not** skip the local scan. Acceptance: the library runs
      `preserve_scan_host_tokens` on every valid record whose `result` is `clean`.
- [ ] [P7-T7] Implement the advisory pattern-set mismatch: a `pattern_set_id` other than
      `cleanup-wt-host-tokens-v1` emits
      `ACTION|preserve-scan|<target-path>|PATTERN-SET-MISMATCH`, changes nothing else, and does not
      affect the exit code; the local scan governs regardless. Acceptance: the result token
      `PATTERN-SET-MISMATCH` appears in the library and does not alter the accumulated exit code.
- [ ] [P7-T8] Create the fixture groups for this phase under
      `tests/fixtures/cleanup_worktrees/preserve/`: `ht-patterns/` with one checked-in source fixture
      per pattern identifier HT1 through HT6; `ht-revision/` whose source fixture contains ordinary
      git revision syntax and must not match HT4; `scan-scope/` whose fixture manifest and
      destination index both contain host tokens while the named source file does not; and
      `pattern-set-id/` whose record carries a `pattern_set_id` other than the identifier this child
      owns. Because the scan reads only the file a manifest record names, these fixtures are inert
      repository content and need no exemption. Acceptance: each named directory exists and carries
      its fixture manifest, canned `jq` stub output, and source fixtures; each named directory also
      carries a `check-ignore.<key>.rc` file containing `1` for every record expected to reach the
      staging phase, which is every record in `ht-revision/`, `scan-scope/`, and `pattern-set-id/`.
- [ ] [P7-T9] Add the tests named by AC-23, AC-24, AC-25, and AC-27 to
      `tests/shell/test_cleanup_worktrees_preserve.bats`: `each host token pattern is detected` with
      one fixture per pattern identifier HT1 through HT6;
      `HEAD~1 and other revision syntax do not match the short-name pattern`;
      `the host token scan reads only the named source file`, using a manifest fixture and a
      destination index fixture that both contain host tokens and must not trigger a refusal; and
      `a pattern set id mismatch is reported and the local scan governs`. Phase 2's
      `a host token match aborts the pass before any staging` is expected to turn green in this phase
      and is gated in P7-T10. Acceptance: all four test names appear in the file.
- [ ] [P7-T10] Gate the host-token hard-stop test that Phase 2 recorded failing. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bats -t -f aborts tests/shell/test_cleanup_worktrees_preserve.bats'"`.
      The test itself asserts exit status 3 and that no `stub-git:` line in the output carries `add`
      as its subcommand operand. Because the stub echoes its whole argv at
      `tests/fixtures/cleanup_worktrees/stub-bin/git` line 45 and `preserve_commit_plan` always
      passes `-C <consolidation-worktree>` first, the line that must not appear has the shape
      `stub-git: -C <path> add -- <target-path>`; the test matches the extended regular expression
      `stub-git: .*[[:space:]]add[[:space:]]`, and a search for the literal `stub-git: add` would
      match nothing whether or not the add ran.
      Acceptance: exit code 0, the TAP plan line printed is `1..1`, no `not ok` line appears, and
      `evidence/qa-gates/gate-ac22-host-token-hard-stop.<timestamp>.md` records the four required
      fields. Satisfies **AC-22**.
- [ ] [P7-T11] Gate the pattern-detection and revision-syntax tests. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bats -t -f detected tests/shell/test_cleanup_worktrees_preserve.bats && bats -t -f revision tests/shell/test_cleanup_worktrees_preserve.bats'"`.
      Acceptance: exit code 0, both runs print the TAP plan line `1..1`, no `not ok` line appears in
      either, and `evidence/qa-gates/gate-ac23-ac24-patterns.<timestamp>.md` records the four
      required fields with both plan lines in `Output Summary:`. Satisfies **AC-23** and **AC-24**.
- [ ] [P7-T12] Gate the scan-scope and pattern-set-identifier tests. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bats -t -f reads tests/shell/test_cleanup_worktrees_preserve.bats && bats -t -f governs tests/shell/test_cleanup_worktrees_preserve.bats'"`.
      Acceptance: exit code 0, both runs print the TAP plan line `1..1`, no `not ok` line appears in
      either, and `evidence/qa-gates/gate-ac25-ac27-scan-scope.<timestamp>.md` records the four
      required fields with both plan lines in `Output Summary:`. Satisfies **AC-25** and **AC-27**.
- [ ] [P7-T13] Confirm the pattern-set identifier is present in the implementation. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'grep -c -F -- cleanup-wt-host-tokens-v1 <WSLROOT>/scripts/bash/cleanup_worktrees_preserve_lib.sh'"`.
      The literal asserted is `cleanup-wt-host-tokens-v1`, which this work creates and which
      supersedes the example placeholder issue #635 carried. Acceptance: the printed count is at
      least 1, the command exits 0, and
      `evidence/qa-gates/gate-pattern-set-identifier.<timestamp>.md` records `Timestamp:`,
      `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying the printed count.

### Phase 8 — The `PRESERVE|` record: skill text and its byte-identical push-down mirror

- [ ] [P8-T1] Append exactly one bullet to the `## Report Line Contract` list in
      `.claude/skills/cleanup-merged-worktrees/SKILL.md`, immediately after the
      `ACTION|<verb>|<target>|<result>` bullet, which is the last bullet of that list and today sits
      at line 71, immediately before the blank line at 72 and the `## End-to-End Workflow` heading at
      73. The bullet is anchored to that neighbouring bullet rather than to a line number because
      children #631 and #632 also edit this list. Every preceding bullet is left byte-unchanged. The
      new bullet's record shape is `PRESERVE|<worktree-path>|<source-path>|<verdict>` and it follows
      the list's observed conventions: an inline code span holding the shape, a spaced em dash,
      angle-bracketed lowercase-hyphenated placeholders, an inline enumerated verdict set with pipe
      separators, and two-space continuation indents. Acceptance: the file's
      `## Report Line Contract` list carries exactly one more bullet than before and the six existing
      record shapes are byte-unchanged.
- [ ] [P8-T2] Confirm the token is present in the skill text. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'grep -n -F -- PRESERVE\| <WSLROOT>/.claude/skills/cleanup-merged-worktrees/SKILL.md && grep -n -E ^##[[:space:]] <WSLROOT>/.claude/skills/cleanup-merged-worktrees/SKILL.md'"`.
      The literal asserted is `PRESERVE|`; the backslash in the command span escapes the pipe for
      the shell and is not part of the literal. Acceptance: exit code 0, at least one printed match
      whose line number falls between the `## Report Line Contract` heading line and the
      `## End-to-End Workflow` heading line, and
      `evidence/qa-gates/gate-ac33-skill-record.<timestamp>.md` recording `Timestamp:`, `Command:`,
      `EXIT_CODE:`, and an `Output Summary:` carrying the matched line with its line number and the
      line numbers of both headings. Satisfies **AC-33**.
- [ ] [P8-T3] Mirror the identical bullet into
      `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`.
      The two files are byte-identical today, both hashing to `a7a3d102d01028b239113d994b4247be`, so
      the mirrored hunk must be identical rather than merely equivalent. Acceptance: the mirror file
      carries the same appended bullet at the same position in its `## Report Line Contract` list.
- [ ] [P8-T4] Verify byte identity of the pair. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && cmp .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md && md5sum .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md'"`.
      The two named files are the instances this condition is judged against; no other pair is
      admissible. Acceptance: exit code 0, `cmp` prints no `differ` line, the two printed md5 values
      are equal to one another, and
      `evidence/qa-gates/gate-ac34-pushdown-byte-identity.<timestamp>.md` records the four required
      fields with both md5 values in `Output Summary:`. Satisfies **AC-34**.
- [ ] [P8-T5] Run the push-down contract suite. Run
      `pwsh -NoProfile -Command "Set-Location -LiteralPath 'RESOLVED-WINDOWS-ROOT'; poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q"`,
      substituting the `ResolvedWindowsRoot:` value that `[P0-T2]` recorded for the quoted
      `RESOLVED-WINDOWS-ROOT` token before running the span. Acceptance: exit code 0, the run prints a summary line containing the
      word `passed` and no `failed` count, and
      `evidence/qa-gates/gate-ac35-pushdown-contracts.<timestamp>.md` records the four required
      fields with the summary line in `Output Summary:`. Satisfies **AC-35**.
- [ ] [P8-T6] Record the deliberate documentation inconsistency. Write
      `evidence/other/record-type-list-divergence.<timestamp>.md` stating that the duplicate
      record-type list in the header comment of `scripts/bash/cleanup_worktrees_lib.sh` is left stale
      by design, because that file stands at 479 of 500 lines and is contended by three serialized
      siblings, and that the wrapper's `usage()` heredoc was updated instead in P4-T8. Acceptance:
      the file exists and names both locations and the reason.

### Phase 9 — Boundary, cap, and hygiene verification

- [ ] [P9-T1] Verify the contended library carries no diff. Run two separate Windows-side
      invocations, in this order:
      `git diff --stat epic/cleanup-merged-worktrees-hardening-integration -- scripts/bash/cleanup_worktrees_lib.sh`;
      then
      `git status --porcelain -- scripts/bash/cleanup_worktrees_lib.sh`.
      The ref `epic/cleanup-merged-worktrees-hardening-integration` exists as a local branch in this
      repository. Acceptance: both invocations exit 0, both print nothing, and
      `evidence/qa-gates/gate-ac36-lib-untouched.<timestamp>.md` records the four required fields
      with both empty outputs and both exit codes noted in `Output Summary:`. The artifact's
      `Command:` and `EXIT_CODE:` record the `diff --stat` invocation. Satisfies **AC-36**.
- [ ] [P9-T2] Verify the hooks tree carries no diff. Run two separate Windows-side invocations, in
      this order:
      `git diff --stat epic/cleanup-merged-worktrees-hardening-integration -- .claude/hooks`;
      then
      `git status --porcelain -- .claude/hooks`.
      Acceptance: both invocations exit 0, both print nothing, and
      `evidence/qa-gates/gate-ac37-hooks-untouched.<timestamp>.md` records the four required fields
      with both exit codes noted in `Output Summary:`. The artifact's `Command:` and `EXIT_CODE:`
      record the `diff --stat` invocation. Satisfies **AC-37**.
- [ ] [P9-T3] Verify the 500-line cap per file. Run three separate Windows-side invocations, in this
      order:
      `git add -A`;
      then
      `git status --porcelain`;
      then
      `git diff --name-only epic/cleanup-merged-worktrees-hardening-integration`
      to produce the changed-file list, then run `wc -l` through the WSL leg on each non-Markdown
      entry of that list. The `git add -A` span is present because an anchored name-listing diff
      enumerates tracked changes only and would not otherwise see the files this work creates. Run
      `wc -l` only on entries of that list that exist in the working tree and do not end in `.md`;
      record entries present only on the ref as `ref-only, not measured` in the table, with their
      count. Acceptance: every measured non-Markdown entry reports 500 or fewer lines, and
      `evidence/qa-gates/gate-ac38-line-caps.<timestamp>.md` records the four required fields with
      the full per-file line-count table and all three git invocations' exit codes in
      `Output Summary:`.
      The artifact's `Command:` and `EXIT_CODE:` record the `diff --name-only` invocation. If a
      measured entry exceeds 500 lines, apply the applicable pre-authorized split from `spec.md` D1
      at that point, record it in `evidence/other/library-split-decision.<timestamp>.md`, re-run the
      gates whose file list the split changed, and re-run this task. This task stays unchecked until
      every measured entry reports 500 or fewer. Satisfies **AC-38**.
- [ ] [P9-T4] Verify no coverage exclusion was added for a production path. Run, on the Windows
      side:
      `git diff epic/cleanup-merged-worktrees-hardening-integration -- scripts/bash/shell_qc_lib.sh scripts/bash/shell-qc.sh .github/workflows/_shell-coverage.yml`.
      Acceptance: exit code 0, the diff prints no added line introducing an exclusion that matches
      any path under `scripts/`, and
      `evidence/qa-gates/gate-ac41-no-coverage-exclusion.<timestamp>.md` records the four required
      fields. Satisfies **AC-41**.
- [ ] [P9-T5] Verify the no-temporary-file rule across the changed test surface. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'grep -r -c -F -- mktemp <WSLROOT>/tests/shell/test_cleanup_worktrees_preserve.bats <WSLROOT>/tests/fixtures/cleanup_worktrees/preserve; grep -r -c -F -- BATS_TEST_TMPDIR <WSLROOT>/tests/shell/test_cleanup_worktrees_preserve.bats <WSLROOT>/tests/fixtures/cleanup_worktrees/preserve'"`.
      The two literals asserted are `mktemp` and `BATS_TEST_TMPDIR`. `grep` exits 1 when it selects
      no line, so the expected exit code of this task is 1, not 0. Acceptance: every printed count
      is `0`, and `evidence/qa-gates/gate-ac43-no-temp-files.<timestamp>.md` records the four
      required fields plus `ExpectedExitCode: 1`, with the full count listing in `Output Summary:`.
      Satisfies **AC-43**.
- [ ] [P9-T6] Record the scope-boundary statement. Write
      `evidence/other/scope-boundary.<timestamp>.md` stating that the three dead consolidation
      functions in `scripts/bash/cleanup_worktrees_actions_lib.sh` —
      `create_consolidation_worktree` at line 70, `cherry_pick_candidates` at line 103, and
      `cleanup_consolidation_on_abort` at line 165 — remain without a production call site after this
      work, that only `verify_consolidation_merged` at line 198 is reached from production, and that
      restoring the full consolidation driver is a distinct defect recorded as a follow-up candidate
      rather than absorbed here. Acceptance: the file exists and names all four functions and the
      follow-up boundary.

### Phase 10 — Final QC loop and coverage

The loop order is format, then check, then test, then test with coverage. **If any stage fails or
rewrites a file, restart the loop from `[P10-T1]`, not from the format stage.** `[P10-T1]` is
re-run on every iteration because the acceptance of `[P10-T2]` and of `[P10-T5]` both cite the
`[P10-T1]` pre-format `shfmt -d` observation as the no-rewrite evidence, and an artifact captured
before the rewrite that triggered the restart describes a superseded tree. A format-stage rewrite
also invalidates the `[P9-T3]` line-cap measurement, which was taken against the pre-format tree.
When the loop restarts because the format stage rewrote a file, re-run `[P9-T3]` and write a fresh
`evidence/qa-gates/gate-ac38-line-caps.<timestamp>.md` before `[P10-T5]` may be recorded. No stage
may be recorded as `SKIPPED`.

- [ ] [P10-T1] Capture the pre-format tree state and the pre-format drift signal. This task runs two
      separate spans. Span one, on the Windows side:
      `git status --porcelain -- scripts tools .claude/lib/bash`.
      The pathspec scopes the capture to the three roots `discover_shell_scripts` walks at
      `scripts/bash/shell_qc_lib.sh` line 85, which are the only paths the format stage can rewrite,
      and it keeps the evidence artifact this task writes out of the listing that `[P10-T2]`
      compares against.
      Span two, in the WSL leg:
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bash scripts/bash/shell-qc.sh check'"`.
      Record the full output of both. Acceptance:
      `evidence/qa-gates/final-qc-preformat-tree.<timestamp>.md` records `Timestamp:`, `Command:`,
      `EXIT_CODE:`, and an `Output Summary:` carrying the complete porcelain listing verbatim.
      `Output Summary:` additionally records, separately, whether the pre-format `shfmt -d` stage
      printed any diff hunk and how many `shellcheck` findings were printed. The artifact's
      `Command:` and `EXIT_CODE:` record the `check` span; the porcelain listing is recorded in
      `Output Summary:`. This task does not require exit 0; it is an observation.
- [ ] [P10-T2] Run the format stage. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bash scripts/bash/shell-qc.sh format'"`,
      then immediately re-run span one of P10-T1, that is
      `git status --porcelain -- scripts tools .claude/lib/bash`,
      on the Windows side, with the same pathspec so that the two listings are comparable and
      neither observes the evidence artifact `[P10-T1]` wrote between them. `shfmt -w` prints
      nothing on a clean
      run and nothing on a repairing run, so the exit code and stdout do not distinguish the two.
      Acceptance: exit code 0; the P10-T1 artifact records that the pre-format `shfmt -d` stage
      printed no diff hunk, which is the discriminating proof that `shfmt -w` rewrote nothing,
      because `git status --porcelain -- scripts tools .claude/lib/bash` prints the same `??` or
      ` M` line whether or not an untracked
      or already-modified file's bytes changed; and the post-format porcelain listing is
      byte-identical to the pre-format listing, which covers tracked-and-clean files. If the
      pre-format `shfmt -d` stage printed a diff hunk, the format stage repaired pre-existing drift:
      record that fact and restart the loop from P10-T1, where the second iteration's pre-format
      `shfmt -d` observation is the clean-pass evidence. A `shellcheck` finding in P10-T1 does not by
      itself restart the loop at the point it is observed; it is repaired and reported through
      P10-T3, and the repair itself restarts the loop from P10-T1 under the preamble rule, because a
      repair rewrites a file. `evidence/qa-gates/final-qc-format.<timestamp>.md` records the four
      required fields plus both porcelain listings and the exit code of each porcelain invocation.
      The artifact's `Command:` and `EXIT_CODE:` record the format invocation.
- [ ] [P10-T3] Run the lint and format-diff stage. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bash scripts/bash/shell-qc.sh check'"`.
      Acceptance: exit code 0, the output carries no `shfmt` diff hunk and no `shellcheck` finding,
      and `evidence/qa-gates/final-qc-check.<timestamp>.md` records the four required fields.
- [ ] [P10-T4] Run the full bats suite. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bash scripts/bash/shell-qc.sh test'"`.
      This is the first task in the plan that runs the whole suite; every test the earlier phases
      authored is expected to be green by this point. Acceptance: exit code 0, the run reports zero
      failures, and `evidence/qa-gates/final-qc-test.<timestamp>.md` records the four required fields
      with the passing and failing counts in `Output Summary:`.
- [ ] [P10-T5] Record the single clean pass required by AC-39. Acceptance:
      `evidence/qa-gates/final-qc-single-pass.<timestamp>.md` exists and records that P10-T2, P10-T3,
      and P10-T4 each exited 0 within one uninterrupted loop iteration and that the format stage
      rewrote no file, citing the P10-T1 pre-format `shfmt -d` observation of no diff hunk as the
      evidence for the no-rewrite claim and the two byte-identical porcelain listings from P10-T2 as
      the corroborating tracked-file observation. The artifact additionally carries `Timestamp:`,
      `Command: (derivation only; no command executed)`, `EXIT_CODE: 0`, and an `Output Summary:`
      restating the recorded values in one line. Satisfies **AC-39**.
- [ ] [P10-T6] Run the coverage stage. Run
      `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd <WSLROOT> && bash scripts/bash/shell-qc.sh test --coverage'"`.
      The successful run prints one headline of the shape `Bash coverage (lines): NN.N%` and no
      branch column; kcov measures line coverage only, so no bash branch-coverage gate exists and
      none is asserted. Acceptance: exit code 0, the headline is printed, its numeric value is at
      least 85.0, `artifacts/pester/kcov/cov.xml` is produced, and
      `evidence/qa-gates/final-qc-coverage.<timestamp>.md` records the four required fields with the
      headline verbatim in `Output Summary:`. Satisfies **AC-40**.
- [ ] [P10-T7] Record the coverage comparison. Read the baseline headline value from the P0-T5
      artifact and the post-change headline value from the P10-T6 artifact, and read the
      `line-rate` attribute for `scripts/bash/cleanup_worktrees_preserve_lib.sh` from
      `artifacts/pester/kcov/cov.xml` as the changed-code coverage figure. Acceptance:
      `evidence/qa-gates/coverage-comparison.<timestamp>.md` exists and records three numeric values
      — baseline line coverage, post-change line coverage, and the new library's own line rate — plus
      the signed delta between the first two, and states explicitly that the post-change value is at
      or above 85.0. If the P0-T5 artifact recorded that no per-file `line-rate` entry exists, record
      the new library's own line rate as the ratio of its covered to its valid line elements read
      from the same cov.xml, state that derivation in the artifact, and if neither is available
      record `not available` with the reason. The baseline value, the post-change value, and the
      signed delta remain mandatory and no substitution is permitted for them. The artifact
      additionally carries `Timestamp:`, `Command: (derivation only; no command executed)`,
      `EXIT_CODE: 0`, and an `Output Summary:` restating the recorded values in one line. If the
      post-change value is below the baseline value, the verdict is remediation-required and this
      task stays unchecked until a further test-adding pass restores it.
- [ ] [P10-T8] Re-run the push-down contract suite as the last gate, because Phase 8 edited a
      `.claude/**` file and later phases may have touched the bundle. Run
      `pwsh -NoProfile -Command "Set-Location -LiteralPath 'RESOLVED-WINDOWS-ROOT'; poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q"`,
      substituting the `ResolvedWindowsRoot:` value that `[P0-T2]` recorded for the quoted
      `RESOLVED-WINDOWS-ROOT` token before running the span. Acceptance: exit code 0, the summary line contains the word `passed`
      and no `failed` count, and `evidence/qa-gates/final-qc-pushdown.<timestamp>.md` records the
      four required fields.
- [ ] [P10-T9] Reconcile the checklist. Verify that every `AC-nn` checkbox in
      `docs/features/active/2026-09-07-cleanup-worktrees-preserve-file-consolidation-637/spec.md`
      that this plan claims is backed by a named evidence artifact that exists on disk and carries
      all four required fields. Acceptance:
      `evidence/qa-gates/ac-reconciliation.<timestamp>.md` exists and lists all 43 identifiers AC-01
      through AC-43, each with the absolute path of every evidence artifact that evidences it and
      each of those artifacts' recorded `EXIT_CODE:`. An identifier may carry more than one
      artifact: AC-04, AC-20, and AC-42 do, and an identifier is complete only when every artifact
      named for it is present and carries all four required fields. Verify that every criterion whose
      artifacts are all present and complete is checked off in `spec.md`, and that no criterion is
      checked off without them. Any identifier missing any of its artifacts is recorded as INCOMPLETE
      and blocks the verdict.
      The artifact additionally carries `Timestamp:`, `Command: (derivation only; no command executed)`,
      `EXIT_CODE: 0`, `ExpectedExitCode: 0`, and an `Output Summary:` recording the count of complete
      identifiers, the count of INCOMPLETE identifiers, and the identifiers in the second group.

## Known deviations from the delegation brief, recorded rather than silently resolved

- The delegation stated that `spec.md` carries **46** acceptance criteria. The file carries **43**:
  identifiers AC-01 through AC-43 under `## Acceptance Criteria`, with no gaps and no duplicates.
  The planner's `AC-INVENTORY:` and `AC-MAPPING:` records, emitted with this plan's handoff rather
  than inside this file, enumerate the 43 identifiers actually present,
  because the contract requires the inventory to name exactly the specification's identifiers.
- Two criteria in `spec.md` are asserted by a search rather than by a named test, because the
  artifact under assertion is not executable: AC-21 asserts a `.gitattributes` line and AC-33
  asserts skill prose. Both are asserted with `grep -F` against a single-line token quoted verbatim
  in this plan's prose.
- `spec.md` AC-22 specifies the assertion "the output carries no `stub-git: add` line". That literal
  never appears in the stub's output whether or not the add ran, because the stub echoes its full
  argv at `tests/fixtures/cleanup_worktrees/stub-bin/git` line 45 and strips `-C` and its path
  operand only afterwards at line 79. `[P7-T10]` substitutes the extended regular expression
  `stub-git: .*[[:space:]]add[[:space:]]`, which observes the same fact and can fail.
- `spec.md` AC-30 specifies the assertion "contains no `--force`". No staging call is made on the
  refusal path, so that search holds whatever the implementation does. `[P4-T10]` substitutes the
  same `add`-operand regex, and the prohibition on `-f` and `--force` is asserted at source level by
  `[P4-T3]`.
