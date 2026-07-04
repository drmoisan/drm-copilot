# AC-to-Task Map (Issue #279)

- Timestamp: 2026-07-03T14-30

## Mapping

- AC1 (all six paths added to `core.json`, correct positions) -> P1-T1. Verified: `core.json` diff contains exactly the six additive insertions in the specified positions (immediately before `.claude/agents/epic-review.md`; immediately before `.claude/hooks/enforce-evidence-locations.ps1`; immediately before `.claude/hooks/enforce-pr-author-skill.ps1`; immediately before `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`), with no existing path removed or reordered.
- AC2 (`packages/mcp-server/resources/claude-customizations/pack-manifests/core.json` not hand-edited) -> Scope note (no implementation task; verified during planning and re-confirmed during execution). Re-confirmation: `git status`/`git diff` for this execution session touched only `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and the new test file under `extensions/drm-copilot/test/`; no changes were made under `packages/mcp-server/resources/`.
- AC3 (real-filesystem completeness test, no hardcoded expected-file list) -> P1-T2. Verified: `claude-pack-manifest-completeness.test.ts` enumerates `.claude/agents/*.md`, `.claude/skills/*/SKILL.md`, and `.claude/hooks/*.ps1` via `node:fs`/`node:path` resolved from `__dirname`, and parses the real `pack-manifests/*.json` files; it does not use `buildInMemoryFileSystem` or a hardcoded expected-file list.
- AC4 (test fails against pre-fix manifest; covers the six specific paths) -> P1-T3 and P1-T4. Verified: P1-T3 added six explicit `it.each` assertions naming each of the six paths; P1-T4 captured a failing run (EXIT_CODE 1, all six paths listed as missing) against a temporarily reverted `core.json`, then restored the fix and confirmed a clean pass (EXIT_CODE 0). Evidence: `docs/features/active/2026-07-03-core-pack-manifest-missing-epic-orchestrate-files-279/evidence/regression-testing/fail-before.2026-07-03T14-30.md`.
- AC5 (full TypeScript toolchain passes cleanly, no coverage regression on changed lines) -> Phase 2 (P2-T1 through P2-T5).

## Notes

During P1-T4 execution, the pre-existing working-tree state of `core.json` was found to contain only 5 of the 6 required P1-T1 insertions (the `.claude/skills/epic-orchestrate/SKILL.md` insertion was missing). This was corrected as part of completing P1-T1's own acceptance criteria before the fail-before proof was finalized; see the fail-before artifact referenced above for the full correction record.
