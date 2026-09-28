# Known Pre-Existing Local Failure — Issue #510, Not a Regression

Timestamp: 2026-08-26T11-36

Command:

```bash
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q
```

EXIT_CODE: 1

Output Summary: 1 failed. The failure is the pre-existing issue #510 condition, confirmed by its
verbatim assertion text, and is **not** a regression introduced by issue #554.

---

## The test node

```text
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

## Open issue

**#510.** The test enumerates the whole `.claude/**` tree and asserts every repository runtime file
has a counterpart in the bundled payload at
`extensions/drm-copilot/resources/claude-customizations/`. Gitignored `.claude/state/*.json` counter
files are enumerated by that scan but have no bundled counterpart, so the test fails whenever such a
counter exists in the working tree.

## Verbatim failure, confirming the attribution exactly

```text
E   AssertionError: Repo file missing from bundle: .claude\state\powershell-batch-budget.default.json
E   assert WindowsPath('.claude/state/powershell-batch-budget.default.json') in [...]
tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py:120: AssertionError
```

The single missing path named by the assertion is a `.claude/state/` counter file and nothing else.
No file this feature writes appears in the failure. The attribution is therefore exact rather than
inferred: had this change omitted one of its own files from the bundle, that file's path would be
the one named here.

## Why the counter file exists in this checkout

`.claude/hooks/enforce-powershell-batch-budget.ps1` is registered on the `Write|Edit` PreToolUse
matcher and writes a session-scoped counter at `.claude/state/powershell-batch-budget.*.json` on
every `.ps1`, `.psm1`, and `.psd1` write. Phases 1 through 4 of this plan wrote such files, so the
counter came into existence during execution:

```
.claude/state/powershell-batch-budget.default.json   399 bytes   2026-08-26 11:21
```

## Non-regression conclusion, with its evidence cited

The baseline artifact
`docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/baseline/phase0-python-parity.2026-08-26T10-18.md`
(task P0-T9) is the evidence for this conclusion. Two facts from it are load-bearing:

1. **At the branch point the test PASSED** — 22 passed, 0 failed across the four suites, with this
   node among the passes — because `.claude/state/` held no counter file at that moment.
2. **The baseline artifact recorded the forward-looking annotation before the failure occurred**,
   stating that the plan's own `.ps1` and `.psd1` writes would bring the counter into existence and
   that a resulting failure "is the **pre-existing issue #510 condition**, not a regression
   introduced by this change."

The failure is therefore caused by the *presence of a gitignored state file*, not by any content
difference between the repository `.claude/` tree and the bundled payload. The predicted cause and
the observed cause match exactly.

## CI is unaffected

The counter file is gitignored, so it never reaches a CI checkout, and the whole-tree comparison
finds nothing extra there. This failure is reproducible only in a local working tree in which a
PowerShell write has occurred during the session.

## Deleting the state file is not a durable fix and must not be attempted as one

The file regenerates on the next `.ps1`, `.psm1`, or `.psd1` write — that is, within minutes of any
further PowerShell work in the session. Deleting it produces a green run that reverts on the next
write, which conceals the open issue rather than closing it.

**A distinction that must not be conflated.** This plan *does* delete files matching
`.claude/state/powershell-batch-budget.*.json` at P2-T18, P3-T23, the P4-T4 preamble, P4-T12, and
P6-T9. Those deletions are batch-budget counter resets performed for an entirely separate purpose —
resetting the per-batch production-file write budget, by the mechanism the batch-budget hook's own
block reason prescribes. They are **not** a remediation of issue #510, they are not performed to
make this test pass, and a reader must not read them as one. Any of them incidentally clearing the
condition for a short window does not change that.

## Downstream consumers of this record

- **P4-T9** (`evidence/qa-gates/pack-manifest-and-payload-parity.2026-08-26T11-23.md`) recorded 22
  passed, 1 failed, with this node as the sole failure and the P0-T9 baseline cited.
- **P6-T5** runs the same suites in the final QC loop and annotates the same node against the same
  baseline. Under the P6-T5 acceptance condition, this failure alone does not restart the toolchain
  loop; any *other* failure does.
