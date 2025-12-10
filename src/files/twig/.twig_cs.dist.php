<?php

declare(strict_types=1);

use FriendsOfTwig\Twigcs\Finder\TemplateFinder;
use FriendsOfTwig\Twigcs\Config\Config;

$symfonyTemplates = TemplateFinder::create()->in(__DIR__.'/templates');
// $finderB = Twigcs\Finder\TemplateFinder::create()->in(__DIR__.'/dirB');

return Config::create()
    // ...
    ->addFinder($symfonyTemplates)
    // ->addFinder($finderB)
    ->setName('my-config')
;
