# Code Review — cleanup-worktrees-sanctioned-removal-manifest (Issue #635)

- Date: 2026-09-08
- Reviewer: feature-review agent
- Base branch: `epic/cleanup-merged-worktrees-hardening-integration` @ `0ea7e577`
- Head: `4d5ecaca`
- Languages in scope: PowerShell (`.ps1`, `.psm1`, `.psd1`), JSON, Markdown. No Python, TypeScript,
  or C# files changed, so no typed-Python review section applies.

## Executive Summary

The implementation is of high quality. The new module is cohesive, has a single clear
responsibility, exposes exactly two I/O seams, and fails closed on every malformation without
raising. The two hook changes are minimal and confined to the may-touch region the specification
defines: three added lines each, all strictly after the `$worktreePath` assignment. The test surface
is thorough — 97 net-new tests including a 32-case fail-closed matrix run against both gates — and it
is genuinely deterministic, with no wall-clock read, no temporary file, and no live checkpoint read
in any new test.

The most important design decision in the change is also the one most easily gotten wrong, and it is
right: condition 10 is implemented as a **presence** test over the two orchestration checkpoints
rather than as an authorization test. That makes the new branch strictly unable to authorize any
removal the existing gates were already protecting, and it makes the exclusion broader than the
gates' own predicates rather than equal to them. An implementation that reused
`Test-EpicWorktreeRemovalAllowed` there would have compiled, passed a naive test, and quietly opened
the one hole the specification names as mandatory to close. It does not.

