Timestamp: 2026-04-12T00:03:21-04:00
Command:
```powershell
@'
const fs = require("node:fs");

const [inventoryPath, lcovPath] = process.argv.slice(2);
if (!inventoryPath || !lcovPath) {
  throw new Error("Usage: node - <inventoryPath> <lcovPath>");
}

const inventoryMarkdown = fs.readFileSync(inventoryPath, "utf8");
const inventoryMatch = inventoryMarkdown.match(/```json\s*([\s\S]*?)\s*```/);
if (!inventoryMatch) {
  throw new Error("Changed line inventory JSON block was not found.");
}

const inventory = JSON.parse(inventoryMatch[1]);
const lcovText = fs.readFileSync(lcovPath, "utf8");
const coverageByFile = new Map();
let currentFile = null;
for (const rawLine of lcovText.split(/\r?\n/)) {
  if (rawLine.startsWith("SF:")) {
    currentFile = rawLine.slice(3).replace(/\\/g, "/");
    coverageByFile.set(currentFile, new Map());
    continue;
  }
  if (rawLine.startsWith("DA:") && currentFile) {
    const [lineNumberText, hitCountText] = rawLine.slice(3).split(",");
    coverageByFile.get(currentFile).set(Number(lineNumberText), Number(hitCountText));
  }
}

function normalizeInventoryFile(filePath) {
  return filePath.replace(/\\/g, "/").replace(/^extensions\/drm-copilot\//, "");
}

function expandRanges(ranges) {
  const lines = [];
  for (const range of ranges) {
    const [startText, endText] = String(range).split("-");
    const start = Number(startText);
    const end = endText === undefined ? start : Number(endText);
    for (let line = start; line <= end; line += 1) {
      lines.push(line);
    }
  }
  return lines;
}

const files = inventory.map((entry) => {
  const normalizedFile = normalizeInventoryFile(entry.file);
  const fileCoverage = coverageByFile.get(normalizedFile);
  const changedLines = expandRanges(entry.changed_line_ranges);
  const coveredLines = [];
  const uncoveredLines = [];
  const unmatchedLines = [];

  for (const line of changedLines) {
    if (!fileCoverage || !fileCoverage.has(line)) {
      unmatchedLines.push(line);
      continue;
    }
    if ((fileCoverage.get(line) ?? 0) > 0) {
      coveredLines.push(line);
    } else {
      uncoveredLines.push(line);
    }
  }

  const disposition = unmatchedLines.length === 0 && uncoveredLines.length === 0 ? "PASS" : "FAIL";
  return {
    file: entry.file,
    lcov_file: normalizedFile,
    changed_line_ranges: entry.changed_line_ranges,
    changed_line_count: changedLines.length,
    covered_line_count: coveredLines.length,
    uncovered_line_count: uncoveredLines.length,
    unmatched_line_count: unmatchedLines.length,
    uncovered_lines: uncoveredLines,
    unmatched_lines: unmatchedLines,
    disposition,
  };
});

const totals = files.reduce(
  (accumulator, file) => {
    accumulator.changed_line_count += file.changed_line_count;
    accumulator.covered_line_count += file.covered_line_count;
    accumulator.uncovered_line_count += file.uncovered_line_count;
    accumulator.unmatched_line_count += file.unmatched_line_count;
    return accumulator;
  },
  {
    changed_line_count: 0,
    covered_line_count: 0,
    uncovered_line_count: 0,
    unmatched_line_count: 0,
  },
);

const aggregateDisposition =
  totals.uncovered_line_count === 0 && totals.unmatched_line_count === 0 ? "PASS" : "FAIL";

console.log(
  JSON.stringify(
    {
      timestamp: new Date().toISOString(),
      files,
      totals,
      aggregate_disposition: aggregateDisposition,
    },
    null,
    2,
  ),
);
'@ | node - "C:/Users/DanMoisan/repos/drm-copilot/docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/other/ts-changed-line-inventory.2026-04-11T22-54.md" "coverage/lcov.info"
```
EXIT_CODE: 0
Output Summary:
- Aggregate changed-line coverage disposition: `PASS`.
- Changed-line totals: `213/213` covered, `0` uncovered, `0` unmatched to `lcov.info`.
- The proof used the refreshed executable inventory from `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/other/ts-changed-line-inventory.2026-04-11T22-54.md`.

Per-File Coverage Proof:
- `extensions/drm-copilot/src/extension.ts`
  - Changed lines: `7`, `18`, `225-233`, `410-416`, `437`
  - Covered changed lines: `19/19`
  - Uncovered changed lines: `none`
  - Unmatched changed lines: `none`
  - Disposition: `PASS`
- `extensions/drm-copilot/src/mcp-tool-inputs.ts`
  - Changed lines: `2`, `8`, `11`, `41-45`, `246-268`
  - Covered changed lines: `31/31`
  - Uncovered changed lines: `none`
  - Unmatched changed lines: `none`
  - Disposition: `PASS`
- `extensions/drm-copilot/src/mcp-tools.ts`
  - Changed lines: `14`, `16`, `40-42`, `303-326`, `404-410`
  - Covered changed lines: `36/36`
  - Uncovered changed lines: `none`
  - Unmatched changed lines: `none`
  - Disposition: `PASS`
- `extensions/drm-copilot/src/repo-automation-service.ts`
  - Changed lines: `7-17`, `36`, `48-50`, `112-117`, `323`, `330`, `337`, `344`, `351`, `354-370`, `372-374`, `376-386`, `403-440`, `466`
  - Covered changed lines: `96/96`
  - Uncovered changed lines: `none`
  - Unmatched changed lines: `none`
  - Disposition: `PASS`
- `extensions/drm-copilot/src/workflow-command-arguments.ts`
  - Changed lines: `1-2`, `34-37`, `41-42`, `71-74`, `159-163`, `168-169`, `258-269`
  - Covered changed lines: `31/31`
  - Uncovered changed lines: `none`
  - Unmatched changed lines: `none`
  - Disposition: `PASS`
