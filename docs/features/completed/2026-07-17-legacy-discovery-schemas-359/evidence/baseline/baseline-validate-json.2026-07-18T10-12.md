# Baseline — JSON Governance (#359)

Timestamp: 2026-07-18T10-12
Command: `poetry run dev.validate-json`
EXIT_CODE: 0

Output Summary:
Pre-change governed set contains 1 governed JSON file
(`docs/features/completed/2026-04-26-push-down-claude-customizations-162/evidence/baseline/phase4-settings-pre.json`),
which validates cleanly (`: ok`). 0 failures. The `examples/` directory does not exist yet, so no
`examples/discovery/v1/` fixtures are governed at baseline. Governed-file discovery was cross-checked via
`iter_governed_files(repo_root)`, which returned the same single file.
