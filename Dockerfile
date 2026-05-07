# Use the official ZAP stable image
FROM zaproxy/zap-stable

# Install Node.js
USER root
RUN apt-get update && apt-get install -y curl
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Create app directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy server code
COPY index.js ./

# Create a startup script
RUN echo '#!/bin/bash\n\
# Start ZAP in headless mode\n\
zap.sh -daemon -host 0.0.0.0 -port 8080 -config api.disablekey=true -config api.addrs.addr.name=.* -config api.addrs.addr.active=true &\n\
\n\
# Wait for ZAP to start\n\
until curl -s http://localhost:8080 > /dev/null; do\n\
  echo "Waiting for ZAP to start..."\n\
  sleep 2\n\
done\n\
\n\
echo "ZAP started, starting MCP server..."\n\
npm start' > /app/start.sh && chmod +x /app/start.sh

# Switch back to zap user for security if possible, 
# but ZAP needs some permissions. zaproxy image uses user 'zap'.
USER zap

# Expose MCP server port
EXPOSE 3000

# Command to run the startup script
ENTRYPOINT ["/app/start.sh"]
