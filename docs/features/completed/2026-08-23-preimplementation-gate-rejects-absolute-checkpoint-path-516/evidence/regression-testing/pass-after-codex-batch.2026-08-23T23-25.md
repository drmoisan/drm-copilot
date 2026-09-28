# Pass-After Capture — Codex Family Batch (issue #516)

Timestamp: 2026-08-24T16-09
Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a96d0b5541701860e` and `scan_folders` = `["tests/scripts/codex-hooks"]`
EXIT_CODE: 0

## Run Result

```json
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a96d0b5541701860e","summary":"Ran bundled PoshQC test against '...' with 1 selected scan folder(s)."}
```

Counts read from `artifacts/pester/pester-junit.xml`:

```text
TOTAL tests=512 failures=0 errors=0
  codex-preimplementation-gate-absolute-paths.Tests.ps1 | tests=35 failures=0 errors=0
  codex-pretooluse-transport.Tests.ps1                  | tests=56 failures=0 errors=0
  legacy-codex-hook-contracts.Tests.ps1                 | tests=43 failures=0 errors=0
```

| Suite required by [P3-T5] | Tests | Failures | Verdict |
| --- | --- | --- | --- |
| `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1` (new) | 35 | 0 | PASS |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (run-only, unmodified) | 43 | 0 | PASS |
| `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` (run-only, unmodified) | 56 | 0 | PASS |

Zero failures across all three required suites, and zero failures across the whole `tests/scripts/codex-hooks` folder (512 tests).

## Byte-Identity Never Observed a Split State

`legacy-codex-hook-contracts.Tests.ps1` carries the root-to-bundle byte-identity assertion for the Codex family, and it passes. That assertion was never at risk of observing a split state: [P3-T4] copied the edited canonical file to the bundle mirror **before** this run and before any commit exists, so both Codex copies were already byte-identical when the assertion executed.

`Get-FileHash` at [P3-T4], for both Codex copies:

```text
98DC6917AE5AE3239DBE89C31391960D260AB74B83A51D93FA9D575AA16DBABD
```

## apply_patch Idempotence Held

The two `apply_patch` cases in the new Codex suite both pass:

- a repo-relative file-marker path for a production `.ps1` file still classifies as an implementation path and **denies**;
- a repo-relative file-marker path for a checkpoint literal still classifies as bookkeeping and **allows**.

This is the load-bearing idempotence proof for the call site that passes repo-relative paths: `(^|/)` matches at `^`, so a path harvested from a file marker by `Test-ImplementationCommand` classifies exactly as it did before the change. `Test-ImplementationCommand` and its marker-harvesting loops are byte-unchanged, which the [P3-T3] hunk inspection confirms: `git diff -U0` reports exactly two hunks in the Codex copy, at original lines 65 and 76-77, both inside `Test-FeatureDocumentationOrEvidencePath` and `Test-ImplementationPath` respectively. `Test-ImplementationCommand` begins at original line 82 and is untouched.

Output Summary: Pester over `tests/scripts/codex-hooks` reports 512 passed, 0 failed, 0 errored. All three suites named by [P3-T5] report zero failures. The new Codex absolute-paths suite went from 19 failures in the fail-before capture to 0, the Codex family byte-identity assertion passes against a pair made identical before this run, and both `apply_patch` idempotence cases pass, confirming the repo-relative call site is unaffected.
