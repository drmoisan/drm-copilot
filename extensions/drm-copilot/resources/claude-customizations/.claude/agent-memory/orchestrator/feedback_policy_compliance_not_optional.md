---
name: Policy requirements are not optional gaps
description: Never frame skipped policy requirements as "known gaps" or defer them to user opt-in; comply before reporting completion.
type: feedback
---

When repository policy (`.claude/rules/*.md`, `.github/instructions/*.md`) requires something — tests, coverage, toolchain steps, file-size limits — completing the change without satisfying that requirement is a policy violation, not a "known gap" or "follow-up."

**Why:** The user explicitly rejected framing a missing Pester test as a "known gap" after a new PowerShell script was added. Per `.claude/rules/powershell.md` and `.claude/rules/general-unit-test.md`, new scripts require Pester tests and >=90% coverage. Treating that as optional or deferrable misrepresents the state of the work and pushes compliance burden onto the user.

**How to apply:**
- Before reporting any code change complete, verify every applicable policy requirement (toolchain steps, tests, coverage, file size, etc.) is satisfied in this same change set.
- Do not use phrases like "known gap," "follow-up," "if you want I can add tests," or "out of scope" to defer a policy requirement. Either complete the requirement, or stop and report the work as blocked with the specific policy citation.
- For PowerShell: new `.ps1` files require Pester tests covering positive, negative, and edge paths, with mocks at the wrapper-seam boundary; run format → analyze → Pester and confirm all pass before reporting completion.
- Asking the user whether to add required tests is not an acceptable substitute for adding them.
