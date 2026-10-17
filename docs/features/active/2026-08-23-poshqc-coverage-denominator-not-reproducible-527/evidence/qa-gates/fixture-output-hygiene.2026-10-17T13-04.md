# Fixture Output Hygiene, Before and After (round 2, P3-T4)

Timestamp: 2026-10-17T13-04
Command: git status --porcelain --untracked-files=all -- tests/fixtures/poshqc-consumer; git check-ignore -v tests/fixtures/poshqc-consumer/artifacts/pester/powershell-coverage.xml (repeated after the fixture run; the before output is quoted from `evidence/regression-testing/post-fix-fixture-hygiene-before.2026-10-17T13-04.md`)
EXIT_CODE: 0
Output Summary: the porcelain output is empty both before and after the fixture run, and check-ignore still names the `.gitignore` rule `/tests/fixtures/poshqc-consumer/artifacts/` for the fixture coverage XML path. The run did write three files under the ignored output directory (`pester-junit.xml`, `powershell-coverage.xml`, `powershell-coverage.koverage.xml` in `tests/fixtures/poshqc-consumer/artifacts/pester/`), and none is visible to git. Mechanism: gitignore.

Before (from the before artifact):

```text
$ git status --porcelain --untracked-files=all -- tests/fixtures/poshqc-consumer
(no output)
$ git check-ignore -v tests/fixtures/poshqc-consumer/artifacts/pester/powershell-coverage.xml
.gitignore:8:/tests/fixtures/poshqc-consumer/artifacts/	tests/fixtures/poshqc-consumer/artifacts/pester/powershell-coverage.xml
```

After the fixture run:

```text
$ git status --porcelain --untracked-files=all -- tests/fixtures/poshqc-consumer
(no output)
$ git check-ignore -v tests/fixtures/poshqc-consumer/artifacts/pester/powershell-coverage.xml
.gitignore:8:/tests/fixtures/poshqc-consumer/artifacts/	tests/fixtures/poshqc-consumer/artifacts/pester/powershell-coverage.xml
```
