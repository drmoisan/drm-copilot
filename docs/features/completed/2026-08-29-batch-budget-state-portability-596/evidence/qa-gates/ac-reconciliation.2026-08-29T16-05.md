# [P8-T2] Acceptance-criteria reconciliation — issue #596

Timestamp: 2026-08-29T23-05

Command: `pwsh -NoProfile -Command "Import-Module ./.claude/lib/requirements/GeneratedDocumentCounters.psm1 -Force; Get-NamedSectionCheckboxCount -Document (Get-Content -LiteralPath 'docs/features/active/2026-08-29-batch-budget-state-portability-596/spec.md' -Raw) -Heading 'Acceptance Criteria'"`

EXIT_CODE: 0

Output Summary: The named-section counter reports **17** checkbox items under the `## Acceptance
Criteria` heading of `spec.md`. After the [P8-T1] reconciliation pass, **16 are checked and 1 is
unchecked**. The single unchecked item is the criterion on `spec.md` line 773 (the PoshQC
consecutive-clean gate), whose format and analyze components hold and whose test component does not.
Every one of the 16 checked items is traceable to a named artifact under
`docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/`. No criterion text was
modified and no criterion was added.

## Verification method for this pass

Each criterion below was re-verified in this pass against two independent sources rather than
inherited from the phase that produced it:

1. the **current tree** — the actual test file, source file, or configuration file the criterion
   names, read directly and searched for the exact literal, count, or regular expression the
   criterion states; and
2. the **recorded run evidence** — the artifact whose `EXIT_CODE:` and quoted result lines establish
   that the named tests actually passed.

A completed phase was not treated as proof that a criterion holds. Five criteria (spec lines 693,
701, 711, 721, and 732) belonged to Phases 2 through 4, which completed with their plan tasks checked
while these criteria remained unchecked; each was verified from scratch in this pass before being
checked off.

Three cross-checks were performed against the live tree rather than against the recording of an
earlier run, because a recorded value can go stale:

- the three `git hash-object` mirror pairs were **recomputed** in this pass and each recomputed value
  matched the value recorded in `qa-gates/mirror-hash-parity-after.2026-08-29T16-05.md` exactly;
- both `git grep` absence searches were **re-run** in this pass and both exited 1 with no output;
- `Test-Path -LiteralPath '.claude/state'` was **re-run** in this pass and printed `False`, so the
  parity-gate criterion on line 753 still describes the tree as it now stands.

## Reconciliation table — all 17 criteria, each appearing exactly once

