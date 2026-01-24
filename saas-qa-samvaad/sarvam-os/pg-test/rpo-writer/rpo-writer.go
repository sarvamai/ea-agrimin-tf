package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	// Standard CNPG RW Service string
	connStr := "postgres://app:y2YoHGAQZ9UmfVd0FBccj8P3CLL7E1Rxo8Vmy7lPQhrHUGNMAmnP5lFDBxNCzoUo@postgres-cluster-rw.postgres.svc.cluster.local:5432/app"
	ctx := context.Background()

	pool, err := pgxpool.New(ctx, connStr)
	if err != nil {
		log.Fatalf("Unable to connect to database: %v\n", err)
	}
	defer pool.Close()

	_, err = pool.Exec(ctx, "CREATE TABLE IF NOT EXISTS heartbeat (id BIGSERIAL PRIMARY KEY, node TEXT, inserted_at TIMESTAMPTZ NOT NULL DEFAULT now());")
	if err != nil {
		fmt.Println("Failed to create the table")
		return
	}
	for {
		insertHeartbeat(ctx, pool, "app-writer")
		time.Sleep(1 * time.Second)
	}
}

func insertHeartbeat(ctx context.Context, pool *pgxpool.Pool, node string) {
	_, err := pool.Exec(ctx,
		`INSERT INTO heartbeat (node, inserted_at) VALUES ($1, now())`,
		node,
	)
	if err != nil {
		log.Println("heartbeat insert failed:", err)
	}
}
