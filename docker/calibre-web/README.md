Initialize Database:

```bash
docker-compose exec calibre-web calibredb restore_database --really-do-it --with-library /books
```