| # | `spec.md` line | Criterion (abbreviated) | Plan task | Evidence artifact | Verdict |
| --- | --- | --- | --- | --- | --- |
| 1 | 688 | PowerShell hook suite: three state-name tests, names pairwise different | [P2-T2], [P2-T6] | `evidence/regression-testing/powershell-hook-pass-after.2026-08-29T16-05.md` | PASS |
| 2 | 693 | Python hook suite: the same three state-name tests | [P3-T2], [P3-T6] | `evidence/regression-testing/python-hook-pass-after.2026-08-29T16-05.md` | PASS |
| 3 | 695 | Literal `'default'` absent from all four in-scope files; present before | [P0-T6], [P6-T1] | `evidence/baseline/search-default-before.2026-08-29T16-05.md` and `evidence/qa-gates/search-default-after.2026-08-29T16-05.md` | PASS |
| 4 | 701 | Each hook suite: hostile-session-id sanitization test matching the stated regex | [P2-T2], [P3-T2], [P2-T6], [P3-T6] | `evidence/regression-testing/powershell-hook-pass-after.2026-08-29T16-05.md` and `evidence/regression-testing/python-hook-pass-after.2026-08-29T16-05.md` | PASS |
| 5 | 704 | `persist-session-id` suite: `WriteStateFile` and `AppendLine` both invoked in the `CLAUDE_ENV_FILE`-set case | [P1-T2], [P1-T6] | `evidence/regression-testing/persist-session-id-pass-after.2026-08-29T16-05.md` | PASS |
| 6 | 711 | Each hook suite: rehydrate-time containment filter with the fixed synthetic constant | [P2-T2], [P3-T2], [P2-T6], [P3-T6] | `evidence/regression-testing/powershell-hook-pass-after.2026-08-29T16-05.md` and `evidence/regression-testing/python-hook-pass-after.2026-08-29T16-05.md` | PASS |
| 7 | 721 | Each hook suite: four path-recording containment tests (a) through (d) | [P2-T2], [P3-T2], [P2-T6], [P3-T6] | `evidence/regression-testing/powershell-hook-pass-after.2026-08-29T16-05.md` and `evidence/regression-testing/python-hook-pass-after.2026-08-29T16-05.md` | PASS |
| 8 | 725 | `(Get-Location).Path` absent; no `Resolve-Path`, no `[System.IO.Path]::GetFullPath` | [P0-T7], [P6-T2] | `evidence/baseline/search-getlocation-before.2026-08-29T16-05.md` and `evidence/qa-gates/search-path-resolution-after.2026-08-29T16-05.md` | PASS |
| 9 | 732 | `claude-gitignore-merge.ts` exists, is pure, suite passes with seven named cases | [P4-T1], [P4-T2], [P4-T4] | `evidence/qa-gates/gitignore-merge-unit.2026-08-29T16-05.md` | PASS |
| 10 | 738 | Managed block delivered on unscoped and pack-scoped publish | [P5-T1], [P5-T4] | `evidence/regression-testing/gitignore-delivery-pass-after.2026-08-29T16-05.md` | PASS |
| 11 | 741 | Idempotency: byte-identical reads, one sentinel pair, no second write | [P5-T1], [P5-T4] | `evidence/regression-testing/gitignore-delivery-pass-after.2026-08-29T16-05.md` | PASS |
| 12 | 745 | Unrelated destination entries preserved in original relative order | [P5-T1], [P5-T4] | `evidence/regression-testing/gitignore-delivery-pass-after.2026-08-29T16-05.md` | PASS |
| 13 | 747 | `coverageThreshold` entry present; `npx jest --coverage` passes with it | [P4-T3], [P7-T10] | `evidence/qa-gates/typescript-test-coverage-final.2026-08-29T16-05.md` | PASS |
| 14 | 753 | Python parity gate passes with no `.claude/state/` present | [P6-T5], [P7-T13] | `evidence/qa-gates/python-parity-gate-after.2026-08-29T16-05.md` and `evidence/qa-gates/parity-gate-final-state.2026-08-29T16-05.md` | PASS |
| 15 | 759 | Hash parity for all three named file pairs | [P0-T8], [P6-T3] | `evidence/qa-gates/mirror-hash-parity-after.2026-08-29T16-05.md` | PASS |
| 16 | 771 | PreToolUse deny-schema contract suite unchanged and green | [P6-T4] | `evidence/qa-gates/pretooluse-contract.2026-08-29T16-05.md` | PASS |
| 17 | 773 | PoshQC format, analyze, and test consecutively clean with per-file line coverage >= 85 | [P7-T2], [P7-T3], [P7-T4], [P7-T5] | `evidence/qa-gates/powershell-format-final.2026-08-29T16-05.md`, `evidence/qa-gates/powershell-lint-final.2026-08-29T16-05.md`, `evidence/qa-gates/powershell-test-final.2026-08-29T16-05.md`, `evidence/qa-gates/powershell-test-coverage-final.2026-08-29T16-05.md` | **PARTIAL** |

Verdict tally: **16 PASS, 1 PARTIAL, 0 BLOCKED.**

## Evidence detail for the five criteria reconciled in this pass

These five were unchecked at the start of Phase 8 despite their owning phases having completed. The
Phase 6 executor flagged that gap explicitly and required this pass to confirm their evidence rather
than assume it. The confirmation follows.

