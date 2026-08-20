# Gate — throwaway comparison harnesses removed from the repository

Timestamp: 2026-08-20T09-53

Task: [P7-T7]

Command: rm -f extensions/drm-copilot/test/lib/pr-context/corpus-differential.tmp.test.ts ; git status --porcelain ; git ls-files --others --exclude-standard ; git ls-files ; find . -name "*corpus-differential*" (excluding node_modules)
EXIT_CODE: 0

## The TypeScript harness is deleted

`extensions/drm-copilot/test/lib/pr-context/corpus-differential.tmp.test.ts` was removed. The
directory listing after removal contains only the pre-existing test modules and `tree-file-system.ts`;
no `.tmp.test.ts` file remains.

## Repository-wide confirmation, zero matching paths

| Check | Result |
| --- | --- |
| `git status --porcelain` (unscoped) filtered for `corpus-differential` or `.tmp.test.ts` | zero matching lines |
| `git ls-files --others --exclude-standard` filtered for the same patterns | zero matching lines |
| `git ls-files` filtered for the same patterns | count 0 |
| `find . -name "*corpus-differential*"`, excluding `node_modules` trees | no output |

The working tree therefore contains no harness file, tracked or untracked, and none was ever
committed.

## The Python leg lives only in the session scratchpad

The Python leg of the differential was written to the session scratchpad at
`<scratchpad>/corpus_differential.py` and was NEVER created under the repository working tree. The
same is true of the four supporting throwaway scripts used during execution
(`cross_runtime_compare.py`, `dup_key_scan.py`, `lcov_summary.py`, `shape_crossruntime.py`,
`shape_agreement.py`, `verify_phase2.py`, `apply_schema_block.py`) and the two intermediate row files
(`py_rows.json`, `ts_rows.json`). The scratchpad is outside the repository, so none of these appears
in the working tree, in `git status`, or in the index. This satisfies the throwaway-script exception in
`.claude/rules/general-code-change.md` and plan constraint SC6, which requires the Layer 2 differential
to be a throwaway script rather than a committed test (the corpus mutates whenever a feature lands, so
a committed test walking it would be non-deterministic across time).

Output Summary: The TypeScript harness `corpus-differential.tmp.test.ts` is deleted; zero paths
matching `*corpus-differential*` or `*.tmp.test.ts` remain anywhere in the repository working tree,
confirmed against the status output, the untracked-file listing, the index, and a filesystem search.
The Python leg and every supporting throwaway script live only in the session scratchpad, outside the
repository.
