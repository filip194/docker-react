# PRODUCTION Dockerfile
# MULTI_STEP BUILD: phases begin with 'FROM' keyword

# naming phases:
# FROM node:alpine as builder
# this kind of naming won't work when we deploy to AWS: this currently will fail if you attempt to use a named builder

# STEP/PHASE 1
FROM node:alpine

USER node

RUN mkdir -p /home/node/app
WORKDIR /home/node/app

# package.json will be copied to '/app' directory
COPY --chown=node:node ./package.json ./
RUN npm install
# after dependecies are installed we will be copying everything else from our project dir into image
# this copying of the files is not actually needed as in docker-compose file there is volume mounting ''.:/home/node/app', everything from current dir to /home/node/app
COPY --chown=node:node ./ ./
RUN npm run build

# PHASE 2
FROM nginx
# exposing port 80 for Elasticbeanstalk to map incoming traffic to
# this instruction is not going to do anything for us developers or image building
EXPOSE 80
# copying from first phase; --from <somewhere> <to_somewhere>
# COPY --from=builder /home/node/app/build /usr/share/nginx/html -> this only works if builder above is named
# starting nginx container automatically executes starting command for nginx server
COPY --from=0 /home/node/app/build /usr/share/nginx/html
