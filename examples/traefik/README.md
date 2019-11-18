## Usage

```bash
mkdir data passwd
chown 1000:1000 data passwd
touch acme.json
chmod 600 acme.json
docker-compose up -d
docker-compose logs -f
```
