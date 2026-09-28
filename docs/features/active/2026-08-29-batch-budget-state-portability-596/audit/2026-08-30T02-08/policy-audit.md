# Policy Audit (reaudit, cycle-1 exit gate) — Feature B: Batch-budget state portability (issue #596)

- Timestamp: 2026-08-30T02-08
- Reviewer: feature-review agent
- Worktree: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5`
- Branch: `feature/batch-budget-state-portability-596` at `a7d4dd27`
- Base: `origin/epic/claude-runtime-portability-integration` (merge-base `6df37664`)
- Work mode: `full-bug` — `spec.md` is the sole acceptance-criteria source
- Prior audit under review: `audit/2026-08-29T23-07/` (0 Blocking, 2 Major, 6 Minor)
- Working tree state at review time: clean (`git status --porcelain` empty, before and after every
  check performed here)

## Finding Counts (stated for mechanical arithmetic)

| Class | Count |
| --- | --- |
| **FAIL / Blocking** | **0** |
| **Blocking PARTIAL** | **0** |
| Non-blocking PARTIAL | 1 (toolchain loop — unscoped PoshQC test stage; see Adjudication 2) |
| Major | 0 |
| Minor (advisory, non-blocking) | 11 (N-1 through N-11; 6 carried, 5 new) |

**blocking_count contribution from this artifact: 0.**

The finding set is shared across the three reaudit artifacts rather than additive. The same 0
Blocking, 0 Major, 11 Minor appear in `code-review.md` and `feature-audit.md`; they are one set
described from three angles, not three sets.

## Scope Resolution

The audit scope is the complete branch diff against the epic integration branch. The base was
resolved independently:

```
git merge-base HEAD origin/epic/claude-runtime-portability-integration
6df3766490977346cf839658f483742856a5e448
```

The branch merged the epic ref at `3081e614`, so a diff against `main` would attribute unrelated
integration commits to this feature. Diffing against the epic ref yields the feature's own change set
only.

Full branch diff: 127 files, 13963 insertions, 148 deletions. Cycle-1 delta (`9e41b9bf..HEAD`):
68 files, 7045 insertions, 5 deletions, of which 6 files are source or test:

| File | Cycle-1 change |
| --- | --- |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 1 line replaced in place (line 92) |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 1 line replaced in place (line 89) |
| both bundle mirrors of the above | same single-line replacement |
| `extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts` | line 128 expression changed; 2 comment lines added |
| `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge.test.ts` | +1 test (32 lines) |
| `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1` | +3 tests (22 lines) |
| `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` | +3 tests (22 lines) |

Changed-file language census, derived from the branch diff:

| Language | Changed files | Coverage verdict required | Verdict |
| --- | --- | --- | --- |
| PowerShell (`.ps1`) | 9 | Yes | **PASS** |
| TypeScript (`.ts`) | 4 | Yes | **PASS** |
| JavaScript config (`.cjs`) | 1 | No — Jest configuration, not production runtime code | n/a |
| Markdown (`.md`) | 113 | No — documentation and evidence | n/a |
| Python | 0 | Not applicable — zero changed files | n/a |
| C# | 0 | Not applicable — zero changed files | n/a |

## Verdict Summary

| Policy area | Verdict | Basis |
| --- | --- | --- |
| Policy reading order observed | PASS | Phase 0 evidence artifact plus direct re-verification of each rule against the diff |
| 500-line file cap | PASS | Every changed file recounted; maximum 495 lines |
| Coverage Exclusion Policy | PASS | `collectCoverageFrom` excludes only `src/**/*.d.ts` |
| Coverage thresholds — PowerShell | PASS | Re-measured 95.35 / 95.35 / 88.10 percent lines, floor 85 |
| Coverage thresholds — TypeScript | PASS | Re-measured: new module 98.79 lines / 95 branches; repo-wide 96.72 / 90.17; floors 85 / 75 |
| No regression on changed lines | PASS | Independently established; current missed-line set is a strict subset of baseline |
| Test file location | PASS | All suites in mirrored test trees; no colocation in `src/` |
| Temporary files in tests | PASS | Scan of all changed test files returned no matches |
| Determinism | PASS | New tests use synthetic path constants and scriptblock seams; `AfterEach` clears all four env vars |
| Mirror parity | PASS | Three pairs recomputed with `git hash-object` and cross-checked against the HEAD tree |
| Evidence location | PASS | `validate_evidence_locations.py --root .` exits 0; no `artifacts/{baselines,qa,evidence,coverage}/` path in the diff |
| Acceptance-criteria check-off protocol | PASS | 16 checkbox flips vs base, zero criterion-text edits; zero checkbox changes during cycle 1 |
| Tonality | PASS | 113 feature-authored Markdown files scanned; no hyperbole in use, no emoji |
| Format (PowerShell) | PASS | PoshQC format run through a capturing `WriteFile` seam: 0 files would be rewritten |
| Lint (PowerShell) | PASS | `Invoke-PoshQCAnalyze` over `.claude/hooks` and `tests/scripts/claude-hooks`: no findings |
| Format (TypeScript) | PASS | `npx prettier --check` on both push-down trees: all files conform |
| Lint (TypeScript) | PASS | `npx eslint src/lib/push-down test/lib/push-down`: exit 0, no output |
| Type check (TypeScript) | PASS | `npx tsc --noEmit`: exit 0, no output |
| Spec conformance — containment rule (was FAIL) | **PASS — closed** | Predicate re-executed against the reviewer's counterexamples; see Verification B-1 |
| Documented merge invariant — content preservation (was FAIL) | **PASS — closed** | Merge module re-executed against the reviewer's input; see Verification B-2 |
| Untested unreadable-session-id catch block (was Minor N-1a) | **PASS — closed** | Catch bodies re-measured as covered; see Verification B-3 |
| PowerShell toolchain loop (single clean consecutive pass) | PARTIAL — **non-blocking** | Two pre-existing unrelated Pester failures reproduced; see Adjudication 2 |

## Rejected Scope Narrowing

None. The delegating prompt directed a full-branch reaudit against the epic base, named the three
remediated findings for independent verification rather than ratification, and explicitly required
verdicts for every language with changed files. No instruction attempted to limit the file set, skip
a toolchain stage, or mark a language out of scope. The one instruction not to relitigate settled
context (criterion 17 and the reclassified coverage-decline finding) was accompanied by a direction to
confirm both are still accurately recorded, which is what this audit did; it is not a scope
narrowing.

## Evidence Location Compliance

```
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
EXIT=0
```

The validator exited 0 with no output. Independently, `git diff --name-only <base>...HEAD` filtered
for `^artifacts/(baselines|qa|evidence|coverage)/` returned nothing. All feature evidence is written
under `docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/<kind>/`, using
the kinds `baseline`, `issue-updates`, `other`, `qa-gates`, `regression-testing`, and
`remediation-baseline`. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose during this review.

Verdict: **PASS**.

## Independent Verification of the Three Remediated Findings

The executor's account was not accepted. Each fix was executed against the shipped code.

### Verification B-1 — prefix collision in the containment predicate

The shipped predicate now reads, identically in both hooks and both bundle mirrors:

```powershell
return ([string]::Equals($normalizedPath, $normalizedRoot, [System.StringComparison]::OrdinalIgnoreCase) -or $normalizedPath.StartsWith($normalizedRoot + '/', [System.StringComparison]::OrdinalIgnoreCase))
```

The `[string]::Equals(...)` operand is the LEFT arm of the disjunction, as required.

Both hook files were dot-sourced (the entry-point guard `if ($MyInvocation.InvocationName -eq '.')`
permits this) and `Test-PowerShellBatchBudgetPathInRoot` / `Test-PythonBatchBudgetPathInRoot` were
called directly with `root = C:/repos/wt/agent-abc`. Observed values:

| Candidate | Expected | PowerShell hook | Python hook | Case |
| --- | --- | --- | --- | --- |
| `C:/repos/wt/agent-abc/src/a.ps1` | True | **True** | **True** | genuine in-root — admitted |
| `C:/repos/wt/agent-abc-r2/src/a.ps1` | False | **False** | **False** | reviewer counterexample 1 — rejected |
| `C:/repos/wt/agent-abcdef/src/a.ps1` | False | **False** | **False** | reviewer counterexample 2 — rejected |
| `C:/repos/wt/agent-abc` | True | **True** | **True** | exact root — still admitted |
| `C:/repos/wt/agent-abc/` | True | **True** | **True** | exact root, trailing separator |
| `C:\repos\wt\agent-abc\src\a.ps1` | True | **True** | **True** | backslash normalization preserved |
| `c:/REPOS/WT/AGENT-ABC/src/a.ps1` | True | **True** | **True** | case-insensitivity preserved |
| `C:/synthetic-out-of-root/x.ps1` | False | **False** | **False** | unrelated absolute — rejected |
| `src/relative.ps1` | True | **True** | **True** | relative admission preserved |
| `` (empty) | False | **False** | **False** | null/whitespace guard preserved |

A trailing-separator root (`C:/repos/wt/agent-abc/`) was also exercised and behaves identically,
because `TrimEnd('/')` runs before the comparison.

The public decision function and the rehydrate filter were exercised separately, because the helper
is shared by both:

```
sibling decision : permission=allow shouldWriteState=False prodFiles=0
in-root decision : permission=allow shouldWriteState=True  prodFiles=1
rehydrated prodFiles (seeded with one sibling entry and one in-root entry):
  C:/repos/wt/agent-abc/src/keep.ps1
