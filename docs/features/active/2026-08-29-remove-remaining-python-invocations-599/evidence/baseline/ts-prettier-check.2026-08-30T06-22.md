# Baseline — TypeScript Format (`prettier --check`)

Timestamp: 2026-08-30T06-22
Task: [P0-T9]
Branch: feature/remove-remaining-python-invocations-599-r2

Command: `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` (run from `extensions/drm-copilot`)

EXIT_CODE: 0

Output Summary: Clean. Output verbatim:

```
Checking formatting...
All matched files use Prettier code style!
```

Zero files require reformatting.

## Read-Only Confirmation

`--check` puts Prettier in check mode: it lists files that would change and writes nothing. This is
the read-only counterpart of `npm run format`, which wraps `prettier --write`. Because no write-mode
formatter ran before this capture, the baseline reflects the tree as committed rather than a tree a
formatter had already repaired.

Prettier's check mode exits non-zero and prints the offending file paths when any file is
misformatted, so the exit code and the `All matched files use Prettier code style!` line are both
falsifiable observations rather than constants.

Note on rule G7 of `.claude/rules/plan-acceptance-gates.md`: the `prettier-write` register entry
matches the argv shape of a Prettier invocation and declares no exclusion for a check flag, so a
check-mode invocation can attract a G7 warning. The rule's own severity measurement records this as
a known false-positive class (Class 1, read-only argv shape). A warning against this task is
expected and is not a defect; G7 ships in the Warning channel and does not fail the gate.
