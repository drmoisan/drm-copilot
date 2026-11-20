# Phase 0 — Policy Reads (Issue #479)

Timestamp: 2026-08-16T23-50

Policy Order: repository-mandated order per `CLAUDE.md` "Policy Compliance Reading Order" and the `policy-compliance-order` skill — (1) repository tone policy, (2) baseline code-change policy, (3) baseline unit-test policy, (4) language-specific policies for the in-scope languages, then the domain rule files being amended.

## Files Read (in order)

1. `.github/copilot-instructions.md` — repository tone and communication policy.
2. `.github/instructions/general-code-change.instructions.md` — baseline code change rules (bugfix workflow, 500-line file limit, mandatory four-stage toolchain loop with restart-on-change).
3. `.github/instructions/general-unit-test.instructions.md` — baseline unit test rules (independence, isolation, determinism, no temporary files).
4. `.github/instructions/python-code-change.instructions.md` — Black / Ruff / Pyright, suppression authorization, typing and module structure.
5. `.github/instructions/python-unit-test.instructions.md` — Pytest as the sole Python test runner.
6. `.github/instructions/typescript-code-change.instructions.md` — Prettier / ESLint / tsc, suppression authorization.
7. `.github/instructions/typescript-unit-test.instructions.md` — Jest, `.test.ts` suffix, mirrored layout.
8. `.github/instructions/powershell-code-change.instructions.md` — PoshQC MCP toolchain contract.
9. `.github/instructions/powershell-unit-test.instructions.md` — Pester 5.x via the MCP test function.
10. `.claude/rules/shell.md` — bash toolchain (shfmt, shellcheck, bats, kcov), discovery contract, `.claude/lib/bash/` root inclusion, kcov line-coverage-only note.
11. `.claude/rules/parallel-orchestration.md` — the prose contract being amended by this feature (orchestrator invariants 1-21, planner P1-P9, manifest M1-M7, Concurrency Bound (A7), Enum Ownership, no-JSON-Schema enforcement).

## Standing Rules Also In Context

- `CLAUDE.md` (project instructions), `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, `.claude/rules/orchestrator-state.md`.

## Constraints Extracted For This Feature

- 500-line ceiling applies to production code, test code, and reusable scripts (Markdown documentation is exempt).
- Toolchain loop order per language: format -> lint -> type-check (N/A for PowerShell and bash) -> test; restart from step 1 on any failure or file modification.
- Coverage: line >= 85% uniformly; branch >= 75% for languages whose tooling measures branch coverage. Pester and kcov do not measure branch coverage, so PowerShell and bash are exempt from the branch threshold only.
- No JSON Schema file may be authored or imported for the parallel artifacts; enforcement is prose plus validator logic.
- Policy documents under `.claude/rules/` and `.github/instructions/` must not be modified, with the single exception that `.claude/rules/parallel-orchestration.md` is the artifact this spec explicitly directs the executor to amend (spec.md "Note on rule-file edits").
