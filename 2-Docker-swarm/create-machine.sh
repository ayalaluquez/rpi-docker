export GOOGLE_APPLICATION_CREDENTIALS=~/Descargas/tetrix-2459a6f7b695.json

for i in "manager" "worker"; do
docker-machine create $i --engine-install-url "https://get.docker.com" \
	-d google \
	--google-machine-type n1-standard-1 \
	--google-zone southamerica-east1-a \
	--google-disk-size "20" \
	--google-tags http-server \
	--google-project molten-sandbox-249001 \
	--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/ubuntu-1804-bionic-v20190813a
done
