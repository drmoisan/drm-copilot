# Code Review — issue #554

- Timestamp: 2026-08-27T22-47
- Branch: `bug/preimplementation-gate-blocks-epic-execution-554-r3` at `f24bbc7f`
- Base: `origin/main` at `1e991b86`
- Scope: full branch diff — 64 files, 8952 insertions, 48 deletions

## Overall Assessment

The structural repair is well designed and correctly implemented. The replacement classifier is
field-scoped and order-independent, the four-row dispatch table is a fixed constant that no prompt
can influence, the prompt-declared path is used only as a cross-check operand, and the two readiness
predicates return a *named failed conjunct* rather than a boolean, which is what makes the
diagnosability criterion satisfiable. The `-modes.ps1` sibling is genuinely pure — it opens no file,
launches no process, and imports no module — and every predicate takes an already-parsed object, so
the whole module is unit-testable with literal fixtures.

The principal quality defects are in test coverage rather than in the production logic, and they are
concentrated on the Codex copy and on one orphaned function. They are enumerated as B1-B4 in
`policy-audit.2026-08-27T22-47.md` and are not repeated in full here.

## Design Principles (`.claude/rules/general-code-change.md`)

### Simplicity — PASS with one exception

The mode table, path map, and agent allow-list are three flat constants; resolution is a loop over
three rows with an early return. That is the simplest shape that satisfies the requirement, and it
avoids the deep indirection the previous seven-token regex accreted.

The exception is the duplication introduced by leaving `Test-PreparationModeDelegation` and
`$script:PreparationModeMarkers` in place while `Resolve-OrchestrationDelegationMode` carries its own
copy of the same two marker literals in `$script:OrchestrationDelegationModeTable`. Two independent
implementations of the same rule now exist in files that must stay in step; nothing enforces that
they do. See B2.

### Reusability — PASS

`Get-OrchestrationModeProperty`, `Get-OrchestrationModeString`, and `Get-OrchestrationModeCollection`
form a small, single-purpose field-access seam reused by every predicate.
`Get-OrchestrationModeFolderBasename` is shared by the prompt-side and record-side of the target
comparison, which is what makes the two sides normalize identically — a common source of defects in
this class of hook, and correctly avoided here.

### Extensibility — PASS

Adding a fifth mode requires one row in `$script:OrchestrationDelegationModeTable`, one entry in
`$script:OrchestrationDelegationCheckpointPathMap`, and one readiness predicate. The decision
function's `if ($mode -eq 'epic' -or $mode -eq 'parallel')` branch is the one place a fifth mode
would require an edit rather than a registration; that is acceptable at four rows but would not
scale, and is worth noting for the "shared mode-resolution module" refactor `spec.md` already lists
as a post-merge follow-up.

### Separation of concerns — PASS, and this is the change's strongest property

The purity boundary is drawn exactly where it should be: all decision logic is in the pure sibling,
both filesystem reads (`Get-EpicCheckpointContent`, `Get-ParallelCheckpointContent`) stay in the main
hook, and the two optional injection parameters let a test suppress the seam entirely. The
`$PSBoundParameters.ContainsKey($injected)` test rather than a truthiness test is the correct choice
and is the reason an explicitly-supplied empty string suppresses the seam instead of silently
falling through to disk during a test run — a failure mode that would have made several allow
assertions pass vacuously. The suite asserts this directly by shadowing `Get-EpicCheckpointContent`
with a throwing definition.

## Error Handling

- `Get-OrchestrationModeProperty` catches only around the `PSObject.Properties` probe, logs at debug,
  and returns `$null`. Narrow and appropriate; not a catch-all.
- The decision function wraps `ConvertFrom-CheckpointJson` in `try/catch` and sets `$modeCheckpoint =
  $null` on failure. `$null` is then a failed first conjunct (`checkpoint-absent`), so a malformed
  checkpoint denies. Fail-closed, correct.
- An absent checkpoint file returns `''` from the seam, which parses to `$null`, which denies. Correct.
- No broad `catch { }` swallowing, no silent ignore.

**PASS.**

## Naming — PASS

