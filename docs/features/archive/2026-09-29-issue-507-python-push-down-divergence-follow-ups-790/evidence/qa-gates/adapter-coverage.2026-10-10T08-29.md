# Final QC Adapter Per-File Coverage (P6-T12)

Timestamp: 2026-10-10T08-29
Command: poetry run python -c "import pathlib, re; t = pathlib.Path('extensions/drm-copilot/coverage/lcov.info').read_text(encoding='utf-8').replace(chr(92), '/').replace(chr(13), ''); b = [x for x in t.split('end_of_record') if re.search(r'^SF:.*src/lib/push-down/claude-filesystem-adapter[.]ts$', x, re.M)]; v = {k: int(n) for k, n in re.findall(r'^(LF|LH|BRF|BRH):([0-9]+)$', b[0], re.M)}; print('BLOCKS', len(b), 'LINES', round(100 * v['LH'] / v['LF'], 2), 'BRANCHES', round(100 * v['BRH'] / v['BRF'], 2) if v['BRF'] else 'NO_BRANCHES')"
EXIT_CODE: 0
Output Summary:
- Loop iteration: 1.
- Printed `BLOCKS 1 LINES 96.99 BRANCHES 89.55`.
- FINAL_ADAPTER_LINES = 96.99 (>= 85).
- FINAL_ADAPTER_BRANCHES = 89.55 (>= 75).
- Source: the LCOV report written by P6-T11 in this loop iteration.
