/**
 * Unit tests for `src/lib/new-active-feature-folder/io.ts`.
 *
 * Hermetic: uses a `Map`-backed `FolderFileSystem` fake, a fake `CommandRunner`,
 * and injected `gh`/env/which lookups. No real subprocess, PATH, or env. AAA;
 * one behavior per test.
 */

import { describe, expect, it } from "@jest/globals";

import {
  buildFolderSlug,
  copyFeatureTemplateForMinorAudit,
  copyTemplate,
  defaultIssueFetcher,
  defaultCodeLauncher,
  findPotentialFile,
  isInsidersSession,
  materializePlanFile,
  parseIssueNumber,
  resolveCodeCli,
} from "../../../src/lib/new-active-feature-folder/io";
import { PLAN_TIMESTAMP_TEMPLATE_NAME } from "../../../src/lib/new-active-feature-folder/models";
import { FakeCommandRunner, FakeFolderFileSystem } from "./fakes";

describe("findPotentialFile", () => {
  it("matches by normalized name in potential, excluding template/README and non-md", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    const dir = "/ws/docs/features/potential";
    fs.seed(`${dir}/notes-feature.md`, "x");
    fs.seed(`${dir}/template.md`, "x");
    fs.seed(`${dir}/README.md`, "x");
    fs.seed(`${dir}/notes-feature.txt`, "x");

    // Act: underscore in the feature name is normalized to a dash before match.
    const result = findPotentialFile("notes_feature", "/ws", fs);

    // Assert
    expect(result).toBe(`${dir}/notes-feature.md`);
  });

  it("falls back to the promoted directory when potential has no match", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    const promoted = "/ws/docs/features/potential/promoted";
    fs.seed(`${promoted}/notes-feature-240.md`, "x");

    // Act
    const result = findPotentialFile("notes-feature", "/ws", fs);

    // Assert
    expect(result).toBe(`${promoted}/notes-feature-240.md`);
  });

  it("returns the name-descending winner", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    const dir = "/ws/docs/features/potential";
    fs.seed(`${dir}/notes-1.md`, "x");
    fs.seed(`${dir}/notes-2.md`, "x");

    // Act
    const result = findPotentialFile("notes", "/ws", fs);

    // Assert: "notes-2.md" sorts after "notes-1.md" descending.
    expect(result).toBe(`${dir}/notes-2.md`);
  });

  it("returns null when no file matches", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();

    // Act
    const result = findPotentialFile("absent", "/ws", fs);

    // Assert
    expect(result).toBeNull();
  });
});

describe("parseIssueNumber", () => {
  it("parses a `- Issue: #123` line", () => {
    // Arrange / Act / Assert
    expect(parseIssueNumber("intro\n- Issue: #123\n")).toBe("123");
  });

  it("returns null when no Issue line is present", () => {
    // Arrange / Act / Assert
    expect(parseIssueNumber("no issue here")).toBeNull();
  });
});

describe("buildFolderSlug", () => {
  it("normalizes underscores when no potential file is present", () => {
    // Arrange / Act / Assert
    expect(buildFolderSlug("notes_feature", null, null)).toBe("notes-feature");
  });

  it("prefers the potential-file stem", () => {
    // Arrange / Act / Assert
    expect(
      buildFolderSlug(
        "ignored",
        "/ws/docs/features/potential/notes-240.md",
        null,
      ),
    ).toBe("notes-240");
  });

  it("appends the issue number when not already a suffix", () => {
    // Arrange / Act / Assert
    expect(buildFolderSlug("notes", null, "240")).toBe("notes-240");
    expect(buildFolderSlug("notes-240", null, "240")).toBe("notes-240");
  });

  it("throws the byte-identical message for an invalid slug", () => {
    // Arrange / Act / Assert
    expect(() => buildFolderSlug("Bad Slug", null, null)).toThrow(
      "Aborted: 'Bad Slug' is invalid. Use kebab/underscore-case letters/numbers (e.g., notes-feature or notes_feature).",
    );
  });
});

