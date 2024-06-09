## Usage

```shell
mkdir data passwd
chown ${PUID}:${PGID} data passwd
touch acme.json
chmod 600 acme.json
docker compose up -d
docker compose logs -f
```
