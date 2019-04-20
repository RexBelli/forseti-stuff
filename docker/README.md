Docker related forseti stuff.

Currently this is just a Dockerfile to containerize the forseti applications.

Usage:
- Clone https://github.com/forseti-security/forseti-security
- Copy the Dockerfile here to that repo
- Run `docker build -t forseti .`

To store in GCR:
```
docker tag forseti gcr.io/<project>/forseti:latest
docker push gcr.io/<project>/forseti:latest
```

