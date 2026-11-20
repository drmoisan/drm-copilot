# Policy Audit — cleanup-worktrees report-mode visibility gaps (#631)

- **Timestamp:** 2026-09-07T20-15
- **Cycle:** remediation cycle 1, round 4 (re-audit)
- **Feature folder:** `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631`
- **Work mode:** `full-bug` (`issue.md:12` — `- Work Mode: full-bug`); AC source is `spec.md` only
- **Branch:** `bug/cleanup-worktrees-report-mode-visibility-gaps-631-r3`
- **Head:** `ebe50907d5ef61a01afd6d5c3324fb62ea9c02e0`
- **Base:** `origin/epic/cleanup-merged-worktrees-hardening-integration`, merge-base `6dff80ed4596bec088d548b23013e6077e32c484`
- **Audit scope:** full branch diff `6dff80ed..ebe50907` (170 files, +7748/-152)

## Rejected Scope Narrowing

None detected. The caller prompt enumerated specific verification targets (D1–D6, R-01/R-02/R-04)
but explicitly directed a "full, independent re-audit" including an independent search for new
defects. No instruction attempted to limit the audit to a subset of changed files, to a plan or
phase, or to mark any language's coverage as informational. The audit was performed against the
full branch diff regardless.

## Evidence Location Compliance

- `git diff --name-only 6dff80ed..ebe50907 | grep -E '^artifacts/(baselines|qa|evidence|coverage)/'`
  returned no matches (exit 1). **PASS.**
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no
  output. **PASS.**
- All feature evidence resolves under
  `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/{baseline,remediation-baseline,qa-gates,regression-testing,other}/`.
  **PASS.**
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events occurred during this audit.

## PR Context Artifacts

`artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` were absent at audit
entry. Both were regenerated before analysis:

```
poetry run python -m scripts.dev_tools.pr_context.collector \
  --base origin/epic/cleanup-merged-worktrees-hardening-integration --head HEAD --repo-root .
```

Freshness cross-check: both files carry the generation stamp `2026-09-08 00:12:11 UTC` and
`Head SHA: ebe50907d5ef61a01afd6d5c3324fb62ea9c02e0`, which equals the current branch head. Pair
identity and head binding both hold. **PASS.**

