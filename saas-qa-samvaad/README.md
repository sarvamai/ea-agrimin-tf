## Sarvam OS RPO and RTO Report

- Generate 100 GB data
```
kubectl cnpg pgbench postgres-cluster -n postgres \
  --job-name pgbench-init-100gb \
  -- --initialize --scale 7000

699900000 of 700000000 tuples (99%) of pgbench_accounts done (elapsed 789.54 s, remaining 0.11 s)
700000000 of 700000000 tuples (100%) of pgbench_accounts done (elapsed 789.65 s, remaining 0.00 s)
vacuuming... 
creating primary keys...
done in 1244.75 s (drop tables 0.00 s, create tables 0.01 s, client-side generate 789.82 s, vacuum 2.80 s, primary keys 452.12 s).                  
stream closed EOF for postgres/pgbench-init-100gb-gqfxp (pgbench)                                                                
```

- Confirm the data
```
\c app

SELECT pg_size_pretty(pg_database_size('app')) AS logical_size;
 logical_size 
--------------
 102 GB
(1 row)
```
- Small Loadtest to check WAL backups


```
 kubectl cnpg pgbench postgres-cluster -n postgres \
  --job-name pgbench-run-1 \
  -- --time 30 --client 16 --jobs 4
job/pgbench-run-1 created

pgbench (17.6 (Debian 17.6-2.pgdg13+1))                                                                       
starting vacuum...end.                                                                                        
transaction type: <builtin: TPC-B (sort of)>                                                                  
scaling factor: 7000                                                                                          
query mode: simple                                                                                            
number of clients: 16                                                                                         
number of threads: 4                                                                                          
maximum number of tries: 1                                                                                    
duration: 30 s                                                                                                
number of transactions actually processed: 84794                                                              
number of failed transactions: 0 (0.000%)                                                                     
latency average = 5.640 ms                                                                                    
initial connection time = 132.261 ms                                                                          
tps = 2836.739920 (without initial connection time)                                                           
stream closed EOF for postgres/pgbench-run-1-4rv9b (pgbench)   
```