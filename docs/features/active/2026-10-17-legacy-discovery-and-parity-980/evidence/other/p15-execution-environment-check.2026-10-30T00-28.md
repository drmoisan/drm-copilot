# P15-T23 — Execution-environment brief check and documentation requalification

Task: [P15-T23] Document the payload identity design and requalify the host claims.
Branch: feature/legacy-discovery-and-parity-980
Issue: #980

## Brief facts unchanged except the P15-T21 wording

Timestamp: 2026-10-30T00:28Z
Command: `git diff <commit before P15-T21> HEAD --stat -- .github/skills/execution-environment/SKILL.md`; `git log --oneline <Phase 15 range> -- .github/skills/execution-environment/SKILL.md`
EXIT_CODE: 0
Output Summary: `1 file changed, 1 insertion(+), 1 deletion(-)`; the only Phase 15 commit touching the brief is the P15-T21 commit (`docs(skills): reword the shared-fixture bullet of the execution-environment brief (P15-T21)`). The single changed line is the fourth `## Test Runtime` bullet; no other brief fact changed in Phase 15, and P15-T23 did not edit the brief or any of its six copies.

## Documentation changes

- `docs/engineering/legacy-discovery-and-parity/enforcement.md`: new `## Identity source`
  section with the per-host identity table (Claude Code, Codex, Copilot harness, VS Code
  legacy Local harness) and the fail-closed rules for unbound calls; the `Start attestation`
  row states that the start is observational and that binding completes at the first
  controlled call; `## Protected records` gains `root-grants/`, `observations/` and the
  `.used` latch; `## Host-principal path` describes the root grant, the `invocation_ref`
  binding and the server-side invocation lookup, plus the dispatch latch refusals; new
  `## Capability probe` section with the sentinel observation flow and the per-host support
  table; `## Registration` closing paragraph describes doctor as a root call.
- `architecture.md`: the host port set paragraph states that the gateway client supplies
  the four identity options from the consumed protected records, that the MCP provider has
  no identity of its own, and that the host port set writes only the `.used` latch.
- `maintainer-guide.md`: the installed-host smoke steps probe after a sentinel run, never
  export identity, and drive the start and stop hooks with the host's own payload.
- `cli-reference.md`: `run_discovery_doctor` and `prepare_discovery_agent` rows describe
  the root grant and the `context-missing` / `unsupported` doctor answer.
- `handoff.md` and `completion-report.md`: the sentence claiming the chain was observed on
  Claude Code, Codex and the Copilot Local harness is replaced by the statement that the
  P12-T12 runs were harness-simulated host events with identity exported by `SCRATCH`
  launchers, pointing to the P16-T7 table
  (`evidence/qa-gates/discovery-host-observations.*.md`). `## Built artifacts` is unchanged.
- `spec.md` and `user-story.md`: `Status` carries the cycle-1 wording; `Last Updated` is
  `2026-10-30T00-30` in both.

## Suites

Timestamp: 2026-10-30T00:28Z
Command: `poetry run pytest tests/scripts/dev_tools/test_discovery_documentation_contracts.py -p no:cacheprovider -q`
EXIT_CODE: 0
Output Summary: `32 passed in 0.85s` (no pinned sentence needed a test update; every existing assertion holds on the rewritten pages).

Timestamp: 2026-10-30T00:28Z
Command: `pwsh` Pester over `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` (through SCRATCH/issue-980-pester.sh)
EXIT_CODE: 0
Output Summary: `Tests Passed: 7, Failed: 0, Skipped: 0`

Timestamp: 2026-10-30T00:28Z
Command: `git grep -c DRM_DISCOVERY -- docs/engineering`
EXIT_CODE: 1
Output Summary: no line printed (the retired name does not appear under docs/engineering; the enforcement page refers to it as "the retired environment-variable identity contract").

Result: PASS
