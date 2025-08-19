<?php

/**
 * PHP Coding Standards Fixer configuration file.
 *
 * @see https://github.com/PHP-CS-Fixer/PHP-CS-Fixer
 */
$finder = PhpCsFixer\Finder::create()
    ->exclude('var')
    ->exclude('node_modules')
    ->exclude('vendor')
    ->exclude('vendor-bin')
    ->exclude('assets/vendor')
    // ->notPath('src/Symfony/Component/Translation/Tests/fixtures/resources.php')
    ->in(__DIR__)
;

$config = new PhpCsFixer\Config();
$config->setParallelConfig(PhpCsFixer\Runner\Parallel\ParallelConfigFactory::detect());

$config->setRules([
    '@PSR12' => true,
    '@Symfony' => true,
    //        'strict_param' => true,
    'array_syntax' => ['syntax' => 'short'],
    'phpdoc_to_comment' => [
        'ignored_tags' => [
            'SuppressWarnings',
            'psalm-suppress',
            'psalm-assert',
            'phan-assert',
            'var',
            'psalm-var',
            'phpstan-var',
            'phan-var',
            'method',
            'phpstan-ignore-nextline',
            'phpstan-ignore-line',
            'phan-suppress-next-line',
            'phan-suppress-current-line',
        ],
    ],
    'phpdoc_separation' => [
        'groups' => [
            ['deprecated', 'link', 'see', 'since'],
            ['author', 'copyright', 'license'],
            ['category', 'package', 'subpackage'],
            ['property', 'property-read', 'property-write'],
            ['var', 'phpstan-var', 'psalm-var', 'phan-var'],
            ['param', 'param-out', 'phpstan-param', 'psalm-param', 'phan-param'],
            ['return', 'phpstan-return', 'psalm-return', 'phan-return'],
            [
                'template',
                'template-covariant',
                'phpstan-template',
                'psalm-template',
            ],
            ['psalm-require-implements'],
            ['psalm-require-extends'],
            ['extends', 'phpstan-extends', 'psalm-extends'],
            ['implements', 'phpstan-implements', 'psalm-implements', 'template-implements'],
            [
                'assert',
                'phpstan-assert',
                'phpstan-assert-if-true',
                'phpstan-assert-if-false',
                'psalm-assert',
                'psalm-assert-if-true',
                'psalm-assert-if-false',
                'phan-assert',
                'phan-assert-true-condition',
                'phan-assert-false-condition',
                'psalm-if-this-is',
                'psalm-this-out',
            ],
            [
                'suppress',
                'psalm-suppress',
                'phan-suppress',
                'SuppressWarnings',
                'phpstan-ignore',
                'phpstan-ignore-next-line',
                'phpstan-ignore-line',
            ],
        ],
    ],
]);

$config->setFinder($finder);

return $config;
