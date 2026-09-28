# Final mirror parity across all 28 module pairs — issue #598

Timestamp: 2026-08-30T02-29
Task: [P10-T7]

Command:
`pwsh -NoProfile -Command "$all = @(Get-ChildItem -Path '.claude/lib' -Filter '*.psm1' -File -Recurse); $bad = @(); foreach ($f in $all) { $rel = $f.FullName.Substring((Get-Location).Path.Length + 1).Replace('\', '/'); $mir = 'extensions/drm-copilot/resources/claude-customizations/' + $rel; if (-not (Test-Path -LiteralPath $mir)) { $bad += $rel } elseif ((Get-Content -Raw -LiteralPath $f.FullName) -ne (Get-Content -Raw -LiteralPath $mir)) { $bad += $rel } }; 'DISCOVERED={0} MISMATCHED={1}' -f $all.Count, $bad.Count; $bad"`

EXIT_CODE: 0

Output Summary:

The command printed exactly one line and nothing followed it:

```
DISCOVERED=28 MISMATCHED=0
```

No path was printed after the counts line, because `$bad` is empty.

## What the check establishes

The check is independent of the pytest bundle-parity gate in `[P10-T6]`. It discovers `.psm1` files
from disk under `.claude/lib`, derives each one's mirror path by prefixing
`extensions/drm-copilot/resources/claude-customizations/`, and compares full file contents with
`Get-Content -Raw`. A missing mirror and a differing mirror both increment the mismatch count.

`DISCOVERED=28` is asserted alongside `MISMATCHED=0` deliberately. A mismatch count of `0` is also
what an empty discovery set prints, so the mismatch count alone could not fail on a run that found
no modules. Requiring the discovered count to be 28 makes the condition sensitive to a discovery
failure as well as to a mirror divergence.

The discovered count of 28 matches the module count recorded by `[P0-T13]` and the
`TOTAL=28 GUARDED=28 UNGUARDED=0` line recorded by `[P7-T9]` in
`evidence/qa-gates/rollout-complete.2026-08-30T00-38.md`.

## Acceptance evaluation

- The printed line is exactly `DISCOVERED=28 MISMATCHED=0`.
- No path follows it.

Both acceptance conditions hold. Every one of the 28 repository modules is byte-identical to its
bundle mirror, which is the cross-cutting mirror requirement in `spec.md`.