### Criterion 2 — `spec.md` line 693, Python hook three state-name tests

Tree verification. `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` carries all
four required `It` blocks inside `Context 'session identity, containment, and rehydrate filter'`:

| Suite line | `It` title | Criterion clause satisfied |
| --- | --- | --- |
| 246 | `composes the state-file name from CLAUDE_SESSION_ID when the environment supplies it` | (a) environment supplies the id |
| 261 | `composes the state-file name from the session-id state file when the environment is empty` | (b) read seam supplies the id |
| 279 | `composes a worktree-derived state-file name when both sources are empty` | (c) worktree-derived fallback |
| 294 | `composes pairwise different state-file names across the three session sources` | the pairwise-difference clause |

The asserted values were read, not assumed. Test (a) asserts the composed leaf is exactly
`python-batch-budget.env-session-42.json`. Test (b) asserts the leaf is
`python-batch-budget.file-session-7.json` and additionally asserts the seam was asked for
`/repo/.claude/state/current-session-id`. Test (c) asserts the leaf matches
`^python-batch-budget\.worktree-repo-[0-9a-f]{8}\.json$`. The pairwise test collects three composed
names and asserts `Should -HaveCount 3` on the collection and `Should -HaveCount 3` on its
`Select-Object -Unique` projection, which is the pairwise-difference assertion the criterion demands.
This mirrors the PowerShell suite, whose four counterpart blocks are at lines 256, 271, 289, and 304.

Run verification. `evidence/regression-testing/python-hook-pass-after.2026-08-29T16-05.md` records
`EXIT_CODE: 0`, the replayed line `Tests Passed: 32, Failed: 0, Skipped: 0, Inconclusive: 0,
NotRun: 0`, and the JUnit extraction `root=Pester tests=32 failures=0`. All four titles appear in the
enumerated `testcase` list with no `failure` child.

### Criterion 4 — `spec.md` line 701, hostile-session-id sanitization

Tree verification. Both suites carry `It 'sanitizes a hostile session id into the state-file name
pattern'` — PowerShell at line 344, Python at line 334. Each passes `-SessionId '../../etc/passwd'`,
whose `/` and `.` sequence places it outside the permitted character class in the sense the criterion
intends. Each asserts the composed leaf against the per-hook branch of the criterion's stated
alternation `^(powershell|python)-batch-budget\.[A-Za-z0-9._-]+\.json$`:

- PowerShell suite line 358: `$leaf | Should -Match '^powershell-batch-budget\.[A-Za-z0-9._-]+\.json$'`
- Python suite line 348: `$leaf | Should -Match '^python-batch-budget\.[A-Za-z0-9._-]+\.json$'`

Each test additionally pins the exact sanitized leaf (`powershell-batch-budget..._.._etc_passwd.json`
and `python-batch-budget..._.._etc_passwd.json`), so the assertion is not satisfiable by an arbitrary
conforming string. Splitting the criterion's alternation into its two per-hook branches is the
correct reading: a PowerShell-hook state file cannot begin `python-batch-budget`, so the per-hook
regex is strictly stronger than the alternation and entails it.

Run verification. Both pass-after artifacts record `failures=0` and name the sanitization title among
the `testcase` names.

### Criterion 6 — `spec.md` line 711, rehydrate-time containment filter

Tree verification. Both suites carry `It 'admits three in-root production files when the persisted
state already holds an out-of-root entry'` — PowerShell at line 403, Python at line 393. In each, the
seeded `prodFiles` array is `@($script:OutOfRootFixture)`, and that variable is assigned the fixed
synthetic constant the criterion names, verbatim:

- `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1:27` —
  `$script:OutOfRootFixture = 'C:/synthetic-out-of-root/scratchpad/out_of_root_fixture.py'`
- `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1:30` — the identical assignment.

