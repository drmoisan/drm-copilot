Timestamp: 2026-04-11T23:43:45-04:00
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
- Aggregate changed-line coverage disposition: `FAIL`.
- Changed-line totals: `213/263` covered, `15` uncovered, `35` unmatched to `lcov.info`.
- Per-file proof disposition:
  - `extensions/drm-copilot/src/mcp-tool-inputs.ts`: `FAIL` with uncovered lines `240, 241, 242, 243, 244, 245`
  - `extensions/drm-copilot/src/mcp-tools.ts`: `FAIL` with unmatched lines `525-531`
  - `extensions/drm-copilot/src/workflow-command-arguments.ts`: `FAIL` with uncovered lines `75, 164, 165, 166, 167, 254, 255, 256, 257` and unmatched lines `571-598`
- Delta from `P0-T2`: none. The serial baseline proof reproduces the same unresolved file set and line inventory recorded in the current failing evidence.
