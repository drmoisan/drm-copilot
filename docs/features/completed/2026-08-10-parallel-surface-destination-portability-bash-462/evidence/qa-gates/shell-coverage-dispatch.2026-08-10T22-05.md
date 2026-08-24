# QA Gate — Terminal Shell CI Dispatch (Remediation Cycle 1)

Timestamp: 2026-08-10T22-05
Issue: #462
Task: [P5-T3]
Branch: `drm-copilot-wt-2026-08-10T09-25`
Baseline: `evidence/remediation-baseline/shell-ci-baseline.2026-08-10T21-40.md` (run 31414584576,
head `f7711fb42b3d3351b1a89871859fbf6b33ffede1`, 92.4%)

## Step (a) — post-change head containing all RI-1 through RI-4 changes

Command: `git rev-parse HEAD`

EXIT_CODE: 0

Output Summary: `f8d82e1e1794b3beda66787c526ffe6da2b4a962`

Commit `f8d82e1e` contains every RI-1 through RI-4 production change: `.gitignore` (RI-4),
`<FEATURE>/spec.md` (RI-1), `.claude/settings.json` and both agent definitions plus all three
bundled mirrors (RI-2), `scripts/bash/shell_qc_lib.sh` and `scripts/bash/cleanup_worktrees_lib.sh`
(RI-3), and the amended disclosure artifact. Pushed to the branch:
`f7711fb4..f8d82e1e  drm-copilot-wt-2026-08-10T09-25`.

AC17 post-commit scope check: `git diff --name-only f7711fb4..HEAD` lists 22 paths — 11 production
and requirement files plus 11 plan/inputs/evidence artifacts under the feature folder. Filtering
that list with `grep -E "^(scripts/dev_tools/|extensions/drm-copilot/src/lib/validate/)"` exits 1
with no matches: **zero files under either prohibited prefix**.

## Step (b) — dispatch

Command: `gh workflow run _shell-coverage.yml --ref drm-copilot-wt-2026-08-10T09-25`

EXIT_CODE: 0

Output Summary: `https://github.com/drmoisan/drm-copilot/actions/runs/31436071256`

## Step (c) — poll to completion

Command: `gh run watch 31436071256 --exit-status --interval 20`

EXIT_CODE: 0

Output Summary: run completed. Job `Shell Coverage (Bats + kcov)` (ID 93610363212) succeeded in
3m18s. Step results:

| Step | Result |
| --- | --- |
| Set up job | pass |
| Check out repository | pass |
| Install shell tooling (shellcheck, shfmt, bats) | pass |
| Cache kcov build | pass |
| Install kcov from cache | pass |
| **Run shell-qc check (shfmt diff + shellcheck)** | **pass** |
| **Run shell-qc test with coverage** | **pass** |
| Upload shell coverage artifacts | pass |
| Complete job | pass |

Both required verification steps are green.

## Step (d) — capture identity and coverage

Command: `gh run view 31436071256 --json url,conclusion,status,headSha,event`

EXIT_CODE: 0

Output Summary:

```
{"conclusion":"success","event":"workflow_dispatch","status":"completed",
 "headSha":"f8d82e1e1794b3beda66787c526ffe6da2b4a962",
 "url":"https://github.com/drmoisan/drm-copilot/actions/runs/31436071256"}
```

**headSha equality: `f8d82e1e1794b3beda66787c526ffe6da2b4a962` == the `git rev-parse HEAD` recorded
in step (a).** Confirmed.

Command: `gh run view 31436071256 --log | grep -E "Bash coverage \(lines\): [0-9]"`

EXIT_CODE: 0

Output Summary:

```
Shell Coverage (Bats + kcov)	Run shell-qc test with coverage	2026-08-10T21:59:04.3769979Z Bash coverage (lines): 92.3%
```

The digit-anchored pattern is mandatory; the unanchored form also matches the `shell-qc.sh` usage
banner's literal `NN.N%` placeholder text.

## Gate Evaluation (manual — the workflow enforces no coverage floor)

`shell-qc.sh test --coverage` prints the coverage value but enforces no threshold, and the workflow
has no automated floor, so a low-coverage run would still conclude `success`. The two conditions
below are evaluated manually against the printed number.

| Condition | Baseline | This run | Verdict |
| --- | --- | --- | --- |
| `NN.N >= 85.0` | 92.4% | **92.3%** | **PASS** — 7.3 points above the floor |
| No regression vs. baseline | 92.429% (1343/1453) | 92.266% (1348/1461) | **NOMINAL REGRESSION of 0.163 percentage points** — see the finding below |

## FINDING — 0.163pp headline coverage decrease (escalated, not silently accepted)

The headline percentage moved from 92.4% to 92.3%. The exact `cov.xml` line ratios were extracted
from the uploaded coverage artifacts of both runs (`gh run download 31414584576` and
`gh run download 31436071256`) and compared:

