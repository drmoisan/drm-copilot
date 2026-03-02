from pathlib import Path


def main() -> None:
    output_file = Path("artifacts/hello_python.txt")
    output_file.parent.mkdir(parents=True, exist_ok=True)
    output_file.write_text("hello_python:ok\n", encoding="utf-8")


if __name__ == "__main__":
    main()
