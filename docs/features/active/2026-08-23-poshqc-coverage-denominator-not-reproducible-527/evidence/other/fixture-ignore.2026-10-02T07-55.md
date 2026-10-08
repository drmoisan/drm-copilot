# Fixture Output Ignore Entry (P1-T6)

Timestamp: 2026-10-02T07-55
Command: git check-ignore -v tests/fixtures/poshqc-consumer/artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary: .gitignore:8:/tests/fixtures/poshqc-consumer/artifacts/	tests/fixtures/poshqc-consumer/artifacts/pester/pester-junit.xml
- `.gitignore` gained two lines directly after line 6 (`/artifacts`): line 7 `# Issue #527: output of the consumer-fixture PoshQC acceptance run.` and line 8 `/tests/fixtures/poshqc-consumer/artifacts/`. Line 6 was confirmed as `/artifacts` before the edit (no drift since plan commit 43e403a1).
- Acceptance: exit 0 and the output contains `.gitignore:8:/tests/fixtures/poshqc-consumer/artifacts/`. Met.
- Confirmed in effect after the MCP fixture run: `git status --porcelain --untracked-files=all` listed none of the three files written under tests/fixtures/poshqc-consumer/artifacts/pester/.

## Staged diff (`git diff --cached -- .gitignore`)

```text
@@ -4,6 +4,8 @@ node_modules
 .vscode-test/
 *.vsix
 /artifacts
+# Issue #527: output of the consumer-fixture PoshQC acceptance run.
+/tests/fixtures/poshqc-consumer/artifacts/
 .agent_logs
```
