# P15-T17 verification — resolved read targets re-checked against the invocation scope

Timestamp: 2026-10-29T23-56
Command: poetry run black <5 files>; poetry run ruff check <5 files>; poetry run pyright <5 files>; poetry run pytest -q --no-cov tests/discovery_runtime -k "gateway or host or public_host or protected"
EXIT_CODE: 0
Output Summary:
- Black: 5 files left unchanged on the final pass; Ruff: all checks passed after the final docstring shortening; Pyright: 0 errors, 0 warnings, 0 informations.
- Pytest (host gateway, protected-record and workflow suites): 379 passed, 0 failed, including every existing read case (`test_read_source_authority_is_bounded_by_the_selected_paths`, `test_read_outside_the_selected_paths_is_refused`, `test_read_outside_the_configured_input_scope_is_refused`, the read-source transition of PT/test_public_host_workflow.py).
- Named tests present and passing: PT/test_gateway_host_read_refusals.py::test_a_symlinked_read_inside_the_selection_is_refused and ::test_a_resolved_target_outside_the_selection_is_refused (injected metadata: a symlink leaf resolving to another selected path inside the configured scope; an ordinary leaf resolving under another root), plus PT/test_gateway_host_reads.py, which drives `select_reads` through an injected resolver: ordinary grants, selection check before resolution, policy refusal as the configured scope, a symlink or reparse stamp in an ancestor or the leaf (`The read crosses a symlink or reparse point.`), a resolved target under another root, another spelling, another drive or outside the workspace (`The resolved read target is outside the invocation's selected paths.`), a leaf without a resolved path, and the Windows versus POSIX root arithmetic.
- Size: gateway_host.py 486 lines (down from 498), gateway_host_reads.py 90, test_gateway_host_refusals.py 403 (down from 525), test_gateway_host_read_refusals.py 123, test_gateway_host_reads.py 204; every file is at or below 500 lines.

## Changes in this task

- R/gateway_host_reads.py (new): `select_reads(paths, selected, workspace_root, resolve)` applies, per path, the lexical selection check, the resolver (a `PathPolicyError` is the configured-scope refusal), the observation check for any `symlink` or `reparse` stamp, and the containment of the final stamp's `resolved_path`, made workspace-relative by pure path arithmetic (`workspace_relative`: Windows roots compare case-insensitively, POSIX roots exactly), within `selected_paths`; a leaf without a resolved path is refused. No filesystem call is added; the metadata seam supplies the stamps through the policy.
- R/gateway_host.py: `_read_selection` builds the `PathPolicy` and delegates to `select_reads` with `policy.resolve_read` as the resolver; the `ReadGrant`/`ReadSelection` imports move to the type-checking block.
- Tests: the four read-scope tests of PT/test_gateway_host_refusals.py (two existing, two new) live in PT/test_gateway_host_read_refusals.py, which imports the `edit` and `refused` helpers from the refusals suite; PT/test_gateway_host_reads.py is the unit module of the new function.

## Execution decisions

- `PathPolicy._inspect` already refuses every symlink and reparse entry (`PATH_LINK`) and every resolved path that differs from the requested spelling (`PATH_ALIAS`, `PATH_ESCAPE`) while it walks, and the workspace capture that precedes the read selection walks the same configured roots. Through the real host composition, a symlinked or aliased source is therefore refused by the capture, before the read selection runs, and the two named refusal tests assert exactly that: `PathPolicyError` with `PATH_LINK` or `PATH_ALIAS`, the one-use grant spent (the latch is created at acceptance, before capture) and no writer call. The gateway's own observation and resolved-target checks are defence in depth behind the policy and are proved reachable and correct through the injected resolver of PT/test_gateway_host_reads.py.
- The selection logic moved to a sibling module because gateway_host.py stood at 498 lines after P15-T16; the module is a pure function with an injected resolver, which is also what makes the checks testable without the filesystem.
- The read-scope tests moved to a sibling suite because the refusals suite crossed 500 lines; no assertion of the two moved tests changed (the grant issue and request are composed by one helper).
