# Phase 0 — Policy Instructions Read

Timestamp: 2026-07-18T11-12

Policy Order: CLAUDE.md -> .claude/rules/general-code-change.md -> .claude/rules/general-unit-test.md -> .claude/rules/python.md -> .github/instructions/general-code-change.instructions.md -> .github/instructions/general-unit-test.instructions.md -> .github/instructions/python-code-change.instructions.md -> .github/instructions/python-unit-test.instructions.md -> .github/instructions/python-suppressions.instructions.md

Files read (in required precedence order):

1. `CLAUDE.md` (standing instructions, loaded via project context)
2. `.claude/rules/general-code-change.md` (cross-language code change policy, loaded via project context)
3. `.claude/rules/general-unit-test.md` (cross-language unit test policy, loaded via project context)
4. `.claude/rules/python.md` (Python toolchain and coding standards — read in session)
5. `.github/instructions/general-code-change.instructions.md` (baseline code change rules — referenced; cross-language content mirrored in `.claude/rules/general-code-change.md` read above)
6. `.github/instructions/general-unit-test.instructions.md` (baseline unit test rules — referenced; cross-language content mirrored in `.claude/rules/general-unit-test.md` read above)
7. `.github/instructions/python-code-change.instructions.md` (Python code change policy — read in session)
8. `.github/instructions/python-unit-test.instructions.md` (Python unit test policy — read in session)
9. `.github/instructions/python-suppressions.instructions.md` (pre-authorized suppression patterns — read in session)

Notes:
- Language in scope: Python only.
- Coverage is mandatory: line >= 85%, branch >= 75%, no regression on changed lines.
- Toolchain order: Black -> Ruff -> Pyright -> Pytest with coverage; restart from format on any failure or file change.
- File-size limit: no production or test file may exceed 500 lines.
- Domain-neutrality invariant applies to all production analyzer modules.
- Suppressions must match a pre-authorized pattern or have explicit approval.

## Remediation Cycle 1 (2026-07-18T13-10)

Timestamp: 2026-07-18T13-10

Policy Order: CLAUDE.md -> .claude/rules/general-code-change.md -> .claude/rules/general-unit-test.md -> .claude/rules/python.md -> .github/instructions/general-code-change.instructions.md -> .github/instructions/general-unit-test.instructions.md -> .github/instructions/python-code-change.instructions.md -> .github/instructions/python-unit-test.instructions.md

Files read (in required precedence order):

1. `CLAUDE.md` (standing instructions, loaded via project context)
2. `.claude/rules/general-code-change.md` (cross-language code change policy, loaded via project context)
3. `.claude/rules/general-unit-test.md` (cross-language unit test policy, loaded via project context)
4. `.claude/rules/python.md` (Python toolchain and coding standards — read in session)
5. `.github/instructions/general-code-change.instructions.md` (baseline code change rules — read in session)
6. `.github/instructions/general-unit-test.instructions.md` (baseline unit test rules — read in session)
7. `.github/instructions/python-code-change.instructions.md` (Python code change policy — read in session)
8. `.github/instructions/python-unit-test.instructions.md` (Python unit test policy — read in session)

Notes:
- Remediation cycle 1 scope: resolve the `pyproject.toml` `[tool.poetry.scripts]` merge conflict via union, then re-run the full Python QC loop with coverage.
- Coverage remains mandatory: line >= 85%, branch >= 75%, no regression on changed lines.
- Toolchain order enforced: Black -> Ruff -> Pyright -> Pytest with coverage; restart from format on any failure or file change.

## Remediation Cycle 2 (2026-07-18T13-40)

Timestamp: 2026-07-18T12-32

Policy Order: CLAUDE.md -> .claude/rules/general-code-change.md -> .claude/rules/general-unit-test.md -> .claude/rules/python.md -> .github/instructions/general-code-change.instructions.md -> .github/instructions/general-unit-test.instructions.md -> .github/instructions/python-code-change.instructions.md -> .github/instructions/python-unit-test.instructions.md

Files read (in required precedence order):

