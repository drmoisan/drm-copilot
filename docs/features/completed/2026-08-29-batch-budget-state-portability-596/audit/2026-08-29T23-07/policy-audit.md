# Policy Audit — Feature B: Batch-budget state portability (issue #596)

- Timestamp: 2026-08-29T23-07
- Reviewer: feature-review agent
- Worktree: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5`
- Branch: `feature/batch-budget-state-portability-596` at `9e41b9bf`
- Base: `origin/epic/claude-runtime-portability-integration` (merge-base `6df37664`)
- Work mode: `full-bug` — `spec.md` is the sole acceptance-criteria source
- Scope: full branch diff against the resolved base; 67 files, 6923 insertions, 148 deletions

## Scope Resolution

The audit scope is the complete branch diff against the epic integration branch. The base was
resolved independently:

```
git merge-base HEAD origin/epic/claude-runtime-portability-integration
6df3766490977346cf839658f483742856a5e448
```

The branch merged the epic ref at `3081e614`, so a diff against `main` would attribute unrelated
integration commits to this feature. Diffing against the epic ref yields the feature's own change
set only. No caller instruction attempted to narrow scope below this, so there is no
`## Rejected Scope Narrowing` content to record.

Changed-file language census, derived from the branch diff:

| Language | Changed files | Coverage verdict required |
| --- | --- | --- |
| PowerShell (`.ps1`) | 9 | Yes |
| TypeScript (`.ts`) | 4 | Yes |
| JavaScript config (`.cjs`) | 1 | No — Jest configuration, not production runtime code |
| Markdown (`.md`) | 53 | No — documentation and evidence |
| Python | 0 | Not applicable — zero changed files |
| C# | 0 | Not applicable — zero changed files |

## Verdict Summary

| Policy area | Verdict | Basis |
| --- | --- | --- |
| Policy reading order observed | PASS | Phase 0 evidence artifact plus direct re-verification of each rule against the diff |
| 500-line file cap | PASS | Every changed file measured; maximum 473 lines |
| Coverage Exclusion Policy | PASS | `collectCoverageFrom` excludes only `src/**/*.d.ts` |
| Coverage thresholds — PowerShell | PASS | 93.8 / 93.8 / 88.1 percent lines, floor 85 |
| Coverage thresholds — TypeScript | PASS | New module 98.78 lines / 90 branches, floors 85 / 75 |
| No regression on changed lines | PASS | No previously covered line became uncovered; see Adjudication 1 |
| Test file location | PASS | All suites in mirrored test trees; no colocation in `src/` |
| Temporary files in tests | PASS | None; PowerShell suites use scriptblock seams, Jest suites use the in-memory adapter |
| Determinism | PASS (feature code) | No wall-clock, RNG, sleep, or network use introduced |
| Mirror parity | PASS | Three pairs verified by `git hash-object` |
| Evidence location | PASS | All evidence under `<FEATURE>/evidence/<kind>/`; nothing under `artifacts/` |
| Acceptance-criteria check-off protocol | PASS | 16 checkbox flips, zero criterion-text edits |
| Tonality | PASS | No hyperbole, no emoji, no humor in feature-authored Markdown |
| Spec conformance — containment rule | **FAIL** | Implementation omits the trailing separator the spec pins; see Finding B-1 |
| Documented merge invariant — content preservation | **FAIL** | Malformed-block path deletes destination content; see Finding B-2 |
| PowerShell toolchain loop (single clean consecutive pass) | PARTIAL | Two pre-existing unrelated Pester failures; see Adjudication 2 |

Findings: **0 Blocking, 2 Major, 6 Minor.**

## Evidence Location Compliance

