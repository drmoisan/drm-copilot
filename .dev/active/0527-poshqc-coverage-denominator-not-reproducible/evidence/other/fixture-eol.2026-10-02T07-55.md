# Fixture Line Endings (P1-T7)

Timestamp: 2026-10-02T07-55
Command: git add tests/fixtures/poshqc-consumer/scripts/Sample.psm1 tests/fixtures/poshqc-consumer/tests/scripts/Sample.Tests.ps1 tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1 .gitignore; git ls-files --eol -- tests/fixtures/poshqc-consumer/scripts/Sample.psm1 tests/fixtures/poshqc-consumer/tests/scripts/Sample.Tests.ps1 tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1 .gitignore
EXIT_CODE: 0
Output Summary: all three fixture files are i/lf and w/lf (no CR in index or worktree), equivalent to CR=False for each; `.gitattributes` `* text=auto eol=lf` applies and no `-text` exemption is needed.
- Deviation DEV-P1-T7 (git equivalent of the `pwsh` `[IO.File]::ReadAllText(...).Contains("`r")` scan). `w/lf` means the worktree file contains LF line endings only; a file containing any CR would report `w/crlf` or `w/mixed`.
- `.gitignore` (edited by P1-T6) is also i/lf w/lf.

## Output

```text
i/lf    w/lf    attr/text=auto eol=lf 	.gitignore
i/lf    w/lf    attr/text=auto eol=lf 	tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1
i/lf    w/lf    attr/text=auto eol=lf 	tests/fixtures/poshqc-consumer/scripts/Sample.psm1
i/lf    w/lf    attr/text=auto eol=lf 	tests/fixtures/poshqc-consumer/tests/scripts/Sample.Tests.ps1
```

Per-file CR result: tests/fixtures/poshqc-consumer/scripts/Sample.psm1 CR=False; tests/fixtures/poshqc-consumer/tests/scripts/Sample.Tests.ps1 CR=False; tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1 CR=False.
