#import "@preview/diagraph:0.2.0": *

/* Concept map graph:

Please help me with a concept map using dot language, saying digraph, to illustrate a concept map where
1. The nodes or elements contains the followings: "Raw GEM data", "Standard GEM data", "SFTP server", "NAS", "Local User", and "Local Drive".
2. Raw GEM data is stored on NAS, and local user can download and upload the raw data via the SFTP protocol. 
3. Local user need to convert the raw data into the standard data before any process. The converted standard GEM data is temporarily stored in local drive.


*/

#set text( // Set main text: https://typst.app/docs/reference/text/text/
  font: "New Computer Modern",
  size: 10pt
)

#set page( // Set page: https://typst.app/docs/reference/layout/page/
  paper: "a4",
  margin: (x: 1.5cm, y: 2.1cm),
  header: align(right)[
    地電磁資料雲端儲存架構構想
  ],
  numbering: "1", // numbering the page
)

#set par( // Set paragraph: https://typst.app/docs/reference/layout/par/
  justify: true, // Hyphenation will be enabled for justified paragraphs
  leading: 0.52em, // The spacing between lines
)

#set heading(numbering: "1.a.") // Numbering heading: https://typst.app/docs/reference/meta/heading/

// https://typst.app/docs/tutorial/advanced-styling/
#show: rest => columns(1, rest) 

= 簡介
== 動機與目的

目前工作流程：
#render(read("./current_workflow.dot"))

#render(read("./new_workflow_1.dot"))



=== Julia interface 

This is suggested by ChatGPT.
```julia
using Distributed

# Add workers for parallel processing
addprocs(4)  # Add the desired number of worker processes

# Load and filter data in parallel
@everywhere using DataFrames
@everywhere using CSV

@time begin
    df_files = ["gs://your-bucket-name/your-file-part1.csv", 
                "gs://your-bucket-name/your-file-part2.csv",
                # Add more file paths as needed
               ]

    function load_and_filter(file_path)
        return CSV.File(file_path) |>
               DataFrame |>
               x -> filter(row -> start_date <= row[:datetime] <= end_date, x)
    end

    dfs = @distributed vcat for file in df_files
        load_and_filter(file)
    end

    merged_df = vcat(dfs...)
end
```

== DuckDB

- #link("https://duckdb.org/why_duckdb.html")[Why DuckDB?]

=== I have a conversation with ChatGPT...

ChatGPT says:

- DuckDB can handle a large number of tables (> 100000) with a large number of rows (e.g., 86400 rows) without any issues.
- DuckDB is optimized for in-memory processing; whether the queried data can be fit into memory should be concerned.
- DuckDB is an embedded database system, you don’t need to install any DBMS server software. You can simply copy the database file to the host machine such as your NAS. 


Create the database file: 
```bash
# in bash
duckdb /path/to/new/database/file
# The file can have any extension, but common choices are .db, .duckdb, or .ddb.
```


Create a table from a csv file:
```sql
CREATE TABLE table1 (name VARCHAR, ID INTEGER, job VARCHAR);
COPY table1 FROM '/path/to/table1.csv' (FORMAT csv, HEADER true);
```

Query data from tables having the format of "XXXX_YYYYMMDD_YYY", where "XXXX" denotes the station, and "YYY" denotes for observation type, and "YYYYMMDD" is for the datetime of the observation:

```sql
SELECT * FROM YULI_2022*; # select all data from YULI station observed in 2022 of any type
# DuckDB will automatically add null values to the result set for columns that do not exist in a particular table.

SELECT * FROM *_*_Mag WHERE SUBSTR(table_name, 6, 8) BETWEEN '20120101' AND '20221231'; # select data in the time range of 2012 to 2022 
# TODO: You should ask for what are good practices for naming a table in order to efficiently query data from different tables

```


It is possible to systematically create your 100000 tables using script:

```julia

using DuckDB

# Set the path to the directory containing the CSV files
csv_dir = "/path/to/csv/files"

# Connect to the DuckDB database
con = DuckDB.DBInterface.connect(DuckDB.DB, ":memory:")

# Loop through the CSV files in the directory
for filename in readdir(csv_dir)
    if endswith(filename, ".csv")
        # Get the table name from the file name
        table_name = splitext(filename)[1]

        # Create the table in DuckDB
        DuckDB.DBInterface.execute(con, "CREATE TABLE $table_name AS SELECT * FROM read_csv('$csv_dir/$filename')")
    end
end

```

== References

Related packages

#list(
  [#link("https://github.com/JuliaCloud/AWS.jl")[AWS.jl]], 
  [#link("https://github.com/rana/GCP.jl")[GCP.jl]],
  [#link("https://juliacloud.github.io/GoogleCloud.jl/latest/")[GoogleCloud.jl]]

)

Google cloud
#list(
  [#link("https://cloud.google.com/storage/docs/gsutil#should-you-use")[`gsutil`]],
  [#link("https://cloud.google.com/storage/docs/discover-object-storage-gcloud")[`gcloud storage` CLI]]
)

Discussions:
#list(
  [#link("https://stackoverflow.com/questions/69528312/working-with-google-cloud-storage-in-julia-applications")[Working with google cloud storage in julia applications]]
)

Tutorial using Julia:
- #link("https://pub.towardsai.net/exploring-julia-programming-language-mongodb-1005b79f59f9")[Exploring Julia Programming Language: MongoDB]; #link("https://felipenoris.github.io/Mongoc.jl/stable/")[Mongoc.jl is a MongoDB driver for the Julia Language.]
  - Also refer: #link("https://aws.amazon.com/tw/nosql/")[NoSQL]
- #link("https://medium.com/@kurtcaglar777/working-with-databases-in-julia-56685ca7c3cb")[Working with Databases in Julia],
- #link("https://mechanicalrabbit.github.io/DataKnots.jl/stable/")[DataKnots.jl (seems related to NoSQL)]
- #link("https://medium.com/juliazoid/welcome-to-duckdb-3c4e75f50b97")[Julia with DuckDB]

