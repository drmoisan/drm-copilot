# Regression: #723 N1 runbook npm view command ([P8-T8], AC-32)

Timestamp: 2026-10-09T21-46
Command: git grep -n -F -e "npm view @danmoisan/drm-copilot-mcp@" -- docs/engineering/missed-npm-publish.runbook.md
EXIT_CODE: 0
Output Summary: three lines; line 137 is the new command inside the target section:

```
docs/engineering/missed-npm-publish.runbook.md:29:npm view @danmoisan/drm-copilot-mcp@1.0.25 version
docs/engineering/missed-npm-publish.runbook.md:137:npm view @danmoisan/drm-copilot-mcp@<version> version
docs/engineering/missed-npm-publish.runbook.md:183:npm view @danmoisan/drm-copilot-mcp@1.0.25 version
```

## Block 2

Command: git grep -n -E -e "^## " -- docs/engineering/missed-npm-publish.runbook.md
EXIT_CODE: 0
Output Summary: 13 headings; `## Red verify step after a green publish step` at line 128 and the next heading `## VERSION_CONSUMED_ELSEWHERE` at line 144. Line 137 lies between 128 and 144.

[P8-T7] check: `git diff --numstat 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a -- docs/engineering/missed-npm-publish.runbook.md` printed `6	0` (6 added, 0 deleted). Merge-base substitution: 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a used in place of the plan literal e7d3779b398604af919678c16c877c8539a86cc0. The fenced block uses a bare fence to match the other fences in the file.

Acceptance (AC-32): at least one matching line with line number greater than 128 and less than 144. PASS.
