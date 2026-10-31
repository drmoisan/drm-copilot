# `2026-10-31-pushed-down-vendored-code-coverage-carve-out` — User Story

- Issue: #1049
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-31
- Spec: `spec.md` (this folder)

## Story Statement

- As a destination-repository maintainer, I want unmodified pushed-down PowerShell files to be exempt from my coverage measurement by exact path and verified hash, so that I can stop maintaining recreated duplicate tests while my own and modified code stays covered.
- As a reviewer, I want manifest-derived exemptions to be recognized and verifiable from a report, and hand-written production-path exclusions to remain Blocking, so that the exception cannot be used to hide untested code.

## Problem / Why

The push-down copies hooks, skills, agents, libraries and rules into destination repositories without the Pester tests that cover them. The pushed-down rule `general-unit-test.md` states that no production file may be excluded from coverage, so a destination that enforces the rule must cover the pushed-down PowerShell files. At least one destination has recreated a Pester suite locally; those tests duplicate upstream coverage, drift on every push-down, and can fail for reasons unrelated to the destination's own code. The rule has no vendored-code category, so a destination cannot exempt pushed-down files without violating it.

## Personas & Scenarios

- Persona: destination-repository maintainer
  - Maintains a repository that receives the push-down and enforces the pushed-down coverage rule.
  - Cares about meaningful coverage of the repository's own code and about stable CI.
  - Constraint: cannot hand-write exclusions for production paths without a Blocking review finding.
  - Frustration: recreated tests of pushed-down hooks fail or drift after each push-down.
- Persona: reviewer (human or feature-review agent)
  - Verifies coverage evidence and exclusion entries on a branch.
  - Needs a deterministic artifact that shows which files were exempted and why.
- Scenario: maintainer opts in
  1. The maintainer runs the push-down; the destination receives `.push-down-manifest.json` with a path and hash for each written file.
  2. The maintainer adds `"exempt_unchanged_push_down_files": true` to `config/poshqc-coverage.json`.
  3. The maintainer runs PoshQC coverage through the MCP tool. Unchanged pushed-down files are dropped from the population; `artifacts/pester/vendored-coverage-exemptions.json` lists each path with its status.
  4. The maintainer removes the recreated duplicate tests of the unmodified pushed-down files.
  5. Later the maintainer edits one pushed-down hook and adds a new hook under `.claude/hooks/`. The next run reports the edited hook `modified` and the new hook `unlisted`; both stay in the denominator and need local tests.
- Scenario: reviewer checks a branch
  1. The reviewer reads the exemption report and confirms that only `exempt` paths were removed.
  2. The reviewer flags any hand-written production-path exclusion, and any manifest hash change without a push-down run, as Blocking.

## Acceptance Criteria

- [ ] As a maintainer, I can read in the pushed-down `general-unit-test` rule that a file may be excluded from coverage only when its exact path is listed in `.push-down-manifest.json` with a matching hash and the exemption is derived by tooling at measurement time.
- [ ] As a maintainer, the manifest written by the push-down records a path and canonical content hash for every file it writes, and each hash matches the bytes written.
- [ ] As a maintainer, a pushed-down file that I modify, and any file not listed in the manifest, is not exempt and stays in my coverage denominator.
- [ ] As a maintainer, a hook I add under `.claude/hooks/` stays in my coverage denominator.
- [ ] As a maintainer, I enable the exemption with one boolean key in `config/poshqc-coverage.json` and write no exclusion path by hand.
- [ ] As a maintainer, an invalid manifest with the opt-in set fails my coverage run with a message naming `.push-down-manifest.json`, and a missing manifest exempts nothing.
- [ ] As a reviewer, I can verify the exemption from `artifacts/pester/vendored-coverage-exemptions.json`, which is sorted and contains no timestamps or absolute paths.
- [ ] As a reviewer, the rule and the feature-review coverage step treat hand-written production-path exclusions and hand-edited manifest hashes as Blocking, and recognize the manifest-derived exemption.
- [ ] As a maintainer, the rule and the PoshQC README state that pushed-down code is tested upstream, that a modified copy is owned and tested locally, and that recreated duplicate tests of unmodified pushed-down files may be removed.
- [ ] As a maintainer of this repository, I can confirm that this repository does not opt in and keeps its own tests, enforced by a repo-gate test.

## Non-Goals

- A bash/kcov exemption list (deferred, OQ-4).
- Any change to this repository's coverage measurement or thresholds.
- New manifest fields or a manifest schema version change.
- Any new Python file.
