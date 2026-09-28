# Code Review — Feature B: Batch-budget state portability (issue #596)

- Timestamp: 2026-08-29T23-07
- Branch: `feature/batch-budget-state-portability-596` at `9e41b9bf`
- Base: `origin/epic/claude-runtime-portability-integration`
- Reviewer: feature-review agent

Findings: **0 Blocking, 2 Major, 6 Minor.** The Major findings are the same two carried in the policy
audit; they are restated here with the code-quality reasoning rather than the policy reasoning.

## Files Reviewed

| File | Change | Assessment |
| --- | --- | --- |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 284 to 457 lines | Good, one defect (B-1) |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 281 to 454 lines | Good, same defect (B-1) |
| `.claude/hooks/persist-session-id.ps1` | +14 lines | Good, minor duplication (N-3) |
| Three bundle mirrors | byte-identical | Verified by `git hash-object` |
| `extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts` | net-new, 164 lines | Good, one defect (B-2) |
| `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` | +46 lines | Good |
| `extensions/drm-copilot/jest.config.cjs` | +7 lines | Good |
| `tests/scripts/claude-hooks/*.Tests.ps1` (3) | +418 lines | Good |
| `extensions/drm-copilot/test/lib/push-down/claude-gitignore-*.test.ts` (2) | net-new, 261 lines | Good |

## Design Principles

**Simplicity first — PASS.** The session-id resolution chain is a flat, readable sequence of three
sources with the first non-empty winning. The containment test is a single boolean helper. No
indirection was introduced beyond what the seams require.

**Reusability — PASS with a deliberate exception.** The two batch-budget hooks are near-duplicates of
one another, differing only in scope filter (`\.(ps1|psm1|psd1)$` versus `\.py$`), test-file
predicate, function-name prefix, and environment-variable names. The added containment helper,
sanitizer, and session-id resolver are duplicated verbatim across both files. `spec.md` lines 546-551
records the decision not to extract a shared `.claude/lib/**` module, with two stated reasons: both
files retain ample headroom against the 500-line cap, and extraction would add two production files
plus a pack-manifest entry against an already-binding change budget. That reasoning is sound and the
duplication predates this feature. It is worth recording, though, that this change **increased** the
duplicated surface from roughly 0 to roughly 120 lines per file, so the extraction argument will be
stronger next time either hook is touched. Not a finding.

**Extensibility — PASS.** New behavior is added through additional optional scriptblock seams
(`ReadSessionIdFile`) and optional parameters (`-Root` on the decision and rehydrate functions) with
safe defaults. The existing `-SessionId` / `-Root` / four-scriptblock surface is preserved, so
pre-existing Pester invocations continue to work unchanged. This matches the spec's stated invariant
and matches the "prefer keyword-style parameters with defaults" guidance.

**Separation of concerns — PASS, and notably well executed.** `claude-gitignore-merge.ts` is a
genuinely pure module. I confirmed it has **no import or require statement of any kind**, so it has
no I/O dependency even transitively; every export is a constant or a pure function. The call site
`deliverDestinationGitignore` owns the read and the conditional write and nothing else. This is the
correct split and it is what makes the merge exhaustively testable without a filesystem.

## The Pure Module — `claude-gitignore-merge.ts`

**Purity: confirmed.** No imports. All five functions are total functions of their arguments. No
module-level mutable state. The three exported constants are frozen by convention
(`ReadonlyArray<string>` for the entry list).

**Idempotency: confirmed empirically.** I executed the shipped merge logic against every case the
acceptance criteria enumerate plus a malformed case, applying the function three times to each input:

| Input | Idempotent | Sentinels in output |
| --- | --- | --- |
| absent / empty string | yes | begin x1, end x1 |
| present, no block | yes | begin x1, end x1 |
| present, no trailing newline | yes | begin x1, end x1 |
| CRLF endings | yes | begin x1, end x1 |
| managed entry present outside block | yes | begin x1, end x1 |
| stale block | yes | begin x1, end x1 |
| malformed: begin without end | yes | begin x1, end x1 |

`f(f(x)) === f(x)` holds in all seven cases, and a third application changes nothing further. The
fixed-point property is achieved cleanly: `toLines` drops the single empty element left by a
terminating newline and `toDocument` re-adds exactly one, so a document and the same document without
its terminator normalize to the same line array. That is the right mechanism and it is documented at
the point of use.

