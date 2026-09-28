# Code Review (reaudit, cycle-1 exit gate) — Feature B: Batch-budget state portability (issue #596)

- Timestamp: 2026-08-30T02-08
- Branch: `feature/batch-budget-state-portability-596` at `a7d4dd27`
- Base: `origin/epic/claude-runtime-portability-integration` (merge-base `6df37664`)
- Reviewer: feature-review agent
- Prior review under reaudit: `audit/2026-08-29T23-07/code-review.md` (0 Blocking, 2 Major, 6 Minor)

## Finding Counts (stated for mechanical arithmetic)

| Class | Count |
| --- | --- |
| **FAIL / Blocking** | **0** |
| **Blocking PARTIAL** | **0** |
| Major | 0 |
| Minor (advisory, non-blocking) | 11 (N-1 through N-11; 6 carried, 5 new) |

**blocking_count contribution from this artifact: 0.**

The finding set is the same set described in `policy-audit.md` and `feature-audit.md`, not an
additional set. Both prior Major findings are closed.

## Cycle-1 Change Set Reviewed

Six source and test files changed between `9e41b9bf` (the commit the prior review examined) and
`a7d4dd27`. The change is unusually small for the impact it carries, which is a point in its favour.

| File | Change | Assessment |
| --- | --- | --- |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | line 92 replaced in place | Correct, verified by execution |
| `.claude/hooks/enforce-python-batch-budget.ps1` | line 89 replaced in place | Correct, verified by execution |
| Two bundle mirrors of the above | same replacement | Byte-identical, verified by `git hash-object` |
| `extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts` | line 128 expression, +2 comment lines | Correct, verified by execution |
| `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge.test.ts` | +1 test | Good |
| `tests/scripts/claude-hooks/enforce-{powershell,python}-batch-budget.Tests.ps1` | +3 tests each | Good, one headroom concern |

`.claude/hooks/persist-session-id.ps1`, `claude-customizations.ts`, `jest.config.cjs`,
`claude-gitignore-delivery.test.ts`, and `persist-session-id.Tests.ps1` were not touched in cycle 1.
Their prior assessments stand and were spot-checked rather than re-reviewed in full.

## B-1 — Containment Predicate: Closed

### The fix as shipped

```powershell
return ([string]::Equals($normalizedPath, $normalizedRoot, [System.StringComparison]::OrdinalIgnoreCase) -or $normalizedPath.StartsWith($normalizedRoot + '/', [System.StringComparison]::OrdinalIgnoreCase))
```

The `[string]::Equals(...)` operand is the LEFT arm of the disjunction, as required. `OrdinalIgnoreCase`
is used on both operands, so the case-insensitivity the criteria pin is preserved on both paths.

### Verified by execution, not by reading

The prior review found this defect by running the function, so this reaudit did the same rather than
reading the diff. Both hooks were dot-sourced and the predicate called directly with
`root = C:/repos/wt/agent-abc`:

```
C:/repos/wt/agent-abc/src/a.ps1      inRoot=True    correct   (genuine in-root)
C:/repos/wt/agent-abc-r2/src/a.ps1   inRoot=False   correct   (reviewer counterexample 1)
C:/repos/wt/agent-abcdef/src/a.ps1   inRoot=False   correct   (reviewer counterexample 2)
C:/repos/wt/agent-abc                inRoot=True    correct   (exact root, still admitted)
C:/repos/wt/agent-abc/               inRoot=True    correct   (exact root, trailing separator)
C:\repos\wt\agent-abc\src\a.ps1      inRoot=True    correct   (backslash normalization)
c:/REPOS/WT/AGENT-ABC/src/a.ps1      inRoot=True    correct   (case-differing in-root)
C:/synthetic-out-of-root/x.ps1       inRoot=False   correct   (unrelated absolute)
src/relative.ps1                     inRoot=True    correct   (relative admission)
'' (empty)                           inRoot=False   correct   (null/whitespace guard)
```

Both hooks produced identical results on all ten cases. Both counterexamples that motivated the
finding are now rejected; every legitimate case that was admitted before is still admitted.

### Both call paths, not just the one the test covers

The helper is shared by `Invoke-*BatchBudgetDecision` and by `ConvertTo-*BatchBudgetState`. The
added test exercises the decision path only, so the rehydrate path was exercised directly:

```
sibling decision : permission=allow shouldWriteState=False prodFiles=0
in-root decision : permission=allow shouldWriteState=True  prodFiles=1
rehydrate, seeded with ('C:/repos/wt/agent-abc-r2/src/a.ps1', 'C:/repos/wt/agent-abc/src/keep.ps1'):
  surviving prodFiles = C:/repos/wt/agent-abc/src/keep.ps1
```

