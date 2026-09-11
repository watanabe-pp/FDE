-- Rawデータプレビュー
SELECT *
FROM "raw-catalog-watanabe"."raw_clinic_watanabe";

-- Curatedデータプレビュー
SELECT *
FROM "raw-catalog-watanabe"."curated_clinic_watanabe";

-- カラム削除
CREATE TABLE "curated_clinic_watanabe"
WITH (
    format = 'TEXTFILE',
    write_compression = 'NONE',
    field_delimiter = ',',
    external_location = 's3://storage-watanabe/curated-watanabe/curated-clinic-watanabe'
) AS
SELECT
    CAST("id" AS VARCHAR) AS "Index",
    CAST("正式名称" AS VARCHAR) AS "機関名称",
    CAST("機関区分" AS VARCHAR) AS "機関区分",
    CAST("都道府県コード" AS VARCHAR) AS "都道府県コード",
    CAST("市区町村コード" AS VARCHAR) AS "市区町村コード",
    TRY_CAST(
        IF(TRIM(CAST("一般病床" AS VARCHAR)) = '', '0', TRIM(CAST("一般病床" AS VARCHAR)))
        AS INTEGER
    ) AS "一般病床",
    TRY_CAST(
        IF(TRIM(CAST("療養病床" AS VARCHAR)) = '', '0', TRIM(CAST("療養病床" AS VARCHAR)))
        AS INTEGER
    ) AS "療養病床",
    TRY_CAST(
        IF(TRIM(CAST("合計病床数" AS VARCHAR)) = '', '0', TRIM(CAST("合計病床数" AS VARCHAR)))
        AS INTEGER
    ) AS "合計病床"
FROM "raw-catalog-watanabe"."raw_clinic_watanabe";

-- 拡張子設定
ALTER TABLE `raw-catalog-watanabe`.`curated_clinic_watanabe`
SET TBLPROPERTIES (
    'classification' = 'csv'
);