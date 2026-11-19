# Remediation Inputs — Issue #1050 (CI-failure cycle 1)

Timestamp: 2026-11-19T14-16
Source: orchestrator-owned plan task [P3-T5] (AC S17), scratch-destination dispatch of the rendered reference-mode caller per pack
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate

## Context

The rendered reference-mode caller was dispatched once per language pack against the PR head `9d75fe2be5ee21f4a04af4dc9bb6b0fa4b76b8eb`, each in a scratch branch `scratch/ci-1050-<pack>` of the source repository holding a minimal fixture and the caller at `.github/workflows/ci.yml` (decision AD-13 in the orchestrator checkpoint).

| Pack | Run | Conclusion |
| --- | --- | --- |
| python | https://github.com/drmoisan/drm-copilot/actions/runs/44541154665 | failure |
| typescript | https://github.com/drmoisan/drm-copilot/actions/runs/44541160197 | success |
| powershell | https://github.com/drmoisan/drm-copilot/actions/runs/44541165447 | success |
| csharp-modern | https://github.com/drmoisan/drm-copilot/actions/runs/44541170750 | success |
| csharp-legacy | https://github.com/drmoisan/drm-copilot/actions/runs/44541175317 | success |

## Blocking Findings

### CI-1 — harness-python.yml coverage threshold step cannot parse the coverage.py JSON report

- Severity: Blocking
- Remediability: autonomous
- Finding-Scope: contained
- Failing check: `Python / Python QC`, step `Check coverage thresholds`
- Failing job URL: https://github.com/drmoisan/drm-copilot/actions/runs/44541154665
- Evidence: Black, Ruff, Pyright and pytest passed (3 passed) and the JSON report was written; the next step failed with `ConvertFrom-Json: The provided JSON includes a property whose name is an empty string, this is only supported using the -AsHashTable switch.` The coverage.py JSON report of the installed coverage 7.17.3 carries an empty-string key (per-file region maps), so the inline `pwsh` step in `.github/workflows/harness-python.yml` (and its byte-identical bundle copy `extensions/drm-copilot/resources/ci-workflows/workflows/harness-python.yml`) fails in every destination whose report carries such a key.
- Required change: parse the report with `ConvertFrom-Json -AsHashtable` and read the totals through hashtable access (`totals`, `num_statements`, `covered_lines`, `num_branches`, `covered_branches`), keeping the threshold logic, messages, and exit behavior; keep the bundle copy byte-identical; add a contract assertion in `extensions/drm-copilot/test/lib/push-down/push-down-ci-contract.test.ts` (or its helper) that the Python harness threshold step uses `-AsHashtable`, with a negative in-memory variant that omits it; run actionlint 1.7.12 over the four harness workflows.
- Classification: proportionate (no acceptance criterion, public interface, or file-inventory change beyond files already in the branch diff plus their tests and mirrors).