`git diff --name-only <base>...HEAD` contains no path under `artifacts/baselines/`, `artifacts/qa/`,
`artifacts/evidence/`, or `artifacts/coverage/`. All feature evidence is written under
`docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/<kind>/`, using the
kinds `baseline`, `issue-updates`, `other`, `qa-gates`, and `regression-testing`. No
`EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose during this review.

Verdict: **PASS**.

## Coverage Verification

Coverage was verified from existing artifacts and, where the artifact could be independently
re-derived cheaply without mutating the tree, by direct re-measurement. Coverage generation was not
re-run for PowerShell.

### PowerShell — verdict PASS

Artifact `artifacts/pester/powershell-coverage.xml` is present. Counts recorded in
`evidence/qa-gates/powershell-test-coverage-final.2026-08-29T16-05.md` and cross-checked against the
Phase 0 baseline artifact:

| File | Baseline (cov/total) | Post-change (cov/total) | Line % | Floor 85 | Delta |
| --- | --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 86/90 = 95.6 | 121/129 | **93.8** | met, +8.8 pp | -1.8 pp |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 86/90 = 95.6 | 121/129 | **93.8** | met, +8.8 pp | -1.8 pp |
| `.claude/hooks/persist-session-id.ps1` | 33/38 = 86.8 | 37/42 | **88.1** | met, +3.1 pp | +1.3 pp |
| Repository-wide | 7236/7639 = 94.7 | 7384/7795 | **94.7** | met, +9.7 pp | +0.004 pp |

Pester measures command and line coverage only. Per `.claude/rules/powershell.md` and
`.claude/rules/quality-tiers.md`, no branch-coverage gate applies to PowerShell; the absence of a
branch figure is not recorded as a failure.

The two per-file declines are adjudicated in Adjudication 1 below. They are **not** a regression on
changed lines and do not fail this gate.

### TypeScript — verdict PASS

Artifact `extensions/drm-copilot/coverage/lcov.info` is present. The new-file figure was
independently re-measured during this review rather than read from the artifact alone:

```
npx jest test/lib/push-down/ --coverage \
  --collectCoverageFrom="src/lib/push-down/claude-gitignore-merge.ts" --coverageThreshold='{}'

File                       | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s
 claude-gitignore-merge.ts |   98.78 |       90 |     100 |   98.78 | 151-152
