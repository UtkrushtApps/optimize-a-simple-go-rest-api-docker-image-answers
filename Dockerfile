# Use Go base image for build stage
FROM golang:1.21-alpine AS builder
WORKDIR /app
# Only copy go.mod and go.sum first for better layer re-use
COPY go.mod .
COPY go.sum .
RUN go mod download
# Now copy the rest of the source
COPY . .
# Build the Go app as a statically linked binary
RUN CGO_ENABLED=0 go build -o server ./

# Use a minimal base for the final image
FROM scratch
WORKDIR /app
# Copy compiled Go binary
COPY --from=builder /app/server ./server
# (Optional) If you serve static files, copy them as well:
# COPY --from=builder /app/static ./static
EXPOSE 8080
USER nobody
ENTRYPOINT ["/app/server"]