```

The sibling-prefix persisted entry was dropped at rehydrate; the in-root entry survived. Both
counterexamples are now rejected on both code paths, and no previously admitted legitimate case was
narrowed.

**Verdict: B-1 CLOSED.** Not blocking.

### Verification B-2 — unterminated managed block

`claude-gitignore-merge.ts` was compiled in isolation (`npx tsc --ignoreConfig ... --module
commonjs`, possible because the module has zero imports) and executed. On the reviewer's original
input:

```
input : "a/\n# BEGIN drm-copilot managed ignores\n.old/\nb/\nc/\n"
output: "a/\n# BEGIN drm-copilot managed ignores\n.claude/state/\n.codex/state/\n# END drm-copilot managed ignores\n.old/\nb/\nc/\n"

b/ present    = true
c/ present    = true
.old/ present = true   (retained as unmanaged content, per decision D-2)
a/ present    = true
```

`b/` and `c/` survive. The result is a fixed point (`f(f(x)) === f(x)`), and each sentinel occurs
exactly once in the output.

The function was applied twice to each of nine inputs covering every case the acceptance criteria
enumerate plus the malformed cases:

| Input | Fixed point | begin count | end count | Unchanged from input |
| --- | --- | --- | --- | --- |
| reviewer counterexample (unterminated) | yes | 1 | 1 | no |
| absent / empty string | yes | 1 | 1 | no |
| present, no block | yes | 1 | 1 | no |
| present, no trailing newline | yes | 1 | 1 | no |
| CRLF endings | yes | 1 | 1 | no |
| managed entry present outside block | yes | 1 | 1 | no |
| stale block | yes | 1 | 1 | no |
| **well-formed current block** | yes | 1 | 1 | **yes — byte-identical** |
| end sentinel preceding begin sentinel | yes | 1 | 2 | no |

The well-formed path is unchanged, which is the property the D-2 edit had to preserve and does.

The final row is recorded as advisory finding N-8 below: when the destination already carries a stray
`# END` line outside the managed block, that line is preserved as unmanaged content and the output
therefore carries two end-sentinel lines. That behaviour is correct under the module's stated
content-preservation invariant, was present before this cycle, and is a fixed point. It is not a
regression and does not block.

