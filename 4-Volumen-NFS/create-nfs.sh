docker run --rm -itd --name nfs \
  --privileged \
  -v /web:/nfs.1 \
  -e SHARED_DIRECTORY=/nfs.1 \
  -p 10.158.0.42:2049:2049 \
  itsthenetwork/nfs-server-alpine:latest
