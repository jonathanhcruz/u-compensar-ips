# Terminal-Based 

this project is a simple university project created only for educational purposes. 

## Installation

1. Install Docker: https://docs.docker.com/get-docker/
2. Run the project from this folder:

```bash
docker compose up -d
```

The database, tables and mock data are created automatically. To reset it: `docker compose down -v && docker compose up -d`.

## Connections

The database is exposed on port **5430** of the host machine.

| Field    | Value            |
|----------|------------------|
| Host     | `localhost`      |
| Port     | `5430`           |
| Database | `ips_ucompensar` |
| User     | `postgres`       |
| Password | `postgres`       |

## Deliveries

The work is split by delivery, one folder each:

- `contextualizacion/`: schema (DDL), mock data and simple queries.
- `profundizacion/`: transactions, stored procedures, 30 `JOIN` queries and 10 views.

Run the `profundizacion/` files in numeric order, then `ipsCreateViews.sql`:

```bash
docker exec -i ips_ucompensar_db psql -U postgres -d ips_ucompensar -f /scripts/profundizacion/<file>.sql
```
