# Agents — first generation ([P5-T4])

Timestamp: 2026-11-18T00-10
Command:
- `sh SCRATCH/issue-1028-gen.sh agents` (`-Surface agents` in write mode).
- Content hashes and Codex writes, in order: `sh SCRATCH/issue-1028-hashes.sh SCRATCH/issue-1028-h0.txt`, which records `git hash-object` of every file under `.codex/agents/`, the bundle `.codex/agents/` and the bundle `pack-manifests/`; `sh SCRATCH/issue-1028-codexgen.sh` (`generate_codex_agent_variants` in write mode, the first run); the `h1` hashes; the second write run; the `h2` hashes.
- Checks: `sh SCRATCH/issue-1028-gen.sh agents check`, `sh SCRATCH/issue-1028-gen.sh all check` and `sh SCRATCH/issue-1028-codexgen.sh --check`.
- Inspection: `git status --porcelain`; `git diff --name-only <BASE> -- scripts/dev_tools/generate_codex_agent_variants.py` plus the four Claude-only agents; `git diff --name-only <BASE> --` the Codex agent, bundle agent and pack-manifest folders; `wc -l .codex/agents/*.toml`.
- Suites: the child 2 write-scope checker suite (`jest-extension test/lib/development-docs/write-scopes`), and Pester and pytest selections.
EXIT_CODE: 0
Output Summary:
- **Write run.** The agents write run wrote 2 files: `.claude/agents/pr-author.md` and its bundle copy, which gain a final line feed. All 48 other agent targets already equalled their sources.
- **Hashes.** Each snapshot covers 274 files. `h0` against `h1` (the first Codex write run): 0 changed hashes. `h1` against `h2` (the second run): 0 changed hashes. No base `.codex/agents/<family>.toml`, no bundle base copy, no variant and no pack manifest changed, because every base body [P5-T3] produced equals the committed base. There is therefore no generated variant to list.
- **Checks.** `-Surface agents -Check` and `-Surface all -Check` print "harness-generation: no drift" (exit 0), and the Codex generator `--check` exits 0.
- **BASE comparison.** `scripts/dev_tools/generate_codex_agent_variants.py` is unchanged from `BASE`. No single-ecosystem agent file differs from `BASE`: the four Claude-only agents show 0 changed paths, and the whole of `.codex/agents/` and both bundle folders show 0. The largest generated `.codex/agents/*.toml` is `orchestrator-c4.toml` at 214 lines, which is within the 800-line limit.
- **Suites.**
  - Write-scope checker suite (`write-scopes.contract.test.ts` and `write-scopes.test.ts`, recorded at [P0-T1]): 2 of 2 suites, 56 of 56 tests.
  - Pester (`ProcessReductionChain.Ledger.Tests.ps1`, `HarnessParityMatrix.RepoGate.Tests.ps1` and the harness-generation suites): 192 passed and 0 failed, including `PRC-LEDGER-CHAIN-HOLDS`, `PRC-LEDGER-SUBCHAIN-HOLDS`, `PRC-LEDGER-NO-EXCEPTIONS` and `PRC-LEDGER-END-STATE-RECORDED`.
  - pytest (`test_parallel_orchestrator_surface_contracts.py`, which holds `test_frozen_epic_surface_matches_pinned_baseline_digest`, and `test_generate_codex_agent_variants.py`): 54 passed.

Changed paths (porcelain after all write runs):

```text
 M .claude/agents/pr-author.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/agents/pr-author.md
```
