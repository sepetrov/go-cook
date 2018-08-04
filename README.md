# Go Cook

```bash
# Build the Docker image
make build

# Start the Docker container
make up

# SSH into the Docker container
make exec

# Build the side chain and start the Go server
bash ./build/dapchain.sh

# Start the client server
bash ./build/webclient.sh
```

Open the application on http://localhost:9000