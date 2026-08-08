# Phase 4 — Gap 1 PowerShell Fail-Before (new tests against the unmodified module)

Timestamp: 2026-08-08T11-50
Task: [P4-T1] [expect-fail]

A failing result is the expected and required outcome of this task. The new `-RootSurface` matrix
is written before the parameter exists, so it must fail against the unmodified
`BlastRadiusExtraction.psm1`.

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5c761b8f1a691079`
and `scan_folders: ["tests/scripts/claude-lib/blast-radius"]`

EXIT_CODE: 7

## Tests added

A `Context 'Configured separator-free root surfaces'` block in
`tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1`, mirroring the Python
matrix from [P3-T1] and [P3-T2] one case for one case:

| Case | PowerShell assertion | Python counterpart |
| --- | --- | --- |
| positive x3 | `Get-PathTokenKind -Token <s> -RootSurface @('package-lock.json','poetry.lock','quality-tiers.yml')` is `'concrete'` | `test_classify_path_token_accepts_a_configured_separator_free_root_surface` |
| negative `README.md` | returns `$null` | `test_classify_path_token_rejects_a_readme_outside_the_configured_set` |
| negative `pyproject.toml` | returns `$null` | `test_classify_path_token_rejects_a_pyproject_outside_the_configured_set` |
| negative `derive_blast_radius` | returns `$null` | `test_classify_path_token_rejects_a_bare_identifier_against_root_surfaces` |
| ordinal `Poetry.Lock` | returns `$null` | `test_classify_path_token_root_surface_membership_is_ordinal` |
| default-argument | `Get-PathTokenKind -Token 'poetry.lock'` returns `$null` | `test_classify_path_token_without_root_surfaces_still_rejects_a_root_surface` |

## Raw result

```
total=292 passed=285 failed=7 errors=0 skipped=0 time=4.707
```

All seven failures are in `BlastRadiusExtraction.Path.Tests.ps1`, and every one carries the same
message:

```
ParameterBindingException: A parameter cannot be found that matches parameter name 'RootSurface'.
```

Failing cases:
1. `accepts the configured separator-free root surface package-lock.json`
2. `accepts the configured separator-free root surface poetry.lock`
3. `accepts the configured separator-free root surface quality-tiers.yml`
4. `rejects the separator-free token README.md outside the configured set`
5. `rejects the separator-free token pyproject.toml outside the configured set`
6. `rejects the separator-free token derive_blast_radius outside the configured set`
7. `rejects a case variant because membership is ordinal`

The eighth new case, `rejects a configured surface when the parameter is omitted`, PASSES against
the unmodified module, which is correct: it asserts the pre-change behaviour that the empty
default must preserve, so it is a backward-compatibility guard rather than a fail-before case.

Output Summary: Seven of the eight new cases FAIL against the unmodified
`BlastRadiusExtraction.psm1` with
`ParameterBindingException: A parameter cannot be found that matches parameter name 'RootSurface'`,
including all three positive cases. This is the required fail-before state: the named-optional
parameter does not yet exist, so the three configured root surfaces remain unreachable in
PowerShell exactly as they are in Python. The 285 passing tests are the rest of the blast-radius
suites, unaffected. The pass-after run is recorded at [P4-T8].
