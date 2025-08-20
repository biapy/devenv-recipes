<?php

/**
 * @copyright 2025 Biapy
 * @license MIT
 */

declare(strict_types=1);

use App\Kernel;
use Symfony\Bundle\FrameworkBundle\Console\Application;

require __DIR__.'/../bootstrap.php';

$env = $_SERVER['APP_ENV'] ?? 'dev';
$debug = (bool) ($_SERVER['APP_DEBUG'] ?? false);

/** @psalm-suppress TypeDoesNotContainType */
if (!is_string($env)) {
    throw new RuntimeException('APP_ENV environment variable is not a string.');
}

$kernel = new Kernel($env, $debug);

return new Application($kernel);
