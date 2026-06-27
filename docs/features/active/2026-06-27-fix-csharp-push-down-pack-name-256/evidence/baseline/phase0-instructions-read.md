# Phase 0 — Policy Instructions Read (Issue #256)

Timestamp: 2026-06-27T14-16

Policy Order: CLAUDE.md → repository tone/communication policy → general code-change policy → general unit-test policy → TypeScript language-specific code-change and unit-test policies → `.claude/rules` mirrors.

Files read (in required order):

1. `CLAUDE.md`
2. `.github/copilot-instructions.md`
3. `.github/instructions/general-code-change.instructions.md`
4. `.github/instructions/general-unit-test.instructions.md`
5. `.github/instructions/typescript-code-change.instructions.md`
6. `.github/instructions/typescript-unit-test.instructions.md`
7. `.claude/rules/general-code-change.md`
8. `.claude/rules/general-unit-test.md`
9. `.claude/rules/typescript.md`
10. `.claude/rules/typescript-suppressions.md`

Scope confirmation: Single in-scope language is TypeScript (extension source under `extensions/drm-copilot/`). No bundled-runtime mirror sync (`.claude`/`.codex`/`.agents`) is required for this change. No new runtime dependencies. Production/test file size limit 500 lines.
