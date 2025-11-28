# Use official Nginx image
FROM nginx:1.25-alpine

# Copy custom nginx configuration
COPY application/nginx.conf /etc/nginx/nginx.conf

# Copy static HTML content
COPY application/index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/health || exit 1

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
