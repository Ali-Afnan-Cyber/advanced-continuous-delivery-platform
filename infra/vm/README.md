# infra/vm

Scripts that prepare the VM.

- `install-tools.sh` installs Docker (only to run Floci), Terraform v1.16.6 and AWS CLI v2.
  Run it once. It is safe to run again.
- After the first run, open a new SSH session or run `newgrp docker` so `docker` works without sudo.
- Docker comes from Ubuntu apt. Record the installed version in the phase notes.
