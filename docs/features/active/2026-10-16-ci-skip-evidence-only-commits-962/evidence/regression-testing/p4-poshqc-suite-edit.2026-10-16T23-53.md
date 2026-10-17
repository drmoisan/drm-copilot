# _poshqc.yml gating and A4/A4C suite edit (P4-T6)

Timestamp: 2026-10-16T23-53
Command: git diff --numstat HEAD -- tests/scripts/workflows/PoshQcWorkflow.Tests.ps1
EXIT_CODE: 0
Output Summary: Shape recorded by edit-points.2026-10-16T23-23.md: POSHQC-SHAPE: sharded, so G6-sharded and A4 with A4C were applied. poshqc-static, poshqc-shard, and poshqc-linux-hooks carry `    if: ${{ inputs.run-heavy }}` directly after their name lines with step conditions unchanged (the shard and hook-suite upload steps keep `if: always()`); the poshqc aggregator keeps its job-level `if: always()` and each of its seven steps, including `Require the static and shard jobs to succeed`, carries `        if: ${{ inputs.run-heavy }}`. The A4 helper condition line (line 85) and the A4C comment line (line 51) were replaced with the section 7 texts; numstat is `2	2` for the suite (the only two changed lines). No PD-9 fix was needed (baseline actionlint findings: 0).

POSHQC-SHAPE: sharded

## A4 record

- A4C old (line 51): `        # -or, exits 1, carries no step-level if condition, and precedes the completeness and merge steps.`
- A4C new (line 51): `        # -or, exits 1, carries no step-level if condition other than the issue #962 run-heavy gate, and precedes the completeness and merge steps.`
- A4 old (line 85): `            if ($gate -match '(?m)^ {8}if:') {`
- A4 new (line 85): `            if ($gate -match '(?m)^ {8}if:' -and $gate -notmatch '(?m)^ {8}if:[ \t]*\$\{\{ inputs\.run-heavy \}\}[ \t]*$') {`

Both pre-edit lines matched the section 7 quotations exactly (CR-INVENTORY EDIT-TARGET-A4 count=1 at line 85, EDIT-TARGET-A4C count=1 at line 51).

## numstat output

```
2	2	tests/scripts/workflows/PoshQcWorkflow.Tests.ps1
```

## _poshqc.yml change summary (from git diff HEAD)

- `on:` block: `run-heavy` input (boolean, default true) under `workflow_call` and `workflow_dispatch` (G0).
- `poshqc-static`, `poshqc-shard`, `poshqc-linux-hooks`: `    if: ${{ inputs.run-heavy }}` inserted after the `name:` line.
- `poshqc`: the seven steps each gained `        if: ${{ inputs.run-heavy }}` after their `- name:` line; `    if: always()` unchanged.