**Verdict: B-2 CLOSED.** Not blocking.

### Verification B-3 — untested unreadable-session-id catch block

`Get-*BatchBudgetSessionId` was called directly with a throwing `-ReadSessionIdFile` seam:

```
powershell hook resolved: 'worktree-repo-816fc349'  matchesWorktreePattern=True
python hook resolved:     'worktree-repo-816fc349'  matchesWorktreePattern=True
control (readable file):  'from-file-id'
seam throws as intended:  unreadable session-id file
```

The exception is caught, resolution falls through to the worktree-derived identifier, and nothing
propagates out of the function. The control case confirms a readable file still wins over the
worktree fallback, so the added test is not passing because the seam is ignored.

The catch bodies are now measured as covered. Independent Pester coverage re-measurement puts the
missed-line set for `.claude/hooks/enforce-powershell-batch-budget.ps1` at `{79, 89, 452, 453, 454,
457}` — lines 154 and 155, the catch bodies, are absent from it. The Python hook's missed set is the
structurally equivalent `{76, 86, 449, 450, 451, 454}`, with 151 and 152 absent.

The remediation used a per-line coverage transition rather than a failing run as the fail-before
proof, because the catch block already existed and behaved correctly; a test driving it could not
fail against the pre-remediation tree. That reasoning is recorded honestly in
`evidence/regression-testing/fail-before-exception.2026-08-29T23-07.md` and is the correct
disposition.

**Verdict: B-3 CLOSED.** Not blocking.

## Coverage Verification

Coverage artifacts were inspected first, then re-measured where the on-disk artifact did not
correspond to HEAD.

**Artifact staleness observed and worked around.** `artifacts/pester/powershell-coverage.xml`
carries the results of a single scoped run (the Python hook suite): it reports the Python hook at
123/129 covered but the PowerShell hook and `persist-session-id.ps1` at 0, and a repo-wide figure of
2.48 percent that is an artefact of scoping rather than a real repo-wide measurement.
`extensions/drm-copilot/coverage/lcov.info` corresponds to the pre-fix merge module (`LF:164`, with
`appendManagedBlock` at line 142 rather than the current 144). Neither artifact is a valid HEAD-wide
record, so both languages were re-measured. Re-measurement was directed to scratchpad output paths;
no repository artifact and no source file was modified.

### PowerShell — verdict PASS

Re-measured with Pester 5 per-suite, `CodeCoverage.Path` scoped to the single hook under test:

| File | Tests | Baseline (cov/missed) | Re-measured (cov/missed/total) | Line % | Floor 85 | Delta |
| --- | --- | --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 36/36 pass | 121 / 8 | 123 / 6 / 129 | **95.35** | met, +10.35 pp | **+1.5 pp** |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 35/35 pass | 121 / 8 | 123 / 6 / 129 | **95.35** | met, +10.35 pp | **+1.5 pp** |
| `.claude/hooks/persist-session-id.ps1` | 16/16 pass | 33 / 5 | 37 / 5 / 42 | **88.10** | met, +3.10 pp | unchanged |

