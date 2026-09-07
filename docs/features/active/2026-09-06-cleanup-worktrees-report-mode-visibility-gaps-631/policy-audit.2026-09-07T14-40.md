# Policy Audit — issue #631 (cleanup-worktrees report-mode visibility gaps)

- Timestamp: 2026-09-07T14-40
- Feature folder: `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631`
- Branch: `bug/cleanup-worktrees-report-mode-visibility-gaps-631-r2`
- Base for diff: `origin/epic/cleanup-merged-worktrees-hardening-integration`, merge-base `6dff80ed4596bec088d548b23013e6077e32c484`
- Commits in scope: `02ce5eec` (Phases 1-9 implementation), `fbb1e65b` (Phase 10-11 evidence + AC check-off; docs-only, verified by `git diff --name-only 02ce5eec fbb1e65b`)
- Work mode: `full-bug` (from `issue.md` `- Work Mode: full-bug`); AC source is `spec.md` `## Acceptance Criteria`
- Overall verdict: **FAIL** (1 blocking finding; see PA-01)

## Rejected Scope Narrowing

None detected. The caller directed a full branch-vs-base audit against the epic
integration merge-base and supplied no instruction to limit the audit to a plan, task,
phase, or file subset. No coverage or toolchain check was directed to be skipped.

## Evidence Location Compliance

**PASS.** Scan of the branch diff for files written under `artifacts/baselines/`,
`artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`:

```
git diff --name-only 6dff80ed...HEAD | grep -E '^artifacts/(baselines|qa|evidence|coverage)/'
-> no matches
```

All 15 evidence artifacts are written under the canonical
`docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/<kind>/`
path with the sanctioned `baseline/`, `qa-gates/`, `regression-testing/`, and `other/`
kind folders. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose during this review.

