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

	for {
		drRPO(ctx, pool)
		time.Sleep(1 * time.Second)
	}
}

func getCurrentLSN(ctx context.Context, pool *pgxpool.Pool) (string, error) {
	var lsn string
	err := pool.QueryRow(ctx,
		`SELECT pg_current_wal_lsn()`,
	).Scan(&lsn)
	return lsn, err
}

func getLastArchivedLSN(ctx context.Context, pool *pgxpool.Pool) (string, error) {
	var lsn string
	err := pool.QueryRow(ctx,
		`SELECT last_archived_wal FROM pg_stat_archiver`,
	).Scan(&lsn)
	return lsn, err
}

func drRPO(ctx context.Context, pool *pgxpool.Pool) {
	currentLSN, err1 := getCurrentLSN(ctx, pool)
	archivedLSN, err2 := getLastArchivedLSN(ctx, pool)

	if err1 != nil || err2 != nil || archivedLSN == "" {
		fmt.Println("DR RPO: WAL info unavailable")
		return
	}

	var bytes int64
	err := pool.QueryRow(ctx,
		`SELECT pg_wal_lsn_diff($1, $2)`,
		currentLSN, archivedLSN,
	).Scan(&bytes)

	if err != nil {
		fmt.Println("DR RPO WAL diff failed:", err)
		return
	}

	fmt.Printf("DR RPO (WAL not archived): %d bytes\n", bytes)
}
