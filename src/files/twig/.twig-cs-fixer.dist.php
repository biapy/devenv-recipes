<?php

use TwigCsFixer\File\Finder;
use TwigCsFixer\Ruleset\Ruleset;
use TwigCsFixer\Standard\TwigCsFixer;
use TwigCsFixer\Config\Config;

$finder = new Finder();
// $finder->in('src');
$finder->in('templates');
// $finder->exclude('bundles');

$ruleset = new Ruleset();

// You can start from a default standard
$ruleset->addStandard(new TwigCsFixer());

// And then add/remove/override some rules
// $ruleset->addRule(new TwigCsFixer\Rules\File\FileExtensionRule());
// $ruleset->removeRule(TwigCsFixer\Rules\Whitespace\EmptyLinesRule::class);
// $ruleset->overrideRule(new TwigCsFixer\Rules\Punctuation\PunctuationSpacingRule(
//     ['}' => 1],
//     ['{' => 1],
// ));

$config = new Config();
$config->setRuleset($ruleset);
$config->setFinder($finder);
$config->allowNonFixableRules();

return $config;
