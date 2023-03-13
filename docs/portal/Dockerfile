ARG CODE_VERSION=master
FROM node:16 as builder

ARG PORTAL_HOSTNAME

ENV APP gitops
ENV BASENAME /

RUN echo "PORTAL: ${PORTAL_HOSTNAME}"

RUN mkdir -p /data-portal
# COPY ./data-portal /data-portal
RUN git clone https://github.com/uc-cdis/data-portal.git
WORKDIR /data-portal

RUN git checkout ${CODE_VERSION}

RUN COMMIT=`git rev-parse HEAD` && echo "export const portalCommit = \"${COMMIT}\";" >src/versions.js \
    && VERSION=`git describe --always --tags` && echo "export const portalVersion =\"${VERSION}\";" >>src/versions.js

COPY overrides/webpack.config.js webpack.config.js
COPY configurations/${PORTAL_HOSTNAME}/ /overrides
COPY overrides/overrides.sh .
RUN bash overrides.sh

RUN npm install
RUN npm ci

RUN npm i --save speed-measure-webpack-plugin
ENV NODE_ENV=production

COPY overrides/runWebpack.sh runWebpack.sh
COPY overrides/getSchema.js /data-portal/data/getSchema.js
RUN bash runWebpack.sh

FROM nginx:latest

COPY overrides/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /data-portal/build/*.js /data-portal/build/index.html /usr/share/nginx/html/
COPY --from=builder /data-portal/data /usr/share/nginx/html/data
COPY --from=builder /data-portal/src/img/ /usr/share/nginx/html/src/img/
COPY --from=builder /data-portal/src/css/ /usr/share/nginx/html/src/css/

COPY overrides/dockerStart.sh dockerStart.sh
CMD bash ./dockerStart.sh