# [P12-T4] Pair-hash parity, recomputed from on-disk content

Timestamp: 2026-09-07T15-52

Command:

```
# per file, SHA-256 over the raw bytes of the on-disk file
Get-FileHash -Algorithm SHA256 -LiteralPath <path>          # the specified method
# per file, line count
@(Get-Content -LiteralPath <path>).Count                    # the specified method
# cross-check, restricted to the copy-set paths
git status --porcelain -- <the 38 copy-set paths>
```

EXIT_CODE: 0

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session from any
context, so `Get-FileHash -Algorithm SHA256` and `@(Get-Content -LiteralPath $path).Count` could not
be executed directly. Both were computed by an equivalent Python implementation:

- **Hash.** `hashlib.sha256` over the file opened in binary mode, rendered as uppercase hexadecimal.
  This is byte-for-byte the same input and the same algorithm `Get-FileHash -Algorithm SHA256` uses,
  and the same output casing, so the digests below are directly comparable with any PowerShell-side
  figure recorded elsewhere in this feature.
- **Line count.** The file is decoded as `utf-8-sig` with newline translation disabled, `
` and
  bare `` are normalized to `
`, one trailing newline is dropped if present, and the remainder is
  split on `
`. That reproduces `@(Get-Content -LiteralPath $path).Count`, which strips the BOM,
  treats all three line-ending conventions as line breaks, and emits no trailing empty element for a
  file that ends in a newline.

## Recomputation, not carry-forward

Every digest below was computed in this task from the **current on-disk content** of each file.
No hash recorded by an earlier phase of this plan was carried forward, reused, or consulted. Earlier
phases recorded hashes that were correct when they were written; the file as it stands now is the
authority, and this artifact is a fresh measurement of it.

## Porcelain cross-check

`git status --porcelain` restricted to the 38 copy-set paths returned **exit code 0 with empty
output**. Verbatim:

```
<empty>
```

An empty result means no copy-set file is modified, staged, or untracked relative to the index and
HEAD. Every file hashed below is therefore in its committed state, so the on-disk content this task
measured is the same content the branch carries at `cc83c0c84ecede048fa5e275eb7a6d66248639fc`. That
is the cross-check the task requires: it rules out the case in which a hash is computed from a
working-tree edit that is not part of the delivered change.

## Output Summary

