# P9-T3 Bundled Copy Byte-Identical Verification — Evidence

**Timestamp:** 2026-04-26T15:41:31Z

---

## Command

```
python -c "import hashlib; sums={f: hashlib.sha256(open(f,'rb').read()).hexdigest() for f in ['scripts/dev_tools/push_down_claude_customizations.py','extensions/drm-copilot/resources/templates/push_down_claude_customizations.py','extensions/drm-copilot/resources/scripts/dev_tools/push_down_claude_customizations.py']}; print(sums); assert len(set(sums.values()))==1, sums; print('ALL IDENTICAL')"
```

**EXIT_CODE:** 0

## Output Summary

All three copies are byte-identical with SHA-256 hash:

```
01ee635e32c35093040a09db319686974258c40891b46f3d76c32b8684a3d72a
```

| Path | SHA-256 |
|------|---------|
| `scripts/dev_tools/push_down_claude_customizations.py` | `01ee635e…3d72a` |
| `extensions/drm-copilot/resources/templates/push_down_claude_customizations.py` | `01ee635e…3d72a` |
| `extensions/drm-copilot/resources/scripts/dev_tools/push_down_claude_customizations.py` | `01ee635e…3d72a` |

**Assertion:** `len(set(sums.values())) == 1` → `True`. All copies are byte-identical.
