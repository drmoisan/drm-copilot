# Phase 0 — Python Parity and Pack-Manifest Baseline (issue #554)

Timestamp: 2026-08-26T10-18

Command:

```bash
poetry run pytest \
  tests/scripts/dev_tools/test_poshqc_bundled_parity.py \
  tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py \
  tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py \
  tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py
```

EXIT_CODE: 0

Output Summary:

| Metric | Value |
| --- | --- |
| Passed | **22** |
| Failed | **0** |
| Collected | 22 |
| Wall time | 0.59 s |

Per-file collection:

| File | Tests |
| --- | --- |
| `test_poshqc_bundled_parity.py` | 1 |
| `test_push_down_claude_resource_contracts.py` | 10 |
| `test_push_down_codex_and_agents_resource_contracts.py` | 9 |
| `test_push_down_codex_and_agents_pack_manifest_completeness.py` | 2 |

**No failing test node.** All 22 tests passed at baseline.

## Annotation on the Known Issue #510 Condition

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
**passed** in this baseline run. It is the test tracked by open issue #510: it enumerates the whole
`.claude/**` tree and compares it against the bundled payload at
`extensions/drm-copilot/resources/claude-customizations/`, and it fails whenever a gitignored
`.claude/state/*.json` counter file exists in the repository tree, because that file has no bundled
counterpart.

That condition is **not currently reproducible in this checkout**: `.claude/state/` holds no counter
file at the branch point, which is why the test passes here. The research pass recorded the same
observation independently (section A4).

**Forward-looking annotation, recorded now so a later failure is not misread.** The PreToolUse hook
`.claude/hooks/enforce-powershell-batch-budget.ps1` writes a session-scoped counter at
`.claude/state/powershell-batch-budget.*.json` on every `.ps1`, `.psm1`, and `.psd1` write. Phases 1
through 4 of this plan write such files, so that counter file will come into existence during
execution and this test may begin to fail. If it does:

- the failure is the **pre-existing issue #510 condition**, not a regression introduced by this
  change;
- CI is unaffected, because the counter file is gitignored and never reaches a CI checkout;
- **deleting the state file is not a durable fix and must not be attempted as one.** The plan's
  batch-budget counter resets at P2-T18, P3-T23, P4-T4, P4-T12, and P6-T9 delete that counter for the
  separate and unrelated purpose of resetting the per-batch write budget, as the hook's own block
  reason prescribes. Those resets are not a remediation of issue #510 and must not be conflated with
  one.

This artifact is the baseline that P4-T9, P5-T9, and P6-T5 cite as proof that any such failure
predates this change.
