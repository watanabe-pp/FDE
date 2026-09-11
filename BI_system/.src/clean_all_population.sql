-- Rawデータプレビュー
SELECT *
FROM "raw-catalog-watanabe"."raw_all_population_watanabe";

-- Curatedデータプレビュー
SELECT *
FROM "raw-catalog-watanabe"."curated_all_population_watanabe";

-- ヘッダー削除
ALTER TABLE `raw-catalog-watanabe`.`raw_all_population_watanabe`
SET TBLPROPERTIES (
    'skip.header.line.count' = '8'
);

-- カラム削除
CREATE TABLE "curated_all_population_watanabe"
WITH (
    format = 'TEXTFILE',
    write_compression = 'NONE',
    field_delimiter = ',',
    external_location = 's3://storage-watanabe/curated-watanabe/curated-all-population-watanabe'
) AS
SELECT
    TRY_CAST(
        SPLIT_PART(col0,'_',2)
        AS VARCHAR
    ) AS "地域",
    TRY_CAST(
        REPLACE(REPLACE(TRIM(col61), '"', ''), ',', '')
        AS INTEGER
    ) AS "総人口",
    TRY_CAST(
        REPLACE(REPLACE(TRIM(col62), '"', ''), ',', '')
        AS INTEGER
    ) AS "男性人口",
    TRY_CAST(
        REPLACE(REPLACE(TRIM(col63), '"', ''), ',', '')
        AS INTEGER
    ) AS "女性人口"
FROM "raw-catalog-watanabe"."raw_all_population_watanabe";

-- 拡張子設定
ALTER TABLE `raw-catalog-watanabe`.`curated_all_population_watanabe`
SET TBLPROPERTIES (
    'classification' = 'csv'
);