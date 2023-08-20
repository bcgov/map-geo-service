# bcstats-callweb

## GitOps

Four Environments are configured: `dev`, `test`, `prod` and `gateway`.

Go to https://github.com/bcgov/map-geo-services/settings/environments to configure the rules around which environments require approvals to proceed.

### Openshift

**Set Github Secrets**

| Secret            | Source                                             |
| ----------------- | -------------------------------------------------- |
| OPENSHIFT_SERVER  | `https://api.silver.devops.gov.bc.ca:6443`         |
| OPENSHIFT_TOKEN   | Permission to manage resources in project `264e6f` |
| OCP_LICENSE_PLATE | `264e6f`                                           |
| CONFIG            | All your secure environment-specific variables     |

> Can use the credentials found in `pipeline-token-*` secret for the service account `pipeline`.

**Set Github Environment Specific Secrets**

| Secret          | Source                                    |
| --------------- | ----------------------------------------- |
| S3_ENDPOINT     | https://bc-data-obj.objectstore.gov.bc.ca |
| S3_CACHE_BUCKET | Example: data_map_geowebcache_dev_bkt     |
| S3_ACCESS_KEY   | Example: data_map_geowebcache_dev_usr     |
| S3_SECRET_KEY   |                                           |

### Artifactory

**Set Github Secrets**

| Secret                | Source                                 |
| --------------------- | -------------------------------------- |
| ARTIFACTORY_REPO_NAME | `a264-docker`                          |
| REGISTRY_USERNAME     | Refer to a artifacts-default-\* secret |
| REGISTRY_PASSWORD     | Refer to a artifacts-default-\* secret |

### Generating environment variables

Use the following script to generate the data that will reside in the Environment Secret `CONFIG`:

```
echo '
import sys, random, string

def rando(len, choices):
  return "".join(random.choice(choices) for _ in range(len))

def rando_cred(len):
  return rando(len, string.ascii_uppercase + string.ascii_lowercase + string.digits)

def rando_s3(len):
  return rando(len, string.ascii_uppercase + string.digits)

vars = [
    ("SAMPLE", rando_cred(10))
]
for k,v in vars:
  print("%s=%s" % (k, v))
' | python3 -
```

Store the information in `Vault` (for reference) and in `Github` (for deployment):

1. Vault: Login at https://vault.developer.gov.bc.ca and go to `264e6f-nonprod/CONFIG` for `dev` and `test` (`264e6f-prod/CONFIG` for `prod`) and update with the above config.

2. Github: Go to https://github.com/bcgov/map-geo-service/settings/environments and add an Environment Secret `CONFIG` with the above config.

## Scaling

Baseline: CPU: 800m, Memory: 2Gb

Available: 16 CPU, 58Gb Memory

| CPU  | Memory | Multiplier   | Est. Req/Sec               | Est. CPU | Est. Memory |
| ---- | ------ | ------------ | -------------------------- | -------- | ----------- |
| 800m | 2Gb    | 1 (20 users) | 16 r/s                     | 800m     | 2Gb         |
| 800m | 2Gb    | 3 (75 users) | 60 r/s                     |          |             |
| 800m | 2Gb    | 3 (75 users) | 35 r/s (with S3 blobstore) |          |             |
| 800m | 2Gb    | 32           | 512 r/s                    | 16 CPU   | 64Gb        |

## Object Storage

```
https://bc-data-obj.objectstore.gov.bc.ca
data_map_geowebcache_dev_bkt
data_map_geowebcache_dev_usr
```

## Runtime Troubleshooting

### Flush Cache

```
curl -v -u geowebcache:secured -X POST -H "Content-type: text/xml" \
  -d "<truncateLayer><layerName>pub:WHSE_HUMAN_CULTURAL_ECONOMIC.EMRG_ORDER_AND_ALERT_AREAS_SP</layerName></truncateLayer>" \
  https://map-gwc.dev.api.gov.bc.ca/gwc/rest/masstruncate
```

```
curl -v -u geowebcache:secured -X POST -H "Content-type: text/xml" \
  "https://map-gwc.dev.api.gov.bc.ca/gwc/rest/seed/pub:WHSE_HUMAN_CULTURAL_ECONOMIC.EMRG_ORDER_AND_ALERT_AREAS_SP"
```
