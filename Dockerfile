# Build stage
FROM golang:1.21-alpine3.17 AS builder

WORKDIR /app

COPY . .
RUN go build -o main main.go

RUN apk add --no-cache curl
RUN curl -L https://github.com/golang-migrate/migrate/releases/download/v4.12.2/migrate.linux-amd64.tar.gz | tar xvz

# Run stage
FROM alpine:3.17

WORKDIR /app

# Copy built binary
COPY --from=builder /app/main /app/main

# Copy migrate binary
COPY --from=builder /app/migrate.linux-amd64 /app/migrate

# Copy configs and scripts
COPY app.env .
COPY start.sh .
RUN chmod +x /app/start.sh
COPY wait-for.sh .
RUN chmod +x wait-for.sh
# Copy migration files
COPY db/migration ./migration

EXPOSE 8080

ENTRYPOINT ["/app/start.sh"]
CMD [ "/app/main" ]
