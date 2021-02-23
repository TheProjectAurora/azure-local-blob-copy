#!/usr/bin/env python3

import os
from os import listdir
from os.path import isfile, join, isdir, basename, split
from azure.storage.blob import ContentSettings, BlobServiceClient, BlobClient, ContainerClient, __version__

from typing import List, Set, Dict, Tuple, Optional
import mimetypes


def help():
    print("""
        This will contain the help for this monster.
        Following data is required:
        * Connection string: AZURE_STORAGE_CONNECTION_STRING
        * Container name
        * Source directory 
        * Destination directory - default /
        
        This is going to work only with the environment variables.
        Main reason is that this is meant to be executed from the AKS or
        Kubernetes cluster.

        The source directory takes only the last part. E.g. if you have source directory:
        /home/testuser/source

        And destination directory is:
        /

        Then the destination directory structure will be:
        /source
        
    """)

def check_environment_variables():
    mandatory = [
        'AZURE_STORAGE_CONNECTION_STRING',
        'SOURCE_DIRECTORY',
        'AZURE_STORAGE_CONTAINER'
    ]

    for variable in mandatory:
        if variable not in os.environ:
            print(f'The environment variable {variable} is missing.')
            exit(1)

Files = List[str]

def get_files(path : str, current_list : Files = [] ) -> Files:
    files = []
    directories = [ path ]
    for path in directories:
        for item in listdir(path):
            fullpath = join(path, item)
            if isfile(fullpath):                
                files.append(fullpath)
            elif isdir(fullpath):
                directories.append(fullpath)       
    return files

def get_prefix(path : str ) -> str:
    (path, endpart ) = split(path)
    while not endpart and path:
        (path, endpart ) = split(path)
    return path

def upload_files(source_dir : str, 
                 files : Files, 
                 connection_string : str, 
                 container : str, 
                 destination : str,
                 cache_setting : str ):
    path_end_position = len(get_prefix('.'+source_dir))
    container_client = BlobServiceClient.from_connection_string(connection_string).get_container_client(container)
    for file in files:
        target_name=join(destination, file[path_end_position:])
        mimetype = mimetypes.guess_type(file)[0]

        print(f"Copying file {file} to {target_name} of type {mimetype}")
        with open(file, "rb") as data:
           blob_client = container_client.upload_blob(name=target_name, 
                                                      data=data, 
                                                      overwrite=True,
                                                      content_settings=ContentSettings(
                                                        content_type=mimetype,
                                                        cache_control = cache_setting)
                                                    )
        
def sanitize_destination(path : str) -> str:
    """ Function removes the leading / characters. They're
        messing up the directory structure.         
    """
    if not path:
        path = ""
    while len(path) > 0 and path[0] == '/':
        path = path[1:]
    return path


def main():
    check_environment_variables()
    connection_string = os.getenv('AZURE_STORAGE_CONNECTION_STRING')
    source_dir = os.getenv("SOURCE_DIRECTORY")
    contaner_name = os.getenv("AZURE_STORAGE_CONTAINER")
    destination_directory = sanitize_destination( os.getenv("DESTINATION_DIRECTORY"))
    cache_setting = os.getenv("CACHE_CONTROL")
    blob_service_client = BlobServiceClient.from_connection_string(connection_string)
    files = get_files(source_dir)
    upload_files(source_dir, files, connection_string, contaner_name, destination_directory, cache_setting)
    


if __name__ == "__main__":
    main()