**19 pairs recomputed, 19 with equal hashes, 0 unequal.** 38 distinct files were hashed.
Every pair's two members carry the same SHA-256 digest and the same line count. The largest line
count observed is 500, on `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, which is
at the 500-line cap and not over it.

Pair composition: 4 parser-sibling pairs (two files, one Claude pair and one Codex pair each),
10 four-copy-hook pairs (five hooks, one Claude pair and one Codex pair each), 4 two-copy-hook pairs
(Claude only), and 1 supplementary registry pair for the two `pester.runsettings.psd1` copies.
The 18 copy-set pairs account for all 36 production PowerShell copies in scope.

## Pair table

| # | Kind | Side | File | SHA-256 (canonical) | SHA-256 (mirror) | Equal | Lines (canonical) | Lines (mirror) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | parser sibling | Claude | `hook-command-scanner.ps1` | `19223E297D621F5787B54DDABA745E591950D153A8EB749CC21B22509F45DC7D` | `19223E297D621F5787B54DDABA745E591950D153A8EB749CC21B22509F45DC7D` | yes | 450 | 450 |
| 2 | parser sibling | Codex | `hook-command-scanner.ps1` | `19223E297D621F5787B54DDABA745E591950D153A8EB749CC21B22509F45DC7D` | `19223E297D621F5787B54DDABA745E591950D153A8EB749CC21B22509F45DC7D` | yes | 450 | 450 |
| 3 | parser sibling | Claude | `hook-command-invocation.ps1` | `B82246C61BB9FCB44AD6471DFA15278069C599AC3A52DA26E62EDE0CF1E92609` | `B82246C61BB9FCB44AD6471DFA15278069C599AC3A52DA26E62EDE0CF1E92609` | yes | 483 | 483 |
| 4 | parser sibling | Codex | `hook-command-invocation.ps1` | `B82246C61BB9FCB44AD6471DFA15278069C599AC3A52DA26E62EDE0CF1E92609` | `B82246C61BB9FCB44AD6471DFA15278069C599AC3A52DA26E62EDE0CF1E92609` | yes | 483 | 483 |
| 5 | four-copy hook | Claude | `enforce-orchestration-preimplementation-gate.ps1` | `218CBFADD55CC51547488332C33213339AF42E56B73408005F97101A06D9C176` | `218CBFADD55CC51547488332C33213339AF42E56B73408005F97101A06D9C176` | yes | 496 | 496 |
| 6 | four-copy hook | Codex | `enforce-orchestration-preimplementation-gate.ps1` | `427CA3034A7268EA37EE176DCC990F3DBB113A143D15B3D2E0AF0236D091A9BB` | `427CA3034A7268EA37EE176DCC990F3DBB113A143D15B3D2E0AF0236D091A9BB` | yes | 500 | 500 |
| 7 | four-copy hook | Claude | `enforce-promotion-mcp-only.ps1` | `924AD2EFA174972ACD7749066EB4FC07885E9CCDAC4286A537419D8EC997406D` | `924AD2EFA174972ACD7749066EB4FC07885E9CCDAC4286A537419D8EC997406D` | yes | 303 | 303 |
| 8 | four-copy hook | Codex | `enforce-promotion-mcp-only.ps1` | `B768E096D612F894363E09CB7C7D3BE1578210DC5D0460135BFE12897E4BA6B8` | `B768E096D612F894363E09CB7C7D3BE1578210DC5D0460135BFE12897E4BA6B8` | yes | 288 | 288 |
| 9 | four-copy hook | Claude | `enforce-epic-merge-gate.ps1` | `71E89258F7461CA21E090A75E2D8722F8F6BE576C586AC834635A87E36518ABF` | `71E89258F7461CA21E090A75E2D8722F8F6BE576C586AC834635A87E36518ABF` | yes | 473 | 473 |
| 10 | four-copy hook | Codex | `enforce-epic-merge-gate.ps1` | `11169C09014B1B9165CBA04BF4E2A335D467205D6928F4AA2CD98141DC71E4F4` | `11169C09014B1B9165CBA04BF4E2A335D467205D6928F4AA2CD98141DC71E4F4` | yes | 174 | 174 |
| 11 | four-copy hook | Claude | `enforce-epic-worktree-removal-gate.ps1` | `0E6FE379251C3C97EFDAE30F9B7AECDEB0DD767C632F0E728D25D78A4CEBA856` | `0E6FE379251C3C97EFDAE30F9B7AECDEB0DD767C632F0E728D25D78A4CEBA856` | yes | 445 | 445 |
| 12 | four-copy hook | Codex | `enforce-epic-worktree-removal-gate.ps1` | `91B1E722D76B120209DEA80AF7A9DAC272F8B202F99389A7B20DC5CBE1A6C440` | `91B1E722D76B120209DEA80AF7A9DAC272F8B202F99389A7B20DC5CBE1A6C440` | yes | 177 | 177 |
| 13 | four-copy hook | Claude | `validate-bash.ps1` | `BD0C2FFE8F1E490C417D21717393878D05F5F15038899DA09928E91BA22D3146` | `BD0C2FFE8F1E490C417D21717393878D05F5F15038899DA09928E91BA22D3146` | yes | 402 | 402 |
| 14 | four-copy hook | Codex | `validate-bash.ps1` | `609C1AF789E1F091D4710F77E1ECE15C56B0183870CC0D09BA74B2F9FE989BA6` | `609C1AF789E1F091D4710F77E1ECE15C56B0183870CC0D09BA74B2F9FE989BA6` | yes | 295 | 295 |
| 15 | two-copy hook | Claude | `enforce-pr-author-skill-helpers.ps1` | `658277DDC0523C07AD9C488215FC56BF3E045777E71B8950459676C8D87C61C5` | `658277DDC0523C07AD9C488215FC56BF3E045777E71B8950459676C8D87C61C5` | yes | 240 | 240 |
| 16 | two-copy hook | Claude | `enforce-parallel-worktree-removal-gate.ps1` | `47CAD03CC3948827AACCD945D78F04B4E9C79AB70B2709CEDB53CDB033CAA5D3` | `47CAD03CC3948827AACCD945D78F04B4E9C79AB70B2709CEDB53CDB033CAA5D3` | yes | 314 | 314 |
| 17 | two-copy hook | Claude | `enforce-parallel-abandon-gate.ps1` | `BE07ECFFD852F22F6B5DC103F519253028FBE6CB66F52BAAC8C48C9D9808AEE6` | `BE07ECFFD852F22F6B5DC103F519253028FBE6CB66F52BAAC8C48C9D9808AEE6` | yes | 331 | 331 |
| 18 | two-copy hook | Claude | `enforce-pr-author-skill.epic-base-branch.ps1` | `D617F4B10F36D1CA58EA44A8863AE377FF784FC53A778EBBBB741D7D47FECCFE` | `D617F4B10F36D1CA58EA44A8863AE377FF784FC53A778EBBBB741D7D47FECCFE` | yes | 115 | 115 |
| 19 | registry: PoshQC runsettings | shared | `pester.runsettings.psd1` | `BCAEBFB014F569ECF116B21AD936296EB024C209E304C188E2BC89D7244DDF91` | `BCAEBFB014F569ECF116B21AD936296EB024C209E304C188E2BC89D7244DDF91` | yes | 274 | 274 |

## Full paths, per pair

**Pair 1 — parser sibling, Claude side**

- canonical: `.claude/hooks/hook-command-scanner.ps1`
- mirror: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1`
- SHA-256: `19223E297D621F5787B54DDABA745E591950D153A8EB749CC21B22509F45DC7D` (both members)
- line count: 450 (both members)

