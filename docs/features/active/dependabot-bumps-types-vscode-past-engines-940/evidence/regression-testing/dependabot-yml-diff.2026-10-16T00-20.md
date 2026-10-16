# dependabot.yml diff (P1-T8, AC-3)

Timestamp: 2026-10-16T00-20
Command: git diff HEAD --unified=0 -- .github/dependabot.yml
EXIT_CODE: 0
Output Summary: Exactly two hunks, each a pure insertion; no removed lines. HEAD is the Phase 0 boundary commit.

```
@@ -17,0 +18 @@ updates:
+      - dependency-name: "@types/vscode"
@@ -36,0 +38 @@ updates:
+      - dependency-name: "@types/vscode"
```

Old-side starts are lines 17 and 36, both before the `/packages/mcp-server` entry (original line 43) and the `github-actions` entry (original line 59). `git diff HEAD --numstat -- .github/dependabot.yml` printed `2	0`.

Companion command: `git status --porcelain -- .github`
Output: ` M .github/dependabot.yml`

On that basis the `/packages/mcp-server` and `github-actions` entries are unchanged.
