# Baseline Adapter Per-File Coverage (P0-T18)

Timestamp: 2026-10-10T08-05
Command: poetry run python -c "import pathlib, re; t = pathlib.Path('extensions/drm-copilot/coverage/lcov.info').read_text(encoding='utf-8').replace(chr(92), '/').replace(chr(13), ''); b = [x for x in t.split('end_of_record') if re.search(r'^SF:.*src/lib/push-down/claude-filesystem-adapter[.]ts$', x, re.M)]; v = {k: int(n) for k, n in re.findall(r'^(LF|LH|BRF|BRH):([0-9]+)$', b[0], re.M)}; print('BLOCKS', len(b), 'LINES', round(100 * v['LH'] / v['LF'], 2), 'BRANCHES', round(100 * v['BRH'] / v['BRF'], 2) if v['BRF'] else 'NO_BRANCHES')"
EXIT_CODE: 0
Output Summary:
- Printed `BLOCKS 1 LINES 94.39 BRANCHES 83.05`
- BASELINE_ADAPTER_LINES = 94.39
- BASELINE_ADAPTER_BRANCHES = 83.05
- Both values meet the 85% line and 75% branch thresholds; `ADAPTER_BELOW_THRESHOLD_AT_BASELINE` is not recorded, so P6-T11 carries no obligation from this baseline.
- Measured before any jest.config.cjs threshold entry exists for this file.
