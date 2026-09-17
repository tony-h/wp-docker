<?php
/******* Auto-Parsed Environment Variables *******/
// Use getenv() to ensure visibility in both Apache and CLI contexts
foreach (getenv() as $key => $value) {
    if (strpos($key, 'WP_CFG_') === 0) {
        $constant_name = substr($key, 7);
        if (!defined($constant_name)) {
            if (strtolower($value) === 'true') $value = true;
            if (strtolower($value) === 'false') $value = false;
            define($constant_name, $value);
        }
    }
}