# LySmart CLI

Command-line interface for LySmart chat.

## Installation

```bash
pip install lysmart-core
```

## Usage

```bash
lysmart --help
Usage: lysmart COMMAND

╭─ Commands ────────────────────────────────────────────────────────────────╮
│ chat         Start the LySmart chat UI.                                       │
│ debug        Test connectivity to configured resources.                   │
│ init         Initialize a new LySmart project.                                │
│ sync         Sync resources to local files.                               │
│ test         Run and explore LySmart tests.                                   │
│ --help (-h)  Display this message and exit.                               │
│ --version    Display application version.                                 │
╰───────────────────────────────────────────────────────────────────────────╯
```

### Initialize a new LySmart project

```bash
lysmart init
```

This will create a new LySmart project in the current directory. It will prompt you for a project name and ask you to configure:

- **Database connections** (BigQuery, DuckDB, Databricks, Snowflake, PostgreSQL, Redshift, MSSQL, Trino)
- **Git repositories** to sync
- **LLM provider** (OpenAI, Anthropic, Mistral, Gemini)
- **Slack integration**
- **Notion integration**

The resulting project structure looks like:

```
<project>/
├── lysmart_config.yaml
├── .lysmart_ignore
├── RULES.md
├── databases/
├── queries/
├── docs/
├── semantics/
├── repos/
├── agent/
│   ├── tools/
│   └── mcps/
└── tests/
```

Options:

- `--force` / `-f`: Force re-initialization even if the project already exists

### Start the LySmart chat UI

```bash
lysmart chat
```

This will start the LySmart chat UI. It will open the chat interface in your browser at `http://localhost:5005`.

### Test connectivity

```bash
lysmart debug
```

Tests connectivity to all configured databases and LLM providers. Displays a summary table showing connection status and details for each resource.

### Sync resources

```bash
lysmart sync
```

Syncs configured resources to local files:

- **Databases** — generates markdown docs (`columns.md`, `preview.md`, `description.md`, `profiling.md`) for each table into `databases/`
- **Git repositories** — clones or pulls repos into `repos/`
- **Notion pages** — exports pages as markdown into `docs/notion/`

After syncing, any Jinja templates (`*.j2` files) in the project directory are rendered with the LySmart context.

### Run tests

```bash
lysmart test
```

Runs test cases defined as YAML files in `tests/`. Each test has a `name`, `prompt`, and expected `sql`. Results are saved to `tests/outputs/`.

Options:

- `--model` / `-m`: Models to test against (default: `openai:gpt-4.1`). Can be specified multiple times.
- `--threads` / `-t`: Number of parallel threads (default: `1`)

Examples:

```bash
lysmart test -m openai:gpt-4.1
lysmart test -m openai:gpt-4.1 -m anthropic:claude-sonnet-4-20250514
lysmart test --threads 4
```

### Explore test results

```bash
lysmart test server
```

Starts a local web server to explore test results in a browser UI showing pass/fail status, token usage, cost, and detailed data comparisons.

Options:

- `--port` / `-p`: Port to run the server on (default: `8765`)
- `--no-open`: Don't automatically open the browser

### BigQuery service account permissions

When you connect BigQuery during `lysmart init`, the service account used by `credentials_path`/ADC must be able to list datasets and run read-only queries to generate docs. Grant the account:

- Project: `roles/bigquery.jobUser` (or `roles/bigquery.user`) so the CLI can submit queries
- Each dataset you sync: `roles/bigquery.dataViewer` (or higher) to read tables

The combination above mirrors the typical "BigQuery User" setup and is sufficient for LySmart's metadata and preview pulls.

### Snowflake authentication

Snowflake supports three authentication methods during `lysmart init`:

- **SSO**: Browser-based authentication (recommended for organizations with SSO policies)
- **Password**: Traditional username/password
- **Key-pair**: Private key file with optional passphrase

## Development

### Building the package

```bash
cd cli
python build.py --help
Usage: build.py [OPTIONS]

Build and package lysmart-core CLI.

╭─ Parameters ──────────────────────────────────────────────────────────────────╮
│ --force -f --no-force              Force rebuild the server binary             │
│ --skip-server -s --no-skip-server  Skip server build, only build Python pkg   │
│ --bump                             Bump version (patch, minor, major)          │
╰───────────────────────────────────────────────────────────────────────────────╯
```

This will:
1. Build the frontend with Vite
2. Compile the backend with Bun into a standalone binary
3. Bundle everything into a Python wheel in `dist/`

### Installing for development

```bash
cd cli
pip install -e .
```

### Publishing to PyPI

```bash
# Build first
python build.py

# Publish
uv publish dist/*
```

## Architecture

```
lysmart chat (CLI command)
    ↓ spawns
lysmart-chat-server (Bun-compiled binary, port 5005)
  + FastAPI server (port 8005)
    ↓ serves
Backend API + Frontend Static Files
    ↓
Browser at http://localhost:5005
```
