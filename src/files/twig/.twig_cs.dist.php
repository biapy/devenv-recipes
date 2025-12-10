<?php

declare(strict_types=1);

use FriendsOfTwig\Twigcs;

$symfonyTemplates = Twigcs\Finder\TemplateFinder::create()->in(__DIR__.'/templates');
// $finderB = Twigcs\Finder\TemplateFinder::create()->in(__DIR__.'/dirB');

return Twigcs\Config\Config::create()
    // ...
    ->addFinder($symfonyTemplates)
    // ->addFinder($finderB)
    ->setName('my-config')
;