Command coverage for the two batch-budget hooks is 204/214 = 95.33 percent each. The Python hook
figure of 123/6 is independently corroborated by the on-disk
`artifacts/pester/powershell-coverage.xml`, whose Python row reads `LINE cov=123 missed=6`.

The reported figures of 93.8 → 95.3 are confirmed. My re-measurement yields 95.35, which rounds to
95.3 at one decimal place; the recorded value is correct.

Pester measures command and line coverage only. Per `.claude/rules/powershell.md` and
`.claude/rules/quality-tiers.md`, no branch-coverage gate applies to PowerShell; the absence of a
branch figure is not recorded as a failure.

### No previously covered line became uncovered — verdict PASS, proven not asserted

This is the claim the directive singles out, so it was established rather than accepted.

The baseline artifact records `covered=121, missed=8` for each hook. My independent re-measurement
records `covered=123, missed=6`, with the missed set enumerated as `{79, 89, 452, 453, 454, 457}`.
The instrumented total is 129 both before and after, because the D-1 edit replaced one line in place
and the file line counts are unchanged at 457 and 454.

Suppose some previously covered line `X` had become uncovered. Then the post-change missed count
would be `8 - k + 1` where `k` is the number of previously missed lines that became covered. The
observed missed count is 6, so `k` would have to be 3. But the baseline Form D record identifies
exactly two lines per hook (154 and 155 in the PowerShell hook; 151 and 152 in the Python hook) whose
state changed, and the baseline missed set is the six lines I still observe as missed plus those two.
There is no third previously missed line available. Therefore `k = 2`, the regression term is 0, and
the current missed set is a **strict subset** of the baseline missed set. No previously covered line
became uncovered.

### TypeScript — verdict PASS

Re-measured with the repository's own Jest configuration
(`npx jest --coverage --coverageReporters=text --coverageReporters=text-summary`, coverage output
directed to scratchpad). Exit 0, `Test Suites: 203 passed, 203 total`, `Tests: 2734 passed, 2734
total`, no `coverage threshold for` line emitted.

```
File                        | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s
All files                   |   96.72 |    90.17 |   89.93 |   96.72 |
  claude-customizations.ts  |     100 |    94.59 |   66.66 |     100 | 133,198
  claude-gitignore-merge.ts |   98.79 |       95 |     100 |   98.79 | 153-154

Statements : 96.72% ( 44234/45730 )
Branches   : 90.17% ( 6297/6983 )
Lines      : 96.72% ( 44234/45730 )
```

| Scope | Lines | Floor | Branches | Floor | Verdict |
| --- | --- | --- | --- | --- | --- |
| `claude-gitignore-merge.ts` (new file) | **98.79** (from 98.78) | 85 | **95** (from 90) | 75 | PASS |
| `claude-customizations.ts` (modified) | **100** (unchanged) | 85 | **94.59** (unchanged) | 75 | PASS |
| Repo-wide `All files` | **96.72** (unchanged) | 85 | **90.17** (from 90.16) | 75 | PASS |

Every re-measured figure matches the recorded evidence exactly, including the uncovered line range
`153-154`.

**No TypeScript metric declined, established arithmetically.** The branch denominator is 6983 both
before and after; covered branches rose 6296 → 6297. A decline would require the covered count to
fall; it rose. The single additional covered branch is fully accounted for by the merge module moving
from 18/20 to 19/20 armed branches (the `endOffset === -1` arm, previously never taken), so no other
file's branch coverage moved in either direction.

The line denominator rose 45728 → 45730. This project sets `coverageProvider: "v8"`, which counts
every physical line including comments — confirmed against the stale artifact, which reports
`LF:164` for the pre-fix 164-line module. The two added comment lines therefore add exactly two
covered lines, which is the whole of the `+2 covered / +2 total` movement. The scoped post-fix lcov
independently reports `LF:166, LH:164` for the module.

The `coverageThreshold` entry for the new module is present and armed at `jest.config.cjs:213-216`
(`lines: 85, branches: 75`).

### Coverage Exclusion Policy — verdict PASS

`extensions/drm-copilot/jest.config.cjs:17`:

```js
collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts"],
```

The single negation targets `.d.ts` declaration files, which carry no executable behavior and are
expressly permitted by `.claude/rules/general-unit-test.md`. No path under `src/` containing
production runtime code is excluded. No Blocking finding arises under this policy.

## File Size Limit (500 lines)

Every changed source and test file was recounted at HEAD. All files are newline-terminated, so
`wc -l` is exact and does not undercount.

| File | Lines | Headroom | Verdict |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 457 | 43 | PASS |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 454 | 46 | PASS |
| `.claude/hooks/persist-session-id.ps1` | 164 | 336 | PASS |
| `extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts` | 166 | 334 | PASS |
| `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` | 361 | 139 | PASS |
| `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1` | **495** | **5** | PASS |
| `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` | **485** | **15** | PASS |
| `tests/scripts/claude-hooks/persist-session-id.Tests.ps1` | 242 | 258 | PASS |
| `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge.test.ts` | 177 | 323 | PASS |
| `extensions/drm-copilot/test/lib/push-down/claude-gitignore-delivery.test.ts` | 116 | 384 | PASS |

