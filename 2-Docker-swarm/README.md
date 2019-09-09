# [Docker Swarm & Google cloud-swarm](https://beta.docs.docker.com/machine/drivers/gce/)

Jugando un poco con orquestación de contenedores en la nube ^.^  

### Prerequsitos

* [Docker](https://docs.docker.com/install/)
* [Docker-machine](https://docs.docker.com/machine/install-machine/)
* [SDK Cloud](https://cloud.google.com/sdk/docs/quickstart-debian-ubuntu) 

### Iniciar sesión con una cuenta de google 

`$ gcloud init`

#### Comando principales de google cloud
	
`$ gcloud auth list` 	=> muestra una lista de cuentas guardadas localmente

`$ gcloud config list` 	=> lista las propiedades de la configuración de glcoud

`$ glcoud info`		=> información de la instalación de SDk

`$ gcloud help`		=> ex: gcloud help compute instances create

[Más comando](https://cloud.google.com/sdk/gcloud/reference/)

### Configuración de credenciales para gcloud

[Crear clave de cuenta de servicio y generar archivo JSON](https://console.cloud.google.com/apis/credentials/serviceaccountkey?hl=es)

#### Crear variable de entorno 
	
`$ export GOOGLE_APPLICATION_CREDENTIALS="/Dir/donde/hayas/descargado/archivo.json"`

[Más info sobre autenticación](https://cloud.google.com/docs/authentication/production?hl=es)


## Crear nodo swarm	

	$ docker-machine create manager \
		--engine-install-url experimental.docker.com \
    		-d google \
    		--google-machine-type n1-standard-1 \
    		--google-zone southamerica-east1-a \
    		--google-disk-size "20" \
    		--google-tags swarm \
    		--google-project <Project-ID>

Opciones
* --google-machine-type n1-standard-1: crea un instancia con 1 vCPU y 3,75 GB de memoria.
* --google-project: google ID proyecto, con el siguiente comando se puede obtener esa info  $ gcloud config get-value project 
* --google-tags: es importante utilizar los tags para configuraciones de firewalls ;)

##### Listar instancia Google Cloud

`$ gcloud compute instances list`                                                                                                         
	
	NAME           ZONE                  MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP    STATUS
	swarm-manager  southamerica-east1-a  n1-standard-1               10.158.0.5   35.xx.xx.xx    RUNNING


### Generar token

`$ eval $(docker-machine env swarm-manager)`

* eval es un comando que permite ejecutar un comando con variables de entorno, en este caso las variables del cliente de docker "swarm-manager".

`$ docker swarm init` 
		
	...
	docker swarm join --token SWMTKN-1-2iz51xqg59ep62z8hnbahljw0qbk8rlbwkv6xff5dbkfroj3uo-dew5gnpd9sitcalxmx0t8vpbt 10.158.0.5:2377
	...

### Crear otra instancia/nodo 

	$ docker-machine create swarm-worker-1 \   
        	--engine-install-url experimental.docker.com \
        	-d google \
        	--google-machine-type g1-small \     
        	--google-zone southamerica-east1-a \
        	--google-disk-size "20" \
        	--google-tags swarm \
        	--google-project <Project-ID>`

Y otro instancia llamadas swarm-worker-2 ... y las que quieras...

### Cambiar las variables de entorno para hacer el join a la instancia manager.
`$ eval $(docker-machine env swarm-worker-1)`

`$ docker swarm join --token SWMTKN-1-2iz51xqg59ep62z8hnbahljw0qbk8rlbwkv6xff5dbkfroj3uo-dew5gnpd9sitcalxmx0t8vpbt 10.158.0.5:2377`


### Volver a cambiar las variables para ver los nodos xD
`$ eval $(docker-machine env swarm-manager)`

`$ docker node ls` 

	ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
	7pwhz8zj3vr565vkqluc8lom3 *   swarm-manager       Ready               Active              Leader              1.12.6
	3ap83zjm9obpl0at0vv3zwvsh     swarm-worker-1      Ready               Active                                  1.12.6
	pnmycyne8vd6fb79y8i           swarm-worker-2      Ready               Active                                  1.12.6



