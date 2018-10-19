CREATE TABLE `accounts` (
  `id` char(26) NOT NULL COMMENT 'アカウントID',
  `login_id` varchar(255) NOT NULL COMMENT 'ログインID',
  `password` varchar(255) DEFAULT '' COMMENT '暗号化済みのパスワード',
  `last_name` varchar(128) DEFAULT NULL COMMENT '氏名（苗字）',
  `first_name` varchar(128) DEFAULT NULL COMMENT '氏名（名前）',
  `email` varchar(256) NOT NULL COMMENT 'メールアドレス',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '削除日時',
  PRIMARY KEY (`id`),
  KEY `idx_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='アカウントテーブル'