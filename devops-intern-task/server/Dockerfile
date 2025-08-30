# Use Node.js official image
FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install app dependencies
RUN npm ci --only=production

# Copy app source code
COPY . .

# Expose the port the app runs on
EXPOSE 8080

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Change ownership of the app directory to nodejs user
RUN chown -R nodejs:nodejs /usr/src/app
USER nodejs

# Command to run the application
CMD ["node", "index.js"]