The reported 495 and 485 are confirmed exactly. The cap is not waivable and both suites are inside
it, so this is a PASS. The 5-line headroom on the PowerShell suite is recorded as advisory finding
N-11: it is not a violation, but it means the next test added to that suite will require a split or
an extraction, and that should be planned rather than discovered.

## Mirror Parity

Recomputed with `git hash-object` rather than read from any artifact, because a prior incident in
this repository produced pair-hash artifacts whose hashes matched no commit. Each object id was
additionally cross-checked against the HEAD tree via `git ls-tree`, so the hashes correspond to
committed objects and not merely to working-tree bytes.

| Pair | Object id | Working tree | HEAD tree | Verdict |
| --- | --- | --- | --- | --- |
| `enforce-powershell-batch-budget.ps1` (repo / bundle) | `bbbf70a648a68689939548d45ddbd8909ec98198` | identical | identical | **MATCH** |
| `enforce-python-batch-budget.ps1` (repo / bundle) | `858bfb116dbd42f3748d930e1fb88bf39f1368de` | identical | identical | **MATCH** |
| `persist-session-id.ps1` (repo / bundle) | `8c0d0b1d7c1501eec5919217720ab5650a6634db` | identical | identical | **MATCH** |

The first two hashes differ from the prior audit's recorded values (`d4503c77...`, `db025b9d...`),
which is expected: those files were edited by the D-1 fix. `persist-session-id.ps1` was not edited in
cycle 1 and its hash is unchanged. `git cat-file -t` confirms both new ids resolve to blobs in the
object store.

The Python resource-contract gate was executed. `.claude/state/` is absent from this worktree, which
is the fresh-checkout and CI condition the criterion names:

```
poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts" -q
1 passed in 0.11s
```

Verdict: **PASS** on both the hash comparison and the contract test.

## Vacuous-Gate Verification

Both literal gates were re-run at HEAD and their before-states reconstructed from the base revision
`6df37664` rather than from any artifact, because the production files changed in cycle 1 and a gate
verified before the edit does not carry forward.

| Search | Before (base revision) | After (HEAD, four files) | Capable of failing |
| --- | --- | --- | --- |
| `'default'` in the two hooks + two mirrors | 2 per file, 8 total | 0 in all four | Yes |
| `(Get-Location).Path` in the same four files | 1 per file, 4 total | 0 in all four | Yes |
| `Resolve-Path` / `GetFullPath` not introduced | n/a | 0 in all four | Yes |
| Corrected containment literal present | n/a | 1 in all four | Yes |
| Defective containment literal absent | 1 per file | 0 in all four | Yes |

Neither gate is vacuous, and the two containment literal gates added in cycle 1 are likewise
non-vacuous: the defective form was present in all four files at `9e41b9bf` and is absent at HEAD.

## Test Policy Compliance

- **Suite execution, re-run during this review.**
  - `PreToolUseSchema.Contract.Tests.ps1`, `enforce-powershell-batch-budget.Tests.ps1`,
    `enforce-python-batch-budget.Tests.ps1`, `persist-session-id.Tests.ps1`: **102 total, 102 passed,
    0 failed, 0 skipped** (prior audit recorded 96; the +6 is the three tests added to each hook
    suite).
  - Full `extensions/drm-copilot/test/lib/push-down/` directory: **235 passed, 235 total** (prior
    audit recorded 234; the +1 is the merge regression test). No regression in the surrounding
    push-down suites.
  - Full Jest run: 203 suites, 2734 tests, all passing.
- **Temporary files.** None. A scan of all changed test files for `TestDrive`, `New-TemporaryFile`,
  `GetTempPath`, `$env:TEMP`, `os.tmpdir`, and `mkdtemp` returned no matches. The three new PowerShell
  tests use synthetic path constants (`/repo`, `/repo-sibling`) that are never touched on disk.
- **Test file location.** Unchanged and correct. PowerShell suites under `tests/scripts/claude-hooks/`
  mirror `.claude/hooks/`; TypeScript suites under `extensions/drm-copilot/test/lib/push-down/`
  mirror `src/lib/push-down/`. No test file exists in a production source tree.
- **Determinism and order-independence.** The B-3 test assigns `$env:CLAUDE_SESSION_ID = ''`. The
  Describe-level `AfterEach` at line 32 clears `CLAUDE_TOOL_INPUT`, `CLAUDE_SESSION_ID`,
  `CLAUDE_POWERSHELL_BUDGET_PROD`, and `CLAUDE_POWERSHELL_BUDGET_TEST`, so the assignment does not
  leak. No `Start-Sleep`, `setTimeout`, `Date.now`, RNG, retry, or network call is introduced.