The constant is defined by each suite itself, so neither test depends on transient local state. Each
test then drives three distinct in-root production candidates through the hook and asserts
`permissionDecision` is `allow` for all three, asserts the third decision's `prodFiles` does **not**
contain the fixture, and asserts it **does** contain the third in-root file. That is exactly the
"three distinct in-root production files are still admitted without a deny" clause together with the
proof that the poisoned entry was dropped from the cap arithmetic.

Run verification. Both pass-after artifacts record `failures=0` and name this title.

### Criterion 7 — `spec.md` line 721, the four path-recording containment tests

Tree verification. Both suites carry all four `It` blocks, authored against
`Invoke-<Prefix>BatchBudgetDecision` with an explicit `-Root '/repo'` argument:

| Clause | `It` title | PowerShell line | Python line |
| --- | --- | --- | --- |
| (a) relative path recorded | `records a relative candidate path` | 362 | 352 |
| (b) in-root absolute recorded | `records an absolute candidate path under the resolved root` | 372 | 362 |
| (c) out-of-root discarded | `discards an absolute candidate path outside the resolved root` | 382 | 372 |
| (d) case-differing in-root recorded | `records an in-root absolute path that differs from the root only in letter case` | 393 | 383 |

Clause (c) is the one whose assertion set the criterion states in full, and each suite asserts all
three of its parts: `permissionDecision | Should -Be 'allow'`, `shouldWriteState | Should -BeFalse`,
and an unchanged recorded-file list expressed as `prodFiles | Should -BeNullOrEmpty` together with
`testFiles | Should -BeNullOrEmpty` against a state that began empty.

One deliberate and mechanically necessary difference between the two suites is recorded here rather
than left for a reader to discover. The PowerShell suite's clause (c) test uses
`$script:OutOfRootPowerShellFixture`, assigned at suite line 28 to
`C:/synthetic-out-of-root/scratchpad/out_of_root_fixture.ps1`, rather than the `.py` constant. The
`.ps1` extension is required because the PowerShell hook's scope filter ignores non-`.ps1` paths, so
a `.py` candidate would be discarded by the scope filter rather than by the containment test and the
test would pass for the wrong reason. This does not weaken criterion 7, which does not name a fixture
constant. The criterion that **does** name the constant is criterion 6 on line 711, and both suites
use the exact `.py` constant there, as recorded above.

Run verification. Both pass-after artifacts record `failures=0` and name all four titles.

### Criterion 9 — `spec.md` line 732, the merge module and its suite

Tree verification. `extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts` exists and is
164 lines, within the 500-line cap. A search of the file for `^import`, `^export`, and `require(`
returns five `export` lines and **no import line of any kind**, so the module pulls in neither
`node:fs`, nor `filesystem-adapter`, nor any other module; `mergeClaudeGitignore(currentText: string):
string` at line 112 therefore performs no I/O, which is the criterion's purity clause. The five
exports are the ones the plan fixed: the relative path constant (line 39), the two sentinel constants
(lines 42 and 46), the managed-entry array (line 56), and the merge function (line 112).

`extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge.test.ts` carries a single
`describe("mergeClaudeGitignore")` at line 15 containing exactly seven `it` blocks, which map one to
one onto the seven cases the criterion enumerates:

| Criterion case | `it` title | Test line |
| --- | --- | --- |
| absent input | `appends a managed block to an absent input` | 21 |
| present without a managed block | `appends a managed block to input without one` | 39 |
| present with an identical block | `returns identical text for input that already carries an up-to-date block` | 55 |
| present with a stale block | `replaces a stale managed block in place` | 66 |
| managed entry outside the block, no duplicate block | `emits one managed block when a managed entry already appears outside it` | 97 |
| input without a trailing newline | `appends a managed block to input with no trailing newline` | 120 |
| CRLF input | `normalizes CRLF input to LF in the merged text` | 133 |

