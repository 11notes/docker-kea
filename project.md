${{ content_synopsis }} This image will run kea dhcp4 [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) for more security.

${{ content_uvp }} Good question! Because ...

${{ github:> [!IMPORTANT] }}
${{ github:> }}* ... this image runs [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) as 1000:1000
${{ github:> }}* ... this image is auto updated to the latest version via CI/CD
${{ github:> }}* ... this image has a health check
${{ github:> }}* ... this image runs read-only
${{ github:> }}* ... this image is automatically scanned for CVEs before and after publishing
${{ github:> }}* ... this image is created via a secure and pinned CI/CD process
${{ github:> }}* ... this image runs a basic integration test before it will be published (or not if it fails)
${{ github:> }}* ... this image will automatically create self-signed SSL certificates for the socket connection
${{ github:> }}* ... this image supports [inline configs](https://github.com/11notes/RTFM/blob/master/linux/container/image/11notes/inline-config.md)

If you value security, simplicity and optimizations to the extreme, then this image might be for you.


${{ title_volumes }}
* **${{ json_root }}/etc** - Directory of your kea config
* **${{ json_root }}/var** - Directory of your kea dynamic data

${{ content_compose }}

${{ content_defaults }}

${{ content_environment }}
| `KEA_CONFIG` *(optional)* | Will overwrite the default config with the value of this variable if set ([inline config](https://github.com/11notes/RTFM/blob/master/linux/container/image/11notes/inline-config.md)) | |
| `KEA_SUBNETS_CONFIG` *(optional)* | Will overwrite only the default subnets config with the value of this variable if set ([inline config](https://github.com/11notes/RTFM/blob/master/linux/container/image/11notes/inline-config.md)) | |
| `KEA_INTERFACES` *(optional)* | JSON array data type of interfaces to bind kea to, defaults to all interfaces | ["*"] |

${{ content_source }}

${{ content_parent }}

${{ content_built }}

${{ content_tips }}