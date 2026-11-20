# 2026-08-19-mermaid-diagram-claude-runtime — Plan

- **Issue:** #491
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-19T08-50
- **Status:** PREFLIGHT: ALL CLEAR (4 rounds). Execution in progress — Phase 0 and Phase 1 complete; Phase 2 partially complete (modules and fence tests on disk, checkboxes pending); resumed after an unrelated API spend-limit termination.
- **Version:** 1.3
- **Work Mode:** full-feature (per `issue.md` marker; AC sources are `spec.md` and `user-story.md`)

## Required References

- Repository tone policy: `.github/copilot-instructions.md`
- General code change policy: `.github/instructions/general-code-change.instructions.md` / `.claude/rules/general-code-change.md`
- General unit test policy: `.github/instructions/general-unit-test.instructions.md` / `.claude/rules/general-unit-test.md`
- PowerShell policy: `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/rules/powershell.md`
- Spec (authoritative, D1–D7 binding): `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/spec.md`
- User story (second AC source): `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/user-story.md`
- Research artifact 1 (grammar table, false-positive rules, fail-open policy): `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/research/mermaid-validation-technology.2026-08-19T08-39.md`
- Research artifact 2 (hook/rule/skill contracts, distribution, coverage mechanics): `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/research/claude-runtime-integration-mechanics.2026-08-19T08-39.md`
- AC tracking protocol: `.claude/skills/acceptance-criteria-tracking/SKILL.md`
- Evidence conventions: `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`

**All work must comply with these policies; do not duplicate their content here. Do not re-open decisions D1–D7. Do not contradict the research artifacts on mechanics.**

## Conventions Used in This Plan

- `<FEATURE>` = `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491`
- `<TS>` = the ISO-8601 timestamp of the actual command run, format `yyyy-MM-ddTHH-mm` (per `evidence-and-timestamp-conventions`). Every evidence artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- All evidence goes under `<FEATURE>/evidence/<kind>/` only. `artifacts/`-rooted evidence paths are forbidden and blocked by `enforce-evidence-locations.ps1`.
- **PowerShell batch budget:** `.claude/hooks/enforce-powershell-batch-budget.ps1` caps each batch at 3 production + 3 test PowerShell files (`.ps1`/`.psm1`/`.psd1`; `tests/**` and `*.Tests.ps1` count as test). Bundled mirror copies of `.psm1`/`.ps1` files count as production files. The reset mechanism documented in the hook's own deny message is deleting `.claude/state/powershell-batch-budget.<session_id>.json`; "start a new batch" tasks below use it. No phase in this plan writes more than 3 production + 3 test PowerShell files per batch.
- **Toolchain loop (PowerShell):** format → lint → test, using the MCP functions mandated by `.claude/rules/powershell.md`:
  1. `mcp__drm-copilot__run_poshqc_format`
  2. `mcp__drm-copilot__run_poshqc_analyze`
  3. `mcp__drm-copilot__run_poshqc_test` (pass/fail gate only — see the coverage caveat below)
  Type checking is not applicable to PowerShell. If any stage fails or auto-fixes files, restart the loop from step 1 and repeat until all stages pass clean in a single pass.
- **Coverage caveat (load-bearing):** the MCP-published PoshQC (`mcp__drm-copilot__run_poshqc_test`) resolves `settings/pester.runsettings.psd1` relative to its own bundled module root and does NOT consume the repo copy at `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. Repo-level `CodeCoverage.Path` registration is therefore inert under the MCP path (verified empirically in this worktree). Every coverage-bearing figure in this plan — baseline, final, and delta — MUST come only from the repo-module run: `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root (Get-Location).Path"`. The MCP call remains valid as a pass/fail test gate; it is never a coverage source.
- **Coverage extraction method:** `artifacts/pester/powershell-coverage.xml` is JaCoCo (`OutputFormat = 'CoverageGutters'`); there is no `line-rate` attribute. Per-file line coverage is computed as `covered / (covered + missed)` summed over the `<counter type="LINE">` elements for the matching `<class sourcefilename="...">` entries.

### Planned module decomposition (fixed by this plan)

Production PowerShell (each file under 500 lines; grammar data separated from validation logic and from fence extraction):

1. `.claude/lib/mermaid/MermaidGrammar.psm1` — data module: diagram-type keyword allowlist (~30 types from research artifact 1 §3, including `C4Context`/`C4Container`/`C4Component`/`C4Dynamic`/`C4Deployment`, `packet` with `packet-beta` alias, the 11.x sidebar keyword-accept types), per-type arrow token sets, the deep-checked type set (flowchart, sequence, class, state, ER), the statement-keyword exemption list (`click`/`style`/`classDef`/`linkStyle`/`class`/`accTitle`/`accDescr`/`title`), plus accessor functions. Module header records the Mermaid 11.17.0 pin and source URL (auditability per D1/spec Inputs).
2. `.claude/lib/mermaid/MermaidLineScanner.psm1` — quote-aware line scanner: `%%` comment stripping outside quoted spans only, `%%{...}%%` directive recognition before comment stripping, quote-aware bracket balance (`[]`, `()`, `{}`; angle brackets never structural; backslash never an escape), unterminated-double-quote detection, line classification (edge / statement-keyword / unclassifiable), sequence pre-colon segmentation.
3. `.claude/lib/mermaid/MermaidMarkdownFences.psm1` — Markdown fence tracker per research artifact 1 §5 (3+ backtick or tilde fences, up to 3 spaces of indentation, blockquote prefixes, fence stack for nesting, `mermaid` info-string first word case-insensitive, unclosed-fence tolerance) plus the D3 opt-out marker detector (`<!-- mermaid-validator: ignore -->` on the immediately preceding line, no intervening lines, one block only).
4. `.claude/lib/mermaid/MermaidValidation.psm1` — orchestration: public `Test-MermaidDiagram -Content <string>` returning the structured result (`Verdict` ∈ `Valid|Invalid|NotJudged`, `DiagramType`, `Findings[{Class;Line;Message}]`, `Warnings[]`), YAML frontmatter/directive/comment skipping, managed-diagram `id:` frontmatter detector, empty/whitespace-body rejection, `subgraph`/`end` pairing, per-type dispatch honoring D4 fail-open items 1–3 and 7, CRLF/LF normalization.
5. `.claude/hooks/enforce-mermaid-validation.ps1` — thin gate: reads `$env:CLAUDE_TOOL_INPUT`; scope check ordered before any content scan; `Join-Path $PSScriptRoot '../lib/mermaid/MermaidValidation.psm1'` import with a fail-open missing-module guard; pure `Invoke-MermaidValidationDecision -ToolInputRaw <string>`; named mockable on-disk reader wrapper (e.g. `Get-MermaidOnDiskContent`) for the Edit managed-diagram check; dot-sourcing guard; read-only-gate header; deny/allow via compact `hookSpecificOutput.permissionDecision` JSON on stdout at exit 0 in every case (never nonzero exit, never `{"decision":"block"}`); reason tokens `MERMAID_VALIDATION_BLOCKED:` and `MERMAID_MANAGED_DIAGRAM_BLOCKED:`; a source comment recording why malformed-input handling deliberately differs from `enforce-evidence-locations.ps1` (D4 item 5); no Python invocation anywhere.

