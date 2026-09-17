# Final QC step 4 — delivery tests

Timestamp: 2026-09-17T13-56

Task: `[P4-T4]` of `remediation-plan.2026-09-17T12-29.md`
Loop pass: 1

Command:

- the **unfiltered** `.claude/state` clear:
  `Get-ChildItem -Path .claude/state -File -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('PRE-RESET ' + $_.FullName); Remove-Item -LiteralPath $_.FullName -Force }`
- its verification:
  `Get-ChildItem -Path .claude/state -File -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count`
- **C10**:
  `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q`

EXIT_CODE: 0

Output Summary:

## The unfiltered removal and its verification

| step | result | exit code |
| --- | --- | --- |
| pre-removal enumeration | **`none`** — no file was enumerated under `.claude/state` | 0 |
| removal | nothing to remove; `$?` was `True` after the pipeline | 0 |
| post-removal verification count | **0** | 0 |

The pre-removal list is `none` because the C3 run in `[P4-T3]` wrote no file under `.claude/state`: the
PowerShell batch-budget gate records a state file when a PowerShell edit is attempted, and Phase 4 performs
no edit. The `[P3-T5]` clear was therefore still in effect.

The clear is required before every C10 run because
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` enumerates `.claude` without honouring
`.gitignore` and reports `Repo file missing from bundle:` for any runtime file under `.claude/state`.

## C10 result

```
.................                                                        [100%]
17 passed in 0.17s
```

- Passed: **17**
- Failed: **0**
- `EXIT_CODE`: **0**

This repeats the `[P3-T5]` result after the full C3 run, which confirms the Pester run did not perturb the
bundled payload or the manifest. The named test
`test_bundled_claude_payload_contains_all_repo_runtime_contracts` is one of the 17 and was individually
confirmed passing by the verbose re-run recorded in the `[P3-T5]` artifact at
`docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/remediation-delivery-tests.2026-09-17T13-56.md`.

Acceptance: `EXIT_CODE: 0` and a failed count of 0. Satisfied.

## Loop status

`[P4-T1]` through `[P4-T4]` have now all passed in a single uninterrupted pass. No step failed and no step
changed a tracked file, so the loop does not restart at `[P4-T1]`. `[P4-T10]` records the loop-completion
statement.
