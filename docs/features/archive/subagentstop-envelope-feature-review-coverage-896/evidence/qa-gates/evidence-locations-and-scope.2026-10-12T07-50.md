# Evidence Locations and Scope (P1-T4)

Timestamp: 2026-10-12T07-50
Command: poetry run python scripts/dev_tools/validate_evidence_locations.py --root .; git status --porcelain --untracked-files=all -- scripts src tests .claude .codex .github .agents pyproject.toml
EXIT_CODE: 0
Output Summary:
- Validator: no output, exit 0 (no `VIOLATION:` line).
- Status command: no output, exit 0; no source, test, runtime-surface, or configuration file changed.