**Pair 2 — parser sibling, Codex side**

- canonical: `.codex/hooks/hook-command-scanner.ps1`
- mirror: `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1`
- SHA-256: `19223E297D621F5787B54DDABA745E591950D153A8EB749CC21B22509F45DC7D` (both members)
- line count: 450 (both members)

**Pair 3 — parser sibling, Claude side**

- canonical: `.claude/hooks/hook-command-invocation.ps1`
- mirror: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1`
- SHA-256: `B82246C61BB9FCB44AD6471DFA15278069C599AC3A52DA26E62EDE0CF1E92609` (both members)
- line count: 483 (both members)

**Pair 4 — parser sibling, Codex side**

- canonical: `.codex/hooks/hook-command-invocation.ps1`
- mirror: `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1`
- SHA-256: `B82246C61BB9FCB44AD6471DFA15278069C599AC3A52DA26E62EDE0CF1E92609` (both members)
- line count: 483 (both members)

**Pair 5 — four-copy hook, Claude side**

- canonical: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
- mirror: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
- SHA-256: `218CBFADD55CC51547488332C33213339AF42E56B73408005F97101A06D9C176` (both members)
- line count: 496 (both members)

**Pair 6 — four-copy hook, Codex side**

- canonical: `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
- mirror: `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
- SHA-256: `427CA3034A7268EA37EE176DCC990F3DBB113A143D15B3D2E0AF0236D091A9BB` (both members)
- line count: 500 (both members)

**Pair 7 — four-copy hook, Claude side**

- canonical: `.claude/hooks/enforce-promotion-mcp-only.ps1`
- mirror: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1`
- SHA-256: `924AD2EFA174972ACD7749066EB4FC07885E9CCDAC4286A537419D8EC997406D` (both members)
- line count: 303 (both members)

**Pair 8 — four-copy hook, Codex side**

- canonical: `.codex/hooks/enforce-promotion-mcp-only.ps1`
- mirror: `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-promotion-mcp-only.ps1`
- SHA-256: `B768E096D612F894363E09CB7C7D3BE1578210DC5D0460135BFE12897E4BA6B8` (both members)
- line count: 288 (both members)

