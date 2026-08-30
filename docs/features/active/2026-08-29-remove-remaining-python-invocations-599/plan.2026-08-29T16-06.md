# 2026-08-29-remove-remaining-python-invocations - Plan

- **Issue:** #599
- **Parent (optional):** `docs/features/epics/claude-runtime-portability/epic.md` (Feature D, wave 2, complexity C3)
- **Owner:** drmoisan
- **Last Updated:** 2026-08-29T16-06
- **Status:** Draft
- **Version:** 0.4 (preflight round 3 deltas D22 and D23 applied, plus the repository owner's
  section-scoped checkbox-counting directive and four prose corrections)
- **Work Mode:** full-feature (resolved from `issue.md:13`, `- Work Mode: full-feature`)

## Required References

- Standing instructions: `CLAUDE.md`
- General code change policy: `.claude/rules/general-code-change.md`
- General unit test policy: `.claude/rules/general-unit-test.md`
- Module rigor tiers: `.claude/rules/quality-tiers.md`
- Shell (bash) standards: `.claude/rules/shell.md`
- Python standards: `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`
- TypeScript standards: `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`
- Plan acceptance gates: `.claude/rules/plan-acceptance-gates.md`
- Tone policy: `.claude/rules/tonality.md`
- Requirements sources: `spec.md` (20 acceptance criteria) and `user-story.md` (13 acceptance criteria)
- Authoritative research: `research/2026-08-29T17-10-remove-remaining-python-invocations-research.md`.
  Its `## Citation Corrections` table supersedes any conflicting line number anywhere else.

**All work must comply with these policies; do not duplicate their content here.**

## Evidence Location

Every evidence artifact this plan produces is written under
`docs/features/active/2026-08-29-remove-remaining-python-invocations-599/evidence/<kind>/`,
with `<kind>` one of `baseline`, `qa-gates`, `regression-testing`, `other`. No `artifacts/`
sub-path is used for evidence. Artifact filenames use the `yyyy-MM-ddTHH-mm` timestamp form;
`<timestamp>` below stands for the timestamp of the run that produces the artifact.

Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

## Command Forms (verified on this machine)

**bash.** The default WSL distribution is `docker-desktop`, which contains no `bash`; a bare
`wsl -e bash` fails with `execvpe(bash) failed`. The toolchain is reachable only through the
`Ubuntu` distribution, where `shfmt`, `shellcheck`, `bats`, and `kcov` are present at `/usr/bin`.
Every bash command in this plan is therefore written in the form:

`wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && <command>'`

**bats output form (observed this pass).** `bats` emits its pretty format only when stdout is a
terminal. Every command in this plan is captured to an evidence artifact, so every `bats` run here
emits TAP: a plan line of the form `1..N`, then one `ok <n> <case name>` line per passing case and
one `not ok <n> <case name>` line per failing case. There is **no** `N tests, 0 failures` summary
line on a captured run. Wherever a task below says "0 failures", the assertion is over the TAP
output: the recorded output contains no line beginning `not ok`. Wherever a task states a case
count, the assertion is over the `1..N` plan line. Verified against the checked-in
`tests/shell/parallel_bash_manifest_membership.bats`, which carries six `@test` blocks and prints
`1..6` followed by six `ok` lines.

`scripts/bash/shell-qc.sh --help` prints "Discovery searches tools/ and scripts/", omitting
`.claude/lib/bash/`. That help text is stale: `scripts/bash/shell_qc_lib.sh:85` includes
`.claude/lib/bash` in the discovery roots and `:335` includes it in the kcov include pattern, so both
new files are linted, formatted, and coverage-measured automatically. No change to the help text is
planned; it is outside this feature's scope.

**Python.** `poetry run black`, `poetry run ruff check`, `poetry run pyright`, `poetry run pytest`,
run from the worktree root. `poetry run python --version` reports 3.13.12 in this worktree. The
project `addopts` value at `pyproject.toml:115` is `-ra --cov-report=lcov:artifacts/python/lcov.info`
and supplies no terminal reporter, so every coverage-bearing pytest command below passes
`--cov-report=term-missing` explicitly.

**TypeScript.** Run from `extensions/drm-copilot`. `npm run lint` wraps `eslint`, `npm run typecheck`
wraps `tsc -p ./ --noEmit`, `npm run format` wraps `prettier --write`, and `npm run test:coverage`
wraps `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`.
`run-jest.cjs` passes its arguments through to Jest after rejecting `--passWithNoTests`,
`--onlyChanged`, and `--lastCommit`.

**PowerShell.** No PowerShell production or test file is added or modified by this feature, so the
PoshQC format/lint loop does not run. One PowerShell suite is executed as a regression check only:
`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`.

**Read-only baselines.** Every Phase 0 baseline uses a read-only command
(`shell-qc.sh check`, `black --check`, `ruff check`, `pyright`, `prettier --check`, `eslint`, `tsc`).
No write-mode formatter runs before a baseline is captured, so no baseline can be taken after a
formatter has silently repaired pre-existing drift.

## Ordering Constraints (read before executing)

1. `tests/shell/parallel_bash_manifest_membership.bats` asserts that every repository
   `.claude/lib/bash/*.sh` file has a `core.json` entry and a byte-identical bundle counterpart. The
   moment Phase 1 creates `.claude/lib/bash/parallel-lane-assertion.sh`, that suite fails until
   Phase 4 mirrors the file and registers it. **Phases 1 through 3 therefore run targeted `bats`
   invocations against named suite files only.** The first whole-tree
   `bash scripts/bash/shell-qc.sh test` run after Phase 0 is P4-T9, which runs after the mirror and
   the `core.json` registration.
2. The parity suites are not run until both the shared corpus and the port exist. The corpus is
   authored in Phase 3, after the entry point lands in Phase 2, and the first parity-suite gate is
   P3-T8.
3. `shell-qc.sh format` must run over the two new bash files **before** they are mirrored into the
   bundle (P4-T1 precedes P4-T2), because the mirror guard is a byte comparison and a later
   reformat would break it. If a formatter run at P4-T1 or P6-T1 rewrites a `.claude/lib/bash/`
   file, that file must be re-copied into its bundle counterpart before the mirror gate runs again;
   re-running the formatter does not re-mirror.
4. The bundle-mirror gate at P5-T11 runs after every `.claude/**` edit and every mirror, and has two
   parts: the pytest suite, whose result is environment-conditional under open issue #510, and a
   `cmp -s` loop over the seven enumerated mirrored files, which is not.
5. Phase 0 baseline commands are classified as implementation commands by
   `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:128-134`
   (`black|ruff|pyright|pytest`, `npx prettier|eslint|tsc|jest`, `pwsh ... tests/scripts/`). Phase 0
   cannot be executed while the orchestration checkpoint is still in preparation mode.

## Literals This Plan Instructs the Executor to Create

The following literals do not exist in the tracked tree yet. They are quoted here verbatim, outside
every command span, so that each acceptance condition asserting them is exonerated rather than read
as a search that can never match:

- `.claude/lib/bash/parallel-lane-assertion.sh`
- `.claude/lib/bash/report-lane-assertion.sh`
- `bash .claude/lib/bash/report-lane-assertion.sh`
- `Bash(bash .claude/lib/bash/report-lane-assertion.sh*)`
- `expected_together_derived_apart`
- `expected_apart_derived_together`
- `member_names_no_item`
- `item_covered_by_no_component`
- `MINIMUM_FIXTURE_COUNT`
- `MINIMUM_LIB_FILE_COUNT=11`
- `Lane assertion: manifest outside the supported YAML subset (`
- `four entry-point-specific allowlist entries`
- `The seven sourceable libraries carry no grant`
- `eleven-file module`
- `the four CLI entry points are present in both trees`
- `the payload directory carries the four entry points`
- `the four published bash entry points`
- `the entry point resolves its own directory before sourcing`
- `the entry point calls pc_enforce_c_locale before any output is produced`
- `the entry point establishes set -euo pipefail as its first executable line`
- `- [x]`

The last entry, `- [x]`, is the checked-checkbox marker that P6-T17 writes into `spec.md` and
`user-story.md`. It occurs zero times in either document today — every criterion line begins `- [ ]`
— so the counting clauses P6-T17 states over it are assertions over lines that task creates, not
searches that can never match. The two documents are LF-only, verified this pass, which is why the
`$` anchor in the awk range pattern those clauses use matches the heading line.

The three case-name entries above it are the exact bats case names P2-T1 creates, one per property enumerated by
`spec.md:559-562`. They are quoted here so that P2-T1's `-f "the entry point"` filter and its
`1..3` plan-line assertion are read as assertions over cases the executor is instructed to create.

`Bash(bash .claude/lib/bash/report-lane-assertion.sh*)` above is the `tools:` entry that P5-T4
adds to the `.claude/agents/parallel-planner.md` persona. It is **not** a
`.claude/settings.json` `permissions.allow` entry; no task in this plan edits
`.claude/settings.json` or its bundle mirror. See Fixed Design Decision 9.

## Fixed Design Decisions (encoded, not relitigated)

1. **bash only.** Two new files, split on the pure-versus-I/O seam the Python reference declares for
   itself at `scripts/dev_tools/parallel_lane_assertion.py:34-38`:
   `.claude/lib/bash/parallel-lane-assertion.sh` (pure library, `pla_` prefix) and
   `.claude/lib/bash/report-lane-assertion.sh` (I/O entry point, `rla_` prefix). No PowerShell
   production file is added.
2. Entry-point name is exactly `report-lane-assertion.sh`.
3. The CLI surface is exactly `--manifest` and `--edges`. There is no `--keys` flag.
4. An out-of-subset manifest (one for which `pm_parse_manifest` returns status 2, per
   `.claude/lib/bash/parallel-manifest-validate.sh:63-96`) prints a distinct refusal line and exits
   0. It is covered by the bash unit suite only and excluded from the parity corpus.
5. `--edges` permissive integer forms are excluded, not reproduced. The port applies the strict lexis
   `^-?(0|[1-9][0-9]*)$` already used at `.claude/lib/bash/compute-cohorts.sh:59`.
6. `MINIMUM_LIB_FILE_COUNT` in `tests/shell/parallel_bash_manifest_membership.bats:21` is raised from
   9 to 11.
7. `.claude/rules/parallel-orchestration.md` is out of scope. No file under `.claude/rules/` is
   edited. Research section 5.3 item 8 records an optional wording addition there; this feature
   declines it.
8. `.claude/agents/parallel-orchestrator.md` is in scope and required: deleting site 2 orphans the
   grant rationale at lines 92-97, which names that CLI as one of two grant consumers.
9. **No `.claude/settings.json` permissions edit — open epic-owner decision.** Preflight round 1
   proposed adding `"Bash(bash .claude/lib/bash/report-lane-assertion.sh*)"` to `permissions.allow`
   in `.claude/settings.json`. This plan adds no such task, because a permissions-scope change is a
   security-relevant configuration decision reserved to the epic owner and that authority has not
   been granted here. The state of the tree, re-derived this pass, is:
   - The three existing bash entry points each carry a project-level grant at
     `.claude/settings.json:8-10` (`Bash(bash .claude/lib/bash/compute-cohorts.sh*)`,
     `Bash(bash .claude/lib/bash/compute-concurrency-batches.sh*)`,
     `Bash(bash .claude/lib/bash/validate-parallel-manifest.sh*)`).
   - The fourth entry point, `.claude/lib/bash/report-lane-assertion.sh`, will not carry one.
   - Adding one would also require editing the bundle mirror
     `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`, because
     `Path(".claude/settings.json")` is a member of the `REQUIRED_BUNDLED_FILES` tuple declared at
     `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:21-31` (the member itself
     is line 22) and is inside the byte-identical `.claude/**` parity scope, plus a re-run of the
     push-down gate (P5-T11) after that edit.
   This item is recorded as an open decision for the epic owner. It is not implementation work in
   this feature, and no acceptance criterion in `spec.md` or `user-story.md` depends on it. The
   persona-level `tools:` entry on `.claude/agents/parallel-planner.md` is a different surface and
   **is** in scope; P5-T4 adds it.

## Corrections and Additions to the Documented Scope

Five items were re-derived against the tree during this revision pass and are recorded here because
the `spec.md` edit table does not carry them. Each has a task in this plan.

1. **`extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` must change.** The
   enumeration at `claude-config-carriage.test.ts:449-456` (array entries at lines 450-455) asserts
   against the hermetic in-memory tree that `seedTree()` builds at
   `config-carriage.test-helpers.ts:136-169`. That helper seeds exactly three bash entry points
   (lines 144-148) and lists exactly three in its `core.json` stub (lines 158-160). Adding a fourth
   path to the assertion list without adding it to both helper lists makes the suite fail. Task
   P4-T7 covers the helper.
2. **`.claude/agents/parallel-planner.md:158-162` carries two counts that this feature invalidates.**
   The paragraph states the bash library is granted as "three entry-point-specific allowlist entries"
   (line 159) and that "The six sourceable libraries carry no grant" (line 162). After this feature
   there are four entry points and seven sourceable libraries. Task P5-T4 corrects both counts.
3. **Two sibling assertions name "three entry points" and become stale.**
   `tests/shell/parallel_bash_manifest_membership.bats:84-89` is a case titled
   "the three CLI entry points are present in both trees", and
   `tests/shell/parallel_payload_only.bats:45-50` is a case titled
   "the payload directory carries the three entry points". Both enumerate exactly the three current
   entry points and both remain green without change, so neither is a failure; both are stale
   documentation of the entry-point set. Tasks P4-T5 and P4-T8 update them. The file header of
   `tests/shell/parallel_payload_only.bats:4` likewise reads "the three published bash entry
   points"; P4-T8 updates it in the same edit.
4. **The deletion of site 1 and site 2 leaves dangling prose.**
   `.claude/skills/epic-orchestrate/SKILL.md:295-299` introduces the MCP form parenthetically as
   "(or the equivalent ...)", and `.claude/skills/parallel-orchestrate/SKILL.md:480-483` ends with
   "adding `--require-complete` at the completion gate", a flag that belongs to the CLI form being
   deleted. Both passages must be rewritten so the MCP form reads as the primary spelling and the
   completion-gate option is expressed as the MCP argument `require_complete`, which is supported
   (`extensions/drm-copilot/src/mcp-tool-definitions.ts:423`,
   `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts:356`). Tasks P5-T1 and P5-T2
   cover this.
5. **`spec.md` and `user-story.md` were corrected after the first plan draft, and this plan now
   follows them rather than substituting for them.** Three acceptance criteria changed:
   - The invocation-count criterion (`spec.md:598-607`, `user-story.md:147-155`) is rewritten and is
     now satisfiable. It asserts that `git grep -n -F "python -m scripts.dev_tools." --
     .claude/skills/` returns exactly one match at
     `.claude/skills/parallel-orchestrate/SKILL.md:817`, down from four before this feature, and
     that `git grep -n -F "poetry run python" -- .claude/skills/` returns exactly two, both declared
     non-goals. P5-T12 asserts exactly that corrected form; no substitution against earlier wording
     is recorded here.
   - Divergence class 3 in `spec.md:338-358` now enumerates **four** reachable members only.
   - The divergence test criterion (`spec.md:566-575`) now pins whitespace inside an endpoint as a
     **convergence** case carried in the shared corpus. P2-T7, P3-T4, P3-T6, and P3-T7 reflect that.

