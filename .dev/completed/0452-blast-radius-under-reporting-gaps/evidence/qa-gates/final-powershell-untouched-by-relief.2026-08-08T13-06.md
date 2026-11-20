# PowerShell and bundled mirror untouched by the second structural relief ([P11-T20])

Timestamp: 2026-08-08T13-06

Command:
```
git diff --stat .claude/lib/blast-radius/
git diff --stat extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/
git diff --no-index --stat .claude/lib/blast-radius extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius
wc -l .claude/lib/blast-radius/*.psm1
grep -n "Get-ConfigOverBreadthFraction" .claude/lib/blast-radius/BlastRadiusConfig.psm1
```

EXIT_CODE: 0

## Output Summary

The second structural relief is PYTHON-ONLY. No `.claude/lib/blast-radius/*.psm1`
file and no file under
`extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/`
differs from its state at [P11-T7].

### No `.psm1` file changed

`git diff --stat .claude/lib/blast-radius/` reports the identical hunk counts
before and after the relief:

```
 .claude/lib/blast-radius/BlastRadius.psm1          | 10 ++-
 .claude/lib/blast-radius/BlastRadiusConfig.psm1    | 53 +++++++++++++
 .../lib/blast-radius/BlastRadiusExtraction.psm1    | 89 ++++++++++++----------
 .claude/lib/blast-radius/BlastRadiusGlob.psm1      | 76 ++++++++++++++++--
 .../lib/blast-radius/BlastRadiusValidation.psm1    |  7 +-
 5 files changed, 183 insertions(+), 52 deletions(-)
```

Those 183 insertions and 52 deletions are entirely the work of Phases 2, 4, 5,
and 7, all completed before [P11-T7]. The relief added none of them. Line counts
are likewise unchanged from the [P11-T7] measurement: `BlastRadius.psm1` 379,
`BlastRadiusConfig.psm1` 491, `BlastRadiusExtraction.psm1` 490,
`BlastRadiusGlob.psm1` 429, `BlastRadiusValidation.psm1` 366.

### Bundled mirror still byte-identical

`git diff --stat` over the bundled directory reports the same five files with the
same 183 / 52 counts, and
`git diff --no-index .claude/lib/blast-radius extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius`
produces NO output and exits 0, so every repo module and its bundled counterpart
are byte-identical including line endings. The relief required no mirror
re-copy because it edited no `.psm1` file.

### `Get-ConfigOverBreadthFraction` keeps name, signature, exports, and behaviour

| Property | Value | Changed by the relief? |
| --- | --- | --- |
| Name | `Get-ConfigOverBreadthFraction` (`BlastRadiusConfig.psm1:333`) | NO |
| Attributes | `[CmdletBinding()]`, `[OutputType([double])]` | NO |
| Parameter | `[Parameter(Mandatory = $true)] [AllowNull()] [object] $Config` | NO |
| Export | listed in `Export-ModuleMember` (`BlastRadiusConfig.psm1:489`) | NO |
| Behaviour | rejects `$null`, booleans, and non-numeric types with `config["over_breadth_fraction"] must be a number in (0, 1].`; rejects out-of-range values with `config["over_breadth_fraction"] must be within (0, 1].`; otherwise returns `[double]$value` | NO |

The two implementations remain behaviourally byte-equivalent. The Python side's
guard order, boolean rejection, half-open `(0, 1]` range test, and both message
strings are unchanged by the relief — the function body was relocated verbatim,
character-for-character, from `_blast_radius_validation.py:263-286` into
`_blast_radius_thresholds.py`. Which Python FILE hosts the reader is an internal
Python file-organization detail with no PowerShell counterpart obligation.
Structural asymmetry between the two languages is already established by this
plan: Phase 1 created `_blast_radius_glob.py` in Python while Phase 2 created no
`.psm1` module, and Hard Constraint "no new `.psm1` module" (checked at
[P2-T9], `spec.md` line 661) makes a symmetric PowerShell split prohibited
rather than merely unnecessary.

### Deliberate decision: the `.DESCRIPTION` attribution comment is left unedited

`.claude/lib/blast-radius/BlastRadiusConfig.psm1:6-9` reads:

```
    Destination-runtime PowerShell port of the guard and truth-table half of
    scripts/dev_tools/_blast_radius_validation.py (require_text,
    require_str_tuple, require_mapping, config_string_list, config_modules,
    config_over_breadth_fraction, resolve_modules, resolve_shared_surfaces). The
```

After the relief, `config_over_breadth_fraction` lives in
`scripts/dev_tools/_blast_radius_thresholds.py` rather than
`scripts/dev_tools/_blast_radius_validation.py`, so this attribution line is now
one file-name stale for one of the eight symbols it lists. It was left unedited
DELIBERATELY, and the decision is recorded here rather than left implicit:

1. A documentation-only `.psm1` change would force a byte-for-byte mirror
   re-copy under Hard Constraint 5 and a full PowerShell toolchain re-run
   (`run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`), invalidating
   the current [P11-T6] and [P11-T7] records for no behavioural gain.
2. `BlastRadiusConfig.psm1` is 491 lines. Any edit pushes that file closer to the
   500-line limit that this very relief exists to satisfy elsewhere.
3. The comment remains accurate about what the module PORTS — the same eight
   behaviours — and the new Python module's own docstring names
   `Get-ConfigOverBreadthFraction` in `.claude/lib/blast-radius/BlastRadiusConfig.psm1`
   as its PowerShell mirror, so the cross-reference is discoverable from the
   Python side.

### Consequence for the [P11-T6] and [P11-T7] records

Because the relief changed no PowerShell file, the [P11-T6] PSScriptAnalyzer
result (zero findings at every severity) and the [P11-T7] Pester result remain
CURRENT and require no re-run. Only the Python half of the [P11-T8] clean-pass
record is superseded, by [P11-T17].
