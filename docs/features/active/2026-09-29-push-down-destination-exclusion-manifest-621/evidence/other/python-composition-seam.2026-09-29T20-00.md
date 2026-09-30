# Python Composition Seam — Issue #621

Task: [P1-T2]
Branch: feature/push-down-destination-exclusion-manifest-exec-621

## Command 1

Timestamp: 2026-09-29T20-00
Command: grep -n -e 'push_down_scoped_customizations(' scripts/dev_tools/push_down_claude_customizations.py
EXIT_CODE: 0
Output Summary: Exactly one call line: `313:    return push_down_scoped_customizations(`.

## Command 2

Timestamp: 2026-09-29T20-00
Command: grep -n -e 'fs=' scripts/dev_tools/push_down_claude_customizations.py
EXIT_CODE: 0
Output Summary: Three matched lines:

```
288:        fs=fs,
316:        fs=excluding_fs,
435:        fs=resolved_fs,
```

Line 316 lies inside the `push_down_scoped_customizations(` call opened at line 313 (the call spans lines 313-322). Line 288 is the `_resolve_published_paths(` argument and line 435 is in `main`.

Findings:
- Variable passed as `fs=` to `push_down_scoped_customizations`: `excluding_fs` (line 316; the plan cited `:275` against the pre-#507/#508 file).
- `excluding_fs` is the `ExcludingFileSystem` built at lines 300-312, wrapping `BundleConfigFileSystem(write_stack, ...)`, where `write_stack = build_destination_write_stack(fs, ...)` (lines 295-299) is the #507/#508 derive-then-merge decorator stack. Wrapping `excluding_fs` therefore keeps the exclusion filter outermost (plan section 2 item 6).
- `effective_bundle` is computed at lines 278-282, and `_resolve_published_paths(` is called at lines 285-289; the manifest read goes between them.
- The call is a direct `return push_down_scoped_customizations(...)`; [P4-T2] must bind the engine result to a variable before building the report.
- Observed line count of the file (`awk 'END{print NR}'`): 447. 447 does not exceed 460, so the `apply_exclusion_filter_and_report` helper route does not apply to [P4-T2]; the inline route applies.