**Pair 9 — four-copy hook, Claude side**

- canonical: `.claude/hooks/enforce-epic-merge-gate.ps1`
- mirror: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`
- SHA-256: `71E89258F7461CA21E090A75E2D8722F8F6BE576C586AC834635A87E36518ABF` (both members)
- line count: 473 (both members)

**Pair 10 — four-copy hook, Codex side**

- canonical: `.codex/hooks/enforce-epic-merge-gate.ps1`
- mirror: `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`
- SHA-256: `11169C09014B1B9165CBA04BF4E2A335D467205D6928F4AA2CD98141DC71E4F4` (both members)
- line count: 174 (both members)

**Pair 11 — four-copy hook, Claude side**

- canonical: `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`
- mirror: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1`
- SHA-256: `0E6FE379251C3C97EFDAE30F9B7AECDEB0DD767C632F0E728D25D78A4CEBA856` (both members)
- line count: 445 (both members)

**Pair 12 — four-copy hook, Codex side**

- canonical: `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`
- mirror: `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1`
- SHA-256: `91B1E722D76B120209DEA80AF7A9DAC272F8B202F99389A7B20DC5CBE1A6C440` (both members)
- line count: 177 (both members)

**Pair 13 — four-copy hook, Claude side**

- canonical: `.claude/hooks/validate-bash.ps1`
- mirror: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1`
- SHA-256: `BD0C2FFE8F1E490C417D21717393878D05F5F15038899DA09928E91BA22D3146` (both members)
- line count: 402 (both members)

**Pair 14 — four-copy hook, Codex side**

- canonical: `.codex/hooks/validate-bash.ps1`
- mirror: `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1`
- SHA-256: `609C1AF789E1F091D4710F77E1ECE15C56B0183870CC0D09BA74B2F9FE989BA6` (both members)
- line count: 295 (both members)

**Pair 15 — two-copy hook, Claude side**

- canonical: `.claude/hooks/enforce-pr-author-skill-helpers.ps1`
- mirror: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1`
- SHA-256: `658277DDC0523C07AD9C488215FC56BF3E045777E71B8950459676C8D87C61C5` (both members)
- line count: 240 (both members)

**Pair 16 — two-copy hook, Claude side**

- canonical: `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`
- mirror: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`
- SHA-256: `47CAD03CC3948827AACCD945D78F04B4E9C79AB70B2709CEDB53CDB033CAA5D3` (both members)
- line count: 314 (both members)

**Pair 17 — two-copy hook, Claude side**

- canonical: `.claude/hooks/enforce-parallel-abandon-gate.ps1`
- mirror: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1`
- SHA-256: `BE07ECFFD852F22F6B5DC103F519253028FBE6CB66F52BAAC8C48C9D9808AEE6` (both members)
- line count: 331 (both members)

**Pair 18 — two-copy hook, Claude side**

- canonical: `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`
- mirror: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`
- SHA-256: `D617F4B10F36D1CA58EA44A8863AE377FF784FC53A778EBBBB741D7D47FECCFE` (both members)
- line count: 115 (both members)

**Pair 19 — registry: PoshQC runsettings, shared side**

- canonical: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
- mirror: `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`
- SHA-256: `BCAEBFB014F569ECF116B21AD936296EB024C209E304C188E2BC89D7244DDF91` (both members)
- line count: 274 (both members)

## Relation to the two parity mechanisms

The Codex pairs are bound by SHA-256 equality in
`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, so byte identity is the contract
and the digests above are the direct evidence for it. The Claude pairs are bound by content equality
in `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, which compares `read_text`
output and is therefore indifferent to line endings; equal SHA-256 digests are a strictly stronger
result than that contract demands and imply it. The two `pester.runsettings.psd1` copies are pinned
to exact text equality by `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`.

Per the plan preamble, the byte-identity property that
`test_bundled_claude_payload_contains_all_repo_runtime_contracts` exists to enforce — the case
deselected under open issue #510 in [P12-T5] — is discharged independently by the digests in this
artifact.
