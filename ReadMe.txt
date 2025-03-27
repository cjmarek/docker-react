

# the -f tells the docker command to use the unusual Dockerfile.dev spelling 
docker build -f Dockerfile.dev .

you really need to re watch the video to understand the run when using volumes. I will never remember this shit.
But I will try to explain here anyway.
PWD = present working directory

Whenever you use volumes, you are trying to tell docker to always take a look at the files on the container and to compare
the files and folders to the source on the docker file. Anything on the dockerfile that has changed will reflect onto the container
because whatever got copied to the container becomes references to the dockerfile source. -v ${PWD}:/app is really a mapping instruction.
But we have a problem with the node_modules in the container because we deleted it. So by mentioning node_modules as -v /app/node_modules
without mapping :/app, then that tells docker not to try to find node_modules on the dockerfile.

to fire up a container with volumes references, 
docker run -p 3000:3000 -v /app/node_modules -v ${PWD}:/app [image id that came from the build]  

* by creating a docker-compose file, we no longer need to fire up a container from an image as we did above,
docker-compose up can kick off a build and then run the container, and not need to know about volumes and ports or image ID's, with this instead. . . 

docker-compose up

* And now you have a running container with your web app working from localhost:3000

* To run a unit test, you need to know the image ID, 
* NOTE docker build -f Dockerfile.dev . creates an image ID that is a guid. But docker-compose creates a friendly image id 'name' instead of a guid.
* If you use docker-compose up, 
* You must open yet another terminal to do docker ps 
* you need to run docker ps to see what the fucking image ID is, and it will be in the shape of a name!!! not a guid If you use docker-compose up
*
* now that we have a image id 'frontend-web', we can run the test (in this example, however leaving -it off gives less beautiful result) by

docker run [image id] npm run test  (* chaining on 'npm run test' acts as an OVERRIDE to the CMD ["npm", "run", "start"] and will invoke the unit test *)

docker run -it [image id]  npm run test       ( including -it gives a much nicer terminal output )

* But if you make a code change to the unit test, you will not see the change happen.

* To see any recent changes in the unit test, you can do this....

* start up another container with docker-compose up

* then you must open another terminal and issue 'docker ps' to get the fucking container id this time, not the image ID

* then you can run the unit test against the running container, this time use the fucking container id, not the image id

* to run a specfic command inside of a container, by using keyword 'exec', that will OVERRIDE the dockerfile commands of CMD ["npm", "run", "start"] in the container


docker exec -it [container id] npm run test

* and this will somehow also run the most current unit tests that you have.
* Also worth noting, this approach to running the tests works in such a way that you have all kinds of options . . . 
Watch Usage
> Press p to filter by a filename regex pattern.
> Press t to filter by a test name regex pattern.
> Press q to filter by a filename regex pattern.
> Press p to quit watch mode.
> Press Enter to trigger a test run.

* while running the tests. This method is the only approach that lets you use the testing options. Just annoying to do this way.
 