Test files (each under 500 lines; all diagram fixtures as here-strings; on-disk reads via mocked wrapper seams; no temp files, no `Start-Process`, no sleeps — `check-powershell-test-purity.ps1` gates this at authoring time). `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1` rejects sibling `Describe`/`Context`/`It` names differing only by letter case, so all test names — the accept-matrix cases especially — must be distinct beyond capitalization. Subprocess entry-point testing follows the precedent at `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1:54-100`:

- `tests/scripts/claude-lib/mermaid/MermaidGrammar.Tests.ps1`
- `tests/scripts/claude-lib/mermaid/MermaidLineScanner.Tests.ps1`
- `tests/scripts/claude-lib/mermaid/MermaidMarkdownFences.Tests.ps1`
- `tests/scripts/claude-lib/mermaid/MermaidValidation.Tests.ps1`
- `tests/scripts/claude-lib/mermaid/MermaidValidationAcceptMatrix.Tests.ps1` (the false-positive accept matrix — first-class deliverable)
- `tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1`
- `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` (modified)

Documentation surfaces (Markdown; exempt from the 500-line file limit, but SKILL.md body stays under 500 lines per the skill-template checklist):

- `.claude/rules/mermaid.md`
- `.claude/skills/mermaid-diagram/SKILL.md`
- `.claude/skills/mermaid-diagram/references/flowchart.md`, `sequence.md`, `class.md`, `state.md`, `er.md`, `c4.md`, `gantt.md`, `pie.md`, `other-types.md` (9 files, pinned to Mermaid 11.17.0, sourced from the research grammar table, each documenting the `WebFetch` fallback to mermaid.js.org)

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Reading and Baseline Capture

- [x] [P0-T1] Read the policy files in this exact order: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/rules/powershell.md`, `.claude/rules/general-unit-test.md`; record the read in `<FEATURE>/evidence/other/phase0-instructions-read.md`
  - Acceptance: artifact exists with `Timestamp:`, `Policy Order:`, and the explicit list of files read
- [x] [P0-T2] Read the feature context in order: `<FEATURE>/spec.md` (including `## Decisions` D1–D7 and `## Out of Scope`), `<FEATURE>/user-story.md`, `<FEATURE>/issue.md`, `<FEATURE>/research/mermaid-validation-technology.2026-08-19T08-39.md`, `<FEATURE>/research/claude-runtime-integration-mechanics.2026-08-19T08-39.md`, and `.github/instructions/mermaid.instructions.md`; append the read list to `<FEATURE>/evidence/other/phase0-instructions-read.md`
  - Acceptance: artifact lists all six context files with a timestamp
- [x] [P0-T3] Verify the `- Work Mode: full-feature` marker in `<FEATURE>/issue.md` and record in `<FEATURE>/evidence/other/phase0-instructions-read.md` that the AC sources are `spec.md` (AC-1..AC-25) and `user-story.md` per `.claude/skills/acceptance-criteria-tracking/SKILL.md`
  - Acceptance: marker confirmed and AC-source resolution recorded
- [x] [P0-T4] Capture the PSScriptAnalyzer baseline: run `mcp__drm-copilot__run_poshqc_analyze` and write `<FEATURE>/evidence/baseline/poshqc-analyze.<TS>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:` (0 when the tool returns `ok:true`, 1 otherwise), and `Output Summary:` recording the returned `ok` flag and `summary` verbatim; `ok:true` denotes zero findings (the tool returns only `{ok, tool, workspace_root, summary}` and writes no artifact)
- [x] [P0-T5] Capture the Pester baseline with coverage using the repo module (the MCP test tool does not consume the repo runsettings — see the coverage caveat): run `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root (Get-Location).Path"` and write `<FEATURE>/evidence/baseline/poshqc-test.<TS>.md`; then copy `artifacts/pester/powershell-coverage.xml` to `<FEATURE>/evidence/baseline/powershell-coverage.baseline.<TS>.xml` before any later run overwrites it. The runsettings sets a single fixed `OutputPath`, so every full-root run overwrites that one report, and `artifacts/` is gitignored — without this copy the baseline per-file figures are unrecoverable and the P7-T5 comparison has nothing to compare against.
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` including the numeric baseline line-coverage headline from `artifacts/pester/powershell-coverage.xml` (extracted per the Coverage extraction method) and the pass/fail test counts; the recorded command is the repo-module run, not the MCP tool; the preserved baseline report copy exists at `<FEATURE>/evidence/baseline/powershell-coverage.baseline.<TS>.xml` and its `<class sourcefilename=` count is recorded in the artifact
- [x] [P0-T6] Capture the resource-contracts parity baseline: run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` and write `<FEATURE>/evidence/baseline/pytest-resource-contracts.<TS>.md`
  - Acceptance: artifact contains the four schema fields; baseline expected green
- [x] [P0-T7] Capture the Python pack-manifest-completeness baseline: run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -q` and write `<FEATURE>/evidence/baseline/pytest-manifest-completeness.<TS>.md`
  - Acceptance: artifact contains the four schema fields; baseline expected green
- [x] [P0-T8] Capture the TypeScript pack-manifest-completeness baseline: run `cd extensions/drm-copilot && npx jest test/lib/push-down/claude-pack-manifest-completeness.test.ts` and write `<FEATURE>/evidence/baseline/jest-manifest-completeness.<TS>.md`
  - Preconditions: run `cd extensions/drm-copilot && npm ci` first if `extensions/drm-copilot/node_modules` is absent (fresh worktree; `npm ci`, not `npm install`, so `package-lock.json` is never rewritten)
  - Acceptance: artifact contains the four schema fields; baseline expected green
- [x] [P0-T9] Capture the no-Python-invocation baseline: run `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 -Output Detailed"` and write `<FEATURE>/evidence/baseline/no-python-invocation.<TS>.md`
  - Acceptance: artifact contains the four schema fields; baseline expected green
