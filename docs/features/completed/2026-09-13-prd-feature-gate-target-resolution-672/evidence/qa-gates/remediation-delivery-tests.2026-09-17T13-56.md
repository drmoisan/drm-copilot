# Python delivery tests — intermediate parity window closed

Timestamp: 2026-09-17T13-56

Task: `[P3-T5]` of `remediation-plan.2026-09-17T12-29.md`

The plan's "Intermediate parity window" section records that Phase 2 changes the repository hook files before
Phase 3 re-mirrors them, and that during that window the bundled-payload parity test is expected to fail. No
task in Phase 1 or Phase 2 asserted it. This task is the first to assert it, after `[P3-T2]` and `[P3-T3]`
re-mirrored both files and `[P3-T4]` confirmed SHA-256 equality, so it closes that window.

Command:

- the **unfiltered** `.claude/state` clear, run immediately before the test run:
  `Get-ChildItem -Path .claude/state -File -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('PRE-RESET ' + $_.FullName); Remove-Item -LiteralPath $_.FullName -Force }`
- its verification:
  `Get-ChildItem -Path .claude/state -File -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count`
- **C10**:
  `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q`

No `--cov` argument is supplied. This remediation adds and changes no Python production source, so no Python
coverage gate applies to it.

EXIT_CODE: 0

Output Summary:

## The unfiltered removal and its verification, recorded separately

| step | result | exit code |
| --- | --- | --- |
| pre-removal enumeration | **`none`** — no file was enumerated under `.claude/state`, so no `PRE-RESET` line was emitted | 0 |
| removal | nothing to remove; `$?` was `True` after the pipeline | 0 |
| post-removal verification count | **0** | 0 |

The pre-removal list is `none` because `[P3-T1]` had already removed the single batch-budget state file at the
R-C boundary, and no PowerShell edit has occurred since. The preamble's exit-code attribution branch — an
`EXIT_CODE: 1` accompanied by a verified count of `0` being a pass — was not exercised, because `.claude/state`
exists and the enumeration succeeded.

The unfiltered removal is required before every C10 run because
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` enumerates `.claude` without honouring
`.gitignore` and reports `Repo file missing from bundle:` for any runtime file under `.claude/state`. Clearing
the directory removes that false failure, which is a local-environment artifact rather than a delivery defect.

## C10 result

```
.................                                                        [100%]
17 passed in 0.17s
```

- Passed: **17**
- Failed: **0**
- `EXIT_CODE`: **0**

## The named test

`test_bundled_claude_payload_contains_all_repo_runtime_contracts` — **PASSED**.

Confirmed by name from a verbose re-run of the same three files, which reported the same 17 passed and exit
code 0. The full node ID observed was
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`.

That test passing is the delivery-side confirmation of criterion 32: both repository hook files have
text-identical counterparts under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`.
`[P3-T4]` establishes the same property by hash; this test establishes it through the delivery contract the
push-down mechanism enforces, and the two are independent observations of it.

The other two files' tests also passed, which covers the remaining delivery registrations:
`test_bundled_claude_files_are_listed_in_some_pack_manifest` for the manifest entry criterion 33 requires, and
`test_poshqc_bundled_module_files_match_repo_root_sources` for the PoshQC bundled parity criterion 34
requires.

Acceptance: `EXIT_CODE: 0`, a failed count of 0, and the `Output Summary:` names
`test_bundled_claude_payload_contains_all_repo_runtime_contracts` as passing. Satisfied. The removal and
verification commands and their own exit codes are recorded separately above.
