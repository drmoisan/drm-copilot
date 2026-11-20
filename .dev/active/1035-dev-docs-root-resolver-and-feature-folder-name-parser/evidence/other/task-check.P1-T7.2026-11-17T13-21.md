# Task Check P1-T7 (Remediation Cycle 1)

Timestamp: 2026-11-17T13-21
Command: sh SCRATCH/issue-1035-p1t7.sh (sh SCRATCH/issue-1035-pscheck.sh p1t7 write <new suite> -- <new suite> and the three existing suites of the script under tests/scripts/dev-tools/, then git diff --stat <Baseline-Head> on both copies of the script)
EXIT_CODE: 0
Output Summary: Changed file: new tests/scripts/dev-tools/new-potential-entry.EntryGuards.Tests.ps1. Selection rule: the new suite plus every existing suite of scripts/dev-tools/new-potential-entry.ps1 (new-potential-entry.Tests.ps1, new-potential-entry.TemplateRoot.Tests.ps1, new-potential-entry.CopyParity.Tests.ps1). Formatter `Already formatted:`; analyzer 0 findings; launcher pester selection exit code 0 (workers=4, wall-clock 150.01 s): four suites with 2, 4, 44 and 4 tests, 0 failures, 0 errors.

- New cases: `aborts without copying when -ShortName is empty`, `aborts without copying when -ShortName is not kebab-case`, `aborts without copying when the template is missing`, `creates the potential directory when it is missing`. The native exit code set by the script's `exit 1` is restored in AfterEach.
- `git diff --stat <Baseline-Head>` on scripts/dev-tools/new-potential-entry.ps1 and extensions/drm-copilot/resources/templates/new-potential-entry.ps1: empty (exit 0).