## Policy Reading Order Applied

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/shell.md` (the only language rule in scope; see language inventory)
6. `.claude/rules/tonality.md`

## Language Inventory (changed files in the branch diff)

| Language | Changed files | Coverage verdict |
|---|---|---|
| bash (`.sh`, `.bats`, extension-less stub scripts) | 5 production `scripts/bash/*.sh`, 7 `tests/shell/*.bats`, 2 `tests/fixtures/**/stub-bin/*` | **PASS** — see Coverage Verification |
| Markdown (docs, SKILL.md, spec, plan, evidence) | 19 | n/a (not a coverage language) |
| TypeScript | 0 | N/A (zero changed files) |
| Python | 0 | N/A (zero changed files) |
| PowerShell | 0 | N/A (zero changed files) |
| C# | 0 | N/A (zero changed files) |

Test fixture data files (scenario `.out`/`.rc` files, `scan_roots/**`) are raw canned
test data, not code; the 500-line cap's fixture exception applies.

## Compliance Findings

### PA-01 — `classify_all_branches` changes classification outcome — **FAIL (Blocking)**

Policy: `.claude/rules/general-code-change.md` "Fail fast and explicitly … Do not
silently ignore errors"; and, more directly, the feature's own governing contract in
`spec.md` ("The short-circuit changes classification **cost** only, never classification
**outcome**. … This is a hard invariant, not a design preference.").

`scripts/bash/cleanup_worktrees_report_records_lib.sh:431-447` inherits `NOT_MERGED` for
a deferred branch `X` whenever any direct ancestor-target `Y` already resolved
`NOT_MERGED`, gated only by a protection carve-out on `X`:

```bash
for target in "${target_list[@]:-}"; do
	[[ -z $target ]] && continue
	[[ -n ${protected[$x]:-} ]] && break
	if [[ ${branch_state[$target]:-} == "NOT_MERGED" ]]; then
		hit=$target
		break
	fi
done
if [[ -n $hit ]]; then
	branch_out[$x]="BRANCH|$x|NOT_MERGED"$'\n'"CHILD_OF|$x|$hit"
```

Nothing checks `X`'s own relationship to `main` before inheriting. The premise stated in
the in-file comment — "a branch contained in a branch that is not merged cannot itself be
merged" — is false. `X` being a git ancestor of an unmerged `Y` says nothing about whether
`X` is already contained in, content-neutral against, or patch-equivalent to `main`.

Two independent lines of evidence are recorded in the code review (CR-01). The decisive
one is in the feature's own positive fixture: `child_of_not_merged` supplies no
`diff-quiet.feature-child.rc`, so the stub exits 0 for `git diff --quiet
main...feature-child`, which `classify_content_neutral`
(`cleanup_worktrees_lib.sh:141-153`) maps to `MERGED_CONTENT_NEUTRAL` — a
delete-eligible state. The short-circuit replaces that verdict with `NOT_MERGED`.

Impact: in apply mode a branch that the unchanged ladder classifies delete-eligible is
reported `NOT_MERGED` and is not deleted. The direction is fail-safe with respect to data
loss, but it defeats the tool's primary function whenever any unmerged branch descends
from an already-merged local branch — the normal state of this repository after any PR
merge. AC5 is not satisfied.

### PA-02 — `.claude/**` mirror contract — **PASS**

`.claude/skills/cleanup-merged-worktrees/SKILL.md` and
`extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
are byte-identical. Verified by both `diff` (no output) and `md5sum` (both
`c6353060b287c20249addf4d3d2175ea`). Both received the identical 15-line Report Line
Contract addition in `02ce5eec`.

### PA-03 — 500-line file cap — **PASS**

Counted directly from the working tree with `wc -l`:

| File | Lines | Cap |
|---|---|---|
| `scripts/bash/cleanup_worktrees_lib.sh` | 491 | 500 |
| `scripts/bash/cleanup_worktrees_report_records_lib.sh` | 463 | 500 |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 417 | 500 |
| `scripts/bash/cleanup_worktrees_scan_helper.sh` | 157 | 500 |
| `scripts/bash/cleanup-worktrees.sh` | 128 | 500 |
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` (unchanged) | 236 | 500 |
| `scripts/bash/cleanup_worktrees_detached_lib.sh` (unchanged) | 301 | 500 |

Independently matches the orchestrator's spot-check and the executor's
`evidence/other/file-size-cap-verification.2026-09-06T23-03.md`. The design decision to
put new logic in a sibling file rather than growing `cleanup_worktrees_lib.sh` is correct
and was followed: that file grew by 12 net lines (479 -> 491).

### PA-04 — Test policy: no temporary files, checked-in fixtures — **PASS**

All new coverage is driven from checked-in fixtures through the `CLEANUP_WT_GIT_BIN` and
new `CLEANUP_WT_SCAN_BIN` stub seams. No test creates a temporary file, scratch
repository, or temp directory. `tests/shell/test_cleanup_worktrees_scan_helper.bats` runs
the real helper against the checked-in `tests/fixtures/cleanup_worktrees/scan_roots/basic/`
tree rather than a fabricated one.

Observation (not a violation): `setup()` in five bats files runs
`chmod +x "${STUB}" 2>/dev/null || true`, mutating the mode of a tracked file during the
test run. This is a pre-existing repository pattern that the change extends to the new
scan stub; it is not introduced by this feature.

### PA-05 — Test file location — **PASS**

`.claude/rules/shell.md:90` states bash "Tests live in `tests/shell/*.bats` and mirror
`scripts/bash/`". All seven touched/added bats files are under `tests/shell/`. No test
file was placed in the production source tree.

### PA-06 — Determinism / banned APIs in tests — **PASS**

No `sleep`, wall-clock read, or network access in any new test. Every git and filesystem
read in the new production code routes through an override seam
(`cleanup_wt_git`, `cleanup_wt_scan_bin`), so the new tests are hermetic. Fixture-derived
sizes (`128K`, `64K`, `32K`) are canned constants, not measured values.

### PA-07 — Coverage exclusion policy — **PASS**

No production file was added to any coverage exclusion. `scripts/bash/**` remains fully in
the kcov denominator, including the new `cleanup_worktrees_scan_helper.sh`. No `exclude`
entry matching a production source path was introduced.

### PA-08 — Mandatory toolchain loop — **PASS (with a documented environment constraint)**

The bash toolchain is format -> lint -> test -> coverage (type-check is not applicable;
architecture-boundary and contract stages are not applicable to this surface). All four
stages are evidenced from a single CI dispatch of `.github/workflows/_shell-coverage.yml`
on commit `02ce5eec`
(https://github.com/drmoisan/drm-copilot/actions/runs/34151370364):

| Stage | Evidence artifact | Result |
|---|---|---|
| format (`shfmt`) | `evidence/qa-gates/final-format.2026-09-06T23-03.md` | exit 0, no-op |
| lint (`shellcheck`) | `evidence/qa-gates/final-check.2026-09-06T23-03.md` | exit 0, no diagnostics |
| test (`bats`) | `evidence/qa-gates/final-test.2026-09-06T23-03.md` | 335 planned, 335 ok, 0 not ok |
| coverage (`kcov`) | `evidence/qa-gates/final-test-coverage.2026-09-06T23-03.md` | `Bash coverage (lines): 93.4%` |

Documented assumption: this reviewer cannot re-execute any of these. The session's Bash
tool denies `wsl` invocations and no `bats`/`kcov`/`shfmt` binary is on the Windows PATH.
The CI run logs and the evidence artifacts above are therefore treated as the toolchain
evidence of record, as directed. The artifacts are internally consistent (321 baseline +
14 new tests = 335) and the 14-test delta reconciles exactly against the new `@test`
blocks counted in the diff (2 scan-seam + 1 scan-helper + 6 report-records + 4
classification + 1 deletion = 14).

Note on the single-pass requirement: the evidence asserts the loop completed in one pass
with no restart. That assertion rests on a single CI run and is consistent with the
artifacts, but a reviewer cannot independently distinguish "no restart occurred" from "no
restart was recorded". Accepted as stated.

### PA-09 — Error handling: fail fast, no silent fallback — **PARTIAL**

Correct and verified:
- The pairwise ancestry probe maps exit > 1 to `BRANCH|X|ANCESTRY_ERROR` and excludes `X`
  from later phases, never falling through to "not an ancestor"
  (`cleanup_worktrees_report_records_lib.sh:382-393`). Covered by
  `child_of_ancestry_probe_error`.
- `scan_stale_refs` and `cleanup_wt_scan_records` capture the underlying read in the
  parent shell and return the non-zero code rather than reading as "nothing found".
- `scan_registration_loss` skips a malformed record silently, mirroring
  `check_main_freshness`'s never-blocking contract, as the spec requires.

Gap: `run_report` now runs three advisory scans (`cleanup_worktrees_lib.sh:474-476`) whose
non-zero returns are folded into the driver's exit code with `|| rc=$?`. A hard failure of
the advisory `git for-each-ref refs/remotes/` read therefore produces a *partial* report
plus a non-zero exit, which contradicts the contract stated four lines above it in the
same docstring ("a git failure aborts the report before any line is emitted … so a git
failure never resolves to a partial, misleading report"). Non-blocking, but the docstring
and the code now disagree. See CR-06.

### PA-10 — Tonality — **PASS**

All new comments, docstrings, SKILL.md text, and evidence artifacts use neutral,
evidence-proportioned language. No hyperbole, humor, or decorative metaphor observed.

### PA-11 — Self-explanatory code commenting — **PASS**

Comment density and content in the new library are high and explanatory (rationale, not
restatement). Two comments are factually wrong about the code they describe and are
recorded as code-review findings (CR-01 on the inheritance premise, CR-03 on the "same
scan output" claim), but the commenting *policy* is satisfied.

## Coverage Verification

Per the coverage-verification procedure, for each language with changed files in the
branch diff:

**bash — verdict PASS.**

- Coverage artifact: `.claude/rules/shell.md:44,62-64` defines the bash coverage artifact
  as a merged Cobertura `cov.xml` under `SHELL_QC_KCOV_OUT_DIR` (default
  `artifacts/pester/kcov`), with the summary line `Bash coverage (lines): NN.N%`. That
  directory is CI-scoped and is not present in this worktree; the artifact of record is
  the CI run log captured in
  `evidence/qa-gates/final-test-coverage.2026-09-06T23-03.md`.
- Repo-wide bash line coverage: **93.4%**, against the uniform >= 85% floor in
  `.claude/rules/quality-tiers.md`. **PASS.**
- Branch coverage: not applicable. `.claude/rules/quality-tiers.md` and
  `.claude/rules/shell.md:68-70` exempt bash from the branch gate because kcov measures
  line coverage only. No FAIL is recorded for the absent branch figure.
- Baseline comparison: 94.2% pre-change (run 34148603116) -> 93.4% post-change (run
  34151370364), a 0.8 pp drop attributed to denominator growth of ~427 lines. Both are
  above the floor; this is not a threshold regression.

Sub-finding (non-blocking) — per-file coverage UNVERIFIED. The tier rule requires >= 85%
line coverage for each *new* file, not only repo-wide. The recorded evidence preserves
only the aggregate summary line; the per-file rows of `cov.xml` were not exported into the
feature evidence folder, so per-file coverage for the two new production files
(`cleanup_worktrees_report_records_lib.sh`, `cleanup_worktrees_scan_helper.sh`) cannot be
confirmed from the artifacts. Concrete reason for the UNVERIFIED mark: no per-file
coverage artifact exists in the repository or the evidence folder. Recorded as
remediation item R-05.

Structural reading of what is and is not exercised (from the `.bats` sources, not from a
coverage report):

- Directly covered by a dedicated `@test`: `cleanup_wt_scan_bin` (both branches),
  `scan_stale_refs` (+/-), `scan_orphan_dirs` (+/-), `scan_registration_loss` (+/-),
  `classify_all_branches` (short-circuit fires / does not fire / hard probe failure),
  `scan_helper_scan_dirs` and `scan_helper_gitdir_target_exists` (three shapes).
- Exercised only indirectly, with no assertion on its own behavior:
  `cleanup_wt_scan_roots` (the `CLEANUP_WT_ORPHAN_ROOTS` override branch and the
  `parse_worktree_list`-derived `-wt` branch), `cleanup_wt_protected_branches` (reached
  in `child_of_not_merged` but never asserted on directly, and never with a protected
  branch that is also deferred — the exact case it was added to fix).
- Not exercised at all: `scan_helper_usage` / the `scan_helper_main` non-`scan-dirs`
  dispatch arm, the `scan_helper_dir_size` `du`-failure -> `unknown` fallback, the
  absolute-`gitdir:`-target branch, and — significant for this review — the *production
  default* branch of `scan_helper_gitfile_name` (the `.git` literal). Only the override
  branch is exercised.

Per the reviewer instruction, a missing edge-case error path alone is not blocking. Two of
these do warrant remediation and are recorded as CR-04 and CR-05: the untested
protected-and-deferred path is the core logic of the function added specifically to fix
that case, and the untested `.git` production default is the exact property the seam is
required to preserve.

## Verdict Summary

| Check | Verdict |
|---|---|
| Rejected scope narrowing | None |
| Evidence location compliance | PASS |
| Outcome-preservation invariant (PA-01) | **FAIL — blocking** |
| `.claude/**` mirror byte-identity | PASS |
| 500-line file cap | PASS |
| No temp files / checked-in fixtures | PASS |
| Test file location | PASS |
| Determinism | PASS |
| Coverage exclusion policy | PASS |
| Toolchain loop (format/lint/test/coverage) | PASS |
| Error handling (fail-fast) | PARTIAL |
| bash coverage (repo-wide, >= 85%) | PASS (93.4%) |
| bash per-file coverage (new files) | UNVERIFIED — artifact not preserved |
| Tonality | PASS |

Blocking findings: **1** (PA-01).
