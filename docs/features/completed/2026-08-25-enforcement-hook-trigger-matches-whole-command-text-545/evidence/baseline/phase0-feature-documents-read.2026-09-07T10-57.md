# Phase 0 — Feature Documents Read

Timestamp: 2026-09-07T10-57

Task: [P0-T2]

Command: (documentation read; no shell command executed)

EXIT_CODE: 0

## Paths read (six)

1. `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md` (1745 lines)
2. `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/issue.md` (284 lines)
3. `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/user-story.md` (88 lines)
4. `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/research/2026-08-25T09-45-enforcement-hook-trigger-matches-whole-command-text-research.md` (368 lines)
5. `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/research/2026-09-06T23-30-command-word-parser-rederivation-research.md` (1836 lines)
6. `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/research/2026-09-06T23-40-shared-helper-registration-and-copyset-research.md` (839 lines)

## Design-decision identifiers D1 through D12, as recorded in `spec.md`

- **D1** — Selected remedy: masked-trigger scanning with a wrapper carve-out, plus structural relocation classification. Rejected alternatives A (naive segment-leading classifier), B (promote the #539 exemption parser wholesale), and C (any Python leg).
- **D2** — Behavior contract, normative. Piece 1 the command scanner (segment records, heredoc state machine); Piece 2 masked trigger evaluation per segment with the three ordered scan-text clauses and the fourteen-member wrapper carve-out set; Piece 3 the structural relocation classifier with its six numbered steps. Decision rules R1 through R6.
- **D3** — The fail-closed argument, form by form. Fifteen-row table; every row is an obligation on the test surface.
- **D4** — Residual accepted risks: over-match persists inside wrapper-led segments; obfuscated respellings remain ungated; an unlisted wrapper whose quoted argument is a command line would newly pass.
- **D5** — `enforce-promotion-mcp-only.ps1` is in scope (settled).
- **D6** — The pr-author under-match is in scope (settled).
- **D7** — The shared helper is a dot-sourced `.ps1` named `hook-command-scanner.ps1`, not a `.psm1` under `.claude/lib/`. Registration count corrected to five registry files carrying seven entries plus four file copies, per helper file.
- **D8** — Issue #539's `spec.md` is annotated additively at five named locations, never rewritten in place.
- **D9** — Synchronization contract: two deliberately divergent synchronized pairs. Claude pair content-equal, Codex pair byte-identical. Five-registry-file registration checklist.
- **D10** — Promotion-hook `gh` relocation is in scope (settled; reverses a prior Non-Goal).
- **D11** — **The whole Bash-classifying hook family is in scope** (settled; reverses the prior Non-Goal that deferred five hooks to a single follow-up candidate). Nine Claude-side hook files. Sub-decisions: D11.1 module form stays a dot-sourced `.ps1`; D11.2 the parser ships as two files from the start, giving fourteen entries across five registry files plus eight file copies; D11.3 `validate-bash.ps1` needs a matching-primitive change (token equality replacing `String.Contains`) with all six literals byte-unchanged; D11.4 the wrapper carve-out set stays pinned as a single named constant; D11.5 a cross-runtime divergence is folded in as an in-scope defect; D11.6 two follow-ups that are NOT delivered here.
- **D12** — **Public Parser Contract**, normative, consumed by epic children D and G. Signatures for `Read-CommandLineSegment` (in `hook-command-scanner.ps1`) and `Test-CommandLineInvocation`, `Get-CommandLineOperand`, `Get-CommandLineFlagValue`, `Test-CommandLineFlag`, `Test-CommandLineMention` (in `hook-command-invocation.ps1`), plus the three constant accessors `Get-CommandLineWrapperName`, `Get-CommandLineTransparentWrapperName`, and `Get-CommandLineGlobalOption`. The segment record carries eight properties: `RawText`, `MaskedText`, `Tokens`, `CommandWord`, `IsWrapperLed`, `HasLiveSubstitution`, `Unbalanced`, `ScanText`.

## Acceptance-criteria source

`spec.md` is the sole acceptance-criteria source under `full-bug`. It carries 37 checkbox criteria under `## Acceptance Criteria`. `user-story.md` is present but carries no acceptance criteria.

## Acceptance test identifiers observed in the spec Test Strategy

AT-1 through AT-7 (main table), AT-8 through AT-10 (`validate-bash.ps1`, D11.3), AT-11 and AT-12 (`enforce-parallel-abandon-gate.ps1`). AT-6 passes today and must keep passing; AT-1 through AT-5 and AT-7 fail against the current hooks by construction.

Output Summary: All six documents were read. Design decisions D1 through D12 are enumerated above, including D11 (the scope reversal that widens scope to nine hooks) and D12 (the public parser contract consumed by epic children D and G). The acceptance-criteria source is `spec.md` with 37 criteria.