| Scope | Baseline covered/total | This run covered/total | Delta |
| --- | --- | --- | --- |
| Whole bash surface | 1343 / 1453 = 92.429% | 1348 / 1461 = 92.266% | +5 covered, +8 total, **-0.163pp** |
| `scripts/bash/cleanup_worktrees_lib.sh` | 179 / 192 = 93.23% | 180 / 193 = 93.26% | +1 covered, +1 total, **+0.03pp (improved)** |
| `scripts/bash/shell_qc_lib.sh` | 156 / 178 = 87.64% | 160 / 185 = 86.49% | +4 covered, +7 total, **-1.15pp** |
| every other file | unchanged | unchanged | 0 |

The delta is confined to the two RI-3 files and is fully explained by **measurement fidelity, not by
any loss of tested behavior**. No test was removed, disabled, or weakened; the bats suite is
byte-identical between the two runs and exercises exactly the same code paths.

Mechanism: kcov counts physical lines. The pre-edit form put a condition and its consequent on one
line:

```bash
((rc > exit_code)) && exit_code=$rc || true      # 1 line, counted covered whenever reached
```

The rewrite splits that into a condition line and a body line (`fi` is not counted):

```bash
if ((rc > exit_code)); then                      # counted, covered when reached
	exit_code=$rc                                # counted separately, covered only when TAKEN
fi
```

The consequent's coverage was previously masked by sharing a physical line with its condition. Seven
sites in `shell_qc_lib.sh` each add one counted line (+7 total); four of those bodies are taken by
the suite (+4 covered) and three are not, producing the three additional uncovered lines. The single
site in `cleanup_worktrees_lib.sh` adds one counted line whose body IS taken, so that file improved.

The three additional uncovered lines, identified by diffing the per-line hit maps of the two
`cov.xml` files:

| Post-edit line | Statement | Classification |
| --- | --- | --- |
| `shell_qc_lib.sh:250` | `exit_code=$rc` in the bats-run loop | Split of an **already-uncovered** statement — the pre-edit combined line at base 247 was itself uncovered, so this converts one uncovered line into two. No coverage was lost. |
| `shell_qc_lib.sh:352` | `exit_code=$rc` after the per-directory `kcov` run | **Newly visible** uncovered branch body. The pre-edit combined line (base 347) counted as covered because the condition was evaluated; the assignment itself was never taken, because the stubbed `kcov` in the bats suite never returns non-zero on that path. |
| `shell_qc_lib.sh:363` | `exit_code=$rc` after `kcov --merge` | **Newly visible** uncovered branch body, same mechanism (base 356). |

So of the three, one is a re-count of an already-uncovered statement and two are pre-existing
untested error branches that the pre-edit idiom concealed. The rewrite did not stop any behavior
from being exercised; it stopped two untested error branches from being reported as covered. The
honest reading is that the baseline 92.4% slightly overstated true line coverage and 92.3% is the
more accurate figure.

**Disposition.** This is reported, not remediated. Covering the two error branches would require new
bats cases forcing a non-zero `kcov` exit, which is new work described by no task in
`remediation-plan.2026-08-10T21-03.md`; `bats` is also unavailable in this environment, so such
cases could not be verified locally. Per the executor contract this is escalated at completion for
the orchestrator's post-execution re-audit to adjudicate rather than actioned unilaterally. The
absolute value remains 7.3 points above the 85% policy floor in
`.claude/rules/quality-tiers.md`, and AC13 (`bash line coverage is >= 85%`) is satisfied.

## RI-3 Authoritative Verification

The `Run shell-qc check (shfmt diff + shellcheck)` step passed on the runner with **both file-wide
`# shellcheck disable=SC2015` directives deleted and no replacement suppression of any scope
present**. This is the authoritative RI-3 evidence per Binding Environment Constraint 2: the CI
runner's apt-packaged shellcheck is the version that emitted the original SC2015 findings, and local
shellcheck 0.11.0 cannot reproduce them. The step also confirms CI's shfmt 3.8.0 accepts the
expanded `if` form with no diff, so no formatting iteration was required.

## Post-Dispatch Commit Policy

Only evidence and documentation commits follow this dispatch on the branch: this artifact, the
P5-T4 artifact, and the plan checkbox updates. No production file changes after `f8d82e1e`, so the
dispatch does not need to be repeated.

Output Summary: Green `_shell-coverage.yml` run 31436071256 at post-change head
`f8d82e1e1794b3beda66787c526ffe6da2b4a962`, conclusion `success`, `headSha` equality confirmed. Both
verification steps green, including the shellcheck step that authoritatively verifies the RI-3
rewrites with no suppression present. Numeric bash line coverage **92.3%**, above the 85% floor by
7.3 points. One finding escalated: a 0.163pp headline decrease from 92.4%, confined to the two RI-3
files, attributable entirely to kcov counting two previously-masked untested error branches plus one
re-split of an already-uncovered statement — not to any loss of tested behavior.
