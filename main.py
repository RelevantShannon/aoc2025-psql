#!/usr/bin/env uv run python3
"""Advent of Code 2025 SQL Runner. See README.md for usage."""

import argparse
import os
import subprocess
import sys
import time
from pathlib import Path


CONTAINER_NAME = "aoc2025"
INPUT_DIR = "./inputs"
POSTGRES_VERSION = "18"
DB_NAME = "aoc2025"
DB_USER = "aocuser"
DB_PASSWORD = "aocpass"
DB_PORT = 9513


def run_command(
    args: list[str], capture_output: bool = True, check: bool = True
) -> subprocess.CompletedProcess:
    """Run a command and return the result."""
    return subprocess.run(args, capture_output=capture_output, text=True, check=check)


def docker_container_exists(container_name: str) -> bool:
    """Check if a Docker container exists (running or stopped)."""
    result = run_command(["docker", "ps", "-a", "--format", "{{.Names}}"], check=False)
    return container_name in result.stdout.splitlines()


def create_postgres_container(
    container_name: str,
    postgres_version: str,
    db_name: str,
    db_user: str,
    db_password: str,
    port: int,
) -> str:
    """Create or recreate a PostgreSQL Docker container. Returns the connection URL."""

    # Remove existing container if it exists
    if docker_container_exists(container_name):
        run_command(["docker", "stop", container_name], check=False)
        run_command(["docker", "rm", "-f", container_name], check=False)

    # Create new container
    result = run_command(
        [
            "docker",
            "run",
            "-d",
            "--name",
            container_name,
            "-e",
            f"POSTGRES_DB={db_name}",
            "-e",
            f"POSTGRES_USER={db_user}",
            "-e",
            f"POSTGRES_PASSWORD={db_password}",
            "-p",
            f"{port}:5432",
            f"postgres:{postgres_version}",
        ],
        check=False,
    )

    if result.returncode != 0:
        print("Failed to create container", file=sys.stderr)
        sys.exit(1)

    # Wait for postgres to be ready (max 30 seconds)
    max_attempts = 30
    for attempt in range(max_attempts):
        result = run_command(
            ["docker", "exec", container_name, "pg_isready", "-U", db_user], check=False
        )
        if result.returncode == 0:
            time.sleep(1)  # Give server a moment to fully initialize
            break

        if attempt == max_attempts - 1:
            print("Timeout waiting for PostgreSQL to be ready", file=sys.stderr)
            sys.exit(1)

        time.sleep(1)

    return f"postgresql://{db_user}:{db_password}@localhost:{port}/{db_name}"


def run_sql(
    db_url: str,
    script_path: str,
    input_content: str | None = None,
) -> None:
    """Run a SQL script and print the output."""
    script_name = os.path.basename(script_path)

    args = ["psql", db_url, "-f", script_path, "-v", "ON_ERROR_STOP=1"]

    if input_content is not None:
        args.extend(["-v", f"input={input_content}"])

    result = subprocess.run(args, capture_output=True, text=True)

    if result.returncode == 0:
        for line in result.stdout.splitlines():
            if line:  # Skip empty lines
                print(line)
    else:
        print("", file=sys.stderr)
        print(f"{script_name} failed:", file=sys.stderr)
        print(result.stdout, file=sys.stderr)
        print(result.stderr, file=sys.stderr)
        sys.exit(1)


def scaffold_new_day(day: int) -> None:
    """Create scaffolding for a new day."""
    day_dir = Path(f"./day/{day}")
    inputs_dir = Path(INPUT_DIR)

    # Create directories if they don't exist
    day_dir.mkdir(parents=True, exist_ok=True)
    inputs_dir.mkdir(parents=True, exist_ok=True)

    # Define files to create
    files = {
        day_dir
        / "setup.sql": "-- Setup for day {day}\n-- The input is available as :'input'\n",
        day_dir / "part1.sql": "-- Part 1 for day {day}\n",
        day_dir / "part2.sql": "-- Part 2 for day {day}\n",
        inputs_dir / f"day{day}.txt": "",
        inputs_dir / f"day{day}.test.txt": "",
    }

    created = []
    skipped = []

    for file_path, content in files.items():
        if file_path.exists():
            skipped.append(str(file_path))
        else:
            file_path.write_text(content.format(day=day))
            created.append(str(file_path))

    if created:
        print("Created:")
        for f in created:
            print(f"  {f}")

    if skipped:
        print("Skipped (already exist):")
        for f in skipped:
            print(f"  {f}")


def run_day(day: int, part: int, is_test: bool, fast: bool = False) -> None:
    """Run the SQL solution for a specific day and part."""
    # Check script files exist
    setup_script = f"./day/{day}/setup.sql"
    part_script = f"./day/{day}/part{part}.sql"

    if not fast and not os.path.isfile(setup_script):
        print(f"Error: Setup script '{setup_script}' does not exist", file=sys.stderr)
        sys.exit(1)

    if not os.path.isfile(part_script):
        print(f"Error: Part script '{part_script}' does not exist", file=sys.stderr)
        sys.exit(1)

    if fast:
        # Use existing container
        db_url = f"postgresql://{DB_USER}:{DB_PASSWORD}@localhost:{DB_PORT}/{DB_NAME}"
        run_sql(db_url, part_script)
    else:
        # Read input file
        input_file = f"day{day}.test.txt" if is_test else f"day{day}.txt"
        input_path = Path(INPUT_DIR) / input_file

        if not input_path.is_file():
            print(f"Error: Input file '{input_path}' does not exist", file=sys.stderr)
            sys.exit(1)

        input_content = input_path.read_text()

        # Create postgres container
        db_url = create_postgres_container(
            CONTAINER_NAME,
            POSTGRES_VERSION,
            DB_NAME,
            DB_USER,
            DB_PASSWORD,
            DB_PORT,
        )

        # Run setup and part scripts
        run_sql(db_url, setup_script, input_content)
        run_sql(db_url, part_script)


def main() -> None:
    parser = argparse.ArgumentParser(description="Advent of Code 2025 SQL Runner")
    parser.add_argument(
        "-n", "--new", type=int, metavar="DAY", help="Create scaffolding for a new day"
    )
    parser.add_argument("-d", "--day", type=int, help="Day number (1-25)")
    parser.add_argument("-p", "--part", type=int, choices=[1, 2], help="Part 1 or 2")
    parser.add_argument(
        "-t", "--test", action="store_true", help="Use test input instead of real input"
    )
    parser.add_argument(
        "-f",
        "--fast",
        action="store_true",
        help="Skip container setup and run part script only",
    )
    parser.add_argument(
        "-r",
        "--raw",
        type=int,
        metavar="DAY",
        help="Print test input for a day with newlines escaped for copy-pasting",
    )

    args = parser.parse_args()

    # Raw file output mode
    if args.raw is not None:
        file_path = Path(INPUT_DIR) / f"day{args.raw}.test.txt"
        if not file_path.is_file():
            print(f"Error: File '{file_path}' does not exist", file=sys.stderr)
            sys.exit(1)
        content = file_path.read_text()
        print(content.replace("\n", "\\n"), end="")
        return

    # New day scaffolding mode
    if args.new is not None:
        scaffold_new_day(args.new)
        return

    # Run mode - require day and part
    if args.day is None or args.part is None:
        parser.error(
            "Running requires both -d/--day and -p/--part (or use -n/--new to scaffold)"
        )

    run_day(args.day, args.part, args.test, args.fast)


if __name__ == "__main__":
    main()
