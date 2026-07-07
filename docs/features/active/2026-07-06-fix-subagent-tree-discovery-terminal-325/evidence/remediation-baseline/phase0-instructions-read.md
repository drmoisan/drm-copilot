# Phase 0 — Policy Instructions Read (P0-T1)

**Timestamp:** 2026-07-06T23-44

**Policy Order:**

1. `CLAUDE.md` — checked at the repository root; no `CLAUDE.md` file exists at
   the repository root in this worktree (confirmed via glob search). Standing
   instructions for this session are instead supplied via the auto-loaded
   `.claude/rules/*.md` files listed below, which were read in full.
2. `.claude/rules/general-code-change.md` — read in full (cross-language code
   change policy: design principles, mandatory toolchain loop, 500-line file
   size limit, error handling, naming, dependencies, I/O boundaries).
3. `.claude/rules/general-unit-test.md` — read in full (cross-language unit
   test policy: core principles, coverage thresholds 85%/75%, coverage
   exclusion policy, scenario completeness, AAA structure, test file
   location).
4. `.claude/rules/typescript.md` — read in full (TypeScript toolchain order,
   coding standards, ESLint stack, testing standards, architecture
   boundaries, determinism).
5. `.claude/rules/typescript-suppressions.md` — read in full (suppression
   authorization policy: pre-authorized single-line `eslint-disable-next-line`
   and `@ts-expect-error` patterns with `-- <reason>`; prohibited file-level
   suppressions).
6. `.claude/rules/architecture-boundaries.md` — read in full (No-COM
   architecture assertions; TypeScript layer boundaries enforced via
   `dependency-cruiser`).

All six file paths above were read, in the stated order, before any edit
in this remediation cycle began.
