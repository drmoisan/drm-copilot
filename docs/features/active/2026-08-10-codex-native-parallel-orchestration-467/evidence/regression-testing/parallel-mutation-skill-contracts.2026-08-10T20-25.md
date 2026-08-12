# Parallel mutation skill contracts

- Task: `P2-T7`
- Captured: `2026-08-11T01:40:32.160-04:00`
- Result: PASS

## Published surfaces

| Skill | Root and bundle lines | SHA-256 | Byte parity |
|---|---:|---|---|
| `parallel-add` | 66 / 66 | `D06F57D8EAD38A246AE05FCA85509429E1BF57D5789C7B53294157493B4AF99E` | PASS |
| `parallel-remove` | 60 / 60 | `D6D7F4333B477260B2AA379F87F2B7BA107E4F5F4F25408D998514461C6622CC` | PASS |
| `parallel-close` | 58 / 58 | `F53C5EF7895BA90421156736D7C4DD306BD1F2FF12988A47D3B5379106471C0B` | PASS |

The initial `parallel-add` root file ended with two LF bytes while its mirror ended with one. The
surplus root EOF blank line was removed before validation. The final pair is byte-identical.

## Authority boundary

- Add calls `decide_admission`, conditionally `recolor_unstarted`, and `build_add_entry` from
  `scripts/dev_tools/parallel_mutation_protocol.py`.
- Remove calls `decide_removal`, conditionally `recolor_unstarted`, and `build_remove_entry` from
  the same Python authority.
- Close calls `decide_close` and `build_close_entry` from the same Python authority.
- Every complete candidate is passed to public `validate_orchestration_artifacts` with artifact
  type `parallel-orchestrator-state`; persistence is denied unless Python and MCP validation both
  accept.

## Command evidence

### Skill parser

- Timestamp: `2026-08-11T01:40:32.160-04:00`
- Command: `python C:\Users\DanMoisan\.codex\skills\.system\skill-creator\scripts\quick_validate.py <each root and bundle mutation skill>`
- EXIT_CODE: `0`
- Output Summary: Six of six skill directories reported `Skill is valid!`; failures `0`.

### Root provenance and non-delegation

- Timestamp: `2026-08-11T01:40:32.160-04:00`
- Command: `Invoke-Pester -Path tests/scripts/codex-hooks/parallel-provenance.Tests.ps1 -PassThru -Output Detailed`
- EXIT_CODE: `0`
- Output Summary: `14` passed, `0` failed, `0` skipped. The three mutation skills passed the root-only and non-delegating-client cases.

### Python mutation authority

- Timestamp: `2026-08-11T01:40:32.160-04:00`
- Command: `poetry run pytest -q tests/scripts/dev_tools/test_parallel_mutation_protocol.py tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py tests/scripts/dev_tools/test_parallel_mutation_admission.py tests/scripts/dev_tools/test_parallel_mutation_recolor.py tests/scripts/dev_tools/test_parallel_mutation_parity.py tests/scripts/dev_tools/test_parallel_mutation_pin_stability_properties.py tests/scripts/dev_tools/test_parallel_mutation_contention_properties.py tests/scripts/dev_tools/test_parallel_mutation_cohort_invariant_binding.py tests/scripts/dev_tools/test_parallel_mutation_abandon_cli.py tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mutations.py tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mutation_modes.py`
- EXIT_CODE: `0`
- Output Summary: `408` passed in `0.53s`, including positive and negative admission, removal, close, sequence, pin-stability, contention, confirmation, and mode cases.

### TypeScript parity and public artifact dispatch

- Timestamp: `2026-08-11T01:40:32.160-04:00`
- Command: `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/parallel-mutation-parity.test.ts test/lib/validate/parallel-orchestrator-state-structures.test.ts test/lib/validate/parallel-orchestrator-state-completion.test.ts test/lib/validate/parallel-orchestrator-state-cohort-barrier.test.ts test/lib/validate/orchestration-artifacts-parallel-dispatch.test.ts`
- EXIT_CODE: `0`
- Output Summary: Five suites passed; `135` tests passed; no snapshots.

### Static validated-client contract

- Timestamp: `2026-08-11T01:40:32.160-04:00`
- Command: `PowerShell in-memory assertions over the three root skills and byte-identical mirrors`
- EXIT_CODE: `0`
- Output Summary: `45` assertions passed. Checks covered root provenance, non-delegation, Python/MCP authority references, seven-field records, fail-closed persistence, duplicate-key rejection, pinned in-flight work, merged-removal rejection, exact operation/item/worktree confirmation, in-flight close rejection, and explicit open-mode close before completion.

### Repository integrity

- Timestamp: `2026-08-11T01:40:32.160-04:00`
- Command: `git status --porcelain -- .claude; git diff --check`
- EXIT_CODE: `0`
- Output Summary: `.claude` status count `0`; `git diff --check` exit `0`.

## Acceptance result

- Complete mutation records preserve exactly `op`, `item_key`, `at`, `prior_state`, `new_state`,
  `disposition`, and `recolor_generation`, with strictly ordered timestamps and authority-controlled
  generation progression.
- Add rejects duplicate keys and cannot move in-flight work.
- Remove rejects merged items, pins in-flight work, and requires detach or abandon confirmation
  bound to the exact operation, item key, and canonical worktree identity.
- Close rejects in-flight work and makes an accepted explicit close mandatory before open-mode
  completion.
- All validator rejections fail closed without checkpoint or mutation-log persistence.