## Policy Reading Order Applied

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`
5. Language-scoped: bash is the only production language with changed source files in this diff.
   `.claude/rules/shell.md` is referenced by `spec.md`'s Test Strategy; PowerShell, Python,
   TypeScript, and C# rules are not in scope because those languages have zero changed files.

No policy document under `.claude/rules/` or `.github/instructions/` was modified by this branch
(verified against the diff file list) and none was modified by this audit.

## Languages With Changed Files

| Language | Changed files in diff | Coverage verdict |
|---|---|---|
| bash (`.sh`, `.bats`, stub binaries) | 16 production/test/fixture-executable files | **PASS** (see Coverage Verification) |
| Markdown (docs, SKILL.md) | 47 | n/a — not a coverage language |
| Fixture data (`.out`, `.rc`, `.gitkeep`, `dotgit`) | 107 | n/a — inert test data |
| TypeScript | 0 | n/a — zero changed files |
| Python | 0 | n/a — zero changed files |
| PowerShell | 0 | n/a — zero changed files |
| C# | 0 | n/a — zero changed files |

## Coverage Verification

Bash coverage is produced by kcov and published as a CI workflow artifact rather than at any of the
four paths in the reviewer's language/artifact table (which covers TypeScript, Python, PowerShell,
and C# only). The canonical bash artifact for this code state is the `shell-coverage` artifact of
workflow run `34162347134`.

**Independent verification performed by this audit** (not taken from the executor's evidence file):

- Confirmed the run's head SHA: `gh run view 34162347134 --json headSha` returns
  `9f0a3e6c744033d68f4179b41ef0872a27fe8dd1`, conclusion `success`.
- Confirmed no code changed after that commit: `git diff --stat 1f702f68 HEAD -- scripts/ tests/`
  is empty, and `git diff --stat 9f0a3e6c HEAD` touches only `docs/`. The CI run is therefore
  valid toolchain evidence for the head under review.
- Extracted from the run log: `1..343` planned bats tests and the literal line
  `Bash coverage (lines): 93.5%`.
- Downloaded and parsed the run's Cobertura `cov.xml` directly
  (`gh api repos/drmoisan/drm-copilot/actions/artifacts/10033128216/zip`):
  root `line-rate=0.935`, `lines-covered=1982`, `lines-valid=2119`.

Per-file rows for every file this branch adds or modifies (this closes the R-05 gap the prior cycle
recorded, at least for this audit's record):

| File | Status in diff | Line coverage | Threshold | Verdict |
|---|---|---|---|---|
| `scripts/bash/cleanup_worktrees_report_records_lib.sh` | new | 89.0% (162/182) | >= 85% | PASS |
| `scripts/bash/cleanup_worktrees_scan_helper.sh` | new | 86.8% (46/53) | >= 85% | PASS |
| `scripts/bash/cleanup_worktrees_lib.sh` | modified | 94.3% (183/194) | >= 85% | PASS |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | modified | 93.9% (155/165) | >= 85% | PASS |
| `scripts/bash/cleanup-worktrees.sh` | modified | 100.0% (22/22) | >= 85% | PASS |
| Repo-wide bash | — | 93.5% (1982/2119) | >= 85% | PASS |

Branch coverage: not applicable. kcov does not measure branch coverage in any output format, so
bash carries no branch-coverage gate (`.claude/rules/quality-tiers.md`, Rationale paragraph). The
Cobertura `branch-rate="1.0"` attribute is a kcov placeholder, not a measurement, and is not read
as a verdict here.

**Threshold note.** The reviewer instruction block states the authoritative uniform tier rule as
line coverage >= 85% for new files, modified files, and repo-wide, and states explicitly that
"Tier-specific lower thresholds are not used." A later paragraph in the same instruction block
restates the per-file figures as 90%/80%; that paragraph contradicts both the authoritative
statement above it and `.claude/rules/quality-tiers.md`, which is the cited source of truth and
states 85% uniformly. This audit applies 85%. Recorded for transparency: at a 90% new-file bar,
`cleanup_worktrees_report_records_lib.sh` (89.0%) would not clear it. Under the authoritative
85% rule it does.

**Coverage regression check.** Both new files are present in the coverage denominator; no
`exclude` entry was added anywhere in this diff (verified — the diff adds no coverage
configuration). Repo-wide bash line coverage moved 94.2% (epic integration tip baseline) → 93.4%
(post-implementation) → **93.5%** (this head). The 0.7pp aggregate decline against the epic
baseline reflects 235 newly instrumented lines across the two new files; it is not a threshold
breach and no changed line regressed. Recorded as an observation, not a finding.

## Coverage Exclusion Policy

No `exclude` entry matching a production source path is introduced. `scripts/bash/` files are
measured in full, including the host-bound wrapper `cleanup-worktrees.sh`. **PASS.**

## Toolchain Loop Verification

The seven-stage loop maps onto bash as format → lint → test → test-with-coverage (type checking and
architecture-boundary tests are not applicable to bash; contract/schema checks are covered by the
push-down mirror contract test).

| Stage | Command | Result | Source |
|---|---|---|---|
| Format | `shfmt -d` over the five changed `scripts/bash/*.sh` files and both stub binaries | exit 0, no diff | **re-run independently by this audit** (shfmt v3.12.0 on PATH) |
| Lint | `shellcheck -x -s bash` over the same seven files | exit 0, no diagnostics | **re-run independently by this audit** (ShellCheck 0.11.0) |
| Type check | n/a for bash | — | `.claude/rules/shell.md` / spec Test Strategy |
| Architecture boundary | n/a for bash | — | — |
| Unit tests | `shell-qc.sh test --coverage` | 343/343 pass, exit 0 | CI run 34162347134, log line `1..343`, verified by this audit |
| Contract/schema | `pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` | 1 passed | executor evidence `qa-gates/skill-md-mirror-contract.2026-09-07T14-40.md`; the byte-identity property was **independently re-verified** by this audit via `diff` between the two SKILL.md paths (identical) |
| Integration | covered by the bats end-to-end `run_report`/`run_apply` suites | pass | CI run |

**PASS** — single-pass clean loop on the head code state.

## Policy Compliance Findings

### `.claude/rules/general-code-change.md`

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity first | PASS | `classify_all_branches` (`cleanup_worktrees_report_records_lib.sh:346-476`) is now a flat two-phase function with no deferral machinery, no protected-branch carve-out, and no verdict substitution. The remediation removed a state machine rather than adding one. |
| Reusability | PASS | `run_report_scans` (`:306-344`) is the single shared driver both scan consumers route through; `classify_all_branches` is the single classification driver shared by `run_report` (`cleanup_worktrees_lib.sh:485`) and `run_apply` (`cleanup_worktrees_actions_lib.sh:387`). |
| Extensibility | PASS | `scan_orphan_dirs` and `scan_registration_loss` take an optional pre-scanned-records first argument keyed on argument count (`:216`, `:280`), preserving the no-argument direct-call contract their six existing tests use. |
| Separation of concerns | PASS | All filesystem I/O is confined to `cleanup_worktrees_scan_helper.sh` behind the `CLEANUP_WT_SCAN_BIN` seam; all git I/O routes through `cleanup_wt_git`. Record-shaping logic is pure over captured text. |
| Dead code removed | PASS | `cleanup_wt_protected_branches` is gone. Repository-wide search for the literal returns matches only in `docs/` prose; zero matches under `scripts/` or `tests/`. D3 satisfied. |
| Fail fast, no silent error swallowing | PASS | Every new git and scan read is captured in the parent shell with `|| rc=$?` and returns the non-zero code (`:83-92`, `:182-185`, `:219-222`, `:283-286`, `:323-330`, `:401-404`). A hard pairwise-probe failure raises the driver rc to 2 without silently degrading to "not an ancestor" (`:459-463`) — **independently exercised and confirmed by this audit** (see the code review's reproduction). |
| Descriptive naming | PASS | `run_report_scans`, `classify_all_branches`, `cleanup_wt_scan_roots`, `scan_helper_gitdir_target_exists`. Local abbreviations (`rc`, `crc`, `srrc`, `orc`, `lrc`, `ebout`) follow the sibling libraries' established convention. |
| No breaking public API change | PASS | `BRANCH|`, `COMMIT|`, `WORKTREE|`, `WARN|main-divergence|`, `DIRTY|`, `ACTION|` shapes are unchanged. `CHILD_OF|` is additive and is invisible to `run_apply`'s `^BRANCH\|` state extraction. |
| No new dependencies | PASS | `du`, `grep`, `awk`, `sort` only; no new package. |
| **500-line file cap** | PASS | `cleanup_worktrees_lib.sh` 490; `cleanup_worktrees_report_records_lib.sh` 476; `cleanup_worktrees_actions_lib.sh` 417; `cleanup_worktrees_scan_helper.sh` 157; `cleanup-worktrees.sh` 128; `test_cleanup_worktrees_detached.bats` 328; `test_cleanup_worktrees_classification.bats` 258; `stub-bin/git` 246; `test_cleanup_worktrees_hard_failures.bats` 181; `test_cleanup_worktrees_deletion.bats` 152; `test_cleanup_worktrees_report_records.bats` 131; `test_cleanup_worktrees_cli.bats` 91; `stub-bin/scan` 57; `test_cleanup_worktrees_scan_helper.bats` 34; `test_cleanup_worktrees_scan_seam.bats` 28. All <= 500. **Counted independently by this audit via `wc -l`.** |
| I/O isolation | PASS | Domain logic (record classification, ancestry pairing) is testable without touching the network or filesystem; every test drives it through the two checked-in stubs. |

### `.claude/rules/general-unit-test.md`

| Requirement | Verdict | Evidence |
|---|---|---|
| Independence | PASS | Every test sets its own `CLEANUP_WT_STUB_SCENARIO` and runs in an `env`-scoped subshell. No shared mutable state. |
| Isolation | PASS | Each `@test` targets one function or one driver under one scenario. |
| Fast execution | PASS | Full suite of 343 bats tests completes inside the CI shell-coverage job. |
| Determinism | PASS | Both stubs replay canned bytes from checked-in fixture files. No clock, no RNG, no network. `LC_ALL=C sort` pins all record ordering, and `classify_all_branches` emits in `enumerate_branches`' original order (`:470-474`) with the ancestor-target chosen from an `LC_ALL=C`-sorted probe list (`:441`). |
| Readability | PASS | Every new test carries a comment stating the scenario and the property under test, and the three counterexample tests name the specific ladder rung they pin. |
| **No temporary files** | PASS | All new fixtures are checked in under `tests/fixtures/cleanup_worktrees/{scenarios,scan_roots}/`. The pointer-file naming seam `CLEANUP_WT_SCAN_GITFILE_NAME` exists precisely so a `.git` pointer file need not be created at test time; the rationale is documented at `cleanup_worktrees_scan_helper.sh:32-40`. Grep of the new bats files finds no `mktemp`, no `BATS_TMPDIR` write, and no scratch repository creation. |
| No external services | PASS | Both binaries are seam-substituted. |
| Test file location mirrors source | PASS | `tests/shell/test_cleanup_worktrees_report_records.bats`, `..._scan_helper.bats`, `..._scan_seam.bats` sit under `tests/`, not colocated in `scripts/`. |
| Scenario completeness — positive/negative | PASS | Positive/negative pairs exist for `STALE_REF`, `ORPHAN_DIR`, `WARN|registration-lost`, and `CHILD_OF`; three additional cut-point counterexamples pin `MERGED_CLEAN`, `MERGED_CONTENT_NEUTRAL`, and `MERGED_EQUIVALENT`. |
| Scenario completeness — error handling | **PARTIAL (non-blocking)** | 20 of 182 instrumented lines in `cleanup_worktrees_report_records_lib.sh` are unhit, and they are almost entirely error/fallback branches: the two `scan_stale_refs` git-failure returns (85-86, 90-91), the empty-root-list early return (168), the non-executable-fallback scan invocation (180), the scan hard-failure returns (183-184, 221, 285), the whole `run_report_scans` scan-failure and rc-maximization block (325-329, 333, 337, 341), the `enumerate_branches` hard-failure return (403), and **the pairwise-probe hard-failure `rc=2` line (462)**. `cleanup_worktrees_scan_helper.sh` leaves 54, 69, 88-89, 127, 145-146 unhit. This is the previously deferred R-06, plus eight lines newly introduced by this cycle's `run_report_scans`. Both files still clear the 85% per-file floor. This audit independently exercised the line-462 path outside the repository and confirmed the delivered behavior matches the specified contract, so this is an unpinned-but-correct path rather than an unknown one. Detail in the code review as CR-R4-02. |
| Coverage >= 85% line, no changed-line regression | PASS | See Coverage Verification. |
| Test categories (tier) | PASS | `quality-tiers.yml` classification for `scripts/bash/` governs; bash carries no property-test, mutation, or golden-test obligation in this repository's shell toolchain. Contract coverage at the host boundary is provided by the push-down SKILL.md mirror test. |
| Determinism infrastructure (banned APIs) | PASS | No `sleep`, no wall-clock read, no `$RANDOM` in the new production or test code. |

### `.claude/rules/tonality.md`

PASS. The new docstrings, SKILL.md text, and `spec.md` amendments are factual and measured. The
rewritten `classify_all_branches` header states the counterexample argument in literal terms and
explicitly withdraws the previously overstated cost claim ("the `CHILD_OF` record buys no
classification-cost reduction and none is claimed for it", `spec.md:336-339`). No hyperbole, no
humor, no decorative metaphor observed.

### `.claude/rules/quality-tiers.md`

PASS. Uniform 85% line threshold applied; no tier-specific lower floor invoked; branch threshold
correctly not applied to bash.

## Toolchain-Gate Summary

| Gate | Verdict |
|---|---|
| Format (`shfmt -d`) | PASS (independently re-run) |
| Lint (`shellcheck -x`) | PASS (independently re-run) |
| Type check | n/a (bash) |
| Architecture boundary | n/a (bash) |
| Unit tests | PASS (343/343, CI 34162347134) |
| Contract/schema (SKILL.md mirror) | PASS (independently re-verified byte-identity) |
| Integration | PASS |
| Line coverage >= 85% (bash) | PASS (93.5% repo-wide; 89.0% / 86.8% for the two new files) |
| Branch coverage | n/a (kcov does not measure it) |
| File size cap | PASS (max 490 of 500) |
| Evidence location | PASS |

## Policy Audit Verdict

**PASS — 0 FAIL findings, 1 non-blocking PARTIAL** (error-path scenario completeness, carried
forward from the deferred R-06 and extended by this cycle's `run_report_scans` block).

Blocking findings from this artifact: **0**.
