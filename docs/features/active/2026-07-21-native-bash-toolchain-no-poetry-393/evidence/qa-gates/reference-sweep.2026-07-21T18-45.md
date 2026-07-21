# QA Gate — Final Reference Sweep (P4-T8) (Issue #393)

Timestamp: 2026-07-21T18-45
Command: rg -n "shell_qc|shell-qc" (repository-wide), reconciled against the P0-T11 baseline
         inventory; frozen paths (docs/features/completed/**, docs/features/archive/**, other
         features' evidence/research/spec) and this feature's own folder excluded.
EXIT_CODE: 0

## Result: zero unexpected live references remain.

Every remaining live hit is a new native-toolchain surface or an updated consumer:

| Surface | Reference | Status |
|---------|-----------|--------|
| scripts/bash/shell-qc.sh | new wrapper (self-referential comments/usage) | new file |
| scripts/bash/shell_qc_lib.sh | new library | new file |
| tests/shell/test_shell_qc_discovery.bats | new bats suite | new test |
| tests/shell/test_shell_qc_commands.bats | new bats suite | new test |
| tests/fixtures/shell_qc/stub-bin/{shfmt,shellcheck,bats,kcov} | stub comments | new fixtures |
| .claude/rules/shell.md | native invocation docs | new rule |
| .vscode/tasks.json (436,457,499) | scripts/bash/shell-qc.sh | repointed (P3-T3) |
| .github/workflows/_shell-coverage.yml (51-52) | bash scripts/bash/shell-qc.sh test --coverage | migrated (P4-T1) |
| .github/workflows/_build-check.yml (37) | bash scripts/bash/shell-qc.sh --help | migrated (P4-T2) |
| scripts/dev_tools/fix_all_branches.py (183,204,221) | bash scripts/bash/shell-qc.sh | repointed (P3-T1) |
| README.md (16,365,368-370) | bash scripts/bash/shell-qc.sh | updated (P4-T5) |
| docs/features/templates/policy_audit/... (278-280) | bash scripts/bash/shell-qc.sh | updated (P4-T6) |
| extensions/.../policy_audit/... (278-280) | bash scripts/bash/shell-qc.sh | updated (P4-T7) |

## Removed references (confirmed absent)
- `scripts.dev_tools.shell_qc` (module path): 0 hits (module deleted; fix_all_branches.py repointed).
- `poetry run shell-qc` / `shell-qc --help` (wheel smoke): 0 hits (workflows/README/templates migrated).
- `pyproject.toml` `shell-qc*` console-script entries: 0 hits (removed).
- `scripts/dev_tools/shell_qc.py`: file deleted.

## Excluded (frozen, unchanged)
- docs/features/active/2026-07-17-...-362 and -369 (other features' research/spec/remediation
  baselines: point-in-time snapshots and precedent citations).
- docs/features/archive/** and docs/features/completed/** (frozen evidence).
- This feature's own docs (issue.md, spec.md, user-story.md, research, plan, evidence).

Output Summary: Reconciled to the P0-T11 10-row inventory; all live consumers migrated to the
native wrapper; no Python/Poetry shell-path reference and no reference to the deleted module
remain outside frozen artifacts.
