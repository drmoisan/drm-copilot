# Stale-Divergence Token Baseline (Issue #890)

Timestamp: 2026-10-12T20-10
Task: P0-T10
Command: `git grep -n -F "_parallel_mutation_errors.py:192" -- .claude tests extensions/drm-copilot/resources/claude-customizations`
EXIT_CODE: 0
Output Summary: 6 matching lines (expected 6), at the planned positions.

```text
.claude/lib/bash/parallel-mutation.sh:18:#      merge-status members (`_parallel_mutation_errors.py:192`, spec D5).
.claude/lib/bash/remove-parallel-item.sh:37:#      merge-status members (`_parallel_mutation_errors.py:192`, spec D5).
extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-mutation.sh:18:#      merge-status members (`_parallel_mutation_errors.py:192`, spec D5).
extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/remove-parallel-item.sh:37:#      merge-status members (`_parallel_mutation_errors.py:192`, spec D5).
tests/scripts/dev_tools/test_parallel_mutation_remove_bash_parity.py:25:       merge-status members (`_parallel_mutation_errors.py:192`, spec D5).
tests/shell/parallel_mutation_remove_parity.bats:15:#      merge-status members (`_parallel_mutation_errors.py:192`, spec D5).
```
