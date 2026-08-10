# Remediation Baseline — Test-Module Line Budget and R-03 Split Decision

Timestamp: 2026-08-08T19-22

Command: `pwsh -NoProfile -Command "foreach ($f in @('tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py','tests/scripts/dev_tools/parallel_orchestrator_surface_test_support.py','tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py')) { Write-Output ($f + ' ' + (Get-Content $f).Count) }"`

Working directory: repository root (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a926e23bcfaa5fb69`)

EXIT_CODE: 0

Output Summary:

| Module | Lines | Limit | Headroom |
| --- | --- | --- | --- |
| `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` | 457 | 500 | 43 |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_test_support.py` | 465 | 500 | 35 |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | 253 | 500 | 247 |

The 500-line limit is set by `.claude/rules/general-code-change.md` `## File Size Limit`, which applies
to test code as well as production code. Test-tree Python files are not among that rule's exceptions.

## R-03 Additions To Be Placed

The R-03 additions comprise three distinct groups:

1. **Three pinned data constants** — `WRITE_VERBS`, `NON_PARENT_ACTOR_MARKERS`, and
   `WRITE_DESTINATION_PREPOSITIONS`, each with the explanatory comment the plan requires.
2. **Six parser functions** — `persona_write_grants()`, `persona_bash_grants()`,
   `write_grant_covers()`, `bash_grant_covers()`, `prescribed_parent_write_targets()`, and
   `prescribed_command_invocations()`, each carrying a Google-style docstring with `Args:`, `Returns:`,
   `Raises:`, and `Side Effects:` sections plus intent comments on every loop, comprehension, and
   non-trivial branch as `.claude/rules/self-explanatory-code-commenting.md` requires.
3. **Three tests** — the write-grant coverage assertion, the bash-grant coverage assertion, and the
   manifest-gate assertion, each in Arrange-Act-Assert form with a failure message that names the
   specific uncovered prescription and the full grant list.

## Split Decision

- **Group 1 (three pinned constants) is placed in the existing `parallel_orchestrator_surface_expectations.py`.**
  That module has 247 lines of headroom, and the constants are inert data, which is exactly the
  module's stated purpose. The three constants with their explanatory comments require well under 247
  lines, so the module remains at or below 500 lines.
- **Group 2 (six parser functions) does NOT fit in `parallel_orchestrator_surface_test_support.py`.**
  That module has only 35 lines of headroom. Six functions, each requiring a complete Google-style
  docstring with four sections plus intent comments, cannot be authored in 35 lines: the six existing
  parsers of comparable shape in that module occupy roughly 25 to 30 lines each. A new parser module
  `tests/scripts/dev_tools/parallel_orchestrator_permission_seam_support.py` is therefore created for
  this reason, reusing `read_repo_text`, `parse_frontmatter`, and `string_sequence` from the existing
  support module rather than re-implementing them.
- **Group 3 (three tests) does NOT fit in `test_parallel_orchestrator_surface_contracts.py`.** That
  module has only 43 lines of headroom. Three Arrange-Act-Assert tests, each with a docstring and a
  multi-line failure message naming the uncovered prescription and the full grant list, cannot be
  authored in 43 lines without violating the docstring and diagnostic-message obligations. A new test
  module `tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py` is therefore
  created for this reason.

The two new modules named in the plan's `## Scope Summary` are created because the headroom in the
existing test module (43 lines) and support module (35 lines) does not admit the R-03 additions, not
for any organizational preference. Both new modules are held at or below 500 lines.
