# Preflight delta — third pass (Issue #673)

- Source: `atomic-executor` under `DIRECTIVE: PREFLIGHT VALIDATION ONLY`, third pass, 2026-09-19
- Plan of record validated: `plan.2026-09-19T09-00.md` (revised in place after the second delta)
- Verdict: **PREFLIGHT: REVISIONS REQUIRED**
- Validator gate: plan validation passed, exit 0, no `PLAN GATE WARNING:` lines.
- Nothing was created, modified, or deleted by the preflight pass.

Revise `plan.2026-09-19T09-00.md` in place. Four blocking findings, four non-blocking, and one orchestrator ruling on F2.

## Confirmed fixed in the tree — do not re-derive

B1 (all four `Get-PrdFeatureAmbiguityDecision` call sites accounted for; the `:394` conversion preserves code and detail; the `:393` conjunct present exactly once so `FolderResolution.Tests.ps1:338-349` survives byte-unchanged). B4 (`:34-68` is exactly the two helpers; `:69` closes the source `BeforeAll`). B5 (eight paths at [P10-T5], the ninth at [P11-T9] with a porcelain companion). B6 (exactly nine rule-5 applications; every commit task states the post-commit/pre-append order; the final empty-porcelain assertion is reachable because `/artifacts` and `.claude/state/` are git-ignored and the scratchpad is outside the repository). Both self-found contradictions (the `-Envelope` hyphen form matches only the four removed occurrences; the changed-lines restatement is correct and the file has exactly three matcher-visible literals). D2's counts (fourteen occurrences less four deletions leaves the stated ten; the two prd-suite token counts are right; step 4's structural assertion reads no live location). Rule numbering (1 through 7, no duplicate, both numeric cross-references resolve). Task identifiers sequential across twelve phases. All thirteen [P0-T5] line counts, every F1 citation, the nine [P5-T6] call lines, `core.json:169-170`, the four manifest path lists, the runsettings and analyzer citations, the three skill insertion points, and the #672 spec's two unchecked criteria.

## Orchestrator ruling on F2 — decided, do not re-open

F2 offers two options. **Take option (a): the gate keeps its `WorktreeTargetResolution.psm1` import and adds the `WorktreeItemResolution.psm1` import, mirroring `enforce-pr-author-skill-helpers.ps1:38-39`.**

Reasons: it is the minimal change; it follows a precedent already in the tree for exactly this reason; it leaves the new module's export surface at the eight functions §2.1 specifies; and it keeps DD-8's claim that `:379-382` is unchanged, so no probe-path edit, no ninth export, and no rise in [P2-T2]/[P2-T3]/[P2-T6]'s counts. Option (b) would change the new module's API to work around a scoping rule the tree already has a convention for.

Update [P9-T4], RS-12, DD-8, and [P10-T3]'s acceptance (which currently expects that file to import `WorktreeItemResolution.psm1` only) to match.

## Blocking findings

### F1 — the checkpoint filename survives in a deny reason three acceptance conditions require to be gone

[P9-T4]'s acceptance requires `orchestrator-state.json` to match no line in `.claude/hooks/enforce-prd-feature-before-planner.ps1`; [P9-T10] adds that file to the literal test's array; [P10-T1] requires zero code matches across the five in-scope hook files.

The literal occurs twice. `:160` is the `-CheckpointPath` default that DD-6 removes. `:368` is inside the double-quoted `permissionDecisionReason` of the `must reference a feature folder` deny — and DD-7's own bullet states that deny at `:363-371` is unchanged. Three acceptance conditions therefore cannot pass, and [P9-T12]'s requirement that the eighth row be Passed with zero root failures cannot hold.

Fix: instruct [P9-T4] to reword `:368` so the reason names the checkpoint without the filename, quoting the exact replacement text in the task prose, as [P5-T2] and [P7-T2] already do for their files. Do not narrow the three conditions to exempt the string: that would leave in place a code-path literal this feature exists to remove.

### F2 — the import swap removes `Join-WorktreeResolutionPath` from the gate's scope

`Join-WorktreeResolutionPath` is defined only in `WorktreeTargetResolution.psm1:311` and exported by that file's explicit `Export-ModuleMember -Function` list at `:341-346`. `WorktreeResolution.psm1`'s export list at `:490-500` does not contain it, and the gate's only other library import arrives through the dot-sourced helpers, which import `WorktreeResolution.psm1` alone (`helpers:27`). A sibling imported inside a module whose exports are pinned by an explicit list is not re-exported to that module's importer — which is why `enforce-pr-author-skill-helpers.ps1` imports both modules explicitly at `:38` and `:39`.

Consequence: `enforce-prd-feature-before-planner.ps1:381` becomes an unresolvable command on every `OtherWorktree` result — the coordinator case this feature exists to fix. [P9-T9] row 1 (twelve live worktrees, expect `allow`) cannot pass, and [P9-T12] and [P11-T4] fail with it.

Fix: apply the orchestrator ruling above (option (a)).

### F3 — [P9-T5] step 4 mocks `Resolve-WorktreeItemTarget` in the wrong session state

