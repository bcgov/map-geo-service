# map geoserver/geowebcache

## GitOps

Four Environments are configured: `dev`, `test`, `prod` and `gateway`.

Go to https://github.com/bcgov/map-geo-services/settings/environments to configure the rules around which environments require approvals to proceed.

### Openshift

**Set Github Secrets**

| Secret            | Source                                                               |
| ----------------- | -------------------------------------------------------------------- |
| OPENSHIFT_SERVER  | `https://api.silver.devops.gov.bc.ca:6443`                           |
| OPENSHIFT_TOKEN   | Permission to manage resources in project                            |
| OCP_LICENSE_PLATE | The license plate that environment namespaces share (i.e./ `a4c31f`) |
| CONFIG            | All your secure environment-specific variables                       |

> Can use the credentials found in `pipeline-token-*` secret for the service account `pipeline`.

### CONFIG Contents for Environment Specific Variables

| Secret          | Source                                    |
| --------------- | ----------------------------------------- |
| S3_ENDPOINT     | https://bc-data-obj.objectstore.gov.bc.ca |
| S3_CACHE_BUCKET | Example: data_map_geowebcache_dev_bkt     |
| S3_ACCESS_KEY   | Example: data_map_geowebcache_dev_usr     |
| S3_SECRET_KEY   |                                           |

**\*Optional Generator for CONFIG**

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
    ("SAMPLE", rando_cred(10)),
    ("S3_ENDPOINT", ""),
    ("S3_BUCKET", ""),
    ("S3_ACCESS_KEY", ""),
    ("S3_SECRET_KEY", ""),
]
for k,v in vars:
  print("%s=%s" % (k, v))
' | python3 -
```

Store the information in `Vault` (for reference) and in `Github` (for deployment):

1. Vault: Login at https://vault.developer.gov.bc.ca and go to `<OCP_LICENSE_PLATE>-nonprod/CONFIG` for `dev` and `test` (`<OCP_LICENSE_PLATE>-prod/CONFIG` for `prod`) and update with the above config.

2. Github: Go to https://github.com/bcgov/map-geo-service/settings/environments and add an Environment Secret `CONFIG` with the above config.

### Container Registry

**Set Github Secrets**

| Secret             | Source                       |
| ------------------ | ---------------------------- |
| REGISTRY           | `ghcr.io`                    |
| REGISTRY_REPO_NAME | `bcgov/map-geo-service`      |
| REGISTRY_USERNAME  | Github User                  |
| REGISTRY_PASSWORD  | Github Personal Access Token |

## Scaling

Baseline Pod for GeoWebCache: CPU: 800m, Memory: 3Gb

| CPU  | Memory | Multiplier   | Est. Req/Sec               | Est. CPU | Est. Memory |
| ---- | ------ | ------------ | -------------------------- | -------- | ----------- |
| 800m | 3Gb    | 1 (20 users) | 16 r/s                     | 800m     | 3Gb         |
| 800m | 3Gb    | 3 (75 users) | 60 r/s                     |          |             |
| 800m | 3Gb    | 3 (75 users) | 35 r/s (with S3 blobstore) |          |             |
| 800m | 3Gb    | 3 (75 users) | 60 r/s (with shared PVC)   |          |             |
| 800m | 3Gb    | 32           | 512 r/s                    | 26 CPU   | 96Gb        |

Proposed Project Sizes:

- Dev: 2 CPU Limit, 8 Gb Memory Limit, Storage 4Gb
- Test: 4 CPU Limit, 16 Gb Memory Limit, Storage 4Gb
- Prod: 32 CPU Limit, 128 Gb Memory Limit, Storage 4Gb
- Tools: lowest quotas

## Object Storage

**Development Environment**

```
https://bc-data-obj.objectstore.gov.bc.ca

data_map_geowebcache_dev_bkt
data_map_geowebcache_dev_usr
```

## Runtime Troubleshooting

### Flush Cache

```
curl -v -u <USERNAME>:<PASSWORD> -X POST -H "Content-type: text/xml" \
  -d "<truncateLayer><layerName>pub:WHSE_HUMAN_CULTURAL_ECONOMIC.EMRG_ORDER_AND_ALERT_AREAS_SP</layerName></truncateLayer>" \
  https://map-gwc.dev.api.gov.bc.ca/gwc/rest/masstruncate
```

```
curl -v -u <USERNAME>:<PASSWORD> -X POST -H "Content-type: text/xml" \
  "https://map-gwc.dev.api.gov.bc.ca/gwc/rest/seed/pub:WHSE_HUMAN_CULTURAL_ECONOMIC.EMRG_ORDER_AND_ALERT_AREAS_SP"
```
