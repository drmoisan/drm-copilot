# Fixture Output Hygiene, Before the Fixture Run (round 2, P3-T1)

Timestamp: 2026-10-17T13-04
Command: git status --porcelain --untracked-files=all -- tests/fixtures/poshqc-consumer; git check-ignore -v tests/fixtures/poshqc-consumer/artifacts/pester/powershell-coverage.xml
EXIT_CODE: 0
Output Summary: the porcelain output is empty (no untracked or modified file under the fixture), and `git check-ignore -v` exits 0 and names the `.gitignore` rule `/tests/fixtures/poshqc-consumer/artifacts/` for the fixture coverage XML path.

```text
$ git status --porcelain --untracked-files=all -- tests/fixtures/poshqc-consumer
(no output)
$ git check-ignore -v tests/fixtures/poshqc-consumer/artifacts/pester/powershell-coverage.xml
.gitignore:8:/tests/fixtures/poshqc-consumer/artifacts/	tests/fixtures/poshqc-consumer/artifacts/pester/powershell-coverage.xml
```
