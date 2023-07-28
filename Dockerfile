# Production web Dockerfile. This is a multi-step docker image

########## FIRST STEP: FRONTEND BUILD #######
FROM node:20 as frontendbuild

WORKDIR /app

#first, we copy the package.json and install the dependencies
COPY site/package*.json ./
RUN npm install

#then we copy the codebase and build it. If there are no changes to the
#package json, the installation proces will be cached in a layer
COPY site/ .
RUN npm run build

########## FINAL STEP: PRODUCTION IMAGE #######
FROM nginx

#copy the frondend files generated in the previous step
COPY --from=frontendbuild /app/dist /usr/share/nginx/html
