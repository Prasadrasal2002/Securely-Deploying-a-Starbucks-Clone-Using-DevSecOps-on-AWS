# Stage 1: Build React App
FROM node:18 AS builder

# Set working directory
WORKDIR /app

# Copy only dependency files and install
COPY package*.json ./
RUN npm install

# Then copy rest of your app
COPY public ./public
COPY src ./src
COPY tailwind.config.js ./

# Build app
RUN npm run build

# Stage 2: Serve app with Nginx
FROM nginx:alpine

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy built assets from React app
COPY --from=builder /app/build /usr/share/nginx/html

# Copy custom nginx config (optional)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]

