
```bash
docker compose up -d
```


Specific Scale
```bash
docker compose up -d --scale gitlab_runner=5
```


/apps/gitlab-runner/config/config.toml

```yaml
concurrent = 4

[[runners]]
  name = "shell"
  url = "https://CI/"
  token = "TOKEN"
  limit = 2
  network_mode = "gitlab_default"
  executor = "shell"
  builds_dir = ""
  shell = "bash"

[[runners]]
  name = "ruby-2.7-docker"
  url = "https://CI/"
  token = "TOKEN"
  limit = 0
  network_mode = "gitlab_default"
  executor = "docker"
  builds_dir = ""
  [runners.docker]
    host = ""
    image = "ruby:2.7"
    privileged = false
    disable_cache = false
    cache_dir = ""


[[runners]]
  name = "production-server"
  url = "https://CI/"
  token = "TOKEN"
  limit = 0
  network_mode = "gitlab_default"
  executor = "ssh"
  builds_dir = ""
  [runners.ssh]
    host = "my-production-server"
    port = "22"
    user = "root"
    password = "production-server-password"
```