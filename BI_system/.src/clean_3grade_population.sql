-- Rawデータプレビュー
SELECT *
FROM "raw-catalog-watanabe"."raw_3grade_population_watanabe";

-- Curatedデータプレビュー
SELECT *
FROM "raw-catalog-watanabe"."curated_3grade_population_watanabe";

-- ヘッダー削除
ALTER TABLE `raw-catalog-watanabe`.`raw_3grade_population_watanabe`
SET TBLPROPERTIES (
    'skip.header.line.count' = '13'
);

-- カラム削除
CREATE TABLE "curated_3grade_population_watanabe"
WITH (
    format = 'TEXTFILE',
    write_compression = 'NONE',
    field_delimiter = ',',
    external_location = 's3://storage-watanabe/curated-watanabe/curated-3grade-population-watanabe'
) AS
SELECT
    TRY_CAST(
        SPLIT_PART(col2,'_',2)
        AS VARCHAR
    ) AS "地域",
    TRY_CAST(
        REPLACE(REPLACE(TRIM(col4), '"', ''), ',', '')
        AS INTEGER
    ) AS "総人口",
    
    TRY_CAST(
        REPLACE(REPLACE(TRIM(col5), '"', ''), ',', '')
        AS INTEGER
    ) AS "14歳以下人口",
    TRY_CAST(
        REPLACE(REPLACE(TRIM(col6), '"', ''), ',', '')
        AS INTEGER
    ) AS "15～64歳人口",
    TRY_CAST(
        REPLACE(REPLACE(TRIM(col7), '"', ''), ',', '')
        AS INTEGER
    ) AS "65歳以上人口"
FROM "raw-catalog-watanabe"."raw_3grade_population_watanabe" t
WHERE CAST(t.col0 AS VARCHAR) = '2020年'
  AND NOT (
      t.col3 IS NULL OR TRIM(t.col3) = ''
      AND EXISTS (
          SELECT 1
          FROM "raw-catalog-watanabe"."raw_3grade_population_watanabe" x
          WHERE CAST(x.col0 AS VARCHAR) = '2020年'
            AND SPLIT_PART(x.col2, '_', 2)
                = SPLIT_PART(t.col2, '_', 2)
            AND x.col3 = '※'
      )
  );

-- 拡張子設定
ALTER TABLE `raw-catalog-watanabe`.`curated_3grade_population_watanabe`
SET TBLPROPERTIES (
    'classification' = 'csv'
);