- [x] [P0-T10] Capture the PoshQC bundled-runsettings parity baseline: run `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` and write `<FEATURE>/evidence/baseline/pytest-poshqc-bundled-parity.<TS>.md`
  - Acceptance: artifact contains the four schema fields; baseline expected green (the repo and bundled `pester.runsettings.psd1` copies are byte-identical today)
- [x] [P0-T11] Verify the already-filed potential entry for the MCP coverage defect exists at `docs/features/potential/2026-08-19-mcp-poshqc-test-ignores-repo-runsettings-coverage.md` (filed by the orchestrator; it records that the MCP-published PoshQC resolves its own bundled `settings/pester.runsettings.psd1`, so repo-level `CodeCoverage.Path` registration is inert under the MCP path — affecting all modules registered there, not just this feature) and record the verified path in `<FEATURE>/evidence/other/potential-entries.md`; do not create the entry and do not fix the defect in this plan
  - Acceptance: entry confirmed present on disk; its path recorded in the evidence artifact with a `Timestamp:`

### Phase 1 — Grammar Data and Line Scanner Modules

Batch A: 2 production + 2 test PowerShell files (within the 3+3 cap).

- [x] [P1-T1] Create `.claude/lib/mermaid/MermaidGrammar.psm1` with the keyword allowlist, per-type arrow token sets, deep-checked type set, and statement-keyword exemption list per research artifact 1 §3, with the Mermaid 11.17.0 pin and source URL in the module header, exported via accessor functions
  - Acceptance: file exists, under 500 lines, exports the accessors, header records `Mermaid 11.17.0` and the mermaid.js.org source URL (AC-4 partial)
- [x] [P1-T2] Create `tests/scripts/claude-lib/mermaid/MermaidGrammar.Tests.ps1` covering: every keyword row of the research §3 table resolves in the allowlist (including `C4Context` capitalization, `packet`/`packet-beta` alias, `gitGraph` direction-suffix forms, `pie showData`, `xychart-beta horizontal`); the deep-checked set is exactly {flowchart, sequence, class, state, ER}; arrow-set lookup returns the documented token sets per type; unknown keyword returns no match
  - Acceptance: suite passes; fixtures are literals/here-strings only
- [x] [P1-T3] Create `.claude/lib/mermaid/MermaidLineScanner.psm1` implementing the quote-aware scanner: quoted spans excluded from bracket balance; `\"` never treated as an escape; `%%`-to-EOL stripped outside quoted spans only; `%%{...}%%` directives recognized before comment stripping; unterminated double-quote detection; line classification by first token (edge / statement-keyword / unclassifiable); sequence pre-colon segmentation helper
  - Acceptance: file exists, under 500 lines, functions exported (AC-4 partial)
- [x] [P1-T4] Create `tests/scripts/claude-lib/mermaid/MermaidLineScanner.Tests.ps1` covering: brackets inside quoted labels excluded from balance (`A["foo[bar](baz)"]`); `%%` inside quotes preserved (`A["50%% off"]`); directive not deleted as comment; unbalanced `[]`/`()`/`{}` each detected on a structural line; unterminated quote detected; backslash treated as ordinary character; Unicode content scanned without error; angle brackets (`<br/>`) never counted as structural; statement-keyword classification for each exempted keyword; sequence text after first `:` excluded from arrow scanning
  - Acceptance: suite passes; here-string fixtures only
- [x] [P1-T5] Run the PowerShell toolchain loop for Phase 1 — `mcp__drm-copilot__run_poshqc_format`, then `mcp__drm-copilot__run_poshqc_analyze`, then `mcp__drm-copilot__run_poshqc_test` (pass/fail gate), restarting from format if any stage fails or changes files — and record the clean pass in `<FEATURE>/evidence/qa-gates/phase1-toolchain-pass.<TS>.md`
  - Acceptance: all three stages pass clean in a single pass; artifact records the three commands with `EXIT_CODE:` each

### Phase 2 — Fence Tracker and Validation Core

Batch B: 2 production + 3 test PowerShell files (within the 3+3 cap).

- [x] [P2-T1] Start a new PowerShell batch by deleting `.claude/state/powershell-batch-budget.<session_id>.json` (the reset mechanism documented in `enforce-powershell-batch-budget.ps1`)
  - Acceptance: state file absent; next PowerShell write is not blocked by the budget hook
- [x] [P2-T2] Create `.claude/lib/mermaid/MermaidMarkdownFences.psm1` implementing the research artifact 1 §5 fence tracker (backtick and tilde fences of 3+, up to 3 spaces indentation, blockquote prefixes, fence stack so a `mermaid` fence nested inside an outer open fence is classified as example text, `mermaid` info-string first word case-insensitive, unclosed-fence tolerance) and the D3 opt-out marker detector (exact text `mermaid-validator: ignore` in an HTML comment on the immediately preceding line, no intervening lines, scope one block)
  - Acceptance: file exists, under 500 lines, exports fence extraction returning per-block content, start line, nesting flag, and opt-out flag (AC-4 partial)
