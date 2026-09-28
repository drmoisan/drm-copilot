# PreToolUse Envelope Consumption by F1's Target Derivation

Timestamp: 2026-09-17T10-43

Method: read the parameter list and body of the target-derivation function named in `f1-identifier-binding.2026-09-17T10-41.md` — `Resolve-WorktreeCallTarget`, `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` lines 227-303 — and searched both F1 modules for envelope field names.

## ENVELOPE-ROOT-FIELD: NONE

Basis:

- `Resolve-WorktreeCallTarget`'s `param()` block (lines 250-257) declares exactly four parameters: `[string] $Text`, `[string] $Branch`, `[string] $FilePath`, `[string] $SessionRoot`. None of them is an envelope or a payload object, so the function cannot read a root-level envelope field from an argument it is not given.
- Its body reads no envelope field. The three signal readers it calls (`Find-WorktreeResolutionFeatureFolderSignal`, `Find-WorktreeResolutionFilePathSignal`, `Find-WorktreeResolutionBranchSignal`) scan the supplied `-Text` with the three regular expressions declared at lines 53, 57, and 61. When `-SessionRoot` is not supplied the function falls back to `(Get-Location).ProviderPath` at line 261, which is a process property and not an envelope field.
- A search of both F1 modules for `cwd` and `session_id` returns no match.

Consequence: the caller, not F1, is responsible for extracting text from the envelope. `[P4-T4]` therefore passes the envelope root (`$envelope.Envelope`, surfaced by `Resolve-ClaudeHookToolInput` on its `Envelope` member at `.claude/lib/hook-payload/HookPayload.psm1` line 481) together with the nested `tool_input` object into the hook's own text composition, and hands the composed text to `Resolve-WorktreeCallTarget -Text`. F1 remains free of envelope knowledge.

No envelope capture is included, because the determination is `NONE` and the capture is required only for the field-list form.

## `[P0-T8]` second halt arm — evaluated here, not deferred

The arm fires only when this artifact records `ENVELOPE-ROOT-FIELD: NONE` **and** the `[P0-T8]` artifact records `F1-DISTINGUISHES: NO`. The `[P0-T8]` artifact records `F1-DISTINGUISHES: YES`: `Resolve-WorktreeCallTarget` separates preamble ruling 8 state B (`Status = 'NoTarget'`, no signal present, line 277) from state C (`Status = 'Ambiguous'`, a present signal that resolves to zero or several worktrees, lines 286 and 297). The conjunction is therefore false, the arm does not fire, and execution proceeds to `[P0-T10]`. The production discriminator between state B and state C is F1's `Status` value, not the test-only injection parameter.

Research record item K3 is closed by this determination: no hook in this repository reads an envelope working-directory field, and F1 does not introduce one.
