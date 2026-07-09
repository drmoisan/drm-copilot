# Baseline Full-Repo Gate (Pre-Fix)

Timestamp: 2026-07-04T12-00
Command: `poetry run python -m scripts.dev_tools.fix_all`
EXIT_CODE: 1

Output Summary:

```
========== Branch Results ==========
Branch json: FAIL (failed at Canceled)
Branch shell: PASS
Branch python: FAIL (failed at Ruff: lint)
Branch powershell: FAIL (failed at PoshQC: analyze)
Branch typescript: FAIL (failed at TSC: type-check)
====================================
```

Root-cause analysis:

- `typescript` branch fails at the genuine `TSC: type-check` step (`npm run typecheck`), reproducing the three pre-fix errors recorded in `baseline-typescript-typecheck.2026-07-04T12-00.md` (`TS2584` x2, `TS2591`). This is the real, in-scope defect this remediation cycle fixes via the `tsconfig.json` `"types": ["node"]` addition.
- `json`, `python` (`Ruff: lint`), and `powershell` (`PoshQC: analyze`) branches run concurrently with the `typescript` branch under `scripts/dev_tools/fix_all_branches.py`'s shared `cancel_event`. Once the `typescript` branch's real failure sets the cancel event, any sibling branch step that has not yet started returns `CommandResult(returncode=-1, output="Canceled")` immediately (see `scripts/dev_tools/fix_all.py` `CommandRunner.run`), which is logged as `Canceled` in the step output but surfaces as the step's own failure label (`Ruff: lint`, `PoshQC: analyze`) in the branch-result summary.
- Verified this is cascading cancellation, not independent defects, by running the equivalent commands standalone outside the concurrent `fix_all` orchestration:
  - `poetry run ruff check .` -> `All checks passed!` (exit 0)
  - `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module './scripts/powershell/PoshQC'; Invoke-PoshQCAnalyze -Root '.'"` -> `PSScriptAnalyzer passed: no findings under .` (exit 0)

Expectation for Phase 6: once the `typescript` branch's `tsc` failure is fixed (Phase 4), the cancel event will not be set during a clean run, and the `json`, `python`, and `powershell` branches are expected to complete their steps normally and report PASS, consistent with their standalone verification above.
