# we are creating here a dockerfile for the production environment
# this docker file is creating a production server, which means the code is not undergoing code changes like a dev environment would
# so we are not going to worry about volumes
# we are creating two parts where the second part is created from the first part, using the alias of 'builder' we came up with (builder could be foo)
# container 1 . . . The build phase
FROM node:16-alpine as builder
WORKDIR '/app'

# copy package.json to the temporary container (used as part of the image building process). 
# npm install will find package.json in the temp container, and will create a node_modules folder there
COPY package.json .
# There will also be a node_modules folder in our local folder. We don't need it. So we will delete the local node_modules folder because it is huge.
RUN npm install
# copy local files and folders over to temp container
COPY . .
# throw the build assets over into the build folder for production deployment
RUN npm run build

# container 2 . . . The Run phase, copy build directory over to nginx to serve the application from a nginx server
FROM nginx
# The container side folder structure came from the Docker hub repository documentation
COPY --from=builder /app/build /usr/share/nginx/html

# my ports 8080, 8081, 8082, 8083 are already being used, 8085 is one that is still available
# https://stackoverflow.com/questions/65874912/docker-error-response-from-daemon-ports-are-not-available-listen-tcp-0-0-0-0
#                     see AvailablePorts.png
# docker run -p 8085:80  [image id]
# nginx uses port 80 by default, so now, we can actually run this production version with docker run -p 8085:80  [image id] using Nginx web server http://localhost:8085