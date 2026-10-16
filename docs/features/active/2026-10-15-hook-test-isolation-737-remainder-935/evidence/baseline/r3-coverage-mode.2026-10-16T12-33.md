# R3 Coverage Mode Check and CI Quotation (P0-T5)

Timestamp: 2026-10-16T12-33
Command: (a) grep -c -F -e 'UseBreakpoints' scripts/powershell/PoshQC/settings/pester.runsettings.psd1; (b) Glob `*/resources/powershell/PoshQC/settings/pester.runsettings.psd1` under the user-profile folders `.vscode/extensions` and `.vscode-insiders/extensions`, then grep -c -F -e 'UseBreakpoints' on each match
EXIT_CODE: 0
Output Summary:
- (a) Repository runsettings `UseBreakpoints` count: 0 (grep exit 1 = no match; count 0 as expected). Pester stays on its 5.x default breakpoint coverage.
- (b) Installed extension copies (extension folder names only):
  - `.vscode/extensions` / `undefined_publisher.drm-copilot-0.0.1`: count 0
  - `.vscode-insiders/extensions` / `undefined_publisher.drm-copilot-0.0.1`: count 0
  - `.vscode-insiders/extensions` / `danmoisan.drm-copilot-1.1.18`: count 0
  - No `INSTALLED-SETTINGS-NOT-BREAKPOINT` condition.
- CI figures (quoted from `remediation-inputs.2026-10-16T11-25.md` and `evidence/baseline/ci-baseline.2026-10-16T00-11.md`; not local measurements):
  - CI run 38890188058 (head `988ed2210`): root LINE 90.17% (covered 16383, missed 1787); `WorktreeResolution.psm1` covered 112 / missed 32.
  - Baseline: 90.42% (`adb9aa5f0`, run 38730332356).
  - Main at `b6be46b5e`: 90.44%; `WorktreeResolution.psm1` covered 142 / missed 2.
