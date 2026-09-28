# Code Review — Issue #518

Timestamp: 2026-08-26T06-55
Reviewer: feature-review
Branch: `bug/prd-feature-gate-resolves-nested-artifact-as-feature-folder-518` @ `2ae27c01`
Base: `origin/main` @ `b5a7490b`

## What the Change Does

`Find-PrdFeatureFolderFromPrompt` in `.claude/hooks/enforce-prd-feature-before-planner.ps1` previously
selected the longest `docs/features/active/...` token in a delegation prompt and, when that token ended
in `.md`, used its parent directory. Any citation of a nested artifact therefore produced a longer token
than the feature folder itself, and the gate resolved to a subdirectory.

The change replaces that with four-segment truncation, adds a deterministic multi-candidate selection
rule, splits the indeterminate-work-mode case onto its own deny path that does not probe for required
files, and corrects the fail-closed default of `Get-PrdFeatureRequiredFile` from the
spec-plus-user-story pair to `spec.md` alone. The identical edit is mirrored into the bundled copy.

## Design Assessment

### Simplicity — good

Truncation replaces a sort with a bounded linear pass. The resolution rule is now structural rather than
length-heuristic, so it is insensitive to how deep a cited artifact sits. The implementation reads in
one direction with no nesting deeper than two levels.

The rejection of a shared helper module (spec Scope & Non-Goals) is the right call and is justified on
measured grounds: extracting the rule would force a new bundled mirror, two `pester.runsettings.psd1`
edits, and a new test file — a larger write set than the duplication it removes.

### Fail-closed contract — preserved

Four deny paths exist and all four are reachable and asserted:

1. envelope anomaly (`Resolve-ClaudeHookToolInput` invalid),
2. no folder resolvable from prompt or checkpoint,
3. indeterminate work-mode marker (new),
4. required file missing.

The new indeterminate path is the one that superficially resembles a relaxation, because it skips the
required-file probe. It is not a relaxation: it returns `permissionDecision = 'deny'` unconditionally.
The rationale comment at lines 390-396 states the argument correctly — when the mode is unknown no
prerequisite set is knowable, a set containing `user-story.md` is unsatisfiable for `full-bug` and
`minor-audit` work without a lifecycle violation, and the empty set fails open — so marker repair is the
only remedy true in all three modes.

The `Get-PrdFeatureRequiredFile` default arm still returns a non-empty set (`@('spec.md')`), so a direct
caller passing an unrecognized mode cannot obtain a permissive empty set. The fail-open defect class
corrected by issue #501 is not reintroduced. The four regression-lock cases in the
`fail-closed prerequisite resolution` context pass.

### Determinism — correct, and the reasoning is recorded in the code

The deduplication collection is `System.Collections.Generic.List[string]` with a `Contains` guard, and
the comment at lines 258-260 states why a `[hashtable]` is prohibited here: PowerShell hashtable key
enumeration order is unspecified, so a first-occurrence selection rule fed by a hashtable would not be
deterministic. Deleting the length sort without also replacing the hashtable would have substituted an
intermittent defect for a reproducible one. The implementation avoids that.

### Separation of concerns — one deviation from the spec's stated invariant

`spec.md:117` states that `Find-PrdFeatureFolderFromPrompt` "remains a pure string function. No
filesystem probe is added to folder resolution." The delivered function calls
`Get-PrdFeatureCheckpointFolder` at line 296, which reads
`artifacts/orchestration/orchestrator-state.json`.

This is a contradiction inside `spec.md`, not an executor error: the operative data-flow specification
at `spec.md:158-161` mandates preferring the checkpoint value inside the selection rule. The
implementation follows the operative text and discloses the I/O honestly in its own help
("The function reads no file except through the existing checkpoint seam"). The I/O is reached only when
two or more distinct candidates exist, and it reuses a seam the hook already owned and already mocked,
so no new mock surface is introduced. `spec.md:117` should be corrected at close-out (finding NB-8).

### Error handling and messages — improved

Both changed reason strings now lead with the resolved folder, which is the substantive improvement the
issue asked for: a reader who sees a folder they did not intend diagnoses a path problem immediately.
All four deny reasons retain the `PRD_FEATURE_BLOCKED:` prefix, and the indeterminate reason retains the
literal phrase `could not be determined`, which is what allows three pre-existing `It` blocks to
continue passing unmodified.