describe("copyTemplate", () => {
  it("for bug copies spec.md and the timestamped plan and breaks before plan.md", () => {
    // Arrange: template dir has spec.md, the timestamped plan, AND legacy plan.md.
    const fs = new FakeFolderFileSystem();
    const tpl = "/ws/templates/bug";
    fs.seed(`${tpl}/spec.md`, "spec");
    fs.seed(`${tpl}/${PLAN_TIMESTAMP_TEMPLATE_NAME}`, "plan-ts");
    fs.seed(`${tpl}/plan.md`, "legacy");

    // Act
    copyTemplate("bug", tpl, "/ws/out", fs);

    // Assert: spec.md and the timestamped plan are copied; legacy plan.md is not.
    expect(fs.files.has("/ws/out/spec.md")).toBe(true);
    expect(fs.files.has(`/ws/out/${PLAN_TIMESTAMP_TEMPLATE_NAME}`)).toBe(true);
    expect(fs.files.has("/ws/out/plan.md")).toBe(false);
  });

  it("for bug copies plan.md only when the timestamped template is absent", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    const tpl = "/ws/templates/bug";
    fs.seed(`${tpl}/spec.md`, "spec");
    fs.seed(`${tpl}/plan.md`, "legacy");

    // Act
    copyTemplate("bug", tpl, "/ws/out", fs);

    // Assert
    expect(fs.files.has("/ws/out/plan.md")).toBe(true);
  });

  it("for non-bug types copies the whole tree", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    const tpl = "/ws/templates/feature";
    fs.seed(`${tpl}/spec.md`, "spec");
    fs.seed(`${tpl}/nested/user-story.md`, "us");

    // Act
    copyTemplate("feature", tpl, "/ws/out", fs);

    // Assert
    expect(fs.files.has("/ws/out/spec.md")).toBe(true);
    expect(fs.files.has("/ws/out/nested/user-story.md")).toBe(true);
  });
});

describe("copyFeatureTemplateForMinorAudit", () => {
  it("prefers the timestamped plan then falls back to plan.md", () => {
    // Arrange
    const fsTs = new FakeFolderFileSystem();
    const tpl = "/ws/templates/feature";
    fsTs.seed(`${tpl}/${PLAN_TIMESTAMP_TEMPLATE_NAME}`, "plan-ts");
    fsTs.seed(`${tpl}/plan.md`, "legacy");

    const fsLegacy = new FakeFolderFileSystem();
    fsLegacy.seed(`${tpl}/plan.md`, "legacy");

    // Act
    copyFeatureTemplateForMinorAudit(tpl, "/ws/out", fsTs);
    copyFeatureTemplateForMinorAudit(tpl, "/ws/out", fsLegacy);

    // Assert
    expect(fsTs.files.has(`/ws/out/${PLAN_TIMESTAMP_TEMPLATE_NAME}`)).toBe(
      true,
    );
    expect(fsTs.files.has("/ws/out/plan.md")).toBe(false);
    expect(fsLegacy.files.has("/ws/out/plan.md")).toBe(true);
  });
});

describe("materializePlanFile", () => {
  it("moves and stamps the timestamped template, applying the header", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    const target = "/ws/out";
    fs.seed(
      `${target}/${PLAN_TIMESTAMP_TEMPLATE_NAME}`,
      "# <feature-name>\n- Last Updated: <yyyy-MM-ddTHH-mm>\n",
    );

    // Act
    const result = materializePlanFile(
      "feature",
      target,
      "notes-feature",
      "#123",
      "octocat",
      "none",
      "Draft",
      "0.1",
      "2026-03-14T15-48",
      fs,
    );

    // Assert: moved to plan.<ts>.md and the header was stamped with the timestamp.
    expect(result).toBe(`${target}/plan.2026-03-14T15-48.md`);
    const content = fs.files.get(`${target}/plan.2026-03-14T15-48.md`) ?? "";
    expect(content).toContain("# notes-feature");
    expect(content).toContain("- Last Updated: 2026-03-14T15-48");
  });

  it("returns the legacy plan.md when only it exists", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    fs.seed("/ws/out/plan.md", "legacy");

    // Act
    const result = materializePlanFile(
      "feature",
      "/ws/out",
      "n",
      "#1",
      "o",
      "none",
      "Draft",
      "0.1",
      "2026-03-14T15-48",
      fs,
    );

    // Assert
    expect(result).toBe("/ws/out/plan.md");
  });

  it("returns null when no plan template exists", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();

    // Act
    const result = materializePlanFile(
      "feature",
      "/ws/out",
      "n",
      "#1",
      "o",
      "none",
      "Draft",
      "0.1",
      "2026-03-14T15-48",
      fs,
    );

    // Assert
    expect(result).toBeNull();
  });
});

