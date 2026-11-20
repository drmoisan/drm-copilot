# Phase 0 — Policy Instructions Read (Issue #422)

Timestamp: 2026-07-26T00-50

Policy Order: The reading order below follows the plan tasks `[P0-T1]` .. `[P0-T5]`, which implement the order defined in `.claude/skills/policy-compliance-order/SKILL.md` (standing instructions first, then cross-language code-change policy, then cross-language unit-test policy, then language-specific rules for each language in scope).

1. `[P0-T1]` `CLAUDE.md` (repo root) — standing instructions, tone policy, policy-compliance reading order, four-layer runtime architecture.
2. `[P0-T2]` `.claude/rules/general-code-change.md` — cross-language code change policy (design principles, mandatory seven-stage toolchain loop, 500-line file limit, error handling, naming, I/O boundaries).
3. `[P0-T3]` `.claude/rules/general-unit-test.md` — cross-language unit test policy (five core principles, uniform coverage thresholds line >= 85% / branch >= 75%, coverage-exclusion policy, Arrange-Act-Assert, test file location under `tests/`, determinism infrastructure).
4. `[P0-T4]` Python rules (Python is a changed language: one new pytest module is added by this plan):
   - `.claude/rules/python.md` — toolchain (`poetry run black .`, `poetry run ruff check .`, `poetry run pyright`, `poetry run pytest --cov --cov-branch --cov-report=term-missing`), PEP 8 naming, strong typing, Pytest rules.
   - `.claude/rules/python-suppressions.md` — pre-authorized `# noqa` / `# type: ignore` patterns and escalation path.
5. `[P0-T5]` TypeScript rules (the corrected content describes the TypeScript toolchain; the pre-fix text of `.claude/rules/typescript.md` is itself an edit target of this plan):
   - `.claude/rules/typescript.md` — toolchain and testing standards (currently names Vitest at lines 16, 42, 47, 51, 73; this is the defect under repair).
   - `.claude/rules/typescript-suppressions.md` — pre-authorized ESLint / TypeScript suppression patterns.

Files Read (explicit list, all read in full):

- `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7169cd5d8fee273d\CLAUDE.md`
- `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7169cd5d8fee273d\.claude\rules\general-code-change.md`
- `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7169cd5d8fee273d\.claude\rules\general-unit-test.md`
- `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7169cd5d8fee273d\.claude\rules\python.md`
- `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7169cd5d8fee273d\.claude\rules\python-suppressions.md`
- `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7169cd5d8fee273d\.claude\rules\typescript.md`
- `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7169cd5d8fee273d\.claude\rules\typescript-suppressions.md`

Acknowledgement of Binding Constraints:

- `.github/instructions/**` is the canonical policy surface and must not be modified.
- Root `package.json`, `jest.config.cjs`, `run-jest.cjs`, `tsconfig*.json`, and `.vscode-test.*` are owned by a sibling orchestration and must not be modified.
- Python toolchain order for this plan: format (Black) -> lint (Ruff) -> type-check (Pyright) -> test (Pytest with coverage). Restart from formatting if any stage fails or changes files.
- Coverage floors: line >= 85%, branch >= 75%; no regression on changed lines.
- All evidence is written under `docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/<kind>/`.
