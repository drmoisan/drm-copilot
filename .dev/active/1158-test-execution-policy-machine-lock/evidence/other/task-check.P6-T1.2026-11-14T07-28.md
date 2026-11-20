# Task Check: P6-T1

Timestamp: 2026-11-14T07-28
Command: sha256sum over the six SKILL.md copies; `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest -q <selection>`; Pester `Run.Path` = `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`, `Run.Exit` = `$true`
EXIT_CODE: 1
Output Summary: the six copies share one SHA-256 (prefix 6c3dab0720d255d3); the canonical file opens with a frontmatter block whose `name` is `test-execution-policy` and whose `description` is non-empty; `test_claude_rules_frontmatter.py` passes; `parallel-gate-wording.Tests.ps1` 56 passed, 0 failed (the `PGW-SWEEP-SURFACES` sweep finds no removed-class token). pytest selection 103 passed, 4 failed; the 4 failures name only the three launcher scripts and the skill pack membership, which P6-T2 bundles and manifests (planned ordering).

## Changed Files

- `.claude/skills/test-execution-policy/SKILL.md` (new, canonical)
- `.agents/skills/test-execution-policy/SKILL.md`, `.github/skills/test-execution-policy/SKILL.md` (byte-identical copies)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/test-execution-policy/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/test-execution-policy/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/test-execution-policy/SKILL.md` (bundle copies)

The file documents every configuration key with its default and validation rule, the lock locations and file names, the seven holder-record fields, exit codes 75 and 2 with the D12 consumer classification and the `TEST_EXECUTION_SUITE_EXIT:` remap, both prefixes, the D19 npm rule, the D25 prefix and launch-command forms, the D9 worker tokens per runner, the two launcher command forms and the `env -u VIRTUAL_ENV` pytest form, the `Invoke-PesterSuite.ps1` entry with its D26 argument rules, the three disable switches, and the MCP gap. It carries `CI integration and golden lanes are evidence`, `non-blocking deviation`, and `machine test-suite lock`.

## Selection and Rule

Rule: for a changed Markdown path, the contract tests that read it (`## Test Cadence (Mandatory)`).

- pytest: `test_claude_rules_frontmatter.py`, `test_codex_full_migration_inventory.py`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_issue_824_follow_ups.py`, `test_skill_bundle_contract_repo.py` (all under `tests/scripts/dev_tools/`).
- Pester: `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`.

## Commands and Exit Codes

| Step | Command | EXIT_CODE |
|---|---|---|
| hash parity | `sha256sum` over the six copies | 0 (one hash) |
| contract tests | launcher `pytest` suite with the selection | 1 (4 planned-ordering failures) |
| wording sweep | Pester `parallel-gate-wording.Tests.ps1` | 0 |

Format, lint, and type check: not applicable (Markdown). A first draft named `bash scripts/bash/shell-qc.sh test`, which the skill-bundle contract reads as an unbundled script invocation; the sentence was reworded and the copies re-made before this record.
