# WordPress Docker Stack

A robust, highly abstracted WordPress deployment stack utilizing Docker Compose, MariaDB, Redis Object Caching, and Ofelia for scheduled tasks. This architecture is designed for multi-site server environments, operating alongside other platforms and containerized services. By leveraging a custom PHP pre-parser, it allows for a 100% infrastructure-as-code deployment where the core application files—including `wp-config.php`—remain completely untouched.

## Key Features

* **Pristine Core Files:** The `wp-config.php` file remains identical to the vanilla WordPress sample. All database and custom variables are injected dynamically.
* **Dynamic Environment Parser:** A custom `wp-env-parser.php` script executes via PHP's `auto_prepend_file` directive, automatically converting any `.env` variable prefixed with `WP_CFG_` into a global PHP constant before WordPress loads.
* **Integrated Redis Caching:** Pre-configured Redis container and PHP extensions for high-performance object caching. Installing [Redis Cache](https://wordpress.org/plugins/redis-cache/) WordPress plugin works without additional configuration.
* **Automated Cron Jobs:** The Ofelia job scheduler executes `wp-cron.php` every 5 minutes and runs automated plugin updates daily without relying on web-triggered cron.
* **Centralized Logging:** Apache access logs and PHP error logs are routed natively to a shared `logs/` directory on the host for rapid auditing.

## Directory Structure

```text
/srv/your-project/wp-docker/
├── .env                        # Environment variables (copied from sample.env)
├── .gitignore                  # Excludes core files, database data, and logs
├── docker-compose.yml          # Service orchestration
├── sample.env                  # Template for environment variables
├── build-context/              # Image build assets
│   ├── Dockerfile              # Custom image extending wordpress:6-php8.3-apache
│   ├── wp-env-parser.php       # Dynamic namespace parser for WP_CFG_ variables
│   └── apache/
│       ├── php-overrides.ini   # Custom PHP limits and auto_prepend_file directive
│       └── site.conf           # Apache VHost configuration and security blocks
├── db_data/                    # MariaDB persistent volume (auto-created)
├── logs/                      # Apache and PHP logs (auto-created)
└── wordpress/                 # Vanilla WordPress core files (auto-created)
```

## Prerequisites

* Docker and Docker Compose installed on the host.
* An external Docker network named `gateway-net` (typically managed by a reverse proxy like Traefik or Nginx).

## Getting Started

1. **Clone the repository and prepare the environment:**
    ```bash
    git clone https://github.com/tony-h/wp-docker.git
    cd wp-docker
    cp sample.env .env
    ```

2. **Configure your `.env` file:**
    Populate the `.env` file with strong, random credentials for MySQL and your custom SMTP/Redis salt values.
    ```bash
    nano .env
    ```


3. **Build the custom image and spin up the stack:**
    ```bash
    docker compose up -d --build
    ```

    *Note: The initial run will pull the base images, compile the Redis PECL extension, install WP-CLI, and map the fresh WordPress core files to the host `wordpress/` directory.*

4. **Finalize Installation:**
    Navigate to your mapped domain in a web browser to complete the standard WordPress installation wizard. The database credentials will connect automatically.

## How the Configuration Architecture Works

### 1. Database Connections

The `docker-compose.yml` natively passes the standard `WORDPRESS_DB_*` environment variables directly to the container. The official WordPress entrypoint utilizes these values to bootstrap the database connection.

### 2. Custom Variables (`WP_CFG_`)

Any custom variable required by plugins (e.g., Simple SMTP, Redis Object Cache, Google Login) is added to the `docker-compose.yml` file using the `WP_CFG_` prefix.

The custom `wp-env-parser.php` intercepts these variables, strips the prefix, and safely defines them as global PHP constants. This strict namespace prevents the container's standard OS environment variables from leaking into the PHP application layer.

## Backups and Maintenance

Because all stateful data is exposed cleanly to the host, this stack integrates seamlessly with unified bash backup routines.

To backup the stack, execute an `rsync` or `tar` routine utilizing `pigz` for multithreaded compression against the project directory. Exclude the `logs/` directory to save space:

```bash
tar --exclude='logs' -I pigz -cvf /path/to/backups/wp_site_$(date +%F).tar.gz /srv/your-project/wp-docker/
```

To access the WordPress CLI for maintenance tasks without entering the container:

```bash
docker compose exec --user www-data wp wp <command>
```