```

| Scope | Lines | Floor | Branches | Floor | Verdict |
| --- | --- | --- | --- | --- | --- |
| `claude-gitignore-merge.ts` (new file) | **98.78** | 85 | **90** | 75 | PASS |
| `claude-customizations.ts` (modified) | 100 (unchanged) | 85 | 94.59 (from 93.93) | 75 | PASS |
| Repo-wide `All files` | 96.72 (from 96.71) | 85 | 90.16 (from 90.15) | 75 | PASS |

The re-measured figures match the recorded evidence exactly, including the uncovered line numbers.
No TypeScript figure declined. The `coverageThreshold` entry added for the new module was confirmed
present in `extensions/drm-copilot/jest.config.cjs` and armed.

### Coverage Exclusion Policy — verdict PASS

`extensions/drm-copilot/jest.config.cjs` line 17 declares:

```js
collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts"],
```

The single negation targets `.d.ts` declaration files, which carry no executable behavior and are
expressly permitted by `.claude/rules/general-unit-test.md`. No path under `src/` containing
production runtime code is excluded. The three `coverageThreshold` comments at lines 96, 176, and 265
each state explicitly that the file concerned remains inside `collectCoverageFrom` and is exempted
only from a threshold, not from measurement. This is the correct posture. No Blocking finding arises
under this policy.

## File Size Limit (500 lines)

| File | Lines | Verdict |
| --- | --- | --- |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 457 | PASS |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 454 | PASS |
| `.claude/hooks/persist-session-id.ps1` | 164 | PASS |
| `extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts` | 164 | PASS |
| `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` | 361 | PASS |
| `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1` | 473 | PASS (27 lines headroom) |
| `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` | 463 | PASS (37 lines headroom) |
| `tests/scripts/claude-hooks/persist-session-id.Tests.ps1` | 242 | PASS |
| `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge.test.ts` | 145 | PASS |
| `extensions/drm-copilot/test/lib/push-down/claude-gitignore-delivery.test.ts` | 116 | PASS |

The decision to place the end-to-end delivery cases in a new sibling suite rather than extend
`claude-config-carriage.test.ts` is documented in the new suite's header and is consistent with the
cap. Both hook production files grew substantially (284 to 457, 281 to 454) but remain inside the
cap; the spec's reasoning for not extracting a shared `.claude/lib/**` module is recorded and sound.

## Mirror Parity

Verified directly with `git hash-object` rather than by reading recorded values, because a prior
incident in this repository produced pair-hash artifacts whose hashes matched no commit.

| Pair | Object id | Verdict |
| --- | --- | --- |
| `enforce-powershell-batch-budget.ps1` (repo / bundle) | `d4503c778bace2d206bbaa356101ee34481446fa` | MATCH |
| `enforce-python-batch-budget.ps1` (repo / bundle) | `db025b9d50826c8ade88d38dd9a651afcaef66d4` | MATCH |
| `persist-session-id.ps1` (repo / bundle) | `8c0d0b1d7c1501eec5919217720ab5650a6634db` | MATCH |

The Python resource-contract gate was additionally executed. `.claude/state/` is absent from this
worktree, which is the fresh-checkout and CI condition the criterion names:

```
poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts" -q
1 passed in 0.10s
```

Verdict: **PASS** on both the hash comparison and the contract test.

## Vacuous-Gate Verification

Two acceptance criteria are searches that pass by returning nothing. Each was checked for a non-zero
before-state reconstructed from the base revision itself, not from a recorded artifact.

| Search | Before (base revision) | After (HEAD) | Capable of failing |
| --- | --- | --- | --- |
| `'default'` in the two hooks + two mirrors | 2 per file, 8 total | 0 in all four | Yes |
| `(Get-Location).Path` in the same four files | 1 per file, 4 total | 0 in all four | Yes |
| `Resolve-Path` / `GetFullPath` not introduced | n/a | 0 in both hooks | Yes |

The base-revision lines were read directly:

```
157:        [string] $SessionId = 'default',
158:        [string] $Root = (Get-Location).Path,
250:        $sessionId = 'default'
```

This matches the spec's stated before-state exactly (2 `'default'` matches per file, 1
`(Get-Location).Path` match per file). Neither gate is vacuous.

## Test Policy Compliance

- **Temporary files.** None. A scan of all five changed or new test files for `TestDrive`,
  `New-TemporaryFile`, `GetTempPath`, `os.tmpdir`, `mkdtemp`, and `$env:TEMP` returned no matches.
  The `Set-Content` and `New-Item` occurrences in `persist-session-id.Tests.ps1` are Pester `Mock`
  registrations and `Should -Invoke` assertions, not real writes. Jest suites use
  `InMemoryPushDownFileSystem` throughout.
- **Test file location.** PowerShell suites live under `tests/scripts/claude-hooks/`, mirroring
  `.claude/hooks/`. TypeScript suites live under `extensions/drm-copilot/test/lib/push-down/`,
  mirroring `src/lib/push-down/`. No test file was created inside a production source tree.
- **Arrange-Act-Assert.** Both new Jest suites use explicit `// Arrange`, `// Act`, `// Assert`
  comments. The PowerShell suites follow the established arrange/act/assert shape without comment
  markers, consistent with the surrounding suites.
- **Determinism.** No `setTimeout`, `Date.now`, `Math.random`, `Start-Sleep`, retry, or network call
  is introduced. The PowerShell suites mutate `$env:CLAUDE_SESSION_ID` and reset it in `AfterEach`;
  that variable is the mechanism under test, and the reset makes the suites order-independent.
- **Mocking rules.** No external executable is mocked. The hooks expose scriptblock seams
  (`ReadSessionIdFile`, `TestPathExists`, `EnsureDirectory`, `ReadState`, `WriteState`) and the tests
  drive those seams, which matches the "Design Seams (Minimal DI)" guidance in
  `.claude/rules/powershell.md`.
- **Suite execution.** Independently re-run during this review:
  - `enforce-powershell-batch-budget.Tests.ps1`, `enforce-python-batch-budget.Tests.ps1`,
    `persist-session-id.Tests.ps1`, `PreToolUseSchema.Contract.Tests.ps1`: 96 total, 96 passed,
    0 failed, 0 skipped.
  - `claude-gitignore-merge.test.ts` and `claude-gitignore-delivery.test.ts`: 11 passed, 11 total.
  - Full `test/lib/push-down/` directory: 234 passed, 234 total — no regression in the surrounding
    push-down suites.

## Toolchain Loop

`evidence/qa-gates/toolchain-loop-convergence.2026-08-29T16-05.md` records two iterations and states
plainly that the loop did **not** fully converge. Iteration 1 restarted because
`npx prettier --write` rewrote `claude-gitignore-merge.ts`; the restart was detected by paired
`git status --porcelain` captures rather than the exit code, which was 0 either way. That detection
method is correct and is the reason a real formatting drift was not recorded as a clean pass.

Iteration 2 ran every stage cleanly except the two unscoped PowerShell test stages, which exit 2 on
two pre-existing failures. Those failures are adjudicated in Adjudication 2. The convergence artifact
records the task as NOT MET rather than checking it off, which is the honest disposition.

Verdict: **PARTIAL**. The feature's own code passes every stage; the single consecutive clean run
required by the criterion is unattainable in this worktree for reasons external to the feature.

## Tonality

`.claude/rules/tonality.md` compliance across all 53 feature-authored Markdown files:

- Hyperbole vocabulary scan (`amazing`, `flawless`, `revolutionary`, `seamless`, `bulletproof`, and
  eleven further terms): no matches.
- Pictographic emoji scan (`U+1F300`–`U+1FAFF`, `U+2705`, `U+274C`, `U+2728`): no matches.
- The only non-ASCII symbol present anywhere in the feature documents is `→` (U+2192), used as
  technical notation in arithmetic derivations (`100 * 86 / 90 = 95.5556 → 95.6`) and in toolchain
  stage ordering (`format → lint → test`). This is utilitarian notation, not decorative styling, and
  is compliant.
- The evidence artifacts state adverse results directly — "The loop did NOT fully converge",
  "decline of 1.8 percentage points ... stated rather than rounded away" — without dramatizing or
  softening them. This matches the Evidence-First Wording and Difficult Messages sections.

Verdict: **PASS**.

## Referred Adjudications

### Adjudication 1 — the two per-file coverage declines

**Independent conclusion: this should NOT block. Classified Minor, not Blocking.**

I disagree with the plan's classification, and I reach that conclusion from the policy text rather
than from the margin.

The repository gate is worded as a changed-lines gate, not a file-percentage gate:

- `.claude/rules/general-unit-test.md`: "Code changes or refactors must not reduce coverage for **the
  lines that were changed**."
- `.claude/rules/powershell.md`: "Coverage regression **on changed lines** is a blocking finding."

Applying that gate to the recorded counts:

| File | Covered | Missed | Total |
| --- | --- | --- | --- |
| Baseline | 86 | 4 | 90 |
| Post-change | 121 | 8 | 129 |

Covered lines rose by 35. Missed lines rose by 4, and the denominator rose by 39. For a previously
covered line to have regressed, the covered count would have to fall; it rose. The four additional
missed lines are all **newly added** lines, not previously covered lines that lost coverage.
Therefore **there is no regression on changed lines**, and the changed-lines gate is met. The per-file
percentage fell purely because the denominator grew faster than the covered count — an arithmetic
consequence of adding 39 measured lines to a file that was already at 95.6 percent.

Both files sit at 93.8 percent against an 85 percent floor, and repository-wide PowerShell line
coverage is unchanged at 94.7 percent. No threshold in force is violated at any scope.

The plan's own text classifies any negative per-file delta as blocking. That is stricter than
repository policy. A plan may impose a stricter internal check, but it cannot create a merge gate
that policy does not, and the correct response is the one taken: report the delta honestly rather
than round it away. The reporting was accurate and complete.

**Are the changed lines covered?** Substantially yes. 121 of 129 measured lines in each hook are
covered, and every behavior named in the acceptance criteria — session-source precedence,
sanitization, containment admission and discard, the rehydrate filter, cap boundary, deny-envelope
shape — is exercised by a passing test that I re-ran.

**Do the four uncovered lines represent untested critical behavior?** Not critical, but two of them
deserve a test. I inspected each:

1. `Test-*BatchBudgetPathInRoot` null/whitespace-path guard (returns `$false`). Trivial and
   defensive; reachable only from a corrupted persisted state containing an empty entry. Low value.
2. `Test-*BatchBudgetPathInRoot` empty-root guard (returns `$true`). This one **fails open** — an
   empty `$Root` admits every candidate path. It is unreachable in production because `$Root`
   defaults to a `$PSScriptRoot`-derived ascent, but an untested fail-open branch in a control hook
   is worth pinning. Recommended, not blocking.
3. The `Get-*BatchBudgetSessionId` unreadable-session-id catch block. This is the one I would
   prioritize: `spec.md` line 623 explicitly enumerates "`.claude/state/current-session-id`
   unreadable: falls through without throwing" in its own Test Strategy edge-case list, and no test
   drives `ReadSessionIdFile` to throw. I confirmed this by scanning both suites — every
   `-ReadSessionIdFile` seam returns a value; none throws. Without the catch, an unreadable file
   would propagate out of a PreToolUse hook and produce a non-zero exit, which the spec itself
   identifies as a fail-open. The protection is real and untested.

**Feasibility against the 500-line cap.** `enforce-powershell-batch-budget.Tests.ps1` is 473 lines,
leaving 27; the Python sibling is 463, leaving 37. One throwing-seam test is roughly 12 lines, so a
single test fits in each file without restructuring. The cap is a real constraint but not a blocker
for the recommended addition.

Recorded as Finding N-1.

### Adjudication 2 — the unmet PoshQC criterion (spec line 773)

**Independent conclusion: the pre-existing claim is CONFIRMED. Leaving the criterion unchecked is
the correct disposition.**

I verified the claim rather than accepting it, using four independent lines of evidence.

**(a) I reproduced both failures at HEAD.** Running only the two owning suites:

```
TOTAL=49 PASSED=47 FAILED=2
FAILED: enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
FAILED: Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
```

Both names are byte-identical to the pair recorded in the Phase 0 baseline artifact.

**(b) Neither owning suite nor its subject is in the branch diff.** `git diff --name-only <base>...HEAD`
filtered for `pr-author` and `codex` returns nothing. The branch does not touch
`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`,
`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`, `enforce-pr-author-skill.ps1`,
`enforce-epic-wave-barrier.ps1`, or the Codex handler registry. The branch therefore could not have
introduced either failure.

**(c) The failure count held at 2 across a rising discovery count.** Baseline recorded
`root=Pester tests=3851 failures=2`; the final run recorded `root=Pester tests=3904 failures=2`. 53
tests were added and no new failure appeared.

**(d) An additional observation not in the orchestrator's report.** I inspected the failure reason
for the second test, which the recorded evidence does not carry:

```
Expected $null or empty, because every registered handler must allow a benign admitted payload,
but got 'enforce-epic-wave-barrier.ps1 x Bash: exit=0
stdout=[{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny",
"permissionDecisionReason":"EPIC_WAVE_BARRIER_BLOCKED: '596' cannot mutate until every depends_on
edge is merged or worktree_removed in the epic checkpoint."}}]
```

The failure is produced by `enforce-epic-wave-barrier.ps1` reading the **ambient epic checkpoint**,
which currently records issue 596 as having unmerged `depends_on` edges. The cause is orchestration
context, not feature code and not the Codex handler registry. Two consequences follow:

1. This criterion is **unsatisfiable from inside this epic worktree** regardless of how correct the
   feature is. It should clear once the epic checkpoint advances, and in a fresh checkout or CI run
   where no epic checkpoint is present. That materially strengthens the case for leaving the
   criterion unchecked rather than treating it as a feature defect.
2. `codex-pretooluse-integration.Tests.ps1` depends on mutable ambient state outside its own
   fixtures, which contravenes the Deterministic Test Requirements in `.claude/rules/powershell.md`
   ("Tests must not depend on ... mutable machine PATH or profile state"). This is a **pre-existing
   defect in a suite this feature does not own** and is out of scope here, but it should be filed
   separately. Recorded as Finding N-2.

The coverage half of this compound criterion is satisfied (all three hooks clear 85 percent). The
toolchain half is not. Leaving the checkbox unchecked is correct; checking it would be false.

### Adjudication 3 — the fixture-constant variation

**Independent conclusion: the reasoning is CORRECT, verified against both the current and the base
revision. The resulting test can genuinely fail. I agree with the disposition.**

**The reasoning is correct.** In `Invoke-PowerShellBatchBudgetDecision` the scope filter runs *before*
the containment check:

```powershell
$normalized = $FilePath -replace '\\', '/'
if ($normalized -notmatch '\.(ps1|psm1|psd1)$') {
    return [ordered]@{ ... permissionDecision = 'allow' ... ; shouldWriteState = $false }   # line 273-275
}

if (-not (Test-PowerShellBatchBudgetPathInRoot -Path $normalized -Root $Root)) {              # line 279
    ...
    return [ordered]@{ ... permissionDecision = 'allow' ... ; shouldWriteState = $false }
}
```

A `.py` candidate returns at line 274 with `permissionDecision = 'allow'` and
`shouldWriteState = $false` — the exact two values the out-of-root test asserts — without
`Test-PowerShellBatchBudgetPathInRoot` ever being called. The test would pass on code that has no
containment check at all. The justification is sound.

**The test can actually fail.** I read the base revision of the function. It has no `-Root`
parameter and no containment check: after the scope filter it proceeds directly to `$isTestFile`
classification and records the path. Against that code, the `.ps1` out-of-root fixture would yield
`shouldWriteState = $true` and a non-empty `prodFiles`, failing all three of the test's substantive
assertions:

```powershell
$result.shouldWriteState | Should -BeFalse
$result.state.prodFiles | Should -BeNullOrEmpty
$result.state.testFiles | Should -BeNullOrEmpty
```

The test is non-vacuous.

**The variation is minimal and correctly scoped.** The suite defines both constants and uses each
where it belongs:

- Line 385, the containment **decision** test, uses `$OutOfRootPowerShellFixture` (`.ps1`) — required,
  per the above.
- Lines 407 and 427, the **rehydrate** test, use `$OutOfRootFixture` — the spec's literal
  `C:/synthetic-out-of-root/scratchpad/out_of_root_fixture.py`. This is correct and not a variation
  at all: `ConvertTo-PowerShellBatchBudgetState` applies containment to persisted entries with no
  extension filter, so the `.py` value is genuinely exercised there. I confirmed the rehydrate test
  is also capable of failing: with the poisoned entry retained, the third of three in-root files
  would hit the cap of 3 and be denied, failing the assertion at line 426.

The Python suite needs only the `.py` constant because its scope filter is `\.py$`. The asymmetry is
a consequence of the two hooks' different scope filters, not an inconsistency. Both suites use the
spec's literal constant wherever the spec's acceptance criterion requires it.

## Findings

### Major

**B-1 — The containment check omits the trailing separator the spec pins, permitting a
sibling-directory false-admit.**

`spec.md` lines 326-328 pin the containment rule explicitly:

> compare with `StartsWith($root + '/', [System.StringComparison]::OrdinalIgnoreCase)`

Both hooks implement it without the appended separator:

```powershell
# .claude/hooks/enforce-powershell-batch-budget.ps1:92  (identical at enforce-python-batch-budget.ps1:92)
return $normalizedPath.StartsWith($normalizedRoot, [System.StringComparison]::OrdinalIgnoreCase)
```

Demonstrated by direct execution of the shipped function:

```
root = C:/repos/wt/agent-abc
C:/repos/wt/agent-abc/src/a.ps1       inRoot=True    correct
C:/repos/wt/agent-abc-r2/src/a.ps1    inRoot=True    INCORRECT — different worktree
C:/repos/wt/agent-abcdef/src/a.ps1    inRoot=True    INCORRECT — different worktree
C:/synthetic-out-of-root/x.ps1        inRoot=False   correct
```

Impact. Defect 3 in `issue.md` is stated as "From a second git worktree of the same repository ... a
path belonging to a different worktree is counted against the current worktree's budget." Any sibling
worktree whose directory name begins with the current root's name is still counted against this
worktree's budget, and its persisted entries still survive the rehydrate filter. Sibling worktrees
sharing a name prefix are a realistic configuration in this repository, where retry worktrees are
suffixed (`-r2`, `-r3`) onto the original name. The fix is strictly better than the prior behavior,
which admitted every path unconditionally, so this is a partial gap rather than a regression — but it
leaves the named defect only partly closed and it contradicts a design decision the spec settled
rather than deferred.

No acceptance criterion detects this: the Defect 3 criterion enumerates relative, in-root absolute,
out-of-root absolute, and case-differing in-root, but no prefix-sibling case.

Remediation: append the separator before comparison, guard the exact-root-equality case, and add one
test per suite using a sibling-prefix path. Both suites have cap headroom for it.

**B-2 — `mergeClaudeGitignore` silently deletes destination content when the managed block is
malformed.**

`claude-gitignore-merge.ts` line 126:

```ts
const endIndex = endOffset === -1 ? lines.length - 1 : beginIndex + endOffset;
```

When an opening sentinel is present but the closing sentinel is absent, `endIndex` becomes the last
line of the file, and `lines.slice(endIndex + 1)` is empty. Every line after the opening sentinel is
discarded. Demonstrated by executing the shipped function:

```
input:  "a/\n# BEGIN drm-copilot managed ignores\n.old/\nb/\nc/\n"
output: "a/\n# BEGIN drm-copilot managed ignores\n.claude/state/\n.codex/state/\n# END drm-copilot managed ignores\n"
```

`b/` and `c/` are gone.

Impact. This contradicts the module's own documented invariant at line 26 — "Content outside the
block is preserved exactly, including its ordering" — and the spec's at line 310, "Content outside
the block is preserved byte-for-byte including its ordering." The write lands in a **consumer**
repository's `.gitignore`, so the loss is silent, remote, and not reported in the push-down summary
artifact (which by design omits this file). A consumer who removes or mangles the END line while
editing, or who resolves a merge conflict across the block, loses every subsequent ignore rule on the
next push-down.

The branch is untested; it is part of the 10 percent of branches the new module does not cover.

Remediation: when no closing sentinel is found at or after the opener, treat the managed block as the
opening line alone and preserve everything after it, then add a regression test for the malformed
input.

### Minor

**N-1 — Four newly added lines are uncovered; one corresponds to a spec-enumerated edge case.**
See Adjudication 1. Highest-value gap is the unreadable-session-id catch block, which `spec.md`
line 623 names in its own Test Strategy edge-case list and which no test exercises. The empty-root
guard is a fail-open branch worth pinning. Does not block.

**N-2 — `codex-pretooluse-integration.Tests.ps1` depends on ambient epic-checkpoint state.**
See Adjudication 2(d). Pre-existing, not owned by this feature, contravenes the Deterministic Test
Requirements in `.claude/rules/powershell.md`. Should be filed as a separate issue; it is currently
one of the two failures blocking the unscoped Pester run for every feature in this epic.

**N-3 — Duplicated state-write logic across both branches of the `persist-session-id.ps1` switch.**
Lines 110-114 and 117-121 perform the same `EnsureDirectory` + `WriteStateFile` sequence against the
same target (`$StateFilePath` and `$decision.path` are the same value in the `state-file` branch).
Hoisting the write above the `switch` for any decision with a session id would remove the duplication
and match the spec's stated approach of a "combined action" (spec line 436). Behaviorally correct as
written; this is a DRY observation only.

**N-4 — Spec Test Strategy checkboxes remain unchecked although the work is delivered.**
`spec.md` lines 591-593 carry three `- [ ]` items seeded from the issue (unit coverage areas,
integration scenario, manual verification note). All three are in fact satisfied. They sit under
`## Test Strategy`, not `## Acceptance Criteria`, so they are correctly excluded from the AC count of
17 — but a checkbox-counting tool run against the whole file will report three additional incomplete
items and mislead a later reader.

**N-5 — The `!`-negation edge case listed in the spec is not tested.**
`spec.md` line 630 enumerates a destination `.gitignore` "containing a `!`-negation of a managed entry
outside the block (which git resolves by last match; the writer must not reorder the destination's
file)". No test covers it. The behavior is correct by inspection — content outside the block is not
reordered in the well-formed path — but the case is unpinned.

**N-6 — `appendManagedBlock` trailing-blank-removal loop is uncovered.**
Lines 151-152, the only uncovered lines in the new module. No test supplies input with trailing blank
lines beyond the terminator. Low risk; noted for completeness.

## Rejected Scope Narrowing

None. The delegating prompt directed a full-branch audit against the epic base and explicitly
referred three items for independent adjudication rather than asking for ratification. No instruction
attempted to limit the file set, skip a toolchain check, or mark a language out of scope.