- [x] [P2-T3] Create `tests/scripts/claude-lib/mermaid/MermaidMarkdownFences.Tests.ps1` covering: plain backtick fence extracted; tilde fence extracted; fence indented 3 spaces recognized; blockquote-prefixed fence recognized; `mermaid` fence nested inside an outer 4-backtick fence flagged as nested (not a diagram); unclosed fence tolerated; info-string case-insensitivity (` ```Mermaid `); opt-out marker immediately above the fence sets the flag; marker separated by a blank line does NOT set the flag; marker applies to exactly one block (second block unflagged)
  - Acceptance: suite passes; here-string fixtures only
- [x] [P2-T4] Create `.claude/lib/mermaid/MermaidValidation.psm1` with public `Test-MermaidDiagram -Content <string>` returning the structured result object (`Verdict`, `DiagramType`, `Findings` with line numbers, `Warnings`), implementing: YAML frontmatter/directive/blank/comment skipping before keyword resolution; malformed-frontmatter detection; managed-diagram `id:` frontmatter detector (exported for the hook); empty/whitespace-body rejection; missing or clearly non-keyword first line rejected, unknown-but-plausible keyword warn-and-allow (D4 item 1); deep checks (bracket/quote balance, per-type arrows, `subgraph`/`end` pairing) only for the deep-checked set; keyword-only checking for non-deep and ZenUML types (D4 items 2, 7); unclassifiable lines skipped (D4 item 3); CRLF/LF-identical verdicts
  - Acceptance: file exists, under 500 lines, imports the Phase 1 modules via `$PSScriptRoot`-relative paths, header records the 11.17.0 pin (AC-4 complete)
- [x] [P2-T5] Create `tests/scripts/claude-lib/mermaid/MermaidValidation.Tests.ps1` covering defect detection and fail-open: one valid here-string accepted per deep-checked type (flowchart, sequence, class, state, ER) plus at least one free-text type (gantt) and one keyword-only type; missing first line rejected; first line starting with an arrow/bracket rejected; misspelled keyword (`flowchar TD`) rejected with the defect named; unknown plausible keyword (`venn`) allowed with a drift warning (AC-9 item 1); per-type invalid arrow rejected for each deep-checked type (e.g. `->>` in flowchart, `--o` misuse in sequence, invalid ER cardinality token) with line number in the finding (AC-7); unbalanced `[]`, `()`, `{}` and unterminated quote each rejected (AC-6); `subgraph` without `end` rejected; empty and whitespace-only bodies rejected, CRLF vs LF byte-equivalent verdicts, frontmatter-bearing diagrams (`title`, `config`, `id`) validated past the frontmatter (AC-10); `id:` detector positive and negative
  - Acceptance: suite passes; every rejection case asserts the finding class and line number; here-strings only (AC-5, AC-6, AC-7, AC-10, AC-9 items 1–3 and 7)
- [x] [P2-T6] Create `tests/scripts/claude-lib/mermaid/MermaidValidationAcceptMatrix.Tests.ps1` — the false-positive accept matrix, one named `It` accept-case per construct from research artifact 1 §4: (1) brackets inside quoted labels `A["foo[bar](baz)"]`; (2) `#quot;` entity in a label with `\"` never treated as an escape; (3) `#35;` and `&amp;` entities; (4) Markdown strings in backticks ``A["`**bold**`"]``; (5) Unicode label text; (6) `%%` inside quoted spans; (7) `subgraph` block with `direction` statement and free-text title; (8) one accept-case per statement keyword `click`/`style`/`classDef`/`linkStyle`/`class`/`accTitle`/`accDescr`/`title` carrying URLs/CSS/free text; (9) `<br/>` and angle brackets in labels; (10) sequence message free text after the first `:` containing `-`, `>`, and brackets; (11) free-text diagram-type body with unbalanced-looking text (gantt task `Deploy (phase 1`); (12) backslashes as ordinary characters
  - Acceptance: every listed construct has a named passing accept-case asserting `Verdict` is `Valid` or `NotJudged`, never `Invalid` (AC-8); all `Describe`/`Context`/`It` names are distinct beyond letter case (enforced by `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1`)
- [x] [P2-T7] Verify accept-matrix completeness: cross-check the `It` names in `tests/scripts/claude-lib/mermaid/MermaidValidationAcceptMatrix.Tests.ps1` against the research artifact 1 §4 construct table row by row and record the mapping in `<FEATURE>/evidence/other/accept-matrix-crosscheck.<TS>.md`
  - Acceptance: artifact maps every §4 construct to a named test case with none missing
- [x] [P2-T8] Run the PowerShell toolchain loop for Phase 2 — `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test` (pass/fail gate), restarting from format if any stage fails or changes files — and record the clean pass in `<FEATURE>/evidence/qa-gates/phase2-toolchain-pass.<TS>.md`
  - Acceptance: all three stages pass clean in a single pass; artifact records the three commands with `EXIT_CODE:` each

### Phase 3 — Hook, Registration, and Coverage Opt-In

Batch C: 3 production (hook `.ps1`, repo `pester.runsettings.psd1`, bundled `pester.runsettings.psd1`) + 2 test PowerShell files (exactly at the 3+3 cap). `settings.json` is JSON and not budget-counted. Because the batch has zero production headroom, P3-T8 resets the batch before the toolchain loop so any corrective edit surfaced by the loop has a full budget.

- [x] [P3-T1] Start a new PowerShell batch by deleting `.claude/state/powershell-batch-budget.<session_id>.json`
  - Acceptance: state file absent
- [x] [P3-T2] Create `.claude/hooks/enforce-mermaid-validation.ps1` per the Planned module decomposition item 5: `$env:CLAUDE_TOOL_INPUT` input; extension/content scope check ordered before any content scan; `Join-Path $PSScriptRoot '../lib/mermaid/MermaidValidation.psm1'` import guarded by `Test-Path` failing OPEN when the module is missing; pure `Invoke-MermaidValidationDecision -ToolInputRaw <string>` returning the decision object or `$null`; named mockable on-disk reader wrapper for the Edit managed-diagram check; syntax validation on `Write` content for `.mmd`/`.mermaid` paths and for fenced ```` ```mermaid ```` blocks in Markdown (D2); Edit syntax path allows (D4 item 4); managed-diagram (`id:`) guard denies Edit and Write on `.mmd`/`.mermaid` paths via the reader seam; D3 opt-out honored per block; fail-open on empty/absent/unparseable input, missing `file_path`, out-of-scope paths (D4 item 5) with the source comment recording the deliberate difference from `enforce-evidence-locations.ps1`; deny reasons formatted `MERMAID_VALIDATION_BLOCKED: <defect class, line number> ... See .claude/skills/mermaid-diagram/SKILL.md.` and `MERMAID_MANAGED_DIAGRAM_BLOCKED: ... <sync workflow pointer>`; compact JSON on stdout, exit 0 always; dot-sourcing guard; read-only header; no Python leg
  - Acceptance: file exists, under 500 lines, satisfies every named contract element (AC-3 partial, AC-23 precondition)
- [x] [P3-T3] Create `tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1` covering: deny on invalid `.mmd` Write with `MERMAID_VALIDATION_BLOCKED:` naming defect, line number, and the SKILL.md pointer; allow on valid `.mmd` Write (AC-11); Markdown Write with an invalid fence denied, valid fence allowed, non-Mermaid Markdown allowed, non-Mermaid file path allowed untouched, `mermaid` fence nested inside an outer fence allowed (AC-12); opt-out marker allows exactly the marked invalid block while a second unmarked invalid block in the same write is still denied (AC-13); managed-diagram deny for both `Edit` and `Write` on an `id:`-frontmatter `.mmd` via `Mock` of the reader wrapper, with `MERMAID_MANAGED_DIAGRAM_BLOCKED:` reason (AC-14); fail-open allows for empty/absent/unparseable `CLAUDE_TOOL_INPUT`, missing `file_path`, out-of-scope path, and Edit payloads with unreconstructable diagram content (AC-15, AC-9 items 4–6); missing-module guard fails open; entry-point cases asserting compact JSON on stdout and exit code 0 on both allow and deny (AC-16 partial); a named negative-control `It` (e.g. `negative control: gate rejects a deliberately invalid diagram end-to-end`) driving a deliberately invalid here-string through `Invoke-MermaidValidationDecision` and asserting the deny decision (AC-17)
  - Acceptance: suite passes; all fixtures are here-strings; on-disk reads only via the mocked wrapper (AC-25)
- [x] [P3-T4] Update `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`: add an `It` block asserting the round-tripped `hookSpecificOutput` deny shape for `enforce-mermaid-validation.ps1`, and update the hardcoded hook count in all three occurrences — line 6 ("all 14 PreToolUse hooks"), line 20 ("14 assertion blocks"), and line 32 (`Describe 'PreToolUse deny-schema contract (all 14 hooks)'`) — from 14 to 15
  - Acceptance: the new `It` passes and all three count occurrences read 15 (AC-16 complete)
- [x] [P3-T5] Update `.claude/settings.json`: append `{"type": "command", "command": "pwsh -NoProfile -File .claude/hooks/enforce-mermaid-validation.ps1"}` inside the existing `"matcher": "Write|Edit"` hooks block
  - Acceptance: JSON valid; entry present in the `Write|Edit` matcher (AC-3 complete)
- [x] [P3-T6] Update `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`: append `.claude/hooks/enforce-mermaid-validation.ps1`, `.claude/lib/mermaid/MermaidGrammar.psm1`, `.claude/lib/mermaid/MermaidLineScanner.psm1`, `.claude/lib/mermaid/MermaidMarkdownFences.psm1`, `.claude/lib/mermaid/MermaidValidation.psm1` to `CodeCoverage.Path` with an issue-#491 comment
  - Acceptance: all five entries present with the comment (AC-22 partial)
- [x] [P3-T7] Copy the edited `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` byte-identically to `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` (the parity suite `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` asserts exact text equality between the two copies)
  - Acceptance: both copies byte-identical; `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` green
- [x] [P3-T8] Start a new PowerShell batch by deleting `.claude/state/powershell-batch-budget.<session_id>.json` before the Phase 3 toolchain loop — batch C sits at its 3-production cap after P3-T7, so a corrective Edit to any Phase-1 or Phase-2 module surfaced by the loop would otherwise be denied mid-loop
  - Acceptance: state file absent
- [x] [P3-T9] Run the PowerShell toolchain loop for Phase 3 — `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test` (pass/fail gate), restarting from format on any failure or file change — then run the coverage-bearing repo-module command `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root (Get-Location).Path"` and confirm the five new production files appear in `artifacts/pester/powershell-coverage.xml` with line coverage >= 85% each, computed as `covered / (covered + missed)` over the `LINE` counters per the Coverage extraction method
  - Acceptance: clean single toolchain pass; per-file line coverage for the five new files recorded from the repo-module run (never from the MCP run) and >= 85%

### Phase 4 — Rule, Skill, and Syntax References

Markdown only; no PowerShell budget impact. Note: the hook is registered as of Phase 3, so any ```` ```mermaid ```` example written in these files must be valid or carry the D3 opt-out marker.

- [x] [P4-T1] Create `.claude/rules/mermaid.md` with frontmatter `paths: ["**/*.mmd", "**/*.mermaid"]` and `description:` per research artifact 2 §3.3, and a body stating the diagram file conventions, the validation mandate, the managed-diagram (`id:` frontmatter) do-not-hand-edit constraint pointing at the sync workflow, the D3 opt-out marker syntax and scope, and the out-of-scope record for the non-portable `mermaidChart.*` mechanisms (shared with the skill per AC-18)
  - Acceptance: frontmatter matches the research §3.3 shape; all four content elements present (AC-1)
- [x] [P4-T2] Create `.claude/skills/mermaid-diagram/SKILL.md` with `name: mermaid-diagram` and the research-artifact-2 description frontmatter; body (under 500 lines) containing: the generate → validate → render workflow; eight generation recipe sections matching the eight `@mermaid-chart` slash-command intents (`/generate_diagram_from_code`, `/generate_execution_sequence`, `/generate_er_diagram`, `/generate_cloud_architecture_diagram`, `/generate_docker_diagram`, `/generate_c4_topdown_architecture`, `/analyze_code_ownership`, `/generate_dependency_diagram`); the D6 conditional rendering paths (`Artifact` → `SendUserFile display: render` → file path plus VS Code preview route, with GitHub native fence rendering noted) and the statement that the hook performs no rendering; the D3 opt-out marker documentation; the explicit statement that the structural gate rejects the named defect classes and does not prove validity; pointers to `references/*.md` pinned to Mermaid 11.17.0 with the documented `WebFetch` fallback to mermaid.js.org; and the D7 out-of-scope record with reasons
  - Acceptance: all named sections present; body under 500 lines (AC-2 partial, AC-18 partial)
- [x] [P4-T3] Create `.claude/skills/mermaid-diagram/references/flowchart.md`, `sequence.md`, `class.md`, and `state.md` from the research artifact 1 §3 grammar table: first-line keyword forms, arrow/edge token sets, structural conventions, and at least one valid example each, pinned to Mermaid 11.17.0 with the `WebFetch` fallback noted
  - Acceptance: four files exist with keyword forms and arrow sets matching the research table
- [x] [P4-T4] Create `.claude/skills/mermaid-diagram/references/er.md`, `c4.md`, `gantt.md`, `pie.md`, and `other-types.md` (the last covering the remaining keyword-only types from the research table: journey, quadrant, requirement, gitGraph, mindmap, timeline, zenuml, sankey-beta, xychart-beta, block-beta, packet, kanban, architecture-beta, radar-beta, treemap-beta, info, and the 11.x sidebar additions), same pinning and fallback convention
  - Acceptance: five files exist; `other-types.md` lists every remaining table keyword (AC-2 complete)
- [x] [P4-T5] Update `.claude/settings.json`: add `"Skill(mermaid-diagram *)"` to `permissions.allow` (conventional entry per research artifact 2 §4.3)
  - Acceptance: entry present; JSON valid
- [x] [P4-T6] Verify capability completeness: walk `.github/instructions/mermaid.instructions.md` end to end (three LM tools, the workflow, all sixteen `mermaidChart.*` command IDs, the eight slash commands, the seven rules, the sync-cooperation rule) and record a row-by-row disposition table in `<FEATURE>/evidence/other/capability-completeness.<TS>.md` proving each capability is either ported by a named delivered surface or listed in the skill/rule out-of-scope record with the spec's stated reason
  - Acceptance: artifact covers every named mechanism with zero silent drops (AC-18 complete)
- [x] [P4-T7] Verify every ```` ```mermaid ```` example embedded in the new rule, SKILL.md, and references files passes `Test-MermaidDiagram` (or carries the D3 marker where a counter-example is deliberate) by running the validator over each embedded block, and record the result in `<FEATURE>/evidence/other/doc-examples-validation.<TS>.md`
  - Acceptance: zero invalid unmarked examples; artifact lists each file and per-block verdict

### Phase 5 — Distribution: Mirrors, Manifest, and Distribution Negative Controls

Mirror `.psm1`/`.ps1` copies are budget-counted production files: two batches of at most 3.

- [x] [P5-T1] [expect-fail] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` BEFORE creating any mirror and record the failure in `<FEATURE>/evidence/regression-testing/distribution-negative-control-parity.<TS>.md`
  - Preconditions: delete `.claude/state/powershell-batch-budget.<session_id>.json` first — the parity suite walks repo `.claude/**` via `rglob` without reading `.gitignore`, so the session-scoped budget state file would otherwise produce an unrelated `Repo file missing from bundle` failure
  - Acceptance: artifact shows EXIT_CODE nonzero with the assertion message naming a new `.claude` file missing from the bundle (pytest aborts at the first failed assertion, so exactly one path is named — `.claude/hooks/enforce-mermaid-validation.ps1`, first in sorted order) — the parity gate is shown capable of failing (AC-21 partial)
- [x] [P5-T2] Start a new PowerShell batch by deleting `.claude/state/powershell-batch-budget.<session_id>.json`
  - Acceptance: state file absent
- [x] [P5-T3] Create byte-identical mirrors `extensions/drm-copilot/resources/claude-customizations/.claude/lib/mermaid/MermaidGrammar.psm1`, `.../MermaidLineScanner.psm1`, and `.../MermaidMarkdownFences.psm1` (3 production files — full batch)
  - Acceptance: each mirror byte-identical to its repo source
- [x] [P5-T4] Start a new PowerShell batch by deleting `.claude/state/powershell-batch-budget.<session_id>.json`
  - Acceptance: state file absent
- [x] [P5-T5] Create byte-identical mirrors `extensions/drm-copilot/resources/claude-customizations/.claude/lib/mermaid/MermaidValidation.psm1` and `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-mermaid-validation.ps1` (2 production files)
  - Acceptance: each mirror byte-identical to its repo source
- [x] [P5-T6] Create byte-identical mirrors of the Markdown surfaces under `extensions/drm-copilot/resources/claude-customizations/.claude/`: `rules/mermaid.md`, `skills/mermaid-diagram/SKILL.md`, and all nine `skills/mermaid-diagram/references/*.md`
  - Acceptance: eleven mirrors byte-identical to their repo sources
- [x] [P5-T7] Apply the Phase 3/4 `settings.json` edits (hook registration in the `Write|Edit` matcher and the `Skill(mermaid-diagram *)` allow entry) to `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` so it is byte-identical to `.claude/settings.json`
  - Acceptance: mirrored `settings.json` byte-identical to the repo copy (AC-19 partial)
- [x] [P5-T8] [expect-fail] Run both completeness suites BEFORE adding `core.json` entries — `cd extensions/drm-copilot && npx jest test/lib/push-down/claude-pack-manifest-completeness.test.ts`; and `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -q` — and record both failures in `<FEATURE>/evidence/regression-testing/distribution-negative-control-manifest.<TS>.md`
  - Acceptance: artifact shows both suites failing, with the split expectations recorded exactly: the TypeScript failing list names `.claude/hooks/enforce-mermaid-validation.ps1`, `.claude/rules/mermaid.md`, `.claude/skills/mermaid-diagram/SKILL.md`, and the four `.claude/lib/mermaid/*.psm1` files (it walks `rules/*.md` and recursive `lib/**`); the Python failing list names only the hook and SKILL.md (it enumerates only `agents/*.md`, `hooks/*`, and `skills/<name>/SKILL.md` — not `rules/` or `lib/`); BOTH lists omit every `references/*.md` file — the D5 unguarded class, motivating P5-T10 (AC-21 partial)
- [x] [P5-T9] Update `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: add entries `.claude/hooks/enforce-mermaid-validation.ps1`, `.claude/rules/mermaid.md`, `.claude/skills/mermaid-diagram/SKILL.md`, `.claude/lib/mermaid/MermaidGrammar.psm1`, `.claude/lib/mermaid/MermaidLineScanner.psm1`, `.claude/lib/mermaid/MermaidMarkdownFences.psm1`, `.claude/lib/mermaid/MermaidValidation.psm1`
  - Acceptance: seven entries present; JSON valid
- [x] [P5-T10] Update `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: add one explicit entry per skill reference file — `.claude/skills/mermaid-diagram/references/flowchart.md`, `sequence.md`, `class.md`, `state.md`, `er.md`, `c4.md`, `gantt.md`, `pie.md`, `other-types.md` — the class NEITHER completeness suite enumerates (D5; precedent `core.json` entry for `human-exception-runbook/example.runbook.md`); then verify by searching `core.json` for each of the nine paths
  - Acceptance: all nine reference entries present, each confirmed by search; verification recorded in `<FEATURE>/evidence/other/core-json-references-verification.<TS>.md` (AC-20)
- [x] [P5-T11] Re-run all three distribution suites and record the green results in `<FEATURE>/evidence/regression-testing/distribution-after.<TS>.md`: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -q`; `cd extensions/drm-copilot && npx jest test/lib/push-down/claude-pack-manifest-completeness.test.ts`
  - Preconditions: delete `.claude/state/powershell-batch-budget.<session_id>.json` first (the P5-T3/P5-T5 mirror writes recreated it, and the resource-contracts suite enumerates it as a repo `.claude` file with no bundle counterpart)
  - Acceptance: all three EXIT_CODE 0; before/after pairing with P5-T1 and P5-T8 completes the distribution negative control (AC-19, AC-21 complete)
- [x] [P5-T12] Verify the already-filed potential entry for the parity-suite defect exists at `docs/features/potential/2026-08-19-claude-resource-parity-enumerates-gitignored-state.md` (filed by the orchestrator; it records that `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` should exclude `.claude/state/**` the same way it excludes `.claude/agent-memory/**`, because that path is session-scoped, gitignored runtime state and is never distributable) and append the verified path to `<FEATURE>/evidence/other/potential-entries.md` (the fixed-name artifact P0-T11 created); do not create the entry and do not fix the test in this plan
  - Acceptance: entry confirmed present on disk; its path appended to the same evidence artifact with a `Timestamp:`

### Phase 6 — End-to-End Gate Controls

- [x] [P6-T1] Demonstrate the gate failing end-to-end: in `pwsh -NoProfile`, set `$env:CLAUDE_TOOL_INPUT` to a `Write` payload for a `.mmd` path whose content declares `flowchart TD` but contains a sequence arrow `->>` and an unclosed bracket, invoke `pwsh -NoProfile -File .claude/hooks/enforce-mermaid-validation.ps1`, and capture stdout and `$LASTEXITCODE` in `<FEATURE>/evidence/regression-testing/hook-negative-control.<TS>.md`
  - Acceptance: stdout is compact deny JSON with `permissionDecision` `deny` and a `MERMAID_VALIDATION_BLOCKED:` reason naming the defect and line; exit code 0 (AC-17 end-to-end evidence)
- [x] [P6-T2] Demonstrate the gate passing: repeat P6-T1 with a valid flowchart payload and capture stdout and exit code in `<FEATURE>/evidence/regression-testing/hook-positive-control.<TS>.md`
  - Acceptance: allow decision (or silent allow per the implemented convention); exit code 0
- [x] [P6-T3] Demonstrate the Markdown and opt-out paths live: repeat the invocation with (a) a Markdown `Write` payload containing an invalid ```` ```mermaid ```` fence (expect deny) and (b) the same payload with `<!-- mermaid-validator: ignore -->` immediately above the fence (expect allow); record both in `<FEATURE>/evidence/regression-testing/hook-markdown-optout-control.<TS>.md`
  - Acceptance: deny then allow, both exit code 0 (D2/D3 live evidence)

### Phase 7 — Final QA Loop, Coverage Delta, and AC Check-Off

Final-QC command tasks are unconditional; `SKIPPED` is not a valid outcome for any of them. If any loop stage fails or changes files, restart from P7-T2 and re-record; each artifact must come from the final clean pass.

- [x] [P7-T1] Start a new PowerShell batch by deleting `.claude/state/powershell-batch-budget.<session_id>.json` so the QA fix-up loop has a full 3+3 budget (after P5-T4's reset, P5-T5 consumed 2 of 3 production slots); this deletion also removes the parity-breaking session state file — the same mechanism serves both purposes and P7-T7's precondition repeats it only if the loop's writes recreate the file
  - Acceptance: state file absent
- [x] [P7-T2] Run `mcp__drm-copilot__run_poshqc_format` and record `<FEATURE>/evidence/qa-gates/final-poshqc-format.<TS>.md`
  - Acceptance: artifact has the four schema fields; no files changed on the final pass
- [x] [P7-T3] Run `mcp__drm-copilot__run_poshqc_analyze` and record `<FEATURE>/evidence/qa-gates/final-poshqc-analyze.<TS>.md`
  - Acceptance: artifact has the four schema fields (`EXIT_CODE:` 0 when `ok:true`); `Output Summary:` records the returned `ok` and `summary` verbatim; `ok:true` denotes zero findings
- [x] [P7-T4] Run the coverage-bearing final test pass with the repo module (type checking is not applicable to PowerShell): `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root (Get-Location).Path"` and record `<FEATURE>/evidence/qa-gates/final-poshqc-test.<TS>.md`; the MCP `run_poshqc_test` gate may additionally be run, but coverage figures come only from this repo-module run (see the coverage caveat)
  - Acceptance: artifact has the four schema fields; `Output Summary:` includes the numeric overall line-coverage headline from `artifacts/pester/powershell-coverage.xml` and pass/fail counts; all tests green; recorded command is the repo-module run
- [x] [P7-T5] Verify the coverage delta: compare the P0-T5 baseline against the P7-T4 result and extract per-file line coverage for the five new production files from `artifacts/pester/powershell-coverage.xml`, computing each file as `covered / (covered + missed)` over the `<counter type="LINE">` elements for the matching `sourcefilename` (JaCoCo format; no `line-rate` attribute exists); record baseline coverage, post-change coverage, and new-file coverage in `<FEATURE>/evidence/qa-gates/coverage-delta.<TS>.md`
  - Acceptance: numeric values recorded, no placeholders; both compared runs use the same repo-module command; the final run's `CodeCoverage.Path` set equals the baseline set plus exactly the five files registered by P3-T6, so the overall-headline difference is stated explicitly and never treated as a regression; the no-regression check is performed per-file over the files common to both runs, comparing the P7-T4 report at `artifacts/pester/powershell-coverage.xml` against the preserved baseline copy at `<FEATURE>/evidence/baseline/powershell-coverage.baseline.<TS>.xml` written by P0-T5 (the live report path is overwritten by every run, so the preserved copy is the only baseline); the >= 85% line-coverage threshold check applies to the five new files (AC-22 complete)
- [x] [P7-T6] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -q` and record `<FEATURE>/evidence/qa-gates/final-pytest-manifest-completeness.<TS>.md`
  - Acceptance: EXIT_CODE 0
- [x] [P7-T7] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` and record `<FEATURE>/evidence/qa-gates/final-pytest-resource-contracts.<TS>.md`
  - Preconditions: delete `.claude/state/powershell-batch-budget.<session_id>.json` if it was recreated by any PowerShell write since P7-T1 (the suite enumerates repo `.claude/**` without reading `.gitignore`)
  - Acceptance: EXIT_CODE 0 (AC-19 final evidence)
- [x] [P7-T8] Run `cd extensions/drm-copilot && npx jest test/lib/push-down/claude-pack-manifest-completeness.test.ts` and record `<FEATURE>/evidence/qa-gates/final-jest-manifest-completeness.<TS>.md`
  - Acceptance: EXIT_CODE 0 (AC-20 final evidence)
- [x] [P7-T9] Run `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` and record `<FEATURE>/evidence/qa-gates/final-pytest-poshqc-bundled-parity.<TS>.md`
  - Acceptance: EXIT_CODE 0 — the P3-T6 runsettings edit and its P3-T7 bundled mirror remain byte-identical
- [x] [P7-T10] Run `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 -Output Detailed"` and record `<FEATURE>/evidence/qa-gates/final-no-python-invocation.<TS>.md`
  - Acceptance: EXIT_CODE 0; suite green against the new hook and lib files (AC-23)
- [x] [P7-T11] Verify no dependency-manifest change: run `git diff main --name-only -- package.json extensions/drm-copilot/package.json pyproject.toml` and record the (empty) output in `<FEATURE>/evidence/qa-gates/dependency-manifest-check.<TS>.md`
  - Acceptance: output empty — no new third-party dependency (AC-24)
- [x] [P7-T12] Verify the 500-line limit for every new PowerShell production and test file (the five production files and the six new/modified test files) via line counts, recorded in `<FEATURE>/evidence/qa-gates/file-size-check.<TS>.md`
  - Acceptance: every file at or under 500 lines
- [x] [P7-T13] Verify test purity: confirm `check-powershell-test-purity.ps1` did not fire on any new test file during execution and that no test uses temp files, `Start-Process`, sleeps, or unmocked on-disk reads; record in `<FEATURE>/evidence/qa-gates/test-purity-check.<TS>.md`
  - Acceptance: zero purity violations (AC-25)
- [x] [P7-T14] Check off acceptance criteria per `.claude/skills/acceptance-criteria-tracking/SKILL.md` in BOTH sources: `<FEATURE>/spec.md` (AC-1 through AC-25 and Definition of Done items with per-criterion evidence) and `<FEATURE>/user-story.md` (story-level criteria), changing only `- [ ]` to `- [x]` for verified items, and record the required AC Status Summary (source, totals, checked, remaining) in `<FEATURE>/evidence/other/ac-summary.<TS>.md`
  - Acceptance: every verified AC checked in both files; unverified items left unchecked with the gap documented; summary artifact present

## Test Plan

- **Unit (lib):** `tests/scripts/claude-lib/mermaid/` — grammar table integrity, quote-aware scanner behavior, fence tracker rules, defect-class rejection (keyword, brackets, quotes, arrows, subgraph/end, empty body), the twelve-construct false-positive accept matrix, the D4 fail-open items 1–3 and 7, CRLF/LF equivalence, frontmatter handling, `id:` detection.
- **Unit (hook):** `tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1` — deny/allow per AC-11..AC-17, D4 fail-open items 4–6, managed-diagram guard through the mocked reader seam, missing-module fail-open, entry-point protocol (compact JSON, exit 0 both paths), named negative-control case.
- **Contract:** new `It` in `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` (deny-shape round trip, hook count).
- **Distribution:** `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `claude-pack-manifest-completeness.test.ts` — each shown failing before the mirror/manifest edits (P5-T1, P5-T8) and green after (P5-T11, P7-T6..T8), plus the `test_poshqc_bundled_parity.py` runsettings-parity gate (P0-T10, P3-T7, P7-T9).
- **End-to-end:** live hook invocations in Phase 6 (deny, allow, Markdown fence, opt-out).
- **Coverage evidence:** baseline `<FEATURE>/evidence/baseline/poshqc-test.<TS>.md` (P0-T5); final `<FEATURE>/evidence/qa-gates/final-poshqc-test.<TS>.md` (P7-T4); comparison `<FEATURE>/evidence/qa-gates/coverage-delta.<TS>.md` (P7-T5). All three come from repo-module `Invoke-PoshQCTest` runs, never from `mcp__drm-copilot__run_poshqc_test`, whose bundled runsettings ignore the repo `CodeCoverage.Path` registration (see the coverage caveat; underlying defect recorded at `docs/features/potential/2026-08-19-mcp-poshqc-test-ignores-repo-runsettings-coverage.md`, verified at P0-T11). Per-file figures use the JaCoCo `LINE` counter formula. PowerShell line coverage only; no branch-coverage gate applies to Pester per `.claude/rules/quality-tiers.md`. Python and TypeScript production code is not modified by this feature, so no Python/TS coverage tasks apply; their suites run as distribution gates only.

## Open Questions / Notes

- The mid-session effectiveness of the Phase 3 hook registration depends on when Claude Code snapshots hook config; no plan task depends on the live hook firing before Phase 6, and Phase 6 invokes the hook directly as a subprocess, which is registration-independent.
- Mirror `.psm1`/`.ps1` copies count against the PowerShell batch budget as production files; Phase 5 is split into two batches (3 + 2) for that reason. If the budget hook is later shown to exempt `extensions/**`, the split is harmless.
- `quality-tiers.yml` does not exist at repo root and must not be created (spec Out of Scope item 9).
- `CLAUDE.md` indexing of the new rule is optional (no test enforces it; research artifact 2 §3.4) and is deliberately omitted from this plan.
- Validator gate: this plan must pass `mcp__drm-copilot__validate_orchestration_artifacts` with `artifact_type: "plan"` and `artifact_path: docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/plan.2026-08-19T08-50.md`, and preflight validation through `atomic-executor` (`DIRECTIVE: PREFLIGHT VALIDATION ONLY`) before execution. Revisions loop through this same file path.