The poisoned sibling entry is dropped at rehydrate and the in-root entry survives. The fix is correct
on both paths. The absence of a rehydrate-path regression test is recorded as advisory finding N-7.

### Design assessment

The disjunction is the right shape. Appending the separator alone — which is what `spec.md:326-328`
literally pins — would have rejected a candidate equal to the root, and the root carries no trailing
separator after `TrimEnd('/')`. The remediation record argues the equality operand from three
premises: the helper is shared with the rehydrate filter where a root-equal persisted entry is
structurally representable; the pre-fix behaviour admitted the exact-root candidate and narrowing it
was not asked for; and the cost is one operand. That reasoning is sound, is documented, and is pinned
by its own test. Reading the spec's literal text as a rule about the prefix case rather than as an
exhaustive expression is the correct reading.

The exact-root pinning test is deliberately not tagged `[expect-fail]`, and the record says so. That
is the honest treatment: the test's purpose is to prevent a narrowing regression, and it would fail
against the naive fix the spec's literal text would have produced.

### Style observation

The replacement is a single 177-character line. The stated reason is that a single-line in-place
replacement holds the files at 457 and 454 lines, which keeps the absolute line numbers in the B-3
per-line coverage evidence valid between the baseline and final captures. That is a real constraint
and it was correct for this cycle. No line-length rule is in force — `pssa.settings.psd1` configures
none, and the same file already contains a 322-character pre-existing line at 296 — so this is not a
violation. Recorded as N-10 because the constraint was specific to this remediation's evidence model
and should not be assumed to bind future edits to the same line.

## B-2 — Unterminated Managed Block: Closed

### The fix as shipped

```ts
const endIndex = endOffset === -1 ? beginIndex : beginIndex + endOffset;
```

The `-1` arm now yields `beginIndex` rather than `lines.length - 1`, so `lines.slice(endIndex + 1)`
is everything after the opening sentinel rather than nothing. The adjacent comment was extended to
record the missing-closer case separately from the misordered-pair case, which is exactly the gap the
prior review identified — the two cases had previously shared one expression without a separate
decision.

### Verified by execution

The module has zero imports, so it compiles and runs in isolation. On the reviewer's original input:

```
input : "a/\n# BEGIN drm-copilot managed ignores\n.old/\nb/\nc/\n"
output: "a/\n# BEGIN drm-copilot managed ignores\n.claude/state/\n.codex/state/\n# END drm-copilot managed ignores\n.old/\nb/\nc/\n"

b/ survives    : true
c/ survives    : true
.old/ survives : true   (retained as unmanaged content)
a/ survives    : true
fixed point    : true
begin sentinel : 1 occurrence
end sentinel   : 1 occurrence
```

`b/` and `c/` survive, the result is a fixed point, and each sentinel occurs exactly once. All three
properties the directive named are confirmed.

### The well-formed path is unchanged

Applying the function twice to each of nine inputs — the seven the acceptance criteria enumerate plus
two malformed cases — every input reaches a fixed point on the first application. The well-formed
current block returns byte-identical to its input, which is the property the D-2 edit had to preserve.
`endOffset === -1` is false whenever a closer exists at or after the opener, so the well-formed path,
the append-when-absent path, and the never-a-second-block invariant are all structurally unreachable
from the changed arm. The recorded evidence that all seven pre-existing tests passed unchanged
corroborates this.

### One conditional property, recorded for accuracy

On input whose end sentinel precedes its begin sentinel, the output carries two `# END` lines: the
managed block's closer, and the stray earlier line preserved as unmanaged content. The begin sentinel
still occurs exactly once and the result is still a fixed point.

This is correct. Deleting the stray line would be deleting unmanaged content, which is the defect B-2
just fixed, and a stray `#`-prefixed line is inert to git. The behaviour predates cycle 1. It is
recorded as N-8 only because the merge test asserts sentinel uniqueness on inputs it controls, and a
future reader could take that as a universal property when it is conditional on the destination not
already carrying a stray closer.

### Design assessment

The comment now carries both cases and explains each, so the next reader will not have to re-derive
which arm handles which malformation. The fix is the minimal one that restores the documented
invariant, and it required no change to `toLines`, `toDocument`, `appendManagedBlock`,
`renderManagedBlock`, `normalizeLineEndings`, any exported constant, or the module's zero-import
property. That is the right blast radius for a one-arm correction.

## B-3 — Untested Catch Block: Closed

The catch block was already present and already correct; the finding was the absence of a test. Both
suites now drive `Get-*BatchBudgetSessionId` with a throwing `-ReadSessionIdFile` seam:

