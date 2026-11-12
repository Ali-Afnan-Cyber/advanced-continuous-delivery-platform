# infra/floci

Floci 2.2.0, a local AWS emulator, in Docker on the VM (outside K3s).
Terraform state and backups will live here.

- Start: `docker compose -f infra/floci/docker-compose.yml up -d`
- Stop, keep data: `... stop`. Remove container, keep data: `... down`. Delete data too: `... down -v`.
- Endpoint: `http://127.0.0.1:4566`, loopback only. Region `us-east-1`.
- Credentials are dummy values only: `test` / `test`. Never use real keys.
- Data: Docker named volume `floci-data` at `/app/data`, storage mode `persistent`.
- Smoke test: `scripts/floci-verify.sh`
