DB_URL=postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable

postgres:
	sudo docker run --name postgres12 --network bank-network -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:12-alpine
createdb:
	sudo docker exec -it postgres12 createdb --username=root --owner=root simple_bank
dropdb:
	sudo docker exec -it postgres12 dropdb  simple_bank
migrateup:
	migrate -path db/migration -database "$(DB_URL)" -verbose up

migrateup1:
	migrate -path db/migration -database "$(DB_URL)" -verbose up 1

migratedown:
	migrate -path db/migration -database "$(DB_URL)" -verbose downmigra

migratedown1:
	migrate -path db/migration -database "$(DB_URL)" -verbose down 1

new_migration:
	migrate create -ext sql -dir db/migration -seq $(name)

migrationversion:
	migrate -path db/migration -database "$(DB_URL)" -verbose version

sqlc:
	sqlc generate
test:
	go test -v -cover ./...
server:
	go run main.go
mock:
	mockgen -package=mockdb github.com/huyhoangvp002/simplebank/db/sqlc  Store  > db/mock/store.go

.PHONY: postgres createdb dropdb migrateup migratedown sqlc test server mock migratedown1 migrateup1 new_migration migrationversion
# .PHONY is used to indicate that these targets do not represent files, but rather commands
# This prevents make from looking for files with the same names as the targets
# and ensures that the commands are always executed when invoked.				