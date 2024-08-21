# build front-end
FROM node:lts-alpine AS frontend

# 非腾讯云服务器可以删除此行
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.cloud.tencent.com/g' /etc/apk/repositories

# 非腾讯云服务器可以删除此行
RUN npm config set registry http://mirrors.cloud.tencent.com/npm/

RUN npm install pnpm -g

WORKDIR /app

COPY ./package.json /app

COPY ./pnpm-lock.yaml /app

RUN pnpm install

COPY . /app

RUN pnpm run build

# build backend
FROM node:lts-alpine as backend

# 非腾讯云服务器可以删除此行
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.cloud.tencent.com/g' /etc/apk/repositories

# 非腾讯云服务器可以删除此行
RUN npm config set registry http://mirrors.cloud.tencent.com/npm/

RUN npm install pnpm -g

WORKDIR /app

COPY /service/package.json /app

COPY /service/pnpm-lock.yaml /app

RUN pnpm install

COPY /service /app

RUN pnpm build

# service
FROM node:lts-alpine

# 非腾讯云服务器可以删除此行
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.cloud.tencent.com/g' /etc/apk/repositories

# 非腾讯云服务器可以删除此行
RUN npm config set registry http://mirrors.cloud.tencent.com/npm/

RUN npm install pnpm -g

WORKDIR /app

COPY /service/package.json /app

COPY /service/pnpm-lock.yaml /app

RUN pnpm install --production && rm -rf /root/.npm /root/.pnpm-store /usr/local/share/.cache /tmp/*

COPY /service /app

COPY --from=frontend /app/dist /app/public

COPY --from=backend /app/build /app/build

ENV OPENAI_API_BASE_URL="https://api.gptsapi.net"

ENV TIMEOUT_MS=300000

ENV OPENAI_API_MODEL=gpt-4o

EXPOSE 3002

CMD ["pnpm", "run", "prod"]
