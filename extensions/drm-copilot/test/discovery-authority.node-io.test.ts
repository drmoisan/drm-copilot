/**
 * Prove the Node `AuthorityStoreIO` adapter over an injected fake `node:fs`.
 *
 * Every errno path the adapter translates is driven through the fake, so the
 * mapping to `DiscoveryAuthorityError` codes is verified without touching a
 * real filesystem.
 */

import * as path from "node:path";

import {
  type AuthorityFileSystemModule,
  createNodeAuthorityStoreIO,
  DiscoveryAuthorityError,
} from "../src/discovery-authority";

function codeOf(action: () => unknown): string {
  try {
    action();
  } catch (error) {
    if (error instanceof DiscoveryAuthorityError) {
      return error.code;
    }
    throw error;
  }
  return "NO_ERROR";
}

describe("createNodeAuthorityStoreIO", () => {
  interface FakeFs extends AuthorityFileSystemModule {
    readonly calls: string[];
    readonly files: Map<string, string>;
    failWith: {
      read?: string;
      write?: string;
      rename?: string;
      unlink?: string;
      mkdir?: string;
    };
  }

  function errno(code: string): Error {
    const error = new Error(code) as Error & { code: string };
    error.code = code;
    return error;
  }

  function fakeFs(): FakeFs {
    const fake: FakeFs = {
      calls: [],
      files: new Map<string, string>(),
      failWith: {},
      readFileSync(path) {
        fake.calls.push(`read ${path}`);
        if (fake.failWith.read) {
          throw errno(fake.failWith.read);
        }
        const text = fake.files.get(path);
        if (text === undefined) {
          throw errno("ENOENT");
        }
        return text;
      },
      writeFileSync(path, data, options) {
        fake.calls.push(`write ${path} ${options.flag}`);
        if (fake.failWith.write) {
          throw errno(fake.failWith.write);
        }
        if (fake.files.has(path)) {
          throw errno("EEXIST");
        }
        fake.files.set(path, data);
      },
      renameSync(from, to) {
        fake.calls.push(`rename ${from} ${to}`);
        if (fake.failWith.rename) {
          throw errno(fake.failWith.rename);
        }
        fake.files.set(to, fake.files.get(from)!);
        fake.files.delete(from);
      },
      linkSync(from, to) {
        fake.calls.push(`link ${from} ${to}`);
        if (fake.files.has(to)) {
          throw errno("EEXIST");
        }
        fake.files.set(to, fake.files.get(from)!);
      },
      unlinkSync(path) {
        fake.calls.push(`unlink ${path}`);
        if (fake.failWith.unlink) {
          throw errno(fake.failWith.unlink);
        }
        if (!fake.files.delete(path)) {
          throw errno("ENOENT");
        }
      },
      mkdirSync(path) {
        fake.calls.push(`mkdir ${path}`);
        if (fake.failWith.mkdir) {
          throw errno(fake.failWith.mkdir);
        }
        return undefined;
      },
    };
    return fake;
  }

  it("reads text, returns null for absence and reports other read failures", () => {
    const fake = fakeFs();
    const io = createNodeAuthorityStoreIO(fake);
    fake.files.set("/state/activation.json", "{}");
    expect(io.readText("/state/activation.json")).toBe("{}");
    expect(io.readText("/state/missing.json")).toBeNull();
    fake.failWith.read = "EACCES";
    expect(codeOf(() => io.readText("/state/activation.json"))).toBe(
      "AUTHORITY_IO",
    );
  });

  it("creates exclusively with the wx flag and maps EEXIST to AUTHORITY_LOCKED", () => {
    const fake = fakeFs();
    const io = createNodeAuthorityStoreIO(fake);
    io.createExclusive("/state/mutation.lock", "");
    expect(fake.calls).toEqual(["write /state/mutation.lock wx"]);
    expect(codeOf(() => io.createExclusive("/state/mutation.lock", ""))).toBe(
      "AUTHORITY_LOCKED",
    );
    fake.failWith.write = "EPERM";
    expect(codeOf(() => io.createExclusive("/state/other", ""))).toBe(
      "AUTHORITY_IO",
    );
  });

  it("publishes by link for first publication and by rename for replacement", () => {
    const fake = fakeFs();
    const io = createNodeAuthorityStoreIO(fake);
    fake.files.set("/state/.activation-a", "first");
    io.publish("/state/.activation-a", "/state/activation.json", false);
    expect(fake.files.get("/state/activation.json")).toBe("first");
    expect(fake.files.has("/state/.activation-a")).toBe(false);
    fake.files.set("/state/.activation-b", "second");
    expect(
      codeOf(() =>
        io.publish("/state/.activation-b", "/state/activation.json", false),
      ),
    ).toBe("ACTIVATION_CHANGED");
    io.publish("/state/.activation-b", "/state/activation.json", true);
    expect(fake.files.get("/state/activation.json")).toBe("second");
    fake.failWith.rename = "EXDEV";
    fake.files.set("/state/.activation-c", "third");
    expect(
      codeOf(() =>
        io.publish("/state/.activation-c", "/state/activation.json", true),
      ),
    ).toBe("AUTHORITY_IO");
  });

  it("tolerates removing an absent file but reports other failures", () => {
    const fake = fakeFs();
    const io = createNodeAuthorityStoreIO(fake);
    expect(() => io.remove("/state/missing")).not.toThrow();
    fake.failWith.unlink = "EBUSY";
    expect(codeOf(() => io.remove("/state/mutation.lock"))).toBe(
      "AUTHORITY_IO",
    );
  });

  it("creates directories recursively and reports failures", () => {
    const fake = fakeFs();
    const io = createNodeAuthorityStoreIO(fake);
    io.ensureDirectory("/state/workspaces/abc");
    expect(fake.calls).toEqual(["mkdir /state/workspaces/abc"]);
    fake.failWith.mkdir = "EACCES";
    expect(codeOf(() => io.ensureDirectory("/state/workspaces/abc"))).toBe(
      "AUTHORITY_IO",
    );
  });

  it("defaults to node:fs and reports absence for a path that does not exist", () => {
    const io = createNodeAuthorityStoreIO();
    expect(
      io.readText(path.join(__dirname, "does-not-exist", "activation.json")),
    ).toBeNull();
  });

  it("wraps non-Error throwables in the I/O diagnostic", () => {
    const fake = fakeFs();
    fake.mkdirSync = () => {
      throw "string failure";
    };
    const io = createNodeAuthorityStoreIO(fake);
    expect(() => io.ensureDirectory("/state")).toThrow("string failure");
  });
});