- **Mocking rules.** No external executable is mocked. The new tests drive the existing
  `ReadSessionIdFile` scriptblock seam, matching the "Design Seams (Minimal DI)" guidance in
  `.claude/rules/powershell.md`.

## Toolchain Loop

Re-executed independently, in policy order, non-mutatingly where the repository tool is write-mode.

| Stage | Command | Result |
| --- | --- | --- |
| 1. Format (PowerShell) | `Invoke-PoshQCFormat` with a capturing `WriteFile` seam over `.claude/hooks`, `tests/scripts/claude-hooks`, and the bundle hooks | **0 files would be rewritten**; tree clean after |
| 1. Format (TypeScript) | `npx prettier --check "src/lib/push-down/**/*.ts" "test/lib/push-down/**/*.ts"` | "All matched files use Prettier code style!" |
| 2. Lint (PowerShell) | `Invoke-PoshQCAnalyze -ScanFolders '.claude/hooks','tests/scripts/claude-hooks'` | "PSScriptAnalyzer passed: no findings" |
| 2. Lint (TypeScript) | `npx eslint src/lib/push-down test/lib/push-down` | exit 0, no output |
| 3. Type check | `npx tsc --noEmit` | exit 0, no output |
| 4. Architecture-boundary | not run — see note | n/a for this repository |
| 5. Unit tests (PowerShell) | four hook suites | 102/102 |
| 5. Unit tests (TypeScript) | full Jest run | 2734/2734 |
| 6. Contract / schema | `PreToolUseSchema.Contract.Tests.ps1`; `test_bundled_claude_payload_contains_all_repo_runtime_contracts` | both pass |
| 7. Integration | `claude-gitignore-delivery.test.ts` through `InMemoryPushDownFileSystem`; full push-down directory | 235/235 |

**Note on stage 4.** `dependency-cruiser` is not installed and no `.dependency-cruiser.cjs` exists in
`extensions/drm-copilot`; `npx depcruise` falls through to a registry fetch. There is therefore no
architecture-boundary check to run in this repository. This is a repository-level condition that
predates the feature and is not attributable to it. The evidence artifact named
`typescript-dependency-tree.*` is a dependency-presence guard for `node_modules/.bin/tsc`, not an
architecture check; it is correctly titled and does not overclaim.

The format check was run in a genuinely non-mutating form. `Invoke-PoshQCFormat` is write-mode and
its exit code is identical on a clean run and a repairing run, so the exported `-WriteFile` seam was
replaced with a collector. The collector recorded zero paths, which is a positive signal rather than
an absence of one, and `git status --porcelain` was empty immediately afterwards.

Verdict: **PARTIAL, non-blocking.** Every stage that can be executed against this feature passes. The
unscoped PoshQC test stage cannot pass in this worktree for reasons external to the feature; see
Adjudication 2.

## Tonality

`.claude/rules/tonality.md` compliance across all 113 feature-authored Markdown files in the branch
diff, including the cycle-1 remediation plan, the remediation-decisions record, and every new
evidence artifact:

- Hyperbole vocabulary scan (20 terms including `amazing`, `flawless`, `revolutionary`, `seamless`,
  `bulletproof`, `perfect`, `effortless`, `game-changing`): **one match**, at
  `audit/2026-08-29T23-07/policy-audit.md:244`, which is the prior audit naming the terms it scanned
  for. That is a mention, not a use. No hyperbole is used anywhere in the corpus.
- Pictographic emoji scan (`U+1F300`–`U+1FAFF`, `U+2705`, `U+274C`, `U+2728`, `U+26A0`,
  `U+1F600`–`U+1F64F`): **no matches**.
- Full non-ASCII inventory: `—` (557), `→` (27), `…` (6), `›` (5), `●` (4), `≤` (4), `–` (4), `≥` (2),
  `✖` (1), `↵` (1). Every occurrence of `›`, `●`, `✖`, and `↵` was located and each is inside a
  verbatim quotation of Jest or ESLint console output. The arrows and mathematical operators are
  technical notation in arithmetic derivations and stage orderings. None is decorative.
- The cycle-1 artifacts state adverse and limiting results directly — "Not addressed, and out of
  scope", "N-1 is therefore reported as PARTIAL, not as unaddressed and not as complete", "a failing
  run is structurally impossible" — without dramatizing or softening them. The
  remediation-reconciliation artifact declines to claim N-1 as delivered, which is the harder and
  more accurate statement.

This audit's own artifacts were written to the same standard.

Verdict: **PASS**.

## Referred Adjudications

### Adjudication 1 — the prior coverage-decline finding is now CLOSED, not carried