describe("defaultIssueFetcher", () => {
  it("returns null when gh is not on PATH", () => {
    // Arrange
    const runner = new FakeCommandRunner();

    // Act
    const result = defaultIssueFetcher("123", runner, () => null);

    // Assert
    expect(result).toBeNull();
    expect(runner.calls).toHaveLength(0);
  });

  it("returns null on a non-zero exit", () => {
    // Arrange
    const runner = new FakeCommandRunner([
      { stdout: "", stderr: "boom", code: 1 },
    ]);

    // Act
    const result = defaultIssueFetcher("123", runner, () => "/usr/bin/gh");

    // Assert
    expect(result).toBeNull();
  });

  it("returns null on blank stdout", () => {
    // Arrange
    const runner = new FakeCommandRunner([
      { stdout: "   ", stderr: "", code: 0 },
    ]);

    // Act / Assert
    expect(defaultIssueFetcher("123", runner, () => "/usr/bin/gh")).toBeNull();
  });

  it("returns null on invalid JSON", () => {
    // Arrange
    const runner = new FakeCommandRunner([
      { stdout: "not json", stderr: "", code: 0 },
    ]);

    // Act / Assert
    expect(defaultIssueFetcher("123", runner, () => "/usr/bin/gh")).toBeNull();
  });

  it("builds IssueMeta with the gh json field list", () => {
    // Arrange
    const runner = new FakeCommandRunner([
      {
        stdout: JSON.stringify({
          number: 240,
          author: { login: "octocat" },
          updatedAt: "2026-03-14T09:00:00Z",
        }),
        stderr: "",
        code: 0,
      },
    ]);

    // Act
    const result = defaultIssueFetcher("240", runner, () => "/usr/bin/gh");

    // Assert
    expect(result).toEqual({
      number: "240",
      author: "octocat",
      updatedDate: "2026-03-14",
    });
    expect(runner.calls[0]).toEqual([
      "/usr/bin/gh",
      "issue",
      "view",
      "240",
      "--json",
      "number,title,url,author,updatedAt",
    ]);
  });

  it("falls back to name and YYYY-MM-DD when fields are missing", () => {
    // Arrange
    const runner = new FakeCommandRunner([
      { stdout: JSON.stringify({}), stderr: "", code: 0 },
    ]);

    // Act
    const result = defaultIssueFetcher("240", runner, () => "/usr/bin/gh");

    // Assert
    expect(result).toEqual({
      number: "240",
      author: "name",
      updatedDate: "YYYY-MM-DD",
    });
  });
});

describe("launcher seam", () => {
  it("isInsidersSession is true when a signal value contains 'insider'", () => {
    // Arrange / Act / Assert
    expect(
      isInsidersSession((name) =>
        name === "TERM_PROGRAM" ? "vscode-insiders" : undefined,
      ),
    ).toBe(true);
    expect(isInsidersSession(() => undefined)).toBe(false);
  });

  it("resolveCodeCli prefers code-insiders in an Insiders session", () => {
    // Arrange: env signals Insiders; both CLIs resolve.
    const cli = resolveCodeCli(
      (name) => (name === "code-insiders" ? "/bin/code-insiders" : "/bin/code"),
      () => "insiders",
    );

    // Assert
    expect(cli).toBe("/bin/code-insiders");
  });

  it("resolveCodeCli prefers code in a non-Insiders session", () => {
    // Arrange
    const cli = resolveCodeCli(
      (name) => (name === "code" ? "/bin/code" : "/bin/code-insiders"),
      () => undefined,
    );

    // Assert
    expect(cli).toBe("/bin/code");
  });

  it("defaultCodeLauncher returns false when no CLI resolves", () => {
    // Arrange
    const runner = new FakeCommandRunner();

    // Act
    const result = defaultCodeLauncher(["/ws/a.md"], {
      runner,
      whichLookup: () => undefined,
      envLookup: () => undefined,
    });

    // Assert
    expect(result).toBe(false);
    expect(runner.calls).toHaveLength(0);
  });

  it("defaultCodeLauncher runs --reuse-window with posix paths when a CLI resolves", () => {
    // Arrange
    const runner = new FakeCommandRunner([{ stdout: "", stderr: "", code: 0 }]);

    // Act
    const result = defaultCodeLauncher(["C:\\ws\\a.md"], {
      runner,
      whichLookup: (name) => (name === "code" ? "/bin/code" : undefined),
      envLookup: () => undefined,
    });

    // Assert
    expect(result).toBe(true);
    expect(runner.calls[0]).toEqual([
      "/bin/code",
      "--reuse-window",
      "C:/ws/a.md",
    ]);
  });
});