```
powershell hook resolved: 'worktree-repo-816fc349'   matchesWorktreePattern=True
python hook resolved:     'worktree-repo-816fc349'   matchesWorktreePattern=True
control (readable seam):  'from-file-id'
```

The exception is caught, resolution falls through to the worktree-derived identifier, and nothing
propagates out of a PreToolUse hook. The control case confirms a readable file still wins over the
worktree fallback, so the test is not passing because the seam is being ignored.

The catch bodies are now measured as covered: the re-measured missed-line set for the PowerShell hook
is `{79, 89, 452, 453, 454, 457}`, from which lines 154 and 155 are absent. The Python hook's set is
the structurally equivalent `{76, 86, 449, 450, 451, 454}`.

**On the fail-before treatment.** A test driving this catch passes against the pre-remediation tree by
construction, so no failing run was possible. The remediation supplied a per-line coverage transition
as the alternative proof and documented why a failing run could not exist, rather than manufacturing
one or quietly tagging the task `[expect-fail]` and reporting a failure that did not occur. That is
the correct engineering treatment of a coverage-gap finding and is worth preserving as a pattern.

## Test Quality of the Cycle-1 Additions

**The three PowerShell tests per suite — good.** Each is a single behaviour with a descriptive title.
Fixtures are synthetic path constants (`/repo`, `/repo-sibling`) that are never touched on disk, so
the tests are hermetic. The sibling test asserts four properties — decision, `shouldWriteState`, and
both file lists empty — rather than only the one that would flip, which makes the failure message
informative.

The sibling test is non-vacuous in the strong sense: the fixture carries a `.ps1` extension, so it
passes the scope filter and genuinely reaches the containment check. This matters, because the prior
review's Adjudication 3 established that a `.py` fixture would return at the scope filter and the test
would pass against code with no containment check at all. The executor applied that lesson correctly:
the PowerShell suite uses `/repo-sibling/scripts/tool.ps1` and the Python suite uses
`/repo-sibling/src/app.py`, each matching its own hook's scope filter.

The recorded fail-before run confirms it: `Expected $false, but got $true` at suite line 437, exactly
one failing test, 35 passing.

**Order-independence preserved.** The B-3 test assigns `$env:CLAUDE_SESSION_ID = ''`. The
Describe-level `AfterEach` at line 32 clears that variable along with three others, so the assignment
cannot leak into a later test. The four hook suites run 102/102 in a single combined invocation.

**The merge test — good.** Arrange/Act/Assert markers, one behaviour, and three assertions that pin
distinct properties: the exact expected document, `countOccurrences` equal to 1 for each sentinel, and
the fixed-point identity `mergeClaudeGitignore(merged) === merged`. Constructing the expected value
from `CLAUDE_MANAGED_IGNORE_ENTRIES` rather than a hard-coded literal means the test tracks a future
change to the managed entry set instead of failing spuriously on one.

**One structural concern.** `enforce-powershell-batch-budget.Tests.ps1` is now 495 lines against a
500-line cap. It is inside the cap and therefore compliant, but the next test added to it will not
fit. The Python sibling has 15 lines. Recorded as N-11: a split or a shared-helper extraction should
be planned before the next change to either suite rather than discovered during one. This also
strengthens the observation the prior review made about the two hooks' growing duplicated surface —
the duplication now extends to the test suites, and both are close to the cap.

## Toolchain Verification

Re-executed independently rather than read from evidence. All non-mutating.

| Check | Result |
| --- | --- |
| PoshQC format (via capturing `WriteFile` seam) | 0 files would be rewritten; tree clean after |
| `Invoke-PoshQCAnalyze` (`.claude/hooks`, `tests/scripts/claude-hooks`) | no findings |
| `npx prettier --check` (both push-down trees) | all files conform |
| `npx eslint src/lib/push-down test/lib/push-down` | exit 0, no output |
| `npx tsc --noEmit` | exit 0, no output |
| Four hook Pester suites | 102 total, 102 passed, 0 failed |
| `test/lib/push-down/` | 235 passed, 235 total |
| Full Jest run | 203 suites, 2734 tests, all passing |
| Resource-contract parity test | 1 passed |

The format check deserves a note on method. `Invoke-PoshQCFormat` is write-mode and returns the same
exit code whether it repaired a file or found nothing to repair, so a bare invocation would be a gate
that cannot fail. It was run with its exported `WriteFile` seam replaced by a collector; the collector
recorded zero paths and `git status --porcelain` was empty immediately afterwards. That is a positive
signal rather than an absence of one.

## Findings

### Blocking

**None.**

### Major

**None.** B-1 and B-2 are both closed and were verified by executing the shipped code.

