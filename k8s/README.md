Folder for k8s related forseti stuff.  All files are example and probably need to be edited before use.  This is only a starting point, none of this is production ready, but it should get a working forseti deployment stood up quickly.

# Server Setup

## Overview
There are a few things that are needed to make this work:

Container:
  - See the docker directory in this repo on how to build the container.

GCP:
  - GKE cluster
  - Cloud SQL instance
  - GCP Service Account with these [permissions](https://forsetisecurity.org/docs/latest/concepts/service-accounts.html#the-server-service-account)
  - GCS bucket (referred to as FORSETI_BUCKET in the configuration file)
  
Kubernetes:
  - secrets:
    - GCP Service Account from above
    - Cloud SQL credentials (username and password)
  - configMaps:
    - forseti-server-conf - [this file](https://github.com/forseti-security/forseti-security/blob/dev/configs/server/forseti_conf_server.yaml.in) filled in appropriately  
    - forseti-rules
  - deployment:
    - forseti-server
  - service:
    - forseti-server - to access the forseti server outside the pod


## Secrets

### GCP Service Account

1) Create service account and download credentials in json format
2) Move file to CWD and rename `forseti-server.json`
3) Create secret:
```
kubectl create secret generic forseti-server-service-account --from-file=forseti-server.json
```

### Cloud SQL Instance Credentials

1) Create secret:
```
kubectl create secret generic cloud-sql-creds --from-literal sql_username=<username> --from-literal sql_password=<password>
```

## ConfigMaps

### Forseti Service Configuration

1) Using [this file](https://github.com/forseti-security/forseti-security/blob/dev/configs/server/forseti_conf_server.yaml.in) as a template, fill in the values for your setup.  Some things to pay attention to:
  - If you don't set up Sendgrid, you'll want to comment out all the email stuff
  - the rules directory should match the mount point in the server deployment (line 42).  In this case, it should be `/config/rules`
2) Create configMap:
```
kubectl create configmap forseti-server-conf --from-file=forseti_conf_server.yaml
```

### Forseti Rules

1) In the `forseti-security` repo, execute:
```
kubectl create configmap forseti-rules --from-file=rules/
```

## Deployment

1) I highly suggest using the provided yaml file.  You'll need to edit:
  - the image location
  - the Cloud SQL connection string
```
kubectl create -f forseti-server.yaml
```

## Service

1) Not much to say here:
```
kubectl create service clusterip forseti-server --tcp=50051
```

# CronJob setup

The same container image can be used to run cron jobs as well.  It's two pieces:
 - the connjob object
 - a script to run

### Run Script

1) The run.sh file in this repo is a slightly modified version of [this](https://github.com/forseti-security/forseti-security/blob/dev/install/gcp/scripts/run_forseti.sh).
2) You'll need to get the Cluster IP from the forseti-service and fill in that value on line 16
3) Create configMap:
```
kubectl create configmap forseti-job-script --from-file=run.sh
```

### CronJob

1) Edit the `forseti-job.yaml` as necessary, likely only the `schedule` line.
2) Create Cronjob:
```
kubectl create -f forseti-job.yaml
```



