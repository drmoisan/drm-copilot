# Pin Survey 1: Pinned Surface Hashes (P0-T6, remediation cycle 2)

Timestamp: 2026-10-12T17-58

Command: git grep -n -F -e "parallel-orchestrate/SKILL.md" -e "parallel-orchestrator.md" -- tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py

EXIT_CODE: 1

ExpectedExitCode: 1

Output Summary:
- First command: exit 1, no output. The expectation module does not name AGENT or SKILL, so no hash of either is pinned.
- Second command: `git grep -n -F -e "PINNED_FROZEN_SURFACE_HASHES" -- tests`. SECOND_COMMAND_EXIT=0. Output (verbatim):

```
tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:160:PINNED_FROZEN_SURFACE_HASHES: tuple[tuple[str, str], ...] = (
tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py:471:    ("relative_path", "expected_digest"), pinned.PINNED_FROZEN_SURFACE_HASHES
```

- Every printed line is in one of the two permitted files. No pinned hash requires re-derivation.
