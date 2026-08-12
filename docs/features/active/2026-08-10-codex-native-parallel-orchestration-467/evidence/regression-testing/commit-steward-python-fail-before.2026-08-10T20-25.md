# P6-T24 Commit-Steward Python Fail-Before

Timestamp: `2026-08-10T20-25`

Command: `poetry run pytest -q tests/scripts/dev_tools/test_resolve_codex_deployment.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_codex_model_policy_config_parity.py`

EXIT_CODE: `1`

Output Summary: `45 passed, 4 failed in 0.20s`. All failures are the expected missing-family defect: `resolve_codex_deployment("commit-steward", "C4", "standalone", "C4")` raises `Unsupported Codex logical agent`; the generator returns no five-profile `commit-steward` inventory; `CORE_FAMILIES` omits `commit-steward`; and `GENERATED_AGENT_FAMILIES` omits `commit-steward`. No unrelated assertion failed.

## Static Gates

- `poetry run black --check <three owners>`: exit `0` after one test-only line-wrap correction.
- `poetry run ruff check <three owners>`: exit `0`, all checks passed.
- `poetry run pyright <three owners>`: exit `0`, `0 errors, 0 warnings, 0 informations`.
- `git diff --check -- <three owners>`: exit `0`.

## Owner Boundaries

- `tests/scripts/dev_tools/test_resolve_codex_deployment.py`: `250` lines.
- `tests/scripts/dev_tools/test_generate_codex_agent_variants.py`: `217` lines.
- `tests/scripts/dev_tools/test_codex_model_policy_config_parity.py`: `74` lines.
- Production/configuration/generated-profile/manifest/dependency/suppression/`.claude/` writes: `0`.
- Temporary filesystem artifacts: `0`.

Result: `PASS (expected failure cleanly attributed)`.
