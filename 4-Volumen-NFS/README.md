# Almacenamiento persistente con NFS 

Es necesario instalación el paquete de nfs

`$ sudo apt -y install nfs-common`

## NFS server usando Docker

Crear un directorio para NFS home

`$ mkdir /nfs_data`

    $ docker run --rm -itd --name nfs \
      --privileged \
      -v /nfs_data:/nfs.1 \
      -e SHARED_DIRECTORY=/nfs.1 \
      -p 10.158.0.42:2049:2049 \
      itsthenetwork/nfs-server-alpine:latest

[más infor](https://hub.docker.com/r/itsthenetwork/nfs-server-alpine/)

Esta imangen está creada con Alpine Linux y NFS v4 a través de TCP en el puerto 2049


### Test

`$ mkdir /nfs_data/datos`
`$ mount -v -t nfs4 -o vers=4,loud 10.158.0.42:/ /mnt/nfs_data/`
`$ ls /mnt/nfs_data/`

### en los otros nodos

Instalar

`$ sudo apt -y install nfs-common`

montar partición

`$ mount -v -t nfs4 -o vers=4,loud 10.158.0.42:/ /mnt/nfs_data/`

