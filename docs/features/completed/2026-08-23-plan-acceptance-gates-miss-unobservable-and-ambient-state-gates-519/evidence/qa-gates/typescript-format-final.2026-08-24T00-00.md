# Final QC — TypeScript formatting — [P8-T6]

Timestamp: 2026-08-26T10-33
Task: [P8-T6]
Command: `npm run format`
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2c2e891a6977ab65/extensions/drm-copilot`
EXIT_CODE: 0

Output Summary: **processed-file count 408; count of printed file lines carrying the trailing literal `(unchanged)` 408. The two counts are equal**, so no file was rewritten and the phase does not restart. The script resolves to `prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`.

The exit code was captured directly with `echo "EXIT=$?"` immediately after the redirect. No pipe stands between the command and the capture.

This is the second pass of Phase 8; the restart and its cause are recorded in `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/qa-gates/python-format-final.2026-08-24T00-00.md`. This run was made against the fully restored dependency tree.

## The observation beyond the exit code

The exit code alone is not sufficient evidence for this task. `prettier --write` exits 0 whether or not it rewrites a file, so an exit code of 0 does not distinguish a clean run from a repairing one. The observation this task records is the pair of counts over the tool's own per-file output lines: `prettier --write` prints one line per processed file, and a file it did NOT rewrite carries the trailing literal `(unchanged)` while a file it rewrote does not.

| Quantity | Command used to count it | Value |
| --- | --- | --- |
| Processed-file lines | `grep -c "ms\b" r3b-p8t6.txt` | 408 |
| Lines carrying `(unchanged)` | `grep -c "(unchanged)" r3b-p8t6.txt` | 408 |
| Difference | — | **0** |

Every processed-file line carries a millisecond duration, which is what the first count matches, and every one of those 408 lines also carries `(unchanged)`. The captured stream has 412 lines in total: the two `npm` header lines, one blank line, 408 file lines, and one trailing newline. 412 minus the 4 non-file lines is 408, so the processed-file count is corroborated by the total line count and not only by the pattern match.

## Corroborating repository observation

`git status --porcelain -- extensions/drm-copilot` produced **no output** after the run, which independently confirms the formatter modified no tracked file under the extension tree.

## Verbatim output, first and last file lines

```text
> drm-copilot@1.1.4 format
> prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"

src/claude-worktree-session.ts 61ms (unchanged)
src/codex-worktree-session.ts 9ms (unchanged)
src/command-runtime.ts 24ms (unchanged)
src/discovery-command-registration.ts 20ms (unchanged)
...
esbuild-extension.cjs 4ms (unchanged)
esbuild-mcp-server.cjs 2ms (unchanged)
jest.config.cjs 4ms (unchanged)
run-jest.cjs 2ms (unchanged)
```

The captured stream carries ANSI colour escape sequences around each filename; they are stripped here for readability and carry no result signal.

## Verdict

**PASS.** Exit code 0, 408 processed files, 408 of them carrying `(unchanged)`, and an empty `git status --porcelain` over the same tree. No file was rewritten, so Phase 8 proceeds to [P8-T7] rather than restarting from [P8-T1].
