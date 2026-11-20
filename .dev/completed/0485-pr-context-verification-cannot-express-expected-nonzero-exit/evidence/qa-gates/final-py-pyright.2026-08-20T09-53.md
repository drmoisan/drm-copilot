# Final QC — Python type checking (Pyright, strict mode)

Timestamp: 2026-08-20T09-53

Task: [P8-T3]

Command: poetry run pyright
EXIT_CODE: 0

## Result

```
0 errors, 0 warnings, 0 informations
```

- Error count: 0
- Warning count: 0
- Files analyzed: 428 (confirmed from the JSON summary of the same configuration)

## The failure this pass replaces

The first attempt at this task FAILED with exit code 1 and one error:

```
tests\scripts\dev_tools\test_collect_pr_context_expected_exit.py:12:52 - error:
"_render_verification_evidence_section" is private and used outside of the module in which it is
declared (reportPrivateUsage)
```

Resolution attempts, in order:

1. Module-level `from ... import _render_verification_evidence_section` — reported.
2. Import moved inside a helper function, mirroring
   `tests/scripts/dev_tools/atomic_executor/test_cli_part3.py:54` — still reported.
3. Renaming the collector renderer to a public name, or adding a public wrapper — REJECTED: either
   change adds lines to `scripts/dev_tools/pr_context/collector.py`, which this change holds to at
   most 5 added lines (AC20, currently 4 used), and a rename is a production API change that
   `spec.md` does not authorize.
4. Reproducing the ~200-line stub fixture of
   `tests/scripts/dev_tools/test_collect_pr_context_part4.py:305-470` so the test could drive the
   public `collect_and_write` path — REJECTED: it duplicates a large fixture, which the
   copy-paste guidance in `.claude/rules/general-code-change.md` prohibits, and it would roughly
   triple the new module's size.
5. Dynamic attribute lookup (`getattr`, `vars(module)[name]`) — REJECTED: `getattr` with a constant
   attribute is a Ruff `B009` violation under the enabled `B` rule set, and the `vars()` form
   discards type information for no readability gain.

Adopted resolution: a LINE-SCOPED `# pyright: ignore[reportPrivateUsage]` on the single import line
inside the documented helper, with the reason recorded in the helper's docstring. The same rule is
suppressed for the same reason by the existing
`tests/scripts/dev_tools/atomic_executor/test_cli_part3.py`, which does it at FILE scope; the line
scope used here is strictly narrower. This is the one suppression this change introduces, and it is
in test code only.

Output Summary: Pyright strict mode passes with exit code 0 — 0 errors, 0 warnings across 428
analyzed files. The single `reportPrivateUsage` error from the first attempt was resolved with a
line-scoped suppression after four alternative approaches were tried and rejected for the reasons
recorded above; the loop was restarted from [P8-T1] after that fix.
