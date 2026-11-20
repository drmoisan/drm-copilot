# P2-T8 independent executor verification

Timestamp: 2026-10-18T10:20:36Z

Command: `poetry run python SCRATCH/issue-980-verify-p2t8.py 2026-10-18T10-19 53`

EXIT_CODE: 0

Output Summary: Accepted P2-T8 only. Five exact staged paths match final hashes; 198 prior accepted paths and 24 frozen v1/export paths are unchanged. All 53 independent cases pass on final production bytes. Coverage is 245/245 executable lines and 121/124 branch arcs; all 21 measured callable/class ranges have 100% line coverage. Maximum physical file length is 499.

The checker independently recomputed staged Git identities, working-byte SHA-256 values, raw line/branch totals, AST unit ranges, docstrings and physical lengths. The numerical proof is in [executor checks](p2t8-executor-checks.2026-10-18T10-20.json). It bound the unchanged [53-case result](p2t8-executor-probes.2026-10-18T10-18.json) to the specialist's final [coverage metrics](p2t8-coverage-metrics.2026-10-18T10-19.json) and [raw coverage](p2t8-coverage.2026-10-18T10-19.json); no broad gate was repeated.

## Task acceptance

- Each present parity row resolves its immutable source contract and configured target client/pin. Wrong source or implementation hashes, missing source contracts and mismatched identities fail.
- Full parity requires independent target implementation, test and evidence support. Source test evidence cannot become target verification, including combined repositories with equal pins or renamed metadata over the same source payload.
- Required feature/client/platform/mode coordinates and explicit dimension claims are checked. Custom modes and multiple clients work; optional dimensions and truthful optional incomplete rows do not create required failures.
- Approved changes and retirements retain scoped decision evidence. Retirement still validates supplied classifications and links; full/completed-change claims require every linked implementation summary to pass. Distinct passing implementations may divide coordinate coverage.
- A configured imported historical source remains valid at its declared pin. The validators preserve all source observations and snapshot bytes.

The P1-T6 duplicate-mode carry-forward is verified. The final staged `test_both_mode_representations_must_agree_and_have_valid_proof` in `test_parity_clients.py:77` covers online/offline/mobile crossed with applicability conflict, verification conflict and invalid second proof (nine cases). The 77-test final and reversed runs pass those cases. Independent probes additionally verify both online representations, each representation alone, and contradictions or invalid proof retained beneath retirement.

## Quality and retained evidence

The specialist's [handoff](../other/p2t8-parity-rules.2026-10-18T10-19.md) and separate pass-6 receipts show Black/Ruff clean, full repository Pyright with zero diagnostics, 77 focused tests in 5.93 seconds, and 77 reversed tests in 2.83 seconds. Quality-tier classification remains 26/26 and the package check verifies 33 resources. Static checks find 59 documented units and no forbidden test I/O, suppressions or whitespace errors. Exact production coverage is 146/146 lines and 73/74 arcs for `parity_rules.py`; 99/99 lines and 48/50 arcs for `parity_target_rules.py`.

All four consolidated defects have passing regressions. Initial probe fixture mistakes, the 45/49 and 48/51 review results, the provisional 53-case run that failed source-stability binding, early lint/type failures and the pass-4 callable gaps remain retained. Pass-4's identity/source_payload/implementation ranges were below 90%; added direct tests cover all final ranges without production changes.

Only P2-T8 is checked off: 23/84 tasks. Feature acceptance remains 5/66 in each source (AC-10 through AC-14). This rule family does not grant aggregate discovery, parity or planning authority; composition and role-output validation remain P2-T9. Python task gates pass. TypeScript, PowerShell and C# are not modified by this task; final repository QA remains Phase 11.

Current phase: Phase 2. Next tasks: P2-T9, P3-T1, P3-T2, P3-T3, P3-T4.