**Naming and typing.** Constants are `SCREAMING_SNAKE_CASE`, functions `camelCase`, filename
kebab-case, all matching `.claude/rules/typescript.md`. No `any`, no type assertion, no non-null
assertion. Public exports carry explicit types. ES module syntax throughout.

**Documentation.** The module header states purpose, the rationale for being a separate module, the
pinned merge rule, and an explicit "Side effects: None". Each helper carries a docstring explaining
*why*, not just what — for example the `normalizeLineEndings` comment explains that a stray CR would
otherwise prevent a sentinel from ever matching. This is above the repository norm.

**Defect B-2 (Major) — malformed-block handling destroys content.** Line 126:

```ts
const endIndex = endOffset === -1 ? lines.length - 1 : beginIndex + endOffset;
```

The `-1` arm makes `endIndex` the file's last line, so `lines.slice(endIndex + 1)` is empty and every
line after the opening sentinel is dropped. Executed against the shipped code:

```
input:  "a/\n# BEGIN drm-copilot managed ignores\n.old/\nb/\nc/\n"
output: "a/\n# BEGIN drm-copilot managed ignores\n.claude/state/\n.codex/state/\n# END drm-copilot managed ignores\n"
```

`b/` and `c/` are lost. This contradicts the module's own stated invariant on line 26 ("Content
outside the block is preserved exactly, including its ordering") and the spec's on line 310. Because
the target is a consumer repository's `.gitignore`, and because the delivered file is deliberately
omitted from `PushDownSummary.files`, the loss is silent at both ends.

The adjacent comment shows the malformed case was considered:

```ts
// An end sentinel that precedes the begin sentinel belongs to an earlier,
// malformed block; only a closer at or after the opener delimits this one.
```

That reasoning handles a *misordered* pair correctly. The *missing-closer* case appears to have
inherited the same expression without a separate decision. The conservative behavior — treat the
block as the opening line alone and preserve everything after it — is a one-line change and preserves
the documented invariant in all inputs.

## The Call Site — `deliverDestinationGitignore`

**Writes only when content differs — confirmed.**

```ts
const currentText = fs.isFile(destinationPath) ? fs.readTextFile(destinationPath) : "";
const mergedText = mergeClaudeGitignore(currentText);
if (mergedText !== currentText) {
  fs.writeTextFile(destinationPath, mergedText);
}
```

A missing destination file is handled as the empty string rather than as an error, matching the
spec's stated contract that absence is a valid input. The guard makes the second publish a genuine
no-op at the filesystem level, not merely a byte-identical rewrite — which is what the idempotency
criterion asserts and what the delivery test verifies through `writtenPaths`.

**Reading through the raw injected filesystem is correct, not an oversight.** I examined the three
decorators composed in `pushDownCustomizations` and confirm the JSDoc's reasoning holds:

- `ExcludingFileSystem` governs the *copied source set*. Its `isPackIncluded` returns `false` for any
  enumerated path whose source-relative spelling is absent from `publishedPaths` when a pack
  selection is active. Routing this write through it would cause the `.gitignore` to be silently
  dropped from every `--packs` push-down — precisely the failure mode the spec identified when
  rejecting the payload-file alternative, and one that no existing manifest-completeness test would
  catch.
- The merging decorator governs the routing document; the deriving decorator governs the
  blast-radius map. Neither has any relationship to this path.

The write is post-copy and has no source file behind it, so none of the decorators' invariants apply.
Using the raw adapter is the only correct choice. The pack-scoped delivery test provides the
regression guard for this specific reasoning, and it passes.

**Sequencing.** `deliverDestinationGitignore` runs after `enginePushDown` returns and before the
summary is returned. The summary is captured and returned unmodified, preserving the
`PushDownSummary` schema that existing tests pin. If the engine throws, no ignore file is written,
which is the right failure ordering. There is no dry-run or preview mode in the push-down pipeline
(confirmed by search), so no code path exists where this write would fire against a caller expecting
no side effects.

## The PowerShell Hooks

**Session-id resolution.** `Get-*BatchBudgetSessionId` implements the documented three-source chain
correctly, with the explicit `-SessionId` argument ahead of the environment variable so the parameter
remains testable. Sanitization is applied to every returned value, including the worktree-derived
identifier, so the `^[A-Za-z0-9._-]+$` guarantee holds on all paths and a hostile id cannot escape the
state directory. The `../../etc/passwd` test confirms this end-to-end.

