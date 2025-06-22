# 1. Use Node.js official image
FROM node:18-alpine AS builder

# 2. Set working directory
WORKDIR /app

# 3. Install dependencies
COPY package.json package-lock.json ./
RUN npm install

# 4. Copy app source code
COPY . .

# 5. Build the Next.js app
RUN npm run build

# 6. Use a minimal image for production
FROM node:18-alpine

# 7. Set working directory
WORKDIR /app

# 8. Copy necessary files from builder
COPY --from=builder /app/pages ./pages
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# 9. Expose port and run the app
EXPOSE 3000
CMD ["npm", "start"]
