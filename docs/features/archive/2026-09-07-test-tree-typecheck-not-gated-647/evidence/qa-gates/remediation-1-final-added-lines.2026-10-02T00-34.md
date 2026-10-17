# Final QC — Added-Line Scans, AC-12 and AC-10 (issue #647, remediation cycle 1)

Timestamp: 2026-10-02T00-34
Loop pass: 1
Command: git diff -U0 1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9 -- extensions/drm-copilot > <SCRATCH>/added-lines.txt; echo "EXIT=$?"; grep -E '^\+' <SCRATCH>/added-lines.txt | grep -v '^+++' | grep -cE '@ts-ignore|@ts-expect-error|@ts-nocheck|eslint-disable|:\s*any\b|\bas\s+any\b|<any>|\bany\[\]'; grep -E '^\+' <SCRATCH>/added-lines.txt | grep -v '^+++' | grep -cE '\.(skip|only)\(|\bx(it|describe|test)\('; echo '+const probe: any = 1;' | grep -cE ':\s*any\b'; git status --porcelain
EXIT_CODE: 0
Output Summary:
- Anchor: BASE_SHA `1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9`; diff EXIT=0.
- AC-12 suppression/`any` count in added lines: 0: pass.
- Skip/only count in added lines: 0: pass.
- Positive control (`+const probe: any = 1;`): 1, so the pattern matches a known violation and the 0 count is meaningful.
- `git status --porcelain`: ` M` plan file only; no untracked path under `extensions/drm-copilot/`, so the anchored diff covers every change: pass.
- P1_HEAD_SHA: `282870ab46c8790353f9cc1fe22afca568b7c58a`.
