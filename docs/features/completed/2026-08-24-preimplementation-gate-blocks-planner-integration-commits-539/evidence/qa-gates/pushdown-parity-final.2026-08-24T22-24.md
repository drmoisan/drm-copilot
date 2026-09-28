# Final Push-Down Parity [P7-T6]

Timestamp: 2026-08-24T22-24

## Pre-run state clear

The parity suite enumerates every file under the repository `.claude/` tree from the filesystem,
excluding only `.claude/settings.local.json` and `.claude/agent-memory/**`. Any gitignored file
resident under `.claude/state/` therefore fails it — including a `powershell-batch-budget.*.json`
written by the batch-budget hook during the loop, or a `python-batch-budget.*.json` left by the
Python budget hook earlier in the session. The [P4-T5] whole-directory clear was applied before
running.

Command: `Get-ChildItem -LiteralPath .claude/state -Force | Remove-Item -Recurse -Force`

- Entries before clear: **0**
- Entries after clear: **0**
- Entries after the parity run: **0**

The directory was already empty. The [P7-T1] format stage changed zero files, so no batch-budget
state file was created during this final loop; the clear was applied unconditionally regardless,
as the task requires.

## Parity run

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q`

EXIT_CODE: 0

Output:

```
.............                                                            [100%]
13 passed in 0.23s
```

- Total tests: **13**
- Passed: **13**
- Failed: **0**
- Errors: **0**

## What these three suites gate

- `test_push_down_claude_resource_contracts.py` — asserts the Claude canonical/bundle content
  equality for the hook and helper pair, and the skill mirrors touched in Phase 6. This is the
  programmatic enforcement behind the Claude half of spec AC 6, independent of the recorded
  pair-hash artifacts.
- `test_push_down_codex_and_agents_pack_manifest_completeness.py` — asserts the Codex pack
  manifest lists every published file, which is what makes the [P5-T4] helper registration in
  `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`
  effective rather than merely present.
- `test_poshqc_bundled_parity.py` — its `test_poshqc_bundled_module_files_match_repo_root_sources`
  requires text equality of `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` with its
  bundled counterpart, which gates spec AC 9. Both copies carry the two new `CodeCoverage.Path`
  helper entries added by [P2-T3] and [P3-T3], and this passing result confirms they agree.

This last point is the parity obligation that is distinct from instrumentation: the MCP test
runner reads the installed extension's runsettings rather than either in-repo copy (recorded in
[P7-T3]), so a passing parity test here does not imply the MCP runner measures the helper files —
and the MCP runner's silence about them does not imply the registration failed. The two
obligations are separate, and both are satisfied: parity here, instrumentation via the self-hosted
module invocation in [P7-T3].

No failure occurred, so no pair identity required restoration and no restart from [P7-T1] was
triggered.

## Output Summary

PASS. `.claude/state/` was cleared and verified empty before and after the run. All 13 tests
across the three push-down parity suites passed with exit code 0 and zero failures. The Claude
pair contract, the Codex pack-manifest completeness check, and the PoshQC bundled-settings text
equality all hold against the delivered tree.
