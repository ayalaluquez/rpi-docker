## Instalación de WordPress con Docker Compose 

Instalación de stack de aplcaciones LEMP (Linux, Nginx, MySQL y PHP) para WordPress. Los contenedores incluiyen base de datos MySQL, servicio web Nginx y WordPress. También la instalación de los certificados Let's Encrypt con certbot.

Prerrequisitos:

- Docker compose instalado
- Nombre de dominio resgitrado. 

    
## Configuración de servidor web (maje-https.conf)

Primero se utiliza el archivo maje.conf con la configurción del puerto 80, esto permitirá utilizar certbot para obtener el certificado. Una vez que haya obtenido el certificado incluiremos la configuración de nginx para servir el sitio al puerto 443 de 'maje-https.conf'. 


### Sobre la configuración Nginx:

	location ~ /.well-known/acme-challenge 
	este location manejará las solicitudes al directorio .well-known, donde certbot colocará un archivo temporal para validar que el DNS de nuestro dominio se resuelva en mismo servidor.

	location / try_files
	busca archivos que coincidan con las solicitudes y cuando obtiene un estado 404 Not Found, pasa el control al archivo index.php, en este caso de Wordpress. 

	location ~ \.php$
	Dado que Nginx requiere un gestor de procesado independiente para PHP, como php-fpm PHP (FastCGI Process Manager),utilizamos la imagen de Docker basada en php:fpm para configuraciones especificas de fastCGI para enviar las solicitudes a contenedor de wordpres. 

	location ~* \.(css|gif|ico|jpeg|jpg|js|png)$
	garantiza que estos tipos de archivos sean almacenables en cache.

_(opcional) 

	server_tokens off; Para ocultar la versión de nginx en la página de error

	Los add_header configuración de seguridad para el encabezado del sitio 
	
	 X-Frame-Options "SAMEORIGIN"; Evitar ataques Clickjacking
	 X-XSS-Protection "1; mode=block"; Proteje de ataque XSS
         X-Content-Type-Options "nosniff"; Protección de detección de contenido por de rastreo MIME
	 Content-Security-Policy "default-src"; Agregar una lista de blanca de cosos que sitio puede ejecutar
         Strict-Transport-Security; Toda la comunicación se envia a través de https  

## Sobre Docker compose

	image: Esto le dice a Compose qué imagen extraer para crear el contenedor.
	
	container_name: Es el nombre que se le dará al contenedor, si no se especifica un nombre, Docker-troll tomará un nombre random tipo 'loving_horse'.
	
	restart:  El valor unless-stopped reinica el container si el container no se de detuvo manualmente.
	Otras opciones:
		on-failure: reinica el contenedor si el servicio devuelve un valor distinto a 0.
		on: no reinicia automaticamente (default)
		always: siempre reinicia el contenedor si se detine. 
		
	env_file: esta opción es para agregar variables de entorno desde un archivo, ej, .env.
	
	environment: se definen las variables de entorno adicionales, más allá de las definidas el archivo .env
	
	volumes: el punto de montaje para contenedores. De esta manera es posible compartir el código de la aplicación con otros contenedores.
	
	networks: Por defecto, docker-compose configura una red única para la aplicación. Ladirección ip cambiar cuando se actualiza el docker compose.
	
	depends_on: Esta opción asegura que los contenedores se iniciarán en orden de dependencia.


### Opciones de cerbot

	--webroot: para que certbot puede acceder a los recursos desde el servidor que responde a un nombre de dominio.
	--webroot-path: especifica la ruta del directorio webroot.
	--no-eff-email: para no recibir spam de Electronic Frontier Foundation (EFF). 
	--staging: Para usar el entorno de ensayo Let's Encrypt para obtener certificados de prueba. El uso de esta opción permite probar configuración y evitar posibles límites de solicitud de dominio.
	-d:  especificar nombres de dominio que le gustaría aplicar la solicitud del certificado.  

## Puesta en marcha 🚀
 	docker-compose up -d
 
### verificar el estado de los contenedores
	docker-compose ps

###### La salida de cerbot debe ser 0

	$ docker-compose ps
 	
	Name                Command               State                     Ports                  
	--------------------------------------------------------------------------------------------
	certbot   certbot certonly --webroot ...   Exit 1                                           
	db        docker-entrypoint.sh --def ...   Up       3306/tcp, 33060/tcp                     
	web       nginx -g daemon off;             Up       0.0.0.0:443->443/tcp, 0.0.0.0:80->80/tcp
	wp        docker-entrypoint.sh php-fpm     Up       9000/tcp   


Si devuelve un valor diferente a 0, es por que algo no salió bien. Y.. verifica

	$ docker-compose logs certbot
	
	Attaching to certbot
	certbot    | Saving debug log to /var/log/letsencrypt/letsencrypt.log
	certbot    | Plugins selected: Authenticator webroot, Installer None
	certbot    | Renewing an existing certificate
	certbot    | An unexpected error occurred:
	certbot    | There were too many requests of a given type :: Error creating new order :: too many certificates already issued for exact set of domains: rosalia.pytrix.me,www.rosalia.pytrix.me: see https://letsencrypt.org/docs/rate-limits/
	certbot    | Please see the logfiles in /var/log/letsencrypt for more details.

En este caso, como se ha realizado muchas solicitudes, letsencrypt baneeo las solicitudes, con la opción --staging es posible evadir esos limites de solicitudes.

En el archivo yml, en servicio de cerbot: 
	
	certonly --webroot --webroot-path=/var/www/html --email tetrix@riseup.net --agree-tos --no-eff-email --staging -d rosalia.pytrix.me -d www.rosalia.pytrix.me

Y  .... para que recrear el contenedor sin afectar las dependencias 

	$ docker-compose up --force-recreate --no-deps certificado

Tambien se pude agregar --force-renewal, si sigue con errores. 
	
	certonly --webroot --webroot-path=/var/www/html --email tetrix@riseup.net --agree-tos --no-eff-email --staging --force-renewall -d rosalia.pytrix.me -d www.rosalia.pytrix.me	

_Es normal renegar con el certbot... no te frustres xD 

Verifica que el certificado se creo en la carpeta /etc/lesencrypt/live y que el contenedor tenga acceso, sera necesario para la configuración de nginx, si no exiten estos archivo el servicio nginx no iniciará.
	
	$ docker-compose exec nginx ls -la /etc/letsencrypt/live
	ó
	
	$ docker exec nginx ls -la /etc/letsencrypt/live

	total 16
	drwx------    3 root     root          4096 Sep  2 00:19 .
	drwxr-xr-x    9 root     root          4096 Sep  3 17:59 ..
	-rw-r--r--    1 root     root           740 Sep  2 00:19 README
	drwxr-xr-x    2 root     root          4096 Sep  3 17:59 maje.duckdns.org
	
	
Ahora configuramo el nginx para que sirva el sitio con https. Primero, detener el contenedor nginx
        

	$ docker-compose stop nginx

Agrega el archivo de configuración del archivo para el puerto 443 en el docker-compose.yml 
```nginx:
 depends_on:
..
..
 volumes:
./maje-https.conf:/etc/nginx/conf.d/maje.conf
..
..
```
Y para que no se reinicie todos lo contenedores y que no afecte las dependencias.
	$ docker-compose up --force-recreate --no-deps nginx
        ó la vieja confiable xD
	$ docker-compose up -d


Y ya... me debes una birra ;)
