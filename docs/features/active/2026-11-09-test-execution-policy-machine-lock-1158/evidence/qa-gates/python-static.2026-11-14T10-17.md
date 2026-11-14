# Final QC: Python Static (P7-T2, loop restart after the #1159 and #1179 merges)

Timestamp: 2026-11-14T10-17
Command: sh SCRATCH/issue-1158-gate-static.sh (`env -u VIRTUAL_ENV poetry run black --check .`; `env -u VIRTUAL_ENV poetry run ruff check --no-fix`; `env -u VIRTUAL_ENV poetry run pyright`; `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`; `git status --porcelain` before and after)
EXIT_CODE: 0
Output Summary: black: `1068 files would be left unchanged.` ruff: `All checks passed!` pyright: `0 errors, 0 warnings, 0 informations`. Generator `--check`: exit 0. `git status --porcelain` was identical before and after the four steps.

| Step | Command | EXIT_CODE | Findings |
|---|---|---|---|
| format | `poetry run black --check .` | 0 | 0 |
| lint | `poetry run ruff check --no-fix` | 0 | 0 |
| type check | `poetry run pyright` | 0 | 0 |
| generator | `python -m scripts.dev_tools.generate_codex_agent_variants --check` | 0 | 0 |

The same script run also covered the TypeScript static checks, each with exit 0:

- root `npm run format:check`, which PR #1180 added to CI as `Check root formatting`; it printed `All matched files use Prettier code style!`;
- in `extensions/drm-copilot`: `npx prettier --check`, `npx eslint`, and `npm run typecheck`.