The prior audit reclassified the two per-file PowerShell coverage declines from Blocking to Minor,
reasoning from the policy text that the repository gate is a changed-lines gate
(`.claude/rules/general-unit-test.md`: "must not reduce coverage for **the lines that were
changed**") rather than a file-percentage gate.

That reasoning was correct and is unaffected by anything in cycle 1. It is now also moot: both files
have risen from 93.8 to 95.35 percent, above their pre-feature baseline of 95.6 percent minus the
denominator growth, and above the 85 percent floor by 10.35 points. There is no decline left to
adjudicate.

**Disposition: closed, not carried forward.** The directive's instruction on this point is confirmed
accurate.

### Adjudication 2 — the unmet PoshQC criterion (spec line 773)

**Independent conclusion: the pre-existing claim is RE-CONFIRMED at HEAD. Leaving the criterion
unchecked remains the correct disposition, and this PARTIAL is non-blocking.**

The claim was re-verified rather than carried, because the tree changed since the prior audit.

**(a) Both failures reproduce at `a7d4dd27`.** Running only the two owning suites:

```
TOTAL=49 PASSED=47 FAILED=2
FAILED: enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
FAILED: Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
```

Both names are byte-identical to the pair recorded at the prior audit and in the Phase 0 baseline.
The counts are identical (49/47/2), so cycle 1 neither introduced nor repaired anything here.

**(b) Neither owning suite nor its subject is in the branch diff.**
`git diff --name-only <base>...HEAD` filtered for `pr-author`, `codex`, and `wave-barrier` returns
nothing (grep exit 1). The branch does not touch either suite, `enforce-pr-author-skill.ps1`,
`enforce-epic-wave-barrier.ps1`, or the Codex handler registry.

**(c) The recorded root cause holds.** The prior audit established that the second failure is
produced by `enforce-epic-wave-barrier.ps1` denying a benign payload because the ambient epic
checkpoint records issue 596 itself as carrying unmerged `depends_on` edges:

```
EPIC_WAVE_BARRIER_BLOCKED: '596' cannot mutate until every depends_on edge is
merged or worktree_removed in the epic checkpoint.
```

That is orchestration context, not feature code. The criterion is unsatisfiable from inside this epic
worktree regardless of the feature's correctness, and resolves on merge or in a fresh checkout where
no epic checkpoint is present.

**Why this PARTIAL does not contribute to `blocking_count`.** The criterion is compound. Its coverage
half is satisfied — all three hooks clear 85 percent, at 95.35, 95.35, and 88.10. Its toolchain half
is blocked by two failures in suites this feature neither owns nor touches, one of which names this
very issue as its blocking condition. Every stage of the loop that is within the feature's control
passes. Treating this as blocking would make the feature unmergeable by a condition that only merging
can clear.

### Adjudication 3 — the cycle-1 test additions are non-vacuous

Each of the three tests added per hook suite was assessed for whether it can fail.

1. `discards an absolute candidate path in a sibling directory whose name extends the root` — the
   fixture is `/repo-sibling/scripts/tool.ps1`, a `.ps1` path, so it passes the scope filter and
   genuinely reaches the containment check. Against the pre-fix predicate it yields
   `shouldWriteState = $true`, failing the first assertion. The fail-before artifact records exactly
   that: `Expected $false, but got $true` at suite line 437, one failing test, 35 passing.
   **Capable of failing — confirmed by the recorded run and by the defect's own mechanics.**
2. `admits a candidate path that is exactly the resolved root` — passes both before and after, by
   design. Its purpose is to prevent the D-1 edit from narrowing behaviour, and it would fail against
   the naive fix (`StartsWith($root + '/')` alone) that the spec's literal text would produce. The
   remediation record states plainly that it is not tagged `[expect-fail]` and why.
   **Capable of failing against the plausible wrong fix — correctly not tagged.**
3. `falls through to the worktree-derived id when the session-id file is unreadable` — passes both
   before and after, because the catch block already existed. Its value is the coverage transition,
   and the fail-before exception dossier says so explicitly rather than manufacturing a failure.
   **Correctly dispositioned; the alternative proof was independently verified above.**

The B-2 merge test is likewise proven capable of failing: the recorded fail-before run reports
`Tests: 1 failed, 7 passed, 8 total` with the correct title, and the seven pre-existing tests passing
unchanged confirms the edit did not alter the well-formed path.

## Findings

### Blocking

**None.**

### Major

**None.** Both prior Major findings are closed and were verified by execution, not by reading.

### Minor (advisory, non-blocking)

Six findings carried from the prior audit, four new observations from this cycle, and one line-count
observation.

**N-1 — PARTIAL: two guard branches in `Test-*BatchBudgetPathInRoot` remain uncovered.**
The highest-value component of N-1, the unreadable-session-id catch block, is **closed** (B-3).
Independently re-measured, the remaining uncovered lines in each hook are the null-or-whitespace path
guard (line 79 / 76) and the empty-root guard (line 89 / 86), plus four entry-point dispatch lines.
The empty-root guard is a fail-open branch: I confirmed by execution that an empty `$Root` admits
`C:/anything/x.ps1`. It is unreachable in production because `$Root` defaults to a
`$PSScriptRoot`-derived ascent. Correctly recorded as PARTIAL in the reconciliation artifact — neither
overclaimed nor understated. Remains advisory.

**N-2 — `codex-pretooluse-integration.Tests.ps1` depends on ambient epic-checkpoint state.**
Re-confirmed at HEAD. Pre-existing, not owned by this feature, contravenes the Deterministic Test
Requirements in `.claude/rules/powershell.md`. Correctly dispositioned as out of scope. Should be
filed as a separate issue; it blocks the unscoped Pester run for every feature in this epic. **Has not
become blocking** — it is external to the branch diff and resolves on merge.

**N-3 — Duplicated state-write logic across both branches of the `persist-session-id.ps1` switch.**
Verified unchanged: `.claude/hooks/persist-session-id.ps1` was not edited in cycle 1. Lines 105-115
and 117-123 perform the same `EnsureDirectory` + `WriteStateFile` sequence. Behaviorally correct;
a DRY observation only. Correctly dispositioned as out of scope.

**N-4 — Spec Test Strategy checkboxes remain unchecked although the work is delivered.**
Verified unchanged: `spec.md` lines 591-593 still carry three `- [ ]` items. They sit under
`## Test Strategy`, not `## Acceptance Criteria`, and the section-scoped counter confirms the AC total
is 17 and excludes them. Correctly dispositioned as out of scope and left as found.

**N-5 — The `!`-negation edge case listed at `spec.md:630` is not tested.**
Verified unchanged: a scan of `claude-gitignore-merge.test.ts` for `!`-negation cases returns nothing.
The behavior is correct by inspection — content outside the block is not reordered — and my
nine-input execution confirmed ordering preservation on every input. Correctly dispositioned as out
of scope.

**N-6 — `appendManagedBlock` trailing-blank-removal loop is uncovered.**
Verified: the module's only uncovered lines are now `153-154`, the same two statements the baseline
reported as `151-152`, displaced by the two comment lines the D-2 edit added above them. The
reconciliation artifact states exactly this. Low risk. Correctly dispositioned as out of scope.

**N-7 (new) — the prefix-sibling case has no dedicated rehydrate-path test.**
The containment helper is shared by the decision path and by `ConvertTo-*BatchBudgetState`. Cycle 1
added a sibling-prefix test on the decision path only. I verified the rehydrate path by direct
execution — a seeded `/repo-sibling/...` entry is dropped while an in-root entry survives — so the
behaviour is correct and proven, but it is unpinned by a test. Low risk, because a single shared
helper makes divergence unlikely.

**N-8 (new) — a stray end sentinel outside the managed block is preserved, so sentinel uniqueness is
not universal.** On input whose end sentinel precedes its begin sentinel, the output carries two
`# END` lines: the managed block's own closer and the stray line, preserved as unmanaged content. The
result is still a fixed point and still carries exactly one begin sentinel. This behaviour predates
cycle 1 and is correct under the module's content-preservation invariant — a stray comment line is
inert to git, and deleting unmanaged content is precisely the defect B-2 fixed. Recorded for accuracy
because the merge test asserts "each sentinel occurs exactly once" on inputs it controls, and that
property is conditional rather than universal.

**N-9 (new) — `claude-customizations.ts` carries no `coverageThreshold` entry although it is a
changed file.** `jest.config.cjs` uses per-changed-file thresholds with no `global` key, and its own
comment notes that a file without an entry is "completely ungated". The modified file measures 100
percent lines and 94.59 percent branches, clearing both policy floors with margin, so no threshold in
force is violated. The observation is that the gate is not armed for it, not that coverage is
inadequate.

**N-10 (new) — the containment predicate is a single 177-character line.** The remediation record
states the reason: a single-line in-place replacement keeps the file at 457 and 454 lines so the
absolute line numbers 154/155 and 151/152 in the B-3 per-line coverage evidence stay valid between
the baseline and final captures. That is a real and well-reasoned constraint, and it was correct for
this cycle. No line-length rule is in force — `pssa.settings.psd1` sets no such rule, and the file
already contains a 322-character pre-existing line — so this is not a violation. It is worth noting
that the constraint that produced it was specific to this remediation's evidence model and does not
bind future edits.

**N-11 (new) — `enforce-powershell-batch-budget.Tests.ps1` has 5 lines of headroom against the
500-line cap.** 495 of 500, confirmed by recount. Inside the cap and therefore a PASS. The next test
added to this suite will not fit, so a split or a shared-helper extraction should be planned before
the next change to it rather than discovered during one. The Python sibling has 15 lines.

## Assumptions Recorded

1. `artifacts/pester/powershell-coverage.xml` and `extensions/drm-copilot/coverage/lcov.info` were
   found not to correspond to HEAD. Rather than trust them, both languages were re-measured with
   output directed to scratchpad paths. No repository artifact and no source file was modified by this
   review; `git status --porcelain` was empty before and after.
2. PoshQC's format command is write-mode only. It was executed through its exported `WriteFile` seam
   with a collector substituted, which yields the same information without mutating the tree.
3. Architecture-boundary tooling is absent from this repository. That stage is recorded as
   not-applicable-to-repository with the reason stated, not as a feature finding.
