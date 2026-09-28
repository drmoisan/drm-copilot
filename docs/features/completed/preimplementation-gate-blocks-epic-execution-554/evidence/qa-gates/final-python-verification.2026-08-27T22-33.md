# P6-T5 — Final Python Verification Suites

Timestamp: 2026-08-27T22-33

Loop iteration: 2 (the same Phase 6 iteration anchored by
`final-poshqc-format.2026-08-27T22-24.md`)

Command:

```bash
poetry run pytest \
  tests/scripts/dev_tools/test_poshqc_bundled_parity.py \
  tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py \
  tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py \
  tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py \
  tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
```

EXIT_CODE: 1

ExpectedExitCode: 1

Output Summary:

| Metric | Value |
| --- | --- |
| Collected | 24 |
| **Passed** | **23** |
| **Failed** | **1** |
| Errors | 0 |
| Wall time | 0.47 s |

```text
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
collected 24 items
...
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
======================== 1 failed, 23 passed in 0.47s =========================
```

The single failure is the whole-tree bundled-Claude-payload test attributable to **open issue #510**.
The task's acceptance permits exactly this failure when annotated against the P0-T9 baseline. The
annotation follows. The exit code of 1 is therefore the expected outcome, recorded in the optional
`ExpectedExitCode` field rather than reported as a gate failure.

## The failing assertion names the gitignored counter file directly

```text
AssertionError: Repo file missing from bundle: .claude\state\powershell-batch-budget.default.json
tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py:120
```

`test_bundled_claude_payload_contains_all_repo_runtime_contracts` enumerates the whole `.claude/**`
tree and requires every non-memory file to have a bundled counterpart under
`extensions/drm-copilot/resources/claude-customizations/`. The only path it reports as missing is
the session-scoped batch-budget counter:

```text
$ ls -la .claude/state/
-rw-r--r-- 1 DanMoisan 197121 399 Aug 26 11:21 powershell-batch-budget.default.json

$ git check-ignore -v .claude/state/powershell-batch-budget.default.json
.gitignore:68:.claude/state/	.claude/state/powershell-batch-budget.default.json
```

The file is gitignored at `.gitignore:68`, so it never reaches a CI checkout and CI is unaffected.

## Annotation against the P0-T9 baseline

`evidence/baseline/phase0-python-parity.2026-08-26T10-18.md` recorded 22 passed and **no failing test
node** at the branch point, because `.claude/state/` held no counter file then. The same baseline
carries a forward-looking annotation that predicts this exact failure verbatim:

> The PreToolUse hook `.claude/hooks/enforce-powershell-batch-budget.ps1` writes a session-scoped
> counter at `.claude/state/powershell-batch-budget.*.json` on every `.ps1`, `.psm1`, and `.psd1`
> write. Phases 1 through 4 of this plan write such files, so that counter file will come into
> existence during execution and this test may begin to fail. If it does: the failure is the
> **pre-existing issue #510 condition**, not a regression introduced by this change; CI is
> unaffected, because the counter file is gitignored and never reaches a CI checkout; **deleting the
> state file is not a durable fix and must not be attempted as one.**

The predicted condition occurred exactly as described, so the failure is **pre-existing and out of
scope for issue #554**. The state file was not deleted to make this test pass.

The collected count grew from 22 to 24 because P4-T7 and P4-T8 registered the four new files in the
two pack manifests, adding two assertions. Both new assertions pass.

## Distinguishing this from a real parity failure

A genuine parity regression would show as a mismatch between a file this change actually mirrored and
its bundled counterpart. Every such file was hashed in the same pass:

```powershell
foreach ($p in $pairs) {
  $ha = (Get-FileHash -Algorithm SHA256 -LiteralPath $p[0]).Hash
  $hb = (Get-FileHash -Algorithm SHA256 -LiteralPath $p[1]).Hash
  '{0} :: {1} :: {2}' -f $p[0], $ha, $(if ($ha -eq $hb) { 'MATCH' } else { 'DIFFER' })
}
```

| Mirrored file | SHA-256 | Verdict |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `0C8C55CE222EE9241B061A2964D5A0BB7154EB57F2B91A9D0F049B4DA82B863E` | **MATCH** |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | `0FFAB72EF27B3AE38F60A38DC1BA60A5F974FAC91A4FA7D28F5094A790B455A4` | **MATCH** |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `B978BAD8B304B2917AFBE524F0043F5018FF0F06C7719A27550C6E888A3B706D` | **MATCH** |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | `8E1165818AE0AE20B63486D2AA51D98A7875FEA9BA7D2F15E0762DF850AA4F0A` | **MATCH** |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `399D6CE69C821AD47CBD33957BEBE9EB8076FB622F84F686728D42D8862D9FB1` | **MATCH** |

Every file this change mirrored is byte-identical to its bundled counterpart. The failing path
`.claude/state/powershell-batch-budget.default.json` is not among them and was never mirrored by this
change: it is runtime state written by an unrelated enforcement hook. The four `.ps1` hashes are
identical to those recorded at P5's `mirror-pair-hashes.2026-08-26T11-23.md`, so nothing mirrored has
drifted since Phase 5. The formal four-pair recomputation after the budget reset is P6-T9.

## Loop consequence

The plan directs that any failure other than the issue #510 one restarts the loop at P6-T1. There is
no other failure, so the loop advances to P6-T6 without a restart.

## Verdict

PASS. 23 of 24 tests pass; the single failure is the bundled-Claude-payload whole-tree test
attributable to issue #510, annotated against the P0-T9 baseline as that task's acceptance permits.
