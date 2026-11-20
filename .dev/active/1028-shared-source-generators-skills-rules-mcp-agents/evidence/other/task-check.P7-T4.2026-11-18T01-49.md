# Task Check — [P7-T4]

Timestamp: 2026-11-18T01-49
Command: sh SCRATCH/issue-1028-run.sh SCRATCH/issue-1028-accheck.ps1 -File <spec.md or user-story.md> -Lines <line list> (changes `- [ ]` to `- [x]` on the named lines only, and refuses any line that is not an unchecked item); git diff --numstat
EXIT_CODE: 0
Output Summary: In `spec.md` 23 items were checked in this task, for 39 checked in total; in `user-story.md` 9 were checked, for 13 in total. `git diff --numstat` shows 23/23 and 9/9 changed lines, so only checkbox lines changed. Six items stay open:
- spec `The required CI Required Gate check passes on the pull request head` and user-story `Every check mode runs in the existing poshqc / PowerShell QC shards ...`: these depend on CI and are checked off at S9.
- spec `No file added or changed by this child exceeds 800 lines` and user-story `Each new PowerShell module has at least 85% line coverage, ... and no added or changed file exceeds 800 lines`: read literally, these do not hold. `config/harness-parity-matrix.json` is child 1's data file, which was 11832 lines at `BASE` and is 11896 now. Every file under the file-size policy is within 800 lines, and `FileSizePolicy.RepoGate.Tests.ps1` passes (`evidence/qa-gates/scope-check.2026-11-18T01-46.md`). The items are left open for the owner or reviewer to decide.
- spec Definition of Done `Every item in ## Acceptance Criteria is checked off` stays open because the items above are open.
- spec Definition of Done `The full toolchain loop (..., integration) passes in a single pass` stays open, because integration tests run in CI only.

Evidence per checked item (spec):
- Malformed source fails before any write: `task-check.P5-T2.2026-11-18T00-00.md` (the agent suite asserts 0 writes for missing required fields), `task-check.P4-T1.2026-11-17T22-59.md` and the Phase 1 framework suite.
- No new converter module: `qa-gates/scope-check.2026-11-18T01-46.md`.
- Skill mirror equals sources, D-14 `native` and excluded copies unchanged: `qa-gates/skills-generation.2026-11-17T22-20.md` and `qa-gates/skill-matrix-native.2026-11-17T22-06.md`.
- Skill mirror unit tests (unselected skill, `agents/openai.yaml`, extra file): the `HarnessSkillMirror.Tests.ps1` cases `never lists, writes or deletes an unselected skill folder`, `never mirrors agents/openai.yaml or references/standard.md` and `reports an extra file in a generated folder`.
- Positive differences applied or `deferred-ledger-region`: `qa-gates/skill-ports.2026-11-17T22-06.md`. Of 111 positives, 16 are applied and 67 are `deferred-ledger-region`. The 28 `not-applicable` positives each name the equivalent section already present in the target, so they do not port.
- Pins, the epic surfaces and the ledger unchanged; digest and ledger tests pass: `qa-gates/skills-generation.2026-11-17T22-20.md` and `qa-gates/agents-generation.2026-11-18T00-10.md`.
- Rules produced from sources with bundles and `-Check` exit 0; the three rule suites; the unconditional-glob rejection test; `general-unit-test.instructions.md` begins with `---`: `qa-gates/rules-generation.2026-11-17T23-05.md`, `qa-gates/rule-sources.2026-11-17T23-00.md` and `task-check.P4-T1.2026-11-17T22-59.md`.
- Agents equal sources; Codex generator runs; `Write(` literals; the four agent-related suites: `qa-gates/agents-generation.2026-11-18T00-10.md`, `task-check.P5-T2.2026-11-18T00-00.md`, and the final gates `qa-gates/pester-parallel.2026-11-18T01-46.md` and `qa-gates/pytest-parallel.2026-11-18T01-46.md`.
- Repository gate: `task-check.P6-T2.2026-11-18T00-48.md`. No workflow change: `qa-gates/scope-check.2026-11-18T01-46.md`. Matrix upkeep: `task-check.P6-T1.2026-11-18T00-43.md`. Brief parity: `qa-gates/brief-parity.2026-11-18T00-56.md`.
- Coverage of at least 85% per new module, the final gates and the leak scan: `qa-gates/pester-parallel.2026-11-18T01-46.md`, `pytest-parallel.2026-11-18T01-46.md`, `jest-coverage.2026-11-18T01-46.md` and `coverage-delta.2026-11-18T01-46.md`.
- No added `.py` or `.ts`, the language classification and the excluded paths: `qa-gates/scope-check.2026-11-18T01-46.md`.
- The push-down and variant-generator suites after all generation: `qa-gates/pytest-parallel.2026-11-18T01-46.md`, the full `pytest -n auto` run with 17122 passed.
- `user-story.md` consistent with this spec: the open user-story items mirror the open spec items.

Changed files: `spec.md`, `user-story.md` (checkbox lines only).
Selection rule: `## Test Cadence (Mandatory)`. The task edits Markdown checkboxes only, so the check is the line-count comparison above.
