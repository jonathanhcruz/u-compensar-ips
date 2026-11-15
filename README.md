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

- `contextualizacion/`: schema (DDL), `ips_admin` user (password `admin123`), mock data and simple queries.
- `profundizacion/`: transactions, stored procedures, 30 `JOIN` queries and 10 views.
- `transferencia/`: audit table, 8 triggers, 12 stored procedures and their evidence.

Run the files of each folder in numeric order:

```bash
docker exec -i ips_ucompensar_db psql -U postgres -d ips_ucompensar -f /scripts/<folder>/<file>.sql
```
