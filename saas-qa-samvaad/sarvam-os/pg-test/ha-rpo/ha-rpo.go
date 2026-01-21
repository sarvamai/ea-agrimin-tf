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
	connStr := "postgres://app:y2YoHGAQZ9UmfVd0FBccj8P3CLL7E1Rxo8Vmy7lPQhrHUGNMAmnP5lFDBxNCzoUo@postgres-cluster-ro.postgres.svc.cluster.local:5432/app"
	ctx := context.Background()

	pool, err := pgxpool.New(ctx, connStr)
	if err != nil {
		log.Fatalf("Unable to connect to database: %v\n", err)
	}
	defer pool.Close()

	for {
		haRPO(ctx, pool)
		time.Sleep(1 * time.Second)
	}

}

func haRPO(ctx context.Context, replica *pgxpool.Pool) {
	replayTime, err := getReplicaReplayTime(ctx, replica)
	if err != nil || replayTime == nil {
		fmt.Println("HA RPO: replica replay time unavailable")
		return
	}

	rpo := time.Since(*replayTime)
	fmt.Println(" HA RPO (replication lag):", rpo)
}

func getReplicaReplayTime(ctx context.Context, pool *pgxpool.Pool) (*time.Time, error) {
	var t *time.Time
	err := pool.QueryRow(ctx,
		`SELECT pg_last_xact_replay_timestamp()`,
	).Scan(&t)
	return t, err
}