1. `CLAUDE.md` (standing instructions, loaded via project context)
2. `.claude/rules/general-code-change.md` (cross-language code change policy, loaded via project context)
3. `.claude/rules/general-unit-test.md` (cross-language unit test policy, loaded via project context)
4. `.claude/rules/python.md` (Python toolchain and coding standards — read in session)
5. `.github/instructions/general-code-change.instructions.md` (baseline code change rules — read in session)
6. `.github/instructions/general-unit-test.instructions.md` (baseline unit test rules — read in session)
7. `.github/instructions/python-code-change.instructions.md` (Python code change policy — read in session)
8. `.github/instructions/python-unit-test.instructions.md` (Python unit test policy — read in session)

Notes:
- Remediation cycle 2 scope: mirror four repo `.claude/agents/*.md` files (legacy-parity-analyst.md, migration-coverage-reviewer.md, requirements-reconciler.md, runtime-characterization-analyst.md) byte-for-byte into the bundled payload `extensions/drm-copilot/resources/claude-customizations/.claude/agents/`, run a scope-boundary drift scan, and re-run the full Python QC loop with coverage.
- Repair direction is repo -> bundle only. Do NOT run `python -m scripts.dev_tools.push_down_claude_customizations`. Do NOT modify `.claude/agents/*.md` source files. Do NOT touch `.claude/agent-memory/**` or `.claude/settings.local.json`.
- Coverage remains mandatory: line >= 85%, branch >= 75%, no regression on changed lines.
- Toolchain order enforced: Black -> Ruff -> Pyright -> Pytest with coverage; restart from format on any failure or file change.

## Remediation Cycle 3 (2026-07-18T17-05)

Timestamp: 2026-07-18T17-05

Policy Order: CLAUDE.md -> .claude/rules/general-code-change.md -> .claude/rules/general-unit-test.md -> .claude/rules/typescript.md -> .claude/rules/typescript-suppressions.md -> .claude/rules/python.md -> .claude/rules/python-suppressions.md -> .github/instructions/general-code-change.instructions.md -> .github/instructions/general-unit-test.instructions.md -> .github/instructions/typescript-code-change.instructions.md -> .github/instructions/typescript-unit-test.instructions.md -> .github/instructions/python-code-change.instructions.md -> .github/instructions/python-unit-test.instructions.md

Files read (in required precedence order):

1. `CLAUDE.md` (standing instructions, loaded via project context)
2. `.claude/rules/general-code-change.md` (cross-language code change policy, loaded via project context)
3. `.claude/rules/general-unit-test.md` (cross-language unit test policy, loaded via project context)
4. `.claude/rules/typescript.md` (TypeScript toolchain and coding standards — read in session)
5. `.claude/rules/typescript-suppressions.md` (pre-authorized TypeScript suppression patterns — read in session)
6. `.claude/rules/python.md` (Python toolchain and coding standards — read in session)
7. `.claude/rules/python-suppressions.md` (pre-authorized Python suppression patterns — read in session)
8. `.github/instructions/general-code-change.instructions.md` (baseline code change rules — read in session)
9. `.github/instructions/general-unit-test.instructions.md` (baseline unit test rules — read in session)
10. `.github/instructions/typescript-code-change.instructions.md` (TypeScript code change policy — read in session)
11. `.github/instructions/typescript-unit-test.instructions.md` (TypeScript unit test policy — read in session)
12. `.github/instructions/python-code-change.instructions.md` (Python code change policy — read in session)
13. `.github/instructions/python-unit-test.instructions.md` (Python unit test policy — read in session)

Notes:
- Remediation cycle 3 scope: register the four #365 agent paths in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` `paths` array to fix the failing `claude-pack-manifest-completeness.test.ts`, run a scope-boundary manifest-completeness scan (including the codex-and-agents parallel contract), then run the full TypeScript and Python QC loops with coverage.
- Languages in scope: TypeScript (extension fix and verification) and Python (regression QC).
- Constraints: do NOT modify repo `.claude/agents/*.md` source files; do NOT modify mirrored bundle files under `extensions/drm-copilot/resources/claude-customizations/.claude/**`; keep `core.json` valid JSON with existing formatting conventions.
- Coverage remains mandatory: line >= 85%, branch >= 75%, no regression on changed lines.
- TypeScript toolchain order: format -> lint -> type-check -> test (coverage via `npm run test:coverage`). Python toolchain order: Black -> Ruff -> Pyright -> Pytest with coverage; restart from format on any failure or file change.
