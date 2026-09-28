Timestamp: 2026-09-27T10-30

Search target: extensions/drm-copilot/src/lib/pr-context/collector-core.ts
Search literal: `whichGh === undefined`

Matched line (exact text, line 136):
```
    ...(whichGh === undefined ? {} : { whichGh }),
```

Line number: 136 (1-based)

Match count: exactly one match in the file.

Discrepancy from plan citations: the plan's Planner Internal Review Record cites this conditional at line 135 (with `const whichGh = options.whichGh;` at line 124). After the rebase onto origin/main at daae7f79 (which pulled in PR #720, touching pr-context files' imports), the anchor line has shifted by one: the conditional is now at line 136, and `const whichGh = options.whichGh;` is now at line 125. The surrounding code (the `new GhClient({...})` construction spanning lines 132-137, the try/catch block starting at line 140) is otherwise unchanged in content and shape from the plan's citations, only shifted by one line. Per the plan's anchor-discipline rule (P0-T8) and the executor delegation instructions, this discrepancy is noted here and does not block execution: every later task in this plan that reads `BRDA:` entries for this conditional uses line 136, the line number recorded in this artifact, not the plan's cited line 135.
