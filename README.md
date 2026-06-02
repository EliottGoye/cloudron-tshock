# TShock for Cloudron

A [Cloudron](https://cloudron.io/) package for [TShock](https://tshock.readme.io/), the open-source modded server for [Terraria](https://terraria.org/).

## Features

- REST API exposed as the app's web interface (health check + remote administration)
- Persistent world, configuration, and database stored in `/app/data`
- Plugin support — drop `.dll` files into `/app/data/plugins/` and restart
- Auto-generated world on first start (large size, random evil)

## Installation

### From source

```bash
git clone https://git.tachy.dev/eliott/cloudron-tshock.git
cd cloudron-tshock
cloudron install -p GAME_PORT=7777
```

## Environment variables

| Variable            | Description                      | Default  |
|---------------------|----------------------------------|----------|
| `TERRARIA_PASSWORD` | Server password required to join | *(none)* |

Set via the Cloudron dashboard or CLI:

```bash
cloudron env set --app <app> TERRARIA_PASSWORD=mysecret
```

> **Note:** `TERRARIA_PASSWORD` is written to `config.json` on first install only.
> To change it afterwards, edit `/app/data/tshock/config.json` directly or delete
> `/app/data/.initialized` and restart to trigger re-initialisation.

## Configuration

TShock is configured via `/app/data/tshock/config.json`, generated automatically on first start.
The file is persistent and survives updates. Edit it with:

```bash
cloudron exec --app <app>
vi /app/data/tshock/config.json
```

Then restart the app to apply changes.

Key fields set at first-run time:

| Field            | Default | Description                     |
|------------------|---------|---------------------------------|
| `ServerPort`     | `7777`  | Game port (matches `GAME_PORT`) |
| `MaxSlots`       | `16`    | Maximum player slots            |
| `ServerPassword` | `""`    | Join password                   |
| `RestApiEnabled` | `true`  | Enables the REST API            |
| `RestApiPort`    | `7878`  | REST API port                   |

## REST API

The REST API is available at the app's domain (e.g. `https://terraria.example.com`).

The superadmin token is generated on first start and saved to `/app/data/rest-api-credentials.txt`:

```bash
cloudron exec --app <app> -- cat /app/data/rest-api-credentials.txt
```

Example requests:

```bash
# Public – no token required
curl https://terraria.example.com/v2/server/status

# Authenticated
curl "https://terraria.example.com/v2/users/list?token=<your-token>"
```

Full API reference: https://tshock.readme.io/reference

## Admin setup (first start)

1. Check the logs for the setup code:
   ```bash
   cloudron logs --app <app> | grep "setup"
   ```
2. Connect to the server in Terraria and run `/setup <code>` in chat.
3. Register an admin account: `/register <password>`
4. Log in: `/login <password>`

## Plugins

TShock plugins are `.dll` assemblies placed in `/app/data/plugins/`.

To install a plugin:

```bash
cloudron push --app <app> MyPlugin.dll /app/data/plugins/MyPlugin.dll
cloudron restart --app <app>
```

## Persistent data layout

```
/app/data/
├── tshock/
│   ├── config.json          # Server configuration
│   ├── tshock.sqlite        # Users, bans, regions database
│   ├── logs/                # TShock logs
│   ├── crashes/             # Crash dumps
│   └── backups/             # World backups
├── worlds/
│   └── World.wld            # Terraria world file
├── plugins/                 # Additional TShock plugins (.dll)
├── rest-api-credentials.txt # Generated REST API token
└── .initialized             # First-run flag
```

## Links

- [TShock documentation](https://tshock.readme.io/)
- [TShock GitHub](https://github.com/Pryaxis/TShock)
