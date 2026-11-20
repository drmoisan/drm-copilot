# Scope Check

Timestamp: 2026-09-30T10-06

Plan task: [P2-T17]

Command: git status --porcelain --untracked-files=all; git diff --merge-base --name-status origin/main (two separate Bash calls)

EXIT_CODE: 0

Output Summary: Every porcelain and name-status path is a section 2 path or lies under the feature folder. Production paths present: exactly `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py`, `scripts/dev_tools/validate_epic_orchestrator_state.py`, `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts`. `scripts/dev_tools/_parallel_orchestrator_state_drift.py` and `extensions/drm-copilot/jest.config.cjs` appear in neither output.

## git status --porcelain --untracked-files=all (verbatim)

```text
 M docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/plan.2026-09-29T21-21.md
 M tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py
?? docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/qa-gates/bundled-payload-parity.md
?? docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/qa-gates/coverage-delta.md
?? docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/qa-gates/final-python-black.md
?? docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/qa-gates/final-python-coverage.md
?? docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/qa-gates/final-python-pyright.md
?? docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/qa-gates/final-python-ruff.md
?? docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/qa-gates/final-typescript-coverage.md
?? docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/qa-gates/final-typescript-lint.md
?? docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/qa-gates/final-typescript-prettier.md
?? docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/qa-gates/final-typescript-typecheck.md
?? docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/qa-gates/frozen-surface-pin.md
?? docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/qa-gates/line-counts.md
?? docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/qa-gates/old-text-absence.md
?? docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/qa-gates/skill-doc-and-mirror.md
?? docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/regression-testing/pass-after-python.md
?? docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/regression-testing/pass-after-typescript.md
```

## git diff --merge-base --name-status origin/main (verbatim)

```text
M	.claude/skills/epic-orchestrate/SKILL.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/baseline/minor-audit-preconditions.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/baseline/p0-base-ref.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/baseline/p0-baseline-summary.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/baseline/p0-frozen-surface-pin.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/baseline/p0-line-counts.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/baseline/p0-npm-ci.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/baseline/p0-python-black.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/baseline/p0-python-coverage.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/baseline/p0-python-pyright.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/baseline/p0-python-ruff.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/baseline/p0-typescript-coverage.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/baseline/p0-typescript-lint.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/baseline/p0-typescript-prettier.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/baseline/p0-typescript-typecheck.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/baseline/phase0-instructions-read.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/other/follow-ups.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/other/p1-implementation-handoff.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/other/preflight-round-1.2026-09-30T02-05.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/other/preflight-round-2.2026-09-30T02-35.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/other/preflight-round-3.2026-09-30T02-55.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/other/preflight-round-4.2026-09-30T09-40.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/regression-testing/fail-before-python.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/regression-testing/fail-before-typescript.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/issue.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/plan.2026-09-29T21-21.md
A	docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/research/research.2026-09-30T01-25.md
M	extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md
M	extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts
M	extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts
A	extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-wave-barrier.test.ts
A	scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py
M	scripts/dev_tools/validate_epic_orchestrator_state.py
A	tests/fixtures/epic_wave_barrier/start-guard-matrix.json
M	tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py
M	tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py
A	tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py
```

## Classification of non-feature-folder paths

| Path | Section 2 item |
|---|---|
| `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py` | 1 (production) |
| `scripts/dev_tools/validate_epic_orchestrator_state.py` | 2 (production) |
| `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts` | 3 (production) |
| `tests/fixtures/epic_wave_barrier/start-guard-matrix.json` | 4 |
| `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py` | 5 |
| `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-wave-barrier.test.ts` | 6 |
| `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py` | 7 |
| `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts` | 8 |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | 9 |
| `.claude/skills/epic-orchestrate/SKILL.md` | 10 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md` | 11 |

All other paths lie under `docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/`.

## Result

PASS: every path is in scope; the two out-of-scope files are absent from both outputs; the production paths are exactly section 2 items 1 to 3.
