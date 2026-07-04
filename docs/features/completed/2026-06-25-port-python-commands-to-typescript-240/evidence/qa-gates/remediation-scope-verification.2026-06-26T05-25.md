# Remediation Scope Verification — F8 (Issue #240)

Timestamp: 2026-06-26T05-25

Command: `git status --short -- extensions/drm-copilot/src` and `git diff --name-only c432b69...HEAD -- extensions/drm-copilot/src extensions/drm-copilot/resources`
EXIT_CODE: 0

Output Summary:
Remediation working-tree change set (beyond the committed F8 change set) under
`extensions/drm-copilot/src`:
- M extensions/drm-copilot/src/lib/new-active-feature-folder/io.ts (launcher seam removed, re-exported)
- ?? extensions/drm-copilot/src/lib/new-active-feature-folder/io-launcher.ts (new launcher module)

No optional `io-launcher.test.ts` was created (P1-T3 split was not required; the existing
`io.test.ts` is 439 lines and launcher tests resolve through the `./io` re-export).

Documentation/evidence-only changes outside src:
- M docs/.../plans/F8-new-active-feature-folder.plan.md (AC re-check-off, P2-T3)
- New evidence artifacts under docs/.../evidence/remediation-baseline/ and evidence/qa-gates/
- Audit/plan/inputs markdown artifacts in the feature folder

Prohibited-path check (must show NO modifications):
- command-runtime.ts: not modified
- repo-automation-args.ts: not modified
- the "python" runtime branch / executeScript: not modified
- F1 interfaces (file-system.ts, subprocess-runner.ts, prompt-mode-contract.ts): not modified
- Python scripts/dev_tools/** and resources/**/*.py and resources/templates/*.py: not modified

Result: change set matches the allowed list. No prohibited path modified.
