{
  pkgs,
  config,
  ...
}:
let
  utils = import ../utils;
  working-dir = "${config.env.DEVENV_ROOT}";
  composer-bin = "${config.languages.php.packages.composer}/bin/composer";
  composer-json = ''
    {
        "require-dev": {
            "phpmd/phpmd": "@stable"
        },
        "scripts": {
            "post-install-cmd": [
                "@install-link"
            ],
            "install-link": [
                "test -e '../../vendor/bin/phpmd' || ln --symbolic ../../vendor-bin/phpmd/vendor/bin/phpmd ../../vendor/bin/phpmd"
            ]
        },
        "scripts-descriptions": {
            "install-link": "Install composer bin link"
        }
    }
  '';
  config-file = ''
    <?xml version="1.0"?>
    <ruleset name="Symfony PHP CS fixer compatible ruleset"
        xmlns="http://pmd.sf.net/ruleset/1.0.0"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://pmd.sf.net/ruleset/1.0.0 http://pmd.sf.net/ruleset_xml_schema.xsd"
        xsi:noNamespaceSchemaLocation="
                        http://pmd.sf.net/ruleset_xml_schema.xsd">
        <description>
            PHP Mess Detector ruleset compatible with PHP CS Fixer Symfony rules.
        </description>

        <!-- Exclude vendor directory -->
        <exclude-pattern>*/vendor/*</exclude-pattern>
        <!-- Exclude migrations directory -->
        <exclude-pattern>*/migrations/*</exclude-pattern>

        <rule ref="rulesets/cleancode.xml">
            <exclude name="MissingImport" />
            <exclude name="StaticAccess" />
        </rule>
        <rule ref="rulesets/codesize.xml">
            <exclude name="TooManyMethods" />
            <exclude name="TooManyPublicMethods" />
        </rule>
        <rule ref="rulesets/codesize.xml/TooManyMethods">
            <properties>
                <property name="ignorepattern" description="Ignore methods matching this regex"
                    value="(^(set|get|is|has|with|test))i" />
            </properties>
        </rule>
        <rule ref="rulesets/codesize.xml/TooManyPublicMethods">
            <properties>
                <property name="ignorepattern" description="Ignore methods matching this regex"
                    value="(^(set|get|test))i" />
            </properties>
        </rule>
        <rule ref="rulesets/design.xml">
            <exclude name="CouplingBetweenObjects" />
        </rule>
        <rule ref="rulesets/controversial.xml" />
        <rule ref="rulesets/unusedcode.xml" />
        <!--rule
        ref="rulesets/naming.xml" /-->
        <rule ref="rulesets/cleancode.xml/MissingImport">
            <properties>
                <property name="ignore-global" value="true" />
            </properties>
        </rule>
        <rule ref="rulesets/cleancode.xml/StaticAccess">
            <properties>
                <property name="exceptions"
                    value="DateTime,DateTimeImmutable,DateInterval,IntlDateFormatter,Mockery,Symfony\Component\Uid\Uuid,Symfony\Component\Filesystem\Path,\Symfony\Component\Mime\Address,Symfony\Component\Form\ChoiceList\ChoiceList,\Behat\Transliterator\Transliterator,\Gedmo\Sluggable\Util\Urlizer,\Pagerfanta\Pagerfanta,\PhpOffice\PhpSpreadsheet\Shared\Date" />
                <property name="ignorepattern"
                    value="/^(castFrom|PHPToExcel|fromLockableObjectAndUser|from|tryFrom|cases|forChoice|fromData)$/" />
            </properties>
        </rule>
        <rule ref="rulesets/design.xml/CouplingBetweenObjects">
            <properties>
                <property name="maximum" value="17" />
            </properties>
        </rule>
    </ruleset>
  '';
in
{
  imports = [
    ../gnu-parallel.nix
    ./composer-bin.nix
  ];

  # https://devenv.sh/tasks/
  tasks = {
    "devenv-recipes:enterShell:initialize:phpmd:composer.json" = {
      description = "Initialize PHP Mess Detector composer.json";
      before = [ "devenv:enterShell" ];
      exec = (utils.tasks.initializeFile "vendor-bin/phpmd/composer.json" composer-json);
    };

    "devenv-recipes:enterShell:initialize:phpmd:configuration" = {
      description = "Initialize PHP Mess Detector configuration file";
      before = [ "devenv:enterShell" ];
      exec = (utils.tasks.initializeFile "phpmd.xml.dist" config-file);
    };

    "devenv-recipes:enterShell:install:phpmd" = (
      utils.composer-bin.installTask "PHP Mess Detector" "phpmd"
    );

    "ci:lint:phpmd" = {
      description = "Lint 'src' and 'tests' with PHP Mess Detector";
      exec = ''
        set -o 'errexit'
        cd '${working-dir}'
        '${config.languages.php.package}/bin/php' -d 'error_reporting=~E_DEPRECATED' '${working-dir}/vendor/bin/phpmd' '${working-dir}/'{src,tests} 'ansi' '${working-dir}/phpmd.xml.dist'
      '';
    };
  };

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.phpmd = rec {
    enable = true;
    name = "PHP Mess Detector";
    inherit (config.languages.php) package;
    extraPackages = [ pkgs.parallel ];
    entry = "'${pkgs.parallel}/bin/parallel' '${package}/bin/php' -d 'error_reporting=~E_DEPRECATED' '${working-dir}/vendor/bin/phpmd' {} 'ansi' '${working-dir}/phpmd.xml.dist' ::: ";
  };

  # See full reference at https://devenv.sh/reference/options/
}
