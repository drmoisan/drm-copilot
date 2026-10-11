# Requirements Source Check (P0-T2)

Timestamp: 2026-10-09T02-51
Command: poetry run python -c "t=open('docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/spec.md',encoding='utf-8').read().splitlines(); i=t.index('## Acceptance Criteria'); j=t.index('## Risks & Mitigations'); print(len([x for x in t[i:j+1] if x.startswith('- [ ] ')])); print(len([x for x in t if '.claude/rules/parallel-orchestration.md' in x])); print(len([x for x in open('docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/issue.md',encoding='utf-8').read().splitlines() if x=='- Work Mode: full-bug']))"
EXIT_CODE: 0
Output Summary: printed 19, 6, 1 (expected 19, at least 2, and 1). Requirements sources read: spec.md, issue.md, research/research.2026-10-08T17-27.md.

## Deviation (PowerShell route denied)

The plan runs this check "in the PowerShell tool". The executor has no PowerShell tool, and an inline `pwsh -NoProfile -Command` invocation was denied by the worktree-isolation hook with this text (the worktree absolute path is replaced by `<worktree-root>`):

```text
This agent is isolated in the worktree <worktree-root>, but this command runs pwsh in a plain command; what it reads or is handed as shell text cannot be shown not to run git. Refusing to run it — a worktree-isolated agent's git operations must target its own worktree. Run the plain command from <worktree-root>.
```

The Python command above computes the same three values with the same slice bounds (inclusive of the Risks heading line, matching `$t[$i..$j]`) and the same ordinal string predicates (`StartsWith`, `Contains`, `-ceq`).

## Output

```text
19
6
1
```
