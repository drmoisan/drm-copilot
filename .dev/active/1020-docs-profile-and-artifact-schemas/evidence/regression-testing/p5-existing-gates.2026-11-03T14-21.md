# Existing Repository Gates ([P5-T5])

Timestamp: 2026-11-03T14-21
Command: git add -- .claude/lib/docs (index only, no commit), then poetry run python -m scripts.dev_tools.check_quality_tiers
EXIT_CODE: 0
Output Summary: `quality-tiers: OK (29 entries, 29 discovered projects)`; the new `.claude/lib/docs` entry (T3) is a discovered project, no `QT007`.

---

Timestamp: 2026-11-03T14-21
Command: poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract_classification.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py -q -p no:cacheprovider --no-cov -rA (serial)
EXIT_CODE: 0
Output Summary: 60 passed, 0 failed. PASSED: `test_every_psscriptroot_occurrence_is_recognized`, `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, `test_committed_quality_tiers_yml_matches_live_tree`, `test_committed_quality_tiers_yml_assigns_spec_tiers`, `test_claude_manifest_powershell_dependency_closure`.

---

Timestamp: 2026-11-03T14-21
Command: poetry run pytest <same five files> -q -p no:cacheprovider --no-cov -n auto --strict-markers --strict-config (parallel, the CI pytest flags)
EXIT_CODE: 0
Output Summary: 60 passed, 0 failed in 4.43s.

## First-pass failure and fix (micro-action within this task)

The first serial run (same command, before the fix) reported 59 passed and 1 failed: `test_every_psscriptroot_occurrence_is_recognized` named the line in `Test-DocsAnalyzerModulePath` (`.claude/lib/docs/DocsAnalyzerRegistry.psm1`) that read `[System.IO.Path]::GetFullPath($PSScriptRoot)`, a spelling that is neither a dependency form nor a named non-dependency form of `tests/scripts/dev_tools/pack_manifest_dependency_scan.py`. The private helper now takes `[string] $ScriptRoot = $PSScriptRoot` (the named non-dependency form `$ScriptRoot = $PSScriptRoot`) and uses `$ScriptRoot`; its only caller passes `-Module` alone, so behavior is unchanged. The bundle mirror was re-synced (`sh SCRATCH/issue-1020-exec-mirror.sh`, 17 of 17 EQUAL; new `DocsAnalyzerRegistry.psm1` SHA-256 `8d75a5f564a9957c7c728d8d6fe39453db7910f97700683aade4ae33aa92da09`), the index was re-staged, and both commands above were re-run.

No test file was modified: `git status --porcelain -- tests/scripts/dev_tools` prints nothing.

CI: `quality-checks7 / Code Quality & Tests (3.11)` through `(3.13)`.
