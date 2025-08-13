<?php

declare(strict_types=1);

$finder = new TwigCsFixer\File\Finder();
$finder->in('.');
$finder->exclude('vendor-bin');
$finder->exclude('vendor');

$config = new TwigCsFixer\Config\Config();
$config->setFinder($finder);
$config->allowNonFixableRules();

return $config;
