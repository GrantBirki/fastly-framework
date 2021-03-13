# Usage

To use this image as your base pipeline image, simply push it up to GitLab or GitHub.

GitLab Example:

```bash
docker login registry.gitlab.com
docker build -t registry.gitlab.com/<account>/<repo>/<image>:<tag> .
docker push registry.gitlab.com/<account>/<repo>/<image>:<tag>
```