### Naming — conforms

Approved verbs throughout (`Find-`, `Get-`, `Resolve-`, `Invoke-`). No abbreviation outside the standard
set. PSScriptAnalyzer reports zero findings across all four changed files.

## Adjudications Requested by the Caller

Each verdict below was reached independently. Where the caller supplied a framing, that framing was
tested rather than adopted.

### Item 1 — Deletion of gitignored runtime state to clear the bundle-parity gate

**Verdict: acceptable as a local workaround; not acceptable as durable evidence. Non-blocking.**

Facts established independently:

- The failing assertion names `.claude/state/powershell-batch-budget.default.json`. Both
  `.claude/state/*.json` files are gitignored at `.gitignore:68` and untracked
  (`git ls-files .claude/state/` returns zero paths).
- The defect is **already tracked**. Issue **#510**, "Bug:
  claude-resource-parity-enumerates-gitignored-state", is OPEN and describes this exact failure. Its
  reproduction steps state at step 4: "Delete the state file and re-run. It passes again." Its Impact
  section explicitly warns: "Because the remedy looks like deleting a file, the natural response is a
  per-plan workaround rather than a repository fix, so the defect recurs for every future feature that
  trips a budget hook."
- The executor did precisely what #510 predicted. The clearance is not durable. Re-running the suite in
  this same worktree during review returned **1 failed / 9 passed** with the identical assertion. The
  two state files are present again with modification times of 06:47 and 06:49, regenerated by the
  batch-budget `PreToolUse` hooks in response to ordinary agent file writes.
- No committed content was changed, no test was modified, no coverage exclusion was added, and CI is
  unaffected because a runner checkout is fresh and does not invoke the Claude `PreToolUse` hooks.

Assessment of the framing "making a failing gate pass by changing the environment rather than the code":
in form, yes. In substance the distinction that matters is what was deleted. These are machine-local,
gitignored, regenerable counters with no durable value and no representation in the repository. Deleting
them destroyed no repository content, no user data, and no evidence. The property the gate exists to
enforce — byte identity between the two hook copies — was verified independently by hash equality and by
`cmp`, and that verification does not depend on the state of `.claude/state/`.

On the cited **#559** precedent: it is not on point. Issue #559 is
"epic-orchestrator-always-on-context-footprint", concerning the removal of **committed configuration
content** from agent and skill files. Deleting committed content that other consumers depend on is a
categorically different act from deleting an untracked, gitignored, regenerable local counter. The
rejection recorded there does not transfer.

Required corrections, both documentation-only:

1. The bundle-parity and post-rebase artifacts say the underlying defect "is carried to a follow-up
   issue". No such issue was filed, and none needed to be: **#510 already exists**. Both artifacts and
   the acceptance-criteria check-off must cite `#510` by number. As written, the phrasing implies an
   unfiled obligation.
2. The durable evidence for the bundle-parity acceptance criterion is the byte-identity hash check, not
   the parity suite's exit code. The check-off should cite the hash comparison first and the suite run
   second, with the environmental condition named.

### Item 2 — [P5-T1] executed through the MCP promotion path rather than `gh issue create`

**Verdict: the acceptance criterion is satisfied. The write-set expansion is acceptable. The task's own
acceptance condition is only partially met.**

- The acceptance criterion at `spec.md:377` requires that four follow-up issues be *filed*. Verified
  directly with `gh issue list`: **#565, #566, #567, #568** all exist, all OPEN, with titles matching the
  evidence artifact. The criterion is about the outcome, not the mechanism. **Satisfied.**
- The deviation was forced, not chosen. `gh issue create` is denied by the `PROMOTION_MCP_ONLY_BLOCKED`
  `PreToolUse` hook, and `atomic-executor` carries no `gh` in its allowlist, so the task as written was
  unexecutable by its assignee through the only command it named. That is a defect in the plan text, not
  in the execution (finding NB-9).
