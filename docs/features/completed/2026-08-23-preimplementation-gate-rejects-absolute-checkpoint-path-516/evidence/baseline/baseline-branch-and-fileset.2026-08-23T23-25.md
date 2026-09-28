# Baseline — Branch Head and Changed File Set (issue #516)

Timestamp: 2026-08-24T15-10
Command: `git rev-parse HEAD` then `git diff --name-only fb3e1f331cc52d1dd7a61332d6d23fcc0b495e24`
EXIT_CODE: 0

## MANDATORY BASELINE SUBSTITUTION — recorded per orchestrator directive

- **Plan-declared baseline:** `c308dd92` (the `## Base State` section of `plan.2026-08-23T23-25.md`, and every `git diff ... c308dd92` command in [P0-T7], [P2-T6], [P5-T1], and [P5-T3]).
- **Substituted baseline actually used:** `fb3e1f331cc52d1dd7a61332d6d23fcc0b495e24`.
- **Reason the substitution is mandatory, not cosmetic:** the plan was authored while this branch was based on `origin/bug/preimplementation-gate-blocks-planner-surfaces-535` at `c308dd92`, with PR #536 open and unmerged. PR #536 has since MERGED into `main`, and this branch has been cleanly rebased onto the current `origin/main` tip. `c308dd92` is therefore now an **ancestor** of `main`. A diff taken against it would sweep in every change `main` absorbed between `c308dd92` and the current tip — PR #536 and PR #540 among them — and would report dozens of files that are not this item's change. The file-set-discipline task [P5-T1] and the two-production-file check [P2-T6] would both fail spuriously.
- **Why `fb3e1f33` is the correct replacement:** `git merge-base HEAD origin/main` returns exactly `fb3e1f331cc52d1dd7a61332d6d23fcc0b495e24`, confirming it is the merge-base of this branch and `main` and therefore the true branch base for this item.
- **Scope of the substitution:** every `git diff` baseline in this plan, without exception — [P0-T7], [P2-T6], [P5-T1], [P5-T3].

## Branch Head

- Branch: `bug/preimplementation-gate-rejects-absolute-checkpoint-path-516`
- `git rev-parse HEAD`: `9c12d20a346cc75db7ad6052f4db4b32f9f69f94`
- Head commit subject: `docs(516): prepare absolute-path preimplementation-gate fix`
- Merge-base with `origin/main`: `fb3e1f331cc52d1dd7a61332d6d23fcc0b495e24` (`Merge pull request #540 from drmoisan/bug/ruff-check-is-write-mode-and-exits-zero-after-fixing-515-r2`)
- Commits on this branch above the merge-base: exactly one (`9c12d20a`), the documentation preparation commit.

## Baseline Changed-File List (`git diff --name-only fb3e1f33`)

```text
docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/issue.md
docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/plan.2026-08-23T23-25.md
docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/research/2026-08-23T23-40-preimplementation-gate-absolute-path-516-research.md
docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/spec.md
```

Four files, all documentation, all under this item's own feature folder. No production file, no test file, no file under `.claude/rules/`, no file under `.github/instructions/`, and no `quality-tiers.yml`.

Output Summary: Head is `9c12d20a346cc75db7ad6052f4db4b32f9f69f94`. The plan-declared baseline `c308dd92` was replaced with the merge-base `fb3e1f331cc52d1dd7a61332d6d23fcc0b495e24` because the branch was rebased onto `main` after PR #536 merged, making the plan-declared value an ancestor of `main` and therefore an invalid diff baseline. Against the substituted baseline the changed-file list is the four documentation files added by the single preparation commit `9c12d20a`, all under the feature folder. This is a docs-only baseline and is the expected clean starting state, not a finding. EXIT_CODE 0 for both commands.
