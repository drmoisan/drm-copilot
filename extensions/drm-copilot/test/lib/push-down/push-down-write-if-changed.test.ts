/**
 * Unit tests for the write-if-changed push-down decorator (issue #1029).
 */

import { WriteIfChangedFileSystem } from "../../../src/lib/push-down/push-down-write-if-changed";
import { buildInMemoryFileSystem } from "./push-down.test-helpers";

describe("WriteIfChangedFileSystem", () => {
  it("skips a write whose LF-normalized text is unchanged", () => {
    const inner = buildInMemoryFileSystem({
      "/dest/a.md": ["one", "two", ""].join("\r\n"),
    });
    const fs = new WriteIfChangedFileSystem(inner);

    fs.writeTextFile("/dest/a.md", "one\ntwo\n");

    expect(inner.writtenPaths).toEqual([]);
    expect(fs.skippedPaths).toEqual(["/dest/a.md"]);
    expect(fs.writtenPaths).toEqual([]);
  });

  it("writes when the text differs", () => {
    const inner = buildInMemoryFileSystem({ "/dest/a.md": "old\n" });
    const fs = new WriteIfChangedFileSystem(inner);

    fs.writeTextFile("/dest/a.md", "new\n");

    expect(inner.readTextFile("/dest/a.md")).toBe("new\n");
    expect(fs.writtenPaths).toEqual(["/dest/a.md"]);
    expect(fs.skippedPaths).toEqual([]);
  });

  it("writes when the file is absent", () => {
    const inner = buildInMemoryFileSystem({}, ["/dest"]);
    const fs = new WriteIfChangedFileSystem(inner);

    fs.writeTextFile("/dest/b.md", "text");

    expect(inner.writtenPaths).toEqual(["/dest/b.md"]);
  });

  it("delegates every other method to the inner adapter", () => {
    const inner = buildInMemoryFileSystem({ "/src/x/a.md": "a" });
    const fs = new WriteIfChangedFileSystem(inner);

    fs.ensureDir("/dest/sub");

    expect(fs.listFiles("/src/x")).toEqual(["/src/x/a.md"]);
    expect(fs.isDir("/src/x")).toBe(true);
    expect(fs.isFile("/src/x/a.md")).toBe(true);
    expect(fs.readTextFile("/src/x/a.md")).toBe("a");
    expect(inner.ensuredDirs).toEqual(["/dest/sub"]);
  });
});
