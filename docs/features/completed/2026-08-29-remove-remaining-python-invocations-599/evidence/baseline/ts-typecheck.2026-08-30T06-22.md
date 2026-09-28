# Baseline — TypeScript Type Check (`npm run typecheck`)

Timestamp: 2026-08-30T06-22
Task: [P0-T11]
Branch: feature/remove-remaining-python-invocations-599-r2

Command: `npm run typecheck` (run from `extensions/drm-copilot`)

EXIT_CODE: 0

Output Summary: Clean. Zero type errors. Output verbatim:

```
> drm-copilot@1.1.7 typecheck
> tsc -p ./ --noEmit
```

`tsc` printed no diagnostics of its own; the two lines above are npm's script banner. The absence
of further output is the success signal — `tsc` prints one line per error and a trailing
`Found N errors` summary when the compile fails, and prints nothing on a clean run.

The wrapped command is `tsc -p ./ --noEmit`, which type-checks the project without emitting build
output. This satisfies the uniform `Type errors: 0` gate that `.claude/rules/quality-tiers.md`
applies across T1 through T4.

`--noEmit` makes the invocation read-only: no compiled artifact and no source file is written.
