# Pack-Manifest Registration and Bundled-Payload Parity (issue #554)

Timestamp: 2026-08-26T11-23

Command:

```bash
poetry run pytest \
  tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py \
  tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py \
  tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py \
  tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py
```

EXIT_CODE: 1

Output Summary:

| Metric | Value |
| --- | --- |
| Passed | **22** |
| Failed | **1** |
| Collected | 23 |

Per-file counts, taken from individual runs so the attribution is exact:

| File | Passed | Failed |
| --- | --- | --- |
| `test_push_down_codex_and_agents_pack_manifest_completeness.py` | 2 | **0** |
| `test_push_down_claude_pack_manifest_completeness.py` | 2 | **0** |
| `test_push_down_codex_and_agents_resource_contracts.py` | 9 | **0** |
| `test_push_down_claude_resource_contracts.py` | 9 | **1** |

The single failing node is:

```text
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

## The Acceptance Conditions Are Met

- **The Codex pack-manifest completeness test passes** (2 of 2), proving the bundled Codex modes
  hook was registered by P4-T8. The pre-existing-unrelated-hook exception set inside that test file
  is **unchanged**: `git status --porcelain -- tests/` returns no output, so no test file is
  modified in the working tree, and no test file appears in the branch diff.
- **The Claude pack-manifest completeness test passes** (2 of 2), proving the bundled Claude modes
  hook was registered by P4-T7.
- **The Codex payload contract test passes** (9 of 9).

## The One Failure Is the Pre-Existing Issue #510 Condition, Established by Measurement

The failure is **not** assumed to be issue #510 and is **not** assumed to be a real parity failure.
It was classified by two independent measurements.

### Measurement 1 — the assertion names a gitignored state counter, not a mirrored file

The assertion message is:

```text
AssertionError: Repo file missing from bundle: .claude\state\powershell-batch-budget.default.json
```

`.claude/state/powershell-batch-budget.default.json` is the session-scoped counter written by the
PreToolUse hook `.claude/hooks/enforce-powershell-batch-budget.ps1` on every `.ps1`, `.psm1`, and
`.psd1` write. It is gitignored, has no bundled counterpart by design, and is not a file this change
mirrors. It came into existence during this phase because P4-T5 and P4-T6 wrote two `.psd1` files.

### Measurement 2 — the whole-tree comparison has exactly one missing path, and it is that file

Running the test's own helpers directly over the same two trees:

```python
from test_push_down_claude_resource_contracts import (
    list_scoped_files, BUNDLED_ROOT, REPO_ROOT, _is_agent_memory_path)
```

produced:

| Query | Result |
| --- | --- |
| Repo `.claude` files missing from the bundle, total | **1** |
| The missing path | `.claude\state\powershell-batch-budget.default.json` |
| Repo `.claude` files missing from the bundle, excluding `.claude/state/` | **0** |

Excluding the gitignored state subtree, the whole-tree comparison finds **zero** missing paths. The
two files this change added under `.claude/hooks/` are therefore present in the bundle, which is the
positive form of the same check.

### Measurement 3 — hashing the files actually mirrored

Per the plan's operational condition that the Python parity tests cannot observe a line-ending or
trailing-byte difference, every mirrored pair was hashed with `Get-FileHash -Algorithm SHA256`:

| Pair | Hash | Verdict |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `0C8C55CE222EE9241B061A2964D5A0BB7154EB57F2B91A9D0F049B4DA82B863E` | **MATCH** |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | `0FFAB72EF27B3AE38F60A38DC1BA60A5F974FAC91A4FA7D28F5094A790B455A4` | **MATCH** |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `B978BAD8B304B2917AFBE524F0043F5018FF0F06C7719A27550C6E888A3B706D` | **MATCH** |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | `8E1165818AE0AE20B63486D2AA51D98A7875FEA9BA7D2F15E0762DF850AA4F0A` | **MATCH** |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `399D6CE69C821AD47CBD33957BEBE9EB8076FB622F84F686728D42D8862D9FB1` | **MATCH** |

All five pairs are byte-identical. No mirrored file is the cause of the failure.

### Baseline citation

`docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/baseline/phase0-python-parity.2026-08-26T10-18.md`
records this test **passing** at the branch point, with `EXIT_CODE: 0` and 22 of 22 passed, together
with a forward-looking annotation stating that the counter file would come into existence during
Phases 1 through 4 and that a resulting failure would be the issue #510 condition rather than a
regression. That prediction is what this run confirms.

**Conclusion: the failure predates this change, is tracked as open issue #510, and is not a
regression introduced here.** CI is unaffected because the counter file is gitignored and never
reaches a CI checkout. Deleting the state file is not a durable fix and was not attempted as one.