Every new public function carries a repository-consistent verb-noun name, and the module deliberately
uses `Get-OrchestrationModeString` rather than `Get-StringProperty` so it cannot shadow the Codex
hook's own same-named helper when both files are dot-sourced into one scope. That collision would
have been easy to miss and the comment records the reasoning.

## Public API and Backward Compatibility — PASS

`Invoke-OrchestrationPreimplementationGateDecision` keeps `-ToolInputRaw` and `-CheckpointRaw` in
their existing positions with their existing attributes and their existing truthiness fall-through;
the two new parameters are appended and optional. Approximately sixty pre-existing cases required
zero edits, and all of them pass. `Get-OrchestrationPreimplementationGateBlockDecision -Reason` keeps
its single mandatory string parameter, pinned by `PreToolUseSchema.Contract.Tests.ps1`, which passes.

The default single-feature deny reason is preserved **verbatim**, including the `route metadata` and
`lifecycle readiness` substrings the pre-existing suite asserts. Verified by reading the literal at
the tail of the decision function.

## I/O Boundaries — PASS

The `-modes.ps1` sibling performs no I/O of any kind. The two new read seams are the only new I/O and
are confined to the main hook. Tests use literal string fixtures throughout; no temporary file is
created. The single filesystem read in the Codex suite is the tracked `.codex/config.toml`, resolved
through a `$PSScriptRoot`-relative `Resolve-Path`, which `spec.md` sanctions explicitly and bounds to
that one case.

## File Size — PASS

489 / 477 / 495 / 477 production lines and 494 / 235 test lines, all under the 500-line cap. The
headroom is thin (the Codex hook has 5 lines) and the D1 decision to split rather than extend
`-helpers.ps1` is what made that possible. Worth flagging for the next change to this file: there is
effectively no room left in `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`.

## Test Quality (`.claude/rules/general-unit-test.md`)

### Independence, isolation, determinism — PASS

Every fixture is a literal string built by concatenation rather than serialization, so the exact
payload under test is visible in the suite. No `Mock`, no ambient scope, no wall clock, no network,
no external process, no temporary file. Each `It` is a pure function of its arguments.

### Structure and readability — PASS

Arrange-Act-Assert is clear throughout. The `-ForEach` tables carry a `Label`/`Case` column that
renders into the test name, so a failure identifies its case without reading the file. The comments
explain *why* a case is shaped the way it is — notably the note on `ConvertTo-SingleFeatureCheckpointJson`
that any deny case omitting an explicit checkpoint would pass vacuously against the live on-disk
checkpoint. That is a real trap and catching it in the fixture's own docstring is good practice.

### Scenario completeness — PARTIAL

Positive, negative, boundary, and error paths are covered on the Claude surface for every predicate
and for the whole ten-case matrix, including the merge-status enum in both directions and the absent
`merge_status` default. The gaps are:

- The non-orchestrator allow branch of the classifier is untested on the Claude surface (B4).
- `Find-OrchestrationDelegationTargetFolder`, `Find-OrchestrationDelegationIssueNumber`, the
  unknown-mode path, and `Get-OrchestrationModeDenyReason` are untested on the Codex surface (B1, B3).
- `Test-PreparationModeDelegation` is untested on the Claude surface (B2).

### Test file location — PASS

Both new suites mirror the production layout under `tests/scripts/claude-hooks/` and
`tests/scripts/codex-hooks/`. No colocation.

### Coverage — FAIL

See `policy-audit.2026-08-27T22-47.md` §Coverage Verification. Repo-wide 94.22% PASS; three of four
changed production files below the 85% uniform line threshold; a ten-line regression on pre-existing
lines.

## Specific Code Observations

### The `-like` marker match matches the barrier hooks exactly — verified

`Resolve-OrchestrationDelegationMode` uses `$Prompt -like ('*' + $marker + '*')` for the epic and
parallel rows. `.claude/hooks/enforce-epic-wave-barrier.ps1:263` and
`.claude/hooks/enforce-parallel-cohort-barrier.ps1:213` use `-notlike "*$marker*"` against the same
literals. The three hooks on the same `Agent` matcher therefore agree on case-sensitivity as well as
on the trailing-period asymmetry, which is what the module comment claims. The claim is accurate.

