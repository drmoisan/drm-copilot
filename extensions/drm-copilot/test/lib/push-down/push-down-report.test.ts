/**
 * Unit tests for the push-down report builder and conflict lines (issue #1029).
 */

import { EXCLUSION_CONFLICT_LINE_PREFIX } from "../../../src/lib/push-down/claude-exclusion-filter";
import { type PushDownAction } from "../../../src/lib/push-down/push-down-plan-comparator";
import {
  buildPushDownReport,
  PUSH_DOWN_CONFLICT_LINE_PREFIX,
  type PushDownReportFile,
  renderPushDownConflictLines,
} from "../../../src/lib/push-down/push-down-report";

/** Build a reported file with a fixed layer, pack, and reason. */
function file(path: string, action: PushDownAction): PushDownReportFile {
  return {
    path,
    layer: "shared",
    pack: "core",
    action,
    reason: `why ${action}`,
  };
}

describe("buildPushDownReport", () => {
  it("sorts files by path and counts each occurring action", () => {
    const report = buildPushDownReport({
      mode: "dry-run",
      ecosystems: { codex: { packs: ["core"] } },
      files: [
        file("z.md", "create"),
        file("B.md", "merge"),
        file("a.md", "create"),
        file(".x/y.md", "excluded"),
      ],
    });
    expect(report.files.map((entry) => entry.path)).toEqual([
      ".x/y.md",
      "B.md",
      "a.md",
      "z.md",
    ]);
    expect(report.counts).toEqual({ create: 2, merge: 1, excluded: 1 });
    expect(report.mode).toBe("dry-run");
    expect(report.ecosystems).toEqual({ codex: { packs: ["core"] } });
  });

  it("renders path, layer, pack, action and reason for each file", () => {
    const report = buildPushDownReport({
      mode: "apply",
      ecosystems: {},
      files: [
        {
          path: "AGENTS.md",
          layer: "shared",
          pack: "core",
          action: "unchanged",
          reason: "r",
        },
      ],
    });
    expect(report.files).toEqual([
      {
        path: "AGENTS.md",
        layer: "shared",
        pack: "core",
        action: "unchanged",
        reason: "r",
      },
    ]);
    expect(report.counts).toEqual({ unchanged: 1 });
  });

  it.each([["/abs/a.md"], ["C:/repo/a.md"], ["dir\\a.md"], ["dir/../a.md"]])(
    "rejects a report path that is absolute or not POSIX (%s)",
    (path) => {
      expect(() =>
        buildPushDownReport({
          mode: "apply",
          ecosystems: {},
          files: [file(path, "create")],
        }),
      ).toThrow("Invalid push-down report path");
    },
  );

  it("rejects a path reported twice", () => {
    expect(() =>
      buildPushDownReport({
        mode: "apply",
        ecosystems: {},
        files: [file("a.md", "create"), file("a.md", "merge")],
      }),
    ).toThrow("reported twice");
  });
});

describe("renderPushDownConflictLines", () => {
  it("renders conflict, unmanaged-conflict and deleted-locally lines", () => {
    const report = buildPushDownReport({
      mode: "apply",
      ecosystems: {},
      files: [
        file("a.md", "conflict"),
        file("b.md", "unmanaged-conflict"),
        file("c.md", "deleted-locally"),
        file("d.md", "create"),
        file("e.md", "orphaned"),
        file("f.md", "excluded"),
      ],
    });
    expect(renderPushDownConflictLines(report)).toEqual([
      "push-down conflict: conflict a.md (layer shared, pack core): why conflict",
      "push-down conflict: unmanaged-conflict b.md (layer shared, pack core): why unmanaged-conflict",
      "push-down conflict: deleted-locally c.md (layer shared, pack core): why deleted-locally",
    ]);
  });

  it("renders conflict lines with a prefix distinct from the exclusion prefix", () => {
    expect(PUSH_DOWN_CONFLICT_LINE_PREFIX).toBe("push-down conflict:");
    expect(
      PUSH_DOWN_CONFLICT_LINE_PREFIX.startsWith(EXCLUSION_CONFLICT_LINE_PREFIX),
    ).toBe(false);
    expect(
      EXCLUSION_CONFLICT_LINE_PREFIX.startsWith(PUSH_DOWN_CONFLICT_LINE_PREFIX),
    ).toBe(false);
  });

  it("renders no line when nothing conflicts", () => {
    const report = buildPushDownReport({
      mode: "apply",
      ecosystems: {},
      files: [file("a.md", "unchanged")],
    });
    expect(renderPushDownConflictLines(report)).toEqual([]);
  });
});