- The write-set expansion is four files under `docs/features/potential/promoted/`. Verified from the
  diff: exactly four additions, zero residual files under `docs/features/potential/` itself, confirming
  the evidence's claim that `potential_to_issue` moves rather than copies. These are the canonical
  lifecycle records of the only permitted path. `mcp__drm-copilot__new_active_feature_folder` was
  correctly not invoked, so no feature folder or branch was created for the four follow-ups.
  **Acceptable**, and it should be called out in the pull-request body.
- The task's own acceptance condition requires the artifact to carry "the exact body text submitted for
  each" issue. It does not. It substitutes a pointer: "The exact body text submitted for each issue is
  preserved verbatim in that issue's promoted record." That claim is **inaccurate**. `gh issue view 565`
  returns a body whose first line is `- Work Mode: full-bug`; the corresponding promoted record carries
  no `- Work Mode:` line at all, and three of the four records lack it. The prose also differs in
  punctuation. The record is a near-copy, not a verbatim preservation (finding NB-2).

### Item 3 — Two Phase 1 test prompts corrected during Phase 2

**Verdict: the executor's claim is independently confirmed. The corrections were necessary and the two
cases remain genuine regression tests.**

This was verified by extracting the pre-fix resolver from commit `22c702cf` and executing both prompt
forms against it, rather than by accepting the executor's transcription.

Pre-fix resolver, corrected prompts:

| Case | Expected | Pre-fix result | Regression property |
| --- | --- | --- | --- |
| `yields one distinct candidate when one folder is cited at three depths` | `docs/features/active/2026-08-23-dedupe-1` | `docs/features/active/2026-08-23-dedupe-1/evidence/baseline` | misresolves — case fails pre-fix |
| `returns the same decision for folder-relative and repo-relative research paths` (folder-relative arm) | — | `docs/features/active/2026-08-23-differential-1` | — |
| same case (repo-relative arm) | — | `docs/features/active/2026-08-23-differential-1/research` | the two arms diverge; with the exact-path existence mock one allows and the other denies — case fails pre-fix |

Both corrected cases therefore still fail against the unfixed hook. Neither was converted into a test
that passes both before and after.

The reason the correction was necessary was also verified, by running the *original* prompts against the
*post-fix* resolver:

- Original dedupe prompt under the fix resolves to `docs/features/active/2026-08-23-dedupe-1,` — with the
  trailing comma captured into the token — and consults the checkpoint seam once. Both assertions of that
  case would fail, for the trailing-punctuation reason `spec.md:79` and `spec.md:295` record as a known
  limitation deliberately left unchanged.
- Original differential prompts under the fix both resolve to
  `docs/features/active/2026-08-23-differential-1.` with a captured period, which the exact-path existence
  mock does not match, so the `Should -Be 'allow'` assertion would fail.

The original prompts were exercising the punctuation limitation rather than the truncation behaviour
their names describe, exactly as the executor reported. Removing the punctuation confound is the correct
repair. The residual process concern is that the committed fail-before artifact was captured against the
pre-correction text and was not re-run afterwards (finding NB-7); this review's independent
re-measurement supplies the missing link.

### Item 4 — The [P1-T9] deviation and the test names

**Verdict: the assertion replacement was necessary and correctly justified. The `It` names are now
inaccurate and should be renamed.**

On the assertion: the task named only the `user-story.md` assertion as dropped, but the adjacent
`Should -Match 'spec\.md'` had to go as well. This is not discretionary. The new indeterminate reason
names neither prerequisite document by design — that is itself an acceptance criterion at
`spec.md:357` — so retaining the `spec.md` assertion would have made the case fail against the correct
implementation. `spec.md:268` supports replacing the assertion wholesale. The executor also strengthened
the case by adding a positive `-BeLike '*...marker-absent/issue.md*'` assertion and an explicit negative
on `user-story.md`. The deviation is sound and is documented in-line.

On the names: they no longer describe what the tests assert.

- `It 'fails closed to the strictest set when the mode is $null'` now asserts `@('spec.md')`.
- `It 'fails closed to the strictest set for an unrecognized mode string'` now asserts `@('spec.md')`.

`spec.md` alone is not the strictest set; the strictest set is the spec-plus-user-story pair the change
deliberately removed. The behaviour is still fail-*closed* — the returned set is non-empty — but the word
"strictest" is now false. The explanatory comment added above the pair is good, but an `It` name is what
appears in a failure message, and a reader who sees `fails closed to the strictest set` alongside an
expectation of `spec.md` will suspect the assertion, not the name.

