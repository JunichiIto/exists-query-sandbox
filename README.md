# exists-query-sandbox
Sandbox app for exists query

## Requirements

- PostgreSQL

## Run test

```
rails db:setup
bundle exec rspec
```

It might take a few seconds to setup test data and the result will be:

```
Rehearsal -------------------------------------------
Uniq:     0.010000   0.000000   0.010000 (  0.092660)
Exists:   0.000000   0.000000   0.000000 (  0.003188)
---------------------------------- total: 0.010000sec

              user     system      total        real
Uniq:     0.000000   0.000000   0.000000 (  0.083102)
Exists:   0.000000   0.000000   0.000000 (  0.002978)

Exists is 27.902036 times faster.

Uniq:
EXPLAIN for: SELECT DISTINCT "posts".* FROM "posts" INNER JOIN "comments" ON "comments"."post_id" = "posts"."id" INNER JOIN "likes" ON "likes"."post_id" = "posts"."id"
                                     QUERY PLAN
-------------------------------------------------------------------------------------
 HashAggregate  (cost=807.54..808.14 rows=60 width=52)
   Group Key: posts.id, posts.title, posts.created_at, posts.updated_at
   ->  Hash Join  (cost=173.14..602.17 rows=20537 width=52)
         Hash Cond: (comments.post_id = posts.id)
         ->  Seq Scan on comments  (cost=0.00..131.04 rows=3704 width=4)
         ->  Hash  (cost=159.27..159.27 rows=1109 width=56)
               ->  Hash Join  (cost=3.35..159.27 rows=1109 width=56)
                     Hash Cond: (likes.post_id = posts.id)
                     ->  Seq Scan on likes  (cost=0.00..130.97 rows=3697 width=4)
                     ->  Hash  (cost=2.60..2.60 rows=60 width=52)
                           ->  Seq Scan on posts  (cost=0.00..2.60 rows=60 width=52)
(11 rows)

Exists
EXPLAIN for: SELECT "posts".* FROM "posts" WHERE (EXISTS (SELECT * FROM comments c WHERE c.post_id = posts.id)
AND
EXISTS (SELECT * FROM likes l WHERE l.post_id = posts.id)
)
                                                  QUERY PLAN
--------------------------------------------------------------------------------------------------------------
 Nested Loop Semi Join  (cost=0.56..54.24 rows=15 width=52)
   ->  Nested Loop Semi Join  (cost=0.28..44.51 rows=30 width=56)
         ->  Seq Scan on posts  (cost=0.00..2.60 rows=60 width=52)
         ->  Index Only Scan using index_comments_on_post_id on comments c  (cost=0.28..6.33 rows=19 width=4)
               Index Cond: (post_id = posts.id)
   ->  Index Only Scan using index_likes_on_post_id on likes l  (cost=0.28..0.74 rows=18 width=4)
         Index Cond: (post_id = c.post_id)
(7 rows)
.

Finished in 15.24 seconds (files took 1.58 seconds to load)
1 example, 0 failures
```

## License

MIT License.