<?php

/**
 * @copyright 2025 Biapy
 * @license MIT
 */

declare(strict_types=1);

use App\Kernel;
use App\Tests\PHPStan\PhpStanObjectManager;
use Doctrine\Persistence\ManagerRegistry;
use Symfony\Component\Dotenv\Dotenv;

require __DIR__.'/../../vendor/autoload.php';

(new Dotenv())->bootEnv(__DIR__.'/../../.env');

$env = $_SERVER['APP_ENV'] ?? 'dev';
$debug = (bool) ($_SERVER['APP_DEBUG'] ?? false);

/** @psalm-suppress TypeDoesNotContainType */
if (!is_string($env)) {
    throw new RuntimeException('APP_ENV environment variable is not a string.');
}

$kernel = new Kernel($env, $debug);
$kernel->boot();

/** @var non-empty-list<ManagerRegistry> $doctrineRegistries */
$doctrineRegistries = [
    $kernel->getContainer()->get('doctrine'),
    // $kernel->getContainer()->get('doctrine_mongodb'),
];

return new PhpStanObjectManager($doctrineRegistries);
