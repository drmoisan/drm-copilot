# Preflight Fixes (remediation cycle 2)

Timestamp: 2026-11-13T14-27
Plan: docs/features/active/parallel-planner-time-based-edge-rule-1164/remediation-plan.2026-11-13T14-14.md
Mode: single-pass preflight, combined with execution (Remediation-Mode: proportionate)
Outcome: PREFLIGHT: ALL CLEAR (two trivial fixes, no substantive defect)

## Fixes

1. [P1-T3] | literal-formatting defect | The expected repr of `reject-item-read-path-non-printable-outside-radius.json` held the raw characters U+200B and U+2028 where Python's `repr` prints the 4-digit escapes (backslash, `u`, four lowercase hex digits). The literal now reads backslash-x-a0, backslash-u-200b, backslash-u-2028, backslash-U-000e0001, matching the code-point list on the same line and CPython `repr`. The asserted value is unchanged in meaning; the plan line is now ASCII except U+00E9, which `repr` keeps as printable. The edit was made at byte level because the Write and Edit tools decode backslash-u sequences.
2. [P2-T8] | stale prose | The task called the `2026-11-13T14-04` review set and `remediation-inputs.2026-11-13T14-14.md` untracked; both are committed (`git ls-files` lists them). The text now commits any review-cycle file still uncommitted and states that those files were committed before execution began. The acceptance is unchanged.

## Checks performed (no defect)

- R5: `$script:WriteTitleVerb` lists Write, Rewrite, and Overwrite; every other listed verb inflects regularly under the existing suffix rules, so the six irregular forms are the complete set. `Get-TitleWord` splits on non-letters, so each test title yields the new form as one word. No Python port of this derivation exists (`tests/scripts/dev_tools/test_blast_radius_write_intent.py` covers the separate issue #722 module). The `Invoke-ParallelAdmission.PrecedenceGate.Tests.ps1` titles begin with Read and Update.
- R6: `pythonRepr` has no bundle copy; its existing tests and corpora carry no backslash, control, or non-printable value in a parallel-state error string. Both parity tests discover corpus stems by directory listing with a floor of 20, so new stems need no test edit. The Python and TypeScript `read_paths` errors both format the entry through `repr` and `pythonRepr`.
- P1-T4: neither `str.isprintable` nor `Unicode database` occurs in either rule copy; `parallel-scheduling-rule-wording.Tests.ps1` requires no token from `## Enforcement`, and its former-statement list is unaffected.
- Validators: the installed MCP validator and the branch Python CLI (`plan` subcommand) both pass the corrected plan.
