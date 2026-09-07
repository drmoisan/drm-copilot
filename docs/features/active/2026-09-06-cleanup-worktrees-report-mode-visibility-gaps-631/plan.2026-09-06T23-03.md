# cleanup-worktrees-report-mode-visibility-gaps (Plan)

- **Issue:** #631
- **Parent:** Epic `cleanup-merged-worktrees-hardening` (`docs/features/epics/cleanup-merged-worktrees-hardening/epic.md`), child B
- **Owner:** drmoisan
- **Last Updated:** 2026-09-06T23-03
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug
- **AC source:** `spec.md` `## Acceptance Criteria` (11 items, AC1-AC11 below)

**Fail-closed evidence rule:** every baseline, regression, and final-QA artifact required below
must exist with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` fields before its
owning task may be checked off. A missing or incomplete artifact leaves the task unchecked.

**Evidence location:** all evidence in this plan resolves under
`docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/<kind>/`
(`baseline/`, `regression-testing/`, `qa-gates/`, `other/`). No `artifacts/`-rooted evidence path
is used anywhere in this plan.

**Toolchain invocation (bash, all commands in this plan):**
```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/<worktree path, forward slashes, no drive colon> && <command>'
```
per `.claude/rules/shell.md`. `shfmt`/`shellcheck` are also available directly on the Windows PATH.

## Design decisions settled by this plan (not left to the executor)

1. **Filesystem-scan seam is a single combined resolver, `CLEANUP_WT_SCAN_BIN`.** It mirrors
   `cleanup_wt_git`'s override shape (`scripts/bash/cleanup_worktrees_enumerate_lib.sh:34-57`:
   honor the env override when set and executable; otherwise fall back), but the fallback target
   is a new bundled real-implementation script (`scripts/bash/cleanup_worktrees_scan_helper.sh`)
   rather than `command -v <tool>`, because no single standard system binary emits the combined
   `path|has_gitfile|gitdir_target_exists|size` tuple this feature needs. This keeps a working,
   independently testable production implementation while giving bats a fully deterministic,
   checked-in-fixture-driven substitute for classification-level tests.
2. **`CHILD_OF` short-circuit is one-level (direct ancestor-target) only, not transitive-chain
   optimizing.** AC3 and the Test Strategy in `spec.md` require correctness for a branch whose
   *direct* ancestor-target already resolved `NOT_MERGED`; neither requires optimizing a
   multi-level ancestor chain. `classify_all_branches` (Phase 6) therefore short-circuits a
   branch only when at least one of its direct ancestor-targets was already resolved as
   `NOT_MERGED` via the unchanged full ladder; any branch whose only ancestor-targets are
   themselves un-independent (deferred) branches simply falls through to the full ladder. This
   never produces a wrong verdict (the outcome-preservation invariant is cost-only), it only
   forgoes the deeper optimization the research flagged as an open question.
3. **`STALE_REF` reads `git for-each-ref --format='%(refname)' refs/remotes/` (full ref form, not
   `:short`)** so the emitted `<refname>` matches `spec.md`'s literal example shape
   (`refs/remotes/child/*`), and `git remote` (no flags, one name per line) for the configured
   remote set.
4. **Emission order** in `run_report`: `check_main_freshness` (existing, unchanged) is followed
   immediately by `scan_stale_refs`, then `scan_orphan_dirs`, then `scan_registration_loss` (all
   three are pre-branch-loop, since none depend on per-branch classification), then the existing
   `WORKTREE|` loop, then the shared `classify_all_branches` call for `BRANCH|`/`CHILD_OF|`/
   `COMMIT|` lines. This colocates every new advisory/scan line with the existing
   `WARN|main-divergence` pre-branch output, per the research's recommendation.
5. **New scenario names use the remote name `upstream`, never the literal `child`**, directly
   satisfying AC2's generality requirement.

## Acceptance Criteria Inventory (from `spec.md`, verbatim scope, 11 items)

- **AC1** — `ORPHAN_DIR|<path>|<size>` positive/negative bats pair.
- **AC2** — `STALE_REF|<refname>` positive/negative bats pair, general (non-`child` name).
- **AC3** — `CHILD_OF|<branch>|<ancestor>` positive/negative bats pair with argv-log proof that
  expensive rungs were skipped in the positive case.
- **AC4** — `WARN|registration-lost|<path>` positive/negative bats pair.
- **AC5** — Outcome-preservation invariant, two separately-tested properties: (a) report-mode
  `BRANCH|` line unchanged; (b) apply-mode allowlist decision unchanged.
- **AC6** — `for-each-ref` stub key-specificity edit is backward compatible: full existing suite
  passes unchanged immediately after the edit, before new fixtures are authored.
- **AC7** — SKILL.md Report Line Contract documents all four new types, cross-referencing (not
  duplicating) existing orphan guidance, mirrored byte-identically into the extension bundle,
  verified by the existing push-down contract test.
- **AC8** — `cleanup_worktrees_lib.sh` stays at or under 500 lines after the `run_report`
  call-site edit.
- **AC9** — Full toolchain loop (`format`, `check`, `test`, `test --coverage`) passes with line
  coverage >= 85%, no bash branch-coverage gate.
- **AC10** — No automatic deletion of orphan directories or stale refs is introduced.
- **AC11** — No AC or test asserts a fixed historical numeric count (four dirs / 17 refs / two
  worktrees); detection is generic and parameterized.

---

### Phase 0 — Policy Reads & Bash Toolchain Baseline

- [x] [P0-T1] Read `CLAUDE.md` in full. Acceptance: no file changes; task checked only after the
      file has been read in this session.
- [x] [P0-T2] Read `.claude/rules/general-code-change.md` in full, noting the 500-line file-size
      cap (File Size Limit section). Acceptance: read confirmed.
- [x] [P0-T3] Read `.claude/rules/general-unit-test.md` in full, noting the no-temp-file test
      policy and the 85%/75% coverage thresholds (line coverage applies to bash; no bash
      branch-coverage gate). Acceptance: read confirmed.
- [x] [P0-T4] Read `.claude/rules/shell.md` in full, noting the four-stage toolchain order
      (format -> check -> test -> test --coverage), the `SHELL_QC_<TOOL>_BIN` seam convention,
      and the 500-line cap restated for shell files. Acceptance: read confirmed.
- [x] [P0-T5] Write the Phase 0 policy-read evidence artifact at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/baseline/phase0-instructions-read.md`
      containing `Timestamp:`, `Policy Order:` (the four files above, in order), and the explicit
      file list read. Acceptance: file exists with all three required fields present.
- [x] [P0-T6] Run `bash scripts/bash/shell-qc.sh format` (write-mode; rewrites in place with no
      stdout on a clean run per `run_format` in `scripts/bash/shell_qc_lib.sh:204-224`). Record
      evidence at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/baseline/baseline-format.2026-09-06T23-03.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` that additionally states
      the result of `git status --porcelain -- scripts/bash tests/shell` run immediately
      afterward (a tree observation distinguishing a no-op run from a repairing one, since
      `shfmt -w`'s exit code is identical in both cases). Acceptance: `EXIT_CODE: 0` and the
      porcelain-status observation is recorded verbatim.
- [x] [P0-T7] Run `bash scripts/bash/shell-qc.sh check`. Record evidence at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/baseline/baseline-check.2026-09-06T23-03.md`
      with the four required fields. Acceptance: `EXIT_CODE: 0` and `Output Summary:` states the
      shellcheck/shfmt result.
- [x] [P0-T8] Run `bash scripts/bash/shell-qc.sh test`. Record evidence at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/baseline/baseline-test.2026-09-06T23-03.md`
      with the four required fields, including the total bats test count observed. Acceptance:
      `EXIT_CODE: 0`.
- [x] [P0-T9] Run `bash scripts/bash/shell-qc.sh test --coverage`. Record evidence at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/baseline/baseline-test-coverage.2026-09-06T23-03.md`
      with the four required fields; `Output Summary:` must include the literal printed line
      `Bash coverage (lines): NN.N%` (the exact numeric baseline, per
      `scripts/bash/shell_qc_lib.sh:291`). Acceptance: `EXIT_CODE: 0` and the numeric baseline
      coverage value is recorded.

### Phase 1 — Sibling Library Skeleton, Filesystem-Scan Seam, and Real Scanner Helper

- [x] [P1-T1] Create `scripts/bash/cleanup_worktrees_report_records_lib.sh` (new file) with a
      header comment documenting: the sourcing contract (functions only, no side effects at
      source time, matching `cleanup_worktrees_enumerate_lib.sh:12-14`'s pattern), the four new
      report-line shapes (`ORPHAN_DIR|<path>|<size>`, `STALE_REF|<refname>`,
      `CHILD_OF|<branch>|<ancestor>`, `WARN|registration-lost|<path>`), and the
      `cleanup_wt_scan_bin` resolver function (resolves `CLEANUP_WT_SCAN_BIN`; when unset or
      non-executable, falls back to `"$(dirname "${BASH_SOURCE[0]}")/cleanup_worktrees_scan_helper.sh"`).
      Acceptance: file exists; `bash -n scripts/bash/cleanup_worktrees_report_records_lib.sh`
      exits 0.
- [x] [P1-T2] Create `scripts/bash/cleanup_worktrees_scan_helper.sh` (new standalone executable,
      `chmod +x`), implementing `scan-dirs <root-dir> [<root-dir> ...]`: for each root that exists
      as a directory, for each immediate subdirectory, emit one line
      `<path>|<has_gitfile:0|1>|<gitdir_target_exists:0|1|NA>|<size-or-unknown>`, where
      `has_gitfile` is `test -f "$dir/.git"`, `gitdir_target_exists` is `NA` when `has_gitfile=0`
      and otherwise the result of resolving the `gitdir: <target>` line's target relative to
      `$dir` and testing its existence, and `size` is `du -sh "$dir" 2>/dev/null | cut -f1`,
      falling back to the literal `unknown` when `du` fails or returns empty. Acceptance:
      `bash -n scripts/bash/cleanup_worktrees_scan_helper.sh` exits 0 and the file is executable.
- [x] [P1-T3] Add a checked-in real fixture directory tree under
      `tests/fixtures/cleanup_worktrees/scan_roots/basic/` with four committed subdirectories:
      `no_git/` (containing only a placeholder file `no_git/.gitkeep`, no `.git` file),
      `good_wt/` (containing `good_wt/.git` with the single line `gitdir: ../good_wt_target`) and
      a sibling `good_wt_target/` directory (containing a placeholder file
      `good_wt_target/.gitkeep`), and `broken_wt/` (containing `broken_wt/.git` with the single
      line `gitdir: ../missing_target_does_not_exist`, and no such sibling directory). Acceptance:
      all four directories and their files exist as tracked content (confirmed via
      `git status --porcelain -- tests/fixtures/cleanup_worktrees/scan_roots` showing them staged
      or already committed, not untracked-and-ignored).
- [ ] [P1-T4] Add `tests/shell/test_cleanup_worktrees_scan_helper.bats` (new file) with one
      `@test "scan-dirs emits has_gitfile/target_exists/size for each candidate directory"` that
      runs `scripts/bash/cleanup_worktrees_scan_helper.sh scan-dirs tests/fixtures/cleanup_worktrees/scan_roots/basic`
      and asserts the output contains a line matching `no_git|0|NA|*`, a line matching
      `good_wt|1|1|*`, and a line matching `broken_wt|1|0|*` (the size field asserted only as
      non-empty via a glob match, per `spec.md`'s size-is-best-effort clause). Acceptance:
      `bats tests/shell/test_cleanup_worktrees_scan_helper.bats` exits 0.
- [x] [P1-T5] Add `tests/fixtures/cleanup_worktrees/stub-bin/scan` (new checked-in stub binary,
      `chmod +x`), mirroring `tests/fixtures/cleanup_worktrees/stub-bin/git`'s `respond()` shape
      (documented in that file's header, `tests/fixtures/cleanup_worktrees/stub-bin/git:10-19`):
      reads `CLEANUP_WT_STUB_SCENARIO`, derives the fixed key `scan-dirs` for a `scan-dirs`
      invocation, replays `<scenario>/scan-dirs.out` to stdout and exits with
      `<scenario>/scan-dirs.rc` (default 0), emitting nothing with exit 0 when no scenario is
      configured. Acceptance: `bash -n tests/fixtures/cleanup_worktrees/stub-bin/scan` exits 0.
- [ ] [P1-T6] Add `tests/shell/test_cleanup_worktrees_scan_seam.bats` (new file) with two
      `@test` blocks: `"cleanup_wt_scan_bin honors an executable CLEANUP_WT_SCAN_BIN override"`
      (asserts the resolver echoes the override path when set and executable) and
      `"cleanup_wt_scan_bin falls back to the bundled scan helper when unset"` (asserts the
      resolver echoes a path ending in `cleanup_worktrees_scan_helper.sh` when
      `CLEANUP_WT_SCAN_BIN` is empty). Acceptance:
      `bats tests/shell/test_cleanup_worktrees_scan_seam.bats` exits 0 for both tests.
- [ ] [P1-T7] Add a `classify_all()` bats helper to
      `tests/shell/test_cleanup_worktrees_classification.bats`, forward-declared here in Phase 1
      (an explicitly permitted placement, alongside Phase 6, for the round-3 defect requirement to
      specify Phase 6's direct-invocation mechanism for `classify_all_branches`) so Phase 6's
      `@test` blocks can call `classify_all_branches` directly, independent of `run_report`'s
      Phase-7 wiring: add `RLIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_report_records_lib.sh"`
      to `setup()` (currently lines 8-15, immediately after the existing `LIB=` assignment at line
      11), and add a new helper function immediately after the existing `cb()` helper (currently
      lines 17-22): `classify_all() { run env CLEANUP_WT_GIT_BIN="${STUB}"
      CLEANUP_WT_STUB_SCENARIO="${SCEN}/$1" bash -c "source '${ELIB}' && source '${LIB}' && source
      '${RLIB}' && classify_all_branches"; }`. This helper deliberately carries NO `2>/dev/null`
      redirection (unlike `cb()` and `report()`), so `$output` in a test using it carries the
      merged `stub-git:` stderr argv log that P6-T4's and P6-T5's assertions read. Acceptance:
      `bash -n tests/shell/test_cleanup_worktrees_classification.bats` exits 0; `grep -c
      "classify_all() {" tests/shell/test_cleanup_worktrees_classification.bats` returns exactly
      `1`.

### Phase 2 — Git Stub Backward-Compatible Extension and Full-Suite Regression Gate

- [x] [P2-T1] Edit `tests/fixtures/cleanup_worktrees/stub-bin/git` in two places. (1) The
      `for-each-ref)` case (currently lines 97-99: `respond "for-each-ref"`) to derive a
      pattern-specific key from the last argument (the refspec pattern) via `sanitize`: when
      `${scenario}/for-each-ref.<that sanitized pattern>.out` or the matching `.rc` file exists,
      respond with that specific key (`for-each-ref.<sanitized-pattern>`); otherwise, when (and
      only when) the raw pattern argument is exactly the literal string `refs/heads/` (the sole
      historical call shape, confirmed at `scripts/bash/cleanup_worktrees_enumerate_lib.sh:75`),
      fall back to the existing bare `for-each-ref` key unchanged; otherwise (any other pattern,
      including `refs/remotes/`, with no matching specific-key file) respond with the specific key
      anyway, which `respond`'s own no-file behavior
      (`tests/fixtures/cleanup_worktrees/stub-bin/git:60-68`) resolves to empty stdout and exit 0 —
      never the bare `refs/heads/`-shaped fallback data. This restricts the bare-key fallback to
      the `refs/heads/` pattern only, so an absent `refs/remotes/`-scoped fixture file yields empty
      output rather than misapplied `refs/heads/` branch/sha lines. (2) The `merge-base)` case
      (currently lines 108-114: `respond "merge-base.$(sanitize "${3:-}")"`, keyed only on the
      first positional argument after `--is-ancestor` — the `<tip>` — per the header KEY-scheme
      comment's `merge-base` line, currently line 25) to a target-aware key: compute
      `tip_key="$(sanitize "${3:-}")"` and `up_key="$(sanitize "${4:-}")"`; when a scenario is
      configured and either `$scenario/merge-base.${tip_key}.${up_key}.out` or
      `$scenario/merge-base.${tip_key}.${up_key}.rc` exists, respond with the target-aware key
      `merge-base.${tip_key}.${up_key}`; otherwise respond with the existing bare key
      `merge-base.${tip_key}` unchanged. A repository-wide check
      (`find tests/fixtures/cleanup_worktrees/scenarios -iname 'merge-base*'`) confirms all 16
      existing `merge-base.<branch>.rc` fixture files use only the bare single-segment form (no
      second `.`-delimited segment before `.rc`), so this fallback is fully backward compatible
      with every existing scenario. Also update the file's header KEY-scheme comment (currently
      lines 20-41) to document both the new specific-then-conditional-fallback form for
      `for-each-ref` (stating explicitly that the fallback applies only to the `refs/heads/`
      pattern) and the new target-aware-then-bare-fallback form for `merge-base`
      (`merge-base --is-ancestor <tip> <up> -> merge-base.<tip>.<up>, falling back to
      merge-base.<tip>`). Acceptance: `bash -n tests/fixtures/cleanup_worktrees/stub-bin/git`
      exits 0; the diff touches only the `for-each-ref)` case body, the `merge-base)` case body,
      and the header documentation lines for those two entries — no other case arm.
- [x] [P2-T2] Edit the same file to add a new `remote)` case (currently falling through to the
      default `*) exit 0 ;;` arm at lines 205-207) that responds with the fixed key `remote`.
      Place it adjacent to the existing `fetch)` case. Acceptance:
      `bash -n tests/fixtures/cleanup_worktrees/stub-bin/git` exits 0; a `remote)` case precedes
      the `*)` default arm in the case statement.
- [ ] [P2-T3] Immediately after P2-T1 (which now edits both the `for-each-ref)` case and the
      `merge-base)` case) and P2-T2, and before any new scenario fixture directory is authored for
      STALE_REF/ORPHAN_DIR/WARN/CHILD_OF, run `bash scripts/bash/shell-qc.sh test` (full existing
      suite, all directories under `tests/shell` and `tests/bash`). Record evidence at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/regression-testing/stub-git-backward-compat.2026-09-06T23-03.md`
      with the four required fields; `Output Summary:` must state the total test count, confirm it
      is not lower than the count recorded in the Phase 0 `baseline-test` artifact (P0-T8), and
      explicitly confirm that both the `for-each-ref` key-specificity edit and the `merge-base`
      target-aware key edit pass every pre-existing scenario directory unchanged. Acceptance:
      `EXIT_CODE: 0` and both the test-count non-regression statement and the two-stub-edit
      confirmation are present. This satisfies AC6.

### Phase 3 — `STALE_REF` Detection

- [x] [P3-T1] Add `scan_stale_refs` to `scripts/bash/cleanup_worktrees_report_records_lib.sh`:
      guarded parent-shell captures of `cleanup_wt_git for-each-ref --format='%(refname)' refs/remotes/`
      and `cleanup_wt_git remote`; for each captured remote-tracking ref, extracts `<name>` as the
      path segment immediately following `refs/remotes/` (`${ref#refs/remotes/}`, then
      `${name%%/*}`); emits `STALE_REF|<refname>` (full ref form) for every ref whose `<name>` is
      absent from the remote-name list, `LC_ALL=C` sorted. A hard failure (non-zero exit) of
      either git call returns non-zero with no `STALE_REF|` line emitted, mirroring
      `parse_worktree_list`'s hard-failure contract
      (`scripts/bash/cleanup_worktrees_enumerate_lib.sh:120-128`). Acceptance:
      `bash -n scripts/bash/cleanup_worktrees_report_records_lib.sh` exits 0; the function is
      defined.
- [x] [P3-T2] Add scenario fixture directory
      `tests/fixtures/cleanup_worktrees/scenarios/stale_ref_present/` with: `for-each-ref.out`
      (bare key; a single `refs/heads/` branch line, e.g. `main aaaa0000`, for branch
      enumeration), `for-each-ref.refs_remotes_.out` (one line,
      `refs/remotes/upstream/feature-old`), `remote.out` (one line, `origin`), and
      `rev-parse.abbrev-ref-HEAD.out` / `rev-parse.show-toplevel.out` /
      `worktree-list.out` (minimal single-main-worktree shapes, matching the format used by
      `tests/fixtures/cleanup_worktrees/scenarios/current_exclusion/`). Acceptance: all listed
      files exist under the new directory.
- [x] [P3-T3] Add scenario fixture directory
      `tests/fixtures/cleanup_worktrees/scenarios/stale_ref_absent/`, identical to
      `stale_ref_present/` except `remote.out` additionally lists `upstream` (two lines: `origin`,
      `upstream`), so no remote-tracking ref is stale. Acceptance: all listed files exist.
- [ ] [P3-T4] Add `tests/shell/test_cleanup_worktrees_report_records.bats` (new file) with a
      `setup()` block matching the pattern in
      `tests/shell/test_cleanup_worktrees_enumeration.bats:9-19`, plus two `@test` blocks:
      `"scan_stale_refs emits STALE_REF for a remote-tracking ref with no configured remote"`
      (under `stale_ref_present`, asserts `$output` equals exactly
      `STALE_REF|refs/remotes/upstream/feature-old`) and
      `"scan_stale_refs emits nothing when the remote exists"` (under `stale_ref_absent`, asserts
      `$output` is empty). Acceptance:
      `bats tests/shell/test_cleanup_worktrees_report_records.bats` exits 0 for both tests. This
      satisfies AC2 (the fixture uses `upstream`, not `child`, proving generality).

### Phase 4 — `ORPHAN_DIR` Detection

- [x] [P4-T1] Add `scan_orphan_dirs` to `scripts/bash/cleanup_worktrees_report_records_lib.sh`:
      resolves default scan roots (`.claude/worktrees` and `${main_wt}-wt`, where `main_wt` is
      the first `parse_worktree_list` stanza path, matching the derivation convention in
      `consolidation_worktree_path`, `scripts/bash/cleanup_worktrees_actions_lib.sh:39-68`),
      honoring a `CLEANUP_WT_ORPHAN_ROOTS` colon-separated override; invokes
      `"$(cleanup_wt_scan_bin)" scan-dirs <roots>`; cross-references `parse_worktree_list`'s
      registered paths (normalized via `normalize_wt_path`); emits `ORPHAN_DIR|<path>|<size>` for
      every scanned record with `has_gitfile=0` whose path is not among the registered paths,
      `LC_ALL=C` sorted; a record with `size=unknown` is emitted verbatim, never dropped.
      Acceptance: `bash -n scripts/bash/cleanup_worktrees_report_records_lib.sh` exits 0; the
      function is defined.
- [x] [P4-T2] Add scenario fixture directory
      `tests/fixtures/cleanup_worktrees/scenarios/orphan_dir_present/` with `scan-dirs.out`
      containing the line `.claude/worktrees/agent-old|0|NA|128K` and a `worktree-list.out` that
      does not list `.claude/worktrees/agent-old` as a registered path. Acceptance: files exist.
- [x] [P4-T3] Add scenario fixture directory
      `tests/fixtures/cleanup_worktrees/scenarios/orphan_dir_absent/` with `scan-dirs.out`
      containing the line `/repo-wt/feat|1|1|64K` and a `worktree-list.out` that DOES list
      `/repo-wt/feat` as a registered worktree path. Acceptance: files exist.
- [ ] [P4-T4] Append two `@test` blocks to `tests/shell/test_cleanup_worktrees_report_records.bats`:
      `"scan_orphan_dirs emits ORPHAN_DIR for an unregistered, .git-less directory"` (under
      `orphan_dir_present`, asserts `$output` equals exactly
      `ORPHAN_DIR|.claude/worktrees/agent-old|128K`) and
      `"scan_orphan_dirs emits nothing for a registered worktree directory"` (under
      `orphan_dir_absent`, asserts `$output` is empty). Acceptance:
      `bats tests/shell/test_cleanup_worktrees_report_records.bats` exits 0 for both new tests.
      This satisfies AC1.

### Phase 5 — `WARN|registration-lost` Detection

- [x] [P5-T1] Add `scan_registration_loss` to
      `scripts/bash/cleanup_worktrees_report_records_lib.sh`: consumes the same
      `"$(cleanup_wt_scan_bin)" scan-dirs <roots>` output as `scan_orphan_dirs` (same roots
      resolution); emits `WARN|registration-lost|<path>` for every record with `has_gitfile=1`
      and `gitdir_target_exists=0`, `LC_ALL=C` sorted; a record whose fields cannot be parsed
      (unexpected shape) is skipped silently, mirroring `check_main_freshness`'s never-blocking
      contract (`scripts/bash/cleanup_worktrees_enumerate_lib.sh:221-236`). Acceptance:
      `bash -n scripts/bash/cleanup_worktrees_report_records_lib.sh` exits 0; the function is
      defined.
- [x] [P5-T2] Add scenario fixture directory
      `tests/fixtures/cleanup_worktrees/scenarios/registration_lost_present/` with
      `scan-dirs.out` containing the line `/repo-wt/half-gone|1|0|32K`. Acceptance: file exists.
- [x] [P5-T3] Add scenario fixture directory
      `tests/fixtures/cleanup_worktrees/scenarios/registration_lost_absent/` with `scan-dirs.out`
      containing the line `/repo-wt/intact|1|1|32K`. Acceptance: file exists.
- [ ] [P5-T4] Append two `@test` blocks to `tests/shell/test_cleanup_worktrees_report_records.bats`:
      `"scan_registration_loss emits WARN|registration-lost for a broken gitdir pointer"` (under
      `registration_lost_present`, asserts `$output` equals exactly
      `WARN|registration-lost|/repo-wt/half-gone`) and
      `"scan_registration_loss emits nothing when the gitdir pointer resolves"` (under
      `registration_lost_absent`, asserts `$output` is empty). Acceptance:
      `bats tests/shell/test_cleanup_worktrees_report_records.bats` exits 0 for both new tests.
      This satisfies AC4.

### Phase 6 — `CHILD_OF` Shared Classification Driver

- [x] [P6-T1] Add `classify_all_branches` to
      `scripts/bash/cleanup_worktrees_report_records_lib.sh` with a header comment documenting
      the two-phase contract (design decision 2 above): (1) for every ordered branch pair `(X,Y)`,
      `X != Y`, run `cleanup_wt_git merge-base --is-ancestor <tip-X> <tip-Y>`, captured with
      `|| rc=$?`; `rc=0` records `Y` as an ancestor-target of `X`; `rc=1` records nothing; `rc>1`
      immediately emits `BRANCH|X|ANCESTRY_ERROR` and excludes `X` from further processing (no
      silent "not an ancestor" fallback, matching the ANCESTRY_ERROR convention documented at
      `scripts/bash/cleanup_worktrees_lib.sh:36-38`); (2) every remaining branch with zero
      ancestor-targets ("independent") is classified via the unchanged `classify_branch`,
      recording its resolved state from the `BRANCH|` line; (3) every remaining branch with one or
      more ancestor-targets ("deferred") is processed in `LC_ALL=C` order: if any of its
      ancestor-targets already has a recorded state of exactly `NOT_MERGED`, emit
      `BRANCH|X|NOT_MERGED` then `CHILD_OF|X|<that-target>` without invoking `classify_branch` for
      `X`; otherwise invoke `classify_branch(X)` via the normal full ladder. The function echoes,
      for every branch in `enumerate_branches`' original order, that branch's own `BRANCH|`,
      optional `CHILD_OF|`, and any `COMMIT|` lines, and returns the maximum per-branch return
      code observed. Acceptance: `bash -n scripts/bash/cleanup_worktrees_report_records_lib.sh`
      exits 0; the function is defined and calls `classify_branch` (not a reimplementation of the
      ladder).
- [x] [P6-T2] Add scenario fixture directory
      `tests/fixtures/cleanup_worktrees/scenarios/child_of_not_merged/` with two branches
      `feature-child` and `feature-parent`: `for-each-ref.out` listing both branch/sha pairs plus
      `main`; `merge-base.feature-child.rc` absent (default rc 0, i.e. `feature-child` IS an
      ancestor of `feature-parent`'s tip when probed with `feature-parent`'s tip as the second
      arg) — supply `merge-base.feature-parent.rc` set to `1` (feature-parent is NOT an ancestor
      of main, continuing feature-parent's own ladder to `unmerged`'s fixture shape); the
      remaining fixtures needed for `feature-parent` to resolve `NOT_MERGED` via the full ladder
      (mirroring `tests/fixtures/cleanup_worktrees/scenarios/unmerged/`'s file set, renamed to
      `feature-parent`); and deliberately NO `cherry.feature-child.*`, `diff-tree.*` keyed to a
      `feature-child` sha, or `rev-list.feature-child.*` files, so that an accidental full-ladder
      invocation for `feature-child` produces an empty/absent stub response distinguishable from
      the expected short-circuit path. Also supply `merge-base.main.rc` = `1` (the bare fallback
      key from P2-T1's target-aware scheme, applying to every probe with `main` as the tip): `main`
      is itself one of the three branches enumerated from `for-each-ref.out`, and with no fixture
      for tip=`main` the stub would default every `merge-base --is-ancestor <main-tip> <up>` probe
      to rc 0, falsely recording `main` as an ancestor-target of both `feature-child` and
      `feature-parent`. This fixture keeps `main` independent, so it is resolved via its own
      `classify_branch` call to `PROTECTED_CURRENT` rather than any `CHILD_OF`-driven
      short-circuit. Acceptance: directory and files exist, including `merge-base.main.rc`; the
      omission of `feature-child`'s expensive-rung files is intentional and documented in a
      fixture-local `README` is NOT required, but the task description above is the source of
      truth for what must be absent.
- [x] [P6-T3] Add scenario fixture directory
      `tests/fixtures/cleanup_worktrees/scenarios/child_of_merged_equivalent/` with the same three
      branches as P6-T2 (`for-each-ref.out` listing `feature-child`, `feature-parent`, and `main`,
      mirroring P6-T2's shape), where `feature-parent` resolves `MERGED_EQUIVALENT` (mirroring
      `tests/fixtures/cleanup_worktrees/scenarios/residual_on_main/`'s fixture shape, renamed to
      `feature-parent`, reusing its bare `merge-base.feature-parent.rc` = `1` so `feature-parent`
      remains independent), and `feature-child` DOES carry its own full set of ladder fixtures
      (`diff-quiet.feature-child.rc`, `cherry.feature-child.out`, a `diff-tree.<sha>.out` keyed to
      its own sha, `rev-list.feature-child.out`, etc., mirroring
      `tests/fixtures/cleanup_worktrees/scenarios/unmerged/`'s shape renamed to `feature-child`),
      since the short-circuit must not apply and `feature-child` must classify normally via its own
      full ladder to `NOT_MERGED`. Using the target-aware `merge-base` key added in P2-T1, supply
      two distinct pairwise-ancestry fixture files for `feature-child` instead of the single bare
      key P6-T2 uses: `merge-base.feature-child.feature-parent.rc` left ABSENT (defaults to rc 0,
      i.e. `feature-child` IS an ancestor of `feature-parent`'s tip, making `feature-parent`
      `feature-child`'s sole ancestor-target, so `feature-child` is a "deferred" branch) and
      `merge-base.feature-child.main.rc` set to `1` (i.e. `feature-child` is NOT an ancestor of
      `main`'s tip, so `main` is never additionally recorded as `feature-child`'s ancestor-target).
      This resolves the key collision that would otherwise force both pairwise probes onto the
      single bare `merge-base.feature-child.rc` key and defeat the AC3 negative-case requirement
      (an ancestor-target that resolves to something other than `NOT_MERGED` must not be
      short-circuited). Also supply `merge-base.main.rc` = `1` (the same defensive bare-fallback
      fixture as P6-T2, for the same reason: keeping `main` independent so `classify_branch`
      resolves it to `PROTECTED_CURRENT` rather than a spurious `CHILD_OF`-driven short-circuit).
      Acceptance: directory and files exist, including both named `merge-base.feature-child.*`
      files and `merge-base.main.rc`.
- [ ] [P6-T4] Append two `@test` blocks to `tests/shell/test_cleanup_worktrees_classification.bats`,
      each invoking the `classify_all()` helper added in P1-T7:
      `"child_of_not_merged: CHILD_OF short-circuit skips feature-child's expensive rungs"` (calls
      `classify_all child_of_not_merged`; asserts `$output` contains
      `BRANCH|feature-child|NOT_MERGED`, contains `BRANCH|feature-parent|NOT_MERGED`, contains
      `CHILD_OF|feature-child|feature-parent`, and — via the `stub-git:` stderr argv log that
      `classify_all()` deliberately does not suppress — does NOT contain `cherry main
      feature-child`, any `diff-tree` invocation naming a `feature-child` sha, or `rev-list
      --reverse --no-merges` naming `feature-child`) and
      `"child_of_merged_equivalent: no short-circuit when the ancestor is not NOT_MERGED"` (calls
      `classify_all child_of_merged_equivalent`; asserts `$output` contains
      `BRANCH|feature-parent|MERGED_EQUIVALENT`, contains a `feature-child` `BRANCH|` line resolved
      via its own full ladder, and does NOT contain any `CHILD_OF|` line — the scenario's
      `merge-base.main.rc` fixture from P6-T3 keeps `main` independent so it cannot itself be
      short-circuited into a spurious `CHILD_OF|main|...` line). Acceptance: both pass.
- [ ] [P6-T5] Add scenario fixture directory
      `tests/fixtures/cleanup_worktrees/scenarios/child_of_ancestry_probe_error/` where the new
      pairwise `merge-base --is-ancestor <feature-child-tip> <upstream-tip>` probe exits with rc
      128 for every upstream (`merge-base.feature-child.rc` = `128`, the bare fallback key from
      P2-T1's target-aware scheme — no target-specific `merge-base.feature-child.<upstream>.rc`
      file is supplied, so the same rc 128 applies uniformly whether the probe's second argument is
      `feature-parent` or `main`). Also supply `for-each-ref.out` listing `feature-child`,
      `feature-parent`, and `main`, one `<branch> <sha>` pair per line (mirroring
      `tests/fixtures/cleanup_worktrees/scenarios/unmerged/for-each-ref.out`'s exact two-line
      `<branch> <sha>` shape, extended to a third line, and matching P6-T2's/P6-T3's three-branch
      listing); `rev-parse.abbrev-ref-HEAD.out` containing the single line `main` (mirroring
      `.../unmerged/rev-parse.abbrev-ref-HEAD.out` verbatim); `rev-parse.show-toplevel.out`
      containing the single line `/repo/main` (mirroring `.../unmerged/rev-parse.show-toplevel.out`
      verbatim); and `worktree-list.out` containing the four-line porcelain block — `worktree
      /repo/main`, `HEAD aaaa0000`, `branch refs/heads/main`, then a trailing blank line (mirroring
      `.../unmerged/worktree-list.out` verbatim). These four files are required because
      `classify_all_branches` (P6-T1) depends on `enumerate_branches`'s `for-each-ref refs/heads/`
      read (the bare-key fallback restricted to the `refs/heads/` pattern per P2-T1) to produce any
      branch list at all, and `classify_branch`'s `compute_protected`/`parse_worktree_list` calls
      consume `rev-parse.abbrev-ref-HEAD.out`, `rev-parse.show-toplevel.out`, and
      `worktree-list.out`; without them the bare `for-each-ref` key is absent (empty stdout, exit 0,
      per `respond()`'s no-file behavior), `enumerate_branches` returns zero branches,
      `classify_all_branches` iterates zero branches, and `$output` is empty, making the assertion
      below unsatisfiable. No `merge-base.feature-parent.rc` or `merge-base.main.rc` fixture is
      required for this scenario: only `feature-child`'s resolution is asserted, and
      `feature-parent`'s/`main`'s own default (unset bare-key fallback, rc 0) pairwise resolutions
      do not interfere with that assertion. Append one `@test` block
      `"child_of_ancestry_probe_error: a hard pairwise ancestry failure maps to ANCESTRY_ERROR"` to
      `tests/shell/test_cleanup_worktrees_classification.bats`, invoking `classify_all
      child_of_ancestry_probe_error` (the helper added in P1-T7), asserting `$output` contains
      `BRANCH|feature-child|ANCESTRY_ERROR` and `$status` is non-zero, never a silent "not an
      ancestor" resolution. Acceptance: passes; the scenario directory contains
      `merge-base.feature-child.rc`, `for-each-ref.out`, `rev-parse.abbrev-ref-HEAD.out`,
      `rev-parse.show-toplevel.out`, and `worktree-list.out`.

### Phase 7 — Wire Shared Driver into `run_report` and `run_apply` (Outcome Preservation)

- [x] [P7-T1] Add the `CLEANUP_WT_SCAN_BIN` filesystem-scan stub seam AND the
      `cleanup_worktrees_report_records_lib.sh` sibling-library source to every existing
      `run_report`/`run_apply` call site in the bats suite, ahead of P7-T2/P7-T3's wiring edit, so
      that (a) no existing or new test ever falls through to a real filesystem scan of
      `.claude/worktrees`, and (b) once P7-T2/P7-T3 make `run_report`/`run_apply` call
      `classify_all_branches` internally, that function is defined in every bats subshell that
      invokes them (bats subshells source libraries directly, bypassing the CLI wrapper's own
      sourcing entirely). Edit three files: (1)
      `tests/shell/test_cleanup_worktrees_classification.bats` — add
      `SCAN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/scan"` and
      `chmod +x "${SCAN}" 2>/dev/null || true` to `setup() { ... }` (locate by the `setup() { ... }`
      function body — do not rely on a fixed line range, since P1-T7's `RLIB=` insertion shifts
      every line after it; `RLIB` is already declared there by P1-T7), and add
      `CLEANUP_WT_SCAN_BIN="${SCAN}"` to the `env` prefix of the `report()` helper AND
      `source '${RLIB}'` after the existing `source '${LIB}'` in its `bash -c` string (locate
      `report()` by name; do not rely on a fixed line range, since P1-T7's `RLIB=` assignment and
      `classify_all()` helper insertion have already shifted this file's lines by the time this
      task runs), which is the sole `run_report` call site in this
      file; (2) `tests/shell/test_cleanup_worktrees_hard_failures.bats` — add the same `SCAN`/
      `chmod` lines, plus `RLIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_report_records_lib.sh"`
      (not yet declared in this file), to `setup()` (currently lines 12-20), and add
      `CLEANUP_WT_SCAN_BIN="${SCAN}"` to the `env` prefix of the `runin()` helper AND
      `source '${RLIB}'` after the existing `source '${LIB}'` in its `bash -c` string (currently
      lines 22-28, matching the current source order `ELIB`/`LIB`/`ALIB`), which is the sole call
      site backing the `run_report` invocation at line 87 and the `run_apply` invocations at lines
      96 and 104; (3) `tests/shell/test_cleanup_worktrees_deletion.bats` — add the same `SCAN`/
      `chmod` lines, plus the same `RLIB=` declaration (not yet declared in this file), to
      `setup()` (currently lines 10-19), and add `CLEANUP_WT_SCAN_BIN="${SCAN}"` to the `env`
      prefix of the `apply()` helper AND `source '${RLIB}'` after the existing `source '${LIB}'` in
      its `bash -c` string (currently lines 21-24), which is the sole `run_apply` call site in this
      file. None of the pre-existing ~24 scenario directories under
      `tests/fixtures/cleanup_worktrees/scenarios/`, nor the three new Phase 6 `child_of_*`
      scenario directories, define a `scan-dirs.out` or `scan-dirs.rc` file, so the Phase 1 scan
      stub (P1-T5) replays nothing and exits 0 under every one of them regardless of which
      scenario is active; this three-file, three-helper edit therefore covers every existing and
      new `run_report`/`run_apply` invocation without touching any scenario fixture directory.
      Acceptance:
      `grep -n 'CLEANUP_WT_SCAN_BIN' tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_hard_failures.bats tests/shell/test_cleanup_worktrees_deletion.bats`
      returns exactly one matching line per file (three lines total); AND
      `grep -n 'cleanup_worktrees_report_records_lib.sh' tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_hard_failures.bats tests/shell/test_cleanup_worktrees_deletion.bats`
      returns at least one matching line per file (the `RLIB=` declaration; `classification.bats`
      already carries one from P1-T7).
- [x] [P7-T2] Edit `run_report` in `scripts/bash/cleanup_worktrees_lib.sh` (function body
      verified at lines 445-479) to replace its inline per-branch loop (verified at lines
      470-477: `while read -r name _; do ... classify_branch "$name" ... done <<<"$ebout"`) with a
      single call to `classify_all_branches`, and to invoke `scan_stale_refs`, `scan_orphan_dirs`,
      and `scan_registration_loss` immediately after the existing `check_main_freshness` call
      (verified at line 464) and before the `WORKTREE|` emission loop (verified at lines 465-469),
      per design decision 4 above. Update the file's own Report line contract header comment
      (verified at lines 40-46) to list the four new record types. Acceptance:
      `bash -n scripts/bash/cleanup_worktrees_lib.sh` exits 0; `run_report`'s function body no
      longer contains its own `classify_branch` call (it is called only inside
      `classify_all_branches`).
- [x] [P7-T3] Edit `run_apply` in `scripts/bash/cleanup_worktrees_actions_lib.sh` (function body
      verified at lines 316-382) to call `classify_all_branches` once (replacing the per-branch
      `classify_branch` call inside its loop, verified at lines 358-380), and for each branch name
      to extract that branch's own report lines from the shared driver's combined output via a
      per-name-scoped filter (matching lines beginning `BRANCH|<name>|`, `CHILD_OF|<name>|`, or
      `COMMIT|<name>|`) before the existing `printf '%s\n'` echo and the existing
      `awk -F'|' '/^BRANCH\|/{print $3; exit}'` state extraction (verified at line 373),
      preserving that extraction's third-field semantics and the allowlist case at the verified
      lines 374-379 unchanged. Acceptance: `bash -n scripts/bash/cleanup_worktrees_actions_lib.sh`
      exits 0; `run_apply` calls `classify_branch` at most once per branch in total, only via the
      shared driver.
- [ ] [P7-T4] Append `@test "child_of_not_merged: report-mode BRANCH line is unchanged by the
      short-circuit"` to `tests/shell/test_cleanup_worktrees_classification.bats`: runs
      `report child_of_not_merged` and asserts `$output` contains exactly
      `BRANCH|feature-child|NOT_MERGED`; separately runs `cb unmerged feature-unmerged` (the
      pre-existing non-short-circuited fixture) and asserts its output is exactly
      `BRANCH|feature-unmerged|NOT_MERGED`; both assertions confirm the `BRANCH|<name>|NOT_MERGED`
      shape is byte-identical in form whether or not the short-circuit fired. Acceptance: passes.
      This satisfies AC5(a).
- [ ] [P7-T5] Append `@test "apply mode allowlist is unaffected by a CHILD_OF short-circuit"` to
      `tests/shell/test_cleanup_worktrees_deletion.bats`, using the existing `apply()` helper
      (`tests/shell/test_cleanup_worktrees_deletion.bats:21-24`) against
      `child_of_not_merged`: asserts `$output` contains `BRANCH|feature-child|NOT_MERGED` and
      contains no `ACTION|delete|feature-child|` substring of any kind (proving `NOT_MERGED` never
      reaches the delete-eligible allowlist, short-circuited or not). Acceptance: passes. This
      satisfies AC5(b).
- [x] [P7-T6] Verify no `run_report`/`run_apply` invocation in the bats suite bypasses the P7-T1
      seam. Run `grep -rn "run_report\|run_apply" tests/shell/` and confirm every matching line is
      one of: a comment or `@test` title line, a `runin <scenario> "run_report"` /
      `runin <scenario> "run_apply"` call-site line (which routes through the seamed `runin()`
      template added in P7-T1), or one of the two seamed helper template lines
      (`tests/shell/test_cleanup_worktrees_classification.bats`'s `report()` body and
      `tests/shell/test_cleanup_worktrees_deletion.bats`'s `apply()` body, both edited in P7-T1) —
      i.e., no line directly invokes `run_report`/`run_apply` inside a `bash -c` string other than
      the three helper templates fixed in P7-T1. Record the full grep output as evidence at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/other/scan-seam-call-site-verification.2026-09-06T23-03.md`
      with the four required fields; `Output Summary:` must state the total match count and
      confirm none is an unseamed direct call site. Acceptance: the evidence file exists and its
      `Output Summary:` states this confirmation.

### Phase 8 — CLI Wrapper Sourcing and Usage Text

- [x] [P8-T1] Edit `scripts/bash/cleanup-worktrees.sh`'s sourcing block (verified at lines 16-24)
      to add `source "$SCRIPT_DIR/cleanup_worktrees_report_records_lib.sh"` immediately after the
      existing `source "$SCRIPT_DIR/cleanup_worktrees_enumerate_lib.sh"` line (verified line 18)
      and before `source "$SCRIPT_DIR/cleanup_worktrees_lib.sh"` (verified line 21), since
      `classify_all_branches` depends on the enumerate lib and is called BY `run_report`/
      `run_apply` in the two files sourced after it. Acceptance:
      `bash -n scripts/bash/cleanup-worktrees.sh` exits 0; the new `source` line appears between
      the two existing ones in file order.
- [x] [P8-T2] Extend `usage()`'s report-line-contract summary — the
      `Report lines (pipe-delimited, LC_ALL=C ordered): ...` paragraph inside the `usage()` heredoc
      (locate by content — P8-T1's new `source` line, run immediately before this task, shifts
      every line after it) — with the four new record shapes (state the literal tokens
      `ORPHAN_DIR|`, `STALE_REF|`, `CHILD_OF|`, and `WARN|registration-lost|` in the added text) and
      add `CLEANUP_WT_SCAN_BIN` to the `Environment overrides:` heading's section (locate by
      content, for the same reason). Acceptance: running
      `bash scripts/bash/cleanup-worktrees.sh --help` produces output containing the literal
      substring `ORPHAN_DIR|` and the literal substring `CLEANUP_WT_SCAN_BIN`.

### Phase 9 — SKILL.md Report Line Contract and Byte-Identical Mirror

- [x] [P9-T1] Edit `.claude/skills/cleanup-merged-worktrees/SKILL.md`'s Report Line Contract
      section (verified heading at line 57, existing bullet list at lines 61-71) to append four
      new bullets, one each for `ORPHAN_DIR|`, `STALE_REF|`, `CHILD_OF|`, and
      `WARN|registration-lost|`, with the `ORPHAN_DIR|` bullet cross-referencing the Dirty
      Worktree Triage Procedure's step 7 (verified at lines 190-197) by name (e.g., "see the
      Dirty Worktree Triage Procedure's step 7 for the manual filesystem-removal disposition")
      rather than restating that step's guidance. Acceptance: the file contains the literal
      substrings `ORPHAN_DIR|`, `STALE_REF|`, `CHILD_OF|`, and `WARN|registration-lost|` (each
      quoted here verbatim as the literal this task creates), and the `ORPHAN_DIR|` bullet's text
      does not duplicate step 7's "flag them for plain filesystem removal" sentence.
- [x] [P9-T2] Apply the byte-identical mirror of the P9-T1 edit into
      `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`.
      Acceptance:
      `diff .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
      produces empty output and exits 0.
- [x] [P9-T3] Run
      `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q`
      (the exact node ID verified at
      `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:106-131`). Record
      evidence at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/qa-gates/skill-md-mirror-contract.2026-09-06T23-03.md`
      with the four required fields; `Output Summary:` must state `1 passed`. Acceptance:
      `EXIT_CODE: 0` and `1 passed` is recorded. This satisfies AC7 together with P9-T1/P9-T2.

### Phase 10 — File-Size Cap and Generic-Detection Verification

- [ ] [P10-T1] After Phases 1-9 are complete, run
      `wc -l scripts/bash/cleanup_worktrees_lib.sh scripts/bash/cleanup_worktrees_report_records_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh scripts/bash/cleanup-worktrees.sh scripts/bash/cleanup_worktrees_scan_helper.sh`
      and record the exact printed counts at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/other/file-size-cap-verification.2026-09-06T23-03.md`
      with the four required fields. Acceptance: every one of the five printed counts is <= 500.
      This satisfies AC8.
- [ ] [P10-T2] Record the AC11 generic-detection confirmation at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/other/ac11-generic-detection-confirmation.2026-09-06T23-03.md`,
      enumerating every new fixture scenario directory added in Phases 1 and 3-6
      (`orphan_dir_present`, `orphan_dir_absent`, `stale_ref_present`, `stale_ref_absent`,
      `registration_lost_present`, `registration_lost_absent`, `child_of_not_merged`,
      `child_of_merged_equivalent`, `child_of_ancestry_probe_error`) and, for each, the exact
      count of `ORPHAN_DIR`/`STALE_REF`/`WARN|registration-lost` canned records it supplies (each
      must be exactly one, not four or seventeen or two), plus a `SearchScope:`/`SearchPatterns:`/
      `SearchResult:` block confirming a `grep -rn "17 "` and a `grep -rn "four director"` over
      the new test and fixture files return no matches tying any assertion to the historical
      2026-09-06 run counts. Acceptance: file exists with all fields populated. This satisfies
      AC11.

### Phase 11 — Final QA Loop

- [ ] [P11-T1] Run `bash scripts/bash/shell-qc.sh format`. Record evidence at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/qa-gates/final-format.2026-09-06T23-03.md`
      with the four required fields, including the `git status --porcelain -- scripts/bash tests/shell`
      tree observation as in P0-T6. Acceptance: `EXIT_CODE: 0`. If this step rewrites any file,
      restart the loop from this task.
- [ ] [P11-T2] Run `bash scripts/bash/shell-qc.sh check`. Record evidence at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/qa-gates/final-check.2026-09-06T23-03.md`
      with the four required fields. Acceptance: `EXIT_CODE: 0`. If this step fails, restart the
      loop from P11-T1.
- [ ] [P11-T3] Run `bash scripts/bash/shell-qc.sh test`. Record evidence at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/qa-gates/final-test.2026-09-06T23-03.md`
      with the four required fields, including the total bats test count and confirmation that it
      is not lower than the Phase 2 regression-gate count (P2-T3). Acceptance: `EXIT_CODE: 0`. If
      this step fails, restart the loop from P11-T1.
- [ ] [P11-T4] Run `bash scripts/bash/shell-qc.sh test --coverage`. Record evidence at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/qa-gates/final-test-coverage.2026-09-06T23-03.md`
      with the four required fields; `Output Summary:` must include the literal printed line
      `Bash coverage (lines): NN.N%` with a numeric value >= 85.0, and must state the value
      alongside the Phase 0 baseline value (P0-T9) for a no-regression comparison. Acceptance:
      `EXIT_CODE: 0` and the recorded percentage is >= 85.0. This satisfies AC9, together with
      P11-T1-T3.
- [ ] [P11-T5] Confirm the full toolchain loop (P11-T1 through P11-T4) completed in a single pass
      with no restart triggered (i.e., no step in this phase rewrote a file or failed after the
      first attempt). Record this confirmation as the final line of
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/qa-gates/final-test-coverage.2026-09-06T23-03.md`
      (appended, not a new file). Acceptance: the confirmation line is present and no restart was
      required, or, if a restart occurred, the sequence was re-run to completion and the final
      evidence artifacts reflect the clean pass.

---

## Acceptance Criteria Traceability

| AC | Description (spec.md) | Implementing Tasks | Test Tasks | Evidence Tasks |
| --- | --- | --- | --- | --- |
| AC1 | `ORPHAN_DIR` positive/negative | P4-T1 | P4-T2, P4-T3, P4-T4 | P10-T2 |
| AC2 | `STALE_REF` positive/negative, general | P3-T1 | P3-T2, P3-T3, P3-T4 | P10-T2 |
| AC3 | `CHILD_OF` positive/negative + argv-log proof | P6-T1 | P1-T7, P6-T2, P6-T3, P6-T4 | P10-T2 |
| AC4 | `WARN\|registration-lost` positive/negative | P5-T1 | P5-T2, P5-T3, P5-T4 | P10-T2 |
| AC5 | Outcome-preservation invariant (a)+(b) | P7-T2, P7-T3 | P7-T4, P7-T5 | — |
| AC6 | `for-each-ref` stub edit backward compatible | P2-T1, P2-T2 | P2-T3 (full suite) | P2-T3 |
| AC7 | SKILL.md contract + byte-identical mirror | P9-T1, P9-T2 | P9-T3 | P9-T3 |
| AC8 | `cleanup_worktrees_lib.sh` <= 500 lines | P7-T2 | — | P10-T1 |
| AC9 | Full toolchain loop, coverage >= 85% | P11-T1..T4 | P11-T1..T4 | P11-T1..T4 |
| AC10 | No automatic deletion introduced | (no deletion code added anywhere in Phases 1-9) | P7-T5 (proves no ACTION|delete for a scan-only or short-circuited finding) | P10-T2 |
| AC11 | No fixed historical numeric counts asserted | P3-P6 fixture design (single-instance records) | — | P10-T2 |

## Out-of-Scope Confirmation (non-goals honored by this plan)

No task in this plan modifies detached-worktree classification, the dirt classifier, the
sanctioned removal manifest, `PRESERVE` file consolidation, `enforce-epic-worktree-removal-gate.ps1`,
`enforce-epic-merge-gate.ps1`, the `collect_pr_context` TypeScript overview, or the
preimplementation-gate command-word matcher. No task introduces automatic deletion of an
`ORPHAN_DIR` or `STALE_REF` finding.

---

## Mandatory Adversarial Self-Review — Round 1 (Initial Authoring)

The following citations were re-derived directly against the repository tree during the initial
authoring pass. This round's record is retained here for traceability; it is superseded, for the
regions each later revision touched, by the Round 2 record, in turn by the Round 3 record, and in
turn by the Round 4 record below. The single governing `SELF-REVIEW:` signal for this plan is the
Round 4 signal below, per the contract's one-signal requirement.

Citations re-derived directly against the repository tree in the initial authoring pass:

- `scripts/bash/cleanup_worktrees_lib.sh` — total line count 479 (confirmed via full file read);
  `classify_branch` at lines 308-443; `run_report` at lines 445-479; `run_report`'s per-branch
  loop at lines 470-477; Report line contract header comment at lines 40-46; ANCESTRY_ERROR
  convention comment at lines 36-38.
- `scripts/bash/cleanup_worktrees_enumerate_lib.sh` — total line count 236 (corrected in Round 5;
  confirmed via `wc -l` and `grep -c '^'` by the round-4 preflight reviewer; Round 1's "237" was an
  off-by-one miscount); confirmed via targeted re-read of the file's tail, lines 225-236;
  `cleanup_wt_git` at lines 34-57;
  `enumerate_branches` at lines 59-83; `parse_worktree_list` at lines 85-148 (hard-failure
  contract at lines 120-128); `normalize_wt_path` at lines 150-164; `compute_protected` at lines
  166-219; `check_main_freshness` at lines 221-236, `WARN|main-divergence` printf at line 233.
- `scripts/bash/cleanup_worktrees_actions_lib.sh` — total line count 382 (corrected in Round 3;
  confirmed via `grep -c '^'`); `consolidation_worktree_path` at lines 39-68; `run_apply` at lines
  316-382; `run_apply`'s per-branch loop at lines 358-380; the `awk -F'|'` state extraction at
  line 373; the allowlist `case` at lines 374-379.
- `scripts/bash/cleanup-worktrees.sh` — total line count 92 (corrected in Round 3; confirmed via
  `grep -c '^'`); sourcing block at lines 16-24 (enumerate lib sourced at line 18, classification
  lib at line 21, actions lib at line 24); `usage()` report-line-contract text at lines 42-45;
  Environment overrides section at lines 47-55.
- `.claude/skills/cleanup-merged-worktrees/SKILL.md` — total line count 264 (confirmed via full
  file read); Report Line Contract heading at line 57, bullet list at lines 61-71; Dirty Worktree
  Triage Procedure step 7 at lines 190-197.
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
  — confirmed byte-identical to the repo copy above (full file read, identical content through
  line 264/265).
- `tests/fixtures/cleanup_worktrees/stub-bin/git` — `for-each-ref)` case at lines 97-99; header
  KEY-scheme documentation at lines 20-41; default fallthrough arm (no `remote` handling) at
  lines 205-207 (confirmed via full file read).
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` —
  `test_bundled_claude_payload_contains_all_repo_runtime_contracts` at lines 106-131, its
  byte-identity assertion at lines 128-131 (confirmed via targeted read of lines 95-139).
- `tests/shell/test_cleanup_worktrees_classification.bats` — total line count 129 (confirmed via
  line-count check); existing `cb()`/`report()` helpers at lines 17-27; existing `unmerged`,
  `residual_on_main`, `ancestry_error` test cases confirmed present and usable as fixture-shape
  templates for Phase 6's new scenarios.
- `tests/shell/test_cleanup_worktrees_deletion.bats` — total line count 83 (confirmed via
  line-count check); `apply()` helper at lines 21-24 (confirmed via full file read of lines
  1-40).
- `tests/shell/test_cleanup_worktrees_enumeration.bats` — total line count 113 (confirmed via
  full file read); `setup()` block at lines 9-19.
- `tests/fixtures/cleanup_worktrees/scenarios/unmerged/` — confirmed existing fixture file set
  (11 files) usable as the `feature-parent`/`feature-child` NOT_MERGED fixture-shape template for
  Phase 6.
- `scripts/bash/shell_qc_lib.sh` — `run_format` at lines 204-224 (confirmed no stdout on a clean
  run); `run_check` at lines 164-202; coverage percentage printf `'Bash coverage (lines): %s%%\n'`
  at line 291 (confirmed via targeted grep and read).
- `scripts/bash/shell-qc.sh` — total line count 103 (corrected in Round 3; confirmed via
  `grep -c '^'`); subcommand dispatch (`check`/`format`/`test`/`test --coverage`/`--help`) at
  lines 47-92.
- `.claude/rules/shell.md` — toolchain order, 500-line cap, `SHELL_QC_<TOOL>_BIN` seam, and
  no-temp-file test policy confirmed via full file read (93 lines).
- `.claude/rules/plan-acceptance-gates.md` — G1-G9 rule table and authoring guidance confirmed
  via full file read; informed the removal of placeholder-bearing literals (`<path>`, `<size>`)
  from grep-style acceptance assertions in P8-T2 and P9-T1 in favor of fixed-string tokens
  (`ORPHAN_DIR|`, `CLEANUP_WT_SCAN_BIN`, etc.).

Sibling-region check performed alongside each edited citation: `run_report`'s WORKTREE-loop
lines (465-469, immediately following the edited `check_main_freshness` call site) were
re-checked and confirmed unaffected by the new scan-function call sites inserted before them;
`run_apply`'s consolidation-branch special case (lines 349-356, immediately preceding its edited
per-branch loop) was re-checked and confirmed to remain per-branch and untouched by routing
classification through the shared driver; the git stub's `fetch)` case (lines 202-204,
immediately preceding the new `remote)` case) was re-checked and confirmed unaffected by the
insertion.

## Mandatory Adversarial Self-Review — Round 2 (Revision Pass, Defects 1-5)

This round follows `PREFLIGHT: REVISIONS REQUIRED` from `atomic-executor` reporting five defects.
Every citation the revision's edits touched, added, or removed was re-derived directly against
the current repository tree in this pass; none is carried forward from Round 1. This round's
record (it completed its own re-derivation pass at the time) is retained here for traceability;
it is superseded, for the regions Round 3 touched, by the Round 3 record, and in turn by the
Round 4 record, below. The single governing `SELF-REVIEW:` signal for this plan is the Round 4
signal below, per the contract's one-signal requirement.

Citations re-derived directly against the current repository tree in this pass:

- `tests/fixtures/cleanup_worktrees/stub-bin/git` — re-read in full (208 lines; corrected in
  Round 3 via `grep -c '^'` — Round 2's "209 lines" was an off-by-one miscount). Confirmed the
  `merge-base)` case body at lines 108-114: `respond "merge-base.$(sanitize "${3:-}")"`, where
  `$3` is the first positional argument after the `--is-ancestor` flag (i.e., the `<tip>`
  argument), not the second (`<upstream>`) argument. This directly contradicts P6-T5's prior text,
  which keyed the fixture on the second argument (`<feature-parent-sha>`); corrected P6-T5 to key
  on `merge-base.feature-child` (the first argument, `<feature-child-tip>`, using the branch-name
  form already used by the sibling fixtures P6-T2/P6-T3). Sibling-region check: the header
  KEY-scheme comment's `merge-base` line (line 25, unchanged by this fix) already documents the
  correct first-arg form (`merge-base.<tip>`), so only the P6-T5 task prose — not the fixture file
  itself — was wrong; no other case arm in the stub keys on a second argument, confirmed by
  re-reading the full `case` statement (lines 96-208).
- `tests/fixtures/cleanup_worktrees/stub-bin/git` — re-checked the `for-each-ref)` case (lines
  97-99) and `respond()`'s no-match behavior (lines 55-69: absent `.out`/`.rc` files yield empty
  stdout and exit 0) to confirm P2-T1's corrected fallback text is implementable without a
  behavior change to `respond()` itself: the case body, not `respond()`, must gate the bare-key
  fallback to the literal pattern `refs/heads/`.
- `scripts/bash/cleanup_worktrees_enumerate_lib.sh` — re-read lines 60-83 (`enumerate_branches`).
  Confirmed line 75 is the sole historical `for-each-ref` call site and its pattern argument is
  the literal string `refs/heads/` (`--format='%(refname:short) %(objectname)' refs/heads/`),
  which is the only call shape the P2-T1 bare-key fallback may legitimately cover.
- `.claude/rules/shell.md` — re-read in full; confirmed the file is 93 lines (not 91 as
  Round 1 recorded), correcting the Round 1 citation error (Defect 4).
- `tests/shell/test_cleanup_worktrees_classification.bats` — re-read in full (129 lines).
  Confirmed `setup()` at lines 8-15, `cb()` at lines 17-22, `report()` at lines 24-27 (the sole
  `run_report` call site in this file, via the `bash -c` string at line 26). Sibling-region check:
  `cb()` (lines 17-22) invokes `classify_branch` only, never `run_report`/`run_apply`, and
  `classify_branch` never calls the new scan functions, so `cb()` is correctly left outside
  P7-T1's seam edit; no other helper or inline `run env` invocation of `run_report` exists in this
  file (confirmed via full-file re-read).
- `tests/shell/test_cleanup_worktrees_hard_failures.bats` — re-read in full (172 lines; corrected
  in Round 3 via `grep -c '^'` — Round 2's "173 lines" was an off-by-one miscount). Confirmed
  `setup()` at lines 12-20, `runin()` at lines 22-28 (the single shared template backing all 17
  `@test` invocations in this file, including the `run_report` call at line 87 and the two
  `run_apply` calls at lines 96 and 104). Sibling-region check: the other 14 `runin()` call sites
  in this file (`classify_branch`, `compute_protected`, `enumerate_branches`,
  `consolidation_worktree_path`, `create_consolidation_worktree`,
  `cleanup_consolidation_on_abort`, `reverify_delete_eligible`, `remove_worktree_safe`) never read
  `CLEANUP_WT_SCAN_BIN`, so adding it to `runin()`'s shared `env` prefix is inert for those
  invocations and changes behavior only for the two functions that route through the new scan
  seam once Phase 7 wires it in.
- `tests/shell/test_cleanup_worktrees_deletion.bats` — re-read lines 1-40. Confirmed `setup()` at
  lines 10-19, `apply()` at lines 21-24 (the sole `run_apply` call site in this file, via the
  `bash -c` string at line 23). Sibling-region check: the standalone `run env CLEANUP_WT_GIT_BIN=…`
  invocation at line 37 (for `delete_candidate`, a different function) does not call
  `run_report`/`run_apply` and does not require the scan seam; confirmed by reading its full
  invocation string, which names only `delete_candidate`.
- `tests/shell/*.bats` (repository-wide) — ran a repository-relative grep for the literal strings
  `run_report` and `run_apply` across `tests/shell/` (see the file list above) and confirmed every
  match falls into one of: a comment/`@test`-title line, a `runin <scenario> "run_report"` /
  `runin <scenario> "run_apply"` call-site line, or one of the two `bash -c` template lines inside
  `report()` (classification.bats:26) and `apply()` (deletion.bats:23) — the two direct
  invocation sites, both now covered by P7-T1's edit via their enclosing helper's `env` prefix. No
  fourth, unseamed direct call site exists.
- This plan file, P1-T3 (fixture-directory task) — re-read the task's own prose and counted the
  named subdirectories: `no_git/`, `good_wt/`, `good_wt_target/`, `broken_wt/` — four, not three
  as the prior wording stated (Defect 5); corrected the count word only, no fixture-shape change.

Sibling-region check summary for this round: each of the three edited bats files' OTHER helpers
and call sites (enumerated above) were individually re-checked and confirmed either unaffected by
the `CLEANUP_WT_SCAN_BIN` seam addition (because they never invoke `run_report`/`run_apply`) or
correctly covered by it (because they do); no sibling test assertion in any of the three files
relies on the pre-seam environment shape in a way this addition would break, since the seam only
adds a new environment variable rather than removing or renaming an existing one.

## Mandatory Adversarial Self-Review — Round 3 (Revision Pass, Defects A-B, Citations 1-3)

This round follows `PREFLIGHT: REVISIONS REQUIRED` from `atomic-executor` reporting two new
blocking defects (A: the sibling library was never sourced into the bats harness; B: the
`merge-base` stub key collision defeats the P6-T3 negative-case fixture) plus three minor citation
errors. Every citation this round's edits touched, added, or removed was re-derived directly
against the current repository tree in this pass; none is carried forward from Round 1 or Round 2.
This round's record (it completed its own re-derivation pass at the time) is retained here for
traceability; it is superseded, for the region Round 4 touched (P6-T5 and its immediate siblings),
by the Round 4 record below. The single governing `SELF-REVIEW:` signal for this plan is the
Round 4 signal below, per the contract's one-signal requirement.

Citations re-derived directly against the current repository tree in this pass:

- `scripts/bash/cleanup-worktrees.sh` — re-read in full; confirmed 92 lines via `grep -c '^'`
  (Round 1's "93" was inaccurate; corrected in place in the Round 1 section above).
- `scripts/bash/cleanup_worktrees_actions_lib.sh` — re-confirmed 382 lines via `grep -c '^'`
  (Round 1's "383" was inaccurate; corrected in place). Re-checked the cited ranges themselves
  (`run_apply` 316-382, the consolidation-branch special case 349-356, the `awk -F'|'` extraction
  at line 373, the allowlist `case` 374-379, `consolidation_worktree_path` 39-68) against a fresh
  read of lines 35-68 and 310-382: all five ranges are unaffected by the line-count correction,
  which touches only the summary total, not any cited sub-range.
- `scripts/bash/shell-qc.sh` — re-confirmed 103 lines via `grep -c '^'` (Round 1's "104" was
  inaccurate; corrected in place).
- `tests/fixtures/cleanup_worktrees/stub-bin/git` — re-read in full; confirmed 208 lines via
  `grep -c '^'` (Round 2's "209" was an off-by-one miscount; corrected in place in the Round 2
  section above). Re-confirmed, against the CURRENT (pre-executor-edit) tree, that the
  `merge-base)` case body (lines 108-114) keys only on the first positional argument
  (`$3`, the `<tip>`), that `respond()`/`sanitize()` (lines 49-69) contain no target-argument
  awareness, and that the header KEY-scheme comment's `merge-base` line (line 25) documents only
  the bare `merge-base.<tip>` form — grounding P2-T1's extended task text, which now instructs the
  executor to add the target-aware-with-bare-fallback logic and the corresponding header-comment
  update. P6-T5's citation of this file was changed from a line number to a content-anchored
  description (the bare-fallback rule stated in P2-T1) to remove a citation that would otherwise
  drift once P2-T1's edit changes the file's line count.
- `tests/fixtures/cleanup_worktrees/scenarios/**/merge-base*` — enumerated via glob; confirmed
  exactly 16 existing fixture files (`ancestry_error`, `cherry_error`, `content_neutral`,
  `deleted_path_absent`, `deleted_path_on_main`, `diff_tree_error`, `dirty_worktree`,
  `ls_tree_error`, `merged_no_worktree`, `merged_with_worktree`, `residual_on_main`,
  `residual_unique_doc`, `rev_list_error`, `rev_parse_error_protection`, `unmerged`,
  `worktree_list_error`), every one a single bare `merge-base.<branch>.rc` file with no second
  `.`-delimited segment before `.rc` — confirming P2-T1's target-aware-with-bare-fallback edit is
  backward compatible with all 16.
- `tests/fixtures/cleanup_worktrees/scenarios/residual_on_main/merge-base.feature-equiv.rc` —
  content re-read: value `1`, confirming P6-T3's reused-fixture assumption that mirroring this
  scenario for `feature-parent` keeps `feature-parent` independent (zero ancestor-targets).
- `tests/fixtures/cleanup_worktrees/scenarios/unmerged/merge-base.feature-unmerged.rc` — content
  re-read: value `1`. This confirms the defect's own claim: mirroring `unmerged`'s shape for
  `feature-child` under the OLD (pre-fix) P6-T3 wording would have set the single bare
  `merge-base.feature-child.rc` to `1` for BOTH pairwise probes, making `feature-child`
  independent (not deferred) and silently defeating the AC3 negative-case test — the exact defect
  reported.
- `tests/fixtures/cleanup_worktrees/scenarios/unmerged/for-each-ref.out` and
  `.../rev-parse.abbrev-ref-HEAD.out` — content re-read: confirmed the `<branch> <sha>`
  for-each-ref line format (`feature-unmerged cccc3333` / `main aaaa0000`) and the `main`
  current-branch convention used by every mirrored scenario, grounding the corrected P6-T2/P6-T3
  `for-each-ref.out` instructions (`feature-child`, `feature-parent`, `main`, one line each).
- `scripts/bash/cleanup_worktrees_enumerate_lib.sh` — re-read `compute_protected` (lines 166-219).
  Confirmed `main` is always classified `PROTECTED_CURRENT` by `classify_branch` via
  `protected-branch|<current_branch>` (emitted at line 197) whenever `rev-parse --abbrev-ref HEAD`
  resolves to `main` (the convention every mirrored scenario's `rev-parse.abbrev-ref-HEAD.out`
  uses). Sibling-region finding: `classify_all_branches` (P6-T1) enumerates `main` as an ordinary
  branch alongside `feature-child`/`feature-parent`, and with no `merge-base.main.*` fixture the
  stub's default rc-0 behavior would falsely record `main` as an ancestor-target of both feature
  branches; if either resolves `NOT_MERGED` before `main` is processed (true for
  `child_of_merged_equivalent`, since `feature-child` resolves `NOT_MERGED` via its own full ladder
  and is processed before `main` in `LC_ALL=C` order), `main` would be short-circuited into a
  spurious `CHILD_OF|main|feature-child` line, breaking P6-T4's "does NOT contain any `CHILD_OF|`
  line" assertion — a sibling defect discovered while re-deriving this region, fixed by adding
  `merge-base.main.rc` = `1` to both `child_of_not_merged` (P6-T2) and `child_of_merged_equivalent`
  (P6-T3), which keeps `main` independent regardless of these ordering/short-circuit details.
- `tests/shell/test_cleanup_worktrees_classification.bats` — re-read lines 1-30 in full;
  re-confirmed `setup()` 8-15, `cb()` 17-22, `report()` 24-27 unchanged from Round 2. Used as the
  exact anchor for the new P1-T7 `classify_all()` helper (inserted after `cb()`) and for P7-T1's
  `source '${RLIB}'` addition to `report()`.
- `tests/shell/test_cleanup_worktrees_hard_failures.bats` — re-read lines 1-35 and lines 160-172;
  corrected the total line count to 172 via `grep -c '^'` (Round 2's "173" was an off-by-one
  miscount; corrected in place in the Round 2 section above). Re-confirmed `setup()` 12-20,
  `runin()` 22-28, `run_report` at line 87, `run_apply` at lines 96 and 104, and the 17-block
  `@test` count (re-verified via `grep -c '@test'`).
- `tests/shell/test_cleanup_worktrees_deletion.bats` — re-read lines 1-40; re-confirmed `setup()`
  10-19, `apply()` 21-24, and the total line count of 83 (re-verified via `grep -c '^'`, unchanged
  from Round 1).
- `tests/shell/*.bats` (repository-wide) — re-ran a repository-relative grep for `run_report` and
  `run_apply`; confirmed the same two direct invocation sites (`classification.bats:26`,
  `deletion.bats:23`) and no unseamed fourth site, consistent with Round 2's finding.

Sibling-region checks performed this round (required by the process instructions):

- **Does adding `RLIB` sourcing to `report()`/`runin()`/`apply()` disturb any sibling task or
  assumption?** Checked: the other 14 `runin()` call sites in `hard_failures.bats` (enumerated in
  Round 2: `classify_branch`, `compute_protected`, `enumerate_branches`,
  `consolidation_worktree_path`, `create_consolidation_worktree`,
  `cleanup_consolidation_on_abort`, `reverify_delete_eligible`, `remove_worktree_safe`) invoke
  functions that do not call `classify_all_branches`, so sourcing `RLIB` alongside them is inert.
  `cb()` in `classification.bats` (lines 17-22) is untouched by P7-T1 and does not source `RLIB`;
  Phase 6's new `classify_all()` helper (P1-T7) is the sole direct-`classify_all_branches`
  invocation path, so `cb()`'s narrower scope (`classify_branch` only) is correctly unaffected.
  `deletion.bats`'s standalone `delete_candidate` invocation (line 37) sources `ELIB`/`LIB`/`ALIB`
  only and is not a `run_report`/`run_apply` call site, so it correctly remains outside P7-T1's
  `RLIB` edit.
- **Does the new target-aware `merge-base` key scheme disturb any OTHER existing task's citations
  or assumptions?** Checked: P6-T5's `child_of_ancestry_probe_error` fixture supplies no
  target-specific file, so its bare-fallback behavior is byte-identical to the pre-fix stub for
  that scenario; P7-T2/P7-T3/P7-T4/P7-T5 operate only on already-classified `BRANCH|`/`CHILD_OF|`
  output and never reference a `merge-base` fixture key, so they are unaffected; all 16
  pre-existing non-`child_of_*` scenarios (enumerated above) are unaffected since none supplies a
  second `.`-delimited segment, so the bare-key fallback path is the only path they exercise,
  identical to their pre-edit behavior.

## Mandatory Adversarial Self-Review — Round 4 (Revision Pass, Defect C)

This round follows `PREFLIGHT: REVISIONS REQUIRED` from `atomic-executor` reporting one new
blocking defect (C: P6-T5's scenario never populated `for-each-ref.out`, so `enumerate_branches`
returns zero branches and the task's own `$output` assertion is unsatisfiable). Every citation this
round's edit touched was re-derived directly against the current repository tree in this pass; none
is carried forward from Round 1, Round 2, or Round 3. This round's record (it completed its own
re-derivation pass at the time) is retained here for traceability; it is superseded, for the three
regions Round 5 touched (P7-T1, P8-T2, and the Round 1 self-review citation list's
`cleanup_worktrees_enumerate_lib.sh` line-count entry), by the Round 5 record below. The single
governing `SELF-REVIEW:` signal for this plan is the Round 5 signal below, per the contract's
one-signal requirement.

Citations re-derived directly against the current repository tree in this pass:

- `tests/fixtures/cleanup_worktrees/scenarios/unmerged/for-each-ref.out` — content re-read: two
  lines, `feature-unmerged cccc3333` and `main aaaa0000`, each a `<branch> <sha>` pair. Grounds
  P6-T5's corrected `for-each-ref.out` instruction (extend the same shape to a third line:
  `feature-child`, `feature-parent`, `main`).
- `tests/fixtures/cleanup_worktrees/scenarios/unmerged/rev-parse.abbrev-ref-HEAD.out` — content
  re-read: single line `main`. Grounds P6-T5's corrected instruction verbatim.
- `tests/fixtures/cleanup_worktrees/scenarios/unmerged/rev-parse.show-toplevel.out` — content
  re-read: single line `/repo/main`. Grounds P6-T5's corrected instruction verbatim.
- `tests/fixtures/cleanup_worktrees/scenarios/unmerged/worktree-list.out` — content re-read: four
  lines, `worktree /repo/main`, `HEAD aaaa0000`, `branch refs/heads/main`, then a trailing blank
  line. Grounds P6-T5's corrected instruction verbatim.
- `tests/fixtures/cleanup_worktrees/scenarios/residual_on_main/*` — enumerated via glob and
  confirmed it also carries its own `rev-parse.abbrev-ref-HEAD.out`, `rev-parse.show-toplevel.out`,
  and `worktree-list.out` files, identical in role to `unmerged/`'s; used below to confirm P6-T3
  already has these three files covered through its own mirrored fixture shape.
- `scripts/bash/cleanup_worktrees_enumerate_lib.sh` — re-read `enumerate_branches` (lines 59-83);
  confirmed the `--format='%(refname:short) %(objectname)' refs/heads/` call at line 75 is the sole
  read that populates the branch list `classify_all_branches` (P6-T1) iterates, so an absent
  `for-each-ref.out` (empty stdout, exit 0, per `respond()`'s no-file behavior, lines 55-69 of the
  stub) collapses `classify_all_branches`'s output to nothing.
- This plan file, P6-T5's own pre-Round-4 text — re-read in full and confirmed it named only
  `merge-base.feature-child.rc`, supplying no `for-each-ref.out`, `rev-parse.abbrev-ref-HEAD.out`,
  `rev-parse.show-toplevel.out`, or `worktree-list.out` — the exact gap Defect C reports.

Sibling-region check performed this round (required by the process instructions):

- **P6-T2** — re-read in full against the current plan text. It already instructs `for-each-ref.out
  listing both branch/sha pairs plus main` explicitly, and separately instructs "the remaining
  fixtures needed for feature-parent to resolve NOT_MERGED via the full ladder (mirroring
  `.../unmerged/`'s file set, renamed to feature-parent)" — a clause that, per the file-set glob
  re-derived above, already carries `unmerged/`'s `rev-parse.abbrev-ref-HEAD.out`,
  `rev-parse.show-toplevel.out`, and `worktree-list.out` (none of which embed a branch name, so
  none require renaming). P6-T2 therefore already has a complete four-file
  enumeration/protection fixture set and is unaffected by, and does not duplicate, this round's fix.
- **P6-T3** — re-read in full. It instructs `for-each-ref.out listing feature-child, feature-parent,
  and main, mirroring P6-T2's shape` explicitly, and separately mirrors `residual_on_main/`'s
  fixture shape for `feature-parent` and `unmerged/`'s shape for `feature-child`'s full ladder;
  both source scenarios were re-confirmed above to carry the same three shared
  rev-parse/worktree-list files. P6-T3 therefore already has a complete fixture set and is likewise
  unaffected by this round's fix.
- **P6-T4** — re-read in full. Its two `@test` blocks invoke `classify_all()` only against
  `child_of_not_merged` and `child_of_merged_equivalent` (P6-T2's and P6-T3's scenarios, both
  already complete); it never invokes `child_of_ancestry_probe_error` and is unaffected by this
  round's edit.
- **Interaction with the Round-3 `merge-base.main.rc = 1` defensive fixture (P6-T2/P6-T3)** —
  checked explicitly and found no interaction. That defensive fixture exists because P6-T2 and
  P6-T3 each drive `feature-parent` to a resolved `NOT_MERGED`/`MERGED_EQUIVALENT` state via the
  full ladder, and P6-T4 then asserts the ABSENCE of a spurious `CHILD_OF|main|...` line — an
  assertion a falsely-deferred `main` could break. P6-T5's `@test` asserts only that `$output`
  CONTAINS `BRANCH|feature-child|ANCESTRY_ERROR` and that `$status` is non-zero; it asserts no
  absence of any `main`- or `feature-parent`-related line, and P6-T5's fixture is read by no other
  task in this plan. Whatever state `main` or `feature-parent` reach under
  `child_of_ancestry_probe_error` — including a falsely-deferred `main`, since no
  `merge-base.main.rc` fixture is added here — therefore cannot falsify P6-T5's assertion, and this
  round's fix deliberately adds no `merge-base.main.rc`/`merge-base.feature-parent.rc` fixture to
  this scenario, matching the required-fix text's own reasoning and re-confirmed here directly
  against the current plan text rather than assumed from the Round 3 preflight conclusion.

## Mandatory Adversarial Self-Review — Round 5 (Revision Pass, Defects D1-D3, Citation-Drift Only)

This round follows `PREFLIGHT: REVISIONS REQUIRED` from `atomic-executor` reporting three
non-blocking citation-drift defects (D1: P7-T1 cited stale pre-P1-T7 line numbers for `setup()`
and `report()` in `test_cleanup_worktrees_classification.bats`; D2: P8-T2 cited stale
pre-P8-T1 line numbers for the report-line-contract paragraph and the "Environment overrides"
section in `cleanup-worktrees.sh`; D3: the Round 1 self-review citation list stated a stale total
line count, "237", for `scripts/bash/cleanup_worktrees_enumerate_lib.sh`, corrected in this round
to "236" per the round-4 preflight reviewer's independent `wc -l`/`grep -c '^'` measurement). All
logic and functional defects from Rounds 1-4 remain fixed and are unaffected by this round; no
task ID, acceptance condition, or fixture shape changes in this pass. Every citation this round's
edit touched was re-derived directly against the current repository tree in this pass; none is
carried forward from Round 1, Round 2, Round 3, or Round 4.

`SELF-REVIEW: RE-DERIVED THIS PASS`

Citations re-derived directly against the current repository tree in this pass:

- `tests/shell/test_cleanup_worktrees_classification.bats` — re-read in full (129 lines, unchanged
  from Round 3). Confirmed `setup() { ... }` is findable by name at lines 8-15 and `report() { ... }`
  is findable by name at lines 24-27, in the file's CURRENT (pre-P1-T7, pre-P7-T1) state. This
  grounds P7-T1's corrected instruction to locate both by content/name rather than by the fixed
  line numbers "8-15" and "24-27" the prior wording cited, since those numbers describe only this
  pre-execution snapshot and P1-T7's `RLIB=` insertion into `setup()` plus its `classify_all()`
  helper insertion immediately after `cb()` will have shifted every line below each insertion point
  by the time P7-T1 (Phase 7, after Phase 1) actually runs.
- `scripts/bash/cleanup-worktrees.sh` — re-read in full (92 lines, unchanged from Round 3).
  Confirmed the literal paragraph beginning `Report lines (pipe-delimited, LC_ALL=C ordered):` is
  present verbatim inside the `usage()` heredoc at lines 42-45, and the literal heading
  `Environment overrides:` is present verbatim at line 47, in the file's CURRENT (pre-P8-T1) state.
  This grounds P8-T2's corrected instruction to locate both by their verbatim content rather than
  by the fixed line numbers "42-45" and "47-55" the prior wording cited, since P8-T1's new `source`
  line insertion (immediately before P8-T2 runs, into the sourcing block at lines 16-24) shifts
  every line below it, including both of these regions, by the time P8-T2 actually runs.
- `scripts/bash/cleanup_worktrees_enumerate_lib.sh` — re-read in full via the Read tool's `cat -n`
  numbered output, which enumerates content through line 237 (the file's closing `}`). This session
  carries no Bash tool access, so `wc -l`/`grep -c '^'` could not be re-run independently in this
  pass; the correction to "236" is therefore applied on the basis of the round-4 preflight
  reviewer's independently confirmed `wc -l` and `grep -c '^'` measurement (both tools count
  terminated lines, so a file whose last line lacks a trailing newline yields a `wc -l`/`grep -c '^'`
  count one lower than its highest `cat -n` line number — consistent with a 237th `cat -n`-numbered
  line and a 236-line `wc -l`/`grep -c '^'` count coexisting in the same file). No task in this plan
  asserts a numeric line count as an executable acceptance condition for this file (the plan's
  acceptance conditions for this file are limited to `bash -n` syntax checks and named-function
  greps), so this correction affects only self-review prose, not any gate.

Sibling-region check performed this round (required by the process instructions):

- **P7-T1's other two file edits (`test_cleanup_worktrees_hard_failures.bats`,
  `test_cleanup_worktrees_deletion.bats`)** — re-checked against the defect's own scope. Neither
  file receives an `RLIB=`/helper insertion from any task in Phase 1 (P1-T7 touches only
  `test_cleanup_worktrees_classification.bats`), so no earlier task shifts either file's lines
  before P7-T1 runs against them. Their existing fixed-line citations (`setup()` at lines 12-20 and
  `runin()` at lines 22-28 for `hard_failures.bats`; `setup()` at lines 10-19 and `apply()` at lines
  21-24 for `deletion.bats`) remain accurate as of the state in which P7-T1 will execute and are
  left unchanged; D1 was scoped by the round-4 preflight reviewer to `classification.bats` only, and
  this round confirms that scope is correct rather than under-inclusive.
- **P8-T1's own citation (`cleanup-worktrees.sh` sourcing block, verified at lines 16-24)** —
  re-checked: P8-T1 is the first task to touch this file in Phase 8, so no earlier task in this plan
  shifts its lines before P8-T1 runs; that citation is unaffected by D2 and is left unchanged. Only
  P8-T2, which runs immediately after P8-T1's own edit, needed the content-anchored correction.
- **The bounded `PLANNER-INTERNAL-REVIEW` citation list's own
  `scripts/bash/cleanup-worktrees.sh | sourcing block lines 16-24, usage() lines 42-55, total 92
  lines` entry** — re-checked against the same current-tree read above: this entry describes the
  file's state as verified BEFORE any task in this plan has executed (a pre-execution snapshot, not
  a post-P8-T1 executor instruction), so it remains accurate and is left unchanged; it is not the
  same class of citation D2 reported, which was a task-instruction citation relied upon after an
  intervening edit.
- **Every other Round 1-4 citation naming a fixed line number or line-count for a file this round
  did not edit** — swept via a full re-read of Rounds 1-4 above; no additional stale citation was
  found beyond the three the round-4 preflight reviewer reported (D1, D2, D3). No task ID,
  acceptance condition, or AC mapping is touched by this round's edits, so the AC-Traceability
  table and every `AC-MAPPING:` line in the bounded record below are unaffected and are re-confirmed
  unchanged.

---

PLANNER-INTERNAL-REVIEW: PASS

CITATION-TO-TREE: PASS
CITATION: scripts/bash/cleanup_worktrees_lib.sh | classify_branch lines 308-443, run_report lines 445-479, per-branch loop lines 470-477
CITATION: scripts/bash/cleanup_worktrees_enumerate_lib.sh | cleanup_wt_git lines 34-57, check_main_freshness lines 221-236, compute_protected lines 166-219
CITATION: scripts/bash/cleanup_worktrees_actions_lib.sh | run_apply lines 316-382, awk extraction line 373, total 382 lines
CITATION: scripts/bash/cleanup-worktrees.sh | sourcing block lines 16-24, usage() lines 42-55, total 92 lines
CITATION: scripts/bash/shell-qc.sh | total 103 lines
CITATION: .claude/skills/cleanup-merged-worktrees/SKILL.md | Report Line Contract line 57, Dirty Worktree Triage step 7 lines 190-197
CITATION: tests/fixtures/cleanup_worktrees/stub-bin/git | for-each-ref case lines 97-99, default arm lines 205-207, merge-base case (first-arg key, pre-edit) lines 108-114, total 208 lines
CITATION: tests/fixtures/cleanup_worktrees/scenarios/**/merge-base*.rc | 16 existing files, all bare single-segment form
CITATION: tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py | test function lines 106-131
CITATION: scripts/bash/cleanup_worktrees_enumerate_lib.sh | for-each-ref refs/heads/ call site line 75
CITATION: tests/shell/test_cleanup_worktrees_classification.bats | setup() lines 8-15, cb() lines 17-22, report() lines 24-27
CITATION: tests/shell/test_cleanup_worktrees_hard_failures.bats | setup() lines 12-20, runin() lines 22-28, total 172 lines
CITATION: tests/shell/test_cleanup_worktrees_deletion.bats | setup() lines 10-19, apply() lines 21-24, total 83 lines
CITATION: .claude/rules/shell.md | full file, 93 lines
CITATION: tests/fixtures/cleanup_worktrees/scenarios/unmerged/for-each-ref.out | two `<branch> <sha>` lines (feature-unmerged cccc3333, main aaaa0000)
CITATION: tests/fixtures/cleanup_worktrees/scenarios/unmerged/rev-parse.abbrev-ref-HEAD.out | single line `main`
CITATION: tests/fixtures/cleanup_worktrees/scenarios/unmerged/rev-parse.show-toplevel.out | single line `/repo/main`
CITATION: tests/fixtures/cleanup_worktrees/scenarios/unmerged/worktree-list.out | four-line porcelain block ending in a trailing blank line
CITATION: tests/fixtures/cleanup_worktrees/scenarios/residual_on_main/ | glob-confirmed to carry its own rev-parse.abbrev-ref-HEAD.out, rev-parse.show-toplevel.out, worktree-list.out

