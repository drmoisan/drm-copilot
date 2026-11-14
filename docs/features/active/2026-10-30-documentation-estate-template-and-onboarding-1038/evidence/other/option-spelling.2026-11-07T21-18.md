# Option spelling check (command reference against UPSTREAM-MAP)

Timestamp: 2026-11-07T21-18
Command: sh SCRATCH/issue-1038-options.sh (PowerShell 7: reads the OPTION-MAP lines of the greatest evidence/baseline/upstream-dispatch.*.md and the TOOL lines of the greatest evidence/baseline/upstream-surfaces.*.md; for each '### `<name>`' section of docs/engineering/documentation-estate/command-reference.md, collects every whitespace-preceded -<Name> token of its fenced blocks (subcommands, allowed: its OPTION-MAP options plus -Command, -Json, -Help, -RepositoryRoot) or every JSON key of its fenced json blocks parsed with ConvertFrom-Json (tools, allowed: its TOOL fields))
EXIT_CODE: 0
Output Summary: 15 sections checked (9 subcommands, 6 MCP tools); 15 match, 0 differs.

SECTION: init | match
SECTION: validate-profile | match
SECTION: check | match
SECTION: inventory | match
SECTION: coverage | match
SECTION: update-ledger | match
SECTION: validate | match
SECTION: generate-reference | match
SECTION: surface-delta | match
SECTION: run_docs_check | match
SECTION: run_docs_inventory | match
SECTION: run_docs_coverage | match
SECTION: update_docs_ledger | match
SECTION: generate_docs_reference | match
SECTION: validate_docs_artifacts | match
