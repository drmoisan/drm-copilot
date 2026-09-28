# Phase 0 — Policy Instructions Read

Timestamp: 2026-09-07T10-57

Task: [P0-T1]

Policy Order: `CLAUDE.md` -> `.github/copilot-instructions.md` -> `.claude/rules/general-code-change.md` -> `.claude/rules/general-unit-test.md` -> `.claude/rules/powershell.md` -> `.claude/rules/quality-tiers.md` -> `.claude/rules/tonality.md`

## Files read, in the mandated order

1. `CLAUDE.md` (56 lines) — repository standing instructions: tone policy, policy compliance reading order, four-layer runtime architecture, orchestration checkpoint path.
2. `.github/copilot-instructions.md` (8 lines) — authoritative tone policy: professional, factual, neutral; no humor, metaphor, hype, or filler.
3. `.claude/rules/general-code-change.md` (80 lines) — design principles, module rigor tiers, mandatory seven-stage toolchain loop, 500-line file cap, error handling, naming, dependency and I/O boundary rules.
4. `.claude/rules/general-unit-test.md` (105 lines) — five core unit-test properties, coverage requirements (line >= 85%, branch >= 75% where measurable), Coverage Exclusion Policy, scenario completeness, Arrange-Act-Assert, prohibition on temporary files in tests, test file location rules, determinism infrastructure.
5. `.claude/rules/powershell.md` (97 lines) — PoshQC toolchain order (format -> analyze -> test), PowerShell 7+ compatibility, advanced-function coding standards, change budget (per-batch cap of 3 production and 3 test files), design seams, Pester testing standards, deterministic test requirements, mocking rules, prohibited behaviors.
6. `.claude/rules/quality-tiers.md` (51 lines) — T1-T4 tier definitions, `quality-tiers.yml` as source of truth, uniform-versus-tier-dependent gate matrix, rationale for uniform coverage thresholds and the PowerShell branch-coverage exemption.
7. `.claude/rules/tonality.md` (80 lines) — required professional tone, prohibitions on humor, hyperbole, and unrestricted metaphor, evidence-first wording, difficult-message guidance.

## Constraints extracted that bind this plan

- PowerShell per-batch cap: at most 3 production files and 3 test files. The plan's Change budget and batching section enumerates every batch against this cap.
- File size cap: 500 lines for production, test, and reusable script files.
- PowerShell toolchain order: format -> analyze -> test; restart from step 1 if any stage fails or rewrites a file.
- Line coverage >= 85% on every changed or added production PowerShell file. Pester measures no branch coverage, so no branch gate applies; the measurement obligation is unchanged.
- Tests must use no temporary file, no live executable, no network, and no child process.
- Do not modify anything under `.claude/rules/` or `.github/instructions/`.

Command: (documentation read; no shell command executed)

EXIT_CODE: 0

Output Summary: All seven policy files were read in the mandated order and are enumerated above with their line counts and the substantive content each contributes. No policy file was modified.
