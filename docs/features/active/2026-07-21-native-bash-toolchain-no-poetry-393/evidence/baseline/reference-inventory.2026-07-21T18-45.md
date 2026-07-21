# Baseline — Live Reference Inventory (Issue #393)

Timestamp: 2026-07-21T18-45
Command: rg -n "shell_qc|shell-qc" (repository-wide, excluding docs/features/completed/**,
         docs/features/archive/**, other features' evidence/research folders, and
         docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/**)
EXIT_CODE: 0

## Live references (to be updated in this change) — reconciled to spec.md 10-row inventory

| # | File | Line(s) | Phase 4/3 task |
|---|------|---------|----------------|
| 1 | pyproject.toml | 50, 51, 52, 53, 86 | P3-T4 (remove 5 console-script entries) |
| 2 | scripts/dev_tools/shell_qc.py | whole file | P3-T5 (delete) |
| 3 | scripts/dev_tools/fix_all_branches.py | 186, 210, 230 (command lists 181-188, 205-212, 224-232) | P3-T1 (repoint x3) |
| 4 | scripts/dev_tools/fix_all.py | 326-329 (marker strings) | contract only, no edit (P1-T4 emits byte-identical) |
| 5 | .vscode/tasks.json | 437, 459, 502 (tasks 434-455, 456-477, 499-519) | P3-T3 (repoint x3) |
| 6 | .github/workflows/_shell-coverage.yml | 77, 78 (+ Python/Poetry steps 16-40) | P4-T1 |
| 7 | .github/workflows/_build-check.yml | 35 | P4-T2 |
| 8 | README.md | 16, 68, 366-370 | P4-T5 |
| 9 | docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md | 278-280 | P4-T6 |
| 10 | extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md | 278-280 | P4-T7 |

Note: `fix_all.py` did not match the `shell_qc|shell-qc` token (it holds the marker strings
`No shell test directories found; skipping.` / `bats not installed; skipping shell tests.`),
consistent with spec.md row 4 (contract, not an edit).

## Excluded live hits (frozen artifacts — not edited; documented exclusion)

Point-in-time snapshots and precedent citations in OTHER features' research/spec/evidence.
Editing these would corrupt those features' audit trails; none is a live consumer of the
shell toolchain:

- docs/features/active/2026-07-17-legacy-discovery-init-templates-362/ (research.2026-07-17T14-15.md;
  remediation-inputs.2026-07-18T15-35.md; evidence/remediation-baseline/r4c1-...enumeration...md)
  — captured pyproject snapshot + naming-precedent citation.
- docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/ (spec.md;
  research.md; evidence/remediation-baseline/r1c1-...md) — `shell-qc-*` cited as a
  multi-entry console-script precedent.
- docs/features/archive/** and docs/features/completed/** — frozen historical evidence
  (e.g., 2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55, 2026-02-21-bootstrap-utility-scripts-40).

Output Summary: 10 live-reference rows reconciled exactly to the spec.md inventory; no
additional live consumer exists. All other hits are frozen artifacts in other features'
folders or archived/completed features and are explicitly excluded.