## Line-Number Citations Corrected in Revision Passes

### Corrected in the version 0.4 pass

Four citations were re-derived directly against the tree in the 0.4 pass and corrected:

- `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts`: the `core.json` stub
  `paths` array spans **154-163**. Lines 158-160 are its three `.claude/lib/bash/` entries, not the
  array itself. P4-T7 now cites both spans with that distinction.
- `extensions/drm-copilot/jest.config.cjs`: the `coverageThreshold` key is at line **25** and its
  closing brace is at line **259**, in a file of **260** lines. P0-T12 now states the key line and
  the map's extent rather than describing "lines 25-259" as the thresholds themselves.
- `wc -l <file>` prints the count **followed by the path**, so "prints 310" and "prints 1055" named
  the wrong object. P5-T1 clause (d) and P5-T2 clause (e) now assert the count on that line. The
  values themselves were re-derived and are unchanged: `.claude/skills/epic-orchestrate/SKILL.md` is
  310 lines and `.claude/skills/parallel-orchestrate/SKILL.md` is 1055 lines.
- P5-T5 clause (d) previously asserted a token containing backtick-quoted `poetry run`, which
  required escaping backticks inside a markdown code span. It now asserts two backtick-free
  single-line tokens instead — `as a whole` at line 95 and `remain outside the allowlist` at line 96
  — each of which returns exactly one match against
  `.claude/agents/parallel-orchestrator.md` today.

### Corrected in the version 0.3 pass

Three citations were re-derived directly against the tree in the 0.3 pass and corrected. Each is
recorded here so a later reader can see that the correction was made deliberately rather than
carried forward:

- `run_check` in `scripts/bash/shell_qc_lib.sh` spans **164-202**, not 165-201. Line 164 is the
  `run_check() {` signature and line 202 is its closing brace. P0-T2 now cites 164-202.
- `pm_declared_issue_nums` in `.claude/lib/bash/parallel-manifest-validate.sh` spans **137-157**,
  not 138-157. Line 137 is the `pm_declared_issue_nums() {` signature and line 157 is its closing
  brace; line 158 is blank and is outside the function. P1-T3 now cites 137-157. The preflight
  delta proposed 137-158; that upper bound includes the blank line 158, so 157 is used instead.
- The scoping sentence in `.claude/agents/parallel-orchestrator.md` that begins "to those two
  invocation forms only" begins on line **95**, not 94. Line 94 ends with "Both grants stay
  scoped". P5-T5 now cites 95-96 for that sentence and keeps its separate citation of line 94 for
  the phrase that precedes it.

Two file lengths were also re-derived in the 0.3 pass, re-confirmed in the 0.4 pass, and are
asserted, because six acceptance conditions depend on a line number that a length change would move:
`.claude/skills/parallel-orchestrate/SKILL.md` is **1055** lines and
`.claude/skills/epic-orchestrate/SKILL.md` is **310** lines. P5-T2 clause (e) and P5-T1 clause (d)
assert those values after the edits.

## Corpus Record Shape (fixed here so both lanes agree)

The shared corpus lives at `tests/fixtures/parallel_lane_assertion/*.json`, one record per file,
matching the two existing corpora described in research section 4.1. Each record carries:

- `name` — the fixture identifier.
- `notes` — one sentence naming the behavior the fixture pins.
- `manifest_path` — repo-relative path to a checked-in manifest under
  `tests/fixtures/parallel_lane_assertion/manifests/`. Both lanes pass this value to `--manifest`.
- `manifest_text` — the exact UTF-8 content of the file at `manifest_path`, carried because
  `spec.md` fixes this field in the record shape. A dedicated case in each lane asserts
  `manifest_text` equals the file's content, so the two can never drift.
- `edges` — the raw `--edges` string.
- `expected_stdout` — the full report as one string with `\n` separators and no trailing newline.
- `expected_status` — always 0.
- `divergence` — optional marker.

The manifests subdirectory does not pollute the corpus glob, which is `*.json` at depth 1.

Bash-only fixtures that have **no** Python counterpart — the out-of-subset manifest and the
unreadable-manifest path — live under `tests/fixtures/parallel_lane_assertion_bash/`, deliberately
outside `tests/fixtures/parallel_lane_assertion/`, so the `spec.md` acceptance criterion that
requires those inputs to appear in no file under the corpus directory holds by construction.

**Divergence class 3 has exactly four members; whitespace is a convergence case.** `spec.md:338-358`
now enumerates the excluded `--edges` input class as exactly four members: an endpoint token bearing
a leading zero, a leading `+`, an underscore digit separator, or a non-ASCII decimal digit. The
bash-only pinning test P2-T7 covers those four and nothing else.

Whitespace inside an endpoint is **not** a member of class 3. It is unreachable through the
`--edges` surface in **both** implementations: `scripts/dev_tools/parallel_lane_assertion.py:425`
splits the value with `str.split()` before `token.partition(":")` at line 426, so no resulting token
can carry interior whitespace, and the bare `:` token that `--edges "101 : 202"` produces reaches
`int("")` and is discarded by the `ValueError` path at lines 430-431. The port consumes the same
whitespace-separated token stream, so the two implementations converge on that input.

Because they converge, the whitespace case is carried **inside** the shared corpus at
`tests/fixtures/parallel_lane_assertion/` as a convergence record rather than by the bash-only
divergence test. Its `expected_stdout` is reproduced byte-for-byte by both parity lanes, and it is
identical to the `expected_stdout` of the record that pairs the same manifest with an empty `--edges`
value. P3-T4 creates the pair and P3-T6 asserts the byte equality between them.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Capture and Policy Reads

- [ ] [P0-T1] Read the policy files in the order defined by `policy-compliance-order` and record the
      read in `evidence/baseline/phase0-instructions-read.<timestamp>.md`. Order: `CLAUDE.md`,
      `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`,
      `.claude/rules/quality-tiers.md`, `.claude/rules/shell.md`, `.claude/rules/python.md`,
      `.claude/rules/python-suppressions.md`, `.claude/rules/typescript.md`,
      `.claude/rules/typescript-suppressions.md`, `.claude/rules/plan-acceptance-gates.md`,
      `.claude/rules/tonality.md`.
  - Acceptance: the artifact exists and contains `Timestamp:`, `Policy Order:`, and the eleven file
    paths above listed in that exact order.

- [ ] [P0-T2] Capture the bash format-and-lint baseline by running
      `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bash scripts/bash/shell-qc.sh check'`
      and record it in `evidence/baseline/bash-check.<timestamp>.md`.
  - Acceptance: the artifact records `Command:`, `EXIT_CODE:`, and an `Output Summary:` that
    reproduces the command's stdout and stderr verbatim. `shell-qc.sh check` is read-only (it runs
    `shfmt -d` then `shellcheck` per file and returns the maximum exit code, per
    `scripts/bash/shell_qc_lib.sh:164-202`), so its exit code alone distinguishes a clean tree from a
    drifted one.
  - Expected value, verified against the pre-Phase-1 tree: `EXIT_CODE: 0` with empty output. Any
    other result at this baseline is pre-existing drift and must be reported before Phase 1 begins,
    because P4-T1's attribution argument depends on this baseline being clean.

- [ ] [P0-T3] Capture the bash coverage baseline by running
      `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bash scripts/bash/shell-qc.sh test --coverage'`
      and record it in `evidence/baseline/bash-coverage.<timestamp>.md`.
  - Acceptance: the artifact's `Output Summary:` records the numeric headline the run prints in the
    form produced by `scripts/bash/shell_qc_lib.sh:290-291`, `Bash coverage (lines): NN.N%`, with
    `NN.N` a real measured value and not a placeholder, together with the bats pass and fail counts.
    `EXIT_CODE:` is recorded as observed.
  - Reference value, verified against the pre-Phase-1 tree: `Bash coverage (lines): 91.4%` over 251
    bats cases. This is recorded as a reference point for the P6-T14 delta, not as an equality
    assertion: this feature adds bats cases and two measured production files, so both the
    percentage and the case count will move. The no-regression comparison in P6-T14 is against the
    value this task actually records, and the gate in P6-T4 is the >= 85.0 floor.

- [ ] [P0-T4] Capture the Python format baseline by running `poetry run black --check .` from the
      worktree root and record it in `evidence/baseline/python-black-check.<timestamp>.md`.
  - Acceptance: the artifact records `EXIT_CODE:` and reproduces the command's output verbatim in
    `Output Summary:`. `--check` makes the command read-only, so the exit code is the discriminator
    and no file is rewritten before the baseline is taken.

- [ ] [P0-T5] Capture the Python lint baseline by running `poetry run ruff check .` from the worktree
      root and record it in `evidence/baseline/python-ruff.<timestamp>.md`.
  - Acceptance: the artifact records `EXIT_CODE: 0` and an `Output Summary:` whose stdout is exactly
    `All checks passed!`. That value was observed on this worktree against the clean tree before
    planning, so it is the recorded success-case output rather than an inferred one.
  - Read-only finding: `ruff check` does not rewrite in this repository. `[tool.ruff]` in
    `pyproject.toml:88-91` sets only `line-length`, `target-version`, and `show-fixes`; there is no
    `fix = true`, and `--fix` is not passed. `show-fixes` changes the diagnostic display only. The
    plan-acceptance gate's G7 heuristic classifies `ruff` as write-mode conservatively; that warning
    is expected here and is not a defect. The exit code plus the `All checks passed!` line are both
    recorded so the acceptance does not rest on the exit code alone.

- [ ] [P0-T6] Capture the Python type-check baseline by running `poetry run pyright` from the
      worktree root and record it in `evidence/baseline/python-pyright.<timestamp>.md`.
  - Acceptance: the artifact records `EXIT_CODE:` and reproduces the summary line the run prints,
    verbatim, in `Output Summary:`.

- [ ] [P0-T7] Capture the Python coverage baseline over the reference module by running
      `poetry run pytest tests/scripts/dev_tools/test_parallel_lane_assertion.py --cov=scripts.dev_tools.parallel_lane_assertion --cov-report=term-missing -p no:cacheprovider`
      and record it in `evidence/baseline/python-lane-assertion-coverage.<timestamp>.md`.
  - Acceptance: the artifact records `EXIT_CODE: 0`, the pytest pass count, and the numeric
    percentage printed on the `scripts/dev_tools/parallel_lane_assertion.py` row of the
    `term-missing` table. The `--cov` value is the importable dotted module name, and
    `--cov-report=term-missing` is supplied because the project `addopts` value at
    `pyproject.toml:115` provides an LCOV reporter only.

