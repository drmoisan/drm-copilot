# Policy Audit — issue #632, remediation cycle 3 EXIT REAUDIT

Timestamp: 2026-09-09T09-00
Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2` @ `8afb0611`
Resolved base: `epic/cleanup-merged-worktrees-hardening-integration`, merge-base `4ffe680e`
Cycle 3 work range: `fcefa802..8afb0611`
Work mode: `full-bug` (`issue.md:12` — `- Work Mode: full-bug`)
Reviewer stance: verification by reproduction on a scratch copy, not by reading.

## Scope Resolution

The caller framed this as a cycle-3 exit reaudit with two named findings (N3, N4) plus a
systemic check. That framing was treated as a set of REQUIRED checks, not as a scope
narrowing: the audit below covers the full branch diff against the resolved base.

No `## Rejected Scope Narrowing` entries. The caller did not attempt to limit the audit to
a subset of changed files, and did not assert that any language with changed files was out
of scope.

Base resolution note. `git merge-base HEAD origin/main` returns `0542c92a`, and against
that base three TypeScript files appear in the diff
(`extensions/drm-copilot/src/lib/pr-context/collector-core.ts` and two tests). Those come
from commit `1c5c6298` ("fix(pr-context): route unmatched changed paths into bucketDocs
(#633)"), and `git branch -a --contains 1c5c6298` shows that commit is already on
`epic/cleanup-merged-worktrees-hardening-integration`. This branch merges into the epic
integration branch, so the correct base is `4ffe680e`. Against `4ffe680e` the TypeScript
files are not in the diff.

Command:

```
git merge-base HEAD origin/epic/cleanup-merged-worktrees-hardening-integration
git diff --name-only 4ffe680e..8afb0611 | grep -vE '\.md$'
```

## Language Coverage Verdicts

Languages with changed source files against the resolved base `4ffe680e`:

| Language | Changed files | Coverage verdict |
|---|---|---|
| bash (`.sh` production, `.bats` tests) | 4 production `.sh`, 14 `.bats`, 1 `.tsv` fixture, many fixture data files | **PASS** |
| TypeScript | 0 | N/A — zero changed files against the resolved base |
| Python | 0 | N/A — zero changed files |
| PowerShell | 0 | N/A — zero changed files |
| C# | 0 | N/A — zero changed files |

### Bash coverage — PASS

Coverage is not rerun by this agent. It is verified from the artifact of CI dispatch
**34255859868** (`Shell Coverage (reusable)`, conclusion `success`, head `5ad0ef09`).

Command:

```
gh api repos/drmoisan/drm-copilot/actions/runs/34255859868/artifacts
gh api repos/drmoisan/drm-copilot/actions/artifacts/10068076892/zip > shell-coverage.zip
unzip -o -q shell-coverage.zip -d unpacked
awk '<per-class covered/total counter>' unpacked/kcov-merged/cov.xml
```

Independently recomputed from `kcov-merged/cov.xml` by counting `<line hits=>` per
`<class>`:

| File | Covered / valid | Percent |
|---|---|---|
| Repo-wide bash | 2169 / 2315 | **93.69%** |
| `scripts/bash/cleanup_worktrees_dirt_lib.sh` | 163 / 173 | **94.22%** |
| `scripts/bash/cleanup_worktrees_lib.sh` | 187 / 196 | 95.41% |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 159 / 169 | 94.08% |
| `scripts/bash/cleanup-worktrees.sh` | 38 / 39 | 97.44% |

The XML header independently reports `line-rate="0.937" lines-covered="2169"
lines-valid="2315"`, matching the recomputation. The executor's claimed classifier figure
of 94.22% (163/173) is reproduced exactly; the evidence artifact is accurate.

Repo-wide 93.69% >= 85% and every in-scope file >= 85%. Branch coverage is not evaluated:
kcov measures no branch coverage, and `.claude/rules/quality-tiers.md` exempts bash from
the branch threshold as a capability limit. `branch-rate="1.0"` in the artifact is a kcov
placeholder, not a measurement, and is not treated as evidence.

New-line coverage. The classifier gained three executable lines (170 -> 173) and three
covered lines (160 -> 163). All three new guard lines carry non-zero hits:

```
line 297 hits=1   [[ $x == [MARCTU] && $y == [MARCTU] ]] && bothloc=1
line 322 hits=1   if ((bothloc == 0)); then  # guard:rung4-index-blob-unaccounted
line 371 hits=1   if ((bothloc == 0)); then  # guard:rung5-index-blob-unaccounted
```

The ten uncovered classifier lines (90-93, 111, 177, 180, 189, 219, 364) are array-literal
entries and continuation lines of multi-line statements, where kcov attributes the hit to
the statement's first line. None is a verdict-emitting guard. All ten pre-date this cycle.

### Test suite — PASS

CI dispatch 34255859868: TAP `1..417`, `grep -c "not ok"` over the full run log returns
**0**. Phase 0 baseline was 411, so the branch adds 6 net tests and breaks none.

The evidence commit `8afb0611` that follows the tested head `5ad0ef09` is documentation
only, confirmed by `git diff --name-only 5ad0ef09..8afb0611` returning five paths, all
under the feature folder (four `evidence/qa-gates/*.md` and the remediation plan).

Locally corroborated with `npx --yes bats` on a scratch copy: classify 24, clear 14,
regression 12, failclosed 15, content_locations 2, guard_registry 3 — all green, zero
`not ok`.

## Toolchain — PASS

| Stage | Command | Result |
|---|---|---|
| Format | `shfmt -d -ln bash scripts/bash/cleanup_worktrees_dirt_lib.sh` | no diff — PASS |
| Lint | `shellcheck -x -s bash scripts/bash/cleanup_worktrees_dirt_lib.sh` | clean — PASS |
| Type check | n/a for bash | skipped per `.claude/rules/shell.md` |
| Unit tests | `npx --yes bats tests/shell/test_cleanup_worktrees_dirt_*.bats` | 70/70 PASS |

## Epic NFRs

| NFR | Verdict | Evidence |
|---|---|---|
| Bash line coverage >= 85% | **PASS** | 93.69% repo-wide from the CI kcov artifact |
| New library functions covered via the `CLEANUP_WT_GIT_BIN` stub seam against checked-in fixtures | **PASS** | Every dirt suite drives `classify_worktree_dirt` through `env CLEANUP_WT_GIT_BIN=<stub> CLEANUP_WT_STUB_SCENARIO=<checked-in dir>`; the new `dirt_index_and_worktree_delta` scenario is 17 checked-in fixture files |
| No temporary files in tests | **PASS** | `grep -nE 'mktemp\|/tmp/\|TMPDIR\|BATS_TMPDIR\|mkdir -p'` over the three changed test files returns nothing. The registry suite states "The mutated source never reaches disk" and passes the mutated text through a variable |
| No production source file > 500 lines | **PASS** | classifier 495; `cleanup_worktrees_lib.sh` 496 |
| `cleanup_worktrees_lib.sh` untouched | **PASS** | absent from `git diff --stat fcefa802..8afb0611`; at 496 lines |
| `.claude/**` edits mirrored byte-identically | **PASS** | one `.claude` edit in cycle 3 (`skills/cleanup-merged-worktrees/SKILL.md`); `diff` against the `extensions/drm-copilot/resources/claude-customizations/.claude/...` mirror reports no difference |

## Evidence Location Compliance — PASS

```
git diff --name-only 0542c92a..8afb0611 | grep -E '^artifacts/(baselines|qa|evidence|coverage)/'
```

Returns nothing. All evidence is under
`docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/` in the
canonical `<kind>` subdirectories: `baseline`, `other`, `qa-gates`,
`regression-testing`, `remediation-baseline`. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED`
entries were needed.

## General Code-Change and Unit-Test Policy

| Rule | Verdict | Note |
|---|---|---|
| Fail fast and explicitly | **PASS** | Every ladder rung whose probe fails in an undefined way emits `UNIQUE`. The N3 fix extends this: an unaccounted index blob now falls through to `UNIQUE` rather than a disposable verdict |
| No silent error suppression | **PASS** | Exit codes are captured into named variables (`drc`, `erc`, `hrc`, `lrc`) and an exit above the probe's defined negative is treated as carrying no verdict |
| Separation of concerns | **PASS** | All git access is routed through the `cleanup_wt_git` seam; the classifier holds no direct I/O |
| Coverage exclusion policy | **PASS** | No production path is excluded from kcov measurement |
| Test file location | **PASS** | All bats files under `tests/shell/`, mirroring `scripts/bash/` |
| Determinism | **PASS** | No wall-clock reads, no sleeps, no RNG; every scenario is a checked-in fixture directory |
| Descriptive naming | **PASS** | `bothloc` is the one abbreviation introduced; it is defined by the header block "INDEX AND WORKING TREE ARE TWO LOCATIONS" and by the guard marker `index-and-worktree-both-hold-content` |

## Executor Disclosures — both verified benign

**Disclosure 1 — the guard named descriptively rather than by literal id.** Verified and
correct. The registry suite derives its marker set with
`grep -oE '# guard:[a-z0-9-]+$'`, which is end-of-line anchored. A prose comment ending in
the literal id would register as a second marker occurrence for the same id and trip the
suite's Invariant 4 duplicate-id accumulator. The id occurs in exactly three places
(library line 297, registry row 41, `LIT_IDS` at line 157), and the end-anchored derivation
returns 40 markers, matching the 40 distinct registry ids. The descriptive phrasing is
required by the derivation, not a concealment.

**Disclosure 2 — predicted intermediate count 4 rather than 6.** A plan-bookkeeping
discrepancy in a transient count, with no effect on shipped text. The final-state counts
are what this audit verified independently (40 markers, 42 rows, 40 distinct ids), and they
are self-consistent. Non-blocking.

## Blocked Gates Carried From Cycle 2 — accepted

Five tasks in the CYCLE 2 plan remain unchecked, adjudicated in
`evidence/other/phase0-blocked-gates.2026-09-08T22-00.md`. Reviewed and accepted:

- Two tree-digest tasks (P0-T3, P0-T10). The isolation guard refuses any command line
  containing `source`, which is the only route to `discover_shell_scripts`. The
  adjudication establishes that the digest's extra reach over the status channel is over an
  empty set in this tree: `tools/` does not exist, and every file under the two remaining
  discovery roots carrying a bash/sh shebang has a `.sh` suffix. I independently confirmed
  the same denial applies to my own context. Environmental, not a defect.
- Three push-down contract legs failing on issue #510, a pre-existing gitignored-state
  defect that fails identically at baseline and post-change. Not attributable to this
  change.

Cycle 3's own plan (`remediation-plan.2026-09-08T23-30.md`) has 48 tasks, 48 checked, 0
unchecked.

## Verdict

No FAIL findings. No blocking PARTIAL findings.
