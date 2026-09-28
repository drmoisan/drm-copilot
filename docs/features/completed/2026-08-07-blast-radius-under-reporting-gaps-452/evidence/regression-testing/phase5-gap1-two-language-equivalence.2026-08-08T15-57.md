# [P5-T7] Gap 1 two-language equivalence check

Timestamp: 2026-08-08T15-57
Task: [P5-T7]

Both languages were evaluated under the identical configured root-surface set
`('package-lock.json', 'poetry.lock', 'quality-tiers.yml')`, matching the separator-free subset
that `config_root_surfaces` / `Get-ConfigRootSurface` derive from `config["shared_surfaces"]`.

Command (Python):

```
poetry run python -c "from scripts.dev_tools._blast_radius_extraction import classify_path_token; rs=('package-lock.json','poetry.lock','quality-tiers.yml'); [print(t.ljust(26), '->', repr(classify_path_token(t, root_surfaces=rs))) for t in ['poetry.lock','package-lock.json','quality-tiers.yml','Poetry.Lock','README.md','derive_blast_radius']]"
```

EXIT_CODE: 0

Command (PowerShell):

```
pwsh -NoProfile -Command "Import-Module ./.claude/lib/blast-radius/BlastRadiusExtraction.psm1 -Force; $rs = @('package-lock.json','poetry.lock','quality-tiers.yml'); foreach ($t in @('poetry.lock','package-lock.json','quality-tiers.yml','Poetry.Lock','README.md','derive_blast_radius')) { $k = Get-PathTokenKind -Token $t -RootSurface $rs; ... }"
```

EXIT_CODE: 0

The Python module resolved is
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5c761b8f1a691079\scripts\dev_tools\_blast_radius_extraction.py`
(verified by printing `__file__`), so the run exercised this worktree and not the parent checkout.

## Output Summary

| Token | Python `classify_path_token` | PowerShell `Get-PathTokenKind` | Corresponding | Reason |
| --- | --- | --- | --- | --- |
| `poetry.lock` | `'concrete'` | `'concrete'` | yes | exact ordinal member of the configured set |
| `package-lock.json` | `'concrete'` | `'concrete'` | yes | exact ordinal member of the configured set |
| `quality-tiers.yml` | `'concrete'` | `'concrete'` | yes | exact ordinal member of the configured set |
| `Poetry.Lock` | `None` | `$null` | yes | membership is ordinal and case-sensitive, so the cased variant is not a member |
| `README.md` | `None` | `$null` | yes | separator-free and not a configured surface |
| `derive_blast_radius` | `None` | `$null` | yes | separator-free, not a configured surface, and carries no extension |

Divergences: 0 of 6.

Python `None` and PowerShell `$null` are the corresponding "not a repository path reference"
results, and Python `'concrete'` (`PATH_KIND_CONCRETE`) corresponds to PowerShell `'concrete'`.

Output Summary: the two languages return corresponding results on all six tokens under the same
configured surface set, with zero divergence. Three tokens classify as `concrete` in both
languages because they are exact ordinal members of the configured set; three classify as
`None` / `$null` in both languages, one of them (`Poetry.Lock`) confirming that membership is
ordinal and case-sensitive in both implementations.
