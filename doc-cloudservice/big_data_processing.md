# Processing Big data

## Using DuckDB ...

[From Zero to dbt: How to Analyze and Build Data Models from Spotify’s Million Playlist Data](https://medium.com/inthepipeline/from-zero-to-dbt-how-to-analyze-and-build-data-models-from-spotifys-million-playlist-data-241c3d8c9b5d)
Outline
- Load 30 GB of json files `AS` a table, and save it to a single `parquet` file.
- Use `jq` in bash for accessing and viewing json files in terminal.

A quick overview:

```duckdb
CREATE TABLE playlists AS 
SELECT UNNEST(playlists , recursive:= true) 
FROM read_json_auto('./mpd.slice*.json', maximum_object_size = 40000000);
```

1. Load data from all files matching './mpd.slice*.json'
2. Select the content of the field "playlists" in these json files
3. Unnest the content of playlists recursively, which output as a table.
```duckdb
SET temp_directory='./tmp';
COPY playlist TO 'playlists.parquet' ;
```
4. Set `temp_directory` (see [DuckDB's configuration](https://duckdb.org/docs/configuration/overview)),
5. and save the file.

You can also refer to [this talk with ChatGPT](https://chatgpt.com/c/ee7d8f5b-3f35-411f-98f4-274ac1390c0a) to understand basic SQL concerning this example.

## ... with dbt

[From Zero to dbt: Part 2 — Modeling Spotify’s Million Playlist Dataset](https://medium.com/inthepipeline/from-zero-to-dbt-part-2-modeling-spotifys-million-playlist-dataset-e62e350d9945)

This article introduces how Data Build Tools (dbt) treat SQL queries as models and make data processing workflow that can be easily managed in a dbt project.

See also [Transforming Data Engineering: A Deep Dive into dbt with DuckDB](https://blog.det.life/transforming-data-engineering-a-deep-dive-into-dbt-with-duckdb-ddd3a0c1e0c2).