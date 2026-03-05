import { describe, expect, it, jest } from "@jest/globals";

describe("hello-typescript", () => {
  it("logs the expected greeting", () => {
    const logSpy = jest.spyOn(console, "log").mockImplementation(() => {
      // Intentionally empty: suppress test output while verifying call behavior.
    });

    jest.resetModules();
    require("../../src/hello-typescript");

    expect(logSpy).toHaveBeenCalledWith("Hello Typescript");

    logSpy.mockRestore();
  });
});
 