### The preparation row correctly uses ordinal `.Contains()`

`MatchCase = $true` routes the preparation row through `$Prompt.Contains($marker)`, which is ordinal
and case-sensitive, matching the shipped `Test-PreparationModeDelegation` behaviour that an existing
test pins. The asymmetry is intentional and documented in the table's own comment.

### Trailing-punctuation stripping is correct but subtle

Both `Find-OrchestrationDelegationTargetFolder` and
`Test-OrchestrationDelegationDeclaredCheckpointPath` strip trailing `. , ; :` with a guard that
preserves the `.md` and `.json` extensions the next branch depends on:

```powershell
while ($best.EndsWith('.') -and -not $best.EndsWith('.md')) {
    $best = $best.Substring(0, $best.Length - 1)
}
```

This is correct for the shipped kickoff wording, where a bare path token is followed by sentence
punctuation. It is the kind of logic that deserves a property-style test; the two suites cover the
bare-directory and `.md` forms but not, for example, a token ending `...` or one ending `.md.`.
Non-blocking.

### Order-dependence in issue-number resolution

`Find-OrchestrationDelegationIssueNumber` returns the first bare-hash match. See finding N3 in the
policy audit. The function's own docstring anticipates a *widening* ("a bare hash form such as a
pull-request reference can supply a number that is not the target's") and argues correctly that an
unmatched number denies. It does not anticipate the *ordering* case, where two hash numbers are
present and their relative order decides which record is looked up.

### Duplicate dot-sourcing in the suites is deliberate and documented

Both suites dot-source the modes sibling explicitly in addition to receiving it through the gate
hook. The Claude suite's comment says this is now redundant but harmless; the Codex suite's says it
guards against a future change to the hook's dot-source line silently redirecting the assertions.
The second rationale is the better one and applies to both. Harmless either way — the file is pure,
so redefining its functions and constants is idempotent.

### `[ordered]` dictionary lookup is case-insensitive

`$script:OrchestrationDelegationCheckpointPathMap.Contains($Mode)` on an `OrderedDictionary` uses a
case-insensitive comparer by default, so `-Mode 'EPIC'` would resolve. Inert in practice: the only
values reaching this parameter come from the fixed mode table. Recorded for completeness only.

## Documentation and Comments — PASS

Comment density is high and the comments carry *reasons*, not restatements — the purity constraint,
the trailing-period asymmetry, the `ContainsKey`-versus-truthiness choice, the naming-collision
avoidance, and the Codex trimming divergence are each explained where a reader would otherwise have
to reconstruct them. This is consistent with the repository's PowerShell documentation policy and
materially raises the maintainability of a file that will be read under time pressure during an
incident.

## Tone — PASS

Every new comment, docstring, and evidence artifact uses neutral, factual language. No humor,
hyperbole, or decorative metaphor was found in the diff.

## Summary of Code-Review Findings

| ID | Finding | Severity |
| --- | --- | --- |
| B1 | Codex modes sibling at 81.82%; pure functions untested; D5 does not exempt them | Blocking |
| B2 | `Test-PreparationModeDelegation` orphaned — dead code plus a ten-line coverage regression | Blocking |
| B3 | `Get-OrchestrationModeDenyReason` untested on the Codex surface | Blocking |
| B4 | Classifier's non-orchestrator allow branch untested on the reachable Claude surface | Blocking |
| N1 | Executor's per-group uncovered-line counts inaccurate (total correct) | Non-blocking |
| N2 | Residual Codex decision-branch gap should be a named, #555-linked exception | Non-blocking |
| N3 | Order-dependence in `Find-OrchestrationDelegationIssueNumber` | Non-blocking |
| N4 | Spec-sanctioned permissive widening broader than the AC's "no new permissive path" wording | Non-blocking |
| N5 | Codex pack manifest omits the Codex main gate hook (pre-existing) | Non-blocking |
| N6 | Known #510 failure did not reproduce | Non-blocking |
| N7 | `.codex/…/gate.ps1` at 495 of 500 lines — no headroom for the next change | Non-blocking |
