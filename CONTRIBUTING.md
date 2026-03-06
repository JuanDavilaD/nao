# 🪄 Contributing to LySmart

Thank you for your interest in contributing to LySmart! 🎉

## Getting Started

### Running the project

At the root of the project, run:

```bash
npm run dev
```

This will start the project in development mode. It will start the frontend and backend in development mode.

### Publishing to PyPI

```bash
npm run publish
```

By default, this will publish a patch version. You can specify a different version bump with:

```bash
npm run publish <major|minor|patch>
```

## Project Structure

```
chat/
├── apps/
│   ├── backend/     # Bun + Fastify + tRPC API server
│   └── frontend/    # React + Vite + TanStack Router
├── cli/             # Python CLI (lysmart-core package)
└── ...
```

## Development Commands

| Command                         | Description                          |
| ------------------------------- | ------------------------------------ |
| `npm run dev`                   | Start backend + frontend in dev mode |
| `npm run dev:backend`           | Backend only (Bun on :5005)          |
| `npm run dev:frontend`          | Frontend only (Vite on :3000)        |
| `npm run lint`                  | Run ESLint on both apps              |
| `npm run lint:fix`              | Fix lint issues                      |
| `npm run format`                | Format with Prettier                 |
| `npm run -w @lysmart/backend test`  | Run backend tests                    |
| `npm run -w @lysmart/frontend test` | Run frontend tests                   |

### Database Commands

| Command                               | Description                         |
| ------------------------------------- | ----------------------------------- |
| `npm run pg:start`                    | Start PostgreSQL via docker-compose |
| `npm run pg:stop`                     | Stop PostgreSQL                     |
| `npm run -w @lysmart/backend db:generate` | Generate migrations                 |
| `npm run -w @lysmart/backend db:migrate`  | Apply migrations                    |
| `npm run -w @lysmart/backend db:studio`   | Open Drizzle Studio GUI             |

## Making Changes

### Code Style

- Run `npm run lint:fix` before committing
- Run `npm run format` to format code with Prettier
- Follow existing patterns in the codebase

## Submitting Changes

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Questions?

- 💬 [Join our Slack](https://join.slack.com/t/lysmart-labs/shared_invite/zt-3cgdql4up-Az9FxGkTb8Qr34z2Dxp9TQ)
- 🐛 [Open an issue](https://github.com/getlysmart/chat/issues)

Thank you for contributing! 🙏
