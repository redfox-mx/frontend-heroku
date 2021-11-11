ARG NODE_VERSION=lts-alpine

###   BUILD STAGE   ###

# 1.- Descargamos la imagen de node para poder construir la aplicacion de angular
FROM node:${NODE_VERSION} AS builder

# declaramos el directorio de trabajo
WORKDIR /usr/app

# 2.- Copiamos solo los pacage*.json para prevenir instalacion de dependencias
#     de manera inecesaria. (Docker cache)
COPY package.json package-lock.json ./

# 3.- Instalamos las dependencias necesarias
RUN npm install --silent

# 4.- Copiamos todo el contenido actual para poder construir nuestra aplicacion
COPY . .

# 5.- Costruimos la aplicacion y guardamos sus "artefactos" en la carpeta dist
RUN npm run build

### SETUP STAGE ###

# 6.- Descargamos la version de nginx
FROM nginx:1.20-alpine

RUN rm -rf /usr/share/nginx/html/*

# 7.- Copiamos nuestros archivos de configuracion
COPY nginx /etc/nginx
COPY --from=builder /usr/app/dist /usr/share/nginx/html

CMD ["nginx", "-g", "daemon off;"]