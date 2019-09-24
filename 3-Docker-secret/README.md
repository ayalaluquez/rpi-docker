# Docker Secret 

Hay varias formas de utilizar variables de entornos para contenedores docker, una opción es escribir la variable directamente en los archivo compose, otra opción es utilizando un *env_file* pero estas opciones no son seguras. 

En muchos casos es importante tener el código y los archivos de configuración de forma publica y contar con un mecanimo seguro de almacenamiento de contraseñas u otros datos sensibles, por dicha, docker tiene un mecanimos que se llama docker secrets para gestionar varibles de entorno de forma más segura. 

Los secretos se definen en el archivo de docker compose y automaticamente en todos los nodos:

### Crear secretos 

`$ echo "pasword1234" | docker secret create mysql_root_password - `

`$ echo "pass_seguro-1234" | docker secret create mysql_password - `

Nota: es importante el - al final del comando

Es posible lista los secretos, pero no su contenido:

`$ docker secret ls`

	ID                          NAME                  DRIVER              CREATED             UPDATED
	6xe2kbxbocsptjh3uybat847g   mysql_password                            21 minutes ago      21 minutes ago
	uschx8psbzsg16f0fn66mgowz   mysql_root_password                       21 minutes ago      21 minutes ago



Una vez que creamos los secretos, se define en el docker compose de la siguiente manera:


	version: '3.7'
	services:
           db:
             image: mysql:latest
        .
        .
        .
	   environment:
     	      - MYSQL_DATABASE=swarm
              - MYSQL_ROOT_PASSWORD=/run/secrets/mysql_root_password
              - MYSQL_USER=nica
              - MYSQL_PASSWORD=/run/secrets/mysql_password
             .
             .
             .
	secrets:
  	   mysql_root_password:
    		external: true
           mysql_password:
    		external: true

Los secrets quedan disponibles en los contenedor en la ruta /run/secrets/