Run verification. `evidence/qa-gates/gitignore-merge-unit.2026-08-29T16-05.md` records `EXIT_CODE: 0`
and the `Tests:` line `Tests:       7 passed, 7 total` for the command `cd extensions/drm-copilot &&
npx jest test/lib/push-down/claude-gitignore-merge.test.ts`, with none of the three prohibited flags
passed. The module remains green in the full final run: `evidence/qa-gates/
typescript-test-coverage-final.2026-08-29T16-05.md` records `EXIT_CODE: 0`, `Test Suites: 203 passed,
203 total`, and `Tests: 2733 passed, 2733 total`.

## Criterion 17 — `spec.md` line 773 — PARTIAL, left unchecked

This criterion is a conjunction of four components. Three hold and one does not. It is left unchecked
because a partially satisfied conjunction is not a satisfied criterion.

| Component | State | Evidence |
| --- | --- | --- |
| `mcp__drm-copilot__run_poshqc_format` passes with no file modification | **HOLDS** | `evidence/qa-gates/powershell-format-final.2026-08-29T16-05.md` — `ok: true`, `EXIT_CODE: 0`, before-and-after `git status --porcelain` identical |
| `mcp__drm-copilot__run_poshqc_analyze` passes | **HOLDS** | `evidence/qa-gates/powershell-lint-final.2026-08-29T16-05.md` — `ok: true`, `EXIT_CODE: 0`, entailing zero analyzer findings |
| Per-file Pester LINE coverage >= 85 percent for all three hooks | **HOLDS** | `evidence/qa-gates/powershell-test-coverage-final.2026-08-29T16-05.md` — 93.8, 93.8, and 88.1 percent, each derived from its own covered and missed counts |
| `mcp__drm-copilot__run_poshqc_test` passes | **DOES NOT HOLD** | `evidence/qa-gates/powershell-test-final.2026-08-29T16-05.md` — `ok: false`, `EXIT_CODE: 2` |

Missing evidence named precisely, as a PARTIAL verdict requires: there is no artifact recording a
`run_poshqc_test` invocation that returned `ok: true`, and none can be produced without repairing two
tests that lie outside this feature.

The two failures are these, quoted verbatim from the JUnit extraction:

```
enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
```

Three independent observations establish that the pair is pre-existing rather than introduced:

1. **Name identity.** Both names are byte-identical to the pair recorded at the [P0-T12] baseline,
   captured before any edit this feature makes.
2. **Count stability across a rising denominator.** The failure count held at exactly 2 while the
   discovered test total rose from 3851 at baseline to 3904 at the final run — 53 newly discovered
   tests, 44 passing and 9 skipped, none failing.
3. **Ownership outside the change set.** The owning suites are
   `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` and
   `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`. Neither appears in
   `git diff --name-only main -- tests/`, whose complete output is this feature's own three suites.

Two independent full unscoped runs, recorded as iterations 1 and 2 in the coverage artifact, produced
byte-identical counts, byte-identical failing names, and byte-identical coverage counters, so the
condition is stable rather than flaky.

Repairing the two suites would widen scope beyond this feature. The orchestrator decision is
therefore to leave criterion 17 unchecked and to carry the failure forward as a documented
limitation, recorded in `evidence/other/known-limitations.2026-08-29T16-05.md`.

The three plan tasks that this same condition leaves unsatisfied — [P7-T4], [P7-T5], and [P7-T11] —
are correspondingly unchecked in `plan.2026-08-29T16-05.md`, each with its artifact present and its
unmet acceptance stated inside that artifact rather than reinterpreted as met. That correspondence is
verified in [P8-T5].

## Statement on check-off discipline

No criterion was checked off without both a tree verification and a run verification. No criterion
text was modified: the only edit made to `spec.md` in this phase was the substitution of `- [x]` for
`- [ ]` on five lines. No criterion was added or removed; the counter reports 17 both before and
after the pass.
