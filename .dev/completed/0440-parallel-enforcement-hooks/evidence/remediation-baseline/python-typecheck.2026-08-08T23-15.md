# Python Type-Check Baseline — Issue #440 F7 Remediation Cycle 1

- **Task:** [P0-T15]
- **Plan of record:** `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/remediation-plan.2026-08-08T23-15.md`

Timestamp: 2026-08-09T00-30

Command: `poetry run pyright` (run from the repository root)

EXIT_CODE: 0

## Output Summary

**Exact error count: 0. Exact warning count: 0.** (Informations: 0.)

Output, verbatim:

```
venv .venv subdirectory not found in venv path c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a0b28ae2f972ac0ee.
0 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.411).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```

Two lines in that output are environment notices, not diagnostics, and neither counts toward the error or warning totals:

- `venv .venv subdirectory not found in venv path ...` — Poetry created this worktree's virtual environment outside the project directory, so there is no in-tree `.venv`. This is a resolution notice from pyright's venv discovery.
- `WARNING: there is a new pyright version available` — a self-update notice from the `pyright` Python wrapper, unrelated to the analyzed code.

### Confirmation that the zero is not vacuous

Because the venv notice could in principle indicate that pyright failed to resolve imports and silently analyzed nothing, the run was repeated with `--stats` to confirm real analysis occurred:

```
pyright 1.1.409
0 errors, 0 warnings, 0 informations
Completed in 4.624sec

Analysis stats
Total files parsed and bound: 626
Total files checked: 376
```

**376 files checked** — the same 376 files Black reports at [P0-T13], so the whole Python surface was genuinely analyzed. The zero error count is a real clean result, not an empty-file-set artifact.

## Determination

**The Python type-check baseline error count is 0 and pyright exits 0.** P4-T8's acceptance is phrased as baseline-equality rather than an unqualified absolute zero; because the baseline is in fact zero, the two readings coincide. P4-T8 therefore passes only when pyright again reports zero errors, which in particular means zero errors attributable to any file in this cycle's change set. No `# type: ignore` exists to be preserved and none may be added (binding constraint 11).
