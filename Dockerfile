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
# Start ZAP in headless mode in the background\n\
zap.sh -daemon -host 0.0.0.0 -port 8080 -config api.disablekey=true -config api.addrs.addr.name=.* -config api.addrs.addr.active=true &\n\
\n\
echo "ZAP is starting in the background..."\n\
echo "Starting MCP server immediately to pass Azure health probes..."\n\
npm start' > /app/start.sh && chmod +x /app/start.sh

# Switch back to zap user for security if possible, 
# but ZAP needs some permissions. zaproxy image uses user 'zap'.
USER zap

# Expose MCP server port
EXPOSE 3000

# Command to run the startup script
ENTRYPOINT ["/app/start.sh"]
