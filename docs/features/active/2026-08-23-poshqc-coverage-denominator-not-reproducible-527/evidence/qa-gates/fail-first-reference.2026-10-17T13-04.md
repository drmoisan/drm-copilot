# Pre-Fix Failing Reference (round 2, P3-T5)

Timestamp: 2026-10-17T13-04
Command: git grep -c -F -e 'SAMPLE_PRESENT=0' -- <FEATURE>/evidence/regression-testing/fail-first-fixture-check.2026-10-02T07-55.md; the same git grep -c -F -e search against the same file for the expected-exit-code declaration (the field name ExpectedExitCode, a colon, a space, and the digit 1)
EXIT_CODE: 0
Output Summary: both searches exited 0. `SAMPLE_PRESENT=0` is found on 3 lines and the expected-exit-code declaration with value 1 is found on 1 line of `fail-first-fixture-check.2026-10-02T07-55.md`. The existing pre-fix artifact therefore records the failing check: the consumer's production file `Sample.psm1` was not measured and the stand-in `validate-bash.ps1` was the only measured file, with a declared expected exit code of 1.

```text
$ git grep -c -F -e 'SAMPLE_PRESENT=0' -- <FEATURE>/evidence/regression-testing/fail-first-fixture-check.2026-10-02T07-55.md
<FEATURE>/evidence/regression-testing/fail-first-fixture-check.2026-10-02T07-55.md:3
$ git grep -c -F -e <expected-exit-code declaration, value 1> -- <FEATURE>/evidence/regression-testing/fail-first-fixture-check.2026-10-02T07-55.md
<FEATURE>/evidence/regression-testing/fail-first-fixture-check.2026-10-02T07-55.md:1
```

`<FEATURE>` is `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527`. The companion `fail-first-fixture-run.2026-10-02T07-55.md` records the pre-fix run and is cited here, not searched. The post-fix result for the same check is in `evidence/regression-testing/post-fix-fixture-check.2026-10-17T13-04.md`.