The ordering comment at the call site is a good catch:

```powershell
# Resolved before the directory is ensured, because reading the session-id
# file must never be what creates the state directory.
```

That is a real hazard — resolving the id after `EnsureDirectory` would make a read-only operation
have a filesystem side effect — and the code and comment both address it.

The SHA-256 handle is disposed in a `finally`, which is correct. The 4-byte, 8-hex-character short
hash gives adequate separation for the worktree-disambiguation purpose; collisions merely reunite two
worktrees under one counter, which is the pre-existing behavior, so the truncation is not risky.

**Containment — Defect B-1 (Major).** The helper is well-structured: normalize, admit relatives
early, guard degenerate root, then compare. Two of the three decisions match the spec exactly. The
comparison does not:

```powershell
# spec.md:326-328 pins:  StartsWith($root + '/', OrdinalIgnoreCase)
# both hooks implement:  StartsWith($normalizedRoot, OrdinalIgnoreCase)
return $normalizedPath.StartsWith($normalizedRoot, [System.StringComparison]::OrdinalIgnoreCase)
```

Executed against the shipped function with `root = C:/repos/wt/agent-abc`:

```
C:/repos/wt/agent-abc/src/a.ps1       inRoot=True    correct
C:/repos/wt/agent-abc-r2/src/a.ps1    inRoot=True    INCORRECT
C:/repos/wt/agent-abcdef/src/a.ps1    inRoot=True    INCORRECT
C:/synthetic-out-of-root/x.ps1        inRoot=False   correct
```

Any sibling directory whose name extends the root's name is admitted. This is the second git worktree
scenario from `issue.md` Steps to Reproduce item 3, and it remains open for prefix-sharing siblings.
Retry worktrees in this repository are named by suffixing the original (`-r2`, `-r3`), which makes the
collision realistic rather than theoretical. It also affects the rehydrate filter, since both paths
share the helper: a poisoned entry from a prefix-sharing sibling survives rehydration and continues to
consume a slot.

The fix is small — append the separator and handle exact-root equality — and both suites have cap
headroom for a regression test.

**Decision ordering.** Placing the containment test after the scope filter and before classification
is correct: a discarded path never reaches the cap arithmetic, which is what the spec requires. The
discard semantics are right and well justified in the inline comment — `allow`, no slot consumed,
`shouldWriteState = $false`, and a `Write-Verbose` diagnostic rather than stdout output, preserving
the deny-only convention.

**Error handling.** Both new failure paths degrade rather than throw: an unreadable session-id file
falls through to the next source, and an unwritable state file is logged at verbose level. Given that
a non-zero exit from a PreToolUse hook is non-blocking and therefore itself a fail-open, keeping the
hook on the exit-0 path is the correct posture, and the spec argues this explicitly. The entry point
still returns 0 on every path.

The `default` literal is fully removed. The parameter default became `''` and routes into the same
resolution helper, so there is no second code path — a good simplification over the previous split
between parameter default and entry-point assignment.

**PowerShell conventions.** Advanced functions with `CmdletBinding()` and `OutputType` throughout;
approved verbs (`Get-`, `Test-`, `ConvertTo-`, `Invoke-`); `[AllowNull()]` / `[AllowEmptyString()]`
where empty input is meaningful; no `Invoke-Expression`; no global or script-scoped mutable state in
production code; no hard-coded credentials. Comment-based help on every new function. The file-level
help block was updated to describe the new session-resolution and containment behavior, which is easy
to skip and was not skipped.

**`persist-session-id.ps1`.** The change is minimal and correct. In the `env-file` branch,
`$decision.path` is the env file, so writing the state file through the separate `$StateFilePath`
parameter is right; in the `state-file` branch the two are the same value. The env-file append is
preserved unchanged, and the `none` branch still performs no write. Finding N-3 below is the only
observation.

## Test Quality

**Both new Jest suites — good.** Explicit Arrange/Act/Assert markers, one behavior per test, no
snapshots, no fake timers needed (no async), no filesystem. The header comments explain scope and why
a sibling suite was created rather than extending `claude-config-carriage.test.ts`.

The idempotency test contains a detail worth calling out as good practice:

```ts
// Snapshot the write log after the first publish so the assertion inspects
// only the second publish's writes; asserting over the whole array would
// always find the first publish's write and could never fail.
const writesBeforeSecond = seeded.writtenPaths.length;
```

