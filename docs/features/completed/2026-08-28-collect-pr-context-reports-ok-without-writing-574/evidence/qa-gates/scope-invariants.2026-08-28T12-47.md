# Phase 7 — The Two Scope Exclusions Held

Timestamp: 2026-08-28T12-47

Task: [P7-T3]

Working directory: repository root for all three commands.

---

## Command 1 — the Python output-path resolution was not converted into a repository-root join

Command: `git grep -F "summary_path = out" -- scripts/dev_tools/pr_context/collector.py`

EXIT_CODE: 0

Output Summary — the matched line, quoted verbatim:

```
scripts/dev_tools/pr_context/collector.py:    summary_path = out
```

The command reported the line. The assignment of the summary path directly from the supplied
output argument stands exactly as it did at baseline: no `repo_root` join, no `.resolve()`, no
absoluteness guard. This is the invariant the spec's Root Cause Analysis requires — the Python
collector is not at fault and needs no path change, and both runtimes implement the same library
contract of writing to the path they were given, resolved by the host against its own working
directory. That contract is correct for a CLI, which is why the documented workaround
`python -m scripts.dev_tools.pr_context.collector --base main --repo-root .` works.

`[P4-T1]` moved two document-assembly blocks out of `collect_and_write` but deliberately left the
output-path resolution, `write_output`, `collect_and_write`, `parse_args`, `main`, the module
entry-point guard, and the two output-path defaults in place. This search confirms that against
the tracked source rather than against the plan's intent.

The literal searched is a single-line, non-interpolated token containing no placeholder or
interpolation marker, so it is checkable, and it is present in the tracked tree, which is what the
command asserts.

---

## Command 2 — anchored name listing

Command: `git diff --name-only origin/main...HEAD`

EXIT_CODE: 0

Output Summary: 53 committed paths, reproduced verbatim in
`docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/other/changed-files.2026-08-28T12-47.md`.
This span is what makes the exclusion check non-vacuous after the change is committed.

---

## Command 3 — porcelain listing

Command: `git status --porcelain --untracked-files=all`

EXIT_CODE: 0

Output Summary: 4 untracked entries, all of them this phase's own evidence outputs under the
feature folder, reproduced verbatim in the `[P7-T1]` artifact. This span is what makes the
exclusion check non-vacuous before the change is committed. The two spans are complementary:
neither alone can see both states.

---

## The derived union, and the exclusion result

The union of the outputs of commands 2 and 3 is the same union `[P7-T1]` derived: **57 paths**,
sorted and de-duplicated, written to
`docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/other/changed-files.txt`.
The union is non-empty.

Checked mechanically against that union:

```
grep -E "enforce-pr-author-skill" .../evidence/other/changed-files.txt
-> no output, exit code 1
```

**Neither `.claude/hooks/enforce-pr-author-skill.ps1` nor
`.claude/hooks/enforce-pr-author-skill-helpers.ps1` appears in the union.** No path under
`.claude/hooks/` appears in it at all.

That exclusion is the spec's Behaviour Semantics item 6 holding as designed rather than by
omission. The hook resolves `artifacts/pr_context.summary.txt` against the hook process's own
working directory, which is the session worktree. Before this fix the artifacts were written into
the server process's checkout, so the hook found either nothing or a stale file at that path.
After this fix the artifacts land in the worktree the tool was given, so the hook begins working
as intended with no change to it. Extending the hook to enforce the head-SHA cross-check would
require a git call at `PreToolUse` time and is recorded in the spec as Follow-up F, not undertaken
here.
