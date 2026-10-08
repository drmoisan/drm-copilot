# AC-10 and AC-12 added-line scans (#647)

Timestamp: 2026-10-01T23-18
Command: git diff -U0 1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9 -- extensions/drm-copilot | grep -E '^\+' | grep -v '^+++' | grep -E '\.(skip|only)\(|\bx(it|describe|test)\(' ; git diff -U0 1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9 -- extensions/drm-copilot | grep -E '^\+' | grep -v '^+++' | grep -E '@ts-ignore|@ts-expect-error|@ts-nocheck|eslint-disable|:\s*any\b|\bas\s+any\b|<any>|\bany\[\]' ; git status --porcelain -- extensions/drm-copilot
EXIT_CODE: 1
ExpectedExitCode: 1

Skip/only pipeline: no line (grep exit 1).
Suppression/any pipeline: no line (grep exit 1).
Porcelain under extensions/drm-copilot: (empty). `test/package-typecheck-script.test.ts` was committed in 9f85f388, so it is covered by the anchored diff scans; no `??` path required a per-file grep.

Output Summary: no added `.skip`, `.only`, `xit`, `xdescribe`, `xtest`, suppression comment, or `any` in any changed or new file.
