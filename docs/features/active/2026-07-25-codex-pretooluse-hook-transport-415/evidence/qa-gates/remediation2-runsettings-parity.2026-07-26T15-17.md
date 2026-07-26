# Final QA Gate — Runsettings Bundled-Parity Pytest (Remediation Cycle 2)

- **Issue:** #415
- **Task:** [P7-T5]
- **Plan:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-26T18-10.md`
- **Rationale:** RD-6 — the cycle-2 delta is PowerShell-only, but it changes the mirrored `pester.runsettings.psd1` pair, and this pytest is the gate that asserts exact text parity between the two copies. It is therefore the one Python-adjacent gate the delta touches.

Timestamp: 2026-07-26T15-17

Command: `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q`

EXIT_CODE: 0

```
.                                                                        [100%]
1 passed in 0.04s
```

## Output Summary

| Metric | Value |
|---|---|
| Passed | 1 |
| Failed | 0 |
| Errors | 0 |
| Elapsed | 0.04 s |

The bundled-parity assertion passes, confirming that the two `pester.runsettings.psd1` copies changed by
[P4-T1] remain exact text matches:

- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
- `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`

This is an independent confirmation of the `git diff --no-index` (exit 0) and `Get-FileHash` (match = True)
checks recorded at [P4-T1] and [P7-T3], satisfying Hard Constraint 5 for the runsettings pair by a third
method.

No Python production or test file was changed by this cycle, so no Python coverage movement is possible and
the cycle-1 Python evidence stands (RD-6).

EXIT_CODE: 0
