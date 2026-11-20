# Git Baseline, Remediation Cycle 2 (issue #937)

Timestamp: 2026-10-16T09-47
Task: P0-T6 (remediation-plan.2026-10-16T08-40.md)
Command: git fetch origin main; git rev-parse --abbrev-ref HEAD; git rev-parse HEAD; git rev-parse origin/main; git merge-base HEAD origin/main; git merge-base --is-ancestor origin/main HEAD; git status --porcelain
EXIT_CODE: 0
Output Summary: Branch bug/exempt-operand-unc-path-leg-937 at 90ab138c2; merge base c415af626 (the origin/main tip merged by 2677047c1). origin/main has since advanced to 04f594f2a (75 commits not in HEAD; is-ancestor exit 1). Porcelain lists only FEATURE paths (this plan file and cycle 2 evidence).

| Command | Output |
|---|---|
| `git fetch origin main` | `From https://github.com/drmoisan/drm-copilot` / `* branch main -> FETCH_HEAD` |
| `git rev-parse --abbrev-ref HEAD` | `bug/exempt-operand-unc-path-leg-937` |
| `git rev-parse HEAD` | `90ab138c218423c2236aa6f87e7d316feeb0c5be` |
| `git rev-parse origin/main` | `04f594f2ad2b891cbd8d1388a2e7fe2c67044d28` |
| `git merge-base HEAD origin/main` | `c415af626c292f38b910e3a27e70ab3e1903b31a` |
| `git merge-base --is-ancestor origin/main HEAD` | exit 1 (origin/main advanced after the cycle 2 merge; `git rev-list --count HEAD..origin/main` prints `75`) |

`git status --porcelain`:

```text
 M docs/features/active/exempt-operand-unc-path-leg-937/remediation-plan.2026-10-16T08-40.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/inputs-read-c2.2026-10-16T09-44.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/pathleg-rows-baseline-c2.2026-10-16T09-46.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/phase0-instructions-read-c2.2026-10-16T09-43.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/scratch-helpers-c2.2026-10-16T09-44.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/scratch-helpers-new-c2.2026-10-16T09-45.md
```

Note: origin/main advancing is not a plan acceptance condition here. The merge base used by P0-T8, P3-T5, and P4-T8 is computed at each task; at this point it is `c415af626`. A further merge of origin/main is outside this plan (PA-2 is the orchestrator's step).
