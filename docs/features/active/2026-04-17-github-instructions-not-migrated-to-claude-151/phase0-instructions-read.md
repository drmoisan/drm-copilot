# Phase 0 Baseline Evidence — Bug #151

- **Plan:** `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/plan.2026-04-17T16-13.md`
- **Captured:** 2026-04-17

---

## P0-T1: Current `.claude/rules/` Directory Listing

Confirmed contents at capture time (4 files):

```
csharp.md
powershell.md
python.md
typescript.md
```

**None of the 6 files to be created already exist.** Confirmed absent:

- `general-code-change.md` — ABSENT
- `general-unit-test.md` — ABSENT
- `tonality.md` — ABSENT
- `typescript-suppressions.md` — ABSENT
- `python-suppressions.md` — ABSENT
- `self-explanatory-code-commenting.md` — ABSENT

---

## P0-T2: Spec Reference and Acceptance Criteria

- **Spec path:** `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/spec.md`
- **Spec status at capture:** `Draft` — confirmed NOT "Delivered"; safe to proceed.
- **Plan path:** `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/plan.2026-04-17T16-13.md`
- **Issue:** #151

**Acceptance Criteria (AC-1 through AC-12) from `spec.md`:**

- [ ] AC-1: `.claude/rules/general-code-change.md` exists with `paths: **`, summarizes the cross-language design principles and the mandatory toolchain loop order (format → lint → type-check → test).
- [ ] AC-2: `.claude/rules/general-unit-test.md` exists with `paths: **`, and explicitly states: repository-wide line coverage ≥ 80% and any new module/class/method ≥ 90%.
- [ ] AC-3: `.claude/rules/typescript.md` Testing Standards section includes: coverage thresholds (≥80% repo-wide, ≥90% new code) and the coverage command (`npm run test:unit:coverage`).
- [ ] AC-4: `.claude/rules/python.md` Testing Standards section includes the repo-wide ≥80% coverage floor (in addition to the existing ≥90% new-code statement).
- [ ] AC-5: `.claude/rules/csharp.md` Testing Standards section includes coverage thresholds (≥80% repo, ≥90% new code).
- [ ] AC-6: `.claude/rules/powershell.md` Testing Standards section includes coverage thresholds (≥80% repo, ≥90% new code).
- [ ] AC-7: `.claude/rules/tonality.md` exists with `paths: **`, summarizes the professional tone requirements and the prohibitions on humor, hyperbole, and decorative metaphor.
- [ ] AC-8: `.claude/rules/typescript-suppressions.md` exists with `paths: **/*.ts`, lists the pre-authorized `eslint-disable-next-line` and `@ts-expect-error` patterns with their required comment format.
- [ ] AC-9: `.claude/rules/python-suppressions.md` exists with `paths: **/*.py`, lists at minimum the S603, ARG002, B008, BLE001, and S110 suppression patterns with their pre-authorized comment formats.
- [ ] AC-10: `.claude/rules/self-explanatory-code-commenting.md` exists with `paths: **/*.py`, summarizes mandatory docstring requirements for classes and functions, and the rule that loops and branches must have intent comments.
- [ ] AC-11: `.claude/skills/feature-review-workflow/SKILL.md` Step 5 check list includes a coverage verification step; Step 8 lists coverage regression as a remediation trigger.
- [ ] AC-12: `.claude/agents/feature-review.md` includes instructions for how the reviewer handles coverage — either by verifying existing coverage artifacts or (if the tool policy is expanded) by running the coverage command directly.

---

## P0-T3: Current Step 5 and Step 8 Content — `.github/skills/feature-review-workflow/SKILL.md`

### Step 5 (current, verbatim)

```
5. **Run required checks**
   - Prefer repo-defined, check-only commands.
   - Default order:
     1. formatting check
     2. lint check
     3. type check
     4. tests
   - Run the smallest relevant subset first when the repo policy permits it.
   - If a tool cannot run in the environment, mark the affected section unverified or partial with a concrete reason.
```

**Insertion point for Phase 3:** Add item `5. coverage` after `4. tests` in the default order list.

### Step 8 (current, verbatim)

```
8. **Trigger remediation when required**
   - Remediation is required when any of the following apply:
     - the policy audit contains meaningful FAIL or PARTIAL results
     - toolchain checks fail
     - the code review contains blockers
     - required acceptance criteria are FAIL or PARTIAL
   - Create `remediation-inputs.<timestamp>.md` first.
   - Create the target remediation plan file from the canonical plan template.
   - Hand off plan creation through `remediation-handoff-atomic-planner`.
   - Do not report completion unless the remediation plan file exists when remediation was triggered.
```

**Insertion point for Phase 3:** Add `- coverage regression below policy threshold (< 80% repo-wide or < 90% for new code)` to the "Remediation is required when any of the following apply" list.

---

## P0-T4: Current `.claude/agents/feature-review.md` Tools Allowlist

```yaml
tools:
  - Read
  - Grep
  - Glob
  - "Bash(git diff *)"
  - "Bash(git log *)"
  - "Write(/docs/features/active/**)"
```

**Agent body summary:** The agent is a feature-branch reviewer outputting `policy-audit`, `code-review`, `feature-audit`, and optionally `remediation-inputs` artifacts to `docs/features/active/**`. It reads work mode from `issue.md` and applies AC sources accordingly. It does not modify policy documents or source code. It marks sections UNVERIFIED with reasons when evidence is unavailable.

**Coverage model decision (Phase 3):** The tool policy does NOT include a coverage run command. Phase 3 will add evidence-verification instructions (inspect pre-existing artifacts) rather than expanding the tool allowlist with a coverage run command.
