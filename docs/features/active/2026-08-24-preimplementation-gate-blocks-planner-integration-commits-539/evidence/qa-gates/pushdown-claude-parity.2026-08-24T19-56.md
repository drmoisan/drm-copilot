# Push-Down Claude Parity and PoshQC Bundled Parity — issue #539 [P4-T6]

Timestamp: 2026-08-24T19-56

Command:

```
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q
```

EXIT_CODE: 0

## Raw result

```
...........                                                              [100%]
11 passed in 0.39s
```

## What this run gates

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` enumerates every file under
  repo `.claude/` from the filesystem (excluding only `.claude/settings.local.json` and
  `.claude/agent-memory/**`) and asserts each is content-equal to its bundled counterpart. The
  Phase 4 additions in scope are the edited canonical Claude hook mirrored by [P4-T1], the new
  canonical Claude helper mirrored by [P4-T2], and the Claude pack manifest entry added by [P4-T4].
- `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` carries
  `test_poshqc_bundled_module_files_match_repo_root_sources`, which requires text equality of
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` with
  `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`. That
  equality was broken by the [P2-T3] and [P3-T3] self-hosted edits and is restored by the [P4-T3]
  mirror edit. This test gates spec AC 9.
- The run was preceded by the [P4-T5] whole-directory clear, so no gitignored `.claude/state/`
  file was resident to fail the filesystem-enumerated assertion.

Output Summary: PASS. 11 passed, 0 failed, 0 errors, in 0.39s. Exit code 0. Every repo `.claude/**`
file — including the edited Claude bundle hook, the new Claude bundle helper, and the updated Claude
pack manifest — is content-equal to its bundled counterpart, and the two PoshQC coverage-settings
copies are text-equal again after the [P4-T3] mirror edit.
