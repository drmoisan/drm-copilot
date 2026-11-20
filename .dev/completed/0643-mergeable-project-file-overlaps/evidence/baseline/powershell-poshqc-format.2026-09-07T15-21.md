# Baseline — PowerShell formatting (issue #643, task [P0-T12])

- Timestamp: 2026-09-07T15:21Z
- Command: `pwsh -NoProfile -Command "(Get-FileHash -Algorithm SHA256 .claude/lib/blast-radius/BlastRadius.psm1, tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1).Hash"` and `git status --porcelain --untracked-files=all`, then the MCP function `mcp__drm-copilot__run_poshqc_format` with `workspace_root` = `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-09-07T08-09`, then the same hash command and porcelain listing again
- EXIT_CODE: 0

## MCP payload (verbatim fields)

- `ok`: `true`
- `summary`: `Ran bundled PoshQC format against 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-09-07T08-09'.`

## Output Summary

The formatter reports `ok` as `true`, and it rewrote nothing: both digest pairs are equal and the
two porcelain listings are byte-identical.

### Digests before the format run

```text
A8F8199A88E9623CD0F1B4C27AEA5089F4AAA0085FF4B2CE4C44015AFDEB419E
7A32A49D2E4B2A2D836F9B27E39E7AEECA7821CA4A2D2C86506749091237354E
```

### Digests after the format run

```text
A8F8199A88E9623CD0F1B4C27AEA5089F4AAA0085FF4B2CE4C44015AFDEB419E
7A32A49D2E4B2A2D836F9B27E39E7AEECA7821CA4A2D2C86506749091237354E
```

Digest pair 1 (`.claude/lib/blast-radius/BlastRadius.psm1`): equal.
Digest pair 2 (`tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1`): equal.

### Porcelain listing before the format run

```text
 M docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/plan.2026-09-07T08-13.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/edit-target-line-counts.2026-09-07T15-10.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/npm-ci-extension.2026-09-07T15-09.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/phase0-instructions-read.2026-09-07T15-07.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/python-black.2026-09-07T15-11.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/python-pyright.2026-09-07T15-13.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/python-pytest-coverage.2026-09-07T15-15.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/python-ruff.2026-09-07T15-12.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/typescript-eslint.2026-09-07T15-17.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/typescript-jest-coverage.2026-09-07T15-20.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/typescript-prettier.2026-09-07T15-16.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/typescript-typecheck.2026-09-07T15-18.md
```

### Porcelain listing after the format run

```text
 M docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/plan.2026-09-07T08-13.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/edit-target-line-counts.2026-09-07T15-10.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/npm-ci-extension.2026-09-07T15-09.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/phase0-instructions-read.2026-09-07T15-07.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/python-black.2026-09-07T15-11.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/python-pyright.2026-09-07T15-13.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/python-pytest-coverage.2026-09-07T15-15.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/python-ruff.2026-09-07T15-12.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/typescript-eslint.2026-09-07T15-17.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/typescript-jest-coverage.2026-09-07T15-20.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/typescript-prettier.2026-09-07T15-16.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/typescript-typecheck.2026-09-07T15-18.md
```

### Tracked `.ps1` / `.psm1` paths appearing only in the after-listing

None. No tracked `.ps1` or `.psm1` path appears in the after-listing that was absent from the
before-listing; the two listings are identical, and neither contains any `.ps1` or `.psm1` path.