A stronger instance of the same defect was found in the same file and was **not** flagged by the
executor. The `Context` header comment at
`tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1:368-374` still reads:

> The gate MUST fail closed to the strictest prerequisite set (spec.md and user-story.md) in every case.

That statement now directly contradicts the delivered behaviour, and it sits above the four cases that
exercise the new indeterminate path. See findings NB-4 and NB-5.

The third name the caller asked about, `treats a path ending in .md as a file and uses its parent
directory`, describes a mechanism that no longer exists, though the case still passes because truncation
produces the same result. `spec.md:269` explicitly calls renaming this one optional and cosmetic, so
leaving it is spec-sanctioned. It is recorded as a nice-to-have only.

## Additional Findings from the Diff

### Stale rationale comment in the hook

`.claude/hooks/enforce-prd-feature-before-planner.ps1:384-386` retains:

```powershell
# Derive the prerequisite set from the persisted work-mode marker rather
# than a fixed spec.md/user-story.md pair. A marker that cannot be read or
# recognized must fail closed to the strictest set, not fail open.
```

The "fail closed ... not fail open" half remains true. The "to the strictest set" half is now false: the
very next statement routes an unreadable marker to a branch that names no prerequisite set at all. This
comment is three lines above the code that contradicts it (finding NB-3).

### No-folder deny reason still names both documents

`.claude/hooks/enforce-prd-feature-before-planner.ps1:377` is unchanged and reads in part "so spec.md and
user-story.md prerequisites can be verified". No acceptance criterion covers this path, and it is
reached only when no folder can be resolved at all, so the text is not misleading in the way the
indeterminate reason was. Recorded for awareness only; no action required.

### Degenerate token behaviour change

A token of the shape `docs/features/active/foo.md` — a stray Markdown file directly under `active/` with
no feature folder — previously resolved to `docs/features/active` via the `.md`-parent rule and now
resolves to `docs/features/active/foo.md` as though it were a folder. No such file exists, and
`docs/features/active` was never a valid feature folder, so there is no practical exposure. Nice-to-have
only.

### Evidence-artifact accuracy

- Two artifacts carry future-dated timestamps. `post-rebase-toolchain-reverification.2026-08-26T06-55.md`
  and `follow-up-issues.2026-08-26T07-05.md` were both committed in `2ae27c01` at `06:44:29`, which is 11
  and 21 minutes respectively before their declared capture times. A timestamp segment must be the actual
  capture time (finding NB-6).
- `fail-before-regression-run.2026-08-26T06-08.md` heads one subsection "(4 of 6 failing)" and then
  enumerates five items. The five-item count is the correct one; it is what makes the section totals sum
  to the stated 18. A transcription error in the heading only.

## Test Quality

The 25 new cases are well constructed. Three properties are worth naming because they are not obvious
and were done deliberately:

1. **The existence mocks key on the exact expected path**, not on a filename suffix. A folder misresolved
   to a nested subdirectory therefore reports the prerequisite as missing and the decision flips. A
   suffix-matching mock would have passed under a misresolved folder and the equivalence cases would have
   been unfalsifiable.
2. **Every multi-candidate case gives the expected winner the shorter slug.** A length-ordered selection
   rule cannot agree with the specified rule by coincidence, so these cases would catch a partial revert
   that removed the truncation but left a sort.
3. **The zero-invocation assertion on `Get-PrdFeatureCheckpointFolder`** is a sound observable proxy for
   "exactly one distinct candidate", because the implementation consults the checkpoint if and only if
   more than one candidate survives deduplication.

The seven pre-existing cases repaired by [P1-T10] each keep their original name and assertion intent; the
added work-mode mock is the only change, which is the minimal repair.

## Verdict

The change is correct, minimal, well-tested, and within every applicable budget. The implementation
matches the specification's operative text on every point examined. **No blocking finding.**

Eleven non-blocking findings are recorded in `remediation-inputs.2026-08-26T06-55.md`. Three of them
(NB-3, NB-4, NB-5) are stale-documentation defects inside files already in the declared write set and can
be folded into [P5-T2] at negligible cost.