- [ ] [P0-T8] Capture the bundle-mirror baseline by running
      `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q -p no:cacheprovider`
      and record it in `evidence/baseline/python-pushdown-contracts.<timestamp>.md`.
  - Acceptance: the artifact records the observed `EXIT_CODE:` and the observed pytest summary line
    verbatim. The result is **environment-conditional** and is accepted under exactly one condition:
    - `EXIT_CODE: 0` with all cases passing is a pass; or
    - a non-zero exit code is accepted **only** when the sole assertion message in the recorded
      output names a path under `.claude/state/`, for example
      `AssertionError: Repo file missing from bundle: .claude/state/python-batch-budget.default.json`.
      Any other assertion message is a blocking finding.
  - Mechanism, re-derived this pass: `list_scoped_files`
    (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:34-43`) walks the
    filesystem with `rglob("*")` and reads no `.gitignore`, and the caller at lines 113-117 excludes
    only `.claude/settings.local.json` and `.claude/agent-memory/**`. `.claude/state/` is gitignored
    at `.gitignore:68` and is written during this run by
    `.claude/hooks/persist-session-id.ps1:150` and
    `.claude/hooks/enforce-python-batch-budget.ps1:185`. This is open issue #510, confirmed OPEN.
  - Deleting the state file is **not** a remedy: it regenerates within the same session, so a
    deletion clears the gate only until the next hook fires.
  - The durable, environment-independent mirror gate is the `cmp -s` loop in P5-T11; this baseline
    records the starting condition only.

- [ ] [P0-T9] Capture the TypeScript format baseline by running
      `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` from
      `extensions/drm-copilot` and record it in `evidence/baseline/ts-prettier-check.<timestamp>.md`.
  - Acceptance: the artifact records `EXIT_CODE:` and reproduces the command's output verbatim.
    `--check` makes the command read-only.

- [ ] [P0-T10] Capture the TypeScript lint baseline by running `npm run lint` from
      `extensions/drm-copilot` and record it in `evidence/baseline/ts-eslint.<timestamp>.md`.
  - Acceptance: the artifact records `EXIT_CODE:` and reproduces the command's output verbatim.

- [ ] [P0-T11] Capture the TypeScript type-check baseline by running `npm run typecheck` from
      `extensions/drm-copilot` and record it in `evidence/baseline/ts-typecheck.<timestamp>.md`.
  - Acceptance: the artifact records `EXIT_CODE:` and reproduces the command's output verbatim.

- [ ] [P0-T12] Capture the TypeScript coverage baseline by running `npm run test:coverage` from
      `extensions/drm-copilot` and record it in `evidence/baseline/ts-coverage.<timestamp>.md`.
  - Acceptance: the artifact records `EXIT_CODE:` as observed, the Jest `Tests:` line verbatim, and
    the four numeric percentages from the `text-summary` reporter block (Statements, Branches,
    Functions, Lines). The whole suite is run rather than a subset because
    `extensions/drm-copilot/jest.config.cjs:17` sets `collectCoverageFrom` to all of `src/**/*.ts`
    and the `coverageThreshold` key at line 25 opens a per-file threshold map whose closing brace is
    at line 259 of that 260-line file, so a subset run reports 0% for every untested production file
    and fails thresholds for reasons unrelated to this feature.

- [ ] [P0-T13] Capture the PowerShell no-Python-invocation regression baseline by running
      `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 -CI"`
      from the worktree root and record it in
      `evidence/baseline/powershell-no-python-invocation.<timestamp>.md`.
  - Acceptance: the artifact records `EXIT_CODE: 0` and reproduces the Pester run summary verbatim
    in `Output Summary:`, with a failed count of 0. The acceptance is the summary and the exit code,
    not the presence of individual case names, because Pester's default verbosity prints per-case
    names for failures only. The suite's own cases `ships an empty allowlist` (line 102) and
    `reports no Python invocation beyond the allowlist across the guarded tree` (line 473) are what a
    failed count of 0 certifies.

### Phase 1 — Pure bash library `.claude/lib/bash/parallel-lane-assertion.sh`

Each task in this phase adds one function group to the library and the bats cases that exercise it,
then runs only those cases. No whole-tree bash test run occurs in this phase; see Ordering
Constraint 1.

- [ ] [P1-T1] Create `.claude/lib/bash/parallel-lane-assertion.sh` carrying the module header, the
      self-directory resolution and `source` of `.claude/lib/bash/parallel-manifest-validate.sh` in
      the form `.claude/lib/bash/compute-cohorts.sh:29-32` uses, the four class-token constants
      holding the exact strings `expected_together_derived_apart`,
      `expected_apart_derived_together`, `member_names_no_item`, and `item_covered_by_no_component`,
      the informational-kind set holding only the last of those four, and the edge separator `:`.
      Create `tests/shell/parallel_lane_assertion.bats` with a case named
      `the library declares the four finding-class tokens` that sources the library and asserts each
      constant's value.
  - Acceptance:
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion.bats -f "the library declares the four finding-class tokens"'`
    exits 0, and the captured output carries the TAP plan line `1..1`, exactly one line beginning
    `ok 1`, and no line beginning `not ok`.
  - Output-form note, observed this pass: bats emits its pretty format only when stdout is a
    terminal. On a captured (redirected) run it emits TAP, so the summary line `1 test, 0 failures`
    is **not** printed and must not be asserted. This was verified against the checked-in
    `tests/shell/parallel_bash_manifest_membership.bats`, which carries six `@test` blocks (lines
    33, 38, 43, 56, 73, and 84) and prints `1..6` followed by six `ok` lines on a captured run.
    Every bats acceptance in this plan is stated over TAP output for that reason.

- [ ] [P1-T2] Add `pla_parse_edges` to `.claude/lib/bash/parallel-lane-assertion.sh`, splitting the
      `--edges` value on whitespace, partitioning each token on its first colon, dropping a token
      with no colon and a token whose endpoint falls outside the lexis `^-?(0|[1-9][0-9]*)$`, and
      preserving input order. Add the bats case `parse_edges keeps input order and drops malformed
      tokens` covering an empty value, a whitespace-only value, a token with no colon, a token with
      two colons, and a token with a non-integer endpoint.
  - Acceptance:
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion.bats -f "parse_edges"'`
    exits 0 with 0 failures.

- [ ] [P1-T3] Add `pla_read_manifest_inputs` to `.claude/lib/bash/parallel-lane-assertion.sh`,
      consuming the node table already populated by `pm_parse_manifest` and reading
      `expected_conflict_components` through `yp_has`, `yp_type_of`, `yp_count_of`, and `yp_value_of`
      in the manner `.claude/lib/bash/parallel-manifest-validate.sh:203-237` already does, and
      reading `items[].issue_num` in the manner `pm_declared_issue_nums` at lines 137-157 does.
      Skip a non-list `expected_conflict_components`, a non-map entry, a non-list `members`, and a
      non-string `name`; keep a member only when it is a positive integer and not a boolean; keep
      members in manifest order without de-duplication; return item keys de-duplicated and sorted
      ascending with `sort -n`. Add the bats case `read_manifest_inputs skips malformed entries
      without raising`.
  - Acceptance:
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion.bats -f "read_manifest_inputs"'`
    exits 0 with 0 failures.

- [ ] [P1-T4] Add `pla_derive_components` to `.claude/lib/bash/parallel-lane-assertion.sh`, seeding
      adjacency from every declared key so an isolated vertex survives, skipping an edge whose
      endpoints are equal or whose endpoint is not a declared key, building symmetric set-valued
      adjacency so direction and duplicates collapse, running BFS from each unvisited root in
      ascending key order with the visited set marked at enqueue time, sorting each component's
      members ascending, and ordering components by lowest member. Add the bats case
      `derive_components partitions declared keys deterministically` covering an isolated vertex, a
      self-loop, an undeclared endpoint, and reversed plus duplicated edges.
  - Acceptance:
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion.bats -f "derive_components"'`
    exits 0 with 0 failures.

- [ ] [P1-T5] Add `pla_find_split_lanes`, `pla_find_merged_lanes`, and `pla_compare` to
      `.claude/lib/bash/parallel-lane-assertion.sh`, emitting findings grouped by class in the fixed
      order split, merged, unknown-member, uncovered-item; visiting expected components in manifest
      order within the split class and derived components in derived order within the merged class;
      visiting keys ascending within the last two classes; building the expected index in manifest
      order so the last occurrence of a repeated key wins without an error being reported; and
      sorting every finding's own member list ascending. Add the bats case
      `compare emits findings in the fixed class order` covering one finding of each of the four
      classes and a repeated key across two expected components.
  - Acceptance:
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion.bats -f "compare emits findings"'`
    exits 0 with 0 failures.

- [ ] [P1-T6] Add `pla_format_report` to `.claude/lib/bash/parallel-lane-assertion.sh`, emitting the
      header `Lane assertion: {N} derived conflict component(s); {D} disagreement(s).`, one
      `ADVISORY [{kind}] {detail}.` line per finding using the four detail templates recorded in
      `spec.md`, and the closing line
      `Advisory only: this diagnostic never blocks, never modifies a derived edge, never feeds compute_cohorts, and never influences scheduling.`,
      joined with `\n`, with `D` counting the first three classes only. Render a component label as
      `'{name}'` when the component carries a string `name` (including the empty string) and as
      `component[{position}]` otherwise, with `position` the zero-based manifest index, and render a
      derived component's member list in the Python list form `[101, 102]`. Add the bats case
      `format_report renders the header, findings, and closing line` covering an absent name, an
      empty-string name, and a two-member derived component.
  - Acceptance:
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion.bats -f "format_report"'`
    exits 0 with 0 failures.

- [ ] [P1-T7] Verify `.claude/lib/bash/parallel-lane-assertion.sh` is inside the 500-line cap by
      running
      `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && wc -l .claude/lib/bash/parallel-lane-assertion.sh'`
      and record the count in `evidence/qa-gates/bash-file-size.<timestamp>.md`.
  - Acceptance: the recorded line count is 500 or fewer. If it exceeds 500, split derivation from
    comparison-and-formatting along the `parallel-yaml-scan.sh` / `parallel-yaml-emit.sh` precedent
    named in `spec.md` and re-run this task.

- [ ] [P1-T8] Verify the library is shellcheck-clean and shfmt-clean by running
      `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && shfmt -d .claude/lib/bash/parallel-lane-assertion.sh && shellcheck .claude/lib/bash/parallel-lane-assertion.sh'`
      and record the result in `evidence/qa-gates/bash-library-lint.<timestamp>.md`.
  - Acceptance: `EXIT_CODE: 0` and empty stdout. `shfmt -d` prints a unified diff and returns
    non-zero when the file needs reformatting, so both halves are read-only and falsifiable.

### Phase 2 — Entry point `.claude/lib/bash/report-lane-assertion.sh`

- [ ] [P2-T1] Create `.claude/lib/bash/report-lane-assertion.sh` with `set -euo pipefail` as its
      first executable line, self-directory resolution before sourcing
      `.claude/lib/bash/parallel-lane-assertion.sh`, a `pc_enforce_c_locale` call before any work in
      the manner `.claude/lib/bash/compute-cohorts.sh:34` uses, the usage text, `--manifest` and
      `--edges` flag parsing, the manifest read via `cat`, dispatch to the library, a single `printf`
      of the report with one trailing newline, and the
      `[[ ${BASH_SOURCE[0]} == "${0}" ]]` guard that `compute-cohorts.sh:139-143` uses. Add **three**
      bats cases to `tests/shell/parallel_lane_assertion.bats`, one per property, named exactly:
      `the entry point resolves its own directory before sourcing`, which invokes the script from a
      working directory other than the repository root and asserts it still runs;
      `the entry point calls pc_enforce_c_locale before any output is produced`, which reads the file
      and asserts the `pc_enforce_c_locale` call precedes the first `printf`; and
      `the entry point establishes set -euo pipefail as its first executable line`, which reads the
      file and asserts its first non-comment, non-blank line is `set -euo pipefail`.
  - Three cases are created rather than one because the matching criterion at `spec.md:559-562`
    enumerates three separate properties — the entry point resolves its own directory before
    sourcing, `pc_enforce_c_locale` is called before any output, and the first executable line
    establishes `set -euo pipefail` — and P6-T17 may mark that criterion PASS only against a case
    set that matches its enumeration. A single case asserting all three would leave P6-T17 marking
    a three-property criterion against a one-case set.
  - Acceptance:
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion.bats -f "the entry point"'`
    exits 0, and the captured output carries the TAP plan line `1..3`, exactly three lines beginning
    `ok`, and no line beginning `not ok`.
  - The filter selects exactly these three cases: no case name added by Phase 1 (P1-T1 through
    P1-T6) contains the substring `the entry point`, and the only two later case names that do —
    `the entry point exits 2 only on a usage error` (P2-T2) and `the entry point rejects a --keys
    flag` (P2-T3) — do not exist when this task runs. Once P2-T2 lands, a `-f "the entry point"`
    run matches more than three cases, so this acceptance is stated for the state of the suite at
    this task only and is not re-used later.

- [ ] [P2-T2] Implement the exit-code contract in `.claude/lib/bash/report-lane-assertion.sh`: exit 2
      with usage text on stderr for an unknown flag or a missing `--manifest`; exit 0 with usage text
      on stdout for `--help`; exit 0 on every other path. Add the bats case
      `the entry point exits 2 only on a usage error` covering an unknown flag, a missing
      `--manifest`, and `--help`.
  - Acceptance:
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion.bats -f "the entry point exits 2 only on a usage error"'`
    exits 0 with 0 failures.

- [ ] [P2-T3] Add the bats case `the entry point rejects a --keys flag` to
      `tests/shell/parallel_lane_assertion.bats`, invoking
      `bash .claude/lib/bash/report-lane-assertion.sh --keys "101 102" --manifest tests/fixtures/parallel_manifest_payload/parallel.md`
      and asserting exit status 2 with the usage text written to stderr, pinning that no `--keys`
      flag was added.
  - Acceptance:
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion.bats -f "rejects a --keys flag"'`
    exits 0 with 0 failures.

- [ ] [P2-T4] Implement the manifest-unreadable path in
      `.claude/lib/bash/report-lane-assertion.sh`, printing
      `Lane assertion: manifest unreadable ({detail}); no comparison made.` and exiting 0. Add the
      bats case `an unreadable manifest prints the unreadable line and exits 0`, which asserts the
      exact prefix `Lane assertion: manifest unreadable (` and exit status 0 using the checked-in
      non-existent path `tests/fixtures/parallel_lane_assertion_bash/no-such-manifest.md`. The suite
      header records divergence class 4: Python emits the `OSError` string, which bash cannot
      reproduce, so only the prefix is parity-scoped and the class is excluded from the shared
      corpus.
  - Acceptance:
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion.bats -f "an unreadable manifest"'`
    exits 0 with 0 failures.

- [ ] [P2-T5] Implement the manifest-unparseable path in
      `.claude/lib/bash/report-lane-assertion.sh`, printing
      `Lane assertion: manifest unparseable ({first M1 error}).` and exiting 0, reusing the M1
      message text that `pm_parse_manifest` appends to `PC_ERRORS` with `PM_CONTEXT` left at its
      declared value `Parallel manifest` (`.claude/lib/bash/parallel-manifest-validate.sh:37`), so
      the four M1 strings are reused byte-for-byte rather than restated. Create the checked-in
      fixture `tests/fixtures/parallel_lane_assertion_bash/not-a-mapping.md` and add the bats case
      `an unparseable manifest prints the M1 error and exits 0`.
  - Acceptance:
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion.bats -f "an unparseable manifest"'`
    exits 0 with 0 failures, and the asserted output is exactly
    `Lane assertion: manifest unparseable (Parallel manifest frontmatter must be a mapping.).`

- [ ] [P2-T6] Implement the out-of-subset path in `.claude/lib/bash/report-lane-assertion.sh`,
      printing the distinct refusal line
      `Lane assertion: manifest outside the supported YAML subset ({detail}); no comparison made.`
      and exiting 0 when `pm_parse_manifest` returns status 2, using `PM_SUBSET_DETAIL` as the
      detail. Create the checked-in fixture
      `tests/fixtures/parallel_lane_assertion_bash/out-of-subset.md` carrying a non-empty flow
      collection, and add the bats case
      `an out-of-subset manifest prints the refusal line and exits 0`, which also asserts that the
      out-of-subset construct appears in no file under `tests/fixtures/parallel_lane_assertion/`.
      **The corpus-absence half of the case must treat a missing directory as a pass.** When this
      task runs, `tests/fixtures/parallel_lane_assertion/` does not exist: it is first created by
      P3-T1. A bare `grep -r` over a missing directory exits 2 and would fail the case for a reason
      unrelated to the property under test. Write the half as: if the directory does not exist, the
      assertion holds; otherwise the recursive search must return no match. That guard makes the
      half vacuous while the directory is absent, which is intentional and stated here — the half
      becomes load-bearing only at the whole-tree re-runs P4-T9 and P6-T4, once the corpus exists.
      The independent, non-vacuous assertion that no corpus record carries an excluded `--edges`
      form is P3-T7, which runs against a populated corpus.
  - Acceptance:
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion.bats -f "an out-of-subset manifest"'`
    exits 0 with 0 failures, and the asserted stdout begins with the literal
    `Lane assertion: manifest outside the supported YAML subset (` and the asserted exit status is 0.

- [ ] [P2-T7] Add the bats case `the port drops an --edges endpoint outside the strict integer lexis`
      to `tests/shell/parallel_lane_assertion.bats`, pinning divergence class 3. Using the
      checked-in manifest `tests/fixtures/parallel_manifest_payload/parallel.md`, which declares
      exactly `issue_num` 101 and 202, invoke the entry point once per excluded form —
      `--edges "0101:202"` (leading zero), `--edges "+101:202"` (leading `+`),
      `--edges "1_01:202"` (underscore digit separator), and one whose first endpoint is written with
      non-ASCII decimal digits — and assert in every case that the header reads
      `Lane assertion: 2 derived conflict component(s); 0 disagreement(s).`, which is the two-component
      result produced when the edge is dropped, whereas the Python reference coerces each of those
      endpoints to 101 and produces a one-component header. Divergence class 3 has exactly these
      four members and this case covers all four and nothing else.
      Record in the suite header that interior or surrounding whitespace inside an endpoint is
      **not** a member of class 3: it is unreachable in both implementations, which therefore
      converge on it, so it is pinned as a convergence record inside the shared corpus by P3-T4 and
      P3-T6 rather than by this divergence case. Do not add a whitespace form to this case.
      The corpus-absence half of the matching acceptance criterion — that no such input appears in
      any file under `tests/fixtures/parallel_lane_assertion/` — is discharged by P3-T7, which runs
      against a populated corpus. P6-T17 maps that criterion to both task IDs.
  - Acceptance:
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion.bats -f "outside the strict integer lexis"'`
    exits 0 with 0 failures.

- [ ] [P2-T8] Add the bats case `no library file sources the diagnostic` to
      `tests/shell/parallel_lane_assertion.bats`, asserting that no file under `.claude/lib/bash/`
      other than `report-lane-assertion.sh` sources `parallel-lane-assertion.sh`, and that no file
      under `.claude/lib/bash/` sources `report-lane-assertion.sh`, pinning that the diagnostic feeds
      no cohort, validation, or scheduling module.
  - Acceptance:
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion.bats -f "no library file sources the diagnostic"'`
    exits 0 with 0 failures.

- [ ] [P2-T9] Verify `.claude/lib/bash/report-lane-assertion.sh` is inside the 500-line cap and is
      lint-clean by running
      `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && wc -l .claude/lib/bash/report-lane-assertion.sh && shfmt -d .claude/lib/bash/report-lane-assertion.sh && shellcheck .claude/lib/bash/report-lane-assertion.sh'`
      and record the result in `evidence/qa-gates/bash-entry-point-lint.<timestamp>.md`.
  - Acceptance: `EXIT_CODE: 0`, the recorded line count is 500 or fewer, and the `shfmt -d` and
    `shellcheck` halves produce empty output.

- [ ] [P2-T10] Run the whole bash unit suite once by
      `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion.bats'`
      and record the result in `evidence/regression-testing/bash-unit-suite.<timestamp>.md`.
  - Acceptance: `EXIT_CODE: 0`; the recorded TAP output carries a plan line of `1..16` or a higher
    count; and it contains no line beginning `not ok`. Sixteen is the floor because Phases 1 and 2
    add sixteen cases: six in P1-T1 through P1-T6, three in P2-T1, and one each in P2-T2 through
    P2-T8. The plan line is asserted rather than a `16 tests, 0 failures` summary, because a
    captured bats run emits TAP and prints no such summary line.
  - This is a single-file invocation rather than `shell-qc.sh test` for an ordering reason, not a
    scoping preference: `shell-qc.sh test` runs the whole `tests/shell` directory, which includes
    `tests/shell/parallel_bash_manifest_membership.bats`. That suite discovers every repository
    `.claude/lib/bash/*.sh` file and requires each to carry a `core.json` entry and a byte-identical
    bundle counterpart. Phase 1 created two such files, and neither is mirrored or registered until
    Phase 4 (P4-T2 and P4-T3), so a whole-tree run here would fail for reasons unrelated to the
    suite under test. The first whole-tree run is P4-T9.

### Phase 3 — Shared parity corpus and the two parity lanes

- [ ] [P3-T1] Create the manifest fixtures
      `tests/fixtures/parallel_lane_assertion/manifests/*.md` covering the assertion-free shapes: a
      manifest with two items declaring exactly `issue_num` 101 and 202 and no
      `expected_conflict_components` key, a manifest with an empty `items` list and no assertion, and
      a manifest declaring 69 items across 13 lanes. The two-item manifest's keys are pinned to 101
      and 202 so that P3-T4's whitespace convergence pair names a determinate manifest.
  - Acceptance: the three files exist, and for every file in
    `tests/fixtures/parallel_lane_assertion/manifests/*.md` the **first line** of the entry point's
    stdout matches the extended regular expression
    `^Lane assertion: [0-9]+ derived conflict component\(s\); [0-9]+ disagreement\(s\)\.$`,
    verified by
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && rc=0; for f in tests/fixtures/parallel_lane_assertion/manifests/*.md; do bash .claude/lib/bash/report-lane-assertion.sh --manifest "$f" | head -n 1 | grep -Eq "^Lane assertion: [0-9]+ derived conflict component\(s\); [0-9]+ disagreement\(s\)\.$" || { echo "BAD HEADER: $f"; rc=1; }; done; exit $rc'`
    exiting 0 with no `BAD HEADER:` line in its output.
  - Why the exit status is not the discriminator: `.claude/lib/bash/report-lane-assertion.sh` exits
    0 on every non-usage path by design (Fixed Design Decision 4 and the spec's exit-code contract),
    including the manifest-unreadable, manifest-unparseable, and out-of-subset refusal paths. A loop
    that only tests `|| exit 1` therefore returns 0 for a malformed fixture exactly as it does for a
    valid one and can never fail. The header line is what distinguishes a fixture the diagnostic
    actually compared from one it refused.

- [ ] [P3-T2] Create the manifest fixtures under
      `tests/fixtures/parallel_lane_assertion/manifests/` covering the component-shape edge cases: a
      component with `name` absent, a component with `name: ''`, a component whose members include a
      non-positive value, a component whose members include a boolean, a component whose members are
      all dropped, a component carrying a duplicate member, and two components claiming the same
      `issue_num`.
  - Acceptance: the seven files exist, and the same header-line loop command as P3-T1 exits 0 with
    no `BAD HEADER:` line in its output, now covering all ten manifests in the directory. The
    header line is the discriminator for the same reason recorded in P3-T1: the entry point exits 0
    on every non-usage path, so its exit status cannot distinguish a compared fixture from a
    refused one.

- [ ] [P3-T3] Create the corpus records
      `tests/fixtures/parallel_lane_assertion/*.json` for the assertion-free and component-shape
      fixtures, each carrying `name`, `notes`, `manifest_path`, `manifest_text`, `edges`,
      `expected_stdout`, and `expected_status: 0`, with `expected_stdout` derived by running the
      Python reference `poetry run python -m scripts.dev_tools.parallel_lane_assertion` over the
      fixture and recording its stdout with the trailing newline stripped.
  - Acceptance: at least ten `*.json` records exist at depth 1 under
    `tests/fixtures/parallel_lane_assertion/`, and every record's `expected_status` is 0.

- [ ] [P3-T4] Create the remaining corpus records covering the edge-derivation cases: a self-loop
      edge, an edge naming an undeclared key, reversed and duplicated edges, a token with no colon,
      a token with two colons, a token with a non-integer endpoint, an empty `edges` value, a
      whitespace-only `edges` value, a merged-class disagreement, a split-class disagreement, a
      `member_names_no_item` finding, and the 13-lane 69-item scale case, each with
      `expected_stdout` derived the same way as in P3-T3.
      **The record carrying a non-integer endpoint must use a non-numeric endpoint**, for example
      `abc:202`, so that it cannot collide with any of the four excluded class-3 forms P3-T7 asserts
      against: `abc` carries no leading zero followed by a further digit, no leading `+`, no
      underscore, and no non-ASCII decimal digit, so it passes P3-T7's check with no exemption.
      Additionally create the **whitespace convergence pair** required by `spec.md:566-575`: a
      record named `edges_endpoint_interior_whitespace` whose `edges` value is `101 : 202` against
      the two-item manifest P3-T1 creates, which declares exactly `issue_num` 101 and 202, carrying
      `divergence: null` and a `notes`
      sentence stating that both implementations split on whitespace and therefore converge; and a
      record named `edges_empty` whose `edges` value is the empty string against the **same**
      `manifest_path`. Both records' `expected_stdout` values are derived from the Python reference
      exactly as in P3-T3 and must come out byte-identical to each other; P3-T6 asserts that
      equality.
  - Acceptance: the corpus holds at least 20 `*.json` records at depth 1 under
    `tests/fixtures/parallel_lane_assertion/`, verified by
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && find tests/fixtures/parallel_lane_assertion -maxdepth 1 -name "*.json" -type f | wc -l'`
    printing a value of 20 or greater.

- [ ] [P3-T5] Create `tests/shell/parallel_lane_assertion_parity.bats` with a header declaring all
      five divergence classes — recording that class 3 has exactly four members and that whitespace
      inside an endpoint is a convergence case carried in the corpus, not a class-3 member — a
      `MINIMUM_FIXTURE_COUNT` constant set to 20, a case named
      `the lane-assertion parity corpus meets the declared floor`, a case named
      `python3 is available to read the corpus`, and a case named
      `the bash lane reproduces every lane-assertion corpus fixture` that invokes
      `bash .claude/lib/bash/report-lane-assertion.sh --manifest <manifest_path> --edges <edges>`
      as a subprocess per fixture and compares both `$output` against `expected_stdout` and `$status`
      against `expected_status`.
  - Acceptance:
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion_parity.bats'`
    exits 0, its TAP plan line reports `1..3` or a higher count, and its output contains no line
    beginning `not ok`.

- [ ] [P3-T6] Add to `tests/shell/parallel_lane_assertion_parity.bats` a case named
      `every finding class appears in the corpus`, asserting that each of
      `expected_together_derived_apart`, `expected_apart_derived_together`, `member_names_no_item`,
      and `item_covered_by_no_component` appears in the `expected_stdout` of at least one corpus
      record; a case named `at least one corpus fixture carries an ADVISORY line and status 0`,
      asserting `expected_status` is 0 for every record including at least one whose
      `expected_stdout` contains an `ADVISORY` line; and a case named
      `every corpus record's manifest_text matches its manifest_path`, asserting the embedded text
      equals the file's content; and a case named
      `the whitespace endpoint fixture converges with the empty-edges fixture`, asserting that the
      record named `edges_endpoint_interior_whitespace` and the record named `edges_empty` name the
      same `manifest_path` and carry byte-identical `expected_stdout` values, which is the
      convergence property `spec.md:566-575` requires.
  - Acceptance:
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion_parity.bats'`
    exits 0, its TAP plan line reports `1..7` or a higher count, and its output contains no line
    beginning `not ok`.

- [ ] [P3-T7] Add to `tests/shell/parallel_lane_assertion_parity.bats` a case named
      `no corpus fixture carries an excluded edges endpoint form`, asserting that no colon-bearing
      token in any record's `edges` value has an endpoint matching any of the four excluded forms of
      divergence class 3: a leading zero followed by a further digit, a leading `+`, an underscore
      anywhere in the endpoint, or a non-ASCII decimal digit. This is the independent, non-vacuous
      assertion that divergence class 3 is excluded from the shared corpus, and it is what makes the
      guarded corpus-absence half of P2-T6 unnecessary as a gate.
  - The assertion is stated over the **four excluded forms** rather than as "every endpoint matches
    `^-?(0|[1-9][0-9]*)$`". The stricter phrasing would fail on legitimate corpus members: the
    convergence record `edges_endpoint_interior_whitespace` carries `edges` value `101 : 202`, whose
    whitespace-separated tokens are `101`, `:`, and `202`, and the bare `:` token has an empty
    endpoint that matches no integer lexis.
  - **No record and no token is exempted.** The four-form check applies to every colon-bearing token
    in every corpus record. The P3-T4 records that deliberately carry a token with no colon, two
    colons, or a non-integer endpoint pass it without an exemption, because none of their endpoints
    carries a leading zero followed by a further digit, a leading `+`, an underscore, or a non-ASCII
    decimal digit — the non-integer endpoint is the non-numeric value `abc` that P3-T4 pins for this
    reason. A record-level exemption would be unnecessary and would weaken the check: it would allow
    a genuine class-3 form to sit inside an exempted record undetected.
  - Acceptance:
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion_parity.bats -f "excluded edges endpoint form"'`
    exits 0, its TAP output carries a plan line of `1..1`, and it contains no line beginning
    `not ok`.

- [ ] [P3-T8] Create `tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py` with the
      same five declared divergence classes in its module docstring, stated in the same corrected
      form as the bats lane header (class 3 has exactly four members; whitespace inside an endpoint
      is a convergence case carried in the corpus), a `MINIMUM_FIXTURE_COUNT`
      constant set to 20 asserted in its own test
      `test_corpus_meets_declared_floor`, a parametrized test
      `test_reference_reproduces_every_corpus_fixture` with `ids=lambda path: path.stem` that calls
      `main(["--manifest", <manifest_path>, "--edges", <edges>])` and asserts the captured stdout
      equals `expected_stdout` plus one trailing newline and the return value equals
      `expected_status`, and a test `test_manifest_text_matches_manifest_path`. The module starts no
      subprocess and invokes no bash.
  - Acceptance:
    `poetry run pytest tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py -q -p no:cacheprovider`
    exits 0 and reports a pass count of at least 22.

- [ ] [P3-T9] Verify the two parity lanes agree over the same corpus by running both in sequence:
      `poetry run pytest tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py -q -p no:cacheprovider`
      then
      `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion_parity.bats'`,
      and record both in `evidence/regression-testing/parity-lanes.<timestamp>.md`.
  - Acceptance: both `EXIT_CODE:` values are 0, and the artifact records the pytest pass count and
    the bats case count.

### Phase 4 — Bundle mirror, pack manifest, payload-only proof, and TypeScript enumerations

- [ ] [P4-T1] Format the new bash files by running
      `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && digest() { bash -c "source scripts/bash/shell_qc_lib.sh; discover_shell_scripts" | xargs sha256sum | sha256sum; }; echo "BEFORE=$(digest)"; rc=0; bash scripts/bash/shell-qc.sh format || rc=$?; echo "FORMAT_RC=${rc}"; echo "AFTER=$(digest)"; git status --porcelain -- .claude/lib/bash tests/shell scripts tools; exit "$rc"'`
      and record the result in `evidence/qa-gates/bash-format-preseal.<timestamp>.md`.
  - Acceptance: `EXIT_CODE: 0`, a recorded `FORMAT_RC=0`, and identical recorded `BEFORE=` and
    `AFTER=` values.
  - The formatter's own exit code is captured into `rc` and re-raised by the trailing `exit "$rc"`
    because the steps are joined with `;` rather than `&&`: without the capture the command's exit
    code would be that of the trailing `git status --porcelain`, which is 0 whatever the formatter
    did, and a `shfmt` that is missing from the distribution (`run_format` returns 127 in that case,
    `scripts/bash/shell_qc_lib.sh:217-219`) would be recorded as a clean run with an unchanged
    digest. The steps cannot be joined with `&&`, because `AFTER=` must be computed even when the
    formatter fails.
  - Why the digest is the discriminator: the digest is taken over the exact file set `run_format`
    writes. `shell-qc.sh format` calls `run_format` (`scripts/bash/shell_qc_lib.sh:204-224`), which
    runs `shfmt -w` over the full output of `discover_shell_scripts`, whose search roots are
    `tools`, `scripts`, and `.claude/lib/bash` (`scripts/bash/shell_qc_lib.sh:85`). Hashing that
    same discovered set therefore changes if and only if `shfmt -w` rewrote a discovered file. The
    invocation form `bash -c "source scripts/bash/shell_qc_lib.sh; discover_shell_scripts"` is the
    same one P6-T3 uses.
  - Why a before-and-after `git status --porcelain` listing replaced the digest rather than the
    reverse: that listing does not change when the rewritten file is untracked (it stays
    `?? <path>`) or already modified (it stays ` M <path>`). Both new bash files are untracked for
    the whole of this plan, because no task in it stages or commits, so a tree listing is identical
    on a clean run and on a repairing run for exactly the files this feature adds. The porcelain
    span is retained in the command as supplementary context recorded in the artifact; it is not
    the acceptance.
  - `shfmt -w` rewrites in place and exits 0 whether or not it changed a file, so the exit code
    alone cannot decide this either.
  - Remedy when `BEFORE=` and `AFTER=` differ: re-running `shell-qc.sh format` produces two
    identical digests on the second run, but that identity is not evidence the task succeeded — the
    second run does not undo or re-mirror the file the first run rewrote. The required remedy is: for every file
    under `.claude/lib/bash/` that the first pass rewrote, re-copy it byte-identically into its
    counterpart under
    `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/` **before** P4-T2
    runs, because the mirror guard at `tests/shell/parallel_bash_manifest_membership.bats:56-71` is
    a `cmp -s` byte comparison that a post-mirror reformat breaks.
  - Attribution: `shell-qc.sh check` exits 0 with empty output against the pre-Phase-1 tree (P0-T2
    records that baseline), so any divergence observed here is attributable to a file this feature
    created, not to pre-existing drift.

- [ ] [P4-T2] Copy `.claude/lib/bash/parallel-lane-assertion.sh` and
      `.claude/lib/bash/report-lane-assertion.sh` byte-identically to
      `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-lane-assertion.sh`
      and
      `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/report-lane-assertion.sh`.
      No script performs this copy; research section 5.2 confirms the mirroring is manual.
  - Acceptance:
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && cmp -s .claude/lib/bash/parallel-lane-assertion.sh extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-lane-assertion.sh && cmp -s .claude/lib/bash/report-lane-assertion.sh extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/report-lane-assertion.sh'`
    exits 0.

- [ ] [P4-T3] Add `".claude/lib/bash/parallel-lane-assertion.sh"` and
      `".claude/lib/bash/report-lane-assertion.sh"` to the `paths` array in
      `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, beside the
      nine existing `.claude/lib/bash/` entries at lines 137-145. This file is bundle-only and sits
      outside the `.claude/**` parity scope
      (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_pack_manifests_are_outside_the_parity_scope`).
  - Acceptance:
    `git grep -n -F ".claude/lib/bash/report-lane-assertion.sh" -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
    returns exactly one match, and
    `git grep -n -F ".claude/lib/bash/parallel-lane-assertion.sh" -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
    returns exactly one match.

- [ ] [P4-T4] Raise `MINIMUM_LIB_FILE_COUNT` in `tests/shell/parallel_bash_manifest_membership.bats`
      from 9 to 11 at line 21, and update the comment at lines 19-20, which currently reads
      "The library is a nine-file module", so the prose agrees with the constant. The replacement
      phrase is `eleven-file module`.
  - Acceptance, all four clauses:
    (a) `git grep -n -F "MINIMUM_LIB_FILE_COUNT=11" -- tests/shell/parallel_bash_manifest_membership.bats`
    returns exactly one match;
    (b) `git grep -n -F "MINIMUM_LIB_FILE_COUNT=9" -- tests/shell/parallel_bash_manifest_membership.bats`
    returns no match;
    (c) `git grep -n -F "nine-file module" -- tests/shell/parallel_bash_manifest_membership.bats`
    returns no match, where it returns exactly one match at line 19 today; and
    (d) `git grep -n -F "eleven-file module" -- tests/shell/parallel_bash_manifest_membership.bats`
    returns exactly one match. Clauses (c) and (d) are what make the prose edit asserted rather than
    merely instructed; without them the comment could be left stale and the task would still pass.

- [ ] [P4-T5] Update the case at `tests/shell/parallel_bash_manifest_membership.bats:84-89`, titled
      "the three CLI entry points are present in both trees", so its title and its enumeration name
      all four entry points, adding `report-lane-assertion.sh` to the loop list at line 85. The
      replacement title is `the four CLI entry points are present in both trees`. The case is green
      without this change; it is updated because its title and list are documentation of the
      entry-point set and become stale otherwise.
  - Acceptance, all four clauses:
    (a) `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_bash_manifest_membership.bats'`
    exits 0, its TAP plan line reads `1..6`, and its output contains no line beginning `not ok`;
    (b) `git grep -c -F "report-lane-assertion.sh" -- tests/shell/parallel_bash_manifest_membership.bats`
    reports 1;
    (c) `git grep -n -F "the three CLI entry points are present in both trees" -- tests/shell/parallel_bash_manifest_membership.bats`
    returns no match, where it returns exactly one match at line 84 today; and
    (d) `git grep -n -F "the four CLI entry points are present in both trees" -- tests/shell/parallel_bash_manifest_membership.bats`
    returns exactly one match. The case count stays 6 because this edit changes an existing case
    rather than adding one; the six `@test` blocks are at lines 33, 38, 43, 56, 73, and 84.
    Clauses (c) and (d) assert the title change, which the `ok` line alone would not distinguish
    from the unedited title on a run that passes either way.

- [ ] [P4-T6] Add `".claude/lib/bash/report-lane-assertion.sh"` to the `it.each` enumeration at
      `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts:237-245`,
      whose seven entries occupy lines 238-244, placing the new entry after
      `".claude/lib/bash/validate-parallel-manifest.sh"` at line 244.
  - Acceptance, both clauses:
    (a) `npm run test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts` run from
    `extensions/drm-copilot` exits 0 with a `Tests:` summary reading `16 passed, 16 total` and 0
    failed; and
    (b) `git grep -c -F ".claude/lib/bash/report-lane-assertion.sh" -- extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`
    reports 1.
  - The pre-edit value was observed, not inferred: on 2026-08-29, against the clean tree, that same
    command reports `15 passed, 15 total`. The new `it.each` entry adds exactly one parametrized
    case, so the post-edit count is 16. Asserting the concrete 16 rather than "one greater than the
    count the same command reports before this edit" removes a comparison against a value no task in
    this plan captures.
  - The acceptance is stated over the `Tests:` summary rather than over an individual case name
    because Jest's default reporter prints per-case names only under `--verbose`.

- [ ] [P4-T7] Add `.claude/lib/bash/report-lane-assertion.sh` to the seeded file map at
      `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts:144-148` and to the
      `core.json` stub `paths` array, which spans lines 154-163 and whose three existing
      `.claude/lib/bash/` entries occupy lines 158-160, then add the same path to the enumeration at
      `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts:449-456`, whose six
      entries occupy lines 450-455. The helper
      edit is mandatory: that suite runs against the hermetic in-memory tree, so an assertion for a
      path the helper does not seed fails.
  - Acceptance: `npm run test -- test/lib/push-down/claude-config-carriage.test.ts` run from
    `extensions/drm-copilot` exits 0 with a `Tests:` summary reporting 0 failed; and
    `git grep -c -F ".claude/lib/bash/report-lane-assertion.sh" -- extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts`
    reports 1 for the test file and 2 for the helper, the latter being the seeded-file entry and the
    `core.json` stub entry. This edit adds no new case, so a passed-count delta is not available and
    the enumeration is verified by the grep instead.

- [ ] [P4-T8] Add to `tests/shell/parallel_payload_only.bats` a case named
      `the payload runs the lane-assertion diagnostic without Python on PATH` that invokes
      `report-lane-assertion.sh` from the bundle root through the existing `run_payload` helper under
      the four-shim `PATH`, passing
      `--manifest "$FIXTURE_MANIFEST"` where `FIXTURE_MANIFEST` is the checked-in
      `tests/fixtures/parallel_manifest_payload/parallel.md`, and asserting exit status 0 with
      `${lines[0]}` equal to `Lane assertion: 2 derived conflict component(s); 0 disagreement(s).`
      That header is the value the fixture produces: it declares exactly `issue_num` 101 and 202
      (lines 7 and 19) and carries no `expected_conflict_components` key, so with no edges the
      diagnostic derives two single-member components and zero disagreements. Also extend the case at
      lines 45-50, titled "the payload directory carries the three entry points", by adding a
      `[ -f "${PAYLOAD_LIB}/report-lane-assertion.sh" ]` line and retitling it
      `the payload directory carries the four entry points`; and edit the file header at line 4,
      which reads "Invokes the three published bash entry points from the bundle root", so that it
      reads `the four published bash entry points`.
  - Acceptance, all five clauses:
    (a) `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_payload_only.bats'`
    exits 0, its TAP plan line reads `1..11`, and its output contains no line beginning `not ok`.
    Eleven is one more than the ten `@test` blocks the file carries today at lines 45, 52, 58, 67,
    74, 80, 86, 92, 98, and 107;
    (b) the recorded TAP output carries an `ok` line naming
    `the payload runs the lane-assertion diagnostic without Python on PATH`;
    (c) `git grep -n -F "the payload directory carries the three entry points" -- tests/shell/parallel_payload_only.bats`
    returns no match, where it returns exactly one match at line 45 today;
    (d) `git grep -n -F "the payload directory carries the four entry points" -- tests/shell/parallel_payload_only.bats`
    returns exactly one match; and
    (e) `git grep -n -F "three entry points" -- tests/shell/parallel_payload_only.bats` and
    `git grep -n -F "the three published bash entry points" -- tests/shell/parallel_payload_only.bats`
    both return no match, and
    `git grep -n -F "the four published bash entry points" -- tests/shell/parallel_payload_only.bats`
    returns exactly one match. Clauses (c) through (e) are what make the two prose edits asserted;
    both regions are green either way, so a passing suite alone cannot evidence them.

- [ ] [P4-T9] Run the whole bash test suite for the first time since Phase 0 by
      `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bash scripts/bash/shell-qc.sh test'`
      and record the result in `evidence/regression-testing/bash-full-suite.<timestamp>.md`.
  - Acceptance: `EXIT_CODE: 0` and 0 bats failures. This is the first whole-tree run after
    Phase 1 created a `.claude/lib/bash/` file, so it is the first point at which
    `tests/shell/parallel_bash_manifest_membership.bats` can pass; running it earlier would fail for
    the mirror and manifest reasons recorded in Ordering Constraint 1.

### Phase 5 — Payload documentation edits and their bundle mirrors

- [ ] [P5-T1] Edit `.claude/skills/epic-orchestrate/SKILL.md` to delete the CLI spelling at line 296
      and rewrite the surrounding sentence at lines 295-299 so the MCP form
      `mcp__drm-copilot__validate_orchestration_artifacts` with
      `artifact_type: "epic-orchestrator-state"` is the primary spelling and the completion-gate
      option is expressed as the MCP argument `require_complete` rather than the CLI flag
      `--require-complete`. Retain the implementation citation
      `scripts/dev_tools/validate_epic_orchestrator_state.py` at line 299.
  - **The replacement must occupy exactly five lines**, so lines 295-299 are replaced in place and
    every line below them keeps its current number. This is a required constraint, not a stylistic
    one: clause (c) below names the pre-existing `require_complete=True` at line 310, and nothing
    else in this task constrains the replacement's length. The five replacement lines must together
    carry the literal `mcp__drm-copilot__validate_orchestration_artifacts`, the artifact type
    `epic-orchestrator-state`, exactly one occurrence of `require_complete`, and the retained
    `scripts/dev_tools/validate_epic_orchestrator_state.py` citation, and must carry neither
    `python -m scripts.dev_tools.validate_orchestration_artifacts` nor `--require-complete`.
  - Acceptance, all four clauses:
    (a) `git grep -n -F "python -m scripts.dev_tools.validate_orchestration_artifacts" -- .claude/skills/epic-orchestrate/SKILL.md`
    returns no match, where it returns exactly one match at line 296 today;
    (b) `git grep -n -F "--require-complete" -- .claude/skills/epic-orchestrate/SKILL.md` returns no
    match, where it returns exactly one match at line 296 today; and
    (c) `git grep -n -F "require_complete" -- .claude/skills/epic-orchestrate/SKILL.md` returns
    exactly two matches: the pre-existing `require_complete=True` at line 310 and one new match
    inside the rewritten passage at lines 295-299. That command returns exactly one match today, so
    the rise from one to two is the evidence that the completion-gate option was respelled as the
    MCP argument; and
    (d) `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && wc -l .claude/skills/epic-orchestrate/SKILL.md'`
    reports a line count of 310, which is the count it reports today, so the file length is unchanged
    and `require_complete=True` still sits at line 310 as clause (c) records. `wc -l <file>` prints
    the count followed by the path, so the asserted value is the count on that line, not the whole
    line.
  - Clauses (b) and (c) are the discriminating pair: they distinguish the MCP argument spelling
    `require_complete` from the deleted CLI flag `--require-complete`. The previously planned clause
    `git grep -c -F "mcp__drm-copilot__validate_orchestration_artifacts" -- .claude/skills/epic-orchestrate/SKILL.md`
    is dropped from this task's acceptance because it already reports a non-zero count today (the
    literal is present at line 297), so it cannot fail whatever the executor does. It is retained
    only in P5-T12, where it serves as a preservation check rather than a change check.

- [ ] [P5-T2] Edit `.claude/skills/parallel-orchestrate/SKILL.md` to delete the CLI spelling at lines
      481-482 and rewrite lines 480-483 so only the MCP form remains and the completion-gate option
      reads as the MCP argument `require_complete`. Do not touch line 817 or the
      `#### CLI Invocation` heading at line 809.
  - **The replacement must occupy exactly four lines**, so lines 480-483 are replaced in place and
    every line below them keeps its current number. This is a required constraint, not a stylistic
    one: line 817 is named by clause (d) of this task, by clause (a) of P5-T12, and by four
    acceptance criteria — `spec.md:598-607`, `spec.md:635-639`, `user-story.md:147-155`, and
    `user-story.md:183-187`. A replacement of any other length shifts line 817 and fails all six for
    a reason unrelated to the property under test, and P6-T17 forbids editing criterion text to
    accommodate the shift. Use this four-line replacement shape:

    ```text
    Validate through `mcp__drm-copilot__validate_orchestration_artifacts` with
    `artifact_type: "parallel-orchestrator-state"`. At the completion gate, pass the
    `require_complete` argument on that same MCP call; no repository-local Python
    interpreter is required at a destination runtime.
    ```

    That shape satisfies clauses (a) through (c) as written: it carries no
    `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts`, no
    `--require-complete`, and exactly one `require_complete`, which is the second of the two matches
    clause (c) requires.
  - Acceptance, all five clauses:
    (a) `git grep -n -F "poetry run python -m scripts.dev_tools.validate_orchestration_artifacts" -- .claude/skills/parallel-orchestrate/SKILL.md`
    returns no match, where it returns exactly one match at line 482 today;
    (b) `git grep -n -F "--require-complete" -- .claude/skills/parallel-orchestrate/SKILL.md`
    returns no match, where it returns exactly one match at line 483 today;
    (c) `git grep -n -F "require_complete" -- .claude/skills/parallel-orchestrate/SKILL.md` returns
    exactly two matches: the pre-existing occurrence at line 497 and one new match inside the
    rewritten passage at lines 480-483. That command returns exactly one match today; and
    (d) `git grep -n -F "poetry run python -m scripts.dev_tools.parallel_drift_detection_cli" -- .claude/skills/parallel-orchestrate/SKILL.md`
    still returns exactly one match, at line 817; and
    (e) `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && wc -l .claude/skills/parallel-orchestrate/SKILL.md'`
    reports a line count of 1055, which is the count it reports today, so the file length is
    unchanged and line 817 still holds the drift-detection invocation that clause (d) and four
    acceptance criteria name. `wc -l <file>` prints the count followed by the path, so the asserted
    value is the count on that line, not the whole line.
  - The previously planned non-zero-count check on
    `mcp__drm-copilot__validate_orchestration_artifacts` is dropped from this task's acceptance for
    the same reason as in P5-T1: the literal is already present at line 480 today, so the count is
    non-zero before any edit and the clause cannot fail. Clause (d) is the non-goal preservation
    check and is falsifiable in the other direction — an over-broad deletion would drop it to zero.

- [ ] [P5-T3] Edit `.claude/skills/parallel-plan/SKILL.md` to replace the invocation at line 315 with
      `bash .claude/lib/bash/report-lane-assertion.sh --manifest docs/features/parallel/<slug>/parallel.md --edges "<a>:<b> ..."`
      and to replace the parenthetical grant note at line 316, which today reads "(covered by the
      planner's existing `Bash(poetry run *)` grant)". Leave lines 322-329 and 569-573 semantically
      unchanged.
  - **The replacement wording must not assert an entry-point-scoped bash grant, because none will
    exist.** No task in this plan edits `.claude/settings.json` or its bundle mirror; see Fixed
    Design Decision 9. Write the replacement as a plain description of the invocation, naming no
    grant — for example, stating that the diagnostic is invoked as a bash command against the
    published payload and requires no Python interpreter at the destination. A replacement that
    claims coverage by a `Bash(bash .claude/lib/bash/report-lane-assertion.sh*)` project grant would
    reintroduce, in the opposite direction, the same payload inconsistency this feature exists to
    close.
  - Acceptance, all three clauses:
    (a) `git grep -n -F "poetry run python -m scripts.dev_tools.parallel_lane_assertion" -- .claude/skills/parallel-plan/SKILL.md`
    returns no match, where it returns exactly one match at line 315 today;
    (b) `git grep -n -F "bash .claude/lib/bash/report-lane-assertion.sh" -- .claude/skills/parallel-plan/SKILL.md`
    returns at least one match inside the `### Seeding procedure` step that begins at line 302, whose
    lane-assertion item spans lines 313-329; and
    (c) `git grep -n -F "covered by the planner's existing" -- .claude/skills/parallel-plan/SKILL.md`
    returns no match, where it returns exactly one match at line 316 today. Clause (c) asserts the
    grant note was actually rewritten rather than left beside the new invocation.

- [ ] [P5-T4] Edit `.claude/agents/parallel-planner.md` to add
      `"Bash(bash .claude/lib/bash/report-lane-assertion.sh*)"` to the `tools:` list at lines 5-20,
      beside the three existing entry-point grants at lines 17-19; to document the new entry point in
      the bash paragraph at lines 158-168; and to correct the two counts that paragraph carries.
      The phrase `three entry-point-specific allowlist entries` at line 159 becomes
      `four entry-point-specific allowlist entries`, and the phrase
      `The six sourceable libraries carry no grant` at line 162 becomes
      `The seven sourceable libraries carry no grant`. Rewrite the stale sentence at lines 185-186 so
      it no longer states that the `Bash(poetry run *)` grant `it is not required by any step above`.
      Leave the PowerShell paragraph at lines 147-156 untouched; Feature C owns it.
  - This task edits the persona's `tools:` list only. It does **not** edit
    `.claude/settings.json`; see Fixed Design Decision 9.
  - Record every command in this task's acceptance, with its full output, in
    `evidence/qa-gates/planner-persona-edit.<timestamp>.md`.
  - Acceptance, all six clauses:
    (a) `git grep -c -F "Bash(bash .claude/lib/bash/report-lane-assertion.sh*)" -- .claude/agents/parallel-planner.md`
    reports 1, where it reports 0 today;
    (b) `git grep -n -F "four entry-point-specific allowlist entries" -- .claude/agents/parallel-planner.md`
    returns exactly one match, and
    `git grep -n -F "three entry-point-specific allowlist entries" -- .claude/agents/parallel-planner.md`
    returns no match, where the latter returns exactly one match at line 159 today;
    (c) `git grep -n -F "The seven sourceable libraries carry no grant" -- .claude/agents/parallel-planner.md`
    returns exactly one match, and
    `git grep -n -F "The six sourceable libraries carry no grant" -- .claude/agents/parallel-planner.md`
    returns no match, where the latter returns exactly one match at line 162 today;
    (d) `git grep -n -F "it is not required by any step above" -- .claude/agents/parallel-planner.md`
    returns no match, where it returns exactly one match at line 186 today;
    (e) `git diff origin/main -- .claude/agents/parallel-planner.md` produces non-empty output; and
    (f) that same output contains no changed line whose content falls inside the PowerShell
    paragraph at lines 147-156 — that is, no added or removed line matching any of `Import-Module`,
    `BlastRadius.psm1`, `Get-PlanPaths`, `Get-BlastRadius`, `Get-BlastRadiusFromObservedPaths`,
    `Test-BlastRadius`, `Test-BlastRadiusConflict`, or `config/blast-radius.json`.
  - Clause (e) uses the **two-dot** form `git diff origin/main`, which compares the working tree
    against the ref. The three-dot form `git diff origin/main...HEAD` compares the merge base
    against `HEAD` and is empty until the executor commits, so it would pass vacuously for an
    executor that runs the gate before committing. The two-dot form is anchored to an explicit ref,
    so it is not the unanchored working-tree-versus-index comparison that rule G8 reports.
  - Reconciliation note for P6-T17: the corresponding criterion at `spec.md:611-615` states the
    three-dot form `git diff --stat origin/main...HEAD -- .claude/agents/parallel-planner.md`. Run
    and record **both** forms in this task's evidence artifact. The two-dot output is the
    load-bearing gate for clauses (e) and (f); the three-dot output is recorded so the criterion's
    literal command is evidenced, with a note stating that it is empty until the change is
    committed and is therefore not the discriminator. No criterion text is edited to accommodate
    this; P6-T17 forbids that.

- [ ] [P5-T5] Edit `.claude/agents/parallel-orchestrator.md` lines 92-97 so the grant rationale names
      only consumers that still exist after site 2 is deleted, and so its counts are internally
      consistent with that. Re-derived this pass, the paragraph today reads: line 92 opens with
      "The two `poetry run` grants remain for the repository-local paths that still need an
      interpreter:"; lines 93-94 name two consumers, "the checkpoint-validator CLI fallback the skill
      names in its `## Parallel-Level Checkpoint` section" and "the drift-detection CLI likewise";
      line 94 continues "Both grants stay scoped"; and lines 95-96 read "to those two invocation
      forms only — not to `poetry run` as a whole — so `pytest`, `black`, `ruff`, and every other
      `poetry run` subcommand remain outside the allowlist." Lines 96-97 carry the cross-reference to
      `.claude/agents/parallel-planner.md`.
  - The count reconciliation is the substance of this task. After P5-T2 deletes site 2, exactly one
    named consumer remains — the drift-detection CLI — so a paragraph that still says "two"
    consumers and "those two invocation forms" is inconsistent with the tree it describes. Rewrite
    the counts to match the surviving consumer set while **retaining the scoping substance**: that
    the grant does not extend to `poetry run` as a whole, and that `pytest`, `black`, `ruff`, and
    every other `poetry run` subcommand remain outside the allowlist. Retain the cross-reference at
    lines 96-97.
  - Acceptance, all four clauses:
    (a) `git grep -n -F "checkpoint-validator CLI fallback" -- .claude/agents/parallel-orchestrator.md`
    returns no match, where it returns exactly one match at line 93 today;
    (b) `git grep -n -F "drift-detection CLI" -- .claude/agents/parallel-orchestrator.md` still
    returns at least one match;
    (c) `git grep -n -F "Both grants stay scoped" -- .claude/agents/parallel-orchestrator.md`
    returns no match, where it returns exactly one match at line 94 today, so the retired two-grant
    count is asserted gone rather than left in place; and
    (d) `git grep -n -F "as a whole" -- .claude/agents/parallel-orchestrator.md` returns exactly one
    match, and `git grep -n -F "remain outside the allowlist" -- .claude/agents/parallel-orchestrator.md`
    returns exactly one match. Together those two tokens are the scoping substance the rewrite must
    preserve: the first is the tail of the phrase on line 95 that limits the grant so it does not
    extend to `poetry run` as a whole, and the second is the tail of the clause on line 96 that keeps
    `pytest`, `black`, `ruff`, and every other subcommand out of the allowlist. Each returns exactly
    one match today, so clause (d) is a preservation check: it fails if the rewrite drops the scoping
    statement along with the count.
  - Both clause-(d) tokens are chosen to carry no backtick. The phrase on line 95 that they stand in
    for contains a backtick-quoted `poetry run`, and asserting that phrase directly would require
    escaping backticks inside a markdown code span. The two backtick-free tokens are each
    single-line and are asserted verbatim instead.

- [ ] [P5-T6] Copy the edited `.claude/skills/epic-orchestrate/SKILL.md` to
      `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`.
  - Acceptance:
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && cmp -s .claude/skills/epic-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md'`
    exits 0.

- [ ] [P5-T7] Copy the edited `.claude/skills/parallel-orchestrate/SKILL.md` to
      `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md`.
  - Acceptance:
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && cmp -s .claude/skills/parallel-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md'`
    exits 0.

- [ ] [P5-T8] Copy the edited `.claude/skills/parallel-plan/SKILL.md` to
      `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md`.
  - Acceptance:
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && cmp -s .claude/skills/parallel-plan/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md'`
    exits 0.

- [ ] [P5-T9] Copy the edited `.claude/agents/parallel-planner.md` to
      `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md`.
  - Acceptance:
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && cmp -s .claude/agents/parallel-planner.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md'`
    exits 0.

- [ ] [P5-T10] Copy the edited `.claude/agents/parallel-orchestrator.md` to
      `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md`.
  - Acceptance:
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && cmp -s .claude/agents/parallel-orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md'`
    exits 0.

- [ ] [P5-T11] Verify the complete bundle mirror by running
      `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q -p no:cacheprovider`
      and record the result in `evidence/regression-testing/pushdown-contracts.<timestamp>.md`.
  - Acceptance, part 1 (environment-conditional, same condition as P0-T8): `EXIT_CODE: 0` with the
    observed pytest summary recorded is a pass. A non-zero exit code is accepted **only** when the
    sole assertion message in the recorded output names a path under `.claude/state/`, for example
    `AssertionError: Repo file missing from bundle: .claude/state/python-batch-budget.default.json`.
    Any other assertion message — in particular one naming a path under `.claude/lib/bash/`,
    `.claude/skills/`, or `.claude/agents/` — is a blocking finding, because such a path is a file
    this feature added or edited. Also run the single node ID that guards the mirror,
    `poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts" -q -p no:cacheprovider`,
    and record its result under the same condition. The node ID is run explicitly because `-q`
    prints progress characters rather than case names, so a file-level run cannot evidence that this
    particular case passed.
  - Why the result is environment-conditional and why deleting the state file is not a remedy: see
    the mechanism recorded in P0-T8 (`list_scoped_files` at
    `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:34-43`, the caller's
    exclusion set at lines 113-117, `.gitignore:68`, and open issue #510). The state file
    regenerates within the session, so a deletion clears the gate only until the next hook fires.
    P3-T8 additionally creates a `.py` file in this run, which is one of the triggers for the
    Python batch-budget hook that writes `.claude/state/`.
  - Acceptance, part 2 (durable gate, no dependence on `.claude/state/`): run
    `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && rc=0; for f in .claude/lib/bash/parallel-lane-assertion.sh .claude/lib/bash/report-lane-assertion.sh .claude/skills/epic-orchestrate/SKILL.md .claude/skills/parallel-orchestrate/SKILL.md .claude/skills/parallel-plan/SKILL.md .claude/agents/parallel-planner.md .claude/agents/parallel-orchestrator.md; do cmp -s "$f" "extensions/drm-copilot/resources/claude-customizations/$f" || { echo "DIFFERS: $f"; rc=1; }; done; exit $rc'`
    and record it in the same artifact with `EXIT_CODE: 0` and empty stdout. Any `DIFFERS:` line is
    a blocking finding. The seven files are the two new bash files (P4-T2) and the five edited
    `.claude/**` files (P5-T6 through P5-T10). This loop is a byte comparison over a fixed,
    enumerated file list, so it is unaffected by `.claude/state/` and by any other untracked file.

- [ ] [P5-T12] Verify the three in-scope invocation sites are closed and the two non-goal sites are
      untouched by running all three of
      `git grep -n -F "python -m scripts.dev_tools." -- .claude/skills/`,
      `git grep -n -F "poetry run python" -- .claude/skills/`, and
      `git grep -c -F "mcp__drm-copilot__validate_orchestration_artifacts" -- .claude/skills/epic-orchestrate/SKILL.md .claude/skills/parallel-orchestrate/SKILL.md`,
      recording all three commands and their full outputs in
      `evidence/qa-gates/invocation-sites.<timestamp>.md`.
  - Acceptance, all three clauses:
    (a) `git grep -n -F "python -m scripts.dev_tools." -- .claude/skills/` returns exactly **one**
    match, at `.claude/skills/parallel-orchestrate/SKILL.md:817`, the drift-detection CLI;
    (b) `git grep -n -F "poetry run python" -- .claude/skills/` returns exactly **two** matches,
    `.claude/skills/parallel-orchestrate/SKILL.md:817` and
    `.claude/skills/parallel-remove/SKILL.md:112`, both declared non-goals of this feature; and
    (c) `git grep -c -F "mcp__drm-copilot__validate_orchestration_artifacts" -- .claude/skills/epic-orchestrate/SKILL.md .claude/skills/parallel-orchestrate/SKILL.md`
    reports a non-zero count for both files. Clause (c) is a preservation check: both counts are
    non-zero today, and the risk it guards is an over-broad deletion in P5-T1 or P5-T2 that removes
    the MCP form along with the CLI spelling.
  - Pre-feature values, re-derived this pass against the clean tree, so the deltas are evidence
    rather than assumption:
    - `git grep -n -F "python -m scripts.dev_tools." -- .claude/skills/` returns **four** matches
      today: `epic-orchestrate/SKILL.md:296` (site 1), `parallel-plan/SKILL.md:315` (site 4),
      `parallel-orchestrate/SKILL.md:482` (site 2), and `parallel-orchestrate/SKILL.md:817`
      (site 3, non-goal). The drop from four to one is the evidence that all three in-scope sites
      closed.
    - `git grep -n -F "poetry run python" -- .claude/skills/` returns **four** matches today:
      `parallel-plan/SKILL.md:315`, `parallel-orchestrate/SKILL.md:482`,
      `parallel-orchestrate/SKILL.md:817`, and `parallel-remove/SKILL.md:112`. Sites 3 and 5 are the
      two that remain.
  - Site 1 at `.claude/skills/epic-orchestrate/SKILL.md:296` is spelled `python -m` with **no**
    `poetry run` prefix, so it never appears in the `poetry run python` grep at all. That is why
    clause (a) rather than clause (b) is the count that evidences its closure, and why an earlier
    formulation asserting a single `poetry run python` match was unsatisfiable.
  - `spec.md:598-607` and `user-story.md:147-155` now carry this corrected form; this task asserts
    those criteria directly.

### Phase 6 — Final QA loop, coverage deltas, and non-goal verification

The loop below runs in the order format, lint, type-check, test for each language. If any step fails
or rewrites a file, restart that language's loop at its format step.

- [ ] [P6-T1] Run the bash format step:
      `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && digest() { bash -c "source scripts/bash/shell_qc_lib.sh; discover_shell_scripts" | xargs sha256sum | sha256sum; }; echo "BEFORE=$(digest)"; rc=0; bash scripts/bash/shell-qc.sh format || rc=$?; echo "FORMAT_RC=${rc}"; echo "AFTER=$(digest)"; git status --porcelain -- .claude/lib/bash tests/shell scripts tools; exit "$rc"'`
      and record it in `evidence/qa-gates/final-bash-format.<timestamp>.md`.
  - Acceptance: `EXIT_CODE: 0`, a recorded `FORMAT_RC=0`, and identical recorded `BEFORE=` and
    `AFTER=` values. That equality is the observation that distinguishes a clean run from a
    repairing one; `shfmt -w` exits 0 in both cases and prints a path only when it rewrites, so the
    exit code alone cannot decide this. The formatter's exit code is captured and re-raised for the
    reason recorded in P4-T1.
  - The digest covers the same file set as P4-T1 and for the same reason: `run_format` formats the
    full output of `discover_shell_scripts`, whose roots are `tools`, `scripts`, and
    `.claude/lib/bash` (`scripts/bash/shell_qc_lib.sh:85`), so hashing that discovered set changes
    if and only if a discovered file was rewritten. The `git status --porcelain` span is retained as
    supplementary context recorded in the artifact and is not the acceptance, for the reason
    recorded in P4-T1: the listing does not change for an untracked file (`?? <path>`) or an
    already-modified file (` M <path>`), and both new bash files are untracked throughout this plan.
  - If `BEFORE=` and `AFTER=` differ, re-copy every rewritten `.claude/lib/bash/` file into its
    counterpart under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/`,
    then restart Phase 6 at this task. Re-running the formatter alone is not the remedy: the second
    run produces identical digests but does not re-mirror the file the first run rewrote, and the
    mirror guard is a byte comparison.

- [ ] [P6-T2] Run the bash lint step:
      `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bash scripts/bash/shell-qc.sh check'`
      and record it in `evidence/qa-gates/final-bash-check.<timestamp>.md`.
  - Acceptance: `EXIT_CODE: 0` and empty output.

- [ ] [P6-T3] Confirm both new files are inside the shell-QC discovery set by running
      `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bash -c "source scripts/bash/shell_qc_lib.sh; discover_shell_scripts" | grep -c -F -e .claude/lib/bash/parallel-lane-assertion.sh -e .claude/lib/bash/report-lane-assertion.sh'`
      and record it in `evidence/qa-gates/bash-discovery.<timestamp>.md`.
  - Acceptance: the command prints `2` and exits 0. `discover_shell_scripts`
    (`scripts/bash/shell_qc_lib.sh:75-102`) emits root-relative paths, so both new files appear with
    the spellings asserted here.

- [ ] [P6-T4] Run the bash coverage step:
      `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bash scripts/bash/shell-qc.sh test --coverage'`
      and record it in `evidence/qa-gates/final-bash-coverage.<timestamp>.md`.
  - Acceptance: `EXIT_CODE: 0`, 0 bats failures, and an `Output Summary:` recording the numeric
    headline `Bash coverage (lines): NN.N%` with `NN.N` at least 85.0.

- [ ] [P6-T5] Extract the per-file coverage rows for the two new bash files by running
      `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && grep -n -F -e parallel-lane-assertion.sh -e report-lane-assertion.sh artifacts/pester/kcov/cov.xml'`
      and record every matching line verbatim in
      `evidence/qa-gates/bash-new-file-coverage.<timestamp>.md`.
  - Acceptance: the command exits 0; the recorded output carries at least one line naming
    `.claude/lib/bash/parallel-lane-assertion.sh` and at least one naming
    `.claude/lib/bash/report-lane-assertion.sh`; and the `line-rate` attribute value read directly
    from each of those two lines is 0.85 or greater. Both values are recorded in the artifact.
  - Output form, observed this pass rather than hedged: kcov emits the Cobertura `<class>` element
    on one line with `filename` as a repo-relative path and `line-rate` on that same line, in this
    attribute order — `<class name="compute_cohorts_sh__30" filename=".claude/lib/bash/compute-cohorts.sh" branch-rate="1.0" complexity="1.0" line-rate="0.887">`.
    A `grep -n -F` for the two new basenames therefore returns two lines, each already carrying its
    own `line-rate` value, and the value is read from the grep output directly. No enclosing-element
    lookup and no positional regular expression is required.
  - The artifact additionally records that neither file appears in any coverage exclusion: the kcov
    exclude pattern is `$repo_root/tests` only (`scripts/bash/shell_qc_lib.sh:336`) and the include
    pattern is the three directory roots `tools`, `scripts`, and `.claude/lib/bash` (`:335`), so no
    per-file exclusion mechanism exists on the bash path.

- [ ] [P6-T6] Run the Python format step: `poetry run black .` from the worktree root, preceded and
      followed by `git status --porcelain`, and record it in
      `evidence/qa-gates/final-python-black.<timestamp>.md`.
  - Acceptance, all three clauses: `EXIT_CODE: 0`; the artifact records the two
    `git status --porcelain` listings verbatim and they are identical; and black's recorded stdout
    contains **no line beginning `reformatted `**.
  - Output form, observed this pass: against the clean tree, `poetry run black .` exits 0 and prints
    `All done!` followed by `457 files left unchanged.`, and `git status --porcelain` was unchanged
    afterwards. The **file count is deliberately not asserted**: this feature adds a Python test
    file (P3-T8), so the 457 will move and an assertion on it would fail for a reason unrelated to
    formatting. The discriminating observation is the absence of any `reformatted ` line, which
    black emits once per rewritten file and only on a repairing run. That absence alone is what
    distinguishes a clean run from a repairing one; the exit code cannot, because black exits 0 in
    both cases, and the before-and-after listings cannot either, for the reason recorded in P4-T1 —
    the Python test file P3-T8 creates is untracked, so it stays `?? <path>` in both listings
    whether or not black rewrote it. The listing identity clause is retained as supplementary
    context; the `reformatted ` absence is the load-bearing observation.

- [ ] [P6-T7] Run the Python lint step: `poetry run ruff check .` from the worktree root, and record
      it in `evidence/qa-gates/final-python-ruff.<timestamp>.md`.
  - Acceptance: `EXIT_CODE: 0` and a recorded stdout of exactly `All checks passed!`, which is the
    success-case output observed on this worktree against the clean tree before planning.
  - Read-only finding, same as P0-T5: `ruff check` does not rewrite in this repository.
    `[tool.ruff]` in `pyproject.toml:88-91` sets only `line-length`, `target-version`, and
    `show-fixes`; there is no `fix = true`, and `--fix` is not passed. The plan-acceptance gate's G7
    heuristic classifies `ruff` as write-mode conservatively, so a G7 warning is expected on this
    task and is not a defect. The `All checks passed!` line is recorded alongside the exit code so
    the acceptance does not rest on the exit code alone.

- [ ] [P6-T8] Run the Python type-check step: `poetry run pyright` from the worktree root, and record
      it in `evidence/qa-gates/final-python-pyright.<timestamp>.md`.
  - Acceptance: `EXIT_CODE: 0`, and the artifact reproduces the run's summary line verbatim.

- [ ] [P6-T9] Run the Python coverage step:
      `poetry run pytest tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py tests/scripts/dev_tools/test_parallel_lane_assertion.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py --cov=scripts.dev_tools.parallel_lane_assertion --cov-report=term-missing -p no:cacheprovider`
      and record it in `evidence/qa-gates/final-python-coverage.<timestamp>.md`.
  - Acceptance, part 1 (unconditional): the pytest pass count is recorded, and the numeric percentage
    on the `scripts/dev_tools/parallel_lane_assertion.py` row of the `term-missing` table is recorded
    and is at least 85. pytest-cov emits that table after the test session in both outcomes — the
    project `addopts` value at `pyproject.toml:115` is `-ra --cov-report=lcov:artifacts/python/lcov.info`
    and passes no `--no-cov-on-fail` — so this half is readable whether or not a case failed.
  - Acceptance, part 2 (environment-conditional, same condition as P0-T8 and P5-T11): `EXIT_CODE: 0`
    is a pass. A non-zero exit is accepted **only** when every failing case belongs to
    `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and its sole assertion
    message names a path under `.claude/state/`, for example
    `AssertionError: Repo file missing from bundle: .claude/state/python-batch-budget.default.json`.
    Any failure in `tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py` or
    `tests/scripts/dev_tools/test_parallel_lane_assertion.py`, and any other assertion message from
    the push-down suite, is a blocking finding and Phase 6 restarts at P6-T6.
  - Rationale for the branch, re-derived this pass: the command's file list includes
    `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, whose `list_scoped_files`
    helper at lines 34-43 walks the tree with `rglob("*")` and reads no `.gitignore`. P3-T8 creates a
    `.py` file during this run, which is the trigger condition of the Python batch-budget hook: that
    hook returns early for any `file_path` not matching `\.py$`
    (`.claude/hooks/enforce-python-batch-budget.ps1:181-183`) and otherwise creates and writes
    `.claude/state/` at `.claude/hooks/enforce-python-batch-budget.ps1:185`. `.claude/state/` is
    gitignored at `.gitignore:68`, so the suite is green against the clean tree and goes red during
    execution. This is open issue #510, confirmed OPEN. Without the branch the unconditional
    `EXIT_CODE: 0` gate is unsatisfiable, and the Phase 6 restart rule would not terminate: re-running
    `black` does not remove the state file, and deleting the file is not a remedy because it
    regenerates the next time the hook fires within the session.

- [ ] [P6-T10] Run the TypeScript format step from `extensions/drm-copilot` as two recorded
      commands, in this order: first `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`,
      then `npm run format`. Record both commands and their full output in
      `evidence/qa-gates/final-ts-format.<timestamp>.md`.
  - Acceptance: both commands record `EXIT_CODE: 0`.
  - Why `--check` is the discriminator: `prettier --check` is read-only. It exits non-zero and lists
    every file it would rewrite, so a zero exit proves that nothing in the checked set needs
    rewriting. The glob set is identical to the one the `format` script passes:
    `extensions/drm-copilot/package.json:207` defines `format` as
    `prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`, the same four globs. A clean
    `--check` over that set therefore proves the subsequent `--write` run rewrites nothing.
    `prettier --write` exits 0 whether or not it rewrote a file, so its own exit code cannot decide
    this.
  - Why a before-and-after tree listing is not the discriminator here: the two TypeScript test files
    this feature touches are already modified in the working tree by P4-T6 and P4-T7 before this
    task runs, so each stays ` M <path>` in a `git status --porcelain` listing whether or not
    `prettier --write` rewrites it. The listing is identical on a clean run and on a repairing run
    for exactly the files at risk.

- [ ] [P6-T11] Run the TypeScript lint and type-check steps: `npm run lint` then `npm run typecheck`
      from `extensions/drm-copilot`, and record both in
      `evidence/qa-gates/final-ts-lint-typecheck.<timestamp>.md`.
  - Acceptance: both `EXIT_CODE:` values are 0.

- [ ] [P6-T12] Run the TypeScript coverage step: `npm run test:coverage` from
      `extensions/drm-copilot`, and record it in
      `evidence/qa-gates/final-ts-coverage.<timestamp>.md`.
  - Acceptance: `EXIT_CODE: 0`, the Jest `Tests:` line recorded verbatim with 0 failed, and the four
    `text-summary` percentages (Statements, Branches, Functions, Lines) recorded.
  - Conditional branch, applicable only when P0-T12 recorded a non-zero baseline exit code: identify
    the failing suite by name from the recorded Jest output and confirm that this feature's diff
    touches no file in that suite, using
    `git diff --name-only origin/main` together with
    `git status --porcelain -- extensions/drm-copilot`. If the confirmation holds, record the
    pre-existing failure, its suite name, and the confirmation in the artifact, and treat the
    coverage percentages as the acceptance. If this feature's diff **does** touch the failing suite,
    the non-zero exit is a blocking finding and Phase 6 restarts at P6-T10.
  - A non-zero exit code is never accepted without the named-suite identification and the
    no-overlap confirmation. Matching the baseline exit code alone is not sufficient, because this
    feature edits two TypeScript test files (P4-T6 and P4-T7) and could itself be the cause.

- [ ] [P6-T13] Run the PowerShell regression check:
      `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 -CI"`
      from the worktree root, and record it in
      `evidence/qa-gates/final-powershell-no-python-invocation.<timestamp>.md`.
  - Acceptance: `EXIT_CODE: 0` with a failed count of 0 in the recorded Pester run summary. A failed
    count of 0 certifies the suite's own case `ships an empty allowlist` (line 102), so the
    acceptance is stated over the summary rather than over a per-case name, which Pester's default
    verbosity prints for failures only. No PowerShell file was
    added or modified, and the suite deliberately excludes `.claude/lib/bash/**` from its scan
    (`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1:65-66`), so the
    two new bash files are outside its guarded tree.

- [ ] [P6-T14] Write the coverage delta artifact
      `evidence/other/coverage-delta.<timestamp>.md`, reporting for each in-scope language the
      baseline value, the post-change value, and the new-code value.
  - Acceptance: the artifact records, for bash, the P0-T3 baseline percentage, the P6-T4 post-change
    percentage, and the two per-file `line-rate` values from P6-T5 as the new-code figures, noting
    that kcov measures line coverage only and that there is no bash branch-coverage gate; for Python,
    the P0-T7 baseline percentage and the P6-T9 post-change percentage for
    `scripts/dev_tools/parallel_lane_assertion.py`, together with the statement that this feature
    adds no Python production file, so the new-code figure is not applicable and the no-regression
    check is the comparison of those two values; and for TypeScript, the P0-T12 and P6-T12
    `text-summary` percentages, together with the statement that this feature changes no file under
    `extensions/drm-copilot/src/`, so the per-file threshold map in `jest.config.cjs` gains no
    entry.
  - The TypeScript acceptance is that **no percentage decreased**. The four values are expected to
    be unchanged. They are not required to be identical: P4-T7 adds a fourth seeded file to the
    hermetic push-down tree, so a small non-decreasing movement in a `src/**` percentage is
    possible, and an identity requirement would fail that outcome while the no-regression
    requirement passes it. Any movement is recorded together with the suite that produced it rather
    than treated as a failure.
  - Any decrease in any of the three language comparisons — bash, Python, or TypeScript — is a
    blocking finding.

- [ ] [P6-T15] Verify the non-goals are untouched by running
      `git diff --stat origin/main...HEAD -- .claude/rules/parallel-orchestration.md .claude/skills/parallel-remove/SKILL.md .claude/hooks/enforce-discovery-artifact-gate.ps1 .claude/hooks/validate-discovery-artifact-gate.ps1`
      together with
      `git status --porcelain -- .claude/rules .claude/skills/parallel-remove .claude/hooks`,
      and record both in `evidence/qa-gates/non-goals-untouched.<timestamp>.md`.
  - Acceptance: the `git diff --stat` output is empty and the `git status --porcelain` output is
    empty, proving no committed change and no working-tree change to any of the four non-goal files.
    The status companion is required because a name-listing or stat diff against a ref cannot observe
    an untracked or unstaged edit.

- [ ] [P6-T16] Verify that no file under `.claude/lib/bash/` other than the entry point sources the
      diagnostic, and that the diagnostic feeds no scheduling module, by running
      `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion.bats -f "no library file sources the diagnostic"'`
      and record it in `evidence/qa-gates/no-production-consumer.<timestamp>.md`.
  - Acceptance: `EXIT_CODE: 0` with 0 failures.

- [ ] [P6-T17] Reconcile every acceptance criterion in `spec.md` and `user-story.md` against the
      evidence artifacts produced by this plan, record the mapping in
      `evidence/qa-gates/acceptance-criteria-reconciliation.<timestamp>.md`, **and check off the
      satisfied criteria in the source documents themselves** by changing `- [ ]` to `- [x]` on the
      corresponding lines of
      `docs/features/active/2026-08-29-remove-remaining-python-invocations-599/spec.md` and
      `docs/features/active/2026-08-29-remove-remaining-python-invocations-599/user-story.md`.
      The work mode is `full-feature`, so the tracking contract requires the check-off to land in the
      requirement documents, not only in an evidence artifact.
  - Change **no criterion text** and add **no** criterion. The only permitted edit to either file is
    the two-character change from `- [ ]` to `- [x]` at the start of a criterion line.
  - Acceptance, all eight clauses:
    (a) the artifact lists all 20 `spec.md` criteria (the `## Acceptance Criteria` items at
    `spec.md:556-639`) and all 13 `user-story.md` criteria (the items at `user-story.md:119-187`),
    each with the task ID and the evidence artifact path that satisfies it;
    (b) each listed criterion is marked exactly PASS or BLOCKED, and a criterion with no evidence
    artifact is marked BLOCKED, never PASS;
    (c) every criterion marked BLOCKED remains `- [ ]` in its source document;
    (d) in `spec.md`, the number printed by
    `awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' docs/features/active/2026-08-29-remove-remaining-python-invocations-599/spec.md | grep -c '^- \[x\]'`
    equals the number of `spec.md` criteria marked PASS in the artifact;
    (e) in `user-story.md`, the number printed by
    `awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' docs/features/active/2026-08-29-remove-remaining-python-invocations-599/user-story.md | grep -c '^- \[x\]'`
    equals the number of `user-story.md` criteria marked PASS in the artifact;
    (f) the two criteria that assert
    `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes — `spec.md:619-620` and
    `user-story.md:159-161` — are marked PASS **only** when the exit code P5-T11 recorded for that
    node ID is 0. When P5-T11 instead recorded the accepted non-zero exit whose sole assertion
    message names a path under `.claude/state/`, both criteria are marked BLOCKED, both remain
    `- [ ]` in their source documents, and the artifact records open issue #510 as the cause
    together with the P5-T11 `cmp -s` loop result as supporting evidence that the seven mirrored
    files are byte-identical;
    (g) a criterion whose text carries a literal line span that this feature's own edits move is
    marked PASS on its substance, with the shift recorded in the artifact as a line-span note, and
    its criterion text is left unedited. There are exactly four such criteria:
    `spec.md:625-628` and `user-story.md:167-170`, which cite
    `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts:242-244` and
    `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts:451-453`, where P4-T6
    places its new entry below line 244 and P4-T7 places its new entry below line 453;
    `spec.md:611-615`, which cites the PowerShell paragraph at
    `.claude/agents/parallel-planner.md:147-156`, moved down one line by the single `tools:` entry
    P5-T4 adds inside lines 5-20; and `user-story.md:140-146`, which cites the stale sentence at
    `.claude/agents/parallel-planner.md:185-186`, moved further down by that same `tools:` addition
    plus the bash-paragraph documentation P5-T4 adds at lines 158-168. The substance of each is
    asserted by a clause that names content rather than a line number — P4-T6 clause (b), P4-T7's
    `git grep -c` clause, and P5-T4 clauses (a) through (d) and (f) — and those clauses are the
    evidence; and
    (h) **scoping-is-live demonstration.** On `spec.md`, the total checkbox count inside
    `## Acceptance Criteria`, printed by
    `awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' docs/features/active/2026-08-29-remove-remaining-python-invocations-599/spec.md | grep -c '^- \[[ x]\]'`,
    is 20, while the whole-file total, printed by
    `grep -c '^- \[[ x]\]' docs/features/active/2026-08-29-remove-remaining-python-invocations-599/spec.md`,
    is 24; the two therefore differ by exactly the four `## Definition of Done` items at
    `spec.md:641`. Both numbers are recorded in the artifact. This comparison is the only observation
    proving the section scoping in clauses (d) and (e) is applied rather than merely described: a
    whole-file scanner and a correctly-scoped one return the same number on a document with no
    out-of-section checkboxes and are indistinguishable there, so the 20-versus-24 difference is what
    makes the scoping falsifiable.
  - Clauses (c) through (e) are what tie the artifact to the documents. Without them the artifact
    could report PASS for a criterion whose checkbox was never changed, or a checkbox could be
    checked with no corresponding evidence row.
  - Clause (f) exists because clause (b) covers only the "no evidence artifact" case, and the two
    push-down criteria have an evidence artifact in both outcomes. Without clause (f) the executor
    would be free to choose the disposition of an environment-conditional result, which is the class
    of acceptance condition that cannot fail. Clause (g) closes the same class for the four criteria
    whose cited spans this feature's own edits move: without it the plan forbids editing criterion
    text and requires exactly PASS or BLOCKED but states no rule, leaving the disposition to the
    executor's choice. The pattern it follows is the one already established in P5-T4's
    "Reconciliation note for P6-T17".
  - Command-form notes for clauses (d), (e), and (h), observed against the tree this pass:
    - Both `spec.md` and `user-story.md` are LF-only, with no CR before any line terminator, so the
      `$` anchor in the awk range pattern `/^## Acceptance Criteria$/` matches the heading line.
    - The awk range opens on the exact heading and closes on the next line beginning `## `, so the
      window is `spec.md:555-640` and `user-story.md:118-188` and no later section contributes.
    - `grep -c` prints the count and exits 1 when the count is zero. The assertion is over the
      printed number, which is recorded in the artifact; the exit code is not the discriminator.
    - `^- \[x\]` counts checked criteria only, while `^- \[[ x]\]` counts checked and unchecked
      together. Clauses (d) and (e) use the first form; clause (h) uses the second, so its two
      numbers are invariant to how many criteria the executor checked off.
    - Run each command through the `wsl -d Ubuntu -e bash -lc` wrapper recorded in
      `## Command Forms`. Because that wrapper's argument is itself single-quoted, substitute double
      quotes for the two inner single-quoted arguments and escape the `$` in the awk range pattern as
      `\$` so bash leaves it literal for awk.

- [ ] [P6-T18] Record the epic-owner action for the Known Residual in
      `evidence/other/known-residual.<timestamp>.md`: the epic manifest's broad leading indicator at
      manifest line 14 is not fully satisfied after this feature lands, because non-goals 1 and 2
      remain by deliberate decision, while the narrow indicator at manifest line 15 is fully
      satisfied and its evidence is the payload-only case added in P4-T8.
  - Acceptance: the artifact exists, names both manifest line numbers, states that the corrective
    action is a manifest rewording owned by the epic owner, and states that no implementation change
    is made here.

- [ ] [P6-T19] Verify the 500-line file cap over **all five files this feature creates** by running
      `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && wc -l .claude/lib/bash/parallel-lane-assertion.sh .claude/lib/bash/report-lane-assertion.sh tests/shell/parallel_lane_assertion.bats tests/shell/parallel_lane_assertion_parity.bats tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py'`
      and recording every output line verbatim, including the `total` line, in
      `evidence/qa-gates/new-file-sizes.<timestamp>.md`.
  - Acceptance: `EXIT_CODE: 0`, the artifact carries one recorded line per file for all five files,
    and every per-file count is 500 or fewer. A count above 500 is a blocking finding.
  - Remedy when a bats file overruns: split it along `@test` group boundaries into a second bats
    file in the same directory — never mid-case and never by deleting cases — and re-run this task.
    For `tests/shell/parallel_lane_assertion.bats` the split seam is library cases (P1-T1 through
    P1-T6) versus entry-point cases (P2-T1 through P2-T8). Remedy when the Python parity module
    overruns: extract the corpus-loading helpers into a sibling module under
    `tests/scripts/dev_tools/` and re-run this task. Remedy when a bash library file overruns is the
    derivation-versus-comparison seam already recorded in P1-T7.
  - This task exists because P1-T7 and P2-T9 measure only the two bash production modules. The three
    new test files carry the same 500-line cap under `.claude/rules/general-code-change.md`, which
    applies the limit to production code, test code, and reusable scripts alike, and no other task
    in this plan measures them.

## Test Plan

- **Unit (bash):** `tests/shell/parallel_lane_assertion.bats` — library function coverage plus the
  entry point's usage, `--help`, exit-code, `--keys`-rejection, divergence-class-3,
  out-of-subset-refusal, and no-production-consumer cases. This is where the kcov line coverage is
  earned.
- **Parity (bash lane):** `tests/shell/parallel_lane_assertion_parity.bats` over
  `tests/fixtures/parallel_lane_assertion/*.json`, invoking the entry point as a subprocess so both
  stdout and exit status are pinned, with a `MINIMUM_FIXTURE_COUNT` floor of 20 asserted in its own
  case and a `python3 is available` case so the suite cannot pass vacuously.
- **Parity (Python lane):** `tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py`
  over the same corpus, calling `main()` with no subprocess, with the same floor asserted in its own
  test.
- **Destination portability:** new case in `tests/shell/parallel_payload_only.bats` invoking the
  entry point from the bundle root under the four-shim `PATH`.
- **Mirror and manifest membership:** `tests/shell/parallel_bash_manifest_membership.bats` with
  `MINIMUM_LIB_FILE_COUNT` raised to 11, and
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
- **TypeScript:** `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`
  and `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts`, the latter together
  with its seeding helper `config-carriage.test-helpers.ts`.
- **PowerShell regression:** `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`.
- **No temporary files anywhere.** Every manifest, corpus record, and PATH shim is checked in.
- **File-size gate:** P1-T7 and P2-T9 measure the two bash production modules; P6-T19 measures all
  five created files, including the three new test files, and records every count in
  `evidence/qa-gates/new-file-sizes.<timestamp>.md`.
- **Coverage evidence:** baselines at `evidence/baseline/bash-coverage.<timestamp>.md`,
  `evidence/baseline/python-lane-assertion-coverage.<timestamp>.md`, and
  `evidence/baseline/ts-coverage.<timestamp>.md`; post-change values at
  `evidence/qa-gates/final-bash-coverage.<timestamp>.md`,
  `evidence/qa-gates/bash-new-file-coverage.<timestamp>.md`,
  `evidence/qa-gates/final-python-coverage.<timestamp>.md`, and
  `evidence/qa-gates/final-ts-coverage.<timestamp>.md`; comparison at
  `evidence/other/coverage-delta.<timestamp>.md`.

## Open Questions / Notes

- **Change budget.** No PowerShell production or test file is added or modified, so the PowerShell
  per-batch cap of 3 production and 3 test files does not bind. The Python change set is one new test
  module and no production module, inside the 3-production / 3-test cap. The bash change set is two
  new production files; `.claude/rules/shell.md` sets no per-batch file cap, only the 500-line
  per-file cap. The cap is verified by three tasks together: P1-T7 and P2-T9 cover the two bash
  production modules, and P6-T19 covers all five created files, including the three new test files
  that P1-T7 and P2-T9 do not measure.
- **Deliberate G7 warnings.** Five tasks invoke a tool the G7 heuristic classifies as write-mode:
  P4-T1 and P6-T1 (`shfmt -w` through `shell-qc.sh format`), P6-T6 (`black`), P6-T10
  (`prettier --write`), and P0-T5 with P6-T7 (`ruff check`). Their observations, recorded against
  the clean tree rather than inferred:
  - `poetry run ruff check .` is **read-only** in this repository. `[tool.ruff]` at
    `pyproject.toml:88-91` sets only `line-length`, `target-version`, and `show-fixes`; there is no
    `fix = true` and `--fix` is not passed. Observed output on the clean tree: exit 0 and stdout
    exactly `All checks passed!`. P0-T5 and P6-T7 assert that literal. The G7 warning on those two
    tasks is a conservative-heuristic false positive.
  - `poetry run black .` observed on the clean tree: exit 0, stdout `All done!` then
    `457 files left unchanged.`, with `git status --porcelain` unchanged afterwards. P6-T6 asserts
    the **absence of any line beginning `reformatted `**, which black emits once per rewritten file
    on a repairing run, and does not assert the file count, because this feature adds a Python test
    file and the count will move.
  - `shfmt -w` and `prettier --write` print a path only when they rewrite and exit 0 either way.
    A before-and-after `git status --porcelain` listing does **not** discriminate for the files this
    feature touches: an untracked file stays `?? <path>` and an already-modified file stays
    ` M <path>` whether or not the formatter rewrote it, and both new bash files are untracked
    throughout this plan while both edited TypeScript test files are already modified by P4-T6 and
    P4-T7. P4-T1 and P6-T1 therefore state a before-and-after `sha256sum` digest over the exact
    `discover_shell_scripts` output that `run_format` writes, and P6-T10 states a read-only
    `prettier --check` over the same glob set the `format` script uses. Both are observations beyond
    the exit code, which is what G7 requires.
- **Feature A has no application surface here.** Its fail-fast import convention is
  `$ErrorActionPreference` plus `Import-Module -ErrorAction Stop`, both PowerShell constructs with no
  bash analogue, and its date-coercion work targets the three `ConvertFrom-Json` sites under
  `.claude/lib/**`. This port adds no PowerShell file, parses no JSON, and reads no timestamp. The
  bash equivalents — `set -euo pipefail`, self-directory resolution before sourcing, and
  `pc_enforce_c_locale` before any work — are followed instead, and are verified by P2-T1.
- **Feature C contention.** Both features edit `## Upstream Library Invocation` in
  `.claude/agents/parallel-planner.md`. P5-T4 confines this feature's edits to the `tools:` list and
  the bash paragraph and leaves the PowerShell paragraph at lines 147-156 untouched.
- **Residual risk.** The repository-to-bundle copy has no automation. Seven mirrored files and one
  bundle-only manifest edit are each a separate manual step, guarded by exactly three assertions:
  `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, the `cmp -s` cases in
  `tests/shell/parallel_bash_manifest_membership.bats:56-71`, and the `core.json` membership case at
  lines 43-54. P5-T11 is the gate that closes this risk, and it carries two parts because the first
  of those three assertions is environment-conditional under open issue #510: the pytest half is
  accepted with a non-zero exit only when its sole assertion message names a path under
  `.claude/state/`, and the `cmp -s` loop over the seven enumerated mirrored files is the durable
  half that does not depend on that condition.
- **`## Definition of Done` is deliberately outside P6-T17's scope.** The four `spec.md` checkboxes
  under `## Definition of Done` at `spec.md:641` are not acceptance criteria and are not counted,
  reconciled, or checked off by P6-T17. This is consistent with the `acceptance-criteria-tracking`
  skill, which enumerates `## Acceptance Criteria`, `### Acceptance Criteria`, and `## Done When` as
  acceptance-criteria sources and does not enumerate `## Definition of Done`. Their presence outside
  the scoped window is what makes `spec.md` a valid out-of-section fixture for P6-T17 clause (h), so
  no synthetic fixture is needed: the whole-file checkbox total is 24 and the
  `## Acceptance Criteria` total is 20.
- **Section-scoped counting is a standing requirement.** Any acceptance condition in this plan that
  counts checkboxes or list items inside a generated or maintained document scopes its match to the
  named section rather than the whole file, and is demonstrated against a document that carries
  unrelated checkboxes outside that section. P6-T17 clauses (d), (e), and (h) are the only such
  conditions in this plan; clause (h) is the demonstration.
- **Open epic-owner decision — `.claude/settings.json` permissions.** The fourth bash entry point
  receives no project-level grant in this feature. The rationale, the affected line span, and the
  bundle-mirror consequence are recorded in Fixed Design Decision 9. No task in this plan edits
  `.claude/settings.json` or its bundle mirror, and P5-T3's replacement wording at
  `.claude/skills/parallel-plan/SKILL.md:316` is required not to claim a grant that will not exist.
