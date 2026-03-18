FROM node:20-alpine as deps

RUN apk add --no-cache libc6-compat