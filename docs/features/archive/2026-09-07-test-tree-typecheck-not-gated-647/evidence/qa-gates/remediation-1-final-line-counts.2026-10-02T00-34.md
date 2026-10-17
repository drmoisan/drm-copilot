# Final QC — Line Counts, AC-13 (issue #647, remediation cycle 1)

Timestamp: 2026-10-02T00-34
Loop pass: 1
Command: grep -c '' extensions/drm-copilot/test/lib/validate/build-validate-orchestration-service-call-input.test.ts; git diff --numstat 1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9 -- extensions/drm-copilot/test/extension.workflow-commands.test.ts; git diff --name-only --diff-filter=AM 1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9 -- extensions/drm-copilot > <SCRATCH>/am-files.txt; echo "EXIT=$?"; grep -E '\.ts$' <SCRATCH>/am-files.txt | xargs grep -c '' | grep -vE ':([0-9]{1,2}|[1-4][0-9]{2}|500)$'; git status --porcelain
EXIT_CODE: 0
Output Summary:
- `TEST_FILE` line count: 182 (at most 500): pass.
- `git diff --numstat` for `extensions/drm-copilot/test/extension.workflow-commands.test.ts`: no line (file unchanged since BASE_SHA): pass.
- Name-list diff EXIT=0; 64 `.ts` paths added or modified since BASE_SHA.
- Over-limit filter output: no line (no added or modified `.ts` file exceeds 500 lines): pass.
- `git status --porcelain`: ` M` plan file only; no untracked path under `extensions/drm-copilot/`: pass.
- P1_HEAD_SHA: `282870ab46c8790353f9cc1fe22afca568b7c58a`.