This is exactly the vacuous-assertion trap that the "capable of failing" requirement exists to catch,
and the author identified and avoided it in-line. The assertion is meaningful.

**PowerShell suites — good.** The three session-source tests are individually specific and are backed
by a fourth test asserting the three composed names are pairwise distinct
(`Select-Object -Unique | Should -HaveCount 3`), which is the assertion that actually proves
separation rather than merely proving three names were produced. `AfterEach` clears all four
environment variables, so the suites are order-independent. Seams are driven rather than commands
mocked, matching the repository's stated seam preference.

The fixture-constant handling is correct and is analyzed in full in the policy audit
(Adjudication 3): the `.ps1` sibling constant exists only where the `.ps1` scope filter would
otherwise make the assertion vacuous, and the spec's literal `.py` constant is retained where the
rehydrate filter genuinely exercises it.

**Gaps.** Three behaviors present in the code have no test: the unreadable-session-id catch block
(N-1), the malformed-block merge path (B-2), and the `!`-negation ordering case the spec enumerates
(N-5). None is critical; the first two are worth closing.

## Findings

### Major

**B-1 — Containment comparison omits the trailing separator, admitting prefix-sharing sibling
directories.** `.claude/hooks/enforce-powershell-batch-budget.ps1:92` and
`.claude/hooks/enforce-python-batch-budget.ps1:92`, plus both bundle mirrors. Deviates from the rule
pinned at `spec.md:326-328`. Empirically demonstrated above. Affects both the decision path and the
rehydrate filter. Recommend appending the separator, handling exact-root equality, and adding one
sibling-prefix regression test per suite.

**B-2 — `mergeClaudeGitignore` deletes all content following an unclosed managed block.**
`extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts:126`. Empirically demonstrated
above. Violates the module's own documented invariant and the spec's. The write lands in a consumer
repository and is not reported in the push-down summary, so the loss is silent. Recommend treating a
missing closer as a single-line block and preserving the remainder, plus a regression test.

### Minor

**N-1 — Four newly added lines uncovered; the unreadable-session-id catch block is the notable one.**
`spec.md:623` enumerates that edge case in its own Test Strategy; no test drives `ReadSessionIdFile`
to throw. The empty-root guard is an untested fail-open branch. Full reasoning in the policy audit,
Adjudication 1. Does not block.

**N-2 — `codex-pretooluse-integration.Tests.ps1` depends on ambient epic-checkpoint state.**
Pre-existing, not owned by this feature. Contravenes the Deterministic Test Requirements in
`.claude/rules/powershell.md`. It is one of the two failures preventing a clean unscoped Pester run
for every feature in this epic and should be filed separately.

**N-3 — Duplicated `EnsureDirectory` + `WriteStateFile` sequence in both branches of the
`persist-session-id.ps1` switch.** Lines 110-114 and 117-121 write the same content to the same
target. Hoisting the write above the `switch` for any decision carrying a session id would remove the
duplication and match the spec's stated "combined action" approach at `spec.md:436`. Behaviorally
correct as written.

**N-4 — Three unchecked Test Strategy checkboxes in `spec.md` (lines 591-593) although the work is
delivered.** They sit outside `## Acceptance Criteria` and so do not affect the AC count, but a
checkbox-counting tool run over the whole file will report three additional incomplete items.

**N-5 — The `!`-negation case enumerated at `spec.md:630` is untested.** Behavior is correct by
inspection in the well-formed path; the case is simply unpinned.

**N-6 — `appendManagedBlock` trailing-blank-removal loop uncovered** (lines 151-152, the module's only
uncovered lines). Low risk.

## Positive Observations

Recorded because they are non-obvious choices that should survive future refactors:

1. The pure/impure split for the gitignore merge is clean and the pure half has zero imports, so its
   purity is structurally guaranteed rather than merely asserted.
2. Resolving the session id *before* ensuring the state directory prevents a read from acquiring a
   filesystem side effect.
3. The idempotency test slices the write log rather than asserting over the whole array, avoiding an
   assertion that could never fail — and says so in a comment.
4. The toolchain convergence record detects a Prettier rewrite via paired `git status --porcelain`
   captures rather than exit code, which is the only reliable detection for a write-mode formatter.
5. The coverage evidence reports the two per-file declines plainly instead of rounding them away, and
   recomputes every percentage from raw counts rather than copying summary lines.
