#NOTE: Make sure that Docker is running in the background!!!!!
# we are creating here a dockerfile for the production environment
# this docker file is creating a production (nginx) server, which means the code is not undergoing code changes like a dev environment would.
# So we are not going to worry about volumes to make code changes hot load dynamically in the running application.
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
# When you run a build command, a build folder gets created over in the working directory (the temp container folder (/app) )
# throw the build assets over into the working directory app/build folder for production deployment
# After this point, we don't need any of the package.json, node modules etc that is in the temp container /app folder. Only needed those for doing a build
RUN npm run build

# This 'FROM' automatically marks the start of the second phase. So, previous block is now considerred all complete.
# See ProductionEnvironmentNginx.png for why nginx
# container 2 . . . The Run phase, copy ONLY the build directory over to nginx to serve the application from a nginx server.
# NOTE: All the other files (other than the build folder) are not needed in the final production folder, we only copy over the build folder.
# so container 2 is very much smaller.
FROM nginx
# tells elastic beanstalk, when it starts up the Docker container, we need to get a port mapped to port 80 to use for incoming traffic. So this is a elastic beanstalk specific instruction only.
EXPOSE 80
# We don't need to do all the volume crap in production. We can just copy everything, we don't expect development changes, hot loading at this point (which was the entire point with volumes)
# The container side folder structure came from the Docker hub repository documentation. How did I know to use  /usr/share/nginx/html? It is from the nginx documentation on docker hub.
# /app/build is the source of the copy operation.
# /usr/share/nginx/html is the target of the copy operation. 
COPY --from=builder /app/build /usr/share/nginx/html

# my ports 8080, 8081, 8082, 8083 are already being used, 8085 is one that is still available, so none of those can be used on the right side of the xxxx:xxxx
# The comment above is irrelevant here!
# Since this is not a development server, (Nginx web server is a production server), we always use 80 as Nginx web server port. And we are not here using local IIS anyway! So
# there are no port conflicts with ports 8080, 8081, 8082, 8083 are already being used as right hand ports into the application
# https://stackoverflow.com/questions/65874912/docker-error-response-from-daemon-ports-are-not-available-listen-tcp-0-0-0-0
#                     see AvailablePorts.png
#   What follows (lines 45 thru 47) is how to launch the production  Nginx web server. You can use any port for the left of :, and NOTE! You will not get the usual terminal output saying which URL to use to invoke the app.
#   so just assume 'docker run -p 3000whatever:80  [image id (from the build you just did)]' worked after you submited it.
#
# docker build .
# docker run -p 8085:80  [image id (from the build you just did)]
# nginx uses port 80 by default, so now, we can actually run this production version with docker run -p 8085:80  [image id] using Nginx web server http://localhost:8085
#CMD ["npm", "run", "start"]   <----NOPE, In this production dockerfile, we don't need this because Nginx automatically performs a default cmd start up of the web server container natively.