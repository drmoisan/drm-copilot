# Phase 8 — Final TypeScript Formatter Gate

Timestamp: 2026-08-28T12-47

Task: [P8-T1]

Command: `git status --porcelain`, then `npm run format` (working directory
`extensions/drm-copilot`), then `git status --porcelain` again.

EXIT_CODE: 0

The recorded exit code is the exit code of `npm run format` itself, captured directly and not from
a pipeline tail.

## Two phase restarts preceded this pass

This artifact records the **third** pass of Phase 8. Two earlier passes were aborted by the phase
preamble's restart rule, and both causes are recorded here because both were invisible to an exit
code.

**Restart 1, triggered by this task.** The first pass of `[P8-T1]` rewrote three tracked files
this change had authored:

```
src/lib/pr-context/summary-helpers.ts 8ms
test/extension.collect-pr-context.test.ts 11ms
test/repo-automation-dispatch-pr-context-verification.test.ts 3ms
```

Each printed without the `(unchanged)` marker, and the porcelain listing went from empty to three
modified entries. **Prettier exited 0 on that repairing run exactly as it does on a clean one**, so
the exit code did not distinguish the two. Only the before-and-after tree observation this task
carries made the rewrite visible. The rewrites were whitespace and line-wrapping only, the unit
suite was green after them, and they were committed on their own.

**Restart 2, triggered by `[P8-T2]`.** The lint gate then failed with exit code 1 on a genuine
defect in code this change introduced:

```
src/lib/pr-context/pr-context-service-call.ts
  57:5  error  There is no `cause` attached to the symptom error being thrown  preserve-caught-error
```

The read-back failure path rethrew a new error carrying the caught error's message text but
discarding the error object, so the underlying filesystem failure was unavailable upstream. It was
fixed at source by attaching the caught error as the cause, not suppressed, and committed. The
message text is unchanged, so no assertion that reads it was affected.

Every task of the phase was rerun in order from `[P8-T1]` after each restart.

## Output Summary

### Porcelain listing before the run, verbatim

```
?? docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/final-ts-format.2026-08-28T12-47.md
```

The single entry is this artifact itself, untracked at the moment of the run. No tracked source
file is listed.

### Porcelain listing after the run, verbatim

```
?? docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/final-ts-format.2026-08-28T12-47.md
```

### Statement

**The two listings are identical**, which is what proves the run left every matched file
unchanged. No tracked file was rewritten by this pass, so no further restart is triggered.

This is corroborated independently by the formatter's own output beyond the exit code: the run
printed 410 lines carrying the `(unchanged)` marker and printed no matched-file line without it.
The only non-marker lines are the two npm banner lines. A file Prettier had rewritten would have
printed without the marker, exactly as the three files did on the first pass.
