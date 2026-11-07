# Upstream dispatch rows (UPSTREAM-MAP, subcommands)

Timestamp: 2026-11-07T20-27
Command: Read Get-DocsCommandTable in .claude/lib/docs/Invoke-DocsCommand.ps1; grep result keys in .claude/lib/docs/DocsPageCheck.psm1 and .claude/lib/docs/DocsReferenceReport.psm1
EXIT_CODE: 0
Output Summary: All nine subcommand rows are present. The inventory row carries -AnalysisMethod. Both result key sets match. The merged surface-delta row lists -Base and -Profile only (the epic enforcement notes also list -BaseSnapshot and -BaseLedger); this is an option-spelling difference, which D-1 permits: the command-reference examples follow the merged row recorded below.

OPTION-MAP: init | -RepositoryId (value), -Profile (value), -Write (switch), -Force (switch)
OPTION-MAP: validate-profile | -Profile (value)
OPTION-MAP: check | -Profile (value), -Path (multi)
OPTION-MAP: inventory | -Profile (value), -Analyzer (multi), -Revision (value), -Write (switch), -AnalysisMethod (value)
OPTION-MAP: coverage | -Profile (value)
OPTION-MAP: update-ledger | -Profile (value), -Operation (value), -Element (value), -Limit (value), -Disposition (value), -Page (multi), -Rationale (value), -Owner (value), -Target (value), -Dimension (value), -State (value), -Claim (value), -ActorKind (value), -ActorId (value), -Write (switch)
OPTION-MAP: validate | -Profile (value), -Mode (value), -Revision (value), -WriteReceipt (switch)
OPTION-MAP: generate-reference | -Profile (value), -Snapshot (value), -OutputDirectory (value), -Write (switch)
OPTION-MAP: surface-delta | -Base (value), -Profile (value)

Common parameters (entry script, reserved): -Command, -Json, -Help, -RepositoryRoot.

RESULT-KEYS: check | match (page_count, profile_path, roots)
RESULT-KEYS: generate-reference | match (mode, output_directory, pages, summary, unrendered)
