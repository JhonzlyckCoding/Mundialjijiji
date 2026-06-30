FROM node:18-alpine
WORKDIR /usr/src/app
ENV NODE_ENV=production
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3017
CMD ["npm", "start"]