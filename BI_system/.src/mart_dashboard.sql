CREATE TABLE mart_prefecture_healthcare_watanabe
WITH (
    format = 'PARQUET',
    write_compression = 'SNAPPY',
    external_location = 's3://storage-watanabe/mart-watanabe/'
)
AS

WITH


-- 都道府県マスタ
prefecture_master AS (
    SELECT *
    FROM (
        VALUES
            ('01', '北海道'),
            ('02', '青森県'),
            ('03', '岩手県'),
            ('04', '宮城県'),
            ('05', '秋田県'),
            ('06', '山形県'),
            ('07', '福島県'),
            ('08', '茨城県'),
            ('09', '栃木県'),
            ('10', '群馬県'),
            ('11', '埼玉県'),
            ('12', '千葉県'),
            ('13', '東京都'),
            ('14', '神奈川県'),
            ('15', '新潟県'),
            ('16', '富山県'),
            ('17', '石川県'),
            ('18', '福井県'),
            ('19', '山梨県'),
            ('20', '長野県'),
            ('21', '岐阜県'),
            ('22', '静岡県'),
            ('23', '愛知県'),
            ('24', '三重県'),
            ('25', '滋賀県'),
            ('26', '京都府'),
            ('27', '大阪府'),
            ('28', '兵庫県'),
            ('29', '奈良県'),
            ('30', '和歌山県'),
            ('31', '鳥取県'),
            ('32', '島根県'),
            ('33', '岡山県'),
            ('34', '広島県'),
            ('35', '山口県'),
            ('36', '徳島県'),
            ('37', '香川県'),
            ('38', '愛媛県'),
            ('39', '高知県'),
            ('40', '福岡県'),
            ('41', '佐賀県'),
            ('42', '長崎県'),
            ('43', '熊本県'),
            ('44', '大分県'),
            ('45', '宮崎県'),
            ('46', '鹿児島県'),
            ('47', '沖縄県')
    ) AS t (
        prefecture_code,
        prefecture_name
    )
),

-- 総人口
population_all AS (
    SELECT
        "地域" AS prefecture_name,
        SUM("総人口") AS total_population

        -- 追加候補
        -- ,SUM("男性人口") AS male_population
        -- ,SUM("女性人口") AS female_population

    FROM curated_3grade_population_watanabe
    GROUP BY
        "地域"
),

-- 年齢3区分人口
population_age AS (
    SELECT
        "地域" AS prefecture_name,

        SUM("14歳以下人口") AS population_14_under,
        SUM("15～64歳人口") AS population_15_64,
        SUM("65歳以上人口") AS population_65_over

    FROM curated_3grade_population_watanabe
    GROUP BY
        "地域"
),


-- 病院集計
hospital AS (
    SELECT
        "都道府県コード" AS prefecture_code,
        COUNT(DISTINCT "index") AS hospital_count

    FROM curated_hospital_watanabe
    GROUP BY
        "都道府県コード"
),


-- 診療所集計
clinic AS (
    SELECT
        "都道府県コード" AS prefecture_code,
        COUNT(DISTINCT "index") AS clinic_count

    FROM curated_clinic_watanabe
    GROUP BY
        "都道府県コード"
),


-- 薬局集計
pharmacy AS (
    SELECT
        "都道府県コード" AS prefecture_code,
        COUNT(DISTINCT "index") AS pharmacy_count

    FROM curated_pharmacy_watanabe
    GROUP BY
        "都道府県コード"
)


-- Mart生成
SELECT
    pm.prefecture_code AS "都道府県コード",
    pm.prefecture_name AS "都道府県名",
    allp.total_population AS "総人口",
    agep.population_65_over AS "65歳以上人口",

    -- 高齢化率
    ROUND(
        CAST(agep.population_65_over AS DOUBLE)
        / NULLIF(allp.total_population, 0)
        * 100,
        2
    ) AS "高齢化率",

    COALESCE(h.hospital_count, 0) AS "病院数",
    COALESCE(c.clinic_count, 0) AS "診療所数",
    COALESCE(p.pharmacy_count, 0) AS "薬局数",

    -- 人口10万人あたり病院数
    ROUND(
        CAST(COALESCE(h.hospital_count, 0) AS DOUBLE)
        / NULLIF(allp.total_population, 0)
        * 100000,
        2
    ) AS "人口10万人あたり病院数",

    -- 人口10万人あたり診療所数
    ROUND(
        CAST(COALESCE(c.clinic_count, 0) AS DOUBLE)
        / NULLIF(allp.total_population, 0)
        * 100000,
        2
    ) AS "人口10万人あたり診療所数",

    -- 人口10万人あたり薬局数
    ROUND(
        CAST(COALESCE(p.pharmacy_count, 0) AS DOUBLE)
        / NULLIF(allp.total_population, 0)
        * 100000,
        2
    ) AS "人口10万人あたり薬局数",

    -- --------------------------------------------------------
    -- 診療所1件あたり65歳以上人口
    -- 数値が大きいほど、診療所に対する高齢者人口が多い
    -- --------------------------------------------------------
    ROUND(
        CAST(agep.population_65_over AS DOUBLE)
        / NULLIF(c.clinic_count, 0),
        2
    ) AS "診療所1件あたり65歳以上人口"


    -- ========================================================
    -- 追加候補
    -- ========================================================

    -- 年少人口
    -- ,agep.population_14_under AS "14歳以下人口"

    -- 生産年齢人口
    -- ,agep.population_15_64 AS "15~64歳人口"

    -- 65歳以上人口10万人あたり診療所数
    -- 高齢者向け医療資源の充足度を見る場合はこちらも有用
    -- ,ROUND(
    --     CAST(COALESCE(c.clinic_count, 0) AS DOUBLE)
    --     / NULLIF(agep.population_65_over, 0)
    --     * 100000,
    --     2
    -- ) AS "65歳以上人口10万人あたり診療所数"

    -- 病院病床数
    -- ,COALESCE(h.hospital_total_beds, 0) AS "病院病床数"

    -- 診療所病床数
    -- ,COALESCE(c.clinic_total_beds, 0) AS "診療所病床数"

    -- 総病床数（病院 + 診療所）
    -- ,COALESCE(h.hospital_total_beds, 0)
    --      + COALESCE(c.clinic_total_beds, 0) AS "総病床数"

    -- 人口10万人あたり病床数
    -- ,ROUND(
    --     CAST(
    --         COALESCE(h.hospital_total_beds, 0)
    --         + COALESCE(c.clinic_total_beds, 0)
    --         AS DOUBLE
    --     )
    --     / NULLIF(allp.total_population, 0)
    --     * 100000,
    --     2
    -- ) AS "人口10万人あたり病床数"

    -- 高齢者人口1万人あたり病床数
    -- ,ROUND(
    --     CAST(
    --         COALESCE(h.hospital_total_beds, 0)
    --         + COALESCE(c.clinic_total_beds, 0)
    --         AS DOUBLE
    --     )
    --     / NULLIF(agep.population_65_over, 0)
    --     * 10000,
    --     2
    -- ) AS "65歳以上人口1万人あたり病床数"


FROM prefecture_master pm

LEFT JOIN population_all allp
    ON pm.prefecture_name = allp.prefecture_name

LEFT JOIN population_age agep
    ON pm.prefecture_name = agep.prefecture_name

LEFT JOIN hospital h
    ON pm.prefecture_code = h.prefecture_code

LEFT JOIN clinic c
    ON pm.prefecture_code = c.prefecture_code

LEFT JOIN pharmacy p
    ON pm.prefecture_code = p.prefecture_code;