Two Medium findings are recorded, both non-blocking: two contract fields the specification declares
fail-closed are neither implemented nor tested, and a `--force` spelling reaches the manifest allow.
Neither meets the remediation trigger. Five Low and informational findings follow. **No blockers.**

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| Medium | `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` | `Test-CleanupWorktreeManifestAuthorizesRemoval`, conditions 2-9 | **F-01.** Two required-field fail-closed rules from the specification's normative contract table are neither implemented nor tested. The top-level table states `run_id` "Absent, non-string, or empty/whitespace ⇒ fail closed", and the `removals[]` table states `branch` "Key absent ⇒ record does not authorize". The module references neither identifier. A manifest with `run_id` omitted, or a record with the `branch` key omitted, still authorizes. | Either add the two guards (four lines total, mirroring the `evidence` and `worktree_path` guards) with four matching matrix deny cases (`-Drop 'run_id'`, `run_id` empty, `-Drop 'branch'`, `run_id` non-string); **or** amend `spec.md`'s two tables to mark both fields advisory and record why. Prefer the first: `run_id` is the audit correlator, and an authorization record with no correlator is measurably less auditable, which cuts against the field the design leans on most. | The specification's own allow predicate (conditions 1-10) does not list either field, and no acceptance criterion covers them, so the implementation conforms to the predicate and to all 37 criteria. But the field tables are described as "a normative cross-module contract" that sibling child F reads verbatim, and the implementation silently resolved the internal inconsistency in the permissive direction rather than recording the choice. That is the part worth fixing. | `grep -n "run_id\|'branch'\|\"branch\"" CleanupWorktreeManifest.psm1` returns no match. `grep -n "run_id\|Drop 'branch'\|Drop 'run_id'" CleanupWorktreeManifestGateMatrix.Tests.ps1` returns only the fixture-value lines 44 and 49; no deny case drops either key. |
| Medium | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | epic `:395-411`, parallel `:264-279` | **F-02.** A `--force` spelling reaches the manifest allow. `Get-CommandLineOperand` documents that "known zero-argument flags such as `--force` contribute nothing", so `git worktree remove --force <path>` yields `$worktreePath = <path>` and, if the manifest covers that path, both gates return `allow`. The `allowed-tools` grant `Bash(git worktree remove *)` is a prefix glob and also admits it. The only prohibition on force is skill prose. | Add a force rejection to the manifest branch in both gates: gate the new branch on `-not (Test-CommandLineFlag -CommandText $commandText -CommandWord 'git' -SubcommandPath @('worktree','remove') -FlagName '--force')`. Add one deny pin per gate. Two lines of production code and two tests. | The specification states as an invariant that "no force flag is ever added to any removal spelling", and `SKILL.md`'s new step-9 text says "Never pass a force flag to that command: a dirty worktree blocks deletion and is reported for manual handling, and it is never force-removed." The gate does not enforce either statement. This does not widen the manifest-covered path **set** — the target must still carry a conforming record — and the pre-existing checkpoint branches have the identical property, so it is consistency with precedent rather than a new class of hole. It matters because `--force` is precisely what lets a removal skip the dirty-worktree triage the skill exists to perform, so it converts a documented prohibition into an unenforced one on the one path this change newly opens. | `.claude/hooks/hook-command-invocation.ps1:279-280` (`Get-CommandLineOperand` docstring); `enforce-epic-worktree-removal-gate.ps1:164-165` and `:172-179` (force is read only to substitute a non-matching sentinel when **no** operand resolves). |
| Low | `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` | `ConvertTo-CleanupWorktreeManifestNormalizedPath`, docstring vs body | **F-03.** The docstring states the function "trims a single trailing slash"; the body is `.TrimEnd('/')`, which trims every trailing slash. `C:/x//` and `C:/x` therefore normalize equal. | Either change the docstring to "trims trailing slashes" or change the body to a single-slash trim. The docstring change is preferable: `TrimEnd` is the more forgiving and more idiomatic choice, and both sides of every comparison are normalized identically. | Not a behavioral defect — both the command target and every recorded `worktree_path` pass through the same function, so no asymmetry can arise, and multiple trailing separators denote the same directory. It is a documentation accuracy issue in a module whose documentation is otherwise precise enough to be relied on. | Docstring at the function's `.DESCRIPTION`; body `return ($Path -replace '\\', '/').TrimEnd('/')`. |
| Low | `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` | `Test-CleanupWorktreeManifestAuthorizesRemoval` condition 5, calling `Find-CleanupWorktreeManifestRemovalRecord` | **F-04.** The manifest JSON is parsed twice per evaluation. The predicate parses `$raw` for conditions 1-4, then passes the same `$raw` string to the finder, which parses it again. The `removals`-presence guard is likewise duplicated in both functions. | Change `Find-CleanupWorktreeManifestRemovalRecord` to take the parsed object (`-Manifest`) instead of `-Raw`, and have the predicate pass the object it already holds. The finder's own `try`/`catch` and `removals` guard then collapse into the caller's. The module test that calls the finder directly would pass a `ConvertFrom-Json` result, which is what the checkpoint-exclusion test already does. | Duplicated fail-closed logic is the class of duplication most worth removing, because the two copies can drift and only one is on the path a given test exercises. The cost today is one redundant parse of a small document, which is immaterial; the maintenance risk is the real cost. | The predicate performs `$raw \| ConvertFrom-Json` inside its own `try`/`catch` and checks `$manifestProperties -notcontains 'removals'`; `Find-CleanupWorktreeManifestRemovalRecord` repeats both against the same `$Raw`. |
| Low | `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` | `Test-CleanupManifestCheckpointCoversPath` | **F-05.** Noun-prefix inconsistency. Five of the six exported functions use the `CleanupWorktreeManifest` prefix; this one uses `CleanupManifest`. | Rename to `Test-CleanupWorktreeManifestCheckpointCoversPath` if the resulting length is acceptable, or leave and note the abbreviation. Not worth a rename on its own; fold into the next edit to this file. | Consistent noun prefixes are what make a module's exported surface discoverable by tab-completion and greppable by prefix. One exception in six weakens that. | `Export-ModuleMember` list at the end of the module. |
| Low | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | manifest branch, first conjunct | **F-06.** Condition 10 treats an absent or unparseable checkpoint as "not covered", so a manifest record can authorize a removal when the checkpoint that would have excluded it cannot be read. Before this change, an unreadable checkpoint always produced a deny — the parallel gate's own reason string still enumerates "The checkpoint was unreadable" as a deny cause. | Record the behavior in the module docstring rather than change it. If it is ever changed, distinguish "checkpoint absent" (the normal cleanup case) from "checkpoint present but unparseable" (the anomalous case) and deny the manifest branch only for the latter. | The permissive reading is **correct for the primary use case**: a `/cleanup-merged-worktrees` run has no epic or parallel checkpoint at all, so requiring a readable one would deny every sanctioned removal and reinstate the bug. The residual is confined to the case where a checkpoint exists but is corrupted or deleted mid-run, and exploiting it requires the ability to write a conforming manifest, which already implies the `bash <file>` route. Practical marginal risk is negligible; recorded so the property is not discovered later as a surprise. | `spec.md` condition 10 specifies behavior for a **matching record** and is silent on an unreadable checkpoint; the implementation returns `$false` from `Test-CleanupManifestCheckpointCoversPath` when `$Checkpoint` is `$null`. |
| Low | `.claude/skills/cleanup-merged-worktrees/SKILL.md` | new `## Sanctioned Removal Manifest` section, placed after triage step 10 | **F-07.** The manifest-write instruction is a named section positioned after step 10 but instructs an action that must precede step 9. | Add a one-line pointer at the head of the Dirty Worktree Triage Procedure: "Before beginning this procedure, read the Sanctioned Removal Manifest section below." One sentence, no renumbering. | The chosen placement is justified — inserting a numbered step before step 9 would have renumbered it and falsified both AC-33's and the plan's explicit "step 9" references — and the risk is already reduced by the forward reference inside step 9's own new text ("the Sanctioned Removal Manifest **below** carries a record for that exact path"), so a linear reader is pointed at the section exactly when it becomes relevant. The section also opens with a bold ordering directive. The residual is that the ordering constraint is discoverable only from within step 9 rather than before it. | Section body opens "**Write the manifest before step 9 of the Dirty Worktree Triage Procedure acts on any `SAFE_TO_DELETE` verdict.**"; step 9 body carries the forward reference. |
| Informational | `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` | file length | **F-08.** The suite is now 495 lines against the 500-line cap: 5 lines of headroom. | Plan the next addition to this suite as a new file, or split the manifest-branch `Describe` into its own suite at that time. | The cap applies to test files, and the next reviewer or executor adding a single `It` with a comment will breach it. Recording it now avoids that being discovered as a gate failure mid-batch. | `wc -l` returns 495. The parallel suite is at 457 (43 lines of headroom). |
| Informational | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | not changed by this feature | **F-09.** Both suites depend on mutable external state: the first does not mock `Get-PrAuthorCheckpointContent`, and the second executes handlers that read the live orchestration checkpoint from disk. Both consequently fail locally whenever an `epic_mode: true` checkpoint exists and pass in CI where it does not. | File as a separate issue against those two suites. Do not fix here — they are outside this feature's diff and outside its change budget. | This is the direct cause of the two local failures, and it is a real nonconformity with the Determinism requirement in `.claude/rules/general-unit-test.md` ("Tests must not rely on mutable global state or external configuration that can change between runs"). It is a pre-existing repository condition that this orchestration run merely exposed. | `grep -n "Mock"` across `enforce-pr-author-skill.Tests.ps1` lists no `Get-PrAuthorCheckpointContent` mock; the failure message for the second suite names `enforce-epic-wave-barrier.ps1` denying on feature key `'635'`. |
| Informational | `docs/.../spec.md` | D6 must-not-touch list | **F-10.** The list names "the extraction regex strings at epic :147 and parallel :70, and their `.Trim('"''')`", constructs that do not exist at the base commit. Issue #545 replaced them with `Test-CommandLineFlag`, `Get-CommandLineOperand` and `Test-CommandLineInvocation` before this branch was cut. | No change required to the code. When the spec is archived with the feature, annotate D6 with a one-line note that the epic resolved toward R6-B, so a later reader does not read the list as an unmet obligation. | Verified directly against `git show d250cf72:<each hook>`: both anchor copies contain only the structural helpers and neither contains a regex string or a `.Trim` call. The role those constructs carried — invocation detection and operand extraction — is unchanged between `d250cf72` and `4d5ecaca` in both hooks. AC-31 is satisfied in substance. The divergence is inconsequential because the design was written to compose with either D6 resolution, which is the property doing the work here. | Section 8.2 of `policy-audit.2026-09-08T09-04.md`. |
| Informational | `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` | condition 7 | **F-12.** `evidence` is required to be a present, non-empty, non-whitespace string, but its content is not validated. The literal `"x"` satisfies it. | No change. Record the limitation where the claim is made. | `spec.md` describes `evidence` as "the single field that makes a record an auditable verdict rather than a bare allowlist entry". Mechanically it is a bare allowlist entry plus a required unvalidated string. No automated check can assess justification quality, so the design is correct given the constraint; the claim is simply stronger than the check, and a reader should not infer machine-verified justification from a passing gate. | Condition 7 body: `if ($record.evidence -isnot [string] -or [string]::IsNullOrWhiteSpace($record.evidence)) { return $false }`. |

## Positive Observations

These are recorded because they are non-obvious choices that a later change should not undo.

1. **Condition 10 is a presence test, and its comment says why.** Both hooks carry an explicit
   comment ("The coverage test is a PRESENCE test, deliberately not an authorization test") stating
   that reusing the `merge_status` predicate there would reopen the only widening path. The module's
   own docstring repeats the reasoning. This is the single most important correctness property of the
   change and it is documented at both call sites and at the definition.
2. **The epic gate's exclusion ignores `route_id`.** The gate's pre-existing parallel-checkpoint
   branch requires `route_id == "parallel"`; the new exclusion does not. That makes the exclusion
   strictly broader than the branch it sits beside — the conservative direction — and prevents a
   parallel checkpoint with an unexpected `route_id` from becoming a manifest-authorizable gap.
3. **Condition 8 is encoded as an authorized subset.** Every other unknown-value rule in the module
   fails closed; the exclusion-list encoding would have been the only one that failed open, and it
   would have done so silently at the moment a new verdict was added to the vocabulary. The constant
   carries the rationale inline. This should not be "simplified" later into vocabulary-minus-exclusions.
4. **Case-sensitive comparison for every vocabulary member.** `-cne` for `tool`, `-cnotcontains` for
   disposition, verdict and branch state. `safe_to_delete` does not authorize. This is narrower than
   PowerShell's default and is the correct default for an authorization predicate.
5. **The freshness bound does not inherit the epic gate's residual argument.** The specification
   explicitly refuses to carry across the "session-stamped paths make a stale collision implausible"
   argument, on the correct ground that cleanup targets are ordinary long-lived paths. The 24-hour
   bound with an injected clock is the consequence, and the at-bound case is pinned as an explicit
   allow so an off-by-one in either direction is visible.
6. **The test matrix is constructed, not enumerated.** Each case is built from one canonical fixture
   by dropping or replacing exactly one member, so a deny is attributable to that member alone.
   Mock bodies use `[scriptblock]::Create` from literal strings because a `-ModuleName` mock body
   executes in module session state where a test-scope variable will not resolve — a subtlety that is
   both handled and explained in the file docstring.
7. **The fail-before evidence is real.** The two allow tests were observed failing against the unfixed
   hooks at exit code 4, with a complete four-node failing inventory and the reason each node is in
   it. The tests demonstrably discriminate rather than passing vacuously.
8. **The `<N> = 396` fix is a genuine fix, not a substitution.** The replacement text defers the
   body-file and receipt contract to `pr-author`'s own skill rather than restating any value, and
   states the no-issue-number case explicitly. `grep -n "396"` returns no occurrence.
9. **The traceability record states its own negative results.** It records explicitly that no
   criterion asserts the `bash <file>` indirection is closed, and that no criterion asserts a
   permission-layer block — the two places where "37 of 37 passing" would most easily be over-read.
   That is the right instinct and is worth preserving as a practice.

## Verdict

**No blocking findings.** Two Medium findings (F-01, F-02) and five Low or informational findings are
recorded. None meets the remediation trigger defined in `feature-review-workflow`: no toolchain stage
fails, no acceptance criterion is FAIL or PARTIAL, no coverage threshold is missed, and no coverage
artifact is absent for a language with changed files.

Both Medium findings are recommended as follow-up work. F-02 is the more valuable of the two to close,
because it is the one place where the change's own stated invariant ("no force flag is ever added to
any removal spelling") and the skill's own prohibition are not backed by the gate that the rest of the
change so carefully constrains.
