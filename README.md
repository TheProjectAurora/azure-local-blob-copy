# Local file system to Azure Blobs Copy

**NOTE** This has been tested only with Linux!

This tool copies the recursively all files from specified local directory to the Azure Blobs.
Those can contain e.g. static items from the Kubernetes POD.

## Usage

The original idea is to use this from the Kubernetes. That's why all parameters are from the
environment variables. Following variables are used:

* AZURE_STORAGE_CONNECTION_STRING - this is the connection string. It can be received with the
  command:
  ```
    export AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string \
                                             -n <storage account name> \
                                             -g <resource group> \
                                             -o tsv)
  ```
* SOURCE_DIRECTORY - The local directory which will be copied.
* AZURE_STORAGE_CONTAINER - Name of the container.
* DESTINATION_DIRECTORY - Prefix for the destination.
* CACHE_CONTROL - String for cache control header. If none, then cache control do not exist.

From the source directory only the last directory is used. So e.g. if the directory is 
`/home/build/static` then only the `static` part of the directory is used when the exact 
destination is decided. If the `DESTINATION_DIRECTORY` is `output/`, then the blob name for the 
file `/home/build/static/css/web.css` is `output/static/css/web.css`. 


## To Be Done

Better documentation and example scenarios.