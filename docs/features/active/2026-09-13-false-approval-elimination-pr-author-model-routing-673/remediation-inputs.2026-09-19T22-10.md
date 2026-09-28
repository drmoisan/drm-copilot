# Preflight delta — fourth pass (Issue #673)

- Source: `atomic-executor` under `DIRECTIVE: PREFLIGHT VALIDATION ONLY`, fourth pass, 2026-09-19
- Plan of record validated: `plan.2026-09-19T09-00.md` (revised in place after the third delta)
- Verdict: **PREFLIGHT: REVISIONS REQUIRED**
- **CONVERGENCE: NO FURTHER ROUNDS EXPECTED** — all three blocking findings are text-local: one phrase in a copied detail expression plus its §2.7.4 restatement, one acceptance clause in [P10-T3], and one sentence in §4 with its §2.7.1 echo. None changes a design decision, a task order, or a test inventory, and no further count, absence, "not edited", or zero-invocation condition contradicts the tree.
- Nothing was created, modified, or deleted by the preflight pass.

Revise `plan.2026-09-19T09-00.md` in place. Three blocking, three non-blocking.

## Confirmed correct this pass — do not re-derive

F1's rewording (the filename literal is on exactly `:160` and `:368`, no comment carries it, the replacement contains no filename, and no test asserts the old reason text, so all three conditions become satisfiable). F2's application and the production half of the sweep (`Join-WorktreeResolutionPath` defined at `:311`, exported only at `:341-347`, absent from the other module's list, called once at `:381`; the accessor route through the dot-sourced helpers at `helpers:27` is real and load-bearing; the model-routing gate carries no worktree-resolution token and [P10-T1] pins every branch, so "reads properties only" holds; no second production instance). F4's eleven call sites with `:488` inside the surviving row at `:481-497`, whose assertions read neither `Signal` nor `SignalValue`. Every re-derived citation in the regions the last round touched, all four line counts, and the plan's zero score against all four host-token matchers including the account name.

## Blocking findings

### B1 — [P9-T4]: the `:394` detail cannot be both copied unchanged and free of the phrase the same task forbids

Self-contradiction class, sixth appearance.

The plan says `:394`'s detail expression is "copied unchanged", §2.7.4 says "the emitted code and the detail text are identical", and the task's acceptance requires the phrase `derived target` to occur nowhere in the file. The tree shows `:394` reads `... does not exist under the derived target worktree, so the call's target cannot be confirmed`. After the task's other rewrites, `:394` is the only surviving occurrence, so the acceptance cannot pass while the instruction is obeyed.

Fix: amend the `:394` clause to "copied with `derived target worktree` replaced by `resolved target worktree`, changing nothing else", and amend §2.7.4 to say the emitted code is identical and the detail differs only in that phrase. The rewording is safe: no test asserts that detail text — the only repository match is a comment at `TargetResolution.Tests.ps1:482`, and the surviving row asserts only deny, the ambiguity code, and the absence of the work-mode phrase.

### B2 — [P10-T3]: the strengthened acceptance states a false reason for one file and asks an unanswerable question for another

The clause says both the pr-author helpers and the prd gate "each additionally import `WorktreeTargetResolution.psm1`, because each calls a function exported only by that module", and requires the artifact to record, for every library function called, which imported module exports it.

The tree shows two problems:

1. The pr-author helpers' only two worktree-resolution calls are `Resolve-WorktreeCallTarget` (`:61`) and `Join-WorktreeResolutionPath` (`:99`), and DD-1/DD-2 replace both. After Phase 5 neither retained import serves a call in that file. What does depend on them is `enforce-pr-author-skill.TargetResolution.Tests.ps1`, which has no `Import-Module` line and, after [P5-T5] replaces the literals with accessor calls, resolves the accessors through the dot-sourced helpers.
2. The prd gate's two accessor calls are exported by `WorktreeResolution.psm1`, which the gate does not import; they resolve through the dot-sourced helpers' import at `helpers:27` — the mechanism §2.7.1 records as sound. A truthful per-call mapping therefore contradicts "which imported module exports it".

Fix: replace the clause with three conditions —
- the prd gate imports `WorktreeTargetResolution.psm1` because it calls `Join-WorktreeResolutionPath`, exported only there;
- the pr-author helpers retain both F1 imports because the suites that dot-source them resolve the reason-code accessors and the result constructor through that session state;
- the mapping requirement admits a third category, "exported by a module imported by a file dot-sourced into the same session state, named by file and line", with "resolvable only by a transitive import" defined as the module-nesting case — a sibling module's function reached through a pinned `Export-ModuleMember` list — which is the case the condition exists to catch.

### B3 — §4's import sentence and §2.7.1's sweep line contradict the tree and four acceptance conditions

§4 says "All three are imported explicitly in every suite, never relied on transitively" and §2.7.1's sweep line says "Every test suite imports all three modules explicitly per §4".

The tree shows `enforce-prd-feature-before-planner.Tests.ps1` and `.FolderResolution.Tests.ps1` contain zero `Import-Module` lines yet call `New-WorktreeResolutionTargetResult` (`:13`, `:28`) and, in FolderResolution, `Get-WorktreeResolutionAmbiguityReasonCode` (`:126`, `:145`); `.TargetResolution.Tests.ps1` imports two of three (`:109-110`) and after [P9-T5] step 4 will mock `Resolve-WorktreeItemTarget` without importing its module; `enforce-pr-author-skill.TargetResolution.Tests.ps1` imports nothing and will call both accessors after [P5-T5]. [P9-T6]'s "touches exactly four lines" and [P9-T7]'s "touches only the blanket-mock line and lines inside the row" forbid adding the imports, so the §4 sentence and those acceptance conditions cannot both hold.

Fix: scope the §4 sentence to the suites this plan authors ([P2-T3], [P4-T3], [P4-T4], [P8-T6], [P9-T9]) and add one sentence recording that the four pre-existing suites resolve library commands through the dot-sourced hook and helpers — sound for the reason already stated for the fixture helper — and that no task adds an import to them. Correct the §2.7.1 sweep line to the same effect.

## Non-blocking findings

### N1 — [P9-T5] step 5 leaves a comment the same step falsifies

`TargetResolution.Tests.ps1:405-406` reads "A NoTarget result carries a null SignalValue, so the tie stays unresolved and the deny comes from the tie branch, not the derivation's own ambiguity branch." Step 5 changes the injected status to `SessionRoot` and DD-7 makes the checkpoint the disambiguator, so both halves become false, and no acceptance condition detects it.

Fix: add the comment to step 5's instruction, as step 8 already does for `:17-25` and `:165-166`.

### N2 — the reworded `:347` detail must retain a substring pinned elsewhere

[P9-T5] step 5 keeps the assertion at `:417` (`*cites 2 feature folders*`) and [P9-T12] gates on that row, while [P9-T4]/DD-7 say only that the detail is "changed to name the checkpoint rather than a derived target".

Fix: state in [P9-T4] that the replacement retains the `cites $($candidates.Count) feature folders ($($candidates -join ', '))` clause.

### N3 — [P9-T5] step 6's eleven line numbers name each call's first line only

Every `-SignalValue` argument sits on the continuation line (`:251, :317, :333, :347, :359, :376, :394, :431, :451, :473, :489`). The exemption prose already says "its composed folder-shaped value", so this is a precision note.

Fix: add "(value on the following line)" to remove the last ambiguity about what the `:488` exemption covers.
