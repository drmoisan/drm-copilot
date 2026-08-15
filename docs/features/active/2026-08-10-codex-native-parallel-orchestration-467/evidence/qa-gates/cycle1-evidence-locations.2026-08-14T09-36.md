# Cycle 1 Evidence-Location Validation

Timestamp: 2026-08-15T00-05
Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence`
EXIT_CODE: 0
Output Summary: The validator returned no violations. All agent-authored cycle evidence is under the canonical issue-467 `evidence/<kind>/` subtree. Under `artifacts/`, the evidence/context exceptions remain tool-owned Pester output and the canonical commit/PR-context files; other existing entries are tool-owned intermediates or allowed orchestration-control files, not agent-authored feature evidence.

## Canonical evidence result

- Validator output: empty
- Files outside canonical issue-467 evidence folders: `0`
- Cycle-authored evidence under forbidden `artifacts/` evidence prefixes: `0`
- Result: `PASS`

## Established `artifacts/` exceptions

Evidence or context retained at an established non-feature path is limited to:

- Tool-owned Pester output:
  - `artifacts/pester/pester-junit.xml`
  - `artifacts/pester/powershell-coverage.koverage.xml`
  - `artifacts/pester/powershell-coverage.xml`
- Canonical commit/PR context:
  - `artifacts/commit_context.txt` (pre-existing; not refreshed in this executor boundary)
  - `artifacts/pr_context.appendix.txt` (pre-existing; not refreshed)
  - `artifacts/pr_context.summary.txt` (pre-existing; not refreshed)

Only tool-owned Pester output and canonical commit/PR context remain under `artifacts/` as evidence/context exceptions.

## Non-evidence artifact inventory

The following existing files are not agent-authored feature evidence and are classified separately:

- `artifacts/.coverage`: tool-owned Python coverage intermediate.
- `artifacts/python/lcov.info`: tool-owned Python coverage report.
- `artifacts/hard_lock_plan.sha256`: hard-lock control artifact.
- `artifacts/hard_lock_prompt.txt`: hard-lock control artifact.
- `artifacts/orchestration/orchestrator-state.json`: allowed orchestration checkpoint.

No file was moved, deleted, staged, or reclassified to obtain this result.