After DD-4 the call to `Resolve-WorktreeItemTarget` sits in `Resolve-PrdFeatureWorktreeTarget`, defined in the hook `.ps1` the suite dot-sources into its `BeforeAll` scope (`enforce-prd-feature-before-planner.TargetResolution.Tests.ps1:101-102`) — not inside module `WorktreeItemResolution`. `-ModuleName` intercepts only calls originating inside the named module. The suite's three working seam mocks at `:182`, `:190`, `:201` correctly use no `-ModuleName` for exactly this reason, while §4's `Get-WorktreeItemLiveRoot` mocks are correctly module-scoped because those are called from inside `Resolve-WorktreeItemTarget`.

Consequence: the mock does not intercept, the capture stays unset, and the `IsPathRooted` assertion fails. Worse, the real resolver then runs and enumerates the host's live worktrees, making the row host-dependent — the determinism property issue #672's spec demands of this suite and that [P11-T9] checks off on the strength of [P10-T7], whose token counts cannot see an enumeration reached indirectly through the library.

Fix: in step 4, specify `Mock -CommandName Resolve-WorktreeItemTarget` in the test scope with no `-ModuleName`, matching `:182`/`:190`/`:201`, and record in the step why this one mock is scope-different from the module-scoped mocks §4 mandates elsewhere.

### F4 — [P9-T5] step 6 contradicts the task's own protected-row guarantee

Step 6 requires every `New-ModelledTarget` call site to pass a branch name in place of a folder or file path, while the same task's acceptance states the surviving row `denies with the ambiguity reason when the folder is absent from the target root` is unedited, and §2.7.4 states the row is not among [P9-T5]'s edits.

There are eleven `New-ModelledTarget` call sites: `:250`, `:316`, `:332`, `:346`, `:358`, `:375`, `:393`, `:430`, `:450`, `:472`, `:488`. The call at `:488-489` lies inside that row and passes a composed folder path. The row's closing brace is `:497`, not `:496`.

Fix: exempt `:488` from step 6 by name, stating the reason (after DD-7 the gate reads no `SignalValue`, so a folder-shaped value there is inert), and correct the cited span to `:481-497`.

## Non-blocking findings — fix in the same round

### F5 — production doc comments left asserting the removed behaviour

[P9-T4] rewrites only the file-header `.DESCRIPTION` (`:14-59`) and [P9-T3] only two `.DESCRIPTION` blocks (`helpers:217-221`, `:254-265`). These become factually false and no acceptance condition detects them:

- `enforce-prd-feature-before-planner.ps1:238-253` — `Get-PrdFeatureCallTarget`'s `.DESCRIPTION`, stating it "supplies the session root from the envelope's own cwd field" and that "the derivation keeps only the worktrees under which that repo-relative path exists".
- `:325-326` — "The envelope root is read here for the first time: it carries the session's own cwd".
- `:104` — "Issue #669 owns worktree location, call-target derivation, and path normalisation" ([P9-T4] preserves `:105-107` and says nothing about `:104`).
- `enforce-prd-feature-before-planner-helpers.ps1:213-215` and `:248-253` — both `.SYNOPSIS` blocks naming the derived target as the disambiguator; plus body comments at `:284` and `:289-291`.

Fix: enumerate these in [P9-T3] and [P9-T4] and add one acceptance condition that can fail, for example that the token `derived target` occurs in neither file.

### F6 — rule 7 states a closed set of synthetic roots that the tree and three tasks contradict

Rule 7 names two literals as the synthetic roots. A third, `/synthetic-worktrees/session-root`, is already in the tree at `enforce-prd-feature-before-planner.Tests.ps1:13` and `.FolderResolution.Tests.ps1:28`, and [P9-T5] step 2, [P9-T6] and [P9-T7] all require it. Rule 7 is "binding on every task", so the executor faces a conflict at three tasks.

Fix: restate rule 7 as a form rule — a bare string literal under `/synthetic-worktrees/`, optionally composed with a loop index — and name the current members as examples rather than as the set.

### F7 — §2.7.6 mis-binds a `core.json` citation, and [P1-T2] copies §2.7 into `spec.md` verbatim

§2.7.6 says the two F1 module paths "are already registered in `core.json:48-49`". The tree shows `:48-49` registers the two prd gate files and `:169-170` the two F1 modules; RS-9 cites `:169-170` correctly and [P2-T4] inserts after `:170`.

Fix: split the sentence so `:48-49` attaches to the two gate files and `:169-170` to the two modules. This matters more than usual because [P1-T2] copies §2.7 into `spec.md` verbatim.

### F8 — [P9-T9] permits what [P10-T7] later gates at zero, with no task between to repair it

[P9-T5]'s acceptance forbids `Get-Location` in the TargetResolution suite. [P9-T9]'s acceptance forbids `Set-Location` and `CurrentDirectory` but not `Get-Location`, a non-exempt `Resolve-Path`, or a source-control invocation — yet [P10-T7] requires all five counts to be 0 for both suites. A conforming [P9-T9] file could fail [P10-T7] with no later task able to fix it.

Fix: add the three missing prohibitions to [P9-T9]'s acceptance.

## Minor note — no delta required

§2.2's description of a resolved result omits `WorktreeRoot`, the one field DD-1, DD-3, DD-6 and DD-8 all read. It is self-enforcing: `New-WorktreeResolutionTargetResult` throws for a resolved state without it, so no acceptance condition is at risk.
