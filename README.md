# Advent of Code 2025 SQL

Solving Advent of Code 2025 puzzles using PostgreSQL.

## Requirements

- Python 3.11+
- Docker
- PostgreSQL client (`psql`)
- uv

## Setup

```bash
# Install uv if you don't have it
curl -LsSf https://astral.sh/uv/install.sh | sh

# Sync the project
uv sync
```

## Usage

### Create scaffolding for a new day

```bash
uv run python main.py -n <day>
```

This creates:

- `day/<n>/setup.sql` - Setup script (create tables, parse input, etc.)
- `day/<n>/part1.sql` - Part 1 solution
- `day/<n>/part2.sql` - Part 2 solution
- `inputs/day<n>.txt` - Real puzzle input (paste your input here)
- `inputs/day<n>.test.txt` - Test input from puzzle description

### Run a solution

```bash
# Run with real input
uv run python main.py -d <day> -p <part>

# Run with test input
uv run python main.py -d <day> -p <part> -t
```

### Arguments

| Flag              | Description                          |
| ----------------- | ------------------------------------ |
| `-n, --new DAY`   | Create scaffolding for a new day     |
| `-d, --day DAY`   | Day number to run (1-25)             |
| `-p, --part PART` | Part number to run (1 or 2)          |
| `-t, --test`      | Use test input instead of real input |

## How it works

1. Spins up a fresh PostgreSQL container via Docker
2. Reads the input file for the specified day
3. Runs `setup.sql` with the input available as `:'input'`
4. Runs `part1.sql` or `part2.sql` and prints the output

## Writing solutions

In `setup.sql`, use the `:'input'` variable to access the puzzle input:

```sql
CREATE TABLE input AS
SELECT unnest(string_to_array(:'input', E'\n')) AS line;
```

The input is passed as a single text value. Parse it as needed for each puzzle.
