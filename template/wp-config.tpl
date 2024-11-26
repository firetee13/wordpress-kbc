<?php
define('DB_NAME', '${db_name}');
define('DB_USER', '${db_user}');
define('DB_PASSWORD', '${db_password}');
define('DB_HOST', '${db_host}');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

/* Authentication Unique Keys and Salts */
define('AUTH_KEY',         '${auth_key}');
define('SECURE_AUTH_KEY',  '${secure_auth_key}');
define('LOGGED_IN_KEY',    '${logged_in_key}');
define('NONCE_KEY',        '${nonce_key}');
define('AUTH_SALT',        '${auth_salt}');
define('SECURE_AUTH_SALT', '${secure_auth_salt}');
define('LOGGED_IN_SALT',   '${logged_in_salt}');
define('NONCE_SALT',       '${nonce_salt}');

define('WP_DEBUG', false);
/* WordPress database table prefix. */
\$table_prefix = 'wp_';

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';