### Minor (advisory, non-blocking)

**N-1 — PARTIAL.** The unreadable-session-id catch block is closed. The null-or-whitespace path guard
and the empty-root fail-open guard remain uncovered in both hooks (lines 79/89 and 76/86). I confirmed
the fail-open by execution: an empty `$Root` admits `C:/anything/x.ps1`. Unreachable in production
because `$Root` defaults to a `$PSScriptRoot`-derived ascent. The reconciliation artifact reports N-1
as PARTIAL rather than as delivered, which is accurate.

**N-2 — `codex-pretooluse-integration.Tests.ps1` depends on ambient epic-checkpoint state.**
Re-confirmed at HEAD, unchanged. Pre-existing, not owned by this feature, contravenes the
Deterministic Test Requirements in `.claude/rules/powershell.md`. Should be filed separately. Has not
become blocking.

**N-3 — Duplicated `EnsureDirectory` + `WriteStateFile` sequence in `persist-session-id.ps1`.**
Verified unchanged; the file was not edited in cycle 1. Lines 105-115 and 117-123 write the same
content to the same target in the `state-file` branch. Behaviorally correct. Out of scope, correctly.

**N-4 — Three unchecked Test Strategy checkboxes in `spec.md` (lines 591-593).** Verified unchanged.
Outside `## Acceptance Criteria`; the section-scoped counter confirms they do not affect the AC total
of 17. Out of scope, correctly.

**N-5 — The `!`-negation case at `spec.md:630` is untested.** Verified unchanged. Behaviour is correct
by inspection and by my nine-input execution, which confirmed ordering preservation on every input.
Out of scope, correctly.

**N-6 — `appendManagedBlock` trailing-blank-removal loop uncovered.** Now lines 153-154, the same two
statements the baseline reported as 151-152, displaced by the two comment lines the D-2 edit added.
The module's only uncovered lines. Low risk. Out of scope, correctly.

**N-7 (new) — the prefix-sibling case has no rehydrate-path regression test.** The shared helper makes
divergence unlikely and I verified the behaviour directly, but the path is unpinned. One test in each
suite would close it; the PowerShell suite has only 5 lines of headroom, so this would pair naturally
with the N-11 split.

**N-8 (new) — sentinel uniqueness is conditional, not universal.** A destination already carrying a
stray `# END` line outside the block yields output with two end-sentinel lines. Correct under the
content-preservation invariant, predates cycle 1, and the result is still a fixed point with exactly
one begin sentinel. Recorded so the merge test's uniqueness assertion is not read as universal.

**N-9 (new) — `claude-customizations.ts` has no `coverageThreshold` entry although it is a changed
file.** `jest.config.cjs` carries no `global` key and its own comment notes an entry-less file is
ungated. The file measures 100 percent lines and 94.59 percent branches, clearing both policy floors,
so nothing in force is violated. The gate is simply not armed for it.

**N-10 (new) — the containment predicate is a single 177-character line.** Chosen so the file's line
count would not move and the B-3 per-line coverage evidence would stay valid. Correct for this cycle;
no line-length rule is in force. Noted because the constraint was specific to this remediation's
evidence model.

**N-11 (new) — `enforce-powershell-batch-budget.Tests.ps1` has 5 lines of headroom (495/500).** Inside
the cap. The next test added will not fit. Plan the split rather than discover it.

## Positive Observations

Recorded because they are non-obvious choices that should survive future refactors.

1. The B-1 fix carries the `[string]::Equals` operand as the left arm rather than adopting the spec's
   literal text verbatim, and the reasoning is written down. A verbatim adoption would have silently
   narrowed the exact-root case on the rehydrate path.
2. The single-line in-place replacement was chosen specifically so the absolute line numbers in the
   B-3 per-line coverage evidence would remain valid across the baseline and final captures. That is a
   subtle coupling between a code edit and an evidence artifact, and it was identified in advance
   rather than discovered as a broken cross-reference.
3. The B-3 fail-before requirement was met with a documented exception dossier and a per-line coverage
   transition, rather than by manufacturing a failure that could not occur. The dossier states plainly
   why a failing run is structurally impossible.
4. The sibling-prefix test fixtures carry each hook's own scope-filter extension (`.ps1` and `.py`
   respectively), which is what keeps them from passing vacuously at the scope filter. This applies
   the prior review's Adjudication 3 correctly.
5. The reconciliation artifact reports N-1 as PARTIAL and states explicitly which of its components
   remain open, rather than claiming the finding as delivered because its highest-value component was
   closed.
6. The D-2 comment was extended to record the missing-closer case as a separate decision from the
   misordered-pair case, so the two no longer share one undocumented expression.
