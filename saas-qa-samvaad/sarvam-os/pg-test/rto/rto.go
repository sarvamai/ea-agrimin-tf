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

	// RTO detection
	for {
		if !isPostgresUp(ctx, pool) {
			break
		}
		time.Sleep(1 * time.Second)
	}

	failureTime := time.Now()
	fmt.Println("Postgres DOWN at:", failureTime)

	// Recovery
	for {
		if isPostgresUp(ctx, pool) {
			break
		}
		time.Sleep(1 * time.Second)
	}

	recoveryTime := time.Now()
	fmt.Println("Postgres UP at:", recoveryTime)
	fmt.Println("RTO:", recoveryTime.Sub(failureTime))
}

func isPostgresUp(ctx context.Context, pool *pgxpool.Pool) bool {
	err := pool.Ping(ctx)
	if err != nil {
		return false
	}
	return true
}
