# [P3-T20] Acceptance criteria status

Timestamp: 2026-11-07T02-48
Command: re-verification of S9, U9, S14, U14, S15, U15, S16, U16, S17, U17, S19, U19, S21 and U21 from this cycle evidence; `sh SCRATCH/issue-1031-c2-ac.sh`
EXIT_CODE: 0
Output Summary: every re-verified criterion holds. Both AC_BLOCK_SHA digests equal the [P0-T6] values. 20 of 22 per source; S10, U10, S22 and U22 are pending CI.

## AC_BLOCK_SHA

| File | SHA-256 | Equal to [P0-T6] |
|---|---|---|
| `FEATURE/spec.md` | f814d160746d16cd499d29834dc400dd3de41113cac9167d9fd5d541830c6f09 | yes |
| `FEATURE/user-story.md` | a6723f3243b6b53f82126596ec53d187898cdc66fac87dc8f99ae769097d8567 | yes |

## Re-verified criteria

| Criterion | Result | Evidence |
|---|---|---|
| S9 / U9 | holds | `coverage-delta`, `c2-python-per-file-coverage`, `c2-powershell-per-file-coverage` |
| S14 / U14 | holds | `c2-bundle-mirror` (101 of 101 pairs equal; contract tests pass), `c2-workingdir-pass` |
| S15 / U15 | holds | `c2-lcov-and-bytecode` |
| S16 / U16 | holds | `c2-test-hygiene`; the new case uses a mock of `Invoke-DocsProcess`, and the adapter still reaches the interpreter only through `Context.InvokeProcess` |
| S17 / U17 | holds | `c2-isolation-pester-fresh` (`enforcement-hooks-no-python-invocation.Tests.ps1`, 35 tests, 0 failed); `c2-scope` (allowlist file outside the cycle union) |
| S19 / U19 | holds | `c2-test-hygiene` |
| S21 / U21 | holds | `c2-tiers-and-size` |

No checkbox or criterion text changed in this cycle. S10, U10, S22 and U22 stay unchecked, pending CI (F5).

### Acceptance Criteria Status
- Source: FEATURE/spec.md `## Acceptance Criteria`
- Total AC items: 22
- Checked off (delivered): 20
- Remaining (unchecked): 2
- Items remaining: S10 (E5, R: Black, Ruff and Pyright, and the 3.11 floor through the CI matrix, pending CI, F5), S22 (CI-dependent, pending CI, F5)

### Acceptance Criteria Status
- Source: FEATURE/user-story.md `## Acceptance Criteria`
- Total AC items: 22
- Checked off (delivered): 20
- Remaining (unchecked): 2
- Items remaining: U10 (E5, Black, Ruff and Pyright, and the 3.11 floor through the CI matrix, pending CI, F5), U22 (CI-dependent, pending CI, F5)
