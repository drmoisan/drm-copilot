# Phase 0 — Baseline pytest Parity Gates (Issue #415)

Timestamp: 2026-07-25T19-20

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py -q`

## Run 1 — as-found working tree (transient `.codex/state/` present)

EXIT_CODE: 1

```
...F....                                                                 [100%]
FAILED tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts
1 failed, 7 passed in 0.15s
```

Failure detail:

```
E  AssertionError: assert WindowsPath('.codex/state/powershell-batch-budget.019f9b0e-e677-75d0-9942-e53f5468c9ee.json') in [ ... bundled files ... ]
tests\scripts\dev_tools\test_push_down_codex_and_agents_resource_contracts.py:215: AssertionError
```

## Run 2 — after removing the transient Codex hook runtime directory

Preparatory command: `rm -rf .codex/state`

EXIT_CODE: 0

```
........                                                                 [100%]
8 passed in 0.11s
```

## Output Summary

**Both parity modules pass at baseline (exit 0, 8 passed) once the transient Codex hook runtime directory is removed.**

Collected tests (8 total, both modules present):

- `test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_required_runtime_files`
- `test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_pack_manifests_and_variants_exist`
- `test_push_down_codex_and_agents_resource_contracts.py::test_routing_config_remains_a_shared_resource_outside_codex_bundle`
- `test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`
- `test_push_down_codex_and_agents_resource_contracts.py::test_codex_config_files_retain_full_drm_copilot_transport`
- `test_push_down_codex_and_agents_resource_contracts.py::test_codex_role_files_do_not_retain_drm_copilot_transport`
- `test_push_down_codex_and_agents_pack_manifest_completeness.py::test_bundled_codex_files_are_listed_in_some_pack_manifest`
- `test_push_down_codex_and_agents_pack_manifest_completeness.py::test_no_bundled_codex_file_is_absent_from_disk_and_exception_list`

## Deviations from the plan's expected baseline (recorded)

**Deviation 1 — the expected `.codex/config.toml` text-mismatch failure did not occur.** Plan `[P0-T6]` anticipated "resource-contracts failure on `.codex/config.toml` root/bundle text mismatch". The branch was rebased onto `origin/main` (`00980851`) after the earlier Phase 0 session, which dropped the uncommitted `.codex/config.toml` ordering-swap diff. Root and bundle `config.toml` are already byte-identical, so `test_codex_config_files_retain_full_drm_copilot_transport` and the payload-contract tests pass. This confirms the Resume-Point statement that `[P1-T2]` step (b) is a no-op and steps (c)/(d) are verification only.

**Deviation 2 — a different, environmental failure was observed and remediated.** `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` enumerates the on-disk `.codex` tree via `list_scoped_files(REPO_ROOT)` (`test_push_down_codex_and_agents_resource_contracts.py:105-114`) and asserts every repo-side `.codex` file also exists in the bundle. The directory `.codex/state/` is Codex hook runtime output: it is untracked and **not** matched by `.gitignore` (`git check-ignore` exited 1), so the enumeration picked up the transient file `powershell-batch-budget.019f9b0e-e677-75d0-9942-e53f5468c9ee.json`.

That file was per-session batch-budget counter state left over from a prior Codex session (contents: `prodCap: 3`, `testCap: 3`, two `prodFiles` entries under `.codex/scripts/resolve-codex-routing.ps1`, empty `testFiles`). It is transient runtime state, not repository content, and it is not part of the issue #415 change scope.

Remediation applied: the transient directory was deleted with `rm -rf .codex/state`. This is environment hygiene only — no tracked file was added, removed, or modified, and `git status --porcelain` after the deletion shows only this feature's own plan/evidence edits. The directory was never committed and is not added to version control, per the standing constraint.

Forward implication: plan convention **C2/C4** already requires every process-level test payload to target `README.md` so the batch-budget entrypoints write nothing under `.codex/state/`. That convention must be honoured in Phase 1 and Phase 7 or this same parity failure will reappear. Plan task `[P8-T9]` assertion (b) ("NO `.codex/state/*` file is staged or committed") is the closing check.
