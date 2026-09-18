-- Rawデータプレビュー
SELECT *
FROM "raw-catalog-watanabe"."raw_pharmacy_watanabe";

-- Curatedデータプレビュー
SELECT *
FROM "raw-catalog-watanabe"."curated_pharmacy_watanabe";

-- カラム削除
CREATE TABLE "curated_pharmacy_watanabe"
WITH (
    format = 'TEXTFILE',
    write_compression = 'NONE',
    field_delimiter = ',',
    external_location = 's3://storage-watanabe/curated-watanabe/curated-pharmacy-watanabe'
) AS
SELECT
    CAST("id" AS VARCHAR) AS "Index",
    CAST("名称" AS VARCHAR) AS "機関名称",
    CAST("機関区分" AS VARCHAR) AS "機関区分",
    CAST("都道府県コード" AS VARCHAR) AS "都道府県コード",
    CAST("市区町村コード" AS VARCHAR) AS "市区町村コード"
FROM "raw-catalog-watanabe"."raw_pharmacy_watanabe";

-- 拡張子設定
ALTER TABLE `raw-catalog-watanabe`.`curated_pharmacy_watanabe`
SET TBLPROPERTIES (
    'classification' = 'csv'
);