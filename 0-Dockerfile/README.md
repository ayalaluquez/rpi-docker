Para crear una imageen es necesario un Dockerfile.

## Construir imagen con el archivo Dockerfile
En el directorio raíz de ese proyecto, ejecuta: 

	$ docker build -t nombreImagen .

Y eso seria todo!, docker build ejecuta cada instrucción del Dockerfile (FROM, COPY..etc) 

## Crear contendor usando la imagen ;)
	$ docker run --name nombreContenedor -p 80:80 -d nombreImagen

* Listar todos los contenedores 

		$ docker ps -a

* Listar todas las imagenes locales
		
		$ docker images

* Revisar los logs en un contendor
	
		$ docker logs nombreContenedor
 
* Eliminar contenedor
 	
		$ docker rm -f nombreContenedor

* Eliminar imagen
		
		$ docker rmi nombreImagen

* Inicar, detener y eliminar todos los contenedores
	
		$ docker start|stop|rm $(docker ps -a -q)

* Eliminar todas las imagenes
		
		$ docker rmi $(docker images -q)