AC-TRACEABILITY: PASS
AC-INVENTORY: AC1, AC2, AC3, AC4, AC5, AC6, AC7, AC8, AC9, AC10, AC11
AC-MAPPING: AC1 | IMPLEMENTATION: P4-T1 | TESTS: P4-T2,P4-T3,P4-T4 | EVIDENCE: P10-T2
AC-MAPPING: AC2 | IMPLEMENTATION: P3-T1 | TESTS: P3-T2,P3-T3,P3-T4 | EVIDENCE: P10-T2
AC-MAPPING: AC3 | IMPLEMENTATION: P6-T1 | TESTS: P1-T7,P6-T2,P6-T3,P6-T4 | EVIDENCE: P10-T2
AC-MAPPING: AC4 | IMPLEMENTATION: P5-T1 | TESTS: P5-T2,P5-T3,P5-T4 | EVIDENCE: P10-T2
AC-MAPPING: AC5 | IMPLEMENTATION: P7-T2,P7-T3 | TESTS: P7-T4,P7-T5 | EVIDENCE: P7-T4,P7-T5
AC-MAPPING: AC6 | IMPLEMENTATION: P2-T1,P2-T2 | TESTS: P2-T3 | EVIDENCE: P2-T3
AC-MAPPING: AC7 | IMPLEMENTATION: P9-T1,P9-T2 | TESTS: P9-T3 | EVIDENCE: P9-T3
AC-MAPPING: AC8 | IMPLEMENTATION: P7-T2 | TESTS: P10-T1 | EVIDENCE: P10-T1
AC-MAPPING: AC9 | IMPLEMENTATION: P11-T1,P11-T2,P11-T3,P11-T4 | TESTS: P11-T3,P11-T4 | EVIDENCE: P11-T1,P11-T2,P11-T3,P11-T4
AC-MAPPING: AC10 | IMPLEMENTATION: Phases-1-9-no-deletion-code | TESTS: P7-T5 | EVIDENCE: P10-T2
AC-MAPPING: AC11 | IMPLEMENTATION: P3-T2,P3-T3,P4-T2,P4-T3,P5-T2,P5-T3,P6-T2,P6-T3,P6-T5 | TESTS: P10-T2 | EVIDENCE: P10-T2

SCOPE-BOUNDARY: PASS
UNRESOLVED-GAPS: NONE

DIRECTIVE: PREFLIGHT VALIDATION ONLY
