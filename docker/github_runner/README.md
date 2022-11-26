# GitHub Self Host Runner

Create .env File
```bash
# .env File Contents
ORGANIZATION=<YOUR-GITHUB-ORGANIZATION>
ACCESS_TOKEN=<YOUR-GITHUB-ACCESS-TOKEN>
PYPI_USERNAME=__token__
PYPI_PASSWORD=<PYPI API TOKEN>
```

Build Container Image
```bash
docker-compose build
```

Scale Runners
```bash
docker-compose up --build --scale runner=2 -d
docker-compose up --scale runner=1 -d
```

Debug
```bash
docker-compose logs -f
```