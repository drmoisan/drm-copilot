# Baseline — TypeScript Lint (`npm run lint`)

Timestamp: 2026-08-30T06-22
Task: [P0-T10]
Branch: feature/remove-remaining-python-invocations-599-r2

Command: `npm run lint` (run from `extensions/drm-copilot`)

EXIT_CODE: 0

Output Summary: Clean. Zero lint diagnostics. Output verbatim:

```
> drm-copilot@1.1.7 lint
> eslint --no-error-on-unmatched-pattern src test
```

ESLint printed no diagnostics of its own; the two lines above are npm's script banner echoing the
package name, version, and the underlying command. The absence of any further output is the
success signal — ESLint prints a problem summary only when it finds problems.

The wrapped command is `eslint --no-error-on-unmatched-pattern src test`, covering the `src` and
`test` trees. This satisfies the uniform `Lint errors: 0` gate that
`.claude/rules/quality-tiers.md` applies across T1 through T4.

ESLint was invoked without `--fix`, so it is read-only and rewrote no source file.
