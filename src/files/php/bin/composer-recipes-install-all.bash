#!/usr/bin/env bash
# bin/composer-recipes-install-all.bash
#
# Install or re-install all composer recipes.
#
# It aims to ensure all recipes are up-to-date and properly configured.
#
# Use with caution in production environments,
# as this may overwrite existing configurations.

# Test if file is sourced.
# See https://stackoverflow.com/questions/2683279/how-to-detect-if-a-script-is-being-sourced
if ! (return 0 2>'/dev/null'); then
	# Apply The Sharat's recommendations
	# See [Shell Script Best Practices](https://sharats.me/posts/shell-script-best-practices/)
	set -o errexit
	set -o nounset
	set -o pipefail

	if [[ ${TRACE-0} == "1" ]]; then
		set -o xtrace
	fi
	# cd "${script_dir}"
fi

list-composer-recipes() {
	composer recipes |
		grep --fixed-strings ' * ' |
		head --lines=-2 |
		cut --delimiter=' ' --fields=3
}

install-composer-recipe() {
	local recipe_name="${1}"

	printf -v 'title' "Installing composer recipe: %s\n" "${recipe_name}"
	title_length="$(echo -n "${title}" | wc --bytes)"
	# Print title, with a line the length of the title of '=' below it
	printf '%s' "${title}"
	printf '=%.0s' $(seq "${title_length}")
	printf '\n\n'

	echo "Executing: composer 'recipes:install' --force --verbose '${recipe_name}'"

	composer 'recipes:install' --force --verbose "${recipe_name}"
}

composer-recipes-install-all() {
	if ! type -f composer >'/dev/null' 2>&1; then
		echo "Composer is not installed. Please install Composer to use this script."
		return 1
	fi

	if ! [[ -e 'composer.json' ]]; then
		echo "composer.json file not found. Please run this script in a Composer project directory."
		return 1
	fi

	list-composer-recipes |
		while read -r recipe; do
			if ! install-composer-recipe "${recipe}"; then
				echo "Failed to install recipe: ${recipe}. Aborting."
				return 1
			fi
		done

	echo "> All composer recipes have been installed or re-installed."
	echo "> Please review the changes before committing."
}

# Test if file is sourced.
# See https://stackoverflow.com/questions/2683279/how-to-detect-if-a-script-is-being-sourced
if ! (return 0 2>'/dev/null'); then
	# File is run as script. Call function as is.
	composer-recipes-install-all "${@}"
	exit ${?}
fi
