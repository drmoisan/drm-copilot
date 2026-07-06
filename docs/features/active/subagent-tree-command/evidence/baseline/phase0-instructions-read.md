# Phase 0 — Policy Instructions Read

Timestamp: 2026-07-05T22-39

Policy Order:
1. `.claude/rules/general-code-change.md`
2. `.claude/rules/general-unit-test.md`
3. `.claude/rules/typescript.md`
4. `.claude/rules/typescript-suppressions.md`
5. `.claude/rules/architecture-boundaries.md`
6. `.claude/rules/quality-tiers.md`

Files read (in order, in full, before touching code):
- [x] `.claude/rules/general-code-change.md` — cross-language code change policy (simplicity, reusability, extensibility, separation of concerns, mandatory toolchain loop, 500-line file limit, error handling, naming, public APIs, dependencies, I/O boundaries).
- [x] `.claude/rules/general-unit-test.md` — cross-language unit test policy (independence/isolation/fast/determinism/readability, 85% line / 75% branch coverage, no-exclusion policy, AAA structure, no temp files, test file location mirrors `src/`).
- [x] `.claude/rules/typescript.md` — TypeScript standards, noting this plan's binding override: the `drm-copilot` extension uses Jest (not Vitest) with v8 coverage per its established convention.
- [x] `.claude/rules/typescript-suppressions.md` — suppression authorization policy (pre-authorized single-line ESLint/`@ts-expect-error` patterns only; no file-level or `@ts-ignore`/`@ts-nocheck`).
- [x] `.claude/rules/architecture-boundaries.md` — No-COM architecture assertions and layer boundary rules; `dependency-cruiser` is the TypeScript enforcement tool (not configured for this extension, so Phase 7 uses a manual `grep` per the plan).
- [x] `.claude/rules/quality-tiers.md` — T1–T4 module rigor tiers; this module is T3/T4 dev tooling, so uniform coverage thresholds (85% line / 75% branch) apply and property-based/mutation testing are not required.
