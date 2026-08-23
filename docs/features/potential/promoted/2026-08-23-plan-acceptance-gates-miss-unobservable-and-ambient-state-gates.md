# plan-acceptance-gates-miss-unobservable-and-ambient-state-gates (Issue #519)

- Date captured: 2026-08-23
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/plan-acceptance-gates-miss-unobservable-and-ambient-state-gates/ (Issue #519)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #519
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/519
- Last Updated: 2026-08-23
## Summary

The G1-G6 acceptance-gate rules inspect only two things: `--cov` argument values and search literals. Across five preflight cycles on a single atomic plan, 25 acceptance conditions were found that could not fail, and the validator passed the plan cleanly on all six runs. None of the 25 fell into a category G1-G6 examine. The rule set is sound for what it covers and blind to at least five further classes of unfalsifiable gate.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: Python 3.13 under Poetry; ruff 0.15.12, black 26.1.0, pyright 1.1.409, pytest 9.0.2
- Command/flags used: `mcp__drm-copilot__validate_orchestration_artifacts` with `artifact_type=plan`, six runs across five plan revisions
- Data source or fixture: the atomic plan for issue #502 at `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/plan.2026-08-22T22-57.md`; 76 tasks, roughly 44 acceptance clauses naming a count, line, field, status, or threshold

## Steps to Reproduce

1. Take an atomic plan whose acceptance conditions include commands other than `pytest --cov` invocations and fixed-string searches — for example formatter invocations, `git diff` and `git status` observations, and prose conditions over "the diff".
2. Run the plan validator against it. Record the Blocking findings and Warnings.
3. Independently walk every acceptance condition and, for each, name a reachable state in which it fails. Record every condition for which no such state exists.
4. Compare the two sets.

## Expected Behavior

`.claude/rules/plan-acceptance-gates.md` opens by stating its own purpose: "a plan can state an acceptance condition that cannot fail... Such a condition reads as a verification step and gates nothing." A validator built for that purpose should catch a representative sample of the class, or the rule file should record which sub-classes it deliberately does not cover so a reviewer knows what still needs human attention.

## Actual Behavior

Step 2 produced, on every one of six runs, exit 0 with exactly two G4 Warnings and zero Blocking findings. Step 3 produced 25 conditions that could not fail. The intersection is empty.

The 25 sort into five classes, none of which G1-G6 inspect:

1. **Output the command does not emit in the success case.** `black .` prints no `reformatted ` line when nothing was rewritten, so a gate requiring "the reformatted-file line recorded verbatim" is unsatisfiable on a clean run and, under a fail-closed evidence rule, can never pass. `run_poshqc_analyze` returns only an ok flag and a one-sentence summary and writes no report file, so a gate demanding a zero-diagnostic count names a value that has no source. `pytest --cov-branch --cov-report=term-missing` prints one combined `Cover` column, so a gate demanding separate line and branch percentages reads two numbers that are never printed. A coverage gate whose command omits `--cov-report=term-missing` prints no table at all when the project's `addopts` supplies only an LCOV reporter.

2. **Write-mode tooling gated on exit code.** A formatter or fixing linter exits 0 when it rewrites a file, so "exit 0" cannot observe the rewrite. This affected `black`, Prettier via `npm run format`, the PoshQC formatter, and `ruff check` — the last because `pyproject.toml` sets `fix = true`, recorded separately as [[ruff-check-is-write-mode-and-exits-zero-after-fixing]].

3. **Ambient state the plan does not pin.** `git diff --exit-code -- <path>` compares worktree to index, so it passes vacuously once a change is committed. Anchoring to a ref fixes that but introduces the mirror-image blindness: `git diff` never reports untracked files, so an anchored diff omits every file the plan creates and a "no new function signature" audit passes without seeing the modules that add signatures. `git diff --name-only` likewise never lists untracked files, so a gate asserting it lists four newly created fixtures always sees an empty list. `git status --porcelain` covers untracked but goes empty once committed — the two are complementary and each alone is wrong in one state.

4. **Task-ordering dependencies inside the plan.** A gate that runs a test path containing deliberately-failing cases added by an earlier task, before the later task that makes them pass, cannot exit 0. A baseline captured *after* a write-mode formatter has already repaired pre-existing drift becomes either a blanket waiver or makes the later gate unsatisfiable.

5. **Evidence the executor selects.** Two conditions asked the executor to identify "the known-genuine pair" and to choose a survivor list. An executor free to pick the evidence it is judged against cannot fail. Separately, a probe list fixed in the plan but never measured against the corpus contained two entries with zero carriers, one of which was structurally unreachable — it appeared in both `shared_surfaces` and `mandate_reads`, so mandate-read exclusion strips it from every harvest.

Classes 1 and 2 share a property that makes them invisible to review: they cannot be detected by reading the plan, the rules, or the tool documentation. Only running the tool and observing its success-case output reveals them. Four careful review cycles missed class 1 entirely; it surfaced only when the reviewer ran black, ruff, pyright, the analyzer and the corpus derivation.

Class 3 has a second property worth recording: each fix introduced its own mirror-image defect. The bare form was replaced by an anchored form that was blind to untracked files; a porcelain form that fixed untracked-blindness was blind to the committed state. Three successive cycles each corrected the previous cycle's correction.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Per-cycle finding counts: 5, 2, 3, 3, 1. Cycle 3 additionally self-found 11 when instructed to walk all 76 conditions individually instead of grepping for patterns — the single largest yield of any cycle, and evidence that the detection method matters more than reviewer effort.
- Validator output was identical on all six runs: `ok: true`, two G4 Warnings for the bare `--cov` space-separated form in the mandated canonical pytest command, no Blocking findings.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High. The consequence is not a broken build but a false assurance: a plan carrying gates that cannot fail passes review and executes, and every one of those gates reports success regardless of what the executor did. The rule file's own framing — that such a condition "reads as a verification step and gates nothing" — is exactly the harm, and it is currently reachable through five routes the validator does not inspect.

Severity is bounded by the fact that a thorough human or agent reviewer *can* find these, as this exercise demonstrates. But it took five cycles and roughly 1.4 million subagent tokens on one plan, and the yield depended entirely on the sweep method.

Not a Blocker: no gate produces a *false failure*, and no incorrect code is admitted directly. The damage is to the verification argument.

## Suspected Cause / Notes

- G1-G4 target `--cov` values and G5-G6 target search literals. Both were chosen because they are decidable context-free or with a cheap repository lookup. The five classes above are harder: class 1 needs tool behavior, classes 3 and 4 need intra-plan reasoning, class 5 needs corpus measurement. The gap is a natural consequence of picking the tractable cases first, not an oversight in the existing rules.
- Not everything here is automatable, and the rule file's own guidance is to weigh a new rule on its false-positive rate at authoring time. Realistic candidates, roughly in order of value per unit of effort:
  - **A write-mode command register.** A static list of commands known to write, with a requirement that any acceptance condition invoking one carry an observation beyond the exit code. This is cheap, has a near-zero false-positive rate, and covers class 2 completely. The inventory already exists: `black .`, `ruff check` without `--no-fix`, `run_poshqc_format`, `npm run format`, `npm ci`, `git add -A` write; `black --check`, `ruff check --no-fix`, `pyright`, `pytest`, `run_poshqc_analyze`, `run_poshqc_test`, `npm run lint`, `npm run typecheck` do not.
  - **A bare-`git diff` rule.** Flag `git diff --exit-code` or `git diff --name-only` with no ref argument, since both are commit-state-dependent, and flag any `git diff` gate asserting over created paths without a preceding stage. Mechanical and decidable from the command text.
  - **A coverage-reporter rule.** Flag a `--cov` invocation whose acceptance demands a printed percentage when neither the command nor the project `addopts` supplies a terminal reporter. Decidable by reading `pyproject.toml`.
  - **An executor-choice heuristic.** Flag acceptance text containing selection language — "any", "a suitable", "the known", "choose" — over evidence the condition is asserted against. Higher false-positive risk; would need measuring before shipping as Blocking.
- Class 1 in general is not statically decidable and probably should be addressed by documentation rather than a rule: a prose requirement in `.claude/skills/atomic-plan-contract/SKILL.md` that a plan author must observe a command's success-case output before asserting over it, plus the write-mode register above.
- The rule file's "Scope of Invocation" section argues against grandfathering because no sweep exists over the committed plan corpus. That reasoning holds for any rule added here too, and is worth re-reading before adding one.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas — per new rule, positive cases from the 25 conditions catalogued above (they are real, measured instances, not synthetic) and negative cases from the corrected forms that replaced them, so a rule that fires on the fix is caught.
- [x] Integration scenario to retest — run any new rules against the #502 plan at each of its six revisions. Expect zero findings at revision 5 and a non-zero count at revision 0 for whichever classes the new rules cover. A rule set that finds nothing at revision 0 is not exercising the case it was written for.
- [x] Manual verification notes — measure the false-positive rate over the committed plan corpus before assigning any rule Blocking severity, following the precedent set for G5, where a corpus measurement of zero findings decided that rule's severity. Record the measurement as